// Testes de caracterização — congelam o comportamento atual de matDaOperacao(),
// defeitos incluídos. Não é permitido "corrigir" nada aqui (WP-1.1).
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { createMatDaOperacao } from './matDaOperacao.mjs';

const FICHAS = {
  'PRD-PLACA': {
    cod: 'PRD-PLACA',
    ficha: [
      { tipo: 'material', cod: 'MAT-TINTA', qtd: 1, perda: 0, setor: 'Pintura', dep: 'DEP-03' },
      { tipo: 'material', cod: 'MAT-CHAPA', qtd: 2, perda: 0, setor: 'Corte', dep: 'DEP-01' },
      { tipo: 'componente', cod: 'CMP-BASE', qtd: 1, perda: 0 }
    ]
  }
};
const COMPONENTES = {
  'CMP-BASE': {
    cod: 'CMP-BASE',
    setor: 'Corte',
    ficha: [{ tipo: 'material', cod: 'MAT-PARAF', qtd: 4, perda: 0, dep: 'DEP-02' }]
  }
};
const ficha = cod => FICHAS[cod];
const comp = cod => COMPONENTES[cod];

function novoMatDaOperacao() {
  return createMatDaOperacao({ ficha, comp });
}

test('matDaOperacao: retorna apenas materiais da linha cujo setor bate com o pedido', () => {
  const matDaOperacao = novoMatDaOperacao();
  const o = { itens: [{ cod: 'PRD-PLACA', qtd: 5 }] };
  const saida = matDaOperacao(o, 'Pintura');
  assert.equal(saida.length, 1);
  assert.equal(saida[0].cod, 'MAT-TINTA');
  assert.equal(saida[0].qtd, 5);
});

test('matDaOperacao: agrega material do componente fabricado no mesmo setor', () => {
  const matDaOperacao = novoMatDaOperacao();
  const o = { itens: [{ cod: 'PRD-PLACA', qtd: 2 }] };
  const saida = matDaOperacao(o, 'Corte');
  const cods = saida.map(x => x.cod).sort();
  // MAT-CHAPA (linha direta do setor Corte) + MAT-PARAF (do componente CMP-BASE, setor Corte)
  assert.deepEqual(cods, ['MAT-CHAPA', 'MAT-PARAF']);
  const chapa = saida.find(x => x.cod === 'MAT-CHAPA');
  assert.equal(chapa.qtd, 4); // 2 * 2
  const paraf = saida.find(x => x.cod === 'MAT-PARAF');
  assert.equal(paraf.qtd, 8); // 4 * 1(perda do componente) * 1(perda da linha) * 2
});

test('matDaOperacao: setor sem correspondência retorna lista vazia', () => {
  const matDaOperacao = novoMatDaOperacao();
  const o = { itens: [{ cod: 'PRD-PLACA', qtd: 1 }] };
  assert.deepEqual(matDaOperacao(o, 'Montagem'), []);
});

test('matDaOperacao: agrega por cod+dep quando duas linhas convergem para a mesma chave', () => {
  const ficha2 = cod =>
    cod === 'PRD-X'
      ? {
          cod: 'PRD-X',
          ficha: [
            { tipo: 'material', cod: 'MAT-A', qtd: 1, perda: 0, setor: 'Corte', dep: 'DEP-01' },
            { tipo: 'material', cod: 'MAT-A', qtd: 3, perda: 0, setor: 'Corte', dep: 'DEP-01' }
          ]
        }
      : undefined;
  const matDaOperacao = createMatDaOperacao({ ficha: ficha2, comp });
  const o = { itens: [{ cod: 'PRD-X', qtd: 1 }] };
  const saida = matDaOperacao(o, 'Corte');
  assert.equal(saida.length, 1);
  assert.equal(saida[0].qtd, 4);
});

test('matDaOperacao [defeito congelado]: item de ordem sem ficha correspondente é ignorado em silêncio', () => {
  const matDaOperacao = novoMatDaOperacao();
  const o = { itens: [{ cod: 'PRD-INEXISTENTE', qtd: 10 }] };
  assert.deepEqual(matDaOperacao(o, 'Corte'), []);
});

test('matDaOperacao [defeito congelado]: entradas com qtd resultante <= 0 são descartadas do resultado', () => {
  const ficha3 = () => ({
    cod: 'PRD-NEG',
    ficha: [{ tipo: 'material', cod: 'MAT-A', qtd: -2, perda: 0, setor: 'Corte', dep: 'DEP-01' }]
  });
  const matDaOperacao = createMatDaOperacao({ ficha: ficha3, comp });
  const o = { itens: [{ cod: 'PRD-NEG', qtd: 1 }] };
  assert.deepEqual(matDaOperacao(o, 'Corte'), []);
});
