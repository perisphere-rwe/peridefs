# Cerebrovascular disease (ASCVD component) ---------------------------------
# Sourced by data-raw/build_specs.R; do not source on its own.
# Runs in its own environment: every object defined here is local to this
# file, and only `spec_*` objects are passed on to later files.

# Ischemic stroke is defined first because the cerebrovascular disease code
# sets below reuse `isch_stroke_icd9` / `isch_stroke_icd10`.

### Ischemic Stroke ----

# this is not used but i'm keeping it in case i ever want to make stroke
# a composite condition with ischemic stroke and other subtypes

#### history/outcome, version 1 ----
#
# Condition:
# ≥1 overnight inpatient claim with a discharge diagnosis code of 433.x1 or
# 434.x1 (ICD-9) or I63.xx (ICD-10) in any discharge diagnosis position.
#
# Outcome:
# Overnight inpatient claim with a primary discharge diagnosis of 433.x1 or
# 434.x1 (ICD-9) or I63.xx (ICD-10). Claims ≤1 day apart are combined into
# a single episode of care.

isch_stroke_icd9 <- tibble::enframe(
  c(expand9("433"), expand9("434")),
  name = NULL, value = "code"
) |>
  dplyr::filter(endsWith(code, "1")) |>
  tibble::deframe()

isch_stroke_icd10 <- expand10("I63")

spec_isch_stroke_v1 <- CodeSpec$new(
  condition = "isch_stroke", version = "v1", label = "Ischemic Stroke",
  defs = list(
    condition = c(
      "*" = paste0(
        "\u22651 overnight inpatient claim with a discharge diagnosis of ",
        "{.strong 433.x1} or {.strong 434.x1} (ICD-9), or {.strong I63.xx} (ICD-10) ",
        "in any discharge diagnosis position."
      )
    ),
    outcome = c(
      "*" = paste0(
        "Overnight inpatient claim with a {.emph primary} discharge diagnosis of ",
        "{.strong 433.x1} or {.strong 434.x1} (ICD-9), or {.strong I63.xx} (ICD-10). ",
        "Claims \u22641 day apart are combined into a single episode of care."
      )
    )
  ),
  codes = list(
    dx_icd9  = make_key("dx_icd9", isch_stroke_icd9),
    dx_icd10 = make_key("dx_icd10", isch_stroke_icd10)
  )
)


### Cerebrovascular Disease ----

#### history, version 1 ----
#
# Any of the following based on ICD-9 codes:
#
# (a)	At least 1 inpatient ICD-9 diagnosis (primary or secondary position) of
# 433.x1 or 434.x1
#
# (b)	At least 1 outpatient or carrier claim with ICD-9 diagnoses (any position)
# of 433.x1 or 434.x1.
#
# (c)	At least 1 claim with ICD-9 diagnoses (any position) of 433.x1 or 434.x1
#
# Any of the following based on ICD-10 codes:
#
# (a)	At least 1 inpatient ICD-10 diagnosis (primary or secondary position)
# I63.xx
#
# (b)	At least 1 outpatient or carrier claim with ICD-10 diagnoses (any
# position) of I63.xx
#
# (c)	At least 1 claim with ICD-10 diagnoses (any position) of I63.xx
#
# Patients with ≥1 inpatient or outpatient claim with any of following:
#
# (e)	An ICD9 procedure code: "3842", "3812", "3990", "0063".
#
# (f)	An ICD10 procedure code: '03CH0ZZ', '03CH4ZZ', '03CJ0ZZ', '03CJ4ZZ',
# '03CK0ZZ', '03CK4ZZ', '03CL0ZZ', '03CL4ZZ', '03CM0ZZ', '03CM4ZZ', '03CN0ZZ',
# '03CN4ZZ', '03RH07Z', '03RH0JZ', '03RH0KZ', '03RH47Z', '03RH4JZ', '03RH4KZ',
# '03RJ07Z', '03RJ0JZ', '03RJ0KZ', '03RJ47Z', '03RJ4JZ', '03RJ4KZ', '03RK07Z',
# '03RK0JZ', '03RK0KZ', '03RK47Z', '03RK4JZ', '03RK4KZ', '03RL07Z', '03RL0JZ',
# '03RL0KZ', '03RL47Z', '03RL4JZ', '03RL4KZ', '03RM07Z', '03RM0JZ', '03RM0KZ',
# '03RM47Z', '03RM4JZ', '03RM4KZ', '03RN07Z', '03RN0JZ', '03RN0KZ', '03RN47Z',
# '03RN4JZ', '03RN4KZ'.
#
# (g)	A CPT code for carotid revascularization: 35301, 35390, 37215, 37216,
# 0005T, 0075T, or 0076T.

