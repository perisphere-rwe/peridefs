# Antiobesity medications ---------------------------------------------------
# Sourced by data-raw/build_specs.R; do not source on its own.
# Runs in its own environment: every object defined here is local to this
# file, and only `spec_*` objects are passed on to later files.

## Antiobesity medication components ----

# Priority tiers reviewed (2026-08-23): every generic here (appetite
# suppressants, orlistat, naltrexone/bupropion, phentermine/topiramate,
# setmelanotide) has obesity/weight-management as its only FDA-approved
# indication, so all remain priority 1; no probable/cautious tier needed.
spec_non_glp1_v1 <- DrugSpec$new(
  'non_glp1', "Antiobesity (non GLP-1)",
  version = 'v1',
  defs = "From the Perisphere antiobesity (non GLP-1) medication list.",
  generic_names = c(
    "BENZPHETAMINE HCL",  # n=116,290 in MC Rx table
    "DIETHYLPROPION HCL",  # n=1,028,425 in MC Rx table
    "LORCASERIN HCL",  # n=2,034,254 in MC Rx table
    "NALTREXONE HCL/BUPROPION HCL",  # n=5,046,258 in MC Rx table
    "ORLISTAT",  # n=406,726 in MC Rx table
    "PHENDIMETRAZINE TARTRATE",  # n=1,412,570 in MC Rx table
    "PHENTERMINE HCL",  # n=44,810,003 in MC Rx table
    "PHENTERMINE RESIN",  # n=138 in MC Rx table
    "PHENTERMINE/TOPIRAMATE",  # n=3,187,485 in MC Rx table
    "SETMELANOTIDE ACETATE"  # n=14,433 in MC Rx table
  )
)

