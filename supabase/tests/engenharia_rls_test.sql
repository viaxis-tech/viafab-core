-- =============================================================================
-- Teste pgTAP: RLS fail-closed do catalogo de engenharia e recursos
-- Sprint: Banco - catalogo de engenharia e recursos
-- SPEC: 2.2 (RF-37/US-26) - isolamento por tenant (e por unidade em
-- setores/maquinas) validado com dois tenants ficticios tentando cross-read.
-- Executar: supabase test db
-- =============================================================================
begin;
select plan(19);

-- -----------------------------------------------------------------------------
-- Fixtures: dois tenants ficticios (A e B), cada um com unidade, item,
-- familia, ficha, setor/maquina/cargo e produto padrao. Executado como
-- owner/superuser (bypassa RLS).
-- -----------------------------------------------------------------------------
insert into public.tenants (id, nome, cnpj) values
  ('c1111111-1111-1111-1111-111111111111', 'Tenant Engenharia A (pgTAP)', '55555555000111'),
  ('c2222222-2222-2222-2222-222222222222', 'Tenant Engenharia B (pgTAP)', '66666666000122');

insert into public.unidades_fabrica (id, tenant_id, nome, sigla, cidade, uf, cnpj, ativo) values
  ('c1111111-0000-0000-0000-000000000001', 'c1111111-1111-1111-1111-111111111111', 'Unidade A', 'UA', 'Cidade A', 'SP', '55555555000111', true),
  ('c2222222-0000-0000-0000-000000000001', 'c2222222-2222-2222-2222-222222222222', 'Unidade B', 'UB', 'Cidade B', 'RJ', '66666666000122', true);

insert into auth.users (
  instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
  raw_app_meta_data, raw_user_meta_data, created_at, updated_at,
  confirmation_token, email_change, email_change_token_new, recovery_token
) values
  ('00000000-0000-0000-0000-000000000000', 'c1111111-0000-0000-0000-000000000009',
   'authenticated', 'authenticated', 'user.a@eng.pgtap.test',
   extensions.crypt('senha-teste-pgtap', extensions.gen_salt('bf')), now(),
   jsonb_build_object(
     'tenant_id', 'c1111111-1111-1111-1111-111111111111',
     'unidades_autorizadas', jsonb_build_array('c1111111-0000-0000-0000-000000000001')
   ),
   '{}'::jsonb, now(), now(), '', '', '', ''),
  ('00000000-0000-0000-0000-000000000000', 'c2222222-0000-0000-0000-000000000009',
   'authenticated', 'authenticated', 'user.b@eng.pgtap.test',
   extensions.crypt('senha-teste-pgtap', extensions.gen_salt('bf')), now(),
   jsonb_build_object(
     'tenant_id', 'c2222222-2222-2222-2222-222222222222',
     'unidades_autorizadas', jsonb_build_array('c2222222-0000-0000-0000-000000000001')
   ),
   '{}'::jsonb, now(), now(), '', '', '', '');

insert into public.itens (id, tenant_id, codigo, nome, tipo, unidade_medida) values
  ('c1111111-0000-0000-0000-000000000101', 'c1111111-1111-1111-1111-111111111111', 'ITEM-A', 'Item A', 'materia_prima', 'un'),
  ('c2222222-0000-0000-0000-000000000101', 'c2222222-2222-2222-2222-222222222222', 'ITEM-B', 'Item B', 'materia_prima', 'un');

insert into public.produtos_padrao (item_id, formato, largura, altura) values
  ('c1111111-0000-0000-0000-000000000101', 'RET', 1, 1),
  ('c2222222-0000-0000-0000-000000000101', 'RET', 1, 1);

insert into public.familias_construtivas (id, tenant_id, codigo, nome) values
  ('c1111111-0000-0000-0000-000000000201', 'c1111111-1111-1111-1111-111111111111', 'FAM-A', 'Familia A'),
  ('c2222222-0000-0000-0000-000000000201', 'c2222222-2222-2222-2222-222222222222', 'FAM-B', 'Familia B');

