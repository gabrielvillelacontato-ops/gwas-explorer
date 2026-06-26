# data/test_datasets/generate_synthetic_gwas.R --------------------------------
# Gerador generico de datasets GWAS sinteticos para validacao do app.
#
# Os datasets gerados injetam QTNs conhecidos em posicoes exatas dentro de um
# background ruidoso, permitindo validar pipelines de anotacao genomica contra
# resultados publicados na literatura.
#
# USO:
#   source("R/annotation.R")  # precisa estar carregado
#   source("data/test_datasets/generate_synthetic_gwas.R")
#
#   config <- list(
#     genome             = "ET39",
#     n_total            = 11290,
#     noise_distribution = list(shape1 = 0.3, shape2 = 3),
#     seed               = 42,
#     qtns = data.frame(
#       Marker = c("snp_1", "snp_2"),
#       Chr    = c("Chr1c", "Chr2e"),
#       Pos    = c(1000000L, 32000000L),
#       p      = c(1e-8, 1e-12)
#     )
#   )
#
#   generate_synthetic_gwas(
#     config      = config,
#     output_file = "data/test_datasets/outputs/my_test.csv",
#     header_lines = c("# Meu dataset", "# Citacao opcional")
#   )

# ---- Funcao auxiliar: extrai tamanhos de cromossomo do .rds de anotacao ----

get_chr_sizes_from_annotation <- function(genome) {
  
  if (!exists("load_annotation")) {
    stop("Funcao load_annotation() nao encontrada. ",
         "Execute source(\"R/annotation.R\") antes.")
  }
  
  ann <- load_annotation(genome)
  
  # Calcula tamanho de cada cromossomo (max position observada)
  chr_sizes <- ann[, list(size = max(end)), by = chr]
  
  # Remove cromossomos nao-canonicos (Chr0, ChrUnknown, scaffolds soltos)
  chr_sizes <- chr_sizes[!grepl("Unknown|^Chr0$|scaffold|HRSCAF", chr,
                                ignore.case = TRUE)]
  
  setNames(chr_sizes$size, chr_sizes$chr)
}

# ---- Funcao auxiliar: gera SNPs background para um cromossomo --------------

generate_background_chr <- function(chr, n, max_pos, noise_dist) {
  positions <- sort(sample.int(max_pos, n, replace = FALSE))
  # Despacha distribuicao do ruido conforme tipo configurado
  if (is.null(noise_dist$type) || noise_dist$type == "uniform") {
    # Uniforme [0,1]: comportamento esperado de GWAS sob hipotese nula
    p_values <- runif(n)
  } else if (noise_dist$type == "beta") {
    # Beta: util quando se quer simular GWAS com inflacao genomica
    p_values <- rbeta(n, shape1 = noise_dist$shape1, shape2 = noise_dist$shape2)
  } else {
    stop("Tipo de distribuicao desconhecido: ", noise_dist$type,
         ". Use 'uniform' ou 'beta'.")
  }
  
  data.frame(
    Marker = paste0(chr, "_", positions),
    Chr    = chr,
    Pos    = positions,
    p      = p_values,
    stringsAsFactors = FALSE
  )
}

# ---- Funcao auxiliar: valida config antes de gerar -------------------------

validate_config <- function(config) {
  
  required_fields <- c("genome", "n_total", "noise_distribution", "qtns")
  missing <- setdiff(required_fields, names(config))
  if (length(missing) > 0) {
    stop("Config invalido. Campos obrigatorios faltando: ",
         paste(missing, collapse = ", "))
  }
  
  if (!config$genome %in% names(ANNOTATION_GENOMES)) {
    stop("Genoma desconhecido: ", config$genome)
  }
  
  qtns <- config$qtns
  required_cols <- c("Marker", "Chr", "Pos", "p")
  if (!all(required_cols %in% colnames(qtns))) {
    stop("Tabela de QTNs deve ter colunas: ",
         paste(required_cols, collapse = ", "))
  }
  
  if (any(qtns$p < 0 | qtns$p > 1)) {
    stop("p-valores dos QTNs devem estar entre 0 e 1.")
  }
  
  if (any(qtns$Pos < 1)) {
    stop("Posicoes dos QTNs devem ser numeros positivos.")
  }
  
  invisible(TRUE)
}

