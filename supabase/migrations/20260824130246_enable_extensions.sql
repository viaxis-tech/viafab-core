-- =============================================================================
-- Migration: enable_extensions
-- Sprint: Banco - fundacao multiempresa, auditoria e RLS fail-closed
-- SPEC: 3.1 (estrutura supabase/migrations) e 2.1 (uso de uuid/jsonb nas tabelas)
-- =============================================================================
-- Extensoes necessarias para geracao de uuid (pgcrypto.gen_random_uuid /
-- uuid-ossp.uuid_generate_v4), criptografia auxiliar (pgcrypto.crypt/gen_salt
-- usada no seed do usuario admin) e a suite de testes pgTAP desta sprint.

create schema if not exists extensions;

create extension if not exists "pgcrypto" with schema extensions;
create extension if not exists "uuid-ossp" with schema extensions;
create extension if not exists "pgtap" with schema extensions;
