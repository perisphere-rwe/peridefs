# R6 class for composite condition code specifications

A `CompositeCodeSpec` is a composition of all versioned condition
components that collectively define a composite endpoint (e.g., ASCVD).
Unlike
[CodeSpec](https://perisphere-rwe.github.io/peridefs/reference/CodeSpec.md),
it does not store codes directly — instead it holds references to
specific versioned
[CodeSpec](https://perisphere-rwe.github.io/peridefs/reference/CodeSpec.md)
leaf objects, accessible by name via the `component` argument.

The `components` list is a flat named list mapping `"name_vX"` keys to
[CodeSpec](https://perisphere-rwe.github.io/peridefs/reference/CodeSpec.md)
objects, e.g.:

    components = list(
      chd_v1           = spec_chd_v1,
      stroke_v1        = spec_stroke_v1,
      cerebrovasc_disease_v1 = spec_cerebrovasc_disease_v1
    )

The `component` argument is **required** when calling `get_codes()` or
[`get_defs()`](https://perisphere-rwe.github.io/peridefs/reference/get_defs.md).
The `variable_type` argument is forwarded to the component spec, so both
condition and outcome codes are accessible.

## Active bindings

- `condition`:

  Short condition identifier (read-only).

- `version`:

  Version label (read-only; `NULL` for composites).

- `label`:

  Human-readable label (read-only).

## Methods

### Public methods

- [`CompositeCodeSpec$new()`](#method-CompositeCodeSpec-new)

- [`CompositeCodeSpec$print()`](#method-CompositeCodeSpec-print)

- [`CompositeCodeSpec$components()`](#method-CompositeCodeSpec-components)

- [`CompositeCodeSpec$keys()`](#method-CompositeCodeSpec-keys)

- [`CompositeCodeSpec$get_codes()`](#method-CompositeCodeSpec-get_codes)

- [`CompositeCodeSpec$get_defs()`](#method-CompositeCodeSpec-get_defs)

- [`CompositeCodeSpec$clone()`](#method-CompositeCodeSpec-clone)

------------------------------------------------------------------------

### Method `new()`

Create a new `CompositeCodeSpec`.

#### Usage

    CompositeCodeSpec$new(
      condition,
      label,
      defs = NULL,
      components = list(),
      version = NULL
    )

#### Arguments

- `condition`:

  Short identifier string, e.g. `"ascvd"`.

- `label`:

  Human-readable label.

- `defs`:

  Character string describing the composite definition.

- `components`:

  Named list of
  [CodeSpec](https://perisphere-rwe.github.io/peridefs/reference/CodeSpec.md)
  objects, keyed by `"name_vX"` strings.

- `version`:

  Optional version label (typically `NULL` for composites).

------------------------------------------------------------------------

### Method [`print()`](https://rdrr.io/r/base/print.html)

Print a summary of the composite spec.

#### Usage

    CompositeCodeSpec$print(...)

------------------------------------------------------------------------

### Method `components()`

Return the flat named component list.

#### Usage

    CompositeCodeSpec$components()

#### Returns

Named list of
[CodeSpec](https://perisphere-rwe.github.io/peridefs/reference/CodeSpec.md)
objects.

------------------------------------------------------------------------

### Method `keys()`

Return the code-set keys available across all components.

#### Usage

    CompositeCodeSpec$keys()

#### Returns

Character vector of unique key strings.

------------------------------------------------------------------------

### Method `get_codes()`

Retrieve codes from a named component.

#### Usage

    CompositeCodeSpec$get_codes(
      component = NULL,
      code_type = NULL,
      variable_type = c("condition", "outcome"),
      periods = FALSE,
      format = c("list", "tibble")
    )

#### Arguments

- `component`:

  **Required.** Name of a component, e.g. `"chd_v1"`. Print the spec to
  see available names.

- `code_type`:

  Optional character vector of code types to filter.

- `variable_type`:

  `"condition"` (default) or `"outcome"`.

- `periods`:

  Logical. `FALSE` (default) = short format.

- `format`:

  `"list"` (default) or `"tibble"`.

#### Returns

Named list or tibble of codes.

------------------------------------------------------------------------

### Method [`get_defs()`](https://perisphere-rwe.github.io/peridefs/reference/get_defs.md)

Retrieve the narrative algorithm description from a named component.

#### Usage

    CompositeCodeSpec$get_defs(
      component = NULL,
      variable_type = c("condition", "outcome")
    )

#### Arguments

- `component`:

  **Required.** Component name.

- `variable_type`:

  `"condition"` (default) or `"outcome"`.

#### Returns

Character string, or `NULL`.

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    CompositeCodeSpec$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
