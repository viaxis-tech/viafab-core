# Plano de Discovery: ViaFab, ERP vertical para fabricação de sinalização vertical

**Data**: 2026-08-20  
**Estágio do produto**: novo, com modelo operacional e seed estruturado, mas sem evidência fornecida de uso em produção  
**Pergunta de discovery**: fábricas de sinalização vertical pagarão por um sistema que transforme uma demanda técnica versionada em planejamento, produção, estoque e expedição rastreáveis, operável por humanos no MVP e pronto para automação futura?

**Legenda**: [Fato do seed] é informação explícita no contexto; [Inferência] é leitura derivada; [Decisão recomendada] é uma escolha de produto a validar.

## 1) Tese do produto e usuários

### Tese

**[Decisão recomendada]** O ViaFab deve ser o sistema de execução industrial da sinalização vertical: recebe uma demanda técnica e versionada, seja do ViaSign ou de uma entrada manual, explode a BOM multinível, verifica materiais e componentes por depósito, agenda setores e máquinas, acompanha a fabricação por etapa e fecha o ciclo com conferência, rastreabilidade e expedição.

O ViaSign continua sendo o produto de centralização, normalização e gestão técnica das placas. O ViaFab continua sendo o produto de planejamento e execução da fábrica. A conexão deve ocorrer por contrato de integração, não por dependência da interface ou do banco do ViaSign.

### Base factual e leitura do problema

- **[Fato do seed]** O seed possui 40 materiais, 66 componentes, 32 produtos, 4 setores, 9 máquinas e 4 depósitos, com referências de BOM validadas e SKUs sem duplicidade.
- **[Fato do seed]** O domínio já representa custo, estoque, estoque de segurança, lead time, lote, múltiplos, perda, setor, máquina, depósito, tempo e componentes multinível.
- **[Fato do seed]** Existem dados de clientes, pedidos, vendas, fornecedores, colaboradores, capacidade, horizonte e conferência.
- **[Fato do seed]** A operação inclui Metalúrgica, Gráfico, Almox e ADESIVAGEM, com máquinas como SOLDA, CORTE, IMPRESSORAS e PLOTTER, além de depósitos de expedição e acabados.
- **[Fato do seed]** O ViaSign já possui placas versionadas, projetos/cenários, `render_model`, área em m², BOM assíncrona por job e isolamento multi-tenant.
- **[Inferência]** O maior problema a provar não é cadastrar uma placa, mas converter especificação técnica em compromisso fabril executável sem perder versão, material, capacidade ou rastreabilidade.

### Usuários

| Usuário | Trabalho a realizar | Papel no MVP |
|---|---|---|
| Dono ou gestor da fábrica | Aceitar pedidos rentáveis, cumprir prazo e enxergar gargalos | Comprador econômico e aprovador |
| PCP ou coordenador de produção | Transformar pedidos em plano, reservas e ordens por setor/máquina | Usuário primário |
| Supervisor de setor | Liberar, acompanhar e reprogramar filas de Metalúrgica, Gráfico, Almox e ADESIVAGEM | Usuário primário |
| Operador | Executar uma tarefa, consumir material, registrar produção, perda e exceção | Usuário operacional |
| Almoxarifado e compras | Separar, transferir, repor e conferir materiais e componentes | Usuário operacional |
| Conferência e expedição | Liberar produto acabado e comprovar o que foi enviado | Usuário operacional |
| Equipe técnica do ViaSign | Publicar a demanda fabricável e sua versão imutável | Sistema parceiro, não usuário do ERP |

**[Decisão recomendada]** O MVP deve otimizar primeiro o trabalho do PCP e dos supervisores, sem criar uma experiência pesada para operadores. O cliente final da placa é afetado pelo prazo e pela qualidade, mas não precisa ser usuário direto do ViaFab no primeiro recorte.

## 2) Jornada ponta a ponta

