## Build script: create and save all peridefs spec objects.
## Run via: source("data-raw/build_specs.R")
##
## Requires the 'icd' package (Suggests) for ICD diagnosis code expansion.
## icd::children() is called with defined = TRUE to return only codes that
## exist in the ICD-9-CM / ICD-10-CM reference tables.

library(icd)
library(tidyverse)
devtools::load_all()

# ---- ICD expansion helpers -----------------------------------------------

expand10 <- function(...) {
  unname(
    unclass(
      children(as.icd10cm(c(...)), defined = TRUE)
    )
  )
}

expand9 <- function(...) {
  unname(
    unclass(
      children(as.icd9cm(c(...)), defined = TRUE)
    )
  )
}

range10 <- function(a, b) {
  unname(
    unclass(
      expand_range(as.icd10cm(a), as.icd10cm(b), defined = TRUE)
    )
  )
}

range9 <- function(a, b) {
  unname(
    unclass(
      expand_range(as.icd9cm(a), as.icd9cm(b), defined = TRUE)
    )
  )
}

# Expand a numeric HCPCS/CPT range to individual code strings.
# e.g., hcpcs_range("33510", "33519") -> c("33510","33511",...,"33519")
hcpcs_range <- function(a, b) {
  as.character(seq(as.integer(a), as.integer(b)))
}

# Helper to build a standard key-level list
make_key <- function(codes,
                     condition = rep(TRUE, length(codes)),
                     outcome   = rep(TRUE, length(codes))) {
  list(
    codes     = codes,
    condition = condition,
    outcome   = outcome
  )
}

make_key_condition_only <- function(codes) {
  make_key(
    codes,
    condition = rep(TRUE,  length(codes)),
    outcome   = rep(FALSE, length(codes))
  )
}

# Specifications for comorbidities/outcomes ----

## Hypertension ----

### history, version 1 ----
#
# Any of the following:
#
# a)	≥1 inpatient claim with an ICD-9 discharge diagnosis code of 401.x, 403.0x,
# 403.1x, 403.9x, or an ICD-10 discharge diagnosis code of I10, I11.x, I12.x,
# I13.x, I15.x, I12.0, I12.9, I16.x in any discharge diagnosis position
#
# b)	≥2 physician evaluation and management visits (page 7) claims with an ICD-9
# diagnosis code of 401.x, 403.0x, 403.1x, 403.9x, or an ICD-10 diagnosis code
# of I10, I11.x, I12.x, I13.x, I15.x, I12.0, I12.9, I16.x, in any position at
# least 30 days apart.
#
### history, version 2 ----
#
# this adds medication to the defn of version 1
#
# Any of the following:
#
# a)	≥1 inpatient claim with an ICD-9 discharge diagnosis code of 401.x, 403.0x,
# 403.1x, 403.9x, or an ICD-10 discharge diagnosis code of I10, I11.x, I12.x,
# I13.x, I15.x, I12.0, I12.9, I16.x in any discharge diagnosis position
#
# b)	≥2 physician evaluation and management visits (page 7) claims with an ICD-9
# diagnosis code of 401.x, 403.0x, 403.1x, 403.9x, or an ICD-10 diagnosis code
# of I10, I11.x, I12.x, I13.x, I15.x, I12.0, I12.9, I16.x, in any position at
# least 30 days apart.
#
# c)	Two or more pharmacy fills for an antihypertensive medication:


htn_icd9 <- c(expand9("401"),
              expand9("4030"),
              expand9("4031"),
              expand9("4039"))

htn_icd10 <- unique(c("I10",
                      expand10("I11"),
                      expand10("I12"),
                      expand10("I13"),
                      expand10("I15"),
                      "I120",
                      "I129",
                      expand10("I16")))


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
    "\u22652 physician E&M visit claims with the same diagnosis codes, ",
    "at least 30 days apart."
  )
)

htn_v2_defs_condition <- c(
  htn_v1_defs_condition,
  "*" = paste0(
  "\u22652 pharmacy fills for an antihypertensive medication ",
  "(see spec_antihypertensive)"
  )
)

htn_codes <- list(
  dx_icd9  = make_key_condition_only(htn_icd9),
  dx_icd10 = make_key_condition_only(htn_icd10)
)

spec_htn_v1 <- CodeSpec$new(
  condition = "htn",
  version = "v1",
  label = "Hypertension",
  defs  = list(condition = htn_v1_defs_condition,
               outcome = NULL),
  codes = htn_codes
)

spec_htn_v2 <- CodeSpec$new(
  condition = "htn",
  version = "v2",
  label = "Hypertension",
  defs  = list(condition = htn_v2_defs_condition,
               outcome = NULL),
  codes = htn_codes
)


## ASCVD components ----

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
# (b) At least 1 outpatient physician evaluation and management claim (page 7)
# with an ICD-9 diagnosis code of 410.xx-414.xx, V45.81 or V45.82, or an ICD-10
# diagnosis code of I21.xxx, I22.xxx, I25.10, I25.810, I25.811, I25.812, I25.3,
# I25.41, I25.42, Z95.1, Z9861, I200, I201, I208, I209, I240, I241, I248, I252,
# I255, I2582, I2583, I2584, I2589, I259, in any position.
#
# (c) At least 1 inpatient or outpatient claim with an ICD-9 procedure code of
# 00.66, 36.0, 36.01-36.19, 36.2, or an ICD-10 procedure code of '0210xxx',
# '0211xxx', '0212xxx', ‘0213xxx', '0270xxx', '0271xxx', '0272xxx',
# '0273xxx','02C0xxx', '02C1xxx', '02C2xxx', '02C3xxx', '3E07xxx', or a HCPCS
# code of 33510-33519, 33521-33523, 33530, 33533-33536, 92980-92982, 92984,
# 92995, 92996, 92920, 92921, 92924, 92925, 92928, 92929, 92933, 92934, 92937,
# 92938, 92941, 92943, 92944, 92973, C9600, C9601, C9602, C9603, C9604, C9605,
# C9606, C9607, C9608, G0290, G0291.
#
# Condition (history) definition uses a broad set of dx codes plus proc/HCPCS.
# Outcome (v1) uses AMI dx codes (primary position) plus revascularization proc.
#
# ICD-10-PCS codes use a wildcard suffix "xxx" that represents 3 variable
# characters. These are stored as-is (pattern strings) in the proc_icd10 key.

#### outcome, version 1 ----
#
# Overnight hospitalization with a discharge diagnosis code for AMI (i.e., an
# ICD-9 code 410.xx, except 410.x2, which represent a subsequent episode of
# care, or an ICD-10 of code I21.xx, I22.xx) in the primary discharge diagnosis
# position or an inpatient or outpatient claim with a procedure code for
# coronary revascularization, including a HCPCS code of 33510-33519,
# 33521-33523, 33530, 33533-33536, 92980-92982, 92984, 92995, 92996, 92920,
# 92921, 92924, 92925, 92928, 92929, 92933, 92934, 92937, 92938, 92941, 92943,
# 92944, 92973, C9600, C9601, C9602, C9603, C9604, C9605, C9606, C9607, C9608,
# G0290, G0291, or an ICD-9 procedure code of 00.66, 36.0, 36.01-36.19, 36.2, or
# an ICD-10 procedure code of '0210xxx', '0211xxx', '0212xxx', ‘0213xxx',
# '0270xxx', '0271xxx', '0272xxx', '0273xxx','02C0xxx', '02C1xxx', '02C2xxx',
# '02C3xxx', '3E07xxx'.

#### outcome, version 2 ----
#
# Version 2 includes everything from version 1 in addition to:
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


chd_icd9_dx_cond <- c(
  range9("410", "414"),
  expand9("V4581"),
  expand9("V4582")
)

chd_icd10_dx_cond <- c(
  expand10("I21"),
  expand10("I22"),
  "I2510",
  "I25810",
  "I25811",
  "I25812",
  "I253",
  "I2541",
  "I2542",
  "Z951",
  "Z9861",
  "I200",
  "I201",
  "I208",
  "I209",
  "I240",
  "I241",
  "I248",
  "I252",
  "I255",
  "I2582",
  "I2583",
  "I2584",
  "I2589",
  "I259"
)

chd_icd9_dx_out <- c(expand9("410")) %>%
  enframe() %>%
  # 410.x2 represent subsequent episode of care
  filter_out(str_detect(value, "410\\d2")) %>%
  deframe()

chd_icd10_dx_out <- c(expand10("I21"), expand10("I22"))

chd_proc_icd9 <- c(
  "0066",
  "360",
  paste(3601:3619),
  "362"
)

# ICD-10-PCS procedure codes — expanded from prefix patterns using the
# CMS FY2026 ICD-10-PCS reference table bundled in R/sysdata.rda.
chd_pcs_patterns <- c(
  "0210xxx",
  "0211xxx",
  "0212xxx",
  "0213xxx",
  # CABG variants
  "0270xxx",
  "0271xxx",
  "0272xxx",
  "0273xxx",
  # dilation (PCI) variants
  "02C0xxx",
  "02C1xxx",
  "02C2xxx",
  "02C3xxx",
  # extirpation (PCI)
  "3E07xxx"                                    # administration (thrombolytics)
)
chd_proc_icd10 <- expand_pcs(chd_pcs_patterns)

# HCPCS codes for coronary revascularization
chd_hcpcs <- c(
  hcpcs_range("33510", "33519"),
  hcpcs_range("33521", "33523"),
  "33530",
  hcpcs_range("33533", "33536"),
  hcpcs_range("92980", "92982"),
  "92984",
  "92995",
  "92996",
  "92920",
  "92921",
  "92924",
  "92925",
  "92928",
  "92929",
  "92933",
  "92934",
  "92937",
  "92938",
  "92941",
  "92943",
  "92944",
  "92973",
  paste0("C", hcpcs_range("9600", "9608")),
  "G0290",
  "G0291"
)

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
        "\u22651 outpatient E&M claim with the same ICD codes in any position."
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
      )
    )
  ),
  codes = list(
    dx_icd9    = make_key(chd_icd9_dx_cond,
                          condition = rep(TRUE, length(chd_icd9_dx_cond)),
                          outcome   = chd_icd9_dx_cond %in% chd_icd9_dx_out),
    dx_icd10   = make_key(chd_icd10_dx_cond,
                          condition = rep(TRUE, length(chd_icd10_dx_cond)),
                          outcome   = chd_icd10_dx_cond %in% chd_icd10_dx_out),
    proc_icd9  = make_key(chd_proc_icd9),
    proc_icd10 = make_key(chd_proc_icd10),
    hcpcs      = make_key(chd_hcpcs)
  )
)

#### outcome, version 2 ----
# Same codes as v1; the outcome definition is extended to include coronary
# revascularizations within 60 days of MI when linked to a qualifying
# non-elective CHD-related primary discharge diagnosis.

spec_chd_v2 <- CodeSpec$new(
  condition = "chd", version = "v2", label = "Coronary Heart Disease",
  defs = list(
    condition = spec_chd_v1$get_defs("condition"),
    outcome = c(
      spec_chd_v1$get_defs("outcome"),
      "i" = paste0(
        "Version 2 additionally includes coronary revascularizations occurring ",
        "within 60 days of an MI hospitalization, if linked to a {.emph primary} ",
        "discharge diagnosis for a non-elective CHD-related condition:"
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
  codes = spec_chd_v1$.__enclos_env__$private$.codes
)

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
      "*" = "\u22652 E&M-linked outpatient claims on separate days with the same codes."
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
    dx_icd9  = make_key(stroke_icd9),
    dx_icd10 = make_key(stroke_icd10)
  )
)

### Ischemic Stroke ----

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
    dx_icd9  = make_key(isch_stroke_icd9),
    dx_icd10 = make_key(isch_stroke_icd10)
  )
)

### LEAD/PAD ----
#
# Lower extremity artery disease (LEAD)/peripheral arterial disease (PAD),
#
#### history, version 1 ----
#
# Any of the following:
#
# Algorithm based on ICD-9 codes:
#
# a)	≥1 hospitalization with a discharge diagnosis code of atherosclerosis or
# thrombosis of arteries of the extremities (ICD-9-CM diagnosis code of 440.2,
# 440.20, 440.21, 440.22, 440.23, 440.24, 440.29, 440.3, 440.30, 440.31, 440.32,
# 440.4, 443.9) in any discharge diagnosis position.
#
# b)	≥2 physician evaluation and management visits (page 7) with a diagnosis
# code of atherosclerosis or thrombosis of arteries of the extremities (ICD-9-CM
# diagnosis code of 440.2, 440.20, 440.21, 440.22, 440.23, 440.24, 440.29,
# 440.3, 440.30, 440.31, 440.32, 440.4, 443.9) in any discharge position on
# separate days.
#
# c)	≥1 CPT code of 37205, 75962, 36902, 36905, 37246, or 37247.
#
# Algorithm based on ICD-10 codes:
#
# a)	≥1 hospitalization with a discharge diagnosis code of atherosclerosis or
# thrombosis of arteries of the extremities (ICD-10-CM diagnosis code of I70.2,
# I70.20, I70.201, I70.202, I70.203, I70.208, I70.209, I70.21, I70.211, I70.212,
# I70.213, I70.218, I70.219, I70.22, I70.221, I70.222, I70.223, I70.228,
# I70.229, I70.23, I70.231, I70.232, I70.233, I70.234, I70.235, I70.238,
# I70.239, I70.24, I70.241, I70.242, I70.243, I70.244, I70.245, I70.248,
# I70.249, I70.25, I70.26, I70.261, I70.262, I70.263, I70.268, I70.269, I70.29,
# I70.291, I70.292, I70.293, I70.298, I70.299, I70.3, I70.30, I70.301, I70.302,
# I70.303, I70.308, I70.309, I70.31, I70.311, I70.312, I70.313, I70.318,
# I70.319, I70.32, I70.321, I70.322, I70.323, I70.328, I70.329, I70.33, I70.331,
# I70.332, I70.333, I70.334, I70.335, I70.338, I70.339, I70.34, I70.341,
# I70.342, I70.343, I70.344, I70.345, I70.348, I70.349, I70.35, I70.36, I70.361,
# I70.362, I70.363, I70.368, I70.369, I70.39, I70.391, I70.392, I70.393,
# I70.398, I70.399, I70.4, I70.40, I70.401, I70.402, I70.403, I70.408, I70.409,
# I70.41, I70.411, I70.412, I70.413, I70.418, I70.419, I70.42, I70.421, I70.422,
# I70.423, I70.428, I70.429, I70.43, I70.431, I70.432, I70.433, I70.434,
# I70.435, I70.438, I70.439, I70.44, I70.441, I70.442, I70.443, I70.444,
# I70.445, I70.448, I70.449, I70.45, I70.46, I70.461, I70.462, I70.463, I70.468,
# I70.469, I70.49, I70.491, I70.492, I70.493, I70.498, I70.499, I70.5, I70.50,
# I70.501, I70.502, I70.503, I70.508, I70.509, I70.51, I70.511, I70.512,
# I70.513, I70.518, I70.519, I70.52, I70.521, I70.522, I70.523, I70.528,
# I70.529, I70.53, I70.531, I70.532, I70.533, I70.534, I70.535, I70.538,
# I70.539, I70.54, I70.541, I70.542, I70.543, I70.544, I70.545, I70.548,
# I70.549, I70.55, I70.56, I70.561, I70.562, I70.563, I70.568, I70.569, I70.59,
# I70.591, I70.592, I70.593, I70.598, I70.599, I70.6, I70.60, I70.601, I70.602,
# I70.603, I70.608, I70.609, I70.61, I70.611, I70.612, I70.613, I70.618,
# I70.619, I70.62, I70.621, I70.622, I70.623, I70.628, I70.629, I70.63, I70.631,
# I70.632, I70.633, I70.634, I70.635, I70.638, I70.639, I70.64, I70.641,
# I70.642, I70.643, I70.644, I70.645, I70.648, I70.649, I70.65, I70.66, I70.661,
# I70.662, I70.663, I70.668, I70.669, I70.69, I70.691, I70.692, I70.693,
# I70.698, I70.699, I70.7, I70.70, I70.701, I70.702, I70.703, I70.708, I70.709,
# I70.71, I70.711, I70.712, I70.713, I70.718, I70.719, I70.72, I70.721, I70.722,
# I70.723, I70.728, I70.729, I70.73, I70.731, I70.732, I70.733, I70.734,
# I70.735, I70.738, I70.739, I70.74, I70.741, I70.742, I70.743, I70.744,
# I70.745, I70.748, I70.749, I70.75, I70.76, I70.761, I70.762, I70.763, I70.768,
# I70.769, I70.79, I70.791, I70.792, I70.793, I70.798, I70.799, I70.9, I70.92,
# I739) in any discharge diagnosis position.
#
# b)	≥2 physician evaluation and management visits (page 7) with a diagnosis
# code of atherosclerosis or thrombosis of arteries of the extremities
# (ICD-10-CM diagnosis code of I70.2, I70.20, I70.201, I70.202, I70.203,
# I70.208, I70.209, I70.21, I70.211, I70.212, I70.213, I70.218, I70.219, I70.22,
# I70.221, I70.222, I70.223, I70.228, I70.229, I70.23, I70.231, I70.232,
# I70.233, I70.234, I70.235, I70.238, I70.239, I70.24, I70.241, I70.242,
# I70.243, I70.244, I70.245, I70.248, I70.249, I70.25, I70.26, I70.261, I70.262,
# I70.263, I70.268, I70.269, I70.29, I70.291, I70.292, I70.293, I70.298,
# I70.299, I70.3, I70.30, I70.301, I70.302, I70.303, I70.308, I70.309, I70.31,
# I70.311, I70.312, I70.313, I70.318, I70.319, I70.32, I70.321, I70.322,
# I70.323, I70.328, I70.329, I70.33, I70.331, I70.332, I70.333, I70.334,
# I70.335, I70.338, I70.339, I70.34, I70.341, I70.342, I70.343, I70.344,
# I70.345, I70.348, I70.349, I70.35, I70.36, I70.361, I70.362, I70.363, I70.368,
# I70.369, I70.39, I70.391, I70.392, I70.393, I70.398, I70.399, I70.4, I70.40,
# I70.401, I70.402, I70.403, I70.408, I70.409, I70.41, I70.411, I70.412,
# I70.413, I70.418, I70.419, I70.42, I70.421, I70.422, I70.423, I70.428,
# I70.429, I70.43, I70.431, I70.432, I70.433, I70.434, I70.435, I70.438,
# I70.439, I70.44, I70.441, I70.442, I70.443, I70.444, I70.445, I70.448,
# I70.449, I70.45, I70.46, I70.461, I70.462, I70.463, I70.468, I70.469, I70.49,
# I70.491, I70.492, I70.493, I70.498, I70.499, I70.5, I70.50, I70.501, I70.502,
# I70.503, I70.508, I70.509, I70.51, I70.511, I70.512, I70.513, I70.518,
# I70.519, I70.52, I70.521, I70.522, I70.523, I70.528, I70.529, I70.53, I70.531,
# I70.532, I70.533, I70.534, I70.535, I70.538, I70.539, I70.54, I70.541,
# I70.542, I70.543, I70.544, I70.545, I70.548, I70.549, I70.55, I70.56, I70.561,
# I70.562, I70.563, I70.568, I70.569, I70.59, I70.591, I70.592, I70.593,
# I70.598, I70.599, I70.6, I70.60, I70.601, I70.602, I70.603, I70.608, I70.609,
# I70.61, I70.611, I70.612, I70.613, I70.618, I70.619, I70.62, I70.621, I70.622,
# I70.623, I70.628, I70.629, I70.63, I70.631, I70.632, I70.633, I70.634,
# I70.635, I70.638, I70.639, I70.64, I70.641, I70.642, I70.643, I70.644,
# I70.645, I70.648, I70.649, I70.65, I70.66, I70.661, I70.662, I70.663, I70.668,
# I70.669, I70.69, I70.691, I70.692, I70.693, I70.698, I70.699, I70.7, I70.70,
# I70.701, I70.702, I70.703, I70.708, I70.709, I70.71, I70.711, I70.712,
# I70.713, I70.718, I70.719, I70.72, I70.721, I70.722, I70.723, I70.728,
# I70.729, I70.73, I70.731, I70.732, I70.733, I70.734, I70.735, I70.738,
# I70.739, I70.74, I70.741, I70.742, I70.743, I70.744, I70.745, I70.748,
# I70.749, I70.75, I70.76, I70.761, I70.762, I70.763, I70.768, I70.769, I70.79,
# I70.791, I70.792, I70.793, I70.798, I70.799, I70.9, I70.92, I739) in any
# discharge position on separate days.
#
# c)	≥1 CPT code of 37205, 75962, 36902, 36905, 37246, or 37247.

