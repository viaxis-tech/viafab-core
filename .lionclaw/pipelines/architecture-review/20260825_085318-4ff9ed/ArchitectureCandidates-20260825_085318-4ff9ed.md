# Architecture Candidates: ViaFab Core (fase 4 — integracao backend)
**Data:** 2026-08-25
**Run:** 20260825_085318-4ff9ed
**Source:** `.lionclaw/pipelines/architecture-review/20260825_085318-4ff9ed/ArchitectureMap-20260825_085318-4ff9ed.md`

> Contexto de triagem: a fase 4 pretende ligar o prototipo ao Supabase. Hoje nao existe
> nenhuma chamada de rede no repositorio (confirmado: zero `fetch(`, zero `createClient`,
> zero `supabase-js` fora de documentacao). Todos os candidatos abaixo foram escolhidos
> por serem **pre-condicoes ou riscos diretos** dessa ligacao, e cada um referencia codigo
> que foi lido linha a linha nesta sessao.

---

## Candidato 1 — Seam de acesso a dados entre o dominio e o `DB` global

- **Files:** `prototype/index.html` L15641-15711 (`DB`), L15726 (`S`), L15734-15757 (`SALDO`/`RESERV`/accessors `fis`/`res` via `Object.defineProperty`), L16472-16526 (`liberarReserva`, `reservarMaterial`), L21550-21594 (`baixaAutomatica`), L15759-15764 (`audit`)
- **Problema:** Nao existe interface de acesso a dado. Ha **42 sitios de mutacao direta** em arrays de `DB` (`DB.<lista>.push/unshift/splice`) espalhados pelo arquivo, e **75 funcoes `render*`/`init*`** que leem os mesmos globais. Pior: mutacao de dominio e efeito de UI vivem na **mesma funcao**. `reservarMaterial(id)` (L16495) calcula necessidade, altera saldo, grava `DB.reservas`, e no meio disso escreve em `$('#res-alert')`, `$('#res-msg')`, chama `audit`, `evento`, `renderEstoque()`, `preencherSelects()` e `toast()`. O saldo por unidade e ainda mais invisivel: `i.fis`/`i.res` parecem campos, mas sao getters/setters sobre `SALDO[S.tenant]` (L15746-15755) — uma leitura aparentemente pura depende de estado de sessao global. Em termos do glossario: **Depth zero e Locality zero** — a interface de qualquer parte e o arquivo inteiro; a superficie de teste nao existe porque toda regra exige DOM e globais montados.
- **Solucao:** Introduzir um seam unico de leitura/escrita de dominio, pelo qual todo o codigo de regra passa a falar (em vez de tocar `DB`/`SALDO`/`ITENS` diretamente), separando "decidir e mutar o dominio" de "redesenhar a tela". O `DB` em memoria vira o **primeiro adapter** desse seam; o Supabase vira o segundo na fase 4. Nao ha seam sem variacao real: aqui a variacao ja e concreta e datada (memoria hoje, PostgREST/Edge Function depois), entao o segundo adapter justifica o seam.
- **Beneficios (locality/leverage/testes):** *Locality* — tenant, unidade fabril, erro de rede, ordenacao e retry passam a ter **um** lugar, em vez de 42. *Leverage* — cada `render*` deixa de saber de onde o dado vem; ligar o backend deixa de ser reescrever chamadores e passa a ser escrever um adapter. *Testes* — a regra de reserva/baixa fica exercitavel sem DOM, o que hoje e impossivel (a unica coisa executavel no frontend e `tools/contraste.mjs`, que le o HTML **como texto**).
- **Payoff:** high
- **Risco:** high
- **Por que agora:** E a pre-condicao dos candidatos 2, 3 e 5. Ligar o Supabase sem esse seam significa espalhar `await` e tratamento de erro por dezenas de funcoes que hoje sao sincronas e ja misturam UI — o custo so cresce a cada tela nova.

---

## Candidato 2 — Custo aberto com duas implementacoes divergentes (JS vs SQL)