cerebrovasc_proc_icd9 <- c("3842", "3812", "3990", "0063")


# ICD-10-PCS carotid stenting codes — listed explicitly in the Word document.
# expand_pcs() validates each against the FY2026 reference table and returns
# only those that are valid billable codes.
cerebrovasc_pcs_patterns <- c(
  "03CH0ZZ",
  "03CH4ZZ",
  "03CJ0ZZ",
  "03CJ4ZZ",
  "03CK0ZZ",
  "03CK4ZZ",
  "03CL0ZZ",
  "03CL4ZZ",
  "03CM0ZZ",
  "03CM4ZZ",
  "03CN0ZZ",
  "03CN4ZZ",
  "03RH07Z",
  "03RH0JZ",
  "03RH0KZ",
  "03RH47Z",
  "03RH4JZ",
  "03RH4KZ",
  "03RJ07Z",
  "03RJ0JZ",
  "03RJ0KZ",
  "03RJ47Z",
  "03RJ4JZ",
  "03RJ4KZ",
  "03RK07Z",
  "03RK0JZ",
  "03RK0KZ",
  "03RK47Z",
  "03RK4JZ",
  "03RK4KZ",
  "03RL07Z",
  "03RL0JZ",
  "03RL0KZ",
  "03RL47Z",
  "03RL4JZ",
  "03RL4KZ",
  "03RM07Z",
  "03RM0JZ",
  "03RM0KZ",
  "03RM47Z",
  "03RM4JZ",
  "03RM4KZ",
  "03RN07Z",
  "03RN0JZ",
  "03RN0KZ",
  "03RN47Z",
  "03RN4JZ",
  "03RN4KZ"
)
cerebrovasc_proc_icd10 <- expand_pcs(cerebrovasc_pcs_patterns)

cerebrovasc_cpt <- c("35301", "35390", "37215", "37216", "0005T", "0075T", "0076T")

spec_cerebrovasc_disease_v1 <- CodeSpec$new(
  condition = "cerebrovasc_disease", version = "v1",
  label = "Cerebrovascular Disease",
  defs = list(
    condition = c(
      "i" = "Any of the following:",
      "*" = paste0(
        "\u22651 inpatient claim with an ICD-9 diagnosis of {.strong 433.x1} or ",
        "{.strong 434.x1}, or an ICD-10 diagnosis of {.strong I63.xx} in any position."
      ),
      "*" = "\u22651 outpatient or carrier claim with the same codes.",
      "*" = "\u22651 claim with the same codes in HHA, DME, Hospice, or SNF files.",
      "*" = paste0(
        "\u22651 inpatient/outpatient claim with an ICD-9 procedure code for carotid ",
        "endarterectomy or revascularization ({.strong 38.42}, {.strong 38.12}, ",
        "{.strong 39.90}, {.strong 00.63}), an ICD-10-PCS code for carotid stenting, ",
        "or a CPT code for carotid revascularization ({.strong 35301}, {.strong 35390}, ",
        "{.strong 37215}, {.strong 37216}, {.strong 0005T}, {.strong 0075T}, {.strong 0076T})."
      )
    ),
    outcome = NULL
  ),
  codes = list(
    dx_icd9    = make_key_condition_only("dx_icd9", isch_stroke_icd9),
    dx_icd10   = make_key_condition_only("dx_icd10", isch_stroke_icd10),
    proc_icd9  = make_key_condition_only("proc_icd9", cerebrovasc_proc_icd9),
    proc_icd10 = make_key_condition_only("proc_icd10", cerebrovasc_proc_icd10),
    cpt        = make_key_condition_only("cpt", cerebrovasc_cpt)
  )
)
