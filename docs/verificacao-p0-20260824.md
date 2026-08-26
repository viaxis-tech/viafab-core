# Ata de verificação — checklist §6.1 / §6.2 da SPEC0824

> Entrega do **WP-0.3** do plano `docs/plano-implementacao-20260825.md`.
> Objeto verificado: `prototype/index.html` contra `docs/Docs20260824_151851/SPEC20260824_151851.md` §6 (18 itens: 8 de regressão P0 + 10 de construção nova).
> Execução: 25/08/2026. Verificador: agente de execução, sob `docs/conducao-agente-20260825.md`.

## 1. Ambiente e método

| Item | Valor |
|---|---|
| Artefato | `prototype/index.html` (arquivo único, sem build) |
| Servidor | HTTP em `http://localhost:8931/index.html` — obrigatório por §4.7 da instrução de condução (`file://` não funciona após D1) |
| Navegador | Google Chrome do sistema, `headless`, viewport 1440×900 |
| Driver | `playwright-core` instalado em `~/.lionclaw-tmp/pwtest`, **fora do repositório**, para preservar `package.json` com zero dependências (Playwright entra no repo só no WP-5.9) |
| Perfil padrão | `direcao` (`h.trentin@viafab.com.br`), trocado em teste quando o item exige outro |
| Erros de página | `page.on('pageerror')` capturado em toda execução; `[]` em todas as execuções aqui registradas |

**Pré-condição:** esta ata só foi possível após a correção do achado **A-01** (o protótipo não inicializava; 23 das 29 chamadas `init*` nunca rodavam). A correção — guarda de existência em `initChao()` — foi decidida pelo dono do produto (opção O1) e está registrada em `docs/registro-execucao.md`.

**Regra de disciplina aplicada:** todo veredito "FALHOU" foi reconferido contra a implementação antes de virar achado. Sete supostos defeitos se revelaram defeitos do *teste* e foram corrigidos (§5). Nenhum foi reportado como defeito do produto.

## 2. Veredito consolidado

### §6.1 — P0 de regressão (8 itens)

| P0 | Veredito |
|---|---|
| P0-03 — Expedição com ordem retida pela qualidade | **PASSOU** |
| P0-11 — Atalhos do Início nos 8 perfis | **PASSOU** |
| P0-12 — "Adicionar atalho" nos 8 perfis | **PASSOU** |
| P0-13 — `Ctrl+K`, `g`+letra, `?`, `/` | **PASSOU** |
| P0-14 — Foco visível por `Tab` nos 2 temas | **PASSOU** |
| P0-16 — `.btn-primary` nos 2 temas | **PASSOU** |
| P0-17 — `tr.clickable` com teclado, inclusive pós-filtro | **PASSOU** (com ressalva de implementação — §4.3) |
| P0-21 — Filtros e exportação da Auditoria | **PASSOU** (não falsificável para multi-tenant — §6) |

### §6.2 — Construção nova (10 itens)

| Item | Veredito |
|---|---|
| RNF-03 — Confirmação de irreversíveis | **FALHOU** — achado A-02 |
| RF-10 — Anti-duplicação de baixa | **PASSOU** |
| RF-12 — Estorno antes de somar | **PASSOU** |
| RF-40/41 — Estabilidade de OS | **PASSOU** contra o texto do critério (achado A-03 fora do texto — §4.12) |
| RF-37 — Aderência real | **PASSOU** |
| RF-35 — Range do Painel | **PASSOU** |
| RNF-01 — Contraste | **PASSOU** |
| RNF-02 — Teclado ponta a ponta | **PASSOU** |
| RNF-07 — Rótulo verdadeiro | **PASSOU** |
| RF-24 — LGPD (`origem.usuario`) | **PASSOU** |

**Resultado:** 17 dos 18 itens passaram. **1 reprovação: RNF-03.** Dois achados de código registrados (A-02, A-03), ambos escalados — nenhum corrigido de passagem, conforme §2.2 da instrução de condução (sem commit inicial não há linha de base).

---

## 3. §6.1 — P0 de regressão

### P0-03 · Expedição com ordem retida pela qualidade

**Ação.** Perfil `direcao`, `go('expedicao')`; inspeção dos blocos `.ped-blk`; acionamento do CTA.

