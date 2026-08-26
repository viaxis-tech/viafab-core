# Architecture Decisions: viafab-core/20260825_085318-4ff9ed

## Context
- **Selected candidate:** C1
- **Source files:**
  - C:\Users\Claudio Fernandes\Desktop\repo-files\viafab-core\.lionclaw\pipelines\architecture-review\20260825_085318-4ff9ed\ArchitectureMap-20260825_085318-4ff9ed.md
  - C:\Users\Claudio Fernandes\Desktop\repo-files\viafab-core\.lionclaw\pipelines\architecture-review\20260825_085318-4ff9ed\ArchitectureCandidates-20260825_085318-4ff9ed.md
  - C:\Users\Claudio Fernandes\Desktop\repo-files\viafab-core\.lionclaw\pipelines\architecture-review\20260825_085318-4ff9ed\ArchitectureDiagnosis-20260825_085318-4ff9ed.md

---

## D1 - Encarnacao fisica do seam de dados

- **Pergunta:** Onde o seam de acesso a dados de C1 vai viver fisicamente, dado que `prototype/index.html` tem um unico `<script>` classico (L15286), zero `import`/`export`, e o repositorio nao tem `package.json`, test runner nem CI?
- **Opcoes consideradas:**
  - A) Seam dentro do mesmo `<script>` single-file — custo de infra zero, mas nenhuma regra fica executavel em Node; os 42 sitios de escrita mudariam sem rede de protecao.
  - B) Extracao total do dominio para modulos ES — leverage maxima, porem big bang sobre 75 funcoes `render*`/`init*` e o boot, num arquivo de 26.081 linhas sem teste de regressao.
  - C) Extracao apenas do nucleo (porta de dados + regras ja quase puras) para `.mjs`, mantendo o restante no single-file, com `<script type="module">` e reexposicao no global para o codigo legado.
- **Decisao:** Opcao C — extrair o nucleo para arquivo(s) `.mjs` sob `prototype/`, carregado via `<script type="module">`, importado tanto pelo `index.html` quanto por testes em Node. O usuario confirmou que o prototipo e servido por HTTP (servidor local), portanto a restricao de CORS do `file://` nao se aplica.
- **Razao:** E a unica opcao que cria a capacidade de executar dominio em Node **antes** de mover os 42 sitios de escrita, sem exigir mover tudo. O Diagnosis registra que o padrao correto ja foi inventado no proprio codigo (`lerLocal`/`gravarLocal`, L15618-15638) e nunca generalizado; a opcao C generaliza esse padrao num escopo controlado. A opcao A preservaria o risco de execucao apontado no Diagnosis (mudanca de 42 sitios sem rede de protecao) e a opcao B ampliaria esse risco em vez de reduzi-lo. O usuario aceitou a recomendacao e confirmou a pre-condicao tecnica (HTTP).
- **Implica:**
  - O prototipo passa a depender de ser servido por HTTP; abrir por `file://` deixa de funcionar. Isso vira pre-condicao documentada, nao um efeito colateral.
  - Surge a necessidade de infra minima de execucao (test runner em Node) — hoje o unico executavel e `tools/contraste.mjs`, que le o HTML como texto.
  - O `.mjs` precisa reexpor no escopo global os identificadores que o codigo legado do single-file ainda consome, ate que os call sites migrem.
  - Abre a decisao seguinte: **o que exatamente entra no primeiro corte** e qual a **forma da porta** (sincrona vs assincrona), ja que 100% do dominio e sincrono hoje.
  - O design lock e o markup das 25 telas permanecem intocados nesta decisao.
- **Timestamp:** 08:58

---

## D2 - Forma da porta de dados: sincrona vs assincrona

