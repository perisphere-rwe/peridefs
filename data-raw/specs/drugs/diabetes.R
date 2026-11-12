# Antidiabetic medications --------------------------------------------------
# Sourced by data-raw/build_specs.R; do not source on its own.
# Runs in its own environment: every object defined here is local to this
# file, and only `spec_*` objects are passed on to later files.

# Depends on: drugs/obesity.R (`spec_glp1_v1`)

## Antidiabetic medication components ----
#
# Source: "Definition of conditions and medications_11262025.docx"
# Section: Diabetes, history, source version 2 (with medication) — GNN list.
# (This cites where the medication GNN list originated in the source
# document; it does not imply a separately exported spec_diabetes_v2 -- see
# the "Diabetes" section notes above.)

### Biguanides ----

# Priority tiers reviewed (2026-08-23) for all antidiabetic sub-specs below
# except spec_antidiab_alpha_glucosidase_v1 (already tiered) and
# spec_antidiab_sglt2_v1 (tiered above): biguanides, sulfonylureas,
# meglitinides, TZDs, DPP-4 inhibitors, insulin/supplies, and amylin
# analogues have no other known US-approved indication beyond diabetes, so
# they remain priority 1 throughout.
spec_antidiab_biguanide_v1 <- DrugSpec$new(
  "biguanide", "Biguanides",
  version = "v1",
  defs    = "Biguanide antidiabetic agents. From the Perisphere antidiabetic medication list.",
  generic_names = c(
    "METFORMIN HCL",  # n=582,684,970 in MC Rx table
    "METFORMIN/AA COMB.#7/HC#125/CH",  # n=11 in MC Rx table
    "METFORMIN/CAFF/AA7/HRB125/CHOL"  # n=32 in MC Rx table
  )
)

### Sulfonylureas ----

spec_antidiab_sulfonylurea_v1 <- DrugSpec$new(
  "sulfonylurea", "Sulfonylureas",
  version = "v1",
  defs    = "Sulfonylurea antidiabetic agents (first- and second-generation). From the Perisphere antidiabetic medication list.",
  generic_names = c(
    "ACETOHEXAMIDE",  # n=20 in MC Rx table
    "CHLORPROPAMIDE",  # n=26,284 in MC Rx table
    "GLIMEPIRIDE",  # n=82,220,866 in MC Rx table
    "GLIPIZIDE",  # n=116,334,542 in MC Rx table
    "GLIPIZIDE/METFORMIN HCL",  # n=3,412,573 in MC Rx table
    "GLYBURIDE",  # n=18,777,790 in MC Rx table
    "GLYBURIDE,MICRONIZED",  # n=772,875 in MC Rx table
    "GLYBURIDE/METFORMIN HCL",  # n=6,493,130 in MC Rx table
    "TOLAZAMIDE",  # n=8,179 in MC Rx table
    "TOLBUTAMIDE",  # n=9,967 in MC Rx table
    "GLYBURIDE, MICRO/METFORMIN HCL"  # n=221,920 in MC Rx table
  )
)

### Meglitinides ----

spec_antidiab_meglitinide_v1 <- DrugSpec$new(
  "meglitinide", "Meglitinides",
  version = "v1",
  defs    = "Meglitinide (glinide) antidiabetic agents. From the Perisphere antidiabetic medication list.",
  generic_names = c(
    "NATEGLINIDE",  # n=2,678,863 in MC Rx table
    "REPAGLINIDE",  # n=4,841,685 in MC Rx table
    "REPAGLINIDE/METFORMIN HCL"  # n=11,197 in MC Rx table
  )
)

### Thiazolidinediones (TZDs) ----

spec_antidiab_tzd_v1 <- DrugSpec$new(
  "tzd", "Thiazolidinediones (TZDs)",
  version = "v1",
  defs    = "Thiazolidinedione (TZD / glitazone) antidiabetic agents. From the Perisphere antidiabetic medication list.",
  generic_names = c(
    "PIOGLITAZONE HCL",  # n=45,499,575 in MC Rx table
    "PIOGLITAZONE HCL/GLIMEPIRIDE",  # n=161,285 in MC Rx table
    "PIOGLITAZONE HCL/METFORMIN HCL",  # n=2,772,081 in MC Rx table
    "PIOGLITAZONE/GLIMEPIRIDE",  # n=40,663 in MC Rx table
    "ROSIGLITAZONE MALEATE",  # n=450,097 in MC Rx table
    "ROSIGLITAZONE/GLIMEPIRIDE",  # n=30,045 in MC Rx table
    "ROSIGLITAZONE/METFORMIN HCL",  # n=162,687 in MC Rx table
    "TROGLITAZONE",  # n=13 in MC Rx table
    "ROSIGLITAZONE MALEATE/GLIMEPIR"  # n=6,885 in MC Rx table
  )
)

