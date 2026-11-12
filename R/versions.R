# Comparing and listing versions of condition definitions.

# Resolve one input to get_version_diffs() / list_versions() to a CodeSpec.
# Accepts a CodeSpec, or any exported condition getter (get_*_vN_codes() or
# get_*_vN_defs()). Factory-built getters keep their spec (and, for ASCVD
# component wrappers, their component name) in their enclosing environment.
.as_code_spec <- function(x, label = "input") {
  if (inherits(x, "CodeSpec")) return(x)

  spec <- NULL
  if (is.function(x)) {
    env <- environment(x)
    if (!is.null(env) && exists("spec", envir = env, inherits = FALSE)) {
      spec <- get("spec", envir = env)
      if (inherits(spec, "CompositeCodeSpec") &&
          exists("component", envir = env, inherits = FALSE)) {
        spec <- .resolve_component(spec$components(),
                                   get("component", envir = env), spec$label)
      }
    }
  } else {
    spec <- x
  }

  if (inherits(spec, "CodeSpec")) return(spec)
  if (inherits(spec, "CompositeCodeSpec")) {
    cli::cli_abort(c(
      "{.arg {label}} is a composite definition ({.val {spec$condition}}), which has no single version.",
      "i" = "Compare its components instead, e.g. {.fn get_chd_v1_codes}."
    ))
  }
  if (inherits(spec, c("DrugSpec", "CompositeDrugSpec"))) {
    cli::cli_abort("{.arg {label}} is a drug spec; only condition code sets can be compared.")
  }
  cli::cli_abort(c(
    "{.arg {label}} is not a peridefs condition definition.",
    "i" = "Pass functions like {.fn get_diabetes_type2_v1_codes} or spec objects like {.code spec_diabetes_type2_v1}."
  ))
}

# Numeric part of a version label ("v12" -> 12).
.version_number <- function(v) as.integer(sub("^v", "", v))

# Describe how one code's membership changes across the (sorted) versions.
.describe_change <- function(in_version, versions) {
  if (all(in_version)) return("unchanged")
  steps <- character()
  if (in_version[1L]) {
    prev <- TRUE
  } else {
    prev <- FALSE
  }
  for (i in seq_along(versions)[-1L]) {
    now <- in_version[i]
    if (!prev && now) steps <- c(steps, paste("added in", versions[i]))
    if (prev && !now) steps <- c(steps, paste("removed in", versions[i]))
    prev <- now
  }
  paste(steps, collapse = "; ")
}

# Normalise user-supplied versions (c("v1", "v2") or c(1, 2)) to "vN" labels.
.normalize_versions <- function(versions) {
  bad <- function() {
    cli::cli_abort(c(
      "{.arg versions} must be version labels like {.code c(\"v1\", \"v2\")} or numbers like {.code c(1, 2)}.",
      "x" = "Got {.val {as.character(versions)}}."
    ))
  }
  if (is.numeric(versions)) {
    if (anyNA(versions) || any(!is.finite(versions)) ||
        any(versions != round(versions)) || any(versions < 1)) bad()
    return(paste0("v", as.integer(versions)))
  }
  if (is.character(versions)) {
    v <- tolower(trimws(versions))
    if (anyNA(v) || !all(grepl("^v?[0-9]+$", v))) bad()
    return(paste0("v", as.integer(sub("^v", "", v))))
  }
  bad()
}

