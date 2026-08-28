#!/usr/bin/env bash
#
# Auditoria de RLS das migrations (WP-0.6 do plano de 25/08/2026).
#
# Reprova quando:
#   - uma tabela criada em public nao tem "enable row level security",
#     "force row level security" e ao menos uma policy;
#   - uma view em public nao declara "security_invoker".
#
# Uso: bash scripts/audit-rls.sh [diretorio-de-migrations]
# Saida: 0 quando limpo, 1 quando ha violacao.
#
# Achado 27/08 (docs/registro-execucao.md): toda checagem usa `grep -qE ...
# <<< "$corpus"` (herestring), nunca `echo "$corpus" | grep -qE ...` (pipe).
# Com `set -o pipefail`, um `grep -q` que encontra o padrao cedo e sai antes
# do `echo` terminar de escrever um corpus grande derruba o `echo` com
# SIGPIPE -- e pipefail conta isso como falha da pipeline inteira, mesmo o
# grep tendo encontrado o padrao. Reproduzido localmente (~1 em 4-8 rodadas)
# e no CI (100% das vezes, com 10 migrations) como falsos-positivos em
# tabelas aleatorias. Herestring elimina o processo escritor concorrente,
# entao nao ha o que receber SIGPIPE.

set -uo pipefail

MIG_DIR="${1:-supabase/migrations}"

if [ ! -d "$MIG_DIR" ]; then
  echo "ERRO: diretorio de migrations nao encontrado: $MIG_DIR" >&2
  exit 1
fi

# Corpus unico em minusculas: a analise e por objeto, nao por arquivo,
# porque o padrao do repositorio separa a migration de schema da de RLS.
CORPUS="$(cat "$MIG_DIR"/*.sql 2>/dev/null | tr '[:upper:]' '[:lower:]')"

if [ -z "$CORPUS" ]; then
  echo "ERRO: nenhuma migration .sql encontrada em $MIG_DIR" >&2
  exit 1
fi

# Variante em uma linha so, para a checagem de view (security_invoker pode
# estar em outra linha do mesmo create view). Calculada uma vez aqui, nunca
# via pipe direto para grep -q mais abaixo -- ver nota sobre SIGPIPE.
CORPUS_FLAT="$(tr '\n' ' ' <<< "$CORPUS")"

violacoes=0
tabelas=0
views=0

reprovar() {
  echo "FALHA  $1"
  violacoes=$((violacoes + 1))
}

while IFS= read -r tabela; do
  [ -z "$tabela" ] && continue
  tabelas=$((tabelas + 1))
  faltando=""

  grep -qE "alter table (if exists )?(public\.)?${tabela}\b[^;]*enable row level security" <<< "$CORPUS" \
    || faltando="${faltando} enable-rls"

  grep -qE "alter table (if exists )?(public\.)?${tabela}\b[^;]*force row level security" <<< "$CORPUS" \
    || faltando="${faltando} force-rls"

  grep -qE "create policy [a-z0-9_]+ on (public\.)?${tabela}\b" <<< "$CORPUS" \
    || faltando="${faltando} policy"

  if [ -n "$faltando" ]; then
    reprovar "public.${tabela}:${faltando}"
  else
    echo "PASSA  public.${tabela}"
  fi
done < <(echo "$CORPUS" | grep -oE "create table (if not exists )?public\.[a-z0-9_]+" | sed -E 's/.*public\.//' | sort -u)

while IFS= read -r view; do
  [ -z "$view" ] && continue
  views=$((views + 1))

  # A clausula security_invoker tem de estar dentro do proprio create view.
  if grep -qE "create (or replace )?view public\.${view}\b[^;]*security_invoker" <<< "$CORPUS_FLAT"; then
    echo "PASSA  view public.${view}"
  else
    reprovar "view public.${view}: sem security_invoker"
  fi
done < <(echo "$CORPUS" | grep -oE "create (or replace )?view public\.[a-z0-9_]+" | sed -E 's/.*public\.//' | sort -u)

echo
echo "Auditados: ${tabelas} tabela(s), ${views} view(s) em ${MIG_DIR}"

if [ "$violacoes" -gt 0 ]; then
  echo "${violacoes} violacao(oes) de RLS encontrada(s)."
  exit 1
fi

echo "Nenhuma violacao de RLS."
exit 0
