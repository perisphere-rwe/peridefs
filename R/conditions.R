# Function factories and condition-specific wrapper functions.
#
# Factories are defined first (used by both conditions.R and drugs.R).
# get_*_vX_codes() / get_*_vX_defs() functions are defined below, one pair
# per versioned spec object.

# ---- Internal helpers ---

# Resolve and validate a named component from a CompositeCodeSpec.
.get_condition_component <- function(spec, component, variable_type) {
  .resolve_component(spec$components(), component, spec$label)
}

# Resolve and validate a named component from a CompositeDrugSpec.
.get_drug_component <- function(spec, component) {
  .resolve_component(spec$components(), component, spec$label)
}

# --- Condition factories ---

# `composite = FALSE` tells the factory which function signature to return without
# forcing `spec` at source time. R lazy-loads data AFTER sourcing R files, so
# accessing `spec` in the factory outer body causes "object not found" errors.
# With this flag, `spec` remains a promise and is only forced at call time.

#' @noRd
make_code_getter <- function(spec, composite = FALSE) {

  # Shared implementation; component is only passed for composite specs.
  .impl <- function(code_type, vt, fmt, periods, concatenate, component = NULL) {
    fetch_list <- function(vt_inner, comp = component) {
      if (!is.null(comp)) {
        spec$get_codes(component = comp, code_type = code_type,
                       variable_type = vt_inner, periods = periods, format = "list")
      } else {
        spec$get_codes(code_type = code_type, variable_type = vt_inner,
                       periods = periods, format = "list")
      }
    }

    multi <- !is.null(component) && !identical(component, "all") && length(component) > 1L

    fetch <- function(vt_inner) {
      if (multi) {
        .union_code_lists(lapply(component, function(comp) fetch_list(vt_inner, comp)))
      } else {
        fetch_list(vt_inner)
      }
    }

    result <- fetch(vt)

    effective_vt <- vt
    if (vt == "outcome" && .result_is_empty(result, "list")) {
      result       <- fetch("condition")
      effective_vt <- "condition"
    }

    if (identical(fmt, "tibble")) {
      rows <- lapply(names(result), function(k) {
        cd <- result[[k]]
        if (!length(cd)) return(NULL)
        tibble::tibble(code_type = k, code = cd, variable_type = effective_vt)
      })
      return(do.call(rbind, Filter(Negate(is.null), rows)))
    }

    if (concatenate) unlist(result, use.names = FALSE) else result
  }

  if (composite) {
    function(code_type     = NULL,
             variable_type = c("condition", "outcome"),
             periods       = FALSE,
             format        = c("list", "tibble"),
             component,
             concatenate   = FALSE) {
      vt  <- match.arg(variable_type)
      fmt <- match.arg(format)
      if (concatenate && identical(fmt, "tibble")) {
        cli::cli_abort(
          "{.arg concatenate} = TRUE is not compatible with {.arg format} = {.val tibble}."
        )
      }
      if (missing(component)) {
        cli::cli_abort(c(
          "{.arg component} is required for composite specs.",
          "i" = "Use {.val all} to union all components, or specify one: {.val {names(spec$components())}}",
          "i" = "Print {.code {spec$condition}} spec to see all options."
        ))
      }
      .validate_components(component, spec)
      .impl(code_type, vt, fmt, periods, concatenate, component)
    }
  } else {
    function(code_type     = NULL,
             variable_type = c("condition", "outcome"),
             periods       = FALSE,
             format        = c("list", "tibble"),
             concatenate   = FALSE) {
      vt  <- match.arg(variable_type)
      fmt <- match.arg(format)
      if (concatenate && identical(fmt, "tibble")) {
        cli::cli_abort(
          "{.arg concatenate} = TRUE is not compatible with {.arg format} = {.val tibble}."
        )
      }
      .impl(code_type, vt, fmt, periods, concatenate)
    }
  }
}

#' @noRd
make_def_getter <- function(spec, composite = FALSE) {
  if (composite) {
    function(variable_type = c("condition", "outcome"), component) {
      vt <- match.arg(variable_type)
      if (missing(component)) {
        cli::cli_abort(c(
          "{.arg component} is required for composite specs.",
          "i" = "Available: {.val {names(spec$components())}}"
        ))
      }
      cd <- .get_condition_component(spec, component, vt)
      .render_def(cd$get_defs(variable_type = vt))
    }
  } else {
    function(variable_type = c("condition", "outcome")) {
      .render_def(spec$get_defs(variable_type = match.arg(variable_type)))
    }
  }
}

# --- Drug factories ---

