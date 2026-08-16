# Retrieve ICD codes for obesity hypoventilation syndrome

Retrieve ICD codes for obesity hypoventilation syndrome

## Usage

``` r
get_ohs_v1_codes(
  code_type = NULL,
  variable_type = c("condition", "outcome"),
  periods = FALSE,
  priority = 1L
)

get_ohs_v1_defs(variable_type = c("condition", "outcome"))
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

`get_ohs_v1_defs()`, `spec_ohs_v1`

## Examples

``` r
get_ohs_v1_codes()
#> # A tibble: 2 × 4
#>   type     code  priority version
#>   <chr>    <chr>    <int> <chr>  
#> 1 dx_icd9  27803        1 v1     
#> 2 dx_icd10 E662         1 v1     
```
