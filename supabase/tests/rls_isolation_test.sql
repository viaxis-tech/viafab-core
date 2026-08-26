-- =============================================================================
-- Teste pgTAP: isolamento RLS cross-tenant e fail-closed
-- Sprint: Banco - fundacao multiempresa, auditoria e RLS fail-closed
-- SPEC: 2.2 (RF-37/US-26) - "suite pgTAP com dois tenants ficticios tentando
-- cross-read".
-- Executar: supabase test db
-- =============================================================================
begin;
select plan(13);

-- -----------------------------------------------------------------------------
-- Fixtures: dois tenants ficticios (A e B) com unidade, perfil, usuario e
-- vinculos minimos. Executado como owner/superuser (bypassa RLS) -- fixtures
-- nao devem ser filtradas por policy.
-- -----------------------------------------------------------------------------
insert into public.tenants (id, nome, cnpj) values
  ('f1111111-1111-1111-1111-111111111111', 'Tenant A (pgTAP)', '11111111000191'),
  ('f2222222-2222-2222-2222-222222222222', 'Tenant B (pgTAP)', '22222222000191');

insert into public.unidades_fabrica (id, tenant_id, nome, sigla, cidade, uf, cnpj, ativo) values
  ('f1111111-0000-0000-0000-000000000001', 'f1111111-1111-1111-1111-111111111111', 'Unidade A', 'UA', 'Cidade A', 'SP', '11111111000191', true),
  ('f2222222-0000-0000-0000-000000000001', 'f2222222-2222-2222-2222-222222222222', 'Unidade B', 'UB', 'Cidade B', 'RJ', '22222222000191', true);

insert into public.perfis (id, tenant_id, nome, permissoes) values
  ('f1111111-0000-0000-0000-000000000002', 'f1111111-1111-1111-1111-111111111111', 'Admin', '{}'::jsonb),
  ('f2222222-0000-0000-0000-000000000002', 'f2222222-2222-2222-2222-222222222222', 'Admin', '{}'::jsonb);

insert into auth.users (
  instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
  raw_app_meta_data, raw_user_meta_data, created_at, updated_at,
  confirmation_token, email_change, email_change_token_new, recovery_token
) values
  ('00000000-0000-0000-0000-000000000000', 'f1111111-0000-0000-0000-000000000009',
   'authenticated', 'authenticated', 'user.a@pgtap.test',
   extensions.crypt('senha-teste-pgtap', extensions.gen_salt('bf')), now(),
   jsonb_build_object('tenant_id', 'f1111111-1111-1111-1111-111111111111'),
   '{}'::jsonb, now(), now(), '', '', '', ''),
  ('00000000-0000-0000-0000-000000000000', 'f2222222-0000-0000-0000-000000000009',
   'authenticated', 'authenticated', 'user.b@pgtap.test',
   extensions.crypt('senha-teste-pgtap', extensions.gen_salt('bf')), now(),
   jsonb_build_object('tenant_id', 'f2222222-2222-2222-2222-222222222222'),
   '{}'::jsonb, now(), now(), '', '', '', '');

insert into public.usuarios_perfil (usuario_id, tenant_id, perfil_id, unidades_autorizadas) values
  ('f1111111-0000-0000-0000-000000000009', 'f1111111-1111-1111-1111-111111111111',
   'f1111111-0000-0000-0000-000000000002', array['f1111111-0000-0000-0000-000000000001']::uuid[]),
  ('f2222222-0000-0000-0000-000000000009', 'f2222222-2222-2222-2222-222222222222',
   'f2222222-0000-0000-0000-000000000002', array['f2222222-0000-0000-0000-000000000001']::uuid[]);

insert into public.usuarios_unidades_concedidas (usuario_id, unidade_id) values
  ('f1111111-0000-0000-0000-000000000009', 'f1111111-0000-0000-0000-000000000001'),
  ('f2222222-0000-0000-0000-000000000009', 'f2222222-0000-0000-0000-000000000001');

insert into public.usuario_atalhos (usuario_id, perfil_id, screen_id, ordem) values
  ('f1111111-0000-0000-0000-000000000009', 'f1111111-0000-0000-0000-000000000002', 'ordens', 1),
  ('f2222222-0000-0000-0000-000000000009', 'f2222222-0000-0000-0000-000000000002', 'ordens', 1);

-- -----------------------------------------------------------------------------
-- Sessao autenticada como usuario do Tenant A
-- -----------------------------------------------------------------------------
set local role authenticated;
select set_config(
  'request.jwt.claims',
  jsonb_build_object(
    'sub', 'f1111111-0000-0000-0000-000000000009',
    'role', 'authenticated',
    'app_metadata', jsonb_build_object(
      'tenant_id', 'f1111111-1111-1111-1111-111111111111',
      'perfil_id', 'f1111111-0000-0000-0000-000000000002',
      'unidades_autorizadas', jsonb_build_array('f1111111-0000-0000-0000-000000000001')
    )
  )::text,
  true
);

