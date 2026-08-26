-- =============================================================================
-- Migration: rls_fail_closed_policies
-- Sprint: Banco - fundacao multiempresa, auditoria e RLS fail-closed
-- SPEC: 2.2 "RLS Policies" (RF-37/US-26/RNF-03)
-- =============================================================================
-- Padrao fail-closed: RLS habilitada em toda tabela de negocio, sem nenhuma
-- policy `using (true)`. Ausencia de policy = acesso negado. Claims de tenant
-- residem exclusivamente em auth.jwt() -> 'app_metadata' (nunca 'user_metadata',
-- que e editavel pelo proprio usuario).
--
-- Desde a versao do CLI usada neste projeto, tabelas novas em `public` NAO sao
-- mais expostas automaticamente aos papeis de Data API (anon/authenticated/
-- service_role) sem GRANT explicito (auto_expose_new_tables=false por padrao,
-- ver supabase/config.toml). Por isso, cada bloco abaixo concede exatamente os
-- privilegios de tabela (SELECT/INSERT/UPDATE) que possuem policy correspondente
-- -- nunca DELETE, que nao tem policy em nenhuma tabela desta sprint.

-- -----------------------------------------------------------------------------
-- tenants
-- -----------------------------------------------------------------------------
alter table public.tenants enable row level security;
alter table public.tenants force row level security;

grant select, update on table public.tenants to authenticated;
grant select, insert, update on table public.tenants to service_role;

-- Tabela raiz: o proprio id representa o tenant. Fail-closed: sem policy de
-- INSERT (provisionamento de tenant e operacao administrativa fora do fluxo
-- comum de RLS, restrita a service_role via GRANT acima).
create policy tenant_isolation_select on public.tenants
  for select using (
    id = (auth.jwt() -> 'app_metadata' ->> 'tenant_id')::uuid
  );

create policy tenant_isolation_update on public.tenants
  for update using (
    id = (auth.jwt() -> 'app_metadata' ->> 'tenant_id')::uuid
  ) with check (
    id = (auth.jwt() -> 'app_metadata' ->> 'tenant_id')::uuid
  );

-- -----------------------------------------------------------------------------
-- unidades_fabrica
-- -----------------------------------------------------------------------------
alter table public.unidades_fabrica enable row level security;
alter table public.unidades_fabrica force row level security;

grant select, insert, update on table public.unidades_fabrica to authenticated;
grant select, insert, update on table public.unidades_fabrica to service_role;

create policy tenant_isolation_select on public.unidades_fabrica
  for select using (
    tenant_id = (auth.jwt() -> 'app_metadata' ->> 'tenant_id')::uuid
  );

create policy tenant_isolation_insert on public.unidades_fabrica
  for insert with check (
    tenant_id = (auth.jwt() -> 'app_metadata' ->> 'tenant_id')::uuid
  );

create policy tenant_isolation_update on public.unidades_fabrica
  for update using (
    tenant_id = (auth.jwt() -> 'app_metadata' ->> 'tenant_id')::uuid
  ) with check (
    tenant_id = (auth.jwt() -> 'app_metadata' ->> 'tenant_id')::uuid
  );

-- -----------------------------------------------------------------------------
-- perfis
-- -----------------------------------------------------------------------------
alter table public.perfis enable row level security;
alter table public.perfis force row level security;

grant select, insert, update on table public.perfis to authenticated;
grant select, insert, update on table public.perfis to service_role;

create policy tenant_isolation_select on public.perfis
  for select using (
    tenant_id = (auth.jwt() -> 'app_metadata' ->> 'tenant_id')::uuid
  );

create policy tenant_isolation_insert on public.perfis
  for insert with check (
    tenant_id = (auth.jwt() -> 'app_metadata' ->> 'tenant_id')::uuid
  );

create policy tenant_isolation_update on public.perfis
  for update using (
    tenant_id = (auth.jwt() -> 'app_metadata' ->> 'tenant_id')::uuid
  ) with check (
    tenant_id = (auth.jwt() -> 'app_metadata' ->> 'tenant_id')::uuid
  );

-- -----------------------------------------------------------------------------
-- usuarios_perfil
-- -----------------------------------------------------------------------------
alter table public.usuarios_perfil enable row level security;
alter table public.usuarios_perfil force row level security;

grant select, insert, update on table public.usuarios_perfil to authenticated;
grant select, insert, update on table public.usuarios_perfil to service_role;

create policy tenant_isolation_select on public.usuarios_perfil
  for select using (
    tenant_id = (auth.jwt() -> 'app_metadata' ->> 'tenant_id')::uuid
  );

