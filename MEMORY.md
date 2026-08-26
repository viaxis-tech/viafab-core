# MEMORY — ViaFab Core

> Estado vivo do projeto. Máx. 200 linhas. Atualizado ao fim de cada sessão, conforme `docs/conducao-agente-20260825.md` §6.
> Board de execução (WP a WP) fica em `docs/registro-execucao.md`, não aqui.

**Atualizado em:** 25/08/2026

---

## O que é

ERP verticalizado para fabricação de sinalização viária, segundo produto do ecossistema Viaxis (o primeiro é o ViaSign). Módulos independentes e vendáveis em separado, que comunicam o ciclo de vida dos itens pelo ecossistema.

Princípio de domínio cravado: sinalização vertical é **paramétrica**. Famílias construtivas e regras reutilizáveis resolvem a BOM e o roteiro de cada placa por geometria, dimensões, materiais, processo e conteúdo. Nunca um produto fixo por placa customizada.

## Onde o projeto está

- **Fase 0** (decisões de produto) — concluída em 24/08. 13 decisões: 9 aceitas, 4 adiadas (D-07, D-08, D-10, D-13). Registro: `docs/decisoes-fase0-20260824.md`.
- **Fase 1** (correção dos 22 P0 do protótipo) — código entregue em 24/08 pelo pipeline `viafab-core1`; 12 sprints, 43 features, SPEC 35/35 itens resolvidos, tudo dentro de `prototype/index.html`. **Encerramento formal pendente da ata de WP-0.3.**
- **Etapa 0** (fundação de engenharia) — em execução desde 25/08. Ver board.
- **Etapas 1 a 5** — não iniciadas. O portão de arquitetura é a Etapa 4 e é gate duro.

## Fronteira protótipo × backend

Os dois lados existem e **não se falam**, por decisão, não por lacuna:

- `prototype/index.html` (single-file, ~26k linhas, sem build) opera 100% sobre o objeto `DB` em memória mais `localStorage`. Zero `fetch`, zero `supabase-js`. `audit()` é função JS local, não INSERT em tabela.
- `supabase/` tem 9 migrations aplicáveis, 18 tabelas em `public`, RLS fail-closed com `force row level security` e policies em migration separada, 5 suítes pgTAP. Nenhuma Edge Function existe.

Ligar um ao outro é a Etapa 5, e só depois dos ADRs da Etapa 4 aprovados.

## Decisões que não se reabrem

- D-01 a D-13 (Fase 0), S6–S9/11 (sprints) e D1–D4 (plano de 25/08) são cravadas. Se a execução mostrar que uma é inviável, escalar com evidência — nunca contornar em silêncio.
- **Q1 resolvida em 25/08: CI sim**, GitHub Actions mínimo.
- O protótipo é o cliente em evolução, não descartável. A decisão entre mantê-lo single-file ou migrar para React 19 + Vite (Q6) fica para o portão, e nada do investimento das Etapas 0–3 se perde nas duas hipóteses.
- `seeds.json` é vocabulário de domínio (dump real de MRP: materiais, componentes, produtos), **não** requisito de schema.
- Design lock: `docs/Docs20260820_134109/design/artifact.html` e `design-contract.json` são intocáveis (travados por SHA-256). Mudança de UI exige revisão formal do lock.

## Decisões pendentes do dono do produto

Q2 (forma da compensação, sai do WP-1.4) · Q3 (significado de MA/MP/MQ) · Q4 (contrato ViaSign: D-08/D-10/D-13 + ADR-012) · Q5 (fórmula autoritativa do custo aberto) · Q6 (shell do produto final). Detalhe e trava de cada uma no board.

Q3 e Q4 têm a maior latência externa — Q4 depende de reunião com o time ViaSign. Agendar cedo.

## Armadilhas conhecidas

- **Numeração de US colide** entre os documentos da raiz (`PRD.md`, `stories-requisitos.md`, escopo ERP completo, US-01..33) e os do pipeline de 24/08 (escopo Fase 0+1, US-01..28). Toda citação precisa dizer a rodada. Aviso já cravado no topo dos dois documentos da raiz.
- **O design-contract embutido no `index.html`** (`:3187`, `:14186`) é cópia congelada e já diverge do CSS vivo em `text-on-accent`. Não é fonte para estilização nova.
- **`prototype/index.html` é arquivo único gigante**: editar função compartilhada (`renderOrdem`, `audit()`, `a11yTabelas()`) respinga em módulos não relacionados. Daí os testes de caracterização virem antes de qualquer refatoração.
- O protótipo é servido por HTTP na porta 8931 (`.claude/launch.json`). Depois de D1, `file://` não funciona — é pré-condição, não defeito.

## Dívidas registradas

- Bug ativo de saldo em `prototype/index.html:17037` (sem clamp/arredondamento). Endereçado por WP-1.3; o teste da invariante deve **reprovar** até a correção via guardião.
- `fn_versao_*` calcula `max+1` sem lock: INSERT concorrente falha na unique. Falha segura; destino é o ADR de concorrência da Etapa 4.
- Divergência de fórmula do custo aberto entre JS e SQL (o JS aplica fator de perda em toda a BOM e trata "processo" como hora-máquina; o SQL não aplica perda e trata como custo de componentes). Q5 decide qual é autoridade; nenhuma tela consome o endpoint antes disso.

## Mapa de documentos

| Documento | Papel |
|---|---|
| `docs/plano-implementacao-20260825.md` | O quê, em que ordem, com que critério de aceite |
| `docs/conducao-agente-20260825.md` | Como conduzir: rituais, guardrails, o que escala |
| `docs/registro-execucao.md` | Board vivo, WP a WP, com evidências |
| `docs/Docs20260824_151851/` | PRD e SPEC vigentes da Fase 0+1 |
| `docs/Docs20260820_134109/` | SPEC do produto completo (modelo de dados e API da Etapa 5) + design lock |
| `docs/decisoes-fase0-20260824.md` | Registro das 13 decisões de produto |
| `docs/auditoria-design-20260823.md` | Lista de riscos e decisões abertas de design |
| `docs/arquivo/` | Superseded, somente leitura |
| `PRD.md`, `stories-requisitos.md` (raiz) | Escopo ERP completo, numeração distinta |

Documentos datados de rodadas anteriores (`docs/Docs*`, `.lionclaw/`) são registro: somente leitura, nunca editar.
