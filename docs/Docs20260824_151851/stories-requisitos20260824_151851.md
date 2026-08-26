# User Stories e Requisitos — ViaFab Fase 0+1 (decisões de produto + correção dos 22 P0)

> Base: `docs/Docs20260824_151851/discovery20260824_151851.md`, `docs/auditoria-design-20260823.md` e leitura direta de `prototype/index.html` (~24.000 linhas) e das migrations em `supabase/migrations/`. Referências de linha seguem a numeração citada na auditoria de 23/08 e foram conferidas por amostragem nesta análise; podem ter deslocado poucas linhas desde então, mas os nomes de função/variável citados foram confirmados no código atual.

## Como ler este documento

- Cada user story referencia, quando aplicável, a função, variável ou tabela do protótipo/backend que ela altera.
- Os IDs P0-01 a P0-22 (22 bloqueios da auditoria), D-01 a D-13 (decisões de produto) e S6/S7/S8/S9-S11 (pendências do relatório de validação de sprints) são citados entre parênteses para rastreabilidade com o discovery.
- Decisões adiadas nesta rodada (D-07, D-08, D-10, D-13) não geram requisito de implementação aqui: ficam registradas na seção final como pendência humana, conforme o discovery.
- Validação de 24/08 contra o código: o protótipo já contém parte das correções P0 aplicadas (P0-02 parcial, P0-11, P0-12, P0-13, P0-17 e P0-21 quase integral). As stories correspondentes (US-07, US-14, US-15, US-16, US-20, US-25) estão redigidas como verificação/regressão do já implementado, destacando apenas o gap remanescente.

---

## Domínio A — Ficha técnica: rascunho, publicação e roteiro por ficha

Base de schema já existente: `supabase/migrations/20260824140000_engenharia_catalogo_tables.sql` já define `ficha_status` como enum (`rascunho`, `publicada`) na tabela `fichas_tecnicas`; `supabase/migrations/20260824140200_engenharia_versionamento_triggers.sql` já implementa `fn_versao_ficha()` e bloqueia UPDATE de conteúdo (só `status`/`vigencia_inicio` são editáveis; nova versão exige INSERT). O protótipo (`prototype/index.html`) ainda não reflete esse modelo.

### US-01 (Engenharia)
Como engenheiro(a) de produto, quero editar uma ficha técnica em uma cópia de rascunho sem afetar a versão publicada, para não corromper snapshots usados por ordens em execução.

Critérios de aceite:
- Editar uma ficha grava em uma cópia de trabalho distinta da versão vigente ("publicada"), espelhando o enum `ficha_status` (`rascunho|publicada`) já existente no schema.
- Existe ação "Descartar" que reverte a cópia de trabalho para o conteúdo da última versão publicada, sem gerar nova linha em `fichas_tecnicas`.
- Trocar de ficha (navegação para outro item) com rascunho não publicado/descartado é interceptada por confirmação explícita de perda de alteração.
- A lista de "fichas não publicadas" na tela de Engenharia (área em torno de `renderFichaLista`, linha ~19809) passa a refletir o estado real de rascunho, hoje incorreto (P0-06).

### US-02 (Engenharia / PCP)
Como engenheiro(a) de produto, quero que a publicação de uma ficha me avise quais ordens abertas serão afetadas, para decidir conscientemente entre aplicar a nova versão ou manter o snapshot já em uso.

Critérios de aceite:
- Ao publicar, um modal lista as ordens abertas (não expedidas) cujo `snap`/`cfg` referenciam a ficha (campos já usados em `renderOrdem`, linha ~15969), segmentadas em "afetadas" e "não afetadas".
- Publicar sem ordens abertas segue direto; publicar com ordens abertas exige confirmação explícita, com opção de fallback declarada (manter snapshot atual da ordem ou herdar a nova versão).
- A publicação sempre gera nova linha versionada em `fichas_tecnicas` (nunca UPDATE de conteúdo), coerente com `fn_versao_ficha()` e a trigger de imutabilidade já existentes.
- Uma faixa visível na tela de detalhe da ficha nomeia as ordens afetadas antes da confirmação de publicação (P0-07).

### US-03 (Engenharia / PCP)
Como engenheiro(a) de produto, quero que o roteiro de fabricação de cada ordem seja derivado da ficha técnica do produto, para que tempo e máquina por operação reflitam o processo real do item, não uma tabela genérica.

Critérios de aceite:
- A ficha técnica ganha uma aba "Roteiro" com lista de operações editável (setor, máquina, tempo padrão por unidade).
- `roteiroDe(id)` (linha ~15956) passa a derivar o roteiro da ficha do produto da ordem, não mais do roteiro base global fixo de 7 operações.
- Produtos com fichas diferentes podem ter número de operações, setor e tempo diferentes entre si no roteiro resultante.
- Tempo padrão e máquina por operação tornam-se editáveis na ficha (hoje ineditáveis, P0-08); escopo reconhecido como +2 a 3 dias adicionais de esforço, conforme D-02 aceita.

