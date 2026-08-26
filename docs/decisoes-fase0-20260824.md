# Registro de decisões — Fase 0 (gate obrigatório)

> Documento gerado em 24/08/2026 para fechar formalmente a Fase 0 do plano de correção definido em `docs/auditoria-design-20260823.md`. **Nenhum código do protótipo (`prototype/index.html`) foi alterado nesta sprint** — este é um registro de rastreabilidade, não uma implementação.

## 1. Declaração do gate

**A Fase 1 (correção dos 22 P0 do protótipo) só pode iniciar depois que este registro estiver completo**, ou seja: com as 13 decisões D-01 a D-13 e as 4 pendências do sprint-validation (S6, S7, S8, S9/S11) classificadas com status explícito (ACEITA, ADIADA ou REJEITADA) e fonte citada. Qualquer item cujo status não conste literalmente em uma das fontes abaixo é registrado como `PENDENTE-ESCALADO` na Seção 4 — nunca inferido ou presumido pelo agente.

### Regra de precedência das fontes

Em caso de divergência de status entre fontes para o mesmo item, prevalece, nesta ordem:

1. **`docs/Docs20260820_134109/design/design-contract.json` + `docs/Docs20260824_151851/SPEC20260824_151851.md`** (mesmo nível de precedência — fonte literal de telas/rotas/componentes/API e SPEC vigente do produto)
2. **`docs/Docs20260820_134109/sprint-validation20260820_134109.md`** (validação técnica do plano de sprints de implementação)
3. **`docs/auditoria-design-20260823.md`** (auditoria de UX/design que originou a numeração D-01..D-13, mas não fecha status — a auditoria lista as decisões como "em aberto")

**Nota sobre o uso do discovery como evidência de detalhe**: a SPEC vigente (`docs/Docs20260824_151851/SPEC20260824_151851.md`, linha 10) afirma o agregado — "13 decisões de produto aceitas (D-01 a D-13, com 4 adiadas)" — e o PRD da mesma execução (`docs/Docs20260824_151851/PRD20260824_151851.md`, linha 443) confirma o mesmo agregado ("13 das 17 decisões pendentes... resolvidas nesta execução, sem nenhuma rejeitada; as 4 decisões adiadas (D-07, D-08, D-10, D-13)"). O detalhamento status-por-item com justificativa individual está registrado em `docs/Docs20260824_151851/discovery20260824_151851.md` (linhas 26-53), documento-base que a SPEC consolida. Este registro usa o discovery como evidência primária de cada status individual, sempre corroborado pelo agregado citado literalmente na SPEC e no PRD da mesma execução — logo, sem violar a precedência declarada acima (SPEC e discovery não divergem; discovery apenas detalha o que a SPEC afirma de forma agregada).

**Nota sobre `design-contract.json`**: este arquivo é entregável da execução anterior (`Docs20260820_134109`), produzido **antes** da auditoria de 23/08 que formalizou a numeração D-01..D-13 e **antes** das decisões terem sido tomadas em 24/08. Ele contém texto narrativo residual mencionando D-02 ("a decisão D-02 sobre qual fonte prevalece na BOM segue em aberto", linha 12061) e um comportamento de fila do operador consistente com o estado pré-D-06 (linha 11390). Esse texto não é um campo de status formal (não usa ACEITA/ADIADA/REJEITADA) e é anterior cronologicamente às fontes de 24/08 — não configura divergência de status entre fontes de mesmo nível de precedência, apenas desatualização esperada de um artefato produzido antes da decisão existir. Não escalado como `PENDENTE-ESCALADO`.

---

## 2. Decisões de produto D-01 a D-13

Fonte primária do status individual e da justificativa: `docs/Docs20260824_151851/discovery20260824_151851.md`, seção "Status final — 13 decisões de produto (D-01 a D-13)" (linhas 26-44). Agregado corroborado por `docs/Docs20260824_151851/SPEC20260824_151851.md` (linha 10) e `docs/Docs20260824_151851/PRD20260824_151851.md` (linha 443). Numeração e tema originados em `docs/auditoria-design-20260823.md` (linha 69), onde as decisões aparecem listadas como "em aberto" (sem status — a auditoria não fecha status, apenas levanta o item).