# ---- Funcao principal: gera dataset sintetico completo ---------------------

generate_synthetic_gwas <- function(config,
                                    output_file,
                                    header_lines = NULL,
                                    verbose = TRUE) {
  
  validate_config(config)
  
  # Reprodutibilidade
  if (!is.null(config$seed)) set.seed(config$seed)
  
  # Carrega tamanhos de cromossomo do .rds
  chr_sizes <- get_chr_sizes_from_annotation(config$genome)
  
  if (verbose) {
    cat("Genoma:", config$genome, "\n")
    cat("Cromossomos detectados:", length(chr_sizes), "\n")
  }
  
  # Quantidade alvo de background = total - QTNs reais
  n_qtns <- nrow(config$qtns)
  n_background <- config$n_total - n_qtns
  
  if (n_background < 0) {
    stop("n_total (", config$n_total, ") menor que numero de QTNs (",
         n_qtns, ").")
  }
  
  # Valida que cada QTN tem cromossomo valido e posicao dentro do range
  qtns <- config$qtns
  for (i in seq_len(nrow(qtns))) {
    chr_i <- qtns$Chr[i]
    pos_i <- qtns$Pos[i]
    
    if (!chr_i %in% names(chr_sizes)) {
      stop("QTN ", qtns$Marker[i], " referencia cromossomo desconhecido: ",
           chr_i)
    }
    if (pos_i > chr_sizes[[chr_i]]) {
      stop("QTN ", qtns$Marker[i], " tem posicao (", pos_i,
           ") maior que o tamanho do cromossomo ", chr_i,
           " (", chr_sizes[[chr_i]], ").")
    }
  }
  
  # Distribui background proporcionalmente ao tamanho de cada cromossomo
  total_size <- sum(chr_sizes)
  snps_per_chr <- vapply(chr_sizes, function(s) {
    as.integer(round(as.double(n_background) * as.double(s) / as.double(total_size)))
  }, integer(1))
  
  # Ajuste fino para total exato
  diff <- n_background - sum(snps_per_chr)
  if (diff != 0) {
    largest_chr <- names(which.max(chr_sizes))
    snps_per_chr[largest_chr] <- snps_per_chr[largest_chr] + diff
  }
  
  if (verbose) {
    cat("Background SNPs:", sum(snps_per_chr), "\n")
    cat("QTNs injetados:", n_qtns, "\n")
    cat("Total final:", sum(snps_per_chr) + n_qtns, "\n\n")
  }
  
  # Gera background
  if (verbose) cat("Gerando background...\n")
  background_list <- lapply(names(chr_sizes), function(chr) {
    n <- snps_per_chr[[chr]]
    generate_background_chr(chr, n, chr_sizes[[chr]],
                            config$noise_distribution)
  })
  background <- do.call(rbind, background_list)
  
  # Combina com QTNs reais
  final <- rbind(background, qtns[, c("Marker", "Chr", "Pos", "p")])
  final <- final[order(final$Chr, final$Pos), ]
  
  if (verbose) {
    cat("\nRange de p-valores:",
        formatC(min(final$p), format = "e", digits = 2), "-",
        formatC(max(final$p), format = "e", digits = 2), "\n")
    
    n_sig <- sum(final$p < 1e-5)
    cat("SNPs com p < 1e-5:", n_sig,
        " (esperado: aprox ", n_qtns, " reais + alguns falsos positivos)\n",
        sep = "")
  }
  
  # Garante que pasta de saida existe
  out_dir <- dirname(output_file)
  if (!dir.exists(out_dir)) dir.create(out_dir, recursive = TRUE)
  
  # Escreve header opcional
  if (!is.null(header_lines)) {
    writeLines(header_lines, output_file)
    suppressWarnings(
      write.table(final, output_file, sep = ",", row.names = FALSE,
                  append = TRUE, col.names = TRUE, quote = FALSE)
    )
  } else {
    write.csv(final, output_file, row.names = FALSE)
  }
  
  if (verbose) {
    cat("\nArquivo salvo:", output_file, "\n")
    cat("Tamanho:", round(file.info(output_file)$size / 1024, 1), "KB\n")
  }
  
  invisible(final)
}

