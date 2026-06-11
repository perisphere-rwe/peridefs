

# These specs can be ignored for now.
# We will incorporate them as needed by projects we work on.

# Remaining specs, not used yet
# spec_hcpcs_ambul,
# spec_hcpcs_em,
# spec_cardiologist_care,
# spec_geriatrics_visit,
# spec_nephrology_visit,
# spec_neurologist_care,
# spec_pulmonary_visit,
# spec_primary_care_visit,
# spec_dialysis,
# spec_frailty,
# spec_non_cvd_readmission,
# spec_non_hf_cvd_readmission,
# spec_very_high_risk_ascvd,
# spec_hypotension,
# spec_icu_stay,
# spec_lipid_panel,
# spec_lab_bun,
# spec_lab_creatinine,
# spec_lab_glucose,
# spec_lab_hba1c,
# spec_lab_bnp,
# spec_lab_potassium,
# spec_lab_sodium,
# spec_lab_troponin,
# spec_lab_egfr,
# spec_lab_bmp,
# spec_liver_disease,
# spec_lead_pad,
# spec_non_statin_lipid,
# spec_nursing_home_history,
# spec_observation_stay,
# spec_old_mi,
# spec_iv_inotropes,
# spec_pad_symptomatic,
# spec_pcsk9,
# spec_pci,
# spec_platelet_inhibitors,
# spec_ras_extra,
# spec_ras,
# spec_racs,
# spec_smoking,
# spec_diuretics_thiazide_like,
# spec_diuretics_thiazide_type,
# spec_ed_visit,
# spec_ezetimibe,
# spec_fall_injury,
# spec_familial_hypercholesterolemia,
# spec_hiv,
# spec_hiv_meds,
# spec_hormone_therapy,
# spec_hyperkalemia,
# spec_cabg,
# spec_cancer,
# spec_cardiac_rehab,
# spec_cr,
# spec_debility,
# spec_dementia,
# spec_depression,
# spec_digoxin,
# spec_ami,
# spec_aki,
# spec_anemia,
# spec_af,
# spec_antiarrhythmic,
# spec_beta_cardio_nonselect

#### Ischemic stroke ----

isch_stroke_icd9 <- c(expand9("433"), expand9("434")) %>%
  enframe()  %>%
  filter(str_detect(value, "1$")) %>%
  pull(value)

isch_stroke_icd10 <- expand10("I63")

spec_isch_stroke_v1 <- CodeSpec$new(
  condition = "isch_stroke",
  version = "v1",
  label = "Ischemic Stroke",
  defs = list(
    condition = c(
      "*" = paste0(
        "\u22651 overnight inpatient claim with an ICD-9 discharge diagnosis of ",
        "{.code 433.x1} or {.code 434.x1}, or an ICD-10 discharge diagnosis of ",
        "{.code I63.xx} in the primary discharge diagnosis position."
      )
    ),
    outcome = NULL
  ),
  codes = list(
    dx_icd9  = make_key(isch_stroke_icd9,  c("433.x1", "434.x1")),
    dx_icd10 = make_key(isch_stroke_icd10, c("I63.xx"))
  )
)

### HCPCS code lists: used by multiple ambulatory visit specs ----
hcpcs_ambul_codes <- unique(
  c(
    hcpcs_range("99201", "99215"),
    hcpcs_range("99241", "99245"),
    hcpcs_range("99271", "99275"),
    hcpcs_range("99301", "99337"),
    hcpcs_range("99339", "99360"),
    hcpcs_range("99381", "99387"),
    hcpcs_range("99391", "99404"),
    hcpcs_range("99411", "99412"),
    hcpcs_range("99420", "99429"),
    hcpcs_range("99455", "99456"),
    "99024",
    "99058",
    "99450",
    "99499"
  )
)
hcpcs_em_codes <- unique(
  c(
    hcpcs_range("99201", "99215"),
    hcpcs_range("99241", "99245"),
    hcpcs_range("99271", "99275"),
    hcpcs_range("99301", "99337"),
    hcpcs_range("99381", "99387"),
    hcpcs_range("99391", "99404"),
    hcpcs_range("99420", "99429"),
    hcpcs_range("99455", "99456"),
    hcpcs_range("99281", "99285"),
    "99024",
    "99058",
    "99450",
    "99499"
  )
)

# spec_hcpcs_ambul: HCPCS codes for ambulatory care utilization ----
spec_hcpcs_ambul <- CodeSpec$new(condition = "hcpcs_ambul",
                                 label = "HCPCS Codes for Ambulatory Care Utilization",
                                 versions = list(v1 = list(
                                   defs = list(
                                     condition = paste0(
                                       "HCPCS codes identifying ambulatory care visits: 99201-99215, 99241-99245, ",
                                       "99271-99275, 99301-99337, 99339-99360, 99381-99387, 99391-99404, ",
                                       "99411-99412, 99420-99429, 99455-99456, 99024, 99058, 99450, 99499. ",
                                       "To identify a specialty-specific visit (e.g., cardiology), filter claims ",
                                       "with these codes to the relevant Medicare specialty code (e.g., '06' for cardiologist)."
                                     ),
                                     outcome = NULL
                                   ),
                                   codes = list(
                                     hcpcs = make_key(
                                       hcpcs_ambul_codes,
                                       hcpcs_ambul_codes,
                                       condition = rep(TRUE, length(hcpcs_ambul_codes)),
                                       outcome = rep(FALSE, length(hcpcs_ambul_codes))
                                     )
                                   )
                                 )))

# spec_hcpcs_em: HCPCS codes for ambulatory E&M linked diagnoses ----
spec_hcpcs_em <- CodeSpec$new(condition = "hcpcs_em",
                              label = "HCPCS Codes for Ambulatory E&M Linked Diagnoses",
                              versions = list(v1 = list(
                                defs = list(
                                  condition = paste0(
                                    "HCPCS codes for ambulatory E&M claims that can be linked to diagnosis codes: ",
                                    "99201-99215, 99241-99245, 99271-99275, 99281-99285, 99301-99337, ",
                                    "99381-99387, 99391-99404, 99420-99429, 99455-99456, 99024, 99058, 99450, 99499."
                                  ),
                                  outcome = NULL
                                ),
                                codes = list(
                                  hcpcs = make_key(
                                    hcpcs_em_codes,
                                    hcpcs_em_codes,
                                    condition = rep(TRUE, length(hcpcs_em_codes)),
                                    outcome = rep(FALSE, length(hcpcs_em_codes))
                                  )
                                )
                              )))

# ---------------------------------------------------------------------------
# Specialty ambulatory visit specs (30, 65, 85, 86, 99, 100)
# Each uses the E&M HCPCS codes filtered to a specific physician specialty code.
# ---------------------------------------------------------------------------
make_specialty_spec <- function(cond, label, spec_code, spec_desc) {
  CodeSpec$new(
    condition = cond,
    label = label,
    versions = list(v1 = list(
      defs = list(
        condition = paste0(
          "Ambulatory physician E&M claim (see spec_hcpcs_em for HCPCS code list) ",
          "with Medicare physician specialty code ",
          spec_code,
          " (",
          spec_desc,
          "). ",
          "MarketScan equivalent: STDPROV values for the same specialty."
        ),
        outcome = NULL
      ),
      codes = list(
        hcpcs = make_key(
          hcpcs_em_codes,
          hcpcs_em_codes,
          condition = rep(TRUE, length(hcpcs_em_codes)),
          outcome = rep(FALSE, length(hcpcs_em_codes))
        )
      )
    ))
  )
}

spec_cardiologist_care  <- make_specialty_spec("cardiologist_care", "Cardiologist Care", "06", "cardiologist")
spec_geriatrics_visit   <- make_specialty_spec("geriatrics_visit",
                                               "Geriatrics Ambulatory Visit",
                                               "38",
                                               "geriatric medicine")
spec_nephrology_visit   <- make_specialty_spec("nephrology_visit",
                                               "Nephrology Ambulatory Visit",
                                               "39",
                                               "nephrology")
spec_neurologist_care   <- make_specialty_spec("neurologist_care", "Neurologist Care", "13", "neurology")
spec_pulmonary_visit    <- make_specialty_spec("pulmonary_visit",
                                               "Pulmonary Ambulatory Visit",
                                               "29",
                                               "pulmonary disease")
spec_primary_care_visit <- make_specialty_spec(
  "primary_care_visit",
  "Primary Care Ambulatory Visit",
  "01/08/11",
  "general practice (01), family practice (08), internal medicine (11)"
)

# spec_dialysis: Dialysis ----
spec_dialysis <- CodeSpec$new(condition = "dialysis",
                              label = "Dialysis",
                              versions = list(v1 = list(
                                defs = list(
                                  condition = paste0(
                                    "Carrier or DME claims with BETOS_CD beginning with 'P9' (dialysis procedure codes). ",
                                    "BETOS (Berenson-Eggers Type of Service) codes are not standard ICD or HCPCS codes; ",
                                    "they are CMS-assigned classification codes on carrier/DME claims. ",
                                    "BETOS P9.x codes cover hemodialysis, peritoneal dialysis, and related services."
                                  ),
                                  outcome = NULL
                                ),
                                codes = list()  # BETOS codes cannot be stored as standard ICD/HCPCS
                              )))

# spec_frailty: Frailty Score ----
# The Kim et al. frailty score uses a weighted sum of ICD codes and HCPCS codes.
# The code ranges are in the document's table 1 (ICD-9) and table 2 (ICD-10).
# The full score requires coefficient weights; here we store only the narrative.
spec_frailty <- CodeSpec$new(condition = "frailty",
                             label = "Frailty",
                             versions = list(v1 = list(
                               defs = list(
                                 condition = paste0(
                                   "Frailty score per Kim et al. (Kim DH, Schneeweiss S, Glynn RJ, Lipsitz LA, ",
                                   "Rockwood K, Avorn J. Measuring Frailty in Medicare Data. J Am Geriatr Soc. ",
                                   "2018;66(6):1180-1186). Total frailty score = ICD-9 frailty score × ",
                                   "(ICD-9 days / total days) + ICD-10 frailty score × (ICD-10 days / total days). ",
                                   "Uses inpatient, outpatient, carrier, DME, SNF, HHA, and hospice claims with ",
                                   "diagnosis codes and HCPCS codes. Coefficient tables for ICD-9 and ICD-10 ",
                                   "codes are in the source document (Tables 1 and 2). The full implementation ",
                                   "requires the coefficient tables; this spec provides only the narrative."
                                 ),
                                 outcome = NULL
                               ),
                               codes = list()  # Requires coefficient table — not representable as a simple code list
                             )))

# spec_non_cvd_readmission: Non-CVD Readmission ----
# Any inpatient claim EXCEPT primary discharge diagnosis ICD-9 390-459 or ICD-10 I00-I99.
# We store the cardiovascular EXCLUSION codes and note the non-CVD definition in defs.
cvd_readm_icd9  <- range9("390", "459")
cvd_readm_icd10 <- range10("I00", "I99")

spec_non_cvd_readmission <- CodeSpec$new(condition = "non_cvd_readmission",
                                         label = "Non-CVD Readmission",
                                         versions = list(v1 = list(
                                           defs = list(
                                             condition = paste0(
                                               "Any inpatient claim where the primary discharge diagnosis code is NOT in ",
                                               "ICD-9 range 390-459 (cardiovascular) or ICD-10 range I00-I99 (cardiovascular). ",
                                               "The code sets stored here are the CARDIOVASCULAR codes to EXCLUDE; ",
                                               "non-CVD readmission = inpatient claims NOT matching these codes."
                                             ),
                                             outcome = paste0(
                                               "Same exclusion logic — non-CVD readmission as an outcome endpoint."
                                             )
                                           ),
                                           codes = list(
                                             dx_icd9  = make_key(
                                               cvd_readm_icd9,
                                               c("390-459 (cardiovascular — to exclude)"),
                                               condition = rep(FALSE, length(cvd_readm_icd9)),
                                               outcome = rep(FALSE, length(cvd_readm_icd9))
                                             ),
                                             dx_icd10 = make_key(
                                               cvd_readm_icd10,
                                               c("I00-I99 (cardiovascular — to exclude)"),
                                               condition = rep(FALSE, length(cvd_readm_icd10)),
                                               outcome = rep(FALSE, length(cvd_readm_icd10))
                                             )
                                           )
                                         )))

