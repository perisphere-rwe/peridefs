# Getting Started

``` r

library(peridefs)
```

`peridefs` provides code sets (ICD-9, ICD-10, and HCPCS/CPT) to define
conditions such as hypertension, diabetes, and atherosclerotic
cardiovascular disease in real world claims data. It also contains
generic names for common drug types (e.g., anti-diabetes). The purpose
of the `peridefs` package is to provide safe and easy access to these
validated definitions.

### Retrieving condition codes

Each condition has one or more `get_<condition>_vX_codes()` functions —
one per algorithm version. Every `get_*` function in `peridefs` returns
a tidy data frame:

``` r

get_hypertension_v1_codes()
#> # A tibble: 36 × 4
#>    type    code  priority version
#>    <chr>   <chr>    <int> <chr>  
#>  1 dx_icd9 401          1 v1     
#>  2 dx_icd9 4010         1 v1     
#>  3 dx_icd9 4011         1 v1     
#>  4 dx_icd9 4019         1 v1     
#>  5 dx_icd9 4030         1 v1     
#>  6 dx_icd9 40300        1 v1     
#>  7 dx_icd9 40301        1 v1     
#>  8 dx_icd9 4031         1 v1     
#>  9 dx_icd9 40310        1 v1     
#> 10 dx_icd9 40311        1 v1     
#> # ℹ 26 more rows
```

The `priority` column reflects our confidence that a code belongs in the
definition (`1` = core, `2` = probable, `3` = cautious); by default only
`priority = 1` rows are returned. The `version` column identifies which
version of the spec produced each row.

#### Selecting a code type

By default, `get_` functions will return all relevant codes or generics.
If you only want to return a specific type or types of codes, use the
`code_type` argument to retrieve a filtered code list. Supprted values
are `"dx_icd9"`, `"dx_icd10"`, `"hcpcs"`, `"proc_icd9"`, and
`"proc_icd10"`:

``` r

get_hypertension_v1_codes(code_type = "dx_icd10")
#> # A tibble: 23 × 4
#>    type     code  priority version
#>    <chr>    <chr>    <int> <chr>  
#>  1 dx_icd10 I10          1 v1     
#>  2 dx_icd10 I11          1 v1     
#>  3 dx_icd10 I110         1 v1     
#>  4 dx_icd10 I119         1 v1     
#>  5 dx_icd10 I12          1 v1     
#>  6 dx_icd10 I120         1 v1     
#>  7 dx_icd10 I129         1 v1     
#>  8 dx_icd10 I13          1 v1     
#>  9 dx_icd10 I130         1 v1     
#> 10 dx_icd10 I131         1 v1     
#> # ℹ 13 more rows
```

Note that if you ask for a code type that isn’t stored in the object,
you get an empty tibble.

``` r

get_hypertension_v1_codes(code_type = 'proc_icd10')
#> # A tibble: 0 × 4
#> # ℹ 4 variables: type <chr>, code <chr>, priority <int>, version <chr>
```

#### Adding periods to codes

Codes are stored in short format (no periods, i.e., `.`) as this is a
common format in claims data. Set `periods = TRUE` to add them to your
codes:

``` r

get_hypertension_v1_codes(code_type = "dx_icd10", periods = TRUE)
#> # A tibble: 23 × 4
#>    type     code  priority version
#>    <chr>    <chr>    <int> <chr>  
#>  1 dx_icd10 I10          1 v1     
#>  2 dx_icd10 I11          1 v1     
#>  3 dx_icd10 I11.0        1 v1     
#>  4 dx_icd10 I11.9        1 v1     
#>  5 dx_icd10 I12          1 v1     
#>  6 dx_icd10 I12.0        1 v1     
#>  7 dx_icd10 I12.9        1 v1     
#>  8 dx_icd10 I13          1 v1     
#>  9 dx_icd10 I13.0        1 v1     
#> 10 dx_icd10 I13.1        1 v1     
#> # ℹ 13 more rows
```