# Lower extremity artery disease (LEAD)/peripheral arterial disease (PAD),

#### history, version 2 ---- (THIS SEEMS IDENTICAL TO V1??)
#
# In addition to version 1, any of the following:
#
# Algorithm based on ICD-9 codes:
#
# d)	≥1 hospitalization with a discharge diagnosis code of atherosclerosis or
# thrombosis of arteries of the extremities (ICD-9-CM diagnosis code of 440.2,
# 440.20, 440.21, 440.22, 440.23, 440.24, 440.29, 440.3, 440.30, 440.31, 440.32,
# 440.4, 443.9) in any discharge diagnosis position.
#
# e)	≥2 physician evaluation and management visits (page 7) with a diagnosis
# code of atherosclerosis or thrombosis of arteries of the extremities (ICD-9-CM
# diagnosis code of 440.2, 440.20, 440.21, 440.22, 440.23, 440.24, 440.29,
# 440.3, 440.30, 440.31, 440.32, 440.4, 443.9) in any discharge position on
# separate days.
#
# f)	≥1 CPT code of 37205, 75962, 36902, 36905, 37246, or 37247.
#
# Algorithm based on ICD-10 codes:
#
# d)	≥1 hospitalization with a discharge diagnosis code of atherosclerosis or
# thrombosis of arteries of the extremities (ICD-10-CM diagnosis code of I702xx,
# I703xx, I704xx, I70.92, I739) in any discharge diagnosis position.
#
# e)	≥2 physician evaluation and management visits (page 7) with a diagnosis
# code of atherosclerosis or thrombosis of arteries of the extremities
# (ICD-10-CM diagnosis code of I702xx, I703xx, I704xx, I70.92, I739) in any
# discharge position on separate days.
#
# f)	≥1 CPT code of 37205, 75962, 36902, 36905, 37246, or 37247.
#

