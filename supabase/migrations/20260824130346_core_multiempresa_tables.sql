-- =============================================================================
-- Migration: core_multiempresa_tables
-- Sprint: Banco - fundacao multiempresa, auditoria e RLS fail-closed
-- SPEC: 2.1 "Nucleo multiempresa e seguranca"
-- =============================================================================
-- Cria as 6 tabelas do nucleo multiempresa/seguranca. RLS e policies sao
-- habilitadas em migration separada (20260824130546_rls_fail_closed_policies.sql)
-- para manter a separacao entre "definicao de schema" e "politica de acesso".

-- -----------------------------------------------------------------------------
-- tenants
-- -----------------------------------------------------------------------------
create table if not exists public.tenants (
  id uuid primary key default gen_random_uuid(),
  nome text not null,
  cnpj text not null,
  criado_em timestamptz not null default now(),
  constraint tenants_cnpj_unique unique (cnpj)
);

comment on table public.tenants is
  'Empresas (tenants) da plataforma multiempresa ViaFab (SPEC 2.1).';

-- -----------------------------------------------------------------------------
-- unidades_fabrica (data-unidade-fabrica)
-- -----------------------------------------------------------------------------
create table if not exists public.unidades_fabrica (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants (id) on delete cascade,
  nome text not null,
  sigla text not null,
  cidade text not null,
  uf text not null,
  cnpj text not null,
  ativo boolean not null default true
);

create index if not exists idx_unidades_fabrica_tenant_id
  on public.unidades_fabrica (tenant_id);

comment on table public.unidades_fabrica is
  'Unidades fabris de cada tenant (US-27, delta-076/077). SPEC 2.1.';

-- -----------------------------------------------------------------------------
-- perfis (data-perfil-sessao)
-- -----------------------------------------------------------------------------
create table if not exists public.perfis (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants (id) on delete cascade,
  nome text not null,
  permissoes jsonb not null default '{}'::jsonb,
  constraint perfis_tenant_nome_unique unique (tenant_id, nome)
);

create index if not exists idx_perfis_tenant_id
  on public.perfis (tenant_id);

comment on table public.perfis is
  'Perfis de acesso por tenant (PCP, engenharia, almoxarifado, operador, '
  'qualidade, expedicao, compras, direcao, admin). SPEC 2.1.';
comment on column public.perfis.permissoes is
  'Matriz de permissoes por modulo: {"<modulo>": {"leitura": bool, "escrita": bool}, ...}.';

-- -----------------------------------------------------------------------------
-- usuarios_perfil
-- -----------------------------------------------------------------------------
create table if not exists public.usuarios_perfil (
  usuario_id uuid primary key references auth.users (id) on delete cascade,
  tenant_id uuid not null references public.tenants (id) on delete cascade,
  perfil_id uuid not null references public.perfis (id) on delete restrict,
  unidades_autorizadas uuid[] not null default '{}'::uuid[]
);

create index if not exists idx_usuarios_perfil_tenant_id
  on public.usuarios_perfil (tenant_id);
create index if not exists idx_usuarios_perfil_perfil_id
  on public.usuarios_perfil (perfil_id);

comment on table public.usuarios_perfil is
  'Vinculo usuario<->perfil<->tenant. Espelhado em auth.users.raw_app_meta_data '
  '(tenant_id, perfil_id, unidades_autorizadas) para uso nas policies de RLS. SPEC 2.1.';

-- -----------------------------------------------------------------------------
-- usuarios_unidades_concedidas
-- -----------------------------------------------------------------------------
create table if not exists public.usuarios_unidades_concedidas (
  usuario_id uuid not null references auth.users (id) on delete cascade,
  unidade_id uuid not null references public.unidades_fabrica (id) on delete cascade,
  concedido_em timestamptz not null default now(),
  concedido_por uuid references auth.users (id),
  constraint usuarios_unidades_concedidas_pk primary key (usuario_id, unidade_id)
);

create index if not exists idx_usu_unidades_concedidas_unidade_id
  on public.usuarios_unidades_concedidas (unidade_id);

comment on table public.usuarios_unidades_concedidas is
  'Concessoes de acesso multi-unidade por usuario (data-unidade-fabrica.usuariosConcedidos). '
  'Vinculo ao tenant e feito indiretamente via unidade_id -> unidades_fabrica.tenant_id. SPEC 2.1.';

-- -----------------------------------------------------------------------------
-- usuario_atalhos (data-atalho-usuario)
-- -----------------------------------------------------------------------------
create table if not exists public.usuario_atalhos (
  usuario_id uuid not null references auth.users (id) on delete cascade,
  perfil_id uuid not null references public.perfis (id) on delete cascade,
  screen_id text not null,
  ordem int not null,
  constraint usuario_atalhos_pk primary key (usuario_id, perfil_id, screen_id)
);

create index if not exists idx_usuario_atalhos_usuario_id
  on public.usuario_atalhos (usuario_id);

comment on table public.usuario_atalhos is
  'Atalhos de tela personalizados por usuario/perfil (data-atalho-usuario). '
  'Vinculo ao tenant e feito indiretamente via perfil_id -> perfis.tenant_id. SPEC 2.1.';
