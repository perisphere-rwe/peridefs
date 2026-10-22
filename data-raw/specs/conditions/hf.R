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

hf_icd9 <- c(
  "40201",
  "40211",
  "40291",
  "40401",
  "40403",
  "40411",
  "40413",
  "40491",
  "40493",
  expand9("428")
)


hf_icd10 <- c(
  "I110",
  "I130",
  "I132",
  "I501",
  "I5020",
  "I5021",
  "I5022",
  "I5023",
  "I5030",
  "I5031",
  "I5032",
  "I5033",
  "I5040",
  "I5041",
  "I5042",
  "I5043",
  "I509",
  "I50810",
  "I50814",
  "I50811",
  "I50812",
  "I50813",
  "I5082",
  "I5083",
  "I5084",
  "I5089"
)
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
  codes = list(
    dx_icd9  = make_key("dx_icd9", hf_icd9),
    dx_icd10 = make_key("dx_icd10", hf_icd10)
  )
)
