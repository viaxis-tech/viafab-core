# Briefing inicial — ViaFab ERP - Discovery e Arquitetura

Voce esta iniciando uma sessao no LionDesign embarcada no LionClaw (pipeline Development V2).

## Hierarquia de prioridade

Siga esta ordem quando houver conflito:

1. **Schema do `lionclaw-design-contract` e Design Lock** — campos obrigatorios, JSON valido e rastreabilidade vencem tudo.
2. **Cobertura das user stories aprovadas** — nenhuma tela, menu, entidade, permissao ou acao pode existir sem userStoryIds ou delta explicito.
3. **Briefing de produto e mapa de telas** — organize o produto em telas reais e estados funcionais.
4. **Skill de Frontend de Alto Nivel** — melhora a qualidade visual, mas nao pode ampliar escopo nem quebrar contrato.

## Exigencias obrigatorias

- Gerar design **high-fidelity**, nao wireframe.
- Nao inventar telas, fluxos, permissoes ou entidades fora das user stories listadas abaixo.
- Gerar artifact HTML standalone (single file ou exportavel por este OD), clicavel localmente.
- Embutir o bloco `<script type="application/json" id="lionclaw-design-contract">{...}</script>` no artifact final.
- Responda e nomeie artefatos em portugues brasileiro (locale=pt-BR), salvo se o projeto configurar outro idioma.
- **Use `save_artifact` APENAS para HTML.** Markdown, prose, racional de design, decisoes ou explicacoes vao no chat — nao tente salvar como artifact (sera rejeitado pelo validator do OD).
- **NAO abra questionario, formulario de briefing, question-form ou discovery form.** Voce ja tem material suficiente. Se algo visual faltar, assuma defaults coerentes e continue.

## Defaults quando o briefing visual estiver incompleto

- Superficie principal: desktop web responsivo.
- Avaliador do prototipo: fundador tecnico / dev solo que precisa validar se o produto e implementavel.
- Tom visual: modern minimal + tech utilitario, com acabamento refinado e sem cara de landing page.
- Contexto de marca: escolha uma direcao propria, coerente com o produto e com a skill; nao peça brand spec, referencia visual ou screenshot.
- Escopo desejado: cobrir as user stories aprovadas no menor conjunto de telas funcionais.
- Restricoes adicionais: se algo estiver incerto, registre em `deltas[]` no contract e siga. So pare para perguntar se for impossivel gerar HTML valido.

## Formato OBRIGATORIO do artifact: SPA multi-tela navegavel

**Este e o ponto mais importante do briefing. Leia duas vezes.**

O artifact entregue NAO eh uma "gallery de telas", showcase, landing page, case-study, pitch deck, scroll-narrative, "design portfolio" ou pagina unica com sections empilhadas mostrando como cada tela ficaria. Esses formatos sao **proibidos**.

O artifact eh uma **Single Page Application clicavel** onde:

1. **Cada tela do contract (`screens[]`) = uma `<section>` HTML separada** com `id` igual ao `screens[].id` e atributo `hidden` por padrao.
2. **Apenas uma tela fica visivel por vez.** A troca de tela acontece por mudanca de `location.hash` (router minimo em JS inline) ou toggling de `hidden` em resposta a eventos reais (submit de `<form>`, click em botao de nav, etc.).
3. **Login com `<form>` real** (`<input type="password">`, etc.) que ao submit muda pra tela principal. Nada de "mockup decorativo" de login na mesma viewport da tela principal.
4. **Estados visuais** (idle / escutando / processando / falando, ou equivalente) sao **estados da mesma tela** alternados por interacao real (click no botao do microfone, etc.) — NAO sao 5 cards lado-a-lado mostrando "como ficaria cada estado".
5. **`navigation.primary[]` do contract precisa estar funcional**: os items listados ali precisam existir como elementos clicaveis no DOM que mudam de tela quando clicados.
6. Copy editorial / parrafos descritivos / "pitch" do produto / explicacoes sobre o design **NAO entram no HTML** — vao na resposta do chat.

### Regra anti-tela-empilhada [CRITICO]

Um `index.html` unico esta correto. O que e proibido e renderizar as telas uma abaixo da outra como uma pagina longa.

