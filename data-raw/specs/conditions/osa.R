# Sleep apnea ---------------------------------------------------------------
# Sourced by data-raw/build_specs.R; do not source on its own.
# Runs in its own environment: every object defined here is local to this
# file, and only `spec_*` objects are passed on to later files.

## Sleep Apnea ----

### history, version 1 ----
#
# Any diagnosis position from inpatient or outpatient encounters:
#
# ICD-9 diagnosis code of 327.20, 327.21, 327.23, 327.27, 327.29, 780.51,
# 780.53, 780.57,
#
# ICD-10 diagnosis code of G47.30, G47.31, G47.33, G47.37, G47.39.
#
osa_icd9  <- c("32720",
               "32723",
               "32729",
               "78057")


osa_icd10 <- c("G4730", "G4733", "G4739")

osa_defs_condition <- c(
  "*" = paste0(
    "\u22651 claim with an ICD-9 diagnosis of {.strong 327.20}, ",
    "{.strong 327.23}, {.strong 327.29}, or {.strong 780.57}, or an ",
    "ICD-10 diagnosis of {.strong G47.30}, {.strong G47.33}, or ",
    "{.strong G47.39} in any  diagnosis position from inpatient, ",
    "outpatient, carrier, or line files."
  )
)

spec_osa_v1 <- CodeSpec$new(
  condition = "osa",
  version = "v1",
  label = "Obstructive sleep apnea",
  defs  = list(condition = osa_defs_condition, outcome = NULL),
  codes = list(
    dx_icd9  = make_key_condition_only("dx_icd9", osa_icd9),
    dx_icd10 = make_key_condition_only("dx_icd10", osa_icd10)
  )
)
