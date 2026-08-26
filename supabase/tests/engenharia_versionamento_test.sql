-- =============================================================================
-- Teste pgTAP: versionamento imutavel do catalogo de engenharia (RNF-14)
-- Sprint: Banco - catalogo de engenharia e recursos
-- SPEC: 2.1 (familias_construtivas/normas_tecnicas/fichas_tecnicas), 2.3
-- ("trg_versao_familia"/"trg_versao_norma")
-- Executar: supabase test db
-- =============================================================================
-- Executado como owner/superuser (bypassa RLS): o foco deste arquivo e o
-- comportamento dos triggers de versionamento/imutabilidade, que valem para
-- qualquer papel (nao dependem de RLS). Isolamento por tenant e coberto em
-- engenharia_rls_test.sql.
begin;
select plan(17);

-- -----------------------------------------------------------------------------
-- Fixtures
-- -----------------------------------------------------------------------------
insert into public.tenants (id, nome, cnpj) values
  ('d1111111-1111-1111-1111-111111111111', 'Tenant Versionamento (pgTAP)', '44444444000177');

insert into public.itens (id, tenant_id, codigo, nome, tipo, unidade_medida) values
  ('d1111111-0000-0000-0000-000000000001', 'd1111111-1111-1111-1111-111111111111', 'MP-TESTE', 'Item de Teste', 'materia_prima', 'un'),
  ('d1111111-0000-0000-0000-000000000002', 'd1111111-1111-1111-1111-111111111111', 'MP-TESTE-2', 'Item de Teste 2', 'materia_prima', 'un');

-- -----------------------------------------------------------------------------
-- familias_construtivas: INSERT de nova linha para o mesmo codigo incrementa
-- versao automaticamente; UPDATE/DELETE de linha existente falham.
-- -----------------------------------------------------------------------------
insert into public.familias_construtivas (id, tenant_id, codigo, nome) values
  ('d1111111-0000-0000-0000-000000000101', 'd1111111-1111-1111-1111-111111111111', 'FAM-TESTE', 'Familia de Teste v1');

select is(
  (select versao from public.familias_construtivas where id = 'd1111111-0000-0000-0000-000000000101'),
  1,
  'familias_construtivas: primeira linha de um codigo novo recebe versao 1'
);

insert into public.familias_construtivas (id, tenant_id, codigo, nome) values
  ('d1111111-0000-0000-0000-000000000102', 'd1111111-1111-1111-1111-111111111111', 'FAM-TESTE', 'Familia de Teste v2');

select is(
  (select versao from public.familias_construtivas where id = 'd1111111-0000-0000-0000-000000000102'),
  2,
  'familias_construtivas: INSERT de nova linha para o mesmo codigo incrementa versao automaticamente (trigger)'
);

select throws_ok(
  $$ update public.familias_construtivas set nome = 'Alterado' where id = 'd1111111-0000-0000-0000-000000000102' $$,
  '42501',
  null::text,
  'familias_construtivas: UPDATE de linha existente falha por trigger (RNF-14)'
);

select throws_ok(
  $$ delete from public.familias_construtivas where id = 'd1111111-0000-0000-0000-000000000102' $$,
  '42501',
  null::text,
  'familias_construtivas: DELETE de linha existente falha por trigger (RNF-14)'
);

-- -----------------------------------------------------------------------------
-- normas_tecnicas: mesmo comportamento, particionado por (tenant_id, nome).
-- -----------------------------------------------------------------------------
insert into public.normas_tecnicas (id, tenant_id, nome, fonte, conteudo) values
  ('d1111111-0000-0000-0000-000000000201', 'd1111111-1111-1111-1111-111111111111', 'Norma de Teste', 'Fonte A', 'Conteudo v1');

select is(
  (select versao from public.normas_tecnicas where id = 'd1111111-0000-0000-0000-000000000201'),
  1,
  'normas_tecnicas: primeira linha de um nome novo recebe versao 1'
);

insert into public.normas_tecnicas (id, tenant_id, nome, fonte, conteudo) values
  ('d1111111-0000-0000-0000-000000000202', 'd1111111-1111-1111-1111-111111111111', 'Norma de Teste', 'Fonte A', 'Conteudo v2');

select is(
  (select versao from public.normas_tecnicas where id = 'd1111111-0000-0000-0000-000000000202'),
  2,
  'normas_tecnicas: INSERT de nova linha para o mesmo nome incrementa versao automaticamente (trigger)'
);

