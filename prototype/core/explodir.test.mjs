// Testes de caracterização — congelam o comportamento atual de explodir(),
// defeitos incluídos. Não é permitido "corrigir" nada aqui (WP-1.1).
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { createExplodir } from './explodir.mjs';

// Catálogo mínimo de teste, no mesmo formato do protótipo:
// item(cod) -> {cod, un, dep}; ficha(cod) -> {cod, ficha:[{tipo,cod,qtd,perda}]}
const ITENS = {
  'MAT-CHAPA': { cod: 'MAT-CHAPA', un: 'm2', dep: 'DEP-01' },
  'MAT-PARAF': { cod: 'MAT-PARAF', un: 'un', dep: 'DEP-02' }
};
const FICHAS = {
  'CMP-BASE': {
    cod: 'CMP-BASE',
    ficha: [{ tipo: 'material', cod: 'MAT-CHAPA', qtd: 2, perda: 10 }]
  },
  'PRD-PLACA': {
    cod: 'PRD-PLACA',
    ficha: [
      { tipo: 'componente', cod: 'CMP-BASE', qtd: 1, perda: 0 },
      { tipo: 'material', cod: 'MAT-PARAF', qtd: 4, perda: 0 }
    ]
  },
  // ficha que se autorreferencia — usada para caracterizar a ausência de
  // detecção de ciclo (o teto de profundidade prof > 6 é o único freio).
  'PRD-CICLICO': {
    cod: 'PRD-CICLICO',
    ficha: [{ tipo: 'componente', cod: 'PRD-CICLICO', qtd: 1, perda: 0 }]
  }
};
const item = cod => ITENS[cod];
const ficha = cod => FICHAS[cod];

function novoExplodir() {
  return createExplodir({ item, ficha });
}

test('explodir: material direto acumula a quantidade pedida', () => {
  const explodir = novoExplodir();
  const saida = explodir('material', 'MAT-PARAF', 5);
  assert.deepEqual(saida, { 'MAT-PARAF': { cod: 'MAT-PARAF', un: 'un', qtd: 5, dep: 'DEP-02' } });
});

test('explodir: componente recursa até material aplicando perda composta', () => {
  const explodir = novoExplodir();
  const saida = explodir('produto', 'PRD-PLACA', 3);
  // MAT-CHAPA: 2 * 1.10 (perda do componente) * 1 (perda do produto=0) * 3 = 6.6
  assert.equal(Math.round(saida['MAT-CHAPA'].qtd * 100) / 100, 6.6);
  // MAT-PARAF: 4 * 3 = 12
  assert.equal(saida['MAT-PARAF'].qtd, 12);
});

test('explodir: acumula quantidades quando o mesmo material aparece em mais de um ramo', () => {
  const explodir = novoExplodir();
  const saida = {};
  explodir('material', 'MAT-PARAF', 3, saida);
  explodir('material', 'MAT-PARAF', 2, saida);
  assert.equal(saida['MAT-PARAF'].qtd, 5);
});

test('explodir [defeito congelado]: ficha ausente é ignorada em silêncio, sem erro', () => {
  const explodir = novoExplodir();
  const saida = explodir('componente', 'CMP-INEXISTENTE', 10);
  assert.deepEqual(saida, {});
});

test('explodir [defeito congelado]: ciclo na árvore de ficha não é detectado — apenas o teto de profundidade (prof > 6) interrompe a recursão em silêncio', () => {
  const explodir = novoExplodir();
  const saida = explodir('produto', 'PRD-CICLICO', 1);
  // Nenhum material é atingido (a ficha só referencia a si mesma); a recursão
  // termina silenciosamente ao ultrapassar prof=6, sem lançar erro nem sinalizar o ciclo.
  assert.deepEqual(saida, {});
});
