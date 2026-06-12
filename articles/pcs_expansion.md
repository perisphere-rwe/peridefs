# ICD-10-PCS Code Expansion

``` r

library(peridefs)
```

ICD-10-PCS (Procedure Coding System) codes are 7-character alphanumeric
strings. Because each character position encodes a specific attribute of
the procedure, a short prefix can represent many valid codes. `peridefs`
includes
[`expand_pcs()`](https://perisphere-rwe.github.io/peridefs/reference/expand_pcs.md)
to resolve such patterns to their full set of valid 7-character codes.

## The FY2026 reference table

`peridefs` bundles the CMS FY2026 ICD-10-PCS code table (effective
October 1, 2025), which contains **79,115 valid codes**.
[`expand_pcs()`](https://perisphere-rwe.github.io/peridefs/reference/expand_pcs.md)
validates all expansions against this table — it will only return codes
that appear on the official CMS list.

## How patterns work

[`expand_pcs()`](https://perisphere-rwe.github.io/peridefs/reference/expand_pcs.md)
works by **prefix matching**: it strips all trailing `x` or `X`
characters from the pattern to form a fixed prefix, then returns every
valid code that starts with that prefix.

``` r

# "0210xxx" → prefix "0210" → all valid codes starting with 0210
cabg_pcs <- expand_pcs("0210xxx")
length(cabg_pcs)
#> [1] 74
head(cabg_pcs)
#> [1] "0210083" "0210088" "0210089" "021008C" "021008F" "021008W"
```

Because both lowercase `x` and uppercase `X` are stripped from the
trailing end, the length of the trailing wildcard string does not matter
— only the non-wildcard prefix is used for matching. A pattern with no
trailing `x`/`X` is treated as an exact code lookup:

``` r

# Exact code — returned only if it exists in the FY2026 table
expand_pcs("02100Z9")
#> [1] "02100Z9"
```

If an exact code does not exist in the reference table, an empty vector
is returned:

``` r

expand_pcs("0000000")
#> character(0)
```

## Multiple patterns

Pass a character vector to expand several patterns at once. Results are
the union of all matches, deduplicated:

``` r

# CABG with two different approach prefixes
combined <- expand_pcs(c("0210xxx", "0211xxx"))
length(combined)
#> [1] 148
```

## How bundled PCS specs are built

Bundled specs that include ICD-10-PCS codes — such as `spec_chd_v1`
(coronary revascularization procedures) — use
[`expand_pcs()`](https://perisphere-rwe.github.io/peridefs/reference/expand_pcs.md)
internally during the build process in `data-raw/build_specs.R`. The
stored code vectors always reflect the FY2026 reference table.

``` r


# ICD-10-PCS codes bundled in spec_chd_v1
spec_chd_v1 <- spec_ascvd$components()[['chd_v1']]
spec_chd_v1$get_codes(code_type = "proc_icd10")$proc_icd10 |> length()
#> [1] 575
```

When CMS releases a new fiscal year update (typically October 1), the
package maintainer runs `data-raw/download_pcs_codes.R` to refresh the
reference table, then rebuilds all affected specs.
