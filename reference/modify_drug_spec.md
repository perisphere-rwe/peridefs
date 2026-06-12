# Modify a drug class specification

Returns a deep clone of `spec` with the requested modifications applied.

## Usage

``` r
modify_drug_spec(
  spec,
  label = NULL,
  defs = NULL,
  generic_names = NULL,
  ndc = NULL
)
```

## Arguments

- spec:

  A
  [DrugSpec](https://perisphere-rwe.github.io/peridefs/reference/DrugSpec.md)
  object.

- label:

  Optional replacement label string.

- defs:

  Optional replacement narrative string.

- generic_names:

  Optional replacement GNN character vector.

- ndc:

  Optional replacement NDC character vector.

## Value

A modified deep clone of `spec`.
