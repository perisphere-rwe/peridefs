# Retrieve ICD codes for asthma

Retrieve ICD codes for asthma

## Usage

``` r
get_asthma_v1_codes(
  code_type = NULL,
  variable_type = c("condition", "outcome"),
  periods = FALSE,
  priority = 1L
)

get_asthma_v1_defs(variable_type = c("condition", "outcome"))
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

`get_asthma_v1_defs()`, `spec_asthma_v1`

## Examples

``` r
get_asthma_v1_codes()
#> # A tibble: 46 × 4
#>    type    code  priority version
#>    <chr>   <chr>    <int> <chr>  
#>  1 dx_icd9 493          1 v1     
#>  2 dx_icd9 4930         1 v1     
#>  3 dx_icd9 49300        1 v1     
#>  4 dx_icd9 49301        1 v1     
#>  5 dx_icd9 49302        1 v1     
#>  6 dx_icd9 4931         1 v1     
#>  7 dx_icd9 49310        1 v1     
#>  8 dx_icd9 49311        1 v1     
#>  9 dx_icd9 49312        1 v1     
#> 10 dx_icd9 4932         1 v1     
#> # ℹ 36 more rows
get_asthma_v1_codes(code_type = "dx_icd10")
#> # A tibble: 26 × 4
#>    type     code  priority version
#>    <chr>    <chr>    <int> <chr>  
#>  1 dx_icd10 J45          1 v1     
#>  2 dx_icd10 J452         1 v1     
#>  3 dx_icd10 J4520        1 v1     
#>  4 dx_icd10 J4521        1 v1     
#>  5 dx_icd10 J4522        1 v1     
#>  6 dx_icd10 J453         1 v1     
#>  7 dx_icd10 J4530        1 v1     
#>  8 dx_icd10 J4531        1 v1     
#>  9 dx_icd10 J4532        1 v1     
#> 10 dx_icd10 J454         1 v1     
#> # ℹ 16 more rows
```
