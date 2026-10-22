# Depression ----------------------------------------------------------------
# Sourced by data-raw/build_specs.R; do not source on its own.
# Runs in its own environment: every object defined here is local to this
# file, and only `spec_*` objects are passed on to later files.

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
# (b) At least 1 outpatient physician claim (page 7)
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
# (b) At least 1 outpatient physician claim (page 7)
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
  dx_icd9  = make_key_condition_only("dx_icd9", depress_icd9),
  dx_icd10 = make_key_condition_only("dx_icd10", depress_icd10)
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
    "\u22651 outpatient physician claim with ",
    "the same ICD codes in any diagnosis position."
  )
)

# Collapsed to a single version (2026-08-15, issue #4): v1/v2 shared
# identical codes and differed only in the condition definition narrative
# (v2 added the medication criterion). Now there's a single version
# carrying the more complete (formerly v2) narrative.
spec_depression_v1 <- CodeSpec$new(
  condition = "depression",
  version   = "v1",
  label     = "Depression",
  defs = list(
    condition = c(
      depress_defs_base,
      "*" = paste0(
        "\u22652 pharmacy claims for a depression medication ",
        "(see {.strong spec_depression}); 2 different GNNs on the same day are permitted."
      )
    ),
    outcome = NULL
  ),
  codes = depress_codes
)
