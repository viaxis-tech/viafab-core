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

  echo "$CORPUS" | grep -qE "alter table (if exists )?(public\.)?${tabela}\b[^;]*enable row level security" \
    || faltando="${faltando} enable-rls"

  echo "$CORPUS" | grep -qE "alter table (if exists )?(public\.)?${tabela}\b[^;]*force row level security" \
    || faltando="${faltando} force-rls"

  echo "$CORPUS" | grep -qE "create policy [a-z0-9_]+ on (public\.)?${tabela}\b" \
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
  if echo "$CORPUS" | tr '\n' ' ' | grep -qE "create (or replace )?view public\.${view}\b[^;]*security_invoker"; then
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
