# WP-1.4 — Design da compensação (resolve Q2)

**Data:** 27/08/2026
**Escopo:** proposta de design, sem alteração de código. Critério de aceite do plano (§5, Etapa 1): "Documento curto ratificado pelo dono do produto antes da Etapa 2". Resolve **Q2** — "como o registro anulado é marcado e como o agrupamento de escritas de um apontamento é representado" — deixada em aberto por D3.

**Onde se aplica:** exclusivamente a cadeia de apontamento que hoje falha o requisito de D3 ("nenhuma remoção física através da porta") — `finalizarOperacao` (`prototype/index.html:16999`) e `corrigirApontamento` (`:17038`), a mesma dupla listada em F-2.1 do plano. `DB.reservas` (`liberarReserva`/`reservarMaterial`) já usa uma convenção não-destrutiva própria (campo `liberada_em` na própria linha, nunca `splice`) e **não muda** por esta proposta — não é o que Q2 pergunta.

## 1. O que existe hoje (e por que viola D3)

`finalizarOperacao` grava em seis coleções (`DB.eventos[ordem]`, `DB.auditoria`, `DB.serie`, `DB.rastreio`, `DB.consumos`, `DB.movimentos`) e guarda em `CF.und` só o **comprimento** de cada array antes da escrita (`ev0`, `se0`, `au0` em `:17004`; `r0`, `c0`, `m0` em `:21548`, devolvidos por `baixaAutomatica`). `corrigirApontamento` desfaz por **posição**: `splice()` de todos os registros a partir daquele índice (`:17059-17067`).

Dois problemas, um de correção e um de arquitetura:

- **Correção:** `DB.auditoria`, `DB.serie`, `DB.consumos`, `DB.movimentos`, `DB.rastreio` são coleções **globais**, compartilhadas por todas as ordens e usuários do tenant. Entre `finalizarOperacao` gravar `au0` e o usuário clicar "Corrigir apontamento" (janela de até 10 min), qualquer outra ação no sistema que grave nessas mesmas coleções desloca os índices. `DB.auditoria.splice(0, DB.auditoria.length - u.au0)` remove as N entradas mais recentes de auditoria **do tenant inteiro**, não necessariamily as desta operação — se outra pessoa registrou uma inspeção de qualidade nesse meio-tempo, a correção apaga essa auditoria também. O mesmo vale para `DB.serie`, `DB.consumos`, `DB.movimentos`, `DB.rastreio`.
- **Arquitetura:** `splice`/remoção física não é portável para o adapter Supabase (WP-5.8) — as tabelas equivalentes são append-only por `REVOKE UPDATE/DELETE` (convenção já em vigor nas 9 migrations existentes). Um design que só funciona porque o adapter de memória permite mutação direta do array não sobrevive à troca de adapter, que é o propósito declarado da porta (D2/D4).

## 2. Proposta

### 2.1 `grupo_escrita_id`

Toda operação de apontamento que grava em mais de uma coleção (hoje: `finalizarOperacao`) gera **um id de grupo antes de escrever**, e carimba esse mesmo id em cada registro que grava naquela chamada — nas seis coleções listadas acima. Formato: mesmo padrão já usado no repositório para identidade sequencial (`EST-<n>` em `registrarEstorno`, `OS-<n>` em `idOS`) — proposto `GE-<n>`, gerado pelo padrão "sequência como parâmetro" que o WP-1.5 (companheiro deste WP) acabou de formalizar em `prototype/core/estorno.mjs` (`criarLinhaEstorno`), não um contador solto novo.

Isso substitui `ev0/se0/au0/r0/c0/m0`: para saber o que uma operação escreveu, filtra-se `registro.grupo_escrita_id === id`, não se compara mais o tamanho do array antes/depois. `CF.und` passa a guardar o `grupo_escrita_id` da operação, não os seis contadores.

**Compatibilidade com sync offline:** o CLAUDE.md já documenta `client_generated_id` como convenção para `apontamentos`/`consumos`/`movimentos_estoque` alimentados pelo chão de fábrica. Quando o apontamento nasce offline, `grupo_escrita_id` e `client_generated_id` podem ser o mesmo valor — a fusão exata dos dois campos (mesmo campo vs. dois campos correlacionados) é decisão de schema da Etapa 5 (WP-5.3), não deste documento; aqui só se registra que o design não colide com essa convenção.

