# Sugestoes de Enriquecimento — SPEC ViaFab

> Arquivo de memoria persistente do enriquecimento. Fonte unica de verdade sobre o que ja foi sugerido e o status de cada item.
> Status possiveis: [PENDENTE] | [APROVADO] | [APLICADO] | [REJEITADO]

## Contexto da analise

- SPEC alvo declarada na tarefa: `SPEC.md` (raiz) — **NAO EXISTE** no filesystem.
- SPEC encontrada no projeto: `docs/Docs20260820_134109/SPEC20260820_134109.md` (849 linhas).
- PRD de referencia: `PRD.md` (raiz, 687 linhas) — inclui Secao 9 "Decisoes Tecnicas" (Database, Backend, Frontend, Security) muito mais recente e detalhada que a SPEC.
- Conclusao: a SPEC existente foi gerada a partir de um ciclo anterior de discovery/design-lock e **nao reflete o PRD atual**.

---

## BLOQUEIO — resolver antes de qualquer edicao

- **E1** [PENDENTE] [DOCUMENTO ALVO] O arquivo `SPEC.md` na raiz do projeto nao existe. A unica SPEC encontrada e `docs/Docs20260820_134109/SPEC20260820_134109.md`, gerada de um ciclo anterior.
  Opcoes: a) Enriquecer diretamente `docs/Docs20260820_134109/SPEC20260820_134109.md` no lugar dela mesma; b) Copiar a SPEC existente para `SPEC.md` na raiz e enriquecer a copia, mantendo a original como historico do ciclo anterior; c) Criar `SPEC.md` na raiz do zero, derivada do PRD atual, usando a SPEC antiga apenas como insumo de design/telas
  Sugestao: opcao b - preserva o artefato historico do design lock intacto, cria um alvo estavel no caminho esperado pela tarefa e evita reescrita total (que violaria a regra de edicao cirurgica).

---

## GRUPO A — Consistencia entre SPEC e PRD (inconsistencias reais, nao lacunas)

- **E2** [PENDENTE] [RASTREABILIDADE] Os IDs de user story da SPEC nao batem com os do PRD. Sao dois conjuntos distintos. Ex.: SPEC US-01 = "Selecionar familia construtiva"; PRD US-01 = "Receber demanda/snapshot do ViaSign". SPEC US-13 = "Consultar saldo de estoque"; PRD US-13 = "Cadastrar demanda manualmente". A SPEC cobre 28 stories; o PRD tem 33. Toda a rastreabilidade das secoes 4.2, 4.7 e 4.8 aponta para IDs que significam outra coisa hoje.
  Opcoes: a) Adotar a numeracao do PRD como unica e remapear todas as tabelas da SPEC; b) Manter as duas e adicionar uma tabela de-para SPEC-US <-> PRD-US; c) Renumerar as stories do PRD para casar com a SPEC
  Sugestao: opcao a - o PRD e o documento vivo e validado; duas numeracoes concorrentes garantem erro de implementacao. A opcao b so adia o problema.

- **E3** [PENDENTE] [RASTREABILIDADE] Os IDs de RF/RNF citados na SPEC divergem semanticamente do PRD. Exemplos: SPEC cita "RF-35/RNF-06" para auditoria automatica, mas no PRD RF-35 = PWA responsiva e RNF-06 = protecao de dados em transito; SPEC cita "RNF-13" para imutabilidade de snapshot, mas no PRD RNF-13 = referencia cruzada de estoque offline; SPEC cita RF-27, RF-33, RF-37, RF-39, RNF-04, RNF-09, RNF-11, RNF-12 com significados que nao existem no PRD atual.
  Opcoes: a) Reescrever todas as referencias RF/RNF da SPEC contra a numeracao do PRD atual; b) Remover as referencias numericas da SPEC e citar apenas o requisito por extenso; c) Manter e adicionar nota de aviso
  Sugestao: opcao a - referencia cruzada errada e pior que referencia ausente, porque parece correta.

