# Changelog

## peridefs (development version)

### Breaking changes

- Renamed all condition- and drug-related objects/functions built around
  hypertension and hyperlipidemia so they use the full condition name
  everywhere, instead of mixing an abbreviation (`htn`) with a
  drug-mechanism name (`lipid_lowering`) on one side and full condition
  names on the other:
  - `spec_htn_v1` -\> `spec_hypertension_v1`; `get_htn_v1_codes()` -\>
    [`get_hypertension_v1_codes()`](https://perisphere-rwe.github.io/peridefs/reference/get_hypertension_v1_codes.md);
    `get_htn_v1_defs()` -\>
    [`get_hypertension_v1_defs()`](https://perisphere-rwe.github.io/peridefs/reference/get_hypertension_v1_defs.md).
    The `CodeSpec`’s own `condition` identifier also changed from
    `"htn"` to `"hypertension"`.
  - The five composite `CompositeDrugSpec` objects are now named after
    the condition they treat rather than the drug mechanism class:
    `spec_antihypertensive` -\> `spec_hypertension`, `spec_antidiabetic`
    -\> `spec_diabetes`, `spec_antiobesity` -\> `spec_obesity`,
    `spec_antidepressive` -\> `spec_depression`, `spec_lipid_lowering`
    -\> `spec_hyperlipidemia` – along with their `get_*_generics()`/
    `get_*_defs()` accessor pairs
    (e.g. `get_antihypertensive_generics()` -\>
    [`get_hypertension_generics()`](https://perisphere-rwe.github.io/peridefs/reference/get_hypertension_generics.md);
    `get_antihypertensive_defs()` similarly became
    [`get_hypertension_meds_labels()`](https://perisphere-rwe.github.io/peridefs/reference/get_hypertension_generics.md),
    see below). Each object’s `drug_class` field
    (e.g. `"antihypertensive"`) is unchanged – it remains a distinct,
    drug-mechanism-based identifier, separate from `condition`.
- `CompositeDrugSpec$get_defs()` was replaced by
  `CompositeDrugSpec$get_meds_labels()`, and the five corresponding
  exported wrapper functions were renamed to match:
  `get_hypertension_defs()` -\>
  [`get_hypertension_meds_labels()`](https://perisphere-rwe.github.io/peridefs/reference/get_hypertension_generics.md),
  `get_diabetes_defs()` -\>
  [`get_diabetes_meds_labels()`](https://perisphere-rwe.github.io/peridefs/reference/get_diabetes_generics.md),
  `get_obesity_defs()` -\>
  [`get_obesity_meds_labels()`](https://perisphere-rwe.github.io/peridefs/reference/get_obesity_generics.md),
  `get_depression_defs()` -\>
  [`get_depression_meds_labels()`](https://perisphere-rwe.github.io/peridefs/reference/get_depression_generics.md),
  `get_hyperlipidemia_defs()` -\>
  [`get_hyperlipidemia_meds_labels()`](https://perisphere-rwe.github.io/peridefs/reference/get_hyperlipidemia_generics.md).
  These now return a tibble with columns `name` (the component key,
  e.g. `"acei_v1"`) and `label` (e.g. `"ACE Inhibitors"`) instead of a
  bare character vector/string, and no longer include version
  information in the output (already encoded in `name`). A drug leaf’s
  `defs` field is typically just an internal sourcing note
  (e.g. `"From the Perisphere antihypertensive medication list."`), not
  a clinical definition, and naming the composite accessor after the
  condition made it too easy to confuse with the condition side’s
  `get_*_v1_defs()`, which *does* return a real diagnostic-algorithm
  narrative — hence the move away from a `_defs()`-style name entirely.
  [`get_defs()`](https://perisphere-rwe.github.io/peridefs/reference/get_defs.md)
  (the general low-level dispatcher) still works on a
  `CompositeDrugSpec`, now returning this same tibble.
- The `class` column of `get_*_generics()` for the diabetes and
  hyperlipidemia composites no longer redundantly encodes the condition
  (e.g. `"antidiab_biguanide"`, `"ll_statin"`); it’s now just the
  unprefixed drug-mechanism class (`"biguanide"`, `"statin"`), matching
  the convention already used by the hypertension, obesity, and
  depression composites. The composite’s own `condition` column/field
  already supplies the condition context, so repeating it in `class` was
  redundant. This only changes the leaf `DrugSpec`’s `drug_class`
  identifier (and therefore the `class` output column) — the underlying
  R object variable names in `data-raw/build_specs.R` (e.g.
  `spec_antidiab_biguanide_v1`, `spec_ll_statin_v1`) are unchanged.

## peridefs 0.3.0

### Breaking changes

- Collapsed the hypertension, coronary heart disease (CHD), depression,
  and diabetes specs down to a single version each (issue
  [\#4](https://github.com/perisphere-rwe/peridefs/issues/4)).
  Previously, these specs had multiple versions (e.g.,
  `spec_htn_v1`/`spec_htn_v2`) that shared identical codes and differed
  only in the narrative `defs` text (e.g., whether a medication
  criterion was included); the remaining single version of each now
  carries the most complete (formerly highest-numbered) narrative. As a
  result, the following exported functions and package data objects have
  been **removed**: `get_htn_v2_codes()`, `get_htn_v2_defs()`,
  `spec_htn_v2`; `get_depression_v2_codes()`,
  `get_depression_v2_defs()`, `spec_depression_v2`;
  `get_diabetes_v2_codes()`, `get_diabetes_v2_defs()`,
  `get_diabetes_v3_codes()`, `get_diabetes_v3_defs()`,
  `spec_diabetes_v2`, `spec_diabetes_v3`; and the `spec_ascvd` composite
  no longer has a `"chd_v2"` component (only `"chd_v1"`, now carrying
  the merged definition). Use `get_htn_v1_codes()`,
  [`get_depression_v1_codes()`](https://perisphere-rwe.github.io/peridefs/reference/get_depression_v1_codes.md),
  and
  [`get_diabetes_v1_codes()`](https://perisphere-rwe.github.io/peridefs/reference/get_diabetes_v1_codes.md)
  (and their `_defs()` counterparts) going forward — they now return the
  most current definition.

- `CodeSpec$get_codes()`/`CompositeCodeSpec$get_codes()` output (and
  therefore
  [`get_ascvd_codes()`](https://perisphere-rwe.github.io/peridefs/reference/get_ascvd_codes.md)
  and similar composite accessors) no longer duplicates the version
  number inside the `class` column. `class` is now the component’s own
  unversioned condition identifier (e.g., `"chd"`), while `version`
  continues to hold the version tag (e.g., `"v1"`) separately —
  previously `class` held the full versioned component key (e.g.,
  `"chd_v1"`), which duplicated information already present in
  `version`. Any downstream code filtering on `class == "chd_v1"`-style
  values needs to filter on `class == "chd"` and `version == "v1"`
  instead.

## peridefs 0.2.0

- Added `concatenate` argument (default `FALSE`) to all `get_*_codes()`
  functions. When `TRUE`, all code vectors are collapsed into a single
  unnamed character vector instead of a named list. Errors informatively
  if combined with `format = "tibble"`.

- `get_*_codes(variable_type = "outcome")` now falls back to condition
  codes for specs that have no outcome definition, rather than returning
  empty code sets.

- Added depression (history) specs: `spec_depression_v1` (diagnosis
  only) and `spec_depression_v2` (diagnosis or antidepressive
  medication), with accessor functions
  [`get_depression_v1_codes()`](https://perisphere-rwe.github.io/peridefs/reference/get_depression_v1_codes.md),
  `get_depression_v2_codes()`, and corresponding `_defs()` variants.

- Exported `spec_antidepressive_v1` as a standalone spec with accessor
  functions `get_antidepressive_v1_generics()`,
  `get_antidepressive_v1_codes()`, and `get_antidepressive_v1_defs()`.

- Added `spec_antiobesity`, a composite drug spec
  (\[CompositeDrugSpec\]) combining `non_glp1_v1` (naltrexone/bupropion,
  orlistat) and `glp1_v1` (exenatide, dulaglutide, semaglutide,
  liraglutide, tirzepatide) components, with accessor functions
  `get_antiobesity_generics()`, `get_antiobesity_codes()`, and
  `get_antiobesity_defs()`.

- Added asthma spec `spec_asthma_v1` (ICD-9 493.xx, ICD-10 J45.xx; 20
  and 26 codes respectively), with accessor functions
  [`get_asthma_v1_codes()`](https://perisphere-rwe.github.io/peridefs/reference/get_asthma_v1_codes.md)
  and
  [`get_asthma_v1_defs()`](https://perisphere-rwe.github.io/peridefs/reference/get_asthma_v1_codes.md).

- Added obesity hypoventilation syndrome spec `spec_ohs_v1` (ICD-9
  278.03, ICD-10 E66.2; also covers Pickwickian syndrome), with accessor
  functions
  [`get_ohs_v1_codes()`](https://perisphere-rwe.github.io/peridefs/reference/get_ohs_v1_codes.md)
  and
  [`get_ohs_v1_defs()`](https://perisphere-rwe.github.io/peridefs/reference/get_ohs_v1_codes.md).

- All composite spec getter functions (`get_*_codes()`,
  `get_*_generics()`, `get_*_codes()` for drug specs) now accept a
  vector of component names to retrieve and union multiple components in
  one call (e.g.,
  `get_ascvd_codes(component = c("chd_v1", "stroke_v1"))`). Errors
  informatively if any component name is invalid.

- `get_*_generics()` and `get_*_codes()` for drug specs now return a
  **named list** by default (keyed by component name), consistent with
  the behaviour of `get_*_codes()` for condition specs. Pass
  `concatenate = TRUE` to flatten to an unnamed character vector (the
  previous default behaviour).

- `component` is no longer a visible parameter on getter functions for
  non-composite specs; it only appears in the signature of getters that
  actually require it.

## peridefs 0.1.0

- Initial development version.
