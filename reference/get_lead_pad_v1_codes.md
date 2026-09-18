# Retrieve ICD codes for lower extremity artery disease (LEAD) / peripheral artery disease (PAD)

Direct access to the `lead_pad_v1` component of `spec_ascvd`. Equivalent
to `get_ascvd_codes(component = "lead_pad_v1", ...)`.

## Usage

``` r
get_lead_pad_v1_codes(...)
```

## Arguments

- component:

  Not used (fixed to `"lead_pad_v1"`); included only because it is
  inherited from
  [`get_ascvd_codes()`](https://perisphere-rwe.github.io/peridefs/reference/get_ascvd_codes.md).

## See also

[`get_lead_pad_v1_defs()`](https://perisphere-rwe.github.io/peridefs/reference/get_lead_pad_v1_defs.md),
[`get_ascvd_codes()`](https://perisphere-rwe.github.io/peridefs/reference/get_ascvd_codes.md),
`spec_ascvd`

## Examples

``` r
get_lead_pad_v1_codes()
#> # A tibble: 312 × 5
#>    type    code  priority version class   
#>    <chr>   <chr>    <int> <chr>   <chr>   
#>  1 dx_icd9 4402         1 v1      lead_pad
#>  2 dx_icd9 44020        1 v1      lead_pad
#>  3 dx_icd9 44021        1 v1      lead_pad
#>  4 dx_icd9 44022        1 v1      lead_pad
#>  5 dx_icd9 44023        1 v1      lead_pad
#>  6 dx_icd9 44024        1 v1      lead_pad
#>  7 dx_icd9 44029        1 v1      lead_pad
#>  8 dx_icd9 4403         1 v1      lead_pad
#>  9 dx_icd9 44030        1 v1      lead_pad
#> 10 dx_icd9 44031        1 v1      lead_pad
#> # ℹ 302 more rows
```
