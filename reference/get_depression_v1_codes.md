# Retrieve ICD codes for depression

Returns code sets from a depression
[CodeSpec](https://perisphere-rwe.github.io/peridefs/reference/CodeSpec.md).
The condition definition is diagnosis-based, with a medication criterion
(see `spec_depression`) as an alternative qualifying path.

## Usage

``` r
get_depression_v1_codes(
  code_type = NULL,
  variable_type = c("condition", "outcome"),
  periods = FALSE,
  priority = 1L
)

get_depression_v1_defs(variable_type = c("condition", "outcome"))
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

`get_depression_v1_defs()`, `spec_depression_v1`

`get_depression_v1_codes()`

## Examples

``` r
get_depression_v1_codes()
#> # A tibble: 62 × 4
#>    type    code  priority version
#>    <chr>   <chr>    <int> <chr>  
#>  1 dx_icd9 29620        1 v1     
#>  2 dx_icd9 29621        1 v1     
#>  3 dx_icd9 29622        1 v1     
#>  4 dx_icd9 29623        1 v1     
#>  5 dx_icd9 29624        1 v1     
#>  6 dx_icd9 29625        1 v1     
#>  7 dx_icd9 29626        1 v1     
#>  8 dx_icd9 29630        1 v1     
#>  9 dx_icd9 29631        1 v1     
#> 10 dx_icd9 29632        1 v1     
#> # ℹ 52 more rows
get_depression_v1_codes(code_type = "dx_icd10")
#> # A tibble: 30 × 4
#>    type     code  priority version
#>    <chr>    <chr>    <int> <chr>  
#>  1 dx_icd10 F329         1 v1     
#>  2 dx_icd10 F320         1 v1     
#>  3 dx_icd10 F321         1 v1     
#>  4 dx_icd10 F322         1 v1     
#>  5 dx_icd10 F323         1 v1     
#>  6 dx_icd10 F324         1 v1     
#>  7 dx_icd10 F325         1 v1     
#>  8 dx_icd10 F339         1 v1     
#>  9 dx_icd10 F330         1 v1     
#> 10 dx_icd10 F331         1 v1     
#> # ℹ 20 more rows
```