| ID | Tema (fonte: auditoria, linha 69) | Status | Documento-fonte do status | Resumo da decisão |
|---|---|---|---|---|
| D-01 | Família paramétrica/normas/roteiro derivado removidos (delta-053/054/055/026) | **ACEITA** | `docs/Docs20260824_151851/discovery20260824_151851.md`, linha 32 | Remoção mantida como definitiva: sem família paramétrica dedicada, sem versionamento de norma técnica, roteiro único global editável em Recursos/Processos. Risco de não conformidade regulatória registrado para revalidação na Fase 3. |
| D-02 | Ficha manual × BOM por fórmula (delta-014, delta-093/094) | **ACEITA** | `docs/Docs20260824_151851/discovery20260824_151851.md`, linha 33 | Snapshot é a única fonte de verdade em execução/apontamento/comparação planejado×realizado; ficha vigente alimenta apenas um **novo** snapshot; correção de ficha com ordem em curso passa por revisão de ordem explícita. Confirma escopo estendido de P0-08 (+2 a 3 dias). |
| D-03 | Área nominal × geométrica no contrato por m² (delta-087) | **ACEITA** | `docs/Docs20260824_151851/discovery20260824_151851.md`, linha 34 | Os dois números coexistem com rótulo explícito: área nominal (retângulo) para consumo de chapa/corte; área geométrica real para faturamento por m² de face, quando aplicável. |
| D-04 | Chave de dimensão com 1 casa decimal (delta-068) | **ACEITA** | `docs/Docs20260824_151851/discovery20260824_151851.md`, linha 35 | Mantida a chave com 1 casa decimal + aviso de possível colisão na linha do importador (RF-48). Migração para 2 casas adiada até evidência de colisão real em produção. |
| D-05 | Ordem de lote rateia avanço entre pedidos (delta-025) | **ACEITA** | `docs/Docs20260824_151851/discovery20260824_151851.md`, linha 36 | Ordem de lote não rateia avanço entre pedidos atendidos; fica de fora do indicador de avanço por pedido em Clientes/entregas, com rótulo explícito da exclusão. |
| D-06 | Operador vê ordens paradas (delta-034) | **ACEITA** | `docs/Docs20260824_151851/discovery20260824_151851.md`, linha 37 | Operador passa a ter visibilidade passiva de ordens bloqueadas/paradas na fila (sem ação de destravar); PCP continua único ponto de decisão para destravar. |
| D-07 | Descritores dos formatos MA/MP/MQ (delta-035) | **ADIADA** — destino: decisão humana do dono do produto (pré-requisito para qualquer fase futura, sem fase-alvo fixa) | `docs/Docs20260824_151851/discovery20260824_151851.md`, linhas 38 e 57 | Não decidida pelo agente por depender de informação de negócio (significado de cada sigla no catálogo de origem) que só o dono do produto tem. Mantido placeholder/genérico até a decisão humana. |
| D-08 | ViaSign: entrada por ponto de implantação (delta-070) | **ADIADA** — destino: Fase 4 (portão de arquitetura), reconfirmação com o time do ViaSign antes da Fase 4 | `docs/Docs20260824_151851/discovery20260824_151851.md`, linhas 39 e 58 | Confirmação do formato `placas[]` por ponto de implantação fica para antes da Fase 4. Não bloqueia a Fase 1 porque a integração real com ViaSign está fora do MVP (simulada). |
| D-09 | Código de catálogo para película tipo IV (delta-073) | **ACEITA** | `docs/Docs20260824_151851/discovery20260824_151851.md`, linha 40 | Criado código de catálogo dedicado para película tipo IV (NBR 14891), em vez de mapear por aproximação ou manter a recusa na conferência. |
| D-10 | Canonicalização do hash do manifesto (delta-071) | **ADIADA** — destino: Fase 4 (portão de arquitetura), junto com assinatura de QR/etiqueta | `docs/Docs20260824_151851/discovery20260824_151851.md`, linhas 41 e 58 | Hash do manifesto continua tratado como identificador opaco no MVP (sem recalcular/verificar). Canonicalização fica para a Fase 4, mesma família de problema de integridade do QR/etiqueta. |
| D-11 | E-mail no `.vfb` — exposição de dado pessoal (LGPD, delta-075) | **ACEITA** | `docs/Docs20260824_151851/discovery20260824_151851.md`, linha 42 | `origem.usuario` passa a ser identificador opaco no manifesto, em vez de e-mail em texto plano. |
| D-12 | `sem_quadro` na nomenclatura (delta-069) | **ACEITA** | `docs/Docs20260824_151851/discovery20260824_151851.md`, linha 43 | Criada variante de formato que já embute a ausência de quadro, em vez de sexta parte na nomenclatura ou aviso sem bloqueio. |
| D-13 | ADR-012 / `viaxis.vfb` ausente do repositório (delta-067) | **ADIADA** — destino: Fase 4 (portão de arquitetura), reconfirmação com o time do ViaSign antes da Fase 4 | `docs/Docs20260824_151851/discovery20260824_151851.md`, linhas 44 e 58 | Não bloqueia a Fase 1. Trazer o ADR-012 ao repositório (ou confirmar fonte canônica) e implementar conferência real de bytes/SHA-256 fica como pendência formal para a Fase 4. |

**Contagem de verificação**: 13 entradas (D-01 a D-13, sem lacunas) · 9 ACEITA · 4 ADIADA (D-07, D-08, D-10, D-13) · 0 REJEITADA — consistente com o agregado da SPEC (linha 10) e do PRD (linha 443) da execução `Docs20260824_151851`.

---

## 3. Pendências do sprint-validation (S6, S7, S8, S9/S11)

