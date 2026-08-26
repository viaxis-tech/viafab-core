# User Stories e Requisitos — ViaFab

> **Aviso de numeração (adicionado em 25/08/2026, WP-0.4):** este documento cobre o **escopo do ERP completo** e sua numeração de US/RF é **distinta e não intercambiável** com a do pipeline de 24/08 (`docs/Docs20260824_151851/`), que trata apenas da Fase 0+1 do protótipo. Ao citar uma US ou RF, sempre indique a rodada de origem.
>
> Gerado a partir de `discovery-notes.md`.
>
> **Conformidade de design (Design Lock)**: o pacote canônico em `docs/Docs20260820_134109/design/` rege a implementação de interface. O `design-contract.json` é a fonte literal para telas, rotas, componentes, estados e contratos de API; o `artifact.html` é a referência navegável de layout. A `auditoria-design-20260823.md` deve ser usada como lista complementar de riscos e decisões abertas, não como substituta do contrato travado.

## 1. User Stories

### Domínio: Demanda e Configuração Técnica

**US-01** — Como PCP/gerente de produção, quero receber uma demanda técnica ou snapshot do ViaSign, para iniciar a criação de uma ordem de fabricação sem redigitação manual.
- Critérios de aceite:
  - Uma demanda ou snapshot recebido fica disponível para ser transformado em ordem.
  - Nenhum dado da demanda/snapshot precisa ser redigitado manualmente para iniciar a ordem.

**US-02** — Como PCP/gerente de produção, quero selecionar a família construtiva aplicável a uma demanda, para que a ordem siga regras reutilizáveis por geometria, dimensões, materiais, processo e conteúdo.
- Critérios de aceite:
  - É possível listar e selecionar entre as famílias construtivas cadastradas.
  - A ordem fica associada à família construtiva selecionada.

**US-03** — Como PCP/gerente de produção, quero informar os parâmetros técnicos da placa (geometria, dimensões, materiais, processo, conteúdo), para que o sistema valide se a configuração é fabricável.
- Critérios de aceite:
  - O formulário de parâmetros exibe os campos definidos pela família construtiva selecionada.
  - Todos os parâmetros obrigatórios da família devem ser preenchidos antes do avanço.

**US-04** — Como PCP/gerente de produção, quero que o sistema valide as regras da família construtiva antes de gerar a ordem, para evitar configurações inválidas ou não fabricáveis.
- Critérios de aceite:
  - Parâmetros que violam regra da família construtiva impedem a geração da ordem.
  - O motivo da violação é exibido ao usuário.

**US-05** — Como PCP/gerente de produção, quero que o sistema gere automaticamente a BOM a partir dos parâmetros validados, para eliminar o levantamento manual de materiais.
- Critérios de aceite:
  - A BOM é gerada sem intervenção manual após a validação dos parâmetros.
  - A BOM gerada reflete os materiais definidos pelas regras da família construtiva para os parâmetros informados.

**US-06** — Como PCP/gerente de produção, quero que o sistema gere automaticamente o roteiro de fabricação a partir dos parâmetros validados, para eliminar a definição manual de operações.
- Critérios de aceite:
  - O roteiro é gerado sem intervenção manual após a validação dos parâmetros.
  - O roteiro gerado reflete as operações definidas pelas regras da família construtiva para os parâmetros informados.

**US-07** — Como PCP/gerente de produção, quero que cada ordem preserve um snapshot técnico versionado e imutável dos parâmetros, BOM e roteiro no momento da criação, para manter rastreabilidade mesmo se a família construtiva mudar depois.
- Critérios de aceite:
  - Ao criar a ordem, um snapshot técnico é registrado com identificador de versão único.
  - Alterações posteriores na família construtiva não afetam snapshots já registrados.
  - O snapshot registrado não pode ser editado.

**US-08** — Como engenharia, quero cadastrar e manter famílias construtivas com regras parametrizadas, para que o PCP resolva novas placas sem criar produtos fixos individuais.
- Critérios de aceite:
  - É possível criar, editar e consultar famílias construtivas com suas regras.
  - Uma família construtiva pode ser reutilizada por múltiplas ordens com parâmetros diferentes.

### Domínio: Integração com ViaSign

