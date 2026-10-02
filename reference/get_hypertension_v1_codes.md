# Retrieve ICD codes for hypertension

Returns code sets from a hypertension
[CodeSpec](https://perisphere-rwe.github.io/peridefs/reference/CodeSpec.md).
The condition definition is diagnosis-based, with a medication criterion
(see `spec_hypertension`) as an alternative qualifying path.

## Usage

``` r
get_hypertension_v1_codes(
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

## Value

A tibble with columns `type`, `code`, `priority`, `version`, and
`definition`.

## See also

[`get_hypertension_v1_defs()`](https://perisphere-rwe.github.io/peridefs/reference/get_hypertension_v1_defs.md),
`spec_hypertension_v1`

## Examples

``` r
get_hypertension_v1_codes()
#> # A tibble: 36 × 5
#>    type    code  priority version definition                                    
#>    <chr>   <chr>    <int> <chr>   <chr>                                         
#>  1 dx_icd9 401          1 v1      Essential hypertension                        
#>  2 dx_icd9 4010         1 v1      Malignant essential hypertension              
#>  3 dx_icd9 4011         1 v1      Benign essential hypertension                 
#>  4 dx_icd9 4019         1 v1      Unspecified essential hypertension            
#>  5 dx_icd9 4030         1 v1      Hypertensive chronic kidney disease: Malignant
#>  6 dx_icd9 40300        1 v1      Hypertensive chronic kidney disease, malignan…
#>  7 dx_icd9 40301        1 v1      Hypertensive chronic kidney disease, malignan…
#>  8 dx_icd9 4031         1 v1      Hypertensive chronic kidney disease: Benign   
#>  9 dx_icd9 40310        1 v1      Hypertensive chronic kidney disease, benign, …
#> 10 dx_icd9 40311        1 v1      Hypertensive chronic kidney disease, benign, …
#> # ℹ 26 more rows
get_hypertension_v1_codes(code_type = "dx_icd10", periods = TRUE)
#> # A tibble: 23 × 5
#>    type     code  priority version definition                                   
#>    <chr>    <chr>    <int> <chr>   <chr>                                        
#>  1 dx_icd10 I10          1 v1      Essential (primary) hypertension             
#>  2 dx_icd10 I11          1 v1      Hypertensive heart disease                   
#>  3 dx_icd10 I11.0        1 v1      Hypertensive heart disease with heart failure
#>  4 dx_icd10 I11.9        1 v1      Hypertensive heart disease without heart fai…
#>  5 dx_icd10 I12          1 v1      Hypertensive chronic kidney disease          
#>  6 dx_icd10 I12.0        1 v1      Hypertensive chronic kidney disease with sta…
#>  7 dx_icd10 I12.9        1 v1      Hypertensive chronic kidney disease with sta…
#>  8 dx_icd10 I13          1 v1      Hypertensive heart and chronic kidney disease
#>  9 dx_icd10 I13.0        1 v1      Hypertensive heart and chronic kidney diseas…
#> 10 dx_icd10 I13.1        1 v1      Hypertensive heart and chronic kidney diseas…
#> # ℹ 13 more rows
```
