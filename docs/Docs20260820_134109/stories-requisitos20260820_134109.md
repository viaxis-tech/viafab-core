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

**US-03** — Como engenheiro/PCP, quero que o sistema gere o roteiro de fabricação (sequência de operações, setores e máquinas) a partir da configuração validada, para saber como a placa deve ser produzida.
Critérios de aceite:
- O roteiro lista as operações em sequência, indicando setor e tipo de máquina.
- O roteiro é derivado das regras da família construtiva e dos parâmetros informados na configuração.
- O roteiro fica vinculado à mesma configuração técnica que originou a BOM.
Padrão de interface sugerido: lista sequencial / linha do tempo (timeline).

**US-04** — Como PCP, quero congelar (versionar) a configuração técnica, a BOM e o roteiro em um snapshot no momento da liberação da demanda, para garantir que a produção sempre use a informação vigente na liberação, mesmo que a família construtiva mude depois.
Critérios de aceite:
- Ao liberar a demanda, o sistema cria um snapshot imutável contendo configuração, BOM e roteiro.
- O snapshot recebe identificador único e timestamp de criação.
- Alterações posteriores na família construtiva não alteram snapshots já congelados.
Padrão de interface sugerido: tela de confirmação/detalhe somente leitura do snapshot.

**US-05** — Como engenheiro, quero cadastrar e versionar famílias construtivas com suas regras, fórmulas e roteiros parametrizados, para que novas demandas possam ser configuradas sem recriar a estrutura do zero.
Critérios de aceite:
- O cadastro permite definir parâmetros, regras de validação, fórmulas de BOM e template de roteiro.
- Uma nova versão da família construtiva não sobrescreve nem apaga versões anteriores.
- Cada versão possui vigência (data de início) e histórico consultável.
Padrão de interface sugerido: formulário estruturado + lista de versões (histórico).

**US-06** — Como engenheiro, quero cadastrar e versionar normas técnicas de sinalização viária (tolerâncias, dimensões permitidas, padrões construtivos), para que as regras aplicadas às famílias construtivas tenham fonte e vigência rastreáveis.
Critérios de aceite:
- O cadastro de norma inclui fonte, vigência e conteúdo da regra.
- A alteração de uma norma gera nova versão sem apagar a anterior.
- Configurações técnicas geradas referenciam a versão da norma vigente no momento da validação.
Padrão de interface sugerido: formulário + lista/histórico de versões.

### 1.2 Planejamento de Produção (PCP)

**US-07** — Como PCP, quero transformar um snapshot técnico congelado em uma ordem de produção, para iniciar o planejamento e a execução da fabricação daquela placa.
Critérios de aceite:
- A ordem de produção criada referencia unicamente o snapshot de origem.
- A ordem recebe um status inicial (ex.: "aguardando material" ou "planejada").
- A ordem possui identificador único e é rastreável até o snapshot e a demanda de origem.
Padrão de interface sugerido: formulário de criação + tela de detalhe da ordem.

**US-08** — Como PCP, quero visualizar um painel com todas as ordens de produção, seus status (planejada, aguardando material, em produção, bloqueada, concluída) e prazos, para identificar rapidamente atrasos, gargalos e falta de material.
Critérios de aceite:
- O painel exibe todas as ordens ativas com status, prazo e responsável.
- O painel permite filtrar por status, setor, máquina e prazo.
- Ordens atrasadas ou bloqueadas são destacadas visualmente com indicador objetivo (ex.: dias de atraso).
Padrão de interface sugerido: dashboard com tabela/lista filtrável e indicadores de status.

**US-09** — Como PCP, quero distribuir as operações de uma ordem de produção entre setores e máquinas específicas, para planejar a capacidade e a sequência de execução na fábrica.
Critérios de aceite:
- Cada operação do roteiro pode ser atribuída a um setor e uma máquina cadastrados.
- O sistema impede a atribuição a máquina/setor sem capacidade cadastrada para o tipo de operação.
- A distribuição fica registrada e visível na ordem de produção.
Padrão de interface sugerido: tela de detalhe com formulário de atribuição + visão de agenda/calendário por máquina.