insert into public.fichas_tecnicas (id, tenant_id, item_id, status) values
  ('c1111111-0000-0000-0000-000000000301', 'c1111111-1111-1111-1111-111111111111', 'c1111111-0000-0000-0000-000000000101', 'rascunho'),
  ('c2222222-0000-0000-0000-000000000301', 'c2222222-2222-2222-2222-222222222222', 'c2222222-0000-0000-0000-000000000101', 'rascunho');

insert into public.setores (id, tenant_id, unidade_id, nome) values
  ('c1111111-0000-0000-0000-000000000401', 'c1111111-1111-1111-1111-111111111111', 'c1111111-0000-0000-0000-000000000001', 'Setor A'),
  ('c2222222-0000-0000-0000-000000000401', 'c2222222-2222-2222-2222-222222222222', 'c2222222-0000-0000-0000-000000000001', 'Setor B');

insert into public.maquinas (id, tenant_id, unidade_id, setor_id, nome, capacidade_horas_dia) values
  ('c1111111-0000-0000-0000-000000000501', 'c1111111-1111-1111-1111-111111111111', 'c1111111-0000-0000-0000-000000000001', 'c1111111-0000-0000-0000-000000000401', 'Maquina A', 8),
  ('c2222222-0000-0000-0000-000000000501', 'c2222222-2222-2222-2222-222222222222', 'c2222222-0000-0000-0000-000000000001', 'c2222222-0000-0000-0000-000000000401', 'Maquina B', 8);

insert into public.cargos (id, tenant_id, codigo, nome, setor_id, custo_hora, efetivo) values
  ('c1111111-0000-0000-0000-000000000601', 'c1111111-1111-1111-1111-111111111111', 'CARGO-A', 'Cargo A', 'c1111111-0000-0000-0000-000000000401', 10, 1),
  ('c2222222-0000-0000-0000-000000000601', 'c2222222-2222-2222-2222-222222222222', 'CARGO-B', 'Cargo B', 'c2222222-0000-0000-0000-000000000401', 10, 1);

-- -----------------------------------------------------------------------------
-- Sessao autenticada como usuario do Tenant A
-- -----------------------------------------------------------------------------
set local role authenticated;
select set_config(
  'request.jwt.claims',
  jsonb_build_object(
    'sub', 'c1111111-0000-0000-0000-000000000009',
    'role', 'authenticated',
    'app_metadata', jsonb_build_object(
      'tenant_id', 'c1111111-1111-1111-1111-111111111111',
      'unidades_autorizadas', jsonb_build_array('c1111111-0000-0000-0000-000000000001')
    )
  )::text,
  true
);

select is((select count(*)::int from public.itens), 1, 'itens: tenant A enxerga somente o proprio item');
select is((select count(*)::int from public.produtos_padrao), 1, 'produtos_padrao: tenant A enxerga somente o proprio produto (via item_id)');
select is((select count(*)::int from public.familias_construtivas), 1, 'familias_construtivas: tenant A enxerga somente a propria familia');
select is((select count(*)::int from public.fichas_tecnicas), 1, 'fichas_tecnicas: tenant A enxerga somente a propria ficha');
select is((select count(*)::int from public.setores), 1, 'setores: tenant A enxerga somente o proprio setor (tenant + unidade)');
select is((select count(*)::int from public.maquinas), 1, 'maquinas: tenant A enxerga somente a propria maquina (tenant + unidade)');
select is((select count(*)::int from public.cargos), 1, 'cargos: tenant A enxerga somente o proprio cargo');

select throws_ok(
  $$ insert into public.itens (id, tenant_id, codigo, nome, tipo, unidade_medida)
     values ('c9999999-0000-0000-0000-000000000001', 'c2222222-2222-2222-2222-222222222222', 'INV', 'Invasor', 'materia_prima', 'un') $$,
  '42501',
  null::text,
  'itens: INSERT com tenant_id de outro tenant falha (policy WITH CHECK)'
);

select throws_ok(
  $$ insert into public.familias_construtivas (id, tenant_id, codigo, nome)
     values ('c9999999-0000-0000-0000-000000000002', 'c2222222-2222-2222-2222-222222222222', 'INV', 'Invasora') $$,
  '42501',
  null::text,
  'familias_construtivas: INSERT com tenant_id de outro tenant falha (policy WITH CHECK)'
);

