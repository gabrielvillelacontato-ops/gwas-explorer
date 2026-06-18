## Próximos passos após o GWAS

Você encontrou um pico no Manhattan plot. E agora? **O GWAS é apenas o começo da história.**

Encontrar um SNP estatisticamente associado a uma característica é o equivalente a colocar uma estrela em um mapa enorme — você sabe que ali tem algo interessante, mas ainda não sabe **o que** é. Esta seção mostra os caminhos típicos para responder essa pergunta.

### Etapa 1 — Identificar os genes próximos

Um SNP raramente é o **causador** direto de uma característica. Na maioria das vezes, ele está **fisicamente próximo** ao gene de fato responsável, em desequilíbrio de ligação com ele.

A primeira coisa a fazer é olhar quais genes estão na vizinhança do SNP. Tipicamente:

- **Janela curta** (10 a 50 kb ao redor do SNP): genes mais prováveis em populações com LD baixo (espécies de polinização cruzada, populações naturais)
- **Janela ampla** (até 250 kb): em culturas autógamas e elites com pouca diversidade, onde o LD se estende por distâncias maiores

Você usa o arquivo de **anotação do genoma de referência** (formato GFF ou GTF) para listar os genes nesse intervalo. Repositórios como Phytozome, Ensembl Plants e o NCBI Genome têm essas anotações para a maioria das culturas.

### Etapa 2 — Priorizar os candidatos

Listar 30 genes em uma janela não resolve nada por si só. Você precisa **priorizar**. Critérios úteis:

1. **Função do gene**: o gene tem alguma anotação funcional ligada à característica? Genes anotados com funções biologicamente plausíveis para a característica em estudo merecem investigação prioritária
2. **Expressão tecidual**: o gene é expresso no tecido relevante? Bancos de dados como Phytozome, Coffee Genome Hub ou Soybase fornecem perfis de expressão
3. **Variação na região codificante**: o SNP altera um aminoácido (variante *missense*) ou está em região regulatória?
4. **Conservação evolutiva**: o gene tem ortólogos com função conhecida em outras espécies?

### Etapa 3 — Validar experimentalmente

Aqui você sai da bioinformática e volta para a biologia molecular. As estratégias clássicas são:

- **Genotipagem direcionada**: confirme o SNP em uma população independente
- **Expressão diferencial**: compare a expressão do gene candidato entre indivíduos de fenótipos contrastantes (RT-qPCR ou RNA-seq)
- **Edição gênica**: CRISPR-Cas9 para nocautear o gene candidato e verificar o efeito fenotípico
- **Transformação genética**: introduzir o alelo "favorável" em um background suscetível e ver se a característica se altera

A escolha entre essas abordagens depende muito da espécie. Em arroz e *Arabidopsis* o CRISPR é rotina; em culturas perenes como café e cacau, edição gênica ainda é tecnicamente desafiadora.

### Etapa 4 — Aplicar em melhoramento (MAS)

Se o gene foi validado, ele vira um **marcador molecular** que o melhorista pode usar em **seleção assistida por marcadores** (MAS). Isso significa que, em vez de esperar a planta crescer e medir o fenótipo, o melhorista extrai DNA de uma folha jovem e seleciona indivíduos com o alelo favorável.

Isso acelera o melhoramento drasticamente — especialmente em culturas perenes, onde uma geração leva anos.

### Um exemplo concreto

Um caso clássico que ilustra todo o ciclo é o gene *Vgt1* (*Vegetative to generative transition 1*) em milho. Mapeamentos de associação identificaram, no cromossomo 8, uma região fortemente associada ao tempo de florescimento — uma característica crucial para adaptação a diferentes latitudes e regimes climáticos.

Os passos seguintes seguiram o roteiro completo: (1) janelas de LD foram analisadas para reduzir a região candidata, (2) anotação genômica revelou um gene homólogo ao *AP2* de *Arabidopsis*, conhecido por controlar transição floral, (3) análise de expressão mostrou diferenças entre alelos precoces e tardios, e (4) a variante causal acabou sendo identificada como uma inserção de transposon **a montante** do gene — em região regulatória, não codificante.

Hoje, *Vgt1* é usado rotineiramente em programas de melhoramento de milho para selecionar genótipos adaptados a regiões específicas, e o caso é citado como exemplo paradigmático de que **a variante causal nem sempre é o SNP que aparece no Manhattan plot** — frequentemente é uma variante próxima, em LD com o marcador detectado.

Esse é o ciclo típico: o GWAS é a porta de entrada, mas o trabalho real está na sequência.

### O que o GWAS Explorer não faz (ainda)

O GWAS Explorer atual foca em **visualização e exploração de resultados**. Para os próximos passos descritos acima, você precisa de outras ferramentas:

- **Anotação genômica**: GenomeBrowser (UCSC), Ensembl Plants, JBrowse
- **Função gênica**: Phytozome, KEGG, Gene Ontology
- **Modelos 3D de proteínas**: AlphaFold Protein Structure Database

Está no roadmap do GWAS Explorer adicionar integração com anotação para *Coffea arabica*, permitindo que ao clicar em um SNP no Manhattan plot, o painel lateral mostre genes próximos automaticamente. **Essa é uma funcionalidade planejada para a próxima versão.**

---

### 📚 Para aprofundar

- **Salvi, S. et al. (2007).** Conserved noncoding genomic sequences associated with a flowering-time quantitative trait locus in maize. *PNAS*, 104(27), 11376-11381. [doi.org/10.1073/pnas.0704145104](https://doi.org/10.1073/pnas.0704145104)
  *Estudo paradigmático que identificou o gene Vgt1 em milho — caso clássico de ciclo completo GWAS → validação → uso em melhoramento.*

- **Kanovská, I.; Biová, J.; Škrabišová, M. (2024).** Post-GWAS strategies in causal gene identification. *Current Opinion in Plant Biology*.
  *Revisão dedicada ao "depois do GWAS" — leitura essencial para quem quer ir além do Manhattan plot.*

- **Frontiers in Plant Science (2024).** Reviewing the essential roles of remote phenotyping, GWAS and explainable AI in practical marker-assisted selection for drought-tolerant winter wheat breeding. [doi.org/10.3389/fpls.2024.1319938](https://doi.org/10.3389/fpls.2024.1319938)
  *Conecta GWAS com seleção assistida na prática, com exemplo em trigo tolerante à seca.*

- **Biological Research (2024), 57:80.** Advances in genomic tools for plant breeding: harnessing DNA molecular markers, genomic selection, and genome editing.
  *Panorama integrado de GWAS, MAS, GS e edição gênica como ferramentas complementares.*