**US-09** — Como PCP/gerente de produção, quero que o ViaFab receba demandas ou snapshots técnicos publicados pelo ViaSign via contrato `viaxis.vfb/1`, para iniciar ordens sem depender de troca manual de informação entre sistemas.
- Critérios de aceite:
  - Uma demanda/snapshot publicado no formato `viaxis.vfb/1` é aceito pelo ViaFab.
  - Dados fora do contrato definido são rejeitados com indicação do motivo.
  - Nota de escopo MVP: a publicação pode ser simulada por fixture/simulador atrás do contrato `viaxis.vfb/1`; a fronteira, a validação e a rejeição de dados fora do contrato são reais e preparadas para futura integração por API. Nenhum conector externo é construído nesta fase. O modo standalone/manual (US-13) permanece obrigatório.

**US-10** — Como PCP/gerente de produção, quero que o ViaFab mapeie os IDs externos do ViaSign para os itens/fichas internos do ViaFab, para garantir consistência de dados entre os módulos independentes.
- Critérios de aceite:
  - Cada ID externo recebido é associado a um item/ficha interno correspondente.
  - IDs externos sem correspondência interna são sinalizados para tratamento.

**US-11** — Como PCP/gerente de produção, quero que o recebimento de uma demanda/snapshot do ViaSign seja idempotente, para que reenvios não dupliquem ordens nem dados.
- Critérios de aceite:
  - O reenvio de uma demanda/snapshot já processado não cria novo registro duplicado.
  - O sistema identifica reenvios pelo identificador do evento/snapshot de origem.

**US-12** — Como PCP/gerente de produção, quero registrar e preservar as revisões e eventos de cada demanda/snapshot recebido do ViaSign, para manter histórico completo de origem.
- Critérios de aceite:
  - Cada revisão recebida fica associada à sua ordem de chegada e conteúdo original.
  - O histórico de eventos de uma demanda/snapshot pode ser consultado posteriormente.

**US-13** — Como PCP/gerente de produção, quero cadastrar uma demanda manualmente quando o ViaSign não estiver disponível, para que a fábrica continue operando de forma standalone.
- Critérios de aceite:
  - É possível criar uma demanda manual sem depender da integração com o ViaSign.
  - A demanda manual segue o mesmo fluxo de transformação em ordem que uma demanda vinda do ViaSign.

### Domínio: Planejamento e Liberação de Produção

**US-14** — Como PCP/gerente de produção, quero verificar a disponibilidade de materiais da BOM antes de liberar uma ordem, para evitar iniciar produção sem insumos suficientes.
- Critérios de aceite:
  - O sistema exibe o saldo disponível de cada item da BOM da ordem.
  - Itens com saldo insuficiente são sinalizados antes da liberação.

**US-15** — Como almoxarifado, quero reservar/separar o estoque necessário para uma ordem liberada, para garantir que os materiais estejam disponíveis no momento da execução.
- Critérios de aceite:
  - É possível reservar os itens da BOM de uma ordem liberada.
  - O saldo disponível de estoque é reduzido pela quantidade reservada.

**US-16** — Como PCP/gerente de produção, quero distribuir as operações do roteiro entre setores e máquinas, para organizar a execução da ordem no chão de fábrica.
- Critérios de aceite:
  - Cada operação do roteiro pode ser associada a um setor e a uma máquina.
  - A distribuição fica visível para consulta antes da liberação da produção.

**US-17** — Como PCP/gerente de produção, quero calcular a capacidade disponível por setor e máquina, para planejar prazos realistas de entrega.
- Critérios de aceite:
  - O sistema exibe a capacidade disponível por setor/máquina em um período informado.
  - A capacidade considerada reflete as operações já planejadas para o mesmo período.

**US-18** — Como PCP/gerente de produção, quero que o sistema identifique conflitos de capacidade ou de materiais antes da liberação da produção, para evitar promessas de prazo sem base.
- Critérios de aceite:
  - Ordens que excedam a capacidade de um setor/máquina no período são sinalizadas antes da liberação.
  - Ordens com materiais insuficientes são sinalizadas antes da liberação.

**US-30** — Como PCP/engenharia, quero cadastrar e manter setores e máquinas da fábrica, para que as operações possam ser distribuídas e a capacidade calculada sobre recursos reais.
- Critérios de aceite:
  - É possível criar, editar e inativar setores e máquinas (cadastro mínimo: identificação, setor da máquina e disponibilidade para planejamento).
  - Setores e máquinas cadastrados ficam disponíveis para a distribuição de operações (US-16) e o cálculo de capacidade (US-17).
  - Fora do escopo: gestão ampla de ativos, manutenção preventiva/corretiva ou telemetria de máquinas.

