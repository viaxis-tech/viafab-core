// prototype/core/custoAberto.mjs
//
// Extraído de prototype/index.html — definição original:
//   function custoAberto(tipo, cod){
//     const mat = custoMat(tipo, cod), pro = custoProc(tipo, cod), mo = custoMO(tipo, cod);
//     return {mat, pro, mo, total:mat + pro + mo};
//   }
//
// Dependências externas (não extraídas por este WP — ver relatório da sprint,
// pendência Q5 do plano sobre a fórmula autoritativa do custo aberto):
//   - `custoMat(tipo, cod, prof)`: custo de material, recursivo pela BOM.
//   - `custoProc(tipo, cod, prof)`: custo de hora-máquina, recursivo pela BOM.
//   - `custoMO(tipo, cod, prof)`: custo de mão de obra, recursivo pela BOM.
// As três dependem de `item`/`ficha`/`horaSetor`/`horaMaquina` e dos catálogos
// globais (ITENS/COMPONENTES/PRODUTOS/CARGOS/MAQUINAS); injetadas via
// `createCustoAberto({ custoMat, custoProc, custoMO })`.
//
// Comportamento congelado por caracterização (ver custoAberto.test.mjs):
//   - `custoAberto` chama as três dependências com a assinatura (tipo, cod),
//     sem repassar `prof` — cada uma reinicia sua própria recursão do zero.
export function createCustoAberto({ custoMat, custoProc, custoMO }) {
  function custoAberto(tipo, cod) {
    const mat = custoMat(tipo, cod), pro = custoProc(tipo, cod), mo = custoMO(tipo, cod);
    return { mat, pro, mo, total: mat + pro + mo };
  }
  return custoAberto;
}
