# R6 class for drug class specifications

Stores the generic drug names (GNNs) and narrative description for a
single version of a drug class definition. Each version is a distinct
object (e.g., `spec_acei_v1`, `spec_acei_v2`).

## Active bindings

- `drug_class`:

  Short drug class identifier (read-only).

- `version`:

  Version label, e.g. `"v1"` (read-only).

- `label`:

  Human-readable drug class label (read-only).

## Methods

### Public methods

- [`DrugSpec$new()`](#method-DrugSpec-initialize)

- [`DrugSpec$print()`](#method-DrugSpec-print)

- [`DrugSpec$get_generics()`](#method-DrugSpec-get_generics)

- [`DrugSpec$get_defs()`](#method-DrugSpec-get_defs)

- [`DrugSpec$clone()`](#method-DrugSpec-clone)

------------------------------------------------------------------------

### `DrugSpec$new()`

Create a new `DrugSpec`.

#### Usage

    DrugSpec$new(
      drug_class,
      label,
      defs = NULL,
      generic_names = character(0L),
      generic_names_probable = character(0L),
      generic_names_cautious = character(0L),
      brand_names = list(),
      generic_defs = NULL,
      version = NULL
    )

#### Arguments

- `drug_class`:

  Short identifier string, e.g. `"acei"`.

- `label`:

  Human-readable label.

- `defs`:

  Character string describing the drug class. May be `NULL`.

- `generic_names`:

  Character vector of GNN drug names that are single-indication and
  aligned with, and FDA-approved for, this drug class's indication.
  Stored at `priority = 1` (core).

- `generic_names_probable`:

  Character vector of GNN drug names that have more than one indication
  (e.g., also FDA-approved, or widely used off-label, for a different
  condition) in addition to this drug class's indication. Stored at
  `priority = 2` (probable).

- `generic_names_cautious`:

  Character vector of GNN drug names that are included in this drug
  class despite not having their expected indication approved in the US
  (e.g., approved for a related but distinct condition, or not marketed
  in the US at all). Stored at `priority = 3` (cautious).

- `brand_names`:

  Optional named list mapping a GNN drug name (must appear in
  `generic_names`, `generic_names_probable`, or
  `generic_names_cautious`) to one or more brand name strings, e.g.
  `list(SEMAGLUTIDE = "Ozempic", "PAROXETINE MESYLATE" = c("Brisdelle", "Pexeva"))`.
  Generics with no entry get an empty brand vector. Stored as a
  list-column (`brand`) in `get_generics()` output, since a single
  generic can map to zero, one, or multiple brands. Ignored (and must be
  left empty) if `generic_defs` is supplied.

- `generic_defs`:

  Optional alternative to
  `generic_names`/`generic_names_probable`/`generic_names_cautious`/
  `brand_names`, for drug classes whose generics don't all map to a
  single condition/indication context (e.g. a drug that's core for one
  condition but cautious for another). A data frame/tibble with required
  columns `generic` (character) and `priority` (integer, `1`/`2`/`3`),
  and optional columns `condition` (character; `NA` if omitted, meaning
  "not condition-specific") and `brand` (character; `NA` if omitted or
  unknown). The same generic may appear in multiple rows with different
  `priority`/`condition` combinations (e.g. finerenone at priority 1 for
  `"ckd"` and priority 3 for `"hypertension"`), and multiple brands for
  one `(generic, priority, condition)` combination are expressed as
  duplicate rows differing only in `brand`:

      tibble::tribble(
        ~generic,       ~priority, ~condition,     ~brand,
        "FINERENONE",   1,         "ckd",          "Kerendia",
        "FINERENONE",   3,         "hypertension", "Kerendia",
        "EPLERENONE",   2,         "hypertension", "Inspra"
      )

  Cannot be combined with `generic_names`/`generic_names_probable`/
  `generic_names_cautious`/`brand_names`.

- `version`:

  Optional version label string, e.g. `"v1"`.

------------------------------------------------------------------------

### `DrugSpec$print()`

Print a summary of the spec.

#### Usage

    DrugSpec$print(...)

------------------------------------------------------------------------

### `DrugSpec$get_generics()`

Retrieve generic (and brand) drug names as a tidy data frame.

#### Usage

    DrugSpec$get_generics(priority = 1L, condition = NULL)

#### Arguments

- `priority`:

  Integer vector subsetting confidence tiers to include (`1` = core, `2`
  = probable, `3` = cautious). Default `1`.

- `condition`:

  Optional character vector subsetting to specific condition(s) (only
  meaningful for specs built with `generic_defs`; see DrugSpec\$new()).
  `NULL` (default) applies no condition filtering. When supplied, rows
  with a `condition` in `condition`, and rows with `condition = NA` (not
  condition-specific), are both included.

#### Returns

A tibble with columns `generic`, `brand` (a list-column of character
vectors — `character(0)` when a generic has no known brand, length 1+
otherwise), `priority`, `condition` (`NA` unless the spec was built with
`generic_defs`), `class`, and `version`. Use
`tidyr::unnest(result, brand, keep_empty = TRUE)` to get one row per
brand (this drops the generic entirely for a plain `unnest()` without
`keep_empty = TRUE`, since most generics have no brand on record).

------------------------------------------------------------------------

### `DrugSpec$get_defs()`

Retrieve the narrative drug class description.

#### Usage

    DrugSpec$get_defs()

#### Returns

Character string, or `NULL`.

------------------------------------------------------------------------

### `DrugSpec$clone()`

The objects of this class are cloneable with this method.

#### Usage

    DrugSpec$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