#### outcome, version 1 ---- (NOT IMPLEMENTED)
#
# 1)	An overnight inpatient claim with a discharge diagnosis code for acute limb
# ischemia in the primary discharge diagnosis position.
#
# 2)	An overnight inpatient claim with a procedure code (from inpatient base
# claim or carrier line) for embolectomy, thrombectomy or peripheral surgical
# revascularization in any position.
#
# 3)	An overnight inpatient claim with a procedure code (from inpatient base
# claim or carrier line) for thrombolysis in the absence of a discharge
# diagnosis code for acute myocardial infarction, ischemic stroke or pulmonary
# embolism in any position.
#
# 4)	An overnight inpatient claim with a procedure code (from inpatient base
# claim or carrier line) for lower extremity amputation above the ankle in any
# position, in the absence of a discharge diagnosis code for traumatic
# amputation of a leg on the same hospitalization. Amputations were counted as
# an event only if the patient had ≥1 inpatient or outpatient claim with a
# diagnosis code for peripheral artery disease in any position prior to or on
# the date of the amputation.
#
# List of codes:
#
# ICD9 diagnosis codes for acute limb ischemia: 444.0, 444.01, 444.09, 444.22,
# 444.81.
#
# ICD10 diagnosis codes for acute limb ischemia: I74.01, I74.09, I74.3, I74.5.
#
# CPT procedure codes for embolectomy or thrombectomy: 34201, 34203.
#
# ICD9 procedure codes for peripheral surgical revascularization: 38.08, 38.16,
# 38.18, 38.38, 38.48, 38.68, 38.88, 39.25, 39.29.
#
# ICD10 procedure codes for peripheral surgical revascularization (2290):
# '0312090', '0312091', '0312092', '0312093', '0312094', '0312095', '0312096',
# '0312097', '0312098', '0312099', '031209B', '031209C', '031209D', '031209F',
# '031209J', '031209K', '03120A0', '03120A1', '03120A2', '03120A3', '03120A4',
# '03120A5', '03120A6', '03120A7', '03120A8', '03120A9', '03120AB', '03120AC',
# '03120AD', '03120AF', '03120AJ', '03120AK', '03120J0', '03120J1', '03120J2',
# '03120J3', '03120J4', '03120J5', '03120J6', '03120J7’, ‘03120J8’, ‘03120J9’,
# ‘03120JB’, ‘03120JC’, ‘03120JD’, ‘03120JF', '03120JJ’, ‘03120JK’, ‘03120K0’,
# ‘03120K1’, ‘03120K2’, ‘03120K3’, ‘03120K4’, ‘03120K5’, ‘03120K6’, ‘03120K7’,
# ‘03120K8’, ‘03120K9’, ‘03120KB', '03120KC’, ‘03120KD’, ‘03120KF’, ‘03120KJ’,
# ‘03120KK’, ‘03120Z0’, ‘03120Z1’, ‘03120Z2’, ‘03120Z3’, ‘03120Z4’, ‘03120Z5’,
# ‘03120Z6’, ‘03120Z7', '03120Z8’, ‘03120Z9’, ‘03120ZB’, ‘03120ZC’, ‘03120ZD’,
# ‘03120ZF’, ‘03120ZJ’, ‘03120ZK’, ‘0313090’, ‘0313091’, ‘0313092’, ‘0313093’,
# ‘0313094', '0313095’, ‘0313096’, ‘0313097’, ‘0313098’, ‘0313099’, ‘031309B’,
# ‘031309C’, ‘031309D’, ‘031309F’, ‘031309J’, ‘031309K’, ‘03130A0’, ‘03130A1',
# '03130A2’, ‘03130A3’, ‘03130A4’, ‘03130A5’, ‘03130A6’, ‘03130A7’, ‘03130A8’,
# ‘03130A9’, ‘03130AB’, ‘03130AC’, ‘03130AD’, ‘03130AF’, ‘03130AJ', '03130AK’,
# ‘03130J0’, ‘03130J1’, ‘03130J2’, ‘03130J3’, ‘03130J4’, ‘03130J5’, ‘03130J6’,
# ‘03130J7’, ‘03130J8’, ‘03130J9’, ‘03130JB’, ‘03130JC’, ‘03130JD', '03130JF’,
# ‘03130JJ’, ‘03130JK’, ‘03130K0’, ‘03130K1’, ‘03130K2’, ‘03130K3’, ‘03130K4’,
# ‘03130K5’, ‘03130K6’, ‘03130K7’, ‘03130K8’, ‘03130K9’, ‘03130KB’, ‘03130KC’,
# ‘03130KD’, ‘03130KF’, ‘03130KJ’, ‘03130KK’, ‘03130Z0’, ‘03130Z1’, ‘03130Z2’,
# ‘03130Z3’, ‘03130Z4’, ‘03130Z5’, ‘03130Z6’, ‘03130Z7', '03130Z8’, ‘03130Z9’,
# ‘03130ZB’, ‘03130ZC’, ‘03130ZD’, ‘03130ZF’, ‘03130ZJ’, ‘03130ZK’, ‘0314090’,
# ‘0314091’, ‘0314092’, ‘0314093’, ‘0314094', '0314095’, ‘0314096’, ‘0314097’,
# ‘0314098’, ‘0314099’, ‘031409B’, ‘031409C’, ‘031409D’, ‘031409F’, ‘031409J’,
# ‘031409K’, ‘03140A0’, ‘03140A1', '03140A2’, ‘03140A3’, ‘03140A4’, ‘03140A5’,
# ‘03140A6’, ‘03140A7’, ‘03140A8’, ‘03140A9’, ‘03140AB’, ‘03140AC’, ‘03140AD’,
# ‘03140AF’, ‘03140AJ', '03140AK’, ‘03140J0’, ‘03140J1’, ‘03140J2’, ‘03140J3’,
# ‘03140J4’, ‘03140J5’, ‘03140J6’, ‘03140J7’, ‘03140J8’, ‘03140J9’, ‘03140JB’,
# ‘03140JC’, ‘03140JD', '03140JF’, ‘03140JJ’, ‘03140JK’, ‘03140K0’, ‘03140K1’,
# ‘03140K2’, ‘03140K3’, ‘03140K4’, ‘03140K5’, ‘03140K6’, ‘03140K7’, ‘03140K8’,
# ‘03140K9’, ‘03140KB’, ‘03140KC’, ‘03140KD’, ‘03140KF’, ‘03140KJ’, ‘03140KK’,
# ‘03140Z0’, ‘03140Z1’, ‘03140Z2’, ‘03140Z3’, ‘03140Z4’, ‘03140Z5’, ‘03140Z6’,
# ‘03140Z7', '03140Z8’, ‘03140Z9’, ‘03140ZB’, ‘03140ZC’, ‘03140ZD’, ‘03140ZF’,
# ‘03140ZJ’, ‘03140ZK’, ‘0315090’, ‘0315091’, ‘0315092’, ‘0315093’, ‘0315094',
# '0315095’, ‘0315096’, ‘0315097’, ‘0315098’, ‘0315099’, ‘031509B’, ‘031509C’,
# ‘031509D’, ‘031509F’, ‘031509J’, ‘031509K’, ‘03150A0’, ‘03150A1', '03150A2’,
# ‘03150A3’, ‘03150A4’, ‘03150A5’, ‘03150A6’, ‘03150A7’, ‘03150A8’, ‘03150A9’,
# ‘03150AB’, ‘03150AC’, ‘03150AD’, ‘03150AF’, ‘03150AJ', '03150AK’, ‘03150J0’,
# ‘03150J1’, ‘03150J2’, ‘03150J3’, ‘03150J4’, ‘03150J5’, ‘03150J6’, ‘03150J7’,
# ‘03150J8’, ‘03150J9’, ‘03150JB’, ‘03150JC’, ‘03150JD', '03150JF’, ‘03150JJ’,
# ‘03150JK’, ‘03150K0’, ‘03150K1’, ‘03150K2’, ‘03150K3’, ‘03150K4’, ‘03150K5’,
# ‘03150K6’, ‘03150K7’, ‘03150K8’, ‘03150K9’, ‘03150KB', '03150KC', '03150KD',
# '03150KF’, ‘03150KJ’, ‘03150KK’, ‘03150Z0’, ‘03150Z1’, ‘03150Z2’, ‘03150Z3’,
# ‘03150Z4’, ‘03150Z5’, ‘03150Z6’, ‘03150Z7’, ‘03150Z8’, ‘03150Z9’, ‘03150ZB’,
# ‘03150ZC’, ‘03150ZD’, ‘03150ZF’, ‘03150ZJ’, ‘03150ZK’, ‘0316090’, ‘0316091’,
# ‘0316092’, ‘0316093’, ‘0316094’, ‘0316095’, ‘0316096’, ‘0316097’, ‘0316098’,
# ‘0316099’, ‘031609B’, ‘031609C’, ‘031609D’, ‘031609F’, ‘031609J’, ‘031609K’,
# ‘03160A0’, ‘03160A1’, ‘03160A2’, ‘03160A3’, ‘03160A4’, ‘03160A5’, ‘03160A6’,
# ‘03160A7’, ‘03160A8’, ‘03160A9’, ‘03160AB’, ‘03160AC’, ‘03160AD’, ‘03160AF’,
# ‘03160AJ’, ‘03160AK’, ‘03160J0’, ‘03160J1’, ‘03160J2’, ‘03160J3’, ‘03160J4’,
# ‘03160J5’, ‘03160J6’, ‘03160J7’, ‘03160J8’, ‘03160J9’, ‘03160JB’, ‘03160JC’,
# ‘03160JD’, ‘03160JF’, ‘03160JJ’, ‘03160JK’, ‘03160K0’, ‘03160K1’, ‘03160K2’,
# ‘03160K3’, ‘03160K4’, ‘03160K5’, ‘03160K6’, ‘03160K7’, ‘03160K8’, ‘03160K9’,
# ‘03160KB’, ‘03160KC’, ‘03160KD’, ‘03160KF’, ‘03160KJ’, ‘03160KK’, ‘03160Z0’,
# ‘03160Z1’, ‘03160Z2’, ‘03160Z3’, ‘03160Z4’, ‘03160Z5’, ‘03160Z6’, ‘03160Z7’,
# ‘03160Z8’, ‘03160Z9’, ‘03160ZB’, ‘03160ZC’, ‘03160ZD’, ‘03160ZF’, ‘03160ZJ’,
# ‘03160ZK’, ‘0317090’, ‘0317093’, ‘031709D’, ‘031709F’, ‘03170A0’, ‘03170A3’,
# ‘03170AD’, ‘03170AF’, ‘03170J0’, ‘03170J3’, ‘03170JD’, ‘03170JF’, ‘03170K0’,
# ‘03170K3’, ‘03170KD’, ‘03170KF’, ‘03170Z0’, ‘03170Z3’, ‘03170ZD’, ‘03170ZF’,
# ‘0318091’, ‘0318094’, ‘031809D’, ‘031809F’, ‘03180A1’, ‘03180A4’, ‘03180AD’,
# ‘03180AF’, ‘03180J1’, ‘03180J4’, ‘03180JD’, ‘03180JF’, ‘03180K1’, ‘03180K4’,
# ‘03180KD’, ‘03180KF’, ‘03180Z1’, ‘03180Z4’, ‘03180ZD’, ‘03180ZF’, ‘0319093’,
# ‘031909F’, ‘03190A3’, ‘03190AF’, ‘03190J3’, ‘03190JF’, ‘03190K3’, ‘03190KF’,
# ‘03190Z3’, ‘03190ZF’, ‘031A094’, ‘031A09F’, ‘031A0A4’, ‘031A0AF’, ‘031A0J4’,
# ‘031A0JF’, ‘031A0K4’, ‘031A0KF’, ‘031A0Z4’, ‘031A0ZF’, ‘031B093’, ‘031B09F’,
# ‘031B0A3’, ‘031B0AF’, ‘031B0J3’, ‘031B0JF’, ‘031B0K3’, ‘031B0KF’, ‘031B0Z3’,
# ‘031B0ZF’, ‘031C094’, ‘031C09F’, ‘031C0A4’, ‘031C0AF’, ‘031C0J4’, ‘031C0JF’,
# ‘031C0K4’, ‘031C0KF’, ‘031C0Z4’, ‘031C0ZF’, ‘031G09G’, ‘031G0AG’, ‘031G0JG’,
# ‘031G0KG’, ‘031G0ZG’, ‘031H09J’, ‘031H0AJ’, ‘031H0JJ’, ‘031H0KJ’, ‘031H0ZJ’,
# ‘031J09K’, ‘031J0AK’, ‘031J0JK’, ‘031J0KK’, ‘031J0ZK’, ‘031K09J’, ‘031K0AJ’,
# ‘031K0JJ’, ‘031K0KJ’, ‘031K0ZJ’, ‘031L09K’, ‘031L0AK’, ‘031L0JK’, ‘031L0KK’,
# ‘031L0ZK’, ‘031M09J’, ‘031M0AJ’, ‘031M0JJ’, ‘031M0KJ’, ‘031M0ZJ’, ‘031N09K’,
# ‘031N0AK’, ‘031N0JK’, ‘031N0KK’, ‘031N0ZK’, ‘0410096’, ‘0410097’, ‘0410098’,
# ‘0410099’, ‘041009B’, ‘041009C’, ‘041009D’, ‘041009F’, ‘041009G’, ‘041009H’,
# ‘041009J’, ‘041009K’, ‘041009Q’, ‘041009R’, ‘04100A6’, ‘04100A7’, ‘04100A8’,
# ‘04100A9’, ‘04100AB’, ‘04100AC’, ‘04100AD’, ‘04100AF’, ‘04100AG’, ‘04100AH’,
# ‘04100AJ’, ‘04100AK’, ‘04100AQ’, ‘04100AR’, ‘04100J6’, ‘04100J7’, ‘04100J8’,
# ‘04100J9’, ‘04100JB’, ‘04100JC’, ‘04100JD’, ‘04100JF’, ‘04100JG’, ‘04100JH’,
# ‘04100JJ’, ‘04100JK’, ‘04100JQ’, ‘04100JR’, ‘04100K6’, ‘04100K7’, ‘04100K8’,
# ‘04100K9’, ‘04100KB’, ‘04100KC’, ‘04100KD’, ‘04100KF’, ‘04100KG’, ‘04100KH’,
# ‘04100KJ’, ‘04100KK’, ‘04100KQ’, ‘04100KR’, ‘04100Z6’, ‘04100Z7’, ‘04100Z8’,
# ‘04100Z9’, ‘04100ZB’, ‘04100ZC’, ‘04100ZD’, ‘04100ZF’, ‘04100ZG’, ‘04100ZH’,
# ‘04100ZJ’, ‘04100ZK’, ‘04100ZQ’, ‘04100ZR’, ‘0410496’, ‘0410497’, ‘0410498’,
# ‘0410499’, ‘041049B’, ‘041049C’, ‘041049D’, ‘041049F’, ‘041049G’, ‘041049H’,
# ‘041049J’, ‘041049K’, ‘041049Q’, ‘041049R’, ‘04104A6’, ‘04104A7’, ‘04104A8’,
# ‘04104A9’, ‘04104AB’, ‘04104AC’, ‘04104AD’, ‘04104AF’, ‘04104AG’, ‘04104AH’,
# ‘04104AJ’, ‘04104AK’, ‘04104AQ’, ‘04104AR’, ‘04104J6’, ‘04104J7’, ‘04104J8’,
# ‘04104J9’, ‘04104JB’, ‘04104JC’, ‘04104JD’, ‘04104JF’, ‘04104JG’, ‘04104JH’,
# ‘04104JJ’, ‘04104JK’, ‘04104JQ’, ‘04104JR’, ‘04104K6’, ‘04104K7’, ‘04104K8’,
# ‘04104K9’, ‘04104KB’, ‘04104KC’, ‘04104KD’, ‘04104KF’, ‘04104KG’, ‘04104KH’,
# ‘04104KJ’, ‘04104KK’, ‘04104KQ’, ‘04104KR’, ‘04104Z6’, ‘04104Z7’, ‘04104Z8’,
# ‘04104Z9’, ‘04104ZB’, ‘04104ZC’, ‘04104ZD’, ‘04104ZF’, ‘04104ZG’, ‘04104ZH’,
# ‘04104ZJ’, ‘04104ZK’, ‘04104ZQ’, ‘04104ZR’, ‘041C09H’, ‘041C09J’, ‘041C09K’,
# ‘041C0AH’, ‘041C0AJ’, ‘041C0AK’, ‘041C0JH’, ‘041C0JJ’, ‘041C0JK’, ‘041C0KH’,
# ‘041C0KJ’, ‘041C0KK’, ‘041C0ZH’, ‘041C0ZJ’, ‘041C0ZK’, ‘041C49H’, ‘041C49J’,
# ‘041C49K’, ‘041C4AH’, ‘041C4AJ’, ‘041C4AK’, ‘041C4JH’, ‘041C4JJ’, ‘041C4JK’,
# ‘041C4KH’, ‘041C4KJ’, ‘041C4KK’, ‘041C4ZH’, ‘041C4ZJ’, ‘041C4ZK’, ‘041D09H’,
# ‘041D09J’, ‘041D09K’, ‘041D0AH’, ‘041D0AJ’, ‘041D0AK’, ‘041D0JH’, ‘041D0JJ’,
# ‘041D0JK’, ‘041D0KH’, ‘041D0KJ’, ‘041D0KK’, ‘041D0ZH’, ‘041D0ZJ’, ‘041D0ZK’,
# ‘041D49H’, ‘041D49J’, ‘041D49K’, ‘041D4AH’, ‘041D4AJ’, ‘041D4AK’, ‘041D4JH’,
# ‘041D4JJ’, ‘041D4JK’, ‘041D4KH’, ‘041D4KJ’, ‘041D4KK’, ‘041D4ZH’, ‘041D4ZJ’,
# ‘041D4ZK’, ‘041E09H’, ‘041E09J’, ‘041E09K’, ‘041E0AH’, ‘041E0AJ’, ‘041E0AK’,
# ‘041E0JH’, ‘041E0JJ’, ‘041E0JK’, ‘041E0KH’, ‘041E0KJ’, ‘041E0KK’, ‘041E0ZH’,
# ‘041E0ZJ’, ‘041E0ZK’, ‘041E49H’, ‘041E49J’, ‘041E49K’, ‘041E4AH’, ‘041E4AJ’,
# ‘041E4AK’, ‘041E4JH’, ‘041E4JJ’, ‘041E4JK’, ‘041E4KH’, ‘041E4KJ’, ‘041E4KK’,
# ‘041E4ZH’, ‘041E4ZJ’, ‘041E4ZK’, ‘041F09H’, ‘041F09J’, ‘041F09K’, ‘041F0AH’,
# ‘041F0AJ’, ‘041F0AK’, ‘041F0JH’, ‘041F0JJ’, ‘041F0JK’, ‘041F0KH’, ‘041F0KJ’,
# ‘041F0KK’, ‘041F0ZH’, ‘041F0ZJ’, ‘041F0ZK’, ‘041F49H’, ‘041F49J’, ‘041F49K’,
# ‘041F4AH’, ‘041F4AJ’, ‘041F4AK’, ‘041F4JH’, ‘041F4JJ’, ‘041F4JK’, ‘041F4KH’,
# ‘041F4KJ’, ‘041F4KK’, ‘041F4ZH’, ‘041F4ZJ’, ‘041F4ZK’, ‘041H09H’, ‘041H09J’,
# ‘041H09K’, ‘041H0AH’, ‘041H0AJ’, ‘041H0AK’, ‘041H0JH’, ‘041H0JJ’, ‘041H0JK’,
# ‘041H0KH’, ‘041H0KJ’, ‘041H0KK’, ‘041H0ZH’, ‘041H0ZJ’, ‘041H0ZK’, ‘041H49H’,
# ‘041H49J’, ‘041H49K’, ‘041H4AH’, ‘041H4AJ’, ‘041H4AK’, ‘041H4JH’, ‘041H4JJ’,
# ‘041H4JK’, ‘041H4KH’, ‘041H4KJ’, ‘041H4KK’, ‘041H4ZH’, ‘041H4ZJ’, ‘041H4ZK’,
# ‘041J09H’, ‘041J09J’, ‘041J09K’, ‘041J0AH’, ‘041J0AJ’, ‘041J0AK’, ‘041J0JH’,
# ‘041J0JJ’, ‘041J0JK’, ‘041J0KH’, ‘041J0KJ’, ‘041J0KK’, ‘041J0ZH’, ‘041J0ZJ’,
# ‘041J0ZK’, ‘041J49H’, ‘041J49J’, ‘041J49K’, ‘041J4AH’, ‘041J4AJ’, ‘041J4AK’,
# ‘041J4JH’, ‘041J4JJ’, ‘041J4JK’, ‘041J4KH’, ‘041J4KJ’, ‘041J4KK’, ‘041J4ZH’,
# ‘041J4ZJ’, ‘041J4ZK’, ‘041K09H’, ‘041K09J’, ‘041K09K’, ‘041K09L’, ‘041K09M’,
# ‘041K09N’, ‘041K09P’, ‘041K09Q’, ‘041K09S’, ‘041K0AH’, ‘041K0AJ’, ‘041K0AK’,
# ‘041K0AL’, ‘041K0AM’, ‘041K0AN’, ‘041K0AP’, ‘041K0AQ’, ‘041K0AS’, ‘041K0JH’,
# ‘041K0JJ’, ‘041K0JK’, ‘041K0JL’, ‘041K0JM’, ‘041K0JN’, ‘041K0JP’, ‘041K0JQ’,
# ‘041K0JS’, ‘041K0KH’, ‘041K0KJ’, ‘041K0KK’, ‘041K0KL’, ‘041K0KM’, ‘041K0KN’,
# ‘041K0KP’, ‘041K0KQ’, ‘041K0KS’, ‘041K0ZH’, ‘041K0ZJ’, ‘041K0ZK’, ‘041K0ZL’,
# ‘041K0ZM’, ‘041K0ZN’, ‘041K0ZP’, ‘041K0ZQ’, ‘041K0ZS’, ‘041K49H’, ‘041K49J’,
# ‘041K49K’, ‘041K49L’, ‘041K49M’, ‘041K49N’, ‘041K49P’, ‘041K49Q’, ‘041K49S’,
# ‘041K4AH’, ‘041K4AJ’, ‘041K4AK’, ‘041K4AL’, ‘041K4AM’, ‘041K4AN’, ‘041K4AP’,
# ‘041K4AQ’, ‘041K4AS’, ‘041K4JH’, ‘041K4JJ’, ‘041K4JK’, ‘041K4JL’, ‘041K4JM’,
# ‘041K4JN’, ‘041K4JP’, ‘041K4JQ’, ‘041K4JS’, ‘041K4KH’, ‘041K4KJ’, ‘041K4KK’,
# ‘041K4KL’, ‘041K4KM’, ‘041K4KN’, ‘041K4KP’, ‘041K4KQ’, ‘041K4KS’, ‘041K4ZH’,
# ‘041K4ZJ’, ‘041K4ZK’, ‘041K4ZL’, ‘041K4ZM’, ‘041K4ZN’, ‘041K4ZP’, ‘041K4ZQ’,
# ‘041K4ZS’, ‘041L09H’, ‘041L09J’, ‘041L09K’, ‘041L09L’, ‘041L09M’, ‘041L09N’,
# ‘041L09P’, ‘041L09Q’, ‘041L09S’, ‘041L0AH’, ‘041L0AJ’, ‘041L0AK’, ‘041L0AL’,
# ‘041L0AM’, ‘041L0AN’, ‘041L0AP’, ‘041L0AQ’, ‘041L0AS’, ‘041L0JH’, ‘041L0JJ’,
# ‘041L0JK’, ‘041L0JL’, ‘041L0JM’, ‘041L0JN’, ‘041L0JP’, ‘041L0JQ’, ‘041L0JS’,
# ‘041L0KH’, ‘041L0KJ’, ‘041L0KK’, ‘041L0KL’, ‘041L0KM’, ‘041L0KN’, ‘041L0KP’,
# ‘041L0KQ’, ‘041L0KS’, ‘041L0ZH’, ‘041L0ZJ’, ‘041L0ZK’, ‘041L0ZL’, ‘041L0ZM’,
# ‘041L0ZN’, ‘041L0ZP’, ‘041L0ZQ’, ‘041L0ZS’, ‘041L49H’, ‘041L49J’, ‘041L49K’,
# ‘041L49L’, ‘041L49M’, ‘041L49N’, ‘041L49P’, ‘041L49Q’, ‘041L49S’, ‘041L4AH’,
# ‘041L4AJ’, ‘041L4AK’, ‘041L4AL’, ‘041L4AM’, ‘041L4AN’, ‘041L4AP’, ‘041L4AQ’,
# ‘041L4AS’, ‘041L4JH’, ‘041L4JJ’, ‘041L4JK’, ‘041L4JL’, ‘041L4JM’, ‘041L4JN’,
# ‘041L4JP’, ‘041L4JQ’, ‘041L4JS’, ‘041L4KH’, ‘041L4KJ’, ‘041L4KK’, ‘041L4KL’,
# ‘041L4KM’, ‘041L4KN’, ‘041L4KP’, ‘041L4KQ’, ‘041L4KS’, ‘041L4ZH’, ‘041L4ZJ’,
# ‘041L4ZK’, ‘041L4ZL’, ‘041L4ZM’, ‘041L4ZN’, ‘041L4ZP’, ‘041L4ZQ’, ‘041L4ZS’,
# ‘041M09L’, ‘041M09M’, ‘041M09P’, ‘041M09Q’, ‘041M09S’, ‘041M0AL’, ‘041M0AM’,
# ‘041M0AP’, ‘041M0AQ’, ‘041M0AS’, ‘041M0JL’, ‘041M0JM’, ‘041M0JP’, ‘041M0JQ’,
# ‘041M0JS’, ‘041M0KL’, ‘041M0KM’, ‘041M0KP’, ‘041M0KQ’, ‘041M0KS’, ‘041M0ZL’,
# ‘041M0ZM’, ‘041M0ZP’, ‘041M0ZQ’, ‘041M0ZS’, ‘041M49L’, ‘041M49M’, ‘041M49P’,
# ‘041M49Q’, ‘041M49S’, ‘041M4AL’, ‘041M4AM’, ‘041M4AP’, ‘041M4AQ’, ‘041M4AS’,
# ‘041M4JL’, ‘041M4JM’, ‘041M4JP’, ‘041M4JQ’, ‘041M4JS’, ‘041M4KL’, ‘041M4KM’,
# ‘041M4KP’, ‘041M4KQ’, ‘041M4KS’, ‘041M4ZL’, ‘041M4ZM’, ‘041M4ZP’, ‘041M4ZQ’,
# ‘041M4ZS’, ‘041N09L’, ‘041N09M’, ‘041N09P’, ‘041N09Q’, ‘041N09S’, ‘041N0AL’,
# ‘041N0AM’, ‘041N0AP’, ‘041N0AQ’, ‘041N0AS’, ‘041N0JL’, ‘041N0JM’, ‘041N0JP’,
# ‘041N0JQ’, ‘041N0JS’, ‘041N0KL’, ‘041N0KM’, ‘041N0KP’, ‘041N0KQ’, ‘041N0KS’,
# ‘041N0ZL’, ‘041N0ZM’, ‘041N0ZP’, ‘041N0ZQ’, ‘041N0ZS’, ‘041N49L’, ‘041N49M’,
# ‘041N49P’, ‘041N49Q’, ‘041N49S’, ‘041N4AL’, ‘041N4AM’, ‘041N4AP’, ‘041N4AQ’,
# ‘041N4AS’, ‘041N4JL’, ‘041N4JM’, ‘041N4JP’, ‘041N4JQ’, ‘041N4JS’, ‘041N4KL’,
# ‘041N4KM’, ‘041N4KP’, ‘041N4KQ’, ‘041N4KS’, ‘041N4ZL’, ‘041N4ZM’, ‘041N4ZP’,
# ‘041N4ZQ’, ‘041N4ZS’, ‘041T09P’, ‘041T09Q’, ‘041T09S’, ‘041T0AP’, ‘041T0AQ’,
# ‘041T0AS’, ‘041T0JP’, ‘041T0JQ’, ‘041T0JS’, ‘041T0KP’, ‘041T0KQ’, ‘041T0KS’,
# ‘041T0ZP’, ‘041T0ZQ’, ‘041T0ZS’, ‘041T49P’, ‘041T49Q’, ‘041T49S’, ‘041T4AP’,
# ‘041T4AQ’, ‘041T4AS’, ‘041T4JP’, ‘041T4JQ’, ‘041T4JS’, ‘041T4KP’, ‘041T4KQ’,
# ‘041T4KS’, ‘041T4ZP’, ‘041T4ZQ’, ‘041T4ZS’, ‘041U09P’, ‘041U09Q’, ‘041U09S’,
# ‘041U0AP’, ‘041U0AQ’, ‘041U0AS’, ‘041U0JP’, ‘041U0JQ’, ‘041U0JS’, ‘041U0KP’,
# ‘041U0KQ’, ‘041U0KS’, ‘041U0ZP’, ‘041U0ZQ’, ‘041U0ZS’, ‘041U49P’, ‘041U49Q’,
# ‘041U49S’, ‘041U4AP’, ‘041U4AQ’, ‘041U4AS’, ‘041U4JP’, ‘041U4JQ’, ‘041U4JS’,
# ‘041U4KP’, ‘041U4KQ’, ‘041U4KS’, ‘041U4ZP’, ‘041U4ZQ’, ‘041U4ZS’, ‘041V09P’,
# ‘041V09Q’, ‘041V09S’, ‘041V0AP’, ‘041V0AQ’, ‘041V0AS’, ‘041V0JP’, ‘041V0JQ’,
# ‘041V0JS’, ‘041V0KP’, ‘041V0KQ’, ‘041V0KS’, ‘041V0ZP’, ‘041V0ZQ’, ‘041V0ZS’,
# ‘041V49P’, ‘041V49Q’, ‘041V49S’, ‘041V4AP’, ‘041V4AQ’, ‘041V4AS’, ‘041V4JP’,
# ‘041V4JQ’, ‘041V4JS’, ‘041V4KP’, ‘041V4KQ’, ‘041V4KS’, ‘041V4ZP’, ‘041V4ZQ’,
# ‘041V4ZS’, ‘041W09P’, ‘041W09Q’, ‘041W09S’, ‘041W0AP’, ‘041W0AQ’, ‘041W0AS’,
# ‘041W0JP’, ‘041W0JQ’, ‘041W0JS’, ‘041W0KP’, ‘041W0KQ’, ‘041W0KS’, ‘041W0ZP’,
# ‘041W0ZQ’, ‘041W0ZS’, ‘041W49P’, ‘041W49Q’, ‘041W49S’, ‘041W4AP’, ‘041W4AQ’,
# ‘041W4AS’, ‘041W4JP’, ‘041W4JQ’, ‘041W4JS’, ‘041W4KP’, ‘041W4KQ’, ‘041W4KS’,
# ‘041W4ZP’, ‘041W4ZQ’, ‘041W4ZS’, ‘045K0ZZ’, ‘045K3ZZ’, ‘045K4ZZ’, ‘045L0ZZ’,
# ‘045L3ZZ’, ‘045L4ZZ’, ‘045M0ZZ’, ‘045M3ZZ’, ‘045M4ZZ’, ‘045N0ZZ’, ‘045N3ZZ’,
# ‘045N4ZZ’, ‘045P0ZZ’, ‘045P3ZZ’, ‘045P4ZZ’, ‘045Q0ZZ’, ‘045Q3ZZ’, ‘045Q4ZZ’,
# ‘045R0ZZ’, ‘045R3ZZ’, ‘045R4ZZ’, ‘045S0ZZ’, ‘045S3ZZ’, ‘045S4ZZ’, ‘045T0ZZ’,
# ‘045T3ZZ’, ‘045T4ZZ’, ‘045U0ZZ’, ‘045U3ZZ’, ‘045U4ZZ’, ‘045V0ZZ’, ‘045V3ZZ’,
# ‘045V4ZZ’, ‘045W0ZZ’, ‘045W3ZZ’, ‘045W4ZZ’, ‘045Y0ZZ’, ‘045Y3ZZ’, ‘045Y4ZZ’,
# ‘04BK0ZZ’, ‘04BK3ZZ’, ‘04BK4ZZ’, ‘04BL0ZZ’, ‘04BL3ZZ’, ‘04BL4ZZ’, ‘04BM0ZZ’,
# ‘04BM3ZZ’, ‘04BM4ZZ’, ‘04BN0ZZ’, ‘04BN3ZZ’, ‘04BN4ZZ’, ‘04BP0ZZ’, ‘04BP3ZZ’,
# ‘04BP4ZZ’, ‘04BQ0ZZ’, ‘04BQ3ZZ’, ‘04BQ4ZZ’, ‘04BR0ZZ’, ‘04BR3ZZ’, ‘04BR4ZZ’,
# ‘04BS0ZZ’, ‘04BS3ZZ’, ‘04BS4ZZ’, ‘04BT0ZZ’, ‘04BT3ZZ’, ‘04BT4ZZ’, ‘04BU0ZZ’,
# ‘04BU3ZZ’, ‘04BU4ZZ’, ‘04BV0ZZ’, ‘04BV3ZZ’, ‘04BV4ZZ’, ‘04BW0ZZ’, ‘04BW3ZZ’,
# ‘04BW4ZZ’, ‘04BY0ZZ’, ‘04BY3ZZ’, ‘04BY4ZZ’, ‘04C10ZZ’, ‘04C13ZZ’, ‘04C14ZZ’,
# ‘04C20ZZ’, ‘04C23ZZ’, ‘04C24ZZ’, ‘04C30ZZ’, ‘04C33ZZ’, ‘04C34ZZ’, ‘04C40ZZ’,
# ‘04C43ZZ’, ‘04C44ZZ’, ‘04C50ZZ’, ‘04C53ZZ’, ‘04C54ZZ’, ‘04C60ZZ’, ‘04C63ZZ’,
# ‘04C64ZZ’, ‘04C70ZZ’, ‘04C73ZZ’, ‘04C74ZZ’, ‘04C80ZZ’, ‘04C83ZZ’, ‘04C84ZZ’,
# ‘04C90ZZ’, ‘04C93ZZ’, ‘04C94ZZ’, ‘04CA0ZZ’, ‘04CA3ZZ’, ‘04CA4ZZ’, ‘04CB0ZZ’,
# ‘04CB3ZZ’, ‘04CB4ZZ’, ‘04CC0ZZ’, ‘04CC3ZZ’, ‘04CC4ZZ’, ‘04CD0ZZ’, ‘04CD3ZZ’,
# ‘04CD4ZZ’, ‘04CE0ZZ’, ‘04CE3ZZ’, ‘04CE4ZZ’, ‘04CF0ZZ’, ‘04CF3ZZ’, ‘04CF4ZZ’,
# ‘04CH0ZZ’, ‘04CH3ZZ’, ‘04CH4ZZ’, ‘04CJ0ZZ’, ‘04CJ3ZZ’, ‘04CJ4ZZ’, ‘04CK0Z6’,
# ‘04CK0ZZ’, ‘04CK3ZZ’, ‘04CK4Z6’, ‘04CK4ZZ’, ‘04CL0Z6’, ‘04CL0ZZ’, ‘04CL3ZZ’,
# ‘04CL4Z6’, ‘04CL4ZZ’, ‘04CM0Z6’, ‘04CM0ZZ’, ‘04CM3ZZ’, ‘04CM4Z6’, ‘04CM4ZZ’,
# ‘04CN0Z6’, ‘04CN0ZZ’, ‘04CN3ZZ’, ‘04CN4Z6’, ‘04CN4ZZ’, ‘04CP0Z6’, ‘04CP0ZZ’,
# ‘04CP3ZZ’, ‘04CP4Z6’, ‘04CP4ZZ’, ‘04CQ0Z6’, ‘04CQ0ZZ’, ‘04CQ3ZZ’, ‘04CQ4Z6’,
# ‘04CQ4ZZ’, ‘04CR0Z6’, ‘04CR0ZZ’, ‘04CR3ZZ’, ‘04CR4Z6’, ‘04CR4ZZ’, ‘04CS0Z6’,
# ‘04CS0ZZ’, ‘04CS3ZZ’, ‘04CS4Z6’, ‘04CS4ZZ’, ‘04CT0Z6’, ‘04CT0ZZ’, ‘04CT3ZZ’,
# ‘04CT4Z6’, ‘04CT4ZZ’, ‘04CU0Z6’, ‘04CU0ZZ’, ‘04CU3ZZ’, ‘04CU4Z6’, ‘04CU4ZZ’,
# ‘04CV0Z6’, ‘04CV0ZZ’, ‘04CV3ZZ’, ‘04CV4Z6’, ‘04CV4ZZ’, ‘04CW0Z6’, ‘04CW0ZZ’,
# ‘04CW3ZZ’, ‘04CW4Z6’, ‘04CW4ZZ’, ‘04CY0Z6’, ‘04CY0ZZ’, ‘04CY3ZZ’, ‘04CY4Z6’,
# ‘04CY4ZZ’, ‘04HY02Z’, ‘04HY32Z’, ‘04HY42Z’, ‘04LK0CZ’, ‘04LK0DZ’, ‘04LK0ZZ’,
# ‘04LK3CZ’, ‘04LK3DZ’, ‘04LK3ZZ’, ‘04LK4CZ’, ‘04LK4DZ’, ‘04LK4ZZ’, ‘04LL0CZ’,
# ‘04LL0DZ’, ‘04LL0ZZ’, ‘04LL3CZ’, ‘04LL3DZ’, ‘04LL3ZZ’, ‘04LL4CZ’, ‘04LL4DZ’,
# ‘04LL4ZZ’, ‘04LM0CZ’, ‘04LM0DZ’, ‘04LM0ZZ’, ‘04LM3CZ’, ‘04LM3DZ’, ‘04LM3ZZ’,
# ‘04LM4CZ’, ‘04LM4DZ’, ‘04LM4ZZ’, ‘04LN0CZ’, ‘04LN0DZ’, ‘04LN0ZZ’, ‘04LN3CZ’,
# ‘04LN3DZ’, ‘04LN3ZZ’, ‘04LN4CZ’, ‘04LN4DZ’, ‘04LN4ZZ’, ‘04LP0CZ’, ‘04LP0DZ’,
# ‘04LP0ZZ’, ‘04LP3CZ’, ‘04LP3DZ’, ‘04LP3ZZ’, ‘04LP4CZ’, ‘04LP4DZ’, ‘04LP4ZZ’,
# ‘04LQ0CZ’, ‘04LQ0DZ’, ‘04LQ0ZZ’, ‘04LQ3CZ’, ‘04LQ3DZ’, ‘04LQ3ZZ’, ‘04LQ4CZ’,
# ‘04LQ4DZ’, ‘04LQ4ZZ’, ‘04LR0CZ’, ‘04LR0DZ’, ‘04LR0ZZ’, ‘04LR3CZ’, ‘04LR3DZ’,
# ‘04LR3ZZ’, ‘04LR4CZ’, ‘04LR4DZ’, ‘04LR4ZZ’, ‘04LS0CZ’, ‘04LS0DZ’, ‘04LS0ZZ’,
# ‘04LS3CZ’, ‘04LS3DZ’, ‘04LS3ZZ’, ‘04LS4CZ’, ‘04LS4DZ’, ‘04LS4ZZ’, ‘04LT0CZ’,
# ‘04LT0DZ’, ‘04LT0ZZ’, ‘04LT3CZ’, ‘04LT3DZ’, ‘04LT3ZZ’, ‘04LT4CZ’, ‘04LT4DZ’,
# ‘04LT4ZZ’, ‘04LU0CZ’, ‘04LU0DZ’, ‘04LU0ZZ’, ‘04LU3CZ’, ‘04LU3DZ’, ‘04LU3ZZ’,
# ‘04LU4CZ’, ‘04LU4DZ’, ‘04LU4ZZ’, ‘04LV0CZ’, ‘04LV0DZ’, ‘04LV0ZZ’, ‘04LV3CZ’,
# ‘04LV3DZ’, ‘04LV3ZZ’, ‘04LV4CZ’, ‘04LV4DZ’, ‘04LV4ZZ’, ‘04LW0CZ’, ‘04LW0DZ’,
# ‘04LW0ZZ’, ‘04LW3CZ’, ‘04LW3DZ’, ‘04LW3ZZ’, ‘04LW4CZ’, ‘04LW4DZ’, ‘04LW4ZZ’,
# ‘04PY0YZ’, ‘04PY3YZ’, ‘04PY4YZ’, ‘04RK07Z’, ‘04RK0JZ’, ‘04RK0KZ’, ‘04RK47Z’,
# ‘04RK4JZ’, ‘04RK4KZ’, ‘04RL07Z’, ‘04RL0JZ’, ‘04RL0KZ’, ‘04RL47Z’, ‘04RL4JZ’,
# ‘04RL4KZ’, ‘04RM07Z’, ‘04RM0JZ’, ‘04RM0KZ’, ‘04RM47Z’, ‘04RM4JZ’, ‘04RM4KZ’,
# ‘04RN07Z’, ‘04RN0JZ’, ‘04RN0KZ’, ‘04RN47Z’, ‘04RN4JZ’, ‘04RN4KZ’, ‘04RP07Z’,
# ‘04RP0JZ’, ‘04RP0KZ’, ‘04RP47Z’, ‘04RP4JZ’, ‘04RP4KZ’, ‘04RQ07Z’, ‘04RQ0JZ’,
# ‘04RQ0KZ’, ‘04RQ47Z’, ‘04RQ4JZ’, ‘04RQ4KZ’, ‘04RR07Z’, ‘04RR0JZ’, ‘04RR0KZ’,
# ‘04RR47Z’, ‘04RR4JZ’, ‘04RR4KZ’, ‘04RS07Z’, ‘04RS0JZ’, ‘04RS0KZ’, ‘04RS47Z’,
# ‘04RS4JZ’, ‘04RS4KZ’, ‘04RT07Z’, ‘04RT0JZ’, ‘04RT0KZ’, ‘04RT47Z’, ‘04RT4JZ’,
# ‘04RT4KZ’, ‘04RU07Z’, ‘04RU0JZ’, ‘04RU0KZ’, ‘04RU47Z’, ‘04RU4JZ’, ‘04RU4KZ’,
# ‘04RV07Z’, ‘04RV0JZ’, ‘04RV0KZ’, ‘04RV47Z’, ‘04RV4JZ’, ‘04RV4KZ’, ‘04RW07Z’,
# ‘04RW0JZ’, ‘04RW0KZ’, ‘04RW47Z’, ‘04RW4JZ’, ‘04RW4KZ’, ‘04RY07Z’, ‘04RY0JZ’,
# ‘04RY0KZ’, ‘04RY47Z’, ‘04RY4JZ’, ‘04RY4KZ’, ‘04WY0YZ’, ‘04WY3YZ’, ‘04WY4YZ’,
# ‘051707Y’, ‘051709Y’, ‘05170AY’, ‘05170JY’, ‘05170KY’, ‘05170ZY’, ‘051747Y’,
# ‘051749Y’, ‘05174AY’, ‘05174JY’, ‘05174KY’, ‘05174ZY’, ‘051807Y’, ‘051809Y’,
# ‘05180AY’, ‘05180JY’, ‘05180KY’, ‘05180ZY’, ‘051847Y’, ‘051849Y’, ‘05184AY’,
# ‘05184JY’, ‘05184KY’, ‘05184ZY’, ‘051907Y’, ‘051909Y’, ‘05190AY’, ‘05190JY’,
# ‘05190KY’, ‘05190ZY’, ‘051947Y’, ‘051949Y’, ‘05194AY’, ‘05194JY’, ‘05194KY’,
# ‘05194ZY’, ‘051A07Y’, ‘051A09Y’, ‘051A0AY’, ‘051A0JY’, ‘051A0KY’, ‘051A0ZY’,
# ‘051A47Y’, ‘051A49Y’, ‘051A4AY’, ‘051A4JY’, ‘051A4KY’, ‘051A4ZY’, ‘051B07Y’,
# ‘051B09Y’, ‘051B0AY’, ‘051B0JY’, ‘051B0KY’, ‘051B0ZY’, ‘051B47Y’, ‘051B49Y’,
# ‘051B4AY’, ‘051B4JY’, ‘051B4KY’, ‘051B4ZY’, ‘051C07Y’, ‘051C09Y’, ‘051C0AY’,
# ‘051C0JY’, ‘051C0KY’, ‘051C0ZY’, ‘051C47Y’, ‘051C49Y’, ‘051C4AY’, ‘051C4JY’,
# ‘051C4KY’, ‘051C4ZY’, ‘051D07Y’, ‘051D09Y’, ‘051D0AY’, ‘051D0JY’, ‘051D0KY’,
# ‘051D0ZY’, ‘051D47Y’, ‘051D49Y’, ‘051D4AY’, ‘051D4JY’, ‘051D4KY’, ‘051D4ZY’,
# ‘051F07Y’, ‘051F09Y’, ‘051F0AY’, ‘051F0JY’, ‘051F0KY’, ‘051F0ZY’, ‘051F47Y’,
# ‘051F49Y’, ‘051F4AY’, ‘051F4JY’, ‘051F4KY’, ‘051F4ZY’, ‘051G07Y’, ‘051G09Y’,
# ‘051G0AY’, ‘051G0JY’, ‘051G0KY’, ‘051G0ZY’, ‘051G47Y’, ‘051G49Y’, ‘051G4AY’,
# ‘051G4JY’, ‘051G4KY’, ‘051G4ZY’, ‘051H07Y’, ‘051H09Y’, ‘051H0AY’, ‘051H0JY’,
# ‘051H0KY’, ‘051H0ZY’, ‘051H47Y’, ‘051H49Y’, ‘051H4AY’, ‘051H4JY’, ‘051H4KY’,
# ‘051H4ZY’, ‘051L07Y’, ‘051L09Y’, ‘051L0AY’, ‘051L0JY’, ‘051L0KY’, ‘051L0ZY’,
# ‘051L47Y’, ‘051L49Y’, ‘051L4AY’, ‘051L4JY’, ‘051L4KY’, ‘051L4ZY’, ‘051M07Y’,
# ‘051M09Y’, ‘051M0AY’, ‘051M0JY’, ‘051M0KY’, ‘051M0ZY’, ‘051M47Y’, ‘051M49Y’,
# ‘051M4AY’, ‘051M4JY’, ‘051M4KY’, ‘051M4ZY’, ‘051N07Y’, ‘051N09Y’, ‘051N0AY’,
# ‘051N0JY’, ‘051N0KY’, ‘051N0ZY’, ‘051N47Y’, ‘051N49Y’, ‘051N4AY’, ‘051N4JY’,
# ‘051N4KY’, ‘051N4ZY’, ‘051P07Y’, ‘051P09Y’, ‘051P0AY’, ‘051P0JY’, ‘051P0KY’,
# ‘051P0ZY’, ‘051P47Y’, ‘051P49Y’, ‘051P4AY’, ‘051P4JY’, ‘051P4KY’, ‘051P4ZY’,
# ‘051Q07Y’, ‘051Q09Y’, ‘051Q0AY’, ‘051Q0JY’, ‘051Q0KY’, ‘051Q0ZY’, ‘051Q47Y’,
# ‘051Q49Y’, ‘051Q4AY’, ‘051Q4JY’, ‘051Q4KY’, ‘051Q4ZY’, ‘051R07Y’, ‘051R09Y’,
# ‘051R0AY’, ‘051R0JY’, ‘051R0KY’, ‘051R0ZY’, ‘051R47Y’, ‘051R49Y’, ‘051R4AY’,
# ‘051R4JY’, ‘051R4KY’, ‘051R4ZY’, ‘051S07Y’, ‘051S09Y’, ‘051S0AY’, ‘051S0JY’,
# ‘051S0KY’, ‘051S0ZY’, ‘051S47Y’, ‘051S49Y’, ‘051S4AY’, ‘051S4JY’, ‘051S4KY’,
# ‘051S4ZY’, ‘051T07Y’, ‘051T09Y’, ‘051T0AY’, ‘051T0JY’, ‘051T0KY’, ‘051T0ZY’,
# ‘051T47Y’, ‘051T49Y’, ‘051T4AY’, ‘051T4JY’, ‘051T4KY’, ‘051T4ZY’, ‘051V07Y’,
# ‘051V09Y’, ‘051V0AY’, ‘051V0JY’, ‘051V0KY’, ‘051V0ZY’, ‘051V47Y’, ‘051V49Y’,
# ‘051V4AY’, ‘051V4JY’, ‘051V4KY’, ‘051V4ZY’, ‘061307Y’, ‘061309Y’, ‘06130AY’,
# ‘06130JY’, ‘06130KY’, ‘06130ZY’, ‘061347Y’, ‘061349Y’, ‘06134AY’, ‘06134JY’,
# ‘06134KY’, ‘06134ZY’, ‘061C07Y’, ‘061C09Y’, ‘061C0AY’, ‘061C0JY’, ‘061C0KY’,
# ‘061C0ZY’, ‘061C47Y’, ‘061C49Y’, ‘061C4AY’, ‘061C4JY’, ‘061C4KY’, ‘061C4ZY’,
# ‘061D07Y’, ‘061D09Y’, ‘061D0AY’, ‘061D0JY’, ‘061D0KY’, ‘061D0ZY’, ‘061D47Y’,
# ‘061D49Y’, ‘061D4AY’, ‘061D4JY’, ‘061D4KY’, ‘061D4ZY’, ‘061F07Y’, ‘061F09Y’,
# ‘061F0AY’, ‘061F0JY’, ‘061F0KY’, ‘061F0ZY’, ‘061F47Y’, ‘061F49Y’, ‘061F4AY’,
# ‘061F4JY’, ‘061F4KY’, ‘061F4ZY’, ‘061G07Y’, ‘061G09Y’, ‘061G0AY’, ‘061G0JY’,
# ‘061G0KY’, ‘061G0ZY’, ‘061G47Y’, ‘061G49Y’, ‘061G4AY’, ‘061G4JY’, ‘061G4KY’,
# ‘061G4ZY’, ‘061H07Y’, ‘061H09Y’, ‘061H0AY’, ‘061H0JY’, ‘061H0KY’, ‘061H0ZY’,
# ‘061H47Y’, ‘061H49Y’, ‘061H4AY’, ‘061H4JY’, ‘061H4KY’, ‘061H4ZY’, ‘061M07Y’,
# ‘061M09Y’, ‘061M0AY’, ‘061M0JY’, ‘061M0KY’, ‘061M0ZY’, ‘061M47Y’, ‘061M49Y’,
# ‘061M4AY’, ‘061M4JY’, ‘061M4KY’, ‘061M4ZY’, ‘061N07Y’, ‘061N09Y’, ‘061N0AY’,
# ‘061N0JY’, ‘061N0KY’, ‘061N0ZY’, ‘061N47Y’, ‘061N49Y’, ‘061N4AY’, ‘061N4JY’,
# ‘061N4KY’, ‘061N4ZY’, ‘061P07Y’, ‘061P09Y’, ‘061P0AY’, ‘061P0JY’, ‘061P0KY’,
# ‘061P0ZY’, ‘061P47Y’, ‘061P49Y’, ‘061P4AY’, ‘061P4JY’, ‘061P4KY’, ‘061P4ZY’,
# ‘061Q07Y’, ‘061Q09Y’, ‘061Q0AY’, ‘061Q0JY’, ‘061Q0KY’, ‘061Q0ZY’, ‘061Q47Y’,
# ‘061Q49Y’, ‘061Q4AY’, ‘061Q4JY’, ‘061Q4KY’, ‘061Q4ZY’, ‘061R07Y’, ‘061R09Y’,
# ‘061R0AY’, ‘061R0JY’, ‘061R0KY’, ‘061R0ZY’, ‘061R47Y’, ‘061R49Y’, ‘061R4AY’,
# ‘061R4JY’, ‘061R4KY’, ‘061R4ZY’, ‘061S07Y’, ‘061S09Y’, ‘061S0AY’, ‘061S0JY’,
# ‘061S0KY’, ‘061S0ZY’, ‘061S47Y’, ‘061S49Y’, ‘061S4AY’, ‘061S4JY’, ‘061S4KY’,
# ‘061S4ZY’, ‘061T07Y’, ‘061T09Y’, ‘061T0AY’, ‘061T0JY’, ‘061T0KY’, ‘061T0ZY’,
# ‘061T47Y’, ‘061T49Y’, ‘061T4AY’, ‘061T4JY’, ‘061T4KY’, ‘061T4ZY’, ‘061V07Y’,
# ‘061V09Y’, ‘061V0AY’, ‘061V0JY’, ‘061V0KY’, ‘061V0ZY’, ‘061V47Y’, ‘061V49Y’,
# ‘061V4AY’, ‘061V4JY’, ‘061V4KY’, ‘061V4ZY’, ‘031509V’, ‘03150AV’, ‘03150JV’,
# ‘03150KV’, ‘03150ZV’, ‘031609V’, ‘03160AV’, ‘03160JV’, ‘03160KV’, ‘03160ZV’,
# ‘031709V’, ‘03170AV’, ‘03170JV’, ‘03170KV’, ‘03170ZV’, ‘031809V’, ‘03180AV’,
# ‘03180JV’, ‘03180KV’, ‘03180ZV’, ‘03193ZF’, ‘031A3ZF’, ‘031B3ZF’, ‘031C3ZF’,
# ‘031H09Y’, ‘031H0AY’, ‘031H0JY’, ‘031H0KY’, ‘031H0ZY’, ‘031J09Y’, ‘031J0AY’,
# ‘031J0JY’, ‘031J0KY’, ‘031J0ZY’, ‘041K3JQ’, ‘041K3JS’, ‘041L3JQ’, ‘041L3JS’,
# ‘041T09P’, ‘041T09Q’, ‘041T09S’, ‘041T0AP’, ‘041T0AQ’, ‘041T0AS’, ‘041T0JP’,
# ‘041P0JQ’, ‘041P0JS’, ‘041T0KP’, ‘041T0KQ’, ‘041T0KS’, ‘041T0ZP’, ‘041T0ZQ’,
# ‘041T0ZS’, ‘041T49P’, ‘041T49Q’, ‘041T49S’, ‘041T4AP’, ‘041T4AQ’, ‘041T4AS’,
# ‘041T4JP’, ‘041M3JQ’, ‘041M3JS’, ‘041T4KP’, ‘041T4KQ’, ‘041T4KS’, ‘041T4ZP’,
# ‘041T4ZQ’, ‘041T4ZS’, ‘041U09P’, ‘041U09Q’, ‘041U09S’, ‘041U0AP’, ‘041U0AQ’,
# ‘041U0AS’, ‘041U0JP’, ‘041Q0JQ’, ‘041Q0JS’, ‘041U0KP’, ‘041U0KQ’, ‘041U0KS’,
# ‘041U0ZP’, ‘041U0ZQ’, ‘041U0ZS’, ‘041U49P’, ‘041U49Q’, ‘041U49S’, ‘041U4AP’,
# ‘041U4AQ’, ‘041U4AS’, ‘041U4JP’, ‘041N3JQ’, ‘041N3JS’, ‘041U4KP’, ‘041U4KQ’,
# ‘041U4KS’, ‘041U4ZP’, ‘041U4ZQ’, ‘041U4ZS’, ‘041T3JQ’, ‘041T3JS’, ‘041U3JQ’,
# ‘041U3JS’, ‘041V3JQ’, ‘041V3JS’, ‘041W3JQ’, ‘041W3JS’, ‘04C10Z6’, ‘04C13Z6’,
# ‘04C14Z6’, ‘04C20Z6’, ‘04C23Z6’, ‘04C24Z6’, ‘04C30Z6’, ‘04C33Z6’, ‘04C34Z6’,
# ‘04C40Z6’, ‘04C43Z6’, ‘04C44Z6’, ‘04C50Z6’, ‘04C53Z6’, ‘04C54Z6’, ‘04C60Z6’,
# ‘04C63Z6’, ‘04C64Z6’, ‘04C70Z6’, ‘04C73Z6’, ‘04C74Z6’, ‘04C80Z6’, ‘04C83Z6’,
# ‘04C84Z6’, ‘04C90Z6’, ‘04C93Z6’, ‘04C94Z6’, ‘04CA0Z6’, ‘04CA3Z6’, ‘04CA4Z6’,
# ‘04CB0Z6’, ‘04CB3Z6’, ‘04CB4Z6’, ‘04CC0Z6’, ‘04CC3Z6’, ‘04CC4Z6’, ‘04CD0Z6’,
# ‘04CD3Z6’, ‘04CD4Z6’, ‘04CE0Z6’, ‘04CE3Z6’, ‘04CE4Z6’, ‘04CF0Z6’, ‘04CF3Z6’,
# ‘04CF4Z6’, ‘04CH0Z6’, ‘04CH3Z6’, ‘04CH4Z6’, ‘04CJ0Z6’, ‘04CJ3Z6’, ‘04CJ4Z6’,
# ‘04CK0ZZ’, ‘04CK0Z6’, ‘04CK3Z6’, ‘04CK4ZZ’, ‘04CK4Z6’, ‘04CL0ZZ’, ‘04CL0Z6’,
# ‘04CL3Z6’, ‘04CL4ZZ’, ‘04CL4Z6’, ‘04CM0ZZ’, ‘04CM0Z6’, ‘04CM3Z6’, ‘04CM4ZZ’,
# ‘04CM4Z6’, ‘04CN0ZZ’, ‘04CN0Z6’, ‘04CN3Z6’, ‘04CN4ZZ’, ‘04CN4Z6’, ‘04CP0ZZ’,
# ‘04CP0Z6’, ‘04CP3Z6’, ‘04CP4ZZ’, ‘04CP4Z6’, ‘04CQ0ZZ’, ‘04CQ0Z6’, ‘04CQ3Z6’,
# ‘04CQ4ZZ’, ‘04CQ4Z6’, ‘04CR0ZZ’, ‘04CR0Z6’, ‘04CR3Z6’, ‘04CR4ZZ’, ‘04CR4Z6’,
# ‘04CS0ZZ’, ‘04CS0Z6’, ‘04CS3Z6’, ‘04CS4ZZ’, ‘04CS4Z6’, ‘04CT0ZZ’, ‘04CT0Z6’,
# ‘04CT3Z6’, ‘04CT4ZZ’, ‘04CT4Z6’, ‘04CU0ZZ’, ‘04CU0Z6’, ‘04CU3Z6’, ‘04CU4ZZ’,
# ‘04CU4Z6’, ‘04CV0ZZ’, ‘04CV0Z6’, ‘04CV3Z6’, ‘04CV4ZZ’, ‘04CV4Z6’, ‘04CW0ZZ’,
# ‘04CW0Z6’, ‘04CW3Z6’, ‘04CW4ZZ’, ‘04CW4Z6’, ‘04CY0ZZ’, ‘04CY0Z6’, ‘04CY3Z6’,
# ‘04CY4ZZ’, ‘04CY4Z6’, ‘061P07Y’, ‘061P09Y’, ‘061P0AY’, ‘061P0JY’, ‘061P0KY’,
# ‘061P0ZY’, ‘061P47Y’, ‘061P49Y’, ‘061P4AY’, ‘061P4JY’, ‘061P4KY’, ‘061P4ZY’,
# ‘061Q07Y’, ‘061Q09Y’, ‘061Q0AY’, ‘061Q0JY’, ‘061Q0KY’, ‘061Q0ZY’, ‘061Q47Y’,
# ‘061Q49Y’, ‘061Q4AY’, ‘061Q4JY’, ‘061Q4KY’, ‘061Q4ZY’, ‘061P07Y’, ‘061P09Y’,
# ‘061P0AY’, ‘061P0JY’, ‘061P0KY’, ‘061P0ZY’, ‘061P47Y’, ‘061P49Y’, ‘061P4AY’,
# ‘061P4JY’, ‘061P4KY’, ‘061P4ZY’, ‘061Q07Y’, ‘061Q09Y’, ‘061Q0AY’, ‘061Q0JY’,
# ‘061Q0KY’, ‘061Q0ZY’, ‘061Q47Y’, ‘061Q49Y’, ‘061Q4AY’, ‘061Q4JY’, ‘061Q4KY’,
# ‘061Q4ZY'.
#
# CPT procedure codes for peripheral surgical revascularization: 35302, 35303,
# 35304, 35305, 35351, 35355, 35361, 35363, 35371, 35372, 35381, 35480, 35481,
# 35482, 35483, 35485, 35521, 35537, 35538, 35539, 35540, 35541, 35546, 35548,
# 35549, 35551, 35556, 35558, 35563, 35565, 35566, 35570, 35571, 35583, 35585,
# 35587, 35621, 35623, 35641, 35646, 35647, 35651, 35654, 35656, 35661, 35663,
# 35665, 35666, 35671, 35875, 35876.
#
# ICD9 procedure codes for thrombolysis: 99.10.
#
# ICD10 procedure codes for thrombolysis: 3E03317, 3E04317, 3E05317, 3E06317,
# 3E08317.
#
# CPT procedure codes for thrombolysis: 37184, 37211, 37213.
#
# ICD9 diagnosis codes for acute myocardial infarction: 410.x0, 410.x1.
#
# ICD10 diagnosis codes for acute myocardial infarction: I21.x, I21.xx.
#
# ICD9 diagnosis codes for ischemic stroke: 433.x1, 434.x1.
#
# ICD10 diagnosis codes for ischemic stroke: I63, I63.x, I63.xx, I63.xxx.
#
# ICD9 diagnosis code for pulmonary embolism: 415.1x.
#
# ICD10 diagnosis codes for pulmonary embolism: T80.0XXA, T81.718A, T81.72XA,
# T82.817A, T82.818A, I26.90, I26.99.
#
# ICD9 procedure codes for lower extremity amputation above the ankle: 84.13,
# 84.14, 84.15, 84.16, 84.17.
#
# ICD10 procedure codes for lower extremity amputation above the ankle: 0Y6M0Z0,
# 0Y6N0Z0, 0Y6H0Z3, 0Y6J0Z3, 0Y670ZZ, 0Y680ZZ, 0Y6C0Z1, '0Y6C0Z2',   0Y6C0Z3,
# 0Y6D0Z1, 0Y6D0Z2, 0Y6D0Z3, 0Y6F0ZZ, 0Y6G0ZZ, 0Y6H0Z1, 0Y6H0Z2, 0Y6J0Z1,
# 0Y6J0Z2, 0Y620ZZ, 0Y630ZZ, 0Y640ZZ.
#
# CPT procedure codes for lower extremity amputation above the ankle: 27590,
# 27591, 27592, 27598, 27880, 27881, 27882, 27888.
#
# ICD9 diagnosis code for traumatic amputation of a leg: 897.x.
#
# ICD10 diagnosis codes for traumatic amputation of a leg: "S78011A", "S78012A",
# "S78019A", "S78111A", "S78112A", "S78119A", "S78121A", "S78122A", "S78129A",
# "S78911A", "S78912A", "S78919A", "S78921A", "S78922A", "S78929A", "S88011A",
# "S88012A", "S88019A", "S88111A", "S88112A", "S88119A", "S88121A", "S88122A",
# "S88129A", "S88911A", "S88912A", "S88919A", "S88921A", "S88922A", "S88929A".
#
# ICD9 diagnosis codes for peripheral artery disease: 440.2, 440.20, 440.21,
# 440.22, 440.23, 440.24, 440.29, 440.3, 440.30, 440.31, 440.32, 440.4, 443.9.
#
# ICD10 diagnosis codes for peripheral artery disease: I70.2, I70.20, I70.201,
# I70.202, I70.203, I70.208, I70.209, I70.21, I70.211, I70.212, I70.213,
# I70.218, I70.219, I70.22, I70.221, I70.222, I70.223, I70.228, I70.229, I70.23,
# I70.231, I70.232, I70.233, I70.234, I70.235, I70.238, I70.239, I70.24,
# I70.241, I70.242, I70.243, I70.244, I70.245, I70.248, I70.249, I70.25, I70.26,
# I70.261, I70.262, I70.263, I70.268, I70.269, I70.29, I70.291, I70.292,
# I70.293, I70.298, I70.299, I70.3, I70.30, I70.301, I70.302, I70.303, I70.308,
# I70.309, I70.31, I70.311, I70.312, I70.313, I70.318, I70.319, I70.32, I70.321,
# I70.322, I70.323, I70.328, I70.329, I70.33, I70.331, I70.332, I70.333,
# I70.334, I70.335, I70.338, I70.339, I70.34, I70.341, I70.342, I70.343,
# I70.344, I70.345, I70.348, I70.349, I70.35, I70.36, I70.361, I70.362, I70.363,
# I70.368, I70.369, I70.39, I70.391, I70.392, I70.393, I70.398, I70.399, I70.4,
# I70.40, I70.401, I70.402, I70.403, I70.408, I70.409, I70.41, I70.411, I70.412,
# I70.413, I70.418, I70.419, I70.42, I70.421, I70.422, I70.423, I70.428,
# I70.429, I70.43, I70.431, I70.432, I70.433, I70.434, I70.435, I70.438,
# I70.439, I70.44, I70.441, I70.442, I70.443, I70.444, I70.445, I70.448,
# I70.449, I70.45, I70.46, I70.461, I70.462, I70.463, I70.468, I70.469, I70.49,
# I70.491, I70.492, I70.493, I70.498, I70.499, I70.5, I70.50, I70.501, I70.502,
# I70.503, I70.508, I70.509, I70.51, I70.511, I70.512, I70.513, I70.518,
# I70.519, I70.52, I70.521, I70.522, I70.523, I70.528, I70.529, I70.53, I70.531,
# I70.532, I70.533, I70.534, I70.535, I70.538, I70.539, I70.54, I70.541,
# I70.542, I70.543, I70.544, I70.545, I70.548, I70.549, I70.55, I70.56, I70.561,
# I70.56, I70.562, I70.563, I70.568, I70.569, I70.59, I70.591, I70.592, I70.593,
# I70.598, I70.599, I70.6, I70.60, I70.601, I70.602, I70.603, I70.608, I70.609,
# I70.61, I70.611, I70.612, I70.613, I70.618, I70.619, I70.62, I70.621, I70.622,
# I70.623, I70.628, I70.629, I70.63, I70.631, I70.632, I70.633, I70.634,
# I70.635, I70.638, I70.639, I70.64, I70.641, I70.642, I70.643, I70.644,
# I70.645, I70.648, I70.649, I70.65, I70.66, I70.661, I70.662, I70.663, I70.668,
# I70.669, I70.69, I70.691, I70.692, I70.693, I70.698, I70.699, I70.7, I70.70,
# I70.701, I70.702, I70.703, I70.708, I70.709, I70.71, I70.711, I70.712,
# I70.713, I70.718, I70.719, I70.72, I70.721, I70.722, I70.723, I70.728,
# I70.729, I70.73, I70.731, I70.732, I70.733, I70.734, I70.735, I70.738,
# I70.739, I70.74, I70.741, I70.742, I70.743, I70.744, I70.745, I70.748,
# I70.749, I70.75, I70.76, I70.761, I70.762, I70.763, I70.768, I70.769, I70.79,
# I70.791, I70.792, I70.793, I70.798, I70.799, I70.92, I73.9.

