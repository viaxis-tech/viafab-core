# Architecture Diagnosis: ViaFab Core
**Data:** 2026-08-25
**Run:** 20260825_085318-4ff9ed
**Candidato escolhido:** C1 — Seam de acesso a dados entre o dominio e o `DB` global

## Causa raiz

O sistema tem um seam de **leitura** parcial (`ordem()`, `item()`, `reservasAtivas()`, `ordensUn()`) e **nenhum** seam de escrita: os acessores devolvem a referencia viva do store, entao toda mutacao acontece in-place no call site, em 42 sitios de `push/unshift/splice` e 21 atribuicoes diretas de `status`. Como nao existe fronteira entre "decidir e mutar o dominio" e "redesenhar a tela", a mesma funcao que aplica a regra tambem escreve no DOM e chama `render*`/`toast`, o que torna a interface de qualquer regra o arquivo inteiro (26.081 linhas, escopo global unico, zero `import`/`export`).

A consequencia mensuravel: a invariante de saldo esta replicada em 6 call sites que **ja divergem entre si** (um deles sem clamp e sem arredondamento), e as 100% das funcoes de dominio sao sincronas — ligar o Supabase obriga a propagar `async`/erro de rede por dezenas de chamadores que hoje tambem desenham tela.

## Evidencias por arquivo

### prototype/index.html:15641-15711
- **Finding:** `DB` e um objeto literal unico com 17 colecoes de dominio (`ordens`, `movimentos`, `reservas`, `separacoes`, `consumos`, `perdas`, `inspecoes`, `retrabalhos`, `expedicoes`, `eventos`, `auditoria`...) **mais** os contadores de identidade `seqCfg: 1197, seqSnap: 780, seqOrd: 2440` (L15710) no mesmo objeto. Nao ha construtor, nao ha tipo, nao ha funcao de acesso: a declaracao e a interface.
- **Impact:** Geracao de id, dado de demonstracao e estado transacional compartilham o mesmo grau de acesso. Qualquer codigo pode incrementar `seqOrd` ou reescrever `ordens` sem passar por validacao. No Supabase a identidade e do banco (sequence/uuid), entao esses tres campos nao tem para onde migrar sem tocar todos os geradores.

### prototype/index.html:15713-15716
- **Finding:** O campo `res` de cada item e derivado por efeito colateral no carregamento: `DB.reservas.forEach(...)` muta `ITENS` logo apos a declaracao do `DB`. O comentario (L15712) declara a intencao ("derivado das reservas vigentes, nao digitado").
- **Impact:** Acopla ordem de inicializacao: `ITENS` precisa existir antes de `DB`, e `DB` precisa existir antes de `SALDO`. Nao ha como instanciar um estado de teste sem reexecutar o arquivo inteiro na ordem certa — que e a razao pela qual nao existe nenhum teste de dominio.

### prototype/index.html:15734-15757
- **Finding:** `fis` e `res` deixam de ser campos e viram `Object.defineProperty` cujo getter le `SALDO[S.tenant]` / `RESERV[S.tenant]` (L15746-15755). Uma expressao com aparencia de leitura pura (`it.fis - it.res`, usada por exemplo em L16503 e L21620) depende de **estado de sessao global**. `S.tenant` e referenciado 53 vezes no arquivo.
- **Impact:** Nao existe leitura de saldo sem sessao montada. Trocar de tenant muda silenciosamente o resultado de qualquer calculo ja em curso. Existe o acessor explicito `saldoUn(cod, t)` (L15757), que seria o seam correto, mas o dominio quase nao o usa — prefere o getter implicito.

