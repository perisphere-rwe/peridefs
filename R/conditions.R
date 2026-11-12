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

# Getters for one named component of a composite (e.g. the ASCVD components).
# The returned function keeps `spec` and `component` in its environment, so
# get_version_diffs() can resolve it to the component's CodeSpec.

#' @noRd
make_component_code_getter <- function(spec, component) {
  force(component)
  getter <- make_code_getter(spec, composite = TRUE)
  function(...) getter(component = component, ...)
}

#' @noRd
make_component_def_getter <- function(spec, component) {
  force(component)
  getter <- make_def_getter(spec, composite = TRUE)
  function(...) getter(component = component, ...)
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
#' @return A tibble with columns `type`, `code`, `priority`, `version`, and `definition`.
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
#
# All versions share one help page (`?hf_codes`). See the type 2 diabetes
# block for how to add a version.

#' Heart failure code sets (all versions)
#'
#' @description
#' `get_hf_vN_codes()` returns the ICD code set for version N of the heart
#' failure definition, and `get_hf_vN_defs()` displays its narrative
#' algorithm. Heart failure is both a condition (history) and an outcome
#' definition: the condition definition counts inpatient or repeated
#' outpatient claims in any diagnosis position, while the outcome definition
#' requires an overnight hospitalization with a primary discharge diagnosis
#' of heart failure. Each version is frozen once released: later versions
#' never change what an earlier version's functions return.
#'
#' @section Versions:
#' \describe{
#'   \item{v1}{ICD-9 402.01, 402.11, 402.91, 404.01, 404.03, 404.11, 404.13,
#'   404.91, 404.93, 428.x; and ICD-10 I11.0, I13.0, I13.2, I50.x.}
#'   \item{v2}{ICD-10 only, so claims before October 1, 2015 cannot qualify.
#'   History uses every billable I50 code; I11.0, I13.0 and I13.2 are left
#'   out because they require a secondary I50.x on the same claim. Outcomes
#'   use all of those codes plus per-code columns that describe the rules
#'   (see below).}
#' }
#'
#' @section v2 outcome code attributes:
#' `get_hf_v2_codes(variable_type = "outcome")` has three extra columns, which
#' illustrate the outcome rules and are not applied by the package:
#' \describe{
#'   \item{`acuity`}{`"acute"`, `"acute_on_chronic"`, `"chronic"` or
#'   `"unspecified"` for I50 codes (including I50.814, I50.82, I50.83 and
#'   I50.84, whose descriptors give no acuity); `NA` for I11.0, I13.0 and
#'   I13.2.}
#'   \item{`required_secondary`}{Codes that must appear in non-primary
#'   positions: `"I50.x"` for I11.0, `"I50.x + N18.x"` for I13.0 and I13.2,
#'   otherwise `"none"`.}
#'   \item{`qualifies_as_primary`}{`TRUE` for the acute and acute-on-chronic
#'   I50 codes and for I11.0, I13.0 and I13.2 (subject to
#'   `required_secondary`). Chronic and unspecified I50 codes can be the
#'   secondary code, or count toward incident heart failure, but do not
#'   qualify as the primary diagnosis of an acute heart failure
#'   hospitalization.}
#' }
#'
#' @section Version history:
#' `r .rd_version_history("hf")`
#'
#' @inheritParams get_hypertension_v1_codes
#' @param variable_type `"condition"` (default) or `"outcome"`. Both are
#'   defined for heart failure; in v2 the outcome set also includes I11.0,
#'   I13.0 and I13.2.
#' @return `get_hf_vN_codes()`: a tibble with columns `type`, `code`,
#'   `priority`, `version`, and `definition` (plus `acuity`,
#'   `required_secondary` and `qualifies_as_primary` for v2 outcomes).
#'   `get_hf_vN_defs()`: the
#'   narrative definition (displayed, and returned invisibly), or `NULL`.
#' @seealso [get_version_diffs()], [list_versions()], \code{spec_hf_v1},
#'   \code{spec_hf_v2}
#' @examples
#' get_hf_v2_codes()
#' get_hf_v2_codes(variable_type = "outcome")
#' get_hf_v2_defs(variable_type = "outcome")
#'
#' # Codes that can be the primary diagnosis of an acute HF hospitalization
#' subset(get_hf_v2_codes(variable_type = "outcome"), qualifies_as_primary)
#'
#' # What changed from v1 to v2?
#' get_version_diffs("hf", versions = c(1, 2), changes_only = TRUE)
#' @name hf_codes
NULL

#' @rdname hf_codes
#' @export
get_hf_v1_codes <- make_code_getter(spec_hf_v1)

#' @rdname hf_codes
#' @export
get_hf_v1_defs <- make_def_getter(spec_hf_v1)

#' @rdname hf_codes
#' @export
get_hf_v2_codes <- make_code_getter(spec_hf_v2)

#' @rdname hf_codes
#' @export
get_hf_v2_defs <- make_def_getter(spec_hf_v2)

# ---- ASCVD (Composite) --------------------------------------------------

#' Retrieve codes for a named ASCVD component
#'
#' @description
#' `spec_ascvd` is a [CompositeCodeSpec] containing all versioned components
#' used across ASCVD definitions:
#' `chd_v1`, `stroke_v1`, `lead_pad_v1`, `cerebrovasc_disease_v1`.
#'
#' The `component` argument is optional; omit it (or pass `"all"`) to
#' retrieve the components that apply to `variable_type`, distinguished by
#' the `class` column. Per the definition book, the condition/history
#' definition is CHD + cerebrovascular disease + LEAD/PAD, while the outcome
#' definition is CHD + stroke + LEAD/PAD (`stroke_v1` and
#' `cerebrovasc_disease_v1` are never combined by default — pass an explicit
#' `component` to override this). Print `spec_ascvd` to see all available
#' component names and the default sets per `variable_type`.
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
#'   renders the components that apply to `variable_type`. See
#'   [get_ascvd_codes()].
#' @seealso [get_ascvd_codes()], \code{spec_ascvd}
#' @export
get_ascvd_defs <- make_def_getter(spec_ascvd, composite = TRUE)

# ---- ASCVD components (direct access) -----------------------------------
#
# Thin wrappers around get_ascvd_codes()/get_ascvd_defs() with `component`
# pinned, so each ASCVD component can be reached directly (e.g.
# get_stroke_v1_codes()) instead of requiring
# get_ascvd_codes(component = "stroke_v1"). Built with
# make_component_code_getter()/make_component_def_getter(); `...` forwards
# every other argument unchanged.

#' Retrieve ICD codes for coronary heart disease (CHD)
#'
#' @description
#' Direct access to the `chd_v1` component of `spec_ascvd`. Equivalent to
#' `get_ascvd_codes(component = "chd_v1", ...)`.
#'
#' @param ... Further arguments passed to the underlying ASCVD getter
#'   (e.g. `variable_type`). `component` is fixed and cannot be supplied.
#' @seealso [get_chd_v1_defs()], [get_ascvd_codes()], \code{spec_ascvd}
#' @examples
#' get_chd_v1_codes()
#' @export
get_chd_v1_codes <- make_component_code_getter(spec_ascvd, "chd_v1")

#' Retrieve the narrative algorithm description for coronary heart disease (CHD)
#'
#' @description
#' Direct access to the `chd_v1` component of `spec_ascvd`. Equivalent to
#' `get_ascvd_defs(component = "chd_v1", ...)`.
#'
#' @param ... Further arguments passed to the underlying ASCVD getter
#'   (e.g. `variable_type`). `component` is fixed and cannot be supplied.
#' @seealso [get_chd_v1_codes()], [get_ascvd_defs()], \code{spec_ascvd}
#' @export
get_chd_v1_defs <- make_component_def_getter(spec_ascvd, "chd_v1")

#' Retrieve ICD codes for stroke (any)
#'
#' @description
#' Direct access to the `stroke_v1` component of `spec_ascvd`. Equivalent to
#' `get_ascvd_codes(component = "stroke_v1", ...)`.
#'
#' @param ... Further arguments passed to the underlying ASCVD getter
#'   (e.g. `variable_type`). `component` is fixed and cannot be supplied.
#' @seealso [get_stroke_v1_defs()], [get_ascvd_codes()], \code{spec_ascvd}
#' @examples
#' get_stroke_v1_codes()
#' @export
get_stroke_v1_codes <- make_component_code_getter(spec_ascvd, "stroke_v1")

#' Retrieve the narrative algorithm description for stroke (any)
#'
#' @description
#' Direct access to the `stroke_v1` component of `spec_ascvd`. Equivalent to
#' `get_ascvd_defs(component = "stroke_v1", ...)`.
#'
#' @param ... Further arguments passed to the underlying ASCVD getter
#'   (e.g. `variable_type`). `component` is fixed and cannot be supplied.
#' @seealso [get_stroke_v1_codes()], [get_ascvd_defs()], \code{spec_ascvd}
#' @export
get_stroke_v1_defs <- make_component_def_getter(spec_ascvd, "stroke_v1")

#' Retrieve ICD codes for lower extremity artery disease (LEAD) / peripheral artery disease (PAD)
#'
#' @description
#' Direct access to the `lead_pad_v1` component of `spec_ascvd`. Equivalent
#' to `get_ascvd_codes(component = "lead_pad_v1", ...)`.
#'
#' @param ... Further arguments passed to the underlying ASCVD getter
#'   (e.g. `variable_type`). `component` is fixed and cannot be supplied.
#' @seealso [get_lead_pad_v1_defs()], [get_ascvd_codes()], \code{spec_ascvd}
#' @examples
#' get_lead_pad_v1_codes()
#' @export
get_lead_pad_v1_codes <- make_component_code_getter(spec_ascvd, "lead_pad_v1")

#' Retrieve the narrative algorithm description for LEAD/PAD
#'
#' @description
#' Direct access to the `lead_pad_v1` component of `spec_ascvd`. Equivalent
#' to `get_ascvd_defs(component = "lead_pad_v1", ...)`.
#'
#' @param ... Further arguments passed to the underlying ASCVD getter
#'   (e.g. `variable_type`). `component` is fixed and cannot be supplied.
#' @seealso [get_lead_pad_v1_codes()], [get_ascvd_defs()], \code{spec_ascvd}
#' @export
get_lead_pad_v1_defs <- make_component_def_getter(spec_ascvd, "lead_pad_v1")

#' Retrieve ICD codes for cerebrovascular disease
#'
#' @description
#' Direct access to the `cerebrovasc_disease_v1` component of `spec_ascvd`.
#' Equivalent to `get_ascvd_codes(component = "cerebrovasc_disease_v1", ...)`.
#'
#' @param ... Further arguments passed to the underlying ASCVD getter
#'   (e.g. `variable_type`). `component` is fixed and cannot be supplied.
#' @seealso [get_cerebrovasc_disease_v1_defs()], [get_ascvd_codes()],
#'   \code{spec_ascvd}
#' @examples
#' get_cerebrovasc_disease_v1_codes()
#' @export
get_cerebrovasc_disease_v1_codes <- make_component_code_getter(spec_ascvd, "cerebrovasc_disease_v1")

#' Retrieve the narrative algorithm description for cerebrovascular disease
#'
#' @description
#' Direct access to the `cerebrovasc_disease_v1` component of `spec_ascvd`.
#' Equivalent to `get_ascvd_defs(component = "cerebrovasc_disease_v1", ...)`.
#'
#' @param ... Further arguments passed to the underlying ASCVD getter
#'   (e.g. `variable_type`). `component` is fixed and cannot be supplied.
#' @seealso [get_cerebrovasc_disease_v1_codes()], [get_ascvd_defs()],
#'   \code{spec_ascvd}
#' @export
get_cerebrovasc_disease_v1_defs <- make_component_def_getter(spec_ascvd, "cerebrovasc_disease_v1")

# ---- Obesity ------------------------------------------------------------

#' Retrieve ICD codes for obesity
#'
#' @description
#' Returns code sets from the obesity [CodeSpec] (`spec_obesity_v1`). The
#' same ICD-9 and ICD-10 code sets are used for both the condition and
#' outcome definitions.
#'
#' @inheritParams get_hypertension_v1_codes
#' @seealso [get_obesity_v1_defs()], \code{spec_obesity_v1}
#' @examples
#' get_obesity_v1_codes()
#' get_obesity_v1_codes(code_type = "dx_icd9")
#' get_obesity_v1_codes(variable_type = "outcome")
#' @export
get_obesity_v1_codes <- make_code_getter(spec_obesity_v1)

#' @rdname get_obesity_v1_codes
#' @export
get_obesity_v1_defs <- make_def_getter(spec_obesity_v1)

# ---- Type 1 Diabetes Mellitus -------------------------------------------

#' Retrieve ICD codes for Type 1 diabetes mellitus
#'
#' @description
#' Returns code sets from `spec_diabetes_type1_v1`. The definition is
#' diagnosis-based (ICD-9 Type 1 codes 250.x1/250.x3 and ICD-10 E10.xx),
#' with an alternative qualifying path of \eqn{\geq}1 pharmacy claim for
#' insulin or an amylin analogue (see `spec_diabetes_type1`).
#'
#' @inheritParams get_hypertension_v1_codes
#' @seealso [get_diabetes_type1_v1_defs()], \code{spec_diabetes_type1_v1}
#' @export
get_diabetes_type1_v1_codes <- make_code_getter(spec_diabetes_type1_v1)

#' @rdname get_diabetes_type1_v1_codes
#' @seealso [get_diabetes_type1_v1_codes()]
#' @export
get_diabetes_type1_v1_defs <- make_def_getter(spec_diabetes_type1_v1)

# ---- Type 2 Diabetes Mellitus -------------------------------------------
#
# All versions share one help page (`?diabetes_type2_codes`, also reachable
# as `?get_diabetes_type2_v1_codes` etc.). To add a version: describe it in
# the "Versions" section, add its getters with `@rdname diabetes_type2_codes`,
# and add its row to `.version_log` (R/changelog.R). The "Version history"
# section, including the exact codes added and removed, is generated.

#' Type 2 diabetes mellitus code sets (all versions)
#'
#' @description
#' `get_diabetes_type2_vN_codes()` returns the ICD code set for version N of
#' the type 2 diabetes definition, and `get_diabetes_type2_vN_defs()` displays
#' its narrative algorithm. Each version is frozen once released: later
#' versions never change what an earlier version's functions return.
#'
#' Every version has an alternative qualifying path of \eqn{\geq}1 pharmacy
#' claim for an oral antidiabetic drug or insulin (see `spec_diabetes_type2`),
#' and classifies patients into four mutually exclusive categories (no
#' diabetes; diabetes without antidiabetic medication; diabetes with oral
#' antidiabetic; diabetes with insulin).
#'
#' @section Versions:
#' \describe{
#'   \item{v1}{ICD-9 type 2/unspecified codes 250.x0/250.x2 plus complication
#'   codes 357.2, 362.0x, 366.41; and ICD-10 E11.xx, E08.xx, E09.xx, E13.xx.}
#'   \item{v2}{ICD-10 type 2 diabetes codes only: every billable E11 code,
#'   including E11.A (in remission). No ICD-9 codes, so claims before
#'   October 1, 2015 cannot qualify through the diagnosis criteria.}
#' }
#'
#' @section Version history:
#' `r .rd_version_history("diabetes_type2")`
#'
#' @inheritParams get_hypertension_v1_codes
#' @param variable_type `"condition"` (default) or `"outcome"`. Type 2
#'   diabetes is defined as a condition only; `"outcome"` falls back to
#'   condition codes.
#' @return `get_diabetes_type2_vN_codes()`: a tibble with columns `type`,
#'   `code`, `priority`, `version`, and `definition`.
#'   `get_diabetes_type2_vN_defs()`: the narrative definition (displayed, and
#'   returned invisibly), or `NULL`.
#' @seealso [get_version_diffs()], [list_versions()],
#'   \code{spec_diabetes_type2_v1}, \code{spec_diabetes_type2_v2}
#' @examples
#' get_diabetes_type2_v2_codes()
#' get_diabetes_type2_v2_defs()
#'
#' # What changed from v1 to v2?
#' get_version_diffs("diabetes_type2", versions = c(1, 2), changes_only = TRUE)
#' @name diabetes_type2_codes
NULL

#' @rdname diabetes_type2_codes
#' @export
get_diabetes_type2_v1_codes <- make_code_getter(spec_diabetes_type2_v1)

#' @rdname diabetes_type2_codes
#' @export
get_diabetes_type2_v1_defs <- make_def_getter(spec_diabetes_type2_v1)

#' @rdname diabetes_type2_codes
#' @export
get_diabetes_type2_v2_codes <- make_code_getter(spec_diabetes_type2_v2)

#' @rdname diabetes_type2_codes
#' @export
get_diabetes_type2_v2_defs <- make_def_getter(spec_diabetes_type2_v2)

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

# ---- Osteoarthritis -----------------------------------------------------

#' Retrieve ICD codes for osteoarthritis
#' @inheritParams get_hypertension_v1_codes
#' @seealso [get_osteoarthritis_v1_defs()], \code{spec_osteoarthritis_v1}
#' @examples
#' get_osteoarthritis_v1_codes()
#' get_osteoarthritis_v1_codes(code_type = "dx_icd10")
#' @export
get_osteoarthritis_v1_codes <- make_code_getter(spec_osteoarthritis_v1)

#' @rdname get_osteoarthritis_v1_codes
#' @export
get_osteoarthritis_v1_defs <- make_def_getter(spec_osteoarthritis_v1)

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