lead_icd9 <- c("4402",
               "44020",
               "44021",
               "44022",
               "44023",
               "44024",
               "44029",
               "4403",
               "44030",
               "44031",
               "44032",
               "4404",
               "4439")

# ICD-10 codes for LEAD/PAD history (v1): I70.2xx–I70.7xx, I70.9x, I73.9
lead_icd10 <- c(
  expand10("I702"),   # I70.2x atherosclerosis of native arteries of extremities
  expand10("I703"),   # I70.3x atherosclerosis of unspecified type bypass graft
  expand10("I704"),   # I70.4x atherosclerosis of autologous vein bypass graft
  expand10("I705"),   # I70.5x atherosclerosis of nonautologous biological bypass graft
  expand10("I706"),   # I70.6x atherosclerosis of nonbiological bypass graft
  expand10("I707"),   # I70.7x atherosclerosis of other type bypass graft
  expand10("I709"),   # I70.9x other and unspecified atherosclerosis (incl. I70.92)
  "I739"              # I73.9 peripheral vascular disease, unspecified
)

lead_cpt <- c("37205", "75962", "36902", "36905", "37246", "37247")

# LEAD/PAD outcome-specific codes (NOT IMPLEMENTED YET)
lead_out_icd9_isch  <- c("4440", "44401", "44409", "44422", "44481")

