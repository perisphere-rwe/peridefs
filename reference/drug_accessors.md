# Miscellaneous drug accessor functions

Accessor functions for composite drug specs.

Accessor functions for composite drug specs.

## Usage

``` r
get_antihypertensive_codes(component = NULL)

get_antihypertensive_defs(component = NULL)

get_antidiabetic_codes(component = NULL)

get_antidiabetic_defs(component = NULL)
```

## Arguments

- component:

  **Required** for composite specs. A named component (e.g.
  `"acei_v1"`), or `"all"` to union all components' GNNs or NDC codes.
  Print the composite spec to see all available component names.