**US-10** — Como PCP, quero comparar o planejado versus o realizado de cada ordem (tempo, materiais, quantidade), para identificar desvios de produção.
Critérios de aceite:
- A tela exibe lado a lado os valores planejados (do snapshot/roteiro) e os valores realizados (apontados).
- Os desvios são calculados automaticamente (diferença percentual ou absoluta).
- A comparação está disponível por ordem individual.
Padrão de interface sugerido: tela de detalhe/comparação (tabela dupla).

### 1.3 Estoque e Almoxarifado

**US-11** — Como almoxarife, quero reservar os materiais necessários para uma ordem de produção com base na BOM do snapshot, para garantir que os insumos estarão disponíveis antes do início da fabricação.
Critérios de aceite:
- O sistema reserva as quantidades exatas da BOM do snapshot para a ordem.
- Se não houver saldo suficiente em estoque, a ordem é marcada como "aguardando material".
- A reserva fica vinculada à ordem de produção e não pode ser usada por outra ordem simultaneamente.
Padrão de interface sugerido: tela de detalhe da ordem + lista de materiais reservados.

**US-12** — Como almoxarife, quero registrar a separação física dos materiais reservados para uma ordem, para confirmar que os insumos foram entregues ao setor de produção.
Critérios de aceite:
- O registro de separação indica item, quantidade separada e depósito de origem.
- O sistema impede separar quantidade maior que a reservada.
- A separação atualiza o status de disponibilidade de material da ordem.
Padrão de interface sugerido: formulário/checklist de separação, otimizado para tablet.

**US-13** — Como almoxarife, quero consultar o saldo de estoque por item e por depósito, para saber a disponibilidade real de materiais antes de planejar novas ordens.
Critérios de aceite:
- A consulta exibe saldo disponível, reservado e físico por item e depósito.
- A consulta permite filtrar por item, depósito ou categoria de material.
- O saldo é atualizado a cada movimentação confirmada.
Padrão de interface sugerido: lista/tabela filtrável.

**US-14** — Como almoxarife, quero registrar entradas e saídas de estoque (recebimento, devolução, ajuste), para manter o saldo de materiais correto e rastreável.
Critérios de aceite:
- Cada movimentação registra item, quantidade, depósito, tipo de movimento e responsável.
- Toda movimentação gera registro auditável com data/hora.
- Movimentações feitas offline ficam pendentes até sincronização e confirmação, sem serem aplicadas silenciosamente ao saldo.
Padrão de interface sugerido: formulário de movimentação + lista de histórico.

### 1.4 Execução de Produção (Chão de Fábrica)

**US-15** — Como operador de produção, quero visualizar a próxima operação da ordem que devo executar, com as instruções do roteiro, para saber o que fazer sem precisar consultar outras fontes.
Critérios de aceite:
- A tela exibe a operação atual, as instruções do roteiro e os materiais associados.
- A tela é otimizada para tablet/celular, com ações grandes.
- Instruções já carregadas continuam visíveis mesmo sem conexão.
Padrão de interface sugerido: tela simples de "próxima operação" com ações grandes (padrão chão de fábrica).

**US-16** — Como operador de produção, quero registrar o início e o fim de uma operação da ordem, para que o sistema saiba o status real de execução e o tempo gasto.
Critérios de aceite:
- O registro de início/fim fica associado à operação, ordem, máquina e operador responsável.
- O sistema calcula automaticamente o tempo decorrido entre início e fim.
- Apontamentos feitos offline ficam marcados como "pendentes de sincronização", sem confirmação silenciosa do movimento.
Padrão de interface sugerido: formulário simples (botões iniciar/finalizar) em tela mobile/tablet.

**US-17** — Como operador de produção, quero registrar o consumo real de materiais em uma operação, para que o sistema compare com o planejado na BOM.
Critérios de aceite:
- O registro de consumo indica item, quantidade consumida e operação/ordem associada.
- O sistema não permite consumir mais do que o separado sem justificativa/aprovação.
- O consumo real fica disponível para comparação planejado x realizado.
Padrão de interface sugerido: formulário simples em tela mobile/tablet.

**US-18** — Como operador de produção, quero bloquear uma ordem quando identificar um impedimento (falta de material, quebra de máquina, problema técnico), para sinalizar ao PCP que a produção está parada.
Critérios de aceite:
- O bloqueio exige motivo selecionado ou descrito.
- A ordem bloqueada muda de status e fica visível no painel do PCP com destaque.
- O histórico de bloqueio (quem, quando, motivo, duração) fica registrado na ordem.
Padrão de interface sugerido: formulário simples + indicador de status na tela da ordem.