**US-31** — Como almoxarifado, quero cadastrar itens de estoque controlados e registrar movimentações de entrada, para que os saldos usados em verificação e reserva tenham origem verificável.
- Critérios de aceite:
  - É possível cadastrar itens controlados com identificação e unidade de medida (cadastro mínimo).
  - É possível registrar movimentações de entrada que atualizam o saldo disponível do item.
  - A verificação de disponibilidade (US-14) e a reserva (US-15) operam sobre saldos originados dessas movimentações.
  - Fora do escopo do MVP: pedidos de compra, cadastro de fornecedores e reposição automática.

**US-32** — Como compras (usuário secundário), quero visualizar as faltas e necessidades de material sinalizadas no planejamento, para providenciar reposição fora do sistema.
- Critérios de aceite:
  - Compras tem acesso somente leitura à visualização de itens com saldo insuficiente sinalizados nas ordens (US-14, US-18).
  - Fora do escopo do MVP: pedidos de compra, fornecedores e reposição automática dentro do ViaFab.

### Domínio: Execução e Rastreabilidade

**US-19** — Como operador, quero registrar o início e a conclusão da execução de uma operação da ordem, para que o progresso da produção seja rastreado em tempo real.
- Critérios de aceite:
  - É possível marcar o início de uma operação vinculada à ordem e ao executor.
  - O horário de início fica registrado e associado à operação.
  - É possível registrar a conclusão da operação com executor, data/hora, status e quantidade aplicável.
  - Uma operação concluída não pode receber novos registros de início.

**US-20** — Como operador, quero registrar o consumo de materiais durante a execução, para manter o estoque e a BOM realizados atualizados.
- Critérios de aceite:
  - É possível registrar a quantidade consumida de cada item da BOM durante a execução.
  - O saldo de estoque é atualizado conforme o consumo registrado.

**US-21** — Como operador, quero registrar perdas e retrabalho durante a execução, para que o PCP tenha visibilidade de desvios do planejado.
- Critérios de aceite:
  - É possível registrar a quantidade e o motivo de uma perda vinculada a uma operação/ordem.
  - É possível registrar um retrabalho vinculado a uma operação/ordem, com motivo.

**US-22** — Como operador, quero registrar bloqueios que impeçam a continuidade de uma operação, para sinalizar impedimentos ao PCP e à engenharia.
- Critérios de aceite:
  - É possível registrar um bloqueio em uma operação com motivo obrigatório.
  - Uma operação bloqueada fica visível como impedida até o bloqueio ser resolvido.
  - Um usuário autorizado conforme o tipo do bloqueio pode encerrá-lo, registrando motivo, responsável e data/hora da resolução.
  - A transição de bloqueado para resolvido é registrada em auditoria.
  - A operação só pode continuar após o bloqueio estar no estado resolvido.

**US-23** — Como qualidade, quero registrar inspeções e resultados de qualidade vinculados à ordem, para garantir rastreabilidade do processo produtivo.
- Critérios de aceite:
  - É possível registrar uma inspeção de qualidade vinculada à ordem, com resultado aprovado ou reprovado.
  - O histórico de inspeções de uma ordem pode ser consultado.

**US-24** — Como PCP/gerente de produção, quero comparar o planejado versus o realizado de cada ordem, para identificar gargalos e desvios de prazo.
- Critérios de aceite:
  - O sistema exibe, lado a lado, os dados planejados (roteiro, capacidade, prazo) e os dados realizados (execução, consumo, perdas, retrabalho) da ordem.
  - Os dados realizados de execução usam os registros de início e conclusão das operações (US-19).

**US-25** — Como expedição, quero vincular a ordem, suas séries e o envio à expedição final, para manter a rastreabilidade completa da engenharia até a entrega.
- Critérios de aceite:
  - É possível registrar o envio de uma ordem, vinculando-a às séries produzidas.
  - A ordem expedida permanece rastreável até a demanda/snapshot de origem.

**US-33** — Como operador, quero registrar a série de cada unidade produzida no momento da sua conclusão na produção, para que somente unidades concluídas e rastreáveis possam ser expedidas.
- Critérios de aceite:
  - A série nasce no fluxo de produção, quando a unidade produzida é concluída e registrada, antes de poder ser expedida.
  - O registro da série vincula ordem, item, depósito e snapshot técnico da ordem.
  - Séries não são geradas no cadastro da demanda nem na criação da ordem.