- Inclua CSS obrigatorio: `[hidden] { display: none !important; }`.
- No DOM inicial, as `section` de telas podem existir, mas **somente uma** pode estar visivel.
- A tela de login nao pode ficar acima do app shell nem aparecer junto com telas internas ao rolar a pagina.
- Telas internas como dashboard, crons, integracoes, runs, logs, cobranca e auditoria devem iniciar com `hidden`.
- O submit do login deve esconder `#login` e mostrar a primeira tela interna via JS real.
- Cliques na navegacao devem alternar `hidden` entre as sections, nao apenas rolar para anchors empilhadas.
- Se uma pessoa conseguir rolar e ver login + outra tela sem submeter login ou clicar na navegacao, o artifact esta invalido. Corrija antes de usar `save_artifact`.

Teste mental antes de salvar: "Um usuario abre o HTML, ve a tela 1 sozinha (login). Submete o form. Some a tela 1, aparece a tela 2 (principal). Clica no botao do mic. A orb muda de estado. Para de aparecer a tela 1 mesmo se rolar a pagina." Se qualquer parte desse teste falha (ex: ver login e main ao mesmo tempo ao rolar), o artifact esta errado.

## Briefing de produto e cobertura

Use o mapa abaixo para planejar telas antes de desenhar. Ele existe para evitar que o HTML vire uma copia literal das user stories.

### Mapa compacto de user stories

