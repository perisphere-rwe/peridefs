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
one per algorithm version. By default the function returns a named list
with one element per code type:

``` r

get_htn_v1_codes()
#> $dx_icd9
#>  [1] "401"   "4010"  "4011"  "4019"  "4030"  "40300" "40301" "4031"  "40310"
#> [10] "40311" "4039"  "40390" "40391"
#> 
#> $dx_icd10
#>  [1] "I10"   "I11"   "I110"  "I119"  "I12"   "I120"  "I129"  "I13"   "I130" 
#> [10] "I131"  "I1310" "I1311" "I132"  "I15"   "I150"  "I151"  "I152"  "I158" 
#> [19] "I159"  "I16"   "I160"  "I161"  "I169"
```

Pass `format = "tibble"` to get a tidy data frame instead

``` r

get_htn_v1_codes(format = "tibble")
#> # A tibble: 36 × 3
#>    code_type code  variable_type
#>    <chr>     <chr> <chr>        
#>  1 dx_icd9   401   condition    
#>  2 dx_icd9   4010  condition    
#>  3 dx_icd9   4011  condition    
#>  4 dx_icd9   4019  condition    
#>  5 dx_icd9   4030  condition    
#>  6 dx_icd9   40300 condition    
#>  7 dx_icd9   40301 condition    
#>  8 dx_icd9   4031  condition    
#>  9 dx_icd9   40310 condition    
#> 10 dx_icd9   40311 condition    
#> # ℹ 26 more rows
```

#### Selecting a code type

By default, `get_` functions will return all relevant codes or generics.
If you only want to return a specific type or types of codes, use the
`code_type` argument to retrieve a filtered code list. Supprted values
are `"dx_icd9"`, `"dx_icd10"`, `"hcpcs"`, `"proc_icd9"`, and
`"proc_icd10"`:

``` r

get_htn_v1_codes(code_type = "dx_icd10")
#> $dx_icd10
#>  [1] "I10"   "I11"   "I110"  "I119"  "I12"   "I120"  "I129"  "I13"   "I130" 
#> [10] "I131"  "I1310" "I1311" "I132"  "I15"   "I150"  "I151"  "I152"  "I158" 
#> [19] "I159"  "I16"   "I160"  "I161"  "I169"
```

Note that if you ask for a code type that isn’t stored in the object,
you get an empty list.

``` r

get_htn_v1_codes(code_type = 'proc_icd10')
#> named list()
```

#### Adding periods to codes

Codes are stored in short format (no periods, i.e., `.`) as this is a
common format in claims data. Set `periods = TRUE` to add them to your
codes:

``` r

get_htn_v1_codes(code_type = "dx_icd10", periods = TRUE)
#> $dx_icd10
#>  [1] "I10"    "I11"    "I11.0"  "I11.9"  "I12"    "I12.0"  "I12.9"  "I13"   
#>  [9] "I13.0"  "I13.1"  "I13.10" "I13.11" "I13.2"  "I15"    "I15.0"  "I15.1" 
#> [17] "I15.2"  "I15.8"  "I15.9"  "I16"    "I16.0"  "I16.1"  "I16.9"
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
#> $dx_icd10
#>  [1] "I110"   "I130"   "I132"   "I501"   "I5020"  "I5021"  "I5022"  "I5023" 
#>  [9] "I5030"  "I5031"  "I5032"  "I5033"  "I5040"  "I5041"  "I5042"  "I5043" 
#> [17] "I509"   "I50810" "I50814" "I50811" "I50812" "I50813" "I5082"  "I5083" 
#> [25] "I5084"  "I5089"
```

The default (`variable_type = "condition"`) retrieves the condition
definition.

### Composite specs and the `component` argument

Some specs are **composites** — they contain several named component
specs rather than a single code set. `spec_ascvd`, for example, groups
coronary heart disease (CHD), stroke, lower extremity artery disease
(LEAD) / peripheral arterial disease (PAD), and cerebrovascular disease
into a single composition.

For composite specs, the `component` argument is **required**. Print the
spec to see all available component names:

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
#>   `chd_v2`: Coronary Heart Disease
#>   `stroke_v1`: Stroke (Any)
#>   `lead_pad_v1`: lower extremity artery disease (LEAD) / peripheral artery
#>   disease (PAD)
#>   `cerebrovasc_disease_v1`: Cerebrovascular Disease
#> Use `component` = "chd_v1", "chd_v2", "stroke_v1", "lead_pad_v1", and
#> "cerebrovasc_disease_v1" in `get_*()` functions.
```

Retrieve codes for a single component:

``` r

