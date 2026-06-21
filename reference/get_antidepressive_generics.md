# Retrieve generic drug names for antidepressive medications

`spec_antidepressive` is a
[CompositeDrugSpec](https://perisphere-rwe.github.io/peridefs/reference/CompositeDrugSpec.md)
with components `ssri_v1`, `snri_v1`, `tca_v1`, `maoi_v1`, and
`other_v1`. Use `component = "all"` to retrieve all GNNs across every
subclass.

## Usage

``` r
get_antidepressive_generics(component, concatenate = FALSE)

get_antidepressive_codes(component, concatenate = FALSE)

get_antidepressive_defs(component)
```

## Arguments

- component:

  **Required.** One or more of `"ssri_v1"`, `"snri_v1"`, `"tca_v1"`,
  `"maoi_v1"`, `"other_v1"`, or `"all"`.

- concatenate:

  Logical. `FALSE` (default) returns a named list keyed by component
  name. `TRUE` flattens to an unnamed character vector.

## Value

Named list of GNN strings (upper-case) or NDC codes, one element per
component. Pass `concatenate = TRUE` to flatten to an unnamed character
vector.

## See also

`spec_antidepressive`
