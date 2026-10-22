# Hypertension --------------------------------------------------------------
# Sourced by data-raw/build_specs.R; do not source on its own.
# Runs in its own environment: every object defined here is local to this
# file, and only `spec_*` objects are passed on to later files.

## Hypertension ----

### history, source versions 1-2 (not separately exported) ----
#
# The source document described two versions that differed only in required
# evidence, not in ICD code set (both share the codes built below). They were
# collapsed (2026-08-15, issue #4) into the single implemented
# spec_hypertension_v1 (below), which carries the more complete
# source-version-2 narrative. "Version 1"/"version 2" here refer only to the
# two source-document drafts -- there is no separately exported
# spec_hypertension_v2.
#
# Source version 1 -- any of the following:
#
# a)	≥1 inpatient claim with an ICD-9 discharge diagnosis code of 401.x, 403.0x,
# 403.1x, 403.9x, or an ICD-10 discharge diagnosis code of I10, I11.x, I12.x,
# I13.x, I15.x, I12.0, I12.9, I16.x in any discharge diagnosis position
#
# b)	≥2 outpatient physician visit claims (page 7) with an ICD-9
# diagnosis code of 401.x, 403.0x, 403.1x, 403.9x, or an ICD-10 diagnosis code
# of I10, I11.x, I12.x, I13.x, I15.x, I12.0, I12.9, I16.x, in any position at
# least 30 days apart.
#
# Source version 2 -- same as version 1 (a)-(b) above, plus:
#
# c)	Two or more pharmacy fills for an antihypertensive medication:


# Reference only, not run: how the released codes were derived. The build
# reads them from data-raw/codesets/<condition>_<version>.csv instead.
# htn_icd9 <- c(expand9("401"),
#               expand9("4030"),
#               expand9("4031"),
#               expand9("4039"))

# htn_icd10 <- unique(c("I10",
#                       expand10("I11"),
#                       expand10("I12"),
#                       expand10("I13"),
#                       expand10("I15"),
#                       "I120",
#                       "I129",
#                       expand10("I16")))


htn_v1_defs_condition <- c(
  "i" = "Any of the following:",
  "*" = paste0(
    "\u22651 inpatient claim with an ICD-9 discharge diagnosis of ",
    "{.strong 401.x}, {.strong 403.0x}, {.strong 403.1x}, or {.strong 403.9x}, or ICD-10 ",
    "discharge diagnosis code of {.strong I10}, {.strong I11.x}, {.strong I12.x}, ",
    "{.strong I13.x}, {.strong I15.x}, {.strong I12.0}, {.strong I12.9}, {.strong I16.x} ",
    "in any discharge diagnosis position."
  ),
  "*" = paste0(
    "\u22652 outpatient physician visit claims with the same diagnosis codes, ",
    "at least 30 days apart."
  )
)

htn_v2_defs_condition <- c(
  htn_v1_defs_condition,
  "*" = paste0(
    "\u22652 pharmacy fills for an antihypertensive medication ",
    "(see spec_hypertension)"
  )
)

# Reference only, not run: how the released codes were derived. The build
# reads them from data-raw/codesets/<condition>_<version>.csv instead.
# htn_codes <- list(
#   dx_icd9  = make_key_condition_only("dx_icd9", htn_icd9),
#   dx_icd10 = make_key_condition_only("dx_icd10", htn_icd10)
# )

# Collapsed to a single version (2026-08-15, issue #4): v1/v2 previously
# shared identical codes and differed only in the condition definition
# narrative (v2 added the medication criterion). Now there's a single
# version carrying the more complete (formerly v2) narrative.
spec_hypertension_v1 <- CodeSpec$new(
  condition = "hypertension",
  version = "v1",
  label = "Hypertension",
  defs  = list(condition = htn_v2_defs_condition,
               outcome = NULL),
  codes = read_codeset("hypertension_v1")
)
