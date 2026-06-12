# Modify a condition code specification

Returns a deep clone of `spec` with the requested modifications applied.

## Usage

``` r
modify_code_spec(spec, label = NULL, defs = NULL, replace_codes = NULL)
```

## Arguments

- spec:

  A
  [CodeSpec](https://perisphere-rwe.github.io/peridefs/reference/CodeSpec.md)
  object.

- label:

  Optional replacement label string.

- defs:

  Optional replacement `defs` list (elements `condition`, `outcome`).

- replace_codes:

  Optional named list of key-level lists that fully replace existing
  code sets.

## Value

A modified deep clone of `spec`.
