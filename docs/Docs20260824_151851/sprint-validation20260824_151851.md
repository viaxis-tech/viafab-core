# Relatorio de Validacao de Sprints — ViaFab Fase 0+1
> Validador de Sprints | Gerado em 24/08/2026 | SPEC: SPEC20260824_151851.md | Plano: sprints20260824_151851.json

## 1. Matriz de cobertura SPEC -> Sprints

| Dominio SPEC | Stories/Requisitos | Sprint que cobre | Status |
|---|---|---|---|
| Fase 0 (gate D-01..D-13 + pendencias) | Gate obrigatorio do projeto | sprint-001 (feat-001..003) | COBERTO |
| Infra transversal (confirmarEfeito, localStorage versionado, constantes, estado vazio) | Decisoes F-2, 2.1.3, 2.1.2, 4.3 | sprint-002 (feat-004..007) | COBERTO |
| F — Acessibilidade/temas | US-17, US-18, US-19, US-20 + RNF-01 (tools/contraste.mjs) | sprint-003 (feat-008..011) | COBERTO |
| A — Ficha tecnica | US-01, US-02, US-03 | sprint-004 (feat-012..015) | COBERTO (ver S2) |
| B — Geracao de ordens + reservas | US-04, US-06 | sprint-005 (feat-016..018) | COBERTO |
| B — Finalizacao/estorno/desbloqueio | US-05 | sprint-006 (feat-019..021) | COBERTO |
| C — Qualidade/Expedicao | US-07, US-08, US-09 (+P0-03 regressao) | sprint-007 (feat-022..025) | COBERTO |
| D — Importacao .vfb | US-10, US-11, US-12, US-13 + RF-48 (D-04, sem US dedicada) | sprint-008 (feat-026..029) | COBERTO |
| E — Inicio/atalhos/teclado | US-14, US-15, US-16 (+P0-11/12/13) | sprint-009 (feat-030..033) | COBERTO |
| G — Painel/Relatorios | US-21, US-22, US-23 | sprint-010 (feat-034..036) | COBERTO |
| H — OS/QR estavel | US-24 (P0-20) | sprint-011 (feat-037) | COBERTO |
| I — Auditoria | US-25 (P0-21, RF-44) | sprint-011 (feat-038..039) | COBERTO |
| J — Comercial/lote/operador | US-26, US-27, US-28 | sprint-012 (feat-040..042) | COBERTO |
| Criterios de verificacao (SPEC secao 6) | 6.1 + 6.2 | sprint-012 (feat-043) | COBERTO (ver S3) |

**Resultado de cobertura**: as 28 US, o RF-48 (sem US dedicada) e os 22 P0 tem sprint correspondente. **Nenhuma lacuna critica de cobertura.** Nenhum scope creep identificado (nenhuma feature das sprints esta fora da SPEC; sprint-001 deriva do gate declarado no projeto).

## 2. Problemas identificados

### S1 — Dependencias incompletas da sprint-012 (severidade: ALTA) — status: RESOLVIDO (aplicado em 24/08)
A feat-043 (verificacao transversal final, SPEC secao 6) valida itens entregues por **todas** as sprints anteriores, incluindo P0-11/12/13 (sprint-009) e RF-35/RF-37 (sprint-010). Porem `sprint-012.dependencies = [001, 002, 003, 005, 006, 007, 011]`:
- sprint-004 esta coberta transitivamente (007 depende de 004) e sprint-008 tambem (011 depende de 008);
- **sprint-009 e sprint-010 NAO estao na cadeia de dependencias**, nem direta nem transitivamente. A sprint-012 poderia ser escalonada antes delas, e a verificacao final rodaria sobre um conjunto incompleto.
**Ajuste proposto**: adicionar `"sprint-009"` e `"sprint-010"` a `sprints[11].dependencies`.

### S2 — Faixa "ordens afetadas" (P0-07) sem criterio de aceite verificavel (severidade: MEDIA) — status: RESOLVIDO (aplicado em 24/08)
A SPEC (4.2, Dominio A) exige o componente "Faixa 'ordens afetadas' (P0-07) [reaproveita .aviso-filtro]" na tela de detalhe da ficha. Na sprint-004 esse item aparece apenas em `hints` (key_interfaces e architecture_notes), mas **nenhum criterio de aceite** de feat-012/feat-013 exige a faixa na tela — o Coder pode entregar so o modal de publicacao e o criterio passa.
**Ajuste proposto**: adicionar criterio em feat-013: "Ficha com rascunho pendente e ordens abertas exibe faixa .aviso-filtro de 'ordens afetadas' na tela de detalhe, com a contagem de ordens abertas que referenciam a ficha (P0-07), antes mesmo de abrir o modal de publicacao".