---

## Domínio B — Planejamento e execução no chão de fábrica

### US-04 (PCP)
Como PCP, quero ver um preview das ordens que serão geradas antes de confirmar "Gerar ordens", para não destruir a fila de planejamento sem chance de reverter.

Critérios de aceite:
- A ação hoje executada direto ao clique (fluxo em torno de `gerarOrdensDoPlano()`, linha ~22275) passa a abrir um modal de confirmação antes de gravar qualquer ordem em `DB.ordens`.
- O modal lista, por ordem a criar: produto, quantidade, faltas de material identificadas e componentes que serão consumidos.
- O botão "Gerar ordens" exibe rótulo vivo com a quantidade que será gerada (ex.: "Gerar 4 ordens"), atualizado conforme o conteúdo da fila de planejamento (parte do fix de P0-01: "rótulo vivo + modal").
- A geração efetiva só ocorre após confirmação explícita no modal.
- A ação gerada é registrada via `audit()` com a quantidade de ordens criadas e o plano de origem (mantido por coerência com RNF-06).

### US-05 (Operador / PCP)
Como operador, quero confirmar a finalização de uma operação vendo o efeito calculado no estoque antes de aplicar, para evitar duplicar baixa de material ao reabrir uma ordem desbloqueada.

Critérios de aceite:
- Finalizar uma operação exibe confirmação com o efeito de consumo já calculado por `matDaOperacao(o, setor)` (linha ~20867) antes de gravar a baixa.
- Uma operação já finalizada e baixada não pode ser finalizada de novo sem passar por um evento explícito de desbloqueio que reabre a operação (mesmo padrão de `evento(o.id, 'Bloqueio liberado', ...)`, linha ~16064-16066).
- Correções de apontamento finalizado respeitam janela de 10 minutos, registradas como nova linha, compatível com o padrão `estornos_apontamento` já descrito em `CLAUDE.md` (append-only).
- O mesmo guard-rail cobre o caminho de reabertura por reprovação de qualidade (P0-05), eliminando o efeito cascata entre P0-04 e P0-05 identificado na auditoria.

### US-06 (Almoxarifado / PCP)
Como almoxarife, quero que "Reservar materiais" estorne a reserva anterior antes de somar uma nova, e possa liberar uma reserva feita, para que o saldo reservado nunca fique duplicado ou preso.

Critérios de aceite:
- Reservar materiais para uma ordem que já possui reserva em `DB.reservas` estorna a reserva vigente antes de calcular e gravar a nova; nunca soma sobre o valor existente.
- Existe botão "Liberar" que devolve o saldo reservado ao disponível e gera evento/auditoria.
- A ação "Recalcular" exibe o delta entre a reserva vigente e a nova necessidade calculada, não apenas o valor final.

---

## Domínio C — Handoffs entre papéis (Qualidade / Expedição)

### US-07 (Qualidade)
Como analista de qualidade, quero uma fila de "Aguardando inspeção" visível assim que uma ordem é concluída na produção, para não deixar peças paradas sem que ninguém saiba que precisam de inspeção.

Estado atual: o card "Aguardando inspeção" com contagem (`#qa-fila-n`, linha ~1515) já existe no protótipo (P0-02 parcialmente aplicado).

Critérios de aceite:
- Verificação/regressão: o card "Aguardando inspeção" na tela de Qualidade (`renderQualidade()`, linha ~16687) exibe contagem correta em `#qa-fila-n`, alimentada automaticamente por toda ordem concluída sem parecer de qualidade (`o.qa` pendente).
- Gap remanescente: a mesma contagem passa a aparecer no resumo crítico da tela Início para os perfis com permissão de leitura em qualidade.

### US-08 (Expedição)
Como expedidor(a), quero ver quantas unidades estão retidas pela qualidade e por quê, para não tratar o depósito como vazio quando na verdade está fisicamente cheio.

Critérios de aceite:
- Stat "Retidas pela qualidade" na tela de Expedição (`renderExpedicao()`, linhas ~17031-17043) com contagem total de unidades e número de ordens sem parecer ou reprovadas.
- Blocos de expedição referentes a itens retidos ficam desabilitados com motivo explícito e ação (CTA) para acompanhar o status na Qualidade.

### US-09 (Qualidade / PCP)
Como analista de qualidade, quero que uma reprovação indique claramente o próximo passo, para que a recuperação de uma peça reprovada não dependa de um caminho não documentado.

Critérios de aceite:
- Ao reprovar, o sistema apresenta o próximo passo (card de reprovação no posto do operador correspondente).
- Desbloquear uma ordem bloqueada por reprovação de qualidade reseta o parecer (`delete o.qa`) e reabre a última operação do roteiro (`status='Pendente'`, `baixado=false`), reproduzindo de forma consistente em toda a jornada de reprovação o comportamento já presente em `renderOrdem` (linhas ~16057-16064).
- O retrabalho gera evento (`evento(o.id, 'Retrabalho aberto', ...)`) e registro de auditoria.

