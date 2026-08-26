// prototype/core/portaDados.mjs
//
// Porta de dados assíncrona (WP-1.2, decisão D2: "100% assíncrona desde o
// início — converter tudo agora"). Este arquivo define o contrato único que
// qualquer adapter concreto implementa (memória, aqui; Supabase em WP-5.8),
// e a implementação do adapter de memória sobre o `DB` global do protótipo.
//
// Escopo deste WP: só a fundação. Nenhum call site do legado (`prototype/index.html`)
// é convertido para consumir esta porta — o legado continua lendo/escrevendo
// `DB`/`SALDO`/`RESERV` diretamente, como sempre fez. A conversão dos 117
// sítios é a Etapa 2 (F-2.1 em diante).
//
// Por que todas as operações são assíncronas mesmo o adapter de memória sendo
// síncrono por natureza: D2 exige a porta 100% assíncrona desde já, para que
// trocar de adapter na Etapa 5 (WP-5.8, Supabase) não exija reescrever quem
// consome a porta — o formato da chamada (com `await`) já é o definitivo.
//
// Operações cobertas (mínimo que a cadeia saldo/apontamento da Etapa 2,
// F-2.1, vai precisar — ver plano §Etapa 1/WP-1.2):
//   - lerSaldo(cod, tenant): leitura de fis/res de um item numa unidade.
//     Espelha os getters `fis`/`res` de `prototype/index.html:15746-15755`
//     (embrião `saldoUn`, citado em D2).
//   - ajustarSaldo(cod, tenant, deltas): escrita/ajuste de saldo. Aplica um
//     delta a `fis` e/ou `res` e arredonda a 2 casas — mesma precisão do
//     legado (`Math.round(v * 100) / 100`, visto em `:25683/:25707/:25726`).
//     NÃO aplica a invariante de não-negatividade: essa regra é o guardião
//     único do WP-1.3 (próximo WP), que compõe sobre esta operação.
//   - ler(colecao, chave) / escrever(colecao, chave, valor): mecanismo
//     genérico de leitura/escrita por coleção nomeada, para os domínios que
//     ainda não têm operação dedicada (preparação para a Etapa 2/5 — sem
//     inventar operações que nenhum domínio pede ainda).
//
// Forma escolhida: factory de objeto de funções (não classe) — consistente
// com o padrão já usado em explodir.mjs/matDaOperacao.mjs/custoAberto.mjs
// (createX({ deps }) => objeto com os métodos), sem introduzir um estilo
// novo no repositório.

/**
 * @typedef {Object} SaldoItem
 * @property {number} fis  Saldo físico do item na unidade.
 * @property {number} res  Saldo reservado do item na unidade.
 */

/**
 * Contrato único da porta de dados. Qualquer adapter (memória, Supabase)
 * deve expor exatamente estas quatro operações, todas assíncronas.
 *
 * @typedef {Object} PortaDados
 * @property {(cod: string, tenant: string) => Promise<SaldoItem>} lerSaldo
 * @property {(cod: string, tenant: string, deltas: {fis?: number, res?: number}) => Promise<SaldoItem>} ajustarSaldo
 * @property {(colecao: string, chave: string) => Promise<unknown>} ler
 * @property {(colecao: string, chave: string, valor: unknown) => Promise<unknown>} escrever
 */

/**
 * Adapter de memória da porta de dados. Opera sobre a mesma estrutura em
 * memória que o protótipo usa hoje para saldo: mapas `{ [tenant]: { [cod]: number } }`
 * (idêntico a `SALDO`/`RESERV` em `prototype/index.html:15734`). Passar as
 * referências vivas de `SALDO`/`RESERV` do protótipo faria este adapter
 * operar sobre o estado real do `DB` global — não feito neste WP porque
 * ainda não há nenhum consumidor da porta no legado (ver cabeçalho do
 * arquivo). Os testes (`portaDados.test.mjs`) usam mapas isolados, nunca o
 * `DB` de produção do protótipo.
 *
 * `colecoes` guarda o estado do mecanismo genérico `ler`/`escrever`, um
 * objeto `{ [nomeColecao]: { [chave]: valor } }` — forma independente das
 * coleções específicas do `DB` (arrays com chave primária variável), porque
 * nenhum domínio ainda consome esse mecanismo; a forma concreta de wiring
 * com uma coleção real do `DB` é decisão de quem primeiro a consumir.
 *
 * @param {{ saldo?: Record<string, Record<string, number>>, reserva?: Record<string, Record<string, number>>, colecoes?: Record<string, Record<string, unknown>> }} [estadoInicial]
 * @returns {PortaDados}
 */
export function createPortaMemoria({ saldo = {}, reserva = {}, colecoes = {} } = {}) {
  function arredonda2(v) {
    return Math.round(v * 100) / 100;
  }

  return {
    async lerSaldo(cod, tenant) {
      return {
        fis: (saldo[tenant] || {})[cod] || 0,
        res: (reserva[tenant] || {})[cod] || 0
      };
    },

    async ajustarSaldo(cod, tenant, deltas = {}) {
      if (!saldo[tenant]) saldo[tenant] = {};
      if (!reserva[tenant]) reserva[tenant] = {};
      if (typeof deltas.fis === 'number') {
        saldo[tenant][cod] = arredonda2((saldo[tenant][cod] || 0) + deltas.fis);
      }
      if (typeof deltas.res === 'number') {
        reserva[tenant][cod] = arredonda2((reserva[tenant][cod] || 0) + deltas.res);
      }
      return {
        fis: saldo[tenant][cod] || 0,
        res: reserva[tenant][cod] || 0
      };
    },

    async ler(colecao, chave) {
      return (colecoes[colecao] || {})[chave];
    },

    async escrever(colecao, chave, valor) {
      if (!colecoes[colecao]) colecoes[colecao] = {};
      colecoes[colecao][chave] = valor;
      return valor;
    }
  };
}
