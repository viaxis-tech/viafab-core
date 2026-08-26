# Architecture Map: ViaFab Core
**Data:** 2026-08-25
**Run:** 20260825_085318-4ff9ed

## Resumo do sistema

ViaFab e um ERP verticalizado para fabricas de sinalizacao viaria (placas CONTRAN), cobrindo engenharia de produto parametrica, explosao de BOM multinivel, roteiro de fabricacao, PCP (plano + programacao), reserva/movimentacao de estoque, apontamento de chao de fabrica, qualidade, expedicao com romaneio/remessa, rastreabilidade (GED/databook) e auditoria, sob multi-tenant e multi-unidade fabril.

O repositorio hoje tem **duas metades que nao se falam**: (a) um prototipo navegavel single-file (`prototype/index.html`, 26.081 linhas / ~1,18 MB) que implementa **todo** o dominio em JavaScript com dados de demonstracao em memoria, e (b) um schema PostgreSQL/Supabase incremental (9 migrations) que cobre apenas nucleo multiempresa/seguranca/auditoria e catalogo de engenharia/recursos. Nao existe camada de aplicacao, nenhuma Edge Function, nenhum `fetch`/`supabase-js`: a SPEC atual (secao 3.0/3.5) declara explicitamente que o prototipo nao se conecta ao backend nesta fase.

## Vocabulario de dominio

| Termo | Significado |
|---|---|
| Tenant / Unidade de fabrica | Empresa (`tenants`) e planta fabril (`unidades_fabrica`). No prototipo, `TENANTS['T-001'..'T-003']` e `S.tenant`; catalogo de engenharia e unico, **saldo de estoque e por unidade** (`SALDO`/`RESERV`). |
| Perfil / `perm(screen)` | Papel de acesso (pcp, engenharia, almoxarifado, operador, qualidade, expedicao, compras, direcao). Matriz posicional `P('r w - ...')` sobre `MODULOS`; `w`=escrita, `r`=leitura, `-`=sem acesso (fail-closed). |
| Item | Material, componente ou produto (`item_tipo`: `materia_prima|componente|produto`). Ids `MAT-*`, `FT-*`, `PRD-*`. |
| Familia construtiva | Catalogo parametrico versionado imutavel (`familias_construtivas`: `parametros_schema`, `regras`, `formula_bom`, `template_roteiro`). |
| Ficha tecnica / linha de ficha | Cabecalho da BOM (`fichas_tecnicas`, versionada) e arvore multinivel (`linhas_ficha`, self-fk `componente_pai_id` + `nivel`). No prototipo: `f.ficha[]`, `f.rascunho`, `f.versao_publicada`, `f.ver`. |
| Roteiro base / operacao | Sequencia de operacoes por item (`roteiros_base`, `ROT_BASE`, `roteiroDe(ordem)`), com setor, maquina padrao e `tempo_padrao_min`. |
| Componente gerado | Peca derivada automaticamente da parametrizacao da placa (`componentes_gerados`, papel `corte|quadro|sinal|recorte|fix`; `gerarComponentesIND`, `estruturaIND`). |
| Nomenclatura / descricao auxiliar | Codigo CONTRAN da placa (R-19, A-14, ...) usado como identificacao da linha do pedido (`NOMENCLATURAS`, `codDaIdent`, `categoriaPlaca`). |
| Pedido / demanda | Origem da demanda (`DB.pedidos`), manual ou via canal ViaSign; linhas com `ident`, `ci` (item de contrato), `campo` (implantacao), `arqs`. |
| Plano / backlog / fila | Fila priorizada de linhas de pedido antes de virar ordem (`DB.plano`, `backlog()`, `CRITERIOS`, `ordenarPlano`). |
| Ordem de producao (OP) | `DB.ordens` com `cfg`, `snap` (snapshot), `status` (`planejada|aguardando-material|em-producao|bloqueada|concluida|expedida`), `avanco`, `prazo`, `eh_lote`. |
| Snapshot (`SNP-*`) / configuracao (`CFG-*`) | Congelamento imutavel de ficha+BOM+roteiro no momento da geracao da ordem. |
| Programacao | Distribuicao das operacoes da ordem em slots setor x dia util respeitando capacidade (`programacao()`, `capSetorDia`, `replanejar`). |
| Reserva / separacao / consumo / perda | Ciclo do material: `DB.reservas` (`qtd_necessaria/qtd_reservada/qtd_faltante`), `DB.separacoes`, `DB.consumos`, `DB.perdas`. |
| Movimento de estoque / lote / rastreio | `DB.movimentos` (com `sinc: pendente|ok`), `DB.lotes` (saldo, NF, validade), `DB.rastreio` (lote consumido por ordem/operacao). |
| Apontamento / estorno | Registro de tempo e consumo por operacao; correcao **append-only** via `ESTORNO_APONTAMENTO` dentro da janela de 10 min (`JANELA_ESTORNO`). |
| Baixa automatica | Consumo de material da ficha do setor ao concluir a operacao (`matDaOperacao`, `baixaAutomatica`, `PARAM.baixaAutomatica`). |
| Serie / unidade identificada | ID unitario por peca produzida (`ITM-*` produto, `CMP-*` componente) em `DB.serie`, com QR proprio. |
| Parecer de qualidade (`ordem.qa`) | `{aprovado, motivo, motivo_detalhe, autor, criado_em}`; motivos em vocabulario fechado (`MOTIVOS_REPROVACAO`). |
| Romaneio / remessa / espelho fiscal | Conferencia de saida (`DB.romaneios`, `ROM_ST`), envio confirmado (`DB.remessas`) e relatorio fiscal/fotografico (`espelhoFiscal`). |
| Databook | Dossie de rastreabilidade por pedido (lote + NF + certificado por material consumido). |
| Custo aberto | Decomposicao material + processo + mao de obra + tempo. No banco: `fn_custo_aberto(uuid)` (recursao sobre `linhas_ficha`); no prototipo: `custoAberto(tipo, cod)`. |
| m2 (metro quadrado) | Indicador de desempenho do segmento, paralelo a contagem de pecas (`m2Ordem`, `desempenhoM2`). |
| Pacote `.vfb` / `viaxis.vfb/1` | Contrato de integracao ViaSign -> ViaFab: ZIP com `manifest.json` de placas, lido e validado client-side (`lerPacoteVfb`, `validarVfb`, `mapearPlacaVfb`). |
| `screen_id` / delta | Identificador de tela usado por roteamento/permissao; `delta-NNN` sao decisoes rastreadas no design contract. |
| Parametros de funcionamento | Chaves de comportamento por fabrica (`PARAM`: `reservaObrigatoria`, `estoqueNegativo`, `baixaAutomatica`, `qualidadeParaExpedir`, `expedicaoParcial`, ...), persistidas em localStorage. |

