# peridefs — Guide for Adding New Conditions and Medications

This guide documents how to add new entries to the peridefs package from the
Perisphere definitions Word document. It is written for an AI assistant being
re-trained on the project, but also serves as a developer reference.

---

## 1. Project overview

`peridefs` exposes Perisphere medical code definitions through a consistent R6
API. Every condition and drug class is a **spec object** — an R6 instance
exported as `spec_{name}`. Users call `get_{name}_codes()`, `get_{name}_defs()`,
and `get_{name}_generics()` to retrieve the data.

The four R6 classes are:

| Class | Use |
|---|---|
| `CodeSpec` | A single condition with ICD/HCPCS/CPT codes, organised by version |
| `DrugSpec` | A single drug class with GNN names and NDC codes, organised by version |
| `CompositeCodeSpec` | A condition whose codes are the union of several `CodeSpec` objects (e.g. ASCVD) |
| `CompositeDrugSpec` | A drug class whose GNNs are the union of several `DrugSpec` objects (e.g. antihypertensive) |

---

## 2. Loading the Word document into memory

The source of truth is:

```
Definition of conditions and medications_11262025.docx
```

located at the **package root** (excluded from the build via `.Rbuildignore`).

The document is a `.docx` ZIP archive. Its content lives in `word/document.xml`.
All paragraphs are extracted into the `texts` character vector, which is
available in the current R session (it was loaded during prior development).
If it is not in memory, rebuild it with:

```r
library(xml2)
docx_path <- "Definition of conditions and medications_11262025.docx"
tmp <- tempfile(); dir.create(tmp)
unzip(docx_path, files = "word/document.xml", exdir = tmp)
doc   <- read_xml(file.path(tmp, "word", "document.xml"))
ns    <- xml_ns(doc)
paras <- xml_find_all(doc, ".//w:p", ns)
texts <- vapply(paras, function(p) {
  paste(xml_text(xml_find_all(p, ".//w:t", ns)), collapse = "")
}, character(1))
```

**Important:** Word fragments text across many `<w:r>` run elements within a
single paragraph. The code above concatenates all run text to reconstruct each
paragraph as a single string. `texts` has one element per paragraph, in
document order.

---

## 3. Document structure

The document is organised as follows:

| Region | Approximate paragraph range | Content |
|---|---|---|
| Table of contents | 1 – ~120 | Numbered list of all conditions and medications with page numbers (dot-leaders) |
| Introduction | ~122 – 145 | Instructions for interpreting the list |
| Content sections | ~146 – end | One section per condition or drug class |

### 3.1 Identifying a section

**Every content section starts with a bold header paragraph** that matches:

```
{Name}, [history|outcome|version {N}|index and outcome], version {N}:
```

Key characteristics:
- The line ends with a colon `:`
- It contains the word `version` (often followed by a digit)
- It has no dot-leader sequence (`. . . .` or `……`)
- It is relatively short (< ~150 characters)

Search pattern:

```r
idx <- which(
  grepl("condition_name", texts, ignore.case = TRUE) &
  grepl("version", texts, ignore.case = TRUE) &
  nchar(texts) < 200 &
  !grepl("\\.{5}|……", texts)          # exclude TOC entries
)
# Use tail(idx, 1) to get the content section, not the TOC entry
```

### 3.2 Reading a section

After finding the header index `i`, the section body follows immediately.
Read forward until the next section header:

```r
for (j in i:(i + 15)) {
  txt <- texts[j]
  if (nchar(trimws(txt)) > 0) cat(sprintf("[%4d] %s\n", j, substr(txt, 1, 200)))
}
```

### 3.3 History vs. outcome flag

The section header word determines the `condition` / `outcome` flags:

| Header keyword | `condition` flag | `outcome` flag |
|---|---|---|
| `history` | `TRUE` | `FALSE` |
| `outcome` | `FALSE` | `TRUE` |
| `index and outcome` | `TRUE` | `TRUE` |
| No qualifier (e.g. just `version 1`) | `TRUE` | `TRUE` |

---

## 4. Interpreting ICD codes in condition definitions

### 4.1 ICD code formats used in the document

| Document notation | Meaning | Expansion function |
|---|---|---|
| `410.xx` | Any defined subcode of 410 | `expand9("410")` |
| `433.x1` | Subcodes of 433 where the 5th digit = 1 | `Filter(\(x) endsWith(x,"1"), expand9("433"))` |
| `584.x` | Any defined subcode of 584 | `expand9("584")` |
| `140.xx–172.xx` | All codes from 140 through 172 | `range9("140", "172")` |
| `280.0, 280.1, 280.8` | Explicit comma-separated list | Parse with `gsub("\\.","", ...)` on each element |
| `'I63.xx'` | Any defined subcode of I63 | `expand10("I63")` |
| `I20.0, I24.0` | Explicit ICD-10 codes (already short format without periods) | Use as-is after removing quotes and periods |
| `'0210.xx'` | ICD-10-PCS procedure code prefix | `expand_pcs("0210xxx")` |
| `'3610'–'3619'` | ICD-9 procedure code range | `range9("3610", "3619")` |
| `33510–33519` | HCPCS code range | `hcpcs_range("33510", "33519")` |