# Dual-indication GLP-1s: separate brand names cover T2D and chronic weight
# management, so each GNN spans both the antidiabetic and antiobesity classes
# (e.g., Ozempic/T2D vs. Wegovy/weight for SEMAGLUTIDE). Priority 2 (probable)
# in both specs.
# Shared across the antiobesity and antidiabetic composites (2026-08-15):
# previously two separate DrugSpec objects (spec_glp1_v1 here and
# spec_antidiab_glp1_v1, defined near the antidiabetic components) listed
# these generics independently, with independently-maintained priority
# tiers and brand names — a duplication/drift risk. Now a single spec
# carries every generic's priority/brand *per condition* via generic_defs;
# spec_obesity and spec_diabetes both reference this one object as
# their "glp1_v1" component, and each composite's own `condition` field
# filters it down to the relevant rows automatically.
#
# RESOLVED (2026-08-15): EXENATIDE EXTENDED-RELEASE previously only had an
# "obesity" row, matching a pre-merge asymmetry between the two original
# specs (present in the old obesity spec's cautious list but absent from
# the old diabetes spec's generic list). Confirmed via FDA labeling that
# it (Bydureon) is indicated as an adjunct to diet/exercise to improve
# glycemic control in adults with T2D, no obesity indication — the same
# profile as its sibling formulations EXENATIDE and EXENATIDE
# MICROSPHERES, which already have diabetes/priority-1 rows below. Added
# the missing diabetes row to match.
spec_glp1_v1 <- DrugSpec$new(
  'glp1', "GLP-1",
  version = 'v1',
  defs = "GLP-1 receptor agonists, shared across the antiobesity and antidiabetic composites.",
  # @BKB: please review the six condition = "obesity", priority = 3L rows
  # below (ALBIGLUTIDE, DULAGLUTIDE, EXENATIDE, EXENATIDE EXTENDED-RELEASE,
  # EXENATIDE MICROSPHERES, LIXISENATIDE). Per the priority-tier definition
  # (P3 = indicated for the condition, alone or with others, but only
  # outside the US), none of these six appears to have ever had an
  # obesity/weight-management indication in any country -- they're T2D-only
  # drugs used off-label for weight loss. If so, none of these tiers
  # actually applies; per the package's own exclusion rules these rows
  # should probably be dropped from the obesity condition entirely rather
  # than tagged priority 3. Flagging for manual confirmation rather than
  # changing unilaterally.
  # Sources:
  #   - https://pmc.ncbi.nlm.nih.gov/articles/PMC12668848/ ("Dulaglutide was
  #     approved ... for T2DM but not for weight loss"; "Lixisenatide ...
  #     lacks FDA approval for weight management"; albiglutide approved only
  #     "as adjunct therapy for glycemic control in T2DM")
  #   - https://www.medcentral.com/meds/which-glp-1-agonist-if-any-is-right-for-my-patient
  #     ("dulaglutide's use remains limited to patients with T2D ... The
  #     drug's manufacturer has announced no existing plans for expanded
  #     indications"; exenatide "indicated to improve glycemic control ...
  #     This agent has no established effects on other organ systems")
  generic_defs = tibble::tribble(
    ~generic,                      ~priority, ~condition,        ~brand,
    "LIRAGLUTIDE",                 2L,        "obesity",         "Saxenda",
    "LIRAGLUTIDE",                 2L,        "diabetes_type2",  "Victoza",
    "SEMAGLUTIDE",                 2L,        "obesity",         "Wegovy",
    "SEMAGLUTIDE",                 2L,        "diabetes_type2",  "Ozempic",
    "TIRZEPATIDE",                 2L,        "obesity",         "Zepbound",
    "TIRZEPATIDE",                 2L,        "diabetes_type2",  "Mounjaro",
    "ALBIGLUTIDE",                 3L,        "obesity",         NA,  # @BKB: see note above tribble -- no obesity indication found anywhere
    "ALBIGLUTIDE",                 1L,        "diabetes_type2",  NA,
    "DULAGLUTIDE",                 3L,        "obesity",         NA,  # @BKB: see note above tribble -- no obesity indication found anywhere
    "DULAGLUTIDE",                 1L,        "diabetes_type2",  NA,
    "EXENATIDE",                   3L,        "obesity",         NA,  # @BKB: see note above tribble -- no obesity indication found anywhere
    "EXENATIDE",                   1L,        "diabetes_type2",  NA,
    "EXENATIDE EXTENDED-RELEASE",  3L,        "obesity",         NA,  # @BKB: see note above tribble -- no obesity indication found anywhere
    "EXENATIDE EXTENDED-RELEASE",  1L,        "diabetes_type2",  NA,
    "EXENATIDE MICROSPHERES",      3L,        "obesity",         NA,  # @BKB: see note above tribble -- no obesity indication found anywhere
    "EXENATIDE MICROSPHERES",      1L,        "diabetes_type2",  NA,
    "LIXISENATIDE",                3L,        "obesity",         NA,  # @BKB: see note above tribble -- no obesity indication found anywhere
    "LIXISENATIDE",                1L,        "diabetes_type2",  NA,
    "INSULIN DEGLUDEC/LIRAGLUTIDE",  1L, "diabetes_type2",  NA,
    "INSULIN GLARGINE/LIXISENATIDE", 1L, "diabetes_type2",  NA
  )
)
# Rx counts (for reference): LIRAGLUTIDE n=37,296,377; SEMAGLUTIDE
# n=140,453,217; TIRZEPATIDE n=79,868,142; ALBIGLUTIDE n=1,136,292
# (Tanzeum, withdrawn 2018 — retained for historical claims capture);
# DULAGLUTIDE n=64,108,557; EXENATIDE n=2,709,695; EXENATIDE MICROSPHERES
# n=8,332,389; LIXISENATIDE n=16,469; INSULIN DEGLUDEC/LIRAGLUTIDE
# n=796,110; INSULIN GLARGINE/LIXISENATIDE n=2,515,845.

## Antiobesity medication compositions ----

spec_obesity <- CompositeDrugSpec$new(
  drug_class = "antiobesity",
  label      = "Antiobesity Medications",
  defs       = "Antiobesity medication subclasses (v1): non-GLP-1 agents and GLP-1 receptor agonists.",
  condition  = "obesity",
  components = list(
    non_glp1_v1 = spec_non_glp1_v1,
    glp1_v1     = spec_glp1_v1
  )
)