## Modules top-level

> Nota de leitura: quase todos os modules do prototipo sao **regioes de um unico arquivo**, delimitadas por comentarios de secao (`/* ===== TITULO ===== */`), nao arquivos separados. As faixas de linha abaixo vem desses marcadores, que foram verificados por leitura.

### PrototypeShell
- **Path:** `prototype/index.html` (markup L902-3152; roteador/sessao/nav L15286-16014; listeners globais e boot L25918-26077)
- **Role:** Shell do SPA: login simulado, sessao com expiracao (`startSession`/`renovarSessao`), troca de perfil e tenant, navegacao (`NAV`, `renderNav`, `route`/`go`, hash + `popstate`), autorizacao fail-closed (`perm`, `aplicarSomenteLeitura`, tela `acesso-negado`), tema, modal generico (`abrirModal`/`trapModal`), toast, paleta de comandos (Ctrl+K), atalhos de teclado, acessibilidade (`a11yTabelas`) e `MutationObserver` que reajusta graficos apos cada render.
- **Dependencias:** app-state, design-system, todos os modules de tela (chama `init*` e `render*`), chart-kit (via `agendarAjuste`), auditoria.
- **Chamadores:** navegador (entrypoint `route(...)` na ultima linha do script).

### DesignSystemTokens
- **Path:** `prototype/index.html` L7-900 (`<style>`), mais `<style id="orient">` (L888) usado por impressao
- **Role:** Design system "ui-obs" inline: tokens de cor/tipografia/espaco em `:root` e `[data-theme="light"]`, camada de compatibilidade de nomes antigos, componentes visuais (btn, pill, card, tbl, tabs, split, gantt, heatmap, folha A4, posto do operador, responsivo tablet).
- **Dependencias:** nenhuma (CSS puro, sem build).
- **Chamadores:** todo o markup e todos os `render*`; `tools/contraste.mjs` le estes tokens como texto.

### EmbeddedDesignContract
- **Path:** `prototype/index.html` L3153-15284 (`<script type="application/json" id="lionclaw-design-contract">`)
- **Role:** Contrato de design embutido no proprio artefato: `visual`, `navigation`, `screens`, `components`, `dataRequirements`, `apiExpectations`, `deltas` (ate `delta-108`). ~12.100 linhas, nunca lido em runtime pelo JS do app (nenhuma leitura de `#lionclaw-design-contract` foi encontrada).
- **Dependencias:** nenhuma em runtime.
- **Chamadores:** ferramentas de pipeline/leitura humana; duplica parcialmente `docs/Docs20260820_134109/design/design-contract.json`.

### AppStateStore
- **Path:** `prototype/index.html` L15339-15368 (`PARAM`), L15611-15726 (`lerLocal`/`gravarLocal`/`DB`/`S`), L15728-15757 (`SALDO`/`RESERV`/`saldoUn`)
- **Role:** Unico store mutavel da aplicacao: `DB` (ordens, movimentos, reservas, separacoes, consumos, perdas, inspecoes, retrabalhos, eventos, auditoria, plano, prog, serie, romaneios, remessas, lotes, docs, rastreio, vfb, os_ids...), sessao `S`, saldo por unidade fabril e parametros de funcionamento. Persistencia seletiva em `localStorage` sob convencao versionada `viafab.<estrutura>.v<N>` — versao divergente e **descartada**, nunca migrada. Apenas `auditoria`, `param`, `painel_periodo`, `usuario_atalhos` e tema sobrevivem a sessao.
- **Dependencias:** domain-catalog (deriva `res` das reservas para os itens).
- **Chamadores:** praticamente todos os modules (acesso global direto, sem interface de acesso).

### DomainCatalogSeed
- **Path:** `prototype/index.html` L15450-15535 (depositos, itens, maquinas, setores, status), L17918-18810 (`COMPONENTES`, `PRODUTOS`, `FORMATOS`, `PELICULAS`, `NOMENCLATURAS`, `PROD_ATTR`), L18806-18878 (`CLIENTES`, `CONTRATOS`), L19297-19334 (`CARGOS`, `MAQ_HORA`), L19137-19296 (`PEDIDOS`, `TIPO_DOC`, lotes/docs)
- **Role:** Catalogo de dominio de demonstracao embutido como literais JS (origem declarada: `seeds.json`), mais os acessores canonicos (`item`, `comp`, `prod`, `ficha`, `insumo`, `deposito`, `maquina`, `cliente`, `contrato`).
- **Dependencias:** nenhuma.
- **Chamadores:** todos os modules de dominio.