### prototype/index.html:15759-15764
- **Finding:** `audit()` faz tres coisas em cinco linhas: muta o dominio (`DB.auditoria.unshift`), persiste (`gravarLocal('auditoria', 1, ...)`) e **renderiza** (`if($('#aud-rows') && !$('#auditoria').hidden) renderAuditoria()`). E chamada por todos os modules de dominio.
- **Impact:** E o exemplo mais puro da fusao dominio/UI: a funcao mais transversal do sistema nao roda sem DOM. Qualquer teste de regra que audite (praticamente todas) exige `document`. No backend, `auditoria` e append-only com `REVOKE UPDATE/DELETE`, entao esta funcao precisa virar escrita remota — e hoje ela e sincrona e desenha tela.

### prototype/index.html:16472-16491
- **Finding:** `liberarReserva(id, avisar)` usa o parametro `avisar` para decidir se executa efeitos de UI. Com `avisar=true` muta status da ordem (L16483), audita, escreve `$('#res-alert').hidden` (L16486), chama `renderEstoque()`, `preencherSelects()` e `toast()` (L16487-16488).
- **Impact:** O booleano `avisar` e uma **fronteira de UI improvisada dentro da funcao de dominio** — prova de que a separacao e necessaria e ja foi sentida, mas foi resolvida com flag em vez de seam. `reservarMaterial` chama `liberarReserva(id, false)` (L16497) exatamente para suprimir a UI.

### prototype/index.html:16495-16531
- **Finding:** `reservarMaterial(id)` concentra regra e apresentacao: calcula disponivel e reserva parcial (L16503-16505), muta saldo (L16506), grava `DB.reservas.push` (L16509), muta status (L16515, L16521), escreve `$('#res-alert')` e `$('#res-msg').innerHTML` (L16516-16520), emite `evento`/`audit` (L16523-16526) e termina em `renderEstoque(); preencherSelects(); toast(...)` (L16527-16530).
- **Impact:** A regra mais sensivel do almoxarifado (reserva parcial, saldo negativo proibido) e inexercitavel sem DOM montado. A decisao de negocio e o texto da mensagem estao na mesma funcao, entao mudar a mensagem e mudar a regra tocam o mesmo bloco.

### prototype/index.html:16416-16423
- **Finding:** `necessidadeDe(id)` tem tres caminhos e o ultimo e um **fallback hardcoded**: `return [{item:'MAT-011', ...}, {item:'MAT-023', ...}, {item:'MAT-016', nec:o.qtd * 4}]` (L16422), com fatores `1.1`, `1.15` e `4` literais.
- **Impact:** Dado de demonstracao esta embutido no caminho de decisao, nao numa seed separada. Ligado ao backend, esse ramo produz necessidade fabricada para qualquer ordem sem snapshot e sem reserva — e nao ha teste que o detecte.

### prototype/index.html:21550-21594
- **Finding:** `baixaAutomatica` implementa transacao por aritmetica de indice: captura `r0/c0/m0` (L21553) e devolve `rev:{rastreio: DB.rastreio.length - r0, consumos: ..., movimentos: DB.movimentos.length - m0}` (L21592-21593). Escreve com **convencoes opostas** no mesmo bloco: `DB.consumos.push` (L21562) e `DB.movimentos.unshift` (L21563).
- **Impact:** O contrato de reversao e "quantos itens entraram", nao "quais". Depende da direcao de insercao de cada colecao permanecer como esta. Nao ha agrupamento explicito das escritas (consumo + lote + movimento + evento + auditoria) — o agrupamento e implicito na ordem das linhas.

### prototype/index.html:17035-17047
- **Finding:** A reversao do apontamento executa **dentro do callback do modal** `abrirModal(..., 'Confirmar correcao', () => {...})`. Ali dentro: `DB.rastreio.splice(...)` (L17039), `DB.consumos.splice(...)` (L17043), `DB.movimentos.splice(0, u.rev.movimentos)` (L17044 — remove do **inicio**, so correto porque a baixa usou `unshift`), `DB.serie.splice` (L17045) e `DB.auditoria.splice(0, DB.auditoria.length - u.au0)` (L17047).
- **Impact:** A operacao de escrita mais critica do produto e um efeito colateral de um handler de apresentacao — nao ha como invoca-la sem abrir um modal. E `DB.auditoria.splice` apaga trilha, operacao **impossivel** contra o backend, onde `auditoria` tem `REVOKE UPDATE/DELETE` inclusive para `service_role`.

