# Compare code sets across versions of a condition definition

Lines up the code sets of two or more versions of a condition so you can
see exactly which codes were added or removed between versions. Every
version stays available unchanged (e.g.
[`get_diabetes_type2_v1_codes()`](https://perisphere-rwe.github.io/peridefs/reference/diabetes_type2_codes.md)
keeps returning the v1 codes after v2 is released); this function shows
how they differ. Codes of every type are compared (diagnosis, procedure,
HCPCS/CPT). Changes to the narrative algorithm (see the `get_*_defs()`
functions) are not.

## Usage

``` r
get_version_diffs(
  condition,
  versions = NULL,
  variable_type = c("condition", "outcome"),
  periods = FALSE,
  changes_only = FALSE,
  format = c("tibble", "flextable")
)
```

## Arguments

- condition:

  A single condition identifier, e.g. `"diabetes_type2"`. See
  [`list_versions()`](https://perisphere-rwe.github.io/peridefs/reference/list_versions.md)
  for the available conditions and versions.

- versions:

  The versions to compare, as labels (`c("v1", "v2")`) or numbers
  (`c(1, 2)`), in any order; at least two, each given once. `NULL`
  (default) compares every version of `condition`.

- variable_type:

  `"condition"` (default) or `"outcome"`: which definition's codes to
  compare. As in the `get_*_codes()` functions, a version with no
  outcome codes falls back to its condition codes.

- periods:

  Logical. `TRUE` returns decimal-format codes (e.g. `"250.00"`).
  Default `FALSE`.

- changes_only:

  Logical. `TRUE` drops codes that are in every compared version,
  leaving only the codes that changed. Default `FALSE`.

- format:

  `"tibble"` (default) or `"flextable"`. `"flextable"` returns a
  formatted table for reports (requires the flextable package): columns
  `definition`, `code`, one per version, `type`, `change`, with rows
  shaded like a GitHub diff (green: added; red: removed; grey:
  unchanged; yellow: the same in the first and last compared versions
  but changed in between, possible with three or more versions).

## Value

For `format = "tibble"`, a tibble with one row per code that appears in
any of the compared versions, and columns:

- one logical column per version (e.g. `v1`, `v2`), oldest first: `TRUE`
  if the code is in that version;

- `code`: the code;

- `type`: the code type (e.g. `"dx_icd10"`);

- `definition`: the code's description (from the newest version that
  contains it);

- `change`: `"unchanged"`, or how membership changed across the compared
  versions, e.g. `"added in v2"` or `"added in v2; removed in v4"`.

Rows are ordered by code type, then code.

For `format = "flextable"`, a `flextable` object with the same rows.

## See also

[`list_versions()`](https://perisphere-rwe.github.io/peridefs/reference/list_versions.md)
to see which versions exist.

## Examples

``` r
# Every version of type 2 diabetes
get_version_diffs("diabetes_type2")
#> # A tibble: 127 × 6
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
#> # ℹ 117 more rows

# Specific versions, by label or by number
get_version_diffs("diabetes_type2", versions = c("v1", "v2"))
#> # A tibble: 127 × 6
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
#> # ℹ 117 more rows
get_version_diffs("diabetes_type2", versions = c(1, 2))
#> # A tibble: 127 × 6
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
#> # ℹ 117 more rows

# Only the codes that changed
get_version_diffs("diabetes_type2", c(1, 2), changes_only = TRUE)
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

# As a formatted table
if (requireNamespace("flextable", quietly = TRUE)) {
  get_version_diffs("diabetes_type2", changes_only = TRUE, format = "flextable")
}


.cl-d8bad469{}.cl-31e46462{font-family:'Arial';font-size:11pt;font-weight:bold;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;}.cl-9f1c1ce9{font-family:'Arial';font-size:11pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;}.cl-6477613b{margin:0;text-align:left;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-a87b1e2d{margin:0;text-align:center;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-de9021d4{width:2.8in;background-color:transparent;vertical-align: middle;border-bottom: 0.75pt solid rgba(102, 102, 102, 1.00);border-top: 0.75pt solid rgba(102, 102, 102, 1.00);border-left: 0.75pt solid rgba(102, 102, 102, 1.00);border-right: 0.75pt solid rgba(102, 102, 102, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-6b590f75{width:0.84in;background-color:transparent;vertical-align: middle;border-bottom: 0.75pt solid rgba(102, 102, 102, 1.00);border-top: 0.75pt solid rgba(102, 102, 102, 1.00);border-left: 0.75pt solid rgba(102, 102, 102, 1.00);border-right: 0.75pt solid rgba(102, 102, 102, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-2fe54c33{width:2.8in;background-color:rgba(255, 235, 233, 1.00);vertical-align: middle;border-bottom: 0.75pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0.75pt solid rgba(102, 102, 102, 1.00);border-right: 0.75pt solid rgba(102, 102, 102, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-0b6db9d7{width:0.84in;background-color:rgba(255, 235, 233, 1.00);vertical-align: middle;border-bottom: 0.75pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0.75pt solid rgba(102, 102, 102, 1.00);border-right: 0.75pt solid rgba(102, 102, 102, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-38b6c474{width:0.84in;background-color:rgba(255, 206, 203, 1.00);vertical-align: middle;border-bottom: 0.75pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0.75pt solid rgba(102, 102, 102, 1.00);border-right: 0.75pt solid rgba(102, 102, 102, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-a2d6d8ad{width:2.8in;background-color:rgba(255, 235, 233, 1.00);vertical-align: middle;border-bottom: 0.75pt solid rgba(102, 102, 102, 1.00);border-top: 0.75pt solid rgba(102, 102, 102, 1.00);border-left: 0.75pt solid rgba(102, 102, 102, 1.00);border-right: 0.75pt solid rgba(102, 102, 102, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-ac8a7a25{width:0.84in;background-color:rgba(255, 235, 233, 1.00);vertical-align: middle;border-bottom: 0.75pt solid rgba(102, 102, 102, 1.00);border-top: 0.75pt solid rgba(102, 102, 102, 1.00);border-left: 0.75pt solid rgba(102, 102, 102, 1.00);border-right: 0.75pt solid rgba(102, 102, 102, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-7adf546f{width:0.84in;background-color:rgba(255, 206, 203, 1.00);vertical-align: middle;border-bottom: 0.75pt solid rgba(102, 102, 102, 1.00);border-top: 0.75pt solid rgba(102, 102, 102, 1.00);border-left: 0.75pt solid rgba(102, 102, 102, 1.00);border-right: 0.75pt solid rgba(102, 102, 102, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-4d6993ad{width:2.8in;background-color:rgba(218, 251, 225, 1.00);vertical-align: middle;border-bottom: 0.75pt solid rgba(102, 102, 102, 1.00);border-top: 0.75pt solid rgba(102, 102, 102, 1.00);border-left: 0.75pt solid rgba(102, 102, 102, 1.00);border-right: 0.75pt solid rgba(102, 102, 102, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-6098bf23{width:0.84in;background-color:rgba(218, 251, 225, 1.00);vertical-align: middle;border-bottom: 0.75pt solid rgba(102, 102, 102, 1.00);border-top: 0.75pt solid rgba(102, 102, 102, 1.00);border-left: 0.75pt solid rgba(102, 102, 102, 1.00);border-right: 0.75pt solid rgba(102, 102, 102, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-4b9ab49d{width:0.84in;background-color:rgba(172, 238, 187, 1.00);vertical-align: middle;border-bottom: 0.75pt solid rgba(102, 102, 102, 1.00);border-top: 0.75pt solid rgba(102, 102, 102, 1.00);border-left: 0.75pt solid rgba(102, 102, 102, 1.00);border-right: 0.75pt solid rgba(102, 102, 102, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}


definition
```
