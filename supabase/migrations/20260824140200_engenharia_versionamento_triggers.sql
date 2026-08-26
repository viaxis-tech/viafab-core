-- =============================================================================
-- Migration: engenharia_versionamento_triggers
-- Sprint: Banco - catalogo de engenharia e recursos
-- SPEC: 2.1 (RNF-14), 2.3 "Triggers" (trg_versao_familia/trg_versao_norma)
-- =============================================================================
-- Implementa a imutabilidade do catalogo versionado (RNF-14):
--   - familias_construtivas / normas_tecnicas: nunca editadas, sempre nova
--     linha por versao. UPDATE e DELETE de qualquer versao existente falham.
--   - fichas_tecnicas: UPDATE restrito a campos de metadados (status,
--     vigencia_inicio); conteudo (tenant_id/item_id/versao/criado_por) e
--     imutavel apos INSERT. DELETE nunca permitido -- nova versao via INSERT.
--   - linhas_ficha: uma vez que a ficha pai esta 'publicada', a arvore da BOM
--     tambem se torna imutavel (senao seria possivel alterar o conteudo de
--     uma versao publicada por baixo, contornando a regra da propria ficha).
-- Estes triggers valem para QUALQUER papel (inclusive service_role, que possui
-- BYPASSRLS na plataforma Supabase) porque triggers nao sao afetados por RLS.

-- -----------------------------------------------------------------------------
-- Funcoes genericas de bloqueio (reaproveitadas pelas 3 tabelas versionadas)
-- -----------------------------------------------------------------------------
create or replace function public.fn_bloqueia_update_versionado()
returns trigger
language plpgsql
as $fn$
begin
  raise exception using
    errcode = '42501',
    message = format(
      '%s: UPDATE nao permitido em catalogo versionado; nova versao deve ser '
      'criada via INSERT (RNF-14)',
      tg_table_name
    );
end;
$fn$;

create or replace function public.fn_bloqueia_delete_versionado()
returns trigger
language plpgsql
as $fn$
begin
  raise exception using
    errcode = '42501',
    message = format(
      '%s: DELETE nao permitido em catalogo versionado (RNF-14)',
      tg_table_name
    );
end;
$fn$;

-- -----------------------------------------------------------------------------
-- familias_construtivas: calculo automatico de versao + imutabilidade total
-- -----------------------------------------------------------------------------
create or replace function public.fn_versao_familia()
returns trigger
language plpgsql
as $fn$
begin
  select coalesce(max(versao), 0) + 1
    into new.versao
    from public.familias_construtivas
    where tenant_id = new.tenant_id
      and codigo = new.codigo;
  return new;
end;
$fn$;

create trigger trg_versao_familia
  before insert on public.familias_construtivas
  for each row execute function public.fn_versao_familia();

create trigger trg_bloqueia_update_familia
  before update on public.familias_construtivas
  for each row execute function public.fn_bloqueia_update_versionado();

create trigger trg_bloqueia_delete_familia
  before delete on public.familias_construtivas
  for each row execute function public.fn_bloqueia_delete_versionado();

-- -----------------------------------------------------------------------------
-- normas_tecnicas: calculo automatico de versao + imutabilidade total
-- -----------------------------------------------------------------------------
create or replace function public.fn_versao_norma()
returns trigger
language plpgsql
as $fn$
begin
  select coalesce(max(versao), 0) + 1
    into new.versao
    from public.normas_tecnicas
    where tenant_id = new.tenant_id
      and nome = new.nome;
  return new;
end;
$fn$;

create trigger trg_versao_norma
  before insert on public.normas_tecnicas
  for each row execute function public.fn_versao_norma();

create trigger trg_bloqueia_update_norma
  before update on public.normas_tecnicas
  for each row execute function public.fn_bloqueia_update_versionado();

create trigger trg_bloqueia_delete_norma
  before delete on public.normas_tecnicas
  for each row execute function public.fn_bloqueia_delete_versionado();

-- -----------------------------------------------------------------------------
-- fichas_tecnicas: calculo automatico de versao (por item) + UPDATE restrito
-- a metadados + DELETE sempre bloqueado.
-- -----------------------------------------------------------------------------
create or replace function public.fn_versao_ficha()
returns trigger
language plpgsql
as $fn$
begin
  select coalesce(max(versao), 0) + 1
    into new.versao
    from public.fichas_tecnicas
    where tenant_id = new.tenant_id
      and item_id = new.item_id;
  return new;
end;
$fn$;

create trigger trg_versao_ficha
  before insert on public.fichas_tecnicas
  for each row execute function public.fn_versao_ficha();

-- "Metadados" editaveis: status, vigencia_inicio. Conteudo/identidade
-- (tenant_id, item_id, versao, criado_por) e imutavel apos o INSERT.
create or replace function public.fn_bloqueia_conteudo_ficha()
returns trigger
language plpgsql
as $fn$
begin
  if new.tenant_id is distinct from old.tenant_id
     or new.item_id is distinct from old.item_id
     or new.versao is distinct from old.versao
     or new.criado_por is distinct from old.criado_por then
    raise exception using
      errcode = '42501',
      message = 'fichas_tecnicas: UPDATE restrito a campos de metadados '
        '(status, vigencia_inicio); alteracao de conteudo exige nova versao '
        'via INSERT (RNF-14)';
  end if;
  return new;
end;
$fn$;

create trigger trg_ficha_update_restrito
  before update on public.fichas_tecnicas
  for each row execute function public.fn_bloqueia_conteudo_ficha();

create trigger trg_bloqueia_delete_ficha
  before delete on public.fichas_tecnicas
  for each row execute function public.fn_bloqueia_delete_versionado();

-- -----------------------------------------------------------------------------
-- linhas_ficha: a BOM de uma ficha 'publicada' e imutavel (protege a garantia
-- de imutabilidade de fichas_tecnicas contra edicao indireta via suas linhas).
-- -----------------------------------------------------------------------------
create or replace function public.fn_bloqueia_linha_ficha_publicada()
returns trigger
language plpgsql
as $fn$
declare
  v_status public.ficha_status;
  v_ficha_id uuid;
begin
  v_ficha_id := coalesce(new.ficha_id, old.ficha_id);

  select status into v_status
  from public.fichas_tecnicas
  where id = v_ficha_id;

  if v_status = 'publicada' then
    raise exception using
      errcode = '42501',
      message = 'linhas_ficha: BOM de ficha publicada e imutavel; crie nova '
        'versao da ficha (INSERT) antes de alterar as linhas (RNF-14)';
  end if;

  if tg_op = 'DELETE' then
    return old;
  end if;
  return new;
end;
$fn$;

create trigger trg_bloqueia_linha_ficha_publicada
  before insert or update or delete on public.linhas_ficha
  for each row execute function public.fn_bloqueia_linha_ficha_publicada();
