# global.R ---------------------------------------------------------------
# GWAS Explorer — Interactive GWAS results visualization
# Author: Mauro Villela
# Stack:  R · Shiny · bslib · plotly · DT

suppressPackageStartupMessages({
  library(shiny)
  library(bslib)
  library(tidyverse)
  library(plotly)
  library(DT)
})

source("R/utils.R")
source("R/plots.R")
source("R/render_md.R")
# ---- Constants ---------------------------------------------------------

APP_TITLE <- "GWAS Explorer"
APP_VERSION <- "0.2.0"

SUPPORTED_FORMATS <- c(
  "TASSEL (GLM / MLM)" = "tassel",
  "GAPIT"              = "gapit",
  "PLINK (.assoc)"     = "plink",
  "Generic CSV"        = "generic"
)

# Default thresholds expressed as -log10(p)
DEFAULT_SIG <- 5    # 1e-5  (appropriate for small N, e.g. 67 accessions)
DEFAULT_SUG <- 3    # 1e-3

# ---- Example data ------------------------------------------------------
# Run data/simulate_gwas.R once to generate the .rds file.
# A tiny inline fallback is used on a fresh clone before that step.

if (file.exists("data/example_gwas.rds")) {
  EXAMPLE_DATA <- readRDS("data/example_gwas.rds")
} else {
  set.seed(42)
  n <- 800L
  chr_ids <- rep(paste0("Chr", 1:11), length.out = n)
  EXAMPLE_DATA <- tibble(
    Marker = paste0(chr_ids, "_", sample(1:50e6, n)),
    Chr    = chr_ids,
    Pos    = sample(1:50e6, n),
    p      = c(runif(n - 8L), 10^-runif(8L, 3, 6)),
    MAF    = round(runif(n, 0.05, 0.5), 3),
    Effect = round(rnorm(n, 0, 0.25), 4)
  )
  message("[gwas-explorer] data/example_gwas.rds not found — using inline fallback.")
  message("  Run data/simulate_gwas.R to generate the realistic demo dataset.")
}
