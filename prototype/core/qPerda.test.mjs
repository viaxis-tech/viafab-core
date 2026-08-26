// Testes de caracterização — congelam o comportamento atual de qPerda(),
// defeitos incluídos. Não é permitido "corrigir" nada aqui (WP-1.1).
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { qPerda } from './qPerda.mjs';

test('qPerda: sem perda (campo ausente) retorna a própria quantidade', () => {
  assert.equal(qPerda({ qtd: 10 }), 10);
});

test('qPerda: perda 0 explícita retorna a própria quantidade', () => {
  assert.equal(qPerda({ qtd: 25, perda: 0 }), 25);
});

test('qPerda: aplica o percentual de perda multiplicativamente', () => {
  assert.equal(qPerda({ qtd: 10, perda: 12 }), 11.200000000000001);
});

test('qPerda: aceita quantidade fracionária', () => {
  assert.equal(qPerda({ qtd: 2.5, perda: 10 }), 2.75);
});

test('qPerda [defeito congelado]: perda negativa reduz a quantidade abaixo do valor base, sem clamp', () => {
  assert.equal(qPerda({ qtd: 10, perda: -50 }), 5);
});

test('qPerda [defeito congelado]: quantidade negativa é propagada sem validação', () => {
  assert.equal(qPerda({ qtd: -4, perda: 25 }), -5);
});
