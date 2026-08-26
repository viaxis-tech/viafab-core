# PRD — ViaFab

> **Aviso de numeração (adicionado em 25/08/2026, WP-0.4):** este documento cobre o **escopo do ERP completo** e sua numeração de US/RF é **distinta e não intercambiável** com a do pipeline de 24/08 (`docs/Docs20260824_151851/`), que trata apenas da Fase 0+1 do protótipo. Ao citar uma US ou RF, sempre indique a rodada de origem.
>
> Documento de Requisitos de Produto gerado a partir de `discovery-notes.md` e `stories-requisitos.md`.
>
> **Conformidade de design (Design Lock)**: o pacote canônico em `docs/Docs20260820_134109/design/` rege a implementação de interface. O `design-contract.json` é a fonte literal para telas, rotas, componentes, estados e contratos de API; o `artifact.html` é a referência navegável de layout. A `auditoria-design-20260823.md` deve ser usada como lista complementar de riscos e decisões abertas, não como substituta do contrato travado.

---

## 1. Resumo Executivo

O ViaFab é um sistema de gestão de fabricação verticalizado para sinalização vertical, que transforma demandas comerciais e técnicas — ou snapshots recebidos do ViaSign — em ordens de fabricação prontas para execução. O produto resolve família construtiva e parâmetros técnicos, gera BOM e roteiro por regras paramétricas (geometria, dimensões, materiais, processo e conteúdo), organiza o planejamento por setor e máquina, e mantém rastreabilidade completa da engenharia até a expedição.

O problema que o ViaFab resolve é a desorganização do fluxo de fabricação: hoje a fábrica recebe demandas comerciais e técnicas espalhadas, depende de conhecimento tácito e consolida manualmente engenharia, BOM, materiais, capacidade, produção, qualidade e expedição. Isso gera redigitação, retrabalho, falta de material, promessas de prazo pouco confiáveis e perda de rastreabilidade. O ViaFab substitui esse processo manual por um fluxo estruturado: da demanda à ordem, da ordem ao planejamento, do planejamento à execução rastreável e vínculo até a expedição.

O público-alvo principal é o responsável pela produção e pelo planejamento da fábrica — gerente de produção/engenharia ou PCP — que confere fabricabilidade, valida configuração construtiva, explode BOM, verifica materiais e capacidade, distribui operações entre setores e máquinas, e acompanha prazo, gargalos, perdas, retrabalho, bloqueios e qualidade. Engenharia, almoxarifado, operadores, qualidade, expedição, compras e direção são usuários secundários que interagem com partes específicas do fluxo. A intenção comercial é oferecer o ViaFab como SaaS B2B por assinatura mensal, mas a primeira validação ocorre na operação própria, com foco no núcleo operacional do MVP.

---

## 2. Personas

### Persona principal

**PCP / Gerente de Produção**
- **Descrição**: Responsável pela produção e pelo planejamento da fábrica. Recebe demandas comerciais e técnicas, confere fabricabilidade, valida configuração construtiva, explode a BOM, verifica materiais e capacidade, distribui operações entre setores e máquinas e acompanha prazo, gargalos, perdas, retrabalho, bloqueios e qualidade. Consolida dados de clientes, engenharia, estoque e chão de fábrica para tomar decisões rápidas sem perder rastreabilidade. Usa principalmente desktop.
- **Objetivos**: Transformar demandas em ordens fabricáveis sem redigitação; garantir que ordens liberadas tenham material e capacidade disponíveis; acompanhar planejado versus realizado; manter rastreabilidade completa de cada ordem.
- **Frustrações**: Redigitação manual de dados entre sistemas; retrabalho por configurações inválidas; falta de material identificada tarde demais; promessas de prazo sem base em capacidade real; perda de rastreabilidade entre engenharia, produção e expedição.

### Personas secundárias

**Engenharia**
- **Descrição**: Cadastra e mantém as famílias construtivas com regras parametrizadas que resolvem cada placa por geometria, dimensões, materiais, processo e conteúdo.
- **Objetivos**: Manter regras reutilizáveis para que o PCP resolva novas placas sem criar produtos fixos individuais.
- **Frustrações**: Dependência de conhecimento tácito não documentado; necessidade de recriar configurações do zero a cada nova demanda.

**Almoxarifado**
- **Descrição**: Cadastra itens de estoque controlados, registra movimentações de entrada e reserva/separa estoque para ordens liberadas. Opera principalmente em tablet ou celular no chão de fábrica.
- **Objetivos**: Garantir que os materiais necessários estejam disponíveis no momento da execução, com saldos confiáveis e rastreáveis.
- **Frustrações**: Saldos de estoque sem origem verificável; falta de visibilidade sobre reservas e necessidades futuras.

**Operador**
- **Descrição**: Executa as operações do roteiro de produção, registrando início, conclusão, consumo de materiais, perdas, retrabalho, bloqueios e a série de cada unidade produzida. Opera em tablet ou celular no chão de fábrica, muitas vezes com conectividade instável.
- **Objetivos**: Registrar o progresso da produção em tempo real, sem redigitação e sem perder ou duplicar informação crítica mesmo offline.
- **Frustrações**: Falta de indicação clara de estado offline; risco de perder ou duplicar registros de movimentações críticas de estoque; bloqueios sem visibilidade clara de motivo ou resolução.

**Qualidade**
- **Descrição**: Registra inspeções e resultados de qualidade vinculados à ordem, garantindo rastreabilidade do processo produtivo. Opera em tablet ou celular.
- **Objetivos**: Garantir que cada ordem tenha histórico de inspeções consultável, com resultados claros de aprovação ou reprovação.
- **Frustrações**: Falta de vínculo entre inspeções e a ordem/série correspondente.

**Expedição**
- **Descrição**: Vincula a ordem, suas séries e o envio à expedição final, mantendo a rastreabilidade completa da engenharia até a entrega. Opera em tablet ou celular.
- **Objetivos**: Expedir apenas unidades concluídas e rastreáveis, com vínculo até a demanda/snapshot de origem.
- **Frustrações**: Falta de rastreabilidade entre série produzida, ordem e envio.

**Compras**
- **Descrição**: Usuário secundário com acesso somente leitura às faltas e necessidades de material sinalizadas no planejamento.
- **Objetivos**: Visualizar faltas de material para providenciar reposição fora do sistema.
- **Frustrações**: Falta de visibilidade antecipada sobre necessidades de material geradas pelo planejamento.