**Esperado (SPEC :735).** Bloco `.ped-blk.retido` desabilitado, com motivo explícito e CTA "Acompanhar na Qualidade".

**Observado.** 3 blocos, 1 com classe `ped-blk retido`. Conteúdo: *"Retidas pela qualidade — 6 unidade(s) no depósito Expedição sem liberação para sair — 0/6 — PRD-0017 · OP-2438 CIR-1,0x1,0-AIP+SI-ACO-SL — Retido pela qualidade: aguardando inspeção."* Contador `0/6` (nenhuma unidade liberada) e **nenhuma ação de expedir/liberar dentro do bloco** — o bloqueio é por ausência de ação, não por botão desabilitado. Os dois blocos não retidos (PED-4462 `0/120`, PED-4468 `0/48`) exibem "Pedido completo". CTA `#ex-ret-qa` "Acompanhar na Qualidade" presente e funcional: clique levou a tela visível de `expedicao` → `qualidade`.

**Veredito: PASSOU.** Ressalva registrada: o critério "desabilitado" foi satisfeito por ausência de controle, não por `disabled` + motivo. Não é divergência do resultado esperado, mas é a leitura literal que sustenta o veredito.

### P0-11 · Atalhos do Início nos 8 perfis

**Esperado (SPEC :736).** Nenhum atalho aponta para `screen` fora de `MODULOS`; tooltip "Sem permissão" **apenas** quando `perm(screen)==='-'`; destino abre na aba correta.

**Observado.** Varredura dos 8 perfis de `PERFIS`. Todo `screen` de atalho pertence às 22 entradas de `MODULOS` (`:15299`). Zero rota nula. Zero tooltip "Sem permissão" em atalho permitido e zero atalho permitido sem tooltip quando bloqueado. Contagens por perfil: `pcp` 6 atalhos, `engenharia` 5, `almoxarifado` 5, `operador` 3, `qualidade` 5.

**Veredito: PASSOU.**

### P0-12 · "Adicionar atalho" nos 8 perfis

**Esperado (SPEC :737).** Ação disponível em 100% dos perfis; seletor do modal lista **apenas** telas com `perm(screen) !== '-'`.

**Observado.** `#in-add` presente e acionável nos 8 perfis. Lista de opções do modal por perfil: `pcp` 14, `engenharia` 12, `almoxarifado` 10, `operador` 1. Nenhuma opção com `perm(screen) === '-'` em nenhum perfil.

**Veredito: PASSOU.**

### P0-13 · `Ctrl+K`, `g`+letra, `?` e `/`

**Esperado (SPEC :738).** Paleta respeita permissão; salto só para módulos permitidos; ajuda abre; `/` foca o filtro onde existe e é inerte onde não existe.

**Observado.** `Ctrl+K` abre a paleta com exatamente os 20 módulos permitidos ao perfil; `itensProibidos: []`; foco cai em `#cp-q`. Salto `g`+letra com perfil `operador`: `c` → `chao-de-fabrica` (permitido, navegou), `e` → `estoque` (não permitido, **não** navegou), `o` → `ordens` (permitido, navegou). `?` abre a ajuda. `/` foca a barra de filtro nas 5 telas testadas que possuem uma, e é silenciosamente inerte nas que não possuem.

**Veredito: PASSOU.**

### P0-14 · Foco visível por `Tab` nos 2 temas

**Esperado (SPEC :739).** Foco visível em todos os elementos interativos e em `tr.clickable`, contraste ≥3:1.

**Observado.** `Tab` real via teclado (não `element.focus()`, que não dispara `:focus-visible`). Tema claro: 29 paradas, 27 elementos distintos. Tema escuro: 29 paradas, 15 distintos. `semIndicador: []` nos dois temas — todo elemento focado apresenta `outline-width > 0` com `outline-style ≠ none`, ou `box-shadow ≠ none`. A parte de contraste ≥3:1 é coberta pelo RNF-01 (§4.7).

**Veredito: PASSOU.**

### P0-16 · `.btn-primary` nos 2 temas

**Ação.** `node tools/contraste.mjs`.

**Observado.** Saída: *"Todos os 11 pares token/tema passaram no criterio AA/foco"*, exit 0.

**Veredito: PASSOU.**

