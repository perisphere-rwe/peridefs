## Build script: create and save all peridefs spec objects.
## Run via: source("data-raw/build_specs.R"), ideally in a fresh R session.
##
## Each condition and drug group has its own script under data-raw/specs/:
##
##   specs/_helpers.R      shared helpers (ICD expansion, make_key(), ...)
##   specs/conditions/*.R  one file per condition, holding every version of it
##   specs/drugs/*.R       one file per medication group (leaf specs + composite)
##
## Every spec script runs in its own environment. Intermediate objects (code
## vectors, etc.) stay local to that script; only objects whose names start
## with `spec_` are copied into the global environment, where later scripts
## (and usethis::use_data() below) can see them. Two scripts defining the same
## `spec_*` name is an error.
##
## Released versions read their exact codes from data-raw/codesets/*.csv
## (see read_codeset() in specs/_helpers.R). New versions are derived with
## expand9()/expand10()/range9()/range10(), which use the CMS ICD-10-CM order
## file and data-raw/reference/icd9cm_hierarchy.csv. The icd package is no
## longer needed.

library(tidyverse)
devtools::load_all()

source("data-raw/specs/_helpers.R")

# ---- Spec scripts, in dependency order --------------------------------------
#
# A script may use `spec_*` objects from scripts listed above it. To add a
# condition or drug group, create its file and add it here.

build_scripts <- c(
  # Conditions
  "conditions/obesity.R",
  "conditions/hypertension.R",
  "conditions/chd.R",
  "conditions/stroke.R",
  "conditions/lead_pad.R",
  "conditions/cerebrovasc_disease.R",
  "conditions/ascvd.R",               # needs the four ASCVD components above
  "conditions/hf.R",
  "conditions/depression.R",
  "conditions/diabetes.R",
  "conditions/ckd.R",
  "conditions/osa.R",
  "conditions/ohs.R",
  "conditions/hyperlipidemia.R",
  "conditions/copd.R",
  "conditions/asthma.R",
  "conditions/osteoarthritis.R",
  # Medications
  "drugs/obesity.R",
  "drugs/depression.R",
  "drugs/hypertension.R",
  "drugs/diabetes.R",                 # needs spec_glp1_v1 from drugs/obesity.R
  "drugs/hyperlipidemia.R"
)

# Source one spec script in its own environment and copy its `spec_*`
# objects into `target`. Returns the names of the specs it created.
source_spec_script <- function(file, target = globalenv(), seen = character()) {
  env   <- new.env(parent = target)
  # Parse as UTF-8 explicitly so non-ASCII text (e.g. em dashes in defs)
  # is read correctly regardless of the session's native encoding.
  exprs <- parse(file.path("data-raw", "specs", file), encoding = "UTF-8",
                 keep.source = FALSE)
  for (e in exprs) eval(e, envir = env)
  new_specs <- sort(grep("^spec_", ls(env), value = TRUE))
  clash <- intersect(new_specs, seen)
  if (length(clash)) {
    stop(file, " redefines spec(s) already built by an earlier script: ",
         paste(clash, collapse = ", "), call. = FALSE)
  }
  for (nm in new_specs) assign(nm, get(nm, envir = env), envir = target)
  new_specs
}

built_specs <- character()
for (f in build_scripts) {
  built_specs <- c(built_specs, source_spec_script(f, seen = built_specs))
}
message("Built ", length(built_specs), " spec objects from ",
        length(build_scripts), " scripts.")


## Save all public specs ----
# Only composite specs and standalone leaf specs are saved to data/.
# Component-only specs (leaf specs that are components of a composite) are
# embedded within the composite's .rda file and are NOT saved separately.
# This prevents them from appearing as accessible package datasets.

usethis::use_data(
  # Hypertension
  spec_hypertension_v1,
  # ASCVD composite
  spec_ascvd,
  # Heart failure
  spec_hf_v1,
  spec_hf_v2,
  # Obesity
  spec_obesity_v1,
  # Depression
  spec_depression_v1,
  # Diabetes
  spec_diabetes_type1_v1,
  spec_diabetes_type2_v1,
  spec_diabetes_type2_v2,
  # CKD
  spec_ckd_v1,
  # Sleep apnea
  spec_osa_v1,
  # Obesity hypoventilation syndrome
  spec_ohs_v1,
  # Hyperlipidemia
  spec_hyperlipidemia_v1,
  # COPD
  spec_copd_v1,
  # Asthma
  spec_asthma_v1,
  # Osteoarthritis
  spec_osteoarthritis_v1,
  # Antiobesity (non GLP-1)
  spec_obesity,
  # Antihypertensive composites
  spec_hypertension,
  # Antidiabetic composites
  spec_diabetes_type1,
  spec_diabetes_type2,
  # Antidepressive composite
  spec_depression,
  # Lipid-lowering composite
  spec_hyperlipidemia,
  overwrite = TRUE
)
