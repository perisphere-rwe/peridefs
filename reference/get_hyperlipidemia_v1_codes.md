# Retrieve ICD codes for hyperlipidemia

Retrieve ICD codes for hyperlipidemia

## Usage

``` r
get_hyperlipidemia_v1_codes(
  code_type = NULL,
  variable_type = c("condition", "outcome"),
  periods = FALSE,
  format = c("list", "tibble"),
  component = NULL
)

get_hyperlipidemia_v1_defs(
  variable_type = c("condition", "outcome"),
  component = NULL
)
```

## Arguments

- code_type:

  Optional character vector of code types to return. Valid values:
  `"dx_icd9"`, `"dx_icd10"`, `"proc_icd9"`, `"proc_icd10"`, `"hcpcs"`,
  `"cpt"`, `"rev"`. `NULL` (default) returns all code types.

- variable_type:

  `"condition"` (default) or `"outcome"`. Hypertension is defined as a
  condition only; `"outcome"` returns empty code sets.

- periods:

  Logical. `FALSE` (default) returns short-format codes (e.g.,
  `"4010"`). `TRUE` returns decimal-format codes (e.g., `"401.0"`).

- format:

  `"list"` (default) returns a named list of character vectors.
  `"tibble"` returns a long-form tibble with columns `code_type`,
  `code`, and `variable_type`.

- component:

  Not used for non-composite specs. Pass `NULL` (default).

## See also

`get_hyperlipidemia_v1_defs()`, `spec_hyperlipidemia_v1`
