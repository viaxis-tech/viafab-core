-- =============================================================================
-- Migration: fn_custo_aberto
-- Sprint: Banco - catalogo de engenharia e recursos
-- SPEC: 2.1 (data-custo-aberto), 3.1 (api-custo-aberto GET /itens/{itemId}/custo)
-- =============================================================================
-- data-custo-aberto e uma entidade DERIVADA (nao persistida): esta funcao
-- calcula, para um item, o custo somando recursivamente a arvore de
-- linhas_ficha (BOM multinivel) da ficha tecnica vigente do item, mais o
-- tempo/mao de obra do roteiro base do item.
--
-- Decisoes de modelagem (a SPEC 2.1 define as colunas de saida mas nao a
-- formula interna -- "custos_abertos ... calculado somando a arvore da
-- ficha"):
--   - "material": soma, na arvore da BOM, de quantidade_acumulada *
--     itens.custo_unitario para os componentes de tipo 'materia_prima'.
--   - "processo": soma, na mesma arvore, de quantidade_acumulada *
--     itens.custo_unitario para os componentes de tipo 'componente'/'produto'
--     (subitens ja processados/gerados, cujo custo_unitario reflete o
--     processamento embutido) -- distingue "materia bruta" de "processado".
--   - "mao_de_obra": soma, no roteiro base do item raiz, de
--     tempo_padrao_min/60 * cargos.custo_hora, casando roteiros_base.setor
--     (texto) com setores.nome e o(s) cargo(s) vinculados aquele setor.
--   - "tempo_minutos": soma de roteiros_base.tempo_padrao_min do item raiz.
--   - "total": material + processo + mao_de_obra.
--
-- Ficha vigente escolhida: versao 'publicada' mais recente do item; se nao
-- houver nenhuma publicada, cai para a versao mais recente em rascunho.
--
-- security invoker (padrao): a funcao roda com os privilegios/RLS de quem
-- chama, entao o isolamento por tenant e automaticamente respeitado pelas
-- policies das tabelas subjacentes (fichas_tecnicas, linhas_ficha, itens,
-- roteiros_base, setores, cargos) -- nao precisa de logica extra de tenant
-- aqui.
create or replace function public.fn_custo_aberto(p_item_id uuid)
returns table (
  material numeric,
  processo numeric,
  mao_de_obra numeric,
  total numeric,
  tempo_minutos numeric
)
language sql
stable
security invoker
set search_path = ''
as $fn$
  with recursive ficha_alvo as (
    select ft.id
    from public.fichas_tecnicas ft
    where ft.item_id = p_item_id
    order by (ft.status = 'publicada') desc, ft.versao desc
    limit 1
  ),
  arvore as (
    select lf.id, lf.componente_item_id, lf.quantidade as quantidade_acumulada
    from public.linhas_ficha lf
    join ficha_alvo fa on fa.id = lf.ficha_id
    where lf.componente_pai_id is null
    union all
    select lf.id, lf.componente_item_id, lf.quantidade * arvore.quantidade_acumulada
    from public.linhas_ficha lf
    join arvore on lf.componente_pai_id = arvore.id
  ),
  custo_material as (
    select coalesce(sum(a.quantidade_acumulada * coalesce(i.custo_unitario, 0)), 0) as valor
    from arvore a
    join public.itens i on i.id = a.componente_item_id
    where i.tipo = 'materia_prima'
  ),
  custo_processo as (
    select coalesce(sum(a.quantidade_acumulada * coalesce(i.custo_unitario, 0)), 0) as valor
    from arvore a
    join public.itens i on i.id = a.componente_item_id
    where i.tipo in ('componente', 'produto')
  ),
  roteiro as (
    select rb.tempo_padrao_min, rb.setor
    from public.roteiros_base rb
    where rb.item_id = p_item_id
  ),
  custo_mao_de_obra as (
    select coalesce(sum(
      r.tempo_padrao_min / 60.0 * coalesce(cg.custo_hora_medio, 0)
    ), 0) as valor
    from roteiro r
    left join lateral (
      select avg(c.custo_hora) as custo_hora_medio
      from public.cargos c
      join public.setores s on s.id = c.setor_id
      where s.nome = r.setor
    ) cg on true
  ),
  tempo as (
    select coalesce(sum(tempo_padrao_min), 0) as valor from roteiro
  )
  select
    cm.valor as material,
    cp.valor as processo,
    cmo.valor as mao_de_obra,
    (cm.valor + cp.valor + cmo.valor) as total,
    t.valor as tempo_minutos
  from custo_material cm, custo_processo cp, custo_mao_de_obra cmo, tempo t;
$fn$;

comment on function public.fn_custo_aberto(uuid) is
  'Custo aberto (data-custo-aberto) de um item: soma recursiva da arvore de '
  'linhas_ficha (BOM multinivel) da ficha vigente + roteiro base. Entidade '
  'derivada, nao persistida (SPEC 2.1). Usada por api-custo-aberto '
  '(GET /itens/{itemId}/custo).';

grant execute on function public.fn_custo_aberto(uuid) to authenticated;
grant execute on function public.fn_custo_aberto(uuid) to service_role;