### Alpha-glucosidase inhibitors ----

spec_antidiab_alpha_glucosidase_v1 <- DrugSpec$new(
  "alpha_glucosidase", "Alpha-Glucosidase Inhibitors",
  version = "v1",
  defs    = "Alpha-glucosidase inhibitor antidiabetic agents. From the Perisphere antidiabetic medication list.",
  generic_names = c(
    "ACARBOSE",  # n=2,695,084 in MC Rx table
    "MIGLITOL"  # n=110,276 in MC Rx table
  ),
  generic_names_cautious = c(
    "VOGLIBOSE"  # Not FDA-approved or marketed in the US (approved in Japan/India)
  )
)

### DPP-4 inhibitors ----

spec_antidiab_dpp4_v1 <- DrugSpec$new(
  "dpp4", "DPP-4 Inhibitors",
  version = "v1",
  defs    = "DPP-4 inhibitor (gliptin) antidiabetic agents, including fixed-dose combinations. From the Perisphere antidiabetic medication list.",
  generic_names = c(
    "ALOGLIPTIN BENZ/METFORMIN HCL",  # n=687,166 in MC Rx table
    "ALOGLIPTIN BENZ/PIOGLITAZONE",  # n=333,008 in MC Rx table
    "ALOGLIPTIN BENZ/PIOGLITZONE",  # n=30,071 in MC Rx table
    "ALOGLIPTIN BENZOATE",  # n=3,007,468 in MC Rx table
    "ALOGLIPTIN/METFORMIN",
    "LINAGLIPTIN",  # n=18,631,487 in MC Rx table
    "LINAGLIPTIN/METFORMIN HCL",  # n=2,503,329 in MC Rx table
    "PIOGLITAZONE/ALOGLIPTIN",
    "SAXAGLIPTIN HCL",  # n=6,136,665 in MC Rx table
    "SAXAGLIPTIN HCL/METFORMIN HCL",  # n=3,106,395 in MC Rx table
    "SAXAGLIPTIN HYDROCHLORIDE",  # n=17,932 in MC Rx table
    "SITAGLIPTIN PHOS/METFORMIN HCL",  # n=28,141,072 in MC Rx table
    "SITAGLIPTIN PHOSPHATE",  # n=71,565,776 in MC Rx table
    "SITAGLIPTIN/SIMVASTATIN",  # n=11,897 in MC Rx table
    "VILDAGLIPTIN",
    "SITAGLIPTIN",  # n=148,377 in MC Rx table
    "SITAGLIPTIN HCL",  # n=32 in MC Rx table
    "SITAGLIPTIN/METFORMIN HCL"  # n=55,672 in MC Rx table
  )
)

### SGLT-2 inhibitors ----