**Direção**
- **Descrição**: Consulta o log de auditoria append-only para garantir rastreabilidade e conformidade das ações relevantes do sistema.
- **Objetivos**: Ter confiança de que toda ação relevante é registrada e não pode ser alterada ou excluída.
- **Frustrações**: Falta de rastreabilidade e histórico auditável no processo atual.

---

## 3. User Stories

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

## 4. Requisitos Funcionais

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

## 5. Requisitos Não-Funcionais

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

---

## 6. Métricas de Sucesso

- **Eliminação de redigitação**: 100% das demandas recebidas (via ViaSign ou cadastro manual) tornam-se disponíveis para transformação em ordem sem redigitação manual dos dados técnicos (RF-01, RF-17).
- **Geração automática confiável**: 100% das ordens criadas têm BOM e roteiro gerados automaticamente a partir dos parâmetros validados, sem intervenção manual (RF-06, RF-07).
- **Rastreabilidade técnica**: 100% das ordens criadas possuem snapshot técnico versionado e imutável, associado a identificador único (RF-08, RF-09, RF-10).
- **Idempotência da integração**: 0 ordens ou dados duplicados em reenvios de demanda/snapshot do ViaSign processados pelo sistema (RF-14).
- **Confiabilidade de liberação**: 0 ordens liberadas para produção sem verificação prévia de disponibilidade de material e sem checagem de conflito de capacidade (RF-18, RF-22, RF-23).
- **Rastreabilidade ponta a ponta**: 100% das ordens expedidas mantêm rastreabilidade completa desde a demanda/snapshot de origem até a série e o envio (RF-31, RF-32, RF-45).
- **Desempenho da edição técnica**: tempo de resposta de edição e preview de configuração técnica dentro da meta de 500 ms no percentil 95 (RNF-01).
- **Auditoria completa**: 100% das ações relevantes sobre demandas, ordens, estoque, execução e qualidade registradas em log de auditoria append-only, sem alteração ou exclusão posterior (RF-34, RNF-05).
- **Isolamento multi-tenant**: 0 ocorrências de acesso cruzado a dados entre tenants diferentes (RF-33, RNF-04).
- **Operação offline segura**: 100% das movimentações críticas de estoque realizadas offline exigem confirmação explícita do usuário após reconexão, sem confirmação silenciosa (RF-38).
- **Validação em operação própria**: fluxo completo de demanda → ordem → planejamento → execução → expedição operando na fábrica própria como piloto do MVP, sem bloqueio por definição de preços, planos ou cobrança (conforme escopo do MVP).

---

## 7. Escopo Negativo (fora do MVP)

- **Integração real com ViaSign**: no MVP, a publicação de demandas/snapshots do ViaSign é simulada por fixture/simulador atrás do contrato `viaxis.vfb/1`; nenhum conector externo real é construído nesta fase (RF-12, US-09).
- **Outras integrações externas**: não há integração externa obrigatória além do ViaSign definida para o MVP.
- **Automação por agentes/IA**: a base deve ser agent-ready (contratos e trilhas estruturados, versionados e auditáveis), mas nenhuma automação por IA ou agente é implementada no MVP (RNF-16).
- **Aplicativo nativo**: no MVP, apenas PWA responsiva via navegador é suportada; não há aplicativo nativo (RF-35).
- **Gestão ampla de ativos**: cadastro de setores e máquinas é mínimo (identificação, setor, disponibilidade); manutenção preventiva/corretiva e telemetria de máquinas estão fora do escopo (US-30).
- **Cadeia de suprimentos**: pedidos de compra, cadastro de fornecedores e reposição automática de estoque não fazem parte do MVP; compras tem apenas visualização somente leitura de faltas sinalizadas (US-31, US-32, RF-42).
- **Definição comercial**: preço, tiers, planos e regras de cobrança ainda não estão definidos e não fazem parte da implementação do MVP; a arquitetura deve evitar acoplar regras de negócio a limites comerciais (RNF-15).

---

## 8. Dependências e Riscos

### Dependências externas

- **Contrato `viaxis.vfb/1` do ViaSign**: a fronteira de integração depende da definição e estabilidade do contrato de publicação de demandas/snapshots técnicos; no MVP essa publicação é simulada por fixture/simulador, mas a validação e rejeição de dados fora do contrato precisam ser reais (RF-12).
- **Infraestrutura Supabase/Vercel**: banco de dados PostgreSQL, autenticação, RLS multi-tenant e Edge Functions em Deno dependem do Supabase; o frontend depende de hospedagem na Vercel.
- **CI/CD e observabilidade**: GitHub Actions para CI/CD e Sentry com auditoria sanitizada para operação.

### Riscos técnicos

- **Conectividade instável no chão de fábrica**: operadores, almoxarifado, qualidade e expedição operam em ambiente com conectividade instável; falhas na implementação do estado offline explícito e da sincronização pendente podem causar perda ou duplicação de registros críticos de estoque (RF-36, RF-37, RF-38).
- **Meta de performance de 500 ms (p95)**: a meta de edição/preview de configuração técnica exige atenção arquitetural desde o início; a meta não pode mascarar erros funcionais (RNF-01).
- **Isolamento multi-tenant e postura fail-closed**: falhas na implementação de RLS ou nas políticas de autorização podem comprometer o isolamento entre tenants, violando um requisito de segurança central do produto (RF-33, RNF-03, RNF-04).
- **Imutabilidade de snapshots técnicos**: a garantia de que snapshots não podem ser alterados após o registro (tanto os gerados internamente quanto os recebidos do ViaSign) precisa ser assegurada de forma consistente em todo o domínio (RF-10, RF-16).
- **Divergência entre documentos**: quando discovery, stories/requisitos e o pacote de design (`design-contract.json`, `artifact.html`, `auditoria-design-20260823.md`) divergirem, a divergência deve ser registrada e escalada, sem que requisitos sejam inventados para resolvê-la.

### Riscos de negócio

- **Modelo de monetização indefinido**: preço, tiers e diferenciação comercial ainda não foram validados; decisões futuras sobre planos não podem impactar o núcleo de domínio do MVP (RNF-15).
- **Validação restrita à operação própria**: a primeira validação do produto ocorre na fábrica própria, antes de qualquer piloto com clientes externos, o que limita a validação de mercado nesta fase.
- **Dependência de adoção pelos usuários secundários**: o valor de rastreabilidade ponta a ponta depende da adoção consistente por operadores, almoxarifado, qualidade e expedição no registro de suas atividades; lacunas de registro comprometem a comparação planejado versus realizado (US-24).

