# Enriquecimento da SPEC — ViaFab Fase 0+1

> Arquivo de memória do enriquecimento. Fonte de verdade sobre o que já foi sugerido e o status de cada item.
> SPEC alvo: `SPEC20260824_151851.md`
> Status possíveis: [PENDENTE] | [APROVADO] | [APLICADO] | [REJEITADO]

Total de itens: 35

Legenda de prioridade: [BLOQUEADOR] impede começar a implementar | [CRÍTICO] risco de corromper dado/estoque | [INCONSISTÊNCIA] SPEC contradiz PRD ou a si mesma | [REFINAMENTO] lacuna de detalhe

---

## Domínio A — Ficha técnica (rascunho, publicação, roteiro)

- **E1** [APLICADO] [CRÍTICO] [DOMÍNIO A / US-01, RF-03] A SPEC cita "interceptação de navegação" (tabela de rastreabilidade, linha US-01) mas não define o escopo nem as opções da confirmação. Não está dito o que o modal oferece, nem quais navegações são interceptadas (só troca de ficha? sair do módulo Engenharia? fechar/recarregar a aba do navegador?).
  Opções: a) Interceptar apenas a troca de ficha, com 2 ações: "Descartar alterações" e "Continuar editando"; b) Interceptar troca de ficha + saída do módulo Engenharia, com 3 ações: "Descartar", "Manter rascunho e sair", "Continuar editando"; c) Opção (b) + `beforeunload` do navegador ao fechar/recarregar a aba.
  Sugestão: opção b - o rascunho é persistido em `ficha.rascunho`, então "sair mantendo o rascunho" é comportamento legítimo e evita forçar decisão destrutiva; `beforeunload` (c) é ruído em protótipo de demonstração e não é exigido pelo RF-03.

- **E2** [APLICADO] [CRÍTICO] [DOMÍNIO A / US-02, RF-04] O fallback da publicação ("manter snapshot atual da ordem" ou "herdar a nova versão") está declarado na SPEC (3.2, `fn_publicar_ficha`), mas não está dito se a escolha é única para todas as ordens afetadas ou decidida ordem a ordem.
  Opções: a) Escolha única global aplicada a todas as ordens afetadas; b) Escolha por ordem, com checkbox/seletor em cada linha do modal; c) Escolha global com override individual por linha.
  Sugestão: opção a - o PRD descreve o fallback como uma decisão consciente de publicação, não como triagem por ordem; escolha por ordem multiplica a superfície de erro e o esforço num modal que já lista faltas e segmentação.

- **E3** [APLICADO] [CRÍTICO] [DOMÍNIO A / US-02, RF-04] "Ordem aberta (não expedida)" não tem definição operacional na SPEC, e não há regra para ordens que já consumiram material. Herdar nova versão numa ordem com operações `baixado=true` pode divergir a baixa já feita do roteiro novo.
  Opções: a) Definir "aberta" como ordem sem `fim` registrado e permitir herança em qualquer uma delas; b) Definir "aberta" como ordem sem `fim` e **bloquear** a herança para ordens que já tenham alguma operação com `baixado=true` (essas só podem manter o snapshot, com motivo explícito na linha); c) Permitir herança em todas, mas exigir confirmação extra nas ordens com baixa já realizada.
  Sugestão: opção b - é a única que respeita a métrica "zero duplicação de baixa de estoque" do PRD; herdar roteiro novo sobre baixa já executada é exatamente o risco que P0-04/P0-05 tentam eliminar.

- **E4** [APLICADO] [IMPORTANTE] [DOMÍNIO A / US-03, RF-07] A SPEC diz que `setor`, `maquina` e `tempo_padrao` de `ficha.rot[]` "tornam-se editáveis", sem definir regras de edição: unidade e limites do tempo padrão, se máquina precisa pertencer ao setor escolhido, e se é possível adicionar, remover ou reordenar operações.
  Opções: a) Só editar os 3 campos das operações existentes, sem adicionar/remover/reordenar; b) Editar os 3 campos + adicionar, remover e reordenar operações, com mínimo de 1 operação por roteiro; c) Opção (b) + validações: `tempo_padrao` em minutos por unidade, decimal com 2 casas, > 0 e ≤ limite configurável; seletor de `maquina` filtrado pelas máquinas do `setor` escolhido.
  Sugestão: opção c - o critério de aceite do PRD exige que "produtos com fichas diferentes possam ter número de operações, setor e tempo diferentes entre si", o que só é possível adicionando/removendo operações; sem unidade e validação declaradas o campo aceita lixo.