### EngenhariaFichas
- **Path:** `prototype/index.html` L17918-18527 (cadastro de itens/produtos, nomenclatura, `estruturaIND`, `gerarComponentesIND`, `resolverProdutoPadrao`), L18431-18527 (`versionarFicha`, `fichaPendente`), L20071-20782 (telas de itens e fichas, roteiro por ficha, publicacao/descarte)
- **Role:** Engenharia de produto: nomenclatura composta em seis partes (`nomeBase`), geracao automatica de componentes por area/papel, edicao de BOM e roteiro por ficha, rascunho vs. versao publicada imutavel, deteccao de ordens abertas afetadas pela publicacao, esquema SVG da placa (`placaEsquema`).
- **Dependencias:** domain-catalog, app-state, custo-engine (custo/tempo exibidos na ficha), chart-kit, shell (modal).
- **Chamadores:** shell-ui, pedidos-demanda (`resolverProdutoPadrao` no importador), plano-engine e chao-fabrica (via `ficha`/`explodir`).

### CustoEngine
- **Path:** `prototype/index.html` L19472-19535 (`custoMat`, `custoMO`, `custoProc`, `custoDe`, `custoAberto`, `tempoDe`, `explodir`, `necessidadeOrdem`)
- **Role:** Explosao recursiva da BOM com perda (`qPerda`) e composicao de custo aberto (material/processo/mao de obra) e tempo padrao. Deep: interface minima (`custoAberto(tipo, cod)`, `explodir(tipo, cod, qtd)`) sobre recursao multinivel.
- **Dependencias:** domain-catalog (fichas, cargos, maquinas).
- **Chamadores:** engenharia-fichas, plano-engine, estoque-reservas, relatorios-painel, pedidos-demanda, print-kit (OS).
- **Contraparte no banco:** `fn_custo_aberto(uuid)` em `supabase/migrations/20260824140400_fn_custo_aberto.sql` — **implementacao paralela**, com formula documentada mas nao equivalente linha a linha a do prototipo.

### PlanoProducaoEngine
- **Path:** `prototype/index.html` L20783-20911 (previsibilidade: gantt de ordens, consumo projetado, cobertura/ruptura), L22624-23110 (backlog, criterios de prioridade, alocacao de componentes prontos, cronograma por capacidade, preview e geracao de ordens)
- **Role:** PCP tatico: monta a fila (`backlog`), prioriza (`PRIOS`/`CRITERIOS`), reaproveita componentes ja produzidos (`componentesProntos`/`alocarProntos`), consolida linhas de pedidos distintos em ordem de lote, projeta cronograma por `CAP_DIA`, apura faltas de material e gera as ordens (`previaOrdensDoPlano`, `confirmarGeracaoDoPlano`, `gerarOrdensDoPlano`, `criarOrdemDoPlano` com `CFG-*`/`SNP-*`).
- **Dependencias:** app-state, domain-catalog, custo-engine, estoque-reservas (cobertura), auditoria, shell (confirmarEfeito/modal).
- **Chamadores:** shell-ui (tela `plano`), pedidos-demanda (`incluirNoPlano`).

### ProgramacaoEngine
- **Path:** `prototype/index.html` L23111-23607
- **Role:** Programacao fina: calendario util, capacidade por setor/dia (`capSetorDia`), alocacao de cada operacao do roteiro em slots (`programacao()`), agregacao por periodo (dia/semana/mes), deteccao de sobrecarga e atraso previsto, `replanejar(id, dia, motivo)` com ancora persistida em `DB.prog`, exportacao CSV da programacao.
- **Dependencias:** app-state, domain-catalog (setores/maquinas), chao-fabrica (`roteiroDe`), estoque-reservas (impedimento por falta), auditoria.
- **Chamadores:** shell-ui (tela `plano`, aba programacao).

### EstoqueReservas
- **Path:** `prototype/index.html` L16407-16759 (reserva, recalculo, liberacao, separacao, movimentos, OCR de anexo de entrada)
- **Role:** Necessidade por ordem, reserva parcial com `qtd_faltante`, recalculo com delta explicito, liberacao devolvendo saldo, separacao contra reserva, lancamento de movimento com lote e `sinc` pendente/ok, classificacao e extracao heuristica de dados de NF/certificado (`classificarDoc`, `extrair`, `lerAnexos`).
- **Dependencias:** app-state, domain-catalog, custo-engine (`necessidadeDe`), ged-rastreabilidade (lotes/docs), auditoria.
- **Chamadores:** shell-ui, plano-engine, chao-fabrica, programacao-engine.

### ChaoDeFabricaExecucao
- **Path:** `prototype/index.html` L16078-16406 (roteiro da ordem, `ESTORNO_APONTAMENTO`, `desbloquearOperacao`), L16760-17059 (posto do operador, timer, consumo, perda, bloqueio, `finalizarOperacao`, `corrigirApontamento`), L19349-19470 (`emitirSeries`, `serializar`), L21522-21639 (`matDaOperacao`, `baixaAutomatica`)
- **Role:** Nucleo de execucao: cronometro por operacao, apontamento de tempo/consumo/perda, baixa automatica de material do setor com consumo FIFO de lote (`baixarLote`), transferencia de deposito do item pronto, emissao de unidades identificadas, trilha append-only de estorno com janela de 10 min e desbloqueio explicito por PCP (`w`) ou Qualidade (`w`) — nunca pelo operador.
- **Dependencias:** app-state, estoque-reservas, ged-rastreabilidade, qualidade (parecer), auditoria, shell (confirmarEfeito).
- **Chamadores:** shell-ui (tela `chao-de-fabrica` e `ordem-detalhe`), qualidade (reabertura por reprovacao), programacao-engine (`roteiroDe`).