**Critical rule:** ALL codes are stored in **short format** (no decimal periods).
`add_periods_icd()` converts back to decimal format at retrieval time when the
user passes `periods = TRUE`.

**Uppercase X vs lowercase x:** In the document, lowercase `x` is a wildcard
(any digit or letter). Uppercase `X` is a literal placeholder character in
ICD-10-CM (e.g., `E1037X1` is a real code, not a pattern).

### 4.2 Extracting explicit comma-separated code lists

Many condition definitions list codes inline in a paragraph:

```r
# Example paragraph text:
# "ICD-9 code of 280.0, 280.1, 280.8, 280.9, 281.0 ..."

parse_doc_icd <- function(txt) {
  raw   <- trimws(strsplit(sub("\\.$", "", txt), ",")[[1]])
  codes <- gsub("\\.", "", raw)       # remove periods to get short format
  codes[nchar(codes) > 0]
}
```

### 4.3 Extracting quoted codes from a paragraph

When codes are wrapped in single quotes in the document text:

```r
raw   <- texts[paragraph_index]
hits  <- regmatches(raw, gregexpr("'[A-Z0-9]+'", raw))[[1]]
codes <- unique(gsub("'", "", hits))
```

Watch for **typos in the document** — e.g., `I701'` (missing opening quote).
In those cases, add the code manually with a comment:

```r
codes <- unique(c(codes, "I701"))   # I701 present in doc (missing opening quote)
```

### 4.4 ICD-9 E codes (external cause)

E codes (E880–E888 for falls, E810–E829 for motor vehicle accidents) are
standard ICD-9-CM diagnosis codes. Expand them like any other ICD-9 code:

```r
fall_e_codes <- unique(c(
  expand9("8800"), expand9("8801"), ..., expand9("8889")
))
```

Note: `range9("8800", "8889")` may fail if not all codes in the range are
defined. Expand individual parent codes instead.

### 4.5 ICD-10-PCS procedure codes

ICD-10-PCS codes are 7 characters. The document uses `xxx` as a 3-character
wildcard suffix (e.g., `0210xxx`). Expand using the bundled FY2026 reference:

```r
chd_proc_icd10 <- expand_pcs(c("0210xxx", "0211xxx", "0212xxx", "0213xxx"))
```

`expand_pcs()` is exported from the package and uses `pcs_codes` stored in
`R/sysdata.rda`. To update `pcs_codes` for a new fiscal year, run
`data-raw/download_pcs_codes.R` (see that file for full instructions).

### 4.6 HCPCS code ranges

```r
# Helper defined in build_specs.R:
hcpcs_range <- function(a, b) as.character(seq(as.integer(a), as.integer(b)))
hcpcs_range("33510", "33519")   # → c("33510","33511",...,"33519")
```

---

## 5. Interpreting drug definitions

### 5.1 Two definition formats

**Format A — Explicit list (anti-hypertensive medication list):**

```
Thiazide or thiazide-type diuretics
Chlorothiazide
Chlorthalidone
Hydrochlorothiazide
```

Extract by reading lines in the section after the header until the next section
header. Blank lines and class-label lines (no uppercase GNN pattern) are skipped.

**Format B — GNN substring match (FDB format):**

```
If index(upcase(GNN), "ATORVASTATIN")
|index(upcase(GNN), "ATORVAST")
| index(upcase(GNN), "FLUVASTATIN")
```

Extract using regex:

```r
extract_gnns <- function(para_text) {
  m <- gregexpr(
    '(?i)(?:index\\(upcase\\(GNN\\),|upcase\\(GNN\\) in)\\s*["\']([^"\']+)["\']',
    para_text, perl = TRUE
  )
  raw <- regmatches(para_text, m)[[1]]
  gsub('.*["\']([^"\']+)["\'].*', "\\1", raw)
}
```

**Important:** Format B GNNs are **substring search terms**, not exhaustive
enumerations. Any drug whose FDB GNN *contains* the search term qualifies.
The defs text must note this:

```r
defs = "Identified via GNN substring match: any GNN containing the term qualifies..."
```

### 5.2 upcase(GNN) in (...) — exact match list

Some sections use an exact-match form alongside the substring form:

```
|upcase(GNN) in ('ESTROGENS, CONJUGATED', 'ESTROGENS,CONJUGATED', ...)
```

Include all items in the `in (...)` list as additional GNNs.

### 5.3 Special NDC overrides

Some sections specify individual NDC (product service ID) overrides:

```
If PROD_SRVC_ID in ("54569595100") then gnn="AMLODIPINE/ATORVASTATIN";
```

Include the overridden GNN (`AMLODIPINE/ATORVASTATIN`) as an explicit entry and
document the NDC override in the defs text.

### 5.4 Drug exclusion notes

Watch for exclusions embedded in the definition:

```
if index(upcase(GNN), "CLONIDINE") and index(upcase(GNN), "APRACLONIDINE") then htmeds=0;
```

Store the GNN (`CLONIDINE`) and document the exclusion in `defs`:

```r
defs = "... Note: exclude APRACLONIDINE when matching CLONIDINE."
```

---

## 6. The condition/outcome flag system

Every code in a `CodeSpec` carries two logical membership flags, parallel to the
`codes` vector:

```
condition = TRUE   →   code belongs to the history/condition definition
outcome   = TRUE   →   code belongs to the outcome definition
```

A single code can be `condition=TRUE, outcome=TRUE` (appears in both), or just
one of them. This is used when `get_*_codes(variable_type = "condition")` vs
`"outcome"` is called.

**When condition and outcome use identical codes** (common), set both to `TRUE`:

```r
make_key(codes, abbreviated)  # defaults: both TRUE
```

**When only a history (condition) definition exists**, set outcome to `FALSE`:

```r
make_key(codes, abbreviated,
         condition = rep(TRUE,  length(codes)),
         outcome   = rep(FALSE, length(codes)))
```

**When history and outcome use DIFFERENT code sets** (e.g., CHD), union them
and mark each code's membership separately:

```r
all_codes <- union(condition_codes, outcome_codes)
dx_icd9 <- make_key(
  all_codes, abbreviated,
  condition = all_codes %in% condition_codes,
  outcome   = all_codes %in% outcome_codes
)
```

---

## 7. Key-naming convention for CodeSpec codes

Code-set keys follow the pattern `{code_type}` (no encounter suffix):

| Key | Description |
|---|---|
| `dx_icd9` | ICD-9-CM diagnosis codes |
| `dx_icd10` | ICD-10-CM diagnosis codes |
| `proc_icd9` | ICD-9-CM procedure codes (Volume 3) |
| `proc_icd10` | ICD-10-PCS procedure codes |
| `hcpcs` | HCPCS/CPT codes (outpatient) |
| `cpt` | CPT codes (when named separately from HCPCS) |
| `rev` | Revenue center codes |
| `specialty` | Physician specialty codes (document in defs; no ICD representation) |

