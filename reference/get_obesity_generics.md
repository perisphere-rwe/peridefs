# Retrieve generic drug names for obesity medications

`spec_obesity` is a
[CompositeDrugSpec](https://perisphere-rwe.github.io/peridefs/reference/CompositeDrugSpec.md)
with components `non_glp1_v1` and `glp1_v1`.

## Usage

``` r
get_obesity_generics(component = NULL, priority = 1L, condition = NULL)

get_obesity_meds_labels(component = NULL)
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
  `get_obesity_generics()` defaults to `"obesity"`), so a leaf component
  shared across composites (e.g. a GLP-1 spec used by both the obesity
  and diabetes composites) only contributes its rows for *this*
  composite's condition. Pass a value explicitly to widen or otherwise
  override the default.

## Value

`get_*_generics()`: a tibble with columns `generic`, `brand`,
`priority`, `condition`, `class`, and `version`. `get_*_meds_labels()`:
a tibble with columns `name` and `label`.

## See also

`spec_obesity`
