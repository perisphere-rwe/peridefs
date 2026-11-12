# Heart failure -------------------------------------------------------------
# Sourced by data-raw/build_specs.R; do not source on its own.
# Runs in its own environment: every object defined here is local to this
# file, and only `spec_*` objects are passed on to later files.

## Heart Failure ----

### history, version 1 ----
#
# Any of the following:
#
# Algorithm based on ICD-9 codes:
#
# (a)  ≥ 1 inpatient claim with ICD-9 diagnoses (any position) of 402.01,
# 402.11, 402.91, 404.01, 404.03, 404.11, 404.13, 404.91, 404.93, 428.X.
#
# (b)  ≥ 2 outpatient or carrier claims separated by at least 30 days with ICD-9
# diagnoses (any position) of 402.01, 402.11, 402.91, 404.01, 404.03, 404.11,
# 404.13, 404.91, 404.93, 428.X,
#
# Algorithm based on ICD-10 codes:
#
# (a)  ≥ 1 inpatient claim with ICD-10 diagnoses (any position) of 'I110',
# 'I130', 'I132', 'I501', 'I5020', 'I5021', 'I5022', 'I5023', 'I5030', 'I5031',
# 'I5032', 'I5033', 'I5040', 'I5041', 'I5042', 'I5043', 'I509', 'I50810',
# 'I50814', 'I50811', 'I50812', 'I50813', 'I5082', 'I5083', 'I5084', 'I5089'.
#
# (b)  ≥ 2 outpatient or carrier claims separated by at least 30 days with
# ICD-10 diagnoses (any position) of 'I110', 'I130', 'I132', 'I501', 'I5020',
# 'I5021', 'I5022', 'I5023', 'I5030', 'I5031', 'I5032', 'I5033', 'I5040',
# 'I5041', 'I5042', 'I5043', 'I509', 'I50810', 'I50814', 'I50811', 'I50812',
# 'I50813', 'I5082', 'I5083', 'I5084', 'I5089',

### outcome, version 1 ----
#
# An overnight hospitalization with a discharge diagnosis code for heart failure
# (i.e., an ICD-9 diagnosis code of 402.01, 402.11, 402.91, 404.01, 404.03,
# 404.11, 404.13, 404.91, 404.93, 428.x, or an ICD-10 diagnosis code of I11.0,
# I13.0, I13.2, I50.1, I50.20, I50.21, I50.22, I50.23, I50.30, I50.31, I50.32,
# I50.33, I50.40, I50.41, I50.42, I50.43, I50.9, 'I50810', 'I50814', 'I50811',
# 'I50812', 'I50813', 'I5082', 'I5083', 'I5084', 'I5089') in the primary
# diagnosis position.
#

# Reference only, not run: how the released codes were derived. The build
# reads them from data-raw/codesets/<condition>_<version>.csv instead.
# hf_icd9 <- c(
#   "40201",
#   "40211",
#   "40291",
#   "40401",
#   "40403",
#   "40411",
#   "40413",
#   "40491",
#   "40493",
#   expand9("428")
# )


# hf_icd10 <- c(
#   "I110",
#   "I130",
#   "I132",
#   "I501",
#   "I5020",
#   "I5021",
#   "I5022",
#   "I5023",
#   "I5030",
#   "I5031",
#   "I5032",
#   "I5033",
#   "I5040",
#   "I5041",
#   "I5042",
#   "I5043",
#   "I509",
#   "I50810",
#   "I50814",
#   "I50811",
#   "I50812",
#   "I50813",
#   "I5082",
#   "I5083",
#   "I5084",
#   "I5089"
# )
spec_hf_v1 <- CodeSpec$new(
  condition = "hf", version = "v1", label = "Heart Failure",
  defs = list(
    condition = c(
      "i" = "Any of the following:",
      "*" = paste0(
        "\u22651 inpatient claim with an ICD-9 diagnosis of {.strong 402.01}, {.strong 402.11}, ",
        "{.strong 402.91}, {.strong 404.01}, {.strong 404.03}, {.strong 404.11}, {.strong 404.13}, ",
        "{.strong 404.91}, {.strong 404.93}, or {.strong 428.x}, or an ICD-10 diagnosis of ",
        "{.strong I11.0}, {.strong I13.0}, {.strong I13.2}, {.strong I50.1}, ",
        "{.strong I50.20}\u2013{.strong I50.43}, {.strong I50.9}, or specified {.strong I508xx} ",
        "codes in any diagnosis position."
      ),
      "*" = "\u22652 outpatient claims at least 30 days apart with the same codes."
    ),
    outcome = c(
      "*" = paste0(
        "Overnight hospitalization with a {.emph primary} discharge diagnosis for heart ",
        "failure (same ICD codes as condition definition)."
      )
    )
  ),
  codes = read_codeset("hf_v1")
)

