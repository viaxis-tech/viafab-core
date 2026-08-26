# Plano de Implementação — ViaFab Core

**Data:** 25/08/2026
**Propósito:** este documento completa a rodada de arquitetura `20260825_085318-4ff9ed` (`.lionclaw/pipelines/architecture-review/`), que fechou as decisões D1–D4 mas parou antes de gerar os artefatos `ArchitectureSpecSource`, `SPEC-20260825` e `sprints-20260825.json` declarados no manifest. Ele consolida tudo que já foi decidido nas rodadas anteriores e define o caminho de execução até o MVP integrado. É o plano canônico do projeto a partir desta data; se o pipeline for retomado, este documento é o insumo.

**Fontes normativas (precedência):**
1. `docs/Docs20260820_134109/design/design-contract.json` (design lock, hash SHA-256) + `docs/Docs20260824_151851/SPEC20260824_151851.md` (SPEC vigente da Fase 0+1)
2. `docs/Docs20260820_134109/SPEC20260820_134109.md` (SPEC do produto completo: 55 tabelas, 111 endpoints, contrato `viaxis.vfb/1`)
3. `.lionclaw/pipelines/architecture-review/20260825_085318-4ff9ed/ArchitectureDecisions-20260825_085318-4ff9ed.md` (decisões de arquitetura D1–D4)
4. `docs/decisoes-fase0-20260824.md` (gate da Fase 0) e `docs/auditoria-design-20260823.md` (fases, P1, P2, portão)

---

## 1. Estado consolidado (fatos verificados em 25/08)

| ID | Fato | Evidência |
|---|---|---|
| F1 | Design lock **aprovado e travado** por SHA-256 (`artifact.html` + `design-contract.json`); universo fixado em US-01..US-28. Nenhuma tela/rota/classe nova sem revisão formal do lock. | `docs/Docs20260820_134109/design/design-lock-report.md`, `manifest.json` (`lockedAt 2026-08-24`) |
| F2 | Fase 0 **fechada, gate LIBERADO**: 13 decisões (9 ACEITA, 4 ADIADA: D-07, D-08, D-10, D-13) + 4 pendências S6/S7/S8/S9-S11 aceitas. | `docs/decisoes-fase0-20260824.md` §5 |
| F3 | Fase 1 (22 P0) **implementada no código, sem encerramento formal**: 19 P0 com marcador `P0-nn` no protótipo; P0-14/16/18 confirmados por inspeção (`index.html:130`, `:39/:84/:205`, `:1763/:19860`). Falta a ata `docs/verificacao-p0-20260824.md` exigida por feat-043[4]; `sprint-validation` parou em "aguardando aprovação final do usuário"; os 9 checkboxes da auditoria seguem desmarcados. | `docs/Docs20260824_151851/sprints20260824_151851.json`, `prototype/index.html` (26.081 linhas, mtime 25/08 07:40) |
| F4 | Plano de sprints 24/08 (12 sprints, 43 features) **completo e validado** (PRD 12/12, SPEC PASS/0 issues, sprints 5/5, enrich 35/35), sem ledger de execução. | `docs/Docs20260824_151851/` |
| F5 | Backend Supabase: **18 de 55 tabelas (~33%)** em 9 migrations — núcleo multiempresa, auditoria append-only, catálogo de engenharia, recursos, versionamento, RLS fail-closed (50 policies, zero policy de DELETE), `fn_custo_aberto`; 62 asserções pgTAP. **Faltam 8 domínios (37 tabelas)**: pedidos/ViaSign, snapshots+ordens, apontamentos, qualidade, estoque, expedição/rastreabilidade, GED, PCP/parâmetros; **8 dos 9 grupos de triggers**; 13 domínios de Edge Functions (111 endpoints); buckets de Storage; integração `viaxis.vfb/1` em 0%. | `supabase/migrations/`, `supabase/tests/`, SPEC0820 §2.1–§3.5, SPEC0824 §7 |
| F6 | Arquitetura 25/08: candidato **C1** escolhido (seam de dados entre domínio e `DB` global); decisões **D1–D4** fechadas (ver §2). Pipeline parou após as decisões. | `ArchitectureDecisions-20260825_085318-4ff9ed.md`, `manifest.json` |
| F7 | Infra de execução **inexistente**: `.git/` presente porém **vazio** (sem HEAD — não há versionamento funcional), sem `package.json`, sem CI (`.github/` ausente), sem testes JS, sem `.env.example`, sem `audit-rls`. Únicos executáveis: `tools/contraste.mjs` e a suíte pgTAP. | verificado nesta sessão |
| F8 | **Bug ativo de corrupção de saldo**: `prototype/index.html:17037` (`it.fis += x.q; it.res += x.q;` sem clamp/arredondamento — resíduo de ponto flutuante a cada estorno) e `:17047` (`DB.auditoria.splice` apaga trilha — operação impossível contra o banco, que tem `REVOKE UPDATE/DELETE` até para `service_role`). | Diagnosis + leitura direta |
| F9 | Armadilhas documentais: numeração US **colidente** entre raiz (`stories-requisitos.md`, US-01..33, escopo ERP completo) e pipeline (`docs/Docs20260824_151851/`, US-01..28, escopo Fase 0+1); `.spec-enricher-suggestions.md` morto (38/38 pendentes sobre `SPEC.md` que não existe); design-contract embutido no `index.html` (`:3187`, `:14186`) ainda declara `text-on-accent:#ffffff`, contradizendo o CSS vivo. | relatórios de inventário desta sessão |

