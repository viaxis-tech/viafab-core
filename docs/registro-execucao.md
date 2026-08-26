# Registro de Execução — ViaFab Core

> Board vivo da execução do plano `docs/plano-implementacao-20260825.md`, mantido conforme `docs/conducao-agente-20260825.md` §3. Estados: `PENDENTE` · `EM_ANDAMENTO` · `CONCLUIDO` (com evidência na linha) · `BLOQUEADO(<motivo>)`.

**Última sessão:** 26/08/2026 — P-01 confirmado resolvido (commit `333cd54` "chore: linha de base do ViaFab Core" já existe na raiz, branch `master`, working tree limpo, sem remoto). P-13 resolvida — **O2** (alterar a SPEC, não aplicar `confirmarEfeito()`). P-14 resolvida — **O1** (incluir `OS.grupo` na `grupo_chave`). **E0 encerrada por completo. E1 destravada.**
**Etapa corrente:** E1 — Rede de proteção de domínio (WP-1.1 a WP-1.5), ainda PENDENTE de execução. Trabalho de implementação decorrente de P-13/O2 (edição da SPEC §4.6) e P-14/O1 (correção de `grupoChaveOS()` + decisão sobre migrar/invalidar `DB.os_ids` já emitido) ainda não foi executado — apenas as decisões foram registradas nesta sessão.

## Fila de decisões do dono do produto

| ID | Questão | Status | Trava |
|---|---|---|---|
| Q1 | CI: sim ou não? (recomendação: sim, GitHub Actions mínimo) | **RESOLVIDA 25/08 — SIM** (dono do produto): GitHub Actions mínimo (`node --test` + `tools/contraste.mjs`; job separado `supabase test db`). Destrava WP-0.5, condicionado a WP-0.1 (repo sem git funcional hoje). | E0 (WP-0.5) |
| Q2 | Forma da compensação (marcação de anulado + agrupamento de escritas) | PENDENTE — proposta sai do WP-1.4 | E1→E2 |
| Q3 | D-07: significado de MA/MP/MQ | PENDENTE | E4 |
| Q4 | ViaSign: D-08/D-10/D-13 + ADR-012 | PENDENTE — reunião a agendar | E4 |
| Q5 | Fórmula autoritativa do custo aberto | PENDENTE | E2 (F-2.4) |
| Q6 | Shell do produto final (single-file × React) | PENDENTE | E4 |

## Board

### E0 — Fundação + encerramento da Fase 1

| WP | Entrega | Estado |
|---|---|---|
| WP-0.1 | `git init` + `.gitignore` + commit inicial | **CONCLUIDO** — commit inicial `333cd54` ("chore: linha de base do ViaFab Core") confirmado na raiz do repositório em 26/08; branch `master`, `git status` limpo, sem remoto configurado. |
| WP-0.2 | `package.json` + `node --test` + scripts | **CONCLUIDO** — `package.json` criado (`private:true`, `type:module`, zero dependências, `engines.node>=22`). `npm test` → `node --test`, exit 0 (smoke, `tests 0`); `npm run contraste` → exit 0 sob Node v24.18.0 / npm 11.16.0. |
| WP-0.3 | Ata `docs/verificacao-p0-20260824.md` (checklist §6.1/§6.2 da SPEC0824) | **CONCLUIDO** — ata escrita com os 18 itens executados em navegador real (HTTP:8931 + Chrome headless, `playwright-core` fora do repositório), cada um com ação → esperado → observado → veredito. **§6.1: 8/8 PASSOU.** **§6.2: 9/10 PASSOU, 1 FALHOU (RNF-03).** Zero erros de página em todas as execuções. Achados: **A-02** (reprovação de RNF-03) e **A-03** (adjacente a RF-40/41). A ata registra também 7 defeitos do próprio teste corrigidos durante a execução (§5) e 5 limitações declaradas da verificação (§6). Nenhuma linha de código alterada, conforme §2.2 da instrução de condução |
| WP-0.4 | Higiene documental + `MEMORY.md` na raiz | **CONCLUIDO** — `.spec-enricher-suggestions.md` e `.prd-validation-report.md` movidos para `docs/arquivo/` com `README.md` de rastreio "superseded"; nota de numeração adicionada no topo de `PRD.md` e `stories-requisitos.md` da raiz; `MEMORY.md` criado na raiz (~80 linhas, dentro do teto de 200). |
| WP-0.5 | CI mínimo (condicionado a Q1) | **CONCLUIDO (aguarda 1º push para evidência de pipeline verde)** — `.github/workflows/ci.yml` com job `node` (`npm test` + `npm run contraste`) e job `database` (`supabase db start` + `supabase test db` + `scripts/audit-rls.sh`). Os 3 comandos do job `node`/auditoria já rodam verdes localmente; o job `database` depende de Docker/CLI no runner. |
| WP-0.6 | `scripts/audit-rls.sh` + hook de pré-commit | **CONCLUIDO** — `scripts/audit-rls.sh` audita 18 tabelas de `public` nas 9 migrations: exit 0, "Nenhuma violacao de RLS". Teste negativo (tabela sem RLS + view sem `security_invoker` em diretório temporário) → 2 violações, exit 1, provando que o script não é falso-positivo. Hook `.githooks/pre-commit` criado e ativado via `git config core.hooksPath .githooks`; dispara a auditoria só quando o commit toca `supabase/migrations/`. |

