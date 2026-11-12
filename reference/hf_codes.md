# Heart failure code sets (all versions)

`get_hf_vN_codes()` returns the ICD code set for version N of the heart
failure definition, and `get_hf_vN_defs()` displays its narrative
algorithm. Heart failure is both a condition (history) and an outcome
definition: the condition definition counts inpatient or repeated
outpatient claims in any diagnosis position, while the outcome
definition requires an overnight hospitalization with a primary
discharge diagnosis of heart failure. Each version is frozen once
released: later versions never change what an earlier version's
functions return.

## Usage

``` r
get_hf_v1_codes(
  code_type = NULL,
  variable_type = c("condition", "outcome"),
  periods = FALSE,
  priority = 1L
)

get_hf_v1_defs(variable_type = c("condition", "outcome"))

get_hf_v2_codes(
  code_type = NULL,
  variable_type = c("condition", "outcome"),
  periods = FALSE,
  priority = 1L
)

get_hf_v2_defs(variable_type = c("condition", "outcome"))
```

## Arguments

- code_type:

  Optional character vector of code types to return. Valid values:
  `"dx_icd9"`, `"dx_icd10"`, `"proc_icd9"`, `"proc_icd10"`, `"hcpcs"`,
  `"cpt"`, `"rev"`. `NULL` (default) returns all code types.

- variable_type:

  `"condition"` (default) or `"outcome"`. Both are defined for heart
  failure; in v2 the outcome set also includes I11.0, I13.0 and I13.2.

- periods:

  Logical. `FALSE` (default) returns short-format codes (e.g.,
  `"4010"`). `TRUE` returns decimal-format codes (e.g., `"401.0"`).

- priority:

  Integer vector subsetting confidence tiers to include (`1` = core, `2`
  = probable, `3` = cautious). Default `1`.

## Value

`get_hf_vN_codes()`: a tibble with columns `type`, `code`, `priority`,
`version`, and `definition` (plus `acuity`, `required_secondary` and
`qualifies_as_primary` for v2 outcomes). `get_hf_vN_defs()`: the
narrative definition (displayed, and returned invisibly), or `NULL`.

## Versions

- v1:

  ICD-9 402.01, 402.11, 402.91, 404.01, 404.03, 404.11, 404.13, 404.91,
  404.93, 428.x; and ICD-10 I11.0, I13.0, I13.2, I50.x.

- v2:

  ICD-10 only, so claims before October 1, 2015 cannot qualify. History
  uses every billable I50 code; I11.0, I13.0 and I13.2 are left out
  because they require a secondary I50.x on the same claim. Outcomes use
  all of those codes plus per-code columns that describe the rules (see
  below).

## v2 outcome code attributes

`get_hf_v2_codes(variable_type = "outcome")` has three extra columns,
which illustrate the outcome rules and are not applied by the package:

- `acuity`:

  `"acute"`, `"acute_on_chronic"`, `"chronic"` or `"unspecified"` for
  I50 codes (including I50.814, I50.82, I50.83 and I50.84, whose
  descriptors give no acuity); `NA` for I11.0, I13.0 and I13.2.

- `required_secondary`:

  Codes that must appear in non-primary positions: `"I50.x"` for I11.0,
  `"I50.x + N18.x"` for I13.0 and I13.2, otherwise `"none"`.

- `qualifies_as_primary`:

  `TRUE` for the acute and acute-on-chronic I50 codes and for I11.0,
  I13.0 and I13.2 (subject to `required_secondary`). Chronic and
  unspecified I50 codes can be the secondary code, or count toward
  incident heart failure, but do not qualify as the primary diagnosis of
  an acute heart failure hospitalization.

## Version history

Every version below remains available. Compare any of them with
`get_version_diffs("hf")`; list them with `list_versions("hf")`.

- **v1**: initial version (54 codes).

