# Retrieve generic drug names for antidiabetic medications

`spec_antidiabetic` is a
[CompositeDrugSpec](https://perisphere-rwe.github.io/peridefs/reference/CompositeDrugSpec.md)
containing all versioned antidiabetic leaf specs: `biguanide_v1`,
`sulfonylurea_v1`, `meglitinide_v1`, `tzd_v1`, `alpha_glucosidase_v1`,
`dpp4_v1`, `sglt2_v1`, `glp1_v1`, `insulin_v1`, `amylin_v1`.

## Usage

``` r
get_antidiabetic_generics(component = NULL)
```

## Arguments

- component:

  **Required.** Component name. Print `spec_antidiabetic` to see all
  available names.

## Value

Character vector of GNN strings (upper-case).

## See also

`spec_antidiabetic`