# spec_non_hf_cvd_readmission: Non-HF CVD Readmission ----
# Inpatient claims with primary diagnosis in ICD-9 390-459 or ICD-10 I00-I99
# EXCEPT heart failure codes (from spec_hf).
spec_non_hf_cvd_readmission <- CodeSpec$new(condition = "non_hf_cvd_readmission",
                                            label = "Non-HF CVD Readmission",
                                            versions = list(v1 = list(
                                              defs = list(
                                                condition = paste0(
                                                  "Inpatient claims with primary discharge diagnosis in ICD-9 range 390-459 or ",
                                                  "ICD-10 range I00-I99 (cardiovascular), EXCLUDING heart failure codes ",
                                                  "(see spec_hf for the HF code set to exclude)."
                                                ),
                                                outcome = paste0("Same definition — non-HF CVD readmission as an outcome endpoint.")
                                              ),
                                              codes = list(
                                                dx_icd9  = make_key(
                                                  cvd_readm_icd9,
                                                  c("390-459 (CVD, excl. HF)"),
                                                  condition = rep(TRUE, length(cvd_readm_icd9)),
                                                  outcome = rep(TRUE, length(cvd_readm_icd9))
                                                ),
                                                dx_icd10 = make_key(
                                                  cvd_readm_icd10,
                                                  c("I00-I99 (CVD, excl. HF)"),
                                                  condition = rep(TRUE, length(cvd_readm_icd10)),
                                                  outcome = rep(TRUE, length(cvd_readm_icd10))
                                                )
                                              )
                                            )))

### TOC ITEMS 76-115 ----

# spec_hypotension: Hypotension ----
hypo_icd9  <- c("4580", "4588", "4589")
hypo_icd10 <- c("I951", "I9589", "I959")  # I958.9 in doc is typo for I95.89

spec_hypotension <- CodeSpec$new(condition = "hypotension",
                                 label = "Hypotension",
                                 versions = list(v1 = list(
                                   defs = list(
                                     condition = paste0(
                                       "\u22651 inpatient claim or \u22651 outpatient E&M claim with an ICD-9 diagnosis ",
                                       "of 458.0, 458.8, or 458.9, or an ICD-10 diagnosis of I95.1, I95.89, or ",
                                       "I95.9 in any diagnosis position."
                                     ),
                                     outcome = NULL
                                   ),
                                   codes = list(
                                     dx_icd9  = make_key(
                                       hypo_icd9,
                                       c("458.0", "458.8", "458.9"),
                                       condition = rep(TRUE, 3L),
                                       outcome = rep(FALSE, 3L)
                                     ),
                                     dx_icd10 = make_key(
                                       hypo_icd10,
                                       c("I95.1", "I95.89", "I95.9"),
                                       condition = rep(TRUE, 3L),
                                       outcome = rep(FALSE, 3L)
                                     )
                                   )
                                 )))

# spec_icu_stay: Intensive Care Unit Stay ----
icu_rev <- c("0200",
             "0201",
             "0202",
             "0203",
             "0204",
             "0206",
             "0207",
             "0208",
             "0209")

spec_icu_stay <- CodeSpec$new(condition = "icu_stay",
                              label = "Intensive Care Stay During Hospitalization",
                              versions = list(v1 = list(
                                defs = list(condition = "Inpatient claim with a revenue center code of 0200-0204, 0206-0209.", outcome = NULL),
                                codes = list(rev = make_key(
                                  icu_rev,
                                  icu_rev,
                                  condition = rep(TRUE, length(icu_rev)),
                                  outcome = rep(FALSE, length(icu_rev))
                                ))
                              )))

# ---------------------------------------------------------------------------
### Individual laboratory test specs ----

bun_cpt <- c("84520",
             "84525",
             "84545",
             "80047",
             "80048",
             "80050",
             "80053",
             "80069")
spec_lab_bun <- CodeSpec$new(condition = "lab_bun",
                             label = "Blood Urea Nitrogen (BUN)",
                             versions = list(v1 = list(
                               defs = list(condition = "CPT codes for blood urea nitrogen (BUN): 84520, 84525, 84545, and metabolic panel codes 80047, 80048, 80050, 80053, 80069.", outcome = NULL),
                               codes = list(cpt = make_key(
                                 bun_cpt,
                                 bun_cpt,
                                 condition = rep(TRUE, length(bun_cpt)),
                                 outcome = rep(FALSE, length(bun_cpt))
                               ))
                             )))

creatinine_cpt <- c("82565",
                    "82570",
                    "82575",
                    "80047",
                    "80048",
                    "80050",
                    "80053",
                    "80069")
spec_lab_creatinine <- CodeSpec$new(condition = "lab_creatinine",
                                    label = "Creatinine",
                                    versions = list(v1 = list(
                                      defs = list(condition = "CPT codes for serum creatinine: 82565, 82570, 82575, and metabolic panel codes 80047, 80048, 80050, 80053, 80069.", outcome = NULL),
                                      codes = list(
                                        cpt = make_key(
                                          creatinine_cpt,
                                          creatinine_cpt,
                                          condition = rep(TRUE, length(creatinine_cpt)),
                                          outcome = rep(FALSE, length(creatinine_cpt))
                                        )
                                      )
                                    )))

glucose_cpt <- c("82947", "82948", "80047", "80048", "80050", "80053", "80069")
spec_lab_glucose <- CodeSpec$new(condition = "lab_glucose",
                                 label = "Glucose",
                                 versions = list(v1 = list(
                                   defs = list(condition = "CPT codes for blood glucose: 82947, 82948, and metabolic panel codes 80047, 80048, 80050, 80053, 80069.", outcome = NULL),
                                   codes = list(cpt = make_key(
                                     glucose_cpt,
                                     glucose_cpt,
                                     condition = rep(TRUE, length(glucose_cpt)),
                                     outcome = rep(FALSE, length(glucose_cpt))
                                   ))
                                 )))

hba1c_cpt <- c("83036")
spec_lab_hba1c <- CodeSpec$new(condition = "lab_hba1c",
                               label = "Hemoglobin A1C",
                               versions = list(v1 = list(
                                 defs = list(condition = "CPT code for hemoglobin A1C (HbA1c): 83036.", outcome = NULL),
                                 codes = list(cpt = make_key(
                                   hba1c_cpt,
                                   hba1c_cpt,
                                   condition = rep(TRUE, length(hba1c_cpt)),
                                   outcome = rep(FALSE, length(hba1c_cpt))
                                 ))
                               )))

bnp_cpt <- c("83880")
spec_lab_bnp <- CodeSpec$new(condition = "lab_bnp",
                             label = "NT-proBNP and BNP",
                             versions = list(v1 = list(
                               defs = list(condition = "CPT code for natriuretic peptides (NT-proBNP and BNP): 83880.", outcome = NULL),
                               codes = list(cpt = make_key(
                                 bnp_cpt,
                                 bnp_cpt,
                                 condition = rep(TRUE, length(bnp_cpt)),
                                 outcome = rep(FALSE, length(bnp_cpt))
                               ))
                             )))

potassium_cpt <- c("84132", "80047", "80048", "80050", "80051", "80053", "80069")
spec_lab_potassium <- CodeSpec$new(condition = "lab_potassium",
                                   label = "Potassium",
                                   versions = list(v1 = list(
                                     defs = list(condition = "CPT codes for serum potassium: 84132, and electrolyte/metabolic panel codes 80047, 80048, 80050, 80051, 80053, 80069.", outcome = NULL),
                                     codes = list(
                                       cpt = make_key(
                                         potassium_cpt,
                                         potassium_cpt,
                                         condition = rep(TRUE, length(potassium_cpt)),
                                         outcome = rep(FALSE, length(potassium_cpt))
                                       )
                                     )
                                   )))

sodium_cpt <- c("84295", "80047", "80048", "80050", "80051", "80053", "80069")
spec_lab_sodium <- CodeSpec$new(condition = "lab_sodium",
                                label = "Sodium",
                                versions = list(v1 = list(
                                  defs = list(condition = "CPT codes for serum sodium: 84295, and electrolyte/metabolic panel codes 80047, 80048, 80050, 80051, 80053, 80069.", outcome = NULL),
                                  codes = list(cpt = make_key(
                                    sodium_cpt,
                                    sodium_cpt,
                                    condition = rep(TRUE, length(sodium_cpt)),
                                    outcome = rep(FALSE, length(sodium_cpt))
                                  ))
                                )))

troponin_cpt <- c("84512", "84484")
spec_lab_troponin <- CodeSpec$new(condition = "lab_troponin",
                                  label = "Troponin I and T",
                                  versions = list(v1 = list(
                                    defs = list(condition = "CPT codes for cardiac troponin: troponin I (84512) and troponin T (84484).", outcome = NULL),
                                    codes = list(
                                      cpt = make_key(
                                        troponin_cpt,
                                        troponin_cpt,
                                        condition = rep(TRUE, length(troponin_cpt)),
                                        outcome = rep(FALSE, length(troponin_cpt))
                                      )
                                    )
                                  )))

egfr_cpt <- c("82565")
spec_lab_egfr <- CodeSpec$new(condition = "lab_egfr",
                              label = "eGFR",
                              versions = list(v1 = list(
                                defs = list(condition = "CPT code for estimated glomerular filtration rate (eGFR), derived from serum creatinine: 82565.", outcome = NULL),
                                codes = list(cpt = make_key(
                                  egfr_cpt,
                                  egfr_cpt,
                                  condition = rep(TRUE, length(egfr_cpt)),
                                  outcome = rep(FALSE, length(egfr_cpt))
                                ))
                              )))

bmp_cpt <- c("80047", "80048", "80050", "80053", "80069")
spec_lab_bmp <- CodeSpec$new(condition = "lab_bmp",
                             label = "Basic Metabolic Panel",
                             versions = list(v1 = list(
                               defs = list(condition = "CPT codes for basic metabolic panel (BMP): 80047, 80048, 80050, 80053, 80069.", outcome = NULL),
                               codes = list(cpt = make_key(
                                 bmp_cpt,
                                 bmp_cpt,
                                 condition = rep(TRUE, length(bmp_cpt)),
                                 outcome = rep(FALSE, length(bmp_cpt))
                               ))
                             )))

# spec_lipid_panel: Lipid Panel Test ----
lipid_hcpcs <- c("80061",
                 "82465",
                 "83721",
                 "83718",
                 "84478",
                 "83695",
                 "83700",
                 "83704")

spec_lipid_panel <- CodeSpec$new(condition = "lipid_panel",
                                 label = "Lipid Panel Test",
                                 versions = list(v1 = list(
                                   defs = list(condition = "HCPCS code for total cholesterol, LDL, or lipid panel: 80061, 82465, 83721, 83718, 84478, 83695, 83700, or 83704.", outcome = NULL),
                                   codes = list(
                                     hcpcs = make_key(
                                       lipid_hcpcs,
                                       lipid_hcpcs,
                                       condition = rep(TRUE, length(lipid_hcpcs)),
                                       outcome = rep(FALSE, length(lipid_hcpcs))
                                     )
                                   )
                                 )))