- **Files:** `prototype/index.html` L19333 (`qPerda`), L19472-19529 (`custoMat`, `custoMO`, `custoProc`, `custoDe`, `custoAberto`, `tempoDe`, `explodir`) vs `supabase/migrations/20260824140400_fn_custo_aberto.sql` L34-103
- **Problema:** O mesmo conceito de negocio esta implementado duas vezes com formulas **verificadamente diferentes** — e a divergencia produz numero de dinheiro errado, silenciosamente:
  1. **Perda.** O JS aplica `qPerda(l) = l.qtd * (1 + l.perda/100)` em **todos** os niveis da BOM (L19477, L19485, L19493, L19521). O SQL acumula `lf.quantidade * arvore.quantidade_acumulada` (L60) — **sem nenhum fator de perda**. O custo material do banco e sistematicamente menor que o do prototipo.
  2. **"Processo" significa coisas diferentes.** No JS, processo = hora-maquina da operacao (`(f.tempo/60) * horaMaquina(f.maq)`, L19492). No SQL, processo = `custo_unitario` dos componentes de tipo `componente`/`produto` (L70-75). Nao sao a mesma grandeza; sao dois conceitos com o mesmo nome de coluna.
  3. **Profundidade.** O JS corta a recursao em `prof > 6` (L19474). O SQL e `with recursive` sem limite — ciclo na BOM derruba a funcao em vez de truncar.
  A propria migration admite a origem do problema no comentario (L11-13): *"a SPEC 2.1 define as colunas de saida mas nao a formula interna"*. Ou seja, a interface (colunas) foi especificada; a **invariante** (formula) nao. Duas implementations, nenhuma interface comum.
- **Solucao:** Eleger **um** lado como a definicao autoritativa de custo aberto e tornar o outro um adapter que a satisfaz, com um teste de conformidade que roda a mesma BOM nos dois caminhos e falha na divergencia. A decisao de qual lado e a interface e exatamente o que a fase 4 precisa cravar.
- **Beneficios (locality/leverage/testes):** *Locality* — a regra de perda e de composicao de custo passa a ter um dono. *Leverage* — orcamento, BI de custo, ficha, OS impressa e `GET /itens/{itemId}/custo` passam a concordar por construcao. *Testes* — `supabase/tests/engenharia_custo_aberto_test.sql` ja existe e exercita so o lado SQL; um teste de conformidade cruzado fecha a lacuna real.
- **Payoff:** high
- **Risco:** low
- **Por que agora:** `fn_custo_aberto` ja tem `grant execute` para `authenticated` prevendo o endpoint. No momento em que a tela passar a consumi-lo, os valores exibidos **mudam** sem que ninguem tenha mexido em regra de negocio.

---

## Candidato 3 — Transacionalidade do apontamento emulada por indice de array

- **Files:** `prototype/index.html` L16982-17020 (`finalizarOperacao`), L17021-17058 (`corrigirApontamento`), L21550-21594 (`baixaAutomatica`), L16109-16146 (`ESTORNO_APONTAMENTO`, `registrarEstorno`, `estornoAberto`), L19262+ (`baixarLote`)
- **Problema:** E o ponto de maior risco de corrupcao de dado do sistema, e o mecanismo de reversao e um contador de posicoes de array. `finalizarOperacao` guarda `ev0`, `se0`, `au0` (L16987) e `baixaAutomatica` guarda `r0`, `c0`, `m0` (L21553); `corrigirApontamento` desfaz via `splice` cego (L17039-17047). Tres problemas concretos:
  1. **Direcao presumida.** `DB.movimentos.splice(0, u.rev.movimentos)` (L17044) remove do **inicio** do array — so funciona porque `baixaAutomatica` usa `unshift`. Qualquer escrita concorrente ou reordenacao entre a baixa e a correcao apaga o movimento errado.
  2. **Colisao frontal com a invariante do banco.** `DB.auditoria.splice(0, DB.auditoria.length - u.au0)` (L17047) **apaga linhas de auditoria** para desfazer. No Supabase, `auditoria` e append-only garantido em duas camadas (ausencia de policy + `REVOKE UPDATE/DELETE` inclusive para `service_role`). Essa correcao e literalmente **impossivel** de executar contra o backend — nao e um detalhe de implementacao, e uma regra de dominio incompativel.
  3. **Estado critico volatil.** `ESTORNO_APONTAMENTO` e declarado no proprio comentario (L16111-16112) como *"estrutura volatil: existe so na memoria desta sessao do navegador, nunca e gravada"*, e a janela de 10 min usa `Date.now()` do cliente.
