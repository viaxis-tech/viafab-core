-- =============================================================================
-- Migration: engenharia_rls_policies
-- Sprint: Banco - catalogo de engenharia e recursos
-- SPEC: 2.2 "RLS Policies" (RNF-03/US-26)
-- =============================================================================
-- RLS fail-closed para as tabelas do catalogo de engenharia e de recursos,
-- reaproveitando o padrao da sprint anterior (claims em auth.jwt() ->
-- 'app_metadata', nunca 'user_metadata'). Tabelas sem tenant_id proprio tem o
-- isolamento aplicado via EXISTS em uma tabela ancestral com tenant_id (mesmo
-- padrao usado em usuarios_unidades_concedidas/usuario_atalhos na sprint-001).
--
-- familias_construtivas/normas_tecnicas/fichas_tecnicas: apenas policies de
-- SELECT/INSERT/UPDATE sao criadas; DELETE nunca tem policy (fail-closed) e,
-- para essas tabelas, tambem ja e bloqueado por trigger em qualquer papel
-- (20260824140200), incluindo service_role.
--
-- setores/maquinas: alem do isolamento por tenant, aplicam isolamento por
-- unidade. Combinamos as duas checagens com AND dentro de uma unica policy
-- por comando -- e nao como duas policies permissivas separadas -- porque o
-- Postgres combina multiplas policies permissivas do mesmo comando com OR, o
-- que abriria uma brecha (bastaria acertar a unidade sem acertar o tenant).
-- Isso diverge levemente do exemplo ilustrativo da SPEC 2.2 (que usa duas
-- policies separadas) de proposito, para evitar essa armadilha de composicao.

-- -----------------------------------------------------------------------------
-- familias_construtivas
-- -----------------------------------------------------------------------------
alter table public.familias_construtivas enable row level security;
alter table public.familias_construtivas force row level security;

grant select, insert on table public.familias_construtivas to authenticated;
grant select, insert on table public.familias_construtivas to service_role;

create policy tenant_isolation_select on public.familias_construtivas
  for select using (
    tenant_id = (auth.jwt() -> 'app_metadata' ->> 'tenant_id')::uuid
  );

create policy tenant_isolation_insert on public.familias_construtivas
  for insert with check (
    tenant_id = (auth.jwt() -> 'app_metadata' ->> 'tenant_id')::uuid
  );
-- Nenhuma policy de UPDATE/DELETE: fail-closed + trigger bloqueia mesmo
-- service_role (RNF-14).

-- -----------------------------------------------------------------------------
-- normas_tecnicas
-- -----------------------------------------------------------------------------
alter table public.normas_tecnicas enable row level security;
alter table public.normas_tecnicas force row level security;

grant select, insert on table public.normas_tecnicas to authenticated;
grant select, insert on table public.normas_tecnicas to service_role;

create policy tenant_isolation_select on public.normas_tecnicas
  for select using (
    tenant_id = (auth.jwt() -> 'app_metadata' ->> 'tenant_id')::uuid
  );

create policy tenant_isolation_insert on public.normas_tecnicas
  for insert with check (
    tenant_id = (auth.jwt() -> 'app_metadata' ->> 'tenant_id')::uuid
  );

-- -----------------------------------------------------------------------------
-- itens
-- -----------------------------------------------------------------------------
alter table public.itens enable row level security;
alter table public.itens force row level security;

grant select, insert, update on table public.itens to authenticated;
grant select, insert, update on table public.itens to service_role;

create policy tenant_isolation_select on public.itens
  for select using (
    tenant_id = (auth.jwt() -> 'app_metadata' ->> 'tenant_id')::uuid
  );

create policy tenant_isolation_insert on public.itens
  for insert with check (
    tenant_id = (auth.jwt() -> 'app_metadata' ->> 'tenant_id')::uuid
  );