### 1.5 Qualidade

**US-19** — Como responsável pela qualidade, quero registrar uma inspeção vinculada a uma ordem/operação, com resultado aprovado ou reprovado, para garantir que apenas produtos conformes avancem no processo.
Critérios de aceite:
- A inspeção registra item/ordem, critério avaliado, resultado (aprovado/reprovado) e responsável.
- Uma ordem reprovada em inspeção crítica não avança automaticamente para a próxima etapa/expedição.
- O histórico de inspeções fica vinculado à ordem e consultável posteriormente.
Padrão de interface sugerido: formulário de inspeção + lista/histórico de inspeções.

### 1.6 Perdas e Retrabalho

**US-20** — Como operador de produção, quero registrar perdas de material ou produto durante uma operação, informando quantidade e motivo, para que o sistema mantenha o consumo real e as perdas rastreáveis por ordem.
Critérios de aceite:
- O registro de perda indica item, quantidade, motivo e operação/ordem associada.
- Perdas registradas impactam o saldo de estoque reservado/consumido da ordem.
- Perdas ficam disponíveis para consulta por ordem, item e período.
Padrão de interface sugerido: formulário simples em tela mobile/tablet.

**US-21** — Como PCP, quero registrar e acompanhar o retrabalho de uma ordem (motivo, operação retrabalhada, tempo e materiais adicionais), para manter rastreabilidade completa de desvios de qualidade.
Critérios de aceite:
- O retrabalho é vinculado à ordem, à operação original e ao motivo.
- O sistema registra tempo e materiais adicionais consumidos no retrabalho.
- Ordens com retrabalho ficam sinalizadas no painel do PCP.
Padrão de interface sugerido: formulário de registro + indicador na tela de detalhe da ordem.

### 1.7 Expedição

**US-22** — Como responsável pela expedição, quero visualizar as ordens concluídas e aprovadas em qualidade, prontas para expedição, para organizar a saída dos produtos.
Critérios de aceite:
- A lista exibe apenas ordens com status "concluída" e aprovadas em qualidade (quando houver inspeção crítica).
- A lista permite filtrar por cliente, pedido ou prazo.
- Ordens com aprovação de qualidade pendente não aparecem como prontas para expedir.
Padrão de interface sugerido: lista/tabela filtrável.

**US-23** — Como responsável pela expedição, quero registrar a expedição de uma ordem (data, responsável, destino/cliente), para fechar a rastreabilidade da ordem do recebimento até a entrega.
Critérios de aceite:
- O registro de expedição associa ordem, data, responsável e cliente/pedido.
- Após o registro, a ordem muda de status para "expedida" e não pode ser reaberta sem permissão específica.
- A ordem expedida mantém o link para todo o histórico (snapshot, BOM, roteiro, apontamentos, qualidade).
Padrão de interface sugerido: formulário de registro + tela de detalhe/histórico consolidado.

### 1.8 Rastreabilidade e Auditoria

**US-24** — Como PCP ou direção, quero consultar o histórico completo de uma ordem (configuração, BOM, roteiro, apontamentos, perdas, retrabalho, qualidade, expedição), para saber exatamente o que foi fabricado, com quais insumos e em qual processo.
Critérios de aceite:
- A tela de detalhe consolida todos os eventos da ordem em ordem cronológica.
- Cada evento exibe responsável, data/hora e tipo de ação.
- O histórico não pode ser editado ou apagado por nenhum perfil de usuário.
Padrão de interface sugerido: tela de detalhe com linha do tempo/histórico consolidado.

**US-25** — Como usuário do sistema, quero que toda alteração relevante (configuração, estoque, produção, qualidade) gere um registro de auditoria, para que ações possam ser investigadas posteriormente.
Critérios de aceite:
- Cada registro de auditoria contém usuário, ação, data/hora e dado alterado.
- Registros de auditoria são somente leitura, sem opção de edição ou exclusão pela interface.
- A consulta de auditoria pode ser filtrada por usuário, entidade e período.
Padrão de interface sugerido: lista/tabela filtrável (tela de auditoria).

### 1.9 Segurança e Multiempresa

