# Retrieve the narrative algorithm description for an ASCVD component

Retrieve the narrative algorithm description for an ASCVD component

## Usage

``` r
get_ascvd_defs(variable_type = c("condition", "outcome"), component = NULL)
```

## Arguments

- variable_type:

  `"condition"` (default) or `"outcome"`.

- component:

  Optional component name. `NULL` (default) or `"all"` renders every
  component. See
  [`get_ascvd_codes()`](https://perisphere-rwe.github.io/peridefs/reference/get_ascvd_codes.md).

## See also

[`get_ascvd_codes()`](https://perisphere-rwe.github.io/peridefs/reference/get_ascvd_codes.md),
`spec_ascvd`