**There is no encounter-type suffix** (`_inpt`, `_outpt`). The defs text
explains encounter requirements (e.g., "≥1 inpatient OR ≥2 outpatient E&M
claims"). Encounter logic is an analysis-time concern, not a code-set concern.

---

## 8. Step-by-step: adding a new condition

### Step 1 — Find the section in the document

```r
idx <- which(grepl("condition name", texts, ignore.case = TRUE) &
             grepl("version", texts, ignore.case = TRUE) &
             nchar(texts) < 200 &
             !grepl("\\.{5}|……", texts))
i <- tail(idx, 1)   # content section (not the TOC entry)
for (j in i:(i + 20)) {
  txt <- texts[j]
  if (nchar(trimws(txt)) > 0) cat(sprintf("[%4d] %s\n", j, substr(txt, 1, 200)))
}
```

### Step 2 — Extract and expand ICD codes

Identify the code format used (see Section 4) and apply the appropriate
expansion function. Always check the result:

```r
my_icd9  <- expand9("580")
my_icd10 <- c("N181","N182","N183","N184","N185","N186","N189","N19")
cat("ICD-9:", length(my_icd9), "| ICD-10:", length(my_icd10), "\n")
```

### Step 3 — Write the spec in `data-raw/build_specs.R`

Add the new spec **before** the `# Save all specs` section at the bottom:

```r
# ---------------------------------------------------------------------------
# spec_my_condition — My Condition Name
# ---------------------------------------------------------------------------
# Source: "Definition..." Word document, section "My Condition, version 1"

my_icd9  <- ...
my_icd10 <- ...

spec_my_condition <- CodeSpec$new(
  condition = "my_condition",
  label     = "My Condition",
  versions  = list(
    v1 = list(
      defs = list(
        condition = paste0(
          "≥1 inpatient claim with ICD-9 diagnosis of ... or ICD-10 diagnosis of ..."
        ),
        outcome = NULL   # or paste0(...) if an outcome definition exists
      ),
      codes = list(
        dx_icd9  = make_key(
          my_icd9,  c("580.xx-588.xx"),   # abbreviated form for display
          condition = rep(TRUE, length(my_icd9)),
          outcome   = rep(FALSE, length(my_icd9))
        ),
        dx_icd10 = make_key(
          my_icd10, my_icd10             # ICD-10 often already specific; use as-is
        )
      )
    )
  )
)
```

### Step 4 — Add to `usethis::use_data()` at the bottom of build_specs.R

```r
usethis::use_data(
  ...,
  spec_my_condition,
  overwrite = TRUE
)
```

### Step 5 — Run `build_specs.R`

```r
if ("package:peridefs" %in% search()) detach("package:peridefs", unload = TRUE)
devtools::load_all(".", quiet = TRUE)
source("data-raw/build_specs.R")
```

**Always detach + reload before sourcing.** R6 private methods are copied into
each instance at creation time. If you modify a class and rebuild without
reloading, old instances (from the previous `.rda` files) still use the old
method code.

### Step 6 — Add wrapper functions to `R/conditions.R`

Append to the end of `conditions.R`:

```r
# ---- My Condition -------------------------------------------------------

#' Retrieve ICD codes for my condition
#'
#' @description
#' Returns code sets from the my condition [CodeSpec] (`spec_my_condition`).
#'
#' @inheritParams get_htn_codes
#' @seealso [get_my_condition_defs()], \code{spec_my_condition}
#' @export
get_my_condition_codes <- function(version       = "latest",
                                   code_type     = NULL,
                                   variable_type = c("condition", "outcome"),
                                   periods       = FALSE,
                                   format        = c("list", "tibble")) {
  get_codes(spec_my_condition, version, code_type, match.arg(variable_type),
            periods, match.arg(format))
}

#' Retrieve the narrative algorithm description for my condition
#' @inheritParams get_htn_defs
#' @seealso [get_my_condition_codes()], \code{spec_my_condition}
#' @export
get_my_condition_defs <- function(version       = "latest",
                                  variable_type = c("condition", "outcome")) {
  get_defs(spec_my_condition, version, match.arg(variable_type))
}
```

### Step 7 — Add the spec name to `utils::globalVariables()` in `R/peridefs-package.R`

```r
utils::globalVariables(c(
  ...,
  "spec_my_condition"
))
```

### Step 8 — Reload, test, and check

```r
if ("package:peridefs" %in% search()) detach("package:peridefs", unload = TRUE)
devtools::load_all(".", quiet = TRUE)

# Quick sanity check
spec_my_condition
get_my_condition_codes()
get_my_condition_defs()

# Full test suite
devtools::test()

# R CMD check
devtools::check()
```

---

## 9. Step-by-step: adding a new drug class

### Step 1 — Find the section and extract GNNs

```r
idx <- which(grepl("drug class name", texts, ignore.case = TRUE) &
             !grepl("\\.{5}|……", texts))
i <- tail(idx, 1)
for (j in i:(i + 20)) {
  txt <- texts[j]
  if (nchar(trimws(txt)) > 0) cat(sprintf("[%4d] %s\n", j, texts[j]))
}
```

Determine which format is used (Section 5.1) and collect GNNs accordingly.

### Step 2 — Write the DrugSpec in `data-raw/build_specs.R`

```r
# ---------------------------------------------------------------------------
# spec_my_drug — My Drug Class
# ---------------------------------------------------------------------------
spec_my_drug <- DrugSpec$new(
  drug_class = "my_drug",
  label      = "My Drug Class",
  versions   = list(
    v1 = list(
      defs          = "From the Perisphere definitions document. GNNs: DRUGONE, DRUGTWO.",
      generic_names = c("DRUGONE", "DRUGTWO"),
      ndc           = character(0L)    # empty until NDC data is available
    )
  )
)
```

If the document lists a v2 from FDB with additional/variant GNNs, use
`drug_spec_v1v2()` helper (already defined in `build_specs.R`):

```r
spec_my_drug <- drug_spec_v1v2(
  "my_drug", "My Drug Class",
  defs_v1 = "From anti-hypertensive medication list.",
  gnns_v1 = c("DRUGONE"),
  defs_v2 = "From FDB. Adds DRUGONE_VARIANT.",
  gnns_v2 = c("DRUGONE", "DRUGONE_VARIANT")
)
```

### Step 3 — Add to `use_data()`, add wrappers, globalVariables, reload, test

Append to `R/drugs.R`:

```r
#' Retrieve generic drug names for my drug class
#' @param version Version to use. Defaults to `"latest"`.
#' @seealso \code{spec_my_drug}
#' @export
get_my_drug_generics <- function(version = "latest") get_generics(spec_my_drug, version)

#' Retrieve NDC codes for my drug class
#' @param version Version to use. Defaults to `"latest"`.
#' @export
get_my_drug_codes <- function(version = "latest") get_ndc(spec_my_drug, version)

#' Retrieve the narrative description for my drug class
#' @param version Version to use. Defaults to `"latest"`.
#' @export
get_my_drug_defs <- function(version = "latest") get_defs(spec_my_drug, version)
```

---

## 10. Creating composite specs

### CompositeCodeSpec (condition whose codes = union of other conditions)

Use when the document defines a condition as "defined by a history of X or Y or Z":

```r
spec_my_composite <- CompositeCodeSpec$new(
  condition = "my_composite",
  label     = "My Composite Condition",
  versions  = list(
    v1 = list(
      defs = list(
        condition = "History of condition A or condition B.",
        outcome   = "Event of condition A or condition B."
      ),
      components = list(
        # condition: which component specs and variable_type to draw from
        condition = list(
          a = comp(spec_a, variable_type = "condition"),
          b = comp(spec_b, variable_type = "condition")
        ),
        # outcome: can use DIFFERENT specs from condition (e.g. ASCVD v2)
        outcome = list(
          a = comp(spec_a, variable_type = "outcome"),
          b = comp(spec_b, variable_type = "outcome")
        )
      )
    )
  )
)
```

**Key design decision:** The condition and outcome component lists CAN differ.
For ASCVD v2, the history definition uses cerebrovascular disease but the
outcome uses stroke — different specs for condition vs outcome. Always check
the document carefully to see if this applies.

### CompositeDrugSpec (drug class = union of sub-classes)

```r
spec_my_drug_composite <- CompositeDrugSpec$new(
  drug_class = "my_drug_composite",
  label      = "My Drug Composite",
  versions   = list(
    v1 = list(
      defs       = "Union of sub-classes.",
      components = list(
        sub_a = comp(spec_sub_a, "v1"),
        sub_b = comp(spec_sub_b, "v1")
      )
    )
  )
)
```

The `comp()` helper (defined in `build_specs.R`) builds a component descriptor:

```r
comp <- function(spec, version = "latest") list(spec = spec, version = version)
```

---

## 11. Versioning rules

- Use `v1`, `v2`, `v3` as version keys (not integers).
- The document signals version differences with "(with medications)", "(without
  medications)", "from anti-hypertensive medication list", "from FDB", etc.
