# Add codes to a condition code specification

Returns a deep clone of `spec` with the specified codes appended to the
given key(s). The original spec is never modified.

## Usage

``` r
add_codes(spec, variable_type = c("condition", "outcome", "both"), ...)
```

## Arguments

- spec:

  A
  [CodeSpec](https://perisphere-rwe.github.io/peridefs/reference/CodeSpec.md)
  object.

- variable_type:

  Which membership flag(s) to set for the new codes. `"condition"` sets
  `condition = TRUE, outcome = FALSE`; `"outcome"` sets
  `condition = FALSE, outcome = TRUE`; `"both"` (default) sets both to
  `TRUE`.

- ...:

  Named arguments where the name is a code-set key (e.g., `dx_icd9`) and
  the value is a character vector of codes to add.

## Value

A modified deep clone of `spec`.

## Examples

``` r
my_htn <- add_codes(
  spec_htn_v1,
  dx_icd10 = c("I119", "I130")
)
```
