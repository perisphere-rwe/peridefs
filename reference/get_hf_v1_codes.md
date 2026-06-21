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
  format = c("list", "tibble"),
  concatenate = FALSE
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

- format:

  `"list"` (default) returns a named list of character vectors.
  `"tibble"` returns a long-form tibble with columns `code_type`,
  `code`, and `variable_type`.

- concatenate:

  Logical. `FALSE` (default) returns a named list of character vectors.
  `TRUE` concatenates all code vectors into a single unnamed character
  vector. Not compatible with `format = "tibble"`.

## See also

[`get_hf_v1_defs()`](https://perisphere-rwe.github.io/peridefs/reference/get_hf_v1_defs.md),
`spec_hf_v1`

## Examples

``` r
get_hf_v1_codes()
#> $dx_icd9
#>  [1] "40201" "40211" "40291" "40401" "40403" "40411" "40413" "40491" "40493"
#> [10] "428"   "4280"  "4281"  "4282"  "42820" "42821" "42822" "42823" "4283" 
#> [19] "42830" "42831" "42832" "42833" "4284"  "42840" "42841" "42842" "42843"
#> [28] "4289" 
#> 
#> $dx_icd10
#>  [1] "I110"   "I130"   "I132"   "I501"   "I5020"  "I5021"  "I5022"  "I5023" 
#>  [9] "I5030"  "I5031"  "I5032"  "I5033"  "I5040"  "I5041"  "I5042"  "I5043" 
#> [17] "I509"   "I50810" "I50814" "I50811" "I50812" "I50813" "I5082"  "I5083" 
#> [25] "I5084"  "I5089" 
#> 
get_hf_v1_codes(variable_type = "outcome")
#> $dx_icd9
#>  [1] "40201" "40211" "40291" "40401" "40403" "40411" "40413" "40491" "40493"
#> [10] "428"   "4280"  "4281"  "4282"  "42820" "42821" "42822" "42823" "4283" 
#> [19] "42830" "42831" "42832" "42833" "4284"  "42840" "42841" "42842" "42843"
#> [28] "4289" 
#> 
#> $dx_icd10
#>  [1] "I110"   "I130"   "I132"   "I501"   "I5020"  "I5021"  "I5022"  "I5023" 
#>  [9] "I5030"  "I5031"  "I5032"  "I5033"  "I5040"  "I5041"  "I5042"  "I5043" 
#> [17] "I509"   "I50810" "I50814" "I50811" "I50812" "I50813" "I5082"  "I5083" 
#> [25] "I5084"  "I5089" 
#> 
```