# spec_liver_disease: Liver Disease, history ----
liver_icd9 <- unique(
  c(
    "07022",
    "07023",
    "07032",
    "07033",
    "07044",
    "07054",
    "0706",
    "0709",
    expand9("4560"),
    expand9("4561"),
    expand9("4562"),
    expand9("570"),
    expand9("571"),
    expand9("5722"),
    expand9("5723"),
    expand9("5724"),
    expand9("5725"),
    expand9("5726"),
    expand9("5727"),
    expand9("5728"),
    "5733",
    "5734",
    "5738",
    "5739",
    "V427"
  )
)
liver_icd10 <- unique(
  c(
    expand10("B18"),
    expand10("I85"),
    "I864",
    "I982",
    expand10("K70"),
    expand10("K711"),
    expand10("K713"),
    expand10("K714"),
    expand10("K715"),
    "K717",
    expand10("K72"),
    expand10("K73"),
    expand10("K74"),
    "K760",
    expand10("K762"),
    expand10("K763"),
    expand10("K764"),
    expand10("K765"),
    expand10("K766"),
    expand10("K767"),
    expand10("K768"),
    expand10("K769"),
    "Z944"
  )
)

spec_liver_disease <- CodeSpec$new(condition = "liver_disease",
                                   label = "Liver Disease",
                                   versions = list(v1 = list(
                                     defs = list(
                                       condition = paste0(
                                         "\u22651 inpatient OR \u22652 outpatient E&M claims with ICD-9 diagnoses of ",
                                         "070.22/23/32/33/44/54, 070.6/9, 456.0x-456.2x, 570.xx, 571.xx, 572.2x-572.8, ",
                                         "573.3/4/8/9, V42.7; or ICD-10 diagnoses of B18.x, I85.xx, I86.4, I98.2, ",
                                         "K70.x, K71.1x/3-5x/7, K72.xx-K74.xx, K76.0, K76.2x-K76.9x, Z94.4."
                                       ),
                                       outcome = NULL
                                     ),
                                     codes = list(
                                       dx_icd9  = make_key(
                                         liver_icd9,
                                         c(
                                           "070.22-070.9",
                                           "456.0x-456.2x",
                                           "570.xx",
                                           "571.xx",
                                           "572.2x-572.8",
                                           "573.x",
                                           "V42.7"
                                         ),
                                         condition = rep(TRUE, length(liver_icd9)),
                                         outcome = rep(FALSE, length(liver_icd9))
                                       ),
                                       dx_icd10 = make_key(
                                         liver_icd10,
                                         c(
                                           "B18.x",
                                           "I85.xx",
                                           "I86.4",
                                           "I98.2",
                                           "K70.x",
                                           "K71.1x-K71.7",
                                           "K72.xx-K74.xx",
                                           "K76.x",
                                           "Z94.4"
                                         ),
                                         condition = rep(TRUE, length(liver_icd10)),
                                         outcome = rep(FALSE, length(liver_icd10))
                                       )
                                     )
                                   )))

# spec_non_statin_lipid: Non-Statin Lipid Lowering Agents ----
spec_non_statin_lipid <- DrugSpec$new("non_statin_lipid",
                                      "Non-Statin Lipid Lowering Agents",
                                      versions = list(v1 = list(
                                        defs = paste0(
                                          "Non-statin lipid lowering agents via GNN substring match. ",
                                          "Document GNNs: FENOFIBRATE, CLOFIBRATE, GEMFIBROZIL, EZETIMIBE, ",
                                          "COLESTIPOL, CHOLESTYRAMINE, COLESEVELAM, NIACIN (excluding NIACINA), NICOTONIC."
                                        ),
                                        generic_names = c(
                                          "FENOFIBRATE",
                                          "CLOFIBRATE",
                                          "GEMFIBROZIL",
                                          "EZETIMIBE",
                                          "COLESTIPOL",
                                          "CHOLESTYRAMINE",
                                          "COLESEVELAM",
                                          "NIACIN",
                                          "NICOTONIC"
                                        ),
                                        ndc = character(0L)
                                      )))

# HCPCS nursing home visit codes (shared by spec_nursing_home_history and
# spec_debility); defined here so both specs can reference it.
deb_hcpcs <- c(
  "99301", "99302", "99303", "99304", "99305", "99306",
  "99307", "99308", "99309", "99310", "99311", "99312",
  "99313", "99315", "99316", "99318", "99379", "99380",
  "G0066"
)

# spec_nursing_home_history: Nursing Home Residence, History ----
# Same HCPCS codes as spec_debility; this is the condition/history version.
spec_nursing_home_history <- CodeSpec$new(condition = "nursing_home_history",
                                          label = "Nursing Home Residence (History)",
                                          versions = list(v1 = list(
                                            defs = list(
                                              condition = paste0(
                                                "Any of the following: ",
                                                "(1) Outpatient claim with nursing home visit HCPCS code (99301-99380 or G0066); ",
                                                "(2) Carrier line claim with place of service 31, 32, or 33, or the same HCPCS codes."
                                              ),
                                              outcome = NULL
                                            ),
                                            codes = list(hcpcs = make_key(
                                              deb_hcpcs,
                                              deb_hcpcs,
                                              condition = rep(TRUE, length(deb_hcpcs)),
                                              outcome = rep(FALSE, length(deb_hcpcs))
                                            ))
                                          )))

# spec_observation_stay: Observation Unit Stay ----
spec_observation_stay <- CodeSpec$new(condition = "observation_stay",
                                      label = "Observation Unit Stay",
                                      versions = list(v1 = list(
                                        defs = list(condition = "Claims with a revenue center code of 0762.", outcome = NULL),
                                        codes = list(rev = make_key(
                                          "0762", "0762", condition = TRUE, outcome = FALSE
                                        ))
                                      )))

# spec_old_mi: Old Myocardial Infarction, History ----
old_mi_icd9  <- expand9("412")
old_mi_icd10 <- "I252"

spec_old_mi <- CodeSpec$new(condition = "old_mi",
                            label = "Old Myocardial Infarction (History)",
                            versions = list(v1 = list(
                              defs = list(condition = "Inpatient or outpatient claim with ICD-9 code 412.xx or ICD-10 code I25.2 in any position.", outcome = NULL),
                              codes = list(
                                dx_icd9  = make_key(
                                  old_mi_icd9,
                                  c("412.xx"),
                                  condition = rep(TRUE, length(old_mi_icd9)),
                                  outcome = rep(FALSE, length(old_mi_icd9))
                                ),
                                dx_icd10 = make_key(
                                  old_mi_icd10,
                                  c("I25.2"),
                                  condition = TRUE,
                                  outcome = FALSE
                                )
                              )
                            )))

# spec_iv_inotropes: Outpatient Intravenous Inotropes ----
spec_iv_inotropes <- DrugSpec$new("iv_inotropes",
                                  "Outpatient Intravenous Inotropes",
                                  versions = list(v1 = list(
                                    defs = paste0(
                                      "Outpatient IV inotropes identified by Part D generic name milrinone, dobutamine, ",
                                      "or dopamine; or HCPCS codes J1250 (dobutamine), J2260 (milrinone), J1265 (dopamine), ",
                                      "or S9348 in any file type. Also identified by specific NCD codes in REV_CNTR_IDE_NDC_UPC_NUM."
                                    ),
                                    generic_names = c("MILRINONE", "DOBUTAMINE", "DOPAMINE"),
                                    ndc = c("J1250", "J2260", "J1265", "S9348")  # stored as HCPCS in ndc slot for now
                                  )))

# spec_pad_symptomatic: PAD Symptomatic ----
pad_symp_icd9  <- gsub("\\.",
                       "",
                       c(
                         "440.21",
                         "440.22",
                         "440.23",
                         "440.24",
                         "440.30",
                         "440.31",
                         "440.32"
                       ))
pad_symp_icd10_raw <- texts[which(grepl("I70.21.*I70.211", texts) &
                                    nchar(texts) > 100)[1]]
pad_symp_icd10 <- if (!is.na(pad_symp_icd10_raw)) {
  unique(gsub("\\.", "", regmatches(
    pad_symp_icd10_raw,
    gregexpr("I[0-9A-Za-z.]+(?=,|\\.|\\)|$)", pad_symp_icd10_raw, perl = TRUE)
  )[[1]]))
} else
  character(0L)
pad_symp_icd9_proc <- gsub("\\.",
                           "",
                           c("00.55", "39.25", "39.26", "39.29", "39.50", "39.90"))
pad_symp_icd9_amp  <- gsub("\\.",
                           "",
                           c("84.1", "84.13", "84.14", "84.15", "84.16", "84.17", "84.18"))
pad_symp_cpt_rev   <- c(
  "34201",
  "34203",
  "34808",
  "34812",
  "34813",
  "34820",
  "34825",
  "34826",
  "34831",
  "34832",
  "34833",
  "34900",
  "35102",
  "35103",
  "35131",
  "35132",
  "35141",
  "35142",
  "35151",
  "35152",
  "35302",
  "35303",
  "35304",
  "35305"
)
pad_symp_cpt_amp   <- c(
  "27295",
  "27590",
  "27591",
  "27592",
  "27594",
  "27596",
  "27598",
  "27880",
  "27881",
  "27882",
  "27884",
  "27886",
  "27888",
  "27889",
  "28800",
  "28805"
)

spec_pad_symptomatic <- CodeSpec$new(condition = "pad_symptomatic",
                                     label = "PAD, Symptomatic",
                                     versions = list(v1 = list(
                                       defs = list(
                                         condition = paste0(
                                           "Any of: (a) \u22651 inpatient or outpatient claim with claudication diagnosis ",
                                           "(ICD-9 440.21-440.24, 440.30-440.32; ICD-10 I70.21x-I70.24x); ",
                                           "(b) Procedure code for peripheral artery revascularization; ",
                                           "(c) Procedure code for major amputation within 90 days of LEAD diagnosis."
                                         ),
                                         outcome = NULL
                                       ),
                                       codes = list(
                                         dx_icd9  = make_key(
                                           pad_symp_icd9,
                                           c("440.21-440.24", "440.30-440.32"),
                                           condition = rep(TRUE, length(pad_symp_icd9)),
                                           outcome = rep(FALSE, length(pad_symp_icd9))
                                         ),
                                         dx_icd10 = make_key(
                                           pad_symp_icd10[seq_len(min(length(pad_symp_icd10), 20))],
                                           c("I70.21x-I70.24x and related"),
                                           condition = rep(TRUE, min(length(pad_symp_icd10), 20)),
                                           outcome = rep(FALSE, min(length(pad_symp_icd10), 20))
                                         ),
                                         proc_icd9 = make_key(unique(
                                           c(pad_symp_icd9_proc, pad_symp_icd9_amp)
                                         ), unique(
                                           c(pad_symp_icd9_proc, pad_symp_icd9_amp)
                                         )),
                                         cpt = make_key(unique(c(
                                           pad_symp_cpt_rev, pad_symp_cpt_amp
                                         )), unique(c(
                                           pad_symp_cpt_rev, pad_symp_cpt_amp
                                         )))
                                       )
                                     )))

# spec_pcsk9: PCSK9 Inhibitors ----
spec_pcsk9 <- DrugSpec$new("pcsk9", "PCSK9 Inhibitors", versions = list(
  v1 = list(
    defs = "PCSK9 inhibitors identified via GNN substring match. GNNs: EVOLOCUMAB, ALIROCUMAB. Brand names (REPATHA, PRALUENT) also used in source document.",
    generic_names = c("EVOLOCUMAB", "ALIROCUMAB"),
    ndc = character(0L)
  )
))

# spec_pci: Percutaneous Coronary Intervention (PCI) / Stent ----
pci_icd9  <- unique(c("0066", "360", range9("3601", "3609")))
pci_icd10 <- expand_pcs(c("0270xxx", "0271xxx", "0272xxx", "0273xxx"))
pci_hcpcs <- unique(
  c(
    hcpcs_range("92980", "92982"),
    "92984",
    hcpcs_range("92995", "92996"),
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
    paste0("C", 9600:9608)
  )
)