- **E5** [APLICADO] [INCONSISTÊNCIA] [DOMÍNIO A / RNF-09] Em 2.1.2 a SPEC declara `rascunho` e `versao_publicada` como objetos, mas lista `rot[]` como campo irmão, fora dos dois. Isso permite editar o roteiro de uma ficha publicada sem gerar versão, contrariando RNF-09 e o próprio comportamento de `fn_versao_ficha()`.
  Opções: a) Declarar explicitamente que `rot[]` faz parte do conteúdo de `rascunho`/`versao_publicada` (edição só no rascunho, publicação versiona junto); b) Manter `rot[]` fora do versionamento e declarar isso como divergência consciente, alinhada ao fato de `roteiros_base` não ter trigger de versionamento (pendência já registrada para a Fase 4); c) Versionar `rot[]` junto com a ficha e registrar em `audit()` toda edição de roteiro.
  Sugestão: opção a - RNF-09 é explícito sobre não divergir do backend; o roteiro é conteúdo da ficha e um snapshot de ordem que aponta para uma versão precisa incluir o roteiro daquela versão.

---

## Domínio B — Planejamento, chão de fábrica e almoxarifado

- **E6** [APLICADO] [REFINAMENTO] [DOMÍNIO B / US-04, RF-08] O modal de preview de `fn_gerar_ordens` lista "por ordem a criar: produto, quantidade, faltas e componentes", sem limite. Uma fila grande de planejamento gera um modal impraticável.
  Opções: a) Sem limite, modal com rolagem interna; b) Listar as primeiras N linhas (ex.: 20) + resumo agregado "+ X outras ordens" com totais; c) Modal só com totais agregados + link "ver detalhe" que expande.
  Sugestão: opção b - preserva a consequência visível exigida por RNF-03 sem transformar a confirmação numa tabela infinita; o total continua sendo o número do rótulo vivo do botão.

- **E7** [APLICADO] [IMPORTANTE] [DOMÍNIO B / US-04, RF-08] O PRD e a SPEC dizem que o preview mostra "faltas de material identificadas", mas não dizem o que a falta faz com a ação. Não está definido se falta bloqueia, avisa ou gera ordem mesmo assim.
  Opções: a) Falta apenas informa; a geração prossegue normalmente; b) Falta informa e a ordem gerada nasce com `bloqueio_motivo` preenchido (reaproveitando o campo novo de US-28); c) Falta bloqueia a geração das ordens afetadas, permitindo gerar só as demais.
  Sugestão: opção b - reaproveita estrutura já criada nesta fase, mantém a decisão com o PCP e faz o operador enxergar o motivo real do represamento na fila (US-28/RF-47), fechando o handoff.

- **E8** [APLICADO] [CRÍTICO] [DOMÍNIO B / US-05, RF-11, RNF-04] A janela de 10 minutos está definida no dado (`janela_expira_em`), mas não na interface. Não está dito a partir de qual evento ela conta, o que o usuário vê enquanto está aberta, e o que aparece quando expira.
  Opções: a) Conta a partir da gravação da finalização; enquanto aberta, botão "Corrigir apontamento" visível; ao expirar, botão some; b) Igual (a), mas ao expirar o botão fica **desabilitado com motivo explícito** ("janela de correção expirada — solicite desbloqueio ao PCP"), coerente com RNF-07; c) Igual (b) + contador regressivo visível (ex.: "corrigível por mais 7 min").
  Sugestão: opção c - botão que some sem explicação é exatamente o "rótulo falso por omissão" que RNF-07 ataca, e o contador elimina a dúvida de quanto tempo resta numa janela curta.

- **E9** [APLICADO] [CRÍTICO] [DOMÍNIO B / US-05, RF-10] A SPEC exige "evento explícito de desbloqueio" para reabrir operação já baixada, mas não define **qual perfil** pode emitir esse evento. US-28/RF-47 já estabelece que o operador não destrava.
  Opções: a) Apenas `pcp` com permissão de escrita; b) `pcp` e `qualidade` (esta última só no caminho de reprovação); c) Qualquer perfil com `w` no módulo `ordens`.
  Sugestão: opção b - o PRD atribui o destravamento ao PCP (US-28) mas também descreve o desbloqueio por reprovação conduzido pela Qualidade (US-09); separar os dois caminhos evita que a Qualidade dependa do PCP para abrir retrabalho.

- **E10** [APLICADO] [INCONSISTÊNCIA] [DOMÍNIO B / US-06, RNF-03] A SPEC (4.6) lista `fn_reservar_material` entre as ações que exigem `confirmarEfeito()` obrigatoriamente, mas as três ações do almoxarifado têm naturezas diferentes: "Recalcular" é preview, "Liberar" é reversível (basta reservar de novo) e "Reservar" grava. RNF-03 diz explicitamente que ações reversíveis **não** devem exigir confirmação.
  Opções: a) Manter `confirmarEfeito()` nas três ações; b) `confirmarEfeito()` apenas em "Reservar materiais"; "Recalcular" apenas exibe o delta (sem gravar) e "Liberar" executa direto com `toast()` + `audit()`; c) `confirmarEfeito()` em "Reservar" e "Liberar"; "Recalcular" como preview puro.
  Sugestão: opção b - é a leitura literal de RNF-03; liberar uma reserva devolve saldo ao disponível e é trivialmente refeito, então confirmá-la degrada o valor do próprio modal de confirmação nas ações que realmente importam.