### prototype/index.html:17037 (comparado a 16477, 16506, 16953, 21558, 21559)
- **Finding:** Seis call sites mutam saldo e **ja divergem na regra**. Cinco aplicam clamp e/ou arredondamento: `Math.max(0, Math.round((it.res - r.res) * 100) / 100)` (L16477), `Math.round((it.res + res) * 100) / 100` (L16506), `Math.max(0, it.res - q)` (L16953), `PARAM.estoqueNegativo ? it.fis - q : Math.max(0, it.fis - q)` (L21558), `Math.max(0, it.res - q)` (L21559). O sexto, na devolucao da correcao, faz `it.fis += x.q; it.res += x.q;` (L17037) — **sem clamp e sem arredondamento**.
- **Impact:** Esta e a prova direta de locality zero: a invariante "saldo arredondado a 2 casas, nao negativo" nao tem dono, entao um dos seis sitios ja a viola. O caminho divergente e justamente o de correcao, que devolve saldo — acumulando residuo de ponto flutuante no estoque a cada estorno. Nao e hipotese de deterioracao futura: e divergencia presente no codigo lido.

### prototype/index.html:16020, 16410, 16415, 21713 (e 19324-19326)
- **Finding:** Os acessores de leitura existem e sao de uma linha: `const ordem = id => DB.ordens.find(...)` (L16020), `const item = c => ITENS.find(...)` (L16410), `const reservasAtivas = id => DB.reservas.filter(...)` (L16415), `const ordensUn = () => DB.ordens.filter(o => ESCOPO_REDE || (o.un || 'T-001') === S.tenant)` (L21713), `comp`/`prod`/`ficha` (L19324-19326).
- **Impact:** Existe meio seam. Ele resolve "onde encontrar" e nao resolve "como alterar": devolve a referencia viva, entao o chamador muta in-place (`o.status = 'bloqueada'` em L16965, 21 ocorrencias de atribuicao literal de status). E o ponto de enxerto natural do seam de escrita — a metade que falta ja tem nome e call sites estabelecidos.

### prototype/index.html:17065-17070, 24374 (vs 15715, 16506)
- **Finding:** O identificador `.res` carrega dois significados incompativeis no mesmo arquivo: em `ITENS` e o saldo reservado, numero (`it.res = Math.round(...)`, L16506); em `DB.inspecoes` e o resultado da inspecao, string (`DB.inspecoes.filter(i => i.res === 'Aprovado')`, L17069, L24374).
- **Impact:** Busca textual por `.res` — a unica ferramenta de navegacao disponivel num arquivo sem modulos — retorna dois dominios misturados. Encarece toda manutencao no candidato e torna refatoracao automatizada insegura.

### prototype/index.html:18923-18962, 21830 (varredura global)
- **Finding:** Varredura do arquivo por `fetch(`, `createClient`, `import `, `export `, `async function`, `await ` retorna **9 ocorrencias, todas do adapter VFB** (`lerZip`, `extrairZip`, `lerPacoteVfb`, `abrirPacoteVfb`) — leitura de arquivo local, nao rede. Zero `fetch`, zero `createClient`, zero `import`/`export`.
- **Impact:** 100% do dominio e sincrono. Introduzir o adapter Supabase sem seam significa converter em `async` cada funcao de regra e, por contagio, cada `render*` que a chama — 75 funcoes `render*`/`init*` no arquivo. E a medida exata do custo de nao ter o seam.

