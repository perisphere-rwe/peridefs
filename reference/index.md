# Package index

## Spec Data Objects

All exported `spec_*` data objects. Each version of a condition or drug
class is a distinct `_vX`-named object. Composite specs contain named
versioned components accessible via `component=` (or `component = "all"`
to union everything). Print any spec to see its definitions and
component names.

- [`spec_objects`](https://perisphere-rwe.github.io/peridefs/reference/spec_objects.md)
  [`spec_depression`](https://perisphere-rwe.github.io/peridefs/reference/spec_objects.md)
  [`spec_hyperlipidemia`](https://perisphere-rwe.github.io/peridefs/reference/spec_objects.md)
  [`spec_diabetes`](https://perisphere-rwe.github.io/peridefs/reference/spec_objects.md)
  [`spec_asthma_v1`](https://perisphere-rwe.github.io/peridefs/reference/spec_objects.md)
  [`spec_hypertension`](https://perisphere-rwe.github.io/peridefs/reference/spec_objects.md)
  [`spec_obesity`](https://perisphere-rwe.github.io/peridefs/reference/spec_objects.md)
  [`spec_ascvd`](https://perisphere-rwe.github.io/peridefs/reference/spec_objects.md)
  [`spec_ckd_v1`](https://perisphere-rwe.github.io/peridefs/reference/spec_objects.md)
  [`spec_copd_v1`](https://perisphere-rwe.github.io/peridefs/reference/spec_objects.md)
  [`spec_depression_v1`](https://perisphere-rwe.github.io/peridefs/reference/spec_objects.md)
  [`spec_diabetes_v1`](https://perisphere-rwe.github.io/peridefs/reference/spec_objects.md)
  [`spec_hf_v1`](https://perisphere-rwe.github.io/peridefs/reference/spec_objects.md)
  [`spec_hypertension_v1`](https://perisphere-rwe.github.io/peridefs/reference/spec_objects.md)
  [`spec_hyperlipidemia_v1`](https://perisphere-rwe.github.io/peridefs/reference/spec_objects.md)
  [`spec_isch_stroke_v1`](https://perisphere-rwe.github.io/peridefs/reference/spec_objects.md)
  [`spec_obesity_v1`](https://perisphere-rwe.github.io/peridefs/reference/spec_objects.md)
  [`spec_ohs_v1`](https://perisphere-rwe.github.io/peridefs/reference/spec_objects.md)
  [`spec_osa_v1`](https://perisphere-rwe.github.io/peridefs/reference/spec_objects.md)
  : Condition and Drug Code Specification Objects

## Conditions: Cardiovascular

Hypertension, heart failure, and the ASCVD composite. ASCVD components
(`chd_v1`, `stroke_v1`, `isch_stroke_v1`, `hf_v1`,
`cerebrovasc_disease_v1`) are accessible via
`get_ascvd_codes(component = ...)`.

- [`get_hypertension_v1_codes()`](https://perisphere-rwe.github.io/peridefs/reference/get_hypertension_v1_codes.md)
  : Retrieve ICD codes for hypertension
- [`get_hypertension_v1_defs()`](https://perisphere-rwe.github.io/peridefs/reference/get_hypertension_v1_defs.md)
  : Retrieve the narrative algorithm description for hypertension (v1)
- [`get_hf_v1_codes()`](https://perisphere-rwe.github.io/peridefs/reference/get_hf_v1_codes.md)
  : Retrieve ICD codes for heart failure
- [`get_hf_v1_defs()`](https://perisphere-rwe.github.io/peridefs/reference/get_hf_v1_defs.md)
  : Retrieve the narrative algorithm description for heart failure (v1)
- [`get_ascvd_codes()`](https://perisphere-rwe.github.io/peridefs/reference/get_ascvd_codes.md)
  : Retrieve codes for a named ASCVD component
- [`get_ascvd_defs()`](https://perisphere-rwe.github.io/peridefs/reference/get_ascvd_defs.md)
  : Retrieve the narrative algorithm description for an ASCVD component

## Conditions: Metabolic & Renal

Obesity, diabetes, hyperlipidemia, and CKD.

- [`get_obesity_v1_codes()`](https://perisphere-rwe.github.io/peridefs/reference/get_obesity_v1_codes.md)
  [`get_obesity_v1_defs()`](https://perisphere-rwe.github.io/peridefs/reference/get_obesity_v1_codes.md)
  : Retrieve ICD codes for obesity
- [`get_diabetes_v1_codes()`](https://perisphere-rwe.github.io/peridefs/reference/get_diabetes_v1_codes.md)
  [`get_diabetes_v1_defs()`](https://perisphere-rwe.github.io/peridefs/reference/get_diabetes_v1_codes.md)
  : Retrieve ICD codes for diabetes mellitus
- [`get_hyperlipidemia_v1_codes()`](https://perisphere-rwe.github.io/peridefs/reference/get_hyperlipidemia_v1_codes.md)
  [`get_hyperlipidemia_v1_defs()`](https://perisphere-rwe.github.io/peridefs/reference/get_hyperlipidemia_v1_codes.md)
  : Retrieve ICD codes for hyperlipidemia
- [`get_ckd_v1_codes()`](https://perisphere-rwe.github.io/peridefs/reference/get_ckd_v1_codes.md)
  [`get_ckd_v1_defs()`](https://perisphere-rwe.github.io/peridefs/reference/get_ckd_v1_codes.md)
  : Retrieve ICD codes for chronic kidney disease

## Conditions: Respiratory

COPD (v1) and sleep apnea (v1).

- [`get_copd_v1_codes()`](https://perisphere-rwe.github.io/peridefs/reference/get_copd_v1_codes.md)
  [`get_copd_v1_defs()`](https://perisphere-rwe.github.io/peridefs/reference/get_copd_v1_codes.md)
  : Retrieve ICD codes for COPD
- [`get_osa_v1_codes()`](https://perisphere-rwe.github.io/peridefs/reference/get_osa_v1_codes.md)
  [`get_osa_v1_defs()`](https://perisphere-rwe.github.io/peridefs/reference/get_osa_v1_codes.md)
  : Retrieve ICD codes for sleep apnea
- [`get_ohs_v1_codes()`](https://perisphere-rwe.github.io/peridefs/reference/get_ohs_v1_codes.md)
  [`get_ohs_v1_defs()`](https://perisphere-rwe.github.io/peridefs/reference/get_ohs_v1_codes.md)
  : Retrieve ICD codes for obesity hypoventilation syndrome
- [`get_asthma_v1_codes()`](https://perisphere-rwe.github.io/peridefs/reference/get_asthma_v1_codes.md)
  [`get_asthma_v1_defs()`](https://perisphere-rwe.github.io/peridefs/reference/get_asthma_v1_codes.md)
  : Retrieve ICD codes for asthma

## Conditions: Mental Health

Depression history (diagnosis or antidepressive medication).

- [`get_depression_v1_codes()`](https://perisphere-rwe.github.io/peridefs/reference/get_depression_v1_codes.md)
  [`get_depression_v1_defs()`](https://perisphere-rwe.github.io/peridefs/reference/get_depression_v1_codes.md)
  : Retrieve ICD codes for depression

## Drugs: Hypertension

ACE/ARBs, Beta-blockers, CCBs, diuretics, renin inhibitors, etc.

- [`get_hypertension_generics()`](https://perisphere-rwe.github.io/peridefs/reference/get_hypertension_generics.md)
  [`get_hypertension_meds_labels()`](https://perisphere-rwe.github.io/peridefs/reference/get_hypertension_generics.md)
  : Retrieve generic drug names for hypertension medications

## Drugs: Diabetes

Biguanides, sulfonylureas, meglitinides, TZDs, alpha-glucosidase
inhibitors, DPP-4, SGLT-2, GLP-1, insulin, etc.

- [`get_diabetes_generics()`](https://perisphere-rwe.github.io/peridefs/reference/get_diabetes_generics.md)
  [`get_diabetes_meds_labels()`](https://perisphere-rwe.github.io/peridefs/reference/get_diabetes_generics.md)
  : Retrieve generic drug names for diabetes medications

## Drugs: Obesity

Non-GLP-1 agents (`non_glp1_v1`: naltrexone/bupropion, orlistat) and
GLP-1 receptor agonists (`glp1_v1`: exenatide, dulaglutide, semaglutide,
liraglutide, tirzepatide).

- [`get_obesity_generics()`](https://perisphere-rwe.github.io/peridefs/reference/get_obesity_generics.md)
  [`get_obesity_meds_labels()`](https://perisphere-rwe.github.io/peridefs/reference/get_obesity_generics.md)
  : Retrieve generic drug names for obesity medications

## Drugs: Depression

SSRIs (`ssri_v1`), SNRIs (`snri_v1`), tricyclics (`tca_v1`), MAOIs
(`maoi_v1`), and other/atypical agents (`other_v1`).

- [`get_depression_generics()`](https://perisphere-rwe.github.io/peridefs/reference/get_depression_generics.md)
  [`get_depression_meds_labels()`](https://perisphere-rwe.github.io/peridefs/reference/get_depression_generics.md)
  : Retrieve generic drug names for depression medications

## Drugs: Hyperlipidemia

Statins (`statin_v1`), ezetimibe (`ezetimibe_v1`), PCSK9 inhibitors
(`pcsk9_v1`), fibrates (`fibrate_v1`), bile acid sequestrants
(`bile_acid_seq_v1`), and niacin (`niacin_v1`).

- [`get_hyperlipidemia_generics()`](https://perisphere-rwe.github.io/peridefs/reference/get_hyperlipidemia_generics.md)
  [`get_hyperlipidemia_meds_labels()`](https://perisphere-rwe.github.io/peridefs/reference/get_hyperlipidemia_generics.md)
  : Retrieve generic drug names for hyperlipidemia medications

## General Accessor

Low-level dispatcher that works on any spec object directly.

- [`get_defs()`](https://perisphere-rwe.github.io/peridefs/reference/get_defs.md)
  : Retrieve and display the narrative algorithm description

## Custom Spec API

Build your own code or drug specifications from scratch, or
non-destructively modify any bundled spec.

- [`code_spec()`](https://perisphere-rwe.github.io/peridefs/reference/code_spec.md)
  : Create a user-defined condition code specification
- [`drug_spec()`](https://perisphere-rwe.github.io/peridefs/reference/drug_spec.md)
  : Create a user-defined drug class specification
- [`add_codes()`](https://perisphere-rwe.github.io/peridefs/reference/add_codes.md)
  : Add codes to a condition code specification
- [`remove_codes()`](https://perisphere-rwe.github.io/peridefs/reference/remove_codes.md)
  : Remove codes from a condition code specification
- [`modify_code_spec()`](https://perisphere-rwe.github.io/peridefs/reference/modify_code_spec.md)
  : Modify a condition code specification
- [`modify_drug_spec()`](https://perisphere-rwe.github.io/peridefs/reference/modify_drug_spec.md)
  : Modify a drug class specification

## ICD-10-PCS Utilities

Expand ICD-10-PCS prefix patterns (e.g., `"0210xxx"`) to all matching
valid 7-character codes using the FY2026 CMS reference table.

- [`expand_pcs()`](https://perisphere-rwe.github.io/peridefs/reference/expand_pcs.md)
  : Expand ICD-10-PCS prefix patterns to all matching valid codes

## R6 Spec Classes

Underlying R6 classes used by all spec objects. Useful when building
custom specs programmatically.

- [`CodeSpec`](https://perisphere-rwe.github.io/peridefs/reference/CodeSpec.md)
  : R6 class for medical condition code specifications
- [`DrugSpec`](https://perisphere-rwe.github.io/peridefs/reference/DrugSpec.md)
  : R6 class for drug class specifications
- [`CompositeCodeSpec`](https://perisphere-rwe.github.io/peridefs/reference/CompositeCodeSpec.md)
  : R6 class for composite condition code specifications
- [`CompositeDrugSpec`](https://perisphere-rwe.github.io/peridefs/reference/CompositeDrugSpec.md)
  : R6 class for composite drug class specifications
