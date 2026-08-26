-- =============================================================================
-- Teste pgTAP: fn_custo_aberto com ficha de 2 niveis
-- Sprint: Banco - catalogo de engenharia e recursos
-- SPEC: 2.1 (data-custo-aberto / fn_custo_aberto)
-- Executar: supabase test db
-- =============================================================================
-- Fixtures proprios (independentes do seed.sql) para nao acoplar o teste a
-- mudancas futuras nos dados de exemplo. Executado como owner/superuser
-- (bypassa RLS) -- fn_custo_aberto e security invoker, entao em producao o
-- isolamento por tenant vem das policies das tabelas subjacentes; aqui o
-- foco e exclusivamente a aritmetica do calculo recursivo.
begin;
select plan(7);

-- -----------------------------------------------------------------------------
-- Tenant, unidade e recursos (setores/cargos) usados no roteiro base.
-- -----------------------------------------------------------------------------
insert into public.tenants (id, nome, cnpj) values
  ('b1111111-1111-1111-1111-111111111111', 'Tenant Custo Aberto (pgTAP)', '77777777000133');

insert into public.unidades_fabrica (id, tenant_id, nome, sigla, cidade, uf, cnpj, ativo) values
  ('b1111111-0000-0000-0000-000000000001', 'b1111111-1111-1111-1111-111111111111', 'Unidade Teste', 'UT', 'Cidade T', 'SP', '77777777000133', true);

insert into public.setores (id, tenant_id, unidade_id, nome) values
  ('b1111111-0000-0000-0000-000000000301', 'b1111111-1111-1111-1111-111111111111', 'b1111111-0000-0000-0000-000000000001', 'Corte'),
  ('b1111111-0000-0000-0000-000000000302', 'b1111111-1111-1111-1111-111111111111', 'b1111111-0000-0000-0000-000000000001', 'Impressao'),
  ('b1111111-0000-0000-0000-000000000303', 'b1111111-1111-1111-1111-111111111111', 'b1111111-0000-0000-0000-000000000001', 'Laminacao'),
  ('b1111111-0000-0000-0000-000000000304', 'b1111111-1111-1111-1111-111111111111', 'b1111111-0000-0000-0000-000000000001', 'Montagem');

insert into public.cargos (id, tenant_id, codigo, nome, setor_id, custo_hora, efetivo) values
  ('b1111111-0000-0000-0000-000000000501', 'b1111111-1111-1111-1111-111111111111', 'OP-CORTE', 'Operador Corte', 'b1111111-0000-0000-0000-000000000301', 25, 1),
  ('b1111111-0000-0000-0000-000000000502', 'b1111111-1111-1111-1111-111111111111', 'OP-IMPR', 'Operador Impressao', 'b1111111-0000-0000-0000-000000000302', 30, 1),
  ('b1111111-0000-0000-0000-000000000503', 'b1111111-1111-1111-1111-111111111111', 'OP-LAM', 'Operador Laminacao', 'b1111111-0000-0000-0000-000000000303', 22, 1),
  ('b1111111-0000-0000-0000-000000000504', 'b1111111-1111-1111-1111-111111111111', 'OP-MONT', 'Operador Montagem', 'b1111111-0000-0000-0000-000000000304', 20, 1);

-- -----------------------------------------------------------------------------
-- Itens: 3 materias-primas + 1 componente (nivel 1) + 1 produto (raiz).
-- -----------------------------------------------------------------------------
insert into public.itens (id, tenant_id, codigo, nome, tipo, unidade_medida, custo_unitario) values
  ('b1111111-0000-0000-0000-000000000601', 'b1111111-1111-1111-1111-111111111111', 'MP-CHAPA', 'Chapa Aluminio', 'materia_prima', 'm2', 80),
  ('b1111111-0000-0000-0000-000000000602', 'b1111111-1111-1111-1111-111111111111', 'MP-PELIC', 'Pelicula Refletiva', 'materia_prima', 'm2', 45),
  ('b1111111-0000-0000-0000-000000000603', 'b1111111-1111-1111-1111-111111111111', 'MP-TINTA', 'Tinta Serigrafica', 'materia_prima', 'kg', 30),
  ('b1111111-0000-0000-0000-000000000701', 'b1111111-1111-1111-1111-111111111111', 'CP-QUADRO', 'Quadro Moldura', 'componente', 'un', 12),
  ('b1111111-0000-0000-0000-000000000801', 'b1111111-1111-1111-1111-111111111111', 'PR-PLACA', 'Placa Teste', 'produto', 'un', null);

