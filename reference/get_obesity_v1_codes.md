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
  priority = 1L
)

get_obesity_v1_defs(variable_type = c("condition", "outcome"))
```

## Arguments

- code_type:

  Optional character vector of code types to return. Valid values:
  `"dx_icd9"`, `"dx_icd10"`, `"proc_icd9"`, `"proc_icd10"`, `"hcpcs"`,
  `"cpt"`, `"rev"`. `NULL` (default) returns all code types.

- variable_type:

  `"condition"` (default) or `"outcome"`. Hypertension is defined as a
  condition only; `"outcome"` falls back to condition codes.

- periods:

  Logical. `FALSE` (default) returns short-format codes (e.g.,
  `"4010"`). `TRUE` returns decimal-format codes (e.g., `"401.0"`).

- priority:

  Integer vector subsetting confidence tiers to include (`1` = core, `2`
  = probable, `3` = cautious). Default `1`.

## See also

`get_obesity_v1_defs()`, `spec_obesity_v1`

## Examples

``` r
get_obesity_v1_codes()
#> # A tibble: 24 × 4
#>    type     code  priority version
#>    <chr>    <chr>    <int> <chr>  
#>  1 dx_icd10 E6601        1 v1     
#>  2 dx_icd10 E663         1 v1     
#>  3 dx_icd10 E669         1 v1     
#>  4 dx_icd10 R939         1 v1     
#>  5 dx_icd10 Z6825        1 v1     
#>  6 dx_icd10 Z6826        1 v1     
#>  7 dx_icd10 Z6827        1 v1     
#>  8 dx_icd10 Z6828        1 v1     
#>  9 dx_icd10 Z6829        1 v1     
#> 10 dx_icd10 Z6830        1 v1     
#> # ℹ 14 more rows
```
