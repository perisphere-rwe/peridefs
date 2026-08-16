# Modify a drug class specification

Returns a deep clone of `spec` with the requested modifications applied.

## Usage

``` r
modify_drug_spec(
  spec,
  label = NULL,
  defs = NULL,
  generic_names = NULL,
  generic_names_probable = NULL,
  generic_names_cautious = NULL,
  brand_names = NULL
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

  Optional replacement GNN character vector for priority 1 (core).

- generic_names_probable:

  Optional replacement GNN character vector for priority 2 (probable).

- generic_names_cautious:

  Optional replacement GNN character vector for priority 3 (cautious).

- brand_names:

  Optional named list mapping a GNN drug name to one or more brand name
  strings (replaces the full brand mapping for the resulting generic
  set; unspecified generics keep their existing brand assignment).

## Value

A modified deep clone of `spec`.
