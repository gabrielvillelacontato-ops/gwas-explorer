# R/render_md.R -----------------------------------------------------------
# Renderiza um arquivo Markdown para HTML usando commonmark (sem dependência
# do pacote 'markdown', que tem problemas de instalação no Windows).

include_markdown <- function(path) {
  if (!file.exists(path)) {
    return(shiny::HTML(paste0("<em>Arquivo não encontrado: ", path, "</em>")))
  }
  md_text   <- paste(readLines(path, encoding = "UTF-8", warn = FALSE),
                     collapse = "\n")
  html_text <- commonmark::markdown_html(md_text, extensions = TRUE)
  shiny::HTML(html_text)
}