---

## Domínio D — Importação de pacotes ViaSign (.vfb) e pedidos

### US-10 (PCP / Comercial)
Como responsável por pedidos, quero que a importação de um pacote .vfb recusado não permita confirmar a criação do pedido, para não criar um pedido demo de outro cliente por engano.

Critérios de aceite:
- O botão de confirmação (fluxo em torno de `importarVfb()`, linha ~21240, e da validação que popula `val.erros`) fica desabilitado enquanto o pacote estiver marcado como recusado.
- O fluxo de importação de pacote real e o de dados de demonstração ficam visualmente segmentados (segmented control), sem alternância silenciosa entre um cliente real e dados de demo.
- O comportamento já existente de recusar quando nenhuma placa é resolvida (`if(!bons.length)` em `importarVfb`) passa a valer também quando o pacote inteiro está inválido, bloqueando o clique antes de a função ser chamada.

### US-11 (Engenharia / Catálogo)
Como engenheiro(a) de catálogo, quero um código de catálogo dedicado para película tipo IV (NBR 14891), para não recusar na conferência uma placa que só falta mapear (D-09).

Critérios de aceite:
- Novo código de catálogo criado para película tipo IV, incluído em `VFB_PEL` (hoje mapeia apenas I→GTP, III→AIP, X→GD, linha ~18369; consumido por `mapearPlacaVfb()`, linha ~18461).
- `mapearPlacaVfb()` deixa de gerar erro para película tipo IV; o produto correspondente pode ser criado ou resolvido normalmente.

### US-12 (Compliance / Admin)
Como responsável por conformidade, quero que o identificador de origem do manifesto .vfb não exponha e-mail em texto plano, para atender à LGPD (D-11).

Critérios de aceite:
- O campo `origem.usuario` do manifesto `.vfb` passa a ser um identificador opaco, não mais e-mail em texto plano.
- Nenhuma tela do protótipo exibe e-mail lido diretamente do manifesto importado.

### US-13 (Engenharia / Catálogo)
Como engenheiro(a) de catálogo, quero uma variante de formato que já embuta a ausência de quadro na nomenclatura, para não depender de um aviso sem bloqueio nem adicionar uma sexta parte à nomenclatura de cinco partes (D-12).

Critérios de aceite:
- A nomenclatura de produto ganha variante de formato "sem quadro" dentro da estrutura de cinco partes já existente, sem criar sexta parte.
- `mapearPlacaVfb()` deixa de apenas avisar (linhas ~18477-18478, condição `c.sem_quadro`) e passa a resolver o produto com a variante correta quando `sem_quadro` é verdadeiro no manifesto.

---

## Domínio E — Início, atalhos e navegação por teclado

### US-14 (Todos os perfis)
Como usuário do sistema, quero que os atalhos padrão da tela Início apontem para módulos que existem e para os quais tenho permissão, para não ver um botão que promete algo que não funciona.

Estado atual: correção já aplicada no protótipo (P0-11): `ATALHO_PADRAO` (linha ~23560) tem destinos válidos com aba e os atalhos são filtrados por `MODULOS` via `atalhoValido` (linha ~23571).

Critérios de aceite (verificação/regressão):
- Nenhum atalho padrão lista `screen` fora de `MODULOS` (linha ~15304); a filtragem por `atalhoValido` e pela permissão real do perfil (`perm(screen)`) permanece ativa para os 9 perfis.
- O tooltip "Sem permissão" só aparece quando `perm(screen)==='-'` de fato para o perfil logado; o comportamento incorreto relatado em P0-11 para 4 perfis não reaparece.
- O destino de cada atalho abre na aba/rota correta, usando o mesmo mecanismo de `rotaDe()`/`go()` (destinos com aba, ex.: `recursos|rc-maoobra`).

### US-15 (Todos os perfis)
Como usuário do sistema, quero poder adicionar um atalho pessoal na tela Início independentemente da minha permissão sobre o módulo "início", para que preferência pessoal não seja tratada como permissão de acesso.

Estado atual: correção já aplicada no protótipo (P0-12): a guarda `perm('inicio')==='r'` citada na auditoria não existe mais no código atual.

Critérios de aceite (verificação/regressão):
- "Adicionar atalho" (`#in-add`, linha ~2664) funciona para 100% dos perfis, sem checagem de permissão sobre o módulo "início"; a guarda removida não é reintroduzida (P0-12).

### US-16 (Todos os perfis)
Como usuário do sistema, quero atalhos de teclado globais para navegar sem depender do mouse, para agilizar tarefas repetitivas em qualquer tela.

Estado atual: correção já aplicada no protótipo (P0-13): paleta `abrirPaleta()` (linha ~25174) acionada por `Ctrl+K` (linha ~25228) e pelo botão da topbar (`#tb-paleta`, linha ~1061), saltos `g`+letra via `ATALHO_TECLA` (linha ~25170) e ajuda de atalhos (linhas ~25211-25216).