### prototype/index.html:15618-15638, 15717-15723
- **Finding:** Existe um seam de persistencia real e bem definido (`chaveLocal`/`lerLocal`/`gravarLocal`, com politica explicita de descarte de versao divergente, L15629), mas ele e usado por apenas 5 chaves — `localStorage` aparece 15 vezes no arquivo, e de `DB` so `auditoria` persiste (L15720-15723).
- **Impact:** O padrao correto ja foi inventado no proprio codigo e nao foi generalizado. O seam de dados pode seguir esse formato em vez de introduzir um vocabulario novo — reduz risco de adocao.

### Repositorio (Glob `{package.json,tools/**,*.config.*,.github/**}`)
- **Finding:** O unico resultado e `tools/contraste.mjs`. Nao ha `package.json`, nao ha test runner, nao ha `.github/`.
- **Impact:** Nao existe rede de protecao para uma mudanca de 42 sitios. Qualquer trabalho em C1 precisa **primeiro** criar a capacidade de executar codigo do dominio em Node — o que hoje e impossivel porque o dominio esta dentro de um `<script>` sem `export`.

## Call sites afetados

- **Escrita direta em colecoes de `DB`:** 42 ocorrencias de `DB.<colecao>.push/unshift/splice` (contagem verificada por Grep).
- **Referencias a `DB.*`:** 268 ocorrencias.
- **Leitores/renderizadores:** 75 funcoes `render*`/`init*` de topo.
- **Escopo de sessao:** 53 referencias a `S.tenant`, a maioria implicita via getters `fis`/`res`.
- **Mutacao de status de ordem:** 21 atribuicoes literais (`.status = '...'`).
- **Mutacao de saldo:** 6 sitios (L15715, L16477, L16506, L16953, L17037, L21558-21559), sendo 1 divergente.
- **Fusao dominio+UI comprovada em:** `audit` (L15759), `liberarReserva` (L16472), `reservarMaterial` (L16495), handler de perda (L16948-16957), handler de bloqueio (L16960-16969), `corrigirApontamento` (L17035-17057), `baixaAutomatica` (via `evento`/`audit`, L21582-21589).

## Seams atuais

- **Acessores de leitura por id (`ordem`, `item`, `ficha`, `comp`, `prod`, `reservasAtivas`, `ordensUn` — L16020, 16410, 16415, 19324-19326, 21713):** separam "onde o dado mora" de "quem le". Problema: devolvem referencia mutavel, entao nao interceptam escrita; e `ordensUn` embute escopo de tenant, misturando busca com autorizacao.
- **`lerLocal`/`gravarLocal` (L15618-15638):** seam de persistencia legitimo, com politica de versao explicita. Problema: cobre 5 chaves, nao o dominio.
- **`PARAM` (L15339-15368):** seam de variacao de comportamento por flag (`baixaAutomatica`, `estoqueNegativo`, `reservaObrigatoria`, `transfDepAuto`). Este e um seam **saudavel** e ja provado em uso (L21551, L21558, L21569).
- **`saldoUn(cod, t)` (L15757):** o unico acesso a saldo com unidade explicita — seam correto, praticamente nao adotado.
- **`Object.defineProperty` em `fis`/`res` (L15746-15755):** seam de interceptacao acidental. Ja prova que a indirecao de saldo e viavel sem tocar os chamadores — mas hoje aponta para um global em vez de para uma porta.
- **`abrirModal`/`confirmarEfeito`:** seam de confirmacao do usuario. Problema: virou hospedeiro de logica de escrita (L17035-17047), invertendo a direcao — a UI passou a conter o dominio.

## Seams ausentes

