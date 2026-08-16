# Miscellaneous drug accessor functions

Accessor functions for composite drug specs. For each composite,
`get_*_generics()` returns the tidy tibble of generic (and brand) drug
names, and `get_*_meds_labels()` returns a tibble of each component's
`name` (its key, e.g. `"acei_v1"`) and human-readable `label` (e.g.
`"ACE Inhibitors"`) — not a narrative definition. Composite drug specs
don't carry a clinically meaningful "definition" the way condition specs
do (see
[`get_hypertension_v1_defs()`](https://perisphere-rwe.github.io/peridefs/reference/get_hypertension_v1_defs.md)
for that); a drug leaf's `defs` field is just an internal sourcing note,
so `get_*_meds_labels()` surfaces the more useful per-component label
instead.

Accessor functions for composite drug specs.

## Arguments

- priority:

  Integer vector subsetting confidence tiers to include (`1` = core, `2`
  = probable, `3` = cautious). Default `1`.

- condition:

  Optional character vector subsetting to specific condition(s). `NULL`
  (default) uses the composite's own condition (e.g.
  [`get_obesity_generics()`](https://perisphere-rwe.github.io/peridefs/reference/get_obesity_generics.md)
  defaults to `"obesity"`), so a leaf component shared across composites
  (e.g. a GLP-1 spec used by both the obesity and diabetes composites)
  only contributes its rows for *this* composite's condition. Pass a
  value explicitly to widen or otherwise override the default.

- component:

  Optional named component (e.g. `"acei_v1"`) for composite specs.
  `NULL` (default) or `"all"` returns every component's generics. Print
  the composite spec to see all available component names.
