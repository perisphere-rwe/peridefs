# Drug-specific wrapper functions.
# Composite drug specs (antihypertensive, antidiabetic) get a single unversioned
# set of get_* functions; component= (required) selects a specific versioned leaf.
# Standalone drug specs (e.g., spec_antidepressive_v1) get their own get_* functions
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
get_antihypertensive_generics <- make_generic_getter(spec_antihypertensive)

#' @rdname drug_accessors
#' @export
get_antihypertensive_codes <- make_ndc_getter(spec_antihypertensive)

#' @rdname drug_accessors
#' @export
get_antihypertensive_defs <- make_drug_def_getter(spec_antihypertensive)

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
get_antidiabetic_generics <- make_generic_getter(spec_antidiabetic)

#' @rdname drug_accessors
#' @export
get_antidiabetic_codes <- make_ndc_getter(spec_antidiabetic)

#' @rdname drug_accessors
#' @export
get_antidiabetic_defs <- make_drug_def_getter(spec_antidiabetic)

# ---- Antidepressive (standalone) ----------------------------------------

#' Retrieve generic drug names for antidepressive medications
#'
#' @description
#' `spec_antidepressive_v1` is a standalone [DrugSpec] (not a composite).
#' Call with no arguments to retrieve all GNNs or NDC codes.
#'
#' @return Character vector of GNN strings (upper-case), or NDC codes.
#' @seealso \code{spec_antidepressive_v1}
#' @export
get_antidepressive_v1_generics <- make_generic_getter(spec_antidepressive_v1)

#' @rdname get_antidepressive_v1_generics
#' @export
get_antidepressive_v1_codes <- make_ndc_getter(spec_antidepressive_v1)

#' @rdname get_antidepressive_v1_generics
#' @export
get_antidepressive_v1_defs <- make_drug_def_getter(spec_antidepressive_v1)

