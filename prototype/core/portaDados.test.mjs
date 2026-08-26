// Testes da porta de dados (WP-1.2): operações básicas de leitura/escrita/
// ajuste de saldo do adapter de memória, contra um estado de teste isolado
// — nunca o `DB` de produção do protótipo (fora de escopo importar
// prototype/index.html, que não é um módulo).
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { createPortaMemoria } from './portaDados.mjs';

test('lerSaldo: item sem saldo registrado retorna fis/res zerados', async () => {
  const porta = createPortaMemoria();
  assert.deepEqual(await porta.lerSaldo('MAT-001', 'T-001'), { fis: 0, res: 0 });
});

test('lerSaldo: lê os valores existentes no estado inicial', async () => {
  const porta = createPortaMemoria({
    saldo: { 'T-001': { 'MAT-001': 240 } },
    reserva: { 'T-001': { 'MAT-001': 15.5 } }
  });
  assert.deepEqual(await porta.lerSaldo('MAT-001', 'T-001'), { fis: 240, res: 15.5 });
});

test('lerSaldo: unidade sem nenhum item registrado retorna fis/res zerados', async () => {
  const porta = createPortaMemoria({ saldo: { 'T-001': { 'MAT-001': 100 } } });
  assert.deepEqual(await porta.lerSaldo('MAT-001', 'T-002'), { fis: 0, res: 0 });
});

test('ajustarSaldo: aplica delta positivo a fis e devolve o saldo resultante', async () => {
  const porta = createPortaMemoria({ saldo: { 'T-001': { 'MAT-001': 100 } } });
  const saldoFinal = await porta.ajustarSaldo('MAT-001', 'T-001', { fis: 40 });
  assert.deepEqual(saldoFinal, { fis: 140, res: 0 });
});

test('ajustarSaldo: aplica delta negativo a res sem clamp em zero (invariante é do WP-1.3)', async () => {
  const porta = createPortaMemoria({ reserva: { 'T-001': { 'MAT-001': 10 } } });
  const saldoFinal = await porta.ajustarSaldo('MAT-001', 'T-001', { res: -25 });
  assert.equal(saldoFinal.res, -15);
});

test('ajustarSaldo: aplica fis e res na mesma chamada', async () => {
  const porta = createPortaMemoria({
    saldo: { 'T-001': { 'MAT-001': 50 } },
    reserva: { 'T-001': { 'MAT-001': 5 } }
  });
  const saldoFinal = await porta.ajustarSaldo('MAT-001', 'T-001', { fis: -10, res: 10 });
  assert.deepEqual(saldoFinal, { fis: 40, res: 15 });
});

test('ajustarSaldo: cria os mapas de tenant/item quando ainda não existem', async () => {
  const porta = createPortaMemoria();
  const saldoFinal = await porta.ajustarSaldo('MAT-NOVO', 'T-003', { fis: 8 });
  assert.deepEqual(saldoFinal, { fis: 8, res: 0 });
});

test('ajustarSaldo: sem deltas informados devolve o saldo inalterado', async () => {
  const porta = createPortaMemoria({ saldo: { 'T-001': { 'MAT-001': 30 } } });
  const saldoFinal = await porta.ajustarSaldo('MAT-001', 'T-001', {});
  assert.deepEqual(saldoFinal, { fis: 30, res: 0 });
});

test('ajustarSaldo: arredonda resíduo de ponto flutuante a 2 casas, mesma precisão do legado', async () => {
  const porta = createPortaMemoria();
  await porta.ajustarSaldo('MAT-001', 'T-001', { fis: 0.1 });
  await porta.ajustarSaldo('MAT-001', 'T-001', { fis: 0.2 });
  const saldoFinal = await porta.lerSaldo('MAT-001', 'T-001');
  assert.equal(saldoFinal.fis, 0.3);
});

test('ler: chave inexistente numa coleção nunca escrita retorna undefined', async () => {
  const porta = createPortaMemoria();
  assert.equal(await porta.ler('reservas', 'RES-001'), undefined);
});

test('escrever + ler: roundtrip genérico por coleção nomeada', async () => {
  const porta = createPortaMemoria();
  const gravado = await porta.escrever('reservas', 'RES-001', { item: 'MAT-001', qtd: 12 });
  assert.deepEqual(gravado, { item: 'MAT-001', qtd: 12 });
  assert.deepEqual(await porta.ler('reservas', 'RES-001'), { item: 'MAT-001', qtd: 12 });
});

test('escrever: coleções diferentes não colidem entre si na mesma chave', async () => {
  const porta = createPortaMemoria();
  await porta.escrever('reservas', 'X-1', { tipo: 'reserva' });
  await porta.escrever('eventos', 'X-1', { tipo: 'evento' });
  assert.deepEqual(await porta.ler('reservas', 'X-1'), { tipo: 'reserva' });
  assert.deepEqual(await porta.ler('eventos', 'X-1'), { tipo: 'evento' });
});

test('escrever: sobrescreve o valor de uma chave já gravada', async () => {
  const porta = createPortaMemoria();
  await porta.escrever('colecao', 'K', 1);
  await porta.escrever('colecao', 'K', 2);
  assert.equal(await porta.ler('colecao', 'K'), 2);
});

test('todas as operações da porta devolvem Promise (contrato D2: 100% assíncrona)', () => {
  const porta = createPortaMemoria();
  assert.ok(porta.lerSaldo('MAT-001', 'T-001') instanceof Promise);
  assert.ok(porta.ajustarSaldo('MAT-001', 'T-001', {}) instanceof Promise);
  assert.ok(porta.ler('colecao', 'K') instanceof Promise);
  assert.ok(porta.escrever('colecao', 'K', 1) instanceof Promise);
});