spec_pci <- CodeSpec$new(condition = "pci",
                         label = "Percutaneous Coronary Intervention (PCI) / Stent",
                         versions = list(v1 = list(
                           defs = list(
                             condition = paste0(
                               "ICD-9 procedure codes 00.66, 36.0, 36.01-36.09; ICD-10-PCS procedure codes ",
                               "for coronary dilation (0270xxx-0273xxx); HCPCS codes 92920-92944, 92973, 92980-92996, C9600-C9608."
                             ),
                             outcome = "Same code set as condition."
                           ),
                           codes = list(
                             proc_icd9  = make_key(pci_icd9, c("00.66", "36.0", "36.01-36.09")),
                             proc_icd10 = make_key(pci_icd10, c(
                               "0270xxx", "0271xxx", "0272xxx", "0273xxx"
                             )),
                             hcpcs      = make_key(pci_hcpcs, pci_hcpcs)
                           )
                         )))

# spec_platelet_inhibitors: Platelet Inhibitors ----
spec_platelet_inhibitors <- DrugSpec$new("platelet_inhibitors",
                                         "Platelet Inhibitors",
                                         versions = list(
                                           v1 = list(
                                             defs = "Platelet inhibitors from FDB. GNNs: CLOPIDOGREL, PRASUGREL, TICAGRELOR, TICLOPIDINE, ABCIXIMAB, ANAGRELIDE, ASPIRIN, CANGRELOR, CILOSTAZOL, DIPYRIDAMOLE, EPTIFIBATIDE, TIROFIBAN, VORAPAXAR.",
                                             generic_names = c(
                                               "CLOPIDOGREL",
                                               "PRASUGREL",
                                               "TICAGRELOR",
                                               "TICLOPIDINE",
                                               "ABCIXIMAB",
                                               "ANAGRELIDE",
                                               "ASPIRIN",
                                               "CANGRELOR",
                                               "CILOSTAZOL",
                                               "DIPYRIDAMOLE",
                                               "EPTIFIBATIDE",
                                               "TIROFIBAN",
                                               "VORAPAXAR"
                                             ),
                                             ndc = character(0L)
                                           )
                                         ))

# spec_ras: RAS Inhibitors (Renin-Angiotensin System), versions 1-3 ----
# Additional FDB-only RAS drugs not in antihypertensive medication list
spec_ras_extra <- DrugSpec$new("ras_extra",
                               "RAS Inhibitors — FDB Additional Agents",
                               versions = list(
                                 v1 = list(
                                   defs = "ACEi agents in FDB RAS list not present in the anti-hypertensive medication list: ZOFENOPRIL, CILAZAPRIL, IMIDAPRIL.",
                                   generic_names = c("ZOFENOPRIL", "CILAZAPRIL", "IMIDAPRIL"),
                                   ndc = character(0L)
                                 )
                               ))

spec_ras <- CompositeDrugSpec$new(
  drug_class = "ras",
  label = "RAS Inhibitors",
  versions = list(
    v1 = list(
      defs = "RAS inhibitors from Perisphere anti-hypertensive medication list (v1): ACE inhibitors + ARBs + ALISKIREN.",
      components = list(
        acei  = spec_acei_v1,
        arb   = spec_arb_v1,
        renin = spec_renin_v1
      )
    ),
    v2 = list(
      defs = "RAS inhibitors from FDB without ALISKIREN (v2): ACEi (FDB) + ARBs (FDB) + ZOFENOPRIL, CILAZAPRIL, IMIDAPRIL.",
      components = list(
        acei      = spec_acei_v2,
        arb       = spec_arb_v2,
        ras_extra = spec_ras_extra
      )
    ),
    v3 = list(
      defs = "RAS inhibitors from FDB with ALISKIREN (v3): same as v2 + ALISKIREN.",
      components = list(
        acei      = comp(spec_acei_v2, "v2"),
        arb       = comp(spec_arb_v2, "v2"),
        renin     = comp(spec_renin_v1, "v1"),
        ras_extra = comp(spec_ras_extra, "v1")
      )
    )
  )
)

# spec_racs: Recent ACS (RACS), History ----
racs_icd9 <- unique(c(
  Filter(\(x) endsWith(x, "0") | endsWith(x, "1"), expand9("410")),
  "4111",
  "41181",
  "41189"
))
racs_icd10 <- unique(
  c(
    expand10("I21"),
    expand10("I22"),
    "I200",
    "I240",
    "I248",
    "I249",
    "I25110",
    "I25700",
    "I25710",
    "I25720",
    "I25730",
    "I25750",
    "I25760",
    "I25790"
  )
)

spec_racs <- CodeSpec$new(condition = "racs",
                          label = "Recent Acute Coronary Syndrome (RACS)",
                          versions = list(v1 = list(
                            defs = list(
                              condition = paste0(
                                "Overnight hospitalization with a primary or any discharge diagnosis code for: ",
                                "acute MI (ICD-9 410.x0/410.x1; ICD-10 I21.xx/I22.xx) OR ",
                                "unstable angina (ICD-9 411.1/411.81/411.89; ICD-10 I20.0, I24.0, I24.8, I24.9, I25.110, I25.7xx)."
                              ),
                              outcome = paste0("Same code set; used as an outcome endpoint.")
                            ),
                            codes = list(
                              dx_icd9  = make_key(racs_icd9, c(
                                "410.x0", "410.x1", "411.1", "411.81", "411.89"
                              )),
                              dx_icd10 = make_key(
                                racs_icd10,
                                c("I21.xx", "I22.xx", "I20.0", "I24.x", "I25.1xx/I25.7xx")
                              )
                            )
                          )))

# spec_smoking: Smoking, History ----
smoke_icd9  <- unique(c("3051", expand9("6490"), "98984", "V1582"))
smoke_icd10 <- unique(
  c(
    "F17200",
    "F17201",
    "F17210",
    "F17211",
    "F17220",
    "F17221",
    "F17290",
    "F17291",
    range10("O99330", "O99335"),
    expand10("T652"),
    "Z720",
    "Z87891"
  )
)
smoke_cpt <- c(
  "99406",
  "99407",
  "G0436",
  "G0437",
  "G9016",
  "S9453",
  "S4995",
  "G9276",
  "G9458",
  "1034F",
  "4004F",
  "4001F"
)

spec_smoking <- CodeSpec$new(condition = "smoking",
                             label = "Smoking History",
                             versions = list(v1 = list(
                               defs = list(
                                 condition = paste0(
                                   "Any of: (a) \u22651 inpatient or outpatient E&M claim with ICD-9 diagnosis ",
                                   "305.1, 649.0x, 989.84, or V15.82, or ICD-10 diagnosis F17.200-F17.291, ",
                                   "O99.330-O99.335, T65.2x, Z72.0, or Z87.891; ",
                                   "(b) \u22651 inpatient or E&M claim with a smoking cessation CPT code ",
                                   "(99406, 99407, G0436, G0437, G9016, S9453, S4995, G9276, G9458, 1034F, 4004F, 4001F); ",
                                   "(c) \u22651 pharmacy claim for nicotine or varenicline."
                                 ),
                                 outcome = NULL
                               ),
                               codes = list(
                                 dx_icd9  = make_key(
                                   smoke_icd9,
                                   c("305.1", "649.0x", "989.84", "V15.82"),
                                   condition = rep(TRUE, length(smoke_icd9)),
                                   outcome = rep(FALSE, length(smoke_icd9))
                                 ),
                                 dx_icd10 = make_key(
                                   smoke_icd10,
                                   c("F17.2xx", "O99.330-O99.335", "T65.2x", "Z72.0", "Z87.891"),
                                   condition = rep(TRUE, length(smoke_icd10)),
                                   outcome = rep(FALSE, length(smoke_icd10))
                                 ),
                                 cpt      = make_key(
                                   smoke_cpt,
                                   smoke_cpt,
                                   condition = rep(TRUE, length(smoke_cpt)),
                                   outcome = rep(FALSE, length(smoke_cpt))
                                 )
                               )
                             )))

# Add spec_lead_pad_v1 to ASCVD components (LEAD is part of v2 but treated as
# a component alongside other versioned specs)
if (exists("spec_lead_pad_v1")) {
  spec_ascvd$.__enclos_env__$private$.components[["lead_pad_v1"]] <- spec_lead_pad_v1
}


### TOC ITEMS 51-75 ----

# spec_diuretics_thiazide_like: Thiazide-LIKE diuretics (Diur_thz_like) ----
# CHLORTHALIDONE, INDAPAMIDE, METOLAZONE — not true thiazides but used
# similarly. A subset of spec_diuretics_thiazide.

spec_diuretics_thiazide_like <- DrugSpec$new("diuretics_thiazide_like",
                                             "Diuretics — Thiazide-Like",
                                             versions = list(
                                               v1 = list(
                                                 defs          = "Thiazide-like diuretics (non-thiazide structure but similar mechanism). Document GNNs: CHLORTHALIDONE, INDAPAMIDE, METOLAZONE.",
                                                 generic_names = c("CHLORTHALIDONE", "INDAPAMIDE", "METOLAZONE"),
                                                 ndc           = character(0L)
                                               )
                                             ))

# spec_diuretics_thiazide_type: True thiazide diuretics (Diur_thz_type) ----
# BENDROFLUMETHIAZIDE, HYDROCHLOROTHIAZIDE, HYDROCHOLOROTHIAZIDE (spelling
# variant), POLYTHIAZIDE, CHLOROTHIAZIDE — benzothiadiazide chemical class.

spec_diuretics_thiazide_type <- DrugSpec$new(
  "diuretics_thiazide_type",
  "Diuretics — Thiazide-Type (True Thiazides)",
  versions = list(
    v1 = list(
      defs          = "True thiazide (benzothiadiazide) diuretics. Document GNNs: BENDROFLUMETHIAZIDE, HYDROCHLOROTHIAZIDE, HYDROCHOLOROTHIAZIDE, POLYTHIAZIDE, CHLOROTHIAZIDE.",
      generic_names = c(
        "BENDROFLUMETHIAZIDE",
        "HYDROCHLOROTHIAZIDE",
        "HYDROCHOLOROTHIAZIDE",
        "POLYTHIAZIDE",
        "CHLOROTHIAZIDE"
      ),
      ndc           = character(0L)
    )
  )
)

# spec_ed_visit: Emergency Department Visit ----
# Revenue codes: 0450-0459, 0981; HCPCS: 99281-99285, 99288, 99291-99292,
# G0380-G0384, G8354; place of service 23 (note in defs only).

ed_rev   <- c(sprintf("04%s%d", "5", 0:9), "0981")
ed_hcpcs <- c(
  hcpcs_range("99281", "99285"),
  "99288",
  "99291",
  "99292",
  "G0380",
  "G0381",
  "G0382",
  "G0383",
  "G0384",
  "G8354"
)

spec_ed_visit <- CodeSpec$new(condition = "ed_visit",
                              label     = "Emergency Department Visit",
                              versions  = list(v1 = list(
                                defs = list(
                                  condition = paste0(
                                    "Emergency department visit identified by any of: a revenue code of ",
                                    "045.x (0450-0459) or 0981; place of service code 23 (on carrier claims); ",
                                    "or a HCPCS code of 99281-99285, 99288, 99291, 99292, G0380-G0384, or G8354."
                                  ),
                                  outcome = NULL
                                ),
                                codes = list(
                                  rev   = make_key(
                                    ed_rev,
                                    ed_rev,
                                    condition = rep(TRUE, length(ed_rev)),
                                    outcome   = rep(FALSE, length(ed_rev))
                                  ),
                                  hcpcs = make_key(
                                    ed_hcpcs,
                                    ed_hcpcs,
                                    condition = rep(TRUE, length(ed_hcpcs)),
                                    outcome   = rep(FALSE, length(ed_hcpcs))
                                  )
                                )
                              )))