# Core comparison: a list of CodeSpecs (any order) -> diff tibble.
.diff_specs <- function(specs, variable_type, periods, changes_only) {
  versions <- vapply(specs, function(s) s$version, character(1L))
  ord      <- order(.version_number(versions))
  specs    <- specs[ord]
  versions <- versions[ord]

  sets <- lapply(specs, function(s) {
    s$get_codes(variable_type = variable_type, periods = periods, priority = NULL)
  })

  # Union of (type, code) pairs. Types in order of first appearance (oldest
  # version first); codes sorted within each type.
  all_rows <- do.call(rbind, lapply(sets, function(x) x[c("type", "code")]))
  all_rows <- unique(all_rows)
  type_lvls <- unique(all_rows$type)
  all_rows <- all_rows[order(match(all_rows$type, type_lvls),
                             all_rows$code, method = "radix"), , drop = FALSE]
  key <- paste(all_rows$type, all_rows$code, sep = "\r")

  membership <- lapply(sets, function(x) key %in% paste(x$type, x$code, sep = "\r"))
  names(membership) <- versions

  # Definition from the newest version that has the code (and a definition).
  definition <- rep(NA_character_, length(key))
  for (x in rev(sets)) {
    k    <- paste(x$type, x$code, sep = "\r")
    idx  <- match(key, k)
    fill <- is.na(definition) & !is.na(idx)
    definition[fill] <- x$definition[idx[fill]]
  }

  in_mat <- do.call(cbind, membership)
  change <- vapply(seq_len(nrow(in_mat)), function(i) {
    .describe_change(in_mat[i, ], versions)
  }, character(1L))

  out <- tibble::as_tibble(c(
    membership,
    list(code = all_rows$code, type = all_rows$type,
         definition = definition, change = change)
  ))

  if (isTRUE(changes_only)) out <- out[out$change != "unchanged", , drop = FALSE]
  out
}

#' Compare code sets across versions of a condition definition
#'
#' @description
#' Lines up the code sets of two or more versions of a condition so you can
#' see exactly which codes were added or removed between versions. Every
#' version stays available unchanged (e.g. `get_diabetes_type2_v1_codes()`
#' keeps returning the v1 codes after v2 is released); this function shows
#' how they differ. Codes of every type are compared (diagnosis, procedure,
#' HCPCS/CPT). Changes to the narrative algorithm (see the `get_*_defs()`
#' functions) are not.
#'
#' @param condition A single condition identifier, e.g. `"diabetes_type2"`.
#'   See [list_versions()] for the available conditions and versions.
#' @param versions The versions to compare, as labels (`c("v1", "v2")`) or
#'   numbers (`c(1, 2)`), in any order; at least two, each given once.
#'   `NULL` (default) compares every version of `condition`.
#' @param variable_type `"condition"` (default) or `"outcome"`: which
#'   definition's codes to compare. As in the `get_*_codes()` functions, a
#'   version with no outcome codes falls back to its condition codes.
#' @param periods Logical. `TRUE` returns decimal-format codes (e.g.
#'   `"250.00"`). Default `FALSE`.
#' @param changes_only Logical. `TRUE` drops codes that are in every
#'   compared version, leaving only the codes that changed. Default `FALSE`.
#' @param format `"tibble"` (default) or `"flextable"`. `"flextable"` returns
#'   a formatted table for reports (requires the \pkg{flextable} package):
#'   columns `definition`, `code`, one per version, `type`, `change`, with
#'   rows shaded like a GitHub diff (green: added; red: removed; grey:
#'   unchanged; yellow: the same in the first and last compared versions but
#'   changed in between, possible with three or more versions).
#'
#' @return For `format = "tibble"`, a tibble with one row per code that
#'   appears in any of the compared versions, and columns:
#'   - one logical column per version (e.g. `v1`, `v2`), oldest first:
#'     `TRUE` if the code is in that version;
#'   - `code`: the code;
#'   - `type`: the code type (e.g. `"dx_icd10"`);
#'   - `definition`: the code's description (from the newest version that
#'     contains it);
#'   - `change`: `"unchanged"`, or how membership changed across the compared
#'     versions, e.g. `"added in v2"` or `"added in v2; removed in v4"`.
#'
#'   Rows are ordered by code type, then code.
#'
#'   For `format = "flextable"`, a `flextable` object with the same rows.
#'
#' @seealso [list_versions()] to see which versions exist.
#' @examples
#' # Every version of type 2 diabetes
#' get_version_diffs("diabetes_type2")
#'
#' # Specific versions, by label or by number
#' get_version_diffs("diabetes_type2", versions = c("v1", "v2"))
#' get_version_diffs("diabetes_type2", versions = c(1, 2))
#'
#' # Only the codes that changed
#' get_version_diffs("diabetes_type2", c(1, 2), changes_only = TRUE)
#'
#' # As a formatted table
#' if (requireNamespace("flextable", quietly = TRUE)) {
#'   get_version_diffs("diabetes_type2", changes_only = TRUE, format = "flextable")
#' }
#' @export
get_version_diffs <- function(condition,
                              versions = NULL,
                              variable_type = c("condition", "outcome"),
                              periods = FALSE,
                              changes_only = FALSE,
                              format = c("tibble", "flextable")) {
  variable_type <- match.arg(variable_type)
  format        <- match.arg(format)
  if (format == "flextable") .check_flextable()
  if (missing(condition) || !is.character(condition) ||
      length(condition) != 1L || is.na(condition)) {
    cli::cli_abort(c(
      "{.arg condition} must be a single condition name, e.g. {.val diabetes_type2}.",
      "i" = "See {.fn list_versions} for the available conditions."
    ))
  }

  available <- list_versions(condition)

  if (is.null(versions)) {
    if (nrow(available) < 2L) {
      cli::cli_abort(c(
        "{.val {condition}} has only one version ({.val {available$version}}), so there is nothing to compare.",
        "i" = "See {.fn list_versions} for conditions with more than one version."
      ))
    }
    versions <- available$version
  } else {
    versions <- .normalize_versions(versions)
  }

  if (length(versions) < 2L) {
    cli::cli_abort("Supply at least two {.arg versions} to compare (got {length(versions)}).")
  }
  if (anyDuplicated(versions)) {
    dup <- unique(versions[duplicated(versions)])
    cli::cli_abort(c(
      "Each version may be given only once.",
      "x" = "{.val {dup}} {?was/were} supplied more than once."
    ))
  }
  unknown <- setdiff(versions, available$version)
  if (length(unknown)) {
    cli::cli_abort(c(
      "{.val {condition}} has no version{?s} {.val {unknown}}.",
      "i" = "Available: {.val {available$version}}."
    ))
  }

  ns <- asNamespace("peridefs")
  specs <- lapply(versions, function(v) {
    fn <- sub("\\(\\)$", "", available$codes_function[available$version == v])
    .as_code_spec(get(fn, envir = ns), fn)
  })

  out <- .diff_specs(specs, variable_type = variable_type, periods = periods,
                     changes_only = changes_only)
  if (format == "flextable") return(.version_diffs_flextable(out))
  out
}

