# Obesity hypoventilation syndrome ------------------------------------------
# Sourced by data-raw/build_specs.R; do not source on its own.
# Runs in its own environment: every object defined here is local to this
# file, and only `spec_*` objects are passed on to later files.

## Obesity hypoventilation syndrome ----

# ICD-9 278.03 is the only specific code for OHS (a leaf node with no children).
# ICD-10 E66.2 (Morbid (severe) obesity with alveolar hypoventilation) is the
# direct map; it also covers Pickwickian syndrome as an included term.

# Reference only, not run: how the released codes were derived. The build
# reads them from data-raw/codesets/<condition>_<version>.csv instead.
# ohs_icd9  <- "27803"   # 278.03 — Obesity hypoventilation syndrome
# ohs_icd10 <- "E662"    # E66.2  — Morbid (severe) obesity with alveolar hypoventilation

ohs_defs_condition <- c(
  "*" = paste0(
    "\u22651 claim with an ICD-9 diagnosis of {.strong 278.03}, or an ICD-10 ",
    "diagnosis of {.strong E66.2} in any diagnosis position from inpatient, ",
    "outpatient, carrier, or line files."
  )
)

spec_ohs_v1 <- CodeSpec$new(
  condition = "ohs",
  version   = "v1",
  label     = "Obesity Hypoventilation Syndrome",
  defs  = list(condition = ohs_defs_condition, outcome = NULL),
  codes = read_codeset("ohs_v1")
)
