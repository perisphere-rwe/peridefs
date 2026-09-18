# Retrieve ICD codes for coronary heart disease (CHD)

Direct access to the `chd_v1` component of `spec_ascvd`. Equivalent to
`get_ascvd_codes(component = "chd_v1", ...)`.

## Usage

``` r
get_chd_v1_codes(...)
```

## Arguments

- component:

  Not used (fixed to `"chd_v1"`); included only because it is inherited
  from
  [`get_ascvd_codes()`](https://perisphere-rwe.github.io/peridefs/reference/get_ascvd_codes.md).

## See also

[`get_chd_v1_defs()`](https://perisphere-rwe.github.io/peridefs/reference/get_chd_v1_defs.md),
[`get_ascvd_codes()`](https://perisphere-rwe.github.io/peridefs/reference/get_ascvd_codes.md),
`spec_ascvd`

## Examples

``` r
get_chd_v1_codes()
#> # A tibble: 766 × 5
#>    type    code  priority version class
#>    <chr>   <chr>    <int> <chr>   <chr>
#>  1 dx_icd9 410          1 v1      chd  
#>  2 dx_icd9 4100         1 v1      chd  
#>  3 dx_icd9 41000        1 v1      chd  
#>  4 dx_icd9 41001        1 v1      chd  
#>  5 dx_icd9 41002        1 v1      chd  
#>  6 dx_icd9 4101         1 v1      chd  
#>  7 dx_icd9 41010        1 v1      chd  
#>  8 dx_icd9 41011        1 v1      chd  
#>  9 dx_icd9 41012        1 v1      chd  
#> 10 dx_icd9 4102         1 v1      chd  
#> # ℹ 756 more rows
```
