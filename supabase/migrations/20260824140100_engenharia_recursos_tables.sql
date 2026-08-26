-- =============================================================================
-- Migration: engenharia_recursos_tables
-- Sprint: Banco - catalogo de engenharia e recursos
-- SPEC: 2.1 "Recursos"
-- =============================================================================
-- Cria setores, maquinas e cargos. RLS e habilitada em migration separada
-- (20260824140300_engenharia_rls_policies.sql).

-- -----------------------------------------------------------------------------
-- setores
-- -----------------------------------------------------------------------------
create table if not exists public.setores (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants (id) on delete cascade,
  unidade_id uuid not null references public.unidades_fabrica (id) on delete cascade,
  nome text not null,
  constraint setores_tenant_unidade_nome_unique unique (tenant_id, unidade_id, nome)
);

create index if not exists idx_setores_tenant_unidade
  on public.setores (tenant_id, unidade_id);

comment on table public.setores is
  'Setores fabris por unidade (corte, impressao, laminacao, montagem, etc.). '
  'SPEC 2.1.';

-- -----------------------------------------------------------------------------
-- maquinas
-- -----------------------------------------------------------------------------
create table if not exists public.maquinas (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants (id) on delete cascade,
  unidade_id uuid not null references public.unidades_fabrica (id) on delete cascade,
  setor_id uuid not null references public.setores (id) on delete cascade,
  nome text not null,
  tipo_operacao text,
  capacidade_horas_dia numeric not null default 0
);

create index if not exists idx_maquinas_tenant_unidade
  on public.maquinas (tenant_id, unidade_id);
create index if not exists idx_maquinas_setor_id
  on public.maquinas (setor_id);

comment on table public.maquinas is
  'Maquinas por setor/unidade, com capacidade diaria (capacidade_horas_dia). '
  'SPEC 2.1.';

-- -----------------------------------------------------------------------------
-- cargos (data-cargo)
-- -----------------------------------------------------------------------------
create table if not exists public.cargos (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants (id) on delete cascade,
  codigo text not null,
  nome text not null,
  setor_id uuid not null references public.setores (id) on delete cascade,
  custo_hora numeric not null default 0,
  efetivo int not null default 0,
  observacao text,
  constraint cargos_tenant_codigo_unique unique (tenant_id, codigo)
);

create index if not exists idx_cargos_tenant_id on public.cargos (tenant_id);
create index if not exists idx_cargos_setor_id on public.cargos (setor_id);

comment on table public.cargos is
  'Cargos/mao de obra vinculados a um setor, com custo_hora usado por '
  'fn_custo_aberto. SPEC 2.1.';