- **E4** [PENDENTE] [ROTEAMENTO] Conflito direto: a SPEC (4.2) define rotas hash (`#ordens`, `#ordem-detalhe/OP-2433`); o PRD (Decisoes Tecnicas > Frontend) determina React Router v7 com paths reais (`/ordens`, `/chao-de-fabrica`) e afirma literalmente que "as rotas hash do prototipo estatico nao sao reproduzidas na aplicacao real".
  Opcoes: a) Atualizar a SPEC para paths reais, mantendo a regra de deep-link com entityId (`/ordens/:ordemId`) e o requisito de rewrite para `index.html` na Vercel; b) Manter hash e atualizar o PRD; c) Suportar ambos
  Sugestao: opcao a - a decisao do PRD e posterior e justificada por deep-link de QR Code impresso; a opcao c dobra a superficie de bug de navegacao sem beneficio.

- **E5** [PENDENTE] [SEGURANCA / RLS] Conflito direto: a SPEC (2.2) baseia toda a RLS exclusivamente em `auth.jwt() -> app_metadata ->> tenant_id`. O PRD determina o oposto: "as policies de RLS nao devem confiar apenas em um tenant_id enviado pelo cliente nem em claims potencialmente desatualizadas (stale). A autorizacao deve ser derivada e validada a partir de uma tabela de memberships/roles".
  Opcoes: a) Reescrever 2.2 com policies baseadas em `memberships` (claim JWT apenas como otimizacao de indice); b) Manter claims como fonte e documentar o risco de claim stale; c) Modelo hibrido com revalidacao periodica de claim
  Sugestao: opcao a - revogacao de acesso com efeito imediato e requisito de seguranca do PRD; claim stale mantem acesso apos revogacao ate a expiracao do token.

- **E6** [PENDENTE] [SEGURANCA / RBAC] Conflito direto: a SPEC modela `perfis.permissoes (jsonb)` — permissoes customizaveis por tenant. O PRD determina "RBAC simples com papeis explicitos... Nao ha sistema generico de permissoes customizaveis por tenant no MVP" e fecha uma matriz acao->papel completa.
  Opcoes: a) Trocar o modelo jsonb por papeis fixos e transportar a matriz acao->papel do PRD para dentro da SPEC; b) Manter jsonb e usar a matriz do PRD apenas como seed inicial de permissoes; c) Manter jsonb livre
  Sugestao: opcao a - permissao customizavel por tenant sem tela de administracao definida e superficie de risco sem dono; a matriz do PRD ja e explicita e testavel.

- **E7** [PENDENTE] [SESSAO] Conflito direto de numeros: a SPEC define `cmp-session-clock` com timeout 1800s e `.env` com `SESSION_INACTIVITY_TIMEOUT_MINUTES=30` para todas as telas. O PRD define 15 minutos de inatividade para telas operacionais/touch (chao de fabrica, estoque, qualidade, expedicao) e sessao mais longa para desktop de PCP/engenharia.
  Opcoes: a) Adotar dois timeouts (touch=15min, dense=configuravel/maior) e refletir em duas variaveis de ambiente distintas; b) Padronizar 15 min para todos; c) Padronizar 30 min para todos
  Sugestao: opcao a - e a decisao do PRD e o motivo e concreto (tablet compartilhado no chao de fabrica nao pode herdar sessao do operador anterior).

- **E8** [PENDENTE] [ESTOQUE] Conflito direto: a SPEC prevê `parametros_sistema.estoque_negativo (bool)` — ou seja, saldo negativo configuravel. O PRD determina "postura estrita: saldo_disponivel nunca pode ficar negativo, inclusive sob concorrencia... constraint CHECK saldo_disponivel >= 0. Nao ha saldo negativo temporario com reconciliacao posterior".
  Opcoes: a) Remover o parametro `estoque_negativo` e manter a constraint estrita do PRD; b) Manter o parametro e travar o valor em `false` no MVP, documentando como reservado para pos-MVP; c) Manter o parametro totalmente funcional
  Sugestao: opcao a - um flag que permite violar a constraint de banco torna a propria constraint impossivel de aplicar; se voce quiser a flexibilidade futura, a opcao b e o meio-termo aceitavel.

