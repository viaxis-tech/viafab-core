# Instrução de Condução por Agente — ViaFab Core

**Data:** 25/08/2026
**Para quem:** qualquer agente (sessão Claude Code ou equivalente) que execute trabalho neste repositório a partir desta data.
**Divisão de papéis entre documentos:** o plano (`docs/plano-implementacao-20260825.md`) define **o que** fazer, **em que ordem** e **com que critério de aceite**. Este documento define **como conduzir**: rituais, guardrails, o que o agente decide sozinho, o que escala, e como registrar progresso. Em conflito entre os dois, o plano manda no escopo e este documento manda na conduta.

---

## 1. Fontes de verdade e precedência

1. Instrução explícita do dono do produto na conversa corrente.
2. `docs/plano-implementacao-20260825.md` (escopo, sequência, critérios de aceite).
3. Este documento (conduta).
4. `docs/Docs20260820_134109/design/design-contract.json` (design lock) + `docs/Docs20260824_151851/SPEC20260824_151851.md` (SPEC vigente da Fase 0+1) + `docs/Docs20260820_134109/SPEC20260820_134109.md` (SPEC do produto completo — modelo de dados e API da Etapa 5).
5. `ArchitectureDecisions-20260825_085318-4ff9ed.md`, `docs/decisoes-fase0-20260824.md`, `docs/auditoria-design-20260823.md`.

Documentos datados de rodadas anteriores (`docs/Docs*`, `.lionclaw/`, `PRD.md`/`stories-requisitos.md` da raiz) são **registro histórico: somente leitura, nunca editar** — exceto a adição de nota de cabeçalho prevista em WP-0.4.

## 2. Ritual de início de sessão

1. Ler `docs/registro-execucao.md` (board): etapa corrente, WP em andamento, bloqueios, fila de decisões.
2. `git status` + `git log --oneline -5`. Se o `.git` estiver vazio/inexistente, você está **antes** de WP-0.1 — nenhuma edição de código é permitida ainda.
3. Após WP-0.2 existir: rodar `npm test`. Suíte vermelha inesperada → consertar ou registrar BLOQUEADO antes de qualquer trabalho novo.
4. Escolher o **menor próximo passo** segundo o board. Nunca pular a ordem E0 → E1 → E2 (∥ E3) → E4 → E5.

## 3. Registro de progresso

- `docs/registro-execucao.md` é o único board de execução. Estados válidos: `PENDENTE`, `EM_ANDAMENTO`, `CONCLUIDO`, `BLOQUEADO(<motivo>)`.
- `CONCLUIDO` exige **evidência citada na própria linha** (comando executado + resultado, path criado, teste que passou). Sem evidência observável, o estado não muda.
- No máximo **um** WP `EM_ANDAMENTO` por vez (na Etapa 2, no máximo uma fatia).
- Atualizar o board ao fechar cada WP/fatia e ao encerrar a sessão (linha "última sessão" no topo).
- Achados fora do escopo do WP corrente (bugs, dívidas): registrar na seção "Achados" do board, **não** corrigir de passagem.

## 4. Guardrails de condução

### 4.1 Sequência e gates
- A Etapa 4 (portão de arquitetura) é gate duro: **nenhuma migration dos domínios da Etapa 5 antes dos ADRs aprovados pelo dono do produto.**
- Dentro da E0, WP-0.1 (git) vem antes de tudo — é a mitigação do risco R1.

### 4.2 Escopo
- Menor delta que satisfaz o critério de aceite do WP. Sem refatoração além da fatia corrente, sem helpers/flags/abstrações sem consumidor atual.
- As decisões D-01..D-13, S6–S9/11 e D1–D4 **não são reabríveis** pelo agente. Se a execução revelar que uma decisão é inviável, escalar com evidência — nunca contorná-la em silêncio.

### 4.3 O que o agente decide sozinho × o que escala

**Decide sozinho:** detalhes de implementação dentro das decisões cravadas — nomes internos, organização dos `.mjs`, estrutura dos testes, ordem interna das tarefas de um WP, mensagens de commit.

**Escala (parar e perguntar):**
- Q1–Q6 do plano (§3) — são do dono do produto.
- Item `FALHOU` na ata de P0 (WP-0.3) cuja correção mude comportamento visível.
- Qualquer mudança que toque conteúdo congelado pelo design lock (ver 4.8).
- Ampliação material de escopo, alteração de contrato público/schema já aplicado, qualquer ação destrutiva ou difícil de reverter.

**Formato de escalada:**

```text
[BLOQUEIO: <WP ou fatia>]
Motivo: <decisão que falta ou evidência do impasse>.
O1. <opção mínima>
O2. <opção estrutural>
Preciso da escolha O1 ou O2.
```