- **Solucao:** Trocar "desfazer removendo o que foi escrito" por "compensar escrevendo o inverso": a correcao vira um novo registro que anula o efeito, nunca uma remocao, alinhando o prototipo a semantica append-only que o banco ja impoe. O agrupamento das escritas de um apontamento (consumo + lote + movimento + serie + evento + auditoria) passa a ser explicito em vez de implicito na ordem das linhas.
- **Beneficios (locality/leverage/testes):** *Locality* — a regra "zero duplicacao de baixa de estoque" (invariante nomeada na SPEC) passa a ter um unico guardiao, hoje espalhado por tres regioes distantes do arquivo. *Leverage* — a correcao funciona igual em memoria e contra o banco. *Testes* — a invariante vira asseguravel; hoje nao ha nenhum teste sobre a cadeia mais perigosa do produto.
- **Payoff:** high
- **Risco:** high
- **Por que agora:** Se o seam do candidato 1 for desenhado sem acomodar compensacao, ele nasce incompativel com a unica tabela que o backend ja tem blindada.

---

## Candidato 4 — Preview e execucao do plano: regra duplicada e decisao de dominio lida do DOM

- **Files:** `prototype/index.html` L22953-22991 (`previaOrdensDoPlano`), L23032-23062+ (`gerarOrdensDoPlano`), L22922 (`criarOrdemDoPlano`), L21795 (`CAP_DIA`), L20922 (`capSetorDia`), L22768 (`cargaPorSetor`)
- **Problema:** Preview e execucao sao **duas implementacoes da mesma regra**, nao uma regra com duas apresentacoes. A deteccao de lote consolidado esta escrita por inteiro nas duas funcoes (L22963-22967 e L23048-23054), com o mesmo `cont`/`fila.filter` copiado. E ambas leem a decisao de negocio direto da UI, em dois momentos diferentes:
  ```
  L22960: const consolidar = $('#pn-consol button[data-c="1"]').getAttribute('aria-pressed') === 'true';
  L23042: const consolidar = $('#pn-consol button[data-c="1"]').getAttribute('aria-pressed') === 'true';
  ```
  O usuario ve o preview, o botao muda, e o `confirmarEfeito` executa com **outra** leitura — o que foi confirmado nao e necessariamente o que sera gerado. Como consequencia, o maior concentrado de regra de negocio do repositorio (prioridade, consolidacao, alocacao de prontos, capacidade) e **intestavel sem DOM montado**. A nocao de capacidade ainda aparece em tres lugares distintos (`CAP_DIA` L21795, `capSetorDia` L20922, `cargaPorSetor` L22768).
- **Solucao:** Fazer as opcoes de planejamento (consolidar, criterio de prioridade) serem estado de dominio explicito, lido uma unica vez e repassado, de modo que preview e execucao passem a ser **o mesmo calculo** — o preview vira uma leitura do resultado, nao um recalculo paralelo. A UI escreve a opcao; o motor nunca consulta a UI.
- **Beneficios (locality/leverage/testes):** *Locality* — a regra de consolidacao passa a existir uma vez. *Leverage* — "o que foi confirmado e o que sera gerado" vira garantia estrutural, nao coincidencia. *Testes* — o motor de PCP fica exercitavel em Node puro, sem DOM.
- **Payoff:** high
- **Risco:** medium
- **Por que agora:** E o candidato mais contido da lista (duas funcoes vizinhas) e entrega a maior area testavel por unidade de esforco; serve de piloto para o seam do candidato 1.

---

## Candidato 5 — Matriz de permissao em duas codificacoes incompativeis

