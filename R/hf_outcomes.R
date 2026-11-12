# Classifying heart failure outcomes in claims data ---------------------------
#
# classify_hf_outcomes() applies a version's outcome rules to diagnosis-level
# claims. The rules are read from the version's outcome code table
# (get_hf_<version>_codes(variable_type = "outcome")), so the code set that
# analysts see and the logic that is applied cannot drift apart. Each version
# registers its own rule builder in `.hf_outcome_rules`; a later version adds
# a function here rather than changing an earlier one.
#
# Only dplyr verbs are used on `data`, so it works on local data frames and on
# lazy tables (duckdb, Spark via dbplyr) without collecting. The one exception
# is the validation queries, which pull back counts (and a handful of example
# rows when the prevalent-HF check fails).

# ---- Rules per version ------------------------------------------------------

# Everything a version's rules need, derived from its outcome code table:
#   all_codes        every code in the table (used for the prevalent-HF check)
#   incident_codes   codes that count as an incident event on their own
#                    (required_secondary == "none": every I50 code in v2)
#   primary_alone    codes that qualify an acute hospitalization as the primary
#                    diagnosis with nothing else required
#   primary_with     named list: for each distinct `required_secondary` value,
#                    list(codes = ..., prefixes = ...). The claim needs one
#                    non-primary diagnosis starting with each prefix.
.hf_outcome_rules <- list(
  v2 = function(codes) {
    needed <- c("code", "required_secondary", "qualifies_as_primary")
    if (!all(needed %in% names(codes))) {
      cli::cli_abort(c(
        "The heart failure v2 outcome code table is missing columns {.field {setdiff(needed, names(codes))}}.",
        "i" = "Rebuild the package data with {.code source(\"data-raw/build_specs.R\")}."
      ))
    }
    none <- codes$required_secondary == "none"
    with <- codes[!none, , drop = FALSE]
    spec_values <- unique(with$required_secondary)
    list(
      all_codes      = codes$code,
      incident_codes = codes$code[none],
      primary_alone  = codes$code[none & codes$qualifies_as_primary],
      primary_with   = stats::setNames(lapply(spec_values, function(s) {
        list(
          codes    = with$code[with$required_secondary == s],
          # "I50.x + N18.x" -> c("I50", "N18")
          prefixes = sub("\\.x$", "", strsplit(s, " + ", fixed = TRUE)[[1L]])
        )
      }), spec_values)
    )
  }
)

.hf_rules_for <- function(version) {
  version <- tolower(trimws(as.character(version)))
  if (length(version) != 1L || is.na(version) || !grepl("^v?[0-9]+$", version)) {
    cli::cli_abort("{.arg version} must be a single version label like {.val v2} or a number like {.val 2}.")
  }
  version <- sub("^v?", "v", version)
  if (!version %in% names(.hf_outcome_rules)) {
    cli::cli_abort(c(
      "No heart failure outcome rules exist for version {.val {version}}.",
      "i" = "Supported versions: {.val {names(.hf_outcome_rules)}}."
    ))
  }
  getter <- get0(paste0("get_hf_", version, "_codes"), envir = asNamespace("peridefs"),
                 mode = "function", inherits = FALSE)
  if (is.null(getter)) {
    cli::cli_abort("Could not find {.fn get_hf_{version}_codes}.")
  }
  rules <- .hf_outcome_rules[[version]](getter(variable_type = "outcome"))
  rules$version <- version
  rules
}

# ---- Validation --------------------------------------------------------------

.hf_check_flag <- function(x, arg) {
  if (!is.logical(x) || length(x) != 1L || is.na(x)) {
    cli::cli_abort("{.arg {arg}} must be {.code TRUE} or {.code FALSE}.")
  }
}

.hf_check_string <- function(x, arg) {
  if (!is.character(x) || length(x) != 1L || is.na(x) || !nzchar(x)) {
    cli::cli_abort("{.arg {arg}} must be a single non-empty string.")
  }
}

.hf_scalar <- function(df, name) {
  v <- dplyr::pull(dplyr::collect(df), name)
  as.numeric(v)
}