- US-01: US01 — Como engenheiro/PCP, quero selecionar uma família construtiva existente e informar os parâmetros da placa (dimensões, geometria, material, acabamento, conteúdo técnico), para gerar uma configuração técnica específica sem criar um novo cadastro de produto. Critérios de aceite:  O sistema lista as famílias construtivas cadastradas com seus parâmetros obrigatórios.  Ao
- US-02: US02 — Como engenheiro/PCP, quero que o sistema explode automaticamente a BOM multinível a partir da configuração validada, para saber quais materiais e componentes serão necessários para fabricar a placa. Critérios de aceite:  A BOM gerada lista todos os itens/componentes necessários com quantidade calculada pela fórmula da família construtiva.  A BOM exibe a hierarquia m
- US-03: US03 — Como engenheiro/PCP, quero que o sistema gere o roteiro de fabricação (sequência de operações, setores e máquinas) a partir da configuração validada, para saber como a placa deve ser produzida. Critérios de aceite:  O roteiro lista as operações em sequência, indicando setor e tipo de máquina.  O roteiro é derivado das regras da família construtiva e dos parâmetros i
- US-04: US04 — Como PCP, quero congelar (versionar) a configuração técnica, a BOM e o roteiro em um snapshot no momento da liberação da demanda, para garantir que a produção sempre use a informação vigente na liberação, mesmo que a família construtiva mude depois. Critérios de aceite:  Ao liberar a demanda, o sistema cria um snapshot imutável contendo configuração, BOM e roteiro.
- US-05: US05 — Como engenheiro, quero cadastrar e versionar famílias construtivas com suas regras, fórmulas e roteiros parametrizados, para que novas demandas possam ser configuradas sem recriar a estrutura do zero. Critérios de aceite:  O cadastro permite definir parâmetros, regras de validação, fórmulas de BOM e template de roteiro.  Uma nova versão da família construtiva não so
- US-06: US06 — Como engenheiro, quero cadastrar e versionar normas técnicas de sinalização viária (tolerâncias, dimensões permitidas, padrões construtivos), para que as regras aplicadas às famílias construtivas tenham fonte e vigência rastreáveis. Critérios de aceite:  O cadastro de norma inclui fonte, vigência e conteúdo da regra.  A alteração de uma norma gera nova versão sem ap
- US-07: US07 — Como PCP, quero transformar um snapshot técnico congelado em uma ordem de produção, para iniciar o planejamento e a execução da fabricação daquela placa. Critérios de aceite:  A ordem de produção criada referencia unicamente o snapshot de origem.  A ordem recebe um status inicial (ex.: "aguardando material" ou "planejada").  A ordem possui identificador único e é r
- US-08: US08 — Como PCP, quero visualizar um painel com todas as ordens de produção, seus status (planejada, aguardando material, em produção, bloqueada, concluída) e prazos, para identificar rapidamente atrasos, gargalos e falta de material. Critérios de aceite:  O painel exibe todas as ordens ativas com status, prazo e responsável.  O painel permite filtrar por status, setor, má
- US-09: US09 — Como PCP, quero distribuir as operações de uma ordem de produção entre setores e máquinas específicas, para planejar a capacidade e a sequência de execução na fábrica. Critérios de aceite:  Cada operação do roteiro pode ser atribuída a um setor e uma máquina cadastrados.  O sistema impede a atribuição a máquina/setor sem capacidade cadastrada para o tipo de operação
- US-10: US10 — Como PCP, quero comparar o planejado versus o realizado de cada ordem (tempo, materiais, quantidade), para identificar desvios de produção. Critérios de aceite:  A tela exibe lado a lado os valores planejados (do snapshot/roteiro) e os valores realizados (apontados).  Os desvios são calculados automaticamente (diferença percentual ou absoluta).  A comparação está d
- US-11: US11 — Como almoxarife, quero reservar os materiais necessários para uma ordem de produção com base na BOM do snapshot, para garantir que os insumos estarão disponíveis antes do início da fabricação. Critérios de aceite:  O sistema reserva as quantidades exatas da BOM do snapshot para a ordem.  Se não houver saldo suficiente em estoque, a ordem é marcada como "aguardando m
- US-12: US12 — Como almoxarife, quero registrar a separação física dos materiais reservados para uma ordem, para confirmar que os insumos foram entregues ao setor de produção. Critérios de aceite:  O registro de separação indica item, quantidade separada e depósito de origem.  O sistema impede separar quantidade maior que a reservada.  A separação atualiza o status de disponibili
- US-13: US13 — Como almoxarife, quero consultar o saldo de estoque por item e por depósito, para saber a disponibilidade real de materiais antes de planejar novas ordens. Critérios de aceite:  A consulta exibe saldo disponível, reservado e físico por item e depósito.  A consulta permite filtrar por item, depósito ou categoria de material.  O saldo é atualizado a cada movimentação
- US-14: US14 — Como almoxarife, quero registrar entradas e saídas de estoque (recebimento, devolução, ajuste), para manter o saldo de materiais correto e rastreável. Critérios de aceite:  Cada movimentação registra item, quantidade, depósito, tipo de movimento e responsável.  Toda movimentação gera registro auditável com data/hora.  Movimentações feitas offline ficam pendentes at
- US-15: US15 — Como operador de produção, quero visualizar a próxima operação da ordem que devo executar, com as instruções do roteiro, para saber o que fazer sem precisar consultar outras fontes. Critérios de aceite:  A tela exibe a operação atual, as instruções do roteiro e os materiais associados.  A tela é otimizada para tablet/celular, com ações grandes.  Instruções já carre
- US-16: US16 — Como operador de produção, quero registrar o início e o fim de uma operação da ordem, para que o sistema saiba o status real de execução e o tempo gasto. Critérios de aceite:  O registro de início/fim fica associado à operação, ordem, máquina e operador responsável.  O sistema calcula automaticamente o tempo decorrido entre início e fim.  Apontamentos feitos offlin
- US-17: US17 — Como operador de produção, quero registrar o consumo real de materiais em uma operação, para que o sistema compare com o planejado na BOM. Critérios de aceite:  O registro de consumo indica item, quantidade consumida e operação/ordem associada.  O sistema não permite consumir mais do que o separado sem justificativa/aprovação.  O consumo real fica disponível para c
- US-18: US18 — Como operador de produção, quero bloquear uma ordem quando identificar um impedimento (falta de material, quebra de máquina, problema técnico), para sinalizar ao PCP que a produção está parada. Critérios de aceite:  O bloqueio exige motivo selecionado ou descrito.  A ordem bloqueada muda de status e fica visível no painel do PCP com destaque.  O histórico de bloque
- US-19: US19 — Como responsável pela qualidade, quero registrar uma inspeção vinculada a uma ordem/operação, com resultado aprovado ou reprovado, para garantir que apenas produtos conformes avancem no processo. Critérios de aceite:  A inspeção registra item/ordem, critério avaliado, resultado (aprovado/reprovado) e responsável.  Uma ordem reprovada em inspeção crítica não avança a
- US-20: US20 — Como operador de produção, quero registrar perdas de material ou produto durante uma operação, informando quantidade e motivo, para que o sistema mantenha o consumo real e as perdas rastreáveis por ordem. Critérios de aceite:  O registro de perda indica item, quantidade, motivo e operação/ordem associada.  Perdas registradas impactam o saldo de estoque reservado/con
- US-21: US21 — Como PCP, quero registrar e acompanhar o retrabalho de uma ordem (motivo, operação retrabalhada, tempo e materiais adicionais), para manter rastreabilidade completa de desvios de qualidade. Critérios de aceite:  O retrabalho é vinculado à ordem, à operação original e ao motivo.  O sistema registra tempo e materiais adicionais consumidos no retrabalho.  Ordens com r
- US-22: US22 — Como responsável pela expedição, quero visualizar as ordens concluídas e aprovadas em qualidade, prontas para expedição, para organizar a saída dos produtos. Critérios de aceite:  A lista exibe apenas ordens com status "concluída" e aprovadas em qualidade (quando houver inspeção crítica).  A lista permite filtrar por cliente, pedido ou prazo.  Ordens com aprovação
- US-23: US23 — Como responsável pela expedição, quero registrar a expedição de uma ordem (data, responsável, destino/cliente), para fechar a rastreabilidade da ordem do recebimento até a entrega. Critérios de aceite:  O registro de expedição associa ordem, data, responsável e cliente/pedido.  Após o registro, a ordem muda de status para "expedida" e não pode ser reaberta sem permi
- US-24: US24 — Como PCP ou direção, quero consultar o histórico completo de uma ordem (configuração, BOM, roteiro, apontamentos, perdas, retrabalho, qualidade, expedição), para saber exatamente o que foi fabricado, com quais insumos e em qual processo. Critérios de aceite:  A tela de detalhe consolida todos os eventos da ordem em ordem cronológica.  Cada evento exibe responsável,
- US-25: US25 — Como usuário do sistema, quero que toda alteração relevante (configuração, estoque, produção, qualidade) gere um registro de auditoria, para que ações possam ser investigadas posteriormente. Critérios de aceite:  Cada registro de auditoria contém usuário, ação, data/hora e dado alterado.  Registros de auditoria são somente leitura, sem opção de edição ou exclusão pe
- US-26: US26 — Como administrador da empresa, quero que usuários só acessem dados da própria empresa (tenant), para garantir isolamento multiempresa dos dados de produção. Critérios de aceite:  Um usuário autenticado não consegue visualizar ou modificar dados de outra empresa em nenhuma tela.  Tentativa de acesso a dado de outro tenant retorna erro de acesso negado (failclosed).
- US-27: US27 — Como administrador da empresa, quero definir perfis de acesso (PCP, engenharia, almoxarifado, operador, qualidade, expedição, compras, direção) com permissões específicas por módulo, para que cada usuário veja e registre apenas o que faz sentido para sua função. Critérios de aceite:  Cada perfil possui um conjunto de permissões de leitura/escrita por módulo.  Um usu
- US-28: US28 — Como usuário do sistema, quero fazer login autenticado e ter minha sessão controlada, para acessar o sistema de forma segura conforme meu perfil e empresa. Critérios de aceite:  O login exige credenciais válidas e associa a sessão a um usuário, uma empresa e um perfil.  A sessão expira após período de inatividade definido.  A falha de autenticação não expõe qual ca

