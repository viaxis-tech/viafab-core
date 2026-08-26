-- =============================================================================
-- Migration: engenharia_catalogo_tables
-- Sprint: Banco - catalogo de engenharia e recursos
-- SPEC: 2.1 "Catalogo de engenharia"
-- =============================================================================
-- Cria as tabelas do catalogo de engenharia: familias construtivas e normas
-- tecnicas (versionadas de forma imutavel, RNF-14), itens, produtos padrao,
-- componentes gerados, fichas tecnicas (BOM multinivel) e roteiros base.
-- Triggers de versionamento/imutabilidade e RLS sao habilitados em migrations
-- separadas (20260824140200 e 20260824140300), mantendo a mesma separacao de
-- responsabilidades adotada na sprint anterior (schema vs. politica de acesso).

-- -----------------------------------------------------------------------------
-- Tipos enumerados (apenas onde a SPEC 2.1 define a lista fechada de valores)
-- -----------------------------------------------------------------------------
do $$ begin
  create type public.item_tipo as enum ('materia_prima', 'componente', 'produto');
exception when duplicate_object then null;
end $$;

do $$ begin
  create type public.ficha_status as enum ('rascunho', 'publicada');
exception when duplicate_object then null;
end $$;

do $$ begin
  create type public.componente_papel as enum ('corte', 'quadro', 'sinal', 'recorte', 'fix');
exception when duplicate_object then null;
end $$;

do $$ begin
  create type public.produto_formato as enum ('CIR', 'LOS', 'OCT', 'TRI', 'RET', 'MA', 'MP', 'MQ', 'IND');
exception when duplicate_object then null;
end $$;

do $$ begin
  create type public.produto_instalacao as enum ('SL', 'AR');
exception when duplicate_object then null;
end $$;

-- -----------------------------------------------------------------------------
-- familias_construtivas
-- -----------------------------------------------------------------------------
-- Catalogo versionado e imutavel (RNF-14): nova versao sempre via INSERT.
-- versao e calculada automaticamente por trigger (20260824140200); nunca deve
-- ser informada manualmente pelo cliente.
create table if not exists public.familias_construtivas (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants (id) on delete cascade,
  codigo text not null,
  nome text not null,
  parametros_schema jsonb not null default '{}'::jsonb,
  regras jsonb not null default '{}'::jsonb,
  formula_bom jsonb not null default '{}'::jsonb,
  template_roteiro jsonb not null default '{}'::jsonb,
  versao int not null default 1,
  vigencia_inicio date not null default current_date,
  criado_em timestamptz not null default now(),
  constraint familias_construtivas_tenant_codigo_versao_unique
    unique (tenant_id, codigo, versao)
);

create index if not exists idx_familias_construtivas_tenant_codigo
  on public.familias_construtivas (tenant_id, codigo);

comment on table public.familias_construtivas is
  'Familias construtivas (parametros, regras, formula de BOM e template de '
  'roteiro) versionadas de forma imutavel: nova linha por versao, sem UPDATE/'
  'DELETE de versoes existentes (RNF-14). SPEC 2.1.';

-- -----------------------------------------------------------------------------
-- normas_tecnicas
-- -----------------------------------------------------------------------------
create table if not exists public.normas_tecnicas (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants (id) on delete cascade,
  nome text not null,
  fonte text not null,
  conteudo text not null,
  versao int not null default 1,
  vigencia_inicio date not null default current_date,
  constraint normas_tecnicas_tenant_nome_versao_unique
    unique (tenant_id, nome, versao)
);

create index if not exists idx_normas_tecnicas_tenant_nome
  on public.normas_tecnicas (tenant_id, nome);

comment on table public.normas_tecnicas is
  'Normas tecnicas versionadas de forma imutavel: nova linha por versao, sem '
  'UPDATE/DELETE de versoes existentes (RNF-14). SPEC 2.1.';

-- -----------------------------------------------------------------------------
-- itens (data-item)
-- -----------------------------------------------------------------------------
create table if not exists public.itens (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants (id) on delete cascade,
  codigo text not null,
  nome text not null,
  tipo public.item_tipo not null,
  unidade_medida text not null,
  categoria text,
  ativo boolean not null default true,
  -- Extensao necessaria (nao listada literalmente na SPEC 2.1) para viabilizar
  -- o calculo de custo de material em fn_custo_aberto (20260824140400): sem um
  -- custo unitario de referencia por item nao ha como somar "material" na
  -- arvore da ficha. Coluna aditiva, nullable, nao remove/renomeia nenhum
  -- campo especificado -- nao quebra contratos de Edge Functions futuras.
  custo_unitario numeric,
  constraint itens_tenant_codigo_unique unique (tenant_id, codigo)
);

create index if not exists idx_itens_tenant_id on public.itens (tenant_id);
create index if not exists idx_itens_tenant_tipo on public.itens (tenant_id, tipo);

comment on table public.itens is
  'Itens do catalogo de engenharia (materia_prima|componente|produto). SPEC 2.1.';
