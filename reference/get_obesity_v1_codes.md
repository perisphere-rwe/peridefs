# Retrieve ICD codes for obesity

Returns code sets from the obesity
[CodeSpec](https://perisphere-rwe.github.io/peridefs/reference/CodeSpec.md)
(`spec_obesity_v1`). The same ICD-9 and ICD-10 code sets are used for
both the condition and outcome definitions.

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
#> # A tibble: 42 × 4
#>    type    code  priority version
#>    <chr>   <chr>    <int> <chr>  
#>  1 dx_icd9 27800        1 v1     
#>  2 dx_icd9 27801        1 v1     
#>  3 dx_icd9 27803        1 v1     
#>  4 dx_icd9 V8530        1 v1     
#>  5 dx_icd9 V8531        1 v1     
#>  6 dx_icd9 V8532        1 v1     
#>  7 dx_icd9 V8533        1 v1     
#>  8 dx_icd9 V8534        1 v1     
#>  9 dx_icd9 V8535        1 v1     
#> 10 dx_icd9 V8536        1 v1     
#> # ℹ 32 more rows
get_obesity_v1_codes(code_type = "dx_icd9")
#> # A tibble: 18 × 4
#>    type    code  priority version
#>    <chr>   <chr>    <int> <chr>  
#>  1 dx_icd9 27800        1 v1     
#>  2 dx_icd9 27801        1 v1     
#>  3 dx_icd9 27803        1 v1     
#>  4 dx_icd9 V8530        1 v1     
#>  5 dx_icd9 V8531        1 v1     
#>  6 dx_icd9 V8532        1 v1     
#>  7 dx_icd9 V8533        1 v1     
#>  8 dx_icd9 V8534        1 v1     
#>  9 dx_icd9 V8535        1 v1     
#> 10 dx_icd9 V8536        1 v1     
#> 11 dx_icd9 V8537        1 v1     
#> 12 dx_icd9 V8538        1 v1     
#> 13 dx_icd9 V8539        1 v1     
#> 14 dx_icd9 V8541        1 v1     
#> 15 dx_icd9 V8542        1 v1     
#> 16 dx_icd9 V8543        1 v1     
#> 17 dx_icd9 V8544        1 v1     
#> 18 dx_icd9 V8545        1 v1     
get_obesity_v1_codes(variable_type = "outcome")
#> # A tibble: 42 × 4
#>    type    code  priority version
#>    <chr>   <chr>    <int> <chr>  
#>  1 dx_icd9 27800        1 v1     
#>  2 dx_icd9 27801        1 v1     
#>  3 dx_icd9 27803        1 v1     
#>  4 dx_icd9 V8530        1 v1     
#>  5 dx_icd9 V8531        1 v1     
#>  6 dx_icd9 V8532        1 v1     
#>  7 dx_icd9 V8533        1 v1     
#>  8 dx_icd9 V8534        1 v1     
#>  9 dx_icd9 V8535        1 v1     
#> 10 dx_icd9 V8536        1 v1     
#> # ℹ 32 more rows
```