## Design Plan aprovado antes do LionDesign

Este e o blueprint de produto para o artifact visual. O schema do design-contract e o Design Lock continuam tendo prioridade maxima.
Plano deterministico gerado pelo LionClaw; validacao deterministica: aprovada.


Telas planejadas:
- login (Login) — Autenticar usuario antes de acessar dados protegidos. — stories: US-01
- principal (Principal) — Executar as principais tarefas do produto usando dados das stories aprovadas. — stories: US-01, US-02, US-03, US-04, US-05, US-06, US-07, US-08, US-09, US-10, US-11, US-12, US-13, US-14, US-15, US-16, US-17, US-18, US-19, US-20, US-21, US-22, US-23, US-24, US-25, US-26, US-27, US-28

Navegacao planejada:
- Principal -> principal — stories: US-01, US-02, US-03, US-04, US-05, US-06, US-07, US-08, US-09, US-10, US-11, US-12, US-13, US-14, US-15, US-16, US-17, US-18, US-19, US-20, US-21, US-22, US-23, US-24, US-25, US-26, US-27, US-28

Vocabulario obrigatorio de dominio:
- dashboard
- registros
- configuracao

Copy proibida ou arriscada:
- acesse seu ambiente
- painel operacional
- eleve sua produtividade

Dados fake recomendados:
(nao declarado)

