// prototype/core/explodir.mjs
//
// Extraído de prototype/index.html — definição original:
//   function explodir(tipo, cod, qtd, saida, prof){
//     saida = saida || {}; prof = prof || 0;
//     if(prof > 6) return saida;
//     if(tipo === 'material'){
//       const k = cod;
//       saida[k] = saida[k] || {cod:cod, un:(item(cod)||{}).un || 'un', qtd:0, dep:(item(cod)||{}).dep};
//       saida[k].qtd += qtd;
//       return saida;
//     }
//     const f = ficha(cod); if(!f) return saida;
//     f.ficha.forEach(l => explodir(l.tipo, l.cod, qPerda(l) * qtd, saida, prof + 1));
//     return saida;
//   }
//
// Dependências externas (não extraídas por este WP — ver relatório da sprint):
//   - `item(cod)`: lookup no catálogo de materiais (ITENS), definido em prototype/index.html.
//   - `ficha(cod)`: lookup de componente/produto (COMPONENTES/PRODUTOS), idem.
// Ambas são funções de catálogo que dependem de estado global do protótipo
// (arrays carregados de seeds.json) e não são "quase-puras" — por isso são
// injetadas via `createExplodir({ item, ficha })` em vez de importadas.
//
// Comportamento congelado por caracterização (ver explodir.test.mjs), defeitos
// incluídos:
//   - Recursão limitada a `prof > 6`: não há detecção de ciclo na árvore de
//     ficha técnica, apenas um teto de profundidade que interrompe em silêncio.
//   - `ficha(cod)` ausente (linha órfã) é ignorada sem erro nem log.
import { qPerda } from './qPerda.mjs';

export function createExplodir({ item, ficha }) {
  function explodir(tipo, cod, qtd, saida, prof) {
    saida = saida || {};
    prof = prof || 0;
    if (prof > 6) return saida;
    if (tipo === 'material') {
      const k = cod;
      saida[k] = saida[k] || { cod: cod, un: (item(cod) || {}).un || 'un', qtd: 0, dep: (item(cod) || {}).dep };
      saida[k].qtd += qtd;
      return saida;
    }
    const f = ficha(cod);
    if (!f) return saida;
    f.ficha.forEach(l => explodir(l.tipo, l.cod, qPerda(l) * qtd, saida, prof + 1));
    return saida;
  }
  return explodir;
}