### 4.4 Código e testes
- Testes de caracterização congelam o comportamento **atual, defeitos incluídos**. Única exceção sancionada: a invariante de saldo (WP-1.3), cujo teste deve reprovar `prototype/index.html:17037` até a correção via guardião.
- Uma fatia/WP só fecha com: `npm test` verde + `node tools/contraste.mjs` exit 0 + critério de aceite do plano atendido + board atualizado + commit.
- Conversão async (E2): converter a fatia **inteira** (handler → render → regra → porta). Nunca deixar `await` parcial no meio de uma cadeia. Lembrete verificado: `async` para no handler de evento — a fatia é finita.
- Compensação (D3): proibido `splice`/`pop`/`shift`/remoção física em coleções de domínio fora do adapter de memória. Desfazer é sempre append do inverso, conforme o design ratificado em WP-1.4.
- Typecheck/lint/build provam apenas suas propriedades; não são prova funcional. Não declarar sucesso sem evidência observável.

### 4.5 Banco de dados (E4/E5 em diante)
- Padrão do repositório é lei: migration de schema **separada** da migration de RLS; toda tabela nova com `enable` + `force row level security` e policies na migration dedicada; **zero** policy de DELETE; claims somente de `app_metadata`; append-only em duas camadas (ausência de policy + `REVOKE`) onde a SPEC exigir.
- Cada domínio novo entrega junto sua suíte pgTAP; `supabase test db` verde antes do commit.
- `scripts/audit-rls.sh` limpo é pré-condição de commit que toca `supabase/migrations/` (hook de WP-0.6).
- Nunca editar migration já aplicada — correção é migration nova. Nunca desabilitar RLS ou trigger "para facilitar".

### 4.6 Git
- Um commit por WP concluído (ou por fatia na E2), mensagem em português referenciando o ID do plano (ex.: `E1 WP-1.3: guardiao unico de saldo + teste da invariante`).
- Nunca `--no-verify`, nunca amend de commit já compartilhado, nunca commitar `.env*`, `supabase/.temp/` ou qualquer segredo.

### 4.7 Interação com o protótipo
- O protótipo é servido por HTTP (`.claude/launch.json`, porta 8931). Após D1, `file://` não funciona — não "corrigir" isso; é pré-condição documentada.
- Verificação manual de tela: usar o preview do harness, nunca pedir ao usuário para checar algo que o agente pode verificar.

### 4.8 Design lock
- `docs/Docs20260820_134109/design/artifact.html` e `design-contract.json` são **intocáveis** (travados por SHA-256).
- Mudança de UI exigida pelo plano (ex.: texto do modal de correção em F-2.1, decorrência de D3): escalar com proposta de **revisão formal do lock** (diff do conteúdo + novo hash + registro no `design-lock-report.md`). Nunca editar conteúdo congelado em silêncio.
- O design-contract embutido em `prototype/index.html` (`:3187`, `:14186`) é cópia congelada e já diverge do CSS vivo em `text-on-accent` — não é fonte para estilização nova.

## 5. Notas de condução por etapa

Os critérios de aceite estão no plano §5; aqui só o que muda a conduta.

- **E0:** WP-0.1 antes de qualquer outra coisa. Na ata (WP-0.3), cada item do checklist §6.1/§6.2 da SPEC0824 é **executado de verdade** (servidor rodando, comando rodado); "PASSOU por leitura" só onde o item é inspecional por natureza.
- **E1:** todo símbolo extraído para `.mjs` que o legado consome é reexposto no global até a migração dos call sites. Comportamento observável idêntico ao anterior — a exceção sancionada é `:17037`.
- **E2:** uma fatia por vez. Fatia começa com a lista de call sites (grep documentado no board) e termina com zero mutação direta remanescente naquela área.
- **E3:** P1 que toca regra de negócio espera a fatia convertida da área; P1 puramente visual pode antecipar. Walkthroughs da Fase 3 exigem humanos — o agente prepara roteiros, dados e ambiente, e **não** executa as sessões sozinho.
- **E4:** o agente **redige** os ADRs como proposta; aprovação é do dono do produto. Sem as entradas Q3–Q6, o portão não fecha — registrar BLOQUEADO, não improvisar.
- **E5:** domínio a domínio na ordem WP-5.1 → WP-5.9. Critério de avanço: fatia do protótipo operando contra `supabase start` local com RLS ativa + pgTAP do domínio verde.

## 6. Encerramento de sessão

1. Board atualizado (estados + evidências + linha "última sessão").
2. Trabalho commitado (ou stash **nunca** usado para estado importante — commit em branch se incompleto).
3. Se algo durável mudou (decisão registrada, etapa fechada), refletir no `MEMORY.md` da raiz (existe a partir de WP-0.4; máx. 200 linhas).
4. Nunca encerrar com suíte vermelha sem `BLOQUEADO(<motivo>)` no board.

## 7. Proibições absolutas

- Editar ou apagar documentos datados de rodadas anteriores (`docs/Docs*`, `.lionclaw/`) — são registro.
- Tocar `artifact.html`/`design-contract.json` fora do processo de revisão do lock.
- Policy de DELETE, `using (true)`, claims de `user_metadata`, RLS desabilitada.
- Remoção física de dados de domínio através da porta (viola D3).
- Segredos em código, commit ou log.
- Declarar `CONCLUIDO` sem evidência executável.
- Pular gate de etapa ou reabrir decisão cravada.
