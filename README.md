
<!-- README.md is generated from README.Rmd. Please edit that file -->

# peridefs

<!-- badges: start -->

<!-- badges: end -->

Provides code sets (ICD-9, ICD-10, and HCPCS/CPT) to define conditions
such as hypertension, diabetes, and atherosclerotic cardiovascular
disease in real world claims data. It also contains generic names for
common drug types (e.g., anti-diabetes). The purpose of the `peridefs`
package is to provide safe and easy access to these validated
definitions.

## Why peridefs?

- **Dynamic and safe**: each condition and drug class can be updated
  over time, but those updates will not break existing code or force
  that code to use the updated definitions.
- **Built by experts**: every code set is designed by Dr Ligong Chen and
  Hong Zhao, who have decades of experience working with claims data and
  have developed each code set following a standardized, validated
  procedure.
- **Adaptable**: codes are stored in pre-built specs for standard
  conditions, and they can be modified through a built-in API that
  allows codes to be removed or added. We do not recommend changing our
  specs, but we do want that to be an option in case it’s needed.

## Installation

``` r
# Install from GitHub
pak::pak("perisphere-rwe/peridefs")
```

## Quick start

A quick look at how you can get relevant information from `peridefs`
family of `get_` functions

``` r
library(peridefs)

# Retrieve ICD-10 hypertension codes as a tibble
get_htn_v1_codes(code_type = "dx_icd10", format = "tibble")
#> # A tibble: 23 × 3
#>    code_type code  variable_type
#>    <chr>     <chr> <chr>        
#>  1 dx_icd10  I10   condition    
#>  2 dx_icd10  I11   condition    
#>  3 dx_icd10  I110  condition    
#>  4 dx_icd10  I119  condition    
#>  5 dx_icd10  I12   condition    
#>  6 dx_icd10  I120  condition    
#>  7 dx_icd10  I129  condition    
#>  8 dx_icd10  I13   condition    
#>  9 dx_icd10  I130  condition    
#> 10 dx_icd10  I131  condition    
#> # ℹ 13 more rows

# Complement with icd package to look up code explanations
library(icd) # for as.icd9 / as.icd10 / explain_code functions
library(tidyverse) # for map / set_names / enframe functions

get_htn_v1_codes(code_type = 'dx_icd10')[[1]] %>% 
  as.icd10() %>% 
  set_names() %>% 
  map_chr(~explain_code(.x)) %>% 
  enframe(name = 'code', value = 'explanation')
#> # A tibble: 23 × 2
#>    code  explanation                                                            
#>    <chr> <chr>                                                                  
#>  1 I10   Essential (primary) hypertension                                       
#>  2 I11   Hypertensive heart disease                                             
#>  3 I110  Hypertensive heart disease with heart failure                          
#>  4 I119  Hypertensive heart disease without heart failure                       
#>  5 I12   Hypertensive chronic kidney disease                                    
#>  6 I120  Hypertensive chronic kidney disease with stage 5 chronic kidney diseas…
#>  7 I129  Hypertensive chronic kidney disease with stage 1 through stage 4 chron…
#>  8 I13   Hypertensive heart and chronic kidney disease                          
#>  9 I130  Hypertensive heart and chronic kidney disease with heart failure and s…
#> 10 I131  Hypertensive heart and chronic kidney disease without heart failure    
#> # ℹ 13 more rows

# Retrieve generic drug names for ACE inhibitors (version 2)
get_antihypertensive_generics(component = 'acei_v2')
#>  [1] "BENAZEPRIL"   "CAPTOPRIL"    "ENALAPRIL"    "FOSINOPRIL"   "FOSINIPRIL"  
#>  [6] "LISINOPRIL"   "MOEXIPRIL"    "MOEXEPRIL"    "PERINDOPRIL"  "QUINAPRIL"   
#> [11] "RAMIPRIL"     "TRANDOLAPRIL"
```

## Specs

`peridefs` is built on an R6 back-end that provides `specs` for
conditions and drug classes. You can work directly with our exported
specs if the `get_` functions don’t provide exactly what you’re looking
for

``` r
# the spec objects all have a built-in print method that
# gives a helpful summary and recommended method for 
# defining the given condition.
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

# just like get_htn_v1_codes() above
spec_htn_v1$get_codes()
#> $dx_icd9
#>  [1] "401"   "4010"  "4011"  "4019"  "4030"  "40300" "40301" "4031"  "40310"
#> [10] "40311" "4039"  "40390" "40391"
#> 
#> $dx_icd10
#>  [1] "I10"   "I11"   "I110"  "I119"  "I12"   "I120"  "I129"  "I13"   "I130" 
#> [10] "I131"  "I1310" "I1311" "I132"  "I15"   "I150"  "I151"  "I152"  "I158" 
#> [19] "I159"  "I16"   "I160"  "I161"  "I169"
```