# Errors if any heart failure claim (any code in the outcome code table, any
# position, any setting) falls strictly before the patient's reference date.
.hf_assert_no_prior_hf <- function(d, rules) {
  prior <- dplyr::filter(
    d,
    .data$claim_date < .data$ref_date,
    .data$dx_code %in% !!rules$all_codes
  )
  counts <- prior |>
    dplyr::distinct(.data$patient_id, .data$claim_id) |>
    dplyr::summarise(n_patients = dplyr::n_distinct(.data$patient_id),
                     n_claims = dplyr::n())
  counts <- dplyr::collect(counts)
  n_patients <- as.numeric(counts$n_patients)
  n_claims   <- as.numeric(counts$n_claims)
  if (n_claims == 0) return(invisible(NULL))

  ex <- prior |>
    dplyr::distinct(.data$patient_id, .data$claim_id, .data$claim_date, .data$dx_code) |>
    dplyr::arrange(.data$patient_id, .data$claim_date, .data$claim_id, .data$dx_code) |>
    utils::head(5L) |>
    dplyr::collect()
  shown <- paste0("patient ", ex$patient_id, ", claim ", ex$claim_id, " on ",
                  format(ex$claim_date), ": ", ex$dx_code)
  names(shown) <- rep("*", length(shown))

  cli::cli_abort(
    c(
      paste0(
        "Found {n_claims} heart failure claim{?s} from {n_patients} patient{?s} ",
        "before {.arg col_ref_date}."
      ),
      "i" = paste0(
        "With {.code exclude_prevalent_hf = TRUE}, the input must not contain heart ",
        "failure claims before the reference date ({.val {rules$version}} outcome codes, ",
        "any position and setting)."
      ),
      "i" = "Examples (up to 5):",
      shown,
      "i" = paste0(
        "Remove patients with prior heart failure before calling this function, or set ",
        "{.code exclude_prevalent_hf = FALSE} to allow them (e.g., for recurrent events)."
      )
    ),
    class = "peridefs_prior_hf_error"
  )
}

# ---- Main function -----------------------------------------------------------

