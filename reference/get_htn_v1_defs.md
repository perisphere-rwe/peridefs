# Retrieve the narrative algorithm description for hypertension (v1)

Retrieve the narrative algorithm description for hypertension (v1)

## Usage

``` r
get_htn_v1_defs(variable_type = c("condition", "outcome"))

get_htn_v2_defs(variable_type = c("condition", "outcome"))
```

## Arguments

- variable_type:

  `"condition"` (default) or `"outcome"`.

## Value

Character string, or `NULL`.

## See also

[`get_htn_v1_codes()`](https://perisphere-rwe.github.io/peridefs/reference/get_htn_v1_codes.md)

[`get_htn_v2_codes()`](https://perisphere-rwe.github.io/peridefs/reference/get_htn_v1_codes.md)

## Examples

``` r
get_htn_v1_defs()
#> ℹ Any of the following:
#> • ≥1 inpatient claim with an ICD-9 discharge diagnosis of 401.x, 403.0x,
#>   403.1x, or 403.9x, or ICD-10 discharge diagnosis code of I10, I11.x, I12.x,
#>   I13.x, I15.x, I12.0, I12.9, I16.x in any discharge diagnosis position.
#> • ≥2 physician E&M visit claims with the same diagnosis codes, at least 30 days
#>   apart.
```