Critérios de aceite (verificação/regressão):
- `Ctrl+K` abre a paleta de comandos construída sobre a lista `NAV` (linha ~15417), respeitando a permissão do perfil logado.
- `g` seguido de uma letra salta para o módulo correspondente conforme `ATALHO_TECLA` (ex.: `g i` para início, `g o` para ordens), apenas para módulos permitidos ao perfil.
- `?` abre a ajuda de atalhos; o indicador (pill/botão) do atalho permanece visível na topbar.
- Gap remanescente a confirmar: `/` foca o campo de busca/filtro da tela atual em todas as telas que possuem filtro (P0-13).

---

## Domínio F — Acessibilidade e temas visuais

### US-17 (Todos os perfis, navegação por teclado)
Como usuário do sistema, quero que o foco de teclado seja claramente visível em qualquer tela e tema, para navegar sem depender de mouse ou de adivinhar onde estou.

Critérios de aceite:
- A regra `:focus-visible` (linha ~130 do CSS) usa `outline: 2px solid var(--accent-text)` com `outline-offset`, atingindo contraste mínimo de 3:1 contra o fundo adjacente nos dois temas.
- `tr.clickable:focus-visible` (linhas ~253-254) segue a mesma regra de contraste (P0-14).

### US-18 (Todos os perfis no tema claro)
Como usuário do tema claro, quero que textos, pills e links passem no critério de contraste AA, para ler o sistema sem esforço.

Critérios de aceite:
- Os tokens do tema claro (`--text-faint`, `--text-dim`, `--accent-text`, linhas ~83-87) são recalibrados para atingir contraste AA (texto normal ≥4,5:1; texto grande/componentes de UI ≥3:1) contra `--bg-primary`.
- No tema escuro, os tokens de texto rebaixados (`--text-faint`/`--text-dim`) sobem 1 degrau na escala de contraste, conforme o fix de P0-15 ("+1 degrau no escuro").
- Pills (`.pill`) expressam o estado por cor concentrada no ponto/borda nos dois temas, mantendo o texto interno com contraste suficiente.
- Um script de verificação de contraste roda nos 2 temas e não aponta violação AA em texto, pills, botão primário e foco (P0-15).

### US-19 (Todos os perfis)
Como usuário do sistema, quero que o botão primário tenha texto legível sobre o laranja da marca, para não perder a leitura da ação principal.

Critérios de aceite:
- `--text-on-accent` (linha ~39), usado em `.btn-primary` (linha ~205), resulta em contraste mínimo de 4,5:1 contra `--accent`, mantendo a cor de marca no fundo do botão (P0-16).

### US-20 (Todos os perfis, navegação por teclado)
Como usuário do sistema, quero navegar pelas tabelas clicáveis usando apenas o teclado, para completar o fluxo pedido→expedição sem mouse.

Estado atual: correção já aplicada no protótipo (P0-17): `a11yTabelas()` (linha ~25146) existe e roda após cada render (`apósRender`, linha ~25244).

Critérios de aceite (verificação/regressão):
- `a11yTabelas()` aplica `tabindex="0"`, `role="button"` e `aria-label` a toda `tr.clickable`, cobrindo as 7 tabelas afetadas, com foco de linha visível, inclusive em linhas renderizadas dinamicamente após filtros/atualizações.
- `Enter` ou `Espaço` sobre uma linha com foco disparam a mesma ação do clique (listener delegado em `document`) (P0-17).

---

## Domínio G — Painel, programação e relatórios

### US-21 (Direção / PCP)
Como usuário do painel, quero que o seletor de período (7/30/90 dias) filtre todos os indicadores exibidos, não apenas um gráfico, para tomar decisão com números consistentes entre si.

Critérios de aceite:
- Alterar o seletor de período recalcula KPIs, carga, donut e aderência simultaneamente (`renderDashboard()`, linha ~19249); hoje apenas um gráfico responde (P0-18).
- Regra padrão: todo card temporal responde ao range selecionado. Exceção apenas nominal: um card só pode ignorar o filtro se estiver listado explicitamente como exceção (lista fechada, definida na implementação e vazia por padrão), exibindo rótulo explícito da limitação, em vez de ignorar o filtro silenciosamente.

### US-22 (Direção)
Como usuário do painel, quero que o indicador de aderência ao prazo reflita a data real de expedição, para não ver 100% de aderência quando a entrega efetivamente atrasou.

Critérios de aceite:
- O cálculo de aderência passa a considerar `fim<=prazo` como critério de "no prazo" (hoje ordens expedidas contam sempre como no prazo).
- Ordens sem `fim` registrado são excluídas do denominador, com rótulo explicando a exclusão.
- O filtro "últimos 90 dias" aplica recorte real sobre as ordens consideradas no cálculo (P0-19).

### US-23 (Direção)
Como usuário de relatórios, quero que "Últimos 30 dias" signifique de fato uma janela retrospectiva de 30 dias, para não ler um cabeçalho impresso que mente sobre o período coberto.