# spec_ezetimibe: Ezetimibe ----
spec_ezetimibe <- DrugSpec$new("ezetimibe", "Ezetimibe", versions = list(
  v1 = list(
    defs          = "Ezetimibe identified via GNN substring match. Document search term: EZETIMIBE.",
    generic_names = c("EZETIMIBE"),
    ndc           = character(0L)
  )
))

# spec_fall_injury: Fall-Related Injury ----
# ICD-9: E codes 880.x-888.9 (fall mechanism) + injury codes (fractures,
#   brain injury, dislocations) — both must be present on the same claim.
# ICD-10: W codes W00-W19 (fall mechanism) + S codes (specific injuries) —
#   both must be present. S codes are extensive; the full enumeration from
#   the document is stored in the defs text. The dx_icd10 key stores only
#   the mechanism W codes; match both W and S codes in the claims workflow.
#
# Exclusion: motor vehicle accident E codes (810-829) — noted in defs.

fall_icd9_e <- unique(
  c(
    expand9("8800"),
    expand9("8801"),
    expand9("8802"),
    expand9("8803"),
    expand9("8809"),
    expand9("8810"),
    expand9("8811"),
    expand9("8812"),
    expand9("8813"),
    expand9("8819"),
    expand9("8820"),
    expand9("8821"),
    expand9("8822"),
    expand9("8823"),
    expand9("8829"),
    expand9("8830"),
    expand9("8831"),
    expand9("8832"),
    expand9("8833"),
    expand9("8839"),
    expand9("8840"),
    expand9("8841"),
    expand9("8842"),
    expand9("8843"),
    expand9("8849"),
    expand9("8850"),
    expand9("8851"),
    expand9("8852"),
    expand9("8853"),
    expand9("8859"),
    expand9("8860"),
    expand9("8861"),
    expand9("8862"),
    expand9("8863"),
    expand9("8869"),
    expand9("8870"),
    expand9("8871"),
    expand9("8872"),
    expand9("8879"),
    expand9("8880"),
    expand9("8881"),
    expand9("8882"),
    expand9("8889")
  )
)
fall_icd10_w <- range10("W00", "W19")

spec_fall_injury <- CodeSpec$new(condition = "fall_injury",
                                 label     = "Fall-Related Injury",
                                 versions  = list(v1 = list(
                                   defs = list(
                                     condition = paste0(
                                       "Emergency department or inpatient claim with: ",
                                       "(a) [ICD-9] a fall-related E code (E880.x-E888.9) AND an injury code for ",
                                       "skull/facial/cervical fractures (800-806.19), other fractures ",
                                       "(807-809, 810-819, 820-821, 827-829), brain injury (852.00-852.39), ",
                                       "or hip/knee/shoulder dislocation (830-832.1, 835.00-835.13, 836.30-836.60); ",
                                       "OR (b) [ICD-10] a fall W code (W00-W19) AND a specific injury S code ",
                                       "(skull fractures S02.x, hip fractures S72.x, etc. — see full enumeration ",
                                       "in source document). In the absence of a fall mechanism code, an isolated ",
                                       "fracture/dislocation code qualifies as long as there is no motor vehicle ",
                                       "accident E/V code (E810-E829 / V codes). Injury codes must be for ",
                                       "nonpathological fractures only."
                                     ),
                                     outcome = paste0(
                                       "Same definition as condition — fall-related injury is both a condition ",
                                       "and an outcome endpoint."
                                     )
                                   ),
                                   codes = list(
                                     dx_icd9  = make_key(fall_icd9_e, c("E880.x-E888.9 (fall mechanism E codes)")),
                                     dx_icd10 = make_key(fall_icd10_w, c("W00-W19 (fall mechanism W codes)"))
                                   )
                                 )))

# spec_familial_hypercholesterolemia: Familial Hypercholesterolemia ----
# ICD-10 only: E78.01. No ICD-9 code specified in document.

spec_familial_hypercholesterolemia <- CodeSpec$new(condition = "familial_hypercholesterolemia",
                                                   label     = "Familial Hypercholesterolemia",
                                                   versions  = list(v1 = list(
                                                     defs = list(
                                                       condition = paste0(
                                                         "\u22651 E&M-linked outpatient visit or \u22651 inpatient claim with an ICD-10-CM ",
                                                         "diagnosis code of E78.01 (familial hypercholesterolemia) in any position. ",
                                                         "No ICD-9-CM code is specified in the source document."
                                                       ),
                                                       outcome = NULL
                                                     ),
                                                     codes = list(dx_icd10 = make_key(
                                                       "E7801", "E78.01", condition = TRUE, outcome = FALSE
                                                     ))
                                                   )))

# spec_hiv: HIV Infection (ICD-based) ----
# ICD-9: 042.x-044.x, V08; ICD-10: B20-B22, B24, Z21

spec_hiv <- CodeSpec$new(condition = "hiv",
                         label     = "HIV Infection",
                         versions  = list(v1 = list(
                           defs = list(
                             condition = paste0(
                               "\u22651 inpatient claim with an ICD-9 diagnosis of 042.x-044.x or V08, ",
                               "or an ICD-10 diagnosis of B20-B22, B24, or Z21 in any position. ",
                               "May also be identified via \u22652 HIV medication fills on separate days within ",
                               "365 days (see spec_hiv_meds; excluding lamivudine, tenofovir, and ",
                               "emtricitabine which are also used for hepatitis B/PrEP)."
                             ),
                             outcome = NULL
                           ),
                           codes = list(
                             dx_icd9  = make_key(
                               c("042", "043", "044", "V08"),
                               c("042.x", "043.x", "044.x", "V08"),
                               condition = rep(TRUE, 4L),
                               outcome = rep(FALSE, 4L)
                             ),
                             dx_icd10 = make_key(
                               c("B20", "B21", "B22", "B24", "Z21"),
                               c("B20", "B21", "B22", "B24", "Z21"),
                               condition = rep(TRUE, 5L),
                               outcome = rep(FALSE, 5L)
                             )
                           )
                         )))

# spec_hiv_meds: HIV Antiretroviral Medications ----
# Source: "HIV, index, version 1" medication list
# GNNs are from the document's medication list.
# Note: lamivudine, tenofovir, and emtricitabine excluded when identifying
# HIV (also indicated for hepatitis B / PrEP), but included here for
# completeness since they are documented ARV medications.

hiv_gnns <- c(
  # NRTIs
  "ABACAVIR",
  "DIDANOSINE",
  "EMTRICITABINE",
  "LAMIVUDINE",
  "STAVUDINE",
  "TENOFOVIR DISOPROXIL FUMARATE",
  "ZIDOVUDINE",
  # NNRTIs
  "DELAVIRDINE",
  "EFAVIRENZ",
  "ETRAVIRINE",
  "NEVIRAPINE",
  "RILPIVIRINE",
  # Protease inhibitors
  "ATAZANAVIR",
  "DARUNAVIR",
  "FOSAMPRENAVIR",
  "INDINAVIR",
  "NELFINAVIR",
  "RITONAVIR",
  "SAQUINAVIR",
  "TIPRANAVIR",
  # Fusion inhibitor
  "ENFUVIRTIDE",
  # Entry inhibitor
  "MARAVIROC",
  # Integrase inhibitors
  "DOLUTEGRAVIR",
  "ELVITEGRAVIR",
  "RALTEGRAVIR",
  # PK enhancer
  "COBICISTAT",
  # Combinations
  "ABACAVIR/LAMIVUDINE",
  "ABACAVIR/DOLUTEGRAVIR/LAMIVUDINE",
  "ABACAVIR/LAMIVUDINE/ZIDOVUDINE",
  "EFAVIRENZ/EMTRICITABINE/TENOFOVIR DISOPROXIL FUMARATE",
  "ELVITEGRAVIR/COBICISTAT/EMTRICITABINE/TENOFOVIR DISOPROXIL FUMARATE",
  "EMTRICITABINE/RILPIVIRINE/TENOFOVIR DISOPROXIL FUMARATE",
  "LAMIVUDINE/ZIDOVUDINE",
  "LOPINAVIR/RITONAVIR",
  "ATAZANAVIR/COBICISTAT",
  "COBICISTAT/DARUNAVIR"
)

spec_hiv_meds <- DrugSpec$new("hiv_meds",
                              "HIV Antiretroviral Medications",
                              versions = list(v1 = list(
                                defs = paste0(
                                  "HIV antiretroviral medications from the Perisphere definitions document. ",
                                  "Includes NRTIs, NNRTIs, protease inhibitors, fusion inhibitors, entry ",
                                  "inhibitors, integrase inhibitors, pharmacokinetic enhancers, and ",
                                  "fixed-dose combinations. Note: when identifying HIV via pharmacy claims, ",
                                  "exclude lamivudine, tenofovir, and emtricitabine (also used for hepatitis ",
                                  "B treatment and HIV pre-exposure prophylaxis / PrEP)."
                                ),
                                generic_names = hiv_gnns,
                                ndc           = character(0L)
                              )))

# spec_hormone_therapy: Hormone Therapy ----
# Source: "Hormone therapy, version 1"
# Uses both index(upcase(GNN), ...) and upcase(GNN) in (...) syntax

spec_hormone_therapy <- DrugSpec$new("hormone_therapy", "Hormone Therapy", versions = list(v1 = list(
  defs = paste0(
    "Hormone therapy medications identified via GNN substring match and ",
    "exact match. Document search terms: ESTRADIOL, PROGESTERONE, ",
    "MEDROXYPROGESTERONE, ESTROPIPATE, DROSPERINONE, ETONORGESTREL, ",
    "LEVONORGESTREL, NORETHINDRONE. Exact GNN matches: conjugated estrogens, ",
    "esterified estrogens, and combination products."
  ),
  generic_names = c(
    # Substring search terms
    "ESTRADIOL",
    "PROGESTERONE",
    "MEDROXYPROGESTERONE",
    "ESTROPIPATE",
    "DROSPERINONE",
    "ETONORGESTREL",
    "LEVONORGESTREL",
    "NORETHINDRONE",
    # Exact GNN matches from upcase(GNN) in (...) list
    "ESTROGEN,CON/M-PROGEST ACET",
    "ESTROGEN,ESTER/ME-TESTOSTERONE",
    "ESTROGENS, CONJUGATED",
    "ESTROGENS,CONJUGATED",
    "ESTROGENS,CONJ.,SYNTHETIC A",
    "ESTROGENS,CONJ.,SYNTHETIC B",
    "ESTROGENS,CONJ/BAZEDOXIFENE",
    "ESTROGENS,ESTERIFIED"
  ),
  ndc = character(0L)
)))

# spec_hyperkalemia: Hyperkalemia ----
# ICD-9: 276.7; ICD-10: E87.5

spec_hyperkalemia <- CodeSpec$new(condition = "hyperkalemia",
                                  label     = "Hyperkalemia",
                                  versions  = list(v1 = list(
                                    defs = list(
                                      condition = paste0(
                                        "\u22651 inpatient claim or \u22651 outpatient claim linked to a physician ",
                                        "evaluation and management code with an ICD-9 diagnosis of 276.7 or an ",
                                        "ICD-10 diagnosis of E87.5 in any position."
                                      ),
                                      outcome = NULL
                                    ),
                                    codes = list(
                                      dx_icd9  = make_key("2767", "276.7", condition = TRUE, outcome = FALSE),
                                      dx_icd10 = make_key("E875", "E87.5", condition = TRUE, outcome = FALSE)
                                    )
                                  )))


### TOC ITEMS 26-50 ----

# spec_cabg: Coronary Artery Bypass Graft Surgery ----
# Source: "CABG, index and outcome, version 1"
# ICD-9 proc: 36.2 and 36.10-36.19; ICD-10 proc: 0210-0213 variants; HCPCS