---

## 2. Decisões vigentes (este plano parte delas; não são reabertas)

**Produto (Fase 0, 24/08)** — fonte: `docs/decisoes-fase0-20260824.md`:

| ID | Decisão | Status |
|---|---|---|
| D-01 | Remoção de família paramétrica dedicada/versionamento de norma/roteiro derivado mantida como definitiva | ACEITA |
| D-02 | Snapshot é a única fonte de verdade em execução; ficha vigente alimenta apenas snapshot novo | ACEITA |
| D-03 | Área nominal (consumo) e geométrica (faturamento m²) coexistem com rótulos explícitos | ACEITA |
| D-04 | Chave de dimensão com 1 casa decimal + aviso de colisão | ACEITA |
| D-05 | Ordem de lote fora do avanço por pedido, com rótulo de exclusão | ACEITA |
| D-06 | Operador vê ordens paradas (visibilidade passiva; PCP destrava) | ACEITA |
| D-07 | Descritores MA/MP/MQ | **ADIADA** — insumo do dono do produto |
| D-08 | ViaSign: entrada por ponto de implantação (`placas[]`) | **ADIADA** — reconfirmar com ViaSign antes do portão |
| D-09 | Código de catálogo dedicado para película tipo IV | ACEITA |
| D-10 | Canonicalização do hash do manifesto | **ADIADA** — portão |
| D-11 | `origem.usuario` como identificador opaco (LGPD) | ACEITA |
| D-12 | Variante de formato `sem_quadro` | ACEITA |
| D-13 | ADR-012/`viaxis.vfb` ao repositório + conferência real SHA-256 | **ADIADA** — portão |

S6 (sem Playwright na Fase 1), S7 (buckets ancorados em sprint de infra), S8 (`series_item` com dono explícito), S9/S11 (componentes e triggers com critérios) — todas ACEITAS.

**Arquitetura (25/08)** — fonte: `ArchitectureDecisions-20260825_085318-4ff9ed.md`:

| ID | Decisão |
|---|---|
| D1 | Extração do núcleo de domínio para `.mjs` sob `prototype/`, carregado via `<script type="module">`, com reexposição global temporária. Pré-condição documentada: protótipo servido por HTTP (`file://` deixa de funcionar; `.claude/launch.json` já serve na porta 8931). |
| D2 | Porta de dados **100% assíncrona** desde o início ("converter tudo agora" — escolha explícita do usuário). Alcance: 117 sítios; getters `fis`/`res` (`:15746-15755`) viram chamadas explícitas (embrião: `saldoUn`). |
| D3 | **Compensação total**: nenhuma remoção física através da porta; desfazer é sempre append do inverso. Implica revisão do texto do modal de correção (`:17032`) — toca o design lock. |
| D4 | Rede de proteção **antes** da conversão: (1) `package.json` + `node --test` sem dependências; (2) extração das regras quase-puras com testes de caracterização; (3) porta + guardião único de saldo com teste que reprova `:17037`; (4) conversão em fatias verticais (handler→render→regra→porta), começando pela cadeia saldo/apontamento. Fato que viabiliza o fatiamento: `async` para no handler de evento — não há big bang. |

---

## 3. Decisões em aberto (únicos pontos que exigem o dono do produto)

| ID | Questão | Recomendação | Quando trava |
|---|---|---|---|
| Q1 | **CI: sim ou não?** (D4 deixou explicitamente em aberto) | Sim — GitHub Actions mínimo (`node --test` + `tools/contraste.mjs`; job separado `supabase test db`). Custo ~zero, e a SPEC0820 §3.5 já exige CI de qualquer forma. Depende de o repositório ter remoto Git. | Etapa 0 |
| Q2 | **Forma da compensação**: como o registro anulado é marcado e como o agrupamento de escritas de um apontamento é representado (pendência deixada por D3 para a SPEC nunca gerada) | Proposta em §5, Etapa 1, WP-1.4 — ratificar antes da Etapa 2 | Etapa 1→2 |
| Q3 | **D-07**: significado de negócio das siglas MA/MP/MQ | Só o dono do produto tem a informação | Portão (Etapa 4) |
| Q4 | **D-08 / D-10 / D-13**: reconfirmação do contrato com o time ViaSign + ADR-012 no repositório | Agendar reunião com lead time; integração permanece simulada até lá | Portão (Etapa 4) |
| Q5 | **Fórmula autoritativa do custo aberto**: JS aplica fator de perda em todos os níveis da BOM e trata "processo" como hora-máquina; o SQL não aplica perda e trata "processo" como custo de componentes. A SPEC definiu as colunas, não a fórmula. | Definir a fórmula como decisão de negócio; o SQL (`fn_custo_aberto`) vira a autoridade, o JS vira consumidor; teste de conformidade cruzado trava a igualdade. Nenhuma tela consome o endpoint antes disso. | Etapa 2 (fatia de custo) |
| Q6 | **Shell do produto final**: O1 — protótipo single-file evolui para ser o cliente definitivo (com núcleo `.mjs`); O2 — UI migra para React 19 + Vite + PWA (stack alvo da SPEC0820 §3) reusando o mesmo núcleo. | Decidir **no portão**, com os dados da validação com usuários (Fase 3). Todo o investimento das Etapas 0–3 (núcleo de domínio, porta, adapters, testes) é comum às duas opções — nada se perde adiando. | Portão (Etapa 4) |

Q1 é a única decisão necessária para começar. Q2 se resolve dentro da execução. Q3–Q6 só travam o portão.

---

## 4. Estratégia

1. **O protótipo é o cliente em evolução, não um descartável.** As decisões D1–D4 investem nele: o núcleo de domínio extraído em `.mjs` é agnóstico de framework e sobrevive tanto à opção O1 quanto à O2 de Q6.
2. **Rede de proteção antes de mover qualquer coisa** (D4). A ordem é inegociável: versionamento Git → runner → testes de caracterização → porta/guardião → conversão. Hoje não existe nem `git log` — refatorar 117 sítios sem VCS não é opção.
3. **O `DB` em memória é o primeiro adapter da porta; o Supabase é o segundo.** O seam só existe porque há dois adapters reais e datados.
4. **Compensação como semântica única de desfazer** (D3), alinhando o cliente ao que o banco já impõe (append-only em duas camadas).
5. **O portão de arquitetura (Fase 4 da auditoria) continua sendo o gate para as 37 tabelas restantes.** As 9 migrations existentes são fundação; nenhuma migration de domínio operacional antes dos ADRs do portão.
6. **Design lock respeitado por processo, não por paralisia**: onde D3 ou correções exigirem tocar tela/texto congelado, a mudança passa por revisão formal do lock (novo hash + registro no report), nunca por edição silenciosa.

