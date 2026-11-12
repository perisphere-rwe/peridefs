# List the versions of condition definitions

Shows every released version of each condition definition, the functions
that return it, and (for versions after v1) when and why it was
introduced. All listed versions remain available; see
[`get_version_diffs()`](https://perisphere-rwe.github.io/peridefs/reference/get_version_diffs.md)
to compare them.

## Usage

``` r
list_versions(condition = NULL)
```

## Arguments

- condition:

  Optional character vector of condition identifiers (e.g.
  `"diabetes_type2"`). `NULL` (default) lists every condition.

## Value

A tibble with columns `condition`, `version`, `label`, `codes_function`,
`defs_function`, `n_codes` (number of codes in the condition
definition), `date` and `summary` (from the version history; `NA` for
v1).

## Examples

``` r
list_versions("diabetes_type2")
#> # A tibble: 2 × 8
#>   condition     version label codes_function defs_function n_codes date  summary
#>   <chr>         <chr>   <chr> <chr>          <chr>           <int> <chr> <chr>  
#> 1 diabetes_typ… v1      Type… get_diabetes_… get_diabetes…     126 NA    NA     
#> 2 diabetes_typ… v2      Type… get_diabetes_… get_diabetes…      87 2026… ICD-10…
list_versions()
#> # A tibble: 19 × 8
#>    condition    version label codes_function defs_function n_codes date  summary
#>    <chr>        <chr>   <chr> <chr>          <chr>           <int> <chr> <chr>  
#>  1 asthma       v1      Asth… get_asthma_v1… get_asthma_v…      46 NA    NA     
#>  2 cerebrovasc… v1      Cere… get_cerebrova… get_cerebrov…     187 NA    NA     
#>  3 chd          v1      Coro… get_chd_v1_co… get_chd_v1_d…     765 NA    NA     
#>  4 ckd          v1      Chro… get_ckd_v1_co… get_ckd_v1_d…     212 NA    NA     
#>  5 copd         v1      Chro… get_copd_v1_c… get_copd_v1_…      31 NA    NA     
#>  6 depression   v1      Depr… get_depressio… get_depressi…      62 NA    NA     
#>  7 diabetes_ty… v1      Type… get_diabetes_… get_diabetes…     106 NA    NA     
#>  8 diabetes_ty… v1      Type… get_diabetes_… get_diabetes…     126 NA    NA     
#>  9 diabetes_ty… v2      Type… get_diabetes_… get_diabetes…      87 2026… ICD-10…
#> 10 hf           v1      Hear… get_hf_v1_cod… get_hf_v1_de…      54 NA    NA     
#> 11 hf           v2      Hear… get_hf_v2_cod… get_hf_v2_de…      23 2026… ICD-10…
#> 12 hyperlipide… v1      Hype… get_hyperlipi… get_hyperlip…      11 NA    NA     
#> 13 hypertension v1      Hype… get_hypertens… get_hyperten…      36 NA    NA     
#> 14 lead_pad     v1      lowe… get_lead_pad_… get_lead_pad…     312 NA    NA     
#> 15 obesity      v1      Obes… get_obesity_v… get_obesity_…      42 NA    NA     
#> 16 ohs          v1      Obes… get_ohs_v1_co… get_ohs_v1_d…       2 NA    NA     
#> 17 osa          v1      Obst… get_osa_v1_co… get_osa_v1_d…       7 NA    NA     
#> 18 osteoarthri… v1      Oste… get_osteoarth… get_osteoart…     176 NA    NA     
#> 19 stroke       v1      Stro… get_stroke_v1… get_stroke_v…     167 NA    NA     
```
