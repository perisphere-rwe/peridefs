# Drug-specific wrapper functions.
# Composite drug specs (antihypertensive, antidiabetic) get a single unversioned
# set of get_* functions; component= (required) selects a specific versioned leaf.
# Standalone drug specs get their own get_* functions
# with no component= argument.

#' Miscellaneous drug accessor functions
#'
#' @description
#' Accessor functions for composite drug specs.
#'
#' @param component **Required.** Component name (e.g., `"acei_v1"`). Print
#'   the composite spec to see all available names.
#' @name drug_accessors
NULL

# ---- Antihypertensive (top-level composite) ----------------------------

#' Retrieve generic drug names for antihypertensive medications
#'
#' @description
#' `spec_antihypertensive` is a [CompositeDrugSpec] containing all versioned
#' antihypertensive leaf specs directly (no intermediate composites):
#' `acei_v1`, `acei_v2`, `arb_v1`, `arb_v2`, `alpha_v1`, `alpha_beta_v1`,
#' `alpha_beta_v2`, `cardio_v1`, `cardio_vasod_v1`, `int_sym_v1`, `int_sym_v2`,
#' `noncardio_v1`, `ccb_dhp_v1`, `ccb_dhp_v2`, `ccb_nondhp_v1`,
#' `thiazide_v1`, `thiazide_v2`, `loop_v1`, `loop_v2`, `ksparing_v1`,
#' `ksparing_v2`, `aldo_v1`, `central_v1`, `central_v2`, `renin_v1`,
#' `vasodilators_v1`.
#'
#' @param component **Required.** Component name. Print `spec_antihypertensive`
#'   to see all available names.
#' @return Character vector of GNN strings (upper-case).
#' @seealso \code{spec_antihypertensive}
#' @export
get_antihypertensive_generics <- make_generic_getter(spec_antihypertensive, composite = TRUE)

#' @rdname drug_accessors
#' @export
get_antihypertensive_codes <- make_ndc_getter(spec_antihypertensive, composite = TRUE)

#' @rdname drug_accessors
#' @export
get_antihypertensive_defs <- make_drug_def_getter(spec_antihypertensive, composite = TRUE)

# ---- Antidiabetic (composite) -------------------------------------------

#' Retrieve generic drug names for antidiabetic medications
#'
#' @description
#' `spec_antidiabetic` is a [CompositeDrugSpec] containing all versioned
#' antidiabetic leaf specs: `biguanide_v1`, `sulfonylurea_v1`,
#' `meglitinide_v1`, `tzd_v1`, `alpha_glucosidase_v1`, `dpp4_v1`,
#' `sglt2_v1`, `glp1_v1`, `insulin_v1`, `amylin_v1`.
#'
#' @param component **Required.** Component name. Print `spec_antidiabetic`
#'   to see all available names.
#' @return Character vector of GNN strings (upper-case).
#' @seealso \code{spec_antidiabetic}
#' @export
get_antidiabetic_generics <- make_generic_getter(spec_antidiabetic, composite = TRUE)

#' @rdname drug_accessors
#' @export
get_antidiabetic_codes <- make_ndc_getter(spec_antidiabetic, composite = TRUE)

#' @rdname drug_accessors
#' @export
get_antidiabetic_defs <- make_drug_def_getter(spec_antidiabetic, composite = TRUE)

# ---- Antiobesity (composite) --------------------------------------------

#' Retrieve generic drug names for antiobesity medications
#'
#' @description
#' `spec_antiobesity` is a [CompositeDrugSpec] with components `non_glp1_v1`
#' and `glp1_v1`. Use `component = "all"` to retrieve all GNNs across both
#' subclasses.
#'
#' @param component **Required.** `"non_glp1_v1"`, `"glp1_v1"`, or `"all"`.
#' @return Character vector of GNN strings (upper-case), or NDC codes.
#' @seealso \code{spec_antiobesity}
#' @export
get_antiobesity_generics <- make_generic_getter(spec_antiobesity, composite = TRUE)

#' @rdname get_antiobesity_generics
#' @export
get_antiobesity_codes <- make_ndc_getter(spec_antiobesity, composite = TRUE)

#' @rdname get_antiobesity_generics
#' @export
get_antiobesity_defs <- make_drug_def_getter(spec_antiobesity, composite = TRUE)

# ---- Antidepressive (composite) -----------------------------------------

#' Retrieve generic drug names for antidepressive medications
#'
#' @description
#' `spec_antidepressive` is a [CompositeDrugSpec] with components `ssri_v1`,
#' `snri_v1`, `tca_v1`, `maoi_v1`, and `other_v1`. Use `component = "all"` to
#' retrieve all GNNs across every subclass.
#'
#' @param component **Required.** One or more of `"ssri_v1"`, `"snri_v1"`,
#'   `"tca_v1"`, `"maoi_v1"`, `"other_v1"`, or `"all"`.
#' @return Named list of GNN strings, or NDC codes (one element per component).
#'   Pass `concatenate = TRUE` to flatten to an unnamed character vector.
#' @seealso \code{spec_antidepressive}
#' @export
get_antidepressive_generics <- make_generic_getter(spec_antidepressive, composite = TRUE)

#' @rdname get_antidepressive_generics
#' @export
get_antidepressive_codes <- make_ndc_getter(spec_antidepressive, composite = TRUE)

#' @rdname get_antidepressive_generics
#' @export
get_antidepressive_defs <- make_drug_def_getter(spec_antidepressive, composite = TRUE)

