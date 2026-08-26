// Testes de caracterização — congelam o comportamento atual de custoAberto(),
// defeitos incluídos. Não é permitido "corrigir" nada aqui (WP-1.1).
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { createCustoAberto } from './custoAberto.mjs';

test('custoAberto: soma material, processo e mão de obra em total', () => {
  const custoAberto = createCustoAberto({
    custoMat: () => 10,
    custoProc: () => 4,
    custoMO: () => 6
  });
  const r = custoAberto('produto', 'PRD-1');
  assert.deepEqual(r, { mat: 10, pro: 4, mo: 6, total: 20 });
});

test('custoAberto: repassa (tipo, cod) inalterados para as três dependências, sem prof', () => {
  const chamadas = [];
  const registra = nome => (...args) => { chamadas.push([nome, ...args]); return 1; };
  const custoAberto = createCustoAberto({
    custoMat: registra('mat'),
    custoProc: registra('pro'),
    custoMO: registra('mo')
  });
  custoAberto('componente', 'CMP-9');
  assert.deepEqual(chamadas, [
    ['mat', 'componente', 'CMP-9'],
    ['pro', 'componente', 'CMP-9'],
    ['mo', 'componente', 'CMP-9']
  ]);
});

test('custoAberto [defeito congelado]: valores negativos de qualquer parcela não são clampados e reduzem o total', () => {
  const custoAberto = createCustoAberto({
    custoMat: () => 10,
    custoProc: () => -3,
    custoMO: () => 2
  });
  assert.deepEqual(custoAberto('produto', 'PRD-2'), { mat: 10, pro: -3, mo: 2, total: 9 });
});
