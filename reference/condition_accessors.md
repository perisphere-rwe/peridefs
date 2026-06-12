# Miscellaneous condition accessor functions

Accessor functions for condition specs.

## Arguments

- code_type:

  Optional code type filter.

- variable_type:

  `"condition"` (default) or `"outcome"`.

- periods:

  Logical. Return decimal-format codes.

- format:

  `"list"` (default) or `"tibble"`.

- component:

  For composite specs: a named component (e.g. `"chd_v1"`), or `"all"`
  to union all components. For leaf specs, not used.
