-- =============================================================================
-- Seed: nucleo multiempresa (tenant demo, unidade, perfis, usuario admin)
-- Sprint: Banco - fundacao multiempresa, auditoria e RLS fail-closed
-- SPEC: 2.4 "Seed Data"
-- =============================================================================
-- Executado pelo Supabase CLI (supabase db reset) apos todas as migrations,
-- como superuser (postgres) -- portanto ignora RLS, nao ha necessidade de
-- JWT/claims aqui. Idempotente: uuids fixos + ON CONFLICT permitem rodar
-- multiplas vezes sem duplicar dados.

-- -----------------------------------------------------------------------------
-- Tenant demo
-- -----------------------------------------------------------------------------
insert into public.tenants (id, nome, cnpj, criado_em)
values (
  'a0000000-0000-4000-8000-000000000001',
  'ViaFab Demo',
  '00000000000191',
  now()
)
on conflict (id) do update set
  nome = excluded.nome,
  cnpj = excluded.cnpj;

-- -----------------------------------------------------------------------------
-- Unidade fabril
-- -----------------------------------------------------------------------------
insert into public.unidades_fabrica (id, tenant_id, nome, sigla, cidade, uf, cnpj, ativo)
values (
  'a0000000-0000-4000-8000-000000000002',
  'a0000000-0000-4000-8000-000000000001',
  'Unidade Matriz',
  'MTZ',
  'Sao Paulo',
  'SP',
  '00000000000272',
  true
)
on conflict (id) do update set
  nome = excluded.nome,
  sigla = excluded.sigla,
  cidade = excluded.cidade,
  uf = excluded.uf,
  cnpj = excluded.cnpj,
  ativo = excluded.ativo;

-- -----------------------------------------------------------------------------
-- Perfis padrao (9) com matriz de permissoes por modulo.
-- Modulos = dominios de Edge Function definidos na SPEC 3.1 (pastas de
-- supabase/functions/). Helper local (pg_temp, valido apenas nesta sessao de
-- seed) preenche leitura/escrita=false para modulos nao mencionados, evitando
-- repeticao e garantindo que a matriz sempre venha completa (13 modulos).
-- -----------------------------------------------------------------------------
create or replace function pg_temp.fn_permissoes(p_default boolean, p_overrides jsonb)
returns jsonb
language sql
immutable
as $fn$
  select jsonb_object_agg(
    modulo,
    jsonb_build_object(
      'leitura', coalesce((p_overrides -> modulo ->> 'leitura')::boolean, p_default),
      'escrita', coalesce((p_overrides -> modulo ->> 'escrita')::boolean, p_default)
    )
  )
  from unnest(array[
    'ordens', 'estoque', 'chao_de_fabrica', 'qualidade', 'expedicao',
    'itens_fichas', 'recursos', 'pedidos', 'clientes', 'plano',
    'auditoria_painel', 'ged_orcamento_os', 'unidades_parametros_viasign'
  ]) as modulo;
$fn$;