select throws_ok(
  $$ insert into public.setores (id, tenant_id, unidade_id, nome)
     values ('c9999999-0000-0000-0000-000000000003', 'c1111111-1111-1111-1111-111111111111',
             'c2222222-0000-0000-0000-000000000001', 'Invasor') $$,
  '42501',
  null::text,
  'setores: INSERT com unidade_id fora de unidades_autorizadas falha mesmo com tenant_id correto'
);

select lives_ok(
  $$ insert into public.setores (id, tenant_id, unidade_id, nome)
     values ('c1111111-0000-0000-0000-000000000402', 'c1111111-1111-1111-1111-111111111111',
             'c1111111-0000-0000-0000-000000000001', 'Setor A2') $$,
  'setores: INSERT com tenant_id e unidade_id corretos e permitido'
);

-- -----------------------------------------------------------------------------
-- Sessao autenticada como usuario do Tenant B (confirma isolamento nos dois
-- sentidos, nao apenas de A para B).
-- -----------------------------------------------------------------------------
select set_config(
  'request.jwt.claims',
  jsonb_build_object(
    'sub', 'c2222222-0000-0000-0000-000000000009',
    'role', 'authenticated',
    'app_metadata', jsonb_build_object(
      'tenant_id', 'c2222222-2222-2222-2222-222222222222',
      'unidades_autorizadas', jsonb_build_array('c2222222-0000-0000-0000-000000000001')
    )
  )::text,
  true
);

select is((select count(*)::int from public.itens where tenant_id = 'c1111111-1111-1111-1111-111111111111'), 0, 'itens: tenant B nao enxerga itens do tenant A');
select is((select count(*)::int from public.familias_construtivas where tenant_id = 'c1111111-1111-1111-1111-111111111111'), 0, 'familias_construtivas: tenant B nao enxerga familias do tenant A');
select is((select count(*)::int from public.fichas_tecnicas where tenant_id = 'c1111111-1111-1111-1111-111111111111'), 0, 'fichas_tecnicas: tenant B nao enxerga fichas do tenant A');
select is((select count(*)::int from public.setores where tenant_id = 'c1111111-1111-1111-1111-111111111111'), 0, 'setores: tenant B nao enxerga setores do tenant A');
select is((select count(*)::int from public.maquinas where tenant_id = 'c1111111-1111-1111-1111-111111111111'), 0, 'maquinas: tenant B nao enxerga maquinas do tenant A');
select is((select count(*)::int from public.cargos where tenant_id = 'c1111111-1111-1111-1111-111111111111'), 0, 'cargos: tenant B nao enxerga cargos do tenant A');
select is((select count(*)::int from public.produtos_padrao where item_id = 'c1111111-0000-0000-0000-000000000101'), 0, 'produtos_padrao: tenant B nao enxerga produto do item do tenant A');

-- -----------------------------------------------------------------------------
-- Fail-closed literal: familias_construtivas nao tem policy de UPDATE/DELETE
-- (alem do bloqueio via trigger) -- confirma "ausencia de policy = acesso
-- negado" tambem por RLS, com throws_ok verificando o codigo 42501.
-- -----------------------------------------------------------------------------
-- DIAGNOSTICO TEMPORARIO (achado 27/08, remover apos investigacao) --------
select diag('DEBUG current_user=' || current_user || ' session_user=' || session_user);
select diag('DEBUG rolbypassrls=' || (select rolbypassrls::text from pg_roles where rolname = current_user));
select diag('DEBUG jwt.claims=' || coalesce(current_setting('request.jwt.claims', true), '<null>'));
select diag('DEBUG grants=' || (select string_agg(privilege_type, ',') from information_schema.role_table_grants where table_name = 'familias_construtivas' and grantee = current_user));
select diag('DEBUG row_count_visivel=' || (select count(*)::text from public.familias_construtivas where tenant_id = 'c2222222-2222-2222-2222-222222222222'));
-- FIM DIAGNOSTICO TEMPORARIO -------------------------------------------------

select throws_ok(
  $$ update public.familias_construtivas set nome = 'Tentativa'
     where tenant_id = 'c2222222-2222-2222-2222-222222222222' $$,
  '42501',
  null::text,
  'familias_construtivas: UPDATE negado para o proprio tenant (sem policy de UPDATE = fail-closed)'
);

reset role;
select * from finish();
rollback;