- **E9** [PENDENTE] [OFFLINE] Conflito direto: a SPEC persiste `sync_status (pendente|conflito|confirmado)` nas tabelas do servidor (`apontamentos`, `consumos`, `movimentos_estoque`) e expoe `POST /estoque/movimentos/sincronizar`. O PRD determina "nao existe linha 'pendente' no ledger — o estado pendente/divergente e mantido pela UI no cliente ate a confirmacao", com dois trilhos (nao critico sincroniza sozinho; critico fica retido ate confirmacao explicita em tela de reconciliacao).
  Opcoes: a) Remover `sync_status` das tabelas criticas de estoque (fila 100% no cliente, via outbox IndexedDB), mantendo apenas `idempotency_key` no servidor; b) Manter `sync_status` apenas em tabelas nao criticas (apontamentos/consumos) e remover de `movimentos_estoque`; c) Manter como esta
  Sugestao: opcao a - alinhado ao PRD e a RF-38; qualquer linha "pendente" no ledger cria a duvida "isso ja conta como estoque?", que e exatamente o que a regra quer eliminar.

- **E10** [PENDENTE] [IDEMPOTENCIA] Divergencia de chave: a SPEC usa `(tenant_id, client_generated_id)` de forma unica e generica. O PRD define DUAS chaves distintas com propositos diferentes: `(tenant_id, origem, evento_id)` para intake ViaSign e `(tenant_id, idempotency_key)` para acoes offline do cliente, alem de `origem_ref` como correlacao de revisoes.
  Opcoes: a) Documentar as duas chaves separadamente na SPEC, com a tabela/constraint de cada uma; b) Unificar tudo em uma chave generica; c) Deixar a decisao para a implementacao
  Sugestao: opcao a - sao dominios de idempotencia diferentes (evento externo vs. acao do proprio usuario); unificar produz colisao conceitual e bug de reenvio.

- **E11** [PENDENTE] [INTEGRACAO VIASIGN] A SPEC nao cobre o fluxo de "ID externo pendente de mapeamento" definido no PRD: evento aceito mesmo sem correspondencia interna, persistido imutavel, marcado como pendente, resposta 202 Accepted, proibicao de gerar/liberar ordem enquanto pendente, e caso de uso proprio de resolucao autorizado a `pcp`/`engenharia` e auditado.
  Opcoes: a) Adicionar a entidade de mapeamento pendente, o estado de bloqueio de ordem e o endpoint de resolucao na SPEC; b) Tratar ID sem correspondencia como rejeicao 422 (contradiz o PRD); c) Deixar fora do MVP
  Sugestao: opcao a - e uma regra ja decidida no PRD e sem ela o intake fica sem caminho de recuperacao operacional.

- **E12** [PENDENTE] [SNAPSHOT] Divergencia de modelo: o PRD exige unicidade `(ordem_id, versao)` e trigger de banco bloqueando UPDATE/DELETE. A tabela `snapshots` da SPEC nao tem coluna `versao` nem `ordem_id` (o vinculo e indireto via `itens_ordem`), usando `snapshot_revisao_de_id` como encadeamento.
  Opcoes: a) Adicionar `versao` e o vinculo direto a ordem, mantendo `snapshot_revisao_de_id` como encadeamento de revisao; b) Manter o modelo da SPEC e ajustar o PRD para unicidade por `(item_id, versao)`; c) Manter ambos sem unicidade formal
  Sugestao: opcao a - "snapshot tecnico versionado por ordem" e o criterio de aceite literal de US-07/RF-09; sem coluna de versao nao ha como testar isso.

- **E13** [PENDENTE] [BLOQUEIOS] A tabela `bloqueios` da SPEC nao tem campo `tipo`, mas o PRD (RF-44) define matriz de resolucao por tipo: material -> `almoxarifado`; tecnico/roteiro -> `engenharia`; qualidade -> `qualidade`; demais -> `pcp`. Sem `tipo` a matriz e inaplicavel.
  Opcoes: a) Adicionar `tipo (enum: material|tecnico|qualidade|outro)`, `resolvido_por`, `motivo_resolucao` e a matriz de autorizacao na SPEC; b) Permitir resolucao por qualquer papel autorizado generico; c) Definir o tipo apenas em texto livre
  Sugestao: opcao a - a matriz do PRD e explicita e so e implementavel com o tipo persistido e o resolvedor registrado.