- When v1 and v2 codes are identical, store one version only.
- When the only difference between versions is the narrative algorithm (not the
  code set itself — e.g., diabetes v1 vs v2), store the same codes in both
  versions but with different `defs` text.
- `"latest"` resolves to the highest-numbered version key.

---

## 12. Narrative defs text guidelines

- Always capture the key algorithm parameters: minimum number of claims (≥1 vs
  ≥2), file types (inpatient, outpatient, carrier, SNF, HHA), position
  (primary, any, discharge), minimum days apart, look-back window.
- Reference other specs by name where applicable:
  `"... see spec_antihypertensive for the medication list."`
- For definitions that can't be represented as code sets (BETOS codes, discharge
  status codes, Medicaid enrollment flags), set `codes = list()` and put the
  full algorithm in `defs`.
- Use `\u2265` for ≥ and `\u2264` for ≤ in defs strings (avoids encoding issues).

---

## 13. What to skip

Some TOC items are not representable as code/drug specs:

| Item | Reason |
|---|---|
| Destitution | Medicaid enrollment flags (not medical codes) |
| High adherence | Medication possession ratio (MPR) algorithm |
| Statin intolerance | Drug adherence/switching counting algorithm |
| Frailty | Weighted ICD score requiring coefficient tables |
| Very high-risk ASCVD | Event-counting logic (implement as CompositeCodeSpec for codes only; document counting in defs) |
| Cardiologist/Nephrology/ Neurology/Pulmonary/ Primary care/Geriatrics ambulatory visits | Physician specialty codes — store the E&M HCPCS codes from `spec_hcpcs_em` in the code set and document the specialty code in defs |
| Dialysis | BETOS codes — store empty code set, document in defs |
| Discharge to hospice/SNF | Discharge status codes — not medical codes |

---

## 14. Common pitfalls

### Pitfall 1: R6 private methods copied at instantiation

If you change a class definition (e.g., fix a bug in `get_codes_impl`), you
**must** detach the package, reload, and re-run `build_specs.R` to create new
spec objects. Old `.rda` instances carry the old method code.

### Pitfall 2: `range9()` / `range10()` failing on undefined endpoints

These functions use `icd::expand_range()` with `defined = TRUE`. If either
endpoint is not in the ICD reference database, the call errors. Fall back to
individual `expand9()` calls on parent codes.

### Pitfall 3: Abbreviated vs. codes not parallel

The `abbreviated` field is a **compact display representation**, not a
per-code parallel vector. There are usually far fewer abbreviated strings than
expanded codes. Storing the wrong thing here does not affect functionality
(users retrieve from `codes`), but the `$print()` method uses `abbreviated`
for display.

### Pitfall 4: Forgetting to add to `use_data()`

Every new `spec_*` object must appear in the `usethis::use_data(...)` call at
the bottom of `build_specs.R`. Omitting it means the `.rda` file is never
created and the object won't be available to users.

### Pitfall 5: Forgetting `globalVariables()`

All `spec_*` names referenced in wrapper functions must be listed in
`utils::globalVariables()` in `R/peridefs-package.R`. Omitting one causes a
NOTE in `R CMD check`.

### Pitfall 6: `@seealso [spec_X]` links break R CMD check

`spec_*` objects are package data, not function topics, so they cannot be
hyperlinked with `[spec_X]` syntax in roxygen. Use `\code{spec_X}` instead.

---

## 15. Quick reference: R session variables

After loading the Word document (Section 2), the following session variables
are available:

| Variable | Type | Description |
|---|---|---|
| `texts` | character | One element per document paragraph, in order |
| `doc` | xml_document | Parsed `word/document.xml` |
| `ns` | xml_namespace | Namespace map for XPath queries |
| `paras` | xml_nodeset | All `<w:p>` paragraph nodes |
| `toc_entries` | character | First 115 TOC entry strings (set during development) |