### E1 — Rede de proteção de domínio

| WP | Entrega | Estado |
|---|---|---|
| WP-1.1 | Regras quase-puras em `prototype/core/*.mjs` + caracterização | **CONCLUIDO (não commitado)** — `qPerda.mjs`, `explodir.mjs`, `matDaOperacao.mjs`, `custoAberto.mjs` extraídos com testes de caracterização (16 novos, defeitos originais preservados: perda negativa sem clamp, qtd negativa propagada, item sem ficha ignorado em silêncio, qtd<=0 descartada). `index.html` consome via `<script type="module">` (`:26069-26084`) com reexposição em `window.*`. `explodir`/`matDaOperacao`/`custoAberto` tiveram o corpo removido do legado (chamadas só pós-boot, via interação); `qPerda` foi **duplicada, não removida** — tem chamada síncrona no seed de `DB.serie` antes do módulo carregar, então a definição original ficou inline (`:19340`) e a extraída roda em paralelo, mesma lógica, documentado em comentário no arquivo. `npm test`: 20/20 verde. `node tools/contraste.mjs`: 11/11 PASSA, exit 0. Ambos reexecutados e conferidos após a entrega do harness-coder, não apenas por relato. Falta o commit (ação do dono do produto). |
| WP-1.2 | Porta de dados assíncrona + adapter memória | PENDENTE |
| WP-1.3 | Guardião único de saldo + teste da invariante (reprova `:17037`) | PENDENTE |
| WP-1.4 | Design da compensação (proposta para Q2) | PENDENTE |
| WP-1.5 | Relógio injetável + identidade como parâmetro | PENDENTE |

### E2 — Conversão async + compensação (fatias verticais)

| Fatia | Escopo | Estado |
|---|---|---|
| F-2.1 | Cadeia saldo/apontamento (inclui revisão do lock p/ texto do modal) | PENDENTE |
| F-2.2 | PCP preview/execução (C4) | PENDENTE |
| F-2.3 | Permissões (C5) | PENDENTE |
| F-2.4 | Custo (C2) + conformidade JS×SQL (depende de Q5) | PENDENTE |
| F-2.5 | Demais módulos (qualidade, expedição, GED, relatórios, admin) | PENDENTE |

### E3 — P1 (Fase 2) + validação com usuários (Fase 3)

| Item | Escopo | Estado |
|---|---|---|
| E3-P1 | Grupos G-01..G-14 na ordem da auditoria (+P2 como enchimento) | PENDENTE |
| E3-W | 5 walkthroughs com dados reais da fábrica-piloto | PENDENTE |
| E3-C | 9 critérios de aceite da etapa de design marcados | PENDENTE |

### E4 — Portão de arquitetura

| Item | Escopo | Estado |
|---|---|---|
| ADR-1..7 | 1 ADR por item do portão (plano §5 E4) | PENDENTE |
| E4-S | Schema revisado das 37 tabelas + plano de testes multi-tenant (US-26) | PENDENTE |
| E4-Q | Entradas Q3/Q4/Q5/Q6 fechadas | BLOQUEADO(aguarda dono do produto) |

### E5 — Backend restante + integração real

| WP | Domínio | Estado |
|---|---|---|
| WP-5.1 | Estoque base | PENDENTE |
| WP-5.2 | Produção (snapshots, ordens, eventos) | PENDENTE |
| WP-5.3 | Chão de fábrica | PENDENTE |
| WP-5.4 | Qualidade + expedição | PENDENTE |
| WP-5.5 | Pedidos / ViaSign (bloqueado até Q4) | PENDENTE |
| WP-5.6 | PCP / GED / transversais (Storage, auditoria genérica) | PENDENTE |
| WP-5.7 | Superfície de API | PENDENTE |
| WP-5.8 | Adapter Supabase da porta | PENDENTE |
| WP-5.9 | Playwright, `.env.example`, deploy, Sentry | PENDENTE |

