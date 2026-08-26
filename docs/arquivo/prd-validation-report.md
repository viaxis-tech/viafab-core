# Relatorio de Validacao PRD — viafab-core1

> Fonte de verdade da validacao. Status: [PENDENTE] | [APLICADO] | [REJEITADO]

## Problemas identificados

- **P1** [APLICADO] [LACUNA] Cadastro de setores e maquinas ausente. Resolucao: US-30 + RF-39 (cadastro minimo criar/editar/inativar, sem modulo amplo de gestao de ativos).
- **P2** [APLICADO] [LACUNA] Origem das series indefinida. Resolucao: US-33 + RF-45 (serie nasce na conclusao da unidade produzida, vincula ordem, item, deposito e snapshot tecnico; nao gerada no cadastro da demanda). RF-32 referenciado a RF-45.
- **P3** [APLICADO] [LACUNA] Faltava conclusao de operacao. Resolucao: US-19 ampliada (inicio + conclusao com executor, data/hora, status, quantidade) + RF-43; US-24 e RF-30 atualizados para usar inicio e conclusao registrados.
- **P4** [APLICADO] [LACUNA] Faltava gestao minima de estoque. Resolucao: US-31 + RF-40 (cadastro minimo de itens controlados) e RF-41 (entradas atualizando saldo). Fora do MVP explicitado: compras completas, fornecedores, reposicao automatica.
- **P5** [APLICADO] [LACUNA] Restricoes arquiteturais ausentes. Resolucao: nova secao RNF "Arquitetura" com RNF-14 (dominio/contratos desacoplados de UI/infra), RNF-15 (regras de negocio sem acoplamento a preco/plano/limite comercial), RNF-16 (agent-ready sem IA no MVP).
- **P6** [APLICADO] [AMBIGUIDADE] Integracao ViaSign real vs simulada. Resolucao: nota de escopo MVP em US-09 e RF-12 (fixture/simulador atras do contrato viaxis.vfb/1, fronteira e validacao reais, sem conector externo; standalone permanece obrigatorio).
- **P7** [APLICADO] [CRITERIO FRACO] Resolucao de bloqueio indefinida. Resolucao: criterios em US-22 (usuario autorizado por tipo, motivo, responsavel, data/hora, transicao auditada, continuidade so apos resolvido) + RF-44.
- **P8** [APLICADO] [AMBIGUIDADE] 500 ms rigido. Resolucao: RNF-01 reescrito como meta mensuravel p95 <= 500 ms em cenario representativo, sem mascarar falha funcional.
- **P9** [APLICADO] [ORGANIZACAO] Duplicacao RF x RNF. Resolucao: RNF-07, RNF-10, RNF-11, RNF-12 e RNF-13 convertidos em referencias cruzadas para RF-16, RF-14, RF-15, RF-17 e RF-38 (fonte normativa unica, sem mudanca de comportamento).
- **P10** [APLICADO] [LACUNA] Auditoria sanitizada. Resolucao: RNF-05 complementado com sanitizacao/redacao de segredos, credenciais, tokens e dados sensiveis, mantendo apenas campos necessarios a rastreabilidade.
- **P11** [APLICADO] [LACUNA] Persona compras. Resolucao ajustada conforme usuario: US-32 + RF-42 (visualizacao somente leitura de faltas/necessidades de material; pedidos de compra, fornecedores e reposicao automatica explicitamente fora do MVP).
- **P12** [APLICADO] [ORGANIZACAO] Design lock nao referenciado. Resolucao: nota de conformidade no cabecalho apontando design-contract.json como fonte literal e auditoria como complemento de riscos.

## Historico
- 2026-08-24: Analise inicial concluida. 12 problemas identificados, todos PENDENTES.
- 2026-08-24: Usuario aprovou P1-P12 (P11 com ajuste de escopo). Todas as 12 correcoes aplicadas em stories-requisitos.md. Novos artefatos: US-30 a US-33, RF-39 a RF-45, RNF-14 a RNF-16, secao RNF "Arquitetura", nota de Design Lock no cabecalho.
