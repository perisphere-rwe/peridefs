# Asthma --------------------------------------------------------------------
# Sourced by data-raw/build_specs.R; do not source on its own.
# Runs in its own environment: every object defined here is local to this
# file, and only `spec_*` objects are passed on to later files.

## Asthma ----

asthma_icd9  <- unique(expand9("493"))
asthma_icd10 <- unique(expand10("J45"))

asthma_defs_condition <- c(
  "i" = "Any of the following:",
  "*" = paste0(
    "\u22651 inpatient claim with an ICD-9 diagnosis of {.strong 493.xx}, or an ",
    "ICD-10 diagnosis of {.strong J45.xx} in any position."
  ),
  "*" = paste0(
    "\u22652 outpatient or carrier claims with the same ICD codes in any position."
  )
)

spec_asthma_v1 <- CodeSpec$new(
  condition = "asthma", version = "v1",
  label = "Asthma",
  defs  = list(condition = asthma_defs_condition, outcome = NULL),
  codes = list(
    dx_icd9  = make_key_condition_only("dx_icd9", asthma_icd9),
    dx_icd10 = make_key_condition_only("dx_icd10", asthma_icd10)
  )
)