Instrucoes especificas para LionDesign:
- Gere uma SPA operacional, nao uma landing page.
- Use entidades concretas das user stories e evite copy generica.
- Nao escreva regras de negocio na tela; mostre apenas dados, estados, formularios e acoes.
- Gere os fluxos de todas as telas necessarias com navegacao clicavel.
- Arquivo unico index.html e permitido, mas telas empilhadas no scroll sao proibidas. Use [hidden] e JS real para mostrar apenas uma section por vez.

Cobertura planejada:
- US-01: principal — Cobertura deterministica.
- US-02: principal — Cobertura deterministica.
- US-03: principal — Cobertura deterministica.
- US-04: principal — Cobertura deterministica.
- US-05: principal — Cobertura deterministica.
- US-06: principal — Cobertura deterministica.
- US-07: principal — Cobertura deterministica.
- US-08: principal — Cobertura deterministica.
- US-09: principal — Cobertura deterministica.
- US-10: principal — Cobertura deterministica.
- US-11: principal — Cobertura deterministica.
- US-12: principal — Cobertura deterministica.
- US-13: principal — Cobertura deterministica.
- US-14: principal — Cobertura deterministica.
- US-15: principal — Cobertura deterministica.
- US-16: principal — Cobertura deterministica.
- US-17: principal — Cobertura deterministica.
- US-18: principal — Cobertura deterministica.
- US-19: principal — Cobertura deterministica.
- US-20: principal — Cobertura deterministica.
- US-21: principal — Cobertura deterministica.
- US-22: principal — Cobertura deterministica.
- US-23: principal — Cobertura deterministica.
- US-24: principal — Cobertura deterministica.
- US-25: principal — Cobertura deterministica.
- US-26: principal — Cobertura deterministica.
- US-27: principal — Cobertura deterministica.
- US-28: principal — Cobertura deterministica.

Regras para usar este plano:
- Use este plano como mapa operacional, nao como copy literal.
- Nao mostre este plano, JSON, criterios internos ou racional no HTML.
- O HTML final deve mostrar apenas a SPA funcional do produto.
- Nao gere landing page, hero, pitch comercial, galeria de telas ou secoes explicativas.
- Um index.html unico e permitido; telas empilhadas no scroll sao proibidas.
- Inclua CSS `[hidden] { display: none !important; }` e JS real para alternar qual `section` esta visivel.
- Login e app shell nunca podem coexistir visualmente. Ao submeter login, esconda login e mostre a primeira tela interna.
- Gere os fluxos de todas as telas necessarias com navegacao clicavel.
- Nao escreva regra de negocio, criterio de aceite ou contrato como texto visivel na UI.



### Como transformar stories em telas

- Agrupe stories por tarefa do usuario, entidade de dados e momento do fluxo.
- Crie o menor conjunto de telas necessario para cobrir as stories, mas inclua estados internos ricos dentro de cada tela.
- Para cada tela planejada, defina antes de codar: objetivo, stories cobertas, acoes primarias, estados, dados exibidos/editados e destino de navegacao.
- Telas comuns esperadas quando fizer sentido: autenticacao, dashboard/listagem principal, detalhe/edicao, criacao/configuracao, revisao/resultado, estado vazio/erro.
- Nao transforme cada user story em uma tela separada se elas pertencem ao mesmo fluxo.
- Nao esconda fluxos importantes em texto estatico. Use botoes, formularios, filtros, tabs ou navegacao real.
- Antes de salvar, faça uma autocritica severa: se a tela principal pudesse servir para qualquer SaaS trocando palavras, esta ruim. Reescreva para o dominio do projeto.

## Skill aplicada: Frontend de Alto Nivel (adaptada para LionDesign)

Esta skill e uma camada de craft visual. Ela NUNCA substitui escopo, contrato ou rastreabilidade por user stories.

Baseline ativo:
- DESIGN_VARIANCE: 8 — layouts assimetricos e memoraveis em desktop; mobile sempre colapsa para coluna unica sem scroll horizontal.
- MOTION_INTENSITY: 6 — microinteracoes e movimento fluido, mas sem comprometer performance.
- VISUAL_DENSITY: 4 — app web claro, arejado e usavel no dia a dia.

