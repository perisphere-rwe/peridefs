# Expand ICD-10-PCS prefix patterns to all matching valid codes

Resolves ICD-10-PCS pattern strings of the form used in the Perisphere
definitions document (e.g., `"0210xxx"`) into the full set of valid
7-character ICD-10-PCS codes from the FY2026 CMS order file.

Patterns are matched by **prefix**: trailing lowercase `x` characters
are stripped to form the prefix, and all valid codes that begin with
that prefix are returned. Codes with no trailing `x` are treated as
exact codes and returned only if they exist in the reference table.

## Usage

``` r
expand_pcs(patterns)
```

## Arguments

- patterns:

  Character vector of ICD-10-PCS pattern strings. Examples:

  - `"0210xxx"` — 4-character prefix, returns all 74 CABG variants

  - `"03CH0ZZ"` — exact code, returned as-is if valid

  - `c("0210xxx", "0211xxx")` — vectorised; results are unioned

## Value

Character vector of unique valid ICD-10-PCS codes (7 characters, no
periods).

## Examples

``` r
# All CABG codes (0210 prefix)
expand_pcs("0210xxx")
#>  [1] "0210083" "0210088" "0210089" "021008C" "021008F" "021008W" "0210093"
#>  [8] "0210098" "0210099" "021009C" "021009F" "021009W" "02100A3" "02100A8"
#> [15] "02100A9" "02100AC" "02100AF" "02100AW" "02100J3" "02100J8" "02100J9"
#> [22] "02100JC" "02100JF" "02100JW" "02100K3" "02100K8" "02100K9" "02100KC"
#> [29] "02100KF" "02100KW" "02100Z3" "02100Z8" "02100Z9" "02100ZC" "02100ZF"
#> [36] "0210344" "02103D4" "0210444" "0210483" "0210488" "0210489" "021048C"
#> [43] "021048F" "021048W" "0210493" "0210498" "0210499" "021049C" "021049F"
#> [50] "021049W" "02104A3" "02104A8" "02104A9" "02104AC" "02104AF" "02104AW"
#> [57] "02104D4" "02104J3" "02104J8" "02104J9" "02104JC" "02104JF" "02104JW"
#> [64] "02104K3" "02104K8" "02104K9" "02104KC" "02104KF" "02104KW" "02104Z3"
#> [71] "02104Z8" "02104Z9" "02104ZC" "02104ZF"

# Exact code lookup
expand_pcs("02100Z9")
#> [1] "02100Z9"

# Multiple patterns — results are combined and deduplicated
expand_pcs(c("0210xxx", "0211xxx"))
#>   [1] "0210083" "0210088" "0210089" "021008C" "021008F" "021008W" "0210093"
#>   [8] "0210098" "0210099" "021009C" "021009F" "021009W" "02100A3" "02100A8"
#>  [15] "02100A9" "02100AC" "02100AF" "02100AW" "02100J3" "02100J8" "02100J9"
#>  [22] "02100JC" "02100JF" "02100JW" "02100K3" "02100K8" "02100K9" "02100KC"
#>  [29] "02100KF" "02100KW" "02100Z3" "02100Z8" "02100Z9" "02100ZC" "02100ZF"
#>  [36] "0210344" "02103D4" "0210444" "0210483" "0210488" "0210489" "021048C"
#>  [43] "021048F" "021048W" "0210493" "0210498" "0210499" "021049C" "021049F"
#>  [50] "021049W" "02104A3" "02104A8" "02104A9" "02104AC" "02104AF" "02104AW"
#>  [57] "02104D4" "02104J3" "02104J8" "02104J9" "02104JC" "02104JF" "02104JW"
#>  [64] "02104K3" "02104K8" "02104K9" "02104KC" "02104KF" "02104KW" "02104Z3"
#>  [71] "02104Z8" "02104Z9" "02104ZC" "02104ZF" "0211083" "0211088" "0211089"
#>  [78] "021108C" "021108F" "021108W" "0211093" "0211098" "0211099" "021109C"
#>  [85] "021109F" "021109W" "02110A3" "02110A8" "02110A9" "02110AC" "02110AF"
#>  [92] "02110AW" "02110J3" "02110J8" "02110J9" "02110JC" "02110JF" "02110JW"
#>  [99] "02110K3" "02110K8" "02110K9" "02110KC" "02110KF" "02110KW" "02110Z3"
#> [106] "02110Z8" "02110Z9" "02110ZC" "02110ZF" "0211344" "02113D4" "0211444"
#> [113] "0211483" "0211488" "0211489" "021148C" "021148F" "021148W" "0211493"
#> [120] "0211498" "0211499" "021149C" "021149F" "021149W" "02114A3" "02114A8"
#> [127] "02114A9" "02114AC" "02114AF" "02114AW" "02114D4" "02114J3" "02114J8"
#> [134] "02114J9" "02114JC" "02114JF" "02114JW" "02114K3" "02114K8" "02114K9"
#> [141] "02114KC" "02114KF" "02114KW" "02114Z3" "02114Z8" "02114Z9" "02114ZC"
#> [148] "02114ZF"
```
