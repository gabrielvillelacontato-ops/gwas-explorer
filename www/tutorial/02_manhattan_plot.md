## Como ler um Manhattan plot

O Manhattan plot é o gráfico mais icônico do GWAS. O nome vem da semelhança com o **skyline de Manhattan** em Nova York — uma silhueta de prédios altos contra o horizonte, onde os "prédios mais altos" são justamente os SNPs mais interessantes.

Cada ponto no gráfico é **um SNP**. A posição horizontal dele indica **onde no genoma esse SNP está**, e a posição vertical indica **quão forte é a associação estatística** com a característica estudada.

### Os eixos

**Eixo horizontal (X) — Posição no genoma**

Os SNPs são organizados em sequência, cromossomo por cromossomo. As cores alternam (verde e roxo no GWAS Explorer) apenas para ajudar visualmente a distinguir um cromossomo do outro — não têm significado biológico. Em uma soja, por exemplo, você verá 20 grupos de pontos correspondentes aos 20 cromossomos da espécie.

**Eixo vertical (Y) — −log₁₀(p)**

Esse é o ponto que confunde muita gente no início. Em vez de mostrar o p-valor direto (que ficaria todo amontoado perto de zero), mostra-se o **logaritmo negativo do p-valor na base 10**. Isso transforma p-valores pequenos em números grandes e fáceis de ler.

Exemplo prático:

| p-valor       | −log₁₀(p) |
|---------------|-----------|
| 0,1           | 1         |
| 0,01          | 2         |
| 0,001         | 3         |
| 0,0001        | 4         |
| 0,00001       | 5         |
| 0,0000001     | 7         |

Quanto mais alto o ponto, mais significativa a associação. **Pontos lá no topo do gráfico são candidatos fortes**; pontos rasteiros no chão são "ruído estatístico".

### As linhas horizontais (limiares)

O Manhattan plot do GWAS Explorer mostra duas linhas tracejadas:

- **Linha vermelha tracejada — significância**: o limiar acima do qual um SNP é considerado **estatisticamente significativo**. Pontos acima dessa linha são fortes candidatos a estar associados à característica.

- **Linha laranja pontilhada — sugestivo**: um limiar mais permissivo. Pontos entre a linha laranja e a vermelha são "sugestivos" — vale a pena olhar com atenção, mas a evidência é mais fraca.

Esses limiares **são configuráveis** nos controles deslizantes da barra lateral. Em estudos com poucos marcadores (alguns milhares de SNPs), limiares como 10⁻⁵ (linha vermelha em −log₁₀ = 5) são apropriados. Em estudos humanos com milhões de SNPs, o limiar padrão é muito mais rigoroso (5 × 10⁻⁸, ou −log₁₀ = 7,3).

### Como identificar picos reais

Um **pico real** tem três características visuais:

1. **Vários SNPs adjacentes** subindo juntos no gráfico, formando uma "torre". Isso acontece porque SNPs próximos no genoma estão em **desequilíbrio de ligação** (LD, *linkage disequilibrium*) — eles são herdados juntos.
2. **Pelo menos um SNP cruza a linha vermelha** de significância
3. **A torre é cercada por região mais baixa**, indicando que o sinal não é só um SNP solitário e suspeito

Um SNP isolado bem acima da linha vermelha, sem vizinhos elevados, geralmente **não é um sinal confiável** — pode ser um erro de genotipagem ou de filtragem.

### Um exemplo concreto

Em um GWAS de teor de proteína em soja, os pesquisadores tipicamente esperam encontrar 2 a 5 picos claros distribuídos pelo genoma. O cromossomo 20 da soja é famoso por abrigar um locus principal de proteína e óleo (conhecido como *cqProt-003*), então um GWAS bem feito para essa característica deve mostrar uma torre alta nesse cromossomo. Se um pesquisador não vê esse pico clássico, é sinal de que algo na análise não foi como esperado — fenotipagem ruim, marcadores insuficientes, ou estrutura populacional não controlada.

---

### 📚 Para aprofundar

- **Turner, S.D. (2018).** qqman: an R package for visualizing GWAS results using Q-Q and manhattan plots. *Journal of Open Source Software*, 3(25), 731. [doi.org/10.21105/joss.00731](https://doi.org/10.21105/joss.00731)
  *Pacote R clássico para Manhattan plots; o GWAS Explorer foi inspirado nele.*

- **Hussain, W. et al. (2018).** ShinyAIM: Shiny-based application of interactive Manhattan plots for longitudinal genome-wide association studies. *Plant Direct*, 2(10), e00091. [doi.org/10.1002/pld3.91](https://doi.org/10.1002/pld3.91)
  *Visualizador interativo para GWAS longitudinais — referência direta para apps Shiny voltados a GWAS de plantas.*

- **Kanovská, I.; Biová, J.; Škrabišová, M. (2024).** Post-GWAS strategies in causal gene identification. *Current Opinion in Plant Biology*.
  *Discute como interpretar picos reais e identificar o gene causal por trás do sinal.*