Note that this feature is not perfect - it just adds a period after the
third character. Periods appear after the third character in ICD-10 but
may appear after the fourth in ICD-9. Most of our analyses focus on
ICD-10 and most databases do not use periods in codes, so getting this
exactly right is not a high priority at the moment.

#### Condition vs. outcome definitions

Some `specs` carry separate code sets for identifying a **condition**
(history / comorbidity lookback) vs. an **outcome** (new event). Use
`variable_type` to select one:

``` r

get_hf_v1_codes(variable_type = "outcome", code_type = "dx_icd10")
#> # A tibble: 26 × 4
#>    type     code  priority version
#>    <chr>    <chr>    <int> <chr>  
#>  1 dx_icd10 I110         1 v1     
#>  2 dx_icd10 I130         1 v1     
#>  3 dx_icd10 I132         1 v1     
#>  4 dx_icd10 I501         1 v1     
#>  5 dx_icd10 I5020        1 v1     
#>  6 dx_icd10 I5021        1 v1     
#>  7 dx_icd10 I5022        1 v1     
#>  8 dx_icd10 I5023        1 v1     
#>  9 dx_icd10 I5030        1 v1     
#> 10 dx_icd10 I5031        1 v1     
#> # ℹ 16 more rows
```

The default (`variable_type = "condition"`) retrieves the condition
definition.

### Composite specs and the `component` argument

Some specs are **composites** — they contain several named component
specs rather than a single code set. `spec_ascvd`, for example, groups
coronary heart disease (CHD), stroke, lower extremity artery disease
(LEAD) / peripheral arterial disease (PAD), and cerebrovascular disease
into a single composition.

For composite specs, the `component` argument is optional. Omitting it
(or passing `"all"`) returns every component at once, distinguished by a
`class` column. Print the spec to see all available component names:

``` r

spec_ascvd
#> 
#> ── Atherosclerotic Cardiovascular Disease (ASCVD) (composite) ──────────────────
#> Condition: `ascvd`
#> Def: Composition of all ASCVD component specs: coronary heart disease (CHD),
#> stroke, lower extremity artery disease (LEAD) / peripheral arterial disease
#> (PAD), and cerebrovascular disease
#> Components:
#>   `chd_v1`: Coronary Heart Disease
#>   `stroke_v1`: Stroke (Any)
#>   `lead_pad_v1`: lower extremity artery disease (LEAD) / peripheral artery
#>   disease (PAD)
#>   `cerebrovasc_disease_v1`: Cerebrovascular Disease
#> Use `component` = "chd_v1", "stroke_v1", "lead_pad_v1", and
#> "cerebrovasc_disease_v1" in `get_*()` functions.
```

Retrieve codes for a single component:

``` r

get_ascvd_codes(component = "chd_v1", code_type = "dx_icd10")
#> # A tibble: 46 × 5
#>    type     code  priority version class
#>    <chr>    <chr>    <int> <chr>   <chr>
#>  1 dx_icd10 I21          1 v1      chd  
#>  2 dx_icd10 I210         1 v1      chd  
#>  3 dx_icd10 I2101        1 v1      chd  
#>  4 dx_icd10 I2102        1 v1      chd  
#>  5 dx_icd10 I2109        1 v1      chd  
#>  6 dx_icd10 I211         1 v1      chd  
#>  7 dx_icd10 I2111        1 v1      chd  
#>  8 dx_icd10 I2119        1 v1      chd  
#>  9 dx_icd10 I212         1 v1      chd  
#> 10 dx_icd10 I2121        1 v1      chd  
#> # ℹ 36 more rows
```

Omit `component` (or pass `"all"`) to get every component’s codes at
once:

``` r

get_ascvd_codes(code_type = "dx_icd10") |> nrow()
#> [1] 609
```

### Reading algorithm definitions

The codes are only half of what you need to get definitions right. You
also need to know how to apply them. `get_<condition>_vX_defs()`
provides a description of the algorithm used to define each condition:

``` r

get_hypertension_v1_defs()
#> ℹ Any of the following:
#> • ≥1 inpatient claim with an ICD-9 discharge diagnosis of 401.x, 403.0x,
#>   403.1x, or 403.9x, or ICD-10 discharge diagnosis code of I10, I11.x, I12.x,
#>   I13.x, I15.x, I12.0, I12.9, I16.x in any discharge diagnosis position.
#> • ≥2 physician E&M visit claims with the same diagnosis codes, at least 30 days
#>   apart.
#> • ≥2 pharmacy fills for an antihypertensive medication (see spec_hypertension)
```

For composite specs, pass the component name:

``` r

get_ascvd_defs(component = "chd_v1", variable_type = "condition")
#> ℹ Any of the following:
#> • ≥1 inpatient claim with an ICD-9 diagnosis code of 410.xx–414.xx, V45.81, or
#>   V45.82, or an ICD-10 diagnosis code of I21.xxx, I22.xxx, or specified
#>   I25/I20/I24 codes in any position.
#> • ≥1 outpatient E&M claim with the same ICD codes in any position.
#> • ≥1 inpatient or outpatient claim with an ICD-9 procedure code of 00.66, 36.0,
#>   36.01–36.19, or 36.2; an ICD-10-PCS code for CABG or PCI; or a HCPCS code for
#>   coronary revascularization.
```

### Versioning

Algorithm versions are encoded directly in the spec and function names
using a `_vX` suffix (e.g., `spec_acei_v1`, `spec_acei_v2`), used when a
spec’s codes or generics genuinely change between versions. Conditions
like hypertension previously had multiple versions that shared identical
codes and differed only in the narrative definition (e.g., whether a
medication criterion was included) — those have been collapsed into a
single version, so
`spec_hypertension_v1`/[`get_hypertension_v1_codes()`](https://perisphere-rwe.github.io/peridefs/reference/get_hypertension_v1_codes.md)/[`get_hypertension_v1_defs()`](https://perisphere-rwe.github.io/peridefs/reference/get_hypertension_v1_defs.md)
always reflect the most current definition.

### Spec objects

Behind every `get_*` function is a `spec_*` data object. You can inspect
it directly to see codes, definitions, and (for composites) component
names:

``` r

spec_hypertension_v1
#> 
#> ── Hypertension (v1) ───────────────────────────────────────────────────────────
#> Condition: `hypertension`
#> Condition def:
#> ℹ Any of the following:
#> • ≥1 inpatient claim with an ICD-9 discharge diagnosis of 401.x, 403.0x,
#>   403.1x, or 403.9x, or ICD-10 discharge diagnosis code of I10, I11.x, I12.x,
#>   I13.x, I15.x, I12.0, I12.9, I16.x in any discharge diagnosis position.
#> • ≥2 physician E&M visit claims with the same diagnosis codes, at least 30 days
#>   apart.
#> • ≥2 pharmacy fills for an antihypertensive medication (see spec_hypertension)
#> 
#> Code sets:
#>   `dx_icd9`: 13 condition / 0 outcome codes
#>   `dx_icd10`: 23 condition / 0 outcome codes
```

## Complement with `icd` package

The `icd` package is not required for `peridefs`, but it can be used to
complement it. In particular, if you want to look up the explanations of
our diagnostic codes, `icd` is helpful and easy to apply:

``` r


library(icd) # for as.icd9 / as.icd10 / explain_code functions
library(tidyverse)

peri_codes <- get_copd_v1_codes(code_type = 'dx_icd9')$code

as.icd9(peri_codes) %>% 
  set_names(peri_codes) %>% 
  map_chr(~explain_code(.x)) %>% 
  enframe(name = 'code', value = 'explanation')
  
```

Note this only works for diagnostic codes and `explain_code` sometimes
fails to give explanations for all codes if you pass a vector (that’s
why I used map in my code).

### Learn more

See the
[Reference](https://perisphere-rwe.github.io/peridefs/reference/index.md)
for the complete list of conditions and drugs.
