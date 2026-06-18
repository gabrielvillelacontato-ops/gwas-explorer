# server.R ---------------------------------------------------------------
# GWAS Explorer — Server logic

server <- function(input, output, session) {

  # ===== Reactive: load GWAS data =======================================

  gwas_data <- reactive({
    # Priority 1: uploaded file
    if (!is.null(input$gwas_file)) {
      tryCatch(
        parse_gwas_file(input$gwas_file$datapath, format = input$file_format),
        error = function(e) {
          showNotification(
            ui       = tagList(icon("triangle-exclamation"), " ", conditionMessage(e)),
            type     = "error",
            duration = 10
          )
          NULL
        }
      )
    # Priority 2: example data button
    } else if (input$use_example > 0L) {
      showNotification("Dataset de exemplo carregado.", type = "message", duration = 3)
      EXAMPLE_DATA
    # Default: nothing loaded
    } else {
      NULL
    }
  }) %>%
    bindEvent(input$gwas_file, input$use_example, ignoreInit = FALSE)

  # Thresholds as -log10 values (from sliders)
  sig_t <- reactive(input$sig_threshold)
  sug_t <- reactive(input$sug_threshold)

  # ===== Reactive: significant & suggestive SNPs ========================

  sig_snps <- reactive({
    req(gwas_data())
    get_significant_snps(gwas_data(), threshold_logp = sig_t())
  })

  # ===== Reactive: summary stats ========================================

  gwas_summary <- reactive({
    req(gwas_data())
    summarise_gwas(gwas_data(), sig_logp = sig_t(), sug_logp = sug_t())
  })

  # ===== Value boxes ====================================================

  output$vb_n_snps <- renderText({
    if (is.null(gwas_data())) return("\u2014")
    format(gwas_summary()$n_snps, big.mark = ",")
  })

  output$vb_n_sig <- renderText({
    if (is.null(gwas_data())) return("\u2014")
    gwas_summary()$n_sig
  })

  output$vb_n_sug <- renderText({
    if (is.null(gwas_data())) return("\u2014")
    gwas_summary()$n_sug
  })

  output$vb_lambda <- renderText({
    if (is.null(gwas_data())) return("\u2014")
    lam <- gwas_summary()$lambda
    if (is.na(lam)) return("n/a")
    lam
  })

 

  # ===== Plots ==========================================================

  output$manhattan_plot <- renderPlotly({
    req(gwas_data())
    # Highlight top 5 SNPs in the Manhattan plot
    top5 <- gwas_data() %>% slice_min(p, n = 5) %>% pull(Marker)
    make_manhattan(
      gwas_df        = gwas_data(),
      sig_logp       = sig_t(),
      sug_logp       = sug_t(),
      highlight_snps = top5
    )
  })

  output$qq_plot <- renderPlotly({
    req(gwas_data())
    make_qq(gwas_data())
  })

  # ===== Tables =========================================================

  output$top_snps_table <- renderDT({
    req(gwas_data())
    gwas_data() %>%
      slice_min(p, n = 10L) %>%
      mutate(
        p      = formatC(p, format = "e", digits = 3),
        Pos    = format(Pos, big.mark = ",", scientific = FALSE)
      ) %>%
      select(any_of(c("Marker", "Chr", "Pos", "p", "MAF", "Effect"))) %>%
      datatable(
        rownames  = FALSE,
        options   = list(dom = "t", pageLength = 10, ordering = FALSE),
        class     = "table-sm table-hover",
        selection = "none"
      )
  })

  output$table_header <- renderUI({
    req(gwas_data())
    n <- gwas_summary()$n_sig
    paste0("SNPs significativos (p \u2264 10\u207b", sig_t(), ") \u2014 ", n, " encontrados")
  })

  output$sig_snp_table <- renderDT({
    req(sig_snps())
    if (nrow(sig_snps()) == 0L) {
      return(datatable(
        tibble(mensagem = "Nenhum SNP passa pelo limiar atual."),
        rownames = FALSE, options = list(dom = "t")
      ))
    }
    sig_snps() %>%
      mutate(
        p   = formatC(p, format = "e", digits = 3),
        Pos = format(Pos, big.mark = ",", scientific = FALSE)
      ) %>%
      select(any_of(c("Marker", "Chr", "Pos", "p", "MAF", "Effect"))) %>%
      datatable(
        rownames = FALSE,
        filter   = "top",
        options  = list(
          pageLength = 20,
          scrollX    = TRUE,
          dom        = "Bfrtip",
          buttons    = c("copy", "csv")
        ),
        extensions = "Buttons",
        class      = "table-sm table-hover"
      )
  })

  # ===== Sidebar: conditional download buttons ==========================

  output$sidebar_exports <- renderUI({
    req(gwas_data())
    tagList(
      h6("Exportar", style = "color: var(--bs-secondary)"),
      downloadButton(
        "dl_sig_csv",
        label = tagList(icon("file-csv"), " SNPs significativos"),
        class = "btn-outline-primary btn-sm w-100 mb-1"
      ),
      downloadButton(
        "dl_all_csv",
        label = tagList(icon("file-csv"), " Full results"),
        class = "btn-outline-secondary btn-sm w-100"
      )
    )
  })

  output$dl_sig_csv <- downloadHandler(
    filename = function() paste0("gwas_sig_snps_", Sys.Date(), ".csv"),
    content  = function(file) write_csv(sig_snps(), file)
  )

  output$dl_all_csv <- downloadHandler(
    filename = function() paste0("gwas_results_", Sys.Date(), ".csv"),
    content  = function(file) write_csv(gwas_data(), file)
  )
}