---

## 5. Etapas de execução

Numeração "Etapa" para não colidir com as "Fases 0–4" da auditoria; o mapeamento está indicado em cada etapa. Estimativas são ordem de grandeza (derivadas do plano da auditoria e das contagens verificadas; não há histórico de velocidade real — ver R8).

### Etapa 0 — Fundação do repositório + encerramento formal da Fase 1 (~1–2 dias)

Fecha o que ficou aberto do plano de 24/08 e cria as pré-condições de D4.

| WP | Entrega | Critério de aceite |
|---|---|---|
| WP-0.1 | `git init` + `.gitignore` (cobrindo `supabase/.temp/` — contém secrets locais do CLI —, `node_modules/`, `.env*`) + commit inicial do estado atual | `git log` mostra o commit; `git status` limpo; nenhum secret rastreado |
| WP-0.2 | `package.json` (`"private": true`, `"type": "module"`, zero dependências) + script `test` rodando `node --test` + script `contraste` | `npm test` executa (smoke) e `npm run contraste` retorna exit 0 |
| WP-0.3 | **Ata `docs/verificacao-p0-20260824.md`**: executar o checklist §6.1/§6.2 da SPEC0824 item a item, com PASSOU/FALHOU | Ata existe, cobre 100% dos itens de 6.1/6.2; itens FALHOU viram correções imediatas; checkboxes da auditoria atualizados onde couber. Fecha feat-043[4] e encerra a Fase 1 |
| WP-0.4 | Higiene documental: arquivar `.spec-enricher-suggestions.md` e `.prd-validation-report.md` (mover para `docs/arquivo/` com nota "superseded"); nota de numeração no topo de `PRD.md` e `stories-requisitos.md` da raiz ("escopo ERP completo, numeração distinta do pipeline 24/08"); criar `MEMORY.md` na raiz (estado vivo do projeto, ≤200 linhas) | Nenhum documento ativo aponta para alvo inexistente; a colisão de numeração está sinalizada na fonte |
| WP-0.5 | CI mínimo (se Q1 = sim): workflow com `node --test` + contraste; job `supabase db start && supabase test db` | Pipeline verde no primeiro push |
| WP-0.6 | `scripts/audit-rls.sh` (escaneia migrations por `CREATE TABLE` sem RLS+policy e `CREATE VIEW` sem `security_invoker`) + hook de pré-commit para `supabase/migrations/` | Rodar o script sobre as 9 migrations existentes retorna limpo; commit tocando migrations dispara o hook |

### Etapa 1 — Rede de proteção de domínio (D4 passos 1–3) (~3–5 dias)

