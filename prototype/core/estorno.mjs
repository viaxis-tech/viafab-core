// prototype/core/estorno.mjs
//
// Relógio injetável + identidade como parâmetro para a janela de correção de
// apontamento (WP-1.5, D4 passo 3 do plano de 25/08). Cobre os dois pontos
// hoje resolvidos com `Date.now()` direto e um contador mutado in-place em
// `prototype/index.html`: `registrarEstorno` (:16139) e a checagem de janela
// hoje inline em `corrigirApontamento` (:17041-17045,
// `Date.now() > linha.janela_expira_em`).
//
// Divergência observada (mesmo tipo de nota já registrada no WP-1.3 para a
// contagem de sítios): o texto do plano (§5, Etapa 1, WP-1.5) cita
// "seqCfg/seqSnap/seqOrd deixam de ser acessados diretamente" como o alvo do
// gerador de identidade. Esses três campos existem em `DB`
// (prototype/index.html:15710) mas são mortos — grep no arquivo inteiro não
// encontra nenhuma leitura ou escrita além da própria seed. A geração real de
// id (`novoId`, :21776, usada por OP/CFG/SNP/PED) já deriva o próximo valor
// de uma lista recebida por parâmetro, sem contador mutado; `idOS` (:25391)
// segue o mesmo formato. Nenhum dos dois precisa de conversão. O único
// gerador de identidade que hoje muta um contador diretamente é `EST_SEQ`
// (:16127, `id:'EST-' + (++EST_SEQ)` dentro de `registrarEstorno`) — é esse o
// alvo real deste WP.
//
// `criarLinhaEstorno` recebe `seq` e `agora` como parâmetros em vez de mutar
// `EST_SEQ`/chamar `Date.now()` internamente. O call site em index.html
// continua responsável por incrementar `EST_SEQ` e por ler o relógio real —
// só a regra pura (formatar o id, calcular `janela_expira_em`) sai para cá,
// testável com sequência e relógio controlados.

/**
 * @param {Object} args
 * @param {number} args.seq Sequência já incrementada pelo chamador (substitui `++EST_SEQ` interno).
 * @param {string} args.operacaoOrdemId Chave `opKey(ordemId, op)`.
 * @param {'baixa'|'correcao'|'desbloqueio'} args.tipo
 * @param {Array<{cod:string, qtd:number}>} [args.delta]
 * @param {string} args.autor
 * @param {number} args.agora Instante da criação, em ms epoch (`Date.now()` no chamador; controlado nos testes).
 * @param {number} args.janelaMs Duração da janela de correção em ms.
 * @returns {{id:string, operacao_ordem_id:string, tipo:string, delta:Array, criado_em:number, janela_expira_em:number, autor:string}}
 */
export function criarLinhaEstorno({ seq, operacaoOrdemId, tipo, delta, autor, agora, janelaMs }) {
  return {
    id: 'EST-' + seq,
    operacao_ordem_id: operacaoOrdemId,
    tipo,
    delta: delta || [],
    criado_em: agora,
    janela_expira_em: agora + janelaMs,
    autor
  };
}

/**
 * Janela de correção ainda aberta para a linha informada, no instante `agora`
 * (relógio injetado — nunca `Date.now()` interno). Mesma regra hoje inline em
 * `corrigirApontamento` (:17042): expira estritamente depois de
 * `janela_expira_em`; o próprio limite ainda conta como aberto. Equivalente
 * por De Morgan a `!linha || Date.now() > linha.janela_expira_em` (a
 * condição de "expirou" do código original) — chamar como
 * `!dentroDaJanela(linha, agora)` no lugar dela é uma substituição direta.
 *
 * @param {{janela_expira_em:number}|null|undefined} linha
 * @param {number} agora
 * @returns {boolean}
 */
export function dentroDaJanela(linha, agora) {
  return !!linha && agora <= linha.janela_expira_em;
}