Critérios de aceite:
- O filtro/rótulo "Últimos 30 dias" (área `renderRelatorios`/`RPV`, linhas ~20810-20850) passa a calcular janela retrospectiva (hoje até 30 dias atrás), não simétrica (±30).
- Alternativa aceitável: manter janela simétrica, mas com rótulo explícito "±N dias".
- O cabeçalho impresso do relatório reflete o período real usado no cálculo (P0-22).

---

## Domínio H — Identificação de OS/QR e rastreabilidade

### US-24 (Expedição / Qualidade)
Como expedidor(a), quero que o ID e o QR de uma OS impressa sejam estáveis entre emissões, para que o QR de ontem não abra o grupo errado hoje.

Critérios de aceite:
- O identificador de OS deixa de ser posicional (renumerado a cada emissão, área de geração em torno da linha ~23464-23481) e passa a ser um sequencial persistido no mesmo armazenamento já usado pelo protótipo (padrão `DB.*`/localStorage, o mesmo da auditoria), não uma chave composta.
- O QR gerado carrega esse identificador estável, não a posição de emissão.
- Reemitir a mesma OS resulta no mesmo ID/QR para o mesmo grupo de itens (P0-20).

---

## Domínio I — Auditoria

### US-25 (Admin / Direção e demais perfis com acesso a auditoria)
Como usuário com acesso à auditoria, quero filtrar, buscar e exportar o registro de auditoria por tenant e por período, para investigar uma ocorrência sem depender de rolagem manual.

Estado atual: correção quase integral já aplicada no protótipo (P0-21): `audit()` grava `un:S.tenant` (linhas ~15651-15653), e `renderAuditoria()` (linhas ~17343-17382) já tem filtro de unidade, período "de/até" (`#f-aud-de`/`#f-aud-ate`), busca (`#f-aud-q`), paginação e botões CSV/Imprimir (`#aud-csv`/`#aud-pdf`, linhas ~1718-1719).

Critérios de aceite:
- Verificação/regressão: todo registro de auditoria carrega `un:S.tenant` e a lista responde aos filtros de unidade, período "de/até", busca textual e paginação.
- Verificação/regressão: a exportação CSV opera sobre a lista filtrada, nunca sobre a lista completa.
- Gap remanescente: a saída de impressão/PDF reaproveita o padrão `folhaA4` já usado em relatórios, gerada a partir da lista filtrada (P0-21).

---

## Domínio J — Outras decisões de produto aceitas sem P0 dedicado

### US-26 (Comercial / Direção)
Como responsável comercial, quero ver a área nominal e a área geométrica de um item de contrato faturado por m², cada uma com rótulo explícito do seu propósito, para não confundir consumo de chapa com faturamento (D-03).

Critérios de aceite:
- A tela de contrato/item exibe os dois números lado a lado, com rótulo "área nominal (retângulo) — consumo de chapa/corte" e "área geométrica — faturamento por m² de face", quando aplicável ao item.
- O cálculo de consumo de material continua usando a área nominal; o cálculo de faturamento por m² usa a área geométrica quando o item de contrato assim define.

### US-27 (PCP / Comercial)
Como PCP, quero que o indicador de avanço por pedido em Clientes/entregas informe explicitamente quando uma ordem de lote não é considerada, para não passar a impressão de um rateio que não existe (D-05).

Critérios de aceite:
- Ordem de lote fica de fora do cálculo de avanço por pedido da tela Clientes/entregas.
- Rótulo explícito informa a exclusão sempre que houver ordem de lote associada ao pedido consultado.

### US-28 (Operador)
Como operador, quero enxergar na minha fila do chão de fábrica quais ordens estão bloqueadas/paradas, mesmo sem poder destravá-las, para entender o que está represado sem precisar perguntar ao PCP (D-06).

Critérios de aceite:
- A fila do operador no chão de fábrica passa a listar ordens bloqueadas/paradas de forma passiva (visível, sem ação de destravar disponível para o perfil operador).
- O único ponto de decisão para destravar continua sendo o PCP (ação equivalente a `od-unblock`), sem alteração de permissão de escrita para o operador.

---

## Requisitos Funcionais

