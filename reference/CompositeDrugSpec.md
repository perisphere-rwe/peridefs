# R6 class for composite drug class specifications

A `CompositeDrugSpec` is a composition of all versioned drug class
components that collectively define a composite drug group (e.g.,
antihypertensives). It holds references to specific versioned
[DrugSpec](https://perisphere-rwe.github.io/peridefs/reference/DrugSpec.md)
leaf objects, accessible by name via the `component` argument.

The `components` list is a flat named list mapping `"name_vX"` keys to
[DrugSpec](https://perisphere-rwe.github.io/peridefs/reference/DrugSpec.md)
objects:

    components = list(
      acei_v1 = spec_acei_v1,
      acei_v2 = spec_acei_v2,
      arb_v1  = spec_arb_v1,
      ...
    )

The `component` argument is optional when calling `get_generics()`;
omitting it (or passing `"all"`) returns every component.

## Active bindings

- `drug_class`:

  Short drug class identifier (read-only).

- `version`:

  Version label (read-only; typically `NULL` for composites).

- `label`:

  Human-readable label (read-only).

- `condition`:

  The single condition/indication this composite represents (read-only),
  e.g. `"hypertension"`. Used as the default `condition` filter in
  `get_generics()`.

## Methods

### Public methods

- [`CompositeDrugSpec$new()`](#method-CompositeDrugSpec-initialize)

- [`CompositeDrugSpec$print()`](#method-CompositeDrugSpec-print)

- [`CompositeDrugSpec$components()`](#method-CompositeDrugSpec-components)

- [`CompositeDrugSpec$get_generics()`](#method-CompositeDrugSpec-get_generics)

- [`CompositeDrugSpec$get_meds_labels()`](#method-CompositeDrugSpec-get_meds_labels)

- [`CompositeDrugSpec$clone()`](#method-CompositeDrugSpec-clone)

------------------------------------------------------------------------

### `CompositeDrugSpec$new()`

Create a new `CompositeDrugSpec`.

#### Usage

    CompositeDrugSpec$new(
      drug_class,
      label,
      defs = NULL,
      components = list(),
      version = NULL,
      condition = NULL
    )

#### Arguments

- `drug_class`:

  Short identifier string, e.g. `"antihypertensive"`.

- `label`:

  Human-readable label.

- `defs`:

  Character string describing the composite.

- `components`:

  Named list of
  [DrugSpec](https://perisphere-rwe.github.io/peridefs/reference/DrugSpec.md)
  objects, keyed by `"name_vX"` strings.

- `version`:

  Optional version label (typically `NULL`).

- `condition`:

  Required character string naming the single condition/indication this
  composite represents, e.g. `"hypertension"`. A `CompositeDrugSpec`
  always represents exactly one condition (unlike a leaf
  [DrugSpec](https://perisphere-rwe.github.io/peridefs/reference/DrugSpec.md)
  built with `generic_defs`, which may span several); this is used as
  the default `condition` filter in `get_generics()`, so a shared leaf
  component tagged with multiple conditions (e.g. a GLP-1 spec used by
  both the obesity and diabetes composites) only contributes its rows
  for *this* composite's condition unless the caller overrides the
  filter explicitly.

------------------------------------------------------------------------

### `CompositeDrugSpec$print()`

Print a summary of the composite drug spec.

#### Usage

    CompositeDrugSpec$print(...)

------------------------------------------------------------------------

### `CompositeDrugSpec$components()`

Return the flat named component list.

#### Usage

    CompositeDrugSpec$components()

#### Returns

Named list of
[DrugSpec](https://perisphere-rwe.github.io/peridefs/reference/DrugSpec.md)
objects.

------------------------------------------------------------------------

### `CompositeDrugSpec$get_generics()`

Retrieve generic (and brand) drug names from one or more components as a
tidy data frame.

#### Usage

    CompositeDrugSpec$get_generics(
      component = NULL,
      priority = 1L,
      condition = self$condition
    )

#### Arguments

- `component`:

  Optional component name(s), e.g. `"acei_v1"`. `NULL` (default) or
  `"all"` returns every component.

- `priority`:

  Integer vector subsetting confidence tiers to include. Default `1`.

- `condition`:

  Optional character vector subsetting to specific condition(s),
  forwarded to each component's `get_generics()`. Defaults to this
  composite's own `condition` (e.g. `"hypertension"`), so a shared leaf
  component tagged with multiple conditions only contributes its rows
  for this composite's condition. Pass `NULL` explicitly to disable
  condition filtering entirely (returns every row from every component
  regardless of condition).

#### Returns

A tibble with columns `generic`, `brand`, `priority`, `condition`,
`class`, and `version`.

------------------------------------------------------------------------

### `CompositeDrugSpec$get_meds_labels()`

Retrieve the human-readable `label` for one or more components as a tidy
tibble.

This deliberately surfaces each leaf's `label` (e.g. `"ACE Inhibitors"`)
rather than its free-text `defs` field. A leaf `DrugSpec`'s `defs` is
typically just an internal sourcing note (e.g.
`"From the Perisphere antihypertensive medication list."`), not a
clinical definition – and now that composite drug specs are named after
the condition they treat (e.g. `spec_hypertension`), a
[`get_defs()`](https://perisphere-rwe.github.io/peridefs/reference/get_defs.md)-style
function here would be easy to confuse with the condition side's
`get_*_v1_defs()`, which *does* return a real diagnostic-algorithm
narrative. Returning labels instead avoids that confusion by making
clear this is a component listing, not a clinical definition. Version
isn't included in the output since `name` (the component key, e.g.
`"acei_v2"`) already encodes it.

#### Usage

    CompositeDrugSpec$get_meds_labels(component = NULL)

#### Arguments

- `component`:

  Optional component name(s). `NULL` (default) or `"all"` returns every
  component's label.

#### Returns

A tibble with columns `name` (the component key, e.g. `"acei_v1"`) and
`label` (e.g. `"ACE Inhibitors"`).

------------------------------------------------------------------------

### `CompositeDrugSpec$clone()`

The objects of this class are cloneable with this method.

#### Usage

    CompositeDrugSpec$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
