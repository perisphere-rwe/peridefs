# Retrieve ICD codes for Type 2 diabetes mellitus

Returns code sets from `spec_diabetes_type2_v1`. The definition is
diagnosis-based (ICD-9 Type 2/unspecified codes 250.x0/250.x2 plus
complication codes 357.2, 362.0x, 366.41; and ICD-10 E11.xx, E08.xx,
E09.xx, E13.xx), with an alternative qualifying path of \\\geq\\1
pharmacy claim for an oral antidiabetic drug or insulin (see
`spec_diabetes_type2`). Patients are further classified into four
mutually exclusive categories (no diabetes; diabetes without
antidiabetic medication; diabetes with oral antidiabetic; diabetes with
insulin).

## Usage

``` r
get_diabetes_type2_v1_codes(
  code_type = NULL,
  variable_type = c("condition", "outcome"),
  periods = FALSE,
  priority = 1L
)

get_diabetes_type2_v1_defs(variable_type = c("condition", "outcome"))
```

## Arguments

- code_type:

  Optional character vector of code types to return. Valid values:
  `"dx_icd9"`, `"dx_icd10"`, `"proc_icd9"`, `"proc_icd10"`, `"hcpcs"`,
  `"cpt"`, `"rev"`. `NULL` (default) returns all code types.

- variable_type:

  `"condition"` (default) or `"outcome"`. Hypertension is defined as a
  condition only; `"outcome"` falls back to condition codes.

- periods:

  Logical. `FALSE` (default) returns short-format codes (e.g.,
  `"4010"`). `TRUE` returns decimal-format codes (e.g., `"401.0"`).

- priority:

  Integer vector subsetting confidence tiers to include (`1` = core, `2`
  = probable, `3` = cautious). Default `1`.

## See also

`get_diabetes_type2_v1_defs()`, `spec_diabetes_type2_v1`

`get_diabetes_type2_v1_codes()`