cabg_proc_icd9  <- c("362", range9("3610", "3619"))
cabg_proc_icd10 <- expand_pcs(c("0210xxx", "0211xxx", "0212xxx", "0213xxx"))
cabg_hcpcs      <- c(
  hcpcs_range("33510", "33519"),
  hcpcs_range("33521", "33523"),
  hcpcs_range("33533", "33536"),
  "33530"
)

spec_cabg <- CodeSpec$new(condition = "cabg",
                          label     = "Coronary Artery Bypass Graft Surgery (CABG)",
                          versions  = list(v1 = list(
                            defs = list(
                              condition = paste0(
                                "Any of the following: ICD-9 procedure codes 36.2 or 36.10-36.19; ",
                                "ICD-10-PCS procedure codes for CABG (0210xxx-0213xxx variants); ",
                                "HCPCS codes 33510-33519, 33521-33523, 33530, 33533-33536."
                              ),
                              outcome = paste0("Same code set as condition definition.")
                            ),
                            codes = list(
                              proc_icd9  = make_key(cabg_proc_icd9, c("36.2", "36.10-36.19")),
                              proc_icd10 = make_key(cabg_proc_icd10, c(
                                "0210xxx", "0211xxx", "0212xxx", "0213xxx"
                              )),
                              hcpcs      = make_key(cabg_hcpcs, cabg_hcpcs)
                            )
                          )))


# spec_cancer: Cancer, history ----
# Source: "Cancer, history, version 1"
# ICD-9: 140-172, 174-208, 209.0x-209.3x, V10.xx
# ICD-10: C00-C96, D03.xx, D45, Z85.xx
# HCPCS for ER identification: 99281-99285, 99288, 99291-99292, G0380-G0384, G8354

cancer_icd9  <- unique(c(
  range9("140", "172"),
  range9("174", "208"),
  expand9("2090"),
  expand9("2091"),
  expand9("2092"),
  expand9("2093"),
  expand9("V10")
))
cancer_icd10 <- unique(c(range10("C00", "C96"), expand10("D03"), "D45", expand10("Z85")))
cancer_hcpcs <- c(
  hcpcs_range("99281", "99285"),
  "99288",
  "99291",
  "99292",
  "G0380",
  "G0381",
  "G0382",
  "G0383",
  "G0384",
  "G8354"
)

spec_cancer <- CodeSpec$new(condition = "cancer",
                            label     = "Cancer",
                            versions  = list(v1 = list(
                              defs = list(
                                condition = paste0(
                                  "Any of the following: ",
                                  "(a) \u22651 outpatient ER visit with ICD-9 diagnosis of 140.xx-172.xx, ",
                                  "174.xx-208.xx, 209.0x-209.3x, or ICD-10 diagnosis of C00.xx-C96.xx, ",
                                  "D03.xx, or D45 in any position (identified via revenue code, place of ",
                                  "service, or HCPCS codes 99281-99285, 99288, 99291, 99292, G0380-G0384, G8354); ",
                                  "(b) \u22651 inpatient or \u22652 carrier/outpatient E&M claims with ICD-9 codes ",
                                  "140.xx-172.xx, 174.xx-208.xx, 209.0x-209.3x, or ICD-10 codes C00.xx-C96.xx, ",
                                  "D03.xx, D45; ",
                                  "(c) \u22651 ER, inpatient, or E&M claim for ICD-9 V10.xx or ICD-10 Z85.xx ",
                                  "(personal history of malignant neoplasm)."
                                ),
                                outcome = NULL
                              ),
                              codes = list(
                                dx_icd9  = make_key(
                                  cancer_icd9,
                                  c("140.xx-172.xx", "174.xx-208.xx", "209.0x-209.3x", "V10.xx"),
                                  condition = rep(TRUE, length(cancer_icd9)),
                                  outcome   = rep(FALSE, length(cancer_icd9))
                                ),
                                dx_icd10 = make_key(
                                  cancer_icd10,
                                  c("C00.xx-C96.xx", "D03.xx", "D45", "Z85.xx"),
                                  condition = rep(TRUE, length(cancer_icd10)),
                                  outcome   = rep(FALSE, length(cancer_icd10))
                                ),
                                hcpcs    = make_key(
                                  cancer_hcpcs,
                                  cancer_hcpcs,
                                  condition = rep(TRUE, length(cancer_hcpcs)),
                                  outcome   = rep(FALSE, length(cancer_hcpcs))
                                )
                              )
                            )))


# spec_cardiac_rehab: Cardiac Rehabilitation ----
# Source: "Cardiac rehabilitation" section
# CPT/HCPCS: 93797, 93798, G0422, G0423

spec_cardiac_rehab <- CodeSpec$new(condition = "cardiac_rehab",
                                   label     = "Cardiac Rehabilitation",
                                   versions  = list(v1 = list(
                                     defs = list(condition = "CPT/HCPCS codes 93797, 93798, G0422, or G0423 on any claim.", outcome   = NULL),
                                     codes = list(cpt = make_key(
                                       c("93797", "93798", "G0422", "G0423"),
                                       c("93797", "93798", "G0422", "G0423"),
                                       condition = rep(TRUE, 4L),
                                       outcome   = rep(FALSE, 4L)
                                     ))
                                   )))


# spec_cr: Coronary Revascularization (history) ----
# Source: "CR, history, version 1"
# ICD-9 dx: V45.81 (CABG status), V45.82 (PTCA status)
# ICD-10 dx: Z95.1, Z98.61
# ICD-9/10 proc and HCPCS: same as CHD (see spec_chd)
# Exclusion: events occurring during or within 30 days of an acute MI
#   hospitalization are excluded (captured in defs only).

cr_icd9_dx  <- c("V4581", "V4582")
cr_icd10_dx <- c("Z951", "Z9861")

spec_cr <- CodeSpec$new(condition = "cr",
                        label     = "Coronary Revascularization (CR)",
                        versions  = list(v1 = list(
                          defs = list(
                            condition = paste0(
                              "Any of the following, EXCLUDING events during or within 30 days of an ",
                              "acute MI hospitalization: ",
                              "(a) \u22651 inpatient claim with ICD-9 diagnosis V45.81 or V45.82, or ICD-10 ",
                              "diagnosis Z95.1 or Z98.61 (status post bypass/PTCA) in any discharge position; ",
                              "(b) \u22651 outpatient claim with the same diagnosis codes; ",
                              "(c) \u22651 inpatient or outpatient claim with ICD-9 procedure code 00.66, ",
                              "36.0, 36.01-36.19, or 36.2, an ICD-10-PCS procedure code for CABG/PCI, ",
                              "or a HCPCS code for coronary revascularization (see spec_chd for procedure ",
                              "and HCPCS code sets)."
                            ),
                            outcome = NULL
                          ),
                          codes = list(
                            dx_icd9    = make_key(
                              cr_icd9_dx,
                              c("V45.81", "V45.82"),
                              condition = rep(TRUE, length(cr_icd9_dx)),
                              outcome   = rep(FALSE, length(cr_icd9_dx))
                            ),
                            dx_icd10   = make_key(
                              cr_icd10_dx,
                              c("Z95.1", "Z98.61"),
                              condition = rep(TRUE, length(cr_icd10_dx)),
                              outcome   = rep(FALSE, length(cr_icd10_dx))
                            ),
                            proc_icd9  = make_key(
                              chd_proc_icd9,
                              chd_proc_icd9_abbreviated,
                              condition = rep(TRUE, length(chd_proc_icd9)),
                              outcome   = rep(FALSE, length(chd_proc_icd9))
                            ),
                            proc_icd10 = make_key(
                              chd_proc_icd10,
                              chd_proc_icd10,
                              condition = rep(TRUE, length(chd_proc_icd10)),
                              outcome   = rep(FALSE, length(chd_proc_icd10))
                            ),
                            hcpcs      = make_key(
                              chd_hcpcs,
                              chd_hcpcs,
                              condition = rep(TRUE, length(chd_hcpcs)),
                              outcome   = rep(FALSE, length(chd_hcpcs))
                            )
                          )
                        )))


# spec_chd_v2: CHD version 2 ----
# Same codes as v1; outcome definition is extended to allow coronary
# revascularizations within 60 days of MI linked to non-elective CHD
# hospitalizations with specific arrhythmia/HF/ACS qualifying diagnoses.

spec_chd_v2 <- CodeSpec$new(
  condition = "chd", version = "v2", label = "Coronary Heart Disease",
  defs = list(
    condition = spec_chd_v1$get_defs("condition"),
    outcome   = paste0(
      spec_chd_v1$get_defs("outcome"),
      " Version 2 additionally includes coronary revascularizations occurring ",
      "within 60 days of an MI hospitalization if the revascularization is linked ",
      "to a primary discharge diagnosis from the following non-elective CHD-related ",
      "conditions: ICD-9 codes 427.xx, 402.01, 402.11, 402.91, 404.01-404.93, ",
      "428.x, 411.xx; ICD-10 codes I47.1, I47.2, I47.9, I48.91, I48.92, I49.xx, ",
      "R00.1, I46.9, I11.0, I13.0, I13.2, I50.xx (arrhythmias, HF, ACS)."
    )
  ),
  codes = spec_chd_v1$.__enclos_env__$private$.codes
)

# Add spec_chd_v2 to spec_ascvd components now that it is defined
spec_ascvd$.__enclos_env__$private$.components[["chd_v2"]] <- spec_chd_v2


# spec_debility: Debility (Nursing Home Residence), outcome ----
# Source: "Debility (Nursing home residence), outcome, version 1"
# HCPCS nursing home visit codes; outcome-only definition.
# Algorithm: 1 OR 2 AND NOT 3 (no baseline nursing home residence).
# Note: deb_hcpcs defined earlier (near spec_nursing_home_history)

spec_debility <- CodeSpec$new(condition = "debility",
                              label     = "Debility (Nursing Home Residence)",
                              versions  = list(v1 = list(
                                defs = list(
                                  condition = NULL,
                                  outcome   = paste0(
                                    "Presence of 1) OR 2), AND NOT 3): ",
                                    "(1) Outpatient claim with a nursing home visit HCPCS code (99301-99380 ",
                                    "or G0066), not between SNF admission and discharge dates; ",
                                    "(2) Carrier line claim with place of service 31, 32, or 33, or the same ",
                                    "HCPCS codes, not between SNF admission and discharge dates; ",
                                    "(3) Nursing home residence during the baseline period (exclusion criterion)."
                                  )
                                ),
                                codes = list(hcpcs = make_key(
                                  deb_hcpcs,
                                  deb_hcpcs,
                                  condition = rep(FALSE, length(deb_hcpcs)),
                                  outcome   = rep(TRUE, length(deb_hcpcs))
                                ))
                              )))


# spec_dementia: Dementia, history ----
# Source: "Dementia, history, version 1"

dem_icd9 <- unique(gsub(
  "\\.",
  "",
  c(
    "331.0",
    "331.1",
    "331.2",
    "331.7",
    "290.0",
    "290.10",
    "290.11",
    "290.12",
    "290.13",
    "290.20",
    "290.21",
    "290.3",
    "290.40",
    "290.41",
    "290.42",
    "290.43",
    "290.8",
    "290.9",
    "294.0",
    "294.1",
    "29410",
    "29411",
    "29420",
    "29421",
    "294.8",
    "33111",
    "33119",
    "797"
  )
))
dem_icd10 <- c(
  "F0150",
  "F0151",
  "F0280",
  "F0281",
  "F0390",
  "F0391",
  "G300",
  "G301",
  "G308",
  "G309",
  "G3101",
  "G3109",
  "G311",
  "F04",
  "F068",
  "G94",
  "R4181"
)