create policy tenant_isolation_update on public.itens
  for update using (
    tenant_id = (auth.jwt() -> 'app_metadata' ->> 'tenant_id')::uuid
  ) with check (
    tenant_id = (auth.jwt() -> 'app_metadata' ->> 'tenant_id')::uuid
  );

-- -----------------------------------------------------------------------------
-- produtos_padrao (sem tenant_id proprio; vinculo via item_id -> itens)
-- -----------------------------------------------------------------------------
alter table public.produtos_padrao enable row level security;
alter table public.produtos_padrao force row level security;

grant select, insert, update on table public.produtos_padrao to authenticated;
grant select, insert, update on table public.produtos_padrao to service_role;

create policy tenant_isolation_select on public.produtos_padrao
  for select using (
    exists (
      select 1 from public.itens i
      where i.id = produtos_padrao.item_id
        and i.tenant_id = (auth.jwt() -> 'app_metadata' ->> 'tenant_id')::uuid
    )
  );

create policy tenant_isolation_insert on public.produtos_padrao
  for insert with check (
    exists (
      select 1 from public.itens i
      where i.id = produtos_padrao.item_id
        and i.tenant_id = (auth.jwt() -> 'app_metadata' ->> 'tenant_id')::uuid
    )
  );

create policy tenant_isolation_update on public.produtos_padrao
  for update using (
    exists (
      select 1 from public.itens i
      where i.id = produtos_padrao.item_id
        and i.tenant_id = (auth.jwt() -> 'app_metadata' ->> 'tenant_id')::uuid
    )
  ) with check (
    exists (
      select 1 from public.itens i
      where i.id = produtos_padrao.item_id
        and i.tenant_id = (auth.jwt() -> 'app_metadata' ->> 'tenant_id')::uuid
    )
  );

-- -----------------------------------------------------------------------------
-- fichas_tecnicas
-- -----------------------------------------------------------------------------
alter table public.fichas_tecnicas enable row level security;
alter table public.fichas_tecnicas force row level security;

grant select, insert, update on table public.fichas_tecnicas to authenticated;
grant select, insert, update on table public.fichas_tecnicas to service_role;

create policy tenant_isolation_select on public.fichas_tecnicas
  for select using (
    tenant_id = (auth.jwt() -> 'app_metadata' ->> 'tenant_id')::uuid
  );

create policy tenant_isolation_insert on public.fichas_tecnicas
  for insert with check (
    tenant_id = (auth.jwt() -> 'app_metadata' ->> 'tenant_id')::uuid
  );

-- UPDATE e permitido por policy (isolamento por tenant); a restricao a
-- "apenas metadados" e imposta pelo trigger trg_ficha_update_restrito
-- (20260824140200), que tem acesso a OLD/NEW e por isso e o lugar correto
-- para essa regra (RLS USING/WITH CHECK nao comparam OLD com NEW).
create policy tenant_isolation_update on public.fichas_tecnicas
  for update using (
    tenant_id = (auth.jwt() -> 'app_metadata' ->> 'tenant_id')::uuid
  ) with check (
    tenant_id = (auth.jwt() -> 'app_metadata' ->> 'tenant_id')::uuid
  );

-- -----------------------------------------------------------------------------
-- linhas_ficha (sem tenant_id proprio; vinculo via ficha_id -> fichas_tecnicas)
-- -----------------------------------------------------------------------------
alter table public.linhas_ficha enable row level security;
alter table public.linhas_ficha force row level security;

grant select, insert, update on table public.linhas_ficha to authenticated;
grant select, insert, update on table public.linhas_ficha to service_role;

create policy tenant_isolation_select on public.linhas_ficha
  for select using (
    exists (
      select 1 from public.fichas_tecnicas f
      where f.id = linhas_ficha.ficha_id
        and f.tenant_id = (auth.jwt() -> 'app_metadata' ->> 'tenant_id')::uuid
    )
  );