- **E11** [APLICADO] [IMPORTANTE] [DOMÍNIO B / US-06, RF-12] Nenhum documento define o comportamento quando o saldo disponível é menor que a necessidade calculada da ordem. Sem regra, o desenvolvedor decide sozinho se grava reserva parcial, recusa ou permite saldo negativo.
  Opções: a) Reservar o disponível (reserva parcial) e sinalizar a diferença como falta na tela; b) Recusar a reserva inteira com motivo explícito e nenhum saldo movimentado; c) Reservar o total pedido, permitindo saldo negativo, com alerta.
  Sugestão: opção a - é o comportamento operacional real de almoxarifado (reserva o que tem, registra a falta) e conversa diretamente com a apuração de faltas de E7; saldo negativo (c) corrompe o indicador de disponibilidade.

---

## Domínio C — Handoffs Qualidade / Expedição

- **E12** [APLICADO] [INCONSISTÊNCIA] [DOMÍNIO C / US-08, RF-17] A SPEC (4.3, "Leitura de unidades retidas") define o filtro como `DB.ordens[].filter(o => o.qa && !o.qa.aprovado)`, que só captura ordens **reprovadas**. RF-17 e o critério de aceite de US-08 exigem contar também as ordens **sem parecer**. Do jeito que está, unidades aguardando inspeção continuam invisíveis na Expedição — que é o P0-03 original.
  Opções: a) Corrigir o filtro para `o.concluida && (!o.qa || !o.qa.aprovado)`, com a stat quebrada em "sem parecer" e "reprovadas"; b) Manter dois filtros separados e duas stats distintas na tela; c) Manter como está (só reprovadas).
  Sugestão: opção a - é literalmente o que RF-17 pede ("sem parecer ou reprovadas", com número total de unidades e de ordens) e mantém uma única stat, como descrito no PRD.

- **E13** [APLICADO] [CRÍTICO] [DOMÍNIO C / US-08, US-09, RF-18, RF-19] `ordem.qa` está especificado em 2.1.2 apenas como `{ aprovado: boolean }`. Não há campo para motivo/observação da reprovação, autor nem data — mas RF-18 exige "motivo explícito" no bloco de expedição e RF-19 exige "próximo passo" explícito, e RNF-06 exige autor e timestamp no handoff.
  Opções: a) Estender `ordem.qa` para `{ aprovado, motivo, autor, criado_em }`, com `motivo` obrigatório quando `aprovado=false`; b) Igual (a), com `motivo` escolhido de lista fechada de motivos de reprovação + campo livre opcional; c) Manter só `aprovado` e derivar o texto de motivo de uma mensagem genérica fixa.
  Sugestão: opção b - lista fechada permite agrupar reprovações em relatório futuro sem depender de texto livre, e o campo complementar cobre o caso não previsto; a opção (c) reintroduz rótulo genérico que não informa o expedidor.

- **E14** [APLICADO] [CRÍTICO] [DOMÍNIO C / US-09, RF-20] O desbloqueio por reprovação reabre a última operação com `status='Pendente'` e `baixado=false`. A SPEC não diz o que acontece com o material já baixado dessa operação: ao refinalizar, `fn_finalizar_operacao` baixaria material de novo, duplicando o consumo — exatamente o efeito cascata P0-04↔P0-05 que o PRD quer eliminar.
  Opções: a) Ao reabrir, gerar linha em `estorno_apontamento` (`tipo='desbloqueio'`) revertendo a baixa; a refinalização baixa normalmente; b) Ao reabrir, manter a baixa original e a refinalização **não** baixa material de novo (retrabalho usa o material já consumido); c) Perguntar ao usuário no momento do desbloqueio se haverá novo consumo de material.
  Sugestão: opção c com default na (b) - retrabalho às vezes reaproveita a peça e às vezes exige material novo; deixar isso implícito é o que gera divergência de estoque. O modal de desbloqueio já existe e pode carregar essa escolha, sempre registrada em `estorno_apontamento`.

