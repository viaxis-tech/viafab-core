# Design Brief

## Direcao Visual

**Direcao:** kit ui-obs aplicado sem reinterpretacao; unica variavel de aplicacao e o laranja da marca ViaFab; tema escuro padrao com alternancia para claro persistida em localStorage; JetBrains Sans como familia unica com numerais tabulares; sidebar fixa de 230px e grids assimetricos
**Design System:** [object Object]
**Densidade:** dense

## Tokens

### Cores

| Token | Valor |
|-------|-------|
| dark | [object Object] |
| light | [object Object] |
| accent | [object Object] |

### Tipografia

| Token | Valor |
|-------|-------|
| display | JetBrains Sans, Inter, ui-sans-serif, system-ui, sans-serif |
| body | JetBrains Sans, Inter, ui-sans-serif, system-ui, sans-serif |
| mono | JetBrains Sans (familia unica, numerais tabulares por font-variant-numeric) |
| scale | h1 32px / h2 24px / h3 19px / leitura 17px / interface 14px / lista 13px / status 12px / rotulo 11px / eixo 10px |

### Espacamento

| Token | Valor |
|-------|-------|
| 1 | 4px |
| 2 | 8px |
| 3 | 12px |
| 4 | 16px |
| 5 | 20px |
| 6 | 24px |
| 8 | 32px |
| 12 | 48px |

### Radii

| Token | Valor |
|-------|-------|
| s | 4px |
| m | 5px |
| l | 7px |
| pill | 999px |

## Mapa de Telas

- **Login** (`login`) — rota: `#login` — stories: US-26, US-28
- **Dashboard de ordens** (`ordens`) — rota: `#ordens` — stories: US-07, US-08, US-18
- **Detalhe da ordem** (`ordem-detalhe`) — rota: `#ordem-detalhe` — stories: US-04, US-09, US-10, US-18, US-21, US-24
- **Estoque** (`estoque`) — rota: `#estoque` — stories: US-11, US-12, US-13, US-14
- **Chão de fábrica** (`chao-de-fabrica`) — rota: `#chao-de-fabrica` — stories: US-15, US-16, US-17, US-18, US-20
- **Qualidade** (`qualidade`) — rota: `#qualidade` — stories: US-19, US-21
- **Expedicao por deposito, romaneio e conferencia** (`expedicao`) — rota: `#expedicao` — stories: US-22, US-23
- **Registros e acesso** (`auditoria`) — rota: `#auditoria` — stories: US-25, US-26, US-27
- **Painel da fábrica** (`dashboard`) — rota: `#dashboard` — stories: US-08, US-10, US-24
- **Itens e depósitos** (`itens`) — rota: `#itens` — stories: US-01, US-05, US-06, US-13, US-14
- **Fichas técnicas** (`fichas`) — rota: `#fichas` — stories: US-01, US-02, US-03, US-05
- **Recursos, processos e mao de obra** (`recursos`) — rota: `#recursos` — stories: US-03, US-05, US-09, US-10, US-13, US-27
- **Clientes e contratos** (`clientes`) — rota: `#clientes` — stories: US-22, US-23
- **Relatórios gerenciais** (`relatorios`) — rota: `#relatorios` — stories: US-10, US-24, US-25
- **Acesso negado** (`acesso-negado`) — rota: `#acesso-negado` — stories: US-26, US-27
- **Pedidos e demandas** (`pedidos`) — rota: `#pedidos` — stories: US-07, US-26, US-27
- **Plano de producao, programacao da fabrica e previsibilidade** (`plano`) — rota: `#plano` — stories: US-04, US-07, US-08, US-09, US-11, US-27
- **Inicio** (`inicio`) — rota: `#inicio` — stories: US-08, US-13, US-27
- **Documentos e databook** (`ged`) — rota: `#ged` — stories: US-14, US-19, US-25
- **Orcamento e analise de custo** (`orcamento`) — rota: `#orcamento` — stories: US-10, US-22
- **Ordens de servico e etiquetas** (`os-impressa`) — rota: `#os-impressa` — stories: US-09, US-15, US-16
- **Pagina do item** (`item`) — rota: `#item` — stories: US-15, US-10, US-17, US-22
- **Unidades e transferencias** (`unidades`) — rota: `#unidades` — stories: US-13, US-14, US-08, US-27
- **Parametros do sistema** (`parametros`) — rota: `#parametros` — stories: US-27, US-11, US-14, US-17, US-26

## Navegacao Principal

- **Inicio** (`nav-inicio`) -> tela `inicio` — stories: US-08, US-27
- **Painel da fabrica** (`nav-dashboard`) -> tela `dashboard` — stories: US-08, US-10, US-24
- **Pedidos e demandas** (`nav-pedidos`) -> tela `pedidos` — stories: US-07, US-27
- **Orcamento e custo** (`nav-orcamento`) -> tela `orcamento` — stories: US-10, US-22
- **Clientes e contratos** (`nav-clientes`) -> tela `clientes` — stories: US-22, US-23
- **Itens e depositos** (`nav-itens`) -> tela `itens` — stories: US-05, US-13, US-14
- **Fichas tecnicas** (`nav-fichas`) -> tela `fichas` — stories: US-02, US-05
- **Plano de producao** (`nav-plano`) -> tela `plano` — stories: US-07, US-08, US-09
- **Ordens de producao** (`nav-ordens`) -> tela `ordens` — stories: US-07, US-08
- **Chao de fabrica** (`nav-chao`) -> tela `chao-de-fabrica` — stories: US-15, US-16, US-17, US-18, US-20
- **Ordens e etiquetas** (`nav-os`) -> tela `os-impressa` — stories: US-09, US-15
- **Recursos e processos** (`nav-recursos`) -> tela `recursos` — stories: US-03, US-09, US-13
- **Estoque** (`nav-estoque`) -> tela `estoque` — stories: US-11, US-12, US-13, US-14
- **Documentos e databook** (`nav-ged`) -> tela `ged` — stories: US-14, US-25
- **Qualidade** (`nav-qualidade`) -> tela `qualidade` — stories: US-19, US-21
- **Expedicao** (`nav-expedicao`) -> tela `expedicao` — stories: US-22, US-23
- **Relatorios gerenciais** (`nav-relatorios`) -> tela `relatorios` — stories: US-10, US-24, US-25
- **Unidades e transferencias** (`nav-unidades`) -> tela `unidades` — stories: US-14, US-27
- **Parametros do sistema** (`nav-parametros`) -> tela `parametros` — stories: US-27
- **Registros e acesso** (`nav-auditoria`) -> tela `auditoria` — stories: US-25, US-26, US-27

## Componentes Principais

