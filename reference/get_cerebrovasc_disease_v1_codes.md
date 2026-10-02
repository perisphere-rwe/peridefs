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
#> # A tibble: 187 × 6
#>    type    code  priority version definition                               class
#>    <chr>   <chr>    <int> <chr>   <chr>                                    <chr>
#>  1 dx_icd9 43301        1 v1      Occlusion and stenosis of basilar arter… cere…
#>  2 dx_icd9 4331         1 v1      Occlusion and stenosis of precerebral a… cere…
#>  3 dx_icd9 43311        1 v1      Occlusion and stenosis of carotid arter… cere…
#>  4 dx_icd9 43321        1 v1      Occlusion and stenosis of vertebral art… cere…
#>  5 dx_icd9 43331        1 v1      Occlusion and stenosis of multiple and … cere…
#>  6 dx_icd9 43381        1 v1      Occlusion and stenosis of other specifi… cere…
#>  7 dx_icd9 43391        1 v1      Occlusion and stenosis of unspecified p… cere…
#>  8 dx_icd9 43401        1 v1      Cerebral thrombosis with cerebral infar… cere…
#>  9 dx_icd9 4341         1 v1      Occlusion of cerebral arteries: Cerebra… cere…
#> 10 dx_icd9 43411        1 v1      Cerebral embolism with cerebral infarct… cere…
#> # ℹ 177 more rows
```