### RF — Domínio A (ficha técnica, rascunho, publicação, roteiro)
- **RF-01**: O sistema deve manter dois estados para toda ficha técnica (rascunho e publicada) e nunca permitir que uma edição de rascunho altere a versão publicada em uso por ordens. Relacionado: US-01. Base: enum `ficha_status`, tabela `fichas_tecnicas`.
- **RF-02**: O sistema deve oferecer a ação "Descartar rascunho", revertendo a cópia de trabalho para o conteúdo da última versão publicada, sem gerar linha nova em `fichas_tecnicas`. Relacionado: US-01.
- **RF-03**: O sistema deve interceptar a troca de ficha (navegação) quando houver rascunho não salvo/publicado, exibindo confirmação antes de perder as alterações. Relacionado: US-01.
- **RF-04**: Ao publicar uma ficha, o sistema deve identificar todas as ordens abertas (não expedidas) que referenciam a ficha e segmentá-las em "afetadas" e "não afetadas" antes de confirmar. Relacionado: US-02.
- **RF-05**: A publicação de uma nova versão de ficha deve sempre gerar nova linha versionada (nunca UPDATE de conteúdo), coerente com o trigger `fn_versao_ficha()` já existente no schema Supabase. Relacionado: US-02.
- **RF-06**: O roteiro de fabricação de uma ordem deve ser derivado da ficha técnica do produto da ordem (`roteiroDe()`), substituindo o roteiro base global fixo de 7 operações. Relacionado: US-03.
- **RF-07**: Tempo padrão e máquina de cada operação do roteiro devem ser editáveis dentro da ficha técnica, por operação. Relacionado: US-03.

### RF — Domínio B (planejamento e execução)
- **RF-08**: A ação "Gerar ordens" deve exibir modal de confirmação com preview (ordens a criar, faltas de material, componentes a consumir) antes de qualquer gravação em `DB.ordens`. Relacionado: US-04.
- **RF-09**: A finalização de uma operação deve exibir o efeito de consumo calculado por `matDaOperacao` e exigir confirmação explícita antes de baixar material. Relacionado: US-05.
- **RF-10**: O sistema deve impedir reapontamento (nova finalização) de uma operação já finalizada e baixada, exceto por meio de um evento explícito de desbloqueio que reabre a operação. Relacionado: US-05.
- **RF-11**: Correções de apontamento finalizado devem respeitar janela de 10 minutos após a finalização, registradas como nova linha, no padrão de `estornos_apontamento`. Relacionado: US-05.
- **RF-12**: "Reservar materiais" deve estornar a reserva vigente da ordem antes de somar a nova necessidade calculada, nunca acumulando reservas sobre reservas. Relacionado: US-06.
- **RF-13**: O sistema deve oferecer ação de "Liberar reserva" independente, devolvendo o saldo reservado ao disponível. Relacionado: US-06.
- **RF-14**: A ação "Recalcular" de reserva deve exibir o delta entre a reserva vigente e a nova necessidade calculada. Relacionado: US-06.

### RF — Domínio C (handoffs Qualidade/Expedição)
- **RF-15**: A tela de Qualidade deve exibir fila "Aguardando inspeção" com contagem, alimentada automaticamente por ordens concluídas sem parecer de qualidade. Relacionado: US-07. Já implementado no protótipo (`#qa-fila-n`); critério de verificação/regressão.
- **RF-16**: A contagem de ordens aguardando inspeção deve aparecer no resumo crítico da tela Início para perfis com permissão de leitura em qualidade. Relacionado: US-07. Gap remanescente de P0-02.
- **RF-17**: A tela de Expedição deve exibir a quantidade de unidades retidas pela qualidade (sem parecer ou reprovadas) e o número de ordens envolvidas. Relacionado: US-08.
- **RF-18**: Blocos de expedição de itens retidos pela qualidade devem ficar desabilitados com motivo explícito. Relacionado: US-08.
- **RF-19**: Toda reprovação de qualidade deve apresentar explicitamente o próximo passo ao usuário responsável. Relacionado: US-09.
- **RF-20**: O desbloqueio de uma ordem bloqueada por reprovação de qualidade deve resetar o parecer de qualidade e reabrir a última operação do roteiro para retrabalho, com evento e auditoria registrados. Relacionado: US-09.

### RF — Domínio D (importação ViaSign e pedidos)
- **RF-21**: O botão de confirmação de importação de pacote `.vfb` deve permanecer desabilitado enquanto o pacote estiver marcado como recusado. Relacionado: US-10.
- **RF-22**: O fluxo de importação de pacote real e o fluxo de dados de demonstração devem ser visualmente segmentados, sem alternância silenciosa entre eles. Relacionado: US-10.
- **RF-23**: O catálogo de películas deve incluir código dedicado para película tipo IV (NBR 14891), mapeado em `VFB_PEL` e reconhecido por `mapearPlacaVfb()` sem gerar erro de recusa. Relacionado: US-11.
- **RF-24**: O campo `origem.usuario` do manifesto `.vfb` deve ser tratado como identificador opaco, nunca como e-mail em texto plano, em qualquer tela ou exportação do sistema. Relacionado: US-12.
- **RF-25**: A nomenclatura de produto deve suportar variante de formato "sem quadro" dentro das cinco partes existentes, aplicada automaticamente quando `classificacao.sem_quadro` é verdadeiro no manifesto importado. Relacionado: US-13.
- **RF-48**: A linha do importador deve exibir aviso de possível colisão quando a chave de dimensão com 1 casa decimal puder mapear dimensões distintas para a mesma chave, mantendo a chave em 1 casa decimal (migração para 2 casas adiada até evidência de colisão real em produção). Relacionado: D-04 aceita, sem US dedicada. Numerado após RF-47 para preservar a numeração já referenciada no restante do documento.

