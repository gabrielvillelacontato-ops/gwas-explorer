# data/simulate_gwas.R --------------------------------------------------
# Generates a realistic demo GWAS dataset modelled on Coffea arabica.
# Run this once before launching the app: source("data/simulate_gwas.R")
#
# Output: data/example_gwas.rds  (read by global.R at startup)
#         data/example_gwas.csv  (shareable flat file)

library(tidyverse)

set.seed(2024L)

# ---- Coffea arabica chromosome sizes (approx. Mb, 11 pseudo-chromosomes) ----
CHR_SIZES <- c(
  Chr01 = 53.8, Chr02 = 47.2, Chr03 = 58.6, Chr04 = 44.1,
  Chr05 = 50.3, Chr06 = 41.9, Chr07 = 39.5, Chr08 = 36.2,
  Chr09 = 43.7, Chr10 = 34.8, Chr11 = 29.4
) * 1e6

N_SNPS <- 6500L   # realistic for 67 accessions after quality filtering

# ---- True signals to inject (mimics caffeine GWAS hits) ----------------
TRUE_SIGNALS <- tribble(
  ~chr_name, ~peak_pos,  ~effect_logp, ~peak_width,
  "Chr05",   9.80e6,     5.8,          1.5e6,      # SFT2-like locus (primary)
  "Chr09",   22.35e6,    4.3,          1.0e6,      # secondary hit
  "Chr03",   41.10e6,    3.6,          0.8e6       # suggestive
)

# ---- Simulate SNP positions -------------------------------------------
snp_list <- imap_dfr(CHR_SIZES, function(size, chr_name) {
  n_chr <- round(N_SNPS * size / sum(CHR_SIZES))
  tibble(
    Chr = chr_name,
    Pos = sort(sample(seq(1e5, size - 1e5), n_chr))
  )
}) %>%
  mutate(
    Marker = paste0(Chr, "_", Pos),
    MAF    = round(runif(n(), 0.05, 0.49), 3),
    Effect = round(rnorm(n(), 0, 0.22), 4),
    p      = runif(n())   # start with uniform null
  )

# ---- Inject true signals (distance-decay Gaussian) --------------------
for (i in seq_len(nrow(TRUE_SIGNALS))) {
  sig  <- TRUE_SIGNALS[i, ]
  idx  <- which(snp_list$Chr == sig$chr_name)
  dist <- abs(snp_list$Pos[idx] - sig$peak_pos)
  in_window <- dist < sig$peak_width * 3

  if (!any(in_window)) next

  idx_window <- idx[in_window]
  dist_norm  <- dist[in_window] / sig$peak_width

  # Gaussian decay from peak; add noise
  peak_logp  <- sig$effect_logp * exp(-0.5 * dist_norm^2) +
                rnorm(sum(in_window), 0, 0.25)

  snp_list$p[idx_window] <- pmin(
    snp_list$p[idx_window],
    10^(-pmax(peak_logp, 0))
  )
}

# ---- Add TASSEL-style column names & clean up -------------------------
gwas_demo <- snp_list %>%
  mutate(Trait = "Caffeine_content") %>%
  select(Trait, Marker, Chr, Pos, p, MAF, Effect) %>%
  arrange(Chr, Pos)

# ---- Save --------------------------------------------------------------
if (!dir.exists("data")) dir.create("data")

saveRDS(gwas_demo, "data/example_gwas.rds")
write_csv(gwas_demo, "data/example_gwas.csv")

cat(
  "\n[simulate_gwas] Done.\n",
  "  SNPs simulated:", nrow(gwas_demo), "\n",
  "  Significant (p < 1e-5):", sum(gwas_demo$p < 1e-5), "\n",
  "  Suggestive  (p < 1e-3):", sum(gwas_demo$p < 1e-3), "\n",
  "  Files saved: data/example_gwas.rds and .csv\n\n"
)