- **E15** [APLICADO] [IMPORTANTE] [DOMÍNIO C / US-09] Não está definido qual perfil executa o desbloqueio da ordem retida por reprovação, nem se a Expedição pode fazê-lo. O CTA descrito em US-08 leva o expedidor "para acompanhar o status na Qualidade", o que sugere leitura, não ação.
  Opções: a) `qualidade` com `w` desbloqueia; `expedicao` apenas visualiza; b) `qualidade` e `pcp` desbloqueiam; `expedicao` apenas visualiza; c) Qualquer perfil com `w` em `qualidade` ou `expedicao`.
  Sugestão: opção b - alinhada a E9; a Expedição é destino do sinal, não dona da decisão, e o PRD mantém o PCP como ponto de destrave de ordem.

---

## Domínio D — Importação ViaSign (.vfb)

- **E16** [APLICADO] [BLOQUEADOR] [DOMÍNIO D / US-11, RF-23] A SPEC (2.1.2, tabela `VFB_PEL`) registrava a entrada da película tipo IV literalmente como "*(código a definir pela engenharia de catálogo)*". Como a SPEC é a fonte de verdade para implementação, esse item não podia ser implementado como estava.
  Opções: a) Definir agora o código seguindo o padrão de 3 letras já usado (ex.: `GDP`, `AID`, `TIV`); b) Manter "a definir" e implementar com placeholder + aviso na tela até a engenharia decidir; c) Reutilizar um código existente temporariamente.
  Sugestão: opção a com o código a ser informado por você - qualquer placeholder (b) recria justamente o "rótulo falso" que RNF-07 proíbe, e (c) corromperia o catálogo. Preciso do código correto ou da sua autorização para fixar um.
  **RESOLUÇÃO (24/08, escalado e respondido pelo dono do produto): opção a, com o código `IV`.** `VFB_PEL` passa a mapear `IV` → `IV`. Não há sigla de 3 letras para este tipo; o próprio numeral da norma é o código. A SPEC foi editada em 2.1.2 com a linha da tabela **e** com uma nota de "desvio de padrão consciente", registrando que chave e código coincidirem é intencional e não deve ser "corrigido" na implementação nem em revisão futura — sem essa nota, o desvio seria lido como pendência esquecida e alguém inventaria uma sigla. `mapearPlacaVfb()` não requer tratamento especial.

- **E17** [APLICADO] [IMPORTANTE] [DOMÍNIO D / US-10, RF-22] O segmented control separa "pacote real" de "dados de demonstração", mas não está definido o que acontece ao alternar depois de já haver um pacote carregado/validado em tela. Sem regra, alternar pode misturar dados dos dois modos — que é a "alternância silenciosa" que RF-22 tenta eliminar.
  Opções: a) Alternar limpa o estado carregado sem avisar; b) Alternar com dados carregados abre confirmação ("isso descarta o pacote carregado") e só então limpa; c) Alternar fica desabilitado enquanto houver pacote carregado, exigindo "Cancelar importação" antes.
  Sugestão: opção b - preserva o gesto natural do controle e impede perda silenciosa; desabilitar (c) sem caminho óbvio de saída trava o usuário.

- **E18** [APLICADO] [IMPORTANTE] [DOMÍNIO D / RF-48, D-04] O aviso de colisão de `chave_dimensao` exige "confirmação manual explícita antes da confirmação da importação", mas não está dito se a confirmação é por linha ou única para todas as colisões, nem se a confirmação fica registrada.
  Opções: a) Uma confirmação global cobrindo todas as linhas em colisão; b) Confirmação por linha (checkbox "conferido") e o botão de importar só habilita quando todas as linhas em colisão estiverem conferidas, com `audit()` registrando quantas colisões foram confirmadas e por quem; c) Apenas aviso visual, sem bloqueio.
  Sugestão: opção b - colisão dimensional é erro que produz peça errada; conferência linha a linha é o único formato que força o olhar sobre a dimensão específica, e o registro em auditoria dá rastreabilidade a quem assumiu o risco.

- **E19** [APLICADO] [REFINAMENTO] [DOMÍNIO D / US-12, RF-24, RNF-05] A SPEC (2.1.2) diz que `origem.usuario` "não é exibido em nenhuma tela", mas RF-24 é mais amplo: "em qualquer tela **ou exportação** do sistema". As exportações CSV/PDF desta fase (auditoria, relatórios, OS) não são cobertas pelo texto atual.
  Opções: a) Estender a regra na SPEC para telas, exportações CSV/PDF e conteúdo de QR; b) Manter apenas telas e registrar exportações como pendência da Fase 4; c) Remover o campo do objeto em memória logo após a importação.
  Sugestão: opção a - é a redação do próprio RF-24 e custa uma linha de SPEC; (c) é tentador mas quebraria a rastreabilidade de origem prevista para o contrato futuro com o ViaSign.

---

## Domínio E — Início, atalhos e navegação por teclado

