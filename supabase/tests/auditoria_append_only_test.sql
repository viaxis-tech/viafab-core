-- =============================================================================
-- Teste pgTAP: auditoria append-only (RF-36/RNF-15)
-- Sprint: Banco - fundacao multiempresa, auditoria e RLS fail-closed
-- Comprova que UPDATE/DELETE em auditoria falham tanto para `authenticated`
-- (fail-closed por ausencia de policy) quanto para `service_role` (REVOKE de
-- privilegio, que independe do atributo BYPASSRLS do papel).
-- Executar: supabase test db
-- =============================================================================
begin;
select plan(6);

-- -----------------------------------------------------------------------------
-- Fixtures
-- -----------------------------------------------------------------------------
insert into public.tenants (id, nome, cnpj) values
  ('e1111111-1111-1111-1111-111111111111', 'Tenant Auditoria (pgTAP)', '33333333000199');

insert into auth.users (
  instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
  raw_app_meta_data, raw_user_meta_data, created_at, updated_at,
  confirmation_token, email_change, email_change_token_new, recovery_token
) values (
  '00000000-0000-0000-0000-000000000000', 'e1111111-0000-0000-0000-000000000009',
  'authenticated', 'authenticated', 'user.audit@pgtap.test',
  extensions.crypt('senha-teste-pgtap', extensions.gen_salt('bf')), now(),
  jsonb_build_object('tenant_id', 'e1111111-1111-1111-1111-111111111111'),
  '{}'::jsonb, now(), now(), '', '', '', ''
);

insert into public.auditoria (id, tenant_id, usuario_id, acao, entidade, entidade_id, dado_alterado)
values (
  'e1111111-0000-0000-0000-000000000010', 'e1111111-1111-1111-1111-111111111111',
  'e1111111-0000-0000-0000-000000000009', 'criar', 'ordem',
  'e1111111-0000-0000-0000-000000000099', '{"campo": "valor"}'::jsonb
);

-- -----------------------------------------------------------------------------
-- Sessao autenticada do proprio tenant: SELECT/INSERT funcionam (policies),
-- UPDATE/DELETE sao negados por ausencia de policy (fail-closed).
-- -----------------------------------------------------------------------------
set local role authenticated;
select set_config(
  'request.jwt.claims',
  jsonb_build_object(
    'sub', 'e1111111-0000-0000-0000-000000000009',
    'role', 'authenticated',
    'app_metadata', jsonb_build_object('tenant_id', 'e1111111-1111-1111-1111-111111111111')
  )::text,
  true
);

select is(
  (select count(*)::int from public.auditoria),
  1,
  'auditoria: usuario do tenant ve o proprio registro (policy tenant_isolation_select)'
);

select lives_ok(
  $$ insert into public.auditoria (tenant_id, usuario_id, acao, entidade, entidade_id, dado_alterado)
     values ('e1111111-1111-1111-1111-111111111111', 'e1111111-0000-0000-0000-000000000009',
             'atualizar', 'ordem', 'e1111111-0000-0000-0000-000000000099', '{"campo": "novo"}'::jsonb) $$,
  'auditoria: INSERT do proprio tenant e permitido (policy tenant_isolation_insert)'
);

select throws_ok(
  $$ update public.auditoria set acao = 'alterado' where tenant_id = 'e1111111-1111-1111-1111-111111111111' $$,
  '42501',
  null::text,
  'auditoria: UPDATE e negado para authenticated (sem policy de UPDATE = fail-closed)'
);

select throws_ok(
  $$ delete from public.auditoria where tenant_id = 'e1111111-1111-1111-1111-111111111111' $$,
  '42501',
  null::text,
  'auditoria: DELETE e negado para authenticated (sem policy de DELETE = fail-closed)'
);

-- -----------------------------------------------------------------------------
-- Sessao service_role: mesmo com o atributo BYPASSRLS (que ignora policies),
-- o REVOKE de UPDATE/DELETE feito na migration bloqueia a operacao na camada
-- de privilegio SQL, independente de RLS.
-- -----------------------------------------------------------------------------
reset role;
set local role service_role;

select throws_ok(
  $$ update public.auditoria set acao = 'alterado-por-service-role' $$,
  '42501',
  null::text,
  'auditoria: UPDATE e negado para service_role mesmo com BYPASSRLS (REVOKE de privilegio)'
);

select throws_ok(
  $$ delete from public.auditoria $$,
  '42501',
  null::text,
  'auditoria: DELETE e negado para service_role mesmo com BYPASSRLS (REVOKE de privilegio)'
);

reset role;
select * from finish();
rollback;
