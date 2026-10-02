# Spot checks of the `definition` text stored in the built specs. These guard
# against a rebuild silently producing NA or misaligned definitions.

def_for <- function(result, code) {
  result$definition[result$code == code]
}

test_that("ICD-9-CM diagnosis definitions are populated", {
  htn <- get_hypertension_v1_codes(code_type = "dx_icd9")
  expect_equal(def_for(htn, "401"), "Essential hypertension")
  # Non-billable parents carry the 3-digit title as a prefix
  expect_equal(
    def_for(htn, "4030"),
    "Hypertensive chronic kidney disease: Malignant"
  )

  obesity <- get_obesity_v1_codes(code_type = "dx_icd9")
  expect_equal(def_for(obesity, "27801"), "Morbid obesity")

  chd <- get_chd_v1_codes(code_type = "dx_icd9")
  expect_match(def_for(chd, "41000"), "^Acute myocardial infarction")
})

test_that("ICD-10-CM diagnosis definitions are populated", {
  htn <- get_hypertension_v1_codes(code_type = "dx_icd10")
  expect_equal(def_for(htn, "I10"), "Essential (primary) hypertension")

  # Codes newer than the icd package's 2016 tables resolve via CMS FY2026
  obesity <- get_obesity_v1_codes(code_type = "dx_icd10")
  expect_equal(def_for(obesity, "E66811"), "Obesity, class 1")
})

test_that("ICD-9-CM and ICD-10-PCS procedure definitions are populated", {
  chd_icd9 <- get_chd_v1_codes(code_type = "proc_icd9")
  expect_equal(
    def_for(chd_icd9, "0066"),
    "Percutaneous transluminal coronary angioplasty [PTCA]"
  )

  chd_pcs <- get_chd_v1_codes(code_type = "proc_icd10")
  expect_match(def_for(chd_pcs, "0210083"), "^Bypass Coronary Artery")

  cerebro <- get_cerebrovasc_disease_v1_codes(code_type = "proc_icd10")
  expect_equal(
    def_for(cerebro, "03CH0ZZ"),
    "Extirpation of Matter from Right Common Carotid Artery, Open Approach"
  )
})

test_that("CPT and HCPCS definitions come from the manual lookup and NLM", {
  chd <- get_chd_v1_codes(code_type = "hcpcs")
  # Numeric CPT codes stored under the `hcpcs` key
  expect_equal(
    def_for(chd, "33510"),
    "Coronary artery bypass using a vein graft, 1 graft"
  )
  expect_match(def_for(chd, "92980"), "^Retired:")
  # Letter-prefixed HCPCS Level II code (NLM)
  expect_match(def_for(chd, "C9600"), "drug eluting intracoronary stent")

  cerebro <- get_cerebrovasc_disease_v1_codes(code_type = "cpt")
  expect_match(def_for(cerebro, "37215"), "distal embolic protection")
  expect_match(def_for(cerebro, "0076T"), "each additional vessel")
})

test_that("known-undefined codes stay NA rather than erroring", {
  chd <- get_chd_v1_codes(code_type = "hcpcs")
  # Retired HCPCS codes are not in the NLM table
  expect_true(all(is.na(chd$definition[chd$code %in% c("G0290", "G0291")])))
  # 33515 is not a valid CPT code and is not part of the spec
  expect_false("33515" %in% chd$code)
})

test_that("definitions stay aligned with codes after editing", {
  base <- get_obesity_v1_codes(code_type = "dx_icd10")
  keep <- "E66811"

  removed <- get_obesity_v1_codes(code_type = "dx_icd10") |>
    (\(x) x$code[x$code != keep][1])()
  spec <- remove_codes(spec_obesity_v1, dx_icd10 = removed)
  after <- spec$get_codes(code_type = "dx_icd10")
  expect_equal(def_for(after, keep), "Obesity, class 1")

  spec <- add_codes(spec_obesity_v1, dx_icd10 = "ZZZZZ")
  added <- spec$get_codes(code_type = "dx_icd10")
  expect_true(is.na(def_for(added, "ZZZZZ")))
  expect_equal(def_for(added, keep), "Obesity, class 1")
  expect_equal(nrow(added), nrow(base) + 1L)
})
