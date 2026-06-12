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

The `component` argument is **required** when calling any `get_*`
method.

## Active bindings

- `drug_class`:

  Short drug class identifier (read-only).

- `version`:

  Version label (read-only; typically `NULL` for composites).

- `label`:

  Human-readable label (read-only).

## Methods

### Public methods

- [`CompositeDrugSpec$new()`](#method-CompositeDrugSpec-new)

- [`CompositeDrugSpec$print()`](#method-CompositeDrugSpec-print)

- [`CompositeDrugSpec$components()`](#method-CompositeDrugSpec-components)

- [`CompositeDrugSpec$get_generics()`](#method-CompositeDrugSpec-get_generics)

- [`CompositeDrugSpec$get_codes()`](#method-CompositeDrugSpec-get_codes)

- [`CompositeDrugSpec$get_defs()`](#method-CompositeDrugSpec-get_defs)

- [`CompositeDrugSpec$clone()`](#method-CompositeDrugSpec-clone)

------------------------------------------------------------------------

### Method `new()`

Create a new `CompositeDrugSpec`.

#### Usage

    CompositeDrugSpec$new(
      drug_class,
      label,
      defs = NULL,
      components = list(),
      version = NULL,
      versions = NULL
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

- `versions`:

  Deprecated. Use `defs`/`components` directly.

------------------------------------------------------------------------

### Method [`print()`](https://rdrr.io/r/base/print.html)

Print a summary of the composite drug spec.

#### Usage

    CompositeDrugSpec$print(...)

------------------------------------------------------------------------

### Method `components()`

Return the flat named component list.

#### Usage

    CompositeDrugSpec$components()

#### Returns

Named list of
[DrugSpec](https://perisphere-rwe.github.io/peridefs/reference/DrugSpec.md)
objects.

------------------------------------------------------------------------

### Method `get_generics()`

Retrieve GNNs from a named component.

#### Usage

    CompositeDrugSpec$get_generics(component = NULL)

#### Arguments

- `component`:

  **Required.** Component name, e.g. `"acei_v1"`.

#### Returns

Character vector of GNN strings.

------------------------------------------------------------------------

### Method `get_codes()`

Retrieve NDC codes from a named component.

#### Usage

    CompositeDrugSpec$get_codes(component = NULL)

#### Arguments

- `component`:

  **Required.** Component name, or `"all"` for the union across all
  components.

#### Returns

Character vector of NDC codes.

------------------------------------------------------------------------

### Method [`get_defs()`](https://perisphere-rwe.github.io/peridefs/reference/get_defs.md)

Retrieve the narrative description for a named component.

#### Usage

    CompositeDrugSpec$get_defs(component = NULL)

#### Arguments

- `component`:

  **Required.** Component name.

#### Returns

Character string, or `NULL`.

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    CompositeDrugSpec$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