- **v2** (2026-10-23, 23 codes): ICD-10 only; history uses I50.x;
  outcomes add I11.0, I13.0, I13.2 with acuity rules.

  - Why: Restricts heart failure to ICD-10-CM codes. Drops all ICD-9
    codes (402.x1, 404.x1, 404.x3 and 428.x), so claims and
    hospitalizations before October 1, 2015 cannot qualify. History no
    longer uses I11.0, I13.0 and I13.2, which require a secondary I50.x
    on the same claim, so it is I50.x only. The outcome definition is
    rebuilt around acute heart failure hospitalization (an acute or
    acute-on-chronic I50 code as the primary diagnosis, or I11.0, I13.0
    or I13.2 as the primary diagnosis with the required secondary codes)
    and incident heart failure (any I50 code). The outcome code set
    carries acuity, required_secondary and qualifies_as_primary columns
    that describe these rules.

  - Condition codes compared with v1:

    - Removed 31 codes:

      - dx_icd9 (28): `40201`, `40211`, `40291`, `40401`, `40403`,
        `40411`, `40413`, `40491`, `40493`, `428`, `4280`, `4281`,
        `4282`, `42820`, `42821`, `42822`, `42823`, `4283`, `42830`,
        `42831`, `42832`, `42833`, `4284`, `42840`, `42841`, `42842`,
        `42843`, `4289`

      - dx_icd10 (3): `I110`, `I130`, `I132`

  - Outcome codes compared with v1:

    - Removed 28 codes:

      - dx_icd9 (28): `40201`, `40211`, `40291`, `40401`, `40403`,
        `40411`, `40413`, `40491`, `40493`, `428`, `4280`, `4281`,
        `4282`, `42820`, `42821`, `42822`, `42823`, `4283`, `42830`,
        `42831`, `42832`, `42833`, `4284`, `42840`, `42841`, `42842`,
        `42843`, `4289`

## See also

