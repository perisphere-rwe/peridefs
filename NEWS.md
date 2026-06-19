# peridefs 0.2.0 (in development)

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

# peridefs 0.1.0

* Initial development version.