lead_out_icd10_isch <- c("I7401", "I7409", "I743", "I745")

lead_out_cpt_emb    <- c("34201", "34203")

lead_out_icd9_amp   <- c("8413", "8414", "8415", "8416", "8417")

lead_out_cpt_amp    <- c("27590", "27591", "27592", "27598", "27880", "27881",
                         "27882", "27888")

lead_out_icd9_rev   <- c("3808", "3816", "3818", "3838", "3848", "3868",
                         "3888", "3925", "3929")

lead_out_icd10_rev  <- c("0312096", "0312097", "0312098", "0312099", "031209B",
                         "031209C", "03120A6", "03120A7", "03120A8", "03120A9",
                         "03120AB", "03120AC", "03120J6", "03120J7", "03120J8",
                         "03120J9", "03120JB", "03120JC")

lead_out_icd9_throm <- "9910"

lead_out_icd10_throm <- c("3E03317", "3E04317", "3E05317", "3E06317", "3E08317")

lead_out_cpt_throm  <- c("37184", "37211", "37213")

spec_lead_pad_v1 <- CodeSpec$new(
  condition = "lead_pad",
  version = "v1",
  label = "lower extremity artery disease (LEAD) / peripheral artery disease (PAD)",
  defs = list(
    condition = c(
      "i" = "Any of the following:",
      "*" = paste0("\u22651 hospitalization with a discharge diagnosis code ",
                   "of atherosclerosis or thrombosis of arteries of the ",
                   "extremities in any discharge diagnosis position."),
      "*" = paste0("\u22652 physician E&M visits with a diagnosis code of ",
                   "atherosclerosis or thrombosis of arteries of the ",
                   " extremities in any discharge position on separate days."),
      "*" = paste0("\u22651 CPT code of {.strong 37205}, {.strong 75962}, ",
                   "{.strong 36902}, {.strong 36905}, {.strong 37246}, ",
                   "or {.strong 37247.}")
    )
  ),
  codes = list(
    dx_icd9  = make_key_condition_only(lead_icd9),
    dx_icd10 = make_key_condition_only(lead_icd10),
    cpt = make_key_condition_only(lead_cpt)
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
# 0005T, 0075T, or 0076.

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

cerebrovasc_cpt <- c("35301", "35390", "37215", "37216", "0005T", "0075T", "0076")

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
      "*" = "\u22651 outpatient or carrier claim with the same codes linked to an E&M claim.",
      "*" = "\u22651 claim with the same codes in HHA, DME, Hospice, or SNF files.",
      "*" = paste0(
        "\u22651 inpatient/outpatient claim with an ICD-9 procedure code for carotid ",
        "endarterectomy or revascularization ({.strong 38.42}, {.strong 38.12}, ",
        "{.strong 39.90}, {.strong 00.63}), an ICD-10-PCS code for carotid stenting, ",
        "or a CPT code for carotid revascularization ({.strong 35301}, {.strong 35390}, ",
        "{.strong 37215}, {.strong 37216}, {.strong 0005T}, {.strong 0075T}, {.strong 0076})."
      )
    ),
    outcome = NULL
  ),
  codes = list(
    dx_icd9    = make_key_condition_only(isch_stroke_icd9),
    dx_icd10   = make_key_condition_only(isch_stroke_icd10),
    proc_icd9  = make_key_condition_only(cerebrovasc_proc_icd9),
    proc_icd10 = make_key_condition_only(cerebrovasc_proc_icd10),
    cpt        = make_key_condition_only(cerebrovasc_cpt)
  )
)


## ASCVD composite ----
#
# ASCVD, history, version 1: Defined by a history of CHD, (ischemic or any)
# stroke.
#
# ASCVD, history, version 2: Defined by a history of CHD, cerebrovascular
# disease, or LEAD/PAD.
#
# ASCVD, outcome, version 1: Defined by an event of CHD, stroke.
#
# ASCVD, outcome, version 2: Defined by an event of CHD, stroke, or LEAD/PAD.
#

spec_ascvd <- CompositeCodeSpec$new(
  condition = "ascvd",
  label = "Atherosclerotic Cardiovascular Disease (ASCVD)",
  defs = paste0(
    "Composition of all ASCVD component specs: coronary heart disease (CHD), ",
    "stroke, lower extremity artery disease (LEAD) / peripheral arterial ",
    "disease (PAD), and cerebrovascular disease"
  ),
  components = list(
    chd_v1                 = spec_chd_v1,
    chd_v2                 = spec_chd_v2,
    stroke_v1              = spec_stroke_v1,
    lead_pad_v1            = spec_lead_pad_v1,
    cerebrovasc_disease_v1 = spec_cerebrovasc_disease_v1
  )
)

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
      "*" = "\u22652 E&M-linked outpatient claims at least 30 days apart with the same codes."
    ),
    outcome = c(
      "*" = paste0(
        "Overnight hospitalization with a {.emph primary} discharge diagnosis for heart ",
        "failure (same ICD codes as condition definition)."
      )
    )
  ),
  codes = list(
    dx_icd9  = make_key(hf_icd9),
    dx_icd10 = make_key(hf_icd10)
  )
)

## Obesity ----

### history, version 1 ----
#
# ICD-10-CM diagnosis codes (any position), inpatient or outpatient:
#
# E66.01, E66.3, E66.9, R93.9,
# Z68.25–Z68.29, Z68.30–Z68.39, Z68.41–Z68.45

obesity_icd10 <- c(
  "E6601",
  "E663",
  "E669",
  "R939",
  "Z6825", "Z6826", "Z6827", "Z6828", "Z6829",
  "Z6830", "Z6831", "Z6832", "Z6833", "Z6834",
  "Z6835", "Z6836", "Z6837", "Z6838", "Z6839",
  "Z6841", "Z6842", "Z6843", "Z6844", "Z6845"
)

obesity_defs_condition <- c(
  "*" = paste0(
    "\u22651 inpatient or outpatient claim with an ICD-10 diagnosis of ",
    "{.strong E66.01}, {.strong E66.3}, {.strong E66.9}, {.strong R93.9}, ",
    "{.strong Z68.25}\u2013{.strong Z68.29}, {.strong Z68.30}\u2013{.strong Z68.39}, ",
    "or {.strong Z68.41}\u2013{.strong Z68.45} in any diagnosis position."
  )
)

