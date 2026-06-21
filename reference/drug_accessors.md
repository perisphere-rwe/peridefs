# Miscellaneous drug accessor functions

Accessor functions for composite drug specs.

Accessor functions for composite drug specs.

## Usage

``` r
get_antihypertensive_codes(component, concatenate = FALSE)

get_antihypertensive_defs(component)

get_antidiabetic_codes(component, concatenate = FALSE)

get_antidiabetic_defs(component)
```

## Arguments

- component:

  **Required** for composite specs. A named component (e.g.
  `"acei_v1"`), or `"all"` to union all components' GNNs or NDC codes.
  Print the composite spec to see all available component names.

- concatenate:

  Logical. `FALSE` (default) returns a named list keyed by component
  name. `TRUE` flattens to an unnamed character vector.
