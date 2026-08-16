# Retrieve and display the narrative algorithm description

Renders the definition for a
[CodeSpec](https://perisphere-rwe.github.io/peridefs/reference/CodeSpec.md)
or
[CompositeCodeSpec](https://perisphere-rwe.github.io/peridefs/reference/CompositeCodeSpec.md)
to the console using cli formatting (bullets, inline code markup, etc.)
and returns the raw definition invisibly for programmatic use. For a
[DrugSpec](https://perisphere-rwe.github.io/peridefs/reference/DrugSpec.md)
leaf, renders and returns its (typically internal sourcing note) `defs`
text the same way. For a
[CompositeDrugSpec](https://perisphere-rwe.github.io/peridefs/reference/CompositeDrugSpec.md),
returns the tibble of component `name`/`label` pairs from
`$get_meds_labels()` instead (see that method, or
[`get_hypertension_meds_labels()`](https://perisphere-rwe.github.io/peridefs/reference/get_hypertension_generics.md)
and friends) — composite drug specs don't carry a narrative definition
the way condition specs do.

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

The raw definition (named character vector or `NULL`), invisibly, for
[CodeSpec](https://perisphere-rwe.github.io/peridefs/reference/CodeSpec.md)/[CompositeCodeSpec](https://perisphere-rwe.github.io/peridefs/reference/CompositeCodeSpec.md)/[DrugSpec](https://perisphere-rwe.github.io/peridefs/reference/DrugSpec.md).
A tibble with columns `name` and `label` for
[CompositeDrugSpec](https://perisphere-rwe.github.io/peridefs/reference/CompositeDrugSpec.md).
