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
  if (composite) {
    function(component     = NULL,
             code_type     = NULL,
             variable_type = c("condition", "outcome"),
             periods       = FALSE,
             priority      = 1L) {
      spec$get_codes(component = component, code_type = code_type,
                     variable_type = match.arg(variable_type),
                     periods = periods, priority = priority)
    }
  } else {
    function(code_type     = NULL,
             variable_type = c("condition", "outcome"),
             periods       = FALSE,
             priority      = 1L) {
      spec$get_codes(code_type = code_type,
                     variable_type = match.arg(variable_type),
                     periods = periods, priority = priority)
    }
  }
}

#' @noRd
make_def_getter <- function(spec, composite = FALSE) {
  if (composite) {
    function(variable_type = c("condition", "outcome"), component = NULL) {
      vt <- match.arg(variable_type)
      if (is.null(component) || identical(component, "all")) {
        return(spec$get_defs(component = component, variable_type = vt))
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
    function(component = NULL, priority = 1L, condition = NULL) {
      # Omit `condition` entirely (rather than forwarding NULL) when the
      # caller doesn't supply one, so the composite's own default (its
      # `condition` field) applies instead of being overridden.
      if (is.null(condition)) {
        spec$get_generics(component = component, priority = priority)
      } else {
        spec$get_generics(component = component, priority = priority, condition = condition)
      }
    }
  } else {
    function(priority = 1L) {
      spec$get_generics(priority = priority)
    }
  }
}

#' @noRd
make_meds_labels_getter <- function(spec) {
  function(component = NULL) {
    spec$get_meds_labels(component = component)
  }
}

# ---- Hypertension -------------------------------------------------------

#' Retrieve ICD codes for hypertension
#'
#' @description
#' Returns code sets from a hypertension [CodeSpec]. The condition
#' definition is diagnosis-based, with a medication criterion (see
#' `spec_hypertension`) as an alternative qualifying path.
#'
#' @param code_type Optional character vector of code types to return.
#'   Valid values: `"dx_icd9"`, `"dx_icd10"`, `"proc_icd9"`, `"proc_icd10"`,
#'   `"hcpcs"`, `"cpt"`, `"rev"`. `NULL` (default) returns all code types.
#' @param variable_type `"condition"` (default) or `"outcome"`. Hypertension
#'   is defined as a condition only; `"outcome"` falls back to condition codes.
#' @param periods Logical. `FALSE` (default) returns short-format codes
#'   (e.g., `"4010"`). `TRUE` returns decimal-format codes (e.g., `"401.0"`).
#' @param priority Integer vector subsetting confidence tiers to include
#'   (`1` = core, `2` = probable, `3` = cautious). Default `1`.
#' @return A tibble with columns `type`, `code`, `priority`, and `version`.
#' @seealso [get_hypertension_v1_defs()], \code{spec_hypertension_v1}
#' @examples
#' get_hypertension_v1_codes()
#' get_hypertension_v1_codes(code_type = "dx_icd10", periods = TRUE)
#' @export
get_hypertension_v1_codes <- make_code_getter(spec_hypertension_v1)

#' Retrieve the narrative algorithm description for hypertension (v1)
#'
#' @param variable_type `"condition"` (default) or `"outcome"`.
#' @return Character string, or `NULL`.
#' @seealso [get_hypertension_v1_codes()]
#' @examples
#' get_hypertension_v1_defs()
#' @export
get_hypertension_v1_defs <- make_def_getter(spec_hypertension_v1)

# ---- Heart Failure -------------------------------------------------------

#' Retrieve ICD codes for heart failure
#'
#' @description
#' Returns code sets from the heart failure [CodeSpec] (`spec_hf_v1`).
#' Heart failure is both a condition and an outcome definition.
#'
#' @inheritParams get_hypertension_v1_codes
#' @seealso [get_hf_v1_defs()], \code{spec_hf_v1}
#' @examples
#' get_hf_v1_codes()
#' get_hf_v1_codes(variable_type = "outcome")
#' @export
get_hf_v1_codes <- make_code_getter(spec_hf_v1)

#' Retrieve the narrative algorithm description for heart failure (v1)
#'
#' @param variable_type `"condition"` (default) or `"outcome"`.
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
#' `chd_v1`, `stroke_v1`, `cerebrovasc_disease_v1`.
#'
#' The `component` argument is optional; omit it (or pass `"all"`) to
#' retrieve every component at once, distinguished by the `class` column.
#' Print `spec_ascvd` to see all available component names.
#'
#' @inheritParams get_hypertension_v1_codes
#' @param component Optional component name(s), e.g. `"chd_v1"`,
#'   `"stroke_v1"`, `"isch_stroke_v1"`, `"hf_v1"`, `"cerebrovasc_disease_v1"`.
#'   `NULL` (default) or `"all"` returns every component.
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
#' @param component Optional component name. `NULL` (default) or `"all"`
#'   renders every component. See [get_ascvd_codes()].
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
#' @inheritParams get_hypertension_v1_codes
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
#' Returns code sets from a diabetes [CodeSpec]. The condition definition
#' is diagnosis-based, with a medication criterion (see
#' `spec_diabetes`) as an alternative qualifying path, and patients are
#' further classified into four mutually exclusive categories (no diabetes;
#' diabetes without antidiabetic medication; diabetes with oral
#' antidiabetic; diabetes with insulin).
#'
#' @inheritParams get_hypertension_v1_codes
#' @seealso [get_diabetes_v1_defs()], \code{spec_diabetes_v1}
#' @export
get_diabetes_v1_codes <- make_code_getter(spec_diabetes_v1)

#' @rdname get_diabetes_v1_codes
#' @seealso [get_diabetes_v1_defs()]
#' @export
get_diabetes_v1_defs <- make_def_getter(spec_diabetes_v1)

# ---- COPD ---------------------------------------------------------------

#' Retrieve ICD codes for COPD
#' @inheritParams get_hypertension_v1_codes
#' @seealso [get_copd_v1_defs()], \code{spec_copd_v1}
#' @export
get_copd_v1_codes <- make_code_getter(spec_copd_v1)

#' @rdname get_copd_v1_codes
#' @export
get_copd_v1_defs <- make_def_getter(spec_copd_v1)

# ---- Hyperlipidemia -----------------------------------------------------

#' Retrieve ICD codes for hyperlipidemia
#' @inheritParams get_hypertension_v1_codes
#' @seealso [get_hyperlipidemia_v1_defs()], \code{spec_hyperlipidemia_v1}
#' @export
get_hyperlipidemia_v1_codes <- make_code_getter(spec_hyperlipidemia_v1)

#' @rdname get_hyperlipidemia_v1_codes
#' @export
get_hyperlipidemia_v1_defs <- make_def_getter(spec_hyperlipidemia_v1)

# ---- Chronic Kidney Disease ---------------------------------------------

#' Retrieve ICD codes for chronic kidney disease
#' @inheritParams get_hypertension_v1_codes
#' @seealso [get_ckd_v1_defs()], \code{spec_ckd_v1}
#' @export
get_ckd_v1_codes <- make_code_getter(spec_ckd_v1)

#' @rdname get_ckd_v1_codes
#' @export
get_ckd_v1_defs <- make_def_getter(spec_ckd_v1)

# ---- Sleep Apnea --------------------------------------------------------

#' Retrieve ICD codes for sleep apnea
#' @inheritParams get_hypertension_v1_codes
#' @seealso [get_osa_v1_defs()], \code{spec_osa_v1}
#' @export
get_osa_v1_codes <- make_code_getter(spec_osa_v1)

#' @rdname get_osa_v1_codes
#' @export
get_osa_v1_defs <- make_def_getter(spec_osa_v1)

# ---- Obesity Hypoventilation Syndrome -----------------------------------

#' Retrieve ICD codes for obesity hypoventilation syndrome
#' @inheritParams get_hypertension_v1_codes
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
#' @inheritParams get_hypertension_v1_codes
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
#' Returns code sets from a depression [CodeSpec]. The condition
#' definition is diagnosis-based, with a medication criterion (see
#' `spec_depression`) as an alternative qualifying path.
#'
#' @inheritParams get_hypertension_v1_codes
#' @seealso [get_depression_v1_defs()], \code{spec_depression_v1}
#' @examples
#' get_depression_v1_codes()
#' get_depression_v1_codes(code_type = "dx_icd10")
#' @export
get_depression_v1_codes <- make_code_getter(spec_depression_v1)

#' @rdname get_depression_v1_codes
#' @seealso [get_depression_v1_codes()]
#' @export
get_depression_v1_defs <- make_def_getter(spec_depression_v1)


