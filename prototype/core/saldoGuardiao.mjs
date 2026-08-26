// prototype/core/saldoGuardiao.mjs
//
// Guardião único de saldo (WP-1.3, D4 passo 3 do plano de 25/08). Toda
// mutação de fis/res de um item no legado passa a compor sobre esta função
// em vez de calcular round/clamp na mão em cada sítio.
//
// Invariante única (texto do WP-1.3): o saldo de um item (fis ou res) é
// sempre arredondado a 2 casas decimais e nunca negativo, salvo quando
// `estoqueNegativo` for truthy — caso em que negativo é permitido.
//
// Decisão de assinatura (detalhe de implementação, deixado a critério de
// quem executa o WP): função pura POR CAMPO — recebe o valor atual de UM
// campo (fis OU res) e um delta, devolve o novo valor já arredondado e
// clampado. Não uma função que recebe o item inteiro {fis, res} de uma vez.
// Motivo: nenhum dos sítios de mutação do legado (ver lista abaixo) calcula
// fis e res numa única expressão — são sempre duas atribuições separadas,
// mesmo quando o mesmo delta é aplicado aos dois campos (ex. estorno de
// apontamento). Uma função por campo mapeia 1:1 com essa estrutura já
// existente, sem precisar inventar um formato de "delta combinado" que
// nenhum call site pede.
//
// Decisão sobre `estoqueNegativo` em `res` (ambiguidade de baixo risco,
// declarada — AGENTS.md §"Ambiguidade de baixo risco"): o texto do plano
// descreve a invariante para "fis, res" em conjunto, mas o comportamento
// JÁ EXISTENTE no legado, em todo sítio que fazia clamp corretamente antes
// deste WP (prototype/index.html, sítios de `res` em `:16477`, `:16953`,
// `:21541`), sempre clampava `res` em 0 incondicionalmente — nenhum desses
// sítios jamais testou `PARAM.estoqueNegativo` para `res`. Preservar esse
// comportamento observável (guardrail 4.4 de docs/conducao-agente-20260825.md:
// só a invariante de `:17044` é uma mudança de comportamento sancionada)
// exige que a opção `estoqueNegativo` seja decidida por quem CHAMA o
// guardião, chamada a chamada — não embutida como regra fixa dentro da
// função. Na conversão de cada sítio (prototype/index.html), todo call site
// que mexe em `res` passa `estoqueNegativo: false` explicitamente; só os
// sítios que mexem em `fis` passam `estoqueNegativo: PARAM.estoqueNegativo`,
// replicando a regra já implementada em `:21540` antes deste WP (o único
// sítio pré-existente que já respeitava o parâmetro).

/**
 * Aplica um delta a um único campo de saldo (fis OU res de um item),
 * respeitando a invariante do domínio: arredondamento a 2 casas decimais e
 * não-negatividade, salvo `estoqueNegativo`.
 *
 * @param {number} valorAtual Valor atual do campo antes do ajuste.
 * @param {number} delta Quantidade a somar (pode ser negativa, para subtrair).
 * @param {{estoqueNegativo?: boolean}} [opcoes] `estoqueNegativo: true` permite
 *   o resultado ficar negativo; por padrão (`false`), o resultado é clampado em 0.
 * @returns {number} Novo valor do campo, arredondado a 2 casas decimais e
 *   clampado em 0 salvo `estoqueNegativo`.
 */
export function aplicarSaldo(valorAtual, delta, { estoqueNegativo = false } = {}) {
  const bruto = (valorAtual || 0) + (delta || 0);
  const arredondado = Math.round(bruto * 100) / 100;
  return estoqueNegativo ? arredondado : Math.max(0, arredondado);
}
