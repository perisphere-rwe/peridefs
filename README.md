<!-- README.md is generated from README.Rmd. Please edit that file -->

# peridefs

<!-- badges: start -->
<!-- badges: end -->

The purpose of the `peridefs` package is to provide safe and easy access
to validated definitions of common characteristics in real world data
analysis. It provides code sets (ICD-9, ICD-10, and HCPCS/CPT) to define
conditions such as hypertension, diabetes, and atherosclerotic
cardiovascular disease, and it also contains generic names for common
drug types (e.g., anti-diabetes).

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

    # Install from GitHub
    pak::pak("perisphere-rwe/peridefs")

## Quick start

A quick look at how you can get relevant information from `peridefs`
family of `get_` functions

    library(peridefs)

    # Retrieve ICD-10 hypertension codes as a tibble
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

    # Complement with icd package to look up code explanations
    library(icd) # for as.icd9 / as.icd10 / explain_code functions
    library(tidyverse) # for mutate / map_chr functions

    get_hypertension_v1_codes(code_type = 'dx_icd10') %>% 
      mutate(explanation = map_chr(code, ~explain_code(as.icd10(.x))))
    #> # A tibble: 23 × 5
    #>    type     code  priority version explanation                                                                                               
    #>    <chr>    <chr>    <int> <chr>   <chr>                                                                                                     
    #>  1 dx_icd10 I10          1 v1      Essential (primary) hypertension                                                                          
    #>  2 dx_icd10 I11          1 v1      Hypertensive heart disease                                                                                
    #>  3 dx_icd10 I110         1 v1      Hypertensive heart disease with heart failure                                                             
    #>  4 dx_icd10 I119         1 v1      Hypertensive heart disease without heart failure                                                          
    #>  5 dx_icd10 I12          1 v1      Hypertensive chronic kidney disease                                                                       
    #>  6 dx_icd10 I120         1 v1      Hypertensive chronic kidney disease with stage 5 chronic kidney disease or end stage renal disease        
    #>  7 dx_icd10 I129         1 v1      Hypertensive chronic kidney disease with stage 1 through stage 4 chronic kidney disease, or unspecified c…
    #>  8 dx_icd10 I13          1 v1      Hypertensive heart and chronic kidney disease                                                             
    #>  9 dx_icd10 I130         1 v1      Hypertensive heart and chronic kidney disease with heart failure and stage 1 through stage 4 chronic kidn…
    #> 10 dx_icd10 I131         1 v1      Hypertensive heart and chronic kidney disease without heart failure                                       
    #> # ℹ 13 more rows

    # Retrieve generic drug names for ACE inhibitors (version 2)
    get_hypertension_generics(component = 'acei_v2')
    #> # A tibble: 31 × 6
    #>    generic                        brand     priority condition class version
    #>    <chr>                          <list>       <int> <chr>     <chr> <chr>  
    #>  1 AMLODIPINE BESYLATE/BENAZEPRIL <chr [0]>        1 <NA>      acei  v2     
    #>  2 BENAZEPRIL                     <chr [0]>        1 <NA>      acei  v2     
    #>  3 BENAZEPRIL HCL                 <chr [0]>        1 <NA>      acei  v2     
    #>  4 BENAZEPRIL/HYDROCHLOROTHIAZIDE <chr [0]>        1 <NA>      acei  v2     
    #>  5 CAPTOPRIL                      <chr [0]>        1 <NA>      acei  v2     
    #>  6 CAPTOPRIL/HYDROCHLOROTHIAZIDE  <chr [0]>        1 <NA>      acei  v2     
    #>  7 ENALAPRIL                      <chr [0]>        1 <NA>      acei  v2     
    #>  8 ENALAPRIL MALEATE              <chr [0]>        1 <NA>      acei  v2     
    #>  9 ENALAPRIL MALEATE/FELODIPINE   <chr [0]>        1 <NA>      acei  v2     
    #> 10 ENALAPRIL MALEATE/HCTZ         <chr [0]>        1 <NA>      acei  v2     
    #> # ℹ 21 more rows

## Specs

`peridefs` is built on an R6 back-end that provides `specs` for
conditions and drug classes. You can work directly with our exported
specs if the `get_` functions don’t provide exactly what you’re looking
for.

    # the spec objects all have a built-in print method that
    # gives a helpful summary and recommended method for 
    # defining the given condition.
    spec_hypertension_v1
    #> 
    #> ── Hypertension (v1) ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    #> Condition: `hypertension`
    #> Condition def:
    #> ℹ Any of the following:
    #> • ≥1 inpatient claim with an ICD-9 discharge diagnosis of 401.x, 403.0x, 403.1x, or 403.9x, or ICD-10 discharge diagnosis code of I10,
    #>   I11.x, I12.x, I13.x, I15.x, I12.0, I12.9, I16.x in any discharge diagnosis position.
    #> • ≥2 physician E&M visit claims with the same diagnosis codes, at least 30 days apart.
    #> • ≥2 pharmacy fills for an antihypertensive medication (see spec_hypertension)
    #> 
    #> Code sets:
    #>   `dx_icd9`: 13 condition / 0 outcome codes
    #>   `dx_icd10`: 23 condition / 0 outcome codes

    # just like get_hypertension_v1_codes() above
    spec_hypertension_v1$get_codes()
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

## Safety

These safety features are a work in progress, but the vision is as
follows:

- We have tests for each condition that assert the code sets are equal
  to static vectors. These tests ensure that package updates will never
  inadvertently overwrite existing code sets, meaning your analyses will
  never be unexplicably changed by our updates to the package.

- When we make updates to a condition, we simply add a new spec (e.g.,
  `spec_hypertension_v1`, `spec_hypertension_v2`,
  `spec_hypertension_v3`, etc. and throw a once-per-session warning if
  you are using an older version of a definition.