spec_obesity_v1 <- CodeSpec$new(
  condition = "obesity", version = "v1", label = "Obesity",
  defs  = list(condition = obesity_defs_condition, outcome = NULL),
  codes = list(dx_icd10 = make_key_condition_only(obesity_icd10))
)


## Depression ----

# Depression, history, version 1 (without medication): Any of the following:
#
# (a) At least 1 inpatient claim with ICD-9 diagnosis code of 296.20-296.26,
# 296.30-296.36, 296.51-296.56, 296.60-296.66, 296.89, 298.0, 300.4, 309.1 or
# 311, or an ICD-10 diagnosis code of F32.9, F32.0-F32.5, F33.9, F33.0-F33.3,
# F33.41, F33.42, F33.31, F31.32, F31.4, F31.5, F31.75, F31.76, F31.60-F31.64,
# F31.77, F31.78, F31.81, F32.3 or F33.3, F34.1, F43.21 or F32.9 in any
# position.
#
# (b) At least 1 outpatient physician evaluation and management claim (page 7)
# with ICD-9 diagnosis code of 296.20-296.26, 296.30-296.36, 296.51-296.56,
# 296.60-296.66, 296.89, 298.0, 300.4, 309.1 or 311, or an ICD-10 diagnosis code
# of F32.9, F32.0-F32.5, F33.9, F33.0-F33.3, F33.41, F33.42, F33.31, F31.32,
# F31.4, F31.5, F31.75, F31.76, F31.60-F31.64, F31.77, F31.78, F31.81, F32.3 or
# F33.3, F34.1, F43.21 or F32.9 in any position.
#
# Depression, history, version 2 (with medication): Any of the following: (a) At
# least 1 inpatient claim with ICD-9 diagnosis code of 296.20-296.26,
# 296.30-296.36, 296.51-296.56, 296.60-296.66, 296.89, 298.0, 300.4, 309.1 or
# 311, or an ICD-10 diagnosis code of F32.9, F32.0-F32.5, F33.9, F33.0-F33.3,
# F33.41, F33.42, F33.31, F31.32, F31.4, F31.5, F31.75, F31.76, F31.60-F31.64,
# F31.77, F31.78, F31.81, F32.3 or F33.3, F34.1, F43.21 in any position.
#
# (b) At least 1 outpatient physician evaluation and management claim (page 7)
# with ICD-9 diagnosis code of 296.20-296.26, 296.30-296.36, 296.51-296.56,
# 296.60-296.66, 296.89, 298.0, 300.4, 309.1 or 311, or an ICD-10 diagnosis code
# of F32.9, F32.0-F32.5, F33.9, F33.0-F33.3, F33.41, F33.42, F33.31, F31.32,
# F31.4, F31.5, F31.75, F31.76, F31.60-F31.64, F31.77, F31.78, F31.81, F32.3 or
# F33.3, F34.1, F43.21 in any position.
#
# (c) At least 2 pharmacy claims of depression medications (can be 2 different
# GNNs on the same day)

# ICD-9 codes (short format, no periods)
depress_icd9 <- unique(c(
  paste(29620:29626),   # 296.20–296.26
  paste(29630:29636),   # 296.30–296.36
  paste(29651:29656),   # 296.51–296.56
  paste(29660:29666),   # 296.60–296.66
  "29689",              # 296.89
  "2980",               # 298.0
  "3004",               # 300.4
  "3091",               # 309.1
  "311"                 # 311
))

# ICD-10 codes (short format, no periods)
depress_icd10 <- unique(c(
  "F329",                                           # F32.9
  "F320", "F321", "F322", "F323", "F324", "F325",  # F32.0–F32.5
  "F339",                                           # F33.9
  "F330", "F331", "F332", "F333",                  # F33.0–F33.3
  "F3341",                                          # F33.41
  "F3342",                                          # F33.42
  "F3331",                                          # F33.31
  "F3132",                                          # F31.32
  "F314",                                           # F31.4
  "F315",                                           # F31.5
  "F3175",                                          # F31.75
  "F3176",                                          # F31.76
  "F3160", "F3161", "F3162", "F3163", "F3164",     # F31.60–F31.64
  "F3177",                                          # F31.77
  "F3178",                                          # F31.78
  "F3181",                                          # F31.81
  "F341",                                           # F34.1
  "F4321"                                           # F43.21
))

depress_codes <- list(
  dx_icd9  = make_key_condition_only(depress_icd9),
  dx_icd10 = make_key_condition_only(depress_icd10)
)

depress_defs_base <- c(
  "i" = "Any of the following:",
  "*" = paste0(
    "\u22651 inpatient claim with an ICD-9 diagnosis of {.strong 296.20\u2013296.26}, ",
    "{.strong 296.30\u2013296.36}, {.strong 296.51\u2013296.56}, ",
    "{.strong 296.60\u2013296.66}, {.strong 296.89}, {.strong 298.0}, ",
    "{.strong 300.4}, {.strong 309.1}, or {.strong 311}, or an ICD-10 diagnosis ",
    "from the depression code set, in any diagnosis position."
  ),
  "*" = paste0(
    "\u22651 outpatient physician evaluation and management (E&M) claim with ",
    "the same ICD codes in any diagnosis position."
  )
)

spec_depression_v1 <- CodeSpec$new(
  condition = "depression",
  version   = "v1",
  label     = "Depression",
  defs = list(
    condition = c(
      depress_defs_base,
      "i" = "Medication use is not required (diagnosis-based only)."
    ),
    outcome = NULL
  ),
  codes = depress_codes
)

spec_depression_v2 <- CodeSpec$new(
  condition = "depression",
  version   = "v2",
  label     = "Depression",
  defs = list(
    condition = c(
      depress_defs_base,
      "*" = paste0(
        "\u22652 pharmacy claims for a depression medication ",
        "(see {.strong spec_antidepressive}); 2 different GNNs on the same day are permitted."
      )
    ),
    outcome = NULL
  ),
  codes = depress_codes
)


## Diabetes ----

# Source: "Definition of conditions and medications_11262025.docx"
# Section: Diabetes, history, versions 1-3
#
# Versions differ by required evidence, not by ICD code set:
#   v1: ICD codes only (diagnosis-based)
#   v2: ICD codes OR antidiabetic medication (diagnosis + medication)
#   v3: same evidence as v2, but sub-classified into four mutually exclusive
#       categories (no medication / oral antidiabetic / insulin / no diabetes)
#
# version 3 is omitted b/c it is based on post-processing version 2, which
# can only realistically be done in applied settings and would be tricky
# to implement in a specification.
#
# All three versions share the same ICD-9 and ICD-10 code sets.
# Diabetes is a condition-only definition (outcome = FALSE for all codes).

### history, version 1 ----

# Any of the following:
#
# Algorithm based on ICD-9 codes:
#
# (a)	At least 1 inpatient claim with a discharge ICD-9 diagnosis (any position)
# of 250.xx, 357.2, 362.0x, or 366.41.
#
# (b)	At least 2 carrier claims, carrier line or outpatient claims with ICD-9
# diagnoses (any position) of 250.xx, 357.2, 362.0x, or 366.41, linked by
# CLAIM_ID to an ambulatory physician evaluation and management claim (page 7),
# with the 2 claims occurring at least 7 days apart.
#
# Algorithm based on ICD-10 codes:
#
# (a)	At least 1 inpatient claim with a discharge ICD-10 diagnosis (any
# position) of 'E0836', 'E0842', 'E0936', 'E0942', 'E1010', 'E1011', 'E1029',
# 'E10311', 'E10319', 'E1036', 'E1039', 'E1040', 'E1042', 'E1051', 'E10618',
# 'E10620', 'E10621', 'E10622', 'E10628', 'E10630', 'E10638', 'E10641',
# 'E10649', 'E1065', 'E1069', 'E108', 'E109', 'E1100', 'E1101', 'E1129',
# 'E11311', 'E11319', 'E11329', 'E11339', 'E11349', 'E11359', 'E1136', 'E1139',
# 'E1140', 'E1142', 'E1151', 'E11618', 'E11620', 'E11621', 'E11622', 'E11628',
# 'E11630', 'E11638', 'E11641', 'E11649', 'E1165', 'E1169', 'E118', 'E119',
# 'E1310', 'E1336', 'E1342',  'E1037X1', 'E1037X2', 'E1037X3', 'E1037X9',
# 'E1110', 'E1111', 'E113291', 'E113292', 'E113293', 'E113299', 'E113391',
# 'E113392', 'E113393', 'E113399', 'E113491', 'E113492', 'E113493', 'E113499',
# 'E113591', 'E113592', 'E113593', 'E113599', 'E1137X2'.
#
# (b)	At least 2 carrier claims, carrier line or outpatient claims with ICD-10
# diagnoses (any position) of 'E0836', 'E0842', 'E0936', 'E0942', 'E1010',
# 'E1011', 'E1029', 'E10311', 'E10319', 'E1036', 'E1039', 'E1040', 'E1042',
# 'E1051', 'E10618', 'E10620', 'E10621', 'E10622', 'E10628', 'E10630', 'E10638',
# 'E10641', 'E10649', 'E1065', 'E1069', 'E108', 'E109', 'E1100', 'E1101',
# 'E1129', 'E11311', 'E11319', 'E11329', 'E11339', 'E11349', 'E11359', 'E1136',
# 'E1139', 'E1140', 'E1142', 'E1151', 'E11618', 'E11620', 'E11621', 'E11622',
# 'E11628', 'E11630', 'E11638', 'E11641', 'E11649', 'E1165', 'E1169', 'E118',
# 'E119', 'E1310', 'E1336', 'E1342', 'E1037X1', 'E1037X2', 'E1037X3', 'E1037X9',
# 'E1110', 'E1111', 'E113291', 'E113292', 'E113293', 'E113299', 'E113391',
# 'E113392', 'E113393', 'E113399', 'E113491', 'E113492', 'E113493', 'E113499',
# 'E113591', 'E113592', 'E113593', 'E113599', 'E1137X2', with the 2 claims
# occurring at least 7 days apart.
#
### history, version 2 ----
#
# Same as version 1 but includes
#  (c)	At least 1 pharmacy claim for an oral antidiabetic drug fill or insulin.

diab_icd9 <- unique(c(
  expand9("250"),
  # diabetes mellitus and all subcodes
  "3572",
  # polyneuropathy in diabetes (357.2)
  expand9("3620"),
  # diabetic retinopathy (362.0x)
  "36641"            # diabetic cataract (366.41)
))



# ICD-10 codes listed explicitly in the document (already short format)
diab_icd10 <- c(
  "E0836",
  "E0842",
  "E0936",
  "E0942",
  "E1010",
  "E1011",
  "E1029",
  "E10311",
  "E10319",
  "E1036",
  "E1039",
  "E1040",
  "E1042",
  "E1051",
  "E10618",
  "E10620",
  "E10621",
  "E10622",
  "E10628",
  "E10630",
  "E10638",
  "E10641",
  "E10649",
  "E1065",
  "E1069",
  "E108",
  "E109",
  "E1037X1",
  "E1037X2",
  "E1037X3",
  "E1037X9",
  "E1100",
  "E1101",
  "E1110",
  "E1111",
  "E1129",
  "E11311",
  "E11319",
  "E11329",
  "E11339",
  "E11349",
  "E11359",
  "E1136",
  "E1139",
  "E1140",
  "E1142",
  "E1151",
  "E11618",
  "E11620",
  "E11621",
  "E11622",
  "E11628",
  "E11630",
  "E11638",
  "E11641",
  "E11649",
  "E1165",
  "E1169",
  "E118",
  "E119",
  "E113291",
  "E113292",
  "E113293",
  "E113299",
  "E113391",
  "E113392",
  "E113393",
  "E113399",
  "E113491",
  "E113492",
  "E113493",
  "E113499",
  "E113591",
  "E113592",
  "E113593",
  "E113599",
  "E1137X2",
  "E1310",
  "E1336",
  "E1342"
)



diab_codes <- list(
  dx_icd9  = make_key_condition_only(diab_icd9),
  dx_icd10 = make_key_condition_only(diab_icd10)
)

# Shared base bullets (criteria a and b) used across all three diabetes versions.
diab_defs_base <- c(
  "i" = "Any of the following:",
  "*" = paste0(
    "\u22651 inpatient claim with a discharge ICD-9 diagnosis of {.strong 250.xx}, ",
    "{.strong 357.2}, {.strong 362.0x}, or {.strong 366.41}, or an ICD-10 diagnosis ",
    "from the diabetes code set in any discharge diagnosis position."
  ),
  "*" = paste0(
    "\u22652 carrier/outpatient claims with the same ICD codes in any position, ",
    "linked to an E&M claim, occurring at least 7 days apart."
  )
)

spec_diabetes_v1 <- CodeSpec$new(
  condition = "diabetes",
  version = "v1",
  label = "Diabetes Mellitus",
  defs  = list(
    condition = c(
      diab_defs_base,
      "i" = "Medication use is not required (diagnosis-based only)."
    ),
    outcome = NULL
  ),
  codes = diab_codes
)

spec_diabetes_v2 <- CodeSpec$new(
  condition = "diabetes", version = "v2", label = "Diabetes Mellitus",
  defs  = list(
    condition = c(diab_defs_base,
                  "*" = "\u22651 pharmacy claim for an oral antidiabetic drug or insulin (see {.strong spec_antidiabetic})."),
    outcome = NULL
  ),
  codes = diab_codes
)

spec_diabetes_v3 <- CodeSpec$new(
  condition = "diabetes", version = "v3", label = "Diabetes Mellitus",
  defs  = list(
    condition = c(
      diab_defs_base,
      "*" = "\u22651 pharmacy claim for an oral antidiabetic drug or insulin (see {.strong spec_antidiabetic}).",
      "i" = paste0(
        "Patients are then classified into four mutually exclusive categories: ",
        "no diabetes; diabetes without antidiabetic medication; ",
        "diabetes with oral antidiabetic (non-insulin); diabetes with insulin."
      )
    ),
    outcome = NULL
  ),
  codes = diab_codes
)

## Chronic kidney disease ----

### history, version 1 ----
#
# Any of the following:
#
# Algorithm based on ICD-9 codes:
#
#  (a)	≥1 inpatient claim with a discharge diagnosis code of chronic kidney
#  disease (ICD-9 diagnosis code of 016.0x, 095.4, 189.0, 189.9, 223.0, 236.91,
#  250.4x, 271.4, 274.1x, 283.11, 403.x1, 403.x0, 404.x2, 404.x3, 404.x0, 404.x1,
#  440.1, 442.1, 447.3, 572.4, 580.xx–588.xx, 591, 642.1x, 646.2x, 753.12–753.17,
#  753.19, 753.2x, 794.4) in any discharge diagnosis position.
#
#  (b)	≥1 physician evaluation and management visit (page 7) with a diagnosis code
#  of chronic kidney disease (ICD-9-CM diagnosis code of 016.0x, 095.4, 189.0,
#  189.9, 223.0, 236.91, 250.4x, 271.4, 274.1x, 283.11, 403.x1, 403.x0, 404.x2,
#  404.x3, 404.x0, 404.x1, 440.1, 442.1, 447.3, 572.4, 580.xx–588.xx, 591, 642.1x,
#  646.2x, 753.12–753.17, 753.19, 753.2x, 794.4) in any position.
#
# Algorithm based on ICD-10 codes:
#
#  (a)	≥1 inpatient claim with a discharge diagnosis code of chronic kidney
#  disease (ICD-10 diagnosis code of ‘A1811', 'A5275', 'C649', 'C689', 'D3000',
#  'D4100', 'D4120', 'D593', 'E1021’,  'E1029', 'E1121’, 'E1129', 'E748', 'I120',
#  'I129', 'I130', 'I1310', 'I1311', 'I132', I701', 'I722', 'K767', 'M1030',
#  'N003', 'N008', 'N009', 'N013', 'N022', 'N032', 'N033', 'N035', 'N038', 'N039',
#  'N040', 'N043', 'N044', 'N048', 'N049', 'N052', 'N055', 'N058', 'N059', 'N08',
#  'N1330', 'N170', 'N171', 'N172', 'N178', 'N179', 'N181', 'N182', 'N183',
#  'N184', 'N185', 'N186', 'N189', 'N19', 'N250', 'N251', 'N2581', 'N2589',
#  'N259', 'N269','Q6102', 'Q6119', 'Q612', 'Q613', 'Q614', 'Q615', 'Q618',
#  'Q6210', 'Q6211', 'Q6212', 'Q6231', 'Q6239', 'R944') in any discharge
#  diagnosis position.
#
#  (b)	≥1 physician evaluation and management visit (page 7) with a diagnosis code
#  of chronic kidney disease (ICD-10-CM diagnosis code of ‘A1811', 'A5275',
#  'C649', 'C689', 'D3000', 'D4100', 'D4120', 'D593', 'E1021’,  'E1029', 'E1121’,
#  'E1129', 'E748', 'I120', 'I129', 'I130', 'I1310', 'I1311', 'I132', I701',
#  'I722', 'K767', 'M1030', 'N003', 'N008', 'N009', 'N013', 'N022', 'N032',
#  'N033', 'N035', 'N038', 'N039', 'N040', 'N043', 'N044', 'N048', 'N049', 'N052',
#  'N055', 'N058', 'N059', 'N08', 'N1330', 'N170', 'N171', 'N172', 'N178', 'N179',
#  'N181', 'N182', 'N183', 'N184', 'N185', 'N186', 'N189', 'N19', 'N250', 'N251',
#  'N2581', 'N2589', 'N259', 'N269','Q6102', 'Q6119', 'Q612', 'Q613', 'Q614',
#  'Q615', 'Q618', 'Q6210', 'Q6211', 'Q6212', 'Q6231', 'Q6239', 'R944') in any
#  position.


ckd_icd9 <- unique(
  c(
    expand9("0160"),
    "0954",
    "1890",
    "1899",
    "2230",
    "23691",
    expand9("2504"),
    # diabetic nephropathy
    "2714",
    expand9("2741"),
    # gouty nephropathy
    "28311",
    Filter(\(x) endsWith(x, "0"), expand9("403")),
    # 403.x0
    Filter(\(x) endsWith(x, "1"), expand9("403")),
    # 403.x1
    Filter(\(x) endsWith(x, "0"), expand9("404")),
    # 404.x0
    Filter(\(x) endsWith(x, "1"), expand9("404")),
    # 404.x1
    Filter(\(x) endsWith(x, "2"), expand9("404")),
    # 404.x2
    Filter(\(x) endsWith(x, "3"), expand9("404")),
    # 404.x3
    "4401",
    "4421",
    "4473",
    "5724",
    range9("580", "588"),
    # 580.xx–588.xx
    "591",
    expand9("6421"),
    expand9("6462"),
    range9("75312", "75317"),
    "75319",
    expand9("7532"),
    "7944"
  )
)


# ICD-10 codes hardcoded from the Perisphere definitions document.
ckd_icd10 <- c(
  "A1811",   # tuberculosis of kidney
  "A5275",
  "C649",
  "C689",
  "D3000",
  "D4100",
  "D4120",
  "D593",
  "E1021",   # type 1 DM with diabetic nephropathy
  "E1029",
  "E1121",   # type 2 DM with diabetic nephropathy
  "E1129",
  "E748",
  "I120",
  "I129",
  "I130",
  "I1310",
  "I1311",
  "I132",
  "I701",
  "I722",
  "K767",
  "M1030",
  "N003",
  "N008",
  "N009",
  "N013",
  "N022",
  "N032",
  "N033",
  "N035",
  "N038",
  "N039",
  "N040",
  "N043",
  "N044",
  "N048",
  "N049",
  "N052",
  "N055",
  "N058",
  "N059",
  "N08",
  "N1330",
  "N170",
  "N171",
  "N172",
  "N178",
  "N179",
  "N181",
  "N182",
  "N183",
  "N184",
  "N185",
  "N186",
  "N189",
  "N19",
  "N250",
  "N251",
  "N2581",
  "N2589",
  "N259",
  "N269",
  "Q6102",
  "Q6119",
  "Q612",
  "Q613",
  "Q614",
  "Q615",
  "Q618",
  "Q6210",
  "Q6211",
  "Q6212",
  "Q6231",
  "Q6239",
  "R944"
)

