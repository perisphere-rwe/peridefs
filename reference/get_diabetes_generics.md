# Retrieve generic drug names for diabetes medications

`spec_diabetes` is a
[CompositeDrugSpec](https://perisphere-rwe.github.io/peridefs/reference/CompositeDrugSpec.md)
containing all versioned antidiabetic leaf specs: `biguanide_v1`,
`sulfonylurea_v1`, `meglitinide_v1`, `tzd_v1`, `alpha_glucosidase_v1`,
`dpp4_v1`, `sglt2_v1`, `glp1_v1`, `insulin_v1`, `amylin_v1`.

## Usage

``` r
get_diabetes_generics(component = NULL, priority = 1L, condition = NULL)

get_diabetes_meds_labels(component = NULL)
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

`spec_diabetes`
