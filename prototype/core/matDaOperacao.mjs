// prototype/core/matDaOperacao.mjs
//
// Extraído de prototype/index.html — definição original:
//   function matDaOperacao(o, setor){
//     const acc = {};
//     const add = (cod, dep, q) => {
//       const k = cod + '|' + dep;
//       acc[k] = acc[k] || {cod:cod, dep:dep, qtd:0};
//       acc[k].qtd += q;
//     };
//     (o.itens || []).forEach(oi => {
//       const f = ficha(oi.cod); if(!f) return;
//       f.ficha.forEach(l => {
//         if(l.tipo === 'material' && l.setor === setor) add(l.cod, l.dep, qPerda(l) * oi.qtd);
//       });
//       f.ficha.filter(l => l.tipo === 'componente').forEach(l => {
//         const c = comp(l.cod); if(!c || c.setor !== setor) return;
//         c.ficha.forEach(cl => {
//           if(cl.tipo === 'material') add(cl.cod, cl.dep, qPerda(cl) * qPerda(l) * oi.qtd);
//         });
//       });
//     });
//     return Object.keys(acc).map(k => acc[k]).filter(x => x.qtd > 0);
//   }
//
// Dependências externas (não extraídas por este WP — ver relatório da sprint):
//   - `ficha(cod)`: lookup de componente/produto (COMPONENTES/PRODUTOS).
//   - `comp(cod)`: lookup específico de componente (COMPONENTES).
// Ambas dependem do catálogo carregado de seeds.json; injetadas via
// `createMatDaOperacao({ ficha, comp })`.
//
// Comportamento congelado por caracterização (ver matDaOperacao.test.mjs),
// defeitos incluídos:
//   - Entradas com `qtd <= 0` são descartadas do resultado (`filter(x => x.qtd > 0)`),
//     mesmo que representem uma reversão legítima de consumo negativo.
//   - Linha de material com `l.setor` divergente do setor do próprio componente
//     que a contém não é filtrada pelo setor do componente, apenas pelo setor
//     da própria linha de material.
import { qPerda } from './qPerda.mjs';

export function createMatDaOperacao({ ficha, comp }) {
  function matDaOperacao(o, setor) {
    const acc = {};
    const add = (cod, dep, q) => {
      const k = cod + '|' + dep;
      acc[k] = acc[k] || { cod: cod, dep: dep, qtd: 0 };
      acc[k].qtd += q;
    };
    (o.itens || []).forEach(oi => {
      const f = ficha(oi.cod);
      if (!f) return;
      f.ficha.forEach(l => {
        if (l.tipo === 'material' && l.setor === setor) add(l.cod, l.dep, qPerda(l) * oi.qtd);
      });
      f.ficha.filter(l => l.tipo === 'componente').forEach(l => {
        const c = comp(l.cod);
        if (!c || c.setor !== setor) return;
        c.ficha.forEach(cl => {
          if (cl.tipo === 'material') add(cl.cod, cl.dep, qPerda(cl) * qPerda(l) * oi.qtd);
        });
      });
    });
    return Object.keys(acc).map(k => acc[k]).filter(x => x.qtd > 0);
  }
  return matDaOperacao;
}