#' @noRd
make_generic_getter <- function(spec, composite = FALSE) {
  if (composite) {
    function(component, concatenate = FALSE) {
      if (missing(component)) {
        cli::cli_abort(c(
          "{.arg component} is required for composite specs.",
          "i" = "Use {.val all} to union all components, or specify one: {.val {names(spec$components())}}"
        ))
      }
      .validate_components(component, spec)
      comps  <- if (identical(component, "all")) names(spec$components()) else component
      result <- lapply(stats::setNames(comps, comps),
                       function(comp) spec$get_generics(component = comp))
      if (concatenate) unlist(result, use.names = FALSE) else result
    }
  } else {
    function(concatenate = FALSE) {
      key    <- paste(spec$drug_class, spec$version, sep = "_")
      result <- stats::setNames(list(spec$get_generics()), key)
      if (concatenate) unlist(result, use.names = FALSE) else result
    }
  }
}

#' @noRd
make_ndc_getter <- function(spec, composite = FALSE) {
  if (composite) {
    function(component, concatenate = FALSE) {
      if (missing(component)) {
        cli::cli_abort(c(
          "{.arg component} is required for composite specs.",
          "i" = "Use {.val all} to union all components, or specify one: {.val {names(spec$components())}}"
        ))
      }
      .validate_components(component, spec)
      comps  <- if (identical(component, "all")) names(spec$components()) else component
      result <- lapply(stats::setNames(comps, comps),
                       function(comp) spec$get_codes(component = comp))
      if (concatenate) unlist(result, use.names = FALSE) else result
    }
  } else {
    function(concatenate = FALSE) {
      key    <- paste(spec$drug_class, spec$version, sep = "_")
      result <- stats::setNames(list(spec$get_codes()), key)
      if (concatenate) unlist(result, use.names = FALSE) else result
    }
  }
}

#' @noRd
make_drug_def_getter <- function(spec, composite = FALSE) {
  if (composite) {
    function(component) {
      if (missing(component)) {
        cli::cli_abort(c(
          "{.arg component} is required for composite specs.",
          "i" = "Use {.val all} to union all components, or specify one: {.val {names(spec$components())}}"
        ))
      }
      .validate_components(component, spec)
      if (!identical(component, "all") && length(component) > 1L) {
        return(lapply(stats::setNames(component, component),
                      function(comp) spec$get_defs(component = comp)))
      }
      spec$get_defs(component = component)
    }
  } else {
    function() spec$get_defs()
  }
}

# ---- Hypertension -------------------------------------------------------

#' Retrieve ICD codes for hypertension
#'
#' @description
#' Returns code sets from a hypertension [CodeSpec].
#' Two versions are available:
#' - **v1** (diagnosis only): `get_htn_v1_codes()`
#' - **v2** (diagnosis + medication): `get_htn_v2_codes()`
#'
#' @param code_type Optional character vector of code types to return.
#'   Valid values: `"dx_icd9"`, `"dx_icd10"`, `"proc_icd9"`, `"proc_icd10"`,
#'   `"hcpcs"`, `"cpt"`, `"rev"`. `NULL` (default) returns all code types.
#' @param variable_type `"condition"` (default) or `"outcome"`. Hypertension
#'   is defined as a condition only; `"outcome"` falls back to condition codes.
#' @param periods Logical. `FALSE` (default) returns short-format codes
#'   (e.g., `"4010"`). `TRUE` returns decimal-format codes (e.g., `"401.0"`).
#' @param format `"list"` (default) returns a named list of character vectors.
#'   `"tibble"` returns a long-form tibble with columns `code_type`, `code`,
#'   and `variable_type`.
#' @param component Not used for non-composite specs. Pass `NULL` (default).
#' @param concatenate Logical. `FALSE` (default) returns a named list of
#'   character vectors. `TRUE` concatenates all code vectors into a single
#'   unnamed character vector. Not compatible with `format = "tibble"`.
#' @return Named list, character vector (if `concatenate = TRUE`), or tibble of codes.
#' @seealso [get_htn_v1_defs()], [get_htn_v2_codes()], \code{spec_htn_v1}
#' @examples
#' get_htn_v1_codes()
#' get_htn_v1_codes(code_type = "dx_icd10", periods = TRUE)
#' @export
get_htn_v1_codes <- make_code_getter(spec_htn_v1)

#' Retrieve the narrative algorithm description for hypertension (v1)
#'
#' @param variable_type `"condition"` (default) or `"outcome"`.
#' @param component Not used. Pass `NULL` (default).
#' @return Character string, or `NULL`.
#' @seealso [get_htn_v1_codes()]
#' @examples
#' get_htn_v1_defs()
#' @export
get_htn_v1_defs <- make_def_getter(spec_htn_v1)

