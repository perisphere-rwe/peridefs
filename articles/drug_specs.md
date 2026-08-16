# Working with Drug Specs

``` r

library(peridefs)
```

Most drug specs in `peridefs` are **composites** — they contain named
component specs (individual drug classes or versions) rather than a flat
GNN list. The `component` argument is optional on every drug `get_*`
function; omit it (or pass `"all"`) to retrieve every component at once.

| Function | Returns |
|----|----|
| `get_<condition>_generics(component = ...)` | Tibble of generic (and brand, as a list-column) names, with `priority`, `condition`, `class`, and `version` columns |
| `get_<condition>_meds_labels(component = ...)` | Tibble of each component’s `name` (key) and human-readable `label` (e.g. `"ACE Inhibitors"`) |

Print any composite spec to see its available component names:

``` r

spec_hypertension
#> 
#> ── Antihypertensive Medications (composite) ────────────────────────────────────
#> Drug class: `antihypertensive`
#> Condition: `hypertension`
#> Def: All antihypertensive leaf components across versions (v1 = Perisphere
#> list; v2 = FDB). Note for central agents: exclude APRACLONIDINE when matching
#> CLONIDINE.
#> 25 component(s):
#>   `acei_v1`: ACE Inhibitors (10 GNNs)
#>   `acei_v2`: ACE Inhibitors (31 GNNs)
#>   `arb_v1`: Angiotensin Receptor Blockers (ARBs) (8 GNNs)
#>   `arb_v2`: Angiotensin Receptor Blockers (ARBs) (34 GNNs)
#>   `alpha_v1`: Alpha-1 Blockers (7 GNNs)
#>   `alpha_beta_v1`: Alpha-Beta Blockers (4 GNNs)
#>   `alpha_beta_v2`: Alpha-Beta Blockers (3 GNNs)
#>   `cardio_v1`: Beta Blockers (Cardioselective) (17 GNNs)
#>   `cardio_vasod_v1`: Beta Blockers (Cardioselective, Vasodilatory) (2 GNNs)
#>   `int_sym_v1`: Beta Blockers (Intrinsic Sympathomimetic Activity) (4 GNNs)
#>   `int_sym_v2`: Beta Blockers (Intrinsic Sympathomimetic Activity) (5 GNNs)
#>   `noncardio_v1`: Beta Blockers (Noncardioselective) (10 GNNs)
#>   `ccb_dhp_v1`: Calcium Channel Blockers (Dihydropyridines) (17 GNNs)
#>   `ccb_nondhp_v1`: Calcium Channel Blockers (Non-Dihydropyridines) (5 GNNs)
#>   `thiazide_v1`: Diuretics (Thiazide and Thiazide-Type) (9 GNNs)
#>   `thiazide_v2`: Diuretics (Thiazide and Thiazide-Type) (10 GNNs)
#>   `loop_v1`: Diuretics (Loop) (3 GNNs)
#>   `loop_v2`: Diuretics (Loop) (5 GNNs)
#>   `ksparing_v1`: Diuretics (Potassium-Sparing) (2 GNNs)
#>   `ksparing_v2`: Diuretics (Potassium-Sparing) (11 GNNs)
#>   `aldo_v1`: Aldosterone Antagonists (6 GNNs)
#>   `central_v1`: Centrally Acting Agents (3 GNNs)
#>   `central_v2`: Centrally Acting Agents (20 GNNs)
#>   `renin_v1`: Direct Renin Inhibitors (8 GNNs)
#>   `vasodilators_v1`: Direct Vasodilators (5 GNNs)
#> Use `component` = "acei_v1", "acei_v2", "arb_v1", "arb_v2", "alpha_v1",
#> "alpha_beta_v1", "alpha_beta_v2", "cardio_v1", "cardio_vasod_v1", "int_sym_v1",
#> "int_sym_v2", "noncardio_v1", "ccb_dhp_v1", "ccb_nondhp_v1", "thiazide_v1",
#> "thiazide_v2", "loop_v1", "loop_v2", …, "renin_v1", and "vasodilators_v1" in
#> `get_*()` functions.
```

## Retrieving GNNs for a specific component

Pass the versioned component name to `get_*_generics()`:

``` r

get_hypertension_generics(component = "acei_v1")
#> # A tibble: 10 × 6
#>    generic      brand     priority condition class version
#>    <chr>        <list>       <int> <chr>     <chr> <chr>  
#>  1 BENAZEPRIL   <chr [0]>        1 NA        acei  v1     
#>  2 CAPTOPRIL    <chr [0]>        1 NA        acei  v1     
#>  3 ENALAPRIL    <chr [0]>        1 NA        acei  v1     
#>  4 FOSINOPRIL   <chr [0]>        1 NA        acei  v1     
#>  5 LISINOPRIL   <chr [0]>        1 NA        acei  v1     
#>  6 MOEXIPRIL    <chr [0]>        1 NA        acei  v1     
#>  7 PERINDOPRIL  <chr [0]>        1 NA        acei  v1     
#>  8 QUINAPRIL    <chr [0]>        1 NA        acei  v1     
#>  9 RAMIPRIL     <chr [0]>        1 NA        acei  v1     
#> 10 TRANDOLAPRIL <chr [0]>        1 NA        acei  v1
```

Omit `component` (or pass `"all"`) to retrieve every component’s GNNs at
once, distinguished by the `class` and `version` columns:

``` r

get_hypertension_generics() |> nrow()
#> [1] 205
```

### Comparing versions

Many drug classes have two versions — v1 from the Perisphere medication
list and v2 from First DataBank (FDB), which may add spelling variants:

``` r

# v1 — Perisphere source
get_hypertension_generics(component = "acei_v1")
#> # A tibble: 10 × 6
#>    generic      brand     priority condition class version
#>    <chr>        <list>       <int> <chr>     <chr> <chr>  
#>  1 BENAZEPRIL   <chr [0]>        1 NA        acei  v1     
#>  2 CAPTOPRIL    <chr [0]>        1 NA        acei  v1     
#>  3 ENALAPRIL    <chr [0]>        1 NA        acei  v1     
#>  4 FOSINOPRIL   <chr [0]>        1 NA        acei  v1     
#>  5 LISINOPRIL   <chr [0]>        1 NA        acei  v1     
#>  6 MOEXIPRIL    <chr [0]>        1 NA        acei  v1     
#>  7 PERINDOPRIL  <chr [0]>        1 NA        acei  v1     
#>  8 QUINAPRIL    <chr [0]>        1 NA        acei  v1     
#>  9 RAMIPRIL     <chr [0]>        1 NA        acei  v1     
#> 10 TRANDOLAPRIL <chr [0]>        1 NA        acei  v1

# v2 — FDB (adds FOSINIPRIL and MOEXEPRIL variants)
get_hypertension_generics(component = "acei_v2")
#> # A tibble: 31 × 6
#>    generic                        brand     priority condition class version
#>    <chr>                          <list>       <int> <chr>     <chr> <chr>  
#>  1 AMLODIPINE BESYLATE/BENAZEPRIL <chr [0]>        1 NA        acei  v2     
#>  2 BENAZEPRIL                     <chr [0]>        1 NA        acei  v2     
#>  3 BENAZEPRIL HCL                 <chr [0]>        1 NA        acei  v2     
#>  4 BENAZEPRIL/HYDROCHLOROTHIAZIDE <chr [0]>        1 NA        acei  v2     
#>  5 CAPTOPRIL                      <chr [0]>        1 NA        acei  v2     
#>  6 CAPTOPRIL/HYDROCHLOROTHIAZIDE  <chr [0]>        1 NA        acei  v2     
#>  7 ENALAPRIL                      <chr [0]>        1 NA        acei  v2     
#>  8 ENALAPRIL MALEATE              <chr [0]>        1 NA        acei  v2     
#>  9 ENALAPRIL MALEATE/FELODIPINE   <chr [0]>        1 NA        acei  v2     
#> 10 ENALAPRIL MALEATE/HCTZ         <chr [0]>        1 NA        acei  v2     
#> # ℹ 21 more rows
```

## Component labels