- **Formulário de login** (`cmp-form-login`) — tipo: `form`
- **Navegação lateral por módulo** (`cmp-sidebar-nav`) — tipo: `navigation`
- **Árvore de BOM multinível** (`cmp-bom-tree`) — tipo: `table`
- **Pílula de status** (`cmp-status-pill`) — tipo: `badge`
- **Cartão de métrica clicável** (`cmp-metric-filter`) — tipo: `filter`
- **Tabela de registros com filtros** (`cmp-data-table`) — tipo: `table`
- **Abas de seção** (`cmp-tabs`) — tipo: `navigation`
- **Cronômetro de operação** (`cmp-timer-apontamento`) — tipo: `widget`
- **Formulário lateral de registro** (`cmp-form-registro`) — tipo: `form`
- **Alerta contextual** (`cmp-alert`) — tipo: `feedback`
- **Notificação de confirmação** (`cmp-toast`) — tipo: `feedback`
- **Contador de expiração da sessão** (`cmp-session-clock`) — tipo: `widget`
- **Matriz de permissões por perfil** (`cmp-perm-matrix`) — tipo: `table`
- **Faixa de indicadores** (`cmp-stat-strip`) — tipo: `metric-strip`
- **Kit de gráficos SVG** (`cmp-chart-kit`) — tipo: `chart`
- **Cronograma de Gantt** (`cmp-gantt`) — tipo: `chart`
- **Matriz de intensidade de consumo** (`cmp-heatmap-consumo`) — tipo: `chart`
- **Tabela de cadastro com ações em linha** (`cmp-tabela-cadastro`) — tipo: `table`
- **Editor de ficha técnica** (`cmp-editor-ficha`) — tipo: `editable-table`
- **Modal de cadastro e edição** (`cmp-modal-cadastro`) — tipo: `dialog`
- **Compositor de relatório** (`cmp-compositor-relatorio`) — tipo: `form`
- **Editor de linhas do pedido** (`cmp-editor-pedido`) — tipo: `table-editor`
- **Painel de viabilidade do prazo** (`cmp-viabilidade-prazo`) — tipo: `panel`
- **Fila priorizada do plano** (`cmp-fila-plano`) — tipo: `table-editor`
- **Capacidade instalada por setor** (`cmp-capacidade-setor`) — tipo: `chart`
- **Tabela de componentes comuns** (`cmp-consolidacao-componentes`) — tipo: `table`
- **Cronograma previsto do plano** (`cmp-gantt-plano`) — tipo: `chart`
- **Cartoes de atalho do usuario** (`cmp-cards-atalho`) — tipo: `card-grid`
- **Fila de atencao** (`cmp-fila-atencao`) — tipo: `list`
- **Anexo de documento com extracao por OCR** (`cmp-dropzone-ocr`) — tipo: `upload`
- **Acervo documental com busca no conteudo** (`cmp-acervo-ged`) — tipo: `card-grid`
- **Tabela de lotes e saldo** (`cmp-tabela-lotes`) — tipo: `table`
- **Databook de rastreabilidade por pedido** (`cmp-databook`) — tipo: `report`
- **Tabela de cargos e custo-hora** (`cmp-tabela-cargos`) — tipo: `table`
- **Peso da mao de obra no custo do produto** (`cmp-peso-mao-de-obra`) — tipo: `table`
- **Tabela de orcamento** (`cmp-tabela-orcamento`) — tipo: `table`
- **Painel de analise de custo** (`cmp-painel-bi-custo`) — tipo: `chart-group`
- **Cartoes de ordem liberada do operador** (`cmp-cards-os-operador`) — tipo: `card-grid`
- **Folha A4 retrato com QR Code** (`cmp-folha-a4`) — tipo: `print-sheet`
- **Fila de expedição por pedido e item** (`cmp-fila-expedicao`) — tipo: `list`
- **Leitor de QR da expedição** (`cmp-leitor-qr-expedicao`) — tipo: `input`
- **Carga selecionada** (`cmp-carga-expedicao`) — tipo: `panel`
- **Romaneio de expedição A4 com relação de QR** (`cmp-romaneio-a4`) — tipo: `document`
- **Compositor da descrição do produto** (`cmp-compositor-descricao`) — tipo: `form`
- **Esquema vetorial da placa** (`cmp-esquema-placa`) — tipo: `visualization`
- **Pre-lista de nomenclatura** (`cmp-prelista-nomenclatura`) — tipo: `select`
- **Painel de arquivos da placa** (`cmp-arquivos-linha`) — tipo: `modal`
- **Importador de planilha de lancamento** (`cmp-importador-planilha`) — tipo: `modal`
- **Tabela de itens de contrato com medicao** (`cmp-contrato-itens`) — tipo: `table`
- **Pagina de visualizacao do item** (`cmp-pagina-item`) — tipo: `layout`
- **Etiqueta de placa com QR** (`cmp-etiqueta-placa`) — tipo: `print`
- **Captura de foto de conclusao** (`cmp-foto-conclusao`) — tipo: `modal`
- **Relatorio final de expedicao** (`cmp-espelho-fiscal`) — tipo: `print`
- **Trilha do roteiro do item** (`cmp-trilha-roteiro`) — tipo: `progress`
- **Tabela do roteiro base** (`cmp-tabela-processos`) — tipo: `table`
- **Painel de conferencia do romaneio** (`cmp-conferencia-romaneio`) — tipo: `list`
- **Tira de periodos da programacao** (`cmp-tira-periodos`) — tipo: `list`
- **Programacao do periodo** (`cmp-programacao-periodo`) — tipo: `table`
- **Carga por setor no periodo** (`cmp-carga-setor-periodo`) — tipo: `table`
- **Conferencia do pacote .vfb** (`cmp-conferencia-vfb`) — tipo: `table`
- **Seletor de unidade de fabrica** (`cmp-seletor-unidade`) — tipo: `select`
- **Cartao de unidade de fabrica** (`cmp-cartao-unidade`) — tipo: `card`
- **Formulario de transferencia entre unidades** (`cmp-form-transferencia`) — tipo: `form`
- **Razao de transferencias** (`cmp-razao-transferencias`) — tipo: `table`
- **Saldo comparado entre unidades** (`cmp-comparativo-saldo`) — tipo: `table`
- **Painel de parametros de funcionamento** (`cmp-painel-parametros`) — tipo: `form`
- **Resumo do efeito da parametrizacao** (`cmp-efeito-parametros`) — tipo: `list`
- **Filtro de familia da ficha tecnica** (`cmp-filtro-familia-ficha`) — tipo: `filter`
- **Cartão de desempenho em m²** (`cmp-card-m2`) — tipo: `chart`
- **Tabela de conversão por período** (`cmp-tabela-m2`) — tipo: `table`
- **Indicador de área a concluir no período** (`cmp-stat-area-programada`) — tipo: `stat`
- **Base de relatório — desempenho em m²** (`cmp-base-rel-m2`) — tipo: `table`
- **Paleta de modulos por teclado** (`cmp-paleta-comandos`) — tipo: `undefined`
- **Confirmacao de apontamento com efeito** (`cmp-confirmacao-apontamento`) — tipo: `undefined`
- **Estorno de apontamento** (`cmp-estorno-apontamento`) — tipo: `undefined`
- **Fila de ordens aguardando inspecao** (`cmp-fila-qualidade`) — tipo: `undefined`
- **Bloco de unidades retidas pela qualidade** (`cmp-retidas-expedicao`) — tipo: `undefined`
- **Roteiro proprio da ficha** (`cmp-roteiro-ficha`) — tipo: `undefined`
- **Rascunho e descarte de ficha** (`cmp-rascunho-ficha`) — tipo: `undefined`
- **Previa da geracao de ordens** (`cmp-previa-geracao-ordens`) — tipo: `undefined`
- **Janela de datas do relatorio** (`cmp-janela-relatorio`) — tipo: `undefined`
- **Filtros e paginacao da auditoria** (`cmp-auditoria-filtros`) — tipo: `undefined`
- **Faixa de filtro aplicado** (`cmp-faixa-filtro`) — tipo: `undefined`

