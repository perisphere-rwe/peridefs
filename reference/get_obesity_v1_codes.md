# Retrieve ICD codes for obesity

Returns code sets from the obesity
[CodeSpec](https://perisphere-rwe.github.io/peridefs/reference/CodeSpec.md)
(`spec_obesity_v1`). The same ICD-9 and ICD-10 code sets are used for
both the condition and outcome definitions.

## Usage

``` r
get_obesity_v1_codes(
  code_type = NULL,
  variable_type = c("condition", "outcome"),
  periods = FALSE,
  priority = 1L
)

get_obesity_v1_defs(variable_type = c("condition", "outcome"))
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

`get_obesity_v1_defs()`, `spec_obesity_v1`

## Examples

``` r
get_obesity_v1_codes()
#> # A tibble: 42 × 5
#>    type    code  priority version definition                      
#>    <chr>   <chr>    <int> <chr>   <chr>                           
#>  1 dx_icd9 27800        1 v1      Obesity, unspecified            
#>  2 dx_icd9 27801        1 v1      Morbid obesity                  
#>  3 dx_icd9 27803        1 v1      Obesity hypoventilation syndrome
#>  4 dx_icd9 V8530        1 v1      Body Mass Index 30.0-30.9, adult
#>  5 dx_icd9 V8531        1 v1      Body Mass Index 31.0-31.9, adult
#>  6 dx_icd9 V8532        1 v1      Body Mass Index 32.0-32.9, adult
#>  7 dx_icd9 V8533        1 v1      Body Mass Index 33.0-33.9, adult
#>  8 dx_icd9 V8534        1 v1      Body Mass Index 34.0-34.9, adult
#>  9 dx_icd9 V8535        1 v1      Body Mass Index 35.0-35.9, adult
#> 10 dx_icd9 V8536        1 v1      Body Mass Index 36.0-36.9, adult
#> # ℹ 32 more rows
get_obesity_v1_codes(code_type = "dx_icd9")
#> # A tibble: 18 × 5
#>    type    code  priority version definition                        
#>    <chr>   <chr>    <int> <chr>   <chr>                             
#>  1 dx_icd9 27800        1 v1      Obesity, unspecified              
#>  2 dx_icd9 27801        1 v1      Morbid obesity                    
#>  3 dx_icd9 27803        1 v1      Obesity hypoventilation syndrome  
#>  4 dx_icd9 V8530        1 v1      Body Mass Index 30.0-30.9, adult  
#>  5 dx_icd9 V8531        1 v1      Body Mass Index 31.0-31.9, adult  
#>  6 dx_icd9 V8532        1 v1      Body Mass Index 32.0-32.9, adult  
#>  7 dx_icd9 V8533        1 v1      Body Mass Index 33.0-33.9, adult  
#>  8 dx_icd9 V8534        1 v1      Body Mass Index 34.0-34.9, adult  
#>  9 dx_icd9 V8535        1 v1      Body Mass Index 35.0-35.9, adult  
#> 10 dx_icd9 V8536        1 v1      Body Mass Index 36.0-36.9, adult  
#> 11 dx_icd9 V8537        1 v1      Body Mass Index 37.0-37.9, adult  
#> 12 dx_icd9 V8538        1 v1      Body Mass Index 38.0-38.9, adult  
#> 13 dx_icd9 V8539        1 v1      Body Mass Index 39.0-39.9, adult  
#> 14 dx_icd9 V8541        1 v1      Body Mass Index 40.0-44.9, adult  
#> 15 dx_icd9 V8542        1 v1      Body Mass Index 45.0-49.9, adult  
#> 16 dx_icd9 V8543        1 v1      Body Mass Index 50.0-59.9, adult  
#> 17 dx_icd9 V8544        1 v1      Body Mass Index 60.0-69.9, adult  
#> 18 dx_icd9 V8545        1 v1      Body Mass Index 70 and over, adult
get_obesity_v1_codes(variable_type = "outcome")
#> # A tibble: 42 × 5
#>    type    code  priority version definition                      
#>    <chr>   <chr>    <int> <chr>   <chr>                           
#>  1 dx_icd9 27800        1 v1      Obesity, unspecified            
#>  2 dx_icd9 27801        1 v1      Morbid obesity                  
#>  3 dx_icd9 27803        1 v1      Obesity hypoventilation syndrome
#>  4 dx_icd9 V8530        1 v1      Body Mass Index 30.0-30.9, adult
#>  5 dx_icd9 V8531        1 v1      Body Mass Index 31.0-31.9, adult
#>  6 dx_icd9 V8532        1 v1      Body Mass Index 32.0-32.9, adult
#>  7 dx_icd9 V8533        1 v1      Body Mass Index 33.0-33.9, adult
#>  8 dx_icd9 V8534        1 v1      Body Mass Index 34.0-34.9, adult
#>  9 dx_icd9 V8535        1 v1      Body Mass Index 35.0-35.9, adult
#> 10 dx_icd9 V8536        1 v1      Body Mass Index 36.0-36.9, adult
#> # ℹ 32 more rows
```