---

## 9. Decisões Técnicas

### Database

Decisões de nível arquitetural para persistência, incluindo os critérios de detalhamento de idempotência, estoque, offline sync e performance já registrados nesta seção. Tabelas, índices e constraints específicos podem ser refinados posteriormente na SPEC, respeitando as decisões arquiteturais aqui fechadas.

**Motor de banco de dados**
- PostgreSQL gerenciado via Supabase, confirmando a dependência já registrada na Seção 8 ("Infraestrutura Supabase/Vercel"). Suporta nativamente RLS (exigido por RNF-04), migrations versionadas e Edge Functions em Deno para lógica server-side.

**Estratégia multi-tenant**
- Schema compartilhado (single-schema) com coluna `tenant_id`/`account_id` em todas as tabelas de dados de negócio, isolado por Row Level Security (RLS). Não será usado schema separado por empresa.
- As policies de RLS não devem confiar apenas em um `tenant_id` enviado pelo cliente nem em claims potencialmente desatualizadas (stale). A autorização deve ser derivada e validada a partir de uma tabela de `memberships`/`roles` que associa `auth.uid()` a um tenant e papel. Claims de JWT podem ser usadas como otimização de consulta, mas a regra de segurança final deve permanecer fail-closed (RNF-03) e checar a associação autorizada na base, não apenas confiar no claim.

**Modelo de identidade e usuários**
- Não haverá tabela própria duplicando `auth.users`. A identidade do usuário usa `auth.users` (Supabase Auth) combinada com uma tabela de `memberships`/`roles` por tenant, que é a fonte de verdade para autorização e para as policies de RLS.

**Visão geral de entidades por domínio (nível arquitetural)**
- Demanda/Configuração técnica: `familias_construtivas` (com versionamento da definição/regras), `demandas`/`snapshots_viasign`, `ordens`.
- Snapshot técnico: `snapshots_tecnicos` (imutável, versionado, vinculado à ordem), com entidades filhas explicitamente vinculadas à ordem/snapshot para a BOM resolvida e para as operações do roteiro resolvido (garantindo que o snapshot referencie exatamente a definição de família/regras usada no momento da geração).
- Planejamento e estoque: `setores`, `maquinas`, `depositos` (localização física necessária para estoque e séries), `itens_estoque`, `movimentacoes_estoque` e `reservas_estoque` (ambas com `tenant_id` e vínculo a `deposito`).
- Execução e rastreabilidade: `execucoes_operacao` (início/fim), `perdas`, `retrabalhos`, `bloqueios`, `inspecoes_qualidade`, `series` (nascem na conclusão da produção, vinculando ordem, item, depósito e snapshot técnico), `expedicoes`.
- Integração ViaSign: eventos/revisões recebidos tratados como imutáveis, com `tenant_id`, ator/ação e chave de idempotência (ver abaixo).
- Auditoria: `audit_log` com `tenant_id`, ator e ação em cada registro.
- Explicitamente fora do escopo desta fase: gestão ampla de ativos/manutenção de máquinas, módulo completo de compras/fornecedores, IA e integrações externas adicionais além do ViaSign.

**Idempotência (ViaSign e integrações)**
- A idempotência do recebimento de demandas/snapshots (RF-14) deve ser garantida por constraint de unicidade a nível de banco, e não apenas por lógica de aplicação: chave única composta por tenant + origem/evento (ex.: `UNIQUE (tenant_id, origem, evento_id)`), evitando duplicação mesmo sob reenvio concorrente ou falha da aplicação.

**Imutabilidade de snapshots técnicos e eventos ViaSign**
- Trigger de banco impede `UPDATE` e `DELETE` nas tabelas `snapshots_tecnicos` e nas tabelas de eventos/revisões recebidos do ViaSign. Nova versão só é criada por `INSERT`, com unicidade garantida por `(ordem_id, versao)`.
- Essa proteção vale para as roles usadas pela aplicação em produção, combinada com privilégios mínimos (least privilege). Acesso administrativo usado para migrations não é caminho funcional do produto e não contorna essa garantia em runtime.

**Auditoria append-only**
- Tabela `audit_log` protegida por RLS e segregada por tenant, contendo `tenant_id`, ator e ação em cada registro, mantendo apenas os campos necessários à rastreabilidade (RNF-05).
- A aplicação não possui `INSERT` irrestrito na tabela, e o cliente nunca escreve diretamente nela. A gravação passa por função server-side controlada (ou trigger) responsável por aplicar allowlist/sanitização dos dados no limite da persistência, removendo segredos, tokens, credenciais e payloads sensíveis antes de gravar.
- Privilégios de `UPDATE`/`DELETE` são revogados das roles da aplicação, e trigger de proteção reforça o bloqueio a nível de banco.

**Idempotência do ViaSign (detalhamento)**
- Identificador de correlação `origem_ref` agrupa todas as entregas/revisões de uma mesma demanda/snapshot do ViaSign (histórico, US-12), distinto da chave de idempotência.
- Chave de idempotência é `(tenant_id, origem, evento_id)`, onde `evento_id` identifica cada entrega/revisão individual. Reenvio do mesmo `evento_id` com o mesmo payload é no-op garantido por constraint única/`ON CONFLICT` a nível de banco, retornando o registro já existente em vez de erro.
- Se o mesmo `evento_id` chegar novamente com payload diferente do já registrado, o sistema não sobrescreve nem aceita silenciosamente: a entrega é rejeitada e a inconsistência é registrada para tratamento (não é tratada como reenvio idempotente válido).

**Estoque e depósitos (detalhamento)**
- `depositos` como catálogo por tenant. Saldo é sempre uma dimensão de (item, depósito), nunca só do item.
- Fonte de verdade é um ledger append-only de movimentações (`movimentacoes_estoque`: entrada, consumo, perda), nunca update direto de saldo. O ledger histórico nunca é alterado por operações de reserva/liberação.
- Saldo agregado por (tenant, item, depósito) mantido em tabela própria (`saldo_estoque`) com `saldo_fisico` e `saldo_reservado`, atualizada de forma atômica por trigger/transação a cada INSERT relevante. `saldo_disponivel = saldo_fisico - saldo_reservado` é derivado.
- Postura estrita: `saldo_disponivel` nunca pode ficar negativo, inclusive sob concorrência. Reservas usam atualização atômica dentro de transação e falham (constraint `CHECK saldo_disponivel >= 0`) quando não há saldo suficiente no momento da confirmação. Não há saldo negativo temporário com reconciliação posterior.
- Cancelamento/liberação de reserva é uma transição de estado explícita e auditável, que reverte apenas `saldo_reservado`, sem alterar ou apagar o ledger histórico de movimentações.

