# Build-time lookups for code definitions. Sourced by build_specs.R.
#
# Each *_defs() function takes a character vector of codes (no periods) and
# returns a character vector of the same length with a definition for each
# code, or NA when none is available. Nothing here runs at package runtime;
# the definitions are stored inside the saved spec objects.
#
# Sources:
#   ICD-10-CM  CMS FY2026 code descriptions (order file)
#   ICD-10-PCS CMS FY2026 order file (same file used by download_pcs_codes.R)
#   ICD-9-CM   CMS v32 master descriptions (diagnosis and procedure)
#   HCPCS II   NLM Clinical Tables API (letter-prefixed codes only)
#   CPT        manual paraphrases only (.MANUAL_CPT_DEFS); NA otherwise
#
# Downloads are cached in data-raw/.cache/ so rebuilds work offline.

.defs_cache_dir <- "data-raw/.cache"

.defs_download <- function(url, file) {
  path <- file.path(.defs_cache_dir, file)
  if (!file.exists(path)) {
    dir.create(.defs_cache_dir, showWarnings = FALSE, recursive = TRUE)
    old <- options(HTTPUserAgent = "Mozilla/5.0", timeout = 300)
    on.exit(options(old), add = TRUE)
    utils::download.file(url, path, quiet = TRUE, mode = "wb")
  }
  path
}

.defs_read_zip_lines <- function(zip, member) {
  x <- readLines(unz(zip, member), encoding = "latin1", warn = FALSE)
  x <- iconv(x, from = "latin1", to = "UTF-8")
  x[nzchar(trimws(x))]
}

.defs_norm <- function(codes) toupper(gsub(".", "", codes, fixed = TRUE))

.defs_lookup <- function(codes, table) {
  unname(table[.defs_norm(codes)])
}

# CMS "order" files: fixed width. Code in cols 7-13, long description from col 78.
.defs_parse_order <- function(zip, member) {
  x <- .defs_read_zip_lines(zip, member)
  out <- trimws(substring(x, 78L))
  stats::setNames(out, trimws(substr(x, 7L, 13L)))
}

# CMS ICD-9-CM files: "<code> <description>".
.defs_parse_icd9 <- function(zip, member) {
  x <- .defs_read_zip_lines(zip, member)
  stats::setNames(
    trimws(sub("^\\S+\\s+", "", x)),
    sub("^(\\S+)\\s.*$", "\\1", x)
  )
}

.defs_icd10cm_table <- local({
  tbl <- NULL
  function() {
    if (is.null(tbl)) {
      zip <- .defs_download(
        "https://www.cms.gov/files/zip/2026-code-descriptions-tabular-order.zip",
        "icd10cm_2026.zip"
      )
      tbl <<- .defs_parse_order(zip, "icd10cm_order_2026.txt")
    }
    tbl
  }
})

.defs_icd10pcs_table <- local({
  tbl <- NULL
  function() {
    if (is.null(tbl)) {
      zip <- .defs_download(
        paste0(
          "https://www.cms.gov/files/zip/2026-icd-10-pcs-order-file-",
          "long-and-abbreviated-titles.zip"
        ),
        "icd10pcs_2026.zip"
      )
      member <- grep("^icd10pcs_order.*\\.txt$", utils::unzip(zip, list = TRUE)$Name,
                     value = TRUE)
      tbl <<- .defs_parse_order(zip, member)
    }
    tbl
  }
})

.defs_icd9_table <- local({
  tbl <- list()
  function(member) {
    if (is.null(tbl[[member]])) {
      zip <- .defs_download(
        paste0(
          "https://www.cms.gov/Medicare/Coding/ICD9ProviderDiagnosticCodes/",
          "Downloads/ICD-9-CM-v32-master-descriptions.zip"
        ),
        "icd9cm_v32.zip"
      )
      tbl[[member]] <<- .defs_parse_icd9(zip, member)
    }
    tbl[[member]]
  }
})

# ---- ICD ---------------------------------------------------------------------

icd10_defs     <- function(codes) .defs_lookup(codes, .defs_icd10cm_table())
icd10pcs_defs  <- function(codes) .defs_lookup(codes, .defs_icd10pcs_table())

# The CMS v32 file lists only billable (5-digit/leaf) codes. Non-billable
# parents (e.g. 250, 4030) fall back to the icd package hierarchy. Its
# descriptions below the 3-digit level are fragments (e.g. "Malignant"), so
# they are prefixed with the 3-digit category title.
.defs_icd9_parent_table <- local({
  tbl <- NULL
  function() {
    if (is.null(tbl)) {
      h <- icd::icd9cm_hierarchy
      three <- stats::setNames(h$long_desc[nchar(h$code) == 3L],
                               h$code[nchar(h$code) == 3L])
      desc <- ifelse(
        nchar(h$code) == 3L, h$long_desc,
        paste0(three[substr(h$code, 1L, 3L)], ": ", h$long_desc)
      )
      tbl <<- stats::setNames(desc, h$code)
    }
    tbl
  }
})

