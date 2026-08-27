import { test } from 'node:test';
import assert from 'node:assert/strict';
import { proximoGrupoEscrita } from './grupoEscrita.mjs';

test('proximoGrupoEscrita: formata o id a partir da sequência recebida', () => {
  assert.equal(proximoGrupoEscrita(1), 'GE-1');
  assert.equal(proximoGrupoEscrita(42), 'GE-42');
});

test('proximoGrupoEscrita: não muta nem depende de estado interno — mesma sequência produz o mesmo id', () => {
  assert.equal(proximoGrupoEscrita(7), proximoGrupoEscrita(7));
});
