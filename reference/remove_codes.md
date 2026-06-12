# Remove codes from a condition code specification

Returns a deep clone of `spec` with the specified codes removed from the
given key(s). The original spec is never modified.

## Usage

``` r
remove_codes(spec, ...)
```

## Arguments

- spec:

  A
  [CodeSpec](https://perisphere-rwe.github.io/peridefs/reference/CodeSpec.md)
  object.

- ...:

  Named arguments where the name is a code-set key and the value is a
  character vector of codes to remove.

## Value

A modified deep clone of `spec`.

## Examples

``` r
# Remove a specific code from the ICD-9 inpatient set
my_htn <- remove_codes(spec_htn_v1, dx_icd9 = c("4019"))
```