- **E14** [PENDENTE] [SERIES] O PRD (US-33/RF-45) e categorico: a serie nasce na conclusao da unidade na producao, vinculando ordem, item, deposito e snapshot tecnico, e "series nao sao geradas no cadastro da demanda nem na criacao da ordem". A SPEC tem `series_item` e `series_deposito`, mas nao declara o momento de nascimento nem o vinculo obrigatorio ao snapshot.
  Opcoes: a) Adicionar `snapshot_id` em `series_item`, declarar o gatilho de criacao na conclusao da operacao final e a proibicao explicita de criacao antecipada; b) Deixar o momento de criacao a criterio da implementacao; c) Gerar series na criacao da ordem
  Sugestao: opcao a - e a garantia de que "so se expede o que foi realmente produzido", que sustenta a metrica de rastreabilidade ponta a ponta.

- **E15** [PENDENTE] [ASSINCRONO] O PRD define processamento assincrono (RNF-02) com tabela `jobs` (status, tentativas, `next_attempt_at`, erro sanitizado), claim atomico via `FOR UPDATE SKIP LOCKED`, backoff, limite de tentativas e idempotencia at-least-once, consumida por worker via Supabase Cron. A SPEC nao menciona `jobs`, worker nem cron em lugar nenhum, embora exponha `POST /relatorios/exportar` e operacoes de lote.
  Opcoes: a) Adicionar a tabela `jobs` e o worker na SPEC, e marcar quais endpoints sao assincronos (exportacao de relatorio, geracao de ordens em lote, consolidacao); b) Tornar tudo sincrono no MVP; c) Adiar a decisao
  Sugestao: opcao a - exportacao de relatorio e geracao de ordens em lote sao exatamente os casos que estouram timeout de Edge Function.

---

## GRUPO B — Escopo: SPEC muito maior que o PRD

- **E16** [PENDENTE] [ESCOPO] A SPEC especifica 24 telas e 111 endpoints, incluindo dominios inteiros que o PRD nao descreve como MVP: clientes/contratos/medicao, orcamento/proposta/custo aberto, GED com OCR e databook, romaneio/conferencia/espelho fiscal, transferencias entre unidades fabris, nomenclaturas CONTRAN, etiquetas, multi-unidade. O PRD, na Secao 7, define escopo negativo e o MVP gira em torno de demanda -> ordem -> planejamento -> execucao -> expedicao.
  Opcoes: a) Marcar explicitamente cada dominio da SPEC como `MVP` ou `pos-MVP`, mantendo o design lock intacto mas deixando claro o que entra agora; b) Remover da SPEC tudo que nao esta no PRD; c) Elevar o escopo do PRD para cobrir tudo que a SPEC descreve
  Sugestao: opcao a - preserva o design lock (que e contrato travado de UI) sem transformar um MVP em um ERP completo de uma vez; a marcacao vira insumo direto do planejamento.

- **E17** [PENDENTE] [ESCOPO] O modulo `orcamento` da SPEC (custo unitario, margem, imposto, preco unitario, proposta, `custo_hora` de cargo) colide com o RNF-15 do PRD: "as regras de negocio nao devem ser acopladas a preco, plano ou limite comercial" e com o escopo negativo "definicao comercial fora do MVP".
  Opcoes: a) Manter orcamento como modulo pos-MVP isolado do nucleo de dominio, com nota explicita de nao-acoplamento; b) Incluir no MVP delimitando que se trata de custo industrial interno (nao de preco de assinatura do SaaS), o que nao viola RNF-15; c) Remover
  Sugestao: opcao b - se o alvo e custo de fabricacao (material + processo + mao de obra), isso e dado de manufatura, nao regra comercial de SaaS; mas isso precisa estar escrito para nao ser confundido com violacao do RNF-15.