spec_dementia <- CodeSpec$new(condition = "dementia",
                              label     = "Dementia",
                              versions  = list(v1 = list(
                                defs = list(
                                  condition = paste0(
                                    "Any of the following: ",
                                    "(a) \u22651 hospitalization with a discharge diagnosis code for dementia ",
                                    "(ICD-9: 331.0-331.2, 331.7, 290.0-290.9, 294.0-294.8, 33111, 33119, 797; ",
                                    "ICD-10: F01.50-F03.91, G30.x, G31.01/09/1, F04, F068, G94, R4181) ",
                                    "in any discharge diagnosis position; ",
                                    "(b) \u22651 physician evaluation and management visit with the same codes."
                                  ),
                                  outcome = NULL
                                ),
                                codes = list(
                                  dx_icd9  = make_key(
                                    dem_icd9,
                                    dem_icd9,
                                    condition = rep(TRUE, length(dem_icd9)),
                                    outcome   = rep(FALSE, length(dem_icd9))
                                  ),
                                  dx_icd10 = make_key(
                                    dem_icd10,
                                    dem_icd10,
                                    condition = rep(TRUE, length(dem_icd10)),
                                    outcome   = rep(FALSE, length(dem_icd10))
                                  )
                                )
                              )))


# spec_depression: Depression, history, versions 1-2 ----
# Source: "Depression, history, version 1 (without medication)"
#         "Depression, history, version 2 (with medication)"
# ICD-9 ranges: 296.20-296.26, 296.30-296.36, 296.51-296.56, 296.60-296.66,
#   296.89, 298.0, 300.4, 309.1, 311
# ICD-10: F32.9, F32.0-F32.5, F33.x, F31.x variants, F34.1, F43.21
# v2 adds requirement for ≥2 pharmacy claims for a depression medication.

dep_icd9 <- unique(c(
  range9("29620", "29626"),
  range9("29630", "29636"),
  range9("29651", "29656"),
  range9("29660", "29666"),
  "29689",
  "2980",
  "3004",
  "3091",
  "311"
))
dep_icd10 <- unique(
  c(
    "F329",
    range10("F320", "F325"),
    "F339",
    range10("F330", "F333"),
    "F3341",
    "F3342",
    "F3331",
    "F3132",
    "F314",
    "F315",
    "F3175",
    "F3176",
    range10("F3160", "F3164"),
    "F3177",
    "F3178",
    "F3181",
    "F323",
    "F341",
    "F4321"
  )
)

dep_codes <- list(
  dx_icd9  = make_key(
    dep_icd9,
    dep_icd9,
    condition = rep(TRUE, length(dep_icd9)),
    outcome   = rep(FALSE, length(dep_icd9))
  ),
  dx_icd10 = make_key(
    dep_icd10,
    dep_icd10,
    condition = rep(TRUE, length(dep_icd10)),
    outcome   = rep(FALSE, length(dep_icd10))
  )
)

dep_defs_base <- paste0(
  "Any of the following: ",
  "(a) \u22651 inpatient claim with ICD-9 diagnosis of 296.20-296.26, 296.30-296.36, ",
  "296.51-296.56, 296.60-296.66, 296.89, 298.0, 300.4, 309.1, or 311, or an ICD-10 ",
  "diagnosis of F32.x, F33.x, F31.x (specified bipolar/depressive variants), F34.1, ",
  "F43.21, in any position; ",
  "(b) \u22651 outpatient E&M claim with the same ICD codes."
)
dep_meds <- paste0(
  "AMITRIPTYLINE, AMOXAPINE, BUPROPION, CITALOPRAM, CLOMIPRAMINE, DESIPRAMINE, ",
  "DESVENLAFAXINE, DOXEPIN, DULOXETINE, ESCITALOPRAM, FLUOXETINE, FLUVOXAMINE, ",
  "IMIPRAMINE, ISOCARBOXAZID, LEVOMILNACIPRAN, MAPROTILINE, MILNACIPRAN, ",
  "MIRTAZAPINE, NEFAZODONE, NORTRIPTYLINE, PAROXETINE, PERPHENAZINE, PHENELZINE, ",
  "PROTRIPTYLINE, SELEGILINE, SERTRALINE, TRANYLCYPROMINE, TRAZODONE, ",
  "TRIMIPRAMINE, VENLAFAXINE, VILAZODONE, VORTIOXETINE."
)

spec_depression <- CodeSpec$new(
  condition = "depression",
  label     = "Depression",
  versions  = list(
    v1 = list(
      defs  = list(
        condition = paste0(dep_defs_base, " Medication use not required."),
        outcome   = NULL
      ),
      codes = dep_codes
    ),
    v2 = list(
      defs  = list(
        condition = paste0(
          dep_defs_base,
          " OR (c) \u22652 pharmacy claims ",
          "for a depression medication (GNN substring match): ",
          dep_meds
        ),
        outcome   = NULL
      ),
      codes = dep_codes
    )
  )
)


# spec_digoxin: Digoxin ----
# Source: "Digoxin, version 1"

spec_digoxin <- DrugSpec$new(drug_class = "digoxin",
                             label      = "Digoxin / Cardiac Glycosides",
                             versions   = list(v1 = list(
                               defs          = paste0(
                                 "Cardiac glycosides identified via GNN substring match. ",
                                 "Document search terms: DIGITALIS, DIGITOXIN, DIGOXIN, OUABAIN."
                               ),
                               generic_names = c("DIGITALIS", "DIGITOXIN", "DIGOXIN", "OUABAIN"),
                               ndc           = character(0L)
                             )))


### REMAINING TOC ITEMS 1-25 (conditions + anti-arrhythmic drug) ----

# spec_ami: Acute Myocardial Infarction ----
# Source: sections "AMI, history, version 1" and "AMI, outcome, version 1"
# ICD-9: 410.xx excluding 410.x2 (subsequent episode of care)
# ICD-10: I21.xx, I22.xx
# Both history and outcome use the same code set; distinction is claim logic:
#   condition: any discharge diagnosis position on overnight hospitalization
#   outcome:   any diagnosis position; inpatient claims ≤1 day apart combined

ami_icd9  <- Filter(\(x) ! endsWith(x, "2"), expand9("410"))
ami_icd10 <- c(expand10("I21"), expand10("I22"))

spec_ami <- CodeSpec$new(condition = "ami",
                         label     = "Acute Myocardial Infarction (AMI)",
                         versions  = list(v1 = list(
                           defs = list(
                             condition = paste0(
                               "Overnight hospitalization with a discharge diagnosis code for AMI ",
                               "(ICD-9 code 410.xx excluding 410.x2, or ICD-10 code I21.xx or I22.xx) ",
                               "in any discharge diagnosis position. Inpatient claims \u22641 day apart may ",
                               "represent a hospital transfer and are combined into a single episode."
                             ),
                             outcome = paste0(
                               "Overnight hospitalization with a discharge diagnosis code for AMI ",
                               "(ICD-9 code 410.xx excluding 410.x2, or ICD-10 code I21.xx or I22.xx) ",
                               "in any diagnosis position. Inpatient claims \u22641 day apart are combined ",
                               "into a single episode of care."
                             )
                           ),
                           codes = list(
                             dx_icd9 = make_key(
                               ami_icd9,
                               c("410.xx (excl. 410.x2)"),
                               condition = rep(TRUE, length(ami_icd9)),
                               outcome   = rep(TRUE, length(ami_icd9))
                             ),
                             dx_icd10 = make_key(
                               ami_icd10,
                               c("I21.xx", "I22.xx"),
                               condition = rep(TRUE, length(ami_icd10)),
                               outcome   = rep(TRUE, length(ami_icd10))
                             )
                           )
                         )))

# spec_very_high_risk_ascvd: Very High-Risk for Future ASCVD Events ----
# Defined by 2+ major ASCVD events OR 1 event + ≥2 high-risk conditions.
# Placed here (after spec_ami, spec_racs, spec_cr, spec_pad_symptomatic) so
# all component specs are available when this composite is constructed.
spec_very_high_risk_ascvd <- CompositeCodeSpec$new(condition = "very_high_risk_ascvd",
                                                   label     = "Very High-Risk for Future ASCVD Events",
                                                   versions  = list(v1 = list(
                                                     defs = list(
                                                       condition = paste0(
                                                         "Defined by: (A) \u22652 major ASCVD events, OR (B) 1 major ASCVD event PLUS ",
                                                         "\u22652 high-risk conditions. ",
                                                         "Major ASCVD events (each counted separately): ",
                                                         "recent ACS within 12 months (spec_racs), AMI (spec_ami), ischemic stroke ",
                                                         "(spec_isch_stroke), CHD/coronary revascularization (spec_cr), heart failure ",
                                                         "(spec_hf), symptomatic PAD (spec_pad_symptomatic). ",
                                                         "High-risk conditions: familial hypercholesterolemia (spec_familial_hypercholesterolemia), ",
                                                         "prior CR (spec_cr), diabetes (spec_diabetes v2), HTN (spec_htn v1), ",
                                                         "CKD (spec_ckd), current smoking (spec_smoking), HF (spec_hf). ",
                                                         "The code sets stored here are the union of all major event code sets. ",
                                                         "The event counting and condition-OR logic must be applied in the analysis workflow."
                                                       ),
                                                       outcome = paste0(
                                                         "Same code set — very high-risk ASCVD can also be used as an outcome endpoint."
                                                       )
                                                     ),
                                                     components = list(
                                                       condition = list(
                                                         racs        = comp(spec_racs, "v1"),
                                                         ami         = comp(spec_ami, "v1"),
                                                         isch_stroke = comp(spec_isch_stroke_v1, "v1"),
                                                         stroke      = comp(spec_stroke_v1, "v1"),
                                                         cr          = comp(spec_cr, "v1"),
                                                         hf          = comp(spec_hf_v1, "v1"),
                                                         pad_symp    = comp(spec_pad_symptomatic, "v1")
                                                       ),
                                                       outcome = list(
                                                         racs        = comp(spec_racs, "v1"),
                                                         ami         = comp(spec_ami, "v1"),
                                                         isch_stroke = comp(spec_isch_stroke_v1, "v1"),
                                                         stroke      = comp(spec_stroke_v1, "v1"),
                                                         cr          = comp(spec_cr, "v1"),
                                                         hf          = comp(spec_hf_v1, "v1"),
                                                         pad_symp    = comp(spec_pad_symptomatic, "v1")
                                                       )
                                                     )
                                                   )))

# spec_aki: Acute Kidney Injury ----
# Source: "Acute kidney injury, version 1"
# ICD-9: 584.x; ICD-10: N17.x
# Algorithm: ≥1 inpatient OR ≥1 outpatient E&M claim

aki_icd9  <- expand9("584")
aki_icd10 <- expand10("N17")

spec_aki <- CodeSpec$new(condition = "aki",
                         label     = "Acute Kidney Injury",
                         versions  = list(v1 = list(
                           defs = list(
                             condition = paste0(
                               "\u22651 inpatient claim or \u22651 outpatient claim linked to a physician ",
                               "evaluation and management code with an ICD-9 diagnosis of 584.x or an ",
                               "ICD-10 diagnosis of N17.x in any diagnosis position."
                             ),
                             outcome = NULL
                           ),
                           codes = list(
                             dx_icd9  = make_key(
                               aki_icd9,
                               c("584.x"),
                               condition = rep(TRUE, length(aki_icd9)),
                               outcome   = rep(FALSE, length(aki_icd9))
                             ),
                             dx_icd10 = make_key(
                               aki_icd10,
                               c("N17.x"),
                               condition = rep(TRUE, length(aki_icd10)),
                               outcome   = rep(FALSE, length(aki_icd10))
                             )
                           )
                         )))


# spec_anemia: Anemia ----
# Source: "Anemia, history, version 1"
# ICD codes listed explicitly in document (no wildcards)
# Algorithm: ≥1 claim in any position from inpatient, outpatient, carrier,
#   SNF, and HHA files

parse_doc_icd <- function(txt) {
  raw   <- trimws(strsplit(sub("\\.$", "", txt), ",")[[1]])
  codes <- gsub("\\.", "", raw)
  codes[nchar(codes) > 0]
}

