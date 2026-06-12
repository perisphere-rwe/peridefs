# Retrieve ICD codes for obesity

Returns code sets from the obesity
[CodeSpec](https://perisphere-rwe.github.io/peridefs/reference/CodeSpec.md)
(`spec_obesity_v1`). Condition only — no outcome definition.

## Usage

``` r
get_obesity_v1_codes(
  code_type = NULL,
  variable_type = c("condition", "outcome"),
  periods = FALSE,
  format = c("list", "tibble"),
  component = NULL
)

get_obesity_v1_defs(
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

`get_obesity_v1_defs()`, `spec_obesity_v1`

## Examples

``` r
get_obesity_v1_codes()
#> $dx_icd10
#>  [1] "E6601" "E663"  "E669"  "R939"  "Z6825" "Z6826" "Z6827" "Z6828" "Z6829"
#> [10] "Z6830" "Z6831" "Z6832" "Z6833" "Z6834" "Z6835" "Z6836" "Z6837" "Z6838"
#> [19] "Z6839" "Z6841" "Z6842" "Z6843" "Z6844" "Z6845"
#> 
```