Key search idiom:

```r
# Find all sections mentioning a condition, excluding TOC dot-leader lines
idx <- which(
  grepl("my search term", texts, ignore.case = TRUE) &
  nchar(texts) < 200 &
  !grepl("\\.{5}|……", texts)
)
# Content section = last match (earlier matches are TOC entries)
i <- tail(idx, 1)
```

---

## 16. File map

| File | Purpose |
|---|---|
| `data-raw/build_specs.R` | **Main build script.** Add new spec definitions here, then run it. |
| `data-raw/download_pcs_codes.R` | Downloads FY ICD-10-PCS reference from CMS. Run when updating fiscal year. |
| `data-raw/parse_docx.R` | Helper functions for reading the Word document XML. |
| `R/CodeSpec.R` | R6 class for condition code specs. |
| `R/DrugSpec.R` | R6 class for drug class specs. |
| `R/CompositeCodeSpec.R` | R6 class for composite condition specs. |
| `R/CompositeDrugSpec.R` | R6 class for composite drug specs. |
| `R/conditions.R` | All exported `get_*_codes()` and `get_*_defs()` wrapper functions. |
| `R/drugs.R` | All exported `get_*_generics()`, `get_*_codes()`, `get_*_defs()` drug wrappers. |
| `R/utils.R` | Internal helpers: `resolve_version()`, `parse_key()`, `add_periods_icd()`. |
| `R/expand_pcs.R` | Exported `expand_pcs()` for ICD-10-PCS expansion. |
| `R/peridefs-package.R` | Package-level docs, `@importFrom`, `utils::globalVariables()`. |
| `R/specs_data.R` | Roxygen documentation for all `spec_*` package data objects. |
| `R/code_spec_api.R` | Exported user API: `code_spec()`, `drug_spec()`, `add_codes()`, `remove_codes()`, `modify_code_spec()`, `modify_drug_spec()`. |
| `R/get_codes.R` | Internal `get_codes()` dispatcher. |
| `R/get_defs.R` | Internal `get_defs()` dispatcher. |
| `R/get_generics.R` | Internal `get_generics()` dispatcher. |
| `R/get_ndc.R` | Internal `get_ndc()` dispatcher. |
| `data/spec_*.rda` | Pre-built spec objects (one file per spec). |
| `R/sysdata.rda` | Internal: `pcs_codes` (79,115 valid ICD-10-PCS codes, FY2026). |
| `tests/testthat/` | Test files. Run `devtools::test()` after every change. |

---

## 17. Expanding `generic_names` using claims data (mc_gnrc)

The base document often lists only root generic names (e.g., `"LISINOPRIL"`),
but the `mc_gnrc` reference table — available as a two-column data frame in
the R session with columns `GNRC_NM` (character) and `n` (integer claim count)
— contains many salt forms, formulation variants, and fixed-dose combinations
that also belong in the spec. This section documents the search-and-add
process used to expand existing specs.

### 17.1 When to run this process

Run this process when:
- A new drug spec has just been added from the Word document.
- The `mc_gnrc` table has been refreshed (new claims data added).
- A spot-check reveals that a known variant (e.g., `ATORVASTATIN CALCIUM`) is
  not in the spec but exists in `mc_gnrc`.

### 17.2 Step 1 — Extract existing keywords

Pull the current `generic_names` from the latest version of the target spec.
For multi-version specs (v1/v2), **only update the latest version**.

```r
library(stringr)
library(dplyr)

keywords <- c("LISINOPRIL", "ENALAPRIL", ...)   # current generic_names entries
pattern  <- str_c(keywords, collapse = "|")
```

For specs that use the `antidiab_gnns` list pattern, extract keywords directly
from that list instead.

### 17.3 Step 2 — Search mc_gnrc

Find all `GNRC_NM` values that contain any keyword, excluding entries already
in the spec:

```r
mc_gnrc |>
  filter(str_detect(GNRC_NM, regex(pattern, ignore_case = TRUE))) |>
  distinct(GNRC_NM) |>
  filter(!GNRC_NM %in% keywords) |>
  arrange(GNRC_NM) |>
  print(n = Inf)
```

For large composite specs, group results by sub-class by building a keyword
list per sub-spec and running the query once per sub-spec.

### 17.4 Step 3 — Decide what to include

Apply the rules below. When in doubt, do a web search to verify that a
candidate GNN is genuinely in the target drug class.

**Always add:**
- Salt and formulation variants of existing generics
  (e.g., `LISINOPRIL` → `LISINOPRIL HCL`, `ENALAPRIL` → `ENALAPRIL MALEATE`).
- Fixed-dose combinations where the spec's drug is the primary component
  (e.g., `LISINOPRIL/HYDROCHLOROTHIAZIDE` for the ACEI spec).
- Biosimilar-suffix forms (e.g., `INSULIN ASPART-SZJJ`).
- Historical/withdrawn drugs when the spec is meant to capture historical claims
  (e.g., `ALBIGLUTIDE`, `LORCASERIN HCL`).

