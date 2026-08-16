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
  generic_names_probable = character(0L),
  generic_names_cautious = character(0L),
  brand_names = list(),
  generic_defs = NULL
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

  Character vector of GNN drug names (priority 1, core).

- generic_names_probable:

  Character vector of GNN drug names with more than one indication
  (priority 2).

- generic_names_cautious:

  Character vector of GNN drug names lacking US approval for this
  class's indication (priority 3).

- brand_names:

  Optional named list mapping a GNN drug name to one or more brand name
  strings, e.g. `list(SEMAGLUTIDE = "Ozempic")`. See
  [DrugSpec](https://perisphere-rwe.github.io/peridefs/reference/DrugSpec.md)
  for details. Cannot be combined with `generic_defs`.

- generic_defs:

  Optional alternative to
  `generic_names`/`generic_names_probable`/`generic_names_cautious`/`brand_names`,
  for drug classes spanning more than one condition/indication context.
  See
  [DrugSpec](https://perisphere-rwe.github.io/peridefs/reference/DrugSpec.md)
  for details.

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
#> 2 generic name(s) (2 core, 0 probable, 0 cautious)
#> GNNs: DRUGONE, DRUGTWO
```