- **Porta de escrita de dominio:** nao ha nenhum ponto unico por onde passe `push`/`unshift`/`splice`. Sem ela, os 42 sitios sao 42 lugares para adicionar `await`, tratamento de erro e retry.
- **Fronteira decisao-de-dominio vs efeito-de-UI:** provada ausente pelo parametro `avisar` (L16481) e pelo `$('#res-msg').innerHTML` dentro da regra de reserva (L16518).
- **Unidade de trabalho (agrupamento de escritas):** hoje o agrupamento e implicito na ordem das linhas e a reversao e aritmetica de indice (L21553, L21592-21593, L17039-17047).
- **Porta de escopo tenant/unidade:** `S.tenant` e lido implicitamente pelos getters; nao ha assinatura que declare "esta leitura e da unidade X". `saldoUn` e o embriao correto.
- **Relogio injetavel:** `now()`/`Date.now()` do cliente sustentam a janela de estorno de 10 min e todo `ts` gravado. Sem porta, nenhum teste consegue exercitar limite de janela.
- **Gerador de identidade:** `seqCfg`/`seqSnap`/`seqOrd` (L15710) vivem dentro do `DB`. No backend a identidade e do banco — sem seam, a troca atinge todos os pontos de criacao.
- **Fronteira sincrono/assincrono:** nenhuma funcao de dominio e `async` (verificado). Nao existe lugar onde a latencia possa ser absorvida.

## Categoria de dependencias

| Dep | Categoria | Estrategia de teste recomendada |
|---|---|---|
| `DB`, `ITENS`, `SALDO`/`RESERV`, `PARAM` (estado em memoria) | in-process | Nenhum adapter. Vira o estado do module aprofundado; teste constroi o estado direto e assere sobre ele. |
| Regras puras ja isoladas (`matDaOperacao` L21527, `qPerda`, `explodir`, `custoAberto`) | in-process | Chamada direta em Node. Sao as primeiras funcoes que ficam testaveis assim que houver `export`. |
| `localStorage` | local-substituivel | Ja ha o seam `lerLocal`/`gravarLocal` (L15618-15638). Teste usa um mapa em memoria com a mesma assinatura — sem introduzir port novo. |
| DOM / `document` / `$` / `render*` / `toast` | local-substituivel | **Nao substituir: remover.** O objetivo do candidato e que o dominio nao dependa disso. Substituto (jsdom) so se sobrar codigo de apresentacao a testar. |
| Relogio (`now()`, `Date.now()`) | in-process | Injetar como funcao no construtor do module. Um parametro, nao um port. |
| `DecompressionStream` / File API (VFB, L18923-18962) | in-process | API de plataforma pura, entrada por `<input type=file>`. Fora do escopo de C1. |
| Postgres/Supabase (fase 4) | local-substituivel | Supabase CLI local ou PGLite. As invariantes ja tem testes SQL em `supabase/tests/`. Nao precisa de mock. |
| Edge Functions / PostgREST proprios (fase 4) | remoto mas proprio (Ports & Adapters) | Porta de dados + adapter HTTP + adapter em memoria. **Dois adapters reais** (o `DB` de hoje e o remoto de amanha), entao a porta se justifica pela regra "dois adapters = seam real". |
| Supabase Auth (claims `app_metadata.tenant_id`) | verdadeiramente externo | Porta injetada que devolve `{tenant_id, unidade, perfil}`. Teste fornece claims fixos; nao sobe Auth. |

Observacao de disciplina: das dependencias acima, **apenas uma** justifica port formal hoje — a de dados, porque o segundo adapter e concreto e datado (fase 4). Relogio e identidade entram como parametros injetados, nao como ports. Nao ha caso para port de UI.

## Impacto em testes/manutencao/performance

