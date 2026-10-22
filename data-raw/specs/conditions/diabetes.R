# Diabetes (Type 1 and Type 2) ----------------------------------------------
# Sourced by data-raw/build_specs.R; do not source on its own.
# Runs in its own environment: every object defined here is local to this
# file, and only `spec_*` objects are passed on to later files.

## Diabetes ----

# Source: "Definition of conditions and medications_11262025.docx"
# Section: Diabetes, history, source versions 1-3 (not separately exported)
#
# The source document described three versions that differed only in
# required evidence, not in ICD code set (all three share the codes built
# below):
#   source v1: ICD codes only (diagnosis-based)
#   source v2: ICD codes OR antidiabetic medication (diagnosis + medication)
#   source v3: same evidence as v2, but sub-classified into four mutually
#       exclusive categories (no diabetes / diabetes without medication /
#       oral antidiabetic / insulin)
#
# All three were collapsed (2026-08-15, issue #4) into the single
# implemented spec_diabetes_v1 (below), which carries the most complete
# source-version-3 narrative, including the four-category classification
# note -- see its `defs$condition` field. "Version 1"/"version 2" in the
# comment blocks below refer only to the source-document drafts; there is
# no separately exported spec_diabetes_v2 or spec_diabetes_v3.
#
# Diabetes is a condition-only definition (outcome = FALSE for all codes).

### history, source version 1 ----

# Any of the following:
#
# Algorithm based on ICD-9 codes:
#
# (a)	At least 1 inpatient claim with a discharge ICD-9 diagnosis (any position)
# of 250.xx, 357.2, 362.0x, or 366.41.
#
# (b)	At least 2 carrier claims, carrier line or outpatient claims with ICD-9
# diagnoses (any position) of 250.xx, 357.2, 362.0x, or 366.41, linked by
# CLAIM_ID to an ambulatory physician claim (page 7),
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
### history, source version 2 ----
#
# Same as source version 1 above, plus:
#  (c)	At least 1 pharmacy claim for an oral antidiabetic drug fill or insulin.
#
# (Source version 3 adds no further codes -- it only sub-classifies patients
# meeting version 2's criteria into four categories; see the note on
# spec_diabetes_v1 below.)

# ICD-9 250.xx: the 5th digit encodes type — 1 or 3 = Type 1; 0 or 2 = Type 2
# (or unspecified). ICD-9 complication codes 357.2, 362.0x, and 366.41 do not
# specify diabetes type; placed in Type 2 per project convention (non-type-1
# codes default to Type 2).
# Reference only, not run: how the released codes were derived. The build
# reads them from data-raw/codesets/<condition>_<version>.csv instead.
# diab_250_all <- expand9("250")
# diab_icd9_t1 <- diab_250_all[
#   endsWith(diab_250_all, "1") | endsWith(diab_250_all, "3")
# ]
# diab_icd9_t2 <- unique(c(
#   diab_250_all[endsWith(diab_250_all, "0") | endsWith(diab_250_all, "2")],
#   "3572",        # polyneuropathy in diabetes (357.2) — type-unspecified → T2
#   expand9("3620"), # diabetic retinopathy (362.0x) — type-unspecified → T2
#   "36641"        # diabetic cataract (366.41) — type-unspecified → T2
# ))

# ICD-10 codes split by category:
#   E10.xx = Type 1 diabetes mellitus
#   E11.xx = Type 2 diabetes mellitus
#   E08.xx = DM due to underlying condition  \
#   E09.xx = Drug/chemical-induced DM         } not type-specific → T2 per convention
#   E13.xx = Other specified DM              /
#
# E10.3xx / E11.3xx (ophthalmic complications): expanded dynamically via
# children() to capture all billable laterality-specific retinopathy codes
# added in FY2020+ (e.g. E10.3211 = T1 mild nonproliferative DR with macular
# edema, right eye). Filtering to billable = TRUE excludes non-specific parent
# codes (e.g. E11.329) that have been superseded by the laterality expansion.
# Reference only, not run: how the released codes were derived. The build
# reads them from data-raw/codesets/<condition>_<version>.csv instead.
# diab_e10_ophthalmic <- {
#   codes <- unname(unclass(children(as.icd10cm("E103"), defined = TRUE)))
#   codes[is_billable(as.icd10cm(codes))]
# }
# diab_e11_ophthalmic <- {
#   codes <- unname(unclass(children(as.icd10cm("E113"), defined = TRUE)))
#   codes[is_billable(as.icd10cm(codes))]
# }

# diab_icd10_t1 <- c(
#   # E10.1: ketoacidosis
#   "E1010", "E1011",
#   # E10.2: kidney complications
#   "E1021", "E1022",  # diabetic nephropathy / CKD — added 2026-09-12 (absent from source doc)
#   "E1029",
#   # E10.3: ophthalmic complications — all billable, dynamically expanded
#   diab_e10_ophthalmic,
#   # E10.4: neurological complications
#   "E1040",
#   "E1041", "E1043", "E1044", "E1049",  # neuropathy subtypes — added 2026-09-12
#   "E1042",
#   # E10.5: circulatory complications
#   "E1051",
#   "E1052", "E1059",  # angiopathy with gangrene / other — added 2026-09-12
#   # E10.6: other specified complications
#   "E10610",  # neuropathic arthropathy — added 2026-09-12
#   "E10618", "E10620", "E10621", "E10622", "E10628",
#   "E10630", "E10638", "E10641", "E10649",
#   "E1065", "E1069",
#   # E10.8 / E10.9
#   "E108", "E109"
# )