get_ascvd_codes(component = "chd_v1", code_type = "dx_icd10")
#> $dx_icd10
#>  [1] "I21"    "I210"   "I2101"  "I2102"  "I2109"  "I211"   "I2111"  "I2119" 
#>  [9] "I212"   "I2121"  "I2129"  "I213"   "I214"   "I219"   "I21A"   "I21A1" 
#> [17] "I21A9"  "I22"    "I220"   "I221"   "I222"   "I228"   "I229"   "I2510" 
#> [25] "I25810" "I25811" "I25812" "I253"   "I2541"  "I2542"  "Z951"   "Z9861" 
#> [33] "I200"   "I201"   "I208"   "I209"   "I240"   "I241"   "I248"   "I252"  
#> [41] "I255"   "I2582"  "I2583"  "I2584"  "I2589"  "I259"
```

Use `component = "all"` to get the union of every component’s codes:

``` r

get_ascvd_codes(component = "all", code_type = "dx_icd10") |> length()
#> [1] 1
```

### Reading algorithm definitions

The codes are only half of what you need to get definitions right. You
also need to know how to apply them. `get_<condition>_vX_defs()`
provides a description of the algorithm used to define each condition:

``` r

get_htn_v1_defs()
#> ℹ Any of the following:
#> • ≥1 inpatient claim with an ICD-9 discharge diagnosis of 401.x, 403.0x,
#>   403.1x, or 403.9x, or ICD-10 discharge diagnosis code of I10, I11.x, I12.x,
#>   I13.x, I15.x, I12.0, I12.9, I16.x in any discharge diagnosis position.
#> • ≥2 physician E&M visit claims with the same diagnosis codes, at least 30 days
#>   apart.
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
using a `_vX` suffix. `spec_htn_v1` and `spec_htn_v2` are two distinct
objects; the corresponding getters are
[`get_htn_v1_codes()`](https://perisphere-rwe.github.io/peridefs/reference/get_htn_v1_codes.md)
and
[`get_htn_v2_codes()`](https://perisphere-rwe.github.io/peridefs/reference/get_htn_v1_codes.md).
When a condition has only one version (e.g., `spec_hf_v1`), there is
only one getter.

``` r

# v1 and v2 share the same code sets for HTN — only the defs differ
identical(get_htn_v1_codes(), get_htn_v2_codes())
#> [1] TRUE

get_htn_v1_defs()
#> ℹ Any of the following:
#> • ≥1 inpatient claim with an ICD-9 discharge diagnosis of 401.x, 403.0x,
#>   403.1x, or 403.9x, or ICD-10 discharge diagnosis code of I10, I11.x, I12.x,
#>   I13.x, I15.x, I12.0, I12.9, I16.x in any discharge diagnosis position.
#> • ≥2 physician E&M visit claims with the same diagnosis codes, at least 30 days
#>   apart.
get_htn_v2_defs()
#> ℹ Any of the following:
#> • ≥1 inpatient claim with an ICD-9 discharge diagnosis of 401.x, 403.0x,
#>   403.1x, or 403.9x, or ICD-10 discharge diagnosis code of I10, I11.x, I12.x,
#>   I13.x, I15.x, I12.0, I12.9, I16.x in any discharge diagnosis position.
#> • ≥2 physician E&M visit claims with the same diagnosis codes, at least 30 days
#>   apart.
#> • ≥2 pharmacy fills for an antihypertensive medication (see
#>   spec_antihypertensive)
```

### Spec objects

Behind every `get_*` function is a `spec_*` data object. You can inspect
it directly to see codes, definitions, and (for composites) component
names:

``` r

spec_htn_v1
#> 
#> ── Hypertension (v1) ───────────────────────────────────────────────────────────
#> Condition: `htn`
#> Condition def:
#> ℹ Any of the following:
#> • ≥1 inpatient claim with an ICD-9 discharge diagnosis of 401.x, 403.0x,
#>   403.1x, or 403.9x, or ICD-10 discharge diagnosis code of I10, I11.x, I12.x,
#>   I13.x, I15.x, I12.0, I12.9, I16.x in any discharge diagnosis position.
#> • ≥2 physician E&M visit claims with the same diagnosis codes, at least 30 days
#>   apart.
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

peri_codes <- get_copd_v1_codes(code_type = 'dx_icd9')[[1]] 

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