Fonte primária do status: `docs/Docs20260824_151851/discovery20260824_151851.md`, seção "Status final — 4 pendências do relatório de validação de sprints" (linhas 46-53). Origem/trecho de cada pendência: `docs/Docs20260820_134109/sprint-validation20260820_134109.md`.

| ID | Trecho/seção de origem (sprint-validation) | Status | Documento-fonte do status | Resumo |
|---|---|---|---|---|
| S6 | `### S6 [WARN] Playwright/E2E ausente do plano` (linhas 45-46): "SPEC (...) preve Playwright E2E por user story. O plano usa config `use_playwright=false`... confirmar se é decisão consciente desta fase (...) ou adicionar sprint/feature de E2E" | **ACEITA** | `docs/Docs20260824_151851/discovery20260824_151851.md`, linha 50 | Registrada nota explícita no plano de sprints justificando a ausência de Playwright nesta fase; não expande o escopo da Fase 1, que foca no protótipo. |
| S7 | `### S7 [WARN] Criacao dos buckets de Storage sem feature/criterio explicito` (linhas 48-49): buckets `documentos-ged`, `arquivos-vfb`, `etiquetas` usados nas sprints 011/013/021 sem critério de aceite de criação/policies | **ACEITA** | `docs/Docs20260824_151851/discovery20260824_151851.md`, linha 51 | Criação dos 3 buckets e respectivas policies ancorada na sprint de infraestrutura (sprint-004), antes de qualquer sprint consumidora. |
| S8 | `### S8 [WARN] Geracao de series_item (rastreabilidade unitaria) sem dono explicito` (linhas 51-52): nenhuma feature/critério da sprint-021 cobre criação de `series_item`/`series_deposito` na conclusão da operação/ordem | **ACEITA** | `docs/Docs20260824_151851/discovery20260824_151851.md`, linha 52 | Critério de aceite explícito adicionado à sprint-021 para gerar `series_item`/`series_deposito` na conclusão da operação/ordem (US-24). |
| S9/S11 | `### S9 [INFO]` (linhas 54-55, componentes `cmp-tabs`/`cmp-esquema-placa`/`cmp-tabela-lotes` fora das sprints) + `### S11 [INFO]` (linhas 60-61, critérios de `trg_apontamento_tempo`/`trg_estorno_expira` incompletos em feat-018); agrupados como item único em "Decisões pendentes com o usuário", item 4 (linha 73) | **ACEITA** | `docs/Docs20260824_151851/discovery20260824_151851.md`, linha 53 | Componentes adicionados explicitamente às sprints 006/012/020; critérios de aceite de `trg_apontamento_tempo` e `trg_estorno_expira` adicionados à feat-018. |

**Nota de escopo**: S10 (`[INFO] Sizing da sprint-004`, linhas 57-58 do sprint-validation) não faz parte das "4 pendências" — a própria seção "Decisões pendentes com o usuário" do sprint-validation (linhas 69-73) lista apenas S6, S7, S8 e S9/S11 como itens que exigem decisão; S10 é observação informativa sem ação pendente. Consistente com o escopo desta sprint ("S9/S11").

---

## 4. Divergências escaladas ao humano

Nenhum item de decisão de produto (D-01..D-13) ou de pendência de sprint (S6, S7, S8, S9/S11) ficou sem status determinável nas fontes pesquisadas. Todas as 13 decisões e as 4 pendências têm status explícito citado com documento-fonte na Seção 2 e na Seção 3.

Não há, portanto, itens `PENDENTE-ESCALADO` nesta rodada.

**Pendências humanas remanescentes que NÃO são status indeterminado** (para clareza — já têm status ADIADA fechado, mas o *conteúdo final* da decisão depende de insumo humano futuro, registrado explicitamente em `docs/Docs20260824_151851/discovery20260824_151851.md`, linhas 55-58):

- **D-07**: dono do produto precisa informar o significado de negócio das siglas MA/MP/MQ antes de existirem descritores definitivos.
- **D-08, D-10, D-13**: reconfirmação com o time do ViaSign exigida antes da Fase 4 (portão de arquitetura).

Essas pendências não bloqueiam a Fase 1 (confirmado em `docs/Docs20260824_151851/discovery20260824_151851.md`, linha 70) e ficam registradas como entrada de trabalho da Fase 4.

---

## 5. Veredicto

## GATE LIBERADO

Critério de liberação: zero itens `PENDENTE-ESCALADO` nas Seções 2 e 3. As 13 decisões de produto (9 ACEITA + 4 ADIADA, 0 REJEITADA) e as 4 pendências de sprint-validation (4 ACEITA) estão registradas com status explícito e fonte rastreável. As 4 decisões adiadas (D-07, D-08, D-10, D-13) têm destino declarado (decisão humana do dono do produto para D-07; Fase 4 — portão de arquitetura, condicionada a reconfirmação com o ViaSign — para D-08, D-10 e D-13) e não bloqueiam a Fase 1.

**A Fase 1 (correção dos 22 P0 do protótipo, `docs/auditoria-design-20260823.md`) está liberada para início.**