| Etapa | Fluxo de negócio específico | Saída auditável |
|---|---|---|
| 1. Demanda | Pedido entra manualmente no ViaFab ou chega do ViaSign como demanda técnica versionada | `demand_id`, cliente/projeto, quantidade, prazo, prioridade e origem |
| 2. Liberação técnica | ViaFab confere se o snapshot está imutável, se a versão está pronta e se o job de BOM terminou | Aceite, pendência ou rejeição com motivo |
| 3. Identificação | Cada item técnico é relacionado a um produto `PRD-*`, componente `FT-*` ou material `MAT-*`, sem depender do SKU do ViaSign | Mapeamento externo-interno versionado |
| 4. Explosão de BOM | A BOM multinível é explodida considerando quantidade líquida, perda, unidade, lote e múltiplos | Necessidades de materiais e componentes |
| 5. Disponibilidade | Estoque é verificado por depósito, com reserva, estoque de segurança, lead time e transferência quando necessário | Reserva, falta, compra ou ordem interna sugerida |
| 6. Planejamento | O PCP distribui operações entre setores e máquinas, respeitando dependências, capacidade diária, horizonte e prazo | Plano e ordens de produção |
| 7. Separação | Almoxarifado separa insumos para a ordem e registra lote, depósito e divergências | Kit ou pendência de material |
| 8. Fabricação | A ordem percorre a rota aplicável, por exemplo CORTE/SOLDA, Gráfico/IMPRESSORAS ou PLOTTER e ADESIVAGEM/MONTAGEM, conforme a definição do produto | Início, pausa, conclusão, consumo, perda e operador por etapa |
| 9. Exceções | Falta de material, quebra de máquina, retrabalho, perda acima do previsto ou mudança de versão bloqueiam ou replanejam a ordem | Evento de exceção com autor, origem e decisão |
| 10. Conferência | Produto e quantidade são conferidos antes da liberação, incluindo vínculo ao pedido e à versão técnica | Aprovação, reprovação ou retrabalho |
| 11. Acabado | Itens são transferidos para o depósito de acabado adequado, como Acabados - MET, Acabados - ADES ou Acabados - ALMOX | Saldo e localização atualizados |
| 12. Expedição | A saída é registrada no depósito Expedição, com itens, quantidade e rastreabilidade da ordem | Evento de envio e fechamento operacional |
| 13. Retorno | ViaFab publica status da fabricação para o ViaSign ou para outros consumidores, sem expor banco ou UI internos | Ciclo de vida sincronizado |

**[Decisão recomendada]** O MVP deve permitir começar sem ViaSign, por entrada manual, e tratar a integração como uma segunda porta de entrada para o mesmo núcleo de execução. Isso preserva a venda independente do ViaFab e testa se o valor operacional existe por si só.

## 3) Módulos e recorte do MVP

### Ideação divergente

| Perspectiva | Cinco ideias geradas |
|---|---|
| Product Manager | 1. Demanda versionada para ordem fabricável; 2. MRP de BOM multinível; 3. PCP por gargalo e capacidade; 4. Rastreabilidade de custo, prazo e qualidade; 5. ViaFab standalone com conector ViaSign |
| Product Designer | 1. Cockpit de exceções do PCP; 2. Fila simples por setor e máquina; 3. Linha do tempo visual da placa e da versão; 4. Separação guiada por depósito; 5. Checklist de conferência e expedição |
| Engenheiro de Software | 1. Motor determinístico de explosão de BOM; 2. Contrato de eventos idempotente com o ViaSign; 3. Reserva e movimentação por depósito; 4. Motor de capacidade e dependências; 5. Livro de auditoria com autor, origem e permissão |

Como o produto é novo, a priorização pesa mais o valor central e a velocidade de validação do que otimizações avançadas.

### Cinco ideias selecionadas