- **E18** [PENDENTE] [ESCOPO] O PRD exige cadastro manual de demanda para operacao standalone (US-13/RF-17) como caminho obrigatorio. Na SPEC nao existe tela nem endpoint de "demanda manual" — o mais proximo e `POST /pedidos` (`api-pedido-criar`), que e outro conceito.
  Opcoes: a) Declarar explicitamente que `pedidos` (criacao manual de pedido/linha) E o caminho standalone, mapeando US-13/RF-17 para a tela `pedidos`; b) Criar entidade `demandas` separada de `pedidos`; c) Deixar como esta
  Sugestao: opcao a - evita duplicar conceito, mas exige a declaracao explicita para que o requisito nao fique orfao e o teste de aceite tenha alvo.

- **E19** [PENDENTE] [ESCOPO] Persona `compras` do PRD (US-32/RF-42): acesso somente leitura a faltas e necessidades de material. Na SPEC, `compras` aparece apenas como nome de perfil no seed; nao ha tela, endpoint nem estado de UI para essa visualizacao.
  Opcoes: a) Definir a visao de faltas (tela `estoque` ou `plano` filtrada, somente leitura) e o endpoint correspondente; b) Reaproveitar `GET /planejamento/projecao-consumo` restringindo o perfil; c) Adiar para pos-MVP
  Sugestao: opcao b - o endpoint de projecao de consumo ja cobre a necessidade; falta apenas declarar o recorte de permissao e o estado somente-leitura da tela.

---

## GRUPO C — Contratos de API e tratamento de erro

- **E20** [PENDENTE] [CONTRATO DE ERRO] A SPEC nao define o formato de erro nem os codigos HTTP. O PRD fecha: corpo `{ code, message, details, request_id }`; 401 sessao ausente/invalida; 403 papel insuficiente; 409 conflito de estado/idempotencia (sem retry automatico); 422 payload fora do contrato; `details` sempre seguro (sem stack, SQL, segredo ou dado de outro tenant).
  Opcoes: a) Adicionar uma secao "Contrato de erro" na SPEC replicando essa tabela e tornando-a obrigatoria para os 111 endpoints; b) Definir por endpoint; c) Deixar para a implementacao
  Sugestao: opcao a - erro padronizado e o que permite o mapeamento centralizado de UI (401 -> login com returnTo, 403 -> acesso-negado, 409 -> alerta contextual, 422 -> erro por campo) que o PRD ja exige.

- **E21** [PENDENTE] [CONTRATO DE ERRO] Nenhum dos 111 endpoints da SPEC declara qual codigo de erro emite em qual condicao. Um desenvolvedor teria que inventar caso a caso.
  Opcoes: a) Adicionar, para cada endpoint de escrita critica, a lista de erros possiveis (ex.: `POST /ordens/{id}/reservas` -> 409 saldo insuficiente, 409 ordem nao liberada, 403 papel != almoxarifado); b) Definir apenas por familia de endpoint (estoque, ordem, execucao); c) Manter generico
  Sugestao: opcao b - cobertura suficiente para nao inventar, sem inflar a SPEC com 111 blocos; casos criticos de estoque e transicao de ordem detalhados individualmente.

- **E22** [PENDENTE] [PAGINACAO] Nenhum endpoint de listagem da SPEC (`GET /ordens`, `GET /estoque/saldos`, `GET /auditoria`, `GET /itens`, `GET /inspecoes`, `GET /pedidos`) define paginacao, ordenacao padrao ou limite maximo. `GET /auditoria` e append-only e cresce indefinidamente.
  Opcoes: a) Cursor (keyset) em tudo, page size padrao 50 e maximo 200; b) Offset/limit simples com page size 25; c) Cursor para auditoria/movimentacoes (alto volume) e offset para o resto
  Sugestao: opcao c - keyset onde o volume cresce sem teto e a UI usa virtualizacao (auditoria, movimentos, saldos), offset onde o usuario precisa saltar de pagina; evita complexidade desnecessaria nas listas pequenas.

- **E23** [PENDENTE] [RATE LIMIT E TIMEOUT] O PRD menciona rate limiting no login (5 tentativas/15 min), no intake ViaSign e em Edge Functions sensiveis, mas sem numeros para os demais. A SPEC nao menciona rate limit nem timeout algum.
  Opcoes: a) Definir limites explicitos (ex.: intake ViaSign 60 req/min por tenant; escrita geral 300 req/min por usuario; timeout de Edge Function 30s; timeout de leitura no cliente 15s com retry); b) Definir apenas login e intake, deixando o resto sem limite no MVP; c) Adiar
  Sugestao: opcao a - o cliente offline faz rajada de sincronizacao na reconexao; sem limite e sem timeout definido, a primeira reconexao de um turno inteiro derruba a funcao.