## Achados fora de escopo

_(registrar aqui bugs/dívidas encontrados durante a execução que não pertencem ao WP corrente; não corrigir de passagem)_

- 25/08 — Bug ativo de saldo em `prototype/index.html:17037` (sem clamp/arredondamento). Já endereçado pelo plano (WP-1.3); listado aqui por ser pré-existente.
- 25/08 — `fn_versao_*` calcula `max+1` sem lock (falha segura na unique sob concorrência). Destino: ADR de concorrência (E4, item 6).
- 25/08 — **BLOQUEANTE (A-01): o protótipo não inicializa.** `initChao()` lança `TypeError: Cannot read properties of null (reading 'addEventListener')` em `prototype/index.html:16958`, porque `#cf-block`, `#cf-block-card`, `#cf-block-close`, `#form-block`, `#bk-mot`, `#bk-desc` e `#e-bk-desc` são referenciados só em JS (`:16958–16969`) e **não existem no HTML** (grep: zero ocorrências fora desse bloco). Como o boot em `:25918–25961` é uma cadeia plana sem `try/catch`, a exceção aborta tudo que vem depois: **23 das 29 chamadas `init*` nunca rodam** (sobrevivem apenas `initLogin`, `initTabs`, `initRecursos`, `initOrdens`, `initOrdemDetalhe`, `initEstoque`), e também morrem o delegador de navegação (`:25947`), `popstate`/`hashchange` (`:25959–25960`), logout (`:25940`), troca de perfil (`:25942`), paleta (`:25939`), renovação de sessão (`:25954–25956`), `resize` (`:25961`), tooltip dos gráficos (`:25929–25930`) e o modal genérico (`:25932–25938`). Evidência funcional (Chrome headless, protótipo servido em `http://localhost:8931`, perfil `direcao`): clicar em qualquer item do menu muda `location.hash` mas **não troca de tela** (só `#inicio` fica visível); `go('estoque')` chamado à mão funciona (`display: block`), provando que o roteador está íntegro e o que falta é o *wiring*; abrir `#ovl` e clicar em `#mo-x` **não fecha o modal**. Trava WP-0.3 e a E1 inteira. Escalado ao dono em 25/08 — ver P-11.
- 25/08 — **A-02: `fn_publicar_ficha` não usa o contrato de `confirmarEfeito()`.** É a **única reprovação** do checklist §6.2 (item RNF-03, SPEC :748 + §4.6 :608, que nomeia `fn_publicar_ficha` entre as 4 mutações críticas). `#fi-save` chama `abrirModal()` em `prototype/index.html:20768`, não `confirmarEfeito()` (`:19772`). Duas divergências do contrato: (1) **não emite a `<table class="tbl">` de efeito** — o usuário confirma sem ver a materialização do que vai mudar; (2) **a nota de perigo é condicional** — com ordem aberta sai `mo-nota danger`, sem ordem aberta degrada para `mo-nota` simples. Publicar continua irreversível nos dois casos (`f.ver` sobrescrito em `:20776`, `FI.orig` reescrito em `:20778`, auditoria gravada em `:20779`); a ausência de ordem aberta reduz o alcance, não a irreversibilidade. Evidência em navegador (66 fichas inventariadas): FT-001 (1 ordem aberta) → `temTabelaDeEfeito:false`, `temNotaDanger:true`; FT-002 (0 ordens abertas) → `temTabelaDeEfeito:false`, `temNotaDanger:false`. Não corrigido: altera comportamento visível, depende do design lock (§4.8) e da linha de base (P-01). Escalado — ver **P-13**.
- 25/08 — **A-03: `os_id` colide entre folhas de OS distintas.** `grupoChaveOS()` (`:25397-25399`) chaveia exclusivamente pela lista ordenada de ids de ordem, ignorando `OS.grupo` (modo de agrupamento) e o valor do grupo. Emissão por setor, consolidada, 4 folhas (Conformação, Corte, Montagem, Plotagem) → apenas 2 ids: `["OS-000001","OS-000002","OS-000002","OS-000002"]`. Corte, Montagem e Plotagem compartilham `OS-000002` e **o mesmo QR**, porque atendem o mesmo conjunto de ordens — o caso normal em produção consolidada. Consequência operacional: ler o QR não identifica qual folha está em mãos, anulando o propósito declarado em `:25387-25395`. **Não conta como reprovação de §6.2**: a linha :751 exige estabilidade (mesmo id após reload, id novo quando o grupo muda, anterior preservado) e todos esses sub-critérios passaram; unicidade por folha não está no texto. Escalado — ver **P-14**.
- 25/08 — **A-01 RESOLVIDO pela opção O1** (decisão do dono do produto). Guarda de existência em torno do bloco `:16958–16971` de `initChao()`; nenhuma outra linha tocada. Verificação pós-correção no mesmo ambiente (HTTP:8931, Chrome headless, perfil `direcao`): **zero erros de página**; as 20 telas do menu passam a abrir e a renderizar dados (dashboard 23 linhas de tabela, orçamento 41, itens 40, plano 61, OS impressa 101, recursos 49, estoque 53, GED 26, unidades 26, auditoria 31, qualidade 5, ordens 10); `#mo-x` volta a fechar o modal genérico (`hidden: false → true`); o filtro de qualidade volta a re-renderizar (0 → 2 linhas); `tools/contraste.mjs` segue 11/11 PASSA. A funcionalidade "bloquear ordem" continua ausente — ver P-12.