| Ideia | Descrição | Por que foi selecionada | Assunções-chave |
|---|---|---|---|
| 1. Demanda técnica para ordem fabricável | Converte um snapshot do ViaSign ou um pedido manual em uma demanda pronta para planejar | É a fronteira entre ViaSign e ViaFab e evita redigitação, perda de versão e ambiguidade | A demanda contém informação suficiente; o mapeamento técnico é sustentável; o PCP confia no aceite |
| 2. BOM multinível e MRP vertical | Calcula necessidades de `MAT-*` e `FT-*` usando perda, lote, lead time, estoque e depósito | Ataca diretamente falta de material e torna o domínio vertical defensável | A BOM representa a fabricação real; perdas e unidades são confiáveis; sugestões são úteis |
| 3. PCP por setor, máquina e capacidade | Agenda ordens entre Metalúrgica, Gráfico, Almox e ADESIVAGEM respeitando dependências | O valor é operacional: prometer prazo sem enxergar gargalo é uma falha central | `capacidadeDia`, tempos e rotas refletem a fábrica; o plano será seguido ou ajustado |
| 4. Execução humana rastreável | Cada setor registra o mínimo necessário para iniciar, consumir, produzir, perder, bloquear e concluir | Entrega valor sem agente de IA e cria a base auditável para automação futura | Operadores conseguem registrar em poucos passos; supervisores mantêm os dados vivos |
| 5. Estoque, conferência e expedição por depósito | Fecha o ciclo com reserva, transferências, acabados, conferência e envio | Evita que o ERP pare no planejamento e conecta produção ao resultado entregue | Saldos têm precisão suficiente; a conferência aceita o fluxo; rastreabilidade reduz retrabalho |

**Checkpoint de priorização:** para esta execução, as cinco ideias acima seguem para estresse-testes. A primeira decisão a reabrir é se a proposta deve começar pela integração ViaSign ou pelo fluxo standalone de uma fábrica.

### Módulos do MVP

| Prioridade | Módulos | Recorte recomendado |
|---|---|---|
| Must | Cadastros industriais | Materiais, componentes, produtos, BOM multinível, unidades, perdas, lotes, lead times, setores, máquinas e depósitos |
| Must | Demanda e ordem | Entrada manual e contrato ViaSign; pedido, quantidade, prazo, prioridade, versão, aceite e rejeição |
| Must | MRP e reserva | Explosão de BOM, saldo por depósito, estoque de segurança, reserva, falta, transferência e sugestão de compra/produção |
| Must | PCP | Horizonte, capacidade diária, dependências, fila por setor/máquina, ordem liberada, bloqueio e replanejamento manual |
| Must | Chão de fábrica | Registro simples de início, pausa, conclusão, consumo, perda, retrabalho, operador e motivo de exceção |
| Must | Estoque e rastreabilidade | Movimentações, lotes quando aplicável, depósitos de acabados, vínculo entre demanda, ordem, consumo e produto |
| Must | Conferência e expedição | Checklist mínimo, aprovação/reprovação, transferência para Expedição e fechamento do envio |
| Must | Base agent-ready | Comandos determinísticos, idempotência, auditoria de autor/origem/permissão, estados explícitos, APIs e eventos versionados |
| Should | Compras operacionais | Fornecedor, pedido de compra, prazo prometido, recebimento e impacto no plano |
| Should | Cockpit de exceções | Faltas, atraso, capacidade excedida, perda fora do padrão, versão alterada e ordens bloqueadas |
| Should | Custos e indicadores | Custo planejado versus realizado, prazo, perda, aderência ao plano e taxa de retrabalho |
| Should | Integração de retorno | Publicação de status e motivos para ViaSign, com suporte a parcial e replanejamento |
| Later | Otimização avançada | Sequenciamento automático, simulação de cenários e otimização de corte/capacidade |
| Later | Automação inteligente | Agentes de planejamento, compras ou acompanhamento; não faz parte do MVP |
| Later | Superfícies adicionais | Portal do cliente final, IoT de máquinas, visão computacional, app offline completo e previsão de demanda |

