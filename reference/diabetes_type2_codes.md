# Type 2 diabetes mellitus code sets (all versions)

`get_diabetes_type2_vN_codes()` returns the ICD code set for version N
of the type 2 diabetes definition, and `get_diabetes_type2_vN_defs()`
displays its narrative algorithm. Each version is frozen once released:
later versions never change what an earlier version's functions return.

Every version has an alternative qualifying path of \\\geq\\1 pharmacy
claim for an oral antidiabetic drug or insulin (see
`spec_diabetes_type2`), and classifies patients into four mutually
exclusive categories (no diabetes; diabetes without antidiabetic
medication; diabetes with oral antidiabetic; diabetes with insulin).

## Usage

``` r
get_diabetes_type2_v1_codes(
  code_type = NULL,
  variable_type = c("condition", "outcome"),
  periods = FALSE,
  priority = 1L
)

get_diabetes_type2_v1_defs(variable_type = c("condition", "outcome"))

get_diabetes_type2_v2_codes(
  code_type = NULL,
  variable_type = c("condition", "outcome"),
  periods = FALSE,
  priority = 1L
)

get_diabetes_type2_v2_defs(variable_type = c("condition", "outcome"))
```

## Arguments

- code_type:

  Optional character vector of code types to return. Valid values:
  `"dx_icd9"`, `"dx_icd10"`, `"proc_icd9"`, `"proc_icd10"`, `"hcpcs"`,
  `"cpt"`, `"rev"`. `NULL` (default) returns all code types.

- variable_type:

  `"condition"` (default) or `"outcome"`. Type 2 diabetes is defined as
  a condition only; `"outcome"` falls back to condition codes.

- periods:

  Logical. `FALSE` (default) returns short-format codes (e.g.,
  `"4010"`). `TRUE` returns decimal-format codes (e.g., `"401.0"`).

- priority:

  Integer vector subsetting confidence tiers to include (`1` = core, `2`
  = probable, `3` = cautious). Default `1`.

## Value

`get_diabetes_type2_vN_codes()`: a tibble with columns `type`, `code`,
`priority`, `version`, and `definition`. `get_diabetes_type2_vN_defs()`:
the narrative definition (displayed, and returned invisibly), or `NULL`.

## Versions

- v1:

  ICD-9 type 2/unspecified codes 250.x0/250.x2 plus complication codes
  357.2, 362.0x, 366.41; and ICD-10 E11.xx, E08.xx, E09.xx, E13.xx.

- v2:

  ICD-10 type 2 diabetes codes only: every billable E11 code, including
  E11.A (in remission). No ICD-9 codes, so claims before October 1, 2015
  cannot qualify through the diagnosis criteria.

## Version history

Every version below remains available. Compare any of them with
`get_version_diffs("diabetes_type2")`; list them with
`list_versions("diabetes_type2")`.

- **v1**: initial version (126 codes).

- **v2** (2026-10-22, 87 codes): ICD-10 type 2 diabetes codes (E11)
  only.

  - Why: A more specific definition. Drops all ICD-9 codes and the
    ICD-10 codes for diabetes due to an underlying condition (E08),
    drug- or chemical-induced diabetes (E09) and other specified
    diabetes (E13), keeping only type 2 diabetes (E11). Adds E11.A (type
    2 diabetes without complications, in remission), the one billable
    E11 code missing from v1. Because no ICD-9 codes remain, claims
    before October 1, 2015 cannot qualify through the diagnosis
    criteria. The medication criterion is unchanged.

  - Codes compared with v1:

    - Removed 40 codes:

      - dx_icd9 (33): `250`, `2500`, `25000`, `25002`, `25010`, `25012`,
        `2502`, `25020`, `25022`, `25030`, `25032`, `25040`, `25042`,
        `25050`, `25052`, `25060`, `25062`, `25070`, `25072`, `25080`,
        `25082`, `25090`, `25092`, `3572`, `3620`, `36201`, `36202`,
        `36203`, `36204`, `36205`, `36206`, `36207`, `36641`

      - dx_icd10 (7): `E0836`, `E0842`, `E0936`, `E0942`, `E1310`,
        `E1336`, `E1342`

    - Added 1 code:

      - dx_icd10 (1): `E11A`