**Sincronização offline (detalhamento)**
- A fila offline (armazenamento local, retry, detecção de reconexão) fica inteiramente no cliente para o MVP; não é responsabilidade do banco de dados.
- Toda ação offline-capable carrega uma `idempotency_key` gerada no cliente, com constraint única por `(tenant_id, idempotency_key)` na tabela de destino, evitando duplicação na sincronização.
- Movimentação crítica de estoque só é inserida no ledger após reconexão e confirmação explícita do usuário (RF-38); antes disso não altera `saldo_estoque` nem aparece como estoque efetivado no banco. Não existe linha "pendente" no ledger — o estado pendente/divergente é mantido pela UI no cliente até a confirmação ser processada pelo servidor em transação autorizada e auditável.
- Eventos não críticos (não relacionados a saldo de estoque, ex.: registros de execução/qualidade) podem sincronizar automaticamente na reconexão, respeitando a mesma constraint de `idempotency_key`.

**Performance (detalhamento)**
- MVP inicia com cálculo de capacidade por setor/máquina (US-17) em consulta em tempo real, com índices compostos liderados por `tenant_id` nas tabelas do caminho quente (`ordens`, `snapshots_tecnicos`, `familias_construtivas`, tabelas de planejamento). Agregação materializada ou trigger de pré-cálculo só serão introduzidos mediante evidência de volume real ou falha da meta de performance, não antecipadamente.
- Regras de família construtiva materializadas em coluna JSONB versionada, permitindo validação interativa em poucas leituras sem múltiplos joins sequenciais; essa materialização não pode impedir a evolução das regras (cada nova versão gera novo registro versionado, nunca edição da versão anterior).
- A meta de 500ms p95 (RNF-01) será verificada por medição representativa após a implementação, não assumida a priori; RNF-02 mantém operações de lote/relatório fora dessa meta interativa.

### Backend

Decisões de nível arquitetural para a camada de serviços/API. Constrói sobre as decisões de Database já fechadas (multi-tenant via RLS + `memberships`, imutabilidade por trigger, idempotência por constraint, ledger de estoque), sem repeti-las nem contradizê-las.

**Padrão arquitetural da API**
- Supabase Edge Functions (Deno) são a camada de casos de uso e orquestração para toda operação com regra de negócio não trivial: criação de ordem, validação de família construtiva, geração de BOM/roteiro, recebimento de demanda/snapshot do ViaSign, liberação de produção, reserva/separação de estoque, execução (início/conclusão), consumo, perdas, retrabalho, bloqueios, qualidade, geração de série e expedição.
- PostgREST direto pelo cliente (via SDK Supabase) fica restrito a leituras e a cadastros simples genuinamente protegidos por RLS e sem invariantes cruzadas (ex.: consultas de listagem, cadastro mínimo de setores/máquinas e itens de estoque sem efeito colateral em saldo). Qualquer escrita que envolva estoque, reservas, snapshots, auditoria, idempotência, mudança de estado da ordem ou autorização especial deve passar obrigatoriamente por um caso de uso server-side (Edge Function), nunca por escrita direta de tabela pelo cliente.
- Não há backend Node/Express separado nem microserviços adicionais. A organização é modular dentro do conjunto de Edge Functions e de código compartilhado (contratos, validação, domínio), evitando infraestrutura extra não justificada pelo discovery.
- Funções PostgreSQL (`plpgsql`) ficam limitadas a invariantes atômicas, triggers de proteção e operações de persistência que exigem garantia a nível de banco (idempotência, imutabilidade, atualização atômica de saldo), sem concentrar regras de negócio de domínio em PL/pgSQL.

**Separação de domínio e infraestrutura (RNF-14)**
- A lógica de domínio (regras de família construtiva, geração de BOM/roteiro, cálculo de conflito de capacidade, regras de transição de estado de ordem/bloqueio/reserva) vive em módulos puros de TypeScript, sem dependência de Deno, do cliente Supabase ou de objetos HTTP. Esses módulos são testáveis isoladamente com Vitest.
- As Edge Functions atuam como adaptadores finos de entrada: recebem a requisição HTTP, autenticam e autorizam o ator, validam o payload contra o contrato, chamam o caso de uso de domínio correspondente, executam a composição transacional necessária (incluindo chamadas ao banco) e traduzem o resultado em resposta HTTP.
- Repositórios/gateways de acesso a dado são interfaces definidas pelo domínio e implementadas na borda de infraestrutura (adaptador Supabase), permitindo testar o domínio com implementações em memória/fake sem subir banco.

**Autenticação**
- Supabase Auth (JWT) é o único mecanismo de autenticação. Um wrapper comum a todas as Edge Functions valida o JWT, carrega o `membership` (tenant + papéis) do usuário autenticado e nega por padrão antes de qualquer chamada ao domínio (fail-closed, RNF-03).
- A service role key nunca é exposta ao frontend/cliente. É usada exclusivamente no lado servidor (Edge Function), restrita a operações que a policy de RLS não pode expressar (ex.: escrita controlada em `audit_log`), sempre precedida de verificação explícita de autorização feita pelo código antes de qualquer bypass de RLS.
- O endpoint de recebimento de demanda/snapshot do ViaSign (RF-12), mesmo simulado por fixture/simulador no MVP, exige autenticação e autorização como qualquer outro caso de uso; não há endpoint anônimo no sistema.

