# GWAS Explorer

> Visualização interativa de resultados de GWAS, com foco em acessibilidade para estudantes brasileiros de agronomia e ciências da vida.

[![R](https://img.shields.io/badge/R-%3E%3D4.1-276DC3?logo=r)](https://www.r-project.org/)
[![Shiny](https://img.shields.io/badge/Shiny-1.8%2B-blue)](https://shiny.posit.co/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

**Demo ao vivo:** *(em breve no shinyapps.io)*

---

## Sobre o projeto

GWAS Explorer é uma aplicação Shiny para exploração interativa de resultados de **Genome-Wide Association Studies** (GWAS). Aceita arquivos de saída dos pipelines mais comuns (TASSEL, GAPIT, PLINK) e gera visualizações sem exigir conhecimento de programação em R.

Este projeto foi desenvolvido como exercício técnico para portfólio, **inspirado em ferramentas estabelecidas** como [ShinyAIM](https://gitlab.com/wyaseen/shinyaim) (Hussain et al., 2018) e o pacote [qqman](https://github.com/stephenturner/qqman) (Turner, 2018). O diferencial principal é o **foco no público brasileiro**: interface em português e tutorial educacional integrado com 5 seções e bibliografia científica recente, voltado para estudantes que estão começando em GWAS.

## Funcionalidades

| Funcionalidade | Descrição |
|---|---|
| **Múltiplos formatos** | Lê TASSEL (GLM/MLM), GAPIT, PLINK e CSV genérico |
| **Manhattan plot interativo** | Zoom, hover com detalhes, limiares configuráveis |
| **QQ plot diagnóstico** | Banda de confiança 95% e fator de inflação λ |
| **Tabela filtrável** | SNPs significativos com exportação CSV |
| **Tutorial integrado** | 5 seções explicativas com referências científicas |
| **Localização PT-BR** | Interface e conteúdo em português |

## Captura de tela

*(adicione aqui um screenshot do app rodando)*

## Instalação

```r
# 1. Clone o repositório
# git clone https://github.com/gabrielvillelacontato-ops/gwas-explorer.git
# cd gwas-explorer

# 2. Instale as dependências
install.packages(c(
  "shiny", "bslib", "tidyverse",
  "plotly", "DT", "commonmark"
))

# 3. Gere o dataset de exemplo
source("data/simulate_gwas.R")

# 4. Execute o app
shiny::runApp()
```

## Estrutura

```
gwas-explorer/
├── global.R              # Pacotes, constantes, dataset de exemplo
├── ui.R                  # Interface (bslib + accordion)
├── server.R              # Lógica reativa e downloads
├── R/
│   ├── plots.R           # Manhattan e QQ plot (ggplot + plotly)
│   ├── utils.R           # Parser de arquivos, cálculo de λ
│   └── render_md.R       # Renderização de Markdown via commonmark
├── data/
│   └── simulate_gwas.R   # Gerador do dataset demo
├── www/
│   ├── styles.css        # Estilos da aba Tutorial
│   └── tutorial/         # 5 seções em Markdown
└── README.md
```

## Roadmap

Funcionalidades planejadas para versões futuras:

- **Anotação genômica integrada** para *Coffea arabica*: ao clicar em um SNP, exibir genes próximos via GFF de referência
- **Comparação lado a lado** de dois GWAS (traits ou populações distintas)
- **Exportação em alta resolução** (SVG vetorial, PNG 300 dpi)
- **Modo escuro** opcional

## Referências e inspirações

- **Hussain, W. et al. (2018).** ShinyAIM: Shiny-based application of interactive Manhattan plots for longitudinal genome-wide association studies. *Plant Direct*, 2(10), e00091.
- **Turner, S.D. (2018).** qqman: an R package for visualizing GWAS results using Q-Q and manhattan plots. *Journal of Open Source Software*, 3(25), 731.

A bibliografia completa, com 12+ referências cobrindo metodologia GWAS, está disponível na aba **Tutorial** do próprio aplicativo.

## Licença

MIT © Mauro Villela

---

*Construído como projeto de portfólio. Comentários e contribuições são bem-vindos.*