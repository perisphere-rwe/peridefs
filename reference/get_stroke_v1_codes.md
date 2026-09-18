# Retrieve ICD codes for stroke (any)

Direct access to the `stroke_v1` component of `spec_ascvd`. Equivalent
to `get_ascvd_codes(component = "stroke_v1", ...)`.

## Usage

``` r
get_stroke_v1_codes(...)
```

## Arguments

- component:

  Not used (fixed to `"stroke_v1"`); included only because it is
  inherited from
  [`get_ascvd_codes()`](https://perisphere-rwe.github.io/peridefs/reference/get_ascvd_codes.md).

## See also

[`get_stroke_v1_defs()`](https://perisphere-rwe.github.io/peridefs/reference/get_stroke_v1_defs.md),
[`get_ascvd_codes()`](https://perisphere-rwe.github.io/peridefs/reference/get_ascvd_codes.md),
`spec_ascvd`

## Examples

``` r
get_stroke_v1_codes()
#> # A tibble: 167 × 5
#>    type    code  priority version class 
#>    <chr>   <chr>    <int> <chr>   <chr> 
#>  1 dx_icd9 430          1 v1      stroke
#>  2 dx_icd9 431          1 v1      stroke
#>  3 dx_icd9 43301        1 v1      stroke
#>  4 dx_icd9 4331         1 v1      stroke
#>  5 dx_icd9 43311        1 v1      stroke
#>  6 dx_icd9 43321        1 v1      stroke
#>  7 dx_icd9 43331        1 v1      stroke
#>  8 dx_icd9 43381        1 v1      stroke
#>  9 dx_icd9 43391        1 v1      stroke
#> 10 dx_icd9 43401        1 v1      stroke
#> # ℹ 157 more rows
```