**Autorização (RBAC)**
- RBAC simples com papéis explícitos alinhados às personas: `pcp`, `engenharia`, `almoxarifado`, `operador`, `qualidade`, `expedicao`, `compras`, `direcao`. Um usuário pode ter mais de um papel no mesmo tenant. Não há sistema genérico de permissões customizáveis por tenant no MVP.
- Cada caso de uso (Edge Function) declara explicitamente os papéis autorizados a executá-lo. Não existe caso de uso de escrita crítica executável por "qualquer usuário autenticado" sem checagem de papel.
- A resolução de bloqueio (RF-44) usa uma matriz explícita que combina tipo do bloqueio com o(s) papel(is) autorizados a resolvê-lo, não apenas autenticação genérica.
- RLS no banco é a última linha de defesa, não a única: a autorização de negócio (quem pode liberar produção, resolver um bloqueio de determinado tipo, registrar inspeção de qualidade) é responsabilidade explícita do caso de uso na Edge Function antes de tocar o banco.
- Resposta de erro distingue claramente: **401** para sessão ausente/inválida (falha de autenticação) e **403** para membership ou papel insuficiente (falha de autorização). Ambas seguem fail-closed: ausência ou inconclusividade de qualquer checagem resulta em rejeição, nunca em execução permissiva por omissão.

**Contratos e validação de payload**
- Zod é a biblioteca de validação de schema para toda Edge Function, com contratos compartilhados e versionados em módulo próprio (ex.: `contracts/viaxis-vfb-v1.ts`), reutilizável entre validação de entrada, validação de saída e futura geração de tipos para o frontend.
- Cada contrato valida entrada e saída (não só entrada), garantindo que a resposta também respeite o formato acordado.
- O contrato `viaxis.vfb/1` é versionado explicitamente no payload/rota; versões futuras (`viaxis.vfb/2`) podem coexistir com a v1 sem quebrá-la, permitindo transição gradual.
- Payload estrutural ou semanticamente inválido (fora do contrato, campo obrigatório ausente, tipo incompatível) é rejeitado com **HTTP 422** e corpo de erro estável: `{ code, message, details, request_id }`. `details` é sempre seguro para exposição: nunca inclui stack trace, SQL, segredos/credenciais ou dados de outro tenant.
- Conflitos de estado ou de idempotência (ex.: `evento_id` já processado com payload diferente, tentativa de transição de estado inválida) usam código de erro específico, **409**, distinto de 422. Reenvio idêntico de um evento já processado (idempotência válida) não é tratado como erro: retorna sucesso com o resultado já registrado, conforme a garantia de banco já definida na seção Database.

**Integração ViaSign (endpoint de recebimento)**
- Edge Function dedicada de intake (ex.: `viasign-intake`) segue o fluxo: (1) autentica e autoriza conforme RBAC; (2) valida o payload contra o contrato `viaxis.vfb/1` via Zod, rejeitando com 422 quando fora do contrato; (3) verifica idempotência por `(tenant_id, origem, evento_id)`; reenvio idêntico é no-op (sucesso, retorna o registro já existente), payload divergente no mesmo `evento_id` é rejeitado com 409; (4) mapeia IDs externos do ViaSign para itens/fichas internos do ViaFab (RF-13); (5) persiste o evento/revisão de forma imutável, associado ao `origem_ref` (histórico completo, RF-15).
- Quando houver ID externo sem correspondência interna, o evento é **aceito mesmo assim**, persistido de forma imutável e marcado como pendente de mapeamento, preservando o histórico (RF-15) e evitando exigir reenvio do ViaSign para algo que é responsabilidade de mapeamento interno (RF-13). A resposta HTTP indica claramente o estado pendente, podendo usar **202 Accepted** quando o recebimento foi aceito mas ainda não pode ser processado.
- Um evento marcado como pendente de mapeamento não pode gerar nem liberar ordem enquanto o mapeamento não for resolvido.
- A resolução do mapeamento pendente é um caso de uso próprio, autorizado por RBAC (papéis com competência de engenharia/PCP), que associa o ID externo pendente ao item/ficha interno correspondente e é registrado em auditoria (append-only, conforme seção Database).

**Processamento assíncrono (RNF-02)**
- Fila baseada em tabela (`jobs`) consumida por Edge Function worker disparada periodicamente via Supabase Cron. Sem infraestrutura externa (sem `pgmq` ou fila gerenciada de terceiros) enquanto não houver evidência de volume ou requisito de entrega que justifique a complexidade adicional.
- A tabela `jobs` mantém, no mínimo: tipo do job, payload, `status` (`pending`/`running`/`done`/`failed`), contador de tentativas, timestamp de última execução, timestamp de próxima tentativa (`next_attempt_at`), e mensagem de erro sanitizada (sem stack trace, SQL ou segredo).
- O claim de um job pelo worker é atômico (`UPDATE ... SET status = 'running' WHERE status = 'pending' AND (...) RETURNING`, ou equivalente com `SELECT ... FOR UPDATE SKIP LOCKED`), garantindo que dois workers não processem o mesmo job simultaneamente.
- Falha de execução permite retry controlado (backoff incremental via `next_attempt_at`) até um limite de tentativas definido; ao esgotar o limite, o job vai para `failed` sem perder o registro (nunca é apagado), permitindo diagnóstico posterior.
- Todo job é implementado de forma idempotente, já que a entrega é at-least-once (reprocessamento de um job já concluído, por falha de atualização de status por exemplo, não pode duplicar efeito).

**Estratégia de testes de backend**
- **Vitest** cobre o domínio puro: regras de família construtiva, geração de BOM/roteiro, cálculo de conflito de capacidade e transições de estado (ordem, bloqueio, reserva), sem infraestrutura.
- **Testes de integração das Edge Functions** rodam contra uma instância local real do Supabase (migrations e seed aplicados), cobrindo Auth, RLS, triggers de imutabilidade, idempotência e concorrência de reservas de estoque. Casos obrigatórios incluem: 401 (sessão ausente/inválida), 403 (papel insuficiente), 409 (conflito de estado/idempotência com payload divergente), 422 (payload fora do contrato), isolamento entre tenants, sanitização do log de auditoria, fluxo de mapeamento pendente do ViaSign, e retry/idempotência dos jobs assíncronos.
- **Playwright** cobre os fluxos críticos reais pela UI (já definido para o projeto), mas não substitui os testes de integração da API; a camada de API mantém cobertura própria.
- Typecheck e build não são considerados prova funcional; a suíte de testes (Vitest + integração + Playwright) é o critério de validação funcional do backend.

### Frontend

Decisões de nível arquitetural para a camada de interface (UI/UX). Constrói sobre as decisões já fechadas de Database e Backend (RLS multi-tenant, escritas críticas via Edge Functions, contratos Zod versionados, erros 401/403/409/422, fila offline no cliente) e sobre o Design Lock do pacote canônico em `docs/Docs20260820_134109/design/`, sem repeti-las nem contradizê-las.