### Qualidade
- **Path:** `prototype/index.html` L15539-15610 (vocabulario fechado e `criarParecerQA`), L17060-17169 (fila de inspecao, registro de parecer, bloqueio da ordem)
- **Role:** Fila "aguardando inspecao", registro de inspecao com criterio critico, parecer estruturado com motivo de vocabulario fechado, bloqueio/retencao da ordem reprovada e caminho de retrabalho que reabre operacao.
- **Dependencias:** app-state, chao-de-fabrica (desbloqueio), auditoria.
- **Chamadores:** shell-ui, expedicao (retencao por QA), relatorios-painel.

### ExpedicaoRomaneio
- **Path:** `prototype/index.html` L17170-17741 (selecao item a item, carrinho, romaneio, conferencia por QR, confirmacao de saida parcial, remessas, folhas de romaneio/remessa), L25157-25218 (`espelhoFiscal`, `csvEspelho`)
- **Role:** Expedicao unidade a unidade: agrupamento por pedido/item, leitura de QR (`lerQR`), romaneio em conferencia -> encerrado, remessa confirmada (com devolucao do saldo nao conferido ao deposito quando `PARAM.expedicaoParcial`), retencao por qualidade (`retidasQA`), espelho fiscal com fotos e itens de contrato.
- **Dependencias:** app-state, qualidade, contratos-medicao (valor por item de contrato), qr-encoder, print-kit, auditoria.
- **Chamadores:** shell-ui (tela `expedicao`).

### GedRastreabilidade
- **Path:** `prototype/index.html` L19167-19296 (lotes, documentos, `baixarLote`, `databookDoPedido`), L23608-23792 (acervo, busca com realce em OCR, databook por pedido, exportacao/impressao)
- **Role:** Acervo documental por material/lote (NF, certificado, laudo, validade), consumo FIFO por lote com trilha `DB.rastreio`, cobertura de lastro documental e montagem do databook por pedido.
- **Dependencias:** app-state, domain-catalog, print-kit.
- **Chamadores:** estoque-reservas, chao-de-fabrica (baixa), shell-ui (tela `ged`).

### PedidosDemanda
- **Path:** `prototype/index.html` L21640-22623 (pedidos, linhas, arquivos da placa, implantacao, template de planilha, importacao `.vfb`/demo, envio ao plano)
- **Role:** Origem da demanda: cadastro/edicao de pedido e linhas com nomenclatura CONTRAN, item de contrato sugerido (`ciSugerido`), dados de implantacao (rodovia/km/coordenada), anexos por linha, importacao por planilha CSV/TSV (`parsePlanilha`) e por pacote ViaSign, verificacao de viabilidade de prazo contra capacidade e envio ao plano.
- **Dependencias:** vfb-adapter, engenharia-fichas (`resolverProdutoPadrao`), contratos-medicao, custo-engine, plano-engine, estoque-reservas (cobertura), auditoria.
- **Chamadores:** shell-ui (tela `pedidos`).

### ViaSignVfbAdapter
- **Path:** `prototype/index.html` L18902-19118 (`VFB_SCHEMA='viaxis.vfb/1'`, `lerZip`, `extrairZip`, `lerPacoteVfb`, `validarVfb`, `mapearPlacaVfb`, `arqsVfb`, `marcarColisoesDimensao`, `avisoReimportVfb`)
- **Role:** Adapter do contrato de integracao com o ViaSign: leitor de ZIP proprio (EOCD + `DecompressionStream('deflate-raw')`), validacao de manifesto, traducao do vocabulario ViaSign para o vocabulario ViaFab (`VFB_FORMA`/`VFB_PEL`/`VFB_SUBS`/`VFB_INST`), deteccao de colisao de chave dimensional e de reimportacao de revisao.
- **Dependencias:** engenharia-fichas (resolucao de produto padrao), domain-catalog.
- **Chamadores:** pedidos-demanda. **Nao ha rede**: o pacote entra por `<input type=file>`.

### ContratosMedicao
- **Path:** `prototype/index.html` L18812-18878 (`CONTRATOS`, `valorLinha`, `itemCtr`), L24701-24995 (telas de contrato, medicao, importacao de itens de contrato)
- **Role:** Contrato do cliente como planilha de itens com preco por `un` ou `m2`, criterio de faturamento (area nominal vs. geometrica) e medicao por unidade expedida.
- **Dependencias:** app-state, domain-catalog, expedicao (unidades expedidas).
- **Chamadores:** pedidos-demanda, expedicao, relatorios-painel, shell-ui (tela `clientes`).

### RelatoriosPainel
- **Path:** `prototype/index.html` L19782-20070 (indicador m2 e painel da fabrica), L21158-21237 (clientes/previsao de entrega), L21238-21521 (relatorios configuraveis + exportacao), L23793-23864 (mao de obra), L23865-24044 (orcamento e BI de custo)
- **Role:** Camada analitica: KPIs de ordens/atraso/ruptura, aderencia de prazo, conversao em m2 por dia/semana/mes, relatorios parametrizaveis (`RELS`, colunas, janela de datas, agrupamento, CSV/PDF), precificacao com margem/imposto e paineis de custo.
- **Dependencias:** app-state, custo-engine, chart-kit, print-kit, domain-catalog.
- **Chamadores:** shell-ui (telas `dashboard`, `relatorios`, `clientes`, `orcamento`, `recursos`).

