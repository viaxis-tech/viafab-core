# CLAUDE.md — ViaFab Core

> Gerado automaticamente pelo Feature Discovery Agent a partir da analise do repositorio (24/08/2026). Nao existia CLAUDE.md antes desta analise.

## O que e o projeto

ViaFab e um ERP verticalizado para fabricas de sinalizacao viaria (placas de advertencia, regulamentacao, indicativas e marcadores conforme nomenclatura CONTRAN). Cobre o ciclo completo: configuracao tecnica do produto (familia construtiva parametrica), explosao de BOM multinivel, geracao de roteiro de fabricacao, planejamento de producao (PCP), reserva/movimentacao de estoque, execucao no chao de fabrica (apontamento de tempo e consumo), qualidade, expedicao, rastreabilidade/auditoria e seguranca multiempresa (multi-tenant, multi-unidade fabril).

Integra-se com o ViaSign (produto irmao do mesmo ecossistema Viaxis) por contrato de eventos versionado (`viaxis.vfb/1` no MVP), sem compartilhar banco nem UI. Funciona standalone com demanda manual quando o ViaSign nao esta disponivel.

## Stack

- **Frontend (prototipo/design lock)**: HTML/CSS/JS estatico em `prototype/index.html` (~24.000 linhas), single-file, sem build. Design system proprio "ui-obs" (tokens CSS em `:root`/`[data-theme="light"]`), fonte JetBrains Sans, icones Lucide, densidade "dense", sidebar fixa 230px. Tema escuro e claro via `data-theme`.
- **Stack alvo do produto real** (definida em `discovery-notes.md`/SPEC, ainda nao implementada em codigo de app): TypeScript, React 19 + Vite + PWA no frontend; Vitest (testes de dominio); Playwright (E2E); GitHub Actions (CI/CD); Sentry.
- **Backend/DB**: PostgreSQL via Supabase (Auth, RLS, Storage, Edge Functions em Deno). Migrations em `supabase/migrations/`, seed em `supabase/seed.sql`, testes SQL em `supabase/tests/`.
- **Hospedagem**: Vercel (frontend) + Supabase (backend).

## Estrutura de pastas principal

```
prototype/index.html              -> prototipo navegavel (design lock), unica fonte de verdade visual
supabase/migrations/*.sql         -> schema incremental (core multiempresa, auditoria, RLS, engenharia, recursos, custo)
supabase/seed.sql                 -> dados de seed (materiais, componentes, produtos, setores, maquinas, depositos)
supabase/tests/*.sql               -> testes pgTAP/SQL de RLS, auditoria, versionamento, custo
docs/Docs20260820_134109/         -> pacote de discovery/PRD/SPEC/stories/design-lock originais (primeira execucao do pipeline)
docs/Docs20260820_134109/design/  -> design-contract.json (fonte literal de telas/rotas/componentes/API), artifact.html, design-brief.md, manifest.json, design-lock-report.md
docs/auditoria-design-20260823.md -> auditoria UX/design de 23/08 (22 P0, 14 grupos P1, P2, 13 decisoes de produto D-01..D-13, plano em 5 fases)
docs/Docs20260824_151851/         -> pasta desta execucao (Fase 0+1: decisoes de produto + correcao P0)
PRD.md, stories-requisitos.md, discovery-notes.md -> artefatos de produto da primeira rodada de discovery
```

## Convencoes encontradas

