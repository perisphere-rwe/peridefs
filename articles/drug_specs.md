# Working with Drug Specs

``` r

library(peridefs)
```

All drug specs in `peridefs` are **composites** — they contain named
component specs (individual drug classes or versions) rather than a flat
GNN list. The `component` argument is required on every drug `get_*`
function.

| Function | Returns |
|----|----|
| `get_<drug>_generics(component = ...)` | Character vector of generic nonproprietary names (GNNs) |
| `get_<drug>_codes(component = ...)` | Character vector of NDC codes (typically empty) |
| `get_<drug>_defs(component = ...)` | Narrative description of the component’s drug class definition |

Print any composite spec to see its available component names:

``` r

spec_antihypertensive
#> 
#> ── Antihypertensive Medications (composite) ────────────────────────────────────
#> Drug class: `antihypertensive`
#> Def: All antihypertensive leaf components across versions (v1 = Perisphere
#> list; v2 = FDB). Note for central agents: exclude APRACLONIDINE when matching
#> CLONIDINE.
#> 25 component(s):
#>   `acei_v1`: ACE Inhibitors (10 GNNs)
#>   `acei_v2`: ACE Inhibitors (12 GNNs)
#>   `arb_v1`: Angiotensin Receptor Blockers (ARBs) (8 GNNs)
#>   `arb_v2`: Angiotensin Receptor Blockers (ARBs) (9 GNNs)
#>   `alpha_v1`: Alpha-1 Blockers (3 GNNs)
#>   `alpha_beta_v1`: Alpha-Beta Blockers (2 GNNs)
#>   `alpha_beta_v2`: Alpha-Beta Blockers (3 GNNs)
#>   `cardio_v1`: Beta Blockers (Cardioselective) (4 GNNs)
#>   `cardio_vasod_v1`: Beta Blockers (Cardioselective, Vasodilatory) (1 GNNs)
#>   `int_sym_v1`: Beta Blockers (Intrinsic Sympathomimetic Activity) (4 GNNs)
#>   `int_sym_v2`: Beta Blockers (Intrinsic Sympathomimetic Activity) (2 GNNs)
#>   `noncardio_v1`: Beta Blockers (Noncardioselective) (2 GNNs)
#>   `ccb_dhp_v1`: Calcium Channel Blockers (Dihydropyridines) (6 GNNs)
#>   `ccb_nondhp_v1`: Calcium Channel Blockers (Non-Dihydropyridines) (2 GNNs)
#>   `thiazide_v1`: Diuretics (Thiazide and Thiazide-Type) (6 GNNs)
#>   `thiazide_v2`: Diuretics (Thiazide and Thiazide-Type) (8 GNNs)
#>   `loop_v1`: Diuretics (Loop) (3 GNNs)
#>   `loop_v2`: Diuretics (Loop) (4 GNNs)
#>   `ksparing_v1`: Diuretics (Potassium-Sparing) (2 GNNs)
#>   `ksparing_v2`: Diuretics (Potassium-Sparing) (4 GNNs)
#>   `aldo_v1`: Aldosterone Antagonists (2 GNNs)
#>   `central_v1`: Centrally Acting Agents (3 GNNs)
#>   `central_v2`: Centrally Acting Agents (5 GNNs)
#>   `renin_v1`: Direct Renin Inhibitors (1 GNNs)
#>   `vasodilators_v1`: Direct Vasodilators (2 GNNs)
#> Use `component` = "acei_v1", "acei_v2", "arb_v1", "arb_v2", "alpha_v1",
#> "alpha_beta_v1", "alpha_beta_v2", "cardio_v1", "cardio_vasod_v1", "int_sym_v1",
#> "int_sym_v2", "noncardio_v1", "ccb_dhp_v1", "ccb_nondhp_v1", "thiazide_v1",
#> "thiazide_v2", "loop_v1", "loop_v2", …, "renin_v1", and "vasodilators_v1" in
#> `get_*()` functions.
```

## Retrieving GNNs for a specific component

Pass the versioned component name to `get_*_generics()`:

``` r

get_antihypertensive_generics(component = "acei_v1")
#>  [1] "BENAZEPRIL"   "CAPTOPRIL"    "ENALAPRIL"    "FOSINOPRIL"   "LISINOPRIL"  
#>  [6] "MOEXIPRIL"    "PERINDOPRIL"  "QUINAPRIL"    "RAMIPRIL"     "TRANDOLAPRIL"
```

Use `component = "all"` to retrieve the union of every component’s GNNs:

``` r

get_antihypertensive_generics(component = "all") |> length()
#> [1] 73
```

### Comparing versions

Many drug classes have two versions — v1 from the Perisphere medication
list and v2 from First DataBank (FDB), which may add spelling variants:

``` r

# v1 — Perisphere source
get_antihypertensive_generics(component = "acei_v1")
#>  [1] "BENAZEPRIL"   "CAPTOPRIL"    "ENALAPRIL"    "FOSINOPRIL"   "LISINOPRIL"  
#>  [6] "MOEXIPRIL"    "PERINDOPRIL"  "QUINAPRIL"    "RAMIPRIL"     "TRANDOLAPRIL"

# v2 — FDB (adds FOSINIPRIL and MOEXEPRIL variants)
get_antihypertensive_generics(component = "acei_v2")
#>  [1] "BENAZEPRIL"   "CAPTOPRIL"    "ENALAPRIL"    "FOSINOPRIL"   "FOSINIPRIL"  
#>  [6] "LISINOPRIL"   "MOEXIPRIL"    "MOEXEPRIL"    "PERINDOPRIL"  "QUINAPRIL"   
#> [11] "RAMIPRIL"     "TRANDOLAPRIL"
```

## Algorithm definitions

Each component carries a narrative description of how that drug class
was identified:

``` r

get_antihypertensive_defs(component = "acei_v1")
#> From the Perisphere antihypertensive medication list.
```

## NDC codes

NDC code vectors are currently empty for drug classes. They can be added
in a future update. The `get_<drug>_codes()` function is reserved for
future use or for custom specs you build with
[`drug_spec()`](https://perisphere-rwe.github.io/peridefs/reference/drug_spec.md).
The primary identification mechanism at the moment is through generic
names.

## Antidiabetic drug classes

`spec_antidiabetic` groups all oral antidiabetic agents and insulin:

``` r

spec_antidiabetic
#> 
#> ── Antidiabetic Medications (composite) ────────────────────────────────────────
#> Drug class: `antidiabetic`
#> Def: All antidiabetic medication subclasses (v1): biguanides, sulfonylureas,
#> meglitinides, thiazolidinediones, alpha-glucosidase inhibitors, DPP-4
#> inhibitors, SGLT-2 inhibitors, GLP-1 receptor agonists, insulin and supplies,
#> amylin analogues.
#> 10 component(s):
#>   `biguanide_v1`: Antidiabetics — Biguanides (3 GNNs)
#>   `sulfonylurea_v1`: Antidiabetics — Sulfonylureas (10 GNNs)
#>   `meglitinide_v1`: Antidiabetics — Meglitinides (3 GNNs)
#>   `tzd_v1`: Antidiabetics — Thiazolidinediones (TZDs) (8 GNNs)
#>   `alpha_glucosidase_v1`: Antidiabetics — Alpha-Glucosidase Inhibitors (3 GNNs)
#>   `dpp4_v1`: Antidiabetics — DPP-4 Inhibitors (15 GNNs)
#>   `sglt2_v1`: Antidiabetics — SGLT-2 Inhibitors (13 GNNs)
#>   `glp1_v1`: Antidiabetics — GLP-1 Receptor Agonists (6 GNNs)
#>   `insulin_v1`: Antidiabetics — Insulin and Supplies (71 GNNs)
#>   `amylin_v1`: Antidiabetics — Amylin Analogues (1 GNNs)
#> Use `component` = "biguanide_v1", "sulfonylurea_v1", "meglitinide_v1",
#> "tzd_v1", "alpha_glucosidase_v1", "dpp4_v1", "sglt2_v1", "glp1_v1",
#> "insulin_v1", and "amylin_v1" in `get_*()` functions.
```

``` r

get_antidiabetic_generics(component = "glp1_v1")
#> [1] "DULAGLUTIDE"            "EXENATIDE"              "EXENATIDE MICROSPHERES"
#> [4] "LIRAGLUTIDE"            "LIXISENATIDE"           "SEMAGLUTIDE"
```

``` r

get_antidiabetic_generics(component = "sglt2_v1")
#>  [1] "CANAGLIFLOZIN"                       "CANAGLIFLOZIN/METFORM"              
#>  [3] "CANAGLIFLOZIN/METFORMIN"             "DAPAGLIFLOZIN"                      
#>  [5] "DAPAGLIFLOZIN/METFORMIN"             "DAPAGLIFLOZIN/SAXAGLIPTIN"          
#>  [7] "EMPAGLIFLOZIN"                       "EMPAGLIFLOZIN/LINAGLIPTIN"          
#>  [9] "EMPAGLIFLOZIN/LINAGLIPTIN/METFORMIN" "EMPAGLIFLOZIN/METFORMIN"            
#> [11] "ERTUGLIFLOZIN"                       "ERTUGLIFLOZIN/METFORMIN"            
#> [13] "ERTUGLIFLOZIN/SITAGLIPTIN"
```

## Creating your own drug spec

Use
[`drug_spec()`](https://perisphere-rwe.github.io/peridefs/reference/drug_spec.md)
to define a custom drug class, or
[`modify_drug_spec()`](https://perisphere-rwe.github.io/peridefs/reference/modify_drug_spec.md)
to extend an existing component. See `vignette("custom_specs")` for
details.