## Deltas

- **assumption** (`delta-001`) — impacto: medium
  O design plan deterministico mapeou a tela de login para US-01. A tela foi vinculada a US-28 (login autenticado e sessao controlada) e US-26 (isolamento multiempresa), que sao as stories reais de autenticacao. US-01 permanece coberta na tela de configuracao tecnica.
- **scope** (`delta-002`) — impacto: medium
  O design plan previa uma unica tela 'principal' cobrindo US-01 a US-28. Ela foi decomposta em 9 telas funcionais por modulo (configuracao, familias, ordens, detalhe da ordem, estoque, chao de fabrica, qualidade, expedicao, auditoria) mais a tela fail-closed de acesso negado. A cobertura das 28 stories foi mantida integralmente.
- **unclear** (`delta-003`) — impacto: medium
  Os limites dimensionais por familia construtiva, as formulas de BOM (fatores de perda, densidade por espessura, perimetro por rebite) e os tempos padrao do roteiro sao valores de demonstracao. As regras reais virao do cadastro versionado de familia e norma.
- **unclear** (`delta-004`) — impacto: medium
  O modo offline (RNF-11 e RNF-12) esta representado apenas como estado visual 'pendente de sincronizacao' em movimentacoes e apontamentos. Nao ha fila local, idempotencia nem resolucao de conflito no prototipo.
- **assumption** (`delta-005`) — impacto: high
  A matriz de permissoes por perfil filtra a navegacao e desabilita acoes de escrita no cliente, e a tentativa de acesso indevido cai em tela fail-closed com registro de auditoria. O enforcement real precisa ser server-side por tenant e perfil. Com as telas de cadastro de itens, fichas tecnicas e relatorios, a superficie de escrita cresceu: o enforcement server-side por tenant e perfil passou a ser bloqueante para producao.
- **assumption** (`delta-006`) — impacto: low
  O perfil Compras aparece na matriz de perfis com leitura em estoque e ordens porque US-27 lista compras entre os perfis, mas nenhuma story aprovada descreve um fluxo proprio de compras. Nenhuma tela exclusiva foi criada para esse perfil.
- **unclear** (`delta-007`) — impacto: low
  Ordens de demonstracao sem apontamento exibem '—' na comparacao planejado x realizado em vez de valores simulados, para nao inventar dados de producao inexistentes.
- **assumption** (`delta-008`) — impacto: medium
  A camada visual foi substituida pela norma fechada ui-obs (github.com/claudio0507/ui-obs) por decisao do operador. Superficies, texto, bordas, raios, alturas, sombras e escala tipografica vem de tokens.css; a unica variavel de aplicacao e --accent. Nenhuma tela, acao, permissao ou entidade foi alterada: a cobertura das user stories permanece identica.