- **Pergunta:** A porta de dados de C1 expoe leitura e escrita de forma sincrona, assincrona, ou hibrida (leitura sincrona sobre snapshot em memoria + escrita assincrona)? Fato verificado por Grep nesta sessao: 117 sitios entre `render*`/`init*` e escritas `DB.<colecao>.push/unshift/splice`, e apenas 6 ocorrencias de `await`/`Promise`/`.then` no arquivo inteiro (todas do adapter VFB, leitura de arquivo local — nao rede).
- **Opcoes consideradas:**
  - A) Porta totalmente sincrona — encaixa no codigo atual sem tocar em ninguem, mas nao acomoda o segundo adapter (Supabase); seria indirecao decorativa, nao seam.
  - B) Porta totalmente assincrona — todo metodo retorna Promise; correta para o adapter remoto, ao custo de propagar `async` por transitividade aos 117 sitios de uma vez.
  - C) Hibrida — leitura sincrona servida de snapshot em memoria (as 75 `render*` nao mudam), escrita assincrona (apenas os ~42 sitios de escrita mudam).
- **Decisao:** Opcao B — porta totalmente assincrona desde o inicio. Conversao de todo o dominio para `async`/`await` agora, em vez de faseada. **Esta decisao rejeita a recomendacao do entrevistador, que era a opcao C.**
- **Razao:** Escolha explicita do usuario ("converter tudo agora"), sem elaboracao adicional. O enquadramento oferecido na pergunta e que sustenta a escolha: a opcao C obriga a conviver com divergencia entre o snapshot local e o servidor (a tela pode mostrar o que o RLS filtra diferente — risco ja listado no Diagnosis) e a admitir escritas que falham **depois** de a UI ter sinalizado sucesso; alem disso, C adia para uma segunda etapa a conversao das leituras, pagando o custo de migracao duas vezes. B elimina a classe inteira de bug de coerencia snapshot/servidor ao preco de um custo de conversao maior e concentrado. Registrado conforme a resposta do usuario; a razao detalhada nao foi elaborada por ele.
- **Implica:**
  - `async` contamina por transitividade as 75 funcoes `render*`/`init*`, o boot (L25918-26077) e os listeners globais — a conversao atinge os 117 sitios, nao apenas os 42 de escrita.
  - Os acessores de leitura de uma linha (`ordem` L16020, `item` L16410, `reservasAtivas` L16415, `ordensUn` L21713, `comp`/`prod`/`ficha` L19324-19326) deixam de ser expressoes sincronas e passam a exigir `await` em todos os seus call sites — inclusive dentro de `.filter`/`.map`/`.find`, onde callback sincrono nao aceita `await` e obriga reescrita do laco.
  - Os getters `Object.defineProperty` de `fis`/`res` (L15746-15755) **nao podem permanecer como getters**: propriedade de acesso nao retorna Promise de forma utilizavel. Precisam virar chamada explicita (o embriao correto ja existe: `saldoUn(cod, t)`, L15757).
  - `audit()` (L15759-15764) vira assincrona e e chamada por todos os modules de dominio — o alcance da conversao passa por praticamente todo o codigo de regra.
  - O `MutationObserver` que reajusta graficos apos cada render e os handlers de `abrirModal`/`confirmarEfeito` passam a lidar com render que ainda nao terminou; ordering de render vira preocupacao real (render concorrente/obsoleto).
  - Aumenta muito a necessidade da rede de protecao decidida em D1: a conversao dos 117 sitios sem teste de regressao e o maior risco isolado deste plano. Sequenciamento sugerido (a confirmar): infra de execucao em Node **antes** da conversao.
  - Elimina a decisao futura sobre politica de recarga/invalidacao de snapshot, que a opcao C exigiria.
- **Timestamp:** 09:04

---

## D3 - Semantica de escrita: remocao vs compensacao