## Pendências abertas (consolidado)

> Lista única de tudo que está aberto e **não é um WP futuro do board** — ou seja, o que exige ação humana, ação externa, ou o que ficou devendo evidência. Atualizada em 25/08/2026 a pedido do dono do produto. Um item só sai daqui com evidência citada.

### Ações do dono do produto

| # | Pendência | Trava o quê | Como resolver |
|---|---|---|---|
| P-01 | ~~Commit inicial do WP-0.1~~ | — | **RESOLVIDA 26/08** (dono do produto): commit `333cd54` confirmado. Ver WP-0.1 acima |
| P-02 | **Remoto Git** (o repositório é local; não há `origin`) | Evidência de "pipeline verde no primeiro push" do WP-0.5; o workflow de CI só executa depois de existir remoto | Criar o repositório remoto e `git remote add origin` + `git push -u` |
| P-03 | **Q2** — forma da compensação: como o registro anulado é marcado e como o agrupamento de escritas de um apontamento é representado | Passagem E1 → E2 | Ratificar a proposta que sai do WP-1.4 |
| P-04 | **Q3 / D-07** — significado de negócio das siglas MA, MP e MQ | Portão de arquitetura (E4) | Só o dono tem a informação. **Alta latência: responder cedo** |
| P-05 | **Q5** — fórmula autoritativa do custo aberto (o JS aplica fator de perda em toda a BOM e trata "processo" como hora-máquina; o SQL não aplica perda e trata como custo de componentes) | Fatia F-2.4 e qualquer tela que consuma o endpoint de custo | Decidir a fórmula como regra de negócio; recomendação técnica é o SQL (`fn_custo_aberto`) virar autoridade e o JS virar consumidor, com teste cruzado travando a igualdade |
| P-11 | ~~A-01 — decisão sobre a correção do boot quebrado~~ | — | **RESOLVIDA 25/08 — O1** (dono do produto). Guarda aplicada e verificada; ver o achado A-01 acima |
| P-12 | **Funcionalidade "bloquear ordem" no chão de fábrica não existe** (só o JS foi escrito; o markup nunca). Comportamento pretendido, legível em `:16960–16971`: motivo + descrição mínima de 5 caracteres levam a ordem a `status = 'bloqueada'`, param o timer, geram evento e registro de auditoria, e sinalizam no dashboard do PCP | Nada hoje (o resto do sistema já trata `status = 'bloqueada'`); é lacuna de funcionalidade, não defeito | Decidir se entra como item de E3 (P1/G-xx) ou como requisito novo. Precisa passar pelo design lock por ser markup novo |
| P-13 | ~~A-02 — RNF-03 reprovado: publicar ficha não usa o contrato de `confirmarEfeito()`~~ | E1 (edição da SPEC) | **RESOLVIDA 26/08 — O2** (dono do produto): alterar a SPEC (§4.6 `:608`) para tirar `fn_publicar_ficha` da lista das 4 mutações críticas, assumindo o modal atual (`abrirModal()`, `:20768`) como confirmação suficiente. Não toca o design lock. Execução pendente: editar `docs/Docs20260824_151851/SPEC20260824_151851.md` e a linha `:748`/§4.6 correspondente |
| P-14 | ~~A-03 — `os_id` e QR colidem entre folhas de OS distintas~~ | E1 (`grupoChaveOS()`) | **RESOLVIDA 26/08 — O1** (dono do produto): incluir `OS.grupo` + valor do grupo na `grupo_chave` de `grupoChaveOS()` (`:25397`). Execução pendente: os ids já emitidos mudam de significado — decidir e implementar se `DB.os_ids` gravado é migrado ou invalidado antes de fechar o WP |
| P-06 | **Q6** — shell do produto final: O1 protótipo single-file evolui para cliente definitivo, ou O2 migração para React 19 + Vite + PWA | Portão (E4) | Decidir com os dados da validação com usuários (E3). Nada do investimento das E0–E3 se perde nas duas hipóteses |