### Domínio: Segurança e Multi-tenant

**US-26** — Como gerente de produção, quero que o acesso aos dados da minha empresa (tenant) seja isolado dos dados de outras empresas, para garantir confidencialidade em um ambiente SaaS multi-tenant.
- Critérios de aceite:
  - Um usuário de um tenant não consegue visualizar ou alterar dados de outro tenant.
  - Toda consulta a dados de negócio é filtrada pelo tenant do usuário autenticado.

**US-27** — Como direção, quero que toda ação relevante no sistema seja registrada em um log de auditoria append-only, para garantir rastreabilidade e conformidade.
- Critérios de aceite:
  - Ações relevantes (criação/alteração de demandas, ordens, estoque, execução, qualidade) geram registro de auditoria.
  - Registros de auditoria não podem ser alterados ou excluídos.

### Domínio: Plataforma e Operação Offline

**US-28** — Como operador/almoxarifado/qualidade/expedição, quero usar o ViaFab em tablet ou celular no chão de fábrica, para registrar informações no local de trabalho.
- Critérios de aceite:
  - As telas de registro de execução, consumo, perdas, retrabalho, bloqueio, qualidade e expedição funcionam em navegador de tablet e celular.

**US-29** — Como operador, quero que o sistema indique explicitamente quando estou offline e há sincronização pendente, para não perder ou duplicar registros de movimentações críticas de estoque.
- Critérios de aceite:
  - Um indicador visível mostra o estado offline quando não há conectividade.
  - Registros pendentes de sincronização ficam visíveis até serem confirmados no servidor.
  - Movimentações críticas de estoque feitas offline exigem confirmação explícita do usuário após a reconexão.

---

## 2. Requisitos Funcionais

### Demanda e Configuração Técnica

- **RF-01**: O sistema deve permitir o cadastro/importação de uma demanda técnica ou snapshot como origem de uma ordem de fabricação. Relacionado a US-01.
- **RF-02**: O sistema deve permitir a seleção de uma família construtiva para uma demanda, dentre as famílias cadastradas. Relacionado a US-02, US-08.
- **RF-03**: O sistema deve permitir a entrada dos parâmetros técnicos (geometria, dimensões, materiais, processo, conteúdo) de uma placa vinculada a uma família construtiva. Relacionado a US-03.
- **RF-04**: O sistema deve validar os parâmetros informados contra as regras da família construtiva selecionada antes de permitir a geração da ordem. Relacionado a US-04.
- **RF-05**: O sistema deve bloquear a geração da ordem quando os parâmetros informados violarem alguma regra da família construtiva, exibindo o motivo da rejeição. Relacionado a US-04.
- **RF-06**: O sistema deve gerar automaticamente a BOM da ordem a partir dos parâmetros validados e das regras da família construtiva. Relacionado a US-05.
- **RF-07**: O sistema deve gerar automaticamente o roteiro de fabricação da ordem a partir dos parâmetros validados e das regras da família construtiva. Relacionado a US-06.
- **RF-08**: O sistema deve registrar, no momento da criação da ordem, um snapshot técnico contendo os parâmetros, a BOM e o roteiro resolvidos. Relacionado a US-07.
- **RF-09**: O sistema deve versionar cada snapshot técnico gerado, associando-o a um identificador único e imutável. Relacionado a US-07.
- **RF-10**: O sistema não deve permitir a alteração de um snapshot técnico já registrado; qualquer mudança deve gerar uma nova versão. Relacionado a US-07.
- **RF-11**: O sistema deve permitir o cadastro de famílias construtivas com regras parametrizadas reutilizáveis por geometria, dimensões, materiais, processo e conteúdo. Relacionado a US-08.

### Integração com ViaSign

- **RF-12**: O sistema deve receber demandas/snapshots técnicos publicados no formato do contrato `viaxis.vfb/1`; no MVP a publicação pode ser simulada por fixture/simulador atrás do contrato, mantendo fronteira e validação reais para futura integração por API, sem construção de conector externo nesta fase. Relacionado a US-09.
- **RF-13**: O sistema deve mapear os IDs externos recebidos do ViaSign para os itens/fichas internos do ViaFab. Relacionado a US-10.
- **RF-14**: O sistema deve processar o recebimento de uma demanda/snapshot do ViaSign de forma idempotente, evitando a criação de registros duplicados em reenvios. Relacionado a US-11.
- **RF-15**: O sistema deve armazenar as revisões e eventos de cada demanda/snapshot recebido do ViaSign, preservando o histórico de origem. Relacionado a US-12.
- **RF-16**: O sistema deve tratar todo snapshot técnico recebido do ViaSign como versionado e imutável, sem permitir edição do conteúdo original recebido. Relacionado a US-12.
- **RF-17**: O sistema deve permitir o cadastro manual de uma demanda quando não houver integração disponível com o ViaSign, mantendo o ViaFab operante de forma standalone. Relacionado a US-13.