- **Pergunta:** A porta de escrita adota qual semantica de desfazer — remocao fisica do que foi escrito (como hoje) ou compensacao por escrita nova que anula a anterior? Fatos verificados por leitura direta de `prototype/index.html` L17030-17058 nesta sessao: `it.fis += x.q; it.res += x.q;` sem clamp e sem arredondamento (L17037) enquanto o saldo do lote **e** arredondado cinco linhas abaixo (L17041); `DB.auditoria.splice(0, DB.auditoria.length - u.au0)` apaga trilha (L17047); `DB.movimentos.splice(0, u.rev.movimentos)` remove do inicio (L17044); todo o bloco roda dentro do callback de `abrirModal` (L17035); e o texto exibido ao usuario promete remocao — "remove N identificacao(oes) emitida(s)" (L17032).
- **Opcoes consideradas:**
  - A) Manter remocao e emular no adapter remoto — preserva UI e comportamento atual, mas exige emular DELETE onde o banco o proibe por design; o seam nasceria mentindo sobre o que o backend permite.
  - B) Compensacao total — nada e removido; toda correcao e uma escrita nova (movimento inverso, devolucao, evento e auditoria de correcao), e o estado corrente passa a ser funcao da soma dos registros.
  - C) Hibrido — compensacao apenas onde o banco blinda (`auditoria`), remocao no restante.
- **Decisao:** Opcao B — compensacao total. Nenhuma colecao de dominio sofre remocao fisica atraves da porta de escrita; desfazer e sempre append do inverso.
- **Razao:** Usuario aceitou a recomendacao do entrevistador. Sustentacao: (1) `auditoria` no Supabase tem `REVOKE UPDATE/DELETE` inclusive para `service_role`, entao L17047 nao e dificil de portar — e impossivel, e a incompatibilidade apareceria em runtime no adapter em vez de no desenho; (2) com compensacao, devolver saldo passa a ser a mesma operacao de escrita que consumir saldo com sinal trocado, atravessando o mesmo guardiao de clamp/arredondamento — a divergencia de L17037 deixa de ser possivel **por construcao**, nao por disciplina; (3) o comportamento da correcao passa a ser identico em memoria e contra o banco, que e o teste de que o seam esta no lugar certo; (4) a regra ja existe no produto (`ESTORNO_APONTAMENTO` e descrito no proprio codigo como trilha append-only e `registrarEstorno` ja e chamado em L17050) — hoje ela apenas convive com um `splice` que a contradiz. A opcao C foi rejeitada por manter duas semanticas de desfazer no mesmo seam, recriando o conhecimento espalhado que C1 ataca.
- **Implica:**
  - Toda leitura passa a filtrar registros anulados; isso e trabalho novo em varios `render*` (fila de series, movimentos, rastreio, consumos).
  - **A UI muda e o design lock pode ser tocado:** o texto do modal (L17032) promete remocao, mas com compensacao a identificacao continua existindo marcada como anulada. O texto e possivelmente a apresentacao precisam ser revistos.
  - A reversao deixa de ser aritmetica de indice: `rev:{rastreio, consumos, movimentos}` como contagens (L21592-21593) e os contadores `ev0`/`se0`/`au0`/`r0`/`c0`/`m0` perdem a funcao e devem ser substituidos por referencia explicita ao que foi escrito.
  - Remove a dependencia oculta da direcao de insercao: hoje `splice(0, n)` (L17044) so funciona porque `baixaAutomatica` usa `unshift` (L21563) enquanto `DB.consumos` usa `push` (L21562) — convencoes opostas no mesmo bloco.
  - A escrita critica sai do callback do modal: `corrigirApontamento` passa a ser invocavel sem abrir modal, o que e pre-condicao para testa-la.
  - Fica pendente para a SPEC (fase 5, fora do escopo desta fase): como o registro anulado e marcado e como o agrupamento de escritas de um apontamento (consumo + lote + movimento + serie + evento + auditoria) e representado.
  - Converge com o candidato C3 do documento de candidatos, que trata a mesma cadeia — a decisao aqui torna o seam compativel com ele em vez de conflitante.
- **Timestamp:** 09:11