| WP | Entrega | Critério de aceite |
|---|---|---|
| WP-1.1 | Extrair para `prototype/core/*.mjs` as regras quase-puras: `matDaOperacao` (`:21527`), `qPerda`, `explodir`, `custoAberto` (`:19472-19529`), com **testes de caracterização** (congelam o comportamento atual, defeitos incluídos) | Regras importáveis em Node; suíte verde; `index.html` consome via `<script type="module">` + reexposição global; zero mudança de comportamento observável |
| WP-1.2 | Porta de dados assíncrona (leitura e escrita) + adapter memória sobre o `DB` atual | Interface única; nenhum call site convertido ainda; adapter memória passa nos testes da porta |
| WP-1.3 | **Guardião único de saldo** com a invariante "arredondado a 2 casas, não negativo (salvo `PARAM.estoqueNegativo`)" + teste que **reprova de propósito** o comportamento de `:17037` | Teste vermelho contra o código atual documenta o bug; correção de `:17037` via guardião é a primeira mudança de comportamento sancionada; os 6 sítios de mutação de saldo passam pelo guardião |
| WP-1.4 | **Design da compensação (resolve Q2)** — proposta: toda operação de apontamento agrupa suas escritas sob um `grupo_escrita_id` (compatível com `client_generated_id` do sync offline futuro); anulação é um registro inverso com `anula_id` apontando o original; leituras filtram anulados por padrão; reversão referencia **o que** foi escrito, nunca contagens de índice (`ev0`/`au0`/`r0`/`c0`/`m0` morrem) | Documento curto ratificado pelo dono do produto antes da Etapa 2 |
| WP-1.5 | Relógio injetável (testa a janela de estorno de 10 min) e gerador de identidade como parâmetro (prepara a identidade vinda do banco; `seqCfg`/`seqSnap`/`seqOrd` deixam de ser acessados diretamente) | Teste de limite da janela de estorno passa com relógio controlado |

### Etapa 2 — Conversão async + compensação em fatias verticais (D2/D3/D4 passo 4) (~8–12 dias)

Cada fatia converte handler→render→regra→porta e termina com `npm test` verde + contraste exit 0. Ordem:

| Fatia | Escopo | Ponto crítico |
|---|---|---|
| F-2.1 | **Cadeia saldo/apontamento**: `reservarMaterial` (`:16495`), `liberarReserva` (`:16472`), `baixaAutomatica` (`:21550`), `finalizarOperacao`, `corrigirApontamento` (`:17021`) | Fim dos `splice` de reversão; compensação conforme WP-1.4; escrita crítica sai do callback do modal; texto do modal (`:17032`) muda → **revisão formal do design lock** |
| F-2.2 | **PCP preview/execução** (candidato C4): opções de planejamento viram estado de domínio lido uma vez; preview passa a ser leitura do mesmo cálculo da execução | Elimina a dupla leitura do DOM (`:22960` vs `:23042`); motor de PCP roda em Node |
| F-2.3 | **Permissões** (candidato C5): representação única carregada da sessão; `perm()` mantido como portão único; tradutor de/para o formato `jsonb` de `perfis.permissoes` | UI e RLS param de poder discordar por construção |
| F-2.4 | **Custo** (candidato C2): `custoAberto` consumindo o núcleo + **teste de conformidade cruzado** (mesma BOM no JS e em `fn_custo_aberto`) | O teste reprova até Q5 ser decidida e um dos lados ajustado; nenhuma tela consome o endpoint antes do verde |
| F-2.5 | Demais módulos por dependência: qualidade, expedição, GED, relatórios, admin | Zero mutação direta de `DB.*` fora do adapter ao final |

**Saída da Etapa 2:** zero `push/unshift/splice` em coleções de domínio fora do adapter; zero remoção física; leituras filtrando anulados; getters `fis`/`res` substituídos por chamadas explícitas.

### Etapa 3 — Fase 2 da auditoria (14 grupos P1) + Fase 3 (validação com usuários) (~10–14 dias, parcialmente paralela à Etapa 2)

- Ordem da auditoria: G-01/02 → G-04/05 → G-06 → G-09/10 → G-12/13 → restantes; lista P2 como enchimento.
- Regra de intercalação: P1 que toca regra de negócio espera a fatia convertida daquela área (evita retrabalho e conflito no arquivo único); P1 puramente visual (G-12 alvos ≥44px, G-13 impressão, G-14 a11y estrutural) pode antecipar.
- Fase 3 ao final: 5 walkthroughs gravados (PCP, Operador em tablet físico, Almoxarifado, Qualidade+Expedição, Direção) com dados reais da fábrica-piloto; OS/etiqueta validadas em papel; P0 novos zerados.
- **Saída:** os 9 critérios de aceite da etapa de design (auditoria, linhas 83–91) todos marcados.