-- -----------------------------------------------------------------------------
-- Roteiro base do item raiz: 4 operacoes, tempo total 45 min.
-- -----------------------------------------------------------------------------
insert into public.roteiros_base (id, tenant_id, item_id, sequencia, operacao, setor, tempo_padrao_min) values
  ('b1111111-0000-0000-0000-000000000c01', 'b1111111-1111-1111-1111-111111111111', 'b1111111-0000-0000-0000-000000000801', 1, 'Corte', 'Corte', 12),
  ('b1111111-0000-0000-0000-000000000c02', 'b1111111-1111-1111-1111-111111111111', 'b1111111-0000-0000-0000-000000000801', 2, 'Impressao', 'Impressao', 15),
  ('b1111111-0000-0000-0000-000000000c03', 'b1111111-1111-1111-1111-111111111111', 'b1111111-0000-0000-0000-000000000801', 3, 'Laminacao', 'Laminacao', 6),
  ('b1111111-0000-0000-0000-000000000c04', 'b1111111-1111-1111-1111-111111111111', 'b1111111-0000-0000-0000-000000000801', 4, 'Montagem', 'Montagem', 12);

-- -----------------------------------------------------------------------------
-- Ficha tecnica (rascunho) com BOM de 2 niveis:
--   nivel 0: Quadro Moldura (qtd 1) + Tinta (qtd 0.05)
--   nivel 1 (filhos do Quadro): Chapa Aluminio (qtd 0.25) + Pelicula (qtd 0.25)
-- -----------------------------------------------------------------------------
insert into public.fichas_tecnicas (id, tenant_id, item_id, status) values
  ('b1111111-0000-0000-0000-000000000a01', 'b1111111-1111-1111-1111-111111111111', 'b1111111-0000-0000-0000-000000000801', 'rascunho');

insert into public.linhas_ficha (id, ficha_id, componente_item_id, quantidade, nivel, componente_pai_id) values
  ('b1111111-0000-0000-0000-000000000b01', 'b1111111-0000-0000-0000-000000000a01', 'b1111111-0000-0000-0000-000000000701', 1, 0, null),
  ('b1111111-0000-0000-0000-000000000b02', 'b1111111-0000-0000-0000-000000000a01', 'b1111111-0000-0000-0000-000000000603', 0.05, 0, null),
  ('b1111111-0000-0000-0000-000000000b03', 'b1111111-0000-0000-0000-000000000a01', 'b1111111-0000-0000-0000-000000000601', 0.25, 1, 'b1111111-0000-0000-0000-000000000b01'),
  ('b1111111-0000-0000-0000-000000000b04', 'b1111111-0000-0000-0000-000000000a01', 'b1111111-0000-0000-0000-000000000602', 0.25, 1, 'b1111111-0000-0000-0000-000000000b01');

-- -----------------------------------------------------------------------------
-- Calculo esperado:
--   material  = 0.25*80 (chapa) + 0.25*45 (pelicula) + 0.05*30 (tinta)
--             = 20 + 11.25 + 1.5 = 32.75
--   processo  = 1*12 (quadro, nivel 0, tipo componente) = 12.00
--   mao_de_obra = 12/60*25 + 15/60*30 + 6/60*22 + 12/60*20
--               = 5 + 7.5 + 2.2 + 4 = 18.70
--   total     = 32.75 + 12.00 + 18.70 = 63.45
--   tempo_minutos = 12 + 15 + 6 + 12 = 45
-- -----------------------------------------------------------------------------
select is(
  (select count(*)::int from public.fn_custo_aberto('b1111111-0000-0000-0000-000000000801')),
  1,
  'fn_custo_aberto: retorna exatamente 1 linha para o item raiz'
);

select is(
  (select material from public.fn_custo_aberto('b1111111-0000-0000-0000-000000000801')),
  32.75::numeric,
  'fn_custo_aberto: material soma corretamente as materias-primas da arvore (2 niveis)'
);

select is(
  (select processo from public.fn_custo_aberto('b1111111-0000-0000-0000-000000000801')),
  12.00::numeric,
  'fn_custo_aberto: processo soma corretamente os componentes/produtos da arvore'
);

select is(
  (select mao_de_obra from public.fn_custo_aberto('b1111111-0000-0000-0000-000000000801')),
  18.70::numeric,
  'fn_custo_aberto: mao_de_obra soma corretamente tempo x custo_hora por setor do roteiro'
);

select is(
  (select tempo_minutos from public.fn_custo_aberto('b1111111-0000-0000-0000-000000000801')),
  45::numeric,
  'fn_custo_aberto: tempo_minutos soma o tempo_padrao_min do roteiro base'
);

select is(
  (select total from public.fn_custo_aberto('b1111111-0000-0000-0000-000000000801')),
  63.45::numeric,
  'fn_custo_aberto: total = material + processo + mao_de_obra'
);

select is(
  (select count(*)::int from public.fn_custo_aberto('00000000-0000-4000-8000-000000000000')),
  1,
  'fn_custo_aberto: item sem ficha/roteiro ainda retorna 1 linha com valores zerados (nao falha)'
);

select * from finish();
rollback;
