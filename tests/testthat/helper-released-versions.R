# Shared by test-frozen-versions.R and test-codesets.R.
#
# The release manifests below list every released spec version. Adding a
# version here is the explicit "this version is now released" step: its
# content is then frozen by test-frozen-versions.R and, for condition specs,
# its code set must match data-raw/codesets/<id>.csv (test-codesets.R).

# ---- Release manifests ------------------------------------------------------

# Condition leaf specs, identified as "<condition>_<version>". Includes the
# components of composite condition specs (e.g. the ASCVD components).
.released_condition_specs <- c(
  "asthma_v1",
  "cerebrovasc_disease_v1",
  "chd_v1",
  "ckd_v1",
  "copd_v1",
  "depression_v1",
  "diabetes_type1_v1",
  "diabetes_type2_v1",
  "hf_v1",
  "hyperlipidemia_v1",
  "hypertension_v1",
  "lead_pad_v1",
  "obesity_v1",
  "ohs_v1",
  "osa_v1",
  "osteoarthritis_v1",
  "stroke_v1"
)

# Drug leaf specs, identified as "<composite object>/<component key>".
.released_drug_specs <- c(
  # spec_depression
  "spec_depression/maoi_v1",
  "spec_depression/other_v1",
  "spec_depression/snri_v1",
  "spec_depression/ssri_v1",
  "spec_depression/tca_v1",
  # spec_diabetes_type1
  "spec_diabetes_type1/amylin_v1",
  "spec_diabetes_type1/insulin_v1",
  # spec_diabetes_type2
  "spec_diabetes_type2/alpha_glucosidase_v1",
  "spec_diabetes_type2/amylin_v1",
  "spec_diabetes_type2/biguanide_v1",
  "spec_diabetes_type2/dpp4_v1",
  "spec_diabetes_type2/glp1_v1",
  "spec_diabetes_type2/insulin_v1",
  "spec_diabetes_type2/meglitinide_v1",
  "spec_diabetes_type2/sglt2_v1",
  "spec_diabetes_type2/sulfonylurea_v1",
  "spec_diabetes_type2/tzd_v1",
  # spec_hyperlipidemia
  "spec_hyperlipidemia/bile_acid_seq_v1",
  "spec_hyperlipidemia/ezetimibe_v1",
  "spec_hyperlipidemia/fibrate_v1",
  "spec_hyperlipidemia/niacin_v1",
  "spec_hyperlipidemia/pcsk9_v1",
  "spec_hyperlipidemia/statin_v1",
  # spec_hypertension
  "spec_hypertension/acei_v1",
  "spec_hypertension/acei_v2",
  "spec_hypertension/aldo_v1",
  "spec_hypertension/alpha_beta_v1",
  "spec_hypertension/alpha_beta_v2",
  "spec_hypertension/alpha_v1",
  "spec_hypertension/arb_v1",
  "spec_hypertension/arb_v2",
  "spec_hypertension/cardio_v1",
  "spec_hypertension/cardio_vasod_v1",
  "spec_hypertension/ccb_dhp_v1",
  "spec_hypertension/ccb_nondhp_v1",
  "spec_hypertension/central_v1",
  "spec_hypertension/central_v2",
  "spec_hypertension/int_sym_v1",
  "spec_hypertension/int_sym_v2",
  "spec_hypertension/ksparing_v1",
  "spec_hypertension/ksparing_v2",
  "spec_hypertension/loop_v1",
  "spec_hypertension/loop_v2",
  "spec_hypertension/noncardio_v1",
  "spec_hypertension/renin_v1",
  "spec_hypertension/thiazide_v1",
  "spec_hypertension/thiazide_v2",
  "spec_hypertension/vasodilators_v1",
  # spec_obesity
  "spec_obesity/glp1_v1",
  "spec_obesity/non_glp1_v1"
)

# ---- Discovery helpers ------------------------------------------------------

.private <- function(x) x$.__enclos_env__$private

# All package datasets (spec_* objects), forced, as a named list.
.all_specs <- function() {
  env <- getNamespaceInfo("peridefs", "lazydata")
  nms <- sort(ls(env), method = "radix")
  stats::setNames(lapply(nms, get, envir = env), nms)
}

# Condition leaf specs keyed by "<condition>_<version>".
.condition_leaves <- function(specs) {
  out <- list()
  add <- function(s) {
    id <- paste0(s$condition, "_", s$version %||% "NOVERSION")
    if (!is.null(out[[id]]) && !identical(.private(out[[id]])$.codes, .private(s)$.codes)) {
      stop("Two different condition specs share the id ", id, call. = FALSE)
    }
    out[[id]] <<- s
  }
  for (s in specs) {
    if (inherits(s, "CodeSpec")) add(s)
    if (inherits(s, "CompositeCodeSpec")) for (cs in s$components()) add(cs)
  }
  out
}

# Drug leaf specs keyed by "<composite object>/<component key>" (or by the
# object name for a standalone DrugSpec dataset).
.drug_leaves <- function(specs) {
  out <- list()
  for (nm in names(specs)) {
    s <- specs[[nm]]
    if (inherits(s, "DrugSpec")) out[[nm]] <- s
    if (inherits(s, "CompositeDrugSpec")) {
      comps <- s$components()
      for (k in names(comps)) out[[paste0(nm, "/", k)]] <- comps[[k]]
    }
  }
  out
}
