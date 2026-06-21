# Retrieve generic drug names for antiobesity medications

`spec_antiobesity` is a
[CompositeDrugSpec](https://perisphere-rwe.github.io/peridefs/reference/CompositeDrugSpec.md)
with components `non_glp1_v1` and `glp1_v1`. Use `component = "all"` to
retrieve all GNNs across both subclasses.

## Usage

``` r
get_antiobesity_generics(component, concatenate = FALSE)

get_antiobesity_codes(component, concatenate = FALSE)

get_antiobesity_defs(component)
```

## Arguments

- component:

  **Required.** `"non_glp1_v1"`, `"glp1_v1"`, or `"all"`.

- concatenate:

  Logical. `FALSE` (default) returns a named list keyed by component
  name. `TRUE` flattens to an unnamed character vector.

## Value

Named list of GNN strings (upper-case) or NDC codes, one element per
component. Pass `concatenate = TRUE` to flatten to an unnamed character
vector.

## See also

`spec_antiobesity`
