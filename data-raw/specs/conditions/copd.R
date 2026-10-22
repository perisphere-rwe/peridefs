# COPD ----------------------------------------------------------------------
# Sourced by data-raw/build_specs.R; do not source on its own.
# Runs in its own environment: every object defined here is local to this
# file, and only `spec_*` objects are passed on to later files.

## Chronic Obstructive Pulmonary Disease ----

### history, version 1 ----
#
# Any of following:
#
# (a)	≥1 inpatient, skilled nursing facility, or home health agency claim with
# ICD-9 diagnoses (any position) of 490.xx, 491.0x, 491.1x, 491.8x, 491.9x,
# 492.0x, 492.8x, 491.20, 491.21, 491.22, 494.0x, 494.1x, 496.xx.
#
# (b)	≥2 outpatient, or carrier claim with ICD-9 diagnoses (any position) linked
# to an outpatient physician claim with a diagnosis of 490.xx, 491.0x, 491.1x, 491.8x, 491.9x, 492.0x,
# 492.8x, 491.20, 491.21, 491.22, 494.0x, 494.1x, 496.xx.
#
# (c)	≥1 inpatient, skilled nursing facility, home health agency claim with
# ICD-10 diagnoses (any position) of 'J40', 'J410', 'J411', 'J418', 'J42',
# 'J430', 'J431', 'J432', 'J438', 'J439', 'J440', 'J441', 'J449', 'J470',
# 'J471', 'J479', J4481, J4489
#
# (d)	≥2 outpatient, or carrier claim with ICD-10 diagnoses (any position)
# linked to an outpatient physician claim with a diagnosis of 'J40', 'J410', 'J411', 'J418', 'J42', 'J430',
# 'J431', 'J432', 'J438', 'J439', 'J440', 'J441', 'J449', 'J470', 'J471',
# 'J479', J4481, J4489
#

# Reference only, not run: how the released codes were derived. The build
# reads them from data-raw/codesets/<condition>_<version>.csv instead.
# copd_icd9 <- unique(
#   c(
#     expand9("490"),
#     expand9("4910"),
#     expand9("4911"),
#     expand9("4918"),
#     expand9("4919"),
#     "49120",
#     "49121",
#     "49122",
#     expand9("4920"),
#     expand9("4928"),
#     expand9("4940"),
#     expand9("4941"),
#     expand9("496")
#   )
# )
# copd_icd10 <- c(
#   "J40",
#   "J410",
#   "J411",
#   "J418",
#   "J42",
#   "J430",
#   "J431",
#   "J432",
#   "J438",
#   "J439",
#   "J440",
#   "J441",
#   "J449",
#   "J470",
#   "J471",
#   "J479",
#   "J4481",
#   "J4489"
# )

copd_defs_condition <- c(
  "i" = "Any of the following:",
  "*" = paste0(
    "\u22651 inpatient, SNF, or home health agency claim with an ICD-9 diagnosis of ",
    "{.strong 490.xx}, {.strong 491.0x}, {.strong 491.1x}, {.strong 491.8x}, {.strong 491.9x}, ",
    "{.strong 491.20}\u2013{.strong 491.22}, {.strong 492.0x}, {.strong 492.8x}, {.strong 494.0x}, ",
    "{.strong 494.1x}, or {.strong 496.xx}, or an ICD-10 diagnosis of {.strong J40}, ",
    "{.strong J410}\u2013{.strong J418}, {.strong J42}, {.strong J430}\u2013{.strong J439}, ",
    "{.strong J440}\u2013{.strong J449}, {.strong J470}\u2013{.strong J479}, ",
    "{.strong J4481}, or {.strong J4489} in any position."
  ),
  "*" = paste0(
    "\u22652 outpatient or carrier claims with the same ICD codes in any position."
  )
)

spec_copd_v1 <- CodeSpec$new(
  condition = "copd", version = "v1",
  label = "Chronic Obstructive Pulmonary Disease (COPD)",
  defs  = list(condition = copd_defs_condition, outcome = NULL),
  codes = read_codeset("copd_v1")
)
