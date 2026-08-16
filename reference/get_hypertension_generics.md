# Retrieve generic drug names for hypertension medications

`spec_hypertension` is a
[CompositeDrugSpec](https://perisphere-rwe.github.io/peridefs/reference/CompositeDrugSpec.md)
containing all versioned antihypertensive leaf specs directly (no
intermediate composites): `acei_v1`, `acei_v2`, `arb_v1`, `arb_v2`,
`alpha_v1`, `alpha_beta_v1`, `alpha_beta_v2`, `cardio_v1`,
`cardio_vasod_v1`, `int_sym_v1`, `int_sym_v2`, `noncardio_v1`,
`ccb_dhp_v1`, `ccb_dhp_v2`, `ccb_nondhp_v1`, `thiazide_v1`,
`thiazide_v2`, `loop_v1`, `loop_v2`, `ksparing_v1`, `ksparing_v2`,
`aldo_v1`, `central_v1`, `central_v2`, `renin_v1`, `vasodilators_v1`.

## Usage

``` r
get_hypertension_generics(component = NULL, priority = 1L, condition = NULL)

get_hypertension_meds_labels(component = NULL)
```

## Arguments

- component:

  Optional named component (e.g. `"acei_v1"`) for composite specs.
  `NULL` (default) or `"all"` returns every component's generics. Print
  the composite spec to see all available component names.

- priority:

  Integer vector subsetting confidence tiers to include (`1` = core, `2`
  = probable, `3` = cautious). Default `1`.

- condition:

  Optional character vector subsetting to specific condition(s). `NULL`
  (default) uses the composite's own condition (e.g.
  [`get_obesity_generics()`](https://perisphere-rwe.github.io/peridefs/reference/get_obesity_generics.md)
  defaults to `"obesity"`), so a leaf component shared across composites
  (e.g. a GLP-1 spec used by both the obesity and diabetes composites)
  only contributes its rows for *this* composite's condition. Pass a
  value explicitly to widen or otherwise override the default.

## Value

`get_*_generics()`: a tibble with columns `generic`, `brand`,
`priority`, `condition`, `class`, and `version`. `get_*_meds_labels()`:
a tibble with columns `name` and `label`.

## See also

`spec_hypertension`
