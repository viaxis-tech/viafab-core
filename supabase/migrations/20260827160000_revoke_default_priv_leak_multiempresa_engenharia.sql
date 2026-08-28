-- =============================================================================
-- Migration: revoke_default_priv_leak_multiempresa_engenharia
-- Achado 27/08 (docs/registro-execucao.md): engenharia_rls_test.sql, teste
-- "familias_construtivas: UPDATE negado para o proprio tenant" falhava so no
-- CI (GitHub Actions), nunca localmente. Diagnosticado com diag() temporario
-- (commit c38a63e, ja revertido) + inspecao direta via psql:
--
--   local:  familias_construtivas pertence a "postgres" -> grants de
--           authenticated = INSERT,SELECT,TRUNCATE,REFERENCES,TRIGGER
--           (exatamente o que as migrations concedem, nada a mais)
--   CI:     mesma tabela, grants de authenticated = INSERT,SELECT,UPDATE,
--           DELETE,TRUNCATE,REFERENCES,TRIGGER
--
-- Causa raiz: "alter default privileges for role supabase_admin in schema
-- public grant all on tables to authenticated, anon, service_role, postgres"
-- (bootstrap padrao da plataforma Supabase, nao esta em nenhuma migration
-- deste repositorio -- select * from pg_default_acl confirma). Quando uma
-- migration roda como "supabase_admin" (caso do CI / projetos hospedados),
-- toda tabela nova ja nasce com privilegio TOTAL para authenticated/anon,
-- porque o "create table" dispara essa regra de default privileges. Quando
-- roda como "postgres" (caso deste ambiente local ate agora), a tabela nasce
-- sem privilegio nenhum para esses papeis, e so os "grant" explicitos das
-- migrations (20260824130546 e 20260824140300) contam.
--
-- As migrations de RLS ja aplicadas fazem "grant select, insert[, update] ..."
-- mas nunca um "revoke all" antes -- ao contrario de
-- 20260824130446_auditoria_append_only.sql, que ja usa exatamente esse padrao
-- defensivo (comentario da propria migration: "remove QUALQUER privilegio
-- pre-existente e concede de volta apenas o estritamente necessario"). Esta
-- migration aplica o MESMO padrao, retroativamente, as 17 tabelas que
-- ficaram sem ele -- nao e possivel editar as migrations ja aplicadas
-- (docs/conducao-agente-20260825.md 4.5).
--
-- Nao muda nenhuma policy de RLS nem nenhum trigger -- so fecha a brecha de
-- GRANT (camada independente da RLS, mesma logica ja documentada para
-- service_role/auditoria: BYPASSRLS nao afeta REVOKE, e "ausencia de grant"
-- so e fail-closed de verdade quando a ausencia e garantida por REVOKE
-- explicito, nao por sorte de qual role rodou o "create table").
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 20260824130546_rls_fail_closed_policies.sql (core multiempresa) -- todas
-- concedem select+insert+update a authenticated/service_role, exceto tenants
-- (so select+update para authenticated). DELETE nunca e concedido por
-- nenhuma delas.
-- -----------------------------------------------------------------------------
revoke all on table public.tenants from public, anon, authenticated, service_role;
grant select, update on table public.tenants to authenticated;
grant select, insert, update on table public.tenants to service_role;

revoke all on table public.unidades_fabrica from public, anon, authenticated, service_role;
grant select, insert, update on table public.unidades_fabrica to authenticated;
grant select, insert, update on table public.unidades_fabrica to service_role;

revoke all on table public.perfis from public, anon, authenticated, service_role;
grant select, insert, update on table public.perfis to authenticated;
grant select, insert, update on table public.perfis to service_role;

revoke all on table public.usuarios_perfil from public, anon, authenticated, service_role;
grant select, insert, update on table public.usuarios_perfil to authenticated;
grant select, insert, update on table public.usuarios_perfil to service_role;

revoke all on table public.usuarios_unidades_concedidas from public, anon, authenticated, service_role;
grant select, insert, update on table public.usuarios_unidades_concedidas to authenticated;
grant select, insert, update on table public.usuarios_unidades_concedidas to service_role;

revoke all on table public.usuario_atalhos from public, anon, authenticated, service_role;
grant select, insert, update on table public.usuario_atalhos to authenticated;
grant select, insert, update on table public.usuario_atalhos to service_role;

-- -----------------------------------------------------------------------------
-- 20260824140300_engenharia_rls_policies.sql (catalogo de engenharia).
-- familias_construtivas/normas_tecnicas: so select+insert (imutaveis por
-- versionamento, RNF-14 -- UPDATE tambem precisa ser revogado, nao so
-- DELETE). As demais: select+insert+update, DELETE nunca concedido.
-- -----------------------------------------------------------------------------
revoke all on table public.familias_construtivas from public, anon, authenticated, service_role;
grant select, insert on table public.familias_construtivas to authenticated;
grant select, insert on table public.familias_construtivas to service_role;

revoke all on table public.normas_tecnicas from public, anon, authenticated, service_role;
grant select, insert on table public.normas_tecnicas to authenticated;
grant select, insert on table public.normas_tecnicas to service_role;

revoke all on table public.itens from public, anon, authenticated, service_role;
grant select, insert, update on table public.itens to authenticated;
grant select, insert, update on table public.itens to service_role;

revoke all on table public.produtos_padrao from public, anon, authenticated, service_role;
grant select, insert, update on table public.produtos_padrao to authenticated;
grant select, insert, update on table public.produtos_padrao to service_role;

revoke all on table public.fichas_tecnicas from public, anon, authenticated, service_role;
grant select, insert, update on table public.fichas_tecnicas to authenticated;
grant select, insert, update on table public.fichas_tecnicas to service_role;

revoke all on table public.linhas_ficha from public, anon, authenticated, service_role;
grant select, insert, update on table public.linhas_ficha to authenticated;
grant select, insert, update on table public.linhas_ficha to service_role;

revoke all on table public.componentes_gerados from public, anon, authenticated, service_role;
grant select, insert, update on table public.componentes_gerados to authenticated;
grant select, insert, update on table public.componentes_gerados to service_role;

revoke all on table public.roteiros_base from public, anon, authenticated, service_role;
grant select, insert, update on table public.roteiros_base to authenticated;
grant select, insert, update on table public.roteiros_base to service_role;

revoke all on table public.setores from public, anon, authenticated, service_role;
grant select, insert, update on table public.setores to authenticated;
grant select, insert, update on table public.setores to service_role;

revoke all on table public.maquinas from public, anon, authenticated, service_role;
grant select, insert, update on table public.maquinas to authenticated;
grant select, insert, update on table public.maquinas to service_role;

revoke all on table public.cargos from public, anon, authenticated, service_role;
grant select, insert, update on table public.cargos to authenticated;
grant select, insert, update on table public.cargos to service_role;
