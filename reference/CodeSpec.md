# R6 class for medical condition code specifications

Stores the code sets and narrative algorithm description for a single
version of a medical condition definition. Each version is a distinct
object (e.g., `spec_htn_v1`, `spec_htn_v2`).

The spec stores:

- `defs`: named list with elements `condition` and `outcome`, each
  holding a narrative algorithm description string (or `NULL` if not
  defined).

- `codes`: named list of key-level lists keyed by
  `{code_type}_{encounter}` (e.g., `dx_icd9`). Each key-level list has:

  - `codes`: character vector of exact short-format codes (no periods).

  - `condition`: logical vector parallel to `codes`; `TRUE` if the code
    belongs to the condition/history definition.

  - `outcome`: logical vector parallel to `codes`; `TRUE` if the code
    belongs to the outcome definition.

  - `exclusions`: optional character string describing codes to exclude.

## Active bindings

- `condition`:

  Short condition identifier (read-only).

- `version`:

  Version label, e.g. `"v1"` (read-only).

- `label`:

  Human-readable condition label (read-only).

## Methods

### Public methods

- [`CodeSpec$new()`](#method-CodeSpec-new)

- [`CodeSpec$print()`](#method-CodeSpec-print)

- [`CodeSpec$keys()`](#method-CodeSpec-keys)

- [`CodeSpec$get_codes()`](#method-CodeSpec-get_codes)

- [`CodeSpec$get_defs()`](#method-CodeSpec-get_defs)

- [`CodeSpec$clone()`](#method-CodeSpec-clone)

------------------------------------------------------------------------

### Method `new()`

Create a new `CodeSpec`.

#### Usage

    CodeSpec$new(
      condition,
      label,
      defs = NULL,
      codes = NULL,
      version = NULL,
      versions = NULL
    )

#### Arguments

- `condition`:

  Short identifier string, e.g. `"htn"`.

- `label`:

  Human-readable label, e.g. `"Hypertension"`.

- `defs`:

  Named list with elements `condition` and `outcome` (character strings
  or `NULL`).

- `codes`:

  Named list of key-level lists. See class description.

- `version`:

  Optional version label string, e.g. `"v1"`.

- `versions`:

  Deprecated. Use `defs`/`codes`/`version` directly.

------------------------------------------------------------------------

### Method [`print()`](https://rdrr.io/r/base/print.html)

Print a summary of the spec.

#### Usage

    CodeSpec$print(...)

------------------------------------------------------------------------

### Method `keys()`

Return code-set keys.

#### Usage

    CodeSpec$keys()

#### Returns

Character vector of keys like `"dx_icd9"`.

------------------------------------------------------------------------

### Method `get_codes()`

Retrieve codes from the spec.

#### Usage

    CodeSpec$get_codes(
      code_type = NULL,
      variable_type = c("condition", "outcome"),
      periods = FALSE,
      format = c("list", "tibble")
    )

#### Arguments

- `code_type`:

  Optional character vector of code types to return. Valid values:
  `"dx_icd9"`, `"dx_icd10"`, `"proc_icd9"`, `"proc_icd10"`, `"hcpcs"`,
  `"cpt"`, `"rev"`. `NULL` returns all.

- `variable_type`:

  `"condition"` (default) or `"outcome"`.

- `periods`:

  Logical. If `TRUE`, return codes with decimal periods (e.g.,
  `"401.0"`). Default `FALSE` returns short format (`"4010"`).

- `format`:

  `"list"` (default) returns a named list of character vectors;
  `"tibble"` returns a long-form tibble.

#### Returns

Named list or tibble of codes.

------------------------------------------------------------------------

### Method [`get_defs()`](https://perisphere-rwe.github.io/peridefs/reference/get_defs.md)

Retrieve the narrative algorithm description.

#### Usage

    CodeSpec$get_defs(variable_type = c("condition", "outcome"))

#### Arguments

- `variable_type`:

  `"condition"` (default) or `"outcome"`.

#### Returns

Character string, or `NULL` if no definition exists for that variable
type.

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    CodeSpec$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
