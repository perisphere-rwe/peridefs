# Retrieve generic drug names for antihypertensive medications

`spec_antihypertensive` is a
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
get_antihypertensive_generics(component, concatenate = FALSE)
```

## Arguments

- component:

  **Required.** Component name. Print `spec_antihypertensive` to see all
  available names.

- concatenate:

  Logical. `FALSE` (default) returns a named list keyed by component
  name. `TRUE` flattens to an unnamed character vector.

## Value

Named list of GNN strings (upper-case) or NDC codes, one element per
component. Pass `concatenate = TRUE` to flatten to an unnamed character
vector.

## See also

`spec_antihypertensive`