insert into public.perfis (id, tenant_id, nome, permissoes)
values
  (
    'a0000000-0000-4000-8000-000000000101',
    'a0000000-0000-4000-8000-000000000001',
    'PCP',
    pg_temp.fn_permissoes(false, '{
      "plano": {"leitura": true, "escrita": true},
      "ordens": {"leitura": true, "escrita": true},
      "recursos": {"leitura": true, "escrita": false},
      "estoque": {"leitura": true, "escrita": false},
      "itens_fichas": {"leitura": true, "escrita": false},
      "pedidos": {"leitura": true, "escrita": false}
    }'::jsonb)
  ),
  (
    'a0000000-0000-4000-8000-000000000102',
    'a0000000-0000-4000-8000-000000000001',
    'Engenharia',
    pg_temp.fn_permissoes(false, '{
      "itens_fichas": {"leitura": true, "escrita": true},
      "recursos": {"leitura": true, "escrita": false},
      "plano": {"leitura": true, "escrita": false},
      "ordens": {"leitura": true, "escrita": false}
    }'::jsonb)
  ),
  (
    'a0000000-0000-4000-8000-000000000103',
    'a0000000-0000-4000-8000-000000000001',
    'Almoxarifado',
    pg_temp.fn_permissoes(false, '{
      "estoque": {"leitura": true, "escrita": true},
      "ged_orcamento_os": {"leitura": true, "escrita": false},
      "recursos": {"leitura": true, "escrita": false},
      "ordens": {"leitura": true, "escrita": false}
    }'::jsonb)
  ),
  (
    'a0000000-0000-4000-8000-000000000104',
    'a0000000-0000-4000-8000-000000000001',
    'Operador',
    pg_temp.fn_permissoes(false, '{
      "chao_de_fabrica": {"leitura": true, "escrita": true},
      "ordens": {"leitura": true, "escrita": false}
    }'::jsonb)
  ),
  (
    'a0000000-0000-4000-8000-000000000105',
    'a0000000-0000-4000-8000-000000000001',
    'Qualidade',
    pg_temp.fn_permissoes(false, '{
      "qualidade": {"leitura": true, "escrita": true},
      "ordens": {"leitura": true, "escrita": false},
      "chao_de_fabrica": {"leitura": true, "escrita": false}
    }'::jsonb)
  ),
  (
    'a0000000-0000-4000-8000-000000000106',
    'a0000000-0000-4000-8000-000000000001',
    'Expedicao',
    pg_temp.fn_permissoes(false, '{
      "expedicao": {"leitura": true, "escrita": true},
      "ordens": {"leitura": true, "escrita": false},
      "estoque": {"leitura": true, "escrita": false}
    }'::jsonb)
  ),
  (
    'a0000000-0000-4000-8000-000000000107',
    'a0000000-0000-4000-8000-000000000001',
    'Compras',
    pg_temp.fn_permissoes(false, '{
      "pedidos": {"leitura": true, "escrita": true},
      "clientes": {"leitura": true, "escrita": false},
      "estoque": {"leitura": true, "escrita": false},
      "ged_orcamento_os": {"leitura": true, "escrita": true}
    }'::jsonb)
  ),
  (
    'a0000000-0000-4000-8000-000000000108',
    'a0000000-0000-4000-8000-000000000001',
    'Direcao',
    pg_temp.fn_permissoes(false, '{
      "auditoria_painel": {"leitura": true, "escrita": false},
      "plano": {"leitura": true, "escrita": false},
      "ordens": {"leitura": true, "escrita": false},
      "estoque": {"leitura": true, "escrita": false},
      "pedidos": {"leitura": true, "escrita": false},
      "clientes": {"leitura": true, "escrita": false},
      "qualidade": {"leitura": true, "escrita": false},
      "expedicao": {"leitura": true, "escrita": false}
    }'::jsonb)
  ),
  (
    'a0000000-0000-4000-8000-000000000109',
    'a0000000-0000-4000-8000-000000000001',
    'Admin',
    pg_temp.fn_permissoes(true, '{}'::jsonb)
  )
on conflict (tenant_id, nome) do update set
  permissoes = excluded.permissoes;

-- -----------------------------------------------------------------------------
-- Usuario admin inicial (Supabase Auth), com claims em raw_app_meta_data
-- (NUNCA em raw_user_meta_data, que e editavel pelo proprio usuario).
-- Senha de demonstracao apenas para ambiente local/dev.
-- -----------------------------------------------------------------------------
insert into auth.users (
  instance_id,
  id,
  aud,
  role,
  email,
  encrypted_password,
  email_confirmed_at,
  recovery_sent_at,
  last_sign_in_at,
  raw_app_meta_data,
  raw_user_meta_data,
  created_at,
  updated_at,
  confirmation_token,
  email_change,
  email_change_token_new,
  recovery_token
)
values (
  '00000000-0000-0000-0000-000000000000',
  'a0000000-0000-4000-8000-000000000201',
  'authenticated',
  'authenticated',
  'admin@viafab-demo.test',
  extensions.crypt('ViaFabDemo!2026', extensions.gen_salt('bf')),
  now(),
  null,
  null,
  jsonb_build_object(
    'provider', 'email',
    'providers', jsonb_build_array('email'),
    'tenant_id', 'a0000000-0000-4000-8000-000000000001',
    'perfil_id', 'a0000000-0000-4000-8000-000000000109',
    'unidades_autorizadas', jsonb_build_array('a0000000-0000-4000-8000-000000000002')
  ),
  '{}'::jsonb,
  now(),
  now(),
  '',
  '',
  '',
  ''
)
on conflict (id) do update set
  raw_app_meta_data = excluded.raw_app_meta_data,
  updated_at = now();