create policy tenant_isolation_insert on public.usuarios_perfil
  for insert with check (
    tenant_id = (auth.jwt() -> 'app_metadata' ->> 'tenant_id')::uuid
  );

create policy tenant_isolation_update on public.usuarios_perfil
  for update using (
    tenant_id = (auth.jwt() -> 'app_metadata' ->> 'tenant_id')::uuid
  ) with check (
    tenant_id = (auth.jwt() -> 'app_metadata' ->> 'tenant_id')::uuid
  );

-- -----------------------------------------------------------------------------
-- usuarios_unidades_concedidas (sem tenant_id proprio; vinculo via unidade_id)
-- -----------------------------------------------------------------------------
alter table public.usuarios_unidades_concedidas enable row level security;
alter table public.usuarios_unidades_concedidas force row level security;

grant select, insert, update on table public.usuarios_unidades_concedidas to authenticated;
grant select, insert, update on table public.usuarios_unidades_concedidas to service_role;

create policy tenant_isolation_select on public.usuarios_unidades_concedidas
  for select using (
    exists (
      select 1
      from public.unidades_fabrica u
      where u.id = usuarios_unidades_concedidas.unidade_id
        and u.tenant_id = (auth.jwt() -> 'app_metadata' ->> 'tenant_id')::uuid
    )
  );

create policy tenant_isolation_insert on public.usuarios_unidades_concedidas
  for insert with check (
    exists (
      select 1
      from public.unidades_fabrica u
      where u.id = usuarios_unidades_concedidas.unidade_id
        and u.tenant_id = (auth.jwt() -> 'app_metadata' ->> 'tenant_id')::uuid
    )
  );

create policy tenant_isolation_update on public.usuarios_unidades_concedidas
  for update using (
    exists (
      select 1
      from public.unidades_fabrica u
      where u.id = usuarios_unidades_concedidas.unidade_id
        and u.tenant_id = (auth.jwt() -> 'app_metadata' ->> 'tenant_id')::uuid
    )
  ) with check (
    exists (
      select 1
      from public.unidades_fabrica u
      where u.id = usuarios_unidades_concedidas.unidade_id
        and u.tenant_id = (auth.jwt() -> 'app_metadata' ->> 'tenant_id')::uuid
    )
  );

-- -----------------------------------------------------------------------------
-- usuario_atalhos (sem tenant_id proprio; vinculo via perfil_id)
-- -----------------------------------------------------------------------------
alter table public.usuario_atalhos enable row level security;
alter table public.usuario_atalhos force row level security;

grant select, insert, update on table public.usuario_atalhos to authenticated;
grant select, insert, update on table public.usuario_atalhos to service_role;

create policy tenant_isolation_select on public.usuario_atalhos
  for select using (
    exists (
      select 1
      from public.perfis p
      where p.id = usuario_atalhos.perfil_id
        and p.tenant_id = (auth.jwt() -> 'app_metadata' ->> 'tenant_id')::uuid
    )
  );

create policy tenant_isolation_insert on public.usuario_atalhos
  for insert with check (
    exists (
      select 1
      from public.perfis p
      where p.id = usuario_atalhos.perfil_id
        and p.tenant_id = (auth.jwt() -> 'app_metadata' ->> 'tenant_id')::uuid
    )
  );

create policy tenant_isolation_update on public.usuario_atalhos
  for update using (
    exists (
      select 1
      from public.perfis p
      where p.id = usuario_atalhos.perfil_id
        and p.tenant_id = (auth.jwt() -> 'app_metadata' ->> 'tenant_id')::uuid
    )
  ) with check (
    exists (
      select 1
      from public.perfis p
      where p.id = usuario_atalhos.perfil_id
        and p.tenant_id = (auth.jwt() -> 'app_metadata' ->> 'tenant_id')::uuid
    )
  );

-- -----------------------------------------------------------------------------
-- auditoria: policies de SELECT/INSERT restritas ao tenant do JWT.
-- Tabela e GRANTs de UPDATE/DELETE ja foram tratados em
-- 20260824130446_auditoria_append_only.sql; aqui so adicionamos as policies
-- que faltavam (o RLS ja havia sido habilitado naquela migration).
-- -----------------------------------------------------------------------------
create policy tenant_isolation_select on public.auditoria
  for select using (
    tenant_id = (auth.jwt() -> 'app_metadata' ->> 'tenant_id')::uuid
  );

create policy tenant_isolation_insert on public.auditoria
  for insert with check (
    tenant_id = (auth.jwt() -> 'app_metadata' ->> 'tenant_id')::uuid
  );
-- Nenhuma policy de UPDATE/DELETE e criada para auditoria: fail-closed.