- **Testes.** A superficie de teste do frontend e zero: o unico executavel e `tools/contraste.mjs`, que le o HTML **como texto**, e nao existe `package.json` nem CI. A causa nao e falta de disciplina — e estrutural: sem `export`, nada do dominio e importavel; e mesmo importavel, `audit()` (L15763) e `reservarMaterial()` (L16516) tocam DOM. Regras de alto valor ja escritas em forma quase pura (`matDaOperacao`, L21527-21549) permanecem intestaveis por vizinhanca.
- **Manutencao.** A divergencia de arredondamento entre L17037 e os outros cinco sitios de saldo e o custo ja materializado. Somem-se: 268 referencias a `DB.*` a inspecionar em qualquer mudanca de forma de dado, `.res` com dois significados quebrando busca textual, e dado de demonstracao dentro do caminho de decisao (L16422).
- **Performance.** Efeito hoje modesto e com um mecanismo identificado: `audit()` chama `renderAuditoria()` a cada registro (L15763) e `gravarLocal` serializa a lista inteira com `JSON.stringify` a cada chamada (L15637). Numa operacao que audita varias vezes em sequencia — `baixaAutomatica` seguida de `finalizarOperacao` — isso e re-render e re-serializacao repetidos. Com adapter remoto no lugar, o mesmo padrao vira N requisicoes em vez de um lote.

## Riscos se nada for feito

- **Ligar o Supabase vira mudanca de contagem conhecida:** 42 sitios de escrita e 268 leituras, com `async` contaminando as 75 funcoes `render*`/`init*` por transitividade. O custo cresce a cada tela nova adicionada antes do seam.
- **A correcao de apontamento ja nasce incompativel:** `DB.auditoria.splice` (L17047) nao tem equivalente possivel contra uma tabela com `REVOKE UPDATE/DELETE` para `service_role`. Sem seam que acomode compensacao (escrever o inverso) em vez de remocao, esse caminho precisa ser reescrito de qualquer forma — melhor decidir isso ao desenhar o seam do que depois.
- **Corrupcao silenciosa de saldo continua acumulando:** cada estorno passa por L17037, sem clamp nem arredondamento, somando residuo de ponto flutuante ao estoque. Sem locality, o proximo call site de saldo tem chance real de divergir tambem.
- **Divergencia UI/RLS:** com `S.tenant` lido implicitamente em getters (L15746-15755), o escopo de tenant nao aparece em nenhuma assinatura. Quando o RLS passar a filtrar de verdade, discordancias entre o que a tela mostra e o que o banco devolve nao terao um lugar unico para investigar.
- **Onboarding e navegacao:** um unico escopo global de 26.081 linhas sem modulos mantem a busca textual como unica ferramenta — degradada por identificadores sobrecarregados como `.res`.
- **Risco de execucao do proprio candidato:** sem `package.json`, sem test runner e sem CI, uma mudanca de 42 sitios ocorre sem rede de protecao. Este e o argumento que sustentou a recomendacao de C4 como piloto na fase 2; ele nao desaparece por C1 ter sido escolhido, apenas passa a exigir sequenciamento explicito (criar capacidade de execucao em Node antes de mover call sites).

## Limites deste diagnostico

- **Nada foi executado.** Nenhum teste rodado, nenhuma migration aplicada, `tools/contraste.mjs` nao foi executado. A divergencia de arredondamento em L17037 foi verificada por **leitura**, nao por reproducao em runtime.
- **Leitura dirigida, nao integral.** Foram lidas integralmente as faixas L15600-15800, L16410-16540, L16940-16970, L17030-17058 e L21522-21640. As contagens (42, 268, 75, 53, 21, 15, 9) vem de Grep sobre o arquivo inteiro e sao verificaveis; o **interior** das funcoes fora das faixas citadas nao foi lido linha a linha.
- **Suposicao explicita:** a afirmacao de que `DB.movimentos.splice(0, n)` (L17044) so e correto porque `baixaAutomatica` usa `unshift` (L21563, L21580) e inferida da leitura das duas funcoes. Nao foi auditado se algum outro caminho escreve em `DB.movimentos` entre a baixa e a correcao — apenas que existem 42 sitios de escrita no total.
- **Nao verificado:** se `ESCOPO_REDE` (L21713) tem outros efeitos sobre escopo de tenant; a definicao de `PARAM` (L15339-15368) foi referenciada pelo Map e nao relida nesta fase.
- **Fora de escopo:** nenhuma interface final foi proposta e nenhum codigo foi modificado, conforme a regra da fase.
