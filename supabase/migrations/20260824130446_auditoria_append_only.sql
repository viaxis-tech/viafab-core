-- =============================================================================
-- Migration: auditoria_append_only
-- Sprint: Banco - fundacao multiempresa, auditoria e RLS fail-closed
-- SPEC: 2.1 (data-auditoria), 2.2 (append-only), RF-36/RNF-15
-- =============================================================================
-- Tabela de auditoria append-only: apenas INSERT/SELECT sao possiveis.
-- UPDATE/DELETE sao bloqueados em duas camadas independentes:
--   1) Nao existe policy de UPDATE/DELETE (RLS fail-closed nega por ausencia).
--   2) REVOKE explicito do privilegio SQL de UPDATE/DELETE de TODOS os papeis,
--      inclusive service_role. Isso e necessario porque service_role possui o
--      atributo BYPASSRLS na plataforma Supabase (ele pula a checagem de RLS),
--      mas o sistema de GRANT/REVOKE do Postgres e uma camada independente da
--      RLS e NAO e afetada por BYPASSRLS. Por isso o REVOKE garante o bloqueio
--      mesmo para service_role (RF-36/RNF-15).

create table if not exists public.auditoria (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants (id) on delete cascade,
  usuario_id uuid references auth.users (id),
  acao text not null,
  entidade text not null,
  entidade_id uuid,
  dado_alterado jsonb,
  criado_em timestamptz not null default now()
);

create index if not exists idx_auditoria_tenant_id
  on public.auditoria (tenant_id);
create index if not exists idx_auditoria_entidade
  on public.auditoria (entidade, entidade_id);
create index if not exists idx_auditoria_criado_em
  on public.auditoria (criado_em desc);

comment on table public.auditoria is
  'Trilha de auditoria append-only (RF-36/RNF-15). Sem UPDATE/DELETE, inclusive '
  'para service_role (REVOKE explicito nesta migration).';

alter table public.auditoria enable row level security;
alter table public.auditoria force row level security;

-- Camada de privilegio: remove QUALQUER privilegio pre-existente (defensivo)
-- e concede de volta apenas o estritamente necessario (SELECT/INSERT).
revoke all on table public.auditoria from public;
revoke all on table public.auditoria from anon;
revoke all on table public.auditoria from authenticated;
revoke all on table public.auditoria from service_role;

grant select, insert on table public.auditoria to authenticated;
grant select, insert on table public.auditoria to service_role;
-- Nenhum papel recebe UPDATE ou DELETE nesta tabela. Ponto final.