**Stack base e renderização**
- SPA em **React 19 + TypeScript**, build com **Vite**, publicada como artefato estático na Vercel. Não há Next.js, Remix, SSR nem RSC no MVP: o backend já é integralmente Supabase Edge Functions, e o requisito de operação offline (RF-35, RF-36, RF-38) exige um shell totalmente cacheável e executável sem servidor no chão de fábrica.
- Não há aplicativo nativo (escopo negativo do MVP); a entrega é PWA responsiva instalável via navegador.

**Camada visual e conformidade com o Design Lock**
- O kit **ui-obs** é norma fechada. O `tokens.css` canônico é importado literalmente e é a fonte única de superfícies, texto, bordas, raios, alturas, sombras e escala tipográfica. A única variável de aplicação é o acento da marca ViaFab.
- Estilização por **CSS Modules** consumindo exclusivamente variáveis CSS de token. Valor visual hardcoded (cor, raio, altura, espaçamento fora da escala) é proibido e deve ser barrado por lint no CI.
- Não serão adotados Tailwind, shadcn/ui, MUI, Chakra ou qualquer biblioteca que imponha tema próprio, por risco de drift em relação ao design travado. CSS-in-JS de runtime também está descartado por custo de renderização contra a meta de RNF-01.
- Tipografia JetBrains Sans com numerais tabulares, densidade `dense` e sidebar fixa conforme o design-brief. Tema escuro é o padrão, com alternância para o tema claro persistida em `localStorage`.
- O contraste **WCAG AA** corrigido na `auditoria-design-20260823.md` é requisito permanente: qualquer novo token ou combinação de cor precisa ser verificado antes de entrar.

**Roteamento e organização de código**
- **React Router v7** em modo declarativo com paths reais (ex.: `/ordens`, `/chao-de-fabrica`), mapeados 1:1 com os identificadores de tela do `design-contract.json`. As rotas hash do protótipo estático não são reproduzidas na aplicação real.
- Deep-link é requisito funcional (abrir ordem específica em tablet, QR Code da OS impressa), o que exige rewrite de todas as rotas para `index.html` na Vercel.
- Carregamento **lazy por rota**, evitando que as 24 telas entrem no bundle inicial.
- Guardas de rota por papel (RBAC alinhado aos papéis definidos no Backend), com fallback na tela `acesso-negado` já prevista no contrato. A guarda de UI é conveniência de navegação, nunca controle de segurança: a autorização efetiva permanece na Edge Function e no RLS.
- Organização por feature/domínio (demanda, ordem, planejamento, estoque, execução, qualidade, expedição, auditoria), com camada compartilhada de componentes de design system, cliente HTTP, contratos e infraestrutura offline.

**Estado, dados e cache**
- **TanStack Query** para todo estado de servidor: cache, revalidação, invalidação, retry e atualizações otimistas. Persister em IndexedDB habilita leitura de dados já carregados em estado offline.
- **Zustand** apenas para estado global de UI: tema, estado da sidebar, status de conectividade e contador da outbox. Não há Redux/RTK Query.
- Leituras usam PostgREST via SDK Supabase quando protegidas por RLS e sem invariante cruzada; toda escrita crítica passa obrigatoriamente pelos casos de uso em Edge Functions, conforme já definido na seção Backend. O cliente nunca escreve direto em tabelas de estoque, snapshots, auditoria ou estado de ordem.

**PWA, offline e sincronização**
- Service Worker gerado por **Workbox** via `vite-plugin-pwa`: precache do app-shell e estratégia stale-while-revalidate para leituras não críticas.
- **Outbox tipada em IndexedDB** (Dexie) como fila offline local, coerente com a decisão de Database de manter a fila inteiramente no cliente. Toda ação offline-capable carrega uma `idempotency_key` gerada no cliente, casando com a constraint única por `(tenant_id, idempotency_key)` no banco.
- A fila tem **dois trilhos explícitos**:
  - **Não crítico** (registros de execução, qualidade e eventos sem efeito em saldo): sincroniza automaticamente na reconexão, com retry e backoff, protegido pela `idempotency_key`.
  - **Crítico** (movimentações de estoque): permanece **retido** localmente em estado pendente, sem envio automático. Só é submetido após revisão e **confirmação explícita do usuário** em tela dedicada de reconciliação pós-reconexão (RF-38). Não existe confirmação silenciosa nem linha pendente no ledger do servidor.
- **Background Sync API está descartada**: além do suporte irregular em iOS/Safari (comum nos tablets de fábrica), sincronizar em segundo plano contradiz a confirmação explícita exigida por RF-38.
- Indicador de conectividade (online/offline) e contador de pendências de sincronização ficam **persistentes no shell da aplicação**, visíveis em qualquer tela onde o usuário registre movimentações (RF-36, RF-37, RNF-09), e não apenas na tela ativa.

**Formulários e validação**
- **React Hook Form** com `zodResolver`, reutilizando os contratos Zod versionados definidos na seção Backend como fonte única de schema. Campos não controlados mantêm o custo de renderização baixo em formulários densos como o editor de ficha técnica.
- Validação no cliente é experiência de uso, não autoridade: o servidor revalida integralmente todo payload antes de persistir.
- Erros de campo retornados em `details` no HTTP 422 são mapeados de volta para os campos correspondentes do formulário.

**Primitivos de interação e acessibilidade**
- **Radix UI Primitives** (headless, sem estilo próprio) para diálogo, popover, select, tabs, tooltip e menus, vestidos por CSS Modules sobre os tokens. A escolha entrega foco preso, navegação por teclado, semântica ARIA e portais corretos sem conflitar com o Design Lock. Nenhuma biblioteca de componentes estilizados é introduzida.
- Duas densidades sobre a mesma base de componentes, sem fork: `dense` como padrão (desktop, PCP e engenharia) e `touch` nas telas operacionais (chão de fábrica, estoque, qualidade, expedição), com alvo de toque mínimo de 44x44 px. A troca é resolvida por atributo no container e por tokens de espaçamento e altura, nunca por componente duplicado.
- Navegação completa por teclado, indicador de foco visível baseado em token, skip link, landmarks semânticos e regiões `aria-live` para toasts e para mudanças de status de sincronização.
- `prefers-reduced-motion` respeitado, inclusive no cronômetro de apontamento e nos gráficos animados.