#' @rdname get_htn_v1_codes
#' @seealso [get_htn_v2_defs()], [get_htn_v1_codes()], \code{spec_htn_v2}
#' @export
get_htn_v2_codes <- make_code_getter(spec_htn_v2)

#' @rdname get_htn_v1_defs
#' @seealso [get_htn_v2_codes()]
#' @export
get_htn_v2_defs <- make_def_getter(spec_htn_v2)

# ---- Heart Failure -------------------------------------------------------

#' Retrieve ICD codes for heart failure
#'
#' @description
#' Returns code sets from the heart failure [CodeSpec] (`spec_hf_v1`).
#' Heart failure is both a condition and an outcome definition.
#'
#' @inheritParams get_htn_v1_codes
#' @seealso [get_hf_v1_defs()], \code{spec_hf_v1}
#' @examples
#' get_hf_v1_codes()
#' get_hf_v1_codes(variable_type = "outcome")
#' @export
get_hf_v1_codes <- make_code_getter(spec_hf_v1)

#' Retrieve the narrative algorithm description for heart failure (v1)
#'
#' @param variable_type `"condition"` (default) or `"outcome"`.
#' @param component Not used. Pass `NULL` (default).
#' @return Character string, or `NULL`.
#' @seealso [get_hf_v1_codes()]
#' @export
get_hf_v1_defs <- make_def_getter(spec_hf_v1)

# ---- ASCVD (Composite) --------------------------------------------------

#' Retrieve codes for a named ASCVD component
#'
#' @description
#' `spec_ascvd` is a [CompositeCodeSpec] containing all versioned components
#' used across ASCVD definitions:
#' `chd_v1`, `chd_v2`, `stroke_v1`, `cerebrovasc_disease_v1`.
#'
#' The `component` argument is **required**. Print `spec_ascvd` to see all
#' available component names.
#'
#' @inheritParams get_htn_v1_codes
#' @param component **Required.** Component name, e.g. `"chd_v1"`,
#'   `"stroke_v1"`, `"isch_stroke_v1"`, `"hf_v1"`, `"cerebrovasc_disease_v1"`.
#' @seealso [get_ascvd_defs()], \code{spec_ascvd}
#' @examples
#' get_ascvd_codes(component = "chd_v1")
#' get_ascvd_codes(component = "stroke_v1", variable_type = "outcome")
#'
#' # See all available components
#' spec_ascvd
#' @export
get_ascvd_codes <- make_code_getter(spec_ascvd, composite = TRUE)

#' Retrieve the narrative algorithm description for an ASCVD component
#'
#' @param variable_type `"condition"` (default) or `"outcome"`.
#' @param component **Required.** Component name. See [get_ascvd_codes()].
#' @seealso [get_ascvd_codes()], \code{spec_ascvd}
#' @export
get_ascvd_defs <- make_def_getter(spec_ascvd, composite = TRUE)

# ---- Obesity ------------------------------------------------------------

#' Retrieve ICD codes for obesity
#'
#' @description
#' Returns code sets from the obesity [CodeSpec] (`spec_obesity_v1`).
#' Condition only — no outcome definition.
#'
#' @inheritParams get_htn_v1_codes
#' @seealso [get_obesity_v1_defs()], \code{spec_obesity_v1}
#' @examples
#' get_obesity_v1_codes()
#' @export
get_obesity_v1_codes <- make_code_getter(spec_obesity_v1)

#' @rdname get_obesity_v1_codes
#' @export
get_obesity_v1_defs <- make_def_getter(spec_obesity_v1)

# ---- Diabetes Mellitus --------------------------------------------------

#' Retrieve ICD codes for diabetes mellitus
#'
#' @description
#' Returns code sets from a diabetes [CodeSpec].
#' Three versions are available: `get_diabetes_v1_codes()`,
#' `get_diabetes_v2_codes()`, `get_diabetes_v3_codes()`.
#'
#' @inheritParams get_htn_v1_codes
#' @seealso [get_diabetes_v1_defs()], \code{spec_diabetes_v1}
#' @export
get_diabetes_v1_codes <- make_code_getter(spec_diabetes_v1)

#' @rdname get_diabetes_v1_codes
#' @seealso [get_diabetes_v1_defs()]
#' @export
get_diabetes_v1_defs <- make_def_getter(spec_diabetes_v1)

#' @rdname get_diabetes_v1_codes
#' @export
get_diabetes_v2_codes <- make_code_getter(spec_diabetes_v2)

#' @rdname get_diabetes_v1_codes
#' @export
get_diabetes_v2_defs <- make_def_getter(spec_diabetes_v2)