spec_antidiab_sglt2_v1 <- DrugSpec$new(
  "sglt2", "SGLT-2 Inhibitors",
  version = "v1",
  defs    = "SGLT-2 inhibitor antidiabetic agents (gliflozins), including fixed-dose combinations. From the Perisphere antidiabetic medication list.",
  # 2026-08-23: priority tiers added (this spec previously had none).
  # DAPAGLIFLOZIN, EMPAGLIFLOZIN, and CANAGLIFLOZIN each carry a distinct
  # additional FDA-approved indication beyond T2D (heart failure and/or
  # chronic kidney disease/diabetic nephropathy) and move to
  # generic_names_probable. ERTUGLIFLOZIN and BEXAGLIFLOZIN have no other
  # known US-approved indication. Fixed-dose antidiabetic combination
  # products (all metformin/DPP-4 combos here) stay priority 1.
  generic_names = c(
    "CANAGLIFLOZIN/METFORM",
    "CANAGLIFLOZIN/METFORMIN",
    "DAPAGLIFLOZIN/METFORMIN",
    "DAPAGLIFLOZIN/SAXAGLIPTIN",
    "EMPAGLIFLOZIN/LINAGLIPTIN",  # n=2,418,949 in MC Rx table
    "EMPAGLIFLOZIN/LINAGLIPTIN/METFORMIN",
    "EMPAGLIFLOZIN/METFORMIN",
    "ERTUGLIFLOZIN",
    "ERTUGLIFLOZIN/METFORMIN",  # n=245,406 in MC Rx table
    "ERTUGLIFLOZIN/SITAGLIPTIN",  # n=106,321 in MC Rx table
    "BEXAGLIFLOZIN",  # n=9,839 in MC Rx table
    "CANAGLIFLOZIN/METFORMIN HCL",  # n=2,366,509 in MC Rx table
    "DAPAGLIFLOZ PROPANED/METFORMIN",  # n=157,863 in MC Rx table
    "DAPAGLIFLOZIN/METFORMIN HCL",  # n=4,946,123 in MC Rx table
    "DAPAGLIFLOZIN/SAXAGLIPTIN HCL",  # n=59,138 in MC Rx table
    "EMPAGLIFLOZ/LINAGLIP/METFORMIN",  # n=443,960 in MC Rx table
    "EMPAGLIFLOZIN/METFORMIN HCL",  # n=5,909,272 in MC Rx table
    "ERTUGLIFLOZIN PIDOLATE",  # n=3,094,383 in MC Rx table
    "ERTUGLIFLOZIN/SITAGLIPTIN PHOS"  # n=29,822 in MC Rx table
  ),
  generic_names_probable = c(
    "CANAGLIFLOZIN",  # n=17,633,966; NOTE: also FDA-approved for diabetic nephropathy with albuminuria (CREDENCE)
    "DAPAGLIFLOZIN",  # NOTE: also FDA-approved for heart failure (HFrEF/HFpEF) and chronic kidney disease
    "DAPAGLIFLOZIN PROPANEDIOL",  # n=44,710,552; NOTE: also FDA-approved for heart failure (HFrEF/HFpEF) and chronic kidney disease
    "EMPAGLIFLOZIN"  # n=75,691,170; NOTE: also FDA-approved for heart failure (HFrEF/HFpEF) and chronic kidney disease
  )
)

### GLP-1 ----
#
# spec_antidiab_glp1_v1 was merged into spec_glp1_v1 (2026-08-15, see the
# comment near its definition); the antidiabetic composite below now
# references that shared object directly as its "glp1_v1" component.

### Insulin and supplies ----

