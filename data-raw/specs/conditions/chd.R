# Coronary heart disease (ASCVD component) ----------------------------------
# Sourced by data-raw/build_specs.R; do not source on its own.
# Runs in its own environment: every object defined here is local to this
# file, and only `spec_*` objects are passed on to later files.

### Coronary Heart Disease ----

#### history, version 1 ----
#
# Any of the following:
#
# (a) At least 1 inpatient claim with an ICD-9 diagnosis code of 410.xx-414.xx,
# V45.81 or V45.82, or an ICD-10 diagnosis code of I21.xxx, I22.xxx, I25.10,
# I25.810, I25.811, I25.812, I25.3, I25.41, I25.42, Z95.1, Z9861, I200, I201,
# I208, I209, I240, I241, I248, I252, I255, I2582, I2583, I2584, I2589, I259, in
# any position.
#
# (b) At least 1 outpatient physician claim (page 7)
# with an ICD-9 diagnosis code of 410.xx-414.xx, V45.81 or V45.82, or an ICD-10
# diagnosis code of I21.xxx, I22.xxx, I25.10, I25.810, I25.811, I25.812, I25.3,
# I25.41, I25.42, Z95.1, Z9861, I200, I201, I208, I209, I240, I241, I248, I252,
# I255, I2582, I2583, I2584, I2589, I259, in any position.
#
# (c) At least 1 inpatient or outpatient claim with an ICD-9 procedure code of
# 00.66, 36.0, 36.01-36.19, 36.2, or an ICD-10 procedure code of '0210xxx',
# '0211xxx', '0212xxx', ‘0213xxx', '0270xxx', '0271xxx', '0272xxx',
# '0273xxx','02C0xxx', '02C1xxx', '02C2xxx', '02C3xxx', '3E07xxx', or a HCPCS
# code of 33510-33514, 33516-33519, 33521-33523, 33530, 33533-33536, 92980-92982, 92984,
# 92995, 92996, 92920, 92921, 92924, 92925, 92928, 92929, 92933, 92934, 92937,
# 92938, 92941, 92943, 92944, 92973, C9600, C9601, C9602, C9603, C9604, C9605,
# C9606, C9607, C9608, G0290, G0291.
#
# Condition (history) definition uses a broad set of dx codes plus proc/HCPCS.
# Outcome (v1) uses AMI dx codes (primary position) plus revascularization proc.
#
# ICD-10-PCS codes use a wildcard suffix "xxx" that represents 3 variable
# characters. These are stored as-is (pattern strings) in the proc_icd10 key.

#### outcome, source version 1 (not separately implemented) ----
#
# The source definition document described two outcome versions, transcribed
# here as "source version 1" and "source version 2" for reference. Both were
# collapsed into the single implemented spec_chd_v1 (below), which uses the
# more complete source-version-2 outcome text -- there is no exported
# spec_chd_v1/spec_chd_v2 outcome distinction; "version 1" and "version 2" in
# this comment block refer only to the two source-document drafts, not to
# two live package specs.
#
# Overnight hospitalization with a discharge diagnosis code for AMI (i.e., an
# ICD-9 code 410.xx, except 410.x2, which represent a subsequent episode of
# care, or an ICD-10 of code I21.xx, I22.xx) in the primary discharge diagnosis
# position or an inpatient or outpatient claim with a procedure code for
# coronary revascularization, including a HCPCS code of 33510-33514, 33516-33519,
# 33521-33523, 33530, 33533-33536, 92980-92982, 92984, 92995, 92996, 92920,
# 92921, 92924, 92925, 92928, 92929, 92933, 92934, 92937, 92938, 92941, 92943,
# 92944, 92973, C9600, C9601, C9602, C9603, C9604, C9605, C9606, C9607, C9608,
# G0290, G0291, or an ICD-9 procedure code of 00.66, 36.0, 36.01-36.19, 36.2, or
# an ICD-10 procedure code of '0210xxx', '0211xxx', '0212xxx', ‘0213xxx',
# '0270xxx', '0271xxx', '0272xxx', '0273xxx','02C0xxx', '02C1xxx', '02C2xxx',
# '02C3xxx', '3E07xxx'.