anemia_icd9  <- parse_doc_icd(texts[182])
anemia_icd10 <- parse_doc_icd(texts[183])

spec_anemia <- CodeSpec$new(condition = "anemia",
                            label     = "Anemia",
                            versions  = list(v1 = list(
                              defs = list(
                                condition = paste0(
                                  "\u22651 claim with a diagnosis code for anemia (ICD-9 codes 280.x-285.x ",
                                  "range; ICD-10 codes D50.x-D64.x range; see spec for full enumeration) ",
                                  "in any diagnosis position from inpatient, outpatient, carrier, SNF, ",
                                  "or HHA files."
                                ),
                                outcome = NULL
                              ),
                              codes = list(
                                dx_icd9  = make_key(
                                  anemia_icd9,
                                  anemia_icd9,
                                  condition = rep(TRUE, length(anemia_icd9)),
                                  outcome   = rep(FALSE, length(anemia_icd9))
                                ),
                                dx_icd10 = make_key(
                                  anemia_icd10,
                                  anemia_icd10,
                                  condition = rep(TRUE, length(anemia_icd10)),
                                  outcome   = rep(FALSE, length(anemia_icd10))
                                )
                              )
                            )))


# spec_af: Atrial Fibrillation ----
# Source: "Atrial fibrillation (AF), history, version 1"
# ICD-9: 427.31 (AF), 427.32 (atrial flutter)
# ICD-10: I48.0, I48.3, I48.4, I48.91, I48.92, I48.1x, I48.2x
# Note: document labels the ICD-9 algorithm "HF" — this is a typo; codes
#   427.31 and 427.32 are AF/flutter, not heart failure.
# Algorithm: ≥1 hospitalization OR ≥1 outpatient/carrier claim (any position)

af_icd9  <- c("42731", "42732")
af_icd10 <- unique(c(
  "I480",
  "I483",
  "I484",
  "I4891",
  "I4892",
  expand10("I481"),
  expand10("I482")
))

spec_af <- CodeSpec$new(condition = "af",
                        label     = "Atrial Fibrillation (AF)",
                        versions  = list(v1 = list(
                          defs = list(
                            condition = paste0(
                              "Any of the following: ",
                              "(a) \u22651 hospitalization with an ICD-9 discharge diagnosis of 427.31 or ",
                              "427.32 (AF or atrial flutter) in any discharge diagnosis position; ",
                              "(b) \u22651 outpatient or carrier claim with the same ICD-9 codes in any ",
                              "position. ICD-10 equivalents: I48.0, I48.1x, I48.2x, I48.3, I48.4, ",
                              "I48.91, I48.92."
                            ),
                            outcome = NULL
                          ),
                          codes = list(
                            dx_icd9  = make_key(
                              af_icd9,
                              c("427.31", "427.32"),
                              condition = rep(TRUE, length(af_icd9)),
                              outcome   = rep(FALSE, length(af_icd9))
                            ),
                            dx_icd10 = make_key(
                              af_icd10,
                              c(
                                "I48.0",
                                "I48.1x",
                                "I48.2x",
                                "I48.3",
                                "I48.4",
                                "I48.91",
                                "I48.92"
                              ),
                              condition = rep(TRUE, length(af_icd10)),
                              outcome   = rep(FALSE, length(af_icd10))
                            )
                          )
                        )))


# spec_antiarrhythmic: Anti-Arrhythmic medications ----
# Source: "Anti-Arrhythmic, version 1, from FDB"
# GNNs are substring search terms from document index(upcase(GNN), ...) calls

spec_antiarrhythmic <- DrugSpec$new(drug_class = "antiarrhythmic",
                                    label      = "Anti-Arrhythmic Medications",
                                    versions   = list(v1 = list(
                                      defs = paste0(
                                        "From First Data Bank (FDB). Identified via GNN substring match. ",
                                        "Document search terms: AMIODARONE, BRETYLIUM TOSYLATE, DILTIAZEM, ",
                                        "DISOPYRAMIDE, DOFETILIDE, DRONEDARONE, ESMOLOL, FLECAINIDE, ",
                                        "IBUTILIDE FUMARATE, LIDOCAINE, MEXILETINE, MORICIZINE, PROCAINAMIDE, ",
                                        "PROPAFENONE, QUINIDINE, SOTALOL, TOCAINIDE, ADENOSINE, VERAPAMIL, ",
                                        "PHENYTOIN."
                                      ),
                                      generic_names = c(
                                        "AMIODARONE",
                                        "BRETYLIUM TOSYLATE",
                                        "DILTIAZEM",
                                        "DISOPYRAMIDE",
                                        "DOFETILIDE",
                                        "DRONEDARONE",
                                        "ESMOLOL",
                                        "FLECAINIDE",
                                        "IBUTILIDE FUMARATE",
                                        "LIDOCAINE",
                                        "MEXILETINE",
                                        "MORICIZINE",
                                        "PROCAINAMIDE",
                                        "PROPAFENONE",
                                        "QUINIDINE",
                                        "SOTALOL",
                                        "TOCAINIDE",
                                        "ADENOSINE",
                                        "VERAPAMIL",
                                        "PHENYTOIN"
                                      ),
                                      ndc = character(0L)
                                    )))


# spec_beta_cardio_nonselect: Beta blockers: cardioselective + noncardioselective ----
# Source: "Beta_cardio_nonselect" section — GNNs: ATENOLOL, BETAXOLOL,
#   BISOPROLOL, METOPROLOL (cardioselective) + NADOLOL, PROPRANOLOL (noncardioselective)
# Implemented as a CompositeDrugSpec of existing leaf specs.

spec_beta_cardio_nonselect <- CompositeDrugSpec$new(drug_class = "beta_cardio_nonselect",
                                                    label      = "Beta Blockers (Cardioselective + Noncardioselective)",
                                                    versions   = list(v1 = list(
                                                      defs = paste0(
                                                        "Union of cardioselective and noncardioselective beta blockers. ",
                                                        "Document GNNs: ATENOLOL, BETAXOLOL, BISOPROLOL, METOPROLOL ",
                                                        "(cardioselective) and NADOLOL, PROPRANOLOL (noncardioselective). ",
                                                        "Excludes ISA beta blockers (spec_beta_int_sym), vasodilatory ",
                                                        "(spec_beta_cardio_vasod), and alpha-beta blockers (spec_alpha_beta)."
                                                      ),
                                                      components = list(
                                                        cardio    = comp(spec_beta_cardio_v1, "v1"),
                                                        noncardio = comp(spec_beta_noncardio_v1, "v1")
                                                      )
                                                    )))


## STATIN DRUG SPECS ----
# Source: "Definition of conditions and medications_11262025.docx"
# Section: Statin, version 1
#
# The document identifies statins via GNN substring matching:
#   index(upcase(GNN), "ATORVASTATIN"), index(upcase(GNN), "ATORVAST"), etc.
# This captures base molecules AND any combination products whose GNN contains
# the statin name (e.g., AMLODIPINE/ATORVASTATIN, EZETIMIBE/SIMVASTATIN).
#
# Each leaf spec stores the representative GNNs for that molecule. The defs
# text notes that matching is substring-based in claims data workflows.
#
# Special NDC overrides in the document:
#   NDC 54569595100 → AMLODIPINE/ATORVASTATIN  (caught by ATORVASTATIN match)
#   NDC 55887036990 → LOVASTATIN               (caught by LOVASTATIN match)

statin_defs_note <- paste0(
  "Identified via GNN substring match: any GNN containing the molecule name ",
  "qualifies, including combination products (e.g., EZETIMIBE/SIMVASTATIN, ",
  "AMLODIPINE/ATORVASTATIN). Two NDC-level overrides in the source document ",
  "(NDC 54569595100 \u2192 AMLODIPINE/ATORVASTATIN; NDC 55887036990 \u2192 LOVASTATIN) ",
  "are already captured by substring matching."
)

# GNNs are the exact search terms from the document's index(upcase(GNN), ...)
# calls — no additional FDB-derived products are added beyond what the document
# specifies. The NDC-override product (AMLODIPINE/ATORVASTATIN) is included in
# the atorvastatin spec as it is explicitly named in the document.

spec_statin_atorvastatin_v1 <- DrugSpec$new("statin_atorvastatin", "Statins \u2014 Atorvastatin",  version = "v1", defs = paste0("Atorvastatin. ", statin_defs_note, " Search: ATORVASTATIN, ATORVAST. NDC 54569595100 \u2192 AMLODIPINE/ATORVASTATIN."), generic_names = c("ATORVASTATIN","ATORVAST","AMLODIPINE/ATORVASTATIN"))
spec_statin_fluvastatin_v1  <- DrugSpec$new("statin_fluvastatin",  "Statins \u2014 Fluvastatin",   version = "v1", defs = paste0("Fluvastatin. ",  statin_defs_note, " Search: FLUVASTATIN."),  generic_names = c("FLUVASTATIN"))
spec_statin_lovastatin_v1   <- DrugSpec$new("statin_lovastatin",   "Statins \u2014 Lovastatin",    version = "v1", defs = paste0("Lovastatin. ",   statin_defs_note, " Search: LOVASTATIN. NDC 55887036990 \u2192 LOVASTATIN."), generic_names = c("LOVASTATIN"))
spec_statin_pitavastatin_v1 <- DrugSpec$new("statin_pitavastatin", "Statins \u2014 Pitavastatin",  version = "v1", defs = paste0("Pitavastatin. ", statin_defs_note, " Search: PITAVASTATIN."), generic_names = c("PITAVASTATIN"))
spec_statin_pravastatin_v1  <- DrugSpec$new("statin_pravastatin",  "Statins \u2014 Pravastatin",   version = "v1", defs = paste0("Pravastatin. ",  statin_defs_note, " Search: PRAVASTATIN."),  generic_names = c("PRAVASTATIN"))
spec_statin_rosuvastatin_v1 <- DrugSpec$new("statin_rosuvastatin", "Statins \u2014 Rosuvastatin",  version = "v1", defs = paste0("Rosuvastatin. ", statin_defs_note, " Search: ROSUVASTATIN."), generic_names = c("ROSUVASTATIN"))
spec_statin_simvastatin_v1  <- DrugSpec$new("statin_simvastatin",  "Statins \u2014 Simvastatin",   version = "v1", defs = paste0("Simvastatin. ",  statin_defs_note, " Search: SIMVASTATIN."),  generic_names = c("SIMVASTATIN"))

spec_statin <- CompositeDrugSpec$new(
  drug_class = "statin",
  label      = "Statins (HMG-CoA Reductase Inhibitors)",
  defs       = paste0("All statin subclasses (v1): atorvastatin, fluvastatin, lovastatin, ",
                      "pitavastatin, pravastatin, rosuvastatin, simvastatin (including combos). ",
                      statin_defs_note),
  components = list(
    atorvastatin_v1  = spec_statin_atorvastatin_v1,
    fluvastatin_v1   = spec_statin_fluvastatin_v1,
    lovastatin_v1    = spec_statin_lovastatin_v1,
    pitavastatin_v1  = spec_statin_pitavastatin_v1,
    pravastatin_v1   = spec_statin_pravastatin_v1,
    rosuvastatin_v1  = spec_statin_rosuvastatin_v1,
    simvastatin_v1   = spec_statin_simvastatin_v1
  )
)


# spec_ckd: Chronic Kidney Disease ----
# Source: "Definition of conditions and medications_11262025.docx"
# Section: Chronic kidney disease (CKD), history, version 1
#
# CKD is a condition-only definition (no separate outcome).
# Algorithm: ≥1 inpatient claim OR ≥1 E&M-linked outpatient claim with these
# ICD codes in any diagnosis position. For Medicare data, ESRD_IND = "Y" in
# the Master Beneficiary Summary File is an additional qualifying criterion
# (note: stored in defs text only — not representable as a code set).