spec_antidiab_insulin_v1 <- DrugSpec$new(
  "insulin", "Insulin and Supplies",
  version = "v1",
  defs    = "Insulin preparations and insulin administration supplies. From the Perisphere antidiabetic medication list.",
  generic_names = c(
    "HUM INSULIN NPH/REG INSULIN HM",  # n=3,296,175 in MC Rx table
    "INS ZN,BF (P)/INS ZN,PK (P),",
    "INSUL,PK PURE/INSUL NPH,PK-P",  # n=3 in MC Rx table
    "INSULIN ADMIN. SUPPLIES",  # n=212,045 in MC Rx table
    "INSULIN ASPART",  # n=74,545,189 in MC Rx table
    "INSULIN DEGLEDEC",
    "INSULIN DEGLEDEC/LIRAGLUTIDE",
    "INSULIN DETEMIR",  # n=44,596,992 in MC Rx table
    "INSULIN GLARGINE,HUM.REC.ANLOG",  # n=174,464,465 in MC Rx table
    "INSULIN GLULISINE",  # n=2,940,926 in MC Rx table
    "INSULIN ISOPHANE NPH,BFPK",
    "INSULIN ISOPHANE NPH,BF-PK",  # n=212 in MC Rx table
    "INSULIN ISOPHANE,BEEF",  # n=112 in MC Rx table
    "INSULIN ISOPHANE,BEEF PURE",  # n=14 in MC Rx table
    "INSULIN ISOPHANE,PORK PURE",  # n=109 in MC Rx table
    "INSULIN LISPRO",  # n=73,695,041 in MC Rx table
    "INSULIN NPH HUM/REG INSULIN HM",  # n=11,208,835 in MC Rx table
    "INSULIN NPH HUMAN ISOPHANE",  # n=8,788,275 in MC Rx table
    "INSULIN NPH HUMAN SEMISYN",
    "INSULIN NPH HUMAN SEMI-SYN",  # n=77 in MC Rx table
    "INSULIN NPH S-S/REG INSULN S-S",  # n=61 in MC Rx table
    "INSULIN NPL/INSULIN LISPRO",  # n=2,057,607 in MC Rx table
    "INSULIN PROTAMINE ZINC,BEEF",
    "INSULIN PROTAMINE ZN,BEEF (P),",
    "INSULIN PROTAMINE ZN,BF-PK",  # n=5 in MC Rx table
    "INSULIN PROTAMINE ZN,PORK (P),",
    "INSULIN REG HUMAN  SEMI-SYN",
    "INSULIN REG HUMAN SEMI-SYN",  # n=103 in MC Rx table
    "INSULIN REG,HUM S-S BUFF",
    "INSULIN REGULAR,HUMAN",
    "INSULIN REGULAR,BEEF-PORK",  # n=453 in MC Rx table
    "INSULIN REGULAR,HUMAN BUFFERED",  # n=22 in MC Rx table
    "INSULIN REGULAR,HUMAN&REL.UNT",  # n=820 in MC Rx table
    "INSULIN ZINC BEEF",  # n=23 in MC Rx table
    "INSULIN ZINC EXT,BEEF (P),",
    "INSULIN ZINC EXTEND HUMAN REC",  # n=156 in MC Rx table
    "INSULIN ZINC EXTENDED,BEEF",  # n=8 in MC Rx table
    "INSULIN ZINC EXTENDED,BF-PK",  # n=19 in MC Rx table
    "INSULIN ZINC HUMAN REC",  # n=240 in MC Rx table
    "INSULIN ZINC HUMAN SEMI-SYN",  # n=6 in MC Rx table
    "INSULIN ZINC PROMPT,BEEF",  # n=3 in MC Rx table
    "INSULIN ZINC PROMPT,BF-PK",  # n=11 in MC Rx table
    "INSULIN ZINC PROMPT,PORK PURE",  # n=6 in MC Rx table
    "INSULIN ZINC,BEEF PURIFIED",  # n=2 in MC Rx table
    "INSULIN ZINC,BEEF-PORK",  # n=45 in MC Rx table
    "INSULIN ZINC,PORK PURIFIED",  # n=47 in MC Rx table
    "INSULIN,BEEF",  # n=2 in MC Rx table
    "INSULIN,PORK",  # n=30 in MC Rx table
    "INSULIN,PORK PURIFIED",  # n=47 in MC Rx table
    "INSULIN,PORK REG. CONCENTRATE",
    "INSULN ASP PRT/INSULIN ASPART",  # n=2,886,127 in MC Rx table
    "LIXISENATIDE/INSULIN GLARGINE",
    "NPH,HUMAN INSULIN ISOPHANE",
    "REG INSULIN HM/RLSE/CHBR/IHLR",  # n=306 in MC Rx table
    "SUB-Q INSULIN DEVICE,20 UNIT",
    "SUB-Q INSULIN DEVICE,40 UNIT",
    "SYR W-NDL,INS 0.3 ML HALF MARK",  # n=386,436 in MC Rx table
    "SYRGND,INS,0.5/CONTAINER",
    "SYRG-ND,INS,0.5/CONTAINER",  # n=1,179 in MC Rx table
    "SYRING  W-NDL,DISP,INSUL,0.3ML",
    "SYRING WNDL,DISP,INSUL,0.5 ML",
    "SYRING W-NDL,DISP,INSUL,0.3 ML",  # n=776,903 in MC Rx table
    "SYRING W-NDL,DISP,INSUL,0.3ML",  # n=1,389,830 in MC Rx table
    "SYRING W-NDL,DISP,INSUL,0.5 ML",  # n=2,200,897 in MC Rx table
    "SYRING W-NDL,DISP,INSUL,0.5ML",  # n=3,898,112 in MC Rx table
    "SYRING W-O NDL,DISP,INSUL,1ML",
    "SYRINGE & NEEDLE,INSULIN,1 ML",  # n=5,446,276 in MC Rx table
    "SYRINGE W-NDL,DISP,INSUL,1ML",
    "SYRINGE W-NDL,DISP.,INSULIN",
    "SYR-ND,INS,0.5/CONTAINER,EMPTY",  # n=1,486 in MC Rx table
    "SYRNGE&NEEDLE,INSLN,1ML&SHARPS",  # n=2,037 in MC Rx table
    "BOLUS INSULIN PUMP, 200 UNIT",  # n=101,214 in MC Rx table
    "DILUENT, INSULIN ASPART NO.1",  # n=32 in MC Rx table
    "DILUENT,INSULIN LISPRO,REGULAR",  # n=6 in MC Rx table
    "INFUSION SET FOR INSULIN PUMP",  # n=771,093 in MC Rx table
    "INFUSION SET-INSULIN PUMP BODY",  # n=4,806 in MC Rx table
    "INSUL NPH HU REC/INS RG HU REC",  # n=21 in MC Rx table
    "INSULIN ASPART (NIACINAMIDE)",  # n=2,732,257 in MC Rx table
    "INSULIN ASPART PROT/INSULN ASP",  # n=734,692 in MC Rx table
    "INSULIN ASPART PROTAM & ASPART",  # n=7,002,676 in MC Rx table
    "INSULIN ASPART-SZJJ",  # n=110 in MC Rx table
    "INSULIN ASPART-XJHZ",  # n=20,384 in MC Rx table
    "INSULIN ASPART/B3/PUMP CART",  # n=23,156 in MC Rx table
    "INSULIN DEGLUDEC",  # n=28,217,524 in MC Rx table
    "INSULIN GLARGINE-AGLR",  # n=104,013 in MC Rx table
    "INSULIN GLARGINE-YFGN",  # n=5,750,339 in MC Rx table
    "INSULIN INFUSION SET/CARTRIDGE",  # n=126,607 in MC Rx table
    "INSULIN INHALATION CHAMBER",  # n=5 in MC Rx table
    "INSULIN LISPRO PROTAMIN/LISPRO",  # n=4,608,139 in MC Rx table
    "INSULIN LISPRO,HUMAN REC.ANLOG",  # n=58,533 in MC Rx table
    "INSULIN LISPRO-AABC",  # n=879,308 in MC Rx table
    "INSULIN NPH HUMAN RECOM",  # n=40,600 in MC Rx table
    "INSULIN NPH/REGULAR INSULN S-S",  # n=40 in MC Rx table
    "INSULIN PEN,REUSABLE,BT LISPRO",  # n=31,757 in MC Rx table
    "INSULIN PEN,REUSABLE,BT,ASPART",  # n=39,330 in MC Rx table
    "INSULIN PMP CART,AUT,G6/7,CNTR",  # n=148,845 in MC Rx table
    "INSULIN PMP CART,BT,G6/L2/CNTR",  # n=13,936 in MC Rx table
    "INSULIN PMP CART/SET/SYR/NEEDL",  # n=3,001 in MC Rx table
    "INSULIN POWDER INHALER/CHAMBER",  # n=8 in MC Rx table
    "INSULIN PROTAMINE ZN,BEEF (P)",  # n=1 in MC Rx table
    "INSULIN PUMP CART,10 UNITS/DAY",  # n=94 in MC Rx table
    "INSULIN PUMP CART,15 UNITS/DAY",  # n=63 in MC Rx table
    "INSULIN PUMP CART,20 UNITS/DAY",  # n=55 in MC Rx table
    "INSULIN PUMP CART,25 UNITS/DAY",  # n=39 in MC Rx table
    "INSULIN PUMP CART,30 UNITS/DAY",  # n=36 in MC Rx table
    "INSULIN PUMP CART,35 UNITS/DAY",  # n=17 in MC Rx table
    "INSULIN PUMP CART,40 UNITS/DAY",  # n=22 in MC Rx table
    "INSULIN PUMP CART,AUTO,BT,G6/7",  # n=1,680,268 in MC Rx table
    "INSULIN PUMP CART,AUTO,BT,G6/L",  # n=38,973 in MC Rx table
    "INSULIN PUMP CART,AUTO,BT/CNTR",  # n=562,343 in MC Rx table
    "INSULIN PUMP CART,AUTOMATED,BT",  # n=2,422,775 in MC Rx table
    "INSULIN PUMP CART,CONT BT/CNTR",  # n=9,067 in MC Rx table
    "INSULIN PUMP CART,CONT INF,BT",  # n=742,978 in MC Rx table
    "INSULIN PUMP CART,CONT INF,RF",  # n=55,720 in MC Rx table
    "INSULIN PUMP CART/SYRNG/NEEDLE",  # n=288 in MC Rx table
    "INSULIN PUMP CARTRIDGE",  # n=1,186,324 in MC Rx table
    "INSULIN PUMP CONTROLLER",  # n=3,214 in MC Rx table
    "INSULIN PUMP SYRINGE, 1.8 ML",  # n=38,195 in MC Rx table
    "INSULIN PUMP SYRINGE, 1.8ML",  # n=431 in MC Rx table
    "INSULIN PUMP SYRINGE, 3 ML",  # n=153,430 in MC Rx table
    "INSULIN PUMP SYRINGE, 3ML",  # n=607 in MC Rx table
    "INSULIN PUMP/CART/SET/SYR/NEED",  # n=15,505 in MC Rx table
    "INSULIN PUMP/INFUS. SET/METER",  # n=7,571 in MC Rx table
    "INSULIN REG, HUM S-S BUFF",  # n=4 in MC Rx table
    "INSULIN REGULAR HUMAN REC",  # n=20,939 in MC Rx table
    "INSULIN REGULAR HUMAN REC/RLSE",  # n=594 in MC Rx table
    "INSULIN REGULAR IN 0.9 % NACL",  # n=38,787 in MC Rx table
    "INSULIN REGULAR, HUMAN",  # n=12,695,177 in MC Rx table
    "INSULIN RELEASE UNIT",  # n=7 in MC Rx table
    "INSULIN ZINC EXT,BEEF (P)",  # n=1 in MC Rx table
    "INSULIN ZINC HUMAN RECOMBINANT",  # n=256 in MC Rx table
    "NEEDLELESS ACCESS. DEV,INSULIN",  # n=133 in MC Rx table
    "NEEDLES, INSULIN DISP., SAFETY",  # n=217,000 in MC Rx table
    "NEEDLES, INSULIN DISPOSABLE",  # n=18,169,054 in MC Rx table
    "NPH, HUMAN INSULIN ISOPHANE",  # n=2,600,487 in MC Rx table
    "SUB-Q INSULIN DEVICE, 20 UNIT",  # n=228,500 in MC Rx table
    "SUB-Q INSULIN DEVICE, 30 UNIT",  # n=240,308 in MC Rx table
    "SUB-Q INSULIN DEVICE, 40 UNIT",  # n=367,904 in MC Rx table
    "SUB-Q INSULIN PUMP, CGM SYSTEM",  # n=3,246 in MC Rx table
    "SUBCUTANEOUS INSULIN PUMP",  # n=666,618 in MC Rx table
    "SUBQ INSULIN PUMP,GLUC.MON.SYS",  # n=521 in MC Rx table
    "SYR,NDL,INSULIN,1ML-SHARPS BIN",  # n=1,846 in MC Rx table
    "SYRING W-NDL,DISP,INSUL,0.25ML",  # n=11 in MC Rx table
    "SYRING W-O NDL,DISP,INSUL, 1ML",  # n=2,691 in MC Rx table
    "SYRING W-O NEEDLE,DISP,INSULIN",  # n=3 in MC Rx table
    "SYRING,NDL,DISP,INSUL,0.333 ML",  # n=3 in MC Rx table
    "SYRING-NEEDL,DISP,INSUL,0.3 ML",  # n=4,183,822 in MC Rx table
    "SYRINGE AND NEEDLE,INSULIN,1ML",  # n=11,885,331 in MC Rx table
    "SYRINGE NDL,INSUL U-500,0.5ML",  # n=4,582 in MC Rx table
    "SYRINGE W-NDL, DISP,INSUL,1ML",  # n=306,432 in MC Rx table
    "SYRINGE W-NDL, DISP,INSUL,2 ML",  # n=311 in MC Rx table
    "SYRINGE W-NDL, DISP,INSUL,2ML",  # n=307 in MC Rx table
    "SYRINGE W-NDL, DISP,INSUL,3ML",  # n=2 in MC Rx table
    "SYRINGE W-NDL, DISP., INSULIN",  # n=48,847 in MC Rx table
    "SYRINGE W-NDL,INSUL,U-40,1 ML",  # n=63 in MC Rx table
    "SYRINGE W-O NEEDL,INSULIN,1 ML",  # n=4,918 in MC Rx table
    "SYRINGE WITH NEEDLE, INSULIN",  # n=37,293 in MC Rx table
    "SYRINGE,INSUL U-500,NDL,0.5ML",  # n=98,503 in MC Rx table
    "SYRINGE,INSULIN,NEEDLESS 1 ML",  # n=40,462 in MC Rx table
    "SYRINGE,NEEDLE,INSULN,SAFE,1ML",  # n=47,432 in MC Rx table
    "SYRINGE,NEEDLE,INSULN,SF 0.5ML",  # n=36,144 in MC Rx table
    "SYRINGE,NEEDLE,INSULN,SF,0.3ML",  # n=6,025 in MC Rx table
    "SYRINGE-NEEDLE,INSULIN,0.5 ML"  # n=9,392,895 in MC Rx table
  )
)

