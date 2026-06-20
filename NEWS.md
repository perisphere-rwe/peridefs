# peridefs 0.2.0 

* Added `concatenate` argument (default `FALSE`) to all `get_*_codes()` functions.
  When `TRUE`, all code vectors are collapsed into a single unnamed character vector
  instead of a named list. Errors informatively if combined with `format = "tibble"`.

* `get_*_codes(variable_type = "outcome")` now falls back to condition codes for
  specs that have no outcome definition, rather than returning empty code sets.

* Added depression (history) specs: `spec_depression_v1` (diagnosis only) and
  `spec_depression_v2` (diagnosis or antidepressive medication), with accessor
  functions `get_depression_v1_codes()`, `get_depression_v2_codes()`, and
  corresponding `_defs()` variants.

* Exported `spec_antidepressive_v1` as a standalone spec with accessor functions
  `get_antidepressive_v1_generics()`, `get_antidepressive_v1_codes()`, and
  `get_antidepressive_v1_defs()`.

* Added `spec_antiobesity`, a composite drug spec ([CompositeDrugSpec]) combining
  `non_glp1_v1` (naltrexone/bupropion, orlistat) and `glp1_v1` (exenatide,
  dulaglutide, semaglutide, liraglutide, tirzepatide) components, with accessor
  functions `get_antiobesity_generics()`, `get_antiobesity_codes()`, and
  `get_antiobesity_defs()`.

* Added asthma spec `spec_asthma_v1` (ICD-9 493.xx, ICD-10 J45.xx; 20 and 26
  codes respectively), with accessor functions `get_asthma_v1_codes()` and
  `get_asthma_v1_defs()`.

# peridefs 0.1.0

* Initial development version.
