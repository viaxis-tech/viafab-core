// prototype/core/grupoEscrita.mjs
//
// Identidade do grupo de escrita (F-2.1, resolve Q2 — ratificada 27/08/2026
// pelo dono do produto, ver docs/wp-1.4-design-compensacao-20260827.md).
// Toda operação de apontamento que grava em mais de uma coleção
// (finalizarOperacao, corrigirApontamento) carimba um único
// `grupo_escrita_id` em cada registro que escreve, no lugar dos contadores
// de índice (ev0/se0/au0/r0/c0/m0) que a proposta de WP-1.4 elimina. Mesmo
// padrão de sequência-como-parâmetro de prototype/core/estorno.mjs (WP-1.5):
// a sequência é recebida do chamador, nenhum contador é mutado aqui dentro.

/**
 * @param {number} seq Sequência já incrementada pelo chamador.
 * @returns {string} Id do grupo de escrita, formato `GE-<seq>` — mesmo
 *   padrão de `EST-<n>` (registrarEstorno) e `OS-<n>` (idOS).
 */
export function proximoGrupoEscrita(seq) {
  return 'GE-' + seq;
}