#' List the versions of condition definitions
#'
#' @description
#' Shows every released version of each condition definition, the
#' functions that return it, and (for versions after v1) when and why it was
#' introduced. All listed versions remain available; see
#' [get_version_diffs()] to compare them.
#'
#' @param condition Optional character vector of condition identifiers (e.g.
#'   `"diabetes_type2"`). `NULL` (default) lists every condition.
#'
#' @return A tibble with columns `condition`, `version`, `label`,
#'   `codes_function`, `defs_function`, `n_codes` (number of codes in the
#'   condition definition), `date` and `summary` (from the version history;
#'   `NA` for v1).
#'
#' @examples
#' list_versions("diabetes_type2")
#' list_versions()
#' @export
list_versions <- function(condition = NULL) {
  # Scan the namespace (not just its exports) so this also works while
  # roxygen is generating docs from a not-yet-updated NAMESPACE.
  ns <- asNamespace("peridefs")
  fns <- ls(ns, pattern = "^get_.+_v[0-9]+_codes$")

  rows <- lapply(fns, function(fn) {
    s <- .as_code_spec(get(fn, envir = ns), fn)
    data.frame(
      condition      = s$condition,
      version        = s$version,
      label          = s$label,
      codes_function = paste0(fn, "()"),
      defs_function  = paste0(sub("_codes$", "_defs", fn), "()"),
      n_codes        = nrow(s$get_codes(variable_type = "condition", priority = NULL)),
      stringsAsFactors = FALSE
    )
  })
  out <- do.call(rbind, rows)

  if (!is.null(condition)) {
    unknown <- setdiff(condition, out$condition)
    if (length(unknown)) {
      cli::cli_abort(c(
        "Unknown condition{?s}: {.val {unknown}}.",
        "i" = "Available: {.val {sort(unique(out$condition))}}."
      ))
    }
    out <- out[out$condition %in% condition, , drop = FALSE]
  }

  log <- .version_log
  idx <- match(paste(out$condition, out$version), paste(log$condition, log$version))
  out$date    <- log$date[idx]
  out$summary <- log$summary[idx]

  out <- out[order(out$condition, .version_number(out$version), method = "radix"), , drop = FALSE]
  rownames(out) <- NULL
  tibble::as_tibble(out)
}
