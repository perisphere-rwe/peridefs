# R6 class for drug class specifications

Stores the generic drug names (GNNs), NDC codes, and narrative
description for a single version of a drug class definition. Each
version is a distinct object (e.g., `spec_acei_v1`, `spec_acei_v2`).

## Active bindings

- `drug_class`:

  Short drug class identifier (read-only).

- `version`:

  Version label, e.g. `"v1"` (read-only).

- `label`:

  Human-readable drug class label (read-only).

## Methods

### Public methods

- [`DrugSpec$new()`](#method-DrugSpec-new)

- [`DrugSpec$print()`](#method-DrugSpec-print)

- [`DrugSpec$get_generics()`](#method-DrugSpec-get_generics)

- [`DrugSpec$get_codes()`](#method-DrugSpec-get_codes)

- [`DrugSpec$get_defs()`](#method-DrugSpec-get_defs)

- [`DrugSpec$clone()`](#method-DrugSpec-clone)

------------------------------------------------------------------------

### Method `new()`

Create a new `DrugSpec`.

#### Usage

    DrugSpec$new(
      drug_class,
      label,
      defs = NULL,
      generic_names = character(0L),
      ndc = character(0L),
      version = NULL,
      versions = NULL
    )

#### Arguments

- `drug_class`:

  Short identifier string, e.g. `"acei"`.

- `label`:

  Human-readable label.

- `defs`:

  Character string describing the drug class. May be `NULL`.

- `generic_names`:

  Character vector of GNN drug names.

- `ndc`:

  Character vector of NDC codes.

- `version`:

  Optional version label string, e.g. `"v1"`.

- `versions`:

  Deprecated. Use `defs`/`generic_names`/`version` directly.

------------------------------------------------------------------------

### Method [`print()`](https://rdrr.io/r/base/print.html)

Print a summary of the spec.

#### Usage

    DrugSpec$print(...)

------------------------------------------------------------------------

### Method `get_generics()`

Retrieve generic drug names (GNNs).

#### Usage

    DrugSpec$get_generics()

#### Returns

Character vector of GNN strings.

------------------------------------------------------------------------

### Method `get_codes()`

Retrieve NDC codes.

#### Usage

    DrugSpec$get_codes()

#### Returns

Character vector of NDC codes (empty until populated).

------------------------------------------------------------------------

### Method [`get_defs()`](https://perisphere-rwe.github.io/peridefs/reference/get_defs.md)

Retrieve the narrative drug class description.

#### Usage

    DrugSpec$get_defs()

#### Returns

Character string, or `NULL`.

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    DrugSpec$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