### ChartKit
- **Path:** `prototype/index.html` L19531-19736 (`chStack`, `chLine`, `chHBar`, `chDonut`, `chSpark`, `eixoY`, `ajustarCharts`, `alinharTabelas`, `tipMove`, `stat`)
- **Role:** Kit de graficos SVG proprio, sem dependencia externa, com compensacao de escala de viewBox e tooltip global. Deep: interface pequena (`chLine(labels, series, opts)`), muito comportamento atras.
- **Dependencias:** design-system (tokens de cor).
- **Chamadores:** relatorios-painel, plano-engine, programacao-engine, engenharia-fichas, shell-ui.

### PrintKit
- **Path:** `prototype/index.html` L24996-25156 (etiquetas de placa, foto de conclusao), L25219-25288 (`folhaA4`, `orientar`, `imprimirFolhas`), L25289-25539 (OS impressa: consolidacao de linhas, `idOS` estavel, `folhaOS`)
- **Role:** Molde unico de documento impresso A4 (cabecalho, kv, blocos, apontamento manual, assinaturas) reutilizado por OS, databook, romaneio, remessa, espelho fiscal, proposta, auditoria e etiquetas; consolidacao de linhas de emissao por setor/maquina/cliente/produto e id de OS estavel por grupo (`DB.os_ids`).
- **Dependencias:** qr-encoder, design-system (CSS de impressao), custo-engine (tempo/necessidade na OS).
- **Chamadores:** expedicao, ged-rastreabilidade, relatorios-painel, auditoria, shell-ui (tela `os-impressa`).

### QrEncoder
- **Path:** `prototype/index.html` L24045-24311
- **Role:** Implementacao propria de QR Code modelo 2, modo byte, nivel M, versoes 1-10: Reed-Solomon sobre GF(256), mascaras com escolha por penalidade, BCH de formato/versao, saida SVG. Exemplo mais claro de module **deep** do repositorio: interface `QR.svg(texto, opts)`.
- **Dependencias:** nenhuma.
- **Chamadores:** print-kit (etiquetas, OS, romaneio), expedicao.

### TrilhaAuditoria
- **Path:** `prototype/index.html` L15759-15777 (`audit`, `evento`, `toast`), L17742-17917 (tela de auditoria: filtros, busca, paginacao, matriz de perfis, exportacao CSV/PDF)
- **Role:** Trilha append-only de acoes por tenant/usuario/modulo, linha do tempo de eventos por ordem (`DB.eventos`) e a unica estrutura de `DB` persistida entre sessoes (`viafab.auditoria.v1`).
- **Dependencias:** app-state, print-kit.
- **Chamadores:** todos os modules de dominio (chamadas diretas a `audit(...)`/`evento(...)`).
- **Contraparte no banco:** tabela `auditoria` com append-only garantido em duas camadas (ausencia de policy + `REVOKE UPDATE/DELETE` inclusive de `service_role`).

### AdminConfig
- **Path:** `prototype/index.html` L24312-24535 (pagina inicial: atalhos por perfil, `resumoCritico`, fila de atencao), L25540-25795 (unidades e transferencias), L25796-25962 (parametros do sistema)
- **Role:** Configuracao operacional e entrada do usuario: atalhos personalizados por perfil persistidos, resumo critico transversal (atrasos, falta de material, rupturas, pendencias de sync, fila de QA), gestao de unidades fabris/transferencia e edicao dos `PARAM` com explicacao do efeito de cada chave.
- **Dependencias:** app-state, todos os modules de dominio (leitura para o resumo), auditoria.
- **Chamadores:** shell-ui (telas `inicio`, `unidades`, `parametros`).

### SupabaseCoreSchema
- **Path:** `supabase/migrations/20260824130246_enable_extensions.sql`, `...130346_core_multiempresa_tables.sql`, `...130446_auditoria_append_only.sql`, `...130546_rls_fail_closed_policies.sql`
- **Role:** Fundacao multiempresa e seguranca: `tenants`, `unidades_fabrica`, `perfis` (matriz de permissao em `jsonb`), `usuarios_perfil`, `usuarios_unidades_concedidas`, `usuario_atalhos`, `auditoria`. Padrao arquitetural explicito: **schema e policy em migrations separadas**, RLS fail-closed com claims lidos so de `auth.jwt() -> 'app_metadata'`, GRANT minimo por tabela (nunca `DELETE`).
- **Dependencias:** `auth.users` (Supabase Auth), `supabase/config.toml` (`auto_expose_new_tables` desligado).
- **Chamadores:** nenhum consumidor no repositorio — nao ha cliente conectado.

### SupabaseEngenhariaSchema
- **Path:** `supabase/migrations/20260824140000_engenharia_catalogo_tables.sql`, `...140100_engenharia_recursos_tables.sql`, `...140200_engenharia_versionamento_triggers.sql`, `...140300_engenharia_rls_policies.sql`, `...140400_fn_custo_aberto.sql`
- **Role:** Catalogo de engenharia (`familias_construtivas`, `normas_tecnicas`, `itens`, `produtos_padrao`, `fichas_tecnicas`, `linhas_ficha`, `componentes_gerados`, `roteiros_base`) e recursos (`setores`, `maquinas`, `cargos`), com imutabilidade versionada por trigger (bloqueio de UPDATE/DELETE, versao calculada no INSERT, BOM de ficha publicada congelada) e `fn_custo_aberto` recursiva `security invoker`.
- **Dependencias:** supabase-core-schema (`tenants`, `unidades_fabrica`, `auth.users`).
- **Chamadores:** nenhum no repositorio; `fn_custo_aberto` tem `grant execute` para `authenticated`/`service_role`, prevendo `GET /itens/{itemId}/custo`.

