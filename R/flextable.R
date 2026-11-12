# flextable output helpers ----------------------------------------------------
#
# Used by get_version_diffs(format = "flextable"). flextable is in Suggests,
# so every call is namespaced and guarded by .check_flextable().

# Wrapped so tests can mock it.
.has_flextable <- function() requireNamespace("flextable", quietly = TRUE)

.check_flextable <- function() {
  if (!.has_flextable()) {
    cli::cli_abort(c(
      "{.code format = \"flextable\"} requires the {.pkg flextable} package.",
      "i" = "Install it with {.run install.packages(\"flextable\")}, or use {.code format = \"tibble\"}."
    ))
  }
  invisible(TRUE)
}

# Standard Perisphere table styling: fonts, bold header, box theme, centred
# columns with a left-aligned first column, optional header/footer lines, and
# peripal header colours when peripal is installed.
#' @noRd
flextable_polish <- function(ft,
                             font_name = "Arial",
                             font_size = 11,
                             header_text = NULL,
                             footer_text = NULL,
                             bold_group_labels = TRUE,
                             use_peripal = NULL,
                             group_label_bg_alpha = 0.5) {

  peripal_installed <- system.file(package = "peripal") != ""

  if (is.null(use_peripal))
    use_peripal <- peripal_installed

  if (use_peripal && !peripal_installed)
    cli::cli_abort(
      message = paste0(
        "{.code use_peripal} is TRUE, but peripal is not installed. ",
        "Install peripal with ",
        "{.run remotes::install_github('perisphere-rwe/peripal')}"
      )
    )

  if (!is.null(header_text))
    ft <- flextable::add_header_lines(ft, header_text)

  if (!is.null(footer_text))
    ft <- flextable::add_footer_lines(ft, footer_text)

  if (use_peripal) {
    # getExportedValue() rather than `::` because peripal is not on CRAN.
    bg_colors <- getExportedValue("peripal", "peripal")(n = 2L)

    ft <- flextable::bg(ft, i = 1L, bg = bg_colors[2L], part = "header")
    ft <- flextable::color(ft, i = 1L, color = "white", part = "header")
  }

  is_grouped <- class(ft$body$dataset)[1L] == "grouped_data"

  if (is_grouped) {
    group_label_idx <- which(!is.na(ft$body$dataset[[1L]]))

    if (bold_group_labels)
      ft <- flextable::bold(ft, i = group_label_idx, j = 1L)

    if (use_peripal)
      ft <- flextable::bg(
        ft,
        i = group_label_idx,
        bg = grDevices::adjustcolor(bg_colors[1L], alpha.f = group_label_bg_alpha)
      )
  }

  ft <- flextable::bold(ft, part = "header")
  ft <- flextable::font(ft, fontname = font_name, part = "all")
  ft <- flextable::fontsize(ft, size = font_size, part = "all")
  ft <- flextable::theme_box(ft)
  ft <- flextable::align(ft, align = "center", part = "all")
  flextable::align(ft, j = 1, align = "left", part = "all")
}

# Set column widths: column 1 gets `prop_used_col_1` of `width_max` inches
# (default: an equal share); the other columns split the rest evenly.
#' @noRd
flextable_autofit <- function(ft,
                              prop_used_col_1 = NULL,
                              width_max = 7) {

  n_cols <- ncol(ft$header$dataset)

  stopifnot(n_cols > 1)

  width_1 <- width_max * (prop_used_col_1 %||% (1 / n_cols))

  width_other <- (width_max - width_1) / (n_cols - 1)

  ft <- flextable::width(ft, width = width_other)
  flextable::width(ft, j = 1, width = width_1)
}

# Row colours for version-diff tables, from GitHub's (Primer) light-theme diff
# colours: line backgrounds for whole rows, and the stronger line-number /
# word-highlight colours for the `change` cell. "mixed" (a code that came and
# went between the first and last compared version) uses Primer's attention
# colour; "unchanged" uses its neutral muted grey, flattened onto white.
.diff_colors <- list(
  row = c(added     = "#dafbe1",  # --diffBlob-additionLine-bgColor
          removed   = "#ffebe9",  # --diffBlob-deletionLine-bgColor
          unchanged = "#eff1f3",  # --bgColor-neutral-muted on white
          mixed     = "#fff8c5"), # --bgColor-attention-muted
  change = c(added     = "#aceebb",  # --diffBlob-additionNum-bgColor
             removed   = "#ffcecb",  # --diffBlob-deletionNum-bgColor
             unchanged = "#eff1f3",
             mixed     = "#f7eea1")  # --display-lemon-bgColor-muted
)

# Classify each row of a version-diff table by comparing the first and last
# compared versions.
.diff_category <- function(d, versions) {
  first <- d[[versions[1L]]]
  last  <- d[[versions[length(versions)]]]
  ifelse(d$change == "unchanged", "unchanged",
         ifelse(!first & last, "added",
                ifelse(first & !last, "removed", "mixed")))
}

# get_version_diffs() output -> styled flextable.
.version_diffs_flextable <- function(d) {
  versions <- grep("^v[0-9]+$", names(d), value = TRUE)
  d <- d[c("definition", "code", versions, "type", "change")]

  ft <- flextable::flextable(d)
  ft <- flextable_polish(ft)
  ft <- flextable_autofit(ft, prop_used_col_1 = 0.4)

  # Colour one category at a time: passing a per-row colour vector to bg()
  # is recycled over cells, not rows, in some flextable versions.
  cat <- .diff_category(d, versions)
  for (k in unique(cat)) {
    rows <- which(cat == k)
    ft <- flextable::bg(ft, i = rows, bg = .diff_colors$row[[k]], part = "body")
    ft <- flextable::bg(ft, i = rows, j = "change", bg = .diff_colors$change[[k]],
                        part = "body")
  }
  ft
}