### P0-17 · `tr.clickable` com teclado, inclusive pós-filtro

**Esperado (SPEC :741).** `Enter` e `Espaço` disparam a mesma ação do clique; `tabindex`, `role` e `aria-label` presentes nas 7 tabelas afetadas, **inclusive em linhas renderizadas após filtro**.

**Observado.** Acionamento: `Enter` sobre `tr.clickable` navega igual ao clique (handler global em `:25992-25995`). Atributos: medidos em três instantes (imediato após o fim da tarefa de render, após dois `requestAnimationFrame`, e após 500 ms), em todas as tabelas, antes e depois de aplicar filtro: `semTabindex: 0`, `semRole: 0`, `semAria: 0` nos três. `janelaDeUmFrameSemAtributos: false`.

**Divergência investigada e resolvida.** Uma execução anterior reportou `posFiltro.semTabindex: 1`. Causa raiz identificada e confirmada empiricamente: os atributos **não** são emitidos por `renderOrdens()` (`:16041` produz `<tr class="clickable" data-ord="…">` sem `tabindex`/`role`/`aria-label`); são injetados por `a11yTabelas()` (`:25974-25981`), que roda via `MutationObserver` sobre `#content` (`:26079-26081`). O observador dispara no *checkpoint de microtask*, portanto **depois** da tarefa que executou o render. O teste anterior media dentro da mesma tarefa síncrona do `click()` e por isso via a linha ainda crua. Reprodução dirigida confirmou: medindo dentro da tarefa do clique, a linha `OP-2434` aparece com `tabindex: null, role: null, aria-label: null`; medindo em qualquer instante posterior, os três atributos estão presentes.

**Veredito: PASSOU.** A janela sem atributos é interna a uma tarefa do event loop e **não é observável por usuário nem por leitor de tela**, que só leem a árvore de acessibilidade depois do checkpoint de microtask. Registrado como ressalva de arquitetura, não como defeito — ver §4.3.

> A hipótese inicial (a linha de estado vazio carregaria `tr.clickable` e entraria na contagem) foi **descartada por medição**: `:16053` emite `<tr><td colspan="10">…` sem a classe `clickable`; a execução dirigida retornou `linhasDeEstadoVazio: 0`.

### P0-21 · Filtros e exportação da Auditoria

**Esperado (SPEC :742).** Lista responde a todos os filtros; todo registro carrega `un: S.tenant`; CSV e PDF contêm o conjunto filtrado completo com cabeçalho declarando o recorte.

**Observado.** Todos os sub-vereditos PASSOU: filtro de unidade, de período e de busca alteram a lista de forma coerente; 100% dos registros carregam `un` igual a `S.tenant`; o CSV exportado contém exatamente o conjunto filtrado e o cabeçalho declara o recorte aplicado; a folha A4 idem.

**Veredito: PASSOU**, com a limitação de §6: existe um único tenant semeado (`T-001`), então o isolamento multi-tenant **não é falsificável** neste protótipo.

---

## 4. §6.2 — Construção nova

### 4.1 RNF-03 · Confirmação de irreversíveis — **FALHOU**

**Esperado (SPEC :748 + §4.6 :608).** As 4 mutações críticas — `fn_gerar_ordens`, `fn_finalizar_operacao`, `fn_publicar_ficha` e a ação "Reservar materiais" de `fn_reservar_material` — abrem `confirmarEfeito()` antes de gravar. "Recalcular" e "Liberar" **não** abrem confirmação.

**Observado.**

| Mutação | Chama `confirmarEfeito()`? | Evidência |
|---|---|---|
| `fn_gerar_ordens` | **Sim** | `:23030` |
| `fn_finalizar_operacao` | **Sim** | `:16923` |
| "Reservar materiais" | **Sim** | `:16566` |
| `fn_publicar_ficha` | **Não** | `#fi-save` chama `abrirModal()` em `:20768` |
| "Recalcular" | Não abre confirmação — correto | — |
| "Liberar" | Não abre confirmação — correto | — |

Verificação em navegador, inventário de 66 fichas, dois casos escolhidos por terem estados opostos:

- **FT-001** (1 ordem aberta): modal abre com título "Publicar FT-001 como v2", `temTabelaDeEfeito: false`, `temNotaDanger: true` (*"1 ordem(ns) aberta(s) passam a usar a v2 no cálculo de necessidade e na baixa automática"*).
- **FT-002** (0 ordens abertas): modal abre com título "Publicar FT-002 como v2", `temTabelaDeEfeito: false`, **`temNotaDanger: false`** — a nota degrada para `mo-nota` simples: *"Nenhuma ordem aberta consome esta ficha — a versão vale só para as próximas."*

**Duas divergências do contrato de `confirmarEfeito()` (`:19772-19775`):**

1. **Sem tabela de efeito.** `confirmarEfeito()` compõe obrigatoriamente `<p class="mo-lead">` + `<table class="tbl">` + `<p class="mo-nota danger">`. A publicação de ficha não emite a tabela em nenhum dos dois casos: o usuário confirma sem ver a materialização do efeito.
2. **Nota de perigo condicional.** Quando não há ordem aberta, a nota perde a classe `danger`. Publicar continua sendo irreversível (`f.ver` é sobrescrito em `:20776`, `FI.orig` é reescrito em `:20778` e um registro de auditoria é gravado) — a ausência de ordem aberta reduz o *alcance*, não a *irreversibilidade*.

**Veredito: FALHOU.** Achado **A-02**. Não corrigido: a correção altera comportamento visível (novo conteúdo de modal), portanto depende do design lock (§4.8) e da linha de base do WP-0.1.

### 4.2 RF-10 · Anti-duplicação de baixa — PASSOU

**Esperado (SPEC :749).** Sem desbloqueio explícito, refinalizar é impossível; com desbloqueio, o consumo segue a escolha registrada em `estorno_apontamento`, sem baixa duplicada.

**Observado.** Após finalizar uma operação, o controle de refinalizar não executa nova baixa sem desbloqueio explícito. Com o desbloqueio registrado, o consumo respeita a escolha gravada em `ESTORNO_APONTAMENTO` — o caminho "retrabalho sem novo material" não gera novos registros em `DB.consumos`, e o caminho com material gera exatamente um conjunto de baixas, não dois.

**Veredito: PASSOU.**

### 4.3 RF-12 · Estorno antes de somar — PASSOU

**Esperado (SPEC :750).** Reservar duas vezes para a mesma ordem → saldo reservado final = necessidade calculada, **nunca** a soma das duas.

**Observado.** Duas reservas consecutivas para a mesma ordem: o saldo reservado final é igual à necessidade calculada, não ao dobro. `reservarMaterial()` (`:16495-16497`) chama `liberarReserva(id, false)` antes de gravar, conforme o comentário de P0-10 em `:16492-16494`.

**Veredito: PASSOU.**

### 4.4 RF-40/41 · Estabilidade de OS — PASSOU (com achado adjacente)

**Esperado (SPEC :751).** Mesmo `os_id` e mesmo QR na reemissão do mesmo grupo, inclusive após recarregar a página; alterar a composição do grupo gera `os_id` novo, preservando o anterior.

**Observado.** Todos os sub-critérios do texto do requisito passaram:

| Sub-critério | Resultado |
|---|---|
| Estável na mesma sessão | OK |
| Mesmos ids após reload | OK |
| Mesmo QR após reload | OK |
| QR carrega só o `os_id` | OK |
| Chave independe da ordem de entrada | OK |
| Grupo alterado gera id novo | OK |
| Registro anterior preservado | OK |

Emissão por setor, 4 folhas (Conformação, Corte, Montagem, Plotagem), consolidada. Registros persistidos em `DB.os_ids`:

```
OS-000001  grupo_chave = OP-2431|OP-2432|OP-2433|OP-2434|OP-2435|OP-2437|OP-2438|OP-2439   seq 1
OS-000002  grupo_chave = OP-2431|OP-2432|OP-2433|OP-2434|OP-2435|OP-2436|OP-2437|OP-2438|OP-2439  seq 2
```

**Veredito: PASSOU.**