**US-26** — Como administrador da empresa, quero que usuários só acessem dados da própria empresa (tenant), para garantir isolamento multiempresa dos dados de produção.
Critérios de aceite:
- Um usuário autenticado não consegue visualizar ou modificar dados de outra empresa em nenhuma tela.
- Tentativa de acesso a dado de outro tenant retorna erro de acesso negado (fail-closed).
- O isolamento entre tenants é validado por testes automatizados.
Padrão de interface sugerido: regra transversal, sem tela própria — aplica-se a todas as telas.

**US-27** — Como administrador da empresa, quero definir perfis de acesso (PCP, engenharia, almoxarifado, operador, qualidade, expedição, compras, direção) com permissões específicas por módulo, para que cada usuário veja e registre apenas o que faz sentido para sua função.
Critérios de aceite:
- Cada perfil possui um conjunto de permissões de leitura/escrita por módulo.
- Um usuário sem permissão para uma ação não visualiza a opção correspondente na interface.
- Alterações de permissões de perfil são registradas em auditoria.
Padrão de interface sugerido: tela de gestão de usuários/perfis (formulário + lista).

**US-28** — Como usuário do sistema, quero fazer login autenticado e ter minha sessão controlada, para acessar o sistema de forma segura conforme meu perfil e empresa.
Critérios de aceite:
- O login exige credenciais válidas e associa a sessão a um usuário, uma empresa e um perfil.
- A sessão expira após período de inatividade definido.
- A falha de autenticação não expõe qual campo (usuário ou senha) está incorreto.
Padrão de interface sugerido: tela de login (formulário).

---

## 2. Requisitos Funcionais

### 2.1 Configuração Técnica e Engenharia
- **RF-01**: O sistema deve permitir selecionar uma família construtiva cadastrada e informar seus parâmetros (dimensões, geometria, materiais, acabamento, conteúdo técnico) para gerar uma configuração técnica específica. Relacionado a US-01.
- **RF-02**: O sistema deve validar os parâmetros informados contra as regras e tolerâncias vigentes da família construtiva e das normas técnicas associadas, bloqueando o avanço quando houver violação. Relacionado a US-01, US-06.
- **RF-03**: O sistema deve explodir automaticamente a BOM multinível de uma configuração técnica validada, calculando quantidades pela fórmula definida na família construtiva. Relacionado a US-02.
- **RF-04**: O sistema deve gerar automaticamente o roteiro de fabricação (sequência de operações, setores e máquinas) a partir da configuração técnica validada. Relacionado a US-03.
- **RF-05**: O sistema deve permitir congelar a configuração técnica, a BOM e o roteiro em um snapshot imutável no momento da liberação da demanda para produção. Relacionado a US-04.
- **RF-06**: O sistema deve permitir cadastrar e versionar famílias construtivas, incluindo parâmetros, regras de validação, fórmulas de BOM e template de roteiro. Relacionado a US-05.
- **RF-07**: O sistema deve permitir cadastrar e versionar normas técnicas de sinalização viária, registrando fonte e vigência de cada versão. Relacionado a US-06.
- **RF-08**: O sistema deve manter o histórico de todas as versões de famílias construtivas e normas técnicas, sem permitir exclusão. Relacionado a US-05, US-06.

### 2.2 Planejamento de Produção (PCP)
- **RF-09**: O sistema deve permitir criar uma ordem de produção a partir de um snapshot técnico congelado, associando-a ao snapshot e à demanda de origem. Relacionado a US-07.
- **RF-10**: O sistema deve atribuir automaticamente um status inicial à ordem de produção conforme a disponibilidade de material. Relacionado a US-07, US-11.
- **RF-11**: O sistema deve exibir um painel com todas as ordens de produção, seus status, prazos e responsáveis, permitindo filtro por status, setor, máquina e prazo. Relacionado a US-08.
- **RF-12**: O sistema deve destacar visualmente ordens atrasadas ou bloqueadas no painel de PCP, indicando o tempo de atraso ou bloqueio. Relacionado a US-08, US-18.
- **RF-13**: O sistema deve permitir atribuir cada operação do roteiro de uma ordem a um setor e uma máquina cadastrados, validando a existência de capacidade cadastrada para o tipo de operação. Relacionado a US-09.
- **RF-14**: O sistema deve permitir comparar valores planejados (do snapshot) e valores realizados (apontados) de tempo, materiais e quantidade por ordem de produção. Relacionado a US-10.

