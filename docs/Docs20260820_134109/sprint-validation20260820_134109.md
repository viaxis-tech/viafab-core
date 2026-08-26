# Relatorio de Validacao de Sprints - ViaFab ERP (Development Pipeline 2.0)

- Data: 2026-08-24
- SPEC: SPEC20260820_134109.md (849 linhas, lida integralmente)
- Plano: sprints20260820_134109.json (26 sprints, 86 features, lido integralmente)
- Design lock: design/design-contract.json + design/artifact.html (APROVADO, locked)
- Status geral: **APROVAVEL COM AJUSTES RECOMENDADOS** (3 avisos, 4 observacoes; nenhuma falha critica)

## Regra obrigatoria do Pipeline 2.0 (touchesUI / affectedScreenIds / designArtifactPath)

| Sprint | touchesUI | affectedScreenIds | designArtifactPath | Resultado |
|---|---|---|---|---|
| 001-005, 007, 009, 011, 013, 015, 017, 019, 021, 023, 025 | false | [] (coerente) | n/a | PASS |
| 006 | true | login, acesso-negado | presente | PASS |
| 008 | true | itens, fichas | presente | PASS |
| 010 | true | recursos, clientes | presente | PASS |
| 012 | true | pedidos | presente | PASS |
| 014 | true | ged, orcamento | presente | PASS |
| 016 | true | ordens, ordem-detalhe | presente | PASS |
| 018 | true | plano | presente | PASS |
| 020 | true | estoque, unidades, parametros | presente | PASS |
| 022 | true | chao-de-fabrica, qualidade | presente | PASS |
| 024 | true | expedicao, os-impressa, item | presente | PASS |
| 026 | true | dashboard, inicio, relatorios, auditoria | presente | PASS |

Nenhuma sprint com touchesUI=true tem affectedScreenIds vazio. Todos os screenIds e componentIds usados existem no design-contract.json (verificado por busca literal). **Regra do pipeline: PASS.**

## Itens de validacao

### S1 [PASS] Cobertura de telas do design lock
As 24 telas do contrato estao atribuidas a exatamente uma sprint de frontend (006, 008, 010, 012, 014, 016, 018, 020, 022, 024, 026). Nenhuma tela orfa; nenhuma tela fora do contrato.

### S2 [PASS] Cobertura de endpoints (111 apiExpectations)
Conferencia por dominio: auth 4 (s005), ordens 8 (s015), estoque 7 (s019), chao-de-fabrica 10 (s021), qualidade 2 (s021), expedicao 8 (s023), itens-fichas 14 fisicos (s007), recursos 7 (s009), pedidos 11 (s011), clientes 5 (s009), plano 11 (s017 + api-plano-incluir em s011), auditoria-painel 8 fisicos (s025), ged-orcamento-os 10 (s013), unidades-parametros 4 (s019). Total: 111/111. Os pares de mesmo path (api-ficha-versao/publicar, api-auditoria/consulta) e os paths distintos api-plano-priorizar vs api-plano-ordenacao foram tratados conforme SPEC 3.2.

### S3 [PASS] Cobertura das 28 user stories
Todas as US rastreiam para pelo menos uma sprint via mapeamento tela/endpoint (SPEC 4.2/4.7). US-04 (snapshot) em s003/s017; US-26/27/28 em s001/s005/s006/s026.

### S4 [PASS] IDs de telas e componentes vs design-contract.json
Todos os affectedScreenIds e affectedComponentIds das 11 sprints de UI existem literalmente no contrato. Nenhum ID inventado.

### S5 [PASS] Dependencias
Ordem respeitada: banco (001-004) -> shared/auth/CI (005) -> pares backend->frontend por dominio. Nenhum frontend antecede seu backend. Sem ciclos; todo dep tem index menor. Encadeamento de reuso correto (fila offline s020 -> s022; cmp-bom-tree s008 -> s016; api-plano-incluir s011 -> s017).

### S6 [WARN] Playwright/E2E ausente do plano
SPEC (stack, 3.1 tests/e2e e 3.5 CI) preve Playwright E2E por user story. O plano usa config use_playwright=false e a sprint-005 (feat-023) exclui Playwright explicitamente. Divergencia SPEC vs plano: confirmar se e decisao consciente desta fase (registrar nota no plano) ou adicionar sprint/feature de E2E.

### S7 [WARN] Criacao dos buckets de Storage sem feature/criterio explicito
SPEC 3.5/5.2 exige buckets documentos-ged, arquivos-vfb, etiquetas com politicas por caminho {tenant_id}/{unidade_id}/... As sprints 011/013/021 usam os buckets, mas nenhuma sprint tem criterio de aceite de criacao dos buckets + policies de Storage. Sugestao: adicionar criterio na sprint-004 (infra de banco/storage) ou na primeira sprint consumidora (011).

### S8 [WARN] Geracao de series_item (rastreabilidade unitaria) sem dono explicito
A sprint-023 assume "series geradas na producao — sprint-021" (hint), mas nenhuma feature/criterio da sprint-021 cobre a criacao de series_item/series_deposito na conclusao da operacao/ordem (US-24/rastreabilidade, base de api-serie-item e etiquetas). Sugestao: adicionar criterio de aceite na feat-068 ou feat-069 da sprint-021.

### S9 [INFO] Componentes do contrato nao listados em nenhuma sprint
cmp-tabs (shell/telas com abas), cmp-esquema-placa (pedidos/item), cmp-tabela-lotes (estoque/ged). As listas sao declaradas como "principais" e os hints mandam consultar usedInScreenIds, mas recomenda-se adiciona-los as sprints correspondentes (006/012/020) para rastreabilidade completa.

### S10 [INFO] Sizing da sprint-004
Sprint mais pesada do plano: ~20 tabelas + 8 triggers + views derivadas + seeds em 3 rounds (teto do config). Aceitavel por ser trabalho homogeneo de SQL, mas e o maior risco de estouro de rounds. Opcional: dividir triggers/views em sprint propria.

### S11 [INFO] Criterios de aceite de triggers incompletos (feat-018)
trg_apontamento_tempo e trg_estorno_expira aparecem na descricao mas nao possuem criterio de aceite verificavel proprio. Sugestao: adicionar 2 criterios (calculo de tempo_min ao preencher fim; estorno recusado/invalidado apos 10 min).

### S12 [PASS] Scope creep
Unico acrescimo fora da secao 2.1 da SPEC: tabelas contratos/itens_contrato (sprint-003, feat-011) — justificado no proprio plano como derivacao necessaria dos endpoints api-contratos/api-itens-contrato/api-medicao-contrato do design lock. Nao e scope creep.

### S13 [PASS] Hints e continuidade
Todas as sprints pos-001 referenciam arquivos/interfaces criados anteriormente (migrations, guards shared, schemas.ts por dominio, modulos de UI reutilizados). Notas de arquitetura consistentes com SPEC.

## Decisoes pendentes com o usuario
1. S6: registrar nota justificando ausencia de Playwright OU adicionar cobertura E2E.
2. S7: onde ancorar a criacao dos buckets de Storage (sprint-004 ou 011).
3. S8: adicionar criterio de geracao de series_item na sprint-021.
4. S9/S11: ajustes menores opcionais (componentes faltantes nas listas; criterios de triggers).

## Historico
- 2026-08-24: relatorio inicial criado. Nenhuma edicao aplicada ao sprints.json ainda.
