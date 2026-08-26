# Relatorio de Validacao — Stories e Requisitos ViaFab

Fonte: discovery20260820_134109.md vs stories-requisitos20260820_134109.md
Data da analise: 2026-08-20

## Problemas identificados

- **P1** [PENDENTE] [Lacunas] A entidade "Demanda" nunca e criada em nenhuma story. US-04 fala em "liberacao da demanda", US-07 em "demanda de origem" e US-22/US-23 filtram/registram por "cliente, pedido, prazo", mas nao existe story de registro/recebimento da demanda (cliente, pedido, quantidade, prazo). O discovery diz que o PCP "recebe as demandas comerciais e tecnicas". Sem isso, o inicio do fluxo nao tem tela.
- **P2** [PENDENTE] [Lacunas] Nao ha story de cadastro de itens/materiais e depositos. Todo o modulo de estoque (US-11 a US-14) pressupoe itens e depositos cadastrados. O discovery cita explicitamente "cadastro de itens, estoque basico" e "multiplos depositos".
- **P3** [PENDENTE] [Lacunas] Nao ha story de cadastro de setores, maquinas e capacidade. US-09/RF-13 exigem atribuicao a "setor e maquina cadastrados" com "capacidade cadastrada", e o discovery diz que "o MVP registra capacidade e apontamentos manualmente". Sem cadastro, US-09 nao e executavel.
- **P4** [PENDENTE] [Ambiguidades] US-15 diz "a proxima operacao da ordem que devo executar", mas nao define como o operador chega ate ela: falta uma fila/lista de trabalho por setor/maquina/operador. Sem isso o fluxo de chao de fabrica nao tem ponto de entrada desenhavel.
- **P5** [PENDENTE] [Ambiguidades] "Inspecao critica" (US-19, US-22, RF-27, RF-31) nao tem definicao: nao esta claro quando uma inspecao e obrigatoria/critica nem quem define isso. Devs e designers interpretariam de formas diferentes.
- **P6** [PENDENTE] [Criterios fracos] US-07 usa criterio nao deterministico: status inicial "(ex.: aguardando material ou planejada)". RF-10 ja define regra automatica por disponibilidade de material; o criterio da story deve ser alinhado e objetivo.
- **P7** [PENDENTE] [Organizacao] Inconsistencia US-20 x RF-30: RF-30 exige sinalizar no painel do PCP ordens com perda OU retrabalho, mas os criterios de US-20 (perdas) nao mencionam sinalizacao no painel — apenas US-21 (retrabalho) menciona.
- **P8** [PENDENTE] [Criterios fracos] RNF-02 usa "familias construtivas de complexidade padrao", termo subjetivo e nao verificavel. Precisa de definicao objetiva (ex.: numero de niveis/itens da BOM).

## Historico de edicoes

(nenhuma edicao aplicada ainda)
