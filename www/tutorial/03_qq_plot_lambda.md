## O QQ plot e o fator λ de inflação

Se o Manhattan plot responde "onde estão os sinais?", o **QQ plot** responde uma pergunta mais sutil e igualmente importante: **"a análise foi bem feita?"**

QQ é abreviação de *Quantile-Quantile* — quantil-quantil. É um gráfico de diagnóstico que compara **os p-valores que você obteve** com **os p-valores que você deveria obter se nada estivesse acontecendo** (a chamada hipótese nula).

### A intuição

Imagine que você roda um GWAS em uma característica completamente aleatória — digamos, número de letras no nome de cada planta. Não existe base genética para isso. Mesmo assim, você está testando milhares de SNPs, e por puro acaso uns 5% deles vão dar p-valor menor que 0,05.

Isso é o esperado sob a hipótese nula. Se você ordenar todos os p-valores do menor pro maior e plotar contra o que se esperaria de uma distribuição uniforme, vai sair uma **linha reta**.

Agora, em um GWAS real com sinais verdadeiros, o que muda? Os SNPs **realmente associados** à característica vão ter p-valores muito menores que o esperado. No QQ plot, isso aparece como **pontos subindo acima da linha** no canto superior direito do gráfico.

### Como ler o QQ plot do GWAS Explorer

- **Linha vermelha tracejada (diagonal)**: a expectativa sob a hipótese nula. Se nenhum SNP estivesse associado, todos os pontos deveriam cair nessa linha.
- **Faixa lilás sombreada**: intervalo de confiança 95% sob a hipótese nula. Pontos dentro dessa faixa são consistentes com "ausência de associação".
- **Pontos roxos**: seus p-valores observados, ordenados do menor (canto inferior esquerdo) para o maior (canto superior direito).

**O cenário ideal:**

- Os pontos seguem a linha vermelha na **maior parte do gráfico** (a maioria dos SNPs não tem associação real)
- Os pontos **se desviam da linha para cima no canto superior direito** (os poucos SNPs com associação real puxam os p-valores extremos pra cima)
- A "decolagem" é gradual, não abrupta

### O fator λ (lambda) de inflação

O **λ (lambda) genômico** é um número único que resume o QQ plot inteiro. Ele mede o quanto, em média, seus p-valores estão "inflados" em relação ao esperado.

A fórmula:

```
λ = mediana(χ²observada) / mediana(χ²esperada sob a nula)
```

Em termos práticos, o λ pega a "altura média" dos seus p-valores e divide pela altura esperada se nada estivesse acontecendo.

**Interpretação:**

| Valor de λ          | Interpretação                                                  |
|---------------------|---------------------------------------------------------------|
| **λ ≈ 1,00**        | Análise bem calibrada. Resultados confiáveis.                |
| **λ entre 1,00 e 1,05** | Pequena inflação aceitável; não é motivo de preocupação.    |
| **λ entre 1,05 e 1,10** | Inflação moderada. Verifique se incluiu PCAs ou matriz de parentesco. |
| **λ > 1,10**        | Inflação significativa. Há algo errado — provavelmente estrutura populacional não controlada. |
| **λ < 0,95**        | Deflação. Modelo super-corrigido; você pode estar perdendo sinais reais. |

### Por que λ pode ficar inflado?

As causas mais comuns:

1. **Estratificação populacional**: sua amostra inclui subpopulações com origens geográficas distintas, e isso cria associações espúrias em todo o genoma
2. **Parentesco oculto**: alguns indivíduos da sua amostra são mais aparentados do que você sabia
3. **Estatística mal calibrada**: o modelo de teste não está adequado para a estrutura dos seus dados
4. **Viés técnico sistemático**: problemas na genotipagem (lotes diferentes de sequenciamento, por exemplo)

A solução padrão é **incluir componentes principais (PCs) como covariáveis** no modelo de GWAS para corrigir estrutura populacional, e usar **modelos lineares mistos (MLM)** que incorporam matriz de parentesco (kinship) para corrigir relacionamentos.

### Um exemplo concreto

Em GWAS clássicos de milho com o painel de diversidade NAM (*Nested Association Mapping*), λ esperado fica próximo de 1,02-1,05 quando o modelo MLM inclui ao menos 3 componentes principais e a matriz de kinship. Se um pesquisador roda um modelo simples GLM sem essas correções no NAM, λ pode disparar para 1,3 ou mais — sinal claro de que a estrutura populacional do milho (subpopulações tropical, temperate e mista) está dominando o resultado.

### Uma armadilha importante

Um λ próximo de 1 **não garante** que seu GWAS está perfeito — só garante que a calibração estatística está OK. Você ainda precisa de tamanho amostral adequado, fenotipagem de qualidade e marcadores bem distribuídos para detectar sinais reais. **λ controla falsos positivos, não detecta falsos negativos.**

---

### 📚 Para aprofundar

- **Devlin, B.; Roeder, K. (1999).** Genomic control for association studies. *Biometrics*, 55(4), 997-1004.
  *Artigo seminal que introduziu o conceito de fator de inflação genômica (λ). Leitura obrigatória para entender a origem do conceito.*

- **Voorman, A. et al. (2011).** Behavior of QQ-Plots and Genomic Control in Studies of Gene-Environment Interaction. *PLoS ONE*, 6(5), e19416. [doi.org/10.1371/journal.pone.0019416](https://doi.org/10.1371/journal.pone.0019416)
  *Mostra como QQ plots podem enganar quando há interação gene-ambiente; alerta importante.*

- **Lipka, A.E. et al. (2012).** GAPIT: genome association and prediction integrated tool. *Bioinformatics*, 28(18), 2397-2399. [doi.org/10.1093/bioinformatics/bts444](https://doi.org/10.1093/bioinformatics/bts444)
  *Software amplamente usado para GWAS em plantas; implementa MLM com kinship por padrão, justamente para controlar λ.*