### Ações externas (latência alta — agendar já)

| # | Pendência | Trava o quê | Como resolver |
|---|---|---|---|
| P-07 | **Q4 / D-08, D-10, D-13** — reconfirmação do contrato com o time ViaSign + ADR-012 ausente do repositório | Portão (E4) e o WP-5.5 (pedidos/ViaSign) inteiro | Reunião com o lead do ViaSign. Até lá a integração permanece **simulada** |
| P-08 | Walkthroughs da Fase 3 (5 sessões com dados reais da fábrica-piloto) | Fechamento da E3 e entrada de dados para Q6 | Exigem humanos; o agente prepara roteiros, dados e ambiente, mas não conduz as sessões |

### Devendo evidência

| # | Pendência | Situação |
|---|---|---|
| P-09 | WP-0.5: "pipeline verde no primeiro push" | Workflow criado e os comandos do job `node` rodam verdes localmente. O job `database` (`supabase db start` + `supabase test db`) nunca rodou — depende de Docker no runner. Evidência só existe após P-02 |
| P-10 | WP-0.6: "commit tocando migrations dispara o hook" | Hook criado e `core.hooksPath` ativado; a auditoria em si foi validada nos dois sentidos (limpo nas 9 migrations; reprova caso plantado). O disparo pelo hook em si só se comprova no primeiro commit que toque `supabase/migrations/` — depende de P-01 |

### Pendências formais já alocadas à E4/E5

Registradas na SPEC0824 §7 e reproduzidas aqui só para não sumirem do radar; **nenhuma ação é esperada antes do portão**: autorização server-side real (a matriz `PERFIS` do protótipo é controle de UI, não de segurança); perfil `admin` e matriz de 9 perfis; proibição real de troca de perfil em runtime; QR/etiqueta assinados e verificação de integridade do `.vfb`; identificador opaco de `origem.usuario`; policies de Storage dos buckets `documentos-ged`, `arquivos-vfb` e `etiquetas`; idempotência transacional de `fn_gerar_ordens`, `fn_finalizar_operacao` e `fn_reservar_material`; sequência server-side para ID estável de OS; migrations de pedidos, ordens, estoque, qualidade e expedição; trigger de versionamento para `roteiros_base`; paginação por `range` e exportação de auditoria via PostgREST com isolamento por tenant.

## Histórico de sessões

| Data | Resumo | Commits |
|---|---|---|
| 26/08/2026 | P-01 confirmado resolvido (commit `333cd54` já existia). P-13 resolvida (O2 — alterar SPEC). P-14 resolvida (O1 — incluir `OS.grupo` na chave). E0 encerrada por completo; E1 destravada. Execução das duas mudanças (edição da SPEC e correção de `grupoChaveOS()`) ainda pendente. | `333cd54` (pré-existente) |
| 25/08/2026 | Inventário completo do repositório; plano `docs/plano-implementacao-20260825.md`, instrução `docs/conducao-agente-20260825.md` e este board criados. | — (repo ainda sem git funcional) |
| 25/08/2026 (tarde) | Q1 respondida (SIM). WP-0.1 executado exceto o commit; WP-0.2, WP-0.4, WP-0.5 e WP-0.6 concluídos com evidência. Seção "Pendências abertas" criada. | — (aguarda P-01) |
| 25/08/2026 (noite) | WP-0.3 concluído. Os 18 itens do checklist §6.1/§6.2 executados em Chrome real sobre HTTP:8931; ata `docs/verificacao-p0-20260824.md` escrita. §6.1 8/8; §6.2 9/10. Achados A-02 (reprovação de RNF-03) e A-03 (colisão de `os_id`/QR) escalados como P-13 e P-14. Sete falsos negativos foram rastreados até defeitos do próprio teste e registrados na ata §5, sem virar achado contra o produto. E0 encerrada no que depende do agente. | — (aguarda P-01) |
| 25/08/2026 (fim de tarde) | WP-0.3 iniciado: protótipo servido em HTTP:8931 e dirigido por Chrome headless (`playwright-core`, fora do repositório). A primeira execução real revelou o achado A-01 — o protótipo não inicializa e 23 dos 29 módulos nunca são ligados. Escalado; dono escolheu O1; guarda aplicada em `initChao()` e verificada (zero erros, 20 telas vivas, contraste 11/11). WP-0.3 desbloqueado. | — (aguarda P-01) |