**Exclude:**
- Combinations where the target drug is not the primary component
  (e.g., `AMLODIPINE/ATORVASTATIN` from a CCB spec — atorvastatin is a statin).
- Topical, ophthalmic, or other formulations for a different indication
  (e.g., `MINOXIDIL/FINASTERIDE` for hair loss; `APRACLONIDINE HCL` for glaucoma).
- IV infusion bags primarily indicated for a different condition
  (e.g., `DILTIAZEM HCL IN 0.9% NACL` is for arrhythmia, not hypertension).
- Drugs sharing a mechanism keyword but with a different primary indication
  (e.g., `SACUBITRIL/VALSARTAN` for heart failure, not hypertension;
  `SOTAGLIFLOZIN` approved for heart failure, not T2D).
- Supplement or compounded products with non-drug fillers
  (e.g., `BUPROPION HCL/DIET SUPP. NO.15`; `METFORMIN/BLOOD SUGAR DIAGNOST`).
- Blood glucose meters and other diagnostic devices (e.g., `BLOOD GLUC MTR/...`).

**Combination products that span two sub-specs within the same composite:**
Assign to exactly one sub-spec — the one whose component is the most clinically
distinctive. Do not duplicate across sub-specs.

```
# Example: AMLODIPINE BESYLATE/VALSARTAN
# → ARB sub-spec (valsartan is the distinctive antihypertensive component)
# → NOT the CCB sub-spec
```

### 17.5 Step 4 — Check for cross-spec overlaps

After editing `build_specs.R`, confirm no `GNRC_NM` appears in more than one
distinct sub-spec class. Overlaps within v1/v2 pairs of the same class are
expected and fine.

```r
lines       <- readLines("data-raw/build_specs.R")
spec_starts <- which(str_detect(lines, "DrugSpec\\$new\\(") &
                     !str_detect(lines, "CompositeDrugSpec\\$new\\("))
spec_names  <- str_extract(lines[spec_starts], "^(\\w+)\\s*<-") |>
  str_remove("\\s*<-")

extract_generics <- function(start_line, all_lines) {
  depth <- 0; block_end <- NA
  for (i in start_line:min(start_line + 200, length(all_lines))) {
    depth <- depth +
      str_count(str_replace_all(all_lines[i], '"[^"]*"', ""), fixed("(")) -
      str_count(str_replace_all(all_lines[i], '"[^"]*"', ""), fixed(")"))
    if (i > start_line && depth <= 0) { block_end <- i; break }
  }
  if (is.na(block_end)) return(character(0))
  window      <- all_lines[start_line:block_end]
  block_start <- which(str_detect(window, "generic_names\\s*=\\s*c\\("))
  if (length(block_start) == 0) return(character(0))
  chunk  <- window[block_start[1]:length(window)]
  depth2 <- 0; end <- NA
  for (i in seq_along(chunk)) {
    depth2 <- depth2 +
      str_count(str_replace_all(chunk[i], '"[^"]*"', ""), fixed("(")) -
      str_count(str_replace_all(chunk[i], '"[^"]*"', ""), fixed(")"))
    if (i > 1 && depth2 <= 0) { end <- i; break }
  }
  if (is.na(end)) return(character(0))
  str_extract_all(paste(chunk[1:end], collapse = " "), '"[^"]+"')[[1]] |>
    str_remove_all('"')
}

specs    <- set_names(map(spec_starts, extract_generics, all_lines = lines), spec_names)
specs    <- keep(specs, ~ length(.) > 0)
all_vals <- imap(specs, ~ tibble(spec = .y, generic = .x)) |> list_rbind()

all_vals |>
  group_by(generic) |>
  filter(n() > 1) |>
  filter(n_distinct(str_remove(spec, "_v[0-9]+$")) > 1) |>
  arrange(generic, spec)
```

Resolve any unexpected overlaps before proceeding.

### 17.6 Step 5 — Annotate with MC Rx claim counts

Add a `# n=X in MC Rx table` comment next to each `generic_names` entry that
appears in `mc_gnrc`. This makes it immediately visible which entries match
claims data and how frequently.

The script below is idempotent: re-running updates counts in place and appends
count info to any pre-existing non-count comment
(e.g., `# legacy/typo form; n=X in MC Rx table`).

