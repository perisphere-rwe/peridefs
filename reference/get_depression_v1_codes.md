# Retrieve ICD codes for depression

Returns code sets from a depression
[CodeSpec](https://perisphere-rwe.github.io/peridefs/reference/CodeSpec.md).
Two versions are available:

- **v1** (diagnosis only): `get_depression_v1_codes()`

- **v2** (diagnosis + medication): `get_depression_v2_codes()`

## Usage

``` r
get_depression_v1_codes(
  code_type = NULL,
  variable_type = c("condition", "outcome"),
  periods = FALSE,
  format = c("list", "tibble"),
  concatenate = FALSE
)

get_depression_v1_defs(variable_type = c("condition", "outcome"))

get_depression_v2_codes(
  code_type = NULL,
  variable_type = c("condition", "outcome"),
  periods = FALSE,
  format = c("list", "tibble"),
  concatenate = FALSE
)

get_depression_v2_defs(variable_type = c("condition", "outcome"))
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

`get_depression_v1_defs()`, `get_depression_v2_codes()`,
`spec_depression_v1`

`get_depression_v1_codes()`

`get_depression_v2_defs()`, `get_depression_v1_codes()`,
`spec_depression_v2`

`get_depression_v2_codes()`

## Examples

``` r
get_depression_v1_codes()
#> $dx_icd9
#>  [1] "29620" "29621" "29622" "29623" "29624" "29625" "29626" "29630" "29631"
#> [10] "29632" "29633" "29634" "29635" "29636" "29651" "29652" "29653" "29654"
#> [19] "29655" "29656" "29660" "29661" "29662" "29663" "29664" "29665" "29666"
#> [28] "29689" "2980"  "3004"  "3091"  "311"  
#> 
#> $dx_icd10
#>  [1] "F329"  "F320"  "F321"  "F322"  "F323"  "F324"  "F325"  "F339"  "F330" 
#> [10] "F331"  "F332"  "F333"  "F3341" "F3342" "F3331" "F3132" "F314"  "F315" 
#> [19] "F3175" "F3176" "F3160" "F3161" "F3162" "F3163" "F3164" "F3177" "F3178"
#> [28] "F3181" "F341"  "F4321"
#> 
get_depression_v1_codes(code_type = "dx_icd10")
#> $dx_icd10
#>  [1] "F329"  "F320"  "F321"  "F322"  "F323"  "F324"  "F325"  "F339"  "F330" 
#> [10] "F331"  "F332"  "F333"  "F3341" "F3342" "F3331" "F3132" "F314"  "F315" 
#> [19] "F3175" "F3176" "F3160" "F3161" "F3162" "F3163" "F3164" "F3177" "F3178"
#> [28] "F3181" "F341"  "F4321"
#> 
```