#' Classify heart failure outcomes in claims data
#'
#' @description
#' Applies a version's heart failure outcome rules to diagnosis-level claims
#' and returns one row per event. The rules come from the version's outcome
#' code table (`get_hf_v2_codes(variable_type = "outcome")`), including its
#' `required_secondary` and `qualifies_as_primary` columns, so what analysts
#' see in the table is what is applied.
#'
#' Two outcomes are classified, both only from claims strictly after the
#' patient's reference date plus `min_event_days`:
#'
#' - `acute_hf_hospitalization`: an inpatient claim (`claim_setting` equal to
#'   any value of `inpatient_setting`) where either (a) the primary diagnosis is an acute
#'   or acute-on-chronic I50 code, or (b) the primary diagnosis is I11.0 and
#'   any I50 code is in a non-primary position, or the primary diagnosis is
#'   I13.0 or I13.2 and both an I50 and an N18 code are in non-primary
#'   positions.
#' - `incident_hf`: the first claim (any setting, any diagnosis position) with
#'   any I50 code. It is incident only if the cohort excludes patients with
#'   heart failure before the reference date; see `exclude_prevalent_hf`.
#'
#' The function does not remove prevalent heart failure, define the reference
#' date, or define follow-up windows. Those belong to cohort construction.
#'
#' @details
#' `data` can be a local data frame or a lazy table (e.g., duckdb or Spark
#' through dbplyr). Only dplyr verbs are applied, so lazy input stays lazy and
#' a lazy table is returned. The validation checks run small queries that
#' return counts (and, if the prevalent-HF check fails, a few example rows).
#' With `min_event_days > 0`, date arithmetic is translated by the backend, so
#' check it on backends other than duckdb.
#'
#' Diagnosis codes must be ICD-10-CM in short format, with no periods
#' (`"I5021"`, not `"I50.21"`); other codes simply do not match. Version `v2`
#' is ICD-10 only, so claims before October 1, 2015 cannot be classified.
#'
#' @param data A data frame or lazy table with one row per diagnosis per claim.
#' @param col_ref_date Name of the column holding each patient's reference
#'   date, the date follow-up for events starts. Required. It should hold one
#'   date per patient, repeated on that patient's rows, with no missing values.
#' @param outcomes One or both of `"acute_hf_hospitalization"` and
#'   `"incident_hf"`.
#' @param version Heart failure definition version, e.g. `"v2"` or `2`.
#'   Only versions that define outcome rules are supported.
#' @param min_event_days Whole number of days, at least 0 (default `0L`). Only
#'   claims strictly after `col_ref_date + min_event_days` are classified.
#' @param exclude_prevalent_hf If `TRUE` (default) and `"incident_hf"` is
#'   requested, the function errors when the input has any heart failure claim
#'   (any code in the outcome code table, any position and setting) strictly
#'   before `col_ref_date`. This only checks claims present in `data`, so pass
#'   the pre-reference claims along; filtering them out first makes the check
#'   pass without proving anything. Set to `FALSE` to skip the check, e.g. for
#'   studies of recurrent heart failure events. The check is not run when
#'   only `"acute_hf_hospitalization"` is requested.
#' @param col_patient_id,col_claim_id Names of the patient and claim
#'   identifier columns. A claim is identified by the patient and claim IDs
#'   together.
#' @param col_dx_code Name of the column with ICD-10-CM diagnosis codes in
#'   short format (no periods).
#' @param col_dx_position Name of the integer column with the diagnosis
#'   position on the claim (`1` is primary).
#' @param col_claim_setting Name of the column with the claim setting.
#'   Acute hospitalizations are taken from claims whose setting is one of the
#'   values in `inpatient_setting`.
#' @param col_claim_date Name of the date column with the claim's start date
#'   (the admission date for inpatient claims, the visit date for others).
#' @param inpatient_setting One or more values of the claim setting column
#'   that identify overnight inpatient claims, e.g.
#'   `c("inpatient_a", "inpatient_b")` when inpatient stays are coded under
#'   several settings. Default `"inpatient"`.
#'
#' @return A data frame (or lazy table, for lazy input) with one row per
#'   event and columns `patient_id`, `outcome`, `claim_id`, `claim_date` and
#'   `qualifying_code`, always under these names regardless of the `col_*`
#'   arguments. A claim can appear once per outcome. For
#'   `acute_hf_hospitalization`, `qualifying_code` is the primary diagnosis
#'   code. For `incident_hf` there is at most one row per patient, the first
#'   claim by date (then claim ID), and `qualifying_code` is the first I50
#'   code on it alphabetically.
#'
#' @seealso [get_hf_v2_codes()]
#' @examples
#' claims <- data.frame(
#'   patient_id    = c(1, 1, 2, 2, 2),
#'   claim_id      = c("a", "b", "c", "c", "c"),
#'   claim_setting = c("outpatient", "inpatient", "inpatient", "inpatient", "inpatient"),
#'   claim_date    = as.Date(c("2024-01-10", "2024-03-01", rep("2024-02-05", 3))),
#'   ref_date      = as.Date("2024-01-01"),
#'   dx_position   = c(1, 1, 1, 2, 3),
#'   dx_code       = c("I509", "I5021", "I130", "I5022", "N184")
#' )
#' classify_hf_outcomes(claims, col_ref_date = "ref_date")
#' @importFrom rlang .data
#' @export
classify_hf_outcomes <- function(data,
                                 col_ref_date,
                                 outcomes = c("acute_hf_hospitalization", "incident_hf"),
                                 version = "v2",
                                 min_event_days = 0L,
                                 exclude_prevalent_hf = TRUE,
                                 col_patient_id = "patient_id",
                                 col_claim_id = "claim_id",
                                 col_dx_code = "dx_code",
                                 col_dx_position = "dx_position",
                                 col_claim_setting = "claim_setting",
                                 col_claim_date = "claim_date",
                                 inpatient_setting = "inpatient") {
  if (missing(col_ref_date)) {
    cli::cli_abort(c(
      "{.arg col_ref_date} is required.",
      "i" = "Give the name of the column with each patient's reference date (when follow-up for events starts)."
    ))
  }
  if (!inherits(data, c("data.frame", "tbl_lazy"))) {
    cli::cli_abort("{.arg data} must be a data frame or a lazy table, not {.cls {class(data)[1]}}.")
  }
  outcomes <- match.arg(outcomes, c("acute_hf_hospitalization", "incident_hf"),
                        several.ok = TRUE)
  outcomes <- unique(outcomes)
  if (!rlang::is_scalar_integerish(min_event_days) || is.na(min_event_days) ||
      min_event_days < 0) {
    cli::cli_abort("{.arg min_event_days} must be a single whole number, 0 or greater.")
  }
  min_event_days <- as.integer(min_event_days)
  .hf_check_flag(exclude_prevalent_hf, "exclude_prevalent_hf")
  if (!is.character(inpatient_setting) || length(inpatient_setting) == 0L ||
      anyNA(inpatient_setting) || !all(nzchar(inpatient_setting))) {
    cli::cli_abort("{.arg inpatient_setting} must be one or more non-empty strings.")
  }
  inpatient_setting <- unique(inpatient_setting)

  cols <- c(patient_id = col_patient_id, claim_id = col_claim_id,
            dx_code = col_dx_code, dx_position = col_dx_position,
            claim_setting = col_claim_setting, claim_date = col_claim_date,
            ref_date = col_ref_date)
  arg_names <- paste0("col_", names(cols))
  for (i in seq_along(cols)) .hf_check_string(cols[[i]], arg_names[i])
  if (anyDuplicated(unname(cols))) {
    dup <- unique(unname(cols)[duplicated(unname(cols))])
    cli::cli_abort("Each {.code col_*} argument must name a different column; {.val {dup}} is used more than once.")
  }
  absent <- cols[!cols %in% colnames(data)]
  if (length(absent)) {
    cli::cli_abort(c(
      "{.arg data} is missing {length(absent)} required column{?s}.",
      stats::setNames(
        paste0("{.field ", absent, "} (", paste0("{.arg ", arg_names[match(names(absent), names(cols))], "}"), ")"),
        rep("x", length(absent))
      )
    ))
  }

  rules <- .hf_rules_for(version)

  d <- dplyr::select(data, !!!stats::setNames(
    lapply(unname(cols), function(x) rlang::expr(dplyr::all_of(!!x))), names(cols)
  ))

  n_missing_ref <- .hf_scalar(
    dplyr::summarise(dplyr::filter(d, is.na(.data$ref_date)), n = dplyr::n()), "n"
  )
  if (n_missing_ref > 0) {
    cli::cli_abort(c(
      "{.arg col_ref_date} ({.field {col_ref_date}}) has {n_missing_ref} missing value{?s}.",
      "i" = "Every row needs a reference date."
    ))
  }

  if (exclude_prevalent_hf && "incident_hf" %in% outcomes) {
    .hf_assert_no_prior_hf(d, rules)
  }

  ev <- if (min_event_days == 0L) {
    dplyr::filter(d, .data$claim_date > .data$ref_date)
  } else {
    dplyr::filter(d, .data$claim_date > .data$ref_date + !!min_event_days)
  }

  pieces <- list()
  if ("acute_hf_hospitalization" %in% outcomes) {
    pieces$acute <- .hf_acute_hospitalizations(ev, rules, inpatient_setting)
  }
  if ("incident_hf" %in% outcomes) {
    pieces$incident <- .hf_incident(ev, rules)
  }

  out <- Reduce(dplyr::union_all, pieces)
  out <- dplyr::arrange(out, .data$patient_id, .data$claim_date, .data$claim_id, .data$outcome)
  if (is.data.frame(out)) out <- tibble::as_tibble(out)
  out
}