- **E20** [APLICADO] [REFINAMENTO] [DOMÍNIO E / US-16, RF-29] O gap do atalho `/` está declarado, mas sem comportamento definido para dois casos previsíveis: tela sem campo de filtro e `/` digitado dentro de um input/textarea.
  Opções: a) `/` dentro de campo de texto digita a barra normalmente; em tela sem filtro, não faz nada silenciosamente; b) Igual (a), mas em tela sem filtro exibe `toast()` "esta tela não possui filtro"; c) Em tela sem filtro, `/` abre a paleta de comandos como fallback.
  Sugestão: opção a - silêncio é o comportamento padrão de atalhos que não se aplicam; toast repetido (b) vira ruído e (c) surpreende o usuário com uma ação que ele não pediu.

- **E21** [APLICADO] [REFINAMENTO] [DOMÍNIO E, TRANSVERSAL] A seção 4.6 (Estados de UI) cobre estado vazio apenas da fila de inspeção e da fila do operador. Faltam os estados vazios de listas que ganham filtro/busca nesta fase: paleta de comandos sem resultado, auditoria sem registro após filtro, e importador sem linha válida.
  Opções: a) Adicionar linha na tabela 4.6 definindo texto e comportamento padrão para "lista filtrada sem resultado" (mensagem + ação "limpar filtros" quando houver filtro ativo); b) Definir estado vazio caso a caso em cada tela; c) Deixar como está.
  Sugestão: opção a - uma regra transversal evita três implementações divergentes e é consistente com a lógica de "rótulo verdadeiro"; distinguir "vazio porque não há dado" de "vazio porque o filtro escondeu" é o ponto que mais confunde usuário.

---

## Domínio F — Acessibilidade e temas

- **E22** [APLICADO] [BLOQUEADOR] [DOMÍNIO F / US-18, US-19, RF-31, RF-33] A SPEC (4.5) diz que os tokens `--text-faint`, `--text-dim`, `--accent-text` e `--text-on-accent` são "recalibrados para AA" e que os tokens escuros "sobem 1 degrau", sem fixar nenhum valor final. Como a SPEC é a fonte de verdade, cada desenvolvedor chegaria a um hex diferente. O PRD já registra dois valores verificados no código: `--accent-text:#9b5239` (claro, 4,68:1) e `--text-on-accent:#1c1c1a`.
  Opções: a) Fixar na SPEC os valores hex finais dos 4 tokens nos 2 temas, com a razão de contraste medida ao lado de cada um; b) Não fixar valores e definir apenas o critério numérico (≥4,5:1 / ≥3:1), deixando o hex para a implementação, desde que o script de contraste valide; c) Fixar só os tokens do tema claro (onde está o problema medido) e manter critério para o escuro.
  Sugestão: opção a - "recalibrado" não é instrução implementável; fixar o hex com a razão medida torna a métrica de sucesso do PRD verificável linha a linha e impede regressão silenciosa em fase futura.

- **E23** [APLICADO] [IMPORTANTE] [DOMÍNIO F / RNF-01] A SPEC exige "script automatizado de verificação de contraste rodando nos 2 temas", mas o projeto não tem build, `package.json` de app, nem etapa de CI descrita para esta fase. Não está definido onde o script vive, como é executado nem o que constitui falha.
  Opções: a) Script embutido no próprio `prototype/index.html` sob uma flag de debug (ex.: `?a11y=1`), imprimindo o relatório no console e falhando visivelmente na tela; b) Script Node standalone em `tools/contraste.mjs`, executado manualmente, lendo os tokens do CSS e emitindo relatório — sem tocar no protótipo; c) Verificação manual com ferramenta externa, documentada como checklist.
  Sugestão: opção b - mantém a Decisão F-1 intacta (nenhuma dependência de runtime no protótipo) e ainda assim entrega um verificador repetível e portável para a CI da Fase 4; (a) polui o design lock e (c) não é "automatizado" como RNF-01 exige.

---

## Domínio G — Painel e relatórios

- **E24** [APLICADO] [REFINAMENTO] [DOMÍNIO G / US-21, RF-35] Não está definido qual período (7/30/90) vem selecionado ao abrir o Painel, nem se a escolha do usuário persiste entre navegações e sessões.
  Opções: a) Default 30 dias, sem persistência (reseta a cada entrada na tela); b) Default 30 dias, persistido em `localStorage` por usuário; c) Default 7 dias, sem persistência.
  Sugestão: opção b - 30 dias é a janela gerencial mais comum e já é o rótulo citado no PRD; persistir respeita a rotina de quem consulta o painel diariamente e usa o mesmo mecanismo já adotado para atalhos pessoais.

