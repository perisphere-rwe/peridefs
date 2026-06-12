# Retrieve ICD codes for hypertension

Returns code sets from a hypertension
[CodeSpec](https://perisphere-rwe.github.io/peridefs/reference/CodeSpec.md).
Two versions are available:

- **v1** (diagnosis only): `get_htn_v1_codes()`

- **v2** (diagnosis + medication): `get_htn_v2_codes()`

## Usage

``` r
get_htn_v1_codes(
  code_type = NULL,
  variable_type = c("condition", "outcome"),
  periods = FALSE,
  format = c("list", "tibble"),
  component = NULL
)

get_htn_v2_codes(
  code_type = NULL,
  variable_type = c("condition", "outcome"),
  periods = FALSE,
  format = c("list", "tibble"),
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

## Value

Named list or tibble of codes.

## See also

[`get_htn_v1_defs()`](https://perisphere-rwe.github.io/peridefs/reference/get_htn_v1_defs.md),
`get_htn_v2_codes()`, `spec_htn_v1`

[`get_htn_v2_defs()`](https://perisphere-rwe.github.io/peridefs/reference/get_htn_v1_defs.md),
`get_htn_v1_codes()`, `spec_htn_v2`

## Examples

``` r
get_htn_v1_codes()
#> $dx_icd9
#>  [1] "401"   "4010"  "4011"  "4019"  "4030"  "40300" "40301" "4031"  "40310"
#> [10] "40311" "4039"  "40390" "40391"
#> 
#> $dx_icd10
#>  [1] "I10"   "I11"   "I110"  "I119"  "I12"   "I120"  "I129"  "I13"   "I130" 
#> [10] "I131"  "I1310" "I1311" "I132"  "I15"   "I150"  "I151"  "I152"  "I158" 
#> [19] "I159"  "I16"   "I160"  "I161"  "I169" 
#> 
get_htn_v1_codes(code_type = "dx_icd10", periods = TRUE)
#> $dx_icd10
#>  [1] "I10"    "I11"    "I11.0"  "I11.9"  "I12"    "I12.0"  "I12.9"  "I13"   
#>  [9] "I13.0"  "I13.1"  "I13.10" "I13.11" "I13.2"  "I15"    "I15.0"  "I15.1" 
#> [17] "I15.2"  "I15.8"  "I15.9"  "I16"    "I16.0"  "I16.1"  "I16.9" 
#> 
```