### SupabaseTests
- **Path:** `supabase/tests/*.sql` (5 arquivos: isolamento RLS, auditoria append-only, RLS de engenharia, versionamento, custo aberto)
- **Role:** Testes SQL que exercem as invariantes de seguranca e versionamento — **a superficie de teste do backend hoje e a interface do banco** (policies, triggers, funcao), nao uma API.
- **Dependencias:** os dois modules de schema, `supabase/seed.sql`.
- **Chamadores:** execucao manual via Supabase CLI (nao ha CI no repositorio).

### SeedData
- **Path:** `supabase/seed.sql` (492 linhas), `seeds.json` (~100 KB, raiz)
- **Role:** Dados de partida. `seeds.json` e a origem declarada do catalogo de materiais embutido no prototipo (campos `sku/nome/custo/estoque/seg/lead/loteMin/loteMult/perda`, mais `startDate`/`horizon`/`modo:"demanda"` — vocabulario de MRP).
- **Dependencias:** schemas.
- **Chamadores:** supabase-tests; prototipo (por copia manual, nao por leitura em runtime).

### ContrasteTool
- **Path:** `tools/contraste.mjs` (218 linhas)
- **Role:** Unico "teste" executavel do frontend: le os blocos `:root` e `[data-theme="light"]` **como texto** de `prototype/index.html` e valida pares de contraste WCAG AA nos dois temas, com exit code != 0 em violacao. Node >= 18, sem dependencias.
- **Dependencias:** acoplamento textual ao CSS do prototipo (usa regex sobre o HTML).
- **Chamadores:** execucao manual (`node tools/contraste.mjs`).

### DocsPipelineArtifacts
- **Path:** `docs/Docs20260820_134109/` (PRD, SPEC, stories, sprints, `design/design-contract.json` 318 KB, `design/artifact.html` 1,18 MB), `docs/Docs20260824_151851/`, `docs/auditoria-design-20260823.md`, `docs/decisoes-fase0-20260824.md`, `PRD.md`, `stories-requisitos.md`, `discovery-notes.md`, `plano-discovery-viafab.md`, `CLAUDE.md`
- **Role:** Cadeia de artefatos do pipeline de produto (discovery -> PRD -> SPEC -> sprints -> design lock -> auditoria -> decisoes de fase). A SPEC e normativa sobre o codigo: define contrato de funcoes `fn_*` client-side, regras de janela de estorno, escopo de fallback de publicacao e o que **nao** deve ser feito nesta fase.
- **Dependencias:** —
- **Chamadores:** agentes do pipeline; leitura humana.

## Fluxos principais

### Autenticacao, roteamento e autorizacao fail-closed
1. `route(destino)` normaliza hash/`popstate` e resolve o `screen` (`MODULOS.indexOf(alvo)`), caindo para `PERFIS[S.perfil].home` quando o alvo nao existe.
2. `perm(screen)` consulta a matriz posicional do perfil; `-` desvia para `acesso-negado` e audita a tentativa; `r` aplica `aplicarSomenteLeitura(screen)` desabilitando controles.
3. `renderNav()` reconstroi a sidebar somente com o que o perfil enxerga; a paleta (Ctrl+K) e os atalhos `g+letra` filtram pelo mesmo `perm`.
4. Sessao expira por inatividade (`PARAM.sessaoMin`); qualquer `click|keydown|wheel|touchstart` renova.

### Demanda -> plano -> ordens de producao
1. Pedido nasce manual, por planilha (`parsePlanilha`) ou por pacote ViaSign; linhas recebem nomenclatura, item de contrato e prazo.
2. `incluirNoPlano(...)` empurra as linhas nao planejadas para `DB.plano`; `ordenarPlano()` aplica o criterio vigente.
3. `alocarProntos()` desconta componentes ja produzidos em `DB.serie`; `cronogramaPlano()` distribui por `CAP_DIA`; `materiaisDoPlano()` apura cobertura.
4. `previaOrdensDoPlano()` monta o preview (primeiras 20 + resumo agregado) e `confirmarEfeito()` exige confirmacao explicita.
5. `gerarOrdensDoPlano()` -> `criarOrdemDoPlano()` cria `OP-*` com `CFG-*`/`SNP-*`; falta de material **nao bloqueia**: a ordem nasce com `bloqueio_motivo` visivel ao operador em leitura.

### Reserva e separacao de material
1. `necessidadeDe(ordem)` explode a BOM (`explodir` + perda) menos o que ja esta reservado.
2. `reservarMaterial()` estorna a reserva vigente antes de gravar a nova e registra reserva parcial com `qtd_faltante` (saldo negativo proibido).
3. `recalcularReserva()` e preview puro (sem gravar); `liberarReserva()` devolve saldo e e reversivel, entao nao pede confirmacao.
4. Separacao debita `fis`/`res` do item na unidade corrente e alimenta `sepDe(ordem, item)`.