ckd_defs_condition <- c(
  "i" = "Any of the following:",
  "*" = paste0(
    "\u22651 inpatient claim with a discharge ICD-9 or ICD-10 diagnosis code for ",
    "chronic kidney disease in any discharge diagnosis position."
  ),
  "*" = paste0(
    "\u22651 physician E&M visit with an ICD-9 or ICD-10 CKD diagnosis code ",
    "in any position."
  ),
  "i" = paste0(
    "For Medicare data, {.strong ESRD_IND = 'Y'} in the Master Beneficiary Summary ",
    "File additionally qualifies a participant as having CKD history."
  )
)

spec_ckd_v1 <- CodeSpec$new(
  condition = "ckd", version = "v1", label = "Chronic Kidney Disease (CKD)",
  defs  = list(condition = ckd_defs_condition, outcome = NULL),
  codes = list(
    dx_icd9  = make_key_condition_only(ckd_icd9),
    dx_icd10 = make_key_condition_only(ckd_icd10)
  )
)


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
    dx_icd9  = make_key_condition_only(osa_icd9),
    dx_icd10 = make_key_condition_only(osa_icd10)
  )
)


## Obesity hypoventilation syndrome ----

# ICD-9 278.03 is the only specific code for OHS (a leaf node with no children).
# ICD-10 E66.2 (Morbid (severe) obesity with alveolar hypoventilation) is the
# direct map; it also covers Pickwickian syndrome as an included term.

ohs_icd9  <- "27803"   # 278.03 — Obesity hypoventilation syndrome
ohs_icd10 <- "E662"    # E66.2  — Morbid (severe) obesity with alveolar hypoventilation

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
  codes = list(
    dx_icd9  = make_key_condition_only(ohs_icd9),
    dx_icd10 = make_key_condition_only(ohs_icd10)
  )
)


## Hyperlipidemia ----

### history, version 1 ----
#
# Any of following codes in any diagnosis position from inpatient or outpatient
# settings:
#
# (a)	≥2 claims on separate calendar days with ICD-9 diagnoses (any position)
# of 272.0, 272.1, 272.2, 272.3, 272.4 linked to a physician E&M code.
#
# (b)	≥2 claims on separate calendar days with ICD-9 diagnoses (any position)
# of 272.0, 272.1, 272.2, 272.3, 272.4.
#
# (c)	≥2 claims on separate calendar days with ICD-10 diagnoses (any position)
# of E78.0, E78.1, E78.2, E78.3, E78.4, E78.5 linked to a physician E&M code.
#
# (d)	≥2 claims on separate calendar days with ICD-10 diagnoses (any position)
# of E78.0, E78.1, E78.2, E78.3, E78.4, E78.5.
#

hyp_icd9  <- c("2720", "2721", "2722", "2723", "2724")
hyp_icd10 <- c("E780", "E781", "E782", "E783", "E784", "E785")

spec_hyperlipidemia_v1 <- CodeSpec$new(
  condition = "hyperlipidemia", version = "v1", label = "Hyperlipidemia",
  defs = list(
    condition = c(
      "*" = paste0(
        "\u22652 claims on separate calendar days with ICD-9 diagnoses ",
        "{.strong 272.0}\u2013{.strong 272.4}, or ICD-10 diagnoses of {.strong E78.0}, ",
        "{.strong E78.1}, {.strong E78.2}, {.strong E78.3}, {.strong E78.4}, or {.strong E78.5} ",
        "in any diagnosis position (carrier, outpatient, inpatient, SNF, or HHA)."
      ),
      "i" = "Carrier and outpatient claims must be linked to a physician E&M code."
    ),
    outcome = NULL
  ),
  codes = list(
    dx_icd9  = make_key_condition_only(hyp_icd9),
    dx_icd10 = make_key_condition_only(hyp_icd10)
  )
)


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
# to physician E&M code of 490.xx, 491.0x, 491.1x, 491.8x, 491.9x, 492.0x,
# 492.8x, 491.20, 491.21, 491.22, 494.0x, 494.1x, 496.xx.
#
# (c)	≥1 inpatient, skilled nursing facility, home health agency claim with
# ICD-10 diagnoses (any position) of 'J40', 'J410', 'J411', 'J418', 'J42',
# 'J430', 'J431', 'J432', 'J438', 'J439', 'J440', 'J441', 'J449', 'J470',
# 'J471', 'J479', J4481, J4489
#
# (d)	≥2 outpatient, or carrier claim with ICD-10 diagnoses (any position)
# linked to physician E&M code of 'J40', 'J410', 'J411', 'J418', 'J42', 'J430',
# 'J431', 'J432', 'J438', 'J439', 'J440', 'J441', 'J449', 'J470', 'J471',
# 'J479', J4481, J4489
#

copd_icd9 <- unique(
  c(
    expand9("490"),
    expand9("4910"),
    expand9("4911"),
    expand9("4918"),
    expand9("4919"),
    "49120",
    "49121",
    "49122",
    expand9("4920"),
    expand9("4928"),
    expand9("4940"),
    expand9("4941"),
    expand9("496")
  )
)
copd_icd10 <- c(
  "J40",
  "J410",
  "J411",
  "J418",
  "J42",
  "J430",
  "J431",
  "J432",
  "J438",
  "J439",
  "J440",
  "J441",
  "J449",
  "J470",
  "J471",
  "J479",
  "J4481",
  "J4489"
)

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
    "\u22652 outpatient or carrier claims with the same ICD codes in any position, ",
    "linked to a physician E&M claim."
  )
)

spec_copd_v1 <- CodeSpec$new(
  condition = "copd", version = "v1",
  label = "Chronic Obstructive Pulmonary Disease (COPD)",
  defs  = list(condition = copd_defs_condition, outcome = NULL),
  codes = list(
    dx_icd9  = make_key_condition_only(copd_icd9),
    dx_icd10 = make_key_condition_only(copd_icd10)
  )
)

## Asthma ----

asthma_icd9  <- unique(expand9("493"))
asthma_icd10 <- unique(expand10("J45"))

asthma_defs_condition <- c(
  "i" = "Any of the following:",
  "*" = paste0(
    "\u22651 inpatient claim with an ICD-9 diagnosis of {.strong 493.xx}, or an ",
    "ICD-10 diagnosis of {.strong J45.xx} in any position."
  ),
  "*" = paste0(
    "\u22652 outpatient or carrier claims with the same ICD codes in any position, ",
    "linked to a physician E&M claim."
  )
)

spec_asthma_v1 <- CodeSpec$new(
  condition = "asthma", version = "v1",
  label = "Asthma",
  defs  = list(condition = asthma_defs_condition, outcome = NULL),
  codes = list(
    dx_icd9  = make_key_condition_only(asthma_icd9),
    dx_icd10 = make_key_condition_only(asthma_icd10)
  )
)


# Specifications for medications ----

## Antiobesity medication components ----

spec_non_glp1_v1 <- DrugSpec$new(
  'non_glp1', "Antiobesity (non GLP-1)",
  version = 'v1',
  defs = "From the Perisphere antiobesity (non GLP-1) medication list.",
  generic_names = c("NALTREXONE HCL/BUPROPION HCL", "ORLISTAT")
)

spec_glp1_v1 <- DrugSpec$new(
  'glp1', "GLP-1",
  version = 'v1',
  defs = "From the Perisphere antiobesity (non GLP-1) medication list.",
  generic_names = c("EXENATIDE",
                    "EXENATIDE EXTENDED-RELEASE",
                    "DULAGLUTIDE",
                    "SEMAGLUTIDE",
                    "LIRAGLUTIDE",
                    "TIRZEPATIDE")
)

## Antiobesity medication compositions ----

spec_antiobesity <- CompositeDrugSpec$new(
  drug_class = "antiobesity",
  label      = "Antiobesity Medications",
  defs       = "Antiobesity medication subclasses (v1): non-GLP-1 agents and GLP-1 receptor agonists.",
  components = list(
    non_glp1_v1 = spec_non_glp1_v1,
    glp1_v1     = spec_glp1_v1
  )
)

## Antidepressive medication components ----

spec_antidep_ssri_v1 <- DrugSpec$new(
  "ssri", "SSRIs",
  version = "v1",
  defs    = "Selective serotonin reuptake inhibitors (SSRIs).",
  generic_names = c(
    "CITALOPRAM", "ESCITALOPRAM", "FLUOXETINE",
    "FLUVOXAMINE", "PAROXETINE", "SERTRALINE"
  )
)

spec_antidep_snri_v1 <- DrugSpec$new(
  "snri", "SNRIs",
  version = "v1",
  defs    = "Serotonin-norepinephrine reuptake inhibitors (SNRIs).",
  generic_names = c(
    "DESVENLAFAXINE", "DULOXETINE", "LEVOMILNACIPRAN",
    "MILNACIPRAN", "VENLAFAXINE"
  )
)

spec_antidep_tca_v1 <- DrugSpec$new(
  "tca", "Tricyclic Antidepressants",
  version = "v1",
  defs    = "Tricyclic and tetracyclic antidepressants (TCAs).",
  generic_names = c(
    "AMITRIPTYLINE", "AMOXAPINE", "CLOMIPRAMINE", "DESIPRAMINE",
    "DOXEPIN", "IMIPRAMINE", "MAPROTILINE", "NORTRIPTYLINE",
    "PROTRIPTYLINE", "TRIMIPRAMINE"
  )
)

spec_antidep_maoi_v1 <- DrugSpec$new(
  "maoi", "MAOIs",
  version = "v1",
  defs    = "Monoamine oxidase inhibitors (MAOIs).",
  generic_names = c(
    "ISOCARBOXAZID", "PHENELZINE", "SELEGILINE", "TRANYLCYPROMINE"
  )
)

spec_antidep_other_v1 <- DrugSpec$new(
  "other", "Other Antidepressants",
  version = "v1",
  defs    = paste0(
    "Atypical and other-mechanism antidepressants, including NDRIs (bupropion), ",
    "NaSSAs (mirtazapine), SARIs (trazodone, nefazodone), serotonin modulators ",
    "(vilazodone, vortioxetine), and perphenazine (included for the ",
    "perphenazine/amitriptyline fixed-dose combination product)."
  ),
  generic_names = c(
    "BUPROPION", "MIRTAZAPINE", "NEFAZODONE",
    "PERPHENAZINE", "TRAZODONE", "VILAZODONE", "VORTIOXETINE"
  )
)

spec_antidepressive <- CompositeDrugSpec$new(
  drug_class = "antidepressive",
  label      = "Antidepressive Medications",
  defs       = paste0(
    "Antidepressive medication subclasses (v1): SSRIs, SNRIs, tricyclic ",
    "antidepressants, MAOIs, and other/atypical agents."
  ),
  components = list(
    ssri_v1  = spec_antidep_ssri_v1,
    snri_v1  = spec_antidep_snri_v1,
    tca_v1   = spec_antidep_tca_v1,
    maoi_v1  = spec_antidep_maoi_v1,
    other_v1 = spec_antidep_other_v1
  )
)

## Antihypertensive medication components ----

### ACE inhibitors ----

spec_acei_v1 <- DrugSpec$new(
  "acei", "ACE Inhibitors",
  version = "v1",
  defs    = "From the Perisphere antihypertensive medication list.",
  generic_names = c("BENAZEPRIL","CAPTOPRIL","ENALAPRIL","FOSINOPRIL","LISINOPRIL",
                    "MOEXIPRIL","PERINDOPRIL","QUINAPRIL","RAMIPRIL","TRANDOLAPRIL")
)

spec_acei_v2 <- DrugSpec$new(
  "acei", "ACE Inhibitors",
  version = "v2",
  defs    = "From First Data Bank (FDB).",
  generic_names = c("BENAZEPRIL","CAPTOPRIL","ENALAPRIL","FOSINOPRIL","FOSINIPRIL",
                    "LISINOPRIL","MOEXIPRIL","MOEXEPRIL","PERINDOPRIL","QUINAPRIL",
                    "RAMIPRIL","TRANDOLAPRIL")
)

### Aldosterone antagonists ----
# (v1 only — no FDB expansion)
spec_aldo_v1 <- DrugSpec$new(
  "aldo", "Aldosterone Antagonists",
  version = "v1",
  defs    = "From the Perisphere antihypertensive medication list.",
  generic_names = c("EPLERENONE", "SPIRONOLACTONE")
)

### Alpha-1 blockers ----
# v1 only
spec_alpha_v1 <- DrugSpec$new(
  "alpha", "Alpha-1 Blockers",
  version = "v1",
  defs    = "From the Perisphere antihypertensive medication list.",
  generic_names = c("DOXAZOSIN", "PRAZOSIN", "TERAZOSIN")
)

### Alpha-beta blockers ----
spec_alpha_beta_v1 <- DrugSpec$new(
  "alpha_beta", "Alpha-Beta Blockers",
  version = "v1",
  defs    = "From the Perisphere antihypertensive medication list.",
  generic_names = c("CARVEDILOL", "LABETALOL")
)

spec_alpha_beta_v2 <- DrugSpec$new(
  "alpha_beta", "Alpha-Beta Blockers",
  version = "v2",
  defs    = "From First Data Bank (FDB). Adds LABETOLOL spelling variant.",
  generic_names = c("CARVEDILOL", "LABETALOL", "LABETOLOL")
)

### ARBs ----
spec_arb_v1 <- DrugSpec$new(
  "arb", "Angiotensin Receptor Blockers (ARBs)",
  version = "v1",
  defs    = "From the Perisphere antihypertensive medication list.",
  generic_names = c("AZILSARTAN","CANDESARTAN","EPROSARTAN","IRBESARTAN",
                    "LOSARTAN","OLMESARTAN","TELMISARTAN","VALSARTAN")
)

spec_arb_v2 <- DrugSpec$new(
  "arb", "Angiotensin Receptor Blockers (ARBs)",
  version = "v2",
  defs    = "From First Data Bank (FDB). Adds OLMESARTEN spelling variant.",
  generic_names = c("AZILSARTAN","CANDESARTAN","EPROSARTAN","IRBESARTAN",
                    "LOSARTAN","OLMESARTAN","OLMESARTEN","TELMISARTAN","VALSARTAN")
)

### Beta blockers: cardioselective  ----
spec_beta_cardio_v1 <- DrugSpec$new(
  "beta_cardio", "Beta Blockers (Cardioselective)",
  version = "v1",
  defs    = "Cardioselective beta blockers from the Perisphere antihypertensive medication list.",
  generic_names = c("ATENOLOL", "BETAXOLOL", "BISOPROLOL", "METOPROLOL")
)

### Beta blockers: cardioselective-vasodilatory ----
spec_beta_cardio_vasod_v1 <- DrugSpec$new(
  "beta_cardio_vasod", "Beta Blockers (Cardioselective, Vasodilatory)",
  version = "v1",
  defs    = "Cardioselective vasodilatory beta blocker from the Perisphere antihypertensive medication list.",
  generic_names = c("NEBIVOLOL")
)

### Beta blockers: ISA ----
spec_beta_int_sym_v1 <- DrugSpec$new(
  "beta_int_sym", "Beta Blockers (Intrinsic Sympathomimetic Activity)",
  version = "v1",
  defs    = "ISA beta blockers from the Perisphere antihypertensive medication list.",
  generic_names = c("ACEBUTOLOL", "CARTEOLOL", "PENBUTOLOL", "PINDOLOL")
)

spec_beta_int_sym_v2 <- DrugSpec$new(
  "beta_int_sym", "Beta Blockers (Intrinsic Sympathomimetic Activity)",
  version = "v2",
  defs    = "ISA beta blockers from FDB. Excludes CARTEOLOL and PENBUTOLOL.",
  generic_names = c("ACEBUTOLOL", "PINDOLOL")
)

### Beta blockers: noncardioselective  ----
spec_beta_noncardio_v1 <- DrugSpec$new(
  "beta_noncardio", "Beta Blockers (Noncardioselective)",
  version = "v1",
  defs    = "Noncardioselective beta blockers from the Perisphere antihypertensive medication list.",
  generic_names = c("NADOLOL", "PROPRANOLOL")
)

### CCB: dihydropyridines ----
# CCB DHP: no v2 change — same list in both Perisphere and FDB sources.
spec_ccb_dhp_v1 <- DrugSpec$new(
  "ccb_dhp", "Calcium Channel Blockers (Dihydropyridines)",
  version = "v1",
  defs    = "Dihydropyridine CCBs from the Perisphere antihypertensive medication list and FDB.",
  generic_names = c("AMLODIPINE","FELODIPINE","ISRADIPINE","NICARDIPINE",
                    "NIFEDIPINE","NISOLDIPINE")
)

### CCB: non-dihydropyridines ----
spec_ccb_nondhp_v1 <- DrugSpec$new(
  "ccb_nondhp", "Calcium Channel Blockers (Non-Dihydropyridines)",
  version = "v1",
  defs    = "Non-dihydropyridine CCBs from the Perisphere antihypertensive medication list.",
  generic_names = c("DILTIAZEM", "VERAPAMIL")
)

### Centrally acting agents ----
spec_central_v1 <- DrugSpec$new(
  "central", "Centrally Acting Agents",
  version = "v1",
  defs    = "Centrally acting antihypertensives from the Perisphere list. Note: exclude APRACLONIDINE when matching CLONIDINE.",
  generic_names = c("CLONIDINE", "METHYLDOPA", "GUANFACINE")
)

spec_central_v2 <- DrugSpec$new(
  "central", "Centrally Acting Agents",
  version = "v2",
  defs    = "Centrally acting antihypertensives from FDB. Note: exclude APRACLONIDINE when matching CLONIDINE.",
  generic_names = c("CLONIDINE","GUANABENZ","GUANFACINE","METHYLDOPA","RESERPINE")
)

### Diuretics: thiazide ----
spec_diuretics_thiazide_v1 <- DrugSpec$new(
  "diuretics_thiazide", "Diuretics (Thiazide and Thiazide-Type)",
  version = "v1",
  defs    = "Thiazide diuretics from the Perisphere antihypertensive medication list.",
  generic_names = c("CHLOROTHIAZIDE","CHLORTHALIDONE","HYDROCHLOROTHIAZIDE",
                    "INDAPAMIDE","METOLAZONE","HCTZ")
)

spec_diuretics_thiazide_v2 <- DrugSpec$new(
  "diuretics_thiazide", "Diuretics (Thiazide and Thiazide-Type)",
  version = "v2",
  defs    = "Thiazide diuretics from FDB. Includes additional agents and spelling variants.",
  generic_names = c("CHLOROTHIAZIDE","CHLORTHALIDONE","HYDROCHLOROTHIAZIDE",
                    "HYDROCHOLOROTHIAZIDE","INDAPAMIDE","METOLAZONE",
                    "BENDROFLUMETHIAZIDE","POLYTHIAZIDE")
)

### Diuretics: loop ----
spec_diuretics_loop_v1 <- DrugSpec$new(
  "diuretics_loop", "Diuretics (Loop)",
  version = "v1",
  defs    = "Loop diuretics from the Perisphere antihypertensive medication list.",
  generic_names = c("BUMETANIDE", "FUROSEMIDE", "TORSEMIDE")
)