- **E24** [PENDENTE] [UPLOAD] A SPEC preve upload em `POST /ged/documentos`, `POST /apontamentos/{ordemId}/fotos` e `POST /pedidos/{id}/linhas/{n}/arquivos`, mas nao define tamanho maximo, tipos MIME aceitos, comportamento de upload em conexao instavel nem se a foto de conclusao pode ficar na fila offline.
  Opcoes: a) Foto de conclusao: JPEG/PNG/WebP, max 5 MB, compressao no cliente antes do envio, enfileiravel offline; GED: PDF/JPEG/PNG, max 20 MB; arquivos de projeto: max 50 MB; b) Limite unico de 10 MB para tudo; c) Deixar para a implementacao
  Sugestao: opcao a - foto tirada em tablet chega facil a 8 MB sem compressao e o operador esta justamente no ambiente com pior conexao; limites por proposito evitam bloquear o caso legitimo (arquivo de projeto grande).

---

## GRUPO D — Estados de UI, copy e responsividade

- **E25** [PENDENTE] [ESTADOS DE UI] A secao 4.5 delega o inventario completo de estados ao `design-contract.json` e lista estados por tela apenas como "destaque, nao exaustiva". Para as telas do caminho critico (chao-de-fabrica, estoque, expedicao, ordens) isso deixa o comportamento de loading/vazio/erro sem definicao normativa na SPEC.
  Opcoes: a) Detalhar loading, vazio e erro de forma completa e normativa apenas para as telas do caminho critico do MVP, mantendo a delegacao ao contrato para o resto; b) Detalhar todas as 24 telas; c) Manter a delegacao total
  Sugestao: opcao a - equilibra: onde o operador registra dado critico sob pressao, o comportamento nao pode ser inferido do prototipo.

- **E26** [PENDENTE] [SKELETON] Nao ha definicao de skeleton: a SPEC diz "skeleton/placeholder conforme cmp-data-table e afins", sem layout, sem numero de linhas e sem threshold de exibicao.
  Opcoes: a) Skeleton com o numero de linhas da ultima renderizacao (max 10), exibido apenas apos 300 ms de espera para evitar flash em resposta rapida; b) Spinner central unico; c) Skeleton imediato e fixo em 5 linhas
  Sugestao: opcao a - com meta de 500 ms p95, skeleton imediato pisca na maioria das requisicoes e piora a percepcao de velocidade.

- **E27** [PENDENTE] [COPY] Nenhum texto de interface esta definido: labels de botao, mensagens de sucesso, mensagens de erro, textos de estado vazio. A SPEC so traz um exemplo ("nenhuma ordem aguardando material").
  Opcoes: a) Criar uma secao de copy na SPEC com os textos das acoes criticas (reservar, separar, apontar inicio/fim, consumir, bloquear, resolver bloqueio, inspecionar, expedir, confirmar sincronizacao) em pt-BR, tom imperativo e curto; b) Criar um arquivo de i18n separado referenciado pela SPEC; c) Deixar para o desenvolvedor
  Sugestao: opcao a para o MVP - texto de confirmacao de acao irreversivel (baixa de estoque, expedicao) nao pode ser improvisado no momento da implementacao.

- **E28** [PENDENTE] [COPY / CONFIRMACAO] Acoes irreversiveis nao tem dialogo de confirmacao definido: baixa por lote, confirmacao de movimentacao critica pos-reconexao, expedicao, publicacao de versao de ficha, cancelamento de transferencia.
  Opcoes: a) Dialogo de confirmacao com resumo do impacto (item, quantidade, deposito) e botao rotulado com o verbo da acao (nunca "OK"); para baixa de estoque e expedicao, exigir confirmacao dupla; b) Confirmacao simples em todas; c) Toast com undo de 10 segundos
  Sugestao: opcao a - o padrao de estorno ja definido (contrapartida em 10 min, nunca DELETE) mostra que undo real nao existe no dominio; entao a barreira tem que estar antes.

