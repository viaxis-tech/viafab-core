# Discovery Notes

## Visao

### Problema
O ViaFab resolve a desorganização do fluxo de fabricação de sinalização vertical. Hoje a fábrica recebe demandas comerciais e técnicas espalhadas, depende de conhecimento tácito e consolida manualmente engenharia, BOM, materiais, capacidade, produção, qualidade e expedição. Isso gera redigitação, retrabalho, falta de material, promessas de prazo pouco confiáveis e perda de rastreabilidade. O produto transforma uma demanda técnica ou um snapshot do ViaSign em uma ordem fabricável, com família construtiva e parâmetros, BOM e roteiro resolvidos, planejamento por setor e máquina, execução rastreável e vínculo até a expedição.

### Usuario principal
O usuário principal é o responsável pela produção e pelo planejamento da fábrica, normalmente o gerente de produção/engenharia ou o PCP. Ele recebe demandas comerciais e técnicas, confere se são fabricáveis, valida a configuração construtiva, explode a BOM, verifica materiais e capacidade, distribui operações entre setores e máquinas e acompanha prazo, gargalos, perdas, retrabalho, bloqueios e qualidade. No dia a dia, precisa consolidar dados de clientes, engenharia, estoque e chão de fábrica e tomar decisões rápidas sem perder a rastreabilidade. Engenharia, almoxarifado, operadores, qualidade, expedição, compras e direção são usuários secundários.

### Referencia
Não há um produto específico escolhido como benchmark. A referência funcional é um ERP/MES industrial tradicional, com cadastro, estoque, PCP, produção, qualidade e expedição, mas o ViaFab deve ser verticalizado para fabricação de sinalização vertical. O diferencial não é copiar uma tela de ERP genérico: é representar famílias construtivas e regras parametrizadas, resolver BOM e roteiro por geometria, dimensões, materiais, processo e conteúdo, preservar snapshots técnicos e conectar a demanda do ViaSign à execução fabril. A operação atual, planilhas e conhecimento da fábrica são a referência prática que o produto precisa organizar.

### Pitch
ViaFab transforma demandas comerciais e técnicas ou snapshots do ViaSign em ordens de fabricação prontas para execução, resolve família construtiva, BOM e roteiro por parâmetros técnicos, organiza o planejamento por setor e máquina e mantém rastreabilidade da engenharia à expedição, reduzindo redigitação, retrabalho e promessas de prazo sem base.

## Funcionalidades

### Core features
1. Transformar uma demanda técnica ou snapshot em uma ordem fabricável: selecionar a família construtiva, informar parâmetros, validar regras e gerar BOM, roteiro e snapshot técnico versionado.
2. Planejar e liberar a fabricação: verificar materiais, reservar/separar estoque, distribuir operações por setor e máquina, calcular capacidade e identificar conflitos antes da produção.
3. Acompanhar e executar o ciclo até a expedição: registrar início, consumo, perdas, retrabalho, bloqueios e qualidade, comparar planejado versus realizado e manter a rastreabilidade da ordem, séries e envio.

### Integracoes
A integração prioritária é com o ViaSign, com fronteira desacoplada: ViaSign e ViaFab continuam módulos independentes e não compartilham banco. O ViaSign publica uma demanda ou snapshot técnico versionado e imutável, com contrato explícito, e o ViaFab valida, mapeia IDs externos para seus itens/fichas, aceita de forma idempotente e preserva revisões e eventos. No MVP a integração pode ser simulada pelo contrato `viaxis.vfb/1`, mas a fronteira já deve ser realista para a evolução por API. O ViaFab também precisa funcionar standalone com demanda manual quando o ViaSign não estiver disponível. Não há outra integração externa obrigatória definida para o MVP, e integração com agentes não faz parte desta fase.

## Monetizacao

### Modelo
A intenção é comercializar o ViaFab como SaaS B2B por assinatura mensal por empresa. Os planos podem variar por número de usuários, unidades fabris, volume de ordens e módulos de estoque, produção e integração. A primeira validação será na operação própria, mas o produto não deve ser tratado como ferramenta interna. Preço, tiers e cobrança ainda não estão definidos e não devem bloquear o discovery nem o núcleo operacional do MVP.

### Planos
Ainda não há decisão sobre quantidade de planos nem diferenciação comercial. A hipótese inicial é que a diferenciação possa considerar usuários, unidades, volume de ordens, módulos operacionais e integrações, mas isso precisa ser validado depois com clientes e piloto. Para o MVP, o foco é o núcleo operacional e a arquitetura deve evitar acoplar regras de negócio a preços ou limites comerciais.

## Tecnico

### Stack
A stack é a do ecossistema Viaxis: TypeScript, React 19 com Vite e PWA no frontend; PostgreSQL e Supabase para banco, autenticação, RLS multi-tenant e Edge Functions em Deno; Vitest para testes de domínio; Playwright para fluxos reais de UI; GitHub Actions para CI/CD; Sentry e auditoria sanitizada para operação. Vercel hospeda o frontend e o Supabase os serviços de backend. O domínio e os contratos devem permanecer desacoplados da UI e da infraestrutura.

### Plataforma
Precisa funcionar em tablet e celular para almoxarifado, operadores, qualidade e expedição no chão de fábrica. O PCP e a engenharia usam principalmente desktop. No MVP, uma PWA responsiva pelo navegador é suficiente; não há necessidade de aplicativo nativo. A experiência deve considerar conectividade instável, com estado offline explícito e sincronização pendente, sem confirmar silenciosamente movimentações críticas de estoque.

### Database
<!-- Preferencias de banco de dados -->

### Backend
<!-- Preferencias de backend -->

### Frontend
<!-- Preferencias de frontend -->

### Security
<!-- Requisitos de seguranca -->

## Contexto

### Referencias visuais
O repositório já contém o pacote visual canônico do design lock: `docs/Docs20260820_134109/design/artifact.html`, `design-contract.json`, `design-brief.md`, `design-plan.json`, `design-plan-validation.json`, `manifest.json` e `design-lock-report.md`. O `design-contract.json` é a fonte literal para telas, rotas, componentes, estados e contratos de API; o `artifact.html` é a referência navegável de layout. A `auditoria-design-20260823.md` deve ser usada como lista de riscos e decisões abertas, não como substituta do contrato travado.

### Notas adicionais
Há restrições que não podem ser perdidas: o domínio da sinalização deve ser paramétrico, com famílias construtivas e regras reutilizáveis que resolvem cada placa por geometria, dimensões, materiais, processo e conteúdo, sem criar um produto fixo por placa. ViaFab e ViaSign são módulos independentes, com snapshots técnicos versionados e imutáveis na integração. O ViaFab deve funcionar standalone e ser agent-ready na base, mas automação por IA não faz parte do MVP. Segurança é fail-closed, com RLS multi-tenant, auditoria append-only, proteção de dados e rastreabilidade. A UX de edição e preview deve permanecer fluida, idealmente abaixo de 500 ms; operações de lote e relatórios podem ser assíncronas. A primeira validação será na fábrica própria, com pragmatismo e foco em ROI. Quando os documentos divergirem, o pipeline deve registrar a divergência e escalar a decisão, sem inventar requisitos.