### 2.3 Estoque e Almoxarifado
- **RF-15**: O sistema deve permitir reservar os materiais de uma ordem de produção com base nas quantidades da BOM do snapshot associado. Relacionado a US-11.
- **RF-16**: O sistema deve impedir que uma mesma unidade de material reservada seja utilizada simultaneamente por mais de uma ordem de produção. Relacionado a US-11.
- **RF-17**: O sistema deve alterar o status da ordem para "aguardando material" quando não houver saldo suficiente para atender à reserva da BOM. Relacionado a US-07, US-11.
- **RF-18**: O sistema deve permitir registrar a separação física dos materiais reservados de uma ordem, impedindo separação de quantidade superior à reservada. Relacionado a US-12.
- **RF-19**: O sistema deve permitir consultar o saldo de estoque (disponível, reservado e físico) por item e por depósito. Relacionado a US-13.
- **RF-20**: O sistema deve permitir registrar movimentações de estoque (entrada, saída, devolução, ajuste), associando item, quantidade, depósito, tipo de movimento e responsável. Relacionado a US-14.

### 2.4 Execução de Produção
- **RF-21**: O sistema deve exibir ao operador a próxima operação de uma ordem, com as instruções do roteiro e os materiais associados. Relacionado a US-15.
- **RF-22**: O sistema deve permitir registrar o início e o fim de uma operação, calculando automaticamente o tempo decorrido entre os dois eventos. Relacionado a US-16.
- **RF-23**: O sistema deve permitir registrar o consumo real de materiais em uma operação, associando-o à ordem e permitindo comparação posterior com a BOM planejada. Relacionado a US-17.
- **RF-24**: O sistema deve impedir o registro de consumo de material acima da quantidade separada sem justificativa/aprovação explícita. Relacionado a US-17.
- **RF-25**: O sistema deve permitir registrar o bloqueio de uma ordem de produção, exigindo motivo, e alterar o status da ordem de forma visível ao PCP. Relacionado a US-18.

### 2.5 Qualidade
- **RF-26**: O sistema deve permitir registrar inspeções de qualidade vinculadas a uma ordem/operação, com critério avaliado, resultado (aprovado/reprovado) e responsável. Relacionado a US-19.
- **RF-27**: O sistema deve impedir que uma ordem reprovada em inspeção crítica de qualidade avance automaticamente para expedição. Relacionado a US-19, US-22.

### 2.6 Perdas e Retrabalho
- **RF-28**: O sistema deve permitir registrar perdas de material ou produto em uma operação, associando item, quantidade, motivo e ordem. Relacionado a US-20.
- **RF-29**: O sistema deve permitir registrar retrabalho de uma ordem, associando motivo, operação original, tempo gasto e materiais adicionais consumidos. Relacionado a US-21.
- **RF-30**: O sistema deve sinalizar no painel do PCP as ordens que possuam registro de retrabalho ou perda associado. Relacionado a US-08, US-20, US-21.

### 2.7 Expedição
- **RF-31**: O sistema deve listar ordens concluídas e aprovadas em qualidade como prontas para expedição, permitindo filtro por cliente, pedido e prazo. Relacionado a US-22.
- **RF-32**: O sistema deve permitir registrar a expedição de uma ordem, associando data, responsável e cliente/pedido, e alterar o status da ordem para "expedida". Relacionado a US-23.
- **RF-33**: O sistema deve impedir a reabertura de uma ordem expedida sem permissão específica de perfil autorizado. Relacionado a US-23, US-27.

### 2.8 Rastreabilidade e Auditoria
- **RF-34**: O sistema deve consolidar em uma tela de histórico todos os eventos de uma ordem (configuração, BOM, roteiro, apontamentos, perdas, retrabalho, qualidade, expedição) em ordem cronológica. Relacionado a US-24.
- **RF-35**: O sistema deve registrar automaticamente em log de auditoria toda alteração relevante em configuração, estoque, produção e qualidade, contendo usuário, ação e data/hora. Relacionado a US-25.
- **RF-36**: O sistema não deve permitir edição ou exclusão de registros de histórico ou auditoria por nenhum perfil de usuário via interface. Relacionado a US-24, US-25.

