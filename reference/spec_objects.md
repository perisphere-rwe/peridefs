# Condition and Drug Code Specification Objects

`peridefs` exports one `spec_*` object per medical condition version or
drug class. Each is an [R6](https://r6.r-lib.org/reference/R6Class.html)
object:

- **Standalone conditions**: a `spec` for a single condition. These
  specs are versioned (e.g., `spec_htn_v1`, `spec_htn_v2`).

- **Composite specs**: a collection of standalone conditions in a single
  spec. For example, atherosclerotic cardiovascular disease is a
  composition of standalong specs for coronary heart disease, stroke,
  and cerebrovascular disease. Composite specs are not versioned because
  they have multiple components that each have versions. Use
  `component=` to access individual components and their respective
  versions, or `component = "all"` to get a union of all the components.

Print any spec to see its definition, code sets, and (for composites)
available component names.

## Condition specs (standalone, [CodeSpec](https://perisphere-rwe.github.io/peridefs/reference/CodeSpec.md))

`spec_htn_v1`, `spec_htn_v2`, `spec_hf_v1`, `spec_obesity_v1`,
`spec_diabetes_v1`, `spec_diabetes_v2`, `spec_diabetes_v3`,
`spec_ckd_v1`, `spec_copd_v1`, `spec_osa_v1`, `spec_hyperlipidemia_v1`

## ASCVD composite ([CompositeCodeSpec](https://perisphere-rwe.github.io/peridefs/reference/CompositeCodeSpec.md))

`spec_ascvd`

## Drug class composites ([CompositeDrugSpec](https://perisphere-rwe.github.io/peridefs/reference/CompositeDrugSpec.md))

`spec_antihypertensive`, `spec_antidiabetic`