**Recorte de saída do MVP:** uma fábrica consegue receber uma demanda, planejar uma ordem, reservar o necessário, executar uma rota real, registrar perdas e concluir a expedição com vínculo até a versão técnica. Cadastros financeiros completos, otimização automática e agente de IA ficam fora.

## 4) Interface de integração ViaSign-ViaFab

### Princípio de fronteira

**[Fato do contexto]** O ViaSign publica uma demanda técnica e versionada; o ViaFab transforma essa demanda em planejamento, produção, estoque e expedição.  
**[Decisão recomendada]** A integração deve funcionar por API e eventos, com payload próprio e contrato versionado. Nenhum produto consulta a UI ou o banco interno do outro.

### Contrato de entrada recomendado, `manufacturing.demand.v1`

| Grupo | Campos mínimos |
|---|---|
| Identidade | `event_id`, `idempotency_key`, `tenant_id`, `source_system`, `occurred_at` |
| Origem técnica | `source_demand_id`, `project_id`, `scenario_id`, `plate_version_id`, `snapshot_id`, `snapshot_version`, `snapshot_hash` |
| Estado técnico | `bom_job_id`, `bom_status=READY`, referência ao snapshot imutável e data de publicação |
| Fabricação | `items[]`, `external_item_id`, quantidade, unidade, área em m² quando aplicável, atributos técnicos e prazo solicitado |
| Governança | autor/origem, permissão, correlação e contato de exceção |

O payload pode carregar o snapshot ou uma referência resolvível a ele, mas o ViaFab precisa conseguir reproduzir exatamente o que foi publicado. O SKU interno não deve ser presumido: deve existir um mapeamento explícito entre identificadores do ViaSign e `PRD-*`, `FT-*` e `MAT-*` do ViaFab.

### Resposta e ciclo de vida

1. ViaFab responde `accepted`, `rejected` ou `pending_validation`, sempre com motivo e `viafab_demand_id` quando houver criação.
2. O ViaFab publica `planned`, `materials_reserved`, `in_production`, `blocked`, `replanned`, `quality_released`, `ready_to_ship`, `shipped` ou `cancelled`.
3. Cada evento leva `source_snapshot_id`, `source_snapshot_version`, `viafab_demand_id`, `order_id`, `event_id`, `occurred_at`, autor e origem.
4. Reenvio do mesmo snapshot e versão deve ser idempotente. Uma nova versão não sobrescreve a anterior: cria revisão, impacto e decisão de replanejamento.
5. BOM assíncrona em processamento não deve virar ordem silenciosamente. O ViaSign publica somente quando o job estiver pronto ou publica uma falha explícita para tratamento.
6. O ViaFab continua utilizável com demanda manual, sem credencial ou disponibilidade do ViaSign.

### Estados recomendados

- **ViaSign**: publicação técnica pronta, substituída, cancelada ou com erro de BOM.
- **ViaFab**: recebida, validando, planejada, reservada, em produção, bloqueada, replanejada, em conferência, pronta para expedição, expedida ou cancelada.

**Guardrail recomendado:** uma alteração de versão depois de reserva ou início de produção exige uma operação explícita de revisão, cancelamento ou replanejamento. Nunca atualizar silenciosamente a ordem existente.

## 5) Riscos e assunções priorizados por impacto x incerteza

Escala: impacto e incerteza de 1 a 5; prioridade = impacto × incerteza. A incerteza é a aproximação operacional de baixa confiança. Os riscos de esforço serão refinados ao desenhar cada experimento.