[`get_version_diffs()`](https://perisphere-rwe.github.io/peridefs/reference/get_version_diffs.md),
[`list_versions()`](https://perisphere-rwe.github.io/peridefs/reference/list_versions.md),
`spec_hf_v1`, `spec_hf_v2`

## Examples

``` r
get_hf_v2_codes()
#> # A tibble: 23 × 5
#>    type     code  priority version definition                                   
#>    <chr>    <chr>    <int> <chr>   <chr>                                        
#>  1 dx_icd10 I501         1 v2      Left ventricular failure, unspecified        
#>  2 dx_icd10 I5020        1 v2      Unspecified systolic (congestive) heart fail…
#>  3 dx_icd10 I5021        1 v2      Acute systolic (congestive) heart failure    
#>  4 dx_icd10 I5022        1 v2      Chronic systolic (congestive) heart failure  
#>  5 dx_icd10 I5023        1 v2      Acute on chronic systolic (congestive) heart…
#>  6 dx_icd10 I5030        1 v2      Unspecified diastolic (congestive) heart fai…
#>  7 dx_icd10 I5031        1 v2      Acute diastolic (congestive) heart failure   
#>  8 dx_icd10 I5032        1 v2      Chronic diastolic (congestive) heart failure 
#>  9 dx_icd10 I5033        1 v2      Acute on chronic diastolic (congestive) hear…
#> 10 dx_icd10 I5040        1 v2      Unspecified combined systolic (congestive) a…
#> # ℹ 13 more rows
get_hf_v2_codes(variable_type = "outcome")
#> # A tibble: 26 × 8
#>    type     code  priority version definition          acuity required_secondary
#>    <chr>    <chr>    <int> <chr>   <chr>               <chr>  <chr>             
#>  1 dx_icd10 I110         1 v2      Hypertensive heart… NA     I50.x             
#>  2 dx_icd10 I130         1 v2      Hypertensive heart… NA     I50.x + N18.x     
#>  3 dx_icd10 I132         1 v2      Hypertensive heart… NA     I50.x + N18.x     
#>  4 dx_icd10 I501         1 v2      Left ventricular f… unspe… none              
#>  5 dx_icd10 I5020        1 v2      Unspecified systol… unspe… none              
#>  6 dx_icd10 I5021        1 v2      Acute systolic (co… acute  none              
#>  7 dx_icd10 I5022        1 v2      Chronic systolic (… chron… none              
#>  8 dx_icd10 I5023        1 v2      Acute on chronic s… acute… none              
#>  9 dx_icd10 I5030        1 v2      Unspecified diasto… unspe… none              
#> 10 dx_icd10 I5031        1 v2      Acute diastolic (c… acute  none              
#> # ℹ 16 more rows
#> # ℹ 1 more variable: qualifies_as_primary <lgl>
get_hf_v2_defs(variable_type = "outcome")
#> ℹ Acute heart failure hospitalization: an overnight hospitalization with
#>   either:
#> • a primary discharge diagnosis of an acute or acute-on-chronic I50 code
#>   (I50.21, I50.23, I50.31, I50.33, I50.41, I50.43, I50.811, I50.813); or
#> • a primary diagnosis of I11.0 with any I50 code in a non-primary position; or
#>   a primary diagnosis of I13.0 or I13.2 with both any I50 code and any N18 code
#>   in non-primary positions.
#> ! I50 codes with chronic or unspecified acuity (e.g., I50.9, I50.22) do not
#>   qualify as the primary diagnosis, but any I50 code can be the secondary code
#>   in the I11.0/I13.x rule. I50.84 (end-stage) does not qualify as a primary
#>   diagnosis.
#> ℹ Incident heart failure:
#> • any I50 code in any position during follow-up, with no I50, I11.0, I13.0 or
#>   I13.2 in the baseline period. Baseline and follow-up windows are defined by
#>   the study.
#> ! ICD-10 only: hospitalizations before October 1, 2015 (ICD-9 era) cannot
#>   qualify. Position rules are applied outside the package; see the acuity,
#>   required_secondary and qualifies_as_primary columns of the outcome code set.

# Codes that can be the primary diagnosis of an acute HF hospitalization
subset(get_hf_v2_codes(variable_type = "outcome"), qualifies_as_primary)
#> # A tibble: 11 × 8
#>    type     code   priority version definition         acuity required_secondary
#>    <chr>    <chr>     <int> <chr>   <chr>              <chr>  <chr>             
#>  1 dx_icd10 I110          1 v2      Hypertensive hear… NA     I50.x             
#>  2 dx_icd10 I130          1 v2      Hypertensive hear… NA     I50.x + N18.x     
#>  3 dx_icd10 I132          1 v2      Hypertensive hear… NA     I50.x + N18.x     
#>  4 dx_icd10 I5021         1 v2      Acute systolic (c… acute  none              
#>  5 dx_icd10 I5023         1 v2      Acute on chronic … acute… none              
#>  6 dx_icd10 I5031         1 v2      Acute diastolic (… acute  none              
#>  7 dx_icd10 I5033         1 v2      Acute on chronic … acute… none              
#>  8 dx_icd10 I5041         1 v2      Acute combined sy… acute  none              
#>  9 dx_icd10 I5043         1 v2      Acute on chronic … acute… none              
#> 10 dx_icd10 I50811        1 v2      Acute right heart… acute  none              
#> 11 dx_icd10 I50813        1 v2      Acute on chronic … acute… none              
#> # ℹ 1 more variable: qualifies_as_primary <lgl>

# What changed from v1 to v2?
get_version_diffs("hf", versions = c(1, 2), changes_only = TRUE)
#> # A tibble: 31 × 6
#>    v1    v2    code  type    definition                                   change
#>    <lgl> <lgl> <chr> <chr>   <chr>                                        <chr> 
#>  1 TRUE  FALSE 40201 dx_icd9 Malignant hypertensive heart disease with h… remov…
#>  2 TRUE  FALSE 40211 dx_icd9 Benign hypertensive heart disease with hear… remov…
#>  3 TRUE  FALSE 40291 dx_icd9 Unspecified hypertensive heart disease with… remov…
#>  4 TRUE  FALSE 40401 dx_icd9 Hypertensive heart and chronic kidney disea… remov…
#>  5 TRUE  FALSE 40403 dx_icd9 Hypertensive heart and chronic kidney disea… remov…
#>  6 TRUE  FALSE 40411 dx_icd9 Hypertensive heart and chronic kidney disea… remov…
#>  7 TRUE  FALSE 40413 dx_icd9 Hypertensive heart and chronic kidney disea… remov…
#>  8 TRUE  FALSE 40491 dx_icd9 Hypertensive heart and chronic kidney disea… remov…
#>  9 TRUE  FALSE 40493 dx_icd9 Hypertensive heart and chronic kidney disea… remov…
#> 10 TRUE  FALSE 428   dx_icd9 Heart failure                                remov…
#> # ℹ 21 more rows
```