### Planejamento e Liberação de Produção

- **RF-18**: O sistema deve verificar a disponibilidade de estoque de cada item da BOM antes de permitir a liberação da ordem para produção. Relacionado a US-14.
- **RF-19**: O sistema deve permitir a reserva/separação de estoque para os itens da BOM de uma ordem liberada. Relacionado a US-15.
- **RF-20**: O sistema deve permitir a distribuição das operações do roteiro de uma ordem entre setores e máquinas cadastrados. Relacionado a US-16.
- **RF-21**: O sistema deve calcular a capacidade disponível por setor e por máquina em um período de planejamento. Relacionado a US-17.
- **RF-22**: O sistema deve identificar e sinalizar conflitos de capacidade entre ordens planejadas para o mesmo setor/máquina antes da liberação da produção. Relacionado a US-18.
- **RF-23**: O sistema deve identificar e sinalizar a insuficiência de materiais de uma ordem antes da liberação da produção. Relacionado a US-18.
- **RF-39**: O sistema deve permitir o cadastro mínimo de setores e máquinas (criar, editar, inativar), disponibilizando-os para a distribuição de operações e o cálculo de capacidade, sem constituir módulo amplo de gestão de ativos. Relacionado a US-30, US-16, US-17.
- **RF-40**: O sistema deve permitir o cadastro mínimo de itens de estoque controlados (identificação e unidade de medida). Relacionado a US-31.
- **RF-41**: O sistema deve permitir o registro de movimentações de entrada de estoque, atualizando o saldo disponível dos itens; a verificação de disponibilidade e a reserva devem operar sobre saldos originados dessas movimentações. Relacionado a US-31, US-14, US-15.
- **RF-42**: O sistema deve disponibilizar à persona compras uma visualização somente leitura de faltas e necessidades de material sinalizadas no planejamento; pedidos de compra, fornecedores e reposição automática estão fora do MVP. Relacionado a US-32.

### Execução e Rastreabilidade

- **RF-24**: O sistema deve permitir o registro do início de execução de cada operação de uma ordem. Relacionado a US-19.
- **RF-43**: O sistema deve permitir o registro da conclusão de cada operação de uma ordem, com executor, data/hora, status e quantidade aplicável. Relacionado a US-19, US-24.
- **RF-25**: O sistema deve permitir o registro do consumo de materiais de uma ordem durante a execução, atualizando o saldo de estoque correspondente. Relacionado a US-20.
- **RF-26**: O sistema deve permitir o registro de perdas associadas a uma operação ou ordem em execução. Relacionado a US-21.
- **RF-27**: O sistema deve permitir o registro de retrabalho associado a uma operação ou ordem em execução. Relacionado a US-21.
- **RF-28**: O sistema deve permitir o registro de bloqueios que impeçam a continuidade de uma operação, com motivo do bloqueio. Relacionado a US-22.
- **RF-44**: O sistema deve permitir a resolução de bloqueios por usuário autorizado conforme o tipo do bloqueio, registrando motivo, responsável e data/hora, com a transição auditada; a operação só pode continuar após o estado resolvido. Relacionado a US-22.
- **RF-29**: O sistema deve permitir o registro de inspeções de qualidade vinculadas a uma ordem, com resultado aprovado/reprovado. Relacionado a US-23.
- **RF-30**: O sistema deve exibir a comparação entre o planejado (roteiro, capacidade, prazo) e o realizado (execução com início e conclusão registrados, consumo, perdas, retrabalho) de cada ordem. Relacionado a US-24.
- **RF-31**: O sistema deve manter a rastreabilidade de cada ordem desde a demanda/snapshot de origem até a expedição, incluindo séries vinculadas. Relacionado a US-25.
- **RF-32**: O sistema deve permitir o registro do envio de uma ordem na expedição, vinculando-a às séries produzidas (ver RF-45). Relacionado a US-25.
- **RF-45**: O sistema deve registrar a série de cada unidade produzida no momento da sua conclusão na produção, vinculando ordem, item, depósito e snapshot técnico; séries não são geradas no cadastro da demanda nem na criação da ordem. Relacionado a US-33, US-25.