# diab_icd10_t2 <- c(
#   # E08: DM due to underlying condition (not type-specific → T2)
#   "E0836", "E0842",
#   # E09: drug/chemical-induced DM (not type-specific → T2)
#   "E0936", "E0942",
#   # E11: Type 2 diabetes mellitus
#   # E11.0: hyperosmolarity
#   "E1100", "E1101",
#   # E11.1: ketoacidosis
#   "E1110", "E1111",
#   # E11.2: kidney complications
#   "E1121", "E1122",  # diabetic nephropathy / CKD — added 2026-09-12
#   "E1129",
#   # E11.3: ophthalmic complications — all billable, dynamically expanded
#   # (also fixes pre-existing asymmetry: E11.37X1/X3/X9 were absent while
#   # E10.37X1/X3/X9 were present; and removes non-billable E11.329/339/349/359)
#   diab_e11_ophthalmic,
#   # E11.4: neurological complications
#   "E1140",
#   "E1141", "E1143", "E1144", "E1149",  # neuropathy subtypes — added 2026-09-12
#   "E1142",
#   # E11.5: circulatory complications
#   "E1151",
#   "E1152", "E1159",  # angiopathy with gangrene / other — added 2026-09-12
#   # E11.6: other specified complications
#   "E11610",  # neuropathic arthropathy — added 2026-09-12
#   "E11618", "E11620", "E11621", "E11622", "E11628",
#   "E11630", "E11638", "E11641", "E11649",
#   "E1165", "E1169",
#   # E11.8 / E11.9
#   "E118", "E119",
#   # E13: other specified DM (not type-specific → T2)
#   "E1310", "E1336", "E1342"
# )

# diab_type1_codes <- list(
#   dx_icd9  = make_key_condition_only("dx_icd9", diab_icd9_t1),
#   dx_icd10 = make_key_condition_only("dx_icd10", diab_icd10_t1)
# )
# diab_type2_codes <- list(
#   dx_icd9  = make_key_condition_only("dx_icd9", diab_icd9_t2),
#   dx_icd10 = make_key_condition_only("dx_icd10", diab_icd10_t2)
# )

# (2026-09-12) Split from the former unified spec_diabetes_v1 into separate
# Type 1 and Type 2 specs. The algorithmic criteria (inpatient/outpatient
# claim counts, 7-day gap) are identical; only the code sets
# and medication alternative criterion differ.

spec_diabetes_type1_v1 <- CodeSpec$new(
  condition = "diabetes_type1",
  version = "v1",
  label = "Type 1 Diabetes Mellitus",
  defs  = list(
    condition = c(
      "i" = "Any of the following:",
      "*" = paste0(
        "\u22651 inpatient claim with a discharge ICD-9 Type 1 diabetes diagnosis ",
        "({.strong 250.x1}, {.strong 250.x3}) or an ICD-10 Type 1 diagnosis (E10.xx) ",
        "in any discharge position."
      ),
      "*" = paste0(
        "\u22652 carrier/outpatient claims with the same ICD codes in any position, ",
        "occurring at least 7 days apart."
      ),
      "*" = "\u22651 pharmacy claim for insulin or an amylin analogue (see {.strong spec_diabetes_type1})."
    ),
    outcome = NULL
  ),
  codes = read_codeset("diabetes_type1_v1")
)

spec_diabetes_type2_v1 <- CodeSpec$new(
  condition = "diabetes_type2",
  version = "v1",
  label = "Type 2 Diabetes Mellitus",
  defs  = list(
    condition = c(
      "i" = "Any of the following:",
      "*" = paste0(
        "\u22651 inpatient claim with a discharge ICD-9 Type 2/unspecified diabetes diagnosis ",
        "({.strong 250.x0}, {.strong 250.x2}, {.strong 357.2}, {.strong 362.0x}, {.strong 366.41}) ",
        "or an ICD-10 Type 2 or unspecified diagnosis (E11.xx, E08.xx, E09.xx, E13.xx) ",
        "in any discharge position."
      ),
      "*" = paste0(
        "\u22652 carrier/outpatient claims with the same ICD codes in any position, ",
        "occurring at least 7 days apart."
      ),
      "*" = "\u22651 pharmacy claim for an oral antidiabetic drug or insulin (see {.strong spec_diabetes_type2}).",
      "i" = paste0(
        "Patients are then classified into four mutually exclusive categories: ",
        "no diabetes; diabetes without antidiabetic medication; ",
        "diabetes with oral antidiabetic (non-insulin); diabetes with insulin."
      )
    ),
    outcome = NULL
  ),
  codes = read_codeset("diabetes_type2_v1")
)