comment on column public.itens.custo_unitario is
  'Custo unitario de referencia usado por fn_custo_aberto para o componente '
  '"material" do custo aberto. Extensao aditiva a SPEC 2.1 (ver comentario da '
  'tabela).';

-- -----------------------------------------------------------------------------
-- produtos_padrao (data-produto-padrao, data-area-produto)
-- -----------------------------------------------------------------------------
-- Relacionamento 1:1 com itens (SPEC 2.5: "itens 1---1 produtos_padrao"):
-- item_id e a propria chave primaria.
create table if not exists public.produtos_padrao (
  item_id uuid primary key references public.itens (id) on delete cascade,
  formato public.produto_formato not null,
  largura numeric not null,
  altura numeric not null,
  pelicula_fundo text,
  legenda text,
  substrato text,
  instalacao public.produto_instalacao,
  codigo_da_placa text,
  area numeric generated always as (largura * altura) stored,
  dimensao_variavel boolean not null default false
);

comment on table public.produtos_padrao is
  'Especificacao de produtos padrao (formato, dimensoes, peliculas). area e '
  'coluna gerada (largura x altura), data-area-produto. SPEC 2.1.';

-- -----------------------------------------------------------------------------
-- fichas_tecnicas (data-ficha)
-- -----------------------------------------------------------------------------
-- Catalogo versionado (RNF-14): UPDATE restrito a campos de metadados
-- (status, vigencia_inicio); conteudo (item_id/versao) e imutavel apos INSERT
-- -- ver trigger trg_ficha_update_restrito (20260824140200).
create table if not exists public.fichas_tecnicas (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants (id) on delete cascade,
  item_id uuid not null references public.itens (id) on delete cascade,
  versao int not null default 1,
  status public.ficha_status not null default 'rascunho',
  vigencia_inicio date,
  criado_por uuid references auth.users (id),
  constraint fichas_tecnicas_tenant_item_versao_unique
    unique (tenant_id, item_id, versao)
);

create index if not exists idx_fichas_tecnicas_tenant_item
  on public.fichas_tecnicas (tenant_id, item_id);

comment on table public.fichas_tecnicas is
  'Fichas tecnicas (cabecalho da BOM) por item, versionadas: nova versao '
  'sempre via INSERT; UPDATE em ficha existente restrito a metadados '
  '(status/vigencia_inicio). SPEC 2.1.';

-- -----------------------------------------------------------------------------
-- linhas_ficha (data-linha-ficha) -- arvore multinivel da BOM (US-02)
-- -----------------------------------------------------------------------------
create table if not exists public.linhas_ficha (
  id uuid primary key default gen_random_uuid(),
  ficha_id uuid not null references public.fichas_tecnicas (id) on delete cascade,
  componente_item_id uuid not null references public.itens (id),
  quantidade numeric not null,
  nivel int not null default 0,
  componente_pai_id uuid references public.linhas_ficha (id) on delete cascade
);

create index if not exists idx_linhas_ficha_ficha_id
  on public.linhas_ficha (ficha_id);
create index if not exists idx_linhas_ficha_componente_pai_id
  on public.linhas_ficha (componente_pai_id);
create index if not exists idx_linhas_ficha_componente_item_id
  on public.linhas_ficha (componente_item_id);

comment on table public.linhas_ficha is
  'Linhas da BOM de uma ficha tecnica, em arvore multinivel via self-fk '
  'componente_pai_id (nullable) + coluna nivel. SPEC 2.1 (US-02).';

-- -----------------------------------------------------------------------------
-- componentes_gerados (data-componente-gerado)
-- -----------------------------------------------------------------------------
create table if not exists public.componentes_gerados (
  id uuid primary key default gen_random_uuid(),
  item_id uuid not null references public.itens (id) on delete cascade,
  cod text not null,
  nome text not null,
  papel public.componente_papel not null,
  ficha_base_id uuid references public.fichas_tecnicas (id),
  dimensao text,
  fator_area numeric
);

create index if not exists idx_componentes_gerados_item_id
  on public.componentes_gerados (item_id);
create index if not exists idx_componentes_gerados_ficha_base_id
  on public.componentes_gerados (ficha_base_id);

comment on table public.componentes_gerados is
  'Componentes gerados a partir de um item (papel: corte|quadro|sinal|'
  'recorte|fix). SPEC 2.1.';

-- -----------------------------------------------------------------------------
-- roteiros_base (data-roteiro-base)
-- -----------------------------------------------------------------------------
create table if not exists public.roteiros_base (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants (id) on delete cascade,
  item_id uuid not null references public.itens (id) on delete cascade,
  sequencia int not null,
  operacao text not null,
  setor text,
  maquina_padrao text,
  tempo_padrao_min numeric not null default 0,
  constraint roteiros_base_tenant_item_sequencia_unique
    unique (tenant_id, item_id, sequencia)
);

create index if not exists idx_roteiros_base_tenant_item
  on public.roteiros_base (tenant_id, item_id);

comment on table public.roteiros_base is
  'Roteiro base (sequencia de operacoes) padrao por item. SPEC 2.1.';