- **Nomenclatura de tabelas/campos em portugues** (`tenants`, `unidades_fabrica`, `perfis`, `ordens_producao`, `fichas_tecnicas`, `linhas_ficha`, `roteiros_base`, `apontamentos`, `movimentos_estoque` etc). Ids de dominio com prefixo por tipo: `PRD-*` (produto), `FT-*` (componente/ficha), `MAT-*` (material), `OP-*` (ordem de producao).
- **Multi-tenant obrigatorio**: toda tabela de negocio carrega `tenant_id`; varias carregam tambem `unidade_id` (isolamento por unidade fabril). Padrao **fail-closed**: nenhuma tabela de negocio tem policy permissiva default (RLS habilitada em migration separada da definicao de schema).
- **Append-only** para tabelas de auditoria/rastreio (`auditoria`, `eventos_ordem`, `movimentos_estoque`) — sem UPDATE/DELETE; correcoes via nova linha (ex.: `estornos_apontamento` com janela de 10 min) ou `snapshot_revisao_de_id` (self-fk) para revisao de snapshot imutavel.
- **Snapshots tecnicos imutaveis**: ficha tecnica, BOM e roteiro sao congelados em `snapshots` no momento da liberacao da demanda; nunca editados in-place — nova versao gera nova linha (`fichas_tecnicas.versao`, `familias_construtivas.versao`).
- **Separacao schema vs. policy**: migrations de criacao de tabela nao habilitam RLS; uma migration dedicada (`*_rls_*_policies.sql`) faz isso depois, por dominio (core, engenharia).
- **Sync offline explicito**: campos `sync_status` (`pendente|conflito|confirmado`) e `client_generated_id` em tabelas alimentadas por chao de fabrica (`apontamentos`, `consumos`, `movimentos_estoque`), pensando em tablet/celular com conectividade instavel.
- **Design tokens unicos por variavel de marca**: apenas `--accent` muda a identidade visual; todo o resto do design system e generico e reutilizavel entre temas.
- **IDs de tela / permissao**: `screen_id`, `perm('<modulo>')` no prototipo controlam roteamento e visibilidade fail-closed por perfil (PCP, engenharia, almoxarifado, operador, qualidade, expedicao, compras, direcao, admin).

## Estado atual do projeto (24/08/2026)

- O prototipo HTML e o design lock (contrato + artifact navegavel) sao a fonte de verdade de UX/UI, produzidos na primeira rodada do pipeline (`Docs20260820_134109`).
- O backend real esta em construcao incremental via migrations Supabase: nucleo multiempresa/seguranca e auditoria (24/08 13:02-13:05), depois catalogo de engenharia, recursos, versionamento/triggers, RLS e funcao de custo aberto (24/08 14:00-14:04). Ainda nao ha migrations para pedidos/ordens/estoque/qualidade/expedicao descritos no SPEC.
- Uma auditoria de UX/design em 23/08 (`docs/auditoria-design-20260823.md`) encontrou 22 bloqueios P0 no prototipo, 14 grupos P1, uma lista P2 e 13 decisoes de produto em aberto (D-01 a D-13), com um plano de correcao em 5 fases (Fase 0 decisoes -> Fase 1 P0 -> Fase 2 P1 -> Fase 3 validacao com usuarios -> Fase 4 portao de arquitetura antes da primeira migration de producao real).
- Esta execucao (`docs/Docs20260824_151851/`) e explicitamente o escopo **Fase 0 + Fase 1** desse plano: fechar as decisoes de produto pendentes e corrigir os 22 P0 no prototipo.

## Conducao do projeto (a partir de 25/08/2026)

A execucao do projeto e regida por tres documentos. **Qualquer agente que va trabalhar neste repositorio deve ler os dois primeiros antes de editar qualquer coisa:**

- `docs/plano-implementacao-20260825.md` — plano canonico (etapas E0-E5, criterios de aceite, riscos, decisoes em aberto Q1-Q6). Completa a rodada de arquitetura `.lionclaw/pipelines/architecture-review/20260825_085318-4ff9ed/`, que fechou as decisoes D1-D4 e parou antes de gerar SPEC/sprints.
- `docs/conducao-agente-20260825.md` — instrucao de conducao: rituais de sessao, guardrails, o que o agente decide sozinho vs escala, proibicoes absolutas.
- `docs/registro-execucao.md` — board vivo de execucao (estado de cada WP, fila de decisoes do dono do produto, achados, historico de sessoes). Atualizar ao fechar cada WP e ao encerrar cada sessao.

Regra minima que resume as demais: nenhuma edicao de codigo antes de WP-0.1 (git funcional — o `.git` atual esta vazio); decisoes D-01..D-13 e D1-D4 nao sao reabriveis; portao E4 e gate duro antes de qualquer migration de dominio operacional.

## Regras de escrita

- Este agente (Feature Discovery) so pode escrever/sobrescrever: `CLAUDE.md` (feito nesta analise) e o arquivo de discovery da execucao atual (`docs/Docs20260824_151851/discovery20260824_151851.md`).
- Codigo do prototipo, migrations e demais documentos existentes sao apenas lidos, nunca alterados por este agente.
- Nota (25/08): a secao "Conducao do projeto" acima foi adicionada pela sessao de planejamento de 25/08; a restricao deste bloco aplica-se ao agente Feature Discovery, nao aos agentes executores regidos por `docs/conducao-agente-20260825.md`.