## See also

[`get_version_diffs()`](https://perisphere-rwe.github.io/peridefs/reference/get_version_diffs.md),
[`list_versions()`](https://perisphere-rwe.github.io/peridefs/reference/list_versions.md),
`spec_diabetes_type2_v1`, `spec_diabetes_type2_v2`

## Examples

``` r
get_diabetes_type2_v2_codes()
#> # A tibble: 87 × 5
#>    type     code    priority version definition                                 
#>    <chr>    <chr>      <int> <chr>   <chr>                                      
#>  1 dx_icd10 E1100          1 v2      Type 2 diabetes mellitus with hyperosmolar…
#>  2 dx_icd10 E1101          1 v2      Type 2 diabetes mellitus with hyperosmolar…
#>  3 dx_icd10 E1110          1 v2      Type 2 diabetes mellitus with ketoacidosis…
#>  4 dx_icd10 E1111          1 v2      Type 2 diabetes mellitus with ketoacidosis…
#>  5 dx_icd10 E1121          1 v2      Type 2 diabetes mellitus with diabetic nep…
#>  6 dx_icd10 E1122          1 v2      Type 2 diabetes mellitus with diabetic chr…
#>  7 dx_icd10 E1129          1 v2      Type 2 diabetes mellitus with other diabet…
#>  8 dx_icd10 E11311         1 v2      Type 2 diabetes mellitus with unspecified …
#>  9 dx_icd10 E11319         1 v2      Type 2 diabetes mellitus with unspecified …
#> 10 dx_icd10 E113211        1 v2      Type 2 diabetes mellitus with mild nonprol…
#> # ℹ 77 more rows
get_diabetes_type2_v2_defs()
#> ℹ Any of the following:
#> • ≥1 inpatient claim with a discharge ICD-10 type 2 diabetes diagnosis (E11.x:
#>   any billable E11 code, including E11.A for diabetes in remission) in any
#>   discharge position.
#> • ≥2 carrier/outpatient claims with the same ICD-10 codes in any position,
#>   occurring at least 7 days apart.
#> • ≥1 pharmacy claim for an oral antidiabetic drug or insulin (see
#>   spec_diabetes_type2).
#> ℹ Patients are then classified into four mutually exclusive categories: no
#>   diabetes; diabetes without antidiabetic medication; diabetes with oral
#>   antidiabetic (non-insulin); diabetes with insulin.
#> ! ICD-10 only: claims before October 1, 2015 (ICD-9 era) cannot qualify through
#>   the diagnosis criteria.

# What changed from v1 to v2?
get_version_diffs("diabetes_type2", versions = c(1, 2), changes_only = TRUE)
#> # A tibble: 41 × 6
#>    v1    v2    code  type    definition                                   change
#>    <lgl> <lgl> <chr> <chr>   <chr>                                        <chr> 
#>  1 TRUE  FALSE 250   dx_icd9 Diabetes mellitus                            remov…
#>  2 TRUE  FALSE 2500  dx_icd9 Diabetes mellitus: Diabetes mellitus withou… remov…
#>  3 TRUE  FALSE 25000 dx_icd9 Diabetes mellitus without mention of compli… remov…
#>  4 TRUE  FALSE 25002 dx_icd9 Diabetes mellitus without mention of compli… remov…
#>  5 TRUE  FALSE 25010 dx_icd9 Diabetes with ketoacidosis, type II or unsp… remov…
#>  6 TRUE  FALSE 25012 dx_icd9 Diabetes with ketoacidosis, type II or unsp… remov…
#>  7 TRUE  FALSE 2502  dx_icd9 Diabetes mellitus: Diabetes with hyperosmol… remov…
#>  8 TRUE  FALSE 25020 dx_icd9 Diabetes with hyperosmolarity, type II or u… remov…
#>  9 TRUE  FALSE 25022 dx_icd9 Diabetes with hyperosmolarity, type II or u… remov…
#> 10 TRUE  FALSE 25030 dx_icd9 Diabetes with other coma, type II or unspec… remov…
#> # ℹ 31 more rows
```
