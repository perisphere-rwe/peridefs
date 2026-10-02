# Retrieve ICD codes for heart failure

Returns code sets from the heart failure
[CodeSpec](https://perisphere-rwe.github.io/peridefs/reference/CodeSpec.md)
(`spec_hf_v1`). Heart failure is both a condition and an outcome
definition.

## Usage

``` r
get_hf_v1_codes(
  code_type = NULL,
  variable_type = c("condition", "outcome"),
  periods = FALSE,
  priority = 1L
)
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

[`get_hf_v1_defs()`](https://perisphere-rwe.github.io/peridefs/reference/get_hf_v1_defs.md),
`spec_hf_v1`

## Examples

``` r
get_hf_v1_codes()
#> # A tibble: 54 × 5
#>    type    code  priority version definition                                    
#>    <chr>   <chr>    <int> <chr>   <chr>                                         
#>  1 dx_icd9 40201        1 v1      Malignant hypertensive heart disease with hea…
#>  2 dx_icd9 40211        1 v1      Benign hypertensive heart disease with heart …
#>  3 dx_icd9 40291        1 v1      Unspecified hypertensive heart disease with h…
#>  4 dx_icd9 40401        1 v1      Hypertensive heart and chronic kidney disease…
#>  5 dx_icd9 40403        1 v1      Hypertensive heart and chronic kidney disease…
#>  6 dx_icd9 40411        1 v1      Hypertensive heart and chronic kidney disease…
#>  7 dx_icd9 40413        1 v1      Hypertensive heart and chronic kidney disease…
#>  8 dx_icd9 40491        1 v1      Hypertensive heart and chronic kidney disease…
#>  9 dx_icd9 40493        1 v1      Hypertensive heart and chronic kidney disease…
#> 10 dx_icd9 428          1 v1      Heart failure                                 
#> # ℹ 44 more rows
get_hf_v1_codes(variable_type = "outcome")
#> # A tibble: 54 × 5
#>    type    code  priority version definition                                    
#>    <chr>   <chr>    <int> <chr>   <chr>                                         
#>  1 dx_icd9 40201        1 v1      Malignant hypertensive heart disease with hea…
#>  2 dx_icd9 40211        1 v1      Benign hypertensive heart disease with heart …
#>  3 dx_icd9 40291        1 v1      Unspecified hypertensive heart disease with h…
#>  4 dx_icd9 40401        1 v1      Hypertensive heart and chronic kidney disease…
#>  5 dx_icd9 40403        1 v1      Hypertensive heart and chronic kidney disease…
#>  6 dx_icd9 40411        1 v1      Hypertensive heart and chronic kidney disease…
#>  7 dx_icd9 40413        1 v1      Hypertensive heart and chronic kidney disease…
#>  8 dx_icd9 40491        1 v1      Hypertensive heart and chronic kidney disease…
#>  9 dx_icd9 40493        1 v1      Hypertensive heart and chronic kidney disease…
#> 10 dx_icd9 428          1 v1      Heart failure                                 
#> # ℹ 44 more rows
```
