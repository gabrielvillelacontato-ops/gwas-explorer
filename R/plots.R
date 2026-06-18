# R/plots.R --------------------------------------------------------------
# Manhattan and QQ plot functions.
# Both return plotly objects with transparent backgrounds for Shiny embedding.

# ---- make_manhattan ----------------------------------------------------
#
# Args:
#   gwas_df        tibble with columns Marker, Chr, Pos, p (+ optional extras)
#   sig_logp       significance threshold as -log10(p), drawn as dashed red line
#   sug_logp       suggestive threshold as -log10(p), drawn as dotted orange line
#   highlight_snps character vector of Marker IDs to highlight (e.g. top hits)
#   title          plot title
#
# Returns: plotly object

make_manhattan <- function(
    gwas_df,
    sig_logp       = 5,
    sug_logp       = 3,
    highlight_snps = character(0),
    title          = "Manhattan plot"
) {

  # ---- Prepare data ----
  df <- gwas_df %>%
    filter(!is.na(p), p > 0, p <= 1, !is.na(Pos)) %>%
    mutate(
      chr_int = chr_to_int(Chr),
      logp    = -log10(p)
    ) %>%
    filter(!is.na(chr_int)) %>%
    arrange(chr_int, Pos)

  if (nrow(df) == 0L) {
    return(plotly_empty() %>% layout(title = "No data to display"))
  }

  # ---- Cumulative chromosome positions ----
  chr_meta <- df %>%
    group_by(chr_int) %>%
    summarise(chr_max = max(Pos), .groups = "drop") %>%
    arrange(chr_int) %>%
    mutate(
      gap      = 4e6,                                  # inter-chromosome gap
      chr_off  = cumsum(lag(chr_max + gap, default = 0L))
    )

  df <- df %>%
    left_join(chr_meta %>% select(chr_int, chr_off), by = "chr_int") %>%
    mutate(
      pos_cum    = Pos + chr_off,
      color_alt  = factor(chr_int %% 2L),
      highlighted = Marker %in% highlight_snps,
      hover_text = paste0(
        "<b>", Marker, "</b><br>",
        "Chr: ", Chr, " | Pos: ", format(Pos, big.mark = ","), "<br>",
        "p = ", formatC(p, format = "e", digits = 2), "<br>",
        "-log\u2081\u2080(p) = ", round(logp, 3)
      )
    )

  # Chromosome axis labels at midpoints
  chr_labels <- df %>%
    group_by(chr_int, Chr) %>%
    summarise(mid = mean(pos_cum), .groups = "drop") %>%
    arrange(chr_int)

  # ---- Build ggplot ----
  palette <- c("0" = "#1D9E75", "1" = "#534AB7")

  p <- ggplot(df, aes(x = pos_cum, y = logp, color = color_alt,
                       text = hover_text)) +
    # Background SNPs
    geom_point(data = filter(df, !highlighted),
               size = 1.4, alpha = 0.7, shape = 16) +
    # Highlighted SNPs (top hits)
    geom_point(data = filter(df, highlighted),
               size = 3, alpha = 1, shape = 18, color = "#E24B4A") +
    # Threshold lines
    geom_hline(yintercept = sig_logp,
               linetype = "dashed", color = "#E24B4A", linewidth = 0.5) +
    geom_hline(yintercept = sug_logp,
               linetype = "dotted", color = "#BA7517", linewidth = 0.5) +
    # Scales
    scale_color_manual(values = palette, guide = "none") +
    scale_x_continuous(
      breaks = chr_labels$mid,
      labels = chr_labels$Chr,
      expand = expansion(mult = 0.01)
    ) +
    scale_y_continuous(expand = expansion(mult = c(0.02, 0.08))) +
    # Labels
    labs(x = NULL, y = "\u2212log\u2081\u2080(p)", title = title) +
    theme_minimal(base_size = 12) +
    theme(
      legend.position      = "none",
      axis.text.x          = element_text(angle = 45, hjust = 1, size = 9),
      panel.grid.major.x   = element_blank(),
      panel.grid.minor     = element_blank(),
      plot.background      = element_rect(fill = "transparent", color = NA),
      panel.background     = element_rect(fill = "transparent", color = NA),
      plot.title           = element_text(size = 13, face = "plain")
    )

  # ---- Convert to plotly ----
  ggplotly(p, tooltip = "text") %>%
    layout(
      paper_bgcolor = "rgba(0,0,0,0)",
      plot_bgcolor  = "rgba(0,0,0,0)",
      legend        = list(orientation = "h", y = -0.15)
    ) %>%
    config(displayModeBar = TRUE,
           modeBarButtonsToRemove = c("select2d", "lasso2d", "autoScale2d"),
           displaylogo = FALSE)
}

# ---- make_qq -----------------------------------------------------------
#
# Args:
#   gwas_df   tibble with column p
#   title     plot title (auto-includes lambda if omitted)
#
# Returns: plotly object

make_qq <- function(gwas_df, title = NULL) {

  pvals <- gwas_df %>%
    filter(!is.na(p), p > 0, p <= 1) %>%
    pull(p)

  n <- length(pvals)
  if (n < 2L) {
    return(plotly_empty() %>% layout(title = "Not enough p-values"))
  }

  lambda <- compute_lambda(pvals)

  qq_df <- tibble(
    expected = sort(-log10(ppoints(n))),
    observed = sort(-log10(pvals))
  ) %>%
    mutate(
      hover_text = paste0(
        "Observed: ",  round(observed, 3), "<br>",
        "Expected: ",  round(expected, 3)
      )
    )

  plot_title <- title %||%
    paste0("QQ plot \u2014 \u03bb = ", round(lambda, 3))

  # Confidence envelope (95 %) via beta distribution quantiles
  conf_df <- tibble(
    expected = qq_df$expected,
    upper    = -log10(qbeta(0.025, seq_len(n), rev(seq_len(n)))),
    lower    = -log10(qbeta(0.975, seq_len(n), rev(seq_len(n))))
  )

  p <- ggplot() +
    # Confidence band
    geom_ribbon(data = conf_df,
                aes(x = expected, ymin = lower, ymax = upper),
                fill = "#534AB7", alpha = 0.12) +
    # Observed points
    geom_point(data = qq_df,
               aes(x = expected, y = observed, text = hover_text),
               size  = 1.6, alpha = 0.65, color = "#534AB7", shape = 16) +
    # Null diagonal
    geom_abline(slope = 1, intercept = 0,
                linetype = "dashed", color = "#E24B4A", linewidth = 0.5) +
    labs(
      x     = "Expected \u2212log\u2081\u2080(p)",
      y     = "Observed \u2212log\u2081\u2080(p)",
      title = plot_title
    ) +
    theme_minimal(base_size = 12) +
    theme(
      panel.grid.minor = element_blank(),
      plot.background  = element_rect(fill = "transparent", color = NA),
      panel.background = element_rect(fill = "transparent", color = NA),
      plot.title       = element_text(size = 13, face = "plain")
    )

  ggplotly(p, tooltip = "text") %>%
    layout(
      paper_bgcolor = "rgba(0,0,0,0)",
      plot_bgcolor  = "rgba(0,0,0,0)"
    ) %>%
    config(displayModeBar = FALSE)
}
