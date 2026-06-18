## Preparando seus dados

Esta seção é prática. Você vai sair do **output bruto** do seu programa de GWAS (TASSEL, GAPIT, PLINK) e chegar em um **arquivo pronto** para subir no GWAS Explorer.

### Estrutura mínima do arquivo

O GWAS Explorer precisa de **quatro colunas obrigatórias** em qualquer arquivo de entrada:

| Coluna   | O que é                                | Exemplo            |
|----------|----------------------------------------|--------------------|
| `Marker` | Identificador único do SNP             | `S5_9800931`       |
| `Chr`    | Cromossomo onde o SNP está             | `Chr5`, `5`, `Os05`|
| `Pos`    | Posição em pares de base no cromossomo | `9800931`          |
| `p`      | P-valor da associação                  | `4.2e-06`          |

Colunas adicionais como `MAF` (frequência do alelo menor), `Effect` (tamanho do efeito do SNP) ou `Trait` (característica analisada) são **opcionais** — se estiverem presentes, aparecem na tabela de SNPs significativos.

### Tolerância a nomes de colunas

O app é flexível: aceita variações comuns dos nomes. Por exemplo, todas essas grafias serão **reconhecidas como o p-valor**:

`p`, `P`, `pvalue`, `p_value`, `P.value`, `p_wald`, `p_lrt`

Da mesma forma, `position`, `pos`, `BP` ou `ps` são todos aceitos como posição. **Você não precisa renomear manualmente** os arquivos de saída do TASSEL ou GAPIT — o app entende.

### Saída do TASSEL

No TASSEL, depois de rodar o modelo GLM ou MLM:

1. Vá em **Results → Export Data**
2. Escolha o nó com seus resultados de associação
3. Salve como **tab-delimited text** (`.txt`)
4. No GWAS Explorer, selecione o formato **"TASSEL (GLM / MLM)"**

A saída típica do TASSEL tem colunas como `Marker`, `Chr`, `Pos`, `p`, `add_p` (p-valor aditivo), `dom_p` (p-valor de dominância). O app usa `p` por padrão.

### Saída do GAPIT

O GAPIT gera vários arquivos automaticamente em formato CSV. O que você precisa é:

```
GAPIT.Association.GWAS_Results.MLM.[NOME_DA_TRAIT].csv
```

Por exemplo, se você rodou GAPIT em uma trait chamada `EarHT`, o arquivo será `GAPIT.Association.GWAS_Results.MLM.EarHT.csv`.

No GWAS Explorer, selecione o formato **"GAPIT"**.

### Saída do PLINK

O PLINK gera arquivos `.assoc` (regressão linear/logística), `.qassoc` (quantitativo) ou `.linear` (modelo linear). Selecione o formato **"PLINK (.assoc)"** no app.

### CSV genérico

Se seu arquivo veio de outro software ou foi gerado manualmente, salve como **CSV** com as quatro colunas obrigatórias (`Marker`, `Chr`, `Pos`, `p`) e selecione **"Generic CSV"** no app.

### Verificações antes de subir

Antes de carregar seu arquivo, é boa prática verificar:

1. **P-valores válidos**: todos os valores devem estar entre 0 e 1 (exclusive). Zeros absolutos geralmente indicam erro de cálculo numérico
2. **Cromossomos consistentes**: misturar `Chr1` e `1` na mesma coluna não quebra o app, mas atrapalha a leitura visual
3. **Posições positivas**: nenhum valor negativo ou zero em `Pos`
4. **Sem duplicatas**: SNPs duplicados aparecem como pontos sobrepostos no Manhattan plot, distorcendo a contagem
5. **Codificação UTF-8 ou ASCII**: arquivos com acentos em encoding errado (especialmente vindos do Excel em Windows) podem causar erros de leitura

### Um exemplo concreto

O **3000 Rice Genomes Project** liberou publicamente um conjunto enorme de SNPs em 3000 acessos de arroz. Se você quiser praticar com dados reais (de verdade, sem simulação), pode baixar resultados de GWAS publicados sobre essa coleção em repositórios como o GWAS Atlas. Os arquivos geralmente vêm em CSV com colunas `SNP`, `chr`, `bp`, `pvalue` — basta selecionar "Generic CSV" no app e ele reconhece os aliases automaticamente.

### Tamanho do arquivo

O GWAS Explorer foi testado com até cerca de 20 mil SNPs sem problemas de desempenho. Arquivos maiores (centenas de milhares de SNPs, como em GWAS humanos) podem deixar o app lento — para esses casos, recomendamos filtrar o arquivo antes para reter apenas SNPs com p-valor menor que 0,1 ou similar.

---

### 📚 Para aprofundar

- **Bradbury, P.J. et al. (2007).** TASSEL: Software for association mapping of complex traits in diverse samples. *Bioinformatics*, 23(19), 2633-2635.
  *Documentação completa do TASSEL, incluindo formatos de entrada e saída.*

- **Lipka, A.E. et al. (2012).** GAPIT: genome association and prediction integrated tool. *Bioinformatics*, 28(18), 2397-2399. [doi.org/10.1093/bioinformatics/bts444](https://doi.org/10.1093/bioinformatics/bts444)
  *Manual oficial do GAPIT explicando os arquivos de saída gerados automaticamente.*

- **Purcell, S. et al. (2007).** PLINK: a tool set for whole-genome association and population-based linkage analyses. *American Journal of Human Genetics*, 81(3), 559-575.
  *Referência original do PLINK; útil para entender os formatos `.assoc` e `.qassoc`.*