#### outcome, source version 2 (the version implemented below as spec_chd_v1) ----
#
# Source version 2 includes everything from source version 1 above, in
# addition to:
#
# Coronary revascularizations within the 60 days following an MI hospitalization
# may be elective and not represent a new coronary event, except the following
# conditions:
#
# Coronary revascularizations within the 60 days following MI will be included
# if these are linked to a primary discharge diagnosis for one of the following
# non-elective CHD-related hospitalizations, arrhythmia, cardiac arrest, heart
# failure and unstable angina:
#
# (a) ICD-9 diagnosis codes of 427.xx, 402.01, 402.11, 402.91, 404.01, 404.03,
# 404.11, 404.13, 404.91, 404.93, 428.x, 411.xx
#
# (b) ICD-10 diagnosis codes of I47.1, I47.2, I47.9, I48.91, I48.92, I49.01,
# I49.02, I49.1, I49.3, I49.40, I49.49, I49.5, I49.8, I49.9, R00.1, I46.9,
# I11.0, I13.0, I13.2, I50.1, I50.20, I50.21, I50.22, I50.23, I50.30, I50.31,
# I50.32, I50.33, I50.40, I50.41, I50.42, I50.43, I50.9, 'I50810', 'I50814',
# 'I50811', 'I50812', 'I50813', 'I5082', 'I5083', 'I5084', 'I5089', I20.0,
# I24.0, I24.1, I24.8.
#


# Reference only, not run: how the released codes were derived. The build
# reads them from data-raw/codesets/<condition>_<version>.csv instead.
# chd_icd9_dx_cond <- c(
#   range9("410", "414"),
#   expand9("V4581"),
#   expand9("V4582")
# )

# chd_icd10_dx_cond <- c(
#   expand10("I21"),
#   expand10("I22"),
#   "I2510",
#   "I25810",
#   "I25811",
#   "I25812",
#   "I253",
#   "I2541",
#   "I2542",
#   "Z951",
#   "Z9861",
#   "I200",
#   "I201",
#   "I208",
#   "I209",
#   "I240",
#   "I241",
#   "I248",
#   "I252",
#   "I255",
#   "I2582",
#   "I2583",
#   "I2584",
#   "I2589",
#   "I259"
# )

# chd_icd9_dx_out <- c(expand9("410")) %>%
#   enframe() %>%
#   # 410.x2 represent subsequent episode of care
#   filter_out(str_detect(value, "410\\d2")) %>%
#   deframe()

# chd_icd10_dx_out <- c(expand10("I21"), expand10("I22"))

# chd_proc_icd9 <- c(
#   "0066",
#   "360",
#   paste(3601:3619),
#   "362"
# )

# ICD-10-PCS procedure codes — expanded from prefix patterns using the
# CMS FY2026 ICD-10-PCS reference table bundled in R/sysdata.rda.
# Reference only, not run: how the released codes were derived. The build
# reads them from data-raw/codesets/<condition>_<version>.csv instead.
# chd_pcs_patterns <- c(
#   "0210xxx",
#   "0211xxx",
#   "0212xxx",
#   "0213xxx",
#   # CABG variants
#   "0270xxx",
#   "0271xxx",
#   "0272xxx",
#   "0273xxx",
#   # dilation (PCI) variants
#   "02C0xxx",
#   "02C1xxx",
#   "02C2xxx",
#   "02C3xxx",
#   # extirpation (PCI)
#   "3E07xxx"                                    # administration (thrombolytics)
# )
# chd_proc_icd10 <- expand_pcs(chd_pcs_patterns)