- **E25** [APLICADO] [IMPORTANTE] [DOMÍNIO G / US-22, RF-37] Com o denominador passando a excluir ordens sem `fim`, é possível que nenhuma ordem se qualifique no período selecionado. A SPEC não define o que o card de aderência exibe nesse caso — e "0%" seria um número falso.
  Opções: a) Exibir "—" com rótulo "sem ordens concluídas no período"; b) Exibir 0%; c) Ocultar o card quando não houver base.
  Sugestão: opção a - 0% (b) afirma atraso que não ocorreu, violando RNF-07, e ocultar (c) faz o card sumir sem explicação; o traço com rótulo é o único que declara a ausência de base.

- **E26** [APLICADO] [REFINAMENTO] [DOMÍNIO G / US-23, RF-39] "Janela retrospectiva real" não define a data base nem se o dia corrente entra. Sem isso, dois relatórios do mesmo dia podem divergir e o cabeçalho impresso mente por 1 dia.
  Opções: a) Janela = [hoje − N dias, hoje], inclusiva nas duas pontas, com o cabeçalho imprimindo as duas datas concretas (ex.: "25/07/2026 a 24/08/2026"); b) Janela = [hoje − N dias, ontem], excluindo o dia corrente incompleto; c) Manter janela simétrica com rótulo "±N dias", conforme alternativa aceita pelo PRD.
  Sugestão: opção a - imprimir as duas datas concretas resolve a ambiguidade de vez e é a leitura literal de "últimos 30 dias" para quem opera; o rótulo "±N" (c) é permitido pelo PRD, mas é a alternativa de contingência, não a preferida.

---

## Domínio H — OS / QR

- **E27** [APLICADO] [CRÍTICO] [DOMÍNIO H / US-24, RF-40] `os_ids[].grupo_chave` é descrito em 2.1.2 apenas como "chave do grupo de itens da OS (não posicional)". A **composição** dessa chave não está definida em lugar nenhum — e ela é o coração do P0-20: se a chave for instável, o ID estável não existe.
  Opções: a) `grupo_chave` = hash/concatenação ordenada dos `id` das ordens que compõem a OS; b) `grupo_chave` = `pedido_id` + destino/entrega (a OS é sempre um agrupamento de entrega, e a composição de itens pode variar); c) `grupo_chave` = identificador do agrupamento escolhido pelo usuário no momento da primeira emissão, persistido a partir daí.
  Sugestão: opção a - é a única que garante literalmente "mesmo grupo de itens → mesmo ID" (critério de aceite de US-24); a ordenação dos ids antes de compor a chave é o que a torna não posicional.

- **E28** [APLICADO] [IMPORTANTE] [DOMÍNIO H / US-24, RF-40, RF-41] Não estão definidos o formato do `os_id` (prefixo, largura, sequencial) nem o comportamento quando a composição do grupo muda entre emissões (item adicionado ou removido).
  Opções: a) Formato `OS-000123` (sequencial local com 6 dígitos); grupo alterado gera **nova** `grupo_chave` e, portanto, novo `os_id`, mantendo o QR antigo apontando para o grupo antigo; b) Mesmo formato, mas grupo alterado **reaproveita** o `os_id` anterior (a OS "evolui"); c) Formato livre (UUID), com o restante igual a (a).
  Sugestão: opção a - reaproveitar o ID (b) é exatamente o cenário "o QR de ontem abre o grupo errado hoje" que US-24 quer eliminar; sequencial legível é preferível a UUID em etiqueta impressa e lida por humano.

---

## Domínio I — Auditoria

- **E29** [APLICADO] [INCONSISTÊNCIA] [DOMÍNIO I / US-25, RF-44, S-7] A SPEC (4.3) diz que a exportação opera sobre "a lista já filtrada... por unidade/período/busca/**paginação** vigentes". Incluir a paginação no recorte significa exportar **apenas a página visível**, o que provavelmente não é a intenção de quem investiga uma ocorrência e contraria o objetivo de US-25 ("sem depender de rolagem manual").
  Opções: a) Exportar todo o conjunto filtrado, ignorando a paginação (que é só apresentação), com o cabeçalho declarando os filtros aplicados e o total de linhas; b) Exportar apenas a página atual, conforme a redação vigente; c) Perguntar no momento da exportação ("página atual" ou "tudo que está filtrado").
  Sugestão: opção a - paginação é recurso de visualização, não critério de recorte de dado; o isolamento por tenant exigido por RNF-08 continua garantido pelo filtro de unidade, que permanece aplicado.

- **E30** [APLICADO] [REFINAMENTO] [DOMÍNIO I / US-25, RF-43, RF-44] Não estão definidos o tamanho da página da lista de auditoria nem o formato do CSV (separador, codificação, colunas exportadas, formato de data).
  Opções: a) 50 linhas por página; CSV com separador `;`, UTF-8 com BOM, datas em `dd/MM/yyyy HH:mm`, colunas = as mesmas exibidas na tabela; b) 25 linhas por página; CSV padrão internacional (`,`, UTF-8 sem BOM, data ISO 8601); c) Deixar indefinido, seguindo o que já existe no código.
  Sugestão: opção a - o consumidor real do arquivo é o Excel em pt-BR, onde `,` e a ausência de BOM quebram acentuação e colunas; 50 linhas equilibra rolagem e número de páginas numa trilha densa.