- **assumption** (`delta-009`) — impacto: low
  O acento da aplicacao usa o laranja definido pelo operador (#d97757), aplicado tambem ao logotipo para evitar dois laranjas quase iguais lado a lado, e nao a semantica --orange do kit (#e9973f escuro / #c26a10 claro), que ficaria indistinguivel do acento. Para nao criar ambiguidade, o estado 'aguardando material' usa a semantica --yellow em vez de --orange. Nenhuma outra semantica foi remapeada.
- **unclear** (`delta-010`) — impacto: medium
  Botao primario segue a norma (fundo --accent + --text-on-accent branco, peso 700). Com o acento laranja a razao de contraste do texto sobre o fundo fica em torno de 3:1, abaixo de WCAG AA 4.5:1 para texto normal. Manter a norma foi a escolha; se o criterio de acessibilidade prevalecer, --text-on-accent precisa virar tinta escura sobre o laranja.
- **assumption** (`delta-011`) — impacto: low
  A seta do <select> nativo e um SVG Lucide codificado em data-URI, que nao aceita currentColor. A cor literal fica no token --icon-chevron, redefinido por tema, e nao dentro de componentes.
- **scope-extension** (`delta-012`) — impacto: high
  O operador solicitou telas de cadastro de materiais, componentes, produtos e depositos. Nenhuma user story aprovada descreve o cadastro de itens: US-05 cobre familias construtivas e US-13/US-14 cobrem saldo e movimentacao, mas pressupoem o item ja existente. As telas foram criadas porque a BOM, a reserva e a movimentacao nao se sustentam sem cadastro. Requer story propria antes da implementacao.
- **scope-extension** (`delta-013`) — impacto: high
  A ordem de producao passou a carregar mais de um item (produtos e componentes) conforme pedido do operador. US-07 descreve a ordem como derivada de um unico snapshot tecnico. O prototipo mantem o vinculo ao snapshot, mas a cardinalidade item-ordem mudou de 1 para N. Impacta reserva (US-11), separacao (US-12) e comparacao planejado x realizado (US-10).
- **scope-extension** (`delta-014`) — impacto: high
  A composicao de fichas tecnicas virou tela propria, com edicao em linha, duplicacao de linha, clonagem de ficha, importacao entre fichas e publicacao de versao. US-02 descreve a BOM como resultado automatico da formula da familia construtiva, nao como estrutura editada manualmente. As duas fontes coexistem no prototipo e podem divergir: e preciso decidir qual prevalece na explosao.
- **assumption** (`delta-015`) — impacto: high
  A baixa de material e a transferencia entre depositos no apontamento sao automaticas, disparadas ao concluir a operacao: baixam os materiais cujas linhas de ficha pertencem ao setor da operacao e transferem os componentes fabricados naquele setor para o deposito de destino. US-17 descreve o consumo como registro manual do operador. As duas formas convivem; o consumo automatico e marcado com origem distinta.
- **scope-extension** (`delta-016`) — impacto: medium
  A secao de previsibilidade de consumo por dia, semana e mes nao consta em nenhuma user story aprovada. A projecao distribui linearmente a necessidade restante de cada ordem ao longo da sua janela de producao, sem considerar lead time de compra, lote minimo de fornecedor ou ordens ainda nao liberadas.
- **scope-extension** (`delta-017`) — impacto: medium
  Painel geral da fabrica, visao de recursos, visao de clientes com previsao de entrega e compositor de relatorios gerenciais foram criados a pedido do operador. Cada tela foi vinculada as stories mais proximas (US-08, US-09, US-10, US-13, US-22, US-23, US-24, US-25), mas nenhuma descreve esses artefatos diretamente.
- **assumption** (`delta-018`) — impacto: medium
  Custos unitarios de material, capacidade de deposito, lead time, estoque minimo, fornecedores e prazos contratados por pedido sao valores de demonstracao. Nenhuma user story aprovada trata de custo ou de contrato comercial. Os valores servem apenas para exercitar o layout e a agregacao dos relatorios.
- **assumption** (`delta-019`) — impacto: low
  Os graficos (barras, linha, rosca, gantt e matriz de intensidade) sao SVG gerado no proprio arquivo, sem biblioteca externa, para manter o artifact standalone e offline. A projecao de producao apontada contra plano no painel usa serie sintetica derivada da data, nao apontamentos reais.
- **assumption** (`delta-020`) — impacto: medium
  A exportacao de relatorio gera CSV no proprio navegador via Blob e o PDF depende da caixa de impressao do sistema. Nao ha geracao server-side, fila de exportacao, nem controle de acesso ao arquivo exportado. US-24 e US-25 exigem rastreabilidade: o prototipo registra a exportacao na auditoria, mas o arquivo em si nao e versionado.
- **assumption** (`delta-021`) — impacto: high
  Nenhuma user story aprovada descreve o lancamento do pedido do cliente. A tela Pedidos e demandas foi criada porque US-07 exige uma ordem com cliente, quantidade e prazo, e ate agora esses dados eram de demonstracao, sem origem no sistema. A tela nao cria permissao nem entidade fora do que US-07 e US-27 ja pressupoem.
- **assumption** (`delta-022`) — impacto: high
  A tela Plano de producao introduz uma etapa entre o pedido e a ordem de producao: fila priorizada, capacidade instalada e consolidacao de componentes. US-07 fala em transformar snapshot em ordem e US-09 em distribuir operacoes, mas nenhuma story aprovada descreve a priorizacao previa.
- **assumption** (`delta-023`) — impacto: high
  A integracao com o ViaSign e simulada: o botao Importar do ViaSign devolve dois projetos fixos. Nao ha contrato de API, autenticacao, paginacao, idempotencia nem tratamento de divergencia entre o projeto do ViaSign e o cadastro de produtos do ERP.
- **assumption** (`delta-024`) — impacto: medium
  A previsao de datas do plano usa um modelo simples: capacidade instalada de 8 h por dia por maquina cadastrada e carga sequencial da fila somada a carga ja em piso. Nao considera calendario de turnos, feriados, setup, paralelismo real entre setores nem restricao de maquina especifica.
- **assumption** (`delta-025`) — impacto: medium
  A consolidacao de componentes gera uma ordem de lote sem pedido de origem unico. Essa ordem nao entra no calculo de avanco por pedido da tela Clientes e entregas, que agrega ordens pelo campo pedido. E preciso definir se a ordem de lote deve ratear avanco entre os pedidos atendidos.
- **assumption** (`delta-026`) — impacto: high
  A geracao de ordens pelo plano cria configuracao e snapshot sequenciais sem passar pela validacao de familia construtiva da tela de Configuracao tecnica. No sistema real a ordem so pode nascer de um snapshot congelado e validado conforme US-01 a US-04; aqui o vinculo e apenas identificador.
- **assumption** (`delta-027`) — impacto: medium
  O catalogo de materiais, componentes e produtos foi substituido pelo catalogo real do repositorio viafab-core (40 materiais, 66 componentes, 32 produtos) com as descricoes originais. Setor, maquina e deposito de cada ficha foram remapeados para a organizacao de fabrica ja definida neste prototipo, conforme instrucao do operador de manter o fluxo existente. Dos 32 produtos, 6 vieram com composicao de origem, 8 tiveram a composicao derivada por analogia estrutural (mesma familia, outra medida ou substrato) e ficam marcados como derivada, e 18 permanecem em elaboracao sem composicao.
- **assumption** (`delta-028`) — impacto: medium
  Custo-hora por cargo, efetivo, custo-hora de maquina e tempo padrao por operacao sao valores de demonstracao. O tempo por operacao foi atribuido por tipo de maquina porque o catalogo de origem trazia tempo zero em todas as fichas. Antes de usar o orcamento para formar preco real e preciso levantar apontamento historico e a folha efetiva.
- **assumption** (`delta-029`) — impacto: high
  Lote e rastreabilidade foram introduzidos como entidade nova: toda entrada de material gera lote, o consumo baixa lote por FEFO e o databook do pedido nasce dessa cadeia. Nenhuma user story aprovada descreve lote, certificado de qualidade ou databook; US-13 e US-14 tratam saldo e movimentacao sem granularidade de lote.
- **assumption** (`delta-030`) — impacto: high
  O OCR e simulado. A extracao le o nome do arquivo e, quando o anexo e texto, o conteudo; o que nao for reconhecido fica em branco e marcado para conferencia, e o conteudo indexado no GED e o que o conferente confirma. Nao ha motor de OCR, nem armazenamento binario, nem antivirus, nem versionamento de documento.
- **assumption** (`delta-031`) — impacto: medium
  A pagina inicial com atalhos por usuario nao e coberta por nenhuma user story aprovada. Os atalhos persistem em localStorage por perfil, nao por usuario autenticado, e o resumo critico e derivado do estado da sessao, nao de um endpoint agregador.
- **assumption** (`delta-032`) — impacto: high
  Orcamento, formacao de preco e painel de custo nao sao cobertos por user story aprovada. Margem e imposto sao percentuais lineares sobre o custo, sem regime tributario, frete, ICMS por destino nem tabela de preco por cliente.
- **assumption** (`delta-033`) — impacto: medium
  A ordem de servico impressa explode a arvore do item da ordem para gerar uma linha por peca e setor, e o QR Code carrega apenas identificadores em texto plano, sem assinatura nem token. Para apontamento por leitura o conteudo precisa ser assinado ou trocado por um identificador opaco, sob pena de qualquer QR forjado abrir uma ordem.
- **assumption** (`delta-034`) — impacto: medium
  A fila do operador no chao de fabrica passou a mostrar apenas ordens planejadas ou em producao sem bloqueio, por decisao do operador de que falta de material e impedimento sao tratados pelo PCP. Isso remove do operador a visibilidade de ordens paradas; se a fabrica precisar que o operador enxergue e sinalize a parada, o criterio precisa ser revisto.
- **assumption** (`delta-035`) — impacto: high
  A descricao do produto passou a ser composta por seis partes fixas (formato, dimensao, pelicula fundo+legenda, substrato, instalacao e codigo da placa) e as 32 placas do catalogo foram reescritas nesse padrao. Nenhuma user story aprovada define nomenclatura de produto: US-05 cobre familia construtiva e US-01 cobre configuracao tecnica, ambas sem regra de descricao. Os codigos de formato MA, MP e MQ vieram do catalogo de origem e o descritor de cada um nao foi confirmado.
- **assumption** (`delta-036`) — impacto: high
  Placa indicativa (IND) tem dimensao livre: ao cadastrar ou importar uma dimensao inedita o sistema cria quatro componentes (corte, quadro, sinal e fixacao) nomeados pela dimensao e multiplica as quantidades da ficha base de 1 m2 pela area final. Inclusive a fixacao escala por area, conforme a regra informada pelo operador; na pratica o numero de suportes tende a depender da largura e da altura de instalacao. Nenhuma story aprovada descreve geracao automatica de componente.
- **assumption** (`delta-037`) — impacto: high
  Cada unidade produzida recebe identificacao unitaria: o componente ganha ID no apontamento do setor que o fabrica e o produto ganha ID na montagem, agregando os IDs dos componentes de mesma posicao da ordem. Serie de item e entidade nova; US-16 cobre apontamento de inicio e fim sem granularidade unitaria e US-22/US-23 tratam expedicao por ordem. A associacao produto-componente usa a posicao sequencial dentro da ordem, nao a rastreabilidade fisica real do posto.
- **assumption** (`delta-038`) — impacto: high
  A expedicao passou a ser por unidade: um pedido pode sair total ou parcialmente e a ordem so muda para expedida quando nao resta unidade identificada na fila. US-23 pressupoe a saida da ordem inteira. Enquanto ha saldo, a ordem permanece concluida e aparece como expedicao parcial, o que muda o significado do status para os paineis que contam ordens prontas.
- **assumption** (`delta-039`) — impacto: medium
  O apontamento de expedicao por QR le o conteudo da etiqueta ou o ID de serie digitado, sem camera nem coletor real. O conteudo do QR segue em texto plano, como ja registrado em delta-033: para uso em campo o payload precisa ser assinado ou trocado por identificador opaco, senao uma etiqueta forjada daria baixa em unidade que nao saiu.
- **assumption** (`delta-040`) — impacto: medium
  A integracao ViaSign passou a entregar dimensao e legenda da placa indicativa e o ERP resolve ou cria o produto daquela medida. A parte 6 da descricao fica na linha do pedido e nao no cadastro do produto, para nao gerar catalogo infinito. Continua sem contrato de API, autenticacao ou idempotencia, como ja registrado em delta-023: uma reimportacao do mesmo projeto duplicaria o pedido.
- **scope-addition** (`delta-041`) — impacto: high
  Contrato do cliente e item de contrato com preco unitario passaram a existir como entidade. Nenhuma user story aprovada descreve contrato, preco ou medicao; US-24 trata expedicao e entrega, nao faturamento. A vinculacao e opcional e nao bloqueia nenhuma etapa da fabricacao.
- **assumption** (`delta-042`) — impacto: medium
  Precos dos itens de contrato, vigencias e objetos sao valores de demonstracao. O modelo assume um contrato vigente por cliente e nao trata aditivo, reajuste, saldo contratual, reequilibrio ou tabela por lote.
- **scope-addition** (`delta-043`) — impacto: high
  Arquivos por linha de pedido — relatorio PDF, arte EPS e imagem da placa — nao tem story. O armazenamento e apenas em memoria da sessao: nao ha repositorio binario, versionamento, antivirus, retencao nem controle de acesso ao arquivo. O EPS nao e pre-visualizavel no navegador.
- **scope-addition** (`delta-044`) — impacto: medium
  Rodovia, km, metro e coordenada vieram do ViaSign e nao constam de nenhuma story aprovada. Nao interferem na fabricacao; alimentam etiqueta, romaneio e relatorio final. Coordenadas do prototipo sao geradas deterministicamente a partir de uma base e nao correspondem a locais reais.
- **scope-addition** (`delta-045`) — impacto: medium
  Importacao por planilha modelo aceita CSV com separador ponto e virgula, virgula ou tabulacao. Nao le XLSX binario, nao valida duplicidade contra linhas ja lancadas e nao possui chave de idempotencia: importar o mesmo arquivo duas vezes duplica as linhas.
- **scope-addition** (`delta-046`) — impacto: medium
  A pagina do item e uma tela nova sem story propria: reorganiza informacao que ja existia em ordens, fichas, estoque e expedicao. Quando aberta por item da ordem e nao por unidade identificada, os dados exibidos sao do lote e nao de uma peca especifica.
- **scope-addition** (`delta-047`) — impacto: medium
  Etiqueta de placa com QR nao tem story. O payload segue em texto plano, herdando o risco ja registrado em delta-039: etiqueta forjada e aceita pela leitura de expedicao. Sao 18 etiquetas por A4; o corte do lote e explicito na tela e nada e truncado em silencio.
- **scope-addition** (`delta-048`) — impacto: medium
  Foto de conclusao nao consta de US-16 nem de US-22. E aplicada por grupo de produto da ordem, nao por peca: um lote de 40 placas identicas recebe a mesma imagem. Placas indicativas, que sao unicas, deveriam ter foto individual — a substituicao por unidade so e possivel pela pagina do item.
- **scope-addition** (`delta-049`) — impacto: high
  O relatorio final de expedicao e um espelho de faturamento e nao substitui documento fiscal: nao ha calculo de imposto, CFOP, base de calculo, retencao nem integracao com emissor de NF-e. Linhas sem item de contrato ficam com valor zero e sao declaradas em observacao no rodape da folha.
- **assumption** (`delta-050`) — impacto: medium
  A parte 6 saiu do cadastro de produto: a descricao auxiliar agora nasce na linha do pedido e viaja na ordem, na unidade identificada, na etiqueta e no relatorio. Produtos ja cadastrados com codigo na descricao tiveram esse sufixo removido, o que altera o nome exibido de 17 dos 32 produtos do catalogo.
- **assumption** (`delta-051`) — impacto: low
  Previsibilidade de consumo e mao de obra deixaram de ser telas proprias e viraram vistas dentro de Plano de producao e Recursos. Nenhuma acao, permissao ou dado foi removido; a navegacao caiu de 22 para 20 itens.
- **assumption** (`delta-052`) — impacto: low
  O esquema visual da placa e desenhado a partir dos parametros do cadastro e da descricao auxiliar, com as cores de categoria do CONTRAN deduzidas do prefixo do codigo. E um recurso de reconhecimento no processo e nao reproduz a arte do projeto: pictogramas, tipografia oficial e diagramacao nao sao representados.
- **scope-change** (`delta-053`) — impacto: high
  As telas de configuracao tecnica (assistente por familia construtiva) e de familias e normas foram removidas a pedido do operador: a parametrizacao passa a ser a ficha tecnica pontual de cada produto somada as cinco partes da nomenclatura. US-01, US-02 e US-03 passam a ser cobertas por Itens, Fichas tecnicas e Recursos/Processos; US-04 pelo congelamento que ocorre na geracao da ordem pelo plano.
- **gap** (`delta-054`) — impacto: high
  US-06 exigia cadastro versionado de norma tecnica com fonte e vigencia rastreaveis. Com a remocao da tela de normas, o que resta e a validacao dimensional por formato: a medida informada e conferida contra as medidas normatizadas do formato e a divergencia e sinalizada. Nao ha mais versionamento de norma com fonte e vigencia.
- **assumption** (`delta-055`) — impacto: high
  O roteiro base de fabricacao passou a ser editavel em Recursos/Processos e vale para toda ordem gerada. Nao ha roteiro por familia nem por produto: uma alteracao aqui muda capacidade, custo de conversao e fila do chao de fabrica de todas as ordens novas.
- **assumption** (`delta-056`) — impacto: medium
  A expedicao passou a exigir que a unidade esteja no deposito de expedicao. O item de topo da ordem entra nesse deposito ao ser concluido, independentemente do deposito configurado na ficha. Componente pedido diretamente pelo cliente tambem entra, o que muda o significado do deposito de destino da ficha para esses casos.
- **assumption** (`delta-057`) — impacto: medium
  O romaneio nao reserva estoque fisico: ele apenas retira a unidade da fila enquanto estiver aberto. Cancelar o romaneio devolve tudo. Nao ha bloqueio contra dois usuarios montando romaneios simultaneos sobre o mesmo deposito.
- **assumption** (`delta-058`) — impacto: high
  A reserva de componente deixou de ser travada por pedido: a peca pronta e alocada para quem estiver na frente da fila e a alocacao e recalculada a cada repriorizacao. Isso significa que um pedido pode perder a cobertura que exibia antes de o operador reordenar a fila; nao ha trava manual para fixar uma peca a um pedido.
- **assumption** (`delta-059`) — impacto: high
  A consolidacao de pecas iguais entre ordens na OS por setor usa o codigo do componente como chave. Se duas ordens pedirem o mesmo codigo com acabamento diferente registrado apenas na descricao auxiliar, elas serao somadas indevidamente. A excecao atual e apenas o setor grafico de placa indicativa e o produto acabado.
- **assumption** (`delta-060`) — impacto: medium
  O orcamento deixou de derivar de um pedido: a proposta e montada a partir do catalogo, com quantidade digitada. Isso desacopla proposta e carteira, entao o valor proposto nao e confrontado automaticamente com o pedido que vier depois nem com o item de contrato.
- **assumption** (`delta-061`) — impacto: medium
  A lista de nomenclatura passou a trazer as 125 entradas do CONTRAN fornecidas pelo operador. Ela e uma pre-lista de digitacao, nao um cadastro versionado: nao ha fonte, vigencia nem vinculo com a arte da placa.
- **assumption** (`delta-062`) — impacto: medium
  A capacidade do setor passou a ser turnos x horas por maquina/dia x numero de maquinas, cadastrada em Recursos. Continua sem feriado, setup, paralelismo real dentro do turno ou disponibilidade por operador.
- **assumption** (`delta-063`) — impacto: high
  O cadastro de setor usa o nome como chave. Renomear propaga para maquinas, roteiro, cargos, fichas e ordens em memoria; num backend isso exige identificador estavel e migracao, sob pena de quebrar vinculos historicos.
- **assumption** (`delta-064`) — impacto: high
  A ordem de producao nao carrega agenda: so prazo e avanco. A programacao por dia, semana e mes e derivada — distribui as operacoes pendentes do roteiro base em dias uteis contra a capacidade diaria do setor (turnos x maquinas), na sequencia da ancora de inicio. Nao ha calendario de feriados, turnos por dia da semana, tempo de setup, paralelismo dentro do setor nem alocacao por maquina individual: a capacidade do setor e tratada como um pote unico.
- **assumption** (`delta-065`) — impacto: medium
  O replanejamento move a ancora de inicio da ordem e vive so na sessao. Nao ha trava contra dois usuarios reprogramando ao mesmo tempo, nem versionamento da programacao, nem registro de quem aceitou uma conclusao apos o prazo. Adiar uma ordem pode empurrar as seguintes sem aviso individual, porque a capacidade e consumida na ordem da fila.
- **assumption** (`delta-066`) — impacto: medium
  O consumo projetado do periodo atribui a baixa inteira ao dia em que a operacao fecha, que e a regra real da baixa automatica. Consequencia: uma operacao que atravessa varios dias nao mostra consumo parcial, e o material aparece todo no ultimo dia dela.
- **integration** (`delta-067`) — impacto: high
  O importador consome o pacote .vfb (ADR-012, schema viaxis.vfb/1): le o ZIP pelo diretorio central, valida o manifesto, resolve o produto pelas cinco partes da nomenclatura e anexa os arquivos pelo caminho declarado. O que nao esta implementado: conferencia de bytes e sha256 dos ativos (o manifesto e lido, os binarios nao), extracao e armazenamento dos arquivos (so os metadados entram na linha), leitura do .vsg anexo e verificacao de assinatura. A descompressao depende de DecompressionStream; sem ela so o manifest.json avulso e aceito.
- **assumption** (`delta-068`) — impacto: high
  A chave de produto do ERP formata a dimensao com uma casa decimal (dimBR), enquanto o manifesto entrega milimetros inteiros. 850 mm e 900 mm colapsam na mesma chave 0,9 e resolveriam o mesmo produto. O importador avisa na linha em vez de casar em silencio, mas a correcao definitiva exige duas casas na chave e renomear o catalogo inteiro — mudanca que altera o nome exibido de todos os produtos.
- **assumption** (`delta-069`) — impacto: high
  classificacao.sem_quadro e campo de primeira classe no contrato do ViaSign (placa com menor lado <= 600 mm dispensa quadro e tem ficha propria), mas a nomenclatura de cinco partes do ViaFab nao carrega essa dimensao. O importador avisa; sem uma sexta parte ou variante de formato, uma placa de 0,60 m casaria com a ficha que leva quadro.
- **assumption** (`delta-070`) — impacto: high
  O manifesto carrega um unico bloco local por placa e quantidade agregada, declarando que todas as unidades ficam no mesmo ponto de implantacao. O ViaFab identifica cada unidade individualmente (ITM-xxxxxx) com rodovia, km, metro e coordenada proprios na etiqueta, no romaneio e no espelho fiscal. Se um projeto de 40 placas em 40 quilometros distintos vier como uma placa com quantidade 40, a implantacao por unidade se perde. Antes de construir o gerador e preciso confirmar que o ViaSign emite uma entrada de placas[] por ponto de implantacao.
- **assumption** (`delta-071`) — impacto: high
  projeto.hash e descrito como SHA-256 do manifesto canonico, mas o contrato nao define a canonicalizacao (ordenacao de chaves, escape, numeros, exclusao do proprio campo hash). Sem isso o ViaFab nao recalcula nem verifica o hash: ele e tratado como identificador opaco de revisao. A assinatura prevista na fase 4 herda o mesmo problema.
- **assumption** (`delta-072`) — impacto: medium
  O processo grafico nao vem no manifesto e o ERP assume sinal impresso (SI) na parte 3 da nomenclatura, inclusive quando pelicula.unica e verdadeiro (R-1 e marcadores, que nao tem fundo mais legenda). O contrato preve que o usuario confirme ou substitua no lancamento, pontual ou em lote; essa confirmacao em lote ainda nao existe na tela de pedidos.
- **assumption** (`delta-073`) — impacto: medium
  Pelicula tipo IV da NBR 14891 esta no enum do contrato e nao tem equivalente no catalogo do ViaFab (I->GTP, III->AIP, X->GD). A placa e recusada na conferencia em vez de ser mapeada por aproximacao. Falta decidir o codigo de catalogo do tipo IV.
- **assumption** (`delta-074`) — impacto: medium
  referencia_viasign (suporte, quadro, chapa e insumos por unidade) e gravado na linha do pedido mas ainda nao e exibido na pagina do item nem confrontado com a ficha do ViaFab. O contrato preve esse confronto — o ViaSign projeta 2,0 m de cantoneira, a ficha consome 2,2 m — e ele e o unico caminho hoje para o numero real de bracadeiras e de pontos de fixacao aerea, que a ficha do ERP escala por area.
- **assumption** (`delta-075`) — impacto: medium
  origem.usuario viaja como e-mail em texto plano dentro de um pacote aberto, sem cifragem. Em um pacote trocado por e-mail ou armazenado em nuvem isso e dado pessoal exposto; avaliar identificador opaco ou omissao do campo.
- **scope-addition** (`delta-076`) — impacto: high
  Operacao multiunidade nao esta em nenhuma user story aprovada. Pedido e ordem passaram a carregar unidade de lancamento e unidade de fabricacao, e o saldo de material deixou de ser unico: fisico e reservado passaram a ser por unidade. O catalogo de engenharia (itens, componentes, produtos, fichas) continua unico na rede.
- **assumption** (`delta-077`) — impacto: high
  A transferencia entre unidades debita a origem na emissao e credita o destino no recebimento; entre os dois momentos a quantidade nao aparece em nenhum saldo, apenas no razao. Nao ha estoque em transito como deposito proprio, nem conferencia de divergencia entre o que saiu e o que chegou, nem chave de idempotencia: reemitir a mesma transferencia duplica o movimento.
- **scope-addition** (`delta-078`) — impacto: high
  Parametros de funcionamento nao tem story aprovada. Sao globais por instalacao e persistidos em armazenamento local do navegador, nao por tenant nem por usuario, e nao ha versionamento nem trilha de qual valor vigorava quando um apontamento foi feito. Mudar um parametro altera o comportamento das ordens ja em curso.
- **assumption** (`delta-079`) — impacto: medium
  Nem todo parametro esta ligado ao comportamento. Estao ligados: reserva obrigatoria, saldo negativo, consumo acima do separado, baixa e transferencia automaticas, deposito de expedicao, consolidacao padrao do plano, trava de componente pronto, qualidade para expedir, expedicao parcial, foto obrigatoria, horas por maquina/dia e minutos de sessao. Certificado obrigatorio na entrada ainda e declarativo: nao bloqueia nem sinaliza a movimentacao.
- **assumption** (`delta-080`) — impacto: medium
  O filtro de familia da ficha tecnica classifica o componente pelo prefixo da descricao (RECORTE/CORTE, QUADRO, SINAL IMPRESSO, FIXACAO/BARRA) e cai em face/pelicula quando nada casa. Componente cadastrado fora desse padrao de nomenclatura vai para o balde generico. O produto e classificado pelo formato do atributo, que e dado estruturado e nao heuristica.
- **fix** (`delta-081`) — impacto: medium
  O texto dos graficos aparecia em corpo desproporcional porque o SVG nascia com viewBox fixo de 720 px e era esticado ate a largura do cartao, ampliando fonte e traco junto. O viewBox passou a nascer com a largura medida do container e, quando ainda houver divergencia (redimensionamento de janela, aba oculta no momento do render), o corpo do texto e a espessura do traco sao compensados pelo fator de escala.
- **fix** (`delta-082`) — impacto: low
  Cabecalho e conteudo de coluna podiam divergir de alinhamento quando o modelo da linha marcava a celula como numerica e o cabecalho nao. Uma passagem em tempo de render iguala os dois: se qualquer lado da coluna for numerico, ambos passam a alinhar a direita. Sao 261 colunas conferidas no conjunto de telas.
- **fix** (`delta-083`) — impacto: medium
  O bloco de estilo usado para trocar a orientacao da folha impressa continha tambem as regras de tablet e celular do posto de trabalho. Como a troca de orientacao reescreve o conteudo do bloco, a primeira impressao apagava os alvos de toque de 44 px do chao de fabrica ate a proxima recarga. As regras foram movidas para um bloco proprio.
- **assumption** (`delta-084`) — impacto: medium
  O cabecalho dos documentos impressos foi reduzido: logotipo de 6,6 mm para 4,2 mm, titulo de 16 pt para 12 pt, QR de 24 mm para 19 mm e corpo de tabela de 8,6 pt para 7,8 pt. Ganha area util na folha, mas nao foi validado em impressao fisica: 6,3 pt no cabecalho de tabela e o menor corpo do documento e pode ficar apertado em impressora de baixa resolucao.
- **assumption** (`delta-085`) — impacto: high
  O indicador de conversao em m2 foi criado sem story aprovada. Nenhuma das 28 stories define desempenho, produtividade ou faturamento medido em area acabada; US-08 e US-24 falam de painel e relatorio sem citar unidade de medida. A area vem do produto acabado (parte 2 da nomenclatura); o componente nao soma, senao a mesma chapa seria contada duas vezes ao longo do roteiro.
- **assumption** (`delta-086`) — impacto: high
  A ordem nao registrava data de conclusao. Foi criado o campo fim, gravado quando a ultima operacao e apontada, e as ordens ja concluidas do prototipo receberam datas de producao distribuidas entre julho e agosto de 2026 para que a serie por dia, semana e mes tenha o que exibir. Esse historico e de demonstracao: em producao a serie so existe a partir do primeiro apontamento real.
- **assumption** (`delta-087`) — impacto: high
  A area usada no indicador e a area nominal do retangulo largura x altura, nao a area efetiva da face. Placa circular, losangular, octogonal e triangular ocupam menos que o retangulo que as circunscreve, e a diferenca chega a 21 por cento no circulo. Para consumo de chapa a area nominal e a correta, porque e o que se corta; para faturamento por m2 de face o cliente pode exigir a area geometrica. Falta decidir qual das duas vale no item de contrato precificado por m2.
- **assumption** (`delta-088`) — impacto: medium
  A area produzida e atribuida a data em que a unidade do produto foi identificada no apontamento, e a expedida a data da remessa. Componente pronto e placa em processo nao entram em nenhuma das duas, entao o indicador ignora trabalho em andamento: uma semana inteira cortando chapa para uma ordem grande aparece como zero ate a montagem fechar.
- **assumption** (`delta-089`) — impacto: medium
  Na programacao da fabrica a area e atribuida ao periodo em que a ordem fecha, nao distribuida pelas operacoes. Um dia pode mostrar muitas horas programadas e zero m2 a concluir sem que isso seja defeito. O filtro de setor nao fatia a area, porque a conclusao e do produto inteiro.
- **assumption** (`delta-090`) — impacto: medium
  Correcao de contraste: o tema claro reprovava AA em massa (rotulos 2,76:1, links 3,91:1) e os chips de estado ficavam entre 2,19 e 3,45:1 nos dois temas. Os tokens de texto foram escurecidos, o acento textual do tema claro passou a #9b5239, --text-on-accent virou tinta escura #1c1c1a sobre o laranja e o chip passou a usar tinta normal com a semantica no ponto e na borda. A marca nao mudou: --accent continua #d97757.
- **assumption** (`delta-091`) — impacto: high
  O apontamento de conclusao virou transacao com confirmacao previa e estorno de 10 minutos. A operacao ja apontada carrega a marca baixado e nao baixa material de novo, inclusive depois do desbloqueio da ordem. O estorno reverte saldo fisico, reservado, lote FEFO, consumo, movimentacao, serie emitida, eventos e auditoria. Em producao isso exige chave de idempotencia por apontamento e transacao no banco, nao reversao em memoria.
- **assumption** (`delta-092`) — impacto: high
  A reserva de materiais estornava o registro mas nao o saldo reservado do item: rodar duas vezes dobrava o reservado. A reserva anterior passou a voltar ao saldo livre antes do recalculo, e existe acao explicita de liberar reserva. Em producao a operacao precisa ser atomica por ordem para nao competir com separacao concorrente.
- **assumption** (`delta-093`) — impacto: high
  A ficha tecnica ganhou rascunho: a edicao acontece sobre uma copia, existe descartar, a troca de ficha com alteracoes pendentes e interceptada e a publicacao lista as ordens abertas afetadas antes de escrever. O snapshot congelado continua imune, mas o calculo de necessidade e a baixa automatica leem a ficha vigente — a decisao D-02 sobre qual fonte prevalece na BOM segue em aberto.
- **assumption** (`delta-094`) — impacto: high
  O roteiro deixou de ser unico para toda a fabrica: cada ficha pode ter roteiro proprio, editavel em operacao, setor, maquina e tempo padrao. Sem roteiro proprio a ficha herda o roteiro base. Ordens ja criadas mantem o roteiro que receberam.
- **assumption** (`delta-095`) — impacto: medium
  A geracao de ordens pelo plano passou a exigir confirmacao com pre-visualizacao das ordens previstas, dos componentes prontos que serao consumidos e dos materiais sem saldo. A simulacao nao escreve em DB. A fila so e esvaziada apos a confirmacao.
- **assumption** (`delta-096`) — impacto: medium
  A qualidade ganhou fila de trabalho: ordem concluida sem parecer aparece nomeada, com acao de inspecionar, e conta na fila de atencao da pagina inicial. A reprovacao passa a conduzir: o posto ve o motivo, e liberar o bloqueio reabre a ultima operacao para retrabalho e limpa o parecer, exigindo nova inspecao antes de expedir.
- **assumption** (`delta-097`) — impacto: medium
  A expedicao passou a mostrar as unidades fisicamente no deposito de expedicao que a qualidade retem, desabilitadas e com o motivo, com atalho para a ordem e para o modulo de qualidade. Antes o deposito aparecia vazio no sistema e cheio na fabrica.
- **assumption** (`delta-098`) — impacto: medium
  O identificador da ordem de servico impressa deixou de ser posicional. Ele deriva de uma chave estavel (agrupamento + grupo + peca), e persistido e viaja no QR, para que uma folha emitida ontem abra o mesmo grupo hoje. Em producao a sequencia precisa vir do banco, nao de contador em memoria.
- **assumption** (`delta-099`) — impacto: medium
  A janela dos relatorios era simetrica: "ultimos 30 dias" filtrava de HOJE-30 a HOJE+30. Passou a ser intervalo explicito de datas, com presets retrospectivos e prospectivos e opcao personalizada, e o cabecalho impresso declara as datas efetivas.
- **assumption** (`delta-100`) — impacto: medium
  A aderencia de prazo contava ordem expedida como sempre no prazo e nao tinha recorte. Agora compara a data de conclusao com o prazo e exclui do denominador a ordem sem data de conclusao, declarando quantas ficaram de fora. A serie de producao apontada deixou de ser sintetica: apontado vem da serie emitida e plano vem da carga diaria das ordens.
- **assumption** (`delta-101`) — impacto: high
  A trilha de auditoria passou a registrar a unidade de fabrica e ganhou filtro por unidade, intervalo de datas, busca livre, paginacao de 50 e exportacao em CSV e A4. O isolamento continua client-side: o enforcement por tenant depende de RLS server-side, ainda pendente (delta-005).
- **assumption** (`delta-102`) — impacto: medium
  Navegacao por teclado: paleta de modulos em Ctrl K, saltos g+letra, / para focar o filtro da tela e ? para a ajuda. Linha de tabela clicavel recebeu tabindex, role e acionamento por Enter e Espaco; graficos ganharam nome acessivel; o dialogo prende o foco e o devolve ao fechar. O fluxo pedido a expedicao ainda nao foi validado ponta a ponta so por teclado com usuario real.
- **assumption** (`delta-103`) — impacto: medium
  O historico do navegador passou a receber uma entrada por navegacao e as telas de detalhe carregam o identificador na rota (#ordem-detalhe/OP-2433). Voltar anda dentro do app e F5 numa tela interna volta para ela apos autenticar, respeitando a permissao do perfil.
- **assumption** (`delta-104`) — impacto: low
  A sessao passou a ser renovada por tecla, rolagem e toque, nao so por clique — digitar deixou de deslogar. Aos 2 minutos do fim aparece aviso e o relogio muda de estado. O logout fecha qualquer dialogo aberto.
- **assumption** (`delta-105`) — impacto: high
  A importacao do ViaSign separou as origens: pacote .vfb real e projeto de demonstracao viraram modos exclusivos, e confirmar com pacote invalido ficou impossivel. Antes um arquivo recusado seguido de OK criava, em silencio, um pedido ficticio de outro cliente.
- **assumption** (`delta-106`) — impacto: medium
  O reconhecimento do codigo CONTRAN na descricao auxiliar era por prefixo sem fronteira: R-1 casava dentro de R-19 e a troca pela pre-lista corrompia o texto. Passou a exigir fronteira e a escolher o codigo mais longo, e a substituicao e ancorada no inicio, preservando o restante da descricao.
- **assumption** (`delta-107`) — impacto: medium
  A pagina inicial tinha atalhos padrao apontando para modulos que nao existem mais (configuracao, familias, planejamento, maoobra) e o botao de adicionar atalho estava morto para todos os perfis, porque era condicionado a permissao de escrita no modulo inicio. Atalho passou a ser preferencia do usuario: os destinos foram corrigidos, aceitam aba (recursos|rc-maoobra) e sao filtrados pela permissao de leitura do destino.
- **assumption** (`delta-108`) — impacto: low
  Os itens da fila de atencao passaram a ser filtrados pela permissao do perfil e levam o filtro aplicado ao destino, com faixa declarando o recorte e acao de limpar.