icd9_defs <- function(codes) {
  out <- .defs_lookup(codes, .defs_icd9_table("CMS32_DESC_LONG_DX.txt"))
  miss <- is.na(out)
  out[miss] <- .defs_lookup(codes[miss], .defs_icd9_parent_table())
  out
}
icd9_proc_defs <- function(codes) .defs_lookup(codes, .defs_icd9_table("CMS32_DESC_LONG_SG.txt"))

# ---- HCPCS / CPT -------------------------------------------------------------

.hcpcs_cache_file <- file.path(.defs_cache_dir, "hcpcs_nlm.rds")

# Single lookup against the NLM Clinical Tables HCPCS API. Returns NA if the
# code is not found or the API is unreachable.
.fetch_hcpcs_nlm <- function(code, timeout = 15) {
  tryCatch({
    resp <- httr::GET(
      "https://clinicaltables.nlm.nih.gov/api/hcpcs/v3/search",
      query = list(terms = code, ef = "long_desc"),
      httr::timeout(timeout)
    )
    if (httr::status_code(resp) != 200L) return(NA_character_)
    res <- jsonlite::fromJSON(httr::content(resp, as = "text", encoding = "UTF-8"),
                              simplifyVector = FALSE)
    hit <- which(unlist(res[[2]]) == code)
    if (!length(hit)) return(NA_character_)
    as.character(res[[3]]$long_desc[[hit[1]]])
  }, error = function(e) NA_character_)
}

# Manual, paraphrased CPT descriptions (not the AMA's official text). CPT
# descriptors are AMA-copyrighted, so these are short plain-language summaries
# of the procedure for the codes used in peridefs specs. Verify against a
# licensed CPT reference before relying on the wording. Several codes were
# deleted from CPT in later years (92980-92984, 92995-92996) and are noted as such.
# Add-on codes (reported with a primary procedure) are marked.
.MANUAL_CPT_DEFS <- c(
  # Coronary artery bypass: venous grafts only
  "33510" = "Coronary artery bypass using a vein graft, 1 graft",
  "33511" = "Coronary artery bypass using vein grafts, 2 grafts",
  "33512" = "Coronary artery bypass using vein grafts, 3 grafts",
  "33513" = "Coronary artery bypass using vein grafts, 4 grafts",
  "33514" = "Coronary artery bypass using vein grafts, 5 grafts",
  "33516" = "Coronary artery bypass using vein grafts, 6 or more grafts",
  # Coronary artery bypass: combined venous and arterial grafts (add-on codes)
  "33517" = "Bypass with vein graft combined with arterial graft(s), 1 vein graft (add-on)",
  "33518" = "Bypass with vein grafts combined with arterial graft(s), 2 vein grafts (add-on)",
  "33519" = "Bypass with vein grafts combined with arterial graft(s), 3 vein grafts (add-on)",
  "33521" = "Bypass with vein grafts combined with arterial graft(s), 4 vein grafts (add-on)",
  "33522" = "Bypass with vein grafts combined with arterial graft(s), 5 vein grafts (add-on)",
  "33523" = "Bypass with vein grafts combined with arterial graft(s), 6 or more vein grafts (add-on)",
  "33530" = "Repeat coronary bypass surgery more than a month after the first operation (add-on)",
  # Coronary artery bypass: arterial grafts only
  "33533" = "Coronary artery bypass using an arterial graft, 1 graft",
  "33534" = "Coronary artery bypass using arterial grafts, 2 grafts",
  "33535" = "Coronary artery bypass using arterial grafts, 3 grafts",
  "33536" = "Coronary artery bypass using arterial grafts, 4 or more grafts",
  # Percutaneous coronary intervention (current codes)
  "92920" = "Percutaneous coronary angioplasty (balloon), single major coronary artery or branch",
  "92921" = "Percutaneous coronary angioplasty, each additional branch (add-on)",
  "92924" = "Percutaneous coronary atherectomy with angioplasty, single major artery or branch",
  "92925" = "Percutaneous coronary atherectomy with angioplasty, each additional branch (add-on)",
  "92928" = "Percutaneous coronary stent placement, single major artery or branch",
  "92929" = "Percutaneous coronary stent placement, each additional branch (add-on)",
  "92933" = "Percutaneous coronary atherectomy with stent, single major artery or branch",
  "92934" = "Percutaneous coronary atherectomy with stent, each additional branch (add-on)",
  "92937" = "Percutaneous revascularization of a bypass graft (stent, atherectomy, and/or angioplasty), single vessel",
  "92938" = "Percutaneous revascularization of a bypass graft, each additional vessel (add-on)",
  "92941" = "Percutaneous revascularization of an acutely occluded artery in acute heart attack, single vessel",
  "92943" = "Percutaneous revascularization of a chronic total coronary occlusion, single vessel",
  "92944" = "Percutaneous revascularization of a chronic total coronary occlusion, each additional vessel (add-on)",
  "92973" = "Mechanical removal of coronary blood clot during percutaneous intervention (add-on)",
  # Retired PCI codes (deleted from CPT; appear in historical claims)
  "92980" = "Retired: coronary stent placement, single vessel",
  "92981" = "Retired: coronary stent placement, each additional vessel (add-on)",
  "92982" = "Retired: coronary balloon angioplasty, single vessel",
  "92984" = "Retired: coronary balloon angioplasty, each additional vessel (add-on)",
  "92995" = "Retired: coronary atherectomy, single vessel",
  "92996" = "Retired: coronary atherectomy, each additional vessel (add-on)",

  # Peripheral and dialysis-circuit interventions (lead PAD spec)
  "37205" = "Stent placement in an artery other than coronary, carotid, vertebral, iliac or leg arteries, percutaneous, first vessel",
  "75962" = "Imaging supervision and interpretation for balloon angioplasty of a peripheral artery",
  "36902" = "Dialysis circuit: angiography and balloon angioplasty of the peripheral segment, with catheter placement and imaging",
  "36905" = "Dialysis circuit: clot removal (thrombectomy) with balloon angioplasty of the peripheral segment, with catheter placement and imaging",
  "37246" = "Balloon angioplasty of an artery (not coronary, carotid, vertebral or dialysis circuit), first artery, with imaging",
  "37247" = "Balloon angioplasty of an artery, each additional artery (add-on)",

  # Carotid / cerebrovascular procedures
  "35301" = "Carotid, vertebral or subclavian endarterectomy (plaque removal) through a neck incision, with or without patch graft",
  "35390" = "Repeat carotid endarterectomy more than a month after the original operation (add-on)",
  "37215" = "Carotid stent placement through the skin, with a distal embolic protection device",
  "37216" = "Carotid stent placement through the skin, without a distal embolic protection device",
  "0005T" = "Retired Category III: percutaneous carotid stent placement (replaced by 37215/37216 in 2005)",
  "0075T" = "Category III: percutaneous stent placement in an extracranial vertebral or intrathoracic carotid artery, first vessel",
  "0076T" = "Category III: percutaneous stent placement in an extracranial vertebral or intrathoracic carotid artery, each additional vessel (add-on)"
)