```r
library(stringr)

gnrc_lookup <- setNames(mc_gnrc$n, mc_gnrc$GNRC_NM)
fmt_n <- function(n) format(n, big.mark = ",", scientific = FALSE, trim = TRUE)
lines <- readLines("data-raw/build_specs.R")

uparen <- function(s) {
  s2 <- str_replace_all(s, '"[^"]*"', "")
  str_count(s2, fixed("(")) - str_count(s2, fixed(")"))
}
trailing_comment <- function(s) {
  qs <- str_locate_all(s, '"')[[1]]
  if (nrow(qs) < 2L) return(NA_character_)
  lq <- max(qs[, 2L]); suf <- substr(s, lq + 1L, nchar(s))
  m  <- str_locate(suf, "#")[1L, 1L]
  if (is.na(m)) return(NA_character_)
  str_trim(substr(suf, m, nchar(suf)))
}
strip_comment <- function(s) {
  qs <- str_locate_all(s, '"')[[1]]
  if (nrow(qs) < 2L) return(s)
  lq <- max(qs[, 2L]); suf <- substr(s, lq + 1L, nchar(s))
  m  <- str_locate(suf, "#")[1L, 1L]
  if (is.na(m)) return(s)
  str_trim(substr(s, 1L, lq + m - 1L), "right")
}

# Narrow pattern: only generic_names blocks and antidiab list sub-vectors.
# Do NOT use a broad '= c(' pattern -- it will corrupt ICD code vectors.
DRUG_CLASS_NAMES <- paste(
  c("biguanide", "sulfonylurea", "meglitinide", "tzd", "alpha_glucosidase",
    "dpp4", "sglt2", "glp1", "insulin", "amylin"),
  collapse = "|"
)
BLOCK_PAT <- paste0(
  "generic_names\\s*=\\s*c\\(",
  "|",
  "^\\s*(", DRUG_CLASS_NAMES, ")\\s*=\\s*c\\("
)

in_block <- FALSE; depth <- 0L
out <- vector("list", length(lines) + 600L); oi <- 0L
push <- function(x) { oi <<- oi + 1L; out[[oi]] <<- x }

for (line in lines) {
  is_start <- str_detect(line, BLOCK_PAT)
  pd       <- uparen(line)
  if (!in_block && !is_start) { push(line); next }
  if (!in_block) {
    depth <- pd; in_block <- (depth > 0L)
  } else {
    depth <- depth + pd
    if (depth <= 0L) in_block <- FALSE
  }
  line_nc <- strip_comment(line)
  strs    <- str_extract_all(line_nc, '"([^"]*)"')[[1L]] |> str_sub(2L, -2L)
  if (length(strs) == 0L) { push(line); next }
  masked      <- str_replace_all(line_nc, '"[^"]*"', "")
  close_comma <- str_detect(masked, "\\),\\s*$")
  indent      <- str_extract(line_nc, "^\\s*")
  emit_close  <- (is_start && pd <= 0L) || (!is_start && pd < 0L)
  if (length(strs) == 1L) {
    gnn <- strs[[1L]]
    if (gnn %in% names(gnrc_lookup)) {
      ec  <- trailing_comment(line)
      cmt <- if (!is.na(ec) && !str_detect(ec, "n=[0-9,]+ in MC Rx table"))
               paste0("  ", ec, "; n=", fmt_n(gnrc_lookup[[gnn]]), " in MC Rx table")
             else
               paste0("  # n=", fmt_n(gnrc_lookup[[gnn]]), " in MC Rx table")
      push(paste0(line_nc, cmt))
    } else { push(line) }
  } else {
    if (is_start) {
      prefix     <- str_extract(line_nc, "^.*=\\s*c\\(")
      str_indent <- paste0(str_extract(prefix, "^\\s*"), "  ")
      push(prefix)
    } else { str_indent <- indent }
    for (j in seq_along(strs)) {
      gnn   <- strs[[j]]
      sline <- paste0(str_indent, '"', gnn, '",');
      if (gnn %in% names(gnrc_lookup))
        sline <- paste0(sline, "  # n=", fmt_n(gnrc_lookup[[gnn]]), " in MC Rx table")
      push(sline)
    }
    if (emit_close) push(paste0(indent, if (close_comma) ")," else ")"))
  }
}
writeLines(unlist(out[seq_len(oi)]), "data-raw/build_specs.R")
```

**Notes on interpreting annotations:**
- Entries with **no comment** are not found in `mc_gnrc` under that exact string.
  The drug may exist under a different spelling or salt form.
- The narrow `BLOCK_PAT` prevents accidental annotation of ICD code lists,
  narrative defs text, or other `= c(...)` vectors in the file.

### 17.7 Documenting completed work

After finishing a drug class, record it in `AGENTS.md` so future sessions
know not to re-run the search unnecessarily:

```markdown
| Drug class | Spec(s) updated | Notes |
|---|---|---|
| Statins | `spec_ll_statin_v1` | Salt forms; NIACIN/statin combos added |
```

---

## 18. Updating the Word document

When the definitions document is updated (e.g., `Definition of conditions and
medications_11262026.docx`):

1. Update the `docx_path` at the top of `data-raw/build_specs.R` and in
   `data-raw/parse_docx.R`.
2. Reload the `texts` vector into the R session (Section 2).
3. For each changed definition, find the new section content, update the code
   expansion and defs text in `build_specs.R`.
4. If the ICD-10-PCS fiscal year has changed, run `data-raw/download_pcs_codes.R`
   first to update `R/sysdata.rda`.
5. Re-run `build_specs.R`, reload, run tests, run check.

The fidelity tests (`tests/testthat/test-spec_fidelity.R`, when implemented)
will automatically verify that stored specs match the document — run those
after any document update.