create policy tenant_isolation_insert on public.linhas_ficha
  for insert with check (
    exists (
      select 1 from public.fichas_tecnicas f
      where f.id = linhas_ficha.ficha_id
        and f.tenant_id = (auth.jwt() -> 'app_metadata' ->> 'tenant_id')::uuid
    )
  );

create policy tenant_isolation_update on public.linhas_ficha
  for update using (
    exists (
      select 1 from public.fichas_tecnicas f
      where f.id = linhas_ficha.ficha_id
        and f.tenant_id = (auth.jwt() -> 'app_metadata' ->> 'tenant_id')::uuid
    )
  ) with check (
    exists (
      select 1 from public.fichas_tecnicas f
      where f.id = linhas_ficha.ficha_id
        and f.tenant_id = (auth.jwt() -> 'app_metadata' ->> 'tenant_id')::uuid
    )
  );

-- -----------------------------------------------------------------------------
-- componentes_gerados (sem tenant_id proprio; vinculo via item_id -> itens)
-- -----------------------------------------------------------------------------
alter table public.componentes_gerados enable row level security;
alter table public.componentes_gerados force row level security;

grant select, insert, update on table public.componentes_gerados to authenticated;
grant select, insert, update on table public.componentes_gerados to service_role;

create policy tenant_isolation_select on public.componentes_gerados
  for select using (
    exists (
      select 1 from public.itens i
      where i.id = componentes_gerados.item_id
        and i.tenant_id = (auth.jwt() -> 'app_metadata' ->> 'tenant_id')::uuid
    )
  );

create policy tenant_isolation_insert on public.componentes_gerados
  for insert with check (
    exists (
      select 1 from public.itens i
      where i.id = componentes_gerados.item_id
        and i.tenant_id = (auth.jwt() -> 'app_metadata' ->> 'tenant_id')::uuid
    )
  );

create policy tenant_isolation_update on public.componentes_gerados
  for update using (
    exists (
      select 1 from public.itens i
      where i.id = componentes_gerados.item_id
        and i.tenant_id = (auth.jwt() -> 'app_metadata' ->> 'tenant_id')::uuid
    )
  ) with check (
    exists (
      select 1 from public.itens i
      where i.id = componentes_gerados.item_id
        and i.tenant_id = (auth.jwt() -> 'app_metadata' ->> 'tenant_id')::uuid
    )
  );

-- -----------------------------------------------------------------------------
-- roteiros_base
-- -----------------------------------------------------------------------------
alter table public.roteiros_base enable row level security;
alter table public.roteiros_base force row level security;

grant select, insert, update on table public.roteiros_base to authenticated;
grant select, insert, update on table public.roteiros_base to service_role;

create policy tenant_isolation_select on public.roteiros_base
  for select using (
    tenant_id = (auth.jwt() -> 'app_metadata' ->> 'tenant_id')::uuid
  );

create policy tenant_isolation_insert on public.roteiros_base
  for insert with check (
    tenant_id = (auth.jwt() -> 'app_metadata' ->> 'tenant_id')::uuid
  );

create policy tenant_isolation_update on public.roteiros_base
  for update using (
    tenant_id = (auth.jwt() -> 'app_metadata' ->> 'tenant_id')::uuid
  ) with check (
    tenant_id = (auth.jwt() -> 'app_metadata' ->> 'tenant_id')::uuid
  );

-- -----------------------------------------------------------------------------
-- setores (tenant + unidade)
-- -----------------------------------------------------------------------------
alter table public.setores enable row level security;
alter table public.setores force row level security;

grant select, insert, update on table public.setores to authenticated;
grant select, insert, update on table public.setores to service_role;

create policy tenant_unidade_isolation_select on public.setores
  for select using (
    tenant_id = (auth.jwt() -> 'app_metadata' ->> 'tenant_id')::uuid
    and unidade_id = any (
      array(select jsonb_array_elements_text(
        auth.jwt() -> 'app_metadata' -> 'unidades_autorizadas'
      ))::uuid[]
    )
  );

