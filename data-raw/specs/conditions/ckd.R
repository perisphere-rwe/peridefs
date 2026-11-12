# Chronic kidney disease ----------------------------------------------------
# Sourced by data-raw/build_specs.R; do not source on its own.
# Runs in its own environment: every object defined here is local to this
# file, and only `spec_*` objects are passed on to later files.

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
#  (b)	≥1 outpatient physician visit (page 7) with a diagnosis code
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
#  (b)	≥1 outpatient physician visit (page 7) with a diagnosis code
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


# Reference only, not run: how the released codes were derived. The build
# reads them from data-raw/codesets/<condition>_<version>.csv instead.
# ckd_icd9 <- unique(
#   c(
#     expand9("0160"),
#     "0954",
#     "1890",
#     "1899",
#     "2230",
#     "23691",
#     expand9("2504"),
#     # diabetic nephropathy
#     "2714",
#     expand9("2741"),
#     # gouty nephropathy
#     "28311",
#     Filter(\(x) endsWith(x, "0"), expand9("403")),
#     # 403.x0
#     Filter(\(x) endsWith(x, "1"), expand9("403")),
#     # 403.x1
#     Filter(\(x) endsWith(x, "0"), expand9("404")),
#     # 404.x0
#     Filter(\(x) endsWith(x, "1"), expand9("404")),
#     # 404.x1
#     Filter(\(x) endsWith(x, "2"), expand9("404")),
#     # 404.x2
#     Filter(\(x) endsWith(x, "3"), expand9("404")),
#     # 404.x3
#     "4401",
#     "4421",
#     "4473",
#     "5724",
#     range9("580", "588"),
#     # 580.xx–588.xx
#     "591",
#     expand9("6421"),
#     expand9("6462"),
#     range9("75312", "75317"),
#     "75319",
#     expand9("7532"),
#     "7944"
#   )
# )


# ICD-10 codes hardcoded from the Perisphere definitions document.
# Reference only, not run: how the released codes were derived. The build
# reads them from data-raw/codesets/<condition>_<version>.csv instead.
# ckd_icd10 <- c(
#   "A1811",   # tuberculosis of kidney
#   "A5275",
#   "C649",
#   "C689",
#   "D3000",
#   "D4100",
#   "D4120",
#   "D593",
#   "E1021",   # type 1 DM with diabetic nephropathy
#   "E1029",
#   "E1121",   # type 2 DM with diabetic nephropathy
#   "E1129",
#   "E748",
#   "I120",
#   "I129",
#   "I130",
#   "I1310",
#   "I1311",
#   "I132",
#   "I701",
#   "I722",
#   "K767",
#   "M1030",
#   "N003",
#   "N008",
#   "N009",
#   "N013",
#   "N022",
#   "N032",
#   "N033",
#   "N035",
#   "N038",
#   "N039",
#   "N040",
#   "N043",
#   "N044",
#   "N048",
#   "N049",
#   "N052",
#   "N055",
#   "N058",
#   "N059",
#   "N08",
#   "N1330",
#   "N170",
#   "N171",
#   "N172",
#   "N178",
#   "N179",
#   "N181",
#   "N182",
#   "N183",
#   "N184",
#   "N185",
#   "N186",
#   "N189",
#   "N19",
#   "N250",
#   "N251",
#   "N2581",
#   "N2589",
#   "N259",
#   "N269",
#   "Q6102",
#   "Q6119",
#   "Q612",
#   "Q613",
#   "Q614",
#   "Q615",
#   "Q618",
#   "Q6210",
#   "Q6211",
#   "Q6212",
#   "Q6231",
#   "Q6239",
#   "R944"
# )

ckd_defs_condition <- c(
  "i" = "Any of the following:",
  "*" = paste0(
    "\u22651 inpatient claim with a discharge ICD-9 or ICD-10 diagnosis code for ",
    "chronic kidney disease in any discharge diagnosis position."
  ),
  "*" = paste0(
    "\u22651 outpatient physician visit with an ICD-9 or ICD-10 CKD diagnosis code ",
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
  codes = read_codeset("ckd_v1")
)
