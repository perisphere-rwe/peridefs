# Retrieve ICD codes for cerebrovascular disease

Direct access to the `cerebrovasc_disease_v1` component of `spec_ascvd`.
Equivalent to
`get_ascvd_codes(component = "cerebrovasc_disease_v1", ...)`.

## Usage

``` r
get_cerebrovasc_disease_v1_codes(...)
```

## Arguments

- component:

  Not used (fixed to `"cerebrovasc_disease_v1"`); included only because
  it is inherited from
  [`get_ascvd_codes()`](https://perisphere-rwe.github.io/peridefs/reference/get_ascvd_codes.md).

## See also

[`get_cerebrovasc_disease_v1_defs()`](https://perisphere-rwe.github.io/peridefs/reference/get_cerebrovasc_disease_v1_defs.md),
[`get_ascvd_codes()`](https://perisphere-rwe.github.io/peridefs/reference/get_ascvd_codes.md),
`spec_ascvd`

## Examples

``` r
get_cerebrovasc_disease_v1_codes()
#> # A tibble: 187 × 5
#>    type    code  priority version class              
#>    <chr>   <chr>    <int> <chr>   <chr>              
#>  1 dx_icd9 43301        1 v1      cerebrovasc_disease
#>  2 dx_icd9 4331         1 v1      cerebrovasc_disease
#>  3 dx_icd9 43311        1 v1      cerebrovasc_disease
#>  4 dx_icd9 43321        1 v1      cerebrovasc_disease
#>  5 dx_icd9 43331        1 v1      cerebrovasc_disease
#>  6 dx_icd9 43381        1 v1      cerebrovasc_disease
#>  7 dx_icd9 43391        1 v1      cerebrovasc_disease
#>  8 dx_icd9 43401        1 v1      cerebrovasc_disease
#>  9 dx_icd9 4341         1 v1      cerebrovasc_disease
#> 10 dx_icd9 43411        1 v1      cerebrovasc_disease
#> # ℹ 177 more rows
```
