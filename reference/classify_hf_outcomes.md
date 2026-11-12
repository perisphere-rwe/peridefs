# Classify heart failure outcomes in claims data

Applies a version's heart failure outcome rules to diagnosis-level
claims and returns one row per event. The rules come from the version's
outcome code table (`get_hf_v2_codes(variable_type = "outcome")`),
including its `required_secondary` and `qualifies_as_primary` columns,
so what analysts see in the table is what is applied.

Two outcomes are classified, both only from claims strictly after the
patient's reference date plus `min_event_days`:

- `acute_hf_hospitalization`: an inpatient claim (`claim_setting` equal
  to any value of `inpatient_setting`) where either (a) the primary
  diagnosis is an acute or acute-on-chronic I50 code, or (b) the primary
  diagnosis is I11.0 and any I50 code is in a non-primary position, or
  the primary diagnosis is I13.0 or I13.2 and both an I50 and an N18
  code are in non-primary positions.

- `incident_hf`: the first claim (any setting, any diagnosis position)
  with any I50 code. It is incident only if the cohort excludes patients
  with heart failure before the reference date; see
  `exclude_prevalent_hf`.

The function does not remove prevalent heart failure, define the
reference date, or define follow-up windows. Those belong to cohort
construction.

## Usage

``` r
classify_hf_outcomes(
  data,
  col_ref_date,
  outcomes = c("acute_hf_hospitalization", "incident_hf"),
  version = "v2",
  min_event_days = 0L,
  exclude_prevalent_hf = TRUE,
  col_patient_id = "patient_id",
  col_claim_id = "claim_id",
  col_dx_code = "dx_code",
  col_dx_position = "dx_position",
  col_claim_setting = "claim_setting",
  col_claim_date = "claim_date",
  inpatient_setting = "inpatient"
)
```

## Arguments

- data:

  A data frame or lazy table with one row per diagnosis per claim.

- col_ref_date:

  Name of the column holding each patient's reference date, the date
  follow-up for events starts. Required. It should hold one date per
  patient, repeated on that patient's rows, with no missing values.

- outcomes:

  One or both of `"acute_hf_hospitalization"` and `"incident_hf"`.

- version:

  Heart failure definition version, e.g. `"v2"` or `2`. Only versions
  that define outcome rules are supported.

- min_event_days:

  Whole number of days, at least 0 (default `0L`). Only claims strictly
  after `col_ref_date + min_event_days` are classified.

- exclude_prevalent_hf:

  If `TRUE` (default) and `"incident_hf"` is requested, the function
  errors when the input has any heart failure claim (any code in the
  outcome code table, any position and setting) strictly before
  `col_ref_date`. This only checks claims present in `data`, so pass the
  pre-reference claims along; filtering them out first makes the check
  pass without proving anything. Set to `FALSE` to skip the check, e.g.
  for studies of recurrent heart failure events. The check is not run
  when only `"acute_hf_hospitalization"` is requested.

- col_patient_id, col_claim_id:

  Names of the patient and claim identifier columns. A claim is
  identified by the patient and claim IDs together.

- col_dx_code:

  Name of the column with ICD-10-CM diagnosis codes in short format (no
  periods).

- col_dx_position:

  Name of the integer column with the diagnosis position on the claim
  (`1` is primary).

- col_claim_setting:

  Name of the column with the claim setting. Acute hospitalizations are
  taken from claims whose setting is one of the values in
  `inpatient_setting`.

- col_claim_date:

  Name of the date column with the claim's start date (the admission
  date for inpatient claims, the visit date for others).

- inpatient_setting:

  One or more values of the claim setting column that identify overnight
  inpatient claims, e.g. `c("inpatient_a", "inpatient_b")` when
  inpatient stays are coded under several settings. Default
  `"inpatient"`.

## Value

A data frame (or lazy table, for lazy input) with one row per event and
columns `patient_id`, `outcome`, `claim_id`, `claim_date` and
`qualifying_code`, always under these names regardless of the `col_*`
arguments. A claim can appear once per outcome. For
`acute_hf_hospitalization`, `qualifying_code` is the primary diagnosis
code. For `incident_hf` there is at most one row per patient, the first
claim by date (then claim ID), and `qualifying_code` is the first I50
code on it alphabetically.

## Details

`data` can be a local data frame or a lazy table (e.g., duckdb or Spark
through dbplyr). Only dplyr verbs are applied, so lazy input stays lazy
and a lazy table is returned. The validation checks run small queries
that return counts (and, if the prevalent-HF check fails, a few example
rows). With `min_event_days > 0`, date arithmetic is translated by the
backend, so check it on backends other than duckdb.

Diagnosis codes must be ICD-10-CM in short format, with no periods
(`"I5021"`, not `"I50.21"`); other codes simply do not match. Version
`v2` is ICD-10 only, so claims before October 1, 2015 cannot be
classified.

## See also

[`get_hf_v2_codes()`](https://perisphere-rwe.github.io/peridefs/reference/hf_codes.md)

## Examples

``` r
claims <- data.frame(
  patient_id    = c(1, 1, 2, 2, 2),
  claim_id      = c("a", "b", "c", "c", "c"),
  claim_setting = c("outpatient", "inpatient", "inpatient", "inpatient", "inpatient"),
  claim_date    = as.Date(c("2024-01-10", "2024-03-01", rep("2024-02-05", 3))),
  ref_date      = as.Date("2024-01-01"),
  dx_position   = c(1, 1, 1, 2, 3),
  dx_code       = c("I509", "I5021", "I130", "I5022", "N184")
)
classify_hf_outcomes(claims, col_ref_date = "ref_date")
#> # A tibble: 4 × 5
#>   patient_id outcome                  claim_id claim_date qualifying_code
#>        <dbl> <chr>                    <chr>    <date>     <chr>          
#> 1          1 incident_hf              a        2024-01-10 I509           
#> 2          1 acute_hf_hospitalization b        2024-03-01 I5021          
#> 3          2 acute_hf_hospitalization c        2024-02-05 I130           
#> 4          2 incident_hf              c        2024-02-05 I5022          
```