### Segurança e Multi-tenant

- **RF-33**: O sistema deve isolar os dados de cada empresa (tenant) por meio de controle de acesso a nível de linha (RLS), impedindo acesso cruzado entre tenants. Relacionado a US-26.
- **RF-34**: O sistema deve registrar em log de auditoria append-only toda ação relevante realizada sobre demandas, ordens, estoque, execução e qualidade. Relacionado a US-27.

### Plataforma e Operação Offline

- **RF-35**: O sistema deve ser acessível via navegador em dispositivos desktop, tablet e celular, com PWA responsiva. Relacionado a US-28.
- **RF-36**: O sistema deve exibir um indicador explícito de estado offline quando a conectividade estiver instável ou indisponível. Relacionado a US-29.
- **RF-37**: O sistema deve exibir um indicador explícito de sincronização pendente quando houver registros aguardando envio ao servidor. Relacionado a US-29.
- **RF-38**: O sistema não deve confirmar automaticamente movimentações críticas de estoque enquanto estiver em estado offline, exigindo confirmação explícita após reconexão. Relacionado a US-29.

---

## 3. Requisitos Não-Funcionais

### Performance

- **RNF-01**: As operações de edição e preview de configuração técnica (parâmetros, BOM, roteiro) devem atender à meta mensurável de performance de até 500 ms no percentil 95 (p95), medida em cenário representativo de uso. A meta não deve mascarar falha funcional: erros devem ser reportados, nunca ocultados para cumprir o tempo de resposta.
- **RNF-02**: Operações de lote (ex.: processamento de múltiplas ordens) e geração de relatórios podem ser executadas de forma assíncrona, sem bloquear a interface do usuário durante o processamento.

### Segurança

- **RNF-03**: O sistema deve adotar postura de segurança fail-closed, negando por padrão qualquer operação não explicitamente autorizada.
- **RNF-04**: O sistema deve implementar Row Level Security (RLS) multi-tenant no banco de dados para todas as tabelas que armazenam dados de clientes/empresas.
- **RNF-05**: O sistema deve manter um log de auditoria append-only, sem permitir alteração ou exclusão de registros já gravados, com sanitização/redação de segredos, credenciais, tokens e dados sensíveis, mantendo apenas os campos necessários à rastreabilidade.
- **RNF-06**: O sistema deve proteger dados sensíveis armazenados e em trânsito.
- **RNF-07**: (Referência cruzada) A imutabilidade de snapshots técnicos recebidos do ViaSign é normatizada exclusivamente por RF-16.

### Usabilidade

- **RNF-08**: A interface deve ser responsiva e utilizável em telas de desktop, tablet e celular, adequando-se ao contexto de uso de cada persona (PCP/engenharia em desktop; almoxarifado, operadores, qualidade e expedição em tablet/celular).
- **RNF-09**: O sistema deve exibir de forma explícita e visível o estado de conectividade (online/offline) e a existência de dados pendentes de sincronização em qualquer tela onde o usuário possa registrar movimentações.

### Confiabilidade

- **RNF-10**: (Referência cruzada) A idempotência do processamento de demandas/snapshots recebidos é normatizada exclusivamente por RF-14.
- **RNF-11**: (Referência cruzada) A preservação do histórico de revisões e eventos é normatizada exclusivamente por RF-15.
- **RNF-12**: (Referência cruzada) A operação standalone com cadastro manual de demandas é normatizada exclusivamente por RF-17.
- **RNF-13**: (Referência cruzada) A não confirmação silenciosa de movimentações críticas de estoque offline é normatizada exclusivamente por RF-38.

### Arquitetura

- **RNF-14**: O domínio e os contratos do sistema devem permanecer desacoplados da UI e da infraestrutura.
- **RNF-15**: As regras de negócio não devem ser acopladas a preço, plano ou limite comercial; restrições comerciais, quando existirem, devem ser aplicadas fora do núcleo de domínio.
- **RNF-16**: Os contratos e as trilhas de dados devem ser agent-ready (estruturados, versionados e auditáveis para futura automação por agentes), sem incluir IA ou automações por agente no MVP.
