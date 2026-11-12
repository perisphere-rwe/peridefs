# Version history of condition definitions ------------------------------------
#
# One row per released version after v1: when it was released, a one-line
# summary of what changed, and why. The exact codes added and removed are NOT
# written here; .rd_version_history() computes them from the spec objects
# with get_version_diffs(), so the documentation can't drift from the data.
#
# When releasing a new version, add its row here (tests fail otherwise; see
# tests/testthat/test-versions.R). Never edit a released row's meaning; add
# a new version instead. Avoid "%" in text (it is special in Rd).

.version_log <- tibble::tribble(
  ~condition,       ~version, ~date,        ~summary, ~rationale,
  "diabetes_type2", "v2",     "2026-10-22",
  "ICD-10 type 2 diabetes codes (E11) only.",
  paste(
    "A more specific definition. Drops all ICD-9 codes and the ICD-10 codes",
    "for diabetes due to an underlying condition (E08), drug- or",
    "chemical-induced diabetes (E09) and other specified diabetes (E13),",
    "keeping only type 2 diabetes (E11). Adds E11.A (type 2 diabetes without",
    "complications, in remission), the one billable E11 code missing from v1.",
    "Because no ICD-9 codes remain, claims before October 1, 2015 cannot",
    "qualify through the diagnosis criteria. The medication criterion is",
    "unchanged."
  ),
  "hf",             "v2",     "2026-10-23",
  "ICD-10 only; history uses I50.x; outcomes add I11.0, I13.0, I13.2 with acuity rules.",
  paste(
    "Restricts heart failure to ICD-10-CM codes. Drops all ICD-9 codes",
    "(402.x1, 404.x1, 404.x3 and 428.x), so claims and hospitalizations",
    "before October 1, 2015 cannot qualify. History no longer uses I11.0,",
    "I13.0 and I13.2, which require a secondary I50.x on the same claim, so",
    "it is I50.x only. The outcome definition is rebuilt around acute heart",
    "failure hospitalization (an acute or acute-on-chronic I50 code as the",
    "primary diagnosis, or I11.0, I13.0 or I13.2 as the primary diagnosis",
    "with the required secondary codes) and incident heart failure (any I50",
    "code). The outcome code set carries acuity, required_secondary and",
    "qualifies_as_primary columns that describe these rules."
  )
)

# Markdown list of codes for one code type, e.g. "dx_icd10 (2): `E11A`, `E119`".
.md_code_list <- function(type, codes) {
  paste0(type, " (", length(codes), "): ",
         paste0("`", codes, "`", collapse = ", "))
}

# Markdown summary of the codes added and removed between two versions.
.md_code_changes <- function(d, from, to) {
  out <- character()
  for (what in c("removed", "added")) {
    keep <- if (what == "removed") d[[from]] & !d[[to]] else !d[[from]] & d[[to]]
    if (!any(keep)) next
    by_type <- split(d$code[keep], factor(d$type[keep], levels = unique(d$type[keep])))
    n <- sum(keep)
    out <- c(out, paste0(
      "    - ", if (what == "removed") "Removed" else "Added", " ",
      n, " code", if (n == 1L) "" else "s", ":\n",
      paste0("        - ", vapply(names(by_type), function(t) {
        .md_code_list(t, by_type[[t]])
      }, character(1L)), collapse = "\n")
    ))
  }
  if (!length(out)) out <- "    - No codes added or removed."
  out
}

# Markdown "Version history" for one condition's help page. Used from
# roxygen as `r .rd_version_history("diabetes_type2")`.
.rd_version_history <- function(condition) {
  v <- list_versions(condition)
  items <- character()
  for (i in seq_len(nrow(v))) {
    ver <- v$version[i]
    if (i == 1L) {
      items <- c(items, paste0(
        "- **", ver, "**: initial version (", v$n_codes[i], " codes)."
      ))
      next
    }
    prev <- v$version[i - 1L]
    log  <- .version_log[.version_log$condition == condition &
                           .version_log$version == ver, , drop = FALSE]
    head <- paste0("- **", ver, "** (", log$date, ", ", v$n_codes[i],
                   " codes): ", log$summary)
    why  <- paste0("    - Why: ", log$rationale)

    changes <- character()
    for (vt in c("condition", "outcome")) {
      d <- get_version_diffs(condition, c(prev, ver), variable_type = vt)
      txt <- .md_code_changes(d, prev, ver)
      changes[[vt]] <- paste(txt, collapse = "\n")
    }
    body <- if (identical(changes[["condition"]], changes[["outcome"]])) {
      c(paste0("    - Codes compared with ", prev, ":"),
        gsub("(^|\n)    ", "\\1        ", changes[["condition"]]))
    } else {
      c(paste0("    - Condition codes compared with ", prev, ":"),
        gsub("(^|\n)    ", "\\1        ", changes[["condition"]]),
        paste0("    - Outcome codes compared with ", prev, ":"),
        gsub("(^|\n)    ", "\\1        ", changes[["outcome"]]))
    }
    items <- c(items, head, why, body)
  }
  paste(c(
    paste0("Every version below remains available. Compare any of them with ",
           "`get_version_diffs(\"", condition, "\")`; list them with ",
           "`list_versions(\"", condition, "\")`."),
    "",
    items
  ), collapse = "\n")
}
