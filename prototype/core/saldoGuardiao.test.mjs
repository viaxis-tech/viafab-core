// Testes do guardião único de saldo (WP-1.3).
//
// Duas seções:
//   1. Caracterização do bug F8/achado (prototype/index.html:17044, fluxo de
//      correção/estorno de apontamento) — a ÚNICA exceção sancionada em
//      docs/conducao-agente-20260825.md guardrail 4.4 a um teste de
//      caracterização provar um bug (não apenas documentá-lo).
//   2. Casos gerais da invariante do guardião em si.
//
// Por que a seção 1 não importa prototype/index.html diretamente: o arquivo
// não é um módulo (é HTML com <script> clássico executado em DOM), o mesmo
// motivo já registrado em portaDados.test.mjs. A fixture abaixo é uma
// reprodução fiel do trecho de index.html:17044 — citada com o número da
// linha, mantida em sincronia com o código real (mesma técnica já usada e
// documentada para `qPerda` em prototype/core/qPerda.mjs, WP-1.1).
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { aplicarSaldo } from './saldoGuardiao.mjs';

/* ============================================================
   1. Caracterização do bug de :17044 (correção/estorno de apontamento)
   ============================================================
   Estado ANTES da correção deste WP (histórico — o vermelho original desta
   suíte, com esta mesma fixture ainda chamando `fisAtual + x.q` bruto, está
   registrado no relatório de execução do WP-1.3):
     u.rev.itens.forEach(x => { const it = item(x.cod);
       if(it){ it.fis += x.q; it.res += x.q; } });
   Estado DEPOIS da correção (linha real hoje em prototype/index.html:17054-17057,
   passa pelo guardião — reproduzido abaixo para o campo fis, onde o defeito
   F8 de resíduo de ponto flutuante se manifestava):
     it.fis = window.aplicarSaldo(it.fis, x.q, { estoqueNegativo: PARAM.estoqueNegativo });
   Mantida em sincronia com o código real pelo mesmo motivo documentado para
   `qPerda` em prototype/core/qPerda.mjs (WP-1.1): index.html não é um módulo
   importável, então a fixture é uma reprodução fiel, não um import. */
function estornaFisComoEmIndexHtml17044(fisAtual, x) {
  return aplicarSaldo(fisAtual, x.q, { estoqueNegativo: false });
}

test('[caracterização F8/:17044, corrigido via guardião] estorno sucessivo de apontamentos não acumula mais resíduo de ponto flutuante em fis', () => {
  let fis = 0;
  // Três estornos de 0.1 cada — antes da correção este teste falhava com
  // 0.30000000000000004 (ver relatório do WP-1.3 para a captura vermelha).
  fis = estornaFisComoEmIndexHtml17044(fis, { q: 0.1 });
  fis = estornaFisComoEmIndexHtml17044(fis, { q: 0.1 });
  fis = estornaFisComoEmIndexHtml17044(fis, { q: 0.1 });
  // A invariante exige 2 casas decimais exatas: 0.3.
  assert.equal(fis, 0.3);
});

/* ============================================================
   2. Casos gerais da invariante do guardião
   ============================================================ */

test('aplicarSaldo: soma normal (sem resíduo) devolve o resultado exato', () => {
  assert.equal(aplicarSaldo(100, 40), 140);
});

test('aplicarSaldo: soma com resíduo de ponto flutuante é arredondada a 2 casas', () => {
  let v = 0;
  v = aplicarSaldo(v, 0.1);
  v = aplicarSaldo(v, 0.1);
  v = aplicarSaldo(v, 0.1);
  assert.equal(v, 0.3);
});

test('aplicarSaldo: subtração que chega exatamente a zero devolve 0', () => {
  assert.equal(aplicarSaldo(25, -25), 0);
});

test('aplicarSaldo: subtração além de zero sem estoqueNegativo é clampada em 0', () => {
  assert.equal(aplicarSaldo(10, -25), 0);
});

test('aplicarSaldo: subtração além de zero com estoqueNegativo permite resultado negativo', () => {
  assert.equal(aplicarSaldo(10, -25, { estoqueNegativo: true }), -15);
});

test('aplicarSaldo: estoqueNegativo ainda arredonda a 2 casas ao permitir negativo', () => {
  assert.equal(aplicarSaldo(0, -0.1 - 0.2, { estoqueNegativo: true }), -0.3);
});

test('aplicarSaldo: valor atual ausente/undefined é tratado como 0', () => {
  assert.equal(aplicarSaldo(undefined, 5), 5);
});

test('aplicarSaldo: delta ausente/undefined não altera o valor atual', () => {
  assert.equal(aplicarSaldo(30, undefined), 30);
});

test('aplicarSaldo: opções omitidas usam o padrão (clamp em 0)', () => {
  assert.equal(aplicarSaldo(5, -10), 0);
});
