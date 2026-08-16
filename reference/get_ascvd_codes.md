# Retrieve codes for a named ASCVD component

`spec_ascvd` is a
[CompositeCodeSpec](https://perisphere-rwe.github.io/peridefs/reference/CompositeCodeSpec.md)
containing all versioned components used across ASCVD definitions:
`chd_v1`, `stroke_v1`, `cerebrovasc_disease_v1`.

The `component` argument is optional; omit it (or pass `"all"`) to
retrieve every component at once, distinguished by the `class` column.
Print `spec_ascvd` to see all available component names.

## Usage

``` r
get_ascvd_codes(
  component = NULL,
  code_type = NULL,
  variable_type = c("condition", "outcome"),
  periods = FALSE,
  priority = 1L
)
```

## Arguments

- component:

  Optional component name(s), e.g. `"chd_v1"`, `"stroke_v1"`,
  `"isch_stroke_v1"`, `"hf_v1"`, `"cerebrovasc_disease_v1"`. `NULL`
  (default) or `"all"` returns every component.

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

## See also

[`get_ascvd_defs()`](https://perisphere-rwe.github.io/peridefs/reference/get_ascvd_defs.md),
`spec_ascvd`

## Examples

``` r
get_ascvd_codes(component = "chd_v1")
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
get_ascvd_codes(component = "stroke_v1", variable_type = "outcome")
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

# See all available components
spec_ascvd
#> 
#> ── Atherosclerotic Cardiovascular Disease (ASCVD) (composite) ──────────────────
#> Condition: `ascvd`
#> Def: Composition of all ASCVD component specs: coronary heart disease (CHD),
#> stroke, lower extremity artery disease (LEAD) / peripheral arterial disease
#> (PAD), and cerebrovascular disease
#> Components:
#>   `chd_v1`: Coronary Heart Disease
#>   `stroke_v1`: Stroke (Any)
#>   `lead_pad_v1`: lower extremity artery disease (LEAD) / peripheral artery
#>   disease (PAD)
#>   `cerebrovasc_disease_v1`: Cerebrovascular Disease
#> Use `component` = "chd_v1", "stroke_v1", "lead_pad_v1", and
#> "cerebrovasc_disease_v1" in `get_*()` functions.
```