---

## Domínio J — Comercial / Operador

- **E31** [APLICADO] [IMPORTANTE] [DOMÍNIO J / US-26, RF-45] A SPEC introduz `area_geometrica_m2` e `faturamento_criterio`, e o PRD condiciona a exibição a "quando aplicável ao item" — sem definir a regra de aplicabilidade nem a origem do valor da área geométrica (calculada da geometria da placa ou informada manualmente).
  Opções: a) Exibir os dois números sempre que `faturamento_criterio` estiver preenchido; área geométrica informada manualmente no item de contrato; b) Exibir os dois sempre que `area_geometrica_m2` existir e diferir de `area_nominal_m2`; valor derivado da geometria do produto quando disponível, com override manual; c) Exibir os dois sempre, repetindo o valor nominal quando não houver geométrica.
  Sugestão: opção b - exibir números idênticos lado a lado (c) só gera dúvida, e a derivação automática com override cobre tanto a placa padrão quanto o recorte especial; o rótulo explícito de propósito exigido por RF-45 permanece em ambos.

- **E32** [APLICADO] [IMPORTANTE] [DOMÍNIO J / US-28, RF-47] `bloqueio_motivo` é declarado como `string|null` exibida em modo leitura, mas não está definido quem preenche, quando, se é obrigatório ao bloquear e se é texto livre ou vocabulário fechado. Texto livre inconsistente esvazia o objetivo de "entender o que está represado sem perguntar ao PCP".
  Opções: a) Texto livre obrigatório preenchido pelo PCP no momento do bloqueio; b) Lista fechada de motivos (falta de material, reprovação de qualidade, aguardando ficha, parada de máquina, outro) + campo livre obrigatório quando "outro"; c) Preenchido automaticamente pelo sistema quando o bloqueio é derivado (falta de material em E7, reprovação em US-09) e manual nos demais casos.
  Sugestão: opção b combinada com (c) - motivo automático quando o sistema conhece a causa, lista fechada + complemento quando o bloqueio é manual; é o que garante rótulo consistente na fila do operador.

---

## Transversais

- **E33** [APLICADO] [CRÍTICO] [TRANSVERSAL / 2.1.2] A SPEC diz que o protótipo opera sobre "objeto `DB` em memória + `localStorage`", mas não diz **quais** das estruturas novas persistem e quais são voláteis. Isso é decisivo para `os_ids[]`: se não persistir, o ID "estável" se perde ao recarregar a página e US-24 falha. Também não há chave de `localStorage` nem estratégia para dados gravados por versões anteriores do protótipo.
  Opções: a) Persistir em `localStorage` apenas `os_ids[]`, `usuario_atalhos` e `DB.auditoria` (o que já é persistido hoje), mantendo o restante em memória; b) Persistir também `estorno_apontamento`, `DB.reservas[]` e `DB.ordens[]`; c) Definir chave namespaced (`viafab.<estrutura>.v1`) + descarte silencioso de dado com versão diferente, aplicável à opção escolhida.
  Sugestão: opção a combinada com (c) - `os_ids[]` precisa sobreviver ao reload por definição de US-24; persistir ordens e reservas (b) transforma o protótipo de demonstração num banco de dados frágil e dificulta reset entre demos. O namespacing versionado evita que um `localStorage` antigo quebre a tela.

- **E34** [APLICADO] [IMPORTANTE] [TRANSVERSAL / COPY] A SPEC não define nenhum texto de interface, exceto três rótulos ("Gerar N ordens", "roteiro base herdado", "Retidas pela qualidade"). Ficam sem copy definida: os quatro modais de `confirmarEfeito()` (frase da consequência e aviso de irreversibilidade), os toasts de sucesso/erro, os motivos de bloqueio e os rótulos de exclusão exigidos por RNF-07.
  Opções: a) Adicionar à SPEC uma tabela de copy com o texto exato de cada modal de confirmação, toast e rótulo de exclusão desta fase; b) Definir apenas o **padrão** de redação (estrutura da frase de consequência, do aviso de irreversibilidade e do rótulo de exclusão) e deixar o texto por conta da implementação; c) Deixar como está.
  Sugestão: opção a - o helper `confirmarEfeito()` foi criado justamente para que as quatro confirmações não divirjam; deixar o texto solto (b) recria a divergência que o helper elimina, e RNF-07 ("rótulo e comportamento devem corresponder exatamente") só é auditável com o texto escrito.