### Amylin analogues ----

spec_antidiab_amylin_v1 <- DrugSpec$new(
  "amylin", "Amylin Analogues",
  version = "v1",
  defs    = "Amylin analogue antidiabetic agents. From the Perisphere antidiabetic medication list.",
  generic_names = c(
    "PRAMLINTIDE ACETATE"  # n=344,852 in MC Rx table
  )
)

## Antidiabetic medication composites ----
#
# (2026-09-12) Former spec_diabetes (single composite, condition = "diabetes")
# split into spec_diabetes_type1 and spec_diabetes_type2.
#
# spec_diabetes_type1: insulin and amylin analogues — the two drug classes
#   with FDA approval for Type 1 diabetes. Both also appear in spec_diabetes_type2
#   because insulin and amylin are used in Type 2 as well.
#
# spec_diabetes_type2: the full ten-class antidiabetic drug list. Includes
#   insulin and amylin (shared with type 1) plus the eight classes that are
#   Type 2-specific (biguanides, sulfonylureas, meglitinides, TZDs,
#   alpha-glucosidase inhibitors, DPP-4 inhibitors, SGLT-2 inhibitors, GLP-1s).

spec_diabetes_type1 <- CompositeDrugSpec$new(
  drug_class = "antidiabetic",
  label      = "Type 1 Diabetes Medications",
  defs       = "Antidiabetic medications used in Type 1 diabetes (v1): insulin and amylin analogues.",
  condition  = "diabetes_type1",
  components = list(
    insulin_v1 = spec_antidiab_insulin_v1,
    amylin_v1  = spec_antidiab_amylin_v1
  )
)