insert into auth.identities (
  id,
  provider_id,
  user_id,
  identity_data,
  provider,
  last_sign_in_at,
  created_at,
  updated_at
)
values (
  'a0000000-0000-4000-8000-000000000202',
  'a0000000-0000-4000-8000-000000000201',
  'a0000000-0000-4000-8000-000000000201',
  jsonb_build_object(
    'sub', 'a0000000-0000-4000-8000-000000000201',
    'email', 'admin@viafab-demo.test',
    'email_verified', true
  ),
  'email',
  now(),
  now(),
  now()
)
on conflict (provider_id, provider) do update set
  identity_data = excluded.identity_data,
  updated_at = now();

-- Espelho da claim no nucleo multiempresa (usuarios_perfil) e concessao da
-- unidade fabril demo ao usuario admin.
insert into public.usuarios_perfil (usuario_id, tenant_id, perfil_id, unidades_autorizadas)
values (
  'a0000000-0000-4000-8000-000000000201',
  'a0000000-0000-4000-8000-000000000001',
  'a0000000-0000-4000-8000-000000000109',
  array['a0000000-0000-4000-8000-000000000002']::uuid[]
)
on conflict (usuario_id) do update set
  tenant_id = excluded.tenant_id,
  perfil_id = excluded.perfil_id,
  unidades_autorizadas = excluded.unidades_autorizadas;

insert into public.usuarios_unidades_concedidas (usuario_id, unidade_id, concedido_em, concedido_por)
values (
  'a0000000-0000-4000-8000-000000000201',
  'a0000000-0000-4000-8000-000000000002',
  now(),
  'a0000000-0000-4000-8000-000000000201'
)
on conflict (usuario_id, unidade_id) do nothing;

-- =============================================================================
-- Seed: catalogo de engenharia e recursos
-- Sprint: Banco - catalogo de engenharia e recursos
-- SPEC: 2.4 "Seed Data"
-- =============================================================================
-- Todas as tabelas versionadas (familias_construtivas, normas_tecnicas,
-- fichas_tecnicas) usam `on conflict (id) do nothing` -- nunca `do update` --
-- porque UPDATE nessas tabelas e bloqueado/restrito por trigger (RNF-14,
-- 20260824140200) mesmo para o superuser que roda o seed: o trigger BEFORE
-- UPDATE dispara independente de quem executa o comando. `do nothing` reexecuta
-- o seed de forma idempotente sem jamais tentar um UPDATE nessas linhas.

-- -----------------------------------------------------------------------------
-- Setores (4 basicos: corte, impressao, laminacao, montagem)
-- -----------------------------------------------------------------------------
insert into public.setores (id, tenant_id, unidade_id, nome)
values
  ('a0000000-0000-4000-8000-000000000301', 'a0000000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-000000000002', 'Corte'),
  ('a0000000-0000-4000-8000-000000000302', 'a0000000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-000000000002', 'Impressao'),
  ('a0000000-0000-4000-8000-000000000303', 'a0000000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-000000000002', 'Laminacao'),
  ('a0000000-0000-4000-8000-000000000304', 'a0000000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-000000000002', 'Montagem')
on conflict (id) do update set nome = excluded.nome;

-- -----------------------------------------------------------------------------
-- Maquinas (pelo menos 1 por setor)
-- -----------------------------------------------------------------------------
insert into public.maquinas (id, tenant_id, unidade_id, setor_id, nome, tipo_operacao, capacidade_horas_dia)
values
  ('a0000000-0000-4000-8000-000000000401', 'a0000000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-000000000002', 'a0000000-0000-4000-8000-000000000301', 'Guilhotina 01', 'corte', 8),
  ('a0000000-0000-4000-8000-000000000402', 'a0000000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-000000000002', 'a0000000-0000-4000-8000-000000000302', 'Impressora UV 01', 'impressao', 8),
  ('a0000000-0000-4000-8000-000000000403', 'a0000000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-000000000002', 'a0000000-0000-4000-8000-000000000303', 'Laminadora 01', 'laminacao', 8),
  ('a0000000-0000-4000-8000-000000000404', 'a0000000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-000000000002', 'a0000000-0000-4000-8000-000000000304', 'Bancada de Montagem 01', 'montagem', 8)
