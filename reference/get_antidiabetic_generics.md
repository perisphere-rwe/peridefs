# Retrieve generic drug names for antidiabetic medications

`spec_antidiabetic` is a
[CompositeDrugSpec](https://perisphere-rwe.github.io/peridefs/reference/CompositeDrugSpec.md)
containing all versioned antidiabetic leaf specs: `biguanide_v1`,
`sulfonylurea_v1`, `meglitinide_v1`, `tzd_v1`, `alpha_glucosidase_v1`,
`dpp4_v1`, `sglt2_v1`, `glp1_v1`, `insulin_v1`, `amylin_v1`.

## Usage

``` r
get_antidiabetic_generics(component, concatenate = FALSE)
```

## Arguments

- component:

  **Required.** Component name. Print `spec_antidiabetic` to see all
  available names.

- concatenate:

  Logical. `FALSE` (default) returns a named list keyed by component
  name. `TRUE` flattens to an unnamed character vector.

## Value

Named list of GNN strings (upper-case) or NDC codes, one element per
component. Pass `concatenate = TRUE` to flatten to an unnamed character
vector.

## See also

`spec_antidiabetic`