### Execucao no chao de fabrica
1. Operador escolhe a ordem no posto; `setorAtualDe` aponta a primeira operacao nao concluida do `roteiroDe(ordem)`.
2. Timer roda; consumo e perda sao apontados contra o separado, com bloqueio/justificativa conforme `PARAM.consumoAcimaSeparado`.
3. `finalizarOperacao(min)` -> `baixaAutomatica(o, op)`: `matDaOperacao` calcula o material daquele setor, `baixarLote` consome lotes FIFO gravando `DB.rastreio`, transfere o item pronto de deposito e marca `baixado=true`.
4. `serializar(o, op)` emite unidades identificadas (`CMP-*`/`ITM-*`) e, na ultima operacao, a foto de conclusao quando exigida.
5. Correcao so por `corrigirApontamento()` dentro de `JANELA_ESTORNO` (10 min), gerando **nova linha** em `ESTORNO_APONTAMENTO`; passada a janela, so `desbloquearOperacao()` por PCP(w) ou Qualidade(w), com escolha explicita entre retrabalho com ou sem novo material.

### Qualidade -> expedicao
1. Ordem concluida entra em `ordensAguardandoInspecao()`; a inspecao grava `DB.inspecoes` e `criarParecerQA` preenche `ordem.qa`.
2. Reprovacao bloqueia a ordem e abre o caminho de retrabalho (reabre operacao via desbloqueio de Qualidade).
3. Unidades produzidas no deposito de expedicao entram em `serieAptas()`; `retidasQA()` segrega o que `PARAM.qualidadeParaExpedir` retem.
4. Selecao item a item -> `gerarRomaneio()` -> conferencia (checkbox ou leitura de QR via `lerQR`) -> `confirmarSaida()` gera `REM-*`; o nao conferido volta ao deposito quando `PARAM.expedicaoParcial`.
5. `espelhoFiscal(remessa)` e `folhasRemessa(...)` imprimem via `folhaA4`; medicao de contrato consome as unidades expedidas.

### Engenharia: rascunho -> publicacao
1. `abrirFicha(cod)` carrega a ficha; edicoes de BOM/roteiro marcam `FI.sujo` e vivem em `f.rascunho`.
2. `descartarFicha()` reverte para `f.versao_publicada` (incluindo `rot[]`).
3. Publicar chama `ordensAbertasDaFicha(cod)` e segmenta ordens afetadas/nao afetadas; a escolha de fallback (manter snapshot ou herdar) e unica e global, com ordens que ja tem operacao `baixado=true` forcadas a manter o snapshot.
4. `versionarFicha()` grava nova versao — nunca UPDATE de conteudo. No banco, a mesma invariante e imposta por `trg_versao_ficha` + `trg_ficha_update_restrito` + `trg_bloqueia_linha_ficha_publicada`.

### Importacao de pacote ViaSign (.vfb)
1. Usuario solta o `.vfb`; `lerPacoteVfb` abre o ZIP (parse de EOCD + `DecompressionStream`) e extrai `manifest.json`.
2. `validarVfb` checa schema `viaxis.vfb/1`, coerencia de area/bbox e duplicidade; `mapearPlacaVfb` traduz forma/pelicula/substrato/implantacao para o vocabulario ViaFab.
3. `marcarColisoesDimensao` sinaliza placas que colapsam na mesma chave dimensional; a importacao so habilita apos conferencia **linha a linha**.
4. `importarVfb(cliente, prazo)` cria o pedido, resolve/cria produtos padrao (`resolverProdutoPadrao` -> `gerarComponentesIND`) e audita quantas colisoes foram confirmadas e por quem.

### Backend Supabase (fluxo declarado, sem consumidor)
1. Migrations criam tabelas **sem** RLS; migration dedicada por dominio habilita RLS `force`, concede GRANT minimo e cria policies baseadas em `auth.jwt() -> 'app_metadata' ->> 'tenant_id'`.
2. Triggers impoem versionamento imutavel independentemente de RLS (valem inclusive para `service_role`, que tem BYPASSRLS).
3. `auditoria` bloqueia UPDATE/DELETE em duas camadas independentes (ausencia de policy + `REVOKE`).
4. `fn_custo_aberto(item)` percorre `linhas_ficha` recursivamente e soma roteiro/cargo — prevista para `GET /itens/{itemId}/custo`, sem chamador implementado.

## Hotspots de complexidade

- **Monolito single-file `prototype/index.html` (26.081 linhas, ~1,18 MB, um unico escopo global):** um arquivo concentra CSS (L7-900), markup de 25 telas (L902-3152), o design contract embutido de ~12.100 linhas (L3153-15284) e ~10.800 linhas de JavaScript (L15286-26078). Nao existe seam: nao ha modulos ES, nenhum `import`/`export`, e cada module do dominio conversa com os outros por identificadores globais (`DB`, `S`, `PARAM`, `ITENS`, `ficha`, `item`). A interface de qualquer parte e "o arquivo inteiro", entao **locality e leverage sao proximos de zero**: mudar `PARAM.baixaAutomatica` implica ler `finalizarOperacao`, `baixaAutomatica`, `matDaOperacao`, `renderParametros` e `renderChao` sem nenhuma fronteira que limite a busca. A superficie de teste hoje e apenas `tools/contraste.mjs`, que le o arquivo como texto. Merece triagem: onde cortar o primeiro seam sem quebrar o design lock.

- **Motor de PCP (plano + programacao + geracao de ordens, ~2.800 linhas em L20783-20911, L22624-23607) com logica de dominio lendo o DOM:** e a maior concentracao de regra de negocio do repositorio (prioridade, consolidacao em ordem de lote, alocacao de componentes prontos, capacidade por setor/dia, replanejamento com ancora, faltas). Duas decisoes de dominio sao lidas **direto da UI** dentro das funcoes de geracao — `$('#pn-consol button[data-c="1"]').getAttribute('aria-pressed') === 'true'` aparece em `previaOrdensDoPlano()` (L22960) e novamente em `gerarOrdensDoPlano()` (L23042). Alem de duplicar a leitura, isso torna o motor **intestavel sem DOM** e faz o preview e a execucao dependerem de dois momentos distintos de leitura do mesmo botao. Ha ainda logica de capacidade repetida em tres lugares (`CAP_DIA`, `capSetorDia`, `cargaPorSetor`).