spec_diabetes_type2 <- CompositeDrugSpec$new(
  drug_class = "antidiabetic",
  label      = "Type 2 Diabetes Medications",
  defs       = paste0(
    "All antidiabetic medication subclasses used in Type 2 diabetes (v1): biguanides, ",
    "sulfonylureas, meglitinides, thiazolidinediones, alpha-glucosidase inhibitors, ",
    "DPP-4 inhibitors, SGLT-2 inhibitors, GLP-1 receptor agonists, insulin and supplies, ",
    "amylin analogues."
  ),
  condition  = "diabetes_type2",
  components = list(
    biguanide_v1         = spec_antidiab_biguanide_v1,
    sulfonylurea_v1      = spec_antidiab_sulfonylurea_v1,
    meglitinide_v1       = spec_antidiab_meglitinide_v1,
    tzd_v1               = spec_antidiab_tzd_v1,
    alpha_glucosidase_v1 = spec_antidiab_alpha_glucosidase_v1,
    dpp4_v1              = spec_antidiab_dpp4_v1,
    sglt2_v1             = spec_antidiab_sglt2_v1,
    glp1_v1              = spec_glp1_v1,
    insulin_v1           = spec_antidiab_insulin_v1,
    amylin_v1            = spec_antidiab_amylin_v1
  )
)
