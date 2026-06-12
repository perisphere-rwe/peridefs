# Creating Custom Specs

``` r

library(peridefs)
```

All bundled specs are immutable — they are read-only data objects that
ship with the package. When you need a code set that differs from a
bundled spec (e.g., a project-specific algorithm, a subset of codes, or
a study-defined version), `peridefs` provides functions to create and
modify specs without touching the originals.

## Creating a new CodeSpec

[`code_spec()`](https://perisphere-rwe.github.io/peridefs/reference/code_spec.md)
creates a new
[`CodeSpec`](https://perisphere-rwe.github.io/peridefs/reference/CodeSpec.md)
from scratch. Provide a short `condition` ID, a `label`, and a named
list of code vectors:

``` r

my_htn <- code_spec(
  condition = "my_htn",
  label     = "Hypertension (study version)",
  version   = "v1",
  codes     = list(
    dx_icd9  = c("4010", "4011", "4019"),
    dx_icd10 = c("I10")
  )
)

my_htn
#> 
#> ── Hypertension (study version) (v1) ───────────────────────────────────────────
#> Condition: `my_htn`
#> Code sets:
#>   `dx_icd9`: 3 condition / 3 outcome codes
#>   `dx_icd10`: 1 condition / 1 outcome codes
```

The resulting spec object has `$get_codes()` and `$get_defs()` methods:

``` r

my_htn$get_codes(code_type = "dx_icd10")
#> $dx_icd10
#> [1] "I10"
```

## Creating a new DrugSpec

[`drug_spec()`](https://perisphere-rwe.github.io/peridefs/reference/drug_spec.md)
creates a
[`DrugSpec`](https://perisphere-rwe.github.io/peridefs/reference/DrugSpec.md)
from a vector of generic names:

``` r

my_thiazide <- drug_spec(
  drug_class    = "my_thiazide",
  label         = "Thiazide Diuretics (study subset)",
  version       = "v1",
  generic_names = c("HYDROCHLOROTHIAZIDE", "CHLORTHALIDONE", "INDAPAMIDE")
)

my_thiazide$get_generics()
#> [1] "HYDROCHLOROTHIAZIDE" "CHLORTHALIDONE"      "INDAPAMIDE"
```

## Adding codes to a bundled spec

[`add_codes()`](https://perisphere-rwe.github.io/peridefs/reference/add_codes.md)
returns a modified deep clone of a spec with additional codes merged in.
The `...` argument names must be valid code-set keys. The original is
never modified:

``` r

# Inspect available keys
names(spec_htn_v1$get_codes())
#> [1] "dx_icd9"  "dx_icd10"

# Add a code and confirm the clone grew; original is unchanged
htn_plus <- add_codes(spec_htn_v1, dx_icd10 = c("I99"))

length(htn_plus$get_codes(code_type = "dx_icd10")$dx_icd10)  # clone
#> [1] 24
length(spec_htn_v1$get_codes(code_type = "dx_icd10")$dx_icd10)  # original
#> [1] 23
```

By default, added codes are flagged for both `condition` and `outcome`.
Use `variable_type` to restrict membership:

``` r

htn_outcome_only <- add_codes(
  spec_htn_v1,
  variable_type = "outcome",
  dx_icd10      = c("I99")
)
```

## Removing codes from a bundled spec

[`remove_codes()`](https://perisphere-rwe.github.io/peridefs/reference/remove_codes.md)
returns a clone with the specified codes excluded:

``` r

htn_trimmed <- remove_codes(spec_htn_v1, dx_icd9 = c("4019"))

# Code removed from clone; original is unchanged
"4019" %in% htn_trimmed$get_codes(code_type = "dx_icd9")$dx_icd9
#> [1] FALSE
"4019" %in% spec_htn_v1$get_codes(code_type = "dx_icd9")$dx_icd9
#> [1] TRUE
```

## Modifying a CodeSpec

[`modify_code_spec()`](https://perisphere-rwe.github.io/peridefs/reference/modify_code_spec.md)
can update the label, narrative definitions, or replace code sets:

``` r

htn_revised <- modify_code_spec(
  spec  = spec_htn_v1,
  label = "Hypertension (revised)",
  defs  = list(
    condition = c("i" = "Study-specific hypertension definition."),
    outcome   = NULL
  )
)

htn_revised
#> 
#> ── Hypertension (revised) (v1) ─────────────────────────────────────────────────
#> Condition: `htn`
#> Condition def:
#> ℹ Study-specific hypertension definition.
#> 
#> Code sets:
#>   `dx_icd9`: 13 condition / 0 outcome codes
#>   `dx_icd10`: 23 condition / 0 outcome codes
```

To create a **new version**, construct a new
[`code_spec()`](https://perisphere-rwe.github.io/peridefs/reference/code_spec.md)
object directly rather than modifying an existing one. This keeps each
version explicit and self-contained:

``` r

spec_my_htn_v2 <- code_spec(
  condition = "my_htn",
  label     = "Hypertension (study v2)",
  version   = "v2",
  defs      = list(
    condition = c("i" = "Expanded definition including I11.x and I13.x."),
    outcome   = NULL
  ),
  codes = list(
    dx_icd10 = c("I10", "I110", "I119", "I130", "I132")
  )
)

spec_my_htn_v2
#> 
#> ── Hypertension (study v2) (v2) ────────────────────────────────────────────────
#> Condition: `my_htn`
#> Condition def:
#> ℹ Expanded definition including I11.x and I13.x.
#> 
#> Code sets:
#>   `dx_icd10`: 5 condition / 5 outcome codes
```

## Modifying a DrugSpec

[`modify_drug_spec()`](https://perisphere-rwe.github.io/peridefs/reference/modify_drug_spec.md)
mirrors
[`modify_code_spec()`](https://perisphere-rwe.github.io/peridefs/reference/modify_code_spec.md)
for drug classes. To work with a specific component from a composite,
extract it first:

``` r

# Extract a leaf spec from a composite
acei_v1 <- spec_antihypertensive$components()$acei_v1

# Build a study-specific variant
my_acei <- modify_drug_spec(
  spec          = acei_v1,
  label         = "ACE Inhibitors (study subset)",
  generic_names = c("LISINOPRIL", "RAMIPRIL", "ENALAPRIL")
)

my_acei$get_generics()
#> [1] "LISINOPRIL" "RAMIPRIL"   "ENALAPRIL"
```

## Immutability

All custom-spec functions return **deep clones**. Bundled spec objects
(`spec_htn_v1`, `spec_antihypertensive`, etc.) are never modified in
place, so you can safely build study-specific variants without affecting
other code in your project that relies on the standard definitions.