- **E29** [PENDENTE] [RESPONSIVIDADE] A SPEC define densidade `dense` e sidebar fixa de 230px, e cita telas "responsivas para tablet/celular", mas nao define nenhum breakpoint, nem o que acontece com a sidebar em telas estreitas, nem qual a largura minima suportada.
  Opcoes: a) Breakpoints explicitos: <768px celular (sidebar vira drawer, densidade touch, tabela vira lista de cartoes), 768-1279px tablet (sidebar colapsada em icones, densidade touch), >=1280px desktop (sidebar 230px, densidade dense); b) Apenas dois breakpoints (mobile/desktop em 1024px); c) Delegar ao design-contract.json
  Sugestao: opcao a - as tres classes de dispositivo estao explicitas nas personas do PRD e a tabela densa e o ponto que mais quebra em 360px de largura.

- **E30** [PENDENTE] [TABELA EM MOBILE] Relacionado a E29: nao esta definido o que acontece com `cmp-data-table` (tabelas densas com muitas colunas) em celular, especialmente nas telas operacionais.
  Opcoes: a) Colapsar em cartoes com 3 campos-chave + expandir para detalhe; b) Scroll horizontal com primeira coluna fixa; c) Ocultar colunas secundarias por prioridade definida por tela
  Sugestao: opcao a nas telas operacionais (chao-de-fabrica, estoque, expedicao) e opcao b nas telas de consulta (auditoria, relatorios), porque nelas a comparacao entre colunas e o proprio objetivo.

- **E31** [PENDENTE] [OFFLINE / UX] O PRD exige tela dedicada de reconciliacao pos-reconexao para movimentacoes criticas, mas ela nao existe no mapa de telas da SPEC (4.2) nem nos estados (4.5, que so traz `offline-pendente` em chao-de-fabrica).
  Opcoes: a) Adicionar uma tela/rota dedicada de reconciliacao, acessivel pelo indicador de pendencias do shell, listando cada movimento retido com item, quantidade, deposito, horario de captura e acoes confirmar/descartar; b) Modal sobreposto na tela atual; c) Confirmacao item a item inline na propria tela de origem
  Sugestao: opcao a - a fila pode acumular varias horas de registros de um turno inteiro; modal nao comporta revisao de lote e a rota dedicada permite retomar a revisao depois de uma interrupcao.

- **E32** [PENDENTE] [OFFLINE / EDGE CASE] Nao esta definido o que acontece quando um registro offline se torna invalido apos a reconexao: a ordem foi cancelada, a operacao ja foi concluida por outro operador, o saldo nao cobre mais o consumo, ou a ordem foi bloqueada nesse intervalo.
  Opcoes: a) O item vai para um estado `conflito` na tela de reconciliacao, com o motivo especifico e as acoes de descartar ou ajustar-e-reenviar, nunca sendo aplicado silenciosamente; b) Descartar automaticamente e notificar; c) Forcar a aplicacao e reconciliar depois
  Sugestao: opcao a - descarte automatico apaga trabalho real ja executado no chao de fabrica; a decisao precisa ser humana e auditavel.

- **E33** [PENDENTE] [OFFLINE / LIMITES] Nao ha limite nem politica de expiracao para a outbox local: quantos registros retidos, por quanto tempo, e o que acontece se o armazenamento do navegador encher ou o cache for limpo.
  Opcoes: a) Alerta visual ao passar de 50 registros pendentes, bloqueio de novos registros criticos em 200, aviso de expiracao para registros com mais de 72h e aviso explicito antes de qualquer limpeza de dados do app; b) Sem limite, apenas contador; c) Expirar automaticamente em 24h
  Sugestao: opcao a - limite silencioso do IndexedDB estourando no meio do turno e perda de dado sem aviso, que e exatamente o risco tecnico apontado na Secao 8 do PRD.

