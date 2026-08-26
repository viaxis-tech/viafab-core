// prototype/core/qPerda.mjs
//
// Extraído de prototype/index.html — definição original:
//   const qPerda = l => l.qtd * (1 + (l.perda || 0) / 100);
//
// Regra pura: não lê nenhum estado global do protótipo (DB, PARAM, catálogo).
// Aplica o percentual de perda de uma linha de ficha sobre a quantidade base.
//
// Comportamento congelado por caracterização (ver qPerda.test.mjs), incluindo
// os seguintes pontos que NÃO são corrigidos por este WP:
//   - `l.perda` negativo reduz a quantidade abaixo de `l.qtd` (sem clamp em 0).
//   - `l.qtd` negativo é aceito e propagado sem validação.
export function qPerda(l) {
  return l.qtd * (1 + (l.perda || 0) / 100);
}