| # | Assunção que pode falhar | Categoria | Impacto | Incerteza | Prioridade | Base e teste sugerido |
|---|---|---:|---:|---:|---:|---|
| A1 | Gestores de fábricas pagarão para reduzir atraso, falta de material e retrabalho | Valor | 5 | 5 | 25 | [Inferência] Validar com pré-venda ou piloto pago, não apenas interesse |
| A2 | Uma demanda técnica versionada contém informação suficiente para abrir uma ordem fabricável | Valor | 5 | 5 | 25 | [Inferência] Rodar concierge com demandas reais e medir retrabalho estrutural |
| A3 | BOM multinível, perdas, unidades e rotas do seed representam a fabricação real | Factibilidade | 5 | 4 | 20 | [Fato] O modelo está consistente; [Inferência] ainda falta prova no chão de fábrica. Fazer shadow planning |
| A4 | PCP entende e usa o plano por setor, máquina, dependência e capacidade | Usabilidade | 4 | 5 | 20 | Observar um ciclo de planejamento e medir aceitação/alterações |
| A5 | Operadores registrarão eventos sem interromper a produção | Usabilidade | 4 | 5 | 20 | Wizard of Oz em uma rota com medição de tempo e completude |
| A6 | Estoque por depósito é suficientemente correto para reservar e separar | Viabilidade | 5 | 4 | 20 | Comparar saldo sistêmico e contagem física em ordens-piloto |
| A7 | Capacidade diária, tempos e máquinas existentes permitem um plano útil | Factibilidade | 5 | 4 | 20 | Spike/backtest com ordens, tempos e restrições reais |
| A8 | O mercado-alvo tem canal, urgência e disponibilidade para um piloto | Go-to-market | 4 | 5 | 20 | Landing segmentada com CTA de piloto pago e 10 conversas qualificadas |
| A9 | ViaFab tem valor mesmo quando vendido sem ViaSign | Estratégia e objetivos | 5 | 4 | 20 | Rodar o fluxo manual standalone e medir intenção de compra/uso |
| A10 | O custo de implantação e suporte humano do MVP cabe na economia do produto | Viabilidade | 5 | 4 | 20 | Estimar onboarding por fábrica durante o concierge e cobrar o piloto |
| A11 | O time consegue manter cadastros, contratos e implantação em uma primeira fábrica | Time | 4 | 4 | 16 | Fazer um piloto com dados reais e registrar horas por função |
| A12 | Auditoria e bloqueios de qualidade não criarão incentivo para burlar registros | Ética | 4 | 3 | 12 | Tornar autor, permissão, motivo de alteração e conferência obrigatórios; observar exceções |

### Matriz de decisão

- **Alto impacto, alta incerteza: desenhar experimento agora.** A1, A2, A3, A4, A5, A6, A7, A8, A9 e A10.
- **Alto impacto, incerteza menor: seguir com guardrails e implementação mínima.** A12, junto de auditoria, permissões e conferência obrigatória.
- **Baixo impacto, alta incerteza: adiar ou rejeitar do MVP.** Agente de IA, otimização avançada, IoT, visão computacional e portal do cliente.
- **Baixo impacto, baixa incerteza: adiar sem bloquear a tese.** Relatórios sofisticados e automações de conveniência.

**Checkpoint de foco:** sem interromper a execução, assumo como primeiro lote de validação A1, A2, A3, A4 e A6. A5 entra logo depois em um piloto de chão de fábrica; A7 e A9 protegem a arquitetura e a venda independente.

## 6) Experimentos de discovery

O produto é novo, então a ordem prioriza desejabilidade e disposição a pagar antes de construir automação. Os experimentos medem comportamento real e coletam dados próprios, em vez de depender de relatórios de mercado.