- **Dupla fonte de verdade do dominio: prototipo JS vs. schema Supabase, sem ponte:** o mesmo dominio esta modelado duas vezes, com formas diferentes e nenhuma verificacao cruzada. Exemplos concretos: custo aberto existe como `custoAberto()`/`custoMat`/`custoMO`/`custoProc` (L19472-19503) **e** como `fn_custo_aberto` SQL, com regras de composicao declaradamente decididas na migration ("a SPEC define as colunas de saida mas nao a formula interna"); versionamento de ficha existe como `versionarFicha()` e como `trg_versao_ficha`/`trg_ficha_update_restrito`; permissao existe como matriz posicional `P('r w - ...')` em JS e como `perfis.permissoes jsonb` no banco; saldo por unidade existe como `SALDO`/`RESERV` em memoria e **nao existe** no schema (nenhuma migration de estoque/ordens/qualidade/expedicao foi criada ainda). Nao ha `fetch`, `createClient` nem `supabase-js` no repositorio. A fase 4 tera de decidir qual lado e a interface e qual e implementacao — hoje ambos se comportam como implementacao sem interface comum.

- **Cadeia de apontamento/baixa/estorno/desbloqueio (L16109-16406, L16760-17059, L21522-21639):** e o ponto de maior risco de corrupcao de dado do sistema e esta espalhado por tres regioes distantes do arquivo. `finalizarOperacao` orquestra `baixaAutomatica` -> `baixarLote` (FIFO sobre `DB.lotes`) -> transferencia de deposito -> `serializar` -> `evento`/`audit`, e guarda um snapshot manual de contadores (`ev0`, `se0`, `au0`, `r0`, `c0`, `m0`) para conseguir reverter parcialmente — ou seja, **transacionalidade emulada por indice de array**. O estorno vive em `ESTORNO_APONTAMENTO`, declarado no proprio comentario como "estrutura volatil" nao persistida, e a janela de 10 min usa o relogio do cliente (limitacao reconhecida na SPEC). Qualquer refatoracao aqui precisa preservar a invariante que a SPEC chama de "zero duplicacao de baixa de estoque".

## O que nao foi mapeado

- **Leitura parcial do prototipo.** Foram lidas integralmente ~2.500 linhas de `prototype/index.html` (shell, permissoes, store, boot, listeners, trechos de dominio) e indexadas **todas** as declaracoes de funcao/constante de topo e **todos** os comentarios de secao. Afirmacoes sobre o interior de funcoes nao lidas linha a linha (por exemplo, o corpo completo de `renderProg`, `folhaOS`, `renderRelatorios`) foram inferidas de nome, assinatura e comentario de secao — **suposicao**, nao verificacao.
- **Historico git nao consultado.** O diretorio `.git/` existe, mas `git log` retornou `fatal: not a git repository` no ambiente desta execucao. Nao foi possivel verificar autoria, cronologia real das migrations nem divergencia entre `prototype/index.html` e `docs/.../design/artifact.html` (1.182.768 vs 1.181.632 bytes — diferenca de ~1 KB **nao** foi diffada).
- **Documentos de produto lidos apenas por indice.** `PRD.md` (78 KB), `stories-requisitos.md`, `discovery-notes.md`, `plano-discovery-viafab.md`, `.spec-enricher-suggestions.md`, `design-brief.md`, `open-design-prompt.md` e os dois `sprints*.json` nao foram lidos; da SPEC atual foi lida a secao 3 completa e os cabecalhos das demais; da auditoria de design, apenas os cabecalhos. Os 22 P0, os 14 grupos P1 e as 13 decisoes D-01..D-13 **nao** foram lidos item a item.
- **Migrations lidas: 7 de 9 integralmente.** `20260824140300_engenharia_rls_policies.sql` (389 linhas) foi verificado apenas quanto ao padrao geral (o padrao completo foi confirmado em `20260824130546`), e `20260824130546` foi lido ate a linha 90 de 227. `supabase/seed.sql` (492 linhas) e os 5 arquivos de `supabase/tests/` nao foram abertos — a descricao deles vem do nome do arquivo e dos comentarios das migrations correspondentes.
- **Nada foi executado.** Nao ha evidencia de que as migrations aplicam, de que os testes SQL passam ou de que `tools/contraste.mjs` termina com exit 0. Nao ha CI no repositorio (`.github/` ausente).
- **Binarios e artefatos nao inspecionados:** `.codegraph/codegraph.db` (SQLite, 139 KB), `prototype/index.preview-*.png`, `docs/.../design/artifact.html`, e os logs em `.lionclaw/pipelines/development-v2/.../runtime/logs/`.
- **`.agents/` esta vazio** e `supabase/snippets/` esta vazio — nenhuma configuracao de agente ou snippet a mapear.
- **Nao verificado se o design contract embutido e consumido em runtime.** A busca por leitura do id `lionclaw-design-contract` no JS nao encontrou ocorrencia, o que sustenta a leitura de "artefato inerte", mas a busca foi por nome do id apenas.
- **Cobertura de screens vs. SPEC nao conferida.** Existem 25 `<section class="screen">` no markup e 22 entradas em `MODULOS`; a diferenca (`login`, `acesso-negado`, e telas fora de `NAV`) foi observada mas nao reconciliada item a item com o mapa de paginas da SPEC 4.1.