**Achado adjacente (A-03), fora do texto do critério.** As 4 folhas receberam apenas 2 ids: `["OS-000001", "OS-000002", "OS-000002", "OS-000002"]`. Corte, Montagem e Plotagem compartilham `OS-000002` e, portanto, o **mesmo QR**. Causa: `grupoChaveOS()` (`:25397-25399`) chaveia exclusivamente pela lista ordenada de ids de ordem, ignorando `OS.grupo` (o modo de agrupamento) e o valor do grupo (`chave`). Quando dois setores atendem o mesmo conjunto de ordens — o caso normal em produção consolidada — as folhas colidem. Consequência operacional: ler o QR não identifica qual folha está em mãos, o que anula o propósito declarado em `:25387-25395`. Registrado como achado; **não** conta como reprovação de §6.2 porque a linha :751 exige estabilidade e não unicidade por folha.

### 4.5 RF-37 · Aderência real — PASSOU

**Esperado (SPEC :752).** Ordem com `fim > prazo` conta como atrasada; ordens sem `fim` saem do denominador com rótulo; denominador zero exibe `—`.

**Observado.** Injetada uma ordem concluída com `fim = prazo + 10 dias`: o card passou de `100% — 4 de 4` para `80% — 4 de 5`, ou seja, a ordem entrou no denominador e **não** no numerador. Ordens sem `fim` são removidas do denominador (`comFim`/`semFim` em `:19891-19893`) e o card declara o recorte. Denominador zero exibe `—`, nunca `0%`, conforme §4.6 :613.

**Veredito: PASSOU.**

### 4.6 RF-35 · Range do Painel — PASSOU

**Esperado (SPEC :753).** Alternar 7/30/90 recalcula KPIs, carga, donut e aderência **simultaneamente**; `EXCECOES_RANGE_PAINEL[]` permanece vazia.

**Problema de falsificabilidade e como foi resolvido.** As 9 ordens ativas semeadas têm prazo entre `HOJE-2` e `HOJE+7` (`HOJE = 2026-08-20`). Nesse conjunto, 7, 30 e 90 dias são **indistinguíveis por construção** — nenhum valor muda, e "não mudar" é indistinguível de "não recalcular". A primeira execução, feita sobre a semente crua, produziu um falso negativo por essa razão.

Foram injetadas duas ordens que só a janela de 90 enxerga:

- `OP-8888` — ativa, `prazo = HOJE+60`, `qtd 999`, itens forçados para `PROD-ZZZ` (código inédito, para que o donut de itens distintos possa mudar);
- `OP-8889` — concluída, `prazo = HOJE+60`, `fim = HOJE+70` (atrasada, para que a aderência possa mudar).

**Observado.** Os oito sinais mudaram **apenas** no range 90 e foram idênticos em 7 e 30:

| Sinal | 7 e 30 | 90 |
|---|---|---|
| KPI ativas | 9 (de 12) | 10 (de 12) |
| Placas | 2321 · 30,88 m² | 1.243 · 142,88 m² |
| Valor | R$ 62.548,06 | R$ 68.100,82 |
| Donut — itens distintos | 11 | 12 |
| Donut — total (texto central) | 332 | 2.354 |
| Carga por setor (alturas de `rect.bar`) | `Aplicação=39.6` | `Aplicação=1.6,131.9` |
| Aderência | `100% — 4 de 4` | `80% — 4 de 5` |
| `EXCECOES_RANGE_PAINEL.length` | 0 | 0 |

Confirmado na implementação (`:19887-19947`): KPIs, carga por setor e donut consomem todos a mesma coleção `at = ativas().filter(o => noHorizontePainel(o.prazo))`, e a aderência consome `conc` com o mesmo filtro — o recálculo é simultâneo por construção, não por coincidência.

**Veredito: PASSOU.**

### 4.7 RNF-01 · Contraste — PASSOU

**Ação.** `node tools/contraste.mjs`.

**Observado.** *"Todos os 11 pares token/tema passaram no criterio AA/foco"*, exit code 0.

**Veredito: PASSOU.**

### 4.8 RNF-02 · Teclado ponta a ponta — PASSOU

**Esperado (SPEC :755).** Percorrer pedido → expedição sem mouse; fluxo completo navegável, foco sempre visível.

**Observado.** Todo o teste foi conduzido com `keyboard.press('Tab')` e `keyboard.press('Enter')` reais — nunca `element.focus()`, que não dispara `:focus-visible`.

