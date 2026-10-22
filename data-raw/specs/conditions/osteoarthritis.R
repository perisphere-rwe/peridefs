# Osteoarthritis ------------------------------------------------------------
# Sourced by data-raw/build_specs.R; do not source on its own.
# Runs in its own environment: every object defined here is local to this
# file, and only `spec_*` objects are passed on to later files.

## Osteoarthritis ----

# Reference only, not run: how the released codes were derived. The build
# reads them from data-raw/codesets/<condition>_<version>.csv instead.
# oa_icd9  <- unique(expand9("715"))
# oa_icd10 <- unique(c(
#   expand10(c(
#     "M15",   # polyosteoarthritis
#     "M16",   # osteoarthritis of hip
#     "M17",   # osteoarthritis of knee
#     "M18",   # osteoarthritis of first carpometacarpal joint
#     "M19"    # other and unspecified osteoarthritis
#   )),
#   # M19.09 (Primary osteoarthritis, other specified site) is absent from the
#   # icd package's ICD-10-CM reference table and must be added manually.
#   "M1909"
# ))

oa_defs_condition <- c(
  "i" = "Any of the following:",
  "*" = paste0(
    "\u22651 inpatient claim with an ICD-9 diagnosis of {.strong 715.xx} ",
    "(osteoarthrosis and allied disorders), or an ICD-10 diagnosis of ",
    "{.strong M15.xx}\u2013{.strong M19.xx} (polyosteoarthritis; ",
    "osteoarthritis of hip, knee, first carpometacarpal joint; other and ",
    "unspecified osteoarthritis) in any position."
  ),
  "*" = paste0(
    "\u22652 outpatient or carrier claims with the same ICD codes in any position."
  )
)

spec_osteoarthritis_v1 <- CodeSpec$new(
  condition = "osteoarthritis", version = "v1",
  label = "Osteoarthritis",
  defs  = list(condition = oa_defs_condition, outcome = NULL),
  codes = read_codeset("osteoarthritis_v1")
)