Regras de hierarquia:
1. Contract + Design Lock vencem qualquer decisao estetica.
2. Cobertura de user stories vence qualquer ideia visual.
3. Cada tela, navegacao, acao, dado e API precisa declarar userStoryIds reais.
4. Elementos sem rastreio entram em deltas[]; nao viram escopo final escondido.

Direcao de frontend:
- Evite UI generica de IA: nada de roxo/azul neon, blobs decorativos, H1 central gigante, 3 cards iguais, nomes falsos tipo Joao da Silva/Maria Santos, numeros redondos tipo 99,99%.
- Para software/dashboard, use sans-serif premium e limpa; nao use serif; nao use preto puro; use off-black/zinc ou base clara refinada.
- Maximo 1 cor de acento, dessaturada e consistente.
- Priorize telas funcionais sobre landing page. O produto deve parecer utilizavel, nao uma peca de marketing.
- Formulario: label acima, helper text na marcacao, erro abaixo do input, estados loading/empty/error/success/disabled quando aplicavel.
- Use grid e agrupamento logico; cards so quando comunicam hierarquia real.
- Motion apenas com transform/opacity; nada de animar top/left/width/height; loops ou efeitos pesados devem ser isolados.

Adaptacao ao artifact HTML do LionDesign:
- Gere HTML standalone clicavel. Nao importe React/Next/Tailwind/Framer a menos que o runtime do OD ja esteja explicitamente usando isso.
- Se precisar de icones, use SVG limpo inline. Emojis sao proibidos no HTML, labels e alt text.
- Aplique o espirito da skill no HTML/CSS/JS final: assimetria controlada, composicao premium, estados completos e interacoes reais.

## Fontes originais para conferencia

As fontes abaixo sao referencia de escopo. Nao copie blocos inteiros para a UI; extraia telas, estados, dados e acoes.

### Discovery

# Discovery Notes

## Visao

### Problema
Hoje a fabricação de sinalização vertical depende de informações espalhadas entre projetos, planilhas, fichas, estoque e comunicação manual. Isso dificulta saber exatamente o que deve ser fabricado, com quais materiais, em qual sequência, usando qual máquina, e quanto foi realmente consumido ou perdido. O problema fica maior porque muitas placas não são produtos repetitivos: a estrutura construtiva se repete, mas dimensões, geometria, conteúdo gráfico e composição podem variar. O ViaFab deve transformar cada demanda em uma configuração técnica e uma ordem de produção rastreável, resolvendo BOM, roteiro, materiais, operações, qualidade, perdas e expedição sem criar um cadastro infinito de produtos. Também deve preservar revisões e histórico para evitar fabricar com informação desatualizada. A integração com o ViaSign poderá alimentar demandas técnicas versionadas no futuro, mas o ViaFab precisa funcionar como ERP de fábrica por si só.

### Usuario principal
O usuário principal é o responsável pela produção e pelo planejamento da fábrica, normalmente um gerente de produção/engenharia ou PCP. Ele recebe as demandas comerciais e técnicas, confere se estão fabricáveis, define ou valida a configuração construtiva, explode a BOM, planeja materiais e operações, distribui as ordens entre setores e máquinas e acompanha prazo, gargalos, perdas e retrabalho. Hoje ele precisa consolidar informações de várias fontes e depende muito de conhecimento tácito da equipe, então o sistema deve dar uma visão confiável do que está planejado, em produção, aguardando material, bloqueado ou concluído. Os usuários secundários são engenharia, almoxarifado, operadores de produção, qualidade, expedição, compras e direção. Cada perfil precisa enxergar e registrar apenas o que faz sentido para sua etapa, mantendo u

... (discovery compactado — 7929 chars omitidos; use como fonte de conferencia, nao como copy literal) ...

ema não apaga o histórico quando uma regra muda.
- Estoque, produção, qualidade, perdas, retrabalho e expedição são auditáveis, com rastreabilidade de revisão e consumo real. Segurança, permissões multiempresa, LGPD e fail-closed são requisitos transversais.
- O sistema é agent-ready na estrutura e nos contratos, mas automação por agentes não faz parte do MVP. Primeiro a operação humana precisa ser correta, observável e confiável.
Não há prazo artificial definido nesta etapa. A prioridade é desenhar o domínio certo antes de schema e implementação.