# Only letter-prefixed (HCPCS Level II) codes are queried. Five-digit numeric
# codes are CPT and use .MANUAL_CPT_DEFS (NA if not listed). Successful lookups are cached; failures are not,
# so an offline run does not poison the cache.
hcpcs_defs <- function(codes) {
  codes <- toupper(codes)
  cache <- if (file.exists(.hcpcs_cache_file)) readRDS(.hcpcs_cache_file) else list()
  todo  <- setdiff(unique(codes[grepl("^[A-Z][0-9]{4}$", codes)]), names(cache))
  if (length(todo)) {
    message("Fetching ", length(todo), " HCPCS definitions from NLM...")
    for (cd in todo) {
      def <- .fetch_hcpcs_nlm(cd)
      if (!is.na(def)) cache[[cd]] <- def
    }
    dir.create(.defs_cache_dir, showWarnings = FALSE, recursive = TRUE)
    saveRDS(cache, .hcpcs_cache_file)
  }
  vapply(codes, function(cd) {
    cache[[cd]] %||% unname(.MANUAL_CPT_DEFS[cd]) %||% NA_character_
  }, character(1), USE.NAMES = FALSE)
}

# `cpt` key: only the paraphrased codes in .MANUAL_CPT_DEFS are defined.
cpt_defs <- function(codes) unname(.MANUAL_CPT_DEFS[codes])

# ---- Dispatch ----------------------------------------------------------------

# Look up definitions by spec code-type key (dx_icd9, proc_icd10, hcpcs, ...).
# In some specs the `hcpcs` key also holds five-digit CPT codes; hcpcs_defs()
# resolves those through .MANUAL_CPT_DEFS.
code_defs <- function(type, codes) {
  switch(type,
    dx_icd9    = icd9_defs(codes),
    dx_icd10   = icd10_defs(codes),
    proc_icd9  = icd9_proc_defs(codes),
    proc_icd10 = icd10pcs_defs(codes),
    hcpcs      = hcpcs_defs(codes),
    cpt        = cpt_defs(codes),
    rep(NA_character_, length(codes))
  )
}
