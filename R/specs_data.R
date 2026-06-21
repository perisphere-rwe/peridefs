# Documentation for spec_* package data objects and miscellaneous accessor groups.

#' Miscellaneous condition accessor functions
#'
#' @description
#' Accessor functions for condition specs.
#'
#' @param code_type Optional code type filter.
#' @param variable_type `"condition"` (default) or `"outcome"`.
#' @param periods Logical. Return decimal-format codes.
#' @param format `"list"` (default) or `"tibble"`.
#' @param component For composite specs: a named component (e.g. `"chd_v1"`),
#'   or `"all"` to union all components. For leaf specs, not used.
#' @name condition_accessors
#' @keywords internal
NULL

#' Miscellaneous drug accessor functions
#'
#' @description
#' Accessor functions for composite drug specs.
#'
#' @param component **Required** for composite specs. A named component (e.g.
#'   `"acei_v1"`), or `"all"` to union all components' GNNs or NDC codes.
#'   Print the composite spec to see all available component names.
#' @name drug_accessors
NULL

#' Condition and Drug Code Specification Objects
#'
#' @description
#' `peridefs` exports one `spec_*` object per medical condition version or
#' drug class. Each is an [R6][R6::R6Class] object:
#'
#' - **Standalone conditions**: a `spec` for a single condition. These
#'   specs are versioned (e.g., `spec_htn_v1`, `spec_htn_v2`).
#'
#' - **Composite specs**: a collection of standalone conditions in a single
#'   spec. For example, atherosclerotic cardiovascular disease is a composition
#'   of standalong specs for coronary heart disease, stroke, and cerebrovascular
#'   disease. Composite specs are not versioned because they have multiple
#'   components that each have versions. Use `component=` to access individual
#'   components and their respective versions, or `component = "all"` to get
#'   a union of all the components.
#'
#' Print any spec to see its definition, code sets, and (for composites)
#' available component names.
#'
#' @section Condition specs (standalone, [CodeSpec]):
#'   `spec_htn_v1`, `spec_htn_v2`,
#'   `spec_hf_v1`,
#'   `spec_obesity_v1`,
#'   `spec_diabetes_v1`, `spec_diabetes_v2`, `spec_diabetes_v3`,
#'   `spec_depression_v1`, `spec_depression_v2`,
#'   `spec_ckd_v1`,
#'   `spec_copd_v1`,
#'   `spec_asthma_v1`,
#'   `spec_osa_v1`,
#'   `spec_ohs_v1`,
#'   `spec_hyperlipidemia_v1`
#'
#' @section ASCVD composite ([CompositeCodeSpec]):
#'   `spec_ascvd`
#'
#' @section Drug class composites ([CompositeDrugSpec]):
#'   `spec_antihypertensive`, `spec_antidiabetic`, `spec_antiobesity`
#'
#' @section Drug class standalone ([DrugSpec]):
#'   `spec_antidepressive_v1`
#'
#' @name spec_objects
#' @aliases
#'   spec_antidepressive_v1
#'   spec_antidiabetic
#'   spec_asthma_v1
#'   spec_antihypertensive
#'   spec_antiobesity
#'   spec_ascvd
#'   spec_ckd_v1
#'   spec_copd_v1
#'   spec_depression_v1
#'   spec_depression_v2
#'   spec_diabetes_v1
#'   spec_diabetes_v2
#'   spec_diabetes_v3
#'   spec_hf_v1
#'   spec_htn_v1
#'   spec_htn_v2
#'   spec_hyperlipidemia_v1
#'   spec_isch_stroke_v1
#'   spec_obesity_v1
#'   spec_ohs_v1
#'   spec_osa_v1
#' @keywords datasets
NULL
