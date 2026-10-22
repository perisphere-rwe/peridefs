# Lipid-lowering medications ------------------------------------------------
# Sourced by data-raw/build_specs.R; do not source on its own.
# Runs in its own environment: every object defined here is local to this
# file, and only `spec_*` objects are passed on to later files.

## Lipid-lowering medication components ----

### Statins ----
#
# GNN matching: ATORVASTATIN (incl. AMLODIPINE/ATORVASTATIN combination),
# FLUVASTATIN, LOVASTATIN, PITAVASTATIN, PRAVASTATIN, ROSUVASTATIN, SIMVASTATIN.
# Note: NDC 54569595100 maps to AMLODIPINE/ATORVASTATIN and NDC 55887036990 to
# LOVASTATIN in some pharmacy files; those mappings are handled upstream.

# Priority tiers reviewed (2026-08-23) for all lipid-lowering sub-specs
# below: statins, ezetimibe, PCSK9 inhibitors, fibrates, and niacin also
# carry cardiovascular event risk-reduction claims on their labels, but
# that's treated as an extension of the hyperlipidemia/ASCVD-risk
# indication itself rather than a distinct diagnosed condition (unlike,
# e.g., heart failure or diabetic nephropathy for the antihypertensives
# above), so these remain priority 1. See spec_ll_bile_acid_seq_v1 above
# for the two exceptions found in this drug class (CHOLESTYRAMINE,
# COLESEVELAM).
# @BKB: this CV-risk-reduction-vs-distinct-condition line is more
# subjective than the other tiering calls in this file -- please
# spot-check the statin and PCSK9 inhibitor (spec_ll_pcsk9_v1, below)
# entries in particular. Statins and PCSK9 inhibitors (e.g. EVOLOCUMAB,
# ALIROCUMAB) carry FDA-approved indications for reducing the risk of MI,
# stroke, and coronary revascularization in patients with established
# cardiovascular disease -- if that's judged a distinct-enough condition
# (comparable to how CAPTOPRIL/PERINDOPRIL were moved to probable for
# heart-failure/stable-CAD claims above), some of these should move from
# priority 1 to priority 2 rather than staying put.
spec_ll_statin_v1 <- DrugSpec$new(
  "statin", "Statins (HMG-CoA Reductase Inhibitors)",
  version = "v1",
  defs    = "From the Perisphere lipid-lowering medication list.",
  generic_names = c(
    "AMLODIPINE/ATORVAST CAL",  # n=230,934 in MC Rx table
    "AMLODIPINE/ATORVASTATIN",  # n=2,896,648 in MC Rx table
    "ASPIRIN(CALC&MG)/PRAVASTATIN",  # n=7 in MC Rx table
    "ATORVASTATIN",
    "ATORVASTATIN CALCIUM",  # n=824,538,830 in MC Rx table
    "FLUVASTATIN",
    "FLUVASTATIN SODIUM",  # n=1,389,190 in MC Rx table
    "LOVASTATIN",  # n=53,839,480 in MC Rx table
    "NIACIN/LOVASTATIN",  # n=296,037 in MC Rx table
    "NIACIN/SIMVASTATIN",  # n=679,412 in MC Rx table
    "PITAVASTATIN",
    "PITAVASTATIN CALCIUM",  # n=7,547,548 in MC Rx table
    "PITAVASTATIN MAGNESIUM",  # n=54,135 in MC Rx table
    "PRAVASTATIN",
    "PRAVASTATIN SODIUM",  # n=161,381,694 in MC Rx table
    "ROSUVASTATIN",
    "ROSUVASTATIN CALCIUM",  # n=286,122,744 in MC Rx table
    "SIMVASTATIN"  # n=309,570,705 in MC Rx table
  )
)

### Ezetimibe ----

spec_ll_ezetimibe_v1 <- DrugSpec$new(
  "ezetimibe", "Ezetimibe",
  version = "v1",
  defs    = "From the Perisphere lipid-lowering medication list.",
  generic_names = c(
    "BEMPEDOIC ACID/EZETIMIBE",  # n=879,792 in MC Rx table
    "EZETIMIBE",  # n=75,793,181 in MC Rx table
    "EZETIMIBE/ATORVASTATIN CALCIUM",  # n=46,998 in MC Rx table
    "EZETIMIBE/ROSUVASTATIN CALCIUM",  # n=22,412 in MC Rx table
    "EZETIMIBE/SIMVASTATIN"  # n=11,139,034 in MC Rx table
  )
)

### PCSK9 inhibitors ----

spec_ll_pcsk9_v1 <- DrugSpec$new(
  "pcsk9", "PCSK9 Inhibitors",
  version = "v1",
  defs    = "From the Perisphere lipid-lowering medication list.",
  generic_names = c(
    "ALIROCUMAB",  # n=5,783,992 in MC Rx table
    "EVOLOCUMAB",  # n=18,168,974 in MC Rx table
    "INCLISIRAN",
    "INCLISIRAN SODIUM"  # n=69,825 in MC Rx table
  )
)