on conflict (id) do update set
  nome = excluded.nome,
  tipo_operacao = excluded.tipo_operacao,
  capacidade_horas_dia = excluded.capacidade_horas_dia;

-- -----------------------------------------------------------------------------
-- Cargos (1 por setor, com custo_hora usado por fn_custo_aberto)
-- -----------------------------------------------------------------------------
insert into public.cargos (id, tenant_id, codigo, nome, setor_id, custo_hora, efetivo, observacao)
values
  ('a0000000-0000-4000-8000-000000000501', 'a0000000-0000-4000-8000-000000000001', 'OP-CORTE', 'Operador de Corte', 'a0000000-0000-4000-8000-000000000301', 25.00, 2, null),
  ('a0000000-0000-4000-8000-000000000502', 'a0000000-0000-4000-8000-000000000001', 'OP-IMPR', 'Operador de Impressao', 'a0000000-0000-4000-8000-000000000302', 30.00, 2, null),
  ('a0000000-0000-4000-8000-000000000503', 'a0000000-0000-4000-8000-000000000001', 'OP-LAM', 'Operador de Laminacao', 'a0000000-0000-4000-8000-000000000303', 22.00, 1, null),
  ('a0000000-0000-4000-8000-000000000504', 'a0000000-0000-4000-8000-000000000001', 'OP-MONT', 'Operador de Montagem', 'a0000000-0000-4000-8000-000000000304', 20.00, 2, null)
on conflict (id) do update set
  nome = excluded.nome,
  setor_id = excluded.setor_id,
  custo_hora = excluded.custo_hora,
  efetivo = excluded.efetivo;

-- -----------------------------------------------------------------------------
-- Itens: materias-primas, componentes e produtos de exemplo
-- -----------------------------------------------------------------------------
insert into public.itens (id, tenant_id, codigo, nome, tipo, unidade_medida, categoria, ativo, custo_unitario)
values
  ('a0000000-0000-4000-8000-000000000601', 'a0000000-0000-4000-8000-000000000001', 'MP-CHAPA-AL', 'Chapa de Aluminio', 'materia_prima', 'm2', 'chapas', true, 80.00),
  ('a0000000-0000-4000-8000-000000000602', 'a0000000-0000-4000-8000-000000000001', 'MP-PELIC-I', 'Pelicula Refletiva Tipo I', 'materia_prima', 'm2', 'peliculas', true, 45.00),
  ('a0000000-0000-4000-8000-000000000603', 'a0000000-0000-4000-8000-000000000001', 'MP-TINTA-SER', 'Tinta Serigrafica', 'materia_prima', 'kg', 'tintas', true, 30.00),
  ('a0000000-0000-4000-8000-000000000701', 'a0000000-0000-4000-8000-000000000001', 'CP-QUADRO-CIR', 'Quadro Moldura Circular', 'componente', 'un', 'quadros', true, 12.00),
  ('a0000000-0000-4000-8000-000000000801', 'a0000000-0000-4000-8000-000000000001', 'PR-PLACA-CIR-R1', 'Placa Circular Regulamentacao R-1', 'produto', 'un', 'placas', true, null),
  ('a0000000-0000-4000-8000-000000000802', 'a0000000-0000-4000-8000-000000000001', 'PR-PLACA-RET-I1', 'Placa Retangular Indicativa I-1', 'produto', 'un', 'placas', true, null)
on conflict (tenant_id, codigo) do update set
  nome = excluded.nome,
  tipo = excluded.tipo,
  unidade_medida = excluded.unidade_medida,
  categoria = excluded.categoria,
  ativo = excluded.ativo,
  custo_unitario = excluded.custo_unitario;