# HCPCS codes for coronary revascularization
# Reference only, not run: how the released codes were derived. The build
# reads them from data-raw/codesets/<condition>_<version>.csv instead.
# chd_hcpcs <- c(
#   # 33515 is not a valid CPT code, so the 33510-33519 range is split around it.
#   hcpcs_range("33510", "33514"),
#   hcpcs_range("33516", "33519"),
#   hcpcs_range("33521", "33523"),
#   "33530",
#   hcpcs_range("33533", "33536"),
#   hcpcs_range("92980", "92982"),
#   "92984",
#   "92995",
#   "92996",
#   "92920",
#   "92921",
#   "92924",
#   "92925",
#   "92928",
#   "92929",
#   "92933",
#   "92934",
#   "92937",
#   "92938",
#   "92941",
#   "92943",
#   "92944",
#   "92973",
#   paste0("C", hcpcs_range("9600", "9608")),
#   "G0290",
#   "G0291"
# )

# Collapsed to a single version (2026-08-15, issue #4): v1/v2 shared
# identical codes and differed only in the outcome definition narrative
# (v2 extended the outcome definition to include coronary
# revascularizations within 60 days of MI, linked to qualifying
# non-elective CHD-related primary discharge diagnoses). Now there's a
# single version carrying the more complete (formerly v2) narrative.
spec_chd_v1 <- CodeSpec$new(
  condition = "chd",
  version = "v1",
  label = "Coronary Heart Disease",
  defs = list(
    condition = c(
      "i" = "Any of the following:",
      "*" = paste0(
        "\u22651 inpatient claim with an ICD-9 diagnosis code of ",
        "{.strong 410.xx}\u2013{.strong 414.xx}, {.strong V45.81}, or {.strong V45.82}, or an ICD-10 ",
        "diagnosis code of {.strong I21.xxx}, {.strong I22.xxx}, or specified ",
        "{.strong I25}/{.strong I20}/{.strong I24} codes in any position."
      ),
      "*" = paste0(
        "\u22651 outpatient claim with the same ICD codes in any position."
      ),
      "*" = paste0(
        "\u22651 inpatient or outpatient claim with an ICD-9 procedure code of ",
        "{.strong 00.66}, {.strong 36.0}, {.strong 36.01}\u2013{.strong 36.19}, or {.strong 36.2}; ",
        "an ICD-10-PCS code for CABG or PCI; ",
        "or a HCPCS code for coronary revascularization."
      )
    ),
    outcome = c(
      "i" = "Any of the following:",
      "*" = paste0(
        "Overnight hospitalization with a {.emph primary} discharge diagnosis of AMI ",
        "({.strong 410.xx} excluding {.strong 410.x2}, or ICD-10 {.strong I21.xx} or {.strong I22.xx})."
      ),
      "*" = paste0(
        "Inpatient or outpatient claim with a procedure code for coronary ",
        "revascularization (see condition definition for procedure codes)."
      ),
      "i" = paste0(
        "Also includes coronary revascularizations occurring within 60 days ",
        "of an MI hospitalization, if linked to a {.emph primary} discharge ",
        "diagnosis for a non-elective CHD-related condition:"
      ),
      "*" = paste0(
        "ICD-9: {.strong 427.xx}, {.strong 402.01}, {.strong 402.11}, {.strong 402.91}, ",
        "{.strong 404.01}\u2013{.strong 404.93}, {.strong 428.x}, {.strong 411.xx}"
      ),
      "*" = paste0(
        "ICD-10: {.strong I47.1}, {.strong I47.2}, {.strong I47.9}, {.strong I48.91}, ",
        "{.strong I48.92}, {.strong I49.x}, {.strong R00.1}, {.strong I46.9}, HF codes ",
        "({.strong I11.0}, {.strong I13.0}, {.strong I13.2}, {.strong I50.x}), ",
        "{.strong I20.0}, {.strong I24.0}, {.strong I24.1}, {.strong I24.8}"
      )
    )
  ),
  codes = read_codeset("chd_v1")
)
