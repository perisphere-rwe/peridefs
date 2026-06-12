# Create a user-defined condition code specification

Constructs a
[CodeSpec](https://perisphere-rwe.github.io/peridefs/reference/CodeSpec.md)
R6 object from user-supplied codes and definitions. Codes should be
provided in **exact short format** (no decimal periods, e.g., `"4010"`
not `"401.0"`).

## Usage

``` r
code_spec(
  condition,
  label,
  version = NULL,
  defs = list(condition = NULL, outcome = NULL),
  codes = list(),
  exclusions = NULL
)
```

## Arguments

- condition:

  Short identifier string, e.g. `"my_cond"`.

- label:

  Human-readable label, e.g. `"My Condition"`.

- version:

  Optional version label string, e.g. `"v1"`. Stored as metadata only;
  use distinct object names (e.g., `my_spec_v1`) to distinguish
  versions.

- defs:

  Named list with elements `condition` and/or `outcome`, each a
  character string describing the algorithm. `NULL` elements are
  allowed.

- codes:

  Named list of key-level lists keyed by `{code_type}_{encounter}`
  (e.g., `"dx_icd9"`). Each element may be:

  - A character vector of codes — both `condition` and `outcome` flags
    are set to `TRUE` for all codes.

  - A list with elements `codes`, `condition` (logical vector),
    `outcome` (logical vector), and optionally `exclusions`.

- exclusions:

  Optional named list of exclusion note strings, one per code-set key.

## Value

A
[CodeSpec](https://perisphere-rwe.github.io/peridefs/reference/CodeSpec.md)
R6 object.

## Examples

``` r
my_spec <- code_spec(
  condition = "test",
  label     = "Test Condition",
  version   = "v1",
  codes     = list(dx_icd9 = c("4010", "4011", "4019"))
)
my_spec
#> 
#> ── Test Condition (v1) ─────────────────────────────────────────────────────────
#> Condition: `test`
#> Code sets:
#>   `dx_icd9`: 3 condition / 3 outcome codes
```
