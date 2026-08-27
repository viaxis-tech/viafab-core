// Testes do relógio injetável + identidade como parâmetro da janela de
// correção de apontamento (WP-1.5). Critério de aceite do plano: "teste de
// limite da janela de estorno passa com relógio controlado" — a seção 2
// cobre exatamente o limite (agora === janela_expira_em e agora ===
// janela_expira_em + 1), sem esperar os 10 minutos reais.
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { criarLinhaEstorno, dentroDaJanela } from './estorno.mjs';

const JANELA_ESTORNO_REAL = 10 * 60 * 1000; // mesmo valor de prototype/index.html:16998

/* ============================================================
   1. criarLinhaEstorno — identidade e relógio como parâmetro
   ============================================================ */

test('criarLinhaEstorno: formata o id a partir da sequência recebida, não de um contador interno', () => {
  const linha = criarLinhaEstorno({
    seq: 7, operacaoOrdemId: 'OP-2431 / Corte da chapa', tipo: 'baixa',
    delta: [{ cod: 'MAT-011', qtd: 8.1 }], autor: 'E. Sartori',
    agora: 1000, janelaMs: JANELA_ESTORNO_REAL
  });
  assert.equal(linha.id, 'EST-7');
});

test('criarLinhaEstorno: janela_expira_em é derivada do relógio injetado, nunca de Date.now()', () => {
  const linha = criarLinhaEstorno({
    seq: 1, operacaoOrdemId: 'OP-2431 / Corte da chapa', tipo: 'baixa',
    autor: 'E. Sartori', agora: 1000, janelaMs: JANELA_ESTORNO_REAL
  });
  assert.equal(linha.criado_em, 1000);
  assert.equal(linha.janela_expira_em, 1000 + JANELA_ESTORNO_REAL);
});

test('criarLinhaEstorno: preserva tipo, delta e autor sem transformação', () => {
  const delta = [{ cod: 'MAT-011', qtd: 8.1 }];
  const linha = criarLinhaEstorno({
    seq: 2, operacaoOrdemId: 'OP-2431 / Corte da chapa', tipo: 'correcao',
    delta, autor: 'E. Sartori', agora: 1000, janelaMs: JANELA_ESTORNO_REAL
  });
  assert.equal(linha.tipo, 'correcao');
  assert.deepEqual(linha.delta, delta);
  assert.equal(linha.autor, 'E. Sartori');
});

test('criarLinhaEstorno: delta ausente vira array vazio, mesmo padrão de registrarEstorno hoje', () => {
  const linha = criarLinhaEstorno({
    seq: 3, operacaoOrdemId: 'OP-2431 / Corte da chapa', tipo: 'baixa',
    autor: 'E. Sartori', agora: 1000, janelaMs: JANELA_ESTORNO_REAL
  });
  assert.deepEqual(linha.delta, []);
});

/* ============================================================
   2. dentroDaJanela — limite da janela com relógio controlado
   ============================================================ */

test('dentroDaJanela: instante imediatamente após a criação está dentro da janela', () => {
  const linha = criarLinhaEstorno({
    seq: 1, operacaoOrdemId: 'x', tipo: 'baixa', autor: 'x',
    agora: 1000, janelaMs: JANELA_ESTORNO_REAL
  });
  assert.equal(dentroDaJanela(linha, 1001), true);
});

test('dentroDaJanela: no limite exato (agora === janela_expira_em) ainda está dentro', () => {
  const linha = criarLinhaEstorno({
    seq: 1, operacaoOrdemId: 'x', tipo: 'baixa', autor: 'x',
    agora: 1000, janelaMs: JANELA_ESTORNO_REAL
  });
  assert.equal(dentroDaJanela(linha, linha.janela_expira_em), true);
});

test('dentroDaJanela: 1ms após o limite já expirou', () => {
  const linha = criarLinhaEstorno({
    seq: 1, operacaoOrdemId: 'x', tipo: 'baixa', autor: 'x',
    agora: 1000, janelaMs: JANELA_ESTORNO_REAL
  });
  assert.equal(dentroDaJanela(linha, linha.janela_expira_em + 1), false);
});

test('dentroDaJanela: linha ausente (nenhum estorno em aberto) é tratada como fora da janela', () => {
  assert.equal(dentroDaJanela(null, 1000), false);
  assert.equal(dentroDaJanela(undefined, 1000), false);
});

test('dentroDaJanela: 10 minutos exatos (janela real de produção) — dentro até o segundo 600, fora no 600,001', () => {
  const linha = criarLinhaEstorno({
    seq: 1, operacaoOrdemId: 'x', tipo: 'baixa', autor: 'x',
    agora: 0, janelaMs: JANELA_ESTORNO_REAL
  });
  assert.equal(dentroDaJanela(linha, JANELA_ESTORNO_REAL), true);
  assert.equal(dentroDaJanela(linha, JANELA_ESTORNO_REAL + 1), false);
});