### S3 — feat-043 nao cita explicitamente RNF-02 e RNF-07 (severidade: BAIXA) — status: RESOLVIDO (aplicado em 24/08)
Os criterios de feat-043 listam contraste, LGPD, anti-duplicacao e OS estavel, e cobrem o restante apenas genericamente ("listando cada item de 6.1/6.2"). RNF-02 (teclado ponta a ponta pedido->expedicao) e RNF-07 (revisao final de rotulos) sao verificacoes da secao 6.2 que merecem criterio explicito, pois sao as mais faceis de "passar" sem execucao real.
**Ajuste proposto**: adicionar criterio: "O fluxo pedido->expedicao e percorrivel integralmente por teclado com foco sempre visivel (RNF-02), e a revisao de rotulos nao encontra rotulo prometendo acao inexistente nem dado excluido de calculo sem rotulo de exclusao (RNF-07), com resultado registrado no documento de verificacao".

### S4 — Sizing da sprint-012 (severidade: BAIXA) — status: RESOLVIDO (aplicado em 24/08, opcao minima)
A sprint-012 acumula 3 features de UI (Dominio J completo) + a verificacao transversal de TODOS os criterios da SPEC secao 6, com potencial correcao de regressoes — e esta marcada `complexity: "medium"`. E a sprint com maior risco de estourar os 3 rounds.
**Ajuste proposto (minimo)**: elevar `complexity` para `"high"` (mantem `estimated_rounds: 3`, o teto do projeto). Alternativa (se preferir): separar feat-043 numa sprint-013 dedicada de verificacao.

### S5 — Hint de volatilidade em sprint-004 (severidade: BAIXA / informativo) — status: RESOLVIDO (aplicado em 24/08)
A SPEC 2.1.3 declara `ficha.rascunho`/`ficha.versao_publicada` como estruturas **volateis** (memoria, nunca localStorage). A sprint-002 registra essa regra para ordens/reservas/estornos, mas a sprint-004 (que cria rascunho/versao_publicada) nao repete a restricao — risco de o Coder persistir o rascunho em localStorage "por conveniencia".
**Ajuste proposto**: acrescentar em `sprints[3].hints.architecture_notes`: "ficha.rascunho e ficha.versao_publicada sao volateis (memoria) — NAO persistir em localStorage (SPEC 2.1.3)".

## 3. Pontos verificados sem problema

- **Ordem/dependencias das demais sprints**: corretas (002 fundacao antes dos consumidores; 006 depende de 005; 007 depende de 004/005/006 pelo desbloqueio e roteiroDe; 011 depende de 008 pela supressao LGPD no QR/export). Sem dependencia circular.
- **Sizing geral**: 3-4 features por sprint, complexidade e rounds coerentes (exceto S4).
- **Criterios de aceite**: em geral excelentes — verificaveis, com textos normativos exatos da copy da SPEC 4.7, valores hex normativos, formatos (OS-NNNNNN, CSV ';'+BOM, dd/MM/yyyy HH:mm) e cenarios de teste objetivos (ex.: "reservar duas vezes", "120 registros/paginacao 50").
- **Hints**: sprints posteriores referenciam artefatos das anteriores (confirmarEfeito, MOTIVOS_*, helpers de localStorage/estado vazio, funcao de desbloqueio), com paths, seletores (#qa-op, #in-add, #aud-csv) e linha aproximada do objeto DB.
- **Regra de precedencia de fontes e gate da Fase 0**: fielmente refletidos na sprint-001.

## 4. Historico de decisoes

| Item | Decisao do usuario | Aplicado no sprints.json? |
|---|---|---|
| S1 | Aprovado: adicionar sprint-009 e sprint-010 as dependencias da sprint-012 | SIM — dependencies da sprint-012 agora inclui 001, 002, 003, 005, 006, 007, 009, 010, 011 |
| S2 | Aprovado: criterio explicito da faixa .aviso-filtro (P0-07) | SIM — novo criterio de aceite adicionado a feat-013 |
| S3 | Aprovado: criterio explicito de RNF-02 e RNF-07 na verificacao final | SIM — novo criterio de aceite adicionado a feat-043 |
| S4 | Aprovado na opcao minima: elevar complexidade, sem separar sprint propria | SIM — sprint-012 complexity: medium -> high (estimated_rounds mantido em 3) |
| S5 | Aprovado: nota de volatilidade de ficha.rascunho/versao_publicada | SIM — frase adicionada ao architecture_notes da sprint-004 |

**Situacao final (24/08): todos os 5 itens resolvidos e aplicados. Plano validado — cobertura completa da SPEC, sem lacunas remanescentes. Aguardando aprovacao final do usuario.**
