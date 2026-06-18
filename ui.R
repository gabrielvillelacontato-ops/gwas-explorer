# ui.R -------------------------------------------------------------------
# GWAS Explorer — User interface
# Uses bslib >= 0.5.0 (page_sidebar, navset_card_tab, value_box)

ui <- page_sidebar(

  title = tagList(
    APP_TITLE,
    tags$small(
      " · por Mauro Villela",
      style = "font-size: 0.55em; opacity: 0.7; font-weight: 400; margin-left: 8px;"
    )
  ),
  
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "styles.css")
  ),

  theme = bs_theme(
    version   = 5,
    primary   = "#534AB7",
    secondary = "#1D9E75",
    base_font = font_google("Inter")
  ),

  # ---- Sidebar -----------------------------------------------------------
  sidebar = sidebar(
    width = 290,
    open  = "open",

    # -- Data input --
    h6("Dados de entrada", style = "color: var(--bs-secondary); margin-top: .5rem"),

    fileInput(
      "gwas_file",
      label       = NULL,
      accept      = c(".txt", ".csv", ".tsv", ".assoc"),
      placeholder = "TASSEL / GAPIT / PLINK / CSV",
      buttonLabel = "Procurar...",
      width       = "100%"
    ),

    selectInput(
      "file_format",
      label   = "Formato do arquivo",
      choices = SUPPORTED_FORMATS,
      selected = "tassel",
      width   = "100%"
    ),

    actionButton(
      "use_example",
      label = tagList(icon("seedling"), " Carregar dados de exemplo"),
      class = "btn-outline-secondary btn-sm w-100 mb-3"
    ),

    hr(style = "margin: .75rem 0"),

    # -- Thresholds --
    h6("Limiares \u2212log\u2081\u2080(p)",
       style = "color: var(--bs-secondary)"),

    sliderInput(
      "sig_threshold",
      label = "Significância (linha vermelha tracejada)",
      min = 2, max = 12, value = DEFAULT_SIG, step = 0.5,
      width = "100%"
    ),

    sliderInput(
      "sug_threshold",
      label = "Sugestivo (linha laranja pontilhada)",
      min = 2, max = 8, value = DEFAULT_SUG, step = 0.5,
      width = "100%"
    ),

    hr(style = "margin: .75rem 0"),

    # -- Exports (shown only when data is loaded) --
    uiOutput("sidebar_exports")
  ),

  # ---- Main panel --------------------------------------------------------
  navset_card_tab(
    id = "main_tabs",

    # Tab 1 — Overview
    nav_panel(
      title = tagList(icon("table-cells"), " Visão geral"),
      value = "tab_overview",

      layout_columns(
        col_widths = c(3, 3, 3, 3),
        fill = FALSE,

        value_box(
          title    = "SNPs analisados",
          value    = textOutput("vb_n_snps"),
          showcase = icon("dna"),
          theme    = "secondary"
        ),
        value_box(
          title    = "Hits significativos",
          value    = textOutput("vb_n_sig"),
          showcase = icon("star"),
          theme    = "warning"
        ),
        value_box(
          title    = "Hits sugestivos",
          value    = textOutput("vb_n_sug"),
          showcase = icon("circle-exclamation")
        ),
        value_box(
          title    = "Fator \u03bb de infla\u00e7\u00e3o",
          value    = textOutput("vb_lambda"),
          showcase = icon("chart-line"),
          theme    = "primary"
        )
      ),

      # Top SNPs mini-table on overview tab
      card(
        card_header("Top 10 SNPs por p-valor"),
        DTOutput("top_snps_table", height = "auto")
      )
    ),

    # Tab 2 — Manhattan
    nav_panel(
      title = tagList(icon("mountain"), " Manhattan"),
      value = "tab_manhattan",
      card(
        full_screen = TRUE,
        card_header("Manhattan plot interativo \u2014 clique em qualquer ponto para detalhes"),
        plotlyOutput("manhattan_plot", height = "460px")
      )
    ),

    # Tab 3 — QQ Plot
    nav_panel(
      title = tagList(icon("chart-line"), " QQ Plot"),
      value = "tab_qq",
      card(
        full_screen = TRUE,
        card_header(
          "Gr\u00e1fico quantil-quantil (QQ plot)",
          tooltip(
            icon("circle-info"),
            "A faixa sombreada representa o intervalo de confian\u00e7a 95% sob a hip\u00f3tese nula.
             Infla\u00e7\u00e3o (\u03bb > 1,1) pode indicar estratifica\u00e7\u00e3o populacional
             ou modelo mal especificado."
          )
        ),
        plotlyOutput("qq_plot", height = "460px")
      )
    ),

    # Tab 4 — SNP Table
    nav_panel(
      title = tagList(icon("list"), " SNPs significativos"),
      value = "tab_table",
      card(
        card_header(uiOutput("table_header")),
        DTOutput("sig_snp_table")
      )
    )
    ,
    
    # Tab 5 — Tutorial
    nav_panel(
      title = tagList(icon("book-open"), " Tutorial"),
      value = "tab_tutorial",
      
      div(
        style = "max-width: 900px; margin: 0 auto; padding: 1rem;",
        
        h3("Guia introdutório ao GWAS", style = "margin-bottom: 0.25rem;"),
        p(
          style = "color: var(--bs-secondary); font-size: 14px; margin-bottom: 2rem;",
          "Este tutorial foi escrito para estudantes e pesquisadores iniciantes em GWAS. ",
          "Cada seção é independente \u2014 você pode ler na ordem ou pular direto para o que precisa."
        ),
        
        accordion(
          id = "tutorial_accordion",
          open = "sec1",
          
          accordion_panel(
            "1. O que é GWAS?",
            value = "sec1",
            icon = icon("dna"),
            include_markdown("www/tutorial/01_o_que_e_gwas.md")
          ),
          
          accordion_panel(
            "2. Como ler um Manhattan plot",
            value = "sec2",
            icon = icon("mountain"),
            include_markdown("www/tutorial/02_manhattan_plot.md")
          ),
          
          accordion_panel(
            "3. O QQ plot e o fator \u03bb de inflação",
            value = "sec3",
            icon = icon("chart-line"),
            include_markdown("www/tutorial/03_qq_plot_lambda.md")
          ),
          
          accordion_panel(
            "4. Preparando seus dados",
            value = "sec4",
            icon = icon("file-import"),
            include_markdown("www/tutorial/04_preparando_dados.md")
          ),
          
          accordion_panel(
            "5. Próximos passos após o GWAS",
            value = "sec5",
            icon = icon("forward"),
            include_markdown("www/tutorial/05_proximos_passos.md")
          )
        )
      )
    )   
  ),
  
  div(
    style = "padding: 12px 16px; margin-top: 16px; font-size: 12px; color: #888; border-top: 0.5px solid #eee; text-align: right;",
    HTML(paste0(
      "GWAS Explorer v", APP_VERSION,
      " · desenvolvido por <strong>Mauro Villela</strong>",
      " · <a href='https://github.com/SEU-USUARIO/gwas-explorer' target='_blank' style='color:#534AB7;'>código-fonte</a>"
    ))
  )
)