-- -----------------------------------------------------------------------------
-- Produtos padrao (1:1 com itens de tipo produto)
-- -----------------------------------------------------------------------------
insert into public.produtos_padrao (item_id, formato, largura, altura, pelicula_fundo, legenda, substrato, instalacao, codigo_da_placa, dimensao_variavel)
values
  ('a0000000-0000-4000-8000-000000000801', 'CIR', 0.60, 0.60, 'refletivo_tipo_i', 'R-1', 'aluminio', 'AR', 'R-1', false),
  ('a0000000-0000-4000-8000-000000000802', 'RET', 1.00, 0.40, 'refletivo_tipo_i', 'I-1', 'aluminio', 'SL', 'I-1', true)
on conflict (item_id) do update set
  formato = excluded.formato,
  largura = excluded.largura,
  altura = excluded.altura,
  pelicula_fundo = excluded.pelicula_fundo,
  legenda = excluded.legenda,
  substrato = excluded.substrato,
  instalacao = excluded.instalacao,
  codigo_da_placa = excluded.codigo_da_placa,
  dimensao_variavel = excluded.dimensao_variavel;

-- -----------------------------------------------------------------------------
-- Familias construtivas (2 exemplos: placa circular de regulamentacao e placa
-- retangular indicativa), com parametros_schema/regras/formula_bom/
-- template_roteiro preenchidos. versao e calculada pelo trigger
-- trg_versao_familia (20260824140200); nao e informada aqui.
-- -----------------------------------------------------------------------------
insert into public.familias_construtivas
  (id, tenant_id, codigo, nome, parametros_schema, regras, formula_bom, template_roteiro, vigencia_inicio)
values
  (
    'a0000000-0000-4000-8000-000000000901',
    'a0000000-0000-4000-8000-000000000001',
    'FCR-01',
    'Placa Circular - Regulamentacao',
    '{
      "diametro_mm": {"tipo": "number", "min": 300, "max": 1000},
      "pelicula": {"tipo": "enum", "valores": ["I", "III", "IV"]}
    }'::jsonb,
    '{
      "area_minima_m2": 0.09,
      "instalacao_padrao": "AR"
    }'::jsonb,
    '{
      "componentes": [
        {"papel": "quadro", "formula_area_m2": "diametro_mm^2 * pi() / 4 / 1000000"},
        {"papel": "sinal", "formula_area_m2": "diametro_mm^2 * pi() / 4 / 1000000"}
      ]
    }'::jsonb,
    '[
      {"sequencia": 1, "operacao": "Corte", "setor": "Corte"},
      {"sequencia": 2, "operacao": "Impressao", "setor": "Impressao"},
      {"sequencia": 3, "operacao": "Laminacao", "setor": "Laminacao"},
      {"sequencia": 4, "operacao": "Montagem", "setor": "Montagem"}
    ]'::jsonb,
    '2026-01-01'
  ),
  (
    'a0000000-0000-4000-8000-000000000902',
    'a0000000-0000-4000-8000-000000000001',
    'FRI-01',
    'Placa Retangular - Indicativa',
    '{
      "largura_mm": {"tipo": "number", "min": 200, "max": 3000},
      "altura_mm": {"tipo": "number", "min": 200, "max": 2000},
      "pelicula": {"tipo": "enum", "valores": ["I", "III", "IV"]}
    }'::jsonb,
    '{
      "area_minima_m2": 0.08,
      "instalacao_padrao": "SL"
    }'::jsonb,
    '{
      "componentes": [
        {"papel": "sinal", "formula_area_m2": "largura_mm * altura_mm / 1000000"}
      ]
    }'::jsonb,
    '[
      {"sequencia": 1, "operacao": "Corte", "setor": "Corte"},
      {"sequencia": 2, "operacao": "Impressao", "setor": "Impressao"},
      {"sequencia": 3, "operacao": "Laminacao", "setor": "Laminacao"}
    ]'::jsonb,
    '2026-01-01'
  )
on conflict (id) do nothing;