### Etapa 4 — Portão de arquitetura (Fase 4 da auditoria) (~1 semana de ADRs + lead time dos insumos externos)

Gate antes de qualquer migration de domínio operacional. Entradas exigidas: Q3 (D-07), Q4 (reunião ViaSign: D-08/D-10/D-13 + ADR-012 no repo), Q5 (custo), Q6 (shell).

Um ADR por risco do portão:

| # | Item do portão | Observação |
|---|---|---|
| 1 | RLS server-side (delta-005, bloqueante) | Parcialmente satisfeito pelas 50 policies existentes; o ADR consolida o regime para as 37 tabelas novas |
| 2 | Idempotência em 4 fluxos (`fn_gerar_ordens`, `fn_finalizar_operacao`, `fn_reservar_material` + importação) | Pendência formal SPEC0824 §7 |
| 3 | IDs estáveis (sequência server-side para OS — complemento do P0-20; setor; dimensão) | `os_ids[]` local é paliativo declarado |
| 4 | QR/etiqueta assinados + verificação real do `.vfb` (SHA-256) | Depende de D-13 |
| 5 | Parâmetros por tenant versionados (delta-078) | Tabela `parametros_sistema` |
| 6 | Concorrência: romaneio/replanejamento/realocação (deltas 057/065/058) | `SELECT ... FOR UPDATE` no saldo já especificado (trg) |
| 7 | Snapshot imutável real (delta-026, RNF-13) | Primeiro uso do padrão `snapshot_revisao_de_id` |

**Saída exigida (auditoria, linha 79):** 1 ADR por risco + schema revisado das 37 tabelas + plano de testes multi-tenant (US-26). As 16 pendências formais da SPEC0824 §7 ficam cada uma mapeada a um ADR ou WP da Etapa 5.

### Etapa 5 — Backend restante + integração real (~4–6 semanas, entregável por domínio)

Cada domínio segue o padrão do repositório: migration de schema → migration de RLS separada → triggers → pgTAP → seed → adapter no cliente. Ordem por dependência:

| WP | Domínio | Conteúdo principal |
|---|---|---|
| WP-5.1 | Estoque base | `depositos`, `lotes_material`, `saldo_estoque`, `reservas`, `separacoes`, `movimentos_estoque` (append-only), `rastreio_consumo`, `transferencias_unidade`; `trg_saldo_estoque_movimento` (`FOR UPDATE`), `trg_reserva_saldo`; seed de depósitos |
| WP-5.2 | Produção | `snapshots` (imutável, RNF-13), `ordens_producao`, `itens_ordem`, `linhas_os`, `operacoes_ordem`, `programacao_operacao`, `programacao_ancora`, `eventos_ordem` (append-only), `conclusao_ordem`; `trg_ordem_status_material` |
| WP-5.3 | Chão de fábrica | `apontamentos` (`sync_status`/`client_generated_id`), `estornos_apontamento` (janela 10 min), `consumos`, `perdas`, `bloqueios`, `retrabalhos`; `trg_apontamento_tempo`, `trg_estorno_expira`, `trg_baixa_automatica_consumo` |
| WP-5.4 | Qualidade + expedição | `inspecoes`, `series_item`, `series_deposito` (S8), `remessas`, `romaneios`; `trg_bloqueio_qualidade` |
| WP-5.5 | Pedidos/clientes/ViaSign | `clientes`, `pedidos`, `linhas_pedido`, `linhas_orcamento`, `vfb_manifestos` (`schema` const `viaxis.vfb/1`), `vfb_importacoes` — **somente após Q4** |
| WP-5.6 | PCP/GED/transversais | `planos_producao`, `parametros_sistema` (defaults conservadores da SPEC0820 §2.4), `documentos_ged`; buckets `documentos-ged`/`arquivos-vfb`/`etiquetas` + policies de Storage (S7); `trg_auditoria_generica`; trigger de versionamento de `roteiros_base` (pendência SPEC0824 §7) |
| WP-5.7 | Superfície de API | Recomendação a ratificar no portão: PostgREST + RPC sob RLS para CRUD; Edge Functions apenas onde há orquestração/idempotência (`gerar ordens`, `finalizar operação`, `reservar`, importação `.vfb`) + `shared/{auth,rbac,tenant-guard,idempotency,audit}` — em vez de materializar os 111 endpoints de uma vez |
| WP-5.8 | Adapter Supabase da porta | O segundo adapter que justifica o seam; Auth com claims `app_metadata` (tenant/perfil/unidades); matriz de permissões carregada de `perfis.permissoes`; custo via `fn_custo_aberto`; sync offline (`sync_status`, `client_generated_id`) |
| WP-5.9 | Qualidade de entrega | Playwright E2E (S6 adiado para cá), `.env.example`, deploy Vercel + Supabase, Sentry |