| # | Testa a assunção | Método | Métrica | Critério de sucesso | Esforço | Timeline |
|---|---|---|---|---|---|---|
| E1 | A1, A8, A9, A10 | Landing segmentada + demonstração manual + pré-venda de piloto pago | Pilotos pagos ou depósito; CTR é secundário | Pelo menos 2 pilotos pagos ou depósitos de 10 empresas qualificadas | Baixo | Semana 1 |
| E2 | A2, A3, A6 | Concierge: snapshot técnico, mapeamento, BOM, MRP e ordem criados manualmente com PCP | Demandas aceitas sem retrabalho estrutural, tempo até planejar, faltas encontradas antes da liberação | 8 de 10 demandas utilizáveis, 90% das faltas críticas identificadas, até 30 min por demanda | Médio | Semana 2 |
| E3 | A3, A4, A6, A7 | Shadow planning de uma semana usando seed e dados reais de uma fábrica, sem alterar a operação | Ordens alocadas, conflitos detectados, aderência do PCP ao plano | 80% das ordens alocadas em rota válida e 90% dos conflitos relevantes identificados antes da produção | Médio | Semana 2 |
| E4 | A5, A12 | Wizard of Oz em uma rota real, com tela ou formulário simples para registrar execução, perdas e conferência | Completude dos eventos, tempo por registro, exceções sem rastreio | 85% dos eventos registrados no turno, mediana de até 2 min por registro e nenhum acabado sem vínculo à ordem | Médio | Semana 3 |
| E5 | A6, A7, A9 e base agent-ready | Spike técnico do contrato API/eventos com reenvio, duplicidade, evento fora de ordem, BOM pendente e nova versão | Idempotência, preservação de versão, mensagens de erro e isolamento do ViaSign | 100% dos duplicados sem ordem duplicada, 100% das versões antigas preservadas e 95% dos erros acionáveis | Baixo/médio | Semana 2 |

### Detalhes dos experimentos

#### E1. Pré-venda de piloto pago

- **Hipótese XYZ:** pelo menos 20% de 10 gestores de fábricas de sinalização vertical com pedidos ativos aceitarão pagar por um piloto que transforma demanda técnica em plano e acompanha a fabricação.
- **Setup:** mensagem única, landing curta, demonstração de uma jornada com placa versionada, chamada para depósito ou contrato de piloto. Recrutar decisores, não apenas curiosos.
- **Medição:** depósito/pagamento é a métrica principal; resposta ao CTA e reunião realizada são sinais secundários.
- **Decisão:** sucesso libera piloto concierge e PRD do caminho principal. Falha com baixa intenção de pagamento exige revisar comprador, dor ou embalagem antes de construir.

#### E2. Concierge ViaSign para ViaFab

- **Hipótese XYZ:** pelo menos 80% de 10 demandas técnicas prontas, vindas de 3 fábricas, serão convertidas em ordens sem interpretação manual relevante do projeto.
- **Setup:** receber snapshot imutável e versão, mapear itens para `PRD-*`, `FT-*` e `MAT-*`, explodir a BOM, reservar o que existir e produzir um plano manualmente assistido.
- **Medição:** retrabalho por item, tempo de aceite, linhas de BOM não mapeadas, faltas e divergências de versão.
- **Decisão:** se falhar por dados do ViaSign, estreitar o contrato de entrada; se falhar por modelo industrial, reduzir o primeiro segmento ou corrigir a BOM antes do produto completo.

#### E3. Shadow planning de estoque e capacidade

- **Hipótese XYZ:** pelo menos 80% dos pedidos da semana de uma fábrica poderão ser alocados em rotas e máquinas válidas, com as principais faltas e conflitos detectados antes da produção.
- **Setup:** usar o seed como base inicial e anexar uma amostra real de pedidos, saldos, tempos, lotes e capacidade. Comparar o plano do ViaFab com a prática do PCP.
- **Medição:** ordens sem rota, sobrecarga por máquina, reserva impossível, atraso previsto, alterações feitas pelo PCP e motivos.
- **Decisão:** sucesso valida o núcleo de PCP. Falha por dados incompletos pede implantação de cadastros e importação; falha por regra de negócio pede recorte de rota/capacidade.

#### E4. Execução humana em uma rota

- **Hipótese XYZ:** pelo menos 85% dos operadores de uma célula registrarão início, consumo, perda e conclusão no turno sem aumentar a mediana do registro acima de 2 minutos.
- **Setup:** escolher uma rota real, com poucos campos e opção de bloqueio. O facilitador pode operar o sistema por trás para simular o produto, mantendo a decisão e o registro próximos do operador.
- **Medição:** eventos completos, tempo, registros feitos depois do turno, perda não explicada, retrabalho e conferência sem vínculo.
- **Decisão:** sucesso libera o desenho de telas operacionais. Falha pede reduzir campos, mudar o ponto de registro ou limitar o MVP a supervisores até a interação amadurecer.