- **E34** [PENDENTE] [PERMISSOES / UI] A SPEC define que acoes sem permissao sao ocultadas e que a rota direta leva a `acesso-negado`, mas nao distingue "ocultar" de "desabilitar com explicacao", nem define o comportamento quando a permissao existe mas o estado da ordem impede a acao.
  Opcoes: a) Sem permissao -> acao oculta; com permissao mas estado impeditivo -> acao visivel, desabilitada e com tooltip do motivo (ex.: "ordem bloqueada por impedimento de material"); b) Desabilitar sempre com tooltip em ambos os casos; c) Ocultar em ambos
  Sugestao: opcao a - ocultar por falta de permissao evita expor a estrutura interna de papeis; mas ocultar por estado deixa o usuario sem entender por que a acao sumiu.

---

## GRUPO E — Performance, testes e operacao

- **E35** [PENDENTE] [PERFORMANCE / PROPRIEDADE INTELECTUAL] O PRD define uma restricao forte de "preview seguro": o cliente nao recebe nem executa as regras proprietarias, coeficientes ou decision tables das familias construtivas — consome apenas uma projecao segura, e o servidor e sempre a autoridade final, com divergencia reportada explicitamente. A SPEC nao menciona isso, e ao contrario modela `familias_construtivas.regras (jsonb)` e `formula_bom (jsonb)` sem qualquer recorte de exposicao ao cliente.
  Opcoes: a) Definir na SPEC o contrato da projecao segura enviada ao cliente (o que entra e o que nunca sai do servidor) e o comportamento de divergencia preview x servidor; b) Enviar as regras completas ao cliente para atender os 500 ms; c) Fazer todo preview no servidor, sem calculo local
  Sugestao: opcao a - e a unica que atende simultaneamente a meta de 500 ms p95 e a protecao do ativo central do produto (o motor de regras).

- **E36** [PENDENTE] [TESTES] A SPEC cita Vitest e Playwright na stack, mas nao define criterios de aceite de teste. O PRD e explicito: typecheck e build nao sao prova funcional; casos obrigatorios incluem 401/403/409/422, isolamento cross-tenant, sanitizacao de auditoria, mapeamento pendente do ViaSign, retry/idempotencia de jobs, concorrencia de reserva, e o ciclo offline -> reconexao -> confirmacao explicita.
  Opcoes: a) Adicionar uma secao de estrategia de testes na SPEC com a lista obrigatoria de cenarios do PRD, marcada como criterio de aceite de fase; b) Referenciar o PRD sem repetir; c) Deixar para o planejamento
  Sugestao: opcao a - a SPEC e declarada "fonte de verdade para implementacao"; um criterio de aceite que so existe em outro documento tende a nao ser executado.

- **E37** [PENDENTE] [OBSERVABILIDADE] O PRD cita Sentry com auditoria sanitizada e `request_id` visivel e copiavel pelo usuario em erros 5xx. A SPEC nao menciona Sentry, `request_id`, correlacao de log nem qualquer instrumentacao.
  Opcoes: a) Adicionar `request_id` gerado por requisicao, propagado no header e no corpo de erro, com integracao Sentry sanitizada (sem PII, segredo ou dado de outro tenant); b) Apenas log estruturado no Supabase, sem Sentry no MVP; c) Adiar
  Sugestao: opcao a - sem `request_id` correlacionavel, um erro relatado pelo operador no chao de fabrica e irrastreavel, e o custo de implementar isso depois e alto.

- **E38** [PENDENTE] [CONFIG] O `.env.example` da SPEC (5.3) esta desatualizado frente ao PRD: `JWT_EXPIRY_MINUTES=30` conflita com o access token de ~1h do Supabase; falta variavel separada de timeout touch vs dense (ver E7); faltam variaveis de Sentry, de allowlist de CORS, de rate limit e de URL do frontend para o CORS das Edge Functions.
  Opcoes: a) Atualizar o `.env.example` completo alinhado as decisoes do PRD; b) Atualizar apenas os conflitos diretos; c) Manter
  Sugestao: opcao a - `.env.example` incompleto e a primeira coisa que trava o setup de um novo ambiente.

---

## Resumo

- Total de itens: 38 (E1 e bloqueante)
- PENDENTE: 38 | APROVADO: 0 | APLICADO: 0 | REJEITADO: 0
