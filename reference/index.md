# Package index

## Spec Data Objects

All exported `spec_*` data objects. Each version of a condition or drug
class is a distinct `_vX`-named object. Composite specs contain named
versioned components accessible via `component=` (or `component = "all"`
to union everything). Print any spec to see its definitions and
component names.

- [`spec_objects`](https://perisphere-rwe.github.io/peridefs/reference/spec_objects.md)
  [`spec_antidiabetic`](https://perisphere-rwe.github.io/peridefs/reference/spec_objects.md)
  [`spec_antihypertensive`](https://perisphere-rwe.github.io/peridefs/reference/spec_objects.md)
  [`spec_ascvd`](https://perisphere-rwe.github.io/peridefs/reference/spec_objects.md)
  [`spec_ckd_v1`](https://perisphere-rwe.github.io/peridefs/reference/spec_objects.md)
  [`spec_copd_v1`](https://perisphere-rwe.github.io/peridefs/reference/spec_objects.md)
  [`spec_diabetes_v1`](https://perisphere-rwe.github.io/peridefs/reference/spec_objects.md)
  [`spec_diabetes_v2`](https://perisphere-rwe.github.io/peridefs/reference/spec_objects.md)
  [`spec_diabetes_v3`](https://perisphere-rwe.github.io/peridefs/reference/spec_objects.md)
  [`spec_hf_v1`](https://perisphere-rwe.github.io/peridefs/reference/spec_objects.md)
  [`spec_htn_v1`](https://perisphere-rwe.github.io/peridefs/reference/spec_objects.md)
  [`spec_htn_v2`](https://perisphere-rwe.github.io/peridefs/reference/spec_objects.md)
  [`spec_hyperlipidemia_v1`](https://perisphere-rwe.github.io/peridefs/reference/spec_objects.md)
  [`spec_isch_stroke_v1`](https://perisphere-rwe.github.io/peridefs/reference/spec_objects.md)
  [`spec_obesity_v1`](https://perisphere-rwe.github.io/peridefs/reference/spec_objects.md)
  [`spec_osa_v1`](https://perisphere-rwe.github.io/peridefs/reference/spec_objects.md)
  : Condition and Drug Code Specification Objects

## Conditions: Cardiovascular

Hypertension (v1, v2), heart failure (v1), and the ASCVD composite.
ASCVD components (`chd_v1`, `chd_v2`, `stroke_v1`, `isch_stroke_v1`,
`hf_v1`, `cerebrovasc_disease_v1`) are accessible via
`get_ascvd_codes(component = ...)`.

- [`get_htn_v1_codes()`](https://perisphere-rwe.github.io/peridefs/reference/get_htn_v1_codes.md)
  [`get_htn_v2_codes()`](https://perisphere-rwe.github.io/peridefs/reference/get_htn_v1_codes.md)
  : Retrieve ICD codes for hypertension
- [`get_htn_v1_defs()`](https://perisphere-rwe.github.io/peridefs/reference/get_htn_v1_defs.md)
  [`get_htn_v2_defs()`](https://perisphere-rwe.github.io/peridefs/reference/get_htn_v1_defs.md)
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

Obesity (v1), diabetes (v1–v3), hyperlipidemia (v1), and CKD (v1).

- [`get_obesity_v1_codes()`](https://perisphere-rwe.github.io/peridefs/reference/get_obesity_v1_codes.md)
  [`get_obesity_v1_defs()`](https://perisphere-rwe.github.io/peridefs/reference/get_obesity_v1_codes.md)
  : Retrieve ICD codes for obesity
- [`get_diabetes_v1_codes()`](https://perisphere-rwe.github.io/peridefs/reference/get_diabetes_v1_codes.md)
  [`get_diabetes_v1_defs()`](https://perisphere-rwe.github.io/peridefs/reference/get_diabetes_v1_codes.md)
  [`get_diabetes_v2_codes()`](https://perisphere-rwe.github.io/peridefs/reference/get_diabetes_v1_codes.md)
  [`get_diabetes_v2_defs()`](https://perisphere-rwe.github.io/peridefs/reference/get_diabetes_v1_codes.md)
  [`get_diabetes_v3_codes()`](https://perisphere-rwe.github.io/peridefs/reference/get_diabetes_v1_codes.md)
  [`get_diabetes_v3_defs()`](https://perisphere-rwe.github.io/peridefs/reference/get_diabetes_v1_codes.md)
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

## Drugs: Antihypertensives

ACE/ARBs, Beta-blockers, CCBs, diuretics, renin inhibitors, etc.

- [`get_antihypertensive_generics()`](https://perisphere-rwe.github.io/peridefs/reference/get_antihypertensive_generics.md)
  : Retrieve generic drug names for antihypertensive medications
- [`get_antihypertensive_codes()`](https://perisphere-rwe.github.io/peridefs/reference/drug_accessors.md)
  [`get_antihypertensive_defs()`](https://perisphere-rwe.github.io/peridefs/reference/drug_accessors.md)
  [`get_antidiabetic_codes()`](https://perisphere-rwe.github.io/peridefs/reference/drug_accessors.md)
  [`get_antidiabetic_defs()`](https://perisphere-rwe.github.io/peridefs/reference/drug_accessors.md)
  : Miscellaneous drug accessor functions

## Drugs: Antidiabetics

Biguanides, sulfonylureas, meglitinides, TZDs, alpha-glucosidase
inhibitors, DPP-4, SGLT-2,GLP-1, insulin, etc.

- [`get_antidiabetic_generics()`](https://perisphere-rwe.github.io/peridefs/reference/get_antidiabetic_generics.md)
  : Retrieve generic drug names for antidiabetic medications
- [`get_antihypertensive_codes()`](https://perisphere-rwe.github.io/peridefs/reference/drug_accessors.md)
  [`get_antihypertensive_defs()`](https://perisphere-rwe.github.io/peridefs/reference/drug_accessors.md)
  [`get_antidiabetic_codes()`](https://perisphere-rwe.github.io/peridefs/reference/drug_accessors.md)
  [`get_antidiabetic_defs()`](https://perisphere-rwe.github.io/peridefs/reference/drug_accessors.md)
  : Miscellaneous drug accessor functions

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