#' @rdname get_diabetes_v1_codes
#' @export
get_diabetes_v3_codes <- make_code_getter(spec_diabetes_v3)

#' @rdname get_diabetes_v1_codes
#' @export
get_diabetes_v3_defs <- make_def_getter(spec_diabetes_v3)

# ---- COPD ---------------------------------------------------------------

#' Retrieve ICD codes for COPD
#' @inheritParams get_htn_v1_codes
#' @seealso [get_copd_v1_defs()], \code{spec_copd_v1}
#' @export
get_copd_v1_codes <- make_code_getter(spec_copd_v1)

#' @rdname get_copd_v1_codes
#' @export
get_copd_v1_defs <- make_def_getter(spec_copd_v1)

# ---- Hyperlipidemia -----------------------------------------------------

#' Retrieve ICD codes for hyperlipidemia
#' @inheritParams get_htn_v1_codes
#' @seealso [get_hyperlipidemia_v1_defs()], \code{spec_hyperlipidemia_v1}
#' @export
get_hyperlipidemia_v1_codes <- make_code_getter(spec_hyperlipidemia_v1)

#' @rdname get_hyperlipidemia_v1_codes
#' @export
get_hyperlipidemia_v1_defs <- make_def_getter(spec_hyperlipidemia_v1)

# ---- Chronic Kidney Disease ---------------------------------------------

#' Retrieve ICD codes for chronic kidney disease
#' @inheritParams get_htn_v1_codes
#' @seealso [get_ckd_v1_defs()], \code{spec_ckd_v1}
#' @export
get_ckd_v1_codes <- make_code_getter(spec_ckd_v1)

#' @rdname get_ckd_v1_codes
#' @export
get_ckd_v1_defs <- make_def_getter(spec_ckd_v1)

# ---- Sleep Apnea --------------------------------------------------------

#' Retrieve ICD codes for sleep apnea
#' @inheritParams get_htn_v1_codes
#' @seealso [get_osa_v1_defs()], \code{spec_osa_v1}
#' @export
get_osa_v1_codes <- make_code_getter(spec_osa_v1)

#' @rdname get_osa_v1_codes
#' @export
get_osa_v1_defs <- make_def_getter(spec_osa_v1)

# ---- Obesity Hypoventilation Syndrome -----------------------------------

#' Retrieve ICD codes for obesity hypoventilation syndrome
#' @inheritParams get_htn_v1_codes
#' @seealso [get_ohs_v1_defs()], \code{spec_ohs_v1}
#' @examples
#' get_ohs_v1_codes()
#' @export
get_ohs_v1_codes <- make_code_getter(spec_ohs_v1)

#' @rdname get_ohs_v1_codes
#' @export
get_ohs_v1_defs <- make_def_getter(spec_ohs_v1)

# ---- Asthma -------------------------------------------------------------

#' Retrieve ICD codes for asthma
#' @inheritParams get_htn_v1_codes
#' @seealso [get_asthma_v1_defs()], \code{spec_asthma_v1}
#' @examples
#' get_asthma_v1_codes()
#' get_asthma_v1_codes(code_type = "dx_icd10")
#' @export
get_asthma_v1_codes <- make_code_getter(spec_asthma_v1)

#' @rdname get_asthma_v1_codes
#' @export
get_asthma_v1_defs <- make_def_getter(spec_asthma_v1)

# ---- Depression ---------------------------------------------------------

#' Retrieve ICD codes for depression
#'
#' @description
#' Returns code sets from a depression [CodeSpec].
#' Two versions are available:
#' - **v1** (diagnosis only): `get_depression_v1_codes()`
#' - **v2** (diagnosis + medication): `get_depression_v2_codes()`
#'
#' @inheritParams get_htn_v1_codes
#' @seealso [get_depression_v1_defs()], [get_depression_v2_codes()],
#'   \code{spec_depression_v1}
#' @examples
#' get_depression_v1_codes()
#' get_depression_v1_codes(code_type = "dx_icd10")
#' @export
get_depression_v1_codes <- make_code_getter(spec_depression_v1)

#' @rdname get_depression_v1_codes
#' @seealso [get_depression_v1_codes()]
#' @export
get_depression_v1_defs <- make_def_getter(spec_depression_v1)

#' @rdname get_depression_v1_codes
#' @seealso [get_depression_v2_defs()], [get_depression_v1_codes()],
#'   \code{spec_depression_v2}
#' @export
get_depression_v2_codes <- make_code_getter(spec_depression_v2)

#' @rdname get_depression_v1_codes
#' @seealso [get_depression_v2_codes()]
#' @export
get_depression_v2_defs <- make_def_getter(spec_depression_v2)