**Componentes de dados densos e visualizações**
- **TanStack Table** (headless) para tabelas de registro, filtros, ordenação e linhas expansíveis, incluindo a árvore de BOM multinível. **TanStack Virtual** para virtualização de listas longas (estoque, auditoria, movimentações).
- Gráficos, Gantt de programação e heatmap de consumo são implementados em **SVG próprio sobre os tokens**, conforme o kit de gráficos já previsto no `design-contract.json`. Recharts, visx, AG Grid e equivalentes estão descartados por imporem tema, tipografia ou licença incompatíveis com a norma travada.

**Tratamento de erro e feedback**
- **Cliente HTTP único** responsável por anexar o JWT, propagar e capturar o `request_id` e traduzir o corpo de erro padronizado `{ code, message, details, request_id }` em comportamento de UI. Não há tratamento ad hoc por chamada.
- **ErrorBoundary por rota**, impedindo que a falha de uma tela derrube toda a aplicação em uso operacional.
- Mapeamento centralizado e obrigatório:
  - **401**: limpa a sessão local e redireciona para `/login` preservando `returnTo`.
  - **403**: tela `acesso-negado` quando for navegação, alerta inline quando for ação pontual.
  - **409**: alerta contextual explicando o conflito de estado ou de idempotência. **Nunca há retry automático** em 409.
  - **422**: erros de campo aplicados ao formulário quando aplicável, sem toast genérico.
  - **5xx e falha de rede**: feedback com `request_id` visível e copiável para correlação com o Sentry, sem expor detalhes internos, stack trace, SQL ou dados de outro tenant.

**Performance interativa e proteção de propriedade intelectual (RNF-01)**
- Edição e preview de configuração técnica operam localmente para atender a meta de 500 ms no p95, usando debounce e `useDeferredValue` para manter a digitação fluida em telas densas.
- **Restrição de preview seguro**: o cliente **não recebe nem executa** a implementação completa das regras proprietárias, coeficientes ou decision tables das famílias construtivas. O frontend consome apenas uma **projeção/contrato seguro**, suficiente para interação e preview, sem permitir reconstrução do motor de regras por engenharia reversa.
- BOM final, roteiro final, validações sensíveis e a criação da ordem são resolvidos e revalidados **exclusivamente no servidor**. O servidor é a autoridade final em qualquer caso.
- Divergência entre o preview local e o resultado do servidor é **reportada explicitamente ao usuário**, nunca mascarada nem descartada para cumprir tempo de resposta (RNF-01).
- Operações de lote e geração de relatórios não bloqueiam a interface, consumindo o processamento assíncrono já definido na seção Backend (RNF-02).

**Estratégia de testes de frontend**
- **Vitest + Testing Library** para unidades e componentes, cobrindo estados de UI, acessibilidade básica, densidades e comportamento de formulários.
- **MSW** para mock no nível de rede, reutilizando os contratos Zod, garantindo que o mock não divirja do contrato real do backend.
- **Playwright** para os fluxos críticos reais pela UI, com cobertura obrigatória de: ciclo offline, reconexão e confirmação explícita de movimentação crítica de estoque; comportamento por papel (RBAC) e acesso negado; os quatro códigos de erro padronizados (401, 403, 409, 422); e regressões visuais e funcionais relevantes nas telas travadas pelo Design Lock.
- Renderização sem erro, typecheck e build **não** são considerados validação de UI. O critério de aceite funcional da interface é a suíte de testes.

### Security

Decisões de nível arquitetural para autenticação, sessão, RBAC detalhado e proteção de dados. Constrói sobre as decisões já fechadas de Database e Backend (RLS multi-tenant via `memberships`, Supabase Auth/JWT, fail-closed, RBAC por papel em cada Edge Function, auditoria append-only), sem repeti-las nem contradizê-las; aqui fecha o detalhamento que faltava nesses temas.

**MFA (autenticação multifator)**
- Obrigatório para `direcao` e para qualquer usuário autorizado a gerenciar memberships, papéis, segredos ou políticas de segurança do tenant.
- Opcional (porém recomendado) para os demais papéis no MVP.
- Ações administrativas sensíveis (alterar papel de outro usuário, revogar sessões, alterar configuração de segurança) exigem step-up/reautenticação quando aplicável, mesmo com sessão MFA já ativa.
- Cada operador tem identidade própria; contas compartilhadas de operador não são usadas como atalho para contornar MFA.

**Sessão e dispositivos compartilhados de chão de fábrica**
- Telas operacionais/`touch` (chão de fábrica, estoque, qualidade, expedição): timeout de inatividade de **15 minutos**. Ao expirar, a sessão é encerrada/bloqueada, exigindo reautenticação individual antes de qualquer nova ação; não é permitido que outro operador continue a sessão do usuário anterior.
- Desktop de PCP/engenharia (densidade `dense`): sessão mais longa, porém com expiração absoluta e logout explícito disponível.
- Access token JWT de curta duração (padrão Supabase, ~1h) com refresh token rotativo.
- A autorização é revalidada contra a tabela `memberships` a cada chamada (já definido na seção Database), portanto revogar papel/membership tem efeito imediato mesmo com access token ainda não expirado.
- Caso de uso administrativo dedicado força a revogação de **todos** os refresh tokens de um usuário (via Admin API do Supabase) em desligamento de funcionário ou suspeita de comprometimento de conta.
- Logout sempre revoga o refresh token da sessão atual.

**Política de senha**
- Mínimo de 12 caracteres, sem exigência de composição artificial (maiúscula/número/símbolo obrigatórios).
- Bloqueio de senhas comprometidas/óbvias (checagem contra lista de senhas vazadas).
- Sem expiração periódica forçada; troca de senha é orientada por evento: recuperação, suspeita de comprometimento ou decisão administrativa.

**Recuperação de senha**
- Link de redefinição por e-mail, token de uso único, expiração curta (30 minutos).
- Ao concluir a troca de senha, todas as sessões/refresh tokens ativos do usuário são revogados.
- Sem recuperação por SMS no MVP.

