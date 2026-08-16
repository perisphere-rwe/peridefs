# Retrieve ICD codes for diabetes mellitus

Returns code sets from a diabetes
[CodeSpec](https://perisphere-rwe.github.io/peridefs/reference/CodeSpec.md).
The condition definition is diagnosis-based, with a medication criterion
(see `spec_diabetes`) as an alternative qualifying path, and patients
are further classified into four mutually exclusive categories (no
diabetes; diabetes without antidiabetic medication; diabetes with oral
antidiabetic; diabetes with insulin).

## Usage

``` r
get_diabetes_v1_codes(
  code_type = NULL,
  variable_type = c("condition", "outcome"),
  periods = FALSE,
  priority = 1L
)

get_diabetes_v1_defs(variable_type = c("condition", "outcome"))
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

`get_diabetes_v1_defs()`, `spec_diabetes_v1`

`get_diabetes_v1_defs()`
