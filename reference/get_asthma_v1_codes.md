# Retrieve ICD codes for asthma

Retrieve ICD codes for asthma

## Usage

``` r
get_asthma_v1_codes(
  code_type = NULL,
  variable_type = c("condition", "outcome"),
  periods = FALSE,
  format = c("list", "tibble"),
  concatenate = FALSE
)

get_asthma_v1_defs(variable_type = c("condition", "outcome"))
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

- format:

  `"list"` (default) returns a named list of character vectors.
  `"tibble"` returns a long-form tibble with columns `code_type`,
  `code`, and `variable_type`.

- concatenate:

  Logical. `FALSE` (default) returns a named list of character vectors.
  `TRUE` concatenates all code vectors into a single unnamed character
  vector. Not compatible with `format = "tibble"`.

## See also

`get_asthma_v1_defs()`, `spec_asthma_v1`

## Examples

``` r
get_asthma_v1_codes()
#> $dx_icd9
#>  [1] "493"   "4930"  "49300" "49301" "49302" "4931"  "49310" "49311" "49312"
#> [10] "4932"  "49320" "49321" "49322" "4938"  "49381" "49382" "4939"  "49390"
#> [19] "49391" "49392"
#> 
#> $dx_icd10
#>  [1] "J45"    "J452"   "J4520"  "J4521"  "J4522"  "J453"   "J4530"  "J4531" 
#>  [9] "J4532"  "J454"   "J4540"  "J4541"  "J4542"  "J455"   "J4550"  "J4551" 
#> [17] "J4552"  "J459"   "J4590"  "J45901" "J45902" "J45909" "J4599"  "J45990"
#> [25] "J45991" "J45998"
#> 
get_asthma_v1_codes(code_type = "dx_icd10")
#> $dx_icd10
#>  [1] "J45"    "J452"   "J4520"  "J4521"  "J4522"  "J453"   "J4530"  "J4531" 
#>  [9] "J4532"  "J454"   "J4540"  "J4541"  "J4542"  "J455"   "J4550"  "J4551" 
#> [17] "J4552"  "J459"   "J4590"  "J45901" "J45902" "J45909" "J4599"  "J45990"
#> [25] "J45991" "J45998"
#> 
```