Distinção entre fundamentos arquiteturais e escopo de entrega do MVP: versionamento de normas, catálogo de regras construtivas, auditoria, multiempresa e contratos agent-ready devem orientar a arquitetura desde o início, mas o MVP entrega primeiro o ciclo operacional confiável de configuração, snapshot, planejamento, estoque, produção, qualidade e expedição. Monetização, integração com máquinas, offline completo e automação por agentes não ampliam o escopo do MVP.

### User Stories e Requisitos aprovados

# User Stories e Requisitos — ViaFab

Documento gerado a partir do discovery do ViaFab (ERP de fábrica verticalizado para sinalização viária). Cada user story indica, quando aplicável, o padrão de interface esperado, para orientar a fase de design.

---

## 1. User Stories

### 1.1 Configuração Técnica e Engenharia

**US-01** — Como engenheiro/PCP, quero selecionar uma família construtiva existente e informar os parâmetros da placa (dimensões, geometria, material, acabamento, conteúdo técnico), para gerar uma configuração técnica específica sem criar um novo cadastro de produto.
Critérios de aceite:
- O sistema lista as famílias construtivas cadastradas com seus parâmetros obrigatórios.
- Ao informar todos os parâmetros obrigatórios, o sistema valida os valores contra as regras da família construtiva vigente.
- Se algum parâmetro violar uma regra ou tolerância, o sistema bloqueia o avanço e exibe qual regra foi violada.
- A configuração gerada fica vinculada à família construtiva de origem e aos parâmetros informados.
Padrão de interface sugerido: formulário multi-etapas (wizard) + tela de detalhe da configuração gerada.

**US-02** — Como engenheiro/PCP, quero que o sistema explode automaticamente a BOM multinível a partir da configuração validada, para saber quais materiais e componentes serão necessários para fabricar a placa.
Critérios de aceite:
- A BOM gerada lista todos os itens/componentes necessários com quantidade calculada pela fórmula da família construtiva.
- A BOM exibe a hierarquia multinível (componente pai/filho).
- A BOM fica vinculada à configuração técnica específica que a originou.
Padrão de interface sugerido: tela de detalhe com lista hierárquica (árvore).

**US-03** — Como engenheiro/PCP, quero que o sistema gere o roteiro de fabricação (sequência de operações, setores e máquinas) a partir da configur

... (stories-requisitos compactado — 24128 chars omitidos; use como fonte de conferencia, nao como copy literal) ...

icar em estado explícito de "pendente de sincronização", só sendo confirmados após sincronização bem-sucedida, com garantia de idempotência e resolução de conflito. Relacionado a US-14, US-16, US-17.
- **RNF-12**: Nenhum movimento crítico de estoque (reserva, separação, consumo) deve ser confirmado silenciosamente quando realizado em modo offline; o usuário deve ser informado do estado pendente. Relacionado a US-11, US-12, US-17.
- **RNF-13**: Snapshots técnicos (configuração, BOM, roteiro) congelados para uma ordem de produção não podem ser alterados após sua criação. Relacionado a US-04.
- **RNF-14**: Alterações em famílias construtivas ou normas técnicas devem gerar novas versões, sem apagar ou sobrescrever versões e histórico anteriores. Relacionado a US-05, US-06.
- **RNF-15**: Registros de histórico e auditoria de uma ordem devem ser preservados de forma permanente e não editável, garantindo rastreabilidade completa do que foi fabricado, com quais insumos e em qual processo. Relacionado a US-24, US-25.

## Notas adicionais do PRD Validator

(prd-validator ausente)

## Design System

- (nenhum design system selecionado — usar default coerente com o briefing)

## Configuracao da sessao (somente metadados — nao contem credenciais)

```json
{
  "agentId": "configured-in-open-design-studio",
  "model": "configured-in-open-design-studio",
  "reasoning": null,
  "designSystemId": null,
  "memoryEnabled": false,
  "mcpServerIds": [],
  "locale": "pt-BR"
}
```

## Entrega esperada

- **SPA multi-tela** seguindo o "Formato OBRIGATORIO" acima — um `<section>` por screen, um visivel por vez, transicoes por interacao real.
- `index.html` standalone unico e permitido; telas empilhadas no scroll sao proibidas.
- Bloco `lionclaw-design-contract` embutido no HTML EXATAMENTE no shape definido abaixo.
- Texto e copy em pt-BR **dentro das telas funcionais** — sem prose marketing, sem hero copy editorial, sem "## Sobre o produto", sem pitch.