1. **Login só com teclado.** Trilha: `theme-login` → `li-tenant` → `li-email` → `li-pass` → `li-perfil` → `li-submit`, todas as paradas com indicador visível; `Enter` em `#li-submit` autenticou (`S.auth === true`).
2. **Varredura das 7 telas do fluxo.** Paradas por tela, todas ciclando e com `semIndicador: 0` e `focusVisibleSempre: true`: pedidos 36, plano 34, ordens 45, ordem-detalhe 33, chão de fábrica 39, qualidade 32, expedição 10.
3. **Mutação real conduzida só por teclado.** Perfil `operador`, chão de fábrica: `Tab` até o cartão da ordem → `Enter` (abriu `OP-2431`, operação "Plotagem e recorte da legenda") → `Tab` até `#cf-start` → `Enter` (timer iniciou, `#cf-stop` habilitou) → `Tab` até `#cf-stop` → `Enter` → modal "Finalizar Plotagem e recorte da legenda" abriu **com foco em `#mo-ok`** e **prendeu o foco por 12 `Tab` consecutivos** → `Enter` confirmou. Resultado gravado: modal fechado, `ESTORNO_APONTAMENTO.length === 1`, `DB.consumos` com 3 baixas automáticas.

**Veredito: PASSOU.**

### 4.9 RNF-07 · Rótulo verdadeiro — PASSOU

**Esperado (SPEC :756).** Nenhum rótulo promete ação inexistente; todo dado excluído de cálculo tem rótulo de exclusão.

**Método.** Instrumentação de `EventTarget.prototype.addEventListener` **antes** do boot, marcando todo elemento que recebe listener de `click` ou `submit`, mais contagem de delegações no `document`. Varredura das 22 telas. Todo suspeito da heurística foi então **clicado de verdade** e o resultado comparado antes/depois em cinco dimensões (`innerHTML` da tela, rota visível, `DB`, estado do overlay, toast).

**Observado.** 415 controles visíveis nas 22 telas. 10 suspeitos pela heurística, **todos provados vivos** pela verificação empírica → `inertes: []`. Segunda metade do critério: o card de aderência declara explicitamente o recorte de exclusão.

**Veredito: PASSOU.**

**Observação não bloqueante** (fora do texto de RNF-07, que nada diz sobre controles desabilitados): 9 controles desabilitados não carregam `title` nem `aria-label` com o motivo — `itens#it-clone`, `fichas#fi-clone`, `fichas#fi-import`, `chao-de-fabrica#cf-stop`, `auditoria#aud-prev`, `auditoria#aud-next`, `pedidos#pd-clone`, `plano#pn-limpar`, `unidades` (botão sem id). A §4.6 :615 exige "desabilitado + motivo explícito" apenas para a confirmação de importação `.vfb` recusada e para os blocos `.ped-blk.retido` da Expedição — ambos conformes. Registrado como candidato a P1/G-xx na E3.

### 4.10 RF-24 · LGPD — PASSOU

**Esperado (SPEC :757 + :253).** `origem.usuario` não aparece em nenhuma tela, exportação (CSV/PDF/`folhaA4`) nem conteúdo de QR/etiqueta.

**Método.** Teste de sentinela — o único formato não vacuoso, já que a semente não traz o campo preenchido. Manifesto `.vfb` construído com `origem.usuario = "sentinela.lgpd@viasign.example"` e `origem.usuario_nome = "Fulano De Tal LGPD"`, carregado por `#vs-file` (o caminho aceita `manifest.json` avulso — `:18962-18973`). Exportações capturadas por interceptação de `Blob` e neutralização de `HTMLAnchorElement.prototype.click`.

**Observado.**

1. **A sentinela chegou à memória:** `VFB.m.origem.usuario === "sentinela.lgpd@viasign.example"` e `usuario_nome === "Fulano De Tal LGPD"`. O teste não é vacuoso.
2. **A importação teve efeito real:** pedido `PED-5201` criado.
3. **A sentinela não apareceu em nenhuma superfície de saída:**
   - painel de conferência `#vs-rep` — imprime apenas `sistema`, `versao_app`, `engine_version` e o nome do tenant (`:21871-21878`);
   - **22 telas** varridas em `innerText` **e** `innerHTML` — 0 ocorrências;
   - **176 blobs de exportação** capturados — 0 ocorrências;
   - **4 folhas A4** e os 44 KB de `#folhas-print` — 0 ocorrências;
   - **payloads de QR** (`OS-000001`, `OS-000002`) e respectivos `aria-label` e `.cap` — 0 ocorrências.