### RF — Domínio E (início, atalhos, teclado)
- **RF-26**: Os atalhos padrão da tela Início devem ser filtrados pela lista `MODULOS` e pela permissão real do perfil corrente (`perm(screen)`), nunca apontando para tela inexistente no roteador. Relacionado: US-14. Já implementado no protótipo (`atalhoValido`); critério de verificação/regressão.
- **RF-27**: O tooltip "Sem permissão" em um atalho só deve aparecer quando `perm(screen)` retornar `'-'` para o perfil logado. Relacionado: US-14. Já implementado no protótipo; critério de verificação/regressão.
- **RF-28**: A ação "Adicionar atalho" deve estar disponível para todos os perfis, sem depender da permissão de escrita no módulo "início". Relacionado: US-15. Já implementado no protótipo (guarda removida); critério de verificação/regressão.
- **RF-29**: O sistema deve oferecer paleta de comandos global (`Ctrl+K`), atalho de salto por letra (`g`+tecla conforme `ATALHO_TECLA`), atalho de filtro (`/`) e atalho de ajuda (`?`), com indicador visível na topbar. Relacionado: US-16. Paleta, `g`+tecla, `?` e indicador já implementados (verificação/regressão); gap remanescente: confirmar `/` focando o filtro em todas as telas.

### RF — Domínio F (acessibilidade e temas)
- **RF-30**: O indicador de foco de teclado (`:focus-visible`) deve manter contraste mínimo de 3:1 contra o fundo adjacente nos temas claro e escuro, incluindo `tr.clickable`. Relacionado: US-17.
- **RF-31**: Os tokens de cor de texto do tema claro (`--text-faint`, `--text-dim`, `--accent-text`) devem satisfazer contraste AA (4,5:1 texto normal; 3:1 texto grande/UI) contra o fundo correspondente. Relacionado: US-18.
- **RF-32**: O componente `.pill` deve expressar o estado por cor concentrada no ponto/borda, mantendo o texto interno com contraste suficiente nos dois temas. Relacionado: US-18.
- **RF-33**: `--text-on-accent`, usado em `.btn-primary`, deve manter contraste mínimo de 4,5:1 contra `--accent`. Relacionado: US-19.
- **RF-34**: Toda `tr.clickable` das tabelas do sistema deve ser acessível por teclado (tabindex, role, ativação por Enter/Espaço) via o helper único `a11yTabelas()`. Relacionado: US-20. Já implementado no protótipo; critério de verificação/regressão.

### RF — Domínio G (painel, programação, relatórios)
- **RF-35**: O seletor de período do painel (7/30/90 dias) deve, por padrão, recalcular todos os indicadores dependentes de tempo (KPIs, carga, donut, aderência), não apenas um gráfico isolado. Relacionado: US-21.
- **RF-36**: Exceção nominal a RF-35: um card temporal só pode não responder ao range selecionado se estiver listado explicitamente como exceção (lista fechada, definida na implementação e vazia por padrão), exibindo rótulo explícito da limitação. Relacionado: US-21.
- **RF-37**: O indicador de aderência ao prazo deve considerar `fim<=prazo` como critério de "no prazo", excluindo do denominador ordens sem `fim` registrado, com rótulo explicando a exclusão. Relacionado: US-22.
- **RF-38**: O filtro "últimos 90 dias" do painel deve aplicar recorte real sobre as ordens consideradas no cálculo de aderência. Relacionado: US-22.
- **RF-39**: O rótulo "Últimos 30 dias" em relatórios deve corresponder a janela retrospectiva real (ou ser rotulado explicitamente como janela simétrica "±N dias"), refletida também no cabeçalho impresso. Relacionado: US-23.

### RF — Domínio H (OS/QR e rastreabilidade)
- **RF-40**: O identificador de OS impressa deve ser estável entre emissões, implementado como sequencial persistido no armazenamento padrão do protótipo (`DB.*`/localStorage, o mesmo usado pela auditoria), não posicional nem chave composta. Relacionado: US-24.
- **RF-41**: O conteúdo do QR de uma OS deve carregar o identificador estável, garantindo que a leitura em datas diferentes abra sempre o mesmo grupo de itens. Relacionado: US-24.

### RF — Domínio I (auditoria)
- **RF-42**: Todo registro de auditoria deve carregar o identificador do tenant (`un`), reaproveitando o padrão já implementado em `audit()`. Relacionado: US-25. Já implementado; critério de verificação/regressão.
- **RF-43**: A tela de Auditoria deve oferecer filtros de data (de/até), busca textual e paginação sobre a lista de registros. Relacionado: US-25. Já implementado; critério de verificação/regressão.
- **RF-44**: A tela de Auditoria deve oferecer exportação da lista filtrada em CSV e em PDF (via `folhaA4`), sem prometer ação que não executa. Relacionado: US-25. CSV já implementado (verificação/regressão); gap remanescente: saída de impressão/PDF via `folhaA4`.

