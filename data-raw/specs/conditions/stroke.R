# Stroke (ASCVD component) --------------------------------------------------
# Sourced by data-raw/build_specs.R; do not source on its own.
# Runs in its own environment: every object defined here is local to this
# file, and only `spec_*` objects are passed on to later files.

### Stroke ----

#### history, version 1 ----
#
# Any of the following:
#
# a)	≥1 overnight inpatient claim with a discharge diagnosis code for stroke
# (ICD-9 diagnosis codes 430.xx, 431.xx, 433.x1, 434.x1 or 436.x, or an ICD-10
# diagnosis code of 'I60.xx', 'I61.xx', 'I63.xx', ‘I67.89’, ‘I67850’, ‘I67858’)
# in any discharge diagnosis position.
#
# b)	≥2 EM-linked outpatient claims on separate days with an ICD-9 diagnosis
# code of 430.xx, 431.xx, 433.x1, 434.x1 or 436.x, or an ICD-10 diagnosis code
# of 'I60.xx', 'I61.xx', 'I63.xx', ‘I67.89’, ‘I67850’, ‘I67858’) in any
# discharge diagnosis position.
#
#### outcome, version 1 ----
#
# Overnight inpatient claim with a discharge diagnosis code for stroke (ICD-9
# diagnosis codes 430.xx, 431.xx, 433.x1, 434.x1 or 436.x, or an ICD-10
# diagnosis code of 'I60.xx', 'I61.xx', 'I63.xx', ‘I67.89’, ‘I67850’, ‘I67858’)
# in primary discharge diagnosis position. Inpatient claims less than or equal
# to 1 day apart may represent a hospital transfer. Therefore, hospitalizations
# will be combined into a single episode of care if the discharge date from a
# prior hospitalization is the same day or the day before the admission for a
# subsequent hospitalization.
#

stroke_icd9 <- unique(c(
  expand9("430"),
  # subarachnoid hemorrhage
  expand9("431"),
  # intracerebral hemorrhage
  Filter(\(x) endsWith(x, "1"), expand9("433")),
  # 433.x1
  Filter(\(x) endsWith(x, "1"), expand9("434")),
  # 434.x1
  expand9("436")
))

stroke_icd10 <- unique(c(
  expand10("I60"),
  # subarachnoid hemorrhage
  expand10("I61"),
  # intracerebral hemorrhage
  expand10("I63"),
  # cerebral infarction
  "I6789",
  # I67.89 — other cerebrovascular disease
  "I67850",
  # cerebrovascular disease NOS subtypes
  "I67858"
))

spec_stroke_v1 <- CodeSpec$new(
  condition = "stroke", version = "v1", label = "Stroke (Any)",
  defs = list(
    condition = c(
      "i" = "Any of the following:",
      "*" = paste0(
        "\u22651 overnight inpatient claim with a discharge diagnosis for stroke ",
        "(ICD-9: {.strong 430.xx}, {.strong 431.xx}, {.strong 433.x1}, {.strong 434.x1}, {.strong 436.x}; ",
        "ICD-10: {.strong I60.xx}, {.strong I61.xx}, {.strong I63.xx}, {.strong I67.89}, ",
        "{.strong I67850}, {.strong I67858}) in any discharge diagnosis position."
      ),
      "*" = "\u22652 outpatient claims on separate days with the same codes."
    ),
    outcome = c(
      "*" = paste0(
        "Overnight inpatient claim with a {.emph primary} discharge diagnosis for stroke ",
        "(same ICD codes as condition definition). Claims \u22641 day apart are combined ",
        "into a single episode of care."
      )
    )
  ),
  codes = list(
    dx_icd9  = make_key("dx_icd9", stroke_icd9),
    dx_icd10 = make_key("dx_icd10", stroke_icd10)
  )
)