**Proteção contra brute force**
- Limite de 5 tentativas de login falhas em 15 minutos, com throttling/bloqueio temporário progressivo (não permanente automático).
- Limite aplicado tanto por identidade (e-mail/usuário) quanto por IP, reduzindo brute force direcionado e bloqueio abusivo de conta alheia (DoS por lockout).
- Mensagem de erro genérica no login, sem revelar se o e-mail existe (evita user enumeration).
- Tentativas de login são registradas de forma sanitizada: nunca com senha, token ou e-mail em claro, nem IP bruto. Quando não há tenant autenticado no momento do evento, usa-se um evento de segurança sem tenant ou com identificador anonimizado, mantendo o audit log de negócio (RNF-05) escopado por tenant.
- Rate limiting também se aplica ao endpoint de intake do ViaSign (RF-12) e às demais Edge Functions sensíveis, não apenas ao login.

**RBAC — matriz de permissões por ação**

| Ação | Papel(is) autorizados |
|---|---|
| Criar/gerenciar família construtiva | `engenharia` |
| Criar ordem a partir de demanda/snapshot; cadastro manual de demanda (standalone) | `pcp` |
| Liberar produção | `pcp` |
| Resolver ID externo pendente de mapeamento (ViaSign) | `pcp`, `engenharia` |
| Cadastro de setores e máquinas | `pcp`, `engenharia` |
| Cadastro de depósitos | `almoxarifado`; alterações estruturais podem exigir também `direcao` |
| Entrada, reserva e separação de estoque | `almoxarifado` |
| Início/conclusão de execução, consumo, perdas, retrabalho, registro de bloqueio | `operador`, respeitando o estado da ordem |
| Resolução de bloqueio | por tipo: material → `almoxarifado`; técnico/roteiro → `engenharia`; qualidade → `qualidade`; demais → `pcp`. Matriz explícita no código e transição sempre auditada (RF-44) |
| Inspeção de qualidade | `qualidade` |
| Registro de expedição | `expedicao` |
| Visualização de faltas/necessidades de material | `compras`, somente leitura |
| Visualização do log de auditoria bruto/completo | `direcao`, somente leitura. Demais papéis usam os históricos funcionais do próprio domínio (ex.: histórico da ordem, histórico de bloqueios), não o log bruto |
| Gerenciar usuários, papéis e memberships do tenant | `direcao` no MVP, com MFA obrigatório (ver acima), toda alteração auditada, e proteção explícita contra remover ou desativar o último administrador do tenant (impede tenant órfão sem ninguém autorizado a gerenciar acesso). Não é criado um papel `admin` técnico separado antes de existir necessidade real |

- Cada Edge Function continua declarando explicitamente os papéis autorizados (já definido na seção Backend); esta matriz é a fonte de verdade de negócio para essas declarações.

**Gestão de segredos**
- Segredos (service role key do Supabase, chaves de API, secrets de assinatura) ficam exclusivamente em variáveis de ambiente/secret store do lado servidor (Supabase Edge Functions / Vercel), nunca versionados em repositório, no bundle do frontend, em log ou no audit log.
- Ambientes totalmente segregados: dev, staging e produção têm segredos distintos, sem reuso de chave de produção fora de produção.
- Sem rotação calendarizada fixa obrigatória no MVP. Rotação é orientada por evento e deve ser **imediata** em caso de suspeita de vazamento, troca de administrador com acesso a segredos, ou incidente de segurança, seguindo procedimento documentado.
- Revisão periódica de quem tem acesso a cada segredo/ambiente é feita mesmo sem rotação automática das chaves.

**LGPD e proteção de dados pessoais**
- Minimização de dados pessoais: campos coletados (de clientes nas demandas/ordens e de usuários/operadores) limitados ao necessário para a operação, sem campos especulativos "para o futuro".
- Direitos do titular (acesso, correção, portabilidade, eliminação) são atendidos por processo administrativo/manual no MVP, sem self-service automatizado.
- Ao desligar ou remover um usuário, a identidade operacional é desativada e desvinculada dos dados pessoais associados, preservando apenas um **identificador técnico não reidentificante** necessário à rastreabilidade e à auditoria (RF-31, RF-34). O registro append-only em si não é apagado nem alterado.
- **Pendente de validação jurídica/negócio antes de produção** (não decidido nesta fase como conclusão de conformidade):
  - Base legal aplicável a cada categoria de dado pessoal tratado (clientes e usuários/operadores).
  - Necessidade de DPO formal e de RIPD (Relatório de Impacto à Proteção de Dados).
  - Prazo de retenção definitivo de dados pessoais e de eventual arquivamento/expurgo.
  - **Importante**: a implementação de anonimização/pseudonimização do ator descrita acima é uma guarda técnica, não constitui, por si só, uma declaração de conformidade com a LGPD. A conformidade final depende da validação jurídica dos pontos acima.

**Headers de segurança e CORS**
- **CSP (Content-Security-Policy)** restritiva: `default-src 'self'`, permitindo apenas as origens do Supabase/Vercel estritamente necessárias; sem `unsafe-inline` nem `unsafe-eval` para script.
- **HSTS** habilitado em ambientes HTTPS (produção/staging); não forçado localmente em ambiente de desenvolvimento sem HTTPS.
- `X-Content-Type-Options: nosniff`, `frame-ancestors 'none'`/`X-Frame-Options: DENY`, `Referrer-Policy: strict-origin-when-cross-origin`, e uma `Permissions-Policy` mínima (desabilitando APIs de câmera/microfone/geolocalização não usadas pelo produto).
- **CORS** nas Edge Functions com allowlist explícita do(s) domínio(s) do frontend (Vercel), nunca wildcard (`*`), com tratamento correto de credenciais e de requisições preflight, sem abrir origens adicionais além do allowlist.

**Segurança de dependências**
- **Dependabot** habilitado no repositório para alertas e PRs automáticos de atualização de dependências vulneráveis.
- Scanner de vulnerabilidades compatível com o lockfile do projeto rodando no CI, com **bloqueio de merge** para vulnerabilidades classificadas como altas/críticas, salvo exceção documentada e justificada.
- **CodeQL** (gratuito) como SAST leve para TypeScript/Deno, integrado ao CI.
- Pentest formal fica fora do MVP interno; essa decisão deve ser **revisitada antes de exposição comercial ampla** do produto.

**Retenção do audit log**
- No MVP, o audit log não sofre expurgo automático nem alteração/exclusão de registros (mantém a garantia append-only já definida na seção Database, RNF-05), evitando perda de rastreabilidade.
- Esta é uma **guarda técnica provisória**, não uma conclusão de política de retenção. O prazo definitivo de retenção e eventual estratégia de arquivamento (por custo de storage ou por exigência legal) ficam **pendentes de validação jurídica e de negócio** antes de produção.