# ---- Outcome logic ------------------------------------------------------------

.hf_acute_hospitalizations <- function(ev, rules, inpatient_setting) {
  inp  <- dplyr::filter(ev, .data$claim_setting %in% !!inpatient_setting)
  prim <- dplyr::filter(inp, .data$dx_position == 1L)
  secondary <- dplyr::filter(inp, .data$dx_position != 1L)
  keys <- c("patient_id", "claim_id")

  pick <- function(x) {
    x |>
      dplyr::transmute(
        .data$patient_id, .data$claim_id, .data$claim_date,
        qualifying_code = .data$dx_code
      ) |>
      dplyr::distinct()
  }

  # (a) Primary diagnosis qualifies on its own.
  hits <- list(pick(dplyr::filter(prim, .data$dx_code %in% !!rules$primary_alone)))

  # (b) Primary diagnosis needs secondary codes (one per required prefix).
  for (r in rules$primary_with) {
    x <- dplyr::filter(prim, .data$dx_code %in% !!r$codes)
    for (p in r$prefixes) {
      has_p <- secondary |>
        dplyr::filter(substr(.data$dx_code, 1L, !!nchar(p)) == !!p) |>
        dplyr::distinct(.data$patient_id, .data$claim_id)
      x <- dplyr::semi_join(x, has_p, by = keys)
    }
    hits[[length(hits) + 1L]] <- pick(x)
  }

  Reduce(dplyr::union_all, hits) |>
    dplyr::distinct() |>
    dplyr::mutate(outcome = "acute_hf_hospitalization") |>
    dplyr::select("patient_id", "outcome", "claim_id", "claim_date", "qualifying_code")
}

# First qualifying claim per patient: earliest date, then smallest claim ID,
# then smallest code, using only portable group-wise min() so the result is
# deterministic on every backend.
.hf_incident <- function(ev, rules) {
  x <- dplyr::filter(ev, .data$dx_code %in% !!rules$incident_codes)

  narrow <- function(x, col) {
    # dplyr probes min() on an empty group when no rows qualify, which warns.
    first <- suppressWarnings(
      x |>
        dplyr::group_by(.data$patient_id) |>
        dplyr::summarise(.first = min(.data[[col]], na.rm = TRUE))
    )
    x |>
      dplyr::inner_join(first, by = "patient_id") |>
      dplyr::filter(.data[[col]] == .data$.first) |>
      dplyr::select(-".first")
  }
  x <- narrow(x, "claim_date")
  x <- narrow(x, "claim_id")
  x <- narrow(x, "dx_code")

  x |>
    dplyr::distinct(.data$patient_id, .data$claim_id, .data$claim_date, .data$dx_code) |>
    dplyr::transmute(
      .data$patient_id,
      outcome = "incident_hf",
      .data$claim_id, .data$claim_date,
      qualifying_code = .data$dx_code
    )
}