[`get_hypertension_meds_labels()`](https://perisphere-rwe.github.io/peridefs/reference/get_hypertension_generics.md)
returns a tibble of each component’s `name` (its key, e.g. `"acei_v1"`)
and human-readable `label` (e.g. `"ACE Inhibitors"`) — not a clinical
definition. See \[get_hypertension_v1_codes()\] for the actual
diagnostic algorithm; a drug leaf’s own `defs` field is just an internal
sourcing note, so it isn’t surfaced here.

``` r

get_hypertension_meds_labels(component = "acei_v1")
#> # A tibble: 1 × 2
#>   name    label         
#>   <chr>   <chr>         
#> 1 acei_v1 ACE Inhibitors

# Omit component to see every leaf's label at once
get_hypertension_meds_labels()
#> # A tibble: 25 × 2
#>    name            label                                             
#>    <chr>           <chr>                                             
#>  1 acei_v1         ACE Inhibitors                                    
#>  2 acei_v2         ACE Inhibitors                                    
#>  3 arb_v1          Angiotensin Receptor Blockers (ARBs)              
#>  4 arb_v2          Angiotensin Receptor Blockers (ARBs)              
#>  5 alpha_v1        Alpha-1 Blockers                                  
#>  6 alpha_beta_v1   Alpha-Beta Blockers                               
#>  7 alpha_beta_v2   Alpha-Beta Blockers                               
#>  8 cardio_v1       Beta Blockers (Cardioselective)                   
#>  9 cardio_vasod_v1 Beta Blockers (Cardioselective, Vasodilatory)     
#> 10 int_sym_v1      Beta Blockers (Intrinsic Sympathomimetic Activity)
#> # ℹ 15 more rows
```

## Confidence tiers

The `priority` column distinguishes how confident we are that a generic
name belongs in a drug class definition: `1` (core) is the default and
most conservative tier, `2` (probable) covers generics with more than
one indication, and `3` (cautious) covers generics without their
expected indication in the US. Pass `priority = 1:3` to widen the result
and include lower-confidence matches.

## Brand names

Some generics genuinely correspond to more than one brand product — most
often because the same `GNRC_NM` covers formulations approved for
different indications (e.g., semaglutide as Ozempic for type 2 diabetes
vs. Wegovy for chronic weight management). Because a single generic can
map to zero, one, or multiple brands, `brand` is stored as a
**list-column**: each row’s `brand` value is a character vector, empty
(`character(0)`) when no brand is on record.

Build a small example with
[`drug_spec()`](https://perisphere-rwe.github.io/peridefs/reference/drug_spec.md)
to see this in action:

``` r

example_spec <- drug_spec(
  drug_class    = "example",
  label         = "Example GLP-1s",
  generic_names_probable = c("SEMAGLUTIDE", "TIRZEPATIDE"),
  generic_names_cautious = c("DULAGLUTIDE"),
  brand_names = list(
    SEMAGLUTIDE = "Ozempic",
    TIRZEPATIDE = "Mounjaro"
    # DULAGLUTIDE has no brand_names entry, so its brand is character(0)
  )
)

example_spec$get_generics(priority = 1:3)
#> # A tibble: 3 × 6
#>   generic     brand     priority condition class   version
#>   <chr>       <list>       <int> <chr>     <chr>   <chr>  
#> 1 SEMAGLUTIDE <chr [1]>        2 NA        example NA     
#> 2 TIRZEPATIDE <chr [1]>        2 NA        example NA     
#> 3 DULAGLUTIDE <chr [0]>        3 NA        example NA
```

Printing the tibble shows `<chr [1]>`/`<chr [0]>` for the list-column
rather than the brand text itself — that’s expected;
[`str()`](https://rdrr.io/r/utils/str.html) or indexing into the column
(e.g., `result$brand[[1]]`) shows the actual value(s). To get a
one-row-per-brand tibble instead, use
[`tidyr::unnest()`](https://tidyr.tidyverse.org/reference/unnest.html)
with `keep_empty = TRUE` — **without** `keep_empty = TRUE`, `unnest()`
silently drops every row with no recorded brand, which is most of them:

``` r

example_spec$get_generics(priority = 1:3) |>
  tidyr::unnest(brand, keep_empty = TRUE)
#> # A tibble: 3 × 6
#>   generic     brand    priority condition class   version
#>   <chr>       <chr>       <int> <chr>     <chr>   <chr>  
#> 1 SEMAGLUTIDE Ozempic         2 NA        example NA     
#> 2 TIRZEPATIDE Mounjaro        2 NA        example NA     
#> 3 DULAGLUTIDE NA              3 NA        example NA
```

## Antidiabetic drug classes

`spec_diabetes` groups all oral antidiabetic agents and insulin. Note
that `class` values are unprefixed drug-mechanism names
(e.g. `"biguanide"`, not `"antidiab_biguanide"`) — the composite’s
`condition` column already supplies the condition context, so repeating
it in `class` would be redundant:

``` r

spec_diabetes
#> 
#> ── Antidiabetic Medications (composite) ────────────────────────────────────────
#> Drug class: `antidiabetic`
#> Condition: `diabetes`
#> Def: All antidiabetic medication subclasses (v1): biguanides, sulfonylureas,
#> meglitinides, thiazolidinediones, alpha-glucosidase inhibitors, DPP-4
#> inhibitors, SGLT-2 inhibitors, GLP-1 receptor agonists, insulin and supplies,
#> amylin analogues.
#> 10 component(s):
#>   `biguanide_v1`: Biguanides (3 GNNs)
#>   `sulfonylurea_v1`: Sulfonylureas (11 GNNs)
#>   `meglitinide_v1`: Meglitinides (3 GNNs)
#>   `tzd_v1`: Thiazolidinediones (TZDs) (9 GNNs)
#>   `alpha_glucosidase_v1`: Alpha-Glucosidase Inhibitors (3 GNNs)
#>   `dpp4_v1`: DPP-4 Inhibitors (18 GNNs)
#>   `sglt2_v1`: SGLT-2 Inhibitors (23 GNNs)
#>   `glp1_v1`: GLP-1 (20 GNNs)
#>   `insulin_v1`: Insulin and Supplies (163 GNNs)
#>   `amylin_v1`: Amylin Analogues (1 GNNs)
#> Use `component` = "biguanide_v1", "sulfonylurea_v1", "meglitinide_v1",
#> "tzd_v1", "alpha_glucosidase_v1", "dpp4_v1", "sglt2_v1", "glp1_v1",
#> "insulin_v1", and "amylin_v1" in `get_*()` functions.
```

``` r

get_diabetes_generics(component = "glp1_v1")
#> # A tibble: 8 × 6
#>   generic                       brand     priority condition class version
#>   <chr>                         <list>       <int> <chr>     <chr> <chr>  
#> 1 ALBIGLUTIDE                   <chr [0]>        1 diabetes  glp1  v1     
#> 2 DULAGLUTIDE                   <chr [0]>        1 diabetes  glp1  v1     
#> 3 EXENATIDE                     <chr [0]>        1 diabetes  glp1  v1     
#> 4 EXENATIDE EXTENDED-RELEASE    <chr [0]>        1 diabetes  glp1  v1     
#> 5 EXENATIDE MICROSPHERES        <chr [0]>        1 diabetes  glp1  v1     
#> 6 LIXISENATIDE                  <chr [0]>        1 diabetes  glp1  v1     
#> 7 INSULIN DEGLUDEC/LIRAGLUTIDE  <chr [0]>        1 diabetes  glp1  v1     
#> 8 INSULIN GLARGINE/LIXISENATIDE <chr [0]>        1 diabetes  glp1  v1
```

``` r

get_diabetes_generics(component = "sglt2_v1")
#> # A tibble: 23 × 6
#>    generic                             brand  priority condition class version
#>    <chr>                               <list>    <int> <chr>     <chr> <chr>  
#>  1 CANAGLIFLOZIN                       <chr>         1 NA        sglt2 v1     
#>  2 CANAGLIFLOZIN/METFORM               <chr>         1 NA        sglt2 v1     
#>  3 CANAGLIFLOZIN/METFORMIN             <chr>         1 NA        sglt2 v1     
#>  4 DAPAGLIFLOZIN                       <chr>         1 NA        sglt2 v1     
#>  5 DAPAGLIFLOZIN/METFORMIN             <chr>         1 NA        sglt2 v1     
#>  6 DAPAGLIFLOZIN/SAXAGLIPTIN           <chr>         1 NA        sglt2 v1     
#>  7 EMPAGLIFLOZIN                       <chr>         1 NA        sglt2 v1     
#>  8 EMPAGLIFLOZIN/LINAGLIPTIN           <chr>         1 NA        sglt2 v1     
#>  9 EMPAGLIFLOZIN/LINAGLIPTIN/METFORMIN <chr>         1 NA        sglt2 v1     
#> 10 EMPAGLIFLOZIN/METFORMIN             <chr>         1 NA        sglt2 v1     
#> # ℹ 13 more rows
```

## Creating your own drug spec

Use
[`drug_spec()`](https://perisphere-rwe.github.io/peridefs/reference/drug_spec.md)
to define a custom drug class, or
[`modify_drug_spec()`](https://perisphere-rwe.github.io/peridefs/reference/modify_drug_spec.md)
to extend an existing component. See `vignette("custom_specs")` for
details.
