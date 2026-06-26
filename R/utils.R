# R/utils.R --------------------------------------------------------------
# Data parsing, validation, and summary utilities

# ---- parse_gwas_file ---------------------------------------------------
#
# Reads a GWAS results file and returns a normalised tibble with columns:
#   Marker (chr), Chr (chr), Pos (dbl), p (dbl)
# Plus any additional columns present in the source file.
#
# Supported formats: TASSEL GLM/MLM, GAPIT, PLINK, Generic CSV.

parse_gwas_file <- function(file_path, format = "tassel") {

  raw <- tryCatch(
    switch(format,
      tassel  = read_tsv(file_path, show_col_types = FALSE, comment = "##"),
      gapit   = read_csv(file_path, show_col_types = FALSE, comment = "#"),
      plink   = read_table(file_path, col_types = cols()),
      generic = read_csv(file_path, show_col_types = FALSE, comment = "#")
    ),
    error = function(e) {
      stop("N\u00e3o foi poss\u00edvel ler o arquivo. Verifique se o formato est\u00e1 correto.\n",
           "Erro: ", conditionMessage(e))
    }
  )

  # Normalise column names (lowercase, strip dots/spaces)
  colnames(raw) <- tolower(trimws(colnames(raw)))
  colnames(raw) <- gsub("[ .]", "_", colnames(raw))

  # Map common aliases → canonical names
  alias_map <- c(
    snp       = "marker", rs        = "marker", snp_id = "marker",
    locus     = "marker",
    chromosome = "chr",   chrom     = "chr",
    position   = "pos",   bp        = "pos",    ps     = "pos",
    pvalue     = "p",     p_value   = "p",      p_wald = "p",
    p_lrt      = "p",     p_score   = "p",      p_fdr  = "p"
  )
  for (alias in names(alias_map)) {
    canonical <- alias_map[[alias]]
    if (alias %in% colnames(raw) && !canonical %in% colnames(raw)) {
      colnames(raw)[colnames(raw) == alias] <- canonical
    }
  }

  # Validate required columns
  required <- c("marker", "chr", "pos", "p")
  missing  <- setdiff(required, colnames(raw))
  if (length(missing) > 0L) {
    stop(
      "Colunas obrigat\u00f3rias n\u00e3o encontradas: ", paste(missing, collapse = ", "), "\n",
      "Colunas presentes: ", paste(colnames(raw), collapse = ", ")
    )
  }

  # Cast, filter and return
  raw %>%
    mutate(
      pos = suppressWarnings(as.numeric(pos)),
      p   = suppressWarnings(as.numeric(p))
    ) %>%
    filter(!is.na(p), p > 0, p <= 1, !is.na(pos), !is.na(marker)) %>%
    rename(Marker = marker, Chr = chr, Pos = pos) %>%
    as_tibble()
}

# ---- compute_lambda ----------------------------------------------------
# Genomic inflation factor (λ) from a vector of raw p-values.
# λ = median(χ²_obs) / median(χ²_expected_under_null)

compute_lambda <- function(pvals) {
  pvals <- pvals[!is.na(pvals) & pvals > 0 & pvals <= 1]
  if (length(pvals) < 2L) return(NA_real_)
  chi2_obs <- qchisq(1 - pvals, df = 1L)
  round(median(chi2_obs, na.rm = TRUE) / qchisq(0.5, df = 1L), 3)
}

# ---- get_significant_snps ----------------------------------------------

get_significant_snps <- function(gwas_df, threshold_logp = 5) {
  gwas_df %>%
    filter(p <= 10^(-threshold_logp)) %>%
    arrange(p)
}

# ---- summarise_gwas ----------------------------------------------------

summarise_gwas <- function(gwas_df, sig_logp = 5, sug_logp = 3) {
  sig_t <- 10^(-sig_logp)
  sug_t <- 10^(-sug_logp)
  list(
    n_snps = nrow(gwas_df),
    n_sig  = sum(gwas_df$p <= sig_t, na.rm = TRUE),
    n_sug  = sum(gwas_df$p <= sug_t & gwas_df$p > sig_t, na.rm = TRUE),
    n_chrs = n_distinct(gwas_df$Chr),
    min_p  = min(gwas_df$p, na.rm = TRUE),
    lambda = compute_lambda(gwas_df$p)
  )
}

# ---- chr_to_int --------------------------------------------------------
# Extracts an integer from chromosome labels like "1", "Chr1", "Ca01", etc.

chr_to_int <- function(chr_vec) {
  # Extrai numero base do nome do cromossomo
  base_num <- suppressWarnings(as.integer(stringr::str_extract(chr_vec, "[0-9]+")))
  
  # Para C. arabica: distinguir subgenomas c (canephora) e e (eugenioides)
  # Chr1c-Chr11c -> 1-11, Chr1e-Chr11e -> 12-22
  is_eugenioides <- grepl("e$", chr_vec, ignore.case = FALSE)
  result <- ifelse(is_eugenioides & !is.na(base_num), base_num + 11L, base_num)
  
  as.integer(result)
}