Se uma user story exigir interpretacao, use o contexto disponivel, registre a decisao em `deltas[]` quando necessario e continue. Nao bloqueie a entrega com perguntas de briefing visual.

## Schema OBRIGATORIO do bloco `lionclaw-design-contract`

Este JSON eh consumido pelo validator do LionClaw. **Qualquer campo extra eh permitido, mas TODOS os campos abaixo sao obrigatorios** — sem isso o Design Lock rejeita.

```html
<script type="application/json" id="lionclaw-design-contract">
{
  "version": "1.0",
  "visual": {
    "direction": "string descritiva da direcao visual (ex: 'software dark utilitario com acento amber')",
    "density": "dense | balanced | editorial | mobile-first | unknown",
    "tokens": {
      "colors": { "bg": "#09090b", "accent": "#d97706", "...": "..." },
      "typography": { "display": "Geist", "body": "Satoshi", "...": "..." },
      "spacing": { "xs": "4px", "sm": "8px", "...": "..." },
      "radii": { "sm": "4px", "md": "8px", "...": "..." }
    }
  },
  "navigation": {
    "primary": [
      { "id": "nav-play", "label": "Jogar", "targetScreenId": "play", "userStoryIds": ["US-02"] }
    ],
    "secondary": []
  },
  "screens": [
    {
      "id": "login",
      "userStoryIds": ["US-01"],
      "title": "Login",
      "route": "#login",
      "purpose": "Autenticar usuario",
      "states": ["loading", "error", "success"],
      "actions": [
        { "id": "action-login", "label": "Entrar", "type": "submit", "userStoryIds": ["US-01"], "apiExpectationIds": ["api-login"] }
      ],
      "dataRequirementIds": ["data-user-login"]
    }
  ],
  "components": [
    { "id": "btn-primary", "name": "Botao primario", "type": "form", "usedInScreenIds": ["login"], "props": {}, "states": [] }
  ],
  "dataRequirements": [
    {
      "id": "data-user-login",
      "name": "Credenciais de login",
      "description": "Dados informados pelo usuario para autenticacao",
      "fields": [
        { "name": "email", "typeHint": "string", "required": true },
        { "name": "password", "typeHint": "string", "required": true }
      ],
      "sourceScreenIds": ["login"],
      "userStoryIds": ["US-01"]
    }
  ],
  "apiExpectations": [
    {
      "id": "api-login",
      "operation": "POST /auth/login",
      "screenIds": ["login"],
      "actionIds": ["action-login"],
      "methodHint": "POST",
      "requestShape": { "email": "string", "password": "string" },
      "responseShape": { "token": "string" },
      "userStoryIds": ["US-01"]
    }
  ],
  "deltas": [
    {
      "id": "delta-001",
      "type": "unclear",
      "description": "explicacao do delta",
      "impact": "low",
      "relatedUserStoryIds": [],
      "requiresRequirementsChange": false
    }
  ]
}
</script>
```

**Regras criticas:**
- `version` deve ser literalmente `"1.0"`.
- Cada `screens[]`, `navigation.primary[]` e `dataRequirements[]`/`apiExpectations[]` referencia user stories por `userStoryIds: string[]` (use os IDs reais do briefing, ex: `"US-01"`).
- Cada `apiExpectations[]` precisa declarar `screenIds: string[]`, `actionIds: string[]` e `userStoryIds: string[]`, mesmo que algum deles seja `[]`.
- Cada `dataRequirements[]` precisa declarar `fields[]`, `sourceScreenIds: string[]` e `userStoryIds: string[]`.
- Telas/componentes/dados/APIs SEM user story listada → registrar como `deltas[]` com `description` explicando por que existe.
- `components[]`, `apiExpectations[]`, `dataRequirements[]` e `deltas[]` exigem `id: string` unico.
- `deltas[]` exige `type`, `description`, `impact`, `relatedUserStoryIds` e `requiresRequirementsChange`.
- Use os 4 grupos de tokens (`colors`, `typography`, `spacing`, `radii`) mesmo que parcialmente vazios — eles sao obrigatorios na estrutura.

Campos adicionais ao schema (ex: `project`, `design_system`, `acceptance_criteria_visualized`) sao tolerados, mas os campos acima nao podem faltar.