### RF — Domínio J (outras decisões de produto)
- **RF-45**: O item de contrato faturado por m² deve exibir área nominal e área geométrica separadamente, cada uma com rótulo explícito de propósito (consumo de material vs. faturamento). Relacionado: US-26.
- **RF-46**: O indicador de avanço por pedido em Clientes/entregas não deve considerar ordens de lote no rateio, exibindo rótulo explícito da exclusão quando aplicável. Relacionado: US-27.
- **RF-47**: A fila do operador no chão de fábrica deve exibir ordens bloqueadas/paradas em modo somente leitura, sem oferecer ação de destravar para o perfil operador. Relacionado: US-28.

---

## Requisitos Não-Funcionais

- **RNF-01 (Acessibilidade/Contraste)**: Todo texto, pill, botão primário e indicador de foco deve atingir contraste AA (WCAG: ≥4,5:1 texto normal, ≥3:1 texto grande/componentes de UI/foco), verificado por script automatizado nos dois temas (claro e escuro). Critério de aceite herdado da auditoria de 23/08.
- **RNF-02 (Usabilidade/Navegação por teclado)**: O fluxo completo pedido→expedição deve ser 100% navegável por teclado, com foco sempre visível, sem dependência de mouse.
- **RNF-03 (Confiabilidade/Confirmação de irreversíveis)**: Toda ação irreversível (gerar ordens, finalizar operação com baixa de material) deve exigir confirmação explícita mostrando a consequência antes de executar; ações reversíveis não devem exigir confirmação.
- **RNF-04 (Confiabilidade/Correção com janela de tempo)**: Correções de apontamento finalizado devem ocorrer dentro de janela de 10 minutos após a finalização, registradas como nova linha (nunca sobrescrita), no padrão append-only já adotado por `estornos_apontamento`.
- **RNF-05 (Segurança/LGPD)**: Identificadores pessoais (e-mail) não devem trafegar em texto plano em manifestos `.vfb` nem em nenhuma tela do sistema; deve-se usar identificador opaco.
- **RNF-06 (Rastreabilidade/Auditoria de handoff)**: Todo evento de handoff entre papéis (conclusão para inspeção, retenção pela qualidade, reprovação/desbloqueio) deve gerar sinal visível no destino e registro de auditoria com tenant (`un`), autor e timestamp.
- **RNF-07 (Confiabilidade/Rótulo verdadeiro)**: Nenhuma tela ou atalho deve prometer ação inexistente ("exportar", "salvar", "sincronizar", "últimos N dias"); rótulo e comportamento devem corresponder exatamente.
- **RNF-08 (Multi-tenant/Isolamento)**: Toda listagem, filtro e exportação de auditoria deve respeitar o isolamento por tenant (`S.tenant`/`un`), sem expor registros de outro tenant.
- **RNF-09 (Manutenibilidade/Consistência com o backend real)**: Alterações em ficha técnica e roteiro no protótipo devem seguir o mesmo padrão de versionamento imutável já implementado no schema Supabase (`fichas_tecnicas.versao`, sem UPDATE de conteúdo), evitando divergência entre protótipo e backend real.
- **RNF-10 (Usabilidade/Consistência visual entre temas)**: Apenas a variável `--accent` deve mudar a identidade visual entre marca/temas; os demais tokens do design system permanecem genéricos e reutilizáveis entre os dois temas, conforme convenção já registrada em `CLAUDE.md`.

---

## Pendências não convertidas em requisito nesta rodada

Conforme o discovery, os itens abaixo foram explicitamente adiados ou não pertencem ao escopo de alteração do protótipo desta execução; nenhum requisito de implementação foi gerado para eles aqui, para não antecipar decisão que ainda depende de informação humana:

- **D-07** (descritores das siglas MA/MP/MQ do catálogo de origem): aguarda o dono do produto informar o significado de negócio de cada sigla; placeholder genérico mantido.
- **D-08** (ViaSign: entrada por ponto de implantação): reconfirmação com o time do ViaSign fica para antes da Fase 4.
- **D-10** (canonicalização do hash do manifesto): tratado como identificador opaco no MVP; resolução fica para a Fase 4, junto da assinatura de QR/etiqueta.
- **D-13** (ADR-012/`viaxis.vfb` ausente do repositório): trazer o ADR ao repositório (ou confirmar fonte canônica) e implementar conferência de bytes/SHA-256 real ficam registrados como pendência formal para a Fase 4.
- **S6, S7, S8, S9/S11** (pendências do relatório de validação de sprints): aplicam-se ao plano de sprints de implementação (`sprints20260820_134109.json`, ex.: buckets de Storage em sprint-004, geração de `series_item`/`series_deposito` em sprint-021, componentes `cmp-tabs`/`cmp-esquema-placa`/`cmp-tabela-lotes` em sprints 006/012/020), não ao protótipo corrigido nesta fase; ajuste desses itens é trabalho de uma fase de implementação posterior.
