# Create a user-defined drug class specification

Constructs a
[DrugSpec](https://perisphere-rwe.github.io/peridefs/reference/DrugSpec.md)
R6 object from user-supplied data.

## Usage

``` r
drug_spec(
  drug_class,
  label,
  version = NULL,
  defs = NULL,
  generic_names = character(0L),
  ndc = character(0L)
)
```

## Arguments

- drug_class:

  Short identifier string, e.g. `"my_drug"`.

- label:

  Human-readable label.

- version:

  Optional version label string, e.g. `"v1"`.

- defs:

  Character string describing the drug class. May be `NULL`.

- generic_names:

  Character vector of GNN drug names.

- ndc:

  Character vector of NDC codes. Defaults to `character(0)`.

## Value

A
[DrugSpec](https://perisphere-rwe.github.io/peridefs/reference/DrugSpec.md)
R6 object.

## Examples

``` r
my_drug <- drug_spec(
  drug_class    = "my_drug",
  label         = "My Drug Class",
  version       = "v1",
  generic_names = c("DRUGONE", "DRUGTWO")
)
my_drug
#> 
#> ── My Drug Class (v1) ──────────────────────────────────────────────────────────
#> Drug class: `my_drug`
#> 2 generic name(s), 0 NDC code(s)
#> GNNs: DRUGONE, DRUGTWO
```