### history and outcome, version 2 ----
#
# Not yet released (edited in place until it reaches production). ICD-10-CM only:
#   - Code universe: I11.0, I13.0, I13.2 and every billable I50 code (I50.1,
#     I50.20-I50.43, I50.810-I50.814, I50.82-I50.84, I50.89, I50.9). Checked
#     against the CMS FY2026 code list: v1 already contained exactly these 26
#     codes.
#   - Drops every ICD-9 code (402.x1, 404.x1/404.x3, 428.x), so claims before
#     2015-10-01 can no longer qualify.
#   - Condition (history): I50.x only. I11.0, I13.0 and I13.2 are not used
#     because they require a secondary I50.x on the same claim.
#   - Outcome: all 26 codes, with per-code attributes (outcome results only):
#       acuity               acute / acute_on_chronic / chronic / unspecified
#                            (NA for I11.0, I13.0, I13.2). I50.814, I50.82,
#                            I50.83, I50.84 have no acute/chronic wording in
#                            their descriptors and are `unspecified`.
#       required_secondary   codes that must appear in non-primary positions
#                            (I11.0: I50.x; I13.0, I13.2: I50.x + N18.x),
#                            otherwise `none`.
#       qualifies_as_primary TRUE for the acute and acute_on_chronic I50 codes
#                            (I50.21/.23/.31/.33/.41/.43/.811/.813) and for
#                            I11.0/I13.0/I13.2 (subject to required_secondary).
#   - The attributes illustrate the rules; the position logic itself is applied
#     in production (and, later, by a classifier).
#   - Not included (considered): I09.81 rheumatic heart failure, I97.130 /
#     I97.131 postprocedural heart failure, O29.12x cardiac failure due to
#     anesthesia during pregnancy.

# Reference only, not run: how the released codes were derived. The build
# reads them from data-raw/codesets/<condition>_<version>.csv instead.
# hf_v2_icd10 <- billable10(expand10("I110", "I130", "I132", "I50"))

spec_hf_v2 <- CodeSpec$new(
  condition = "hf", version = "v2", label = "Heart Failure",
  defs = list(
    condition = c(
      "i" = "Any of the following:",
      "*" = paste0(
        "\u22651 inpatient claim with an ICD-10 diagnosis of {.strong I11.0}, ",
        "{.strong I13.0}, {.strong I13.2}, or {.strong I50.x} (any billable I50 code) ",
        "in any diagnosis position."
      ),
      "*" = "\u22652 outpatient claims at least 30 days apart with the same codes.",
      "!" = paste0(
        "I11.0, I13.0 and I13.2 are not used for history because they require a ",
        "secondary I50.x code on the same claim."
      ),
      "!" = paste0(
        "ICD-10 only: claims before October 1, 2015 (ICD-9 era) cannot qualify."
      )
    ),
    outcome = c(
      "i" = "Acute heart failure hospitalization: an overnight hospitalization with either:",
      "*" = paste0(
        "a {.emph primary} discharge diagnosis of an acute or acute-on-chronic I50 code ",
        "({.strong I50.21}, {.strong I50.23}, {.strong I50.31}, {.strong I50.33}, ",
        "{.strong I50.41}, {.strong I50.43}, {.strong I50.811}, {.strong I50.813}); or"
      ),
      "*" = paste0(
        "a {.emph primary} diagnosis of {.strong I11.0} with any I50 code in a {.emph non-primary} ",
        "position; or a {.emph primary} diagnosis of {.strong I13.0} or {.strong I13.2} with both ",
        "any I50 code and any N18 code in {.emph non-primary} positions."
      ),
      "!" = paste0(
        "I50 codes with chronic or unspecified acuity (e.g., I50.9, I50.22) do not qualify ",
        "as the primary diagnosis, but any I50 code can be the secondary code in the I11.0/I13.x ",
        "rule. I50.84 (end-stage) does not qualify as a primary diagnosis."
      ),
      "i" = "Incident heart failure:",
      "*" = paste0(
        "any I50 code in any position during follow-up, with no I50, I11.0, I13.0 or I13.2 ",
        "in the baseline period. Baseline and follow-up windows are defined by the study."
      ),
      "!" = paste0(
        "ICD-10 only: hospitalizations before October 1, 2015 (ICD-9 era) cannot qualify. ",
        "Position rules are applied outside the package; see the acuity, required_secondary ",
        "and qualifies_as_primary columns of the outcome code set."
      )
    )
  ),
  # Derived as make_key("dx_icd10", hf_v2_icd10); attributes read from the CSV
  codes = read_codeset("hf_v2", attributes_for = "outcome")
)