---

## D4 - Sequenciamento da execucao

- **Pergunta:** Dada a conversao total para `async` (D2) e a compensacao total (D3), em que ordem o trabalho e executado — conversao primeiro ou rede de protecao primeiro? E qual e a primeira fatia a ser convertida? Fato verificado por Grep nesta sessao: 272 pontos de entrada (`addEventListener` + handlers inline) em `prototype/index.html`.
- **Opcoes consideradas:**
  - A) Converter os 117 sitios primeiro, testes depois — entrega visivel mais cedo, mas qualquer regressao introduzida na conversao fica indetectavel; foi exatamente a ausencia de rede que permitiu a corrupcao de saldo de L17037 passar despercebida.
  - B) Infra de execucao em Node + testes de caracterizacao primeiro, depois conversao top-down em fatias verticais, comecando pela cadeia de saldo/apontamento.
  - C) Igual a B, porem com a primeira fatia num module periferico (ex.: relatorios) como piloto de risco baixo antes de tocar a cadeia critica.
- **Decisao:** Opcao B. Ordem de execucao acordada: (1) `package.json` + runner (`node --test`, sem dependencias, coerente com o estilo de `tools/contraste.mjs`); (2) extrair para `.mjs` as regras ja quase puras — `matDaOperacao` (L21527), `qPerda`, `explodir`, `custoAberto` (L19472-19529) — e trava-las com testes de caracterizacao que registram o comportamento **atual**, nao o desejado; (3) extrair a porta e o guardiao unico de saldo, com teste que fixa a invariante "arredondado a 2 casas, nao negativo", fazendo L17037 falhar de proposito; (4) so entao converter, uma fatia vertical por vez (handler -> render -> regra -> porta), comecando pela cadeia de saldo/apontamento.
- **Razao:** Usuario aceitou a recomendacao do entrevistador. Sustentacao: a cadeia de apontamento e onde ha corrupcao **acontecendo hoje** (residuo de ponto flutuante somado ao estoque a cada estorno, via L17037), e onde D3 tem o maior efeito, e e a que o Diagnosis identifica como o maior risco de corrupcao de dado do sistema. Executar a fatia mais perigosa primeiro, com a rede ja montada, e preferivel a deixa-la para o fim quando o orcamento estiver esgotado. A opcao C foi considerada (corresponde ao argumento "C4 como piloto" da fase 2) e preterida por custar uma fatia adicional sem reduzir o risco da cadeia critica.
- **Implica:**
  - Resolve a pendencia deixada em aberto em D2 ("sequenciamento a confirmar"): a infra de execucao vem **antes** da conversao.
  - Observacao que reduz o risco de D2, verificada nesta sessao: `async` **nao contamina indefinidamente** — ele para no handler de evento, porque o navegador nao aguarda o retorno de um listener. A cadeia e `porta -> regra -> render -> handler` e termina ali. Isso torna a conversao fatiavel verticalmente, em vez do big bang que a leitura inicial de D2 sugeria.
  - O repositorio ganha `package.json` e um diretorio de testes — hoje inexistentes. Isso muda a forma do projeto e deve constar na SPEC.
  - Testes de caracterizacao congelam comportamento atual **incluindo defeitos conhecidos**; a excecao deliberada e a invariante de saldo, cujo teste deve reprovar o codigo atual (L17037) em vez de canonizar o bug.
  - A fatia inicial (saldo/apontamento) cobre `reservarMaterial` (L16495), `liberarReserva` (L16472), `baixaAutomatica` (L21550-21594) e `corrigirApontamento` (L17021-17058) — que sao tambem os sitios onde a fusao dominio/UI esta comprovada.
  - Nao ha CI no repositorio (`.github/` ausente); se os testes devem rodar automaticamente ou apenas sob demanda ficou **em aberto** e nao foi decidido nesta entrevista.
- **Timestamp:** 09:18

---