spec_diuretics_loop_v2 <- DrugSpec$new(
  "diuretics_loop", "Diuretics (Loop)",
  version = "v2",
  defs    = "Loop diuretics from FDB. Adds ETHACRYNIC ACID.",
  generic_names = c("BUMETANIDE", "ETHACRYNIC ACID", "FUROSEMIDE", "TORSEMIDE")
)

### Diuretics: potassium-sparing ----
spec_diuretics_ksparing_v1 <- DrugSpec$new(
  "diuretics_ksparing", "Diuretics (Potassium-Sparing)",
  version = "v1",
  defs    = "Potassium-sparing diuretics from the Perisphere antihypertensive medication list.",
  generic_names = c("AMILORIDE", "TRIAMTERENE")
)

spec_diuretics_ksparing_v2 <- DrugSpec$new(
  "diuretics_ksparing", "Diuretics (Potassium-Sparing)",
  version = "v2",
  defs    = "Potassium-sparing diuretics from FDB. Adds spelling variants.",
  generic_names = c("AMILORIDE","TRIAMTERENE","TRIAMTERINE","TRIMATERENE")
)

### Direct renin inhibitors ----
spec_renin_v1 <- DrugSpec$new(
  "renin", "Direct Renin Inhibitors",
  version = "v1",
  defs    = "Direct renin inhibitors from the Perisphere antihypertensive medication list.",
  generic_names = c("ALISKIREN")
)

### Direct vasodilators ----
spec_vasodilators_v1 <- DrugSpec$new(
  "vasodilators", "Direct Vasodilators",
  version = "v1",
  defs    = "Direct vasodilators from the Perisphere antihypertensive medication list.",
  generic_names = c("HYDRALAZINE", "MINOXIDIL")
)

## Antihypertensive medication compositions ----

### beta blockers ----

spec_betablockers <- CompositeDrugSpec$new(
  drug_class = "betablockers",
  label      = "Beta Blockers",
  defs       = "All beta blocker subclasses across versions. Use component= to select a specific version.",
  components = list(
    cardio_v1       = spec_beta_cardio_v1,
    cardio_vasod_v1 = spec_beta_cardio_vasod_v1,
    int_sym_v1      = spec_beta_int_sym_v1,
    int_sym_v2      = spec_beta_int_sym_v2,
    noncardio_v1    = spec_beta_noncardio_v1
  )
)

### CCBs ----
spec_ccb <- CompositeDrugSpec$new(
  drug_class = "ccb",
  label      = "Calcium Channel Blockers",
  defs       = "Dihydropyridine and non-dihydropyridine CCBs across versions.",
  components = list(
    dhp_v1    = spec_ccb_dhp_v1,
    nondhp_v1 = spec_ccb_nondhp_v1
  )
)

### diuretics ----
# (incl. aldosterone antagonists)
spec_diuretics <- CompositeDrugSpec$new(
  drug_class = "diuretics",
  label      = "Diuretics",
  defs       = "Thiazide, loop, potassium-sparing, and aldosterone antagonist diuretics across versions.",
  components = list(
    thiazide_v1  = spec_diuretics_thiazide_v1,
    thiazide_v2  = spec_diuretics_thiazide_v2,
    loop_v1      = spec_diuretics_loop_v1,
    loop_v2      = spec_diuretics_loop_v2,
    ksparing_v1  = spec_diuretics_ksparing_v1,
    ksparing_v2  = spec_diuretics_ksparing_v2,
    aldo_v1      = spec_aldo_v1
  )
)

### All antihypertensives ----

# All drug specs listed directly. Sub-composites (betablockers, ccb,
# diuretics) still exist as standalone objects but are kept flat here.
# If we nested, it would mean you'd have to run get_codes more than once,
# which would make the package feel too clunky.

spec_antihypertensive <- CompositeDrugSpec$new(
  drug_class = "antihypertensive",
  label      = "Antihypertensive Medications",
  defs       = paste0(
    "All antihypertensive leaf components across versions (v1 = Perisphere list; ",
    "v2 = FDB). Note for central agents: exclude APRACLONIDINE when matching CLONIDINE."
  ),
  components = list(
    acei_v1         = spec_acei_v1,
    acei_v2         = spec_acei_v2,
    arb_v1          = spec_arb_v1,
    arb_v2          = spec_arb_v2,
    alpha_v1        = spec_alpha_v1,
    alpha_beta_v1   = spec_alpha_beta_v1,
    alpha_beta_v2   = spec_alpha_beta_v2,
    cardio_v1       = spec_beta_cardio_v1,
    cardio_vasod_v1 = spec_beta_cardio_vasod_v1,
    int_sym_v1      = spec_beta_int_sym_v1,
    int_sym_v2      = spec_beta_int_sym_v2,
    noncardio_v1    = spec_beta_noncardio_v1,
    ccb_dhp_v1      = spec_ccb_dhp_v1,
    ccb_nondhp_v1   = spec_ccb_nondhp_v1,
    thiazide_v1     = spec_diuretics_thiazide_v1,
    thiazide_v2     = spec_diuretics_thiazide_v2,
    loop_v1         = spec_diuretics_loop_v1,
    loop_v2         = spec_diuretics_loop_v2,
    ksparing_v1     = spec_diuretics_ksparing_v1,
    ksparing_v2     = spec_diuretics_ksparing_v2,
    aldo_v1         = spec_aldo_v1,
    central_v1      = spec_central_v1,
    central_v2      = spec_central_v2,
    renin_v1        = spec_renin_v1,
    vasodilators_v1 = spec_vasodilators_v1
  )
)




# Antidiabetic drug components ----
# Source: "Definition of conditions and medications_11262025.docx"
# Section: Diabetes, history, version 2 (with medication) — GNN list

# All GNNs from the document's antidiabetic medication list, version 1
antidiab_gnns <- list(
  biguanide = c(
    "METFORMIN HCL",
    "METFORMIN/AA COMB.#7/HC#125/CH",
    "METFORMIN/CAFF/AA7/HRB125/CHOL"
  ),
  sulfonylurea = c(
    "ACETOHEXAMIDE",
    "CHLORPROPAMIDE",
    "GLIMEPIRIDE",
    "GLIPIZIDE",
    "GLIPIZIDE/METFORMIN HCL",
    "GLYBURIDE",
    "GLYBURIDE,MICRONIZED",
    "GLYBURIDE/METFORMIN HCL",
    "TOLAZAMIDE",
    "TOLBUTAMIDE"
  ),
  meglitinide = c("NATEGLINIDE", "REPAGLINIDE", "REPAGLINIDE/METFORMIN HCL"),
  tzd = c(
    "PIOGLITAZONE HCL",
    "PIOGLITAZONE HCL/GLIMEPIRIDE",
    "PIOGLITAZONE HCL/METFORMIN HCL",
    "PIOGLITAZONE/GLIMEPIRIDE",
    "ROSIGLITAZONE MALEATE",
    "ROSIGLITAZONE/GLIMEPIRIDE",
    "ROSIGLITAZONE/METFORMIN HCL",
    "TROGLITAZONE"
  ),
  alpha_glucosidase = c("ACARBOSE", "MIGLITOL", "VOGLIBOSE"),
  dpp4 = c(
    "ALOGLIPTIN BENZ/METFORMIN HCL",
    "ALOGLIPTIN BENZ/PIOGLITAZONE",
    "ALOGLIPTIN BENZ/PIOGLITZONE",
    "ALOGLIPTIN BENZOATE",
    "ALOGLIPTIN/METFORMIN",
    "LINAGLIPTIN",
    "LINAGLIPTIN/METFORMIN HCL",
    "PIOGLITAZONE/ALOGLIPTIN",
    "SAXAGLIPTIN HCL",
    "SAXAGLIPTIN HCL/METFORMIN HCL",
    "SAXAGLIPTIN HYDROCHLORIDE",
    "SITAGLIPTIN PHOS/METFORMIN HCL",
    "SITAGLIPTIN PHOSPHATE",
    "SITAGLIPTIN/SIMVASTATIN",
    "VILDAGLIPTIN"
  ),
  sglt2 = c(
    "CANAGLIFLOZIN",
    "CANAGLIFLOZIN/METFORM",
    "CANAGLIFLOZIN/METFORMIN",
    "DAPAGLIFLOZIN",
    "DAPAGLIFLOZIN/METFORMIN",
    "DAPAGLIFLOZIN/SAXAGLIPTIN",
    "EMPAGLIFLOZIN",
    "EMPAGLIFLOZIN/LINAGLIPTIN",
    "EMPAGLIFLOZIN/LINAGLIPTIN/METFORMIN",
    "EMPAGLIFLOZIN/METFORMIN",
    "ERTUGLIFLOZIN",
    "ERTUGLIFLOZIN/METFORMIN",
    "ERTUGLIFLOZIN/SITAGLIPTIN"
  ),
  glp1 = c(
    "DULAGLUTIDE",
    "EXENATIDE",
    "EXENATIDE MICROSPHERES",
    "LIRAGLUTIDE",
    "LIXISENATIDE",
    "SEMAGLUTIDE"
  ),
  insulin = c(
    "HUM INSULIN NPH/REG INSULIN HM",
    "INS ZN,BF (P)/INS ZN,PK (P),",
    "INSUL,PK PURE/INSUL NPH,PK-P",
    "INSULIN ADMIN. SUPPLIES",
    "INSULIN ASPART",
    "INSULIN DEGLEDEC",
    "INSULIN DEGLEDEC/LIRAGLUTIDE",
    "INSULIN DETEMIR",
    "INSULIN GLARGINE,HUM.REC.ANLOG",
    "INSULIN GLULISINE",
    "INSULIN ISOPHANE NPH,BFPK",
    "INSULIN ISOPHANE NPH,BF-PK",
    "INSULIN ISOPHANE,BEEF",
    "INSULIN ISOPHANE,BEEF PURE",
    "INSULIN ISOPHANE,PORK PURE",
    "INSULIN LISPRO",
    "INSULIN NPH HUM/REG INSULIN HM",
    "INSULIN NPH HUMAN ISOPHANE",
    "INSULIN NPH HUMAN SEMISYN",
    "INSULIN NPH HUMAN SEMI-SYN",
    "INSULIN NPH S-S/REG INSULN S-S",
    "INSULIN NPL/INSULIN LISPRO",
    "INSULIN PROTAMINE ZINC,BEEF",
    "INSULIN PROTAMINE ZN,BEEF (P),",
    "INSULIN PROTAMINE ZN,BF-PK",
    "INSULIN PROTAMINE ZN,PORK (P),",
    "INSULIN REG HUMAN  SEMI-SYN",
    "INSULIN REG HUMAN SEMI-SYN",
    "INSULIN REG,HUM S-S BUFF",
    "INSULIN REGULAR,HUMAN",
    "INSULIN REGULAR,BEEF-PORK",
    "INSULIN REGULAR,HUMAN BUFFERED",
    "INSULIN REGULAR,HUMAN&REL.UNT",
    "INSULIN ZINC BEEF",
    "INSULIN ZINC EXT,BEEF (P),",
    "INSULIN ZINC EXTEND HUMAN REC",
    "INSULIN ZINC EXTENDED,BEEF",
    "INSULIN ZINC EXTENDED,BF-PK",
    "INSULIN ZINC HUMAN REC",
    "INSULIN ZINC HUMAN SEMI-SYN",
    "INSULIN ZINC PROMPT,BEEF",
    "INSULIN ZINC PROMPT,BF-PK",
    "INSULIN ZINC PROMPT,PORK PURE",
    "INSULIN ZINC,BEEF PURIFIED",
    "INSULIN ZINC,BEEF-PORK",
    "INSULIN ZINC,PORK PURIFIED",
    "INSULIN,BEEF",
    "INSULIN,PORK",
    "INSULIN,PORK PURIFIED",
    "INSULIN,PORK REG. CONCENTRATE",
    "INSULN ASP PRT/INSULIN ASPART",
    "LIXISENATIDE/INSULIN GLARGINE",
    "NPH,HUMAN INSULIN ISOPHANE",
    "REG INSULIN HM/RLSE/CHBR/IHLR",
    "SUB-Q INSULIN DEVICE,20 UNIT",
    "SUB-Q INSULIN DEVICE,40 UNIT",
    "SYR W-NDL,INS 0.3 ML HALF MARK",
    "SYRGND,INS,0.5/CONTAINER",
    "SYRG-ND,INS,0.5/CONTAINER",
    "SYRING  W-NDL,DISP,INSUL,0.3ML",
    "SYRING WNDL,DISP,INSUL,0.5 ML",
    "SYRING W-NDL,DISP,INSUL,0.3 ML",
    "SYRING W-NDL,DISP,INSUL,0.3ML",
    "SYRING W-NDL,DISP,INSUL,0.5 ML",
    "SYRING W-NDL,DISP,INSUL,0.5ML",
    "SYRING W-O NDL,DISP,INSUL,1ML",
    "SYRINGE & NEEDLE,INSULIN,1 ML",
    "SYRINGE W-NDL,DISP,INSUL,1ML",
    "SYRINGE W-NDL,DISP.,INSULIN",
    "SYR-ND,INS,0.5/CONTAINER,EMPTY",
    "SYRNGE&NEEDLE,INSLN,1ML&SHARPS"
  ),
  amylin = c("PRAMLINTIDE ACETATE")
)

antidiab_defs <- list(
  biguanide         = "Biguanide antidiabetic agents. From the Perisphere antidiabetic medication list.",
  sulfonylurea      = "Sulfonylurea antidiabetic agents (first- and second-generation). From the Perisphere antidiabetic medication list.",
  meglitinide       = "Meglitinide (glinide) antidiabetic agents. From the Perisphere antidiabetic medication list.",
  tzd               = "Thiazolidinedione (TZD / glitazone) antidiabetic agents. From the Perisphere antidiabetic medication list.",
  alpha_glucosidase = "Alpha-glucosidase inhibitor antidiabetic agents. From the Perisphere antidiabetic medication list.",
  dpp4              = "DPP-4 inhibitor (gliptin) antidiabetic agents, including fixed-dose combinations. From the Perisphere antidiabetic medication list.",
  sglt2             = "SGLT-2 inhibitor antidiabetic agents (gliflozins), including fixed-dose combinations. From the Perisphere antidiabetic medication list.",
  glp1              = "GLP-1 receptor agonist antidiabetic agents. From the Perisphere antidiabetic medication list.",
  insulin           = "Insulin preparations and insulin administration supplies. From the Perisphere antidiabetic medication list.",
  amylin            = "Amylin analogue antidiabetic agents. From the Perisphere antidiabetic medication list."
)

spec_antidiab_biguanide_v1         <- DrugSpec$new("antidiab_biguanide",         "Biguanides",                   version = "v1", defs = antidiab_defs$biguanide,         generic_names = antidiab_gnns$biguanide)
spec_antidiab_sulfonylurea_v1      <- DrugSpec$new("antidiab_sulfonylurea",      "Sulfonylureas",                version = "v1", defs = antidiab_defs$sulfonylurea,      generic_names = antidiab_gnns$sulfonylurea)
spec_antidiab_meglitinide_v1       <- DrugSpec$new("antidiab_meglitinide",       "Meglitinides",                 version = "v1", defs = antidiab_defs$meglitinide,       generic_names = antidiab_gnns$meglitinide)
spec_antidiab_tzd_v1               <- DrugSpec$new("antidiab_tzd",               "Thiazolidinediones (TZDs)",    version = "v1", defs = antidiab_defs$tzd,               generic_names = antidiab_gnns$tzd)
spec_antidiab_alpha_glucosidase_v1 <- DrugSpec$new("antidiab_alpha_glucosidase", "Alpha-Glucosidase Inhibitors", version = "v1", defs = antidiab_defs$alpha_glucosidase, generic_names = antidiab_gnns$alpha_glucosidase)
spec_antidiab_dpp4_v1              <- DrugSpec$new("antidiab_dpp4",              "DPP-4 Inhibitors",             version = "v1", defs = antidiab_defs$dpp4,              generic_names = antidiab_gnns$dpp4)
spec_antidiab_sglt2_v1             <- DrugSpec$new("antidiab_sglt2",             "SGLT-2 Inhibitors",            version = "v1", defs = antidiab_defs$sglt2,             generic_names = antidiab_gnns$sglt2)
spec_antidiab_glp1_v1              <- DrugSpec$new("antidiab_glp1",              "GLP-1 Receptor Agonists",      version = "v1", defs = antidiab_defs$glp1,              generic_names = antidiab_gnns$glp1)
spec_antidiab_insulin_v1           <- DrugSpec$new("antidiab_insulin",           "Insulin and Supplies",         version = "v1", defs = antidiab_defs$insulin,           generic_names = antidiab_gnns$insulin)
spec_antidiab_amylin_v1            <- DrugSpec$new("antidiab_amylin",            "Amylin Analogues",             version = "v1", defs = antidiab_defs$amylin,            generic_names = antidiab_gnns$amylin)

# Antidiabetic drugs composite ----

spec_antidiabetic <- CompositeDrugSpec$new(
  drug_class = "antidiabetic",
  label      = "Antidiabetic Medications",
  defs       = paste0(
    "All antidiabetic medication subclasses (v1): biguanides, sulfonylureas, ",
    "meglitinides, thiazolidinediones, alpha-glucosidase inhibitors, DPP-4 inhibitors, ",
    "SGLT-2 inhibitors, GLP-1 receptor agonists, insulin and supplies, amylin analogues."
  ),
  components = list(
    biguanide_v1         = spec_antidiab_biguanide_v1,
    sulfonylurea_v1      = spec_antidiab_sulfonylurea_v1,
    meglitinide_v1       = spec_antidiab_meglitinide_v1,
    tzd_v1               = spec_antidiab_tzd_v1,
    alpha_glucosidase_v1 = spec_antidiab_alpha_glucosidase_v1,
    dpp4_v1              = spec_antidiab_dpp4_v1,
    sglt2_v1             = spec_antidiab_sglt2_v1,
    glp1_v1              = spec_antidiab_glp1_v1,
    insulin_v1           = spec_antidiab_insulin_v1,
    amylin_v1            = spec_antidiab_amylin_v1
  )
)

## Save all public specs ----
# Only composite specs and standalone leaf specs are saved to data/.
# Component-only specs (leaf specs that are components of a composite) are
# embedded within the composite's .rda file and are NOT saved separately.
# This prevents them from appearing as accessible package datasets.

usethis::use_data(
  # Hypertension
  spec_htn_v1, spec_htn_v2,
  # Ischemic stroke (not included b/c its in stroke)
  # spec_isch_stroke_v1,
  # ASCVD composite
  spec_ascvd,
  # Heart failure
  spec_hf_v1,
  # Obesity
  spec_obesity_v1,
  # Depression
  spec_depression_v1, spec_depression_v2,
  # Diabetes
  spec_diabetes_v1, spec_diabetes_v2, spec_diabetes_v3,
  # CKD
  spec_ckd_v1,
  # Sleep apnea
  spec_osa_v1,
  # Obesity hypoventilation syndrome
  spec_ohs_v1,
  # Hyperlipidemia
  spec_hyperlipidemia_v1,
  # COPD
  spec_copd_v1,
  # Asthma
  spec_asthma_v1,
  # Antiobesity (non GLP-1)
  spec_antiobesity,
  # Antihypertensive composites
  spec_antihypertensive,
  # Antidiabetic composite
  spec_antidiabetic,
  # Antidepressive composite
  spec_antidepressive,
  overwrite = TRUE
)