### 2.2 Anulação — comportamento por tipo de coleção, nunca remoção física

`corrigirApontamento` deixa de fazer `splice`. Em vez disso, abre um **novo** `grupo_escrita_id` (o "grupo de correção") e grava conforme o tipo de coleção:

| Coleção | Hoje (bug) | Proposta |
|---|---|---|
| `DB.consumos`, `DB.movimentos`, `DB.rastreio` (ledgers de quantidade) | `splice` das N últimas entradas globais | Acrescenta um registro por item afetado com a quantidade invertida (mesma forma de hoje, sinal trocado), `anula_id: <grupo_escrita_id original>` |
| `DB.serie` (identificação unitária — não existe "unidade negativa" com sentido de domínio) | `splice` remove as identificações emitidas | Registro original ganha `anulado_por: <grupo_escrita_id da correção>`; nenhum registro novo. Telas que listam identificações "vivas" (expedição, rastreabilidade) passam a filtrar `!anulado_por` por padrão |
| `DB.eventos[ordem]`, `DB.auditoria` (trilha, já append-only por natureza) | `splice` apaga histórico anterior — a correção real do bug | **Para de fazer `splice`.** Continua só acrescentando o evento/auditoria "Apontamento corrigido" que o código já grava hoje (`:17071-17073`) — trilha nunca é filtrada, esse é o ponto de uma auditoria |
| Saldo (`fis`/`res`) | Já correto (WP-1.3) | Sem mudança — é estado corrente, não log; o guardião aplica o delta inverso sobre o valor vigente |

### 2.3 Leituras filtram anulados por padrão

Telas operacionais que agregam as coleções-ledger para decisão de negócio (rastreabilidade do pedido — `databookDoPedido`, expedição, relatórios de custo/consumo) passam a excluir por padrão registros cujo `grupo_escrita_id` aparece como `anula_id` de outro grupo, e registros de série com `anulado_por` setado. Telas de trilha (`DB.auditoria`, eventos da ordem) **nunca filtram** — mostrar a correção ao lado do original é o propósito da auditoria.

### 2.4 Reversão referencia o que foi escrito, nunca índice

`u.rev.itens` (lista `{cod, q}` usada para reverter saldo, hoje já baseada em conteúdo, não posição) **não muda**. O que muda é só a parte de índice: `CF.und.grupo_escrita_id` substitui `ev0/se0/au0/r0/c0/m0`.

## 3. O que este documento não decide (fica para F-2.1)

- Formato exato de coluna/campo no schema Supabase (Etapa 5, WP-5.3) — aqui só se fixa o comportamento observável.
- Texto do modal de "Corrigir apontamento" (`:17048-17051`) hoje descreve remoção física ("remove N identificação(ões)"); a nova semântica é "anula". Trocar esse texto toca conteúdo do design lock — **F-2.1 escala com proposta de revisão formal do lock** (diff + novo hash), conforme o próprio plano já prevê para essa fatia (§5, coluna "Ponto crítico" de F-2.1). Não editado agora.
- Requer que `DB.consumos`, `DB.movimentos`, `DB.rastreio`, `DB.eventos[*]`, `DB.auditoria` ganhem um campo de identidade estável (`id`) — nenhuma dessas coleções tem hoje (só `ts`, verificado por leitura direta de todos os `push`/`unshift`); só `DB.serie` já tem `id` (`proxSerie`, usado em `emitirSeries`). Adicionar esse campo é implementação de F-2.1, não deste WP — registrado aqui para não ser redescoberto na fatia.

## 4. Pedido de ratificação

Isto resolve Q2 conforme a recomendação já registrada no plano (§5, Etapa 1, WP-1.4) e no board (`docs/registro-execucao.md`, fila de decisões). Falta a ratificação explícita do dono do produto antes de abrir F-2.1 (Etapa 2), conforme o gate documentado no plano §7.
