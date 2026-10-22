# Obesity -------------------------------------------------------------------
# Sourced by data-raw/build_specs.R; do not source on its own.
# Runs in its own environment: every object defined here is local to this
# file, and only `spec_*` objects are passed on to later files.

## Obesity ----

### history, version 1 ----
#
# ICD-10-CM diagnosis codes (any position), inpatient or outpatient. Same
# code set applies to both the condition and outcome definitions.
#
# E66.0, E66.01, E66.09, E66.2, E66.811, E66.812, E66.813, E66.89, E66.9,
# Z68.30-Z68.39, Z68.41-Z68.45
#
# Narrowed 2026-09-26 to a strict BMI >= 30 obesity definition: E66.1
# (drug-induced obesity), E66.3 (overweight, not obese), R93.9 (imaging
# inconclusive due to body fat, not an obesity diagnosis), and the
# BMI 25-29.9 codes (Z68.25-Z68.29 / V85.21-V85.25) were excluded.

obesity_icd10 <- c(
  "E660",
  "E6601",
  "E6609",
  # "E661", drug induced obesity
  "E662",
  # "E663", overweight (not obese)
  "E66811", # class 1
  "E66812", # class 2
  "E66813", # class 3
  "E6689",  # unspecified
  "E669",   # unspecified
  # "R939",not really obesity
  # these are for BMI 30 and above
  "Z6830",
  "Z6831",
  "Z6832",
  "Z6833",
  "Z6834",
  "Z6835",
  "Z6836",
  "Z6837",
  "Z6838",
  "Z6839",
  # BMI 40 and above
  "Z6841",
  "Z6842",
  "Z6843",
  "Z6844",
  "Z6845"
)

# ICD-9-CM diagnosis codes (short format, no periods), added 2026-09-24 for
# consistency with other conditions' dual ICD-9/ICD-10 code sets, then
# narrowed 2026-09-26 to the strict BMI >= 30 definition (see above):
# 278.02 (overweight) was excluded, as were the BMI 25-29.9 codes
# V85.21-V85.25. 278.03 (obesity hypoventilation syndrome) is kept for
# symmetry with E66.2 (morbid obesity with alveolar hypoventilation) on
# the ICD-10 side.
obesity_icd9 <- c(
  "27800", # Obesity, unspecified
  "27801", # Morbid obesity
  # "27802",  Overweight(not obese)
  "27803", # Obesity hypoventilation syndrome
  # "V8521", # Body Mass Index 25.0-25.9, adult
  # "V8522", # Body Mass Index 26.0-26.9, adult
  # "V8523", # Body Mass Index 27.0-27.9, adult
  # "V8524", # Body Mass Index 28.0-28.9, adult
  # "V8525", # Body Mass Index 29.0-29.9, adult
  "V8530", # Body Mass Index 30.0-30.9, adult
  "V8531", # Body Mass Index 31.0-31.9, adult
  "V8532", # Body Mass Index 32.0-32.9, adult
  "V8533", # Body Mass Index 33.0-33.9, adult
  "V8534", # Body Mass Index 34.0-34.9, adult
  "V8535", # Body Mass Index 35.0-35.9, adult
  "V8536", # Body Mass Index 36.0-36.9, adult
  "V8537", # Body Mass Index 37.0-37.9, adult
  "V8538", # Body Mass Index 38.0-38.9, adult
  "V8539", # Body Mass Index 39.0-39.9, adult
  "V8541", # Body Mass Index 40.0-44.9, adult
  "V8542", # Body Mass Index 45.0-49.9, adult
  "V8543", # Body Mass Index 50.0-59.9, adult
  "V8544", # Body Mass Index 60.0-69.9, adult
  "V8545"  # Body Mass Index 70 and over, adult
)

obesity_defs_shared <- c(
  "*" = paste0(
    "\u22651 inpatient or outpatient claim with an ICD-9 diagnosis of ",
    "{.strong 278.00}, {.strong 278.01}, {.strong 278.03}, ",
    "{.strong V85.30}\u2013{.strong V85.39}, or ",
    "{.strong V85.41}\u2013{.strong V85.45}, or an ",
    "ICD-10 diagnosis of {.strong E66.0}, {.strong E66.01}, ",
    "{.strong E66.09}, {.strong E66.2}, {.strong E66.811}, ",
    "{.strong E66.812}, {.strong E66.813}, {.strong E66.89}, ",
    "{.strong E66.9}, {.strong Z68.30}\u2013{.strong Z68.39}, or ",
    "{.strong Z68.41}\u2013{.strong Z68.45} in any diagnosis position ",
    "(BMI \u226530)."
  )
)


spec_obesity_v1 <- CodeSpec$new(
  condition = "obesity", version = "v1", label = "Obesity",
  defs  = list(condition = obesity_defs_shared, outcome = obesity_defs_shared),
  codes = list(
    dx_icd9  = make_key("dx_icd9", obesity_icd9),
    dx_icd10 = make_key("dx_icd10", obesity_icd10)
  )
)
