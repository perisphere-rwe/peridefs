# Retrieve ICD codes for osteoarthritis

Retrieve ICD codes for osteoarthritis

## Usage

``` r
get_osteoarthritis_v1_codes(
  code_type = NULL,
  variable_type = c("condition", "outcome"),
  periods = FALSE,
  priority = 1L
)

get_osteoarthritis_v1_defs(variable_type = c("condition", "outcome"))
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

`get_osteoarthritis_v1_defs()`, `spec_osteoarthritis_v1`

## Examples

``` r
get_osteoarthritis_v1_codes()
#> # A tibble: 176 × 5
#>    type    code  priority version definition                                    
#>    <chr>   <chr>    <int> <chr>   <chr>                                         
#>  1 dx_icd9 715          1 v1      Osteoarthrosis and allied disorders           
#>  2 dx_icd9 7150         1 v1      Osteoarthrosis and allied disorders: Osteoart…
#>  3 dx_icd9 71500        1 v1      Osteoarthrosis, generalized, site unspecified 
#>  4 dx_icd9 71504        1 v1      Osteoarthrosis, generalized, hand             
#>  5 dx_icd9 71509        1 v1      Osteoarthrosis, generalized, multiple sites   
#>  6 dx_icd9 7151         1 v1      Osteoarthrosis and allied disorders: Osteoart…
#>  7 dx_icd9 71510        1 v1      Osteoarthrosis, localized, primary, site unsp…
#>  8 dx_icd9 71511        1 v1      Osteoarthrosis, localized, primary, shoulder …
#>  9 dx_icd9 71512        1 v1      Osteoarthrosis, localized, primary, upper arm 
#> 10 dx_icd9 71513        1 v1      Osteoarthrosis, localized, primary, forearm   
#> # ℹ 166 more rows
get_osteoarthritis_v1_codes(code_type = "dx_icd10")
#> # A tibble: 128 × 5
#>    type     code  priority version definition                             
#>    <chr>    <chr>    <int> <chr>   <chr>                                  
#>  1 dx_icd10 M15          1 v1      Polyosteoarthritis                     
#>  2 dx_icd10 M150         1 v1      Primary generalized (osteo)arthritis   
#>  3 dx_icd10 M151         1 v1      Heberden's nodes (with arthropathy)    
#>  4 dx_icd10 M152         1 v1      Bouchard's nodes (with arthropathy)    
#>  5 dx_icd10 M153         1 v1      Secondary multiple arthritis           
#>  6 dx_icd10 M154         1 v1      Erosive (osteo)arthritis               
#>  7 dx_icd10 M158         1 v1      Other polyosteoarthritis               
#>  8 dx_icd10 M159         1 v1      Polyosteoarthritis, unspecified        
#>  9 dx_icd10 M16          1 v1      Osteoarthritis of hip                  
#> 10 dx_icd10 M160         1 v1      Bilateral primary osteoarthritis of hip
#> # ℹ 118 more rows
```