**Veredito: PASSOU.** A garantia é explícita e comentada no código (`:21871-21875`).

---

## 5. Defeitos do teste corrigidos durante a execução

Registrados para que o próximo executor não repita o percurso, e para deixar claro que nenhum destes virou achado contra o produto.

| # | Sintoma inicial | Causa real |
|---|---|---|
| T-1 | RF-35 reprovava em donut e carga | A ordem injetada era clone de `ordensUn()[0]` e reutilizava os mesmos códigos de produto; o donut de itens distintos não tinha como mudar. Além disso o teste media `textContent` em vez de valores geométricos |
| T-2 | RNF-07 acusava 10 controles mortos no GED | Os handlers são delegados em `document` (`:23749`); a heurística parava em `document.body` |
| T-3 | RNF-07 acusava "Registrar perda" morto | É `type="submit"` dentro de `<form id="form-perda">`; o handler é `submit`, não `click` (`:16948`) |
| T-4 | RNF-07 reprovava por "desabilitado sem motivo" | Critério inventado pelo teste; o texto de RNF-07 não o contém |
| T-5 | RNF-02 reprovava a confirmação por teclado | O teste chamava `blur()` após checar a armadilha de foco, jogando o foco para fora do modal; usuário real nunca faz isso |
| T-6 | P0-17 acusava linha sem `tabindex` pós-filtro | Medição dentro da mesma tarefa síncrona do `click()`, antes do `MutationObserver` que injeta os atributos (§3, P0-17) |
| T-7 | Suspeita de erro de sintaxe em `:19681` | Renderização da ferramenta de busca exibiu `/` como `\`; a leitura direta do arquivo confirmou `(p.v / tot)` correto |

## 6. Limitações desta verificação

Declaradas para que nenhum item acima seja lido como garantia mais forte do que é.

1. **Multi-tenant não é falsificável.** Existe um único tenant semeado (`T-001`). O P0-21 comprova que todo registro carrega `un: S.tenant`, mas não comprova isolamento entre tenants. Fica para US-26 / E4.
2. **A semente não discrimina o range do Painel.** RF-35 só se tornou falsificável por injeção de dados em tempo de execução. Um conjunto de dados de teste com dispersão real de prazos é pré-requisito para o E2E do WP-5.9.
3. **Não há backend.** Toda mutação verificada é em memória/`localStorage`. Idempotência, concorrência e autorização real permanecem fora do alcance desta ata — já registradas na SPEC §7.
4. **Verificação de rótulo é por amostragem estrutural, não semântica.** RNF-07 comprova que todo controle visível tem handler vivo; não comprova que o texto de cada rótulo descreve corretamente o efeito. Isso depende dos walkthroughs da Fase 3 (P-08).
5. **Nenhum código foi alterado nesta verificação.** As duas reprovações permanecem no produto por decisão de processo (§2.2 da instrução de condução: sem o commit inicial não há linha de base).

## 7. Achados abertos

| ID | Achado | Item afetado | Estado |
|---|---|---|---|
| A-02 | `fn_publicar_ficha` usa `abrirModal()` e não `confirmarEfeito()`: sem tabela de efeito, e a nota de perigo degrada para nota simples quando a ficha não tem ordem aberta | **RNF-03 (§6.2) — reprovação** | Escalado |
| A-03 | `grupoChaveOS()` chaveia só por ids de ordem, ignorando `OS.grupo` e o valor do grupo; folhas de setores distintos que atendem as mesmas ordens colidem no mesmo `os_id` e no mesmo QR | RF-40/41 (adjacente, fora do texto do critério) | Escalado |
| — | Janela de uma tarefa em que `tr.clickable` existe sem `tabindex`/`role`/`aria-label`, por a injeção ser feita por `MutationObserver` | P0-17 (ressalva) | Não é defeito observável; registrado |
| — | 9 controles desabilitados sem motivo legível | RNF-07 (observação) | Candidato a P1/G-xx na E3 |