select is(
  (select count(*)::int from public.unidades_fabrica where tenant_id = 'f2222222-2222-2222-2222-222222222222'),
  0,
  'unidades_fabrica: tenant A nao enxerga unidades do tenant B (SELECT cross-tenant = 0 linhas)'
);

select is(
  (select count(*)::int from public.unidades_fabrica),
  1,
  'unidades_fabrica: tenant A enxerga somente a propria unidade'
);

select is(
  (select count(*)::int from public.perfis),
  1,
  'perfis: tenant A enxerga somente o proprio perfil'
);

select is(
  (select count(*)::int from public.tenants),
  1,
  'tenants: tenant A enxerga somente o proprio registro'
);

select is(
  (select count(*)::int from public.usuarios_perfil),
  1,
  'usuarios_perfil: tenant A enxerga somente o proprio usuario'
);

select is(
  (select count(*)::int from public.usuarios_unidades_concedidas),
  1,
  'usuarios_unidades_concedidas: tenant A enxerga somente as proprias concessoes'
);

select is(
  (select count(*)::int from public.usuario_atalhos),
  1,
  'usuario_atalhos: tenant A enxerga somente os proprios atalhos'
);

select throws_ok(
  $$ insert into public.unidades_fabrica (id, tenant_id, nome, sigla, cidade, uf, cnpj, ativo)
     values ('f9999999-0000-0000-0000-000000000099', 'f2222222-2222-2222-2222-222222222222', 'Invasora', 'INV', 'X', 'SP', '00000000000000', true) $$,
  '42501',
  null::text,
  'unidades_fabrica: INSERT com tenant_id de outro tenant falha (policy WITH CHECK)'
);

select throws_ok(
  $$ insert into public.perfis (id, tenant_id, nome, permissoes)
     values ('f9999999-0000-0000-0000-000000000098', 'f2222222-2222-2222-2222-222222222222', 'Invasor', '{}'::jsonb) $$,
  '42501',
  null::text,
  'perfis: INSERT com tenant_id de outro tenant falha (policy WITH CHECK)'
);

-- -----------------------------------------------------------------------------
-- Sessao autenticada como usuario do Tenant B (confirma isolamento nos dois
-- sentidos, nao apenas de A para B).
-- -----------------------------------------------------------------------------
select set_config(
  'request.jwt.claims',
  jsonb_build_object(
    'sub', 'f2222222-0000-0000-0000-000000000009',
    'role', 'authenticated',
    'app_metadata', jsonb_build_object(
      'tenant_id', 'f2222222-2222-2222-2222-222222222222',
      'perfil_id', 'f2222222-0000-0000-0000-000000000002',
      'unidades_autorizadas', jsonb_build_array('f2222222-0000-0000-0000-000000000001')
    )
  )::text,
  true
);

select is(
  (select count(*)::int from public.unidades_fabrica where tenant_id = 'f1111111-1111-1111-1111-111111111111'),
  0,
  'unidades_fabrica: tenant B nao enxerga unidades do tenant A (SELECT cross-tenant = 0 linhas)'
);

select is(
  (select count(*)::int from public.tenants where id = 'f1111111-1111-1111-1111-111111111111'),
  0,
  'tenants: tenant B nao enxerga o registro do tenant A'
);

-- -----------------------------------------------------------------------------
-- Fail-closed literal: tabela SEM NENHUMA policy criada deve negar acesso por
-- completo, mesmo com RLS habilitada + GRANT de tabela concedido ao papel.
-- Demonstra "ausencia de policy = acesso negado" de forma isolada, sem
-- depender da semantica especifica de nenhuma tabela de negocio.
-- -----------------------------------------------------------------------------
reset role;

create table if not exists public._fail_closed_demo (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null,
  valor text
);

alter table public._fail_closed_demo enable row level security;
alter table public._fail_closed_demo force row level security;
grant select, insert on public._fail_closed_demo to authenticated;
-- Nenhuma policy e criada de proposito.

insert into public._fail_closed_demo (tenant_id, valor)
values ('f1111111-1111-1111-1111-111111111111', 'linha existente antes do teste');

set local role authenticated;
select set_config(
  'request.jwt.claims',
  jsonb_build_object(
    'sub', 'f1111111-0000-0000-0000-000000000009',
    'role', 'authenticated',
    'app_metadata', jsonb_build_object('tenant_id', 'f1111111-1111-1111-1111-111111111111')
  )::text,
  true
);

select is(
  (select count(*)::int from public._fail_closed_demo),
  0,
  'fail-closed: tabela sem nenhuma policy nega SELECT mesmo com linha existente e GRANT de tabela'
);

select throws_ok(
  $$ insert into public._fail_closed_demo (tenant_id, valor) values ('f1111111-1111-1111-1111-111111111111', 'tentativa negada') $$,
  '42501',
  null::text,
  'fail-closed: tabela sem nenhuma policy nega INSERT mesmo com GRANT de tabela'
);

reset role;
select * from finish();
rollback;