select throws_ok(
  $$ update public.normas_tecnicas set conteudo = 'Alterado' where id = 'd1111111-0000-0000-0000-000000000202' $$,
  '42501',
  null::text,
  'normas_tecnicas: UPDATE de linha existente falha por trigger (RNF-14)'
);

select throws_ok(
  $$ delete from public.normas_tecnicas where id = 'd1111111-0000-0000-0000-000000000202' $$,
  '42501',
  null::text,
  'normas_tecnicas: DELETE de linha existente falha por trigger (RNF-14)'
);

-- -----------------------------------------------------------------------------
-- fichas_tecnicas: versao automatica por item; UPDATE restrito a metadados
-- (status/vigencia_inicio); DELETE sempre bloqueado.
-- -----------------------------------------------------------------------------
insert into public.fichas_tecnicas (id, tenant_id, item_id, status) values
  ('d1111111-0000-0000-0000-000000000301', 'd1111111-1111-1111-1111-111111111111', 'd1111111-0000-0000-0000-000000000001', 'rascunho');

select is(
  (select versao from public.fichas_tecnicas where id = 'd1111111-0000-0000-0000-000000000301'),
  1,
  'fichas_tecnicas: primeira ficha de um item recebe versao 1'
);

insert into public.fichas_tecnicas (id, tenant_id, item_id, status) values
  ('d1111111-0000-0000-0000-000000000302', 'd1111111-1111-1111-1111-111111111111', 'd1111111-0000-0000-0000-000000000001', 'rascunho');

select is(
  (select versao from public.fichas_tecnicas where id = 'd1111111-0000-0000-0000-000000000302'),
  2,
  'fichas_tecnicas: INSERT de nova ficha para o mesmo item incrementa versao automaticamente (trigger)'
);

select lives_ok(
  $$ update public.fichas_tecnicas set status = 'publicada', vigencia_inicio = current_date
     where id = 'd1111111-0000-0000-0000-000000000302' $$,
  'fichas_tecnicas: UPDATE de metadados (status/vigencia_inicio) e permitido'
);

select throws_ok(
  $$ update public.fichas_tecnicas set item_id = 'd1111111-0000-0000-0000-000000000002'
     where id = 'd1111111-0000-0000-0000-000000000302' $$,
  '42501',
  null::text,
  'fichas_tecnicas: UPDATE de conteudo (item_id) e negado; nova versao exige INSERT'
);

select throws_ok(
  $$ delete from public.fichas_tecnicas where id = 'd1111111-0000-0000-0000-000000000302' $$,
  '42501',
  null::text,
  'fichas_tecnicas: DELETE nunca e permitido (RNF-14)'
);

-- -----------------------------------------------------------------------------
-- linhas_ficha: BOM editavel enquanto a ficha esta em rascunho; imutavel
-- assim que a ficha e publicada.
-- -----------------------------------------------------------------------------
select lives_ok(
  $$ insert into public.linhas_ficha (id, ficha_id, componente_item_id, quantidade, nivel)
     values ('d1111111-0000-0000-0000-000000000401', 'd1111111-0000-0000-0000-000000000301',
             'd1111111-0000-0000-0000-000000000002', 1, 0) $$,
  'linhas_ficha: INSERT permitido enquanto a ficha pai esta em rascunho'
);

update public.fichas_tecnicas set status = 'publicada'
where id = 'd1111111-0000-0000-0000-000000000301';

select throws_ok(
  $$ insert into public.linhas_ficha (id, ficha_id, componente_item_id, quantidade, nivel)
     values ('d1111111-0000-0000-0000-000000000402', 'd1111111-0000-0000-0000-000000000301',
             'd1111111-0000-0000-0000-000000000002', 1, 0) $$,
  '42501',
  null::text,
  'linhas_ficha: INSERT negado apos a ficha pai ser publicada'
);

select throws_ok(
  $$ update public.linhas_ficha set quantidade = 2
     where id = 'd1111111-0000-0000-0000-000000000401' $$,
  '42501',
  null::text,
  'linhas_ficha: UPDATE negado apos a ficha pai ser publicada'
);

select throws_ok(
  $$ delete from public.linhas_ficha where id = 'd1111111-0000-0000-0000-000000000401' $$,
  '42501',
  null::text,
  'linhas_ficha: DELETE negado apos a ficha pai ser publicada'
);

select * from finish();
rollback;
