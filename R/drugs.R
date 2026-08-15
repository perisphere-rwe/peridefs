# Drug-specific wrapper functions.
# Each composite drug spec (hypertension, diabetes, obesity, depression,
# hyperlipidemia) gets a single unversioned pair of get_*_generics()/
# get_*_meds_labels() functions; component is optional (defaults to all
# components). Both functions and the underlying spec objects are named
# after the condition the medications treat, not the drug mechanism class
# (e.g. `spec_hypertension`, not `spec_antihypertensive`); the drug-mechanism
# identifier still lives on each object's `drug_class` field (and on the
# `class` column of `get_*_generics()` output, e.g. `"acei"`, `"biguanide"`,
# `"statin"` — unprefixed, since the composite's `condition` already
# supplies the condition context).

#' Miscellaneous drug accessor functions
#'
#' @description
#' Accessor functions for composite drug specs. For each composite,
#' `get_*_generics()` returns the tidy tibble of generic (and brand) drug
#' names, and `get_*_meds_labels()` returns a tibble of each component's
#' `name` (its key, e.g. `"acei_v1"`) and human-readable `label` (e.g.
#' `"ACE Inhibitors"`) — not a narrative definition. Composite drug specs
#' don't carry a clinically meaningful "definition" the way condition specs
#' do (see [get_hypertension_v1_defs()] for that); a drug leaf's `defs`
#' field is just an internal sourcing note, so `get_*_meds_labels()`
#' surfaces the more useful per-component label instead.
#'
#' @param component Optional component name (e.g., `"acei_v1"`). `NULL`
#'   (default) or `"all"` returns every component, distinguished by the
#'   `class` column. Print the composite spec to see all available names.
#' @param priority Integer vector subsetting confidence tiers to include
#'   (`1` = core, `2` = probable, `3` = cautious). Default `1`.
#' @param condition Optional character vector subsetting to specific
#'   condition(s). `NULL` (default) uses the composite's own condition
#'   (e.g. `get_obesity_generics()` defaults to `"obesity"`), so a leaf
#'   component shared across composites (e.g. a GLP-1 spec used by both
#'   the obesity and diabetes composites) only contributes its rows for
#'   *this* composite's condition. Pass a value explicitly to widen or
#'   otherwise override the default.
#' @name drug_accessors
NULL

# ---- Hypertension (top-level composite) --------------------------------

#' Retrieve generic drug names for hypertension medications
#'
#' @description
#' `spec_hypertension` is a [CompositeDrugSpec] containing all versioned
#' antihypertensive leaf specs directly (no intermediate composites):
#' `acei_v1`, `acei_v2`, `arb_v1`, `arb_v2`, `alpha_v1`, `alpha_beta_v1`,
#' `alpha_beta_v2`, `cardio_v1`, `cardio_vasod_v1`, `int_sym_v1`, `int_sym_v2`,
#' `noncardio_v1`, `ccb_dhp_v1`, `ccb_dhp_v2`, `ccb_nondhp_v1`,
#' `thiazide_v1`, `thiazide_v2`, `loop_v1`, `loop_v2`, `ksparing_v1`,
#' `ksparing_v2`, `aldo_v1`, `central_v1`, `central_v2`, `renin_v1`,
#' `vasodilators_v1`.
#'
#' @inheritParams drug_accessors
#' @return `get_*_generics()`: a tibble with columns `generic`, `brand`,
#'   `priority`, `condition`, `class`, and `version`. `get_*_meds_labels()`:
#'   a tibble with columns `name` and `label`.
#' @seealso \code{spec_hypertension}
#' @export
get_hypertension_generics <- make_generic_getter(spec_hypertension, composite = TRUE)

#' @rdname get_hypertension_generics
#' @export
get_hypertension_meds_labels <- make_meds_labels_getter(spec_hypertension)

# ---- Diabetes (composite) -----------------------------------------------

#' Retrieve generic drug names for diabetes medications
#'
#' @description
#' `spec_diabetes` is a [CompositeDrugSpec] containing all versioned
#' antidiabetic leaf specs: `biguanide_v1`, `sulfonylurea_v1`,
#' `meglitinide_v1`, `tzd_v1`, `alpha_glucosidase_v1`, `dpp4_v1`,
#' `sglt2_v1`, `glp1_v1`, `insulin_v1`, `amylin_v1`.
#'
#' @inheritParams drug_accessors
#' @return `get_*_generics()`: a tibble with columns `generic`, `brand`,
#'   `priority`, `condition`, `class`, and `version`. `get_*_meds_labels()`:
#'   a tibble with columns `name` and `label`.
#' @seealso \code{spec_diabetes}
#' @export
get_diabetes_generics <- make_generic_getter(spec_diabetes, composite = TRUE)

#' @rdname get_diabetes_generics
#' @export
get_diabetes_meds_labels <- make_meds_labels_getter(spec_diabetes)

# ---- Obesity (composite) -------------------------------------------------

#' Retrieve generic drug names for obesity medications
#'
#' @description
#' `spec_obesity` is a [CompositeDrugSpec] with components `non_glp1_v1`
#' and `glp1_v1`.
#'
#' @inheritParams drug_accessors
#' @return `get_*_generics()`: a tibble with columns `generic`, `brand`,
#'   `priority`, `condition`, `class`, and `version`. `get_*_meds_labels()`:
#'   a tibble with columns `name` and `label`.
#' @seealso \code{spec_obesity}
#' @export
get_obesity_generics <- make_generic_getter(spec_obesity, composite = TRUE)

#' @rdname get_obesity_generics
#' @export
get_obesity_meds_labels <- make_meds_labels_getter(spec_obesity)

# ---- Hyperlipidemia (composite) ------------------------------------------

#' Retrieve generic drug names for hyperlipidemia medications
#'
#' @description
#' `spec_hyperlipidemia` is a [CompositeDrugSpec] with components `statin_v1`,
#' `ezetimibe_v1`, `pcsk9_v1`, `fibrate_v1`, `bile_acid_seq_v1`, and
#' `niacin_v1`.
#'
#' @inheritParams drug_accessors
#' @return `get_*_generics()`: a tibble with columns `generic`, `brand`,
#'   `priority`, `condition`, `class`, and `version`. `get_*_meds_labels()`:
#'   a tibble with columns `name` and `label`.
#' @seealso \code{spec_hyperlipidemia}
#' @export
get_hyperlipidemia_generics <- make_generic_getter(spec_hyperlipidemia, composite = TRUE)

#' @rdname get_hyperlipidemia_generics
#' @export
get_hyperlipidemia_meds_labels <- make_meds_labels_getter(spec_hyperlipidemia)

# ---- Depression (composite) ----------------------------------------------

#' Retrieve generic drug names for depression medications
#'
#' @description
#' `spec_depression` is a [CompositeDrugSpec] with components `ssri_v1`,
#' `snri_v1`, `tca_v1`, `maoi_v1`, and `other_v1`.
#'
#' @inheritParams drug_accessors
#' @return `get_*_generics()`: a tibble with columns `generic`, `brand`,
#'   `priority`, `condition`, `class`, and `version`. `get_*_meds_labels()`:
#'   a tibble with columns `name` and `label`.
#' @seealso \code{spec_depression}
#' @export
get_depression_generics <- make_generic_getter(spec_depression, composite = TRUE)

#' @rdname get_depression_generics
#' @export
get_depression_meds_labels <- make_meds_labels_getter(spec_depression)