-- -----------------------------------------------------------------------------
-- Norma tecnica de exemplo (versionada; on conflict (id) do nothing pelo
-- mesmo motivo das familias construtivas)
-- -----------------------------------------------------------------------------
insert into public.normas_tecnicas (id, tenant_id, nome, fonte, conteudo, vigencia_inicio)
values (
  'a0000000-0000-4000-8000-000000000e01',
  'a0000000-0000-4000-8000-000000000001',
  'CONTRAN - Sinalizacao Vertical',
  'CONTRAN Resolucao 180/2016',
  'Especificacoes de fabricacao de placas de sinalizacao vertical rodoviaria: '
  'dimensoes, cores, peliculas retrorrefletivas e criterios de instalacao.',
  '2026-01-01'
)
on conflict (id) do nothing;

-- -----------------------------------------------------------------------------
-- Roteiro base do produto circular (item 0801): 4 operacoes, tempos em
-- multiplos de 6 min (fracoes exatas de hora, evita dizima na conferencia
-- manual do calculo de mao_de_obra em fn_custo_aberto).
-- -----------------------------------------------------------------------------
insert into public.roteiros_base (id, tenant_id, item_id, sequencia, operacao, setor, maquina_padrao, tempo_padrao_min)
values
  ('a0000000-0000-4000-8000-000000000c01', 'a0000000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-000000000801', 1, 'Corte', 'Corte', 'Guilhotina 01', 12),
  ('a0000000-0000-4000-8000-000000000c02', 'a0000000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-000000000801', 2, 'Impressao', 'Impressao', 'Impressora UV 01', 15),
  ('a0000000-0000-4000-8000-000000000c03', 'a0000000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-000000000801', 3, 'Laminacao', 'Laminacao', 'Laminadora 01', 6),
  ('a0000000-0000-4000-8000-000000000c04', 'a0000000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-000000000801', 4, 'Montagem', 'Montagem', 'Bancada de Montagem 01', 12)
on conflict (id) do update set
  operacao = excluded.operacao,
  setor = excluded.setor,
  maquina_padrao = excluded.maquina_padrao,
  tempo_padrao_min = excluded.tempo_padrao_min;

-- -----------------------------------------------------------------------------
-- Ficha tecnica do produto circular (item 0801), em rascunho: BOM de 2 niveis
-- (linhas_ficha) usada tambem pelo teste pgTAP de fn_custo_aberto. Mantida
-- como 'rascunho' de proposito -- se fosse 'publicada', o trigger
-- trg_bloqueia_linha_ficha_publicada bloquearia a reexecucao idempotente do
-- INSERT das linhas em um novo `supabase db reset` dentro da mesma sessao de
-- testes (o BEFORE INSERT dispara antes do ON CONFLICT DO NOTHING resolver).
-- versao e calculada pelo trigger trg_versao_ficha; nao e informada aqui.
-- -----------------------------------------------------------------------------
insert into public.fichas_tecnicas (id, tenant_id, item_id, status, vigencia_inicio, criado_por)
values (
  'a0000000-0000-4000-8000-000000000a01',
  'a0000000-0000-4000-8000-000000000001',
  'a0000000-0000-4000-8000-000000000801',
  'rascunho',
  '2026-01-01',
  'a0000000-0000-4000-8000-000000000201'
)
on conflict (id) do nothing;

-- Nivel 0: quadro moldura (componente) + tinta (materia-prima) direto na raiz.
-- Nivel 1: chapa de aluminio + pelicula, consumidas dentro do quadro moldura.
insert into public.linhas_ficha (id, ficha_id, componente_item_id, quantidade, nivel, componente_pai_id)
values
  ('a0000000-0000-4000-8000-000000000b01', 'a0000000-0000-4000-8000-000000000a01', 'a0000000-0000-4000-8000-000000000701', 1, 0, null),
  ('a0000000-0000-4000-8000-000000000b02', 'a0000000-0000-4000-8000-000000000a01', 'a0000000-0000-4000-8000-000000000603', 0.05, 0, null),
  ('a0000000-0000-4000-8000-000000000b03', 'a0000000-0000-4000-8000-000000000a01', 'a0000000-0000-4000-8000-000000000601', 0.25, 1, 'a0000000-0000-4000-8000-000000000b01'),
  ('a0000000-0000-4000-8000-000000000b04', 'a0000000-0000-4000-8000-000000000a01', 'a0000000-0000-4000-8000-000000000602', 0.25, 1, 'a0000000-0000-4000-8000-000000000b01')
on conflict (id) do nothing;
