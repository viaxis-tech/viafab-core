#!/usr/bin/env node
// tools/contraste.mjs
//
// Verificador de contraste WCAG AA — le os tokens de cor de `:root` e
// `[data-theme="light"]` diretamente do CSS de prototype/index.html (sem
// executar a pagina, sem headless browser) e valida os pares normativos da
// SPEC (secao 4.5) nos dois temas: texto, .pill, .btn-primary e o
// indicador de foco (:focus-visible).
//
// Uso:  node tools/contraste.mjs
// Sem dependencias externas (Node >= 18, ESM nativo).
//
// Criterio de falha: exit code != 0 e listagem das violacoes quando
// qualquer par medido ficar abaixo do criterio aplicavel
// (>=4,5:1 texto normal; >=3:1 texto grande/UI/foco), em qualquer tema.

import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { dirname, join } from 'node:path';

const __dirname = dirname(fileURLToPath(import.meta.url));
const PROTOTYPE_PATH = join(__dirname, '..', 'prototype', 'index.html');

// ---------------------------------------------------------------- leitura

function lerCss() {
  let html;
  try {
    html = readFileSync(PROTOTYPE_PATH, 'utf8');
  } catch (err) {
    console.error(`Nao foi possivel ler ${PROTOTYPE_PATH}: ${err.message}`);
    process.exit(2);
  }
  return html.replace(/\/\*[\s\S]*?\*\//g, ''); // remove comentarios CSS
}

// Extrai o conteudo de um bloco `<seletor>{...}` cujo seletor comeca em
// inicio de linha (evita casar o mesmo texto quando aparece como parte de
// um seletor composto, ex.: ":root,[data-theme=\"light\"]{" na camada de
// compatibilidade).
function extrairBloco(css, seletorExato) {
  const escapado = seletorExato.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
  const re = new RegExp(`(?:^|\\n)${escapado}\\{([\\s\\S]*?)\\n\\}`);
  const m = css.match(re);
  if (!m) {
    console.error(`Bloco ${seletorExato} nao encontrado em prototype/index.html`);
    process.exit(2);
  }
  return m[1];
}

// Extrai pares --token:valor; de um bloco de declaracoes
function extrairTokens(bloco) {
  const tokens = {};
  const re = /--([a-zA-Z0-9-]+)\s*:\s*([^;]+);/g;
  let m;
  while ((m = re.exec(bloco))) {
    tokens[m[1]] = m[2].trim();
  }
  return tokens;
}

// Resolve `var(--nome[, fallback])` recursivamente ate um valor literal
function resolverToken(tokens, nome, visitados = new Set()) {
  if (visitados.has(nome)) {
    throw new Error(`Referencia circular ao resolver --${nome}`);
  }
  visitados.add(nome);
  const bruto = tokens[nome];
  if (bruto === undefined) {
    throw new Error(`Token --${nome} nao declarado`);
  }
  return resolverValor(tokens, bruto, visitados);
}

function resolverValor(tokens, valor, visitados) {
  const m = valor.match(/^var\(\s*--([a-zA-Z0-9-]+)\s*(?:,\s*([\s\S]+))?\)$/);
  if (!m) return valor;
  const [, nomeRef, fallback] = m;
  if (tokens[nomeRef] !== undefined) {
    return resolverToken(tokens, nomeRef, visitados);
  }
  if (fallback !== undefined) {
    return resolverValor(tokens, fallback.trim(), visitados);
  }
  throw new Error(`Nao foi possivel resolver var(--${nomeRef})`);
}

// -------------------------------------------------------------- luminancia

function hexParaRgb(hex) {
  let h = hex.trim().replace('#', '');
  if (h.length === 3) h = h.split('').map((c) => c + c).join('');
  if (!/^[0-9a-fA-F]{6}$/.test(h)) {
    throw new Error(`Valor de cor nao suportado (esperado hex): "${hex}"`);
  }
  return {
    r: parseInt(h.slice(0, 2), 16),
    g: parseInt(h.slice(2, 4), 16),
    b: parseInt(h.slice(4, 6), 16),
  };
}

function canalLinear(c) {
  const s = c / 255;
  return s <= 0.03928 ? s / 12.92 : Math.pow((s + 0.055) / 1.055, 2.4);
}

function luminanciaRelativa({ r, g, b }) {
  return 0.2126 * canalLinear(r) + 0.7152 * canalLinear(g) + 0.0722 * canalLinear(b);
}

function razaoDeContraste(hexA, hexB) {
  const la = luminanciaRelativa(hexParaRgb(hexA));
  const lb = luminanciaRelativa(hexParaRgb(hexB));
  const clara = Math.max(la, lb);
  const escura = Math.min(la, lb);
  return (clara + 0.05) / (escura + 0.05);
}

// ------------------------------------------------------------------ dados

const css = lerCss();
const tokensEscuro = extrairTokens(extrairBloco(css, ':root'));
// tema claro herda tudo de :root e sobrescreve apenas o que redeclara
const tokensClaro = { ...tokensEscuro, ...extrairTokens(extrairBloco(css, '[data-theme="light"]')) };

function resolver(tema, nome) {
  const tokens = tema === 'claro' ? tokensClaro : tokensEscuro;
  return resolverToken(tokens, nome);
}

// -------------------------------------------------------------- checagens
//
// Cobertura obrigatoria (RNF-01): texto, .pill, .btn-primary e indicador
// de foco, nos dois temas. Fundos de referencia seguem a tabela normativa
// da SPEC 4.5 ("Medido contra"): --bg-primary para texto e foco,
// --accent para o texto sobre o botao primario, --bg-field para o fundo
// do .pill (chip sem estado, cor via --pill-c/--text-muted).

const TEXTO_NORMAL = 4.5;
const UI_FOCO = 3.0;

const checagens = [
  // --- texto (US-18, RF-31) ---
  { tema: 'claro', categoria: 'texto', fg: 'text-dim', bg: 'bg-primary', min: TEXTO_NORMAL },
  { tema: 'claro', categoria: 'texto', fg: 'text-faint', bg: 'bg-primary', min: TEXTO_NORMAL },
  { tema: 'claro', categoria: 'texto', fg: 'accent-text', bg: 'bg-primary', min: TEXTO_NORMAL },
  { tema: 'escuro', categoria: 'texto', fg: 'text-dim', bg: 'bg-primary', min: TEXTO_NORMAL },
  { tema: 'escuro', categoria: 'texto', fg: 'text-faint', bg: 'bg-primary', min: TEXTO_NORMAL },

  // --- .btn-primary (US-19, RF-33) ---
  { tema: 'claro', categoria: 'btn-primary', fg: 'text-on-accent', bg: 'accent', min: TEXTO_NORMAL },
  { tema: 'escuro', categoria: 'btn-primary', fg: 'text-on-accent', bg: 'accent', min: TEXTO_NORMAL },

  // --- .pill (US-18, RF-32 — chip sem estado: cor via --text-muted) ---
  { tema: 'claro', categoria: 'pill', fg: 'text-muted', bg: 'bg-field', min: TEXTO_NORMAL },
  { tema: 'escuro', categoria: 'pill', fg: 'text-muted', bg: 'bg-field', min: TEXTO_NORMAL },

  // --- indicador de foco (US-17, RF-30) ---
  { tema: 'claro', categoria: 'foco', fg: 'accent-text', bg: 'bg-primary', min: UI_FOCO },
  { tema: 'escuro', categoria: 'foco', fg: 'accent-text', bg: 'bg-primary', min: UI_FOCO },
];

// -------------------------------------------------------------------- run

const CRITERIO_LABEL = { [TEXTO_NORMAL]: '>=4,5:1 texto normal', [UI_FOCO]: '>=3:1 UI/foco' };

let falhas = [];
console.log('Verificador de contraste WCAG AA — tools/contraste.mjs\n');
console.log(`Lendo tokens de: ${PROTOTYPE_PATH}\n`);

for (const c of checagens) {
  let hexFg, hexBg, razao, erro = null;
  try {
    hexFg = resolver(c.tema, c.fg);
    hexBg = resolver(c.tema, c.bg);
    razao = razaoDeContraste(hexFg, hexBg);
  } catch (e) {
    erro = e.message;
  }

  const rotulo = `[${c.categoria}] tema ${c.tema}: --${c.fg} sobre --${c.bg}`;
  if (erro) {
    falhas.push({ ...c, erro });
    console.log(`FALHA  ${rotulo} — erro ao resolver tokens: ${erro}`);
    continue;
  }

  const passou = razao >= c.min;
  const status = passou ? 'PASSA ' : 'FALHA ';
  const razaoFmt = razao.toFixed(2).replace('.', ',');
  console.log(
    `${status} ${rotulo} (${hexFg} / ${hexBg}) = ${razaoFmt}:1 — criterio ${CRITERIO_LABEL[c.min]}`
  );
  if (!passou) {
    falhas.push({ ...c, hexFg, hexBg, razao });
  }
}

console.log('');
if (falhas.length === 0) {
  console.log(`Todos os ${checagens.length} pares token/tema passaram no criterio AA/foco.`);
  process.exit(0);
} else {
  console.log(`${falhas.length} violacao(oes) encontrada(s):`);
  for (const f of falhas) {
    if (f.erro) {
      console.log(`  - [${f.categoria}] tema ${f.tema}: --${f.fg} sobre --${f.bg} — ${f.erro}`);
    } else {
      const razaoFmt = f.razao.toFixed(2).replace('.', ',');
      console.log(
        `  - [${f.categoria}] tema ${f.tema}: --${f.fg} (${f.hexFg}) sobre --${f.bg} (${f.hexBg}) = ${razaoFmt}:1, abaixo de ${CRITERIO_LABEL[f.min]}`
      );
    }
  }
  process.exit(1);
}