### Fibrates ----
#
# GNN matching: FENOFIBRATE, FENOFIBRIC ACID (active metabolite of fenofibrate),
# CLOFIBRATE, GEMFIBROZIL.

spec_ll_fibrate_v1 <- DrugSpec$new(
  "fibrate", "Fibrates",
  version = "v1",
  defs    = "From the Perisphere lipid-lowering medication list.",
  generic_names = c(
    "CLOFIBRATE",  # n=8 in MC Rx table
    "FENOFIBRATE",  # n=38,426,904 in MC Rx table
    "FENOFIBRATE NANOCRYSTALLIZED",  # n=38,580,751 in MC Rx table
    "FENOFIBRATE,MICRONIZED",  # n=13,655,102 in MC Rx table
    "FENOFIBRIC ACID",  # n=179,125 in MC Rx table
    "FENOFIBRIC ACID (CHOLINE)",  # n=7,929,332 in MC Rx table
    "GEMFIBROZIL"  # n=22,194,891 in MC Rx table
  )
)

### Bile acid sequestrants ----

spec_ll_bile_acid_seq_v1 <- DrugSpec$new(
  "bile_acid_seq", "Bile Acid Sequestrants",
  version = "v1",
  defs    = "From the Perisphere lipid-lowering medication list.",
  # 2026-08-23: priority tiers added (this spec previously had none).
  # CHOLESTYRAMINE is also FDA-approved for pruritus associated with
  # partial biliary obstruction, and COLESEVELAM is separately FDA-approved
  # as an adjunct to improve glycemic control in T2D -- both distinct
  # conditions from hyperlipidemia. COLESTIPOL has no other known
  # US-approved indication.
  generic_names = c(
    "COLESTIPOL",
    "COLESTIPOL HCL",  # n=6,982,208 in MC Rx table
    "COLESTIPOL HCL,MICRONIZED"  # n=29,249 in MC Rx table
  ),
  generic_names_probable = c(
    "CHOLESTYRAMINE",  # n=166,587; NOTE: also FDA-approved for pruritus associated with partial biliary obstruction
    "CHOLESTYRAMINE (WITH SUGAR)",  # n=8,443,157; NOTE: also FDA-approved for pruritus associated with partial biliary obstruction
    "CHOLESTYRAMINE/ASPARTAME",  # n=3,070,417; NOTE: also FDA-approved for pruritus associated with partial biliary obstruction
    "CHOLESTYRAMINE/SUCROSE",  # n=105,327; NOTE: also FDA-approved for pruritus associated with partial biliary obstruction
    "COLESEVELAM",  # NOTE: also FDA-approved as adjunct therapy to improve glycemic control in T2D
    "COLESEVELAM HCL"  # n=8,444,448; NOTE: also FDA-approved as adjunct therapy to improve glycemic control in T2D
  )
)

### Niacin ----
#
# GNN matching: strings containing "NIACIN" (excluding "NIACINA" / niacinamide)
# or "NICOTINIC" (for nicotinic acid forms). Niacinamide (NIACINA-) is a B-vitamin
# supplement without lipid-lowering activity and is excluded.

spec_ll_niacin_v1 <- DrugSpec$new(
  "niacin", "Niacin",
  version = "v1",
  defs    = paste0(
    "From the Perisphere lipid-lowering medication list. ",
    "Includes GNNs containing 'NIACIN' (excluding niacinamide / 'NIACINA-') ",
    "or 'NICOTINIC' (for nicotinic acid preparations)."
  ),
  generic_names = c(
    "INOSITOL NIACINATE",  # n=81 in MC Rx table
    "NIACIN",  # n=11,370,413 in MC Rx table
    "NIACIN (INOSITOL NIACINATE)",  # n=58,498 in MC Rx table
    "NIACIN EXTENDED-RELEASE",
    "NICOTINIC ACID"
  )
)

## Lipid-lowering medication composite ----

spec_hyperlipidemia <- CompositeDrugSpec$new(
  drug_class = "lipid_lowering",
  label      = "Lipid-Lowering Medications",
  defs       = paste0(
    "Lipid-lowering medication subclasses (v1): statins (HMG-CoA reductase inhibitors), ",
    "ezetimibe, PCSK9 inhibitors, fibrates, bile acid sequestrants, and niacin."
  ),
  condition  = "hyperlipidemia",
  components = list(
    statin_v1        = spec_ll_statin_v1,
    ezetimibe_v1     = spec_ll_ezetimibe_v1,
    pcsk9_v1         = spec_ll_pcsk9_v1,
    fibrate_v1       = spec_ll_fibrate_v1,
    bile_acid_seq_v1 = spec_ll_bile_acid_seq_v1,
    niacin_v1        = spec_ll_niacin_v1
  )
)