- **E35** [APLICADO] [REFINAMENTO] [TRANSVERSAL / VERIFICAÇÃO] Vários P0 entram na SPEC como "verificação/regressão" de correções já aplicadas (P0-03, P0-11, P0-12, P0-13, P0-14, P0-16, P0-17, P0-21), mas a SPEC não define o que constitui **evidência** de que a regressão passou — enquanto a métrica do PRD exige "zero P0 remanescentes" verificado ao final.
  Opções: a) Adicionar à SPEC uma seção "Critérios de verificação" com um roteiro objetivo por P0 de regressão (ação → resultado esperado); b) Registrar apenas que a verificação é manual, sem roteiro; c) Deixar como está e tratar na fase de testes.
  Sugestão: opção a - sem roteiro, "verificado" vira opinião; um roteiro curto por item torna a métrica do PRD auditável e serve de base direta para os testes E2E da fase seguinte.

---

## Histórico de aplicação

**24/08 — Aprovação em bloco de 34 itens (E1-E15, E17-E35), seguindo exatamente a "Sugestão" de cada um. E16 escalado ao dono do produto e mantido [PENDENTE] naquele momento.**

**24/08 (2ª rodada) — E16 respondido pelo dono do produto: código da película tipo IV é `IV`. Aplicado em 2.1.2 (`VFB_PEL` + nota de desvio de padrão consciente).**

Status final: **35 [APLICADO] · 0 [PENDENTE] · 0 [REJEITADO]** — nenhuma lacuna aberta.

Onde cada item entrou na SPEC:

| Seção da SPEC | Itens aplicados |
|---|---|
| 2.1.2 — `DB.ordens[]` (linhas `qa`, `bloqueio_motivo`) | E13, E32 |
| 2.1.2 — novas sub-tabelas `ordem.qa`, `MOTIVOS_REPROVACAO[]`, `ordem.bloqueio_motivo`, `MOTIVOS_BLOQUEIO` | E13, E32 |
| 2.1.2 — `DB.reservas[]` (+`qtd_necessaria`, `qtd_faltante`) e regra de saldo insuficiente | E11 |
| 2.1.2 — `ficha` (`rot[]` como conteúdo versionado) + tabela "Regras de edição do roteiro" | E5, E4 |
| 2.1.2 — `os_ids[]` (+`seq`) + bloco "Composição de `grupo_chave`" | E27, E28 |
| 2.1.2 — `item_contrato` + regra de exibição das duas áreas | E31 |
| 2.1.2 — `origem.usuario` + bloco "Abrangência da supressão" | E19 |
| 2.1.2 — `VFB_PEL` (`IV` → `IV`) + nota de desvio de padrão consciente | E16 |
| **2.1.3 (nova)** — Persistência: `localStorage` vs. volátil, namespacing `viafab.<estrutura>.v<N>` | E33 |
| 3.2 — `fn_gerar_ordens` (falta de material, limite do preview) | E7, E6 |
| 3.2 — `fn_finalizar_operacao` (perfil autorizado, janela de 10 min, retrabalho e material) | E9, E8, E14 |
| 3.2 — `fn_reservar_material` (confirmação por ação, saldo insuficiente) | E10, E11 |
| 3.2 — `fn_publicar_ficha` (definição de "aberta", fallback global, restrição por baixa, roteiro inválido) | E3, E2, E4 |
| 3.2 — bloco "Confirmação de colisão dimensional" | E18 |
| 3.2 — bloco "Interceptação de navegação com rascunho aberto" | E1 |
| 4.3 — filtro de unidades retidas corrigido | E12 |
| 4.3 — escopo da exportação de auditoria (paginação fora do recorte) | E29 |
| 4.3 — regra transversal de estado vazio de lista filtrada | E21 |
| 4.5 — tabela normativa de tokens com hex e razão medida | E22 |
| 4.5 — bloco "Onde vive e como roda o verificador de contraste" (`tools/contraste.mjs`) | E23 |
| 4.6 — 7 linhas novas na tabela de Estados de UI | E1, E8, E10, E17, E20, E21, E25 |
| **4.7 (nova)** — Textos de interface (copy normativa: modais, toasts, rótulos de exclusão) | E34 |
| **4.8 (nova)** — Regras de janela temporal (Painel e Relatórios) | E24, E25, E26 |
| **4.9 (nova)** — Auditoria: paginação e formato de exportação | E30 |
| **6 (nova)** — Critérios de Verificação (6.1 regressão, 6.2 construção nova) | E35 |
| 7 — antiga seção 6 renumerada (Pendências Fase 4) | — |

Observação de consistência: nenhuma seção foi reescrita; todas as intervenções foram aditivas ou substituições pontuais de linha. As decisões de escopo (S-1, B-1, F-1) permanecem intactas — nenhum item aprovado introduz migration, Edge Function, dependência de runtime no protótipo ou tela nova.
