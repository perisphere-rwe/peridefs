# Retrieve and display the narrative algorithm description

Renders the definition for a
[CodeSpec](https://perisphere-rwe.github.io/peridefs/reference/CodeSpec.md)
or
[DrugSpec](https://perisphere-rwe.github.io/peridefs/reference/DrugSpec.md)
to the console using cli formatting (bullets, inline code markup, etc.)
and returns the raw definition invisibly for programmatic use.

## Usage

``` r
get_defs(spec, variable_type = c("condition", "outcome"))
```

## Arguments

- spec:

  A
  [CodeSpec](https://perisphere-rwe.github.io/peridefs/reference/CodeSpec.md),
  [CompositeCodeSpec](https://perisphere-rwe.github.io/peridefs/reference/CompositeCodeSpec.md),
  [DrugSpec](https://perisphere-rwe.github.io/peridefs/reference/DrugSpec.md),
  or
  [CompositeDrugSpec](https://perisphere-rwe.github.io/peridefs/reference/CompositeDrugSpec.md)
  object.

- variable_type:

  `"condition"` (default) or `"outcome"`. Ignored for
  [DrugSpec](https://perisphere-rwe.github.io/peridefs/reference/DrugSpec.md)
  and
  [CompositeDrugSpec](https://perisphere-rwe.github.io/peridefs/reference/CompositeDrugSpec.md)
  objects.

## Value

The raw definition (named character vector or `NULL`), invisibly.