- **Files:** `prototype/index.html` L15299-15310 (`MODULOS`, `P(s)`), L15312-15330+ (`PERFIS`), L15884-15890 (`perm`) vs `supabase/migrations/20260824130346_core_multiempresa_tables.sql` L47-62 (`perfis.permissoes jsonb`)
- **Problema:** Autorizacao esta modelada duas vezes, com **formatos que nao se convertem sem traducao explicita**. No cliente e uma matriz **posicional** por string: `P('r r r r w w ...')`, validada apenas por contagem (`if(v.length !== MODULOS.length) throw`, L15307) — a ordem das 22 colunas de `MODULOS` e a unica coisa que da significado a cada caractere. No banco e `{"<modulo>": {"leitura": bool, "escrita": bool}}` (comentario da coluna, L61-62). Alem do formato, a **fonte** diverge: `PERFIS` e uma constante hardcoded no bundle, com usuario e `home` embutidos, enquanto o banco tem `perfis` por tenant. Inserir um modulo novo hoje exige reeditar a string de cada perfil na posicao certa — erro que so aparece em runtime, e apenas se a contagem mudar.
- **Solucao:** Estabelecer uma representacao unica de permissao e um ponto de traducao entre ela e o formato do banco, com a matriz deixando de ser constante compilada para virar dado carregado da sessao. Manter `perm()` como o unico portao de leitura (ele ja e o seam certo — o problema e a fonte que ele consulta, nao a funcao).
- **Beneficios (locality/leverage/testes):** *Locality* — o significado de "escrita em expedicao" para de existir em dois vocabularios. *Leverage* — `renderNav`, paleta Ctrl+K, `aplicarSomenteLeitura` e as policies RLS passam a concordar por construcao. *Testes* — `supabase/tests/rls_isolation_test.sql` ja cobre o lado do banco; a matriz do cliente hoje nao tem teste nenhum.
- **Payoff:** medium
- **Risco:** medium
- **Por que agora:** Autorizacao e a primeira coisa que o backend real assume. Enquanto o cliente decidir acesso por uma string posicional hardcoded, a UI e o RLS podem discordar — e a UI ficara permissiva onde o banco nega, gerando erro em vez de tela bloqueada.

---

## Ranking payoff/risco

| # | Titulo | Payoff | Risco |
|---|---|---|---|
| C1 | Seam de acesso a dados entre dominio e `DB` global | high | high |
| C2 | Custo aberto com duas implementacoes divergentes | high | low |
| C3 | Transacionalidade do apontamento por indice de array | high | high |
| C4 | Preview/execucao do plano duplicados + decisao lida do DOM | high | medium |
| C5 | Matriz de permissao em duas codificacoes | medium | medium |

---

## Recomendacao

**C4 — Preview e execucao do plano.** E o unico candidato que combina payoff alto com risco realmente controlado: sao duas funcoes vizinhas, o defeito e demonstravel em duas linhas identicas (L22960 e L23042), e a correcao converte o maior concentrado de regra de negocio do repositorio em codigo exercitavel sem DOM — passando a superficie de teste do frontend de "um script que le HTML como texto" para "o motor de PCP roda em Node".

C1 tem payoff maior e e a pre-condicao estrutural da fase 4, mas atacar 42 sitios de mutacao e 75 funcoes de render de uma vez, num arquivo de 26.081 linhas sem nenhum teste de regressao, e um big bang sem rede de protecao. **C4 e o piloto de C1**: prova o padrao de separar decisao de dominio de efeito de UI num escopo pequeno, e o padrao validado ali e o que se generaliza depois. Se a fase 4 preferir comecar por ganho imediato de correcao em vez de estrutura, **C2 e a alternativa de risco baixo** — e a unica divergencia ja verificada que produz numero de dinheiro errado no instante em que o endpoint de custo for consumido.

---

## Limites desta triagem

- **Nao verificado:** que as migrations aplicam, que os testes SQL passam, ou que `tools/contraste.mjs` termina com exit 0. Nada foi executado.
- **Leitura parcial.** Foram lidas integralmente as regioes citadas em cada candidato (L15605-15784, L16407-16526, L16982-17058, L19472-19529, L21550-21640, L22953-23062) e a migration `fn_custo_aberto` por inteiro. O restante das ~26.000 linhas foi acessado por busca dirigida, nao por leitura linha a linha.
- **Suposicao explicita em C3:** a afirmacao de que `splice(0, n)` sobre `DB.movimentos` depende da ordem de `unshift` foi inferida da leitura de `baixaAutomatica` (L21563, L21580); nao foi testada em execucao, nem foi auditado se algum outro caminho escreve em `DB.movimentos` entre a baixa e a correcao.
- **Fora de escopo por regra:** duplicacao entre `PRD.md`, `SPEC*.md`, `CLAUDE.md` e demais documentos de pipeline nao foi tratada — e duplicacao de documentacao, nao arquitetural.
- **Nao foi proposta interface final** para nenhum candidato, conforme o escopo desta fase.