#### E5. Spike do contrato de integração

- **Hipótese XYZ:** pelo menos 95% de 20 cenários de integração, incluindo duplicidade, reenvio e nova versão, serão processados de forma determinística e auditável.
- **Setup:** criar fixtures derivadas do modelo fornecido, simular job de BOM pendente/pronto, publicar demanda, reenviar, atrasar eventos e publicar uma revisão.
- **Medição:** duplicidade de ordens, sobrescrita de snapshot, correlação perdida, mensagem de erro e autorização incorreta.
- **Decisão:** sucesso congela o contrato v1 para o piloto. Falha exige separar ainda mais o adaptador ViaSign do domínio ViaFab e não avançar com integração acoplada.

### Cronograma de discovery

- **Semana 1:** pré-venda de piloto, recrutamento de fábricas, observação de um fluxo real, coleta de demandas e rascunho do contrato.
- **Semana 2:** concierge ViaSign/ViaFab, shadow planning de BOM/estoque/capacidade e spike de idempotência.
- **Semana 3:** Wizard of Oz no chão de fábrica, análise dos limiares, decisão de recorte e preparação do PRD.

### Framework de decisão

- **Se E1 e E2 tiverem sucesso:** avançar para piloto pago controlado e PRD do fluxo demanda → ordem → planejamento.
- **Se E1 falhar e E2 tiver sucesso:** pivotar comprador, preço ou canal; não assumir que utilidade operacional gera compra automaticamente.
- **Se E2 falhar por snapshot/BOM:** estreitar o contrato técnico ou o primeiro tipo de placa; não ampliar o catálogo.
- **Se E3 falhar por dados de capacidade/estoque:** criar uma etapa de saneamento e implantação, mantendo o PCP manual assistido.
- **Se E4 falhar:** simplificar a experiência e reduzir o escopo de apontamento; não adicionar agente ou automação para compensar baixa adoção.
- **Se E5 falhar:** corrigir o contrato e o adaptador; não compartilhar banco ou criar dependência da UI do ViaSign.

## 7) Backlog dos próximos 10 passos

| # | Próximo passo | Saída de decisão |
|---:|---|---|
| 1 | Recrutar 3 a 5 fábricas de sinalização vertical com pedidos ativos e PCP identificável | Amostra de discovery e segmento inicial |
| 2 | Coletar 10 demandas reais anonimizadas, incluindo desenho/snapshot, quantidade, prazo e versão | Base para E1/E2 |
| 3 | Coletar para os mesmos casos BOM, estoque por depósito, perdas, tempos, máquinas e capacidade | Diagnóstico de suficiência do modelo |
| 4 | Observar uma ordem ponta a ponta e medir espera, retrabalho, falta, apontamento e conferência | Baseline comportamental |
| 5 | Congelar o glossário e a máquina de estados do ViaFab, incluindo operação standalone | Fronteira do MVP |
| 6 | Especificar `manufacturing.demand.v1`, mapeamento de IDs e política de revisão de snapshot | Contrato ViaSign-ViaFab |
| 7 | Rodar E1 e obter compromisso financeiro ou evidência clara de rejeição | Prova inicial de valor e GTM |
| 8 | Rodar E2 e E3 em uma amostra limitada, comparando plano, BOM e estoque com a prática | Prova do núcleo operacional |
| 9 | Rodar E4 e E5, registrando horas de suporte e falhas de adoção/integração | Prova de operação humana e agent-readiness |
| 10 | Fazer o gate: avançar, pivotar, estreitar ou matar; então criar o PRD, métricas e user stories apenas do caminho aprovado | Decisão de investimento do MVP |

O documento deve ser atualizado depois de cada experimento com evidência observada, limiar atingido, assunção reclassificada e decisão tomada.