### 2.9 Segurança e Multiempresa
- **RF-37**: O sistema deve isolar os dados por empresa (tenant), impedindo que um usuário visualize ou modifique dados de empresa diferente da sua. Relacionado a US-26.
- **RF-38**: O sistema deve permitir definir perfis de acesso por módulo (PCP, engenharia, almoxarifado, operador, qualidade, expedição, compras, direção), controlando permissões de leitura e escrita. Relacionado a US-27.
- **RF-39**: O sistema deve ocultar da interface as opções e ações para as quais o usuário autenticado não possui permissão. Relacionado a US-27.
- **RF-40**: O sistema deve exigir autenticação por credenciais válidas para acesso, associando a sessão a um usuário, uma empresa e um perfil. Relacionado a US-28.

---

## 3. Requisitos Não-Funcionais

### 3.1 Performance
- **RNF-01**: O tempo de resposta de consultas e listagens de uso frequente (ordens de produção, saldo de estoque, painel do PCP) deve ser inferior a 2 segundos em 95% das requisições sob carga normal de uso.
- **RNF-02**: A explosão de BOM e a geração do roteiro a partir de uma configuração técnica validada devem ser concluídas em até 5 segundos para famílias construtivas de complexidade padrão.

### 3.2 Segurança
- **RNF-03**: Todo acesso a dados deve respeitar o isolamento multiempresa (multi-tenant) via controle de acesso a nível de linha (RLS), com falha padrão de acesso negado (fail-closed) quando a permissão não puder ser verificada. Relacionado a US-26.
- **RNF-04**: A autenticação de usuários deve usar mecanismo seguro de sessão, com expiração por inatividade e sem exposição de qual campo (usuário ou senha) está incorreto em caso de falha de login. Relacionado a US-28.
- **RNF-05**: Dados pessoais tratados pelo sistema devem seguir princípios de proteção de dados (LGPD), incluindo minimização de coleta e controle de acesso por perfil.
- **RNF-06**: Toda ação de criação, alteração ou exclusão em entidades críticas (configuração, estoque, produção, qualidade, expedição) deve gerar registro de auditoria imutável, contendo usuário, ação, data/hora e dado alterado. Relacionado a US-25.

### 3.3 Usabilidade
- **RNF-07**: As telas destinadas a operadores de chão de fábrica (produção, qualidade, expedição) devem ser responsivas e utilizáveis em tablet e celular, com áreas de toque adequadas ao uso em ambiente industrial. Relacionado a US-15, US-16, US-17.
- **RNF-08**: O painel do PCP deve permitir identificar ordens atrasadas, bloqueadas ou com falta de material diretamente na listagem principal, sem navegação adicional. Relacionado a US-08.
- **RNF-09**: Mensagens de erro e validação devem indicar de forma objetiva e específica qual regra foi violada ou qual campo é obrigatório, sem mensagens genéricas. Relacionado a US-01, US-02.

### 3.4 Confiabilidade
- **RNF-10**: Consultas e instruções já carregadas (ex.: roteiro da próxima operação) devem permanecer disponíveis ao usuário mesmo sem conexão de rede. Relacionado a US-15.
- **RNF-11**: Apontamentos e movimentações de estoque realizados sem conexão devem ficar em estado explícito de "pendente de sincronização", só sendo confirmados após sincronização bem-sucedida, com garantia de idempotência e resolução de conflito. Relacionado a US-14, US-16, US-17.
- **RNF-12**: Nenhum movimento crítico de estoque (reserva, separação, consumo) deve ser confirmado silenciosamente quando realizado em modo offline; o usuário deve ser informado do estado pendente. Relacionado a US-11, US-12, US-17.
- **RNF-13**: Snapshots técnicos (configuração, BOM, roteiro) congelados para uma ordem de produção não podem ser alterados após sua criação. Relacionado a US-04.
- **RNF-14**: Alterações em famílias construtivas ou normas técnicas devem gerar novas versões, sem apagar ou sobrescrever versões e histórico anteriores. Relacionado a US-05, US-06.
- **RNF-15**: Registros de histórico e auditoria de uma ordem devem ser preservados de forma permanente e não editável, garantindo rastreabilidade completa do que foi fabricado, com quais insumos e em qual processo. Relacionado a US-24, US-25.
