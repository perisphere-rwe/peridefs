# Miscellaneous condition accessor functions

Accessor functions for condition specs.

## Arguments

- code_type:

  Optional code type filter.

- variable_type:

  `"condition"` (default) or `"outcome"`.

- periods:

  Logical. Return decimal-format codes.

- priority:

  Integer vector subsetting confidence tiers to include (`1` = core, `2`
  = probable, `3` = cautious). Default `1`.

- component:

  For composite specs: optional named component (e.g. `"chd_v1"`).
  `NULL` (default) or `"all"` returns every component. For leaf specs,
  not used.