Critério de integração por domínio: a fatia correspondente do protótipo opera contra `supabase start` local com RLS ativa, e a suíte pgTAP do domínio passa.

---

## 6. Riscos

| ID | Risco | Mitigação |
|---|---|---|
| R1 | Refatoração de 117 sítios **sem versionamento** (`.git` vazio) | Etapa 0 antes de qualquer edição de código; inegociável |
| R2 | Regressão na conversão async | Testes de caracterização primeiro (WP-1.1); fatias verticais; fato verificado de que `async` para no handler — não há contaminação infinita |
| R3 | D3 e correções tocam conteúdo congelado pelo design lock | Processo formal de revisão do lock (novo hash + registro no report); nunca edição silenciosa |
| R4 | Numeração US colidente induz erro de referência | WP-0.4 sinaliza na fonte; novas referências sempre citam a rodada |
| R5 | Custo aberto divergente exibe número de dinheiro errado ao ligar o endpoint | Teste de conformidade cruzado (F-2.4) como pré-condição de consumo; Q5 decide a fórmula |
| R6 | `fn_versao_*` calcula `max+1` sem lock — INSERT concorrente falha na unique | Falha segura; registrar no ADR de concorrência (portão item 6); serializar se virar dor real |
| R7 | Contrato ViaSign não confirmado (D-08/D-10/D-13) | Integração permanece simulada; WP-5.5 bloqueado até Q4 |
| R8 | Estimativas sem histórico de velocidade real | Tratar como ordem de grandeza; replanejar ao fim de cada etapa (rolling wave: detalhe fino só na etapa corrente) |

---

## 7. Dependências e sequência

```
Etapa 0 ──> Etapa 1 ──> Etapa 2 ──┬──> Etapa 4 (portão) ──> Etapa 5
                        Etapa 3 ──┘
   Q1            Q2 (WP-1.4)        Q3, Q4, Q5*, Q6
```

- Etapa 3 corre parcialmente em paralelo à Etapa 2 (regra de intercalação em §5).
- Q5 pode ser antecipada para destravar F-2.4 dentro da Etapa 2.
- Total estimado até o MVP integrado: **~10–14 semanas** de esforço, mais lead time dos insumos externos (ViaSign, fábrica-piloto).

---

## 8. Próximas ações

- **A1** — Executar a Etapa 0 (WP-0.1 a WP-0.6). Única decisão pendente: **Q1** (CI; recomendação: sim).
- **A2** — Agendar desde já, por lead time: resposta de **D-07** (dono do produto) e reunião com o time **ViaSign** (D-08/D-10/D-13 + ADR-012). Necessárias apenas no portão, mas são os itens de maior latência externa.
- **A3** — Ratificar a proposta de compensação (WP-1.4 / Q2) quando a Etapa 1 a apresentar.