create policy tenant_unidade_isolation_insert on public.setores
  for insert with check (
    tenant_id = (auth.jwt() -> 'app_metadata' ->> 'tenant_id')::uuid
    and unidade_id = any (
      array(select jsonb_array_elements_text(
        auth.jwt() -> 'app_metadata' -> 'unidades_autorizadas'
      ))::uuid[]
    )
  );

create policy tenant_unidade_isolation_update on public.setores
  for update using (
    tenant_id = (auth.jwt() -> 'app_metadata' ->> 'tenant_id')::uuid
    and unidade_id = any (
      array(select jsonb_array_elements_text(
        auth.jwt() -> 'app_metadata' -> 'unidades_autorizadas'
      ))::uuid[]
    )
  ) with check (
    tenant_id = (auth.jwt() -> 'app_metadata' ->> 'tenant_id')::uuid
    and unidade_id = any (
      array(select jsonb_array_elements_text(
        auth.jwt() -> 'app_metadata' -> 'unidades_autorizadas'
      ))::uuid[]
    )
  );

-- -----------------------------------------------------------------------------
-- maquinas (tenant + unidade)
-- -----------------------------------------------------------------------------
alter table public.maquinas enable row level security;
alter table public.maquinas force row level security;

grant select, insert, update on table public.maquinas to authenticated;
grant select, insert, update on table public.maquinas to service_role;

create policy tenant_unidade_isolation_select on public.maquinas
  for select using (
    tenant_id = (auth.jwt() -> 'app_metadata' ->> 'tenant_id')::uuid
    and unidade_id = any (
      array(select jsonb_array_elements_text(
        auth.jwt() -> 'app_metadata' -> 'unidades_autorizadas'
      ))::uuid[]
    )
  );

create policy tenant_unidade_isolation_insert on public.maquinas
  for insert with check (
    tenant_id = (auth.jwt() -> 'app_metadata' ->> 'tenant_id')::uuid
    and unidade_id = any (
      array(select jsonb_array_elements_text(
        auth.jwt() -> 'app_metadata' -> 'unidades_autorizadas'
      ))::uuid[]
    )
  );

create policy tenant_unidade_isolation_update on public.maquinas
  for update using (
    tenant_id = (auth.jwt() -> 'app_metadata' ->> 'tenant_id')::uuid
    and unidade_id = any (
      array(select jsonb_array_elements_text(
        auth.jwt() -> 'app_metadata' -> 'unidades_autorizadas'
      ))::uuid[]
    )
  ) with check (
    tenant_id = (auth.jwt() -> 'app_metadata' ->> 'tenant_id')::uuid
    and unidade_id = any (
      array(select jsonb_array_elements_text(
        auth.jwt() -> 'app_metadata' -> 'unidades_autorizadas'
      ))::uuid[]
    )
  );

-- -----------------------------------------------------------------------------
-- cargos (apenas tenant; nao tem unidade_id proprio)
-- -----------------------------------------------------------------------------
alter table public.cargos enable row level security;
alter table public.cargos force row level security;

grant select, insert, update on table public.cargos to authenticated;
grant select, insert, update on table public.cargos to service_role;

create policy tenant_isolation_select on public.cargos
  for select using (
    tenant_id = (auth.jwt() -> 'app_metadata' ->> 'tenant_id')::uuid
  );

create policy tenant_isolation_insert on public.cargos
  for insert with check (
    tenant_id = (auth.jwt() -> 'app_metadata' ->> 'tenant_id')::uuid
  );

create policy tenant_isolation_update on public.cargos
  for update using (
    tenant_id = (auth.jwt() -> 'app_metadata' ->> 'tenant_id')::uuid
  ) with check (
    tenant_id = (auth.jwt() -> 'app_metadata' ->> 'tenant_id')::uuid
  );
