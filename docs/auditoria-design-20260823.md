# Auditoria de UX e design — ViaFab (23/08/2026)

Escopo: protótipo `Desktop/index.html` (24.023 linhas). Método: /hm-ux-flow + /hm-designer, walkthrough real em browser (8 perfis, 22 telas, 2 temas, desktop 1280 e tablet 768), 6 análises paralelas de código, cruzamento com o contrato lionclaw embutido (24 telas, 28 US, 89 deltas) e docs de discovery/validação deste repositório.

Versão navegável (mesma numeração): https://claude.ai/code/artifact/c285ad00-f3df-464b-bcf4-3a26b0f56401

**Veredicto: OPTIMIZE.** Fundação forte (navegação por fluxo de negócio, identidade própria, densidade correta, microcopy de regra de negócio, rastreabilidade ponta a ponta). Não valida ainda: 22 P0 objetivos + 13 decisões de produto em aberto. Não precisa de redesign.

## Pontos fortes (preservar)

1. Sidebar agrupada na ordem do fluxo real (Comercial → Engenharia → Produção → Materiais → Saída).
2. Permissões fail-closed no roteador, com auditoria de tentativa negada e somente-leitura em 3 camadas.
3. Viabilidade de prazo e cobertura de material ANTES de "Enviar ao planejamento" (pedidos).
4. Posto do operador por subtração (só ordens liberadas; regra declarada na tela) + regimes de consumo acima do separado com erro que cita o número.
5. Identidade verificável: logotipo dois-temas, folha A4 molde único com CNPJ/QR, etiqueta de placa, QR próprio.
6. Microcopy madura (lote/certificado, recusas do leitor de QR com 6 motivos, 54 empty states com instrução).
7. Rastreabilidade fecha: linha do pedido → ordem → série → romaneio → espelho fiscal; OS consolida entre ordens preservando rateio.

## P0 — 22 bloqueios (fix resumido; linhas de index.html)

| ID | Área | Problema | Fix essencial | Linhas |
|----|------|----------|---------------|--------|
| P0-01 | Plano | "Gerar ordens" executa sem preview/confirmação; fila destruída; sem volta | Rótulo vivo + modal listando ordens, faltas e componentes consumidos | 21203–21280 |
| P0-02 | Qualidade | Sem fila de trabalho; ordem concluída espera inspeção sem ninguém saber (seed: OP-2438) | Card "Aguardando inspeção" + contagem no resumo crítico do Início | 22506–22521 |
| P0-03 | Expedição | Unidades retidas pela qualidade invisíveis (depósito físico cheio, sistema "vazio") | Stat "Retidas pela qualidade" + blocos desabilitados com motivo e CTA | 16104, 16348–16355 |
| P0-04 | Chão | Finalizar sem confirmação/estorno; após desbloqueio, re-finalizar duplica baixa de material | Confirmação com efeito (matDaOperacao já calcula); guarda anti-reapontamento; correção 10 min | 15967–15995, 19934 |
| P0-05 | Qualidade | Reprovação não conduz ninguém; recuperação passa por laço não documentado (e dispara P0-04) | Próximo passo ao reprovar; card de reprovação no posto; desbloqueio reseta qa e reabre operações | 16065–16083, 15560 |
| P0-06 | Engenharia | Ficha sem rascunho: edição grava direto; "não publicadas" mente; sem descartar | Editar sobre cópia + Descartar + interceptar troca de ficha | 19110–19194 |
| P0-07 | Engenharia | Editar/publicar ficha usada por ordens abertas sem verificação; fallback lê ficha atual | Faixa nomeando ordens afetadas; modal de publicação com afetadas × não; confirmar fallback | 19062, 15602–15608 |
| P0-08 | Engenharia | Sem roteiro por ficha — ROT_BASE global de 7 operações p/ qualquer produto; tempo/máquina ineditáveis | Aba Roteiro na ficha; roteiroDe() deriva das fichas (depende de D-02) | 15460–15478 |
| P0-09 | Importação | .vfb recusado + OK = cria pedido demo de outro cliente em silêncio | Desabilitar OK com pacote inválido; segmented pacote/demo | 20200, 20815–20865 |
| P0-10 | Estoque | "Reservar materiais" duplica reserva (não estorna antes de somar); sem liberar reserva | Estornar antes; botão Liberar; "Recalcular" com delta | 15658–15676 |
| P0-11 | Início | Atalhos padrão apontam p/ módulos inexistentes; tooltip "Sem permissão" mentiroso (4 perfis) | Filtrar padrão por MODULOS; corrigir destinos; destino com aba | 22486–22537 |
| P0-12 | Início | "Adicionar atalho" morto p/ 100% dos perfis (perm('inicio')==='r' sempre) | Remover a guarda — preferência de usuário, não permissão | 22533, 22621 |
| P0-13 | Shell | Zero atalhos de teclado globais (só Esc) | Ctrl+K paleta sobre NAV; g+letra; "/" filtro; "?" ajuda; pill na topbar | 23998 |
| P0-14 | A11y | Focus ring 1,17–1,33:1 (invisível) | outline 2px accent-text + offset | 130 |
| P0-15 | Temas | Claro reprova AA em massa (dim 2,76 = ths/eyebrows; faint 3,63; links 3,91); pills 2,19–3,45 nos 2 temas | faint #666660, dim #65655f, accent-text #9b5239 (claro); dark +1 degrau; pill: texto normal, cor só no ponto/borda | 83, 89, 225–229 |
| P0-16 | Temas | btn-primary branco sobre laranja 3,12:1 (delta-010 pendente) | --text-on-accent:#1c1c1a (5,41:1), mantém a marca | 39, 204 |
| P0-17 | A11y | tr.clickable sem tabindex/role/keydown — navegação primária inacessível por teclado | Helper único: tabindex+role+keydown delegado + foco de linha (7 tabelas) | 249, 15426… |
| P0-18 | Painel | Seletor 7/30/90 não filtra KPIs/carga/donut/aderência (só 1 gráfico) | Range filtra tudo ou desce para os cards temporais com rótulo | 18459–18552 |
| P0-19 | Painel | Aderência inflada: expedida = sempre no prazo; "últimos 90 dias" sem filtro; o.fim ignorado | fim<=prazo; excluir sem fim do denominador declarando; recorte real | 18469, 18523 |
| P0-20 | OS | ID/QR posicionais — renumeram a cada emissão; QR de ontem abre outro grupo | ID estável (chave+data ou sequencial persistido); QR carrega a chave | 23464–23481 |
| P0-21 | Auditoria | Sem tenant no registro, sem data/busca/paginação/exportação | un:S.tenant + filtros de/até + busca + CSV/PDF via folhaA4 | 15234, 16611–16643 |
| P0-22 | Relatórios | "Últimos 30 dias" = ±30 (janela simétrica); cabeçalho impresso mente | Janela retrospectiva ou rótulo ±N; ideal: datas com presets | 19803–19811 |

## P1 — 14 grupos (antes do dev)

- **G-01 Navegação**: pushState+popstate (Back sai do app hoje); rotas com ID (#ordem-detalhe/OP-2433); F5 honra destino pós-login; fila de atenção leva com filtro aplicado.
- **G-02 Sessão**: renovar por teclado/scroll (hoje só clique — desloga digitando); aviso aos 2 min; logout fecha modal; expiração ≠ visual de credencial inválida.
- **G-03 Login**: e-mail decorativo sinalizado como demo; empresa depois de autenticar; troca de perfil vira "Ver como…" com confirmação, sem responder a scroll, mantendo o módulo.
- **G-04 Handoffs**: badge de novidade no chão; "reprovadas sem tratativa" com campo de tratativa real (hoje conta para sempre); fila de atenção filtrada por permissão; bloqueio diz a quem foi e oferece próxima ordem.
- **G-05 Material**: reservar no detalhe da ordem; sync offline aplicar saldo/lote de verdade (hoje só marca ok); unificar "crítico" vs "abaixo do mínimo"; depósito decorativo — modelar saldo por depósito ou remover selects.
- **G-06 Formulários**: combobox com busca no lugar de selects de 98–126 opções; obrigatórios visíveis + required em selects + erro inline com foco; autofoco pulando readonly; prévia da nomenclatura no topo; **parser por prefixo corrompe CONTRAN (R-25 em "R-19…" grava "R-259")** — regex ancorada (20097).
- **G-07 Confirmações**: confirmar só o irreversível (Confirmar saída, Cancelar romaneio); placa/NF na confirmação de saída, não na montagem; ordenação da fila default "menor folga" com legenda; segmentado de consolidação com efeito no rótulo.
- **G-08 Cadastros/parâmetros**: parâmetros aplicam só no salvar + reset com confirmação + certificadoObrigatorio implementar ou remover; produto novo nasce "Em elaboração"; bloquear descrição composta duplicada; contratos com vigência em datas + novo cliente.
- **G-09 Uma verdade por número**: previsaoDe() única regra de entrega; consolidar Início×Painel; dados sintéticos (sparklines, produção×plano) derivar do real ou selar "ilustrativo"; penalidades (+3/+2) para PARAM com decomposição.
- **G-10 Drill-down/metas**: tiles e gráficos clicáveis para telas filtradas; stat() com meta/faixa; m² comparar com último dia útil; "Exportar painel"/"Salvar composição" implementar ou rebaixar; exportar em Clientes/Recursos/Mão de obra.
- **G-11 Custo**: composição do custo-hora aberta (encargos/depreciação/energia); 176h→PARAM; texto do orçamento ("por dentro") corrigido com fórmula visível; ocupação de setor com base única e todas as operações; perm('maoobra')→perm('recursos') + perm() acusa chave desconhecida.
- **G-12 Toque/responsivo**: pointer:coarse estendido a expedição/qualidade (chips ~17px na doca; medido 30–36px no posto); 26 grids inline → classes com breakpoint; sidebar mobile em drawer com grupos e 44px.
- **G-13 Impressão**: @media print com tokens claros + print-color-adjust; etiqueta usa var(--font-mono) (hoje ID sai em Courier); OS paginada com cabeçalho repetido e "Folha X de Y"; itens ≥9pt; QR 24–26mm.
- **G-14 A11y estrutural**: aria-live no toast (não no tooltip); gráficos com nome acessível + tooltip por toque; modal com trap/devolução de foco; remover atalho visível fora do hover; foco movido na troca de módulo; ícones aria-hidden; prefers-reduced-motion.

## P2 — seleção (não bloqueia)

Toasts concatenam sem separação (15241) · skeleton inexistente no DS · empty state sem anatomia própria (287) · .rowflag ambíguo perigo/seleção (250) · .stat.danger/.warn inexistentes no CSS (384) · badge da sidebar desatualizada + `<\span>` malformado (15311) · breadcrumb sem registro/clique (15341) · acesso negado sem saída útil (3005) · fonte via CDN (offline cai p/ fallback) (8) · 222 font-sizes crus vs 11 tokens mortos · 3 dialetos de CSV (19877) · aderência vermelha p/ cliente sem histórico (18529) · ajuste de inventário soma sem motivo (15727) · modal de foto "Cancelar" ambíguo (23198) · seed com saldo > entrada (15874).

## Decisões de produto em aberto (Fase 0 — dono do produto)

D-01 Tese do produto: família paramétrica/normas/roteiro derivado removidos (delta-053/054/055/026) — assumir? · D-02 Ficha manual × BOM por fórmula: qual prevalece (delta-014) · D-03 Área nominal × geométrica no contrato m² (delta-087) · D-04 Chave de dimensão 1 casa decimal (delta-068) · D-05 Ordem de lote rateia avanço (delta-025) · D-06 Operador vê ordens paradas (delta-034) · D-07 Descritores MA/MP/MQ (delta-035) · D-08 ViaSign: entrada por ponto de implantação (delta-070) · D-09 Código película tipo IV (delta-073) · D-10 Canonicalização do hash (delta-071) · D-11 E-mail no .vfb (LGPD, delta-075) · D-12 sem_quadro na nomenclatura (delta-069) · D-13 ADR-012/viaxis.vfb ausente do repo (delta-067).

Somam-se P1–P8 do relatorio-validacao (todos pendentes) e 46 deltas com requiresRequirementsChange aguardando retorno às stories.

## Plano por fases

- **Fase 0 — Decisões** (1 reunião, paralela): 13 decisões + P1–P8 registradas; stories atualizadas; ADR-012 no repo.
- **Fase 1 — 22 P0 no protótipo** (~8–10 dias): d1–2 tokens/a11y (P0-14/15/16/17) → d3–5 integridade (P0-01/04/10/06/07/09) → d5–6 handoffs (P0-02/03/05) → d7 home/teclado (P0-11/12/13) → d8 números (P0-18/19/22/20/21). P0-08 depende de D-02 (+2–3 dias se confirmado). Saída: zero P0; contraste AA por script; fluxo completo por teclado.
- **Fase 2 — P1** (~8–12 dias): G-01/02 → G-04/05 → G-06 → G-09/10 → G-12/13 → restantes. P2 como enchimento. Saída: back/F5/deep-link ok; nenhum rótulo mente; um número, uma definição; tablet ≥44px.
- **Fase 3 — Validação com usuários** (1 semana, paralela ao fim da F2): 5 roteiros gravados (PCP, Operador em tablet físico, Almoxarifado, Qualidade+Expedição, Direção) com dados reais da fábrica-piloto (hoje 18/32 produtos sem composição; números demo). Saída: roteiros completos sem facilitador; OS/etiqueta validadas em papel (delta-084); P0 novos zerados.
- **Fase 4 — Portão de arquitetura** (antes da 1ª migration): RLS server-side (delta-005 "bloqueante") · idempotência em 4 fluxos (040/045/077/004) · IDs estáveis (setor por nome 063; OS; dimensão) · QR assinado (033/039/047) · parâmetros por tenant versionados (078) · concorrência romaneio/replanejamento/realocação (057/065/058) · snapshot imutável real (026). Saída: 1 ADR por risco; schema revisado; plano de testes multi-tenant (US-26).

## Critérios de aceite da etapa de design

- [ ] Zero P0 (22 + novos da Fase 3)
- [ ] Contraste AA verificado por script nos 2 temas (texto, pills, primário, foco ≥3:1)
- [ ] Fluxo pedido→expedição 100% por teclado com foco visível
- [ ] Nenhum rótulo promete ação inexistente ("exportar", "salvar", "sincronizar", "últimos N dias")
- [ ] Todo handoff entre papéis gera sinal no destino
- [ ] Irreversível confirma com consequência; reversível não confirma
- [ ] Tablet físico: alvos ≥44px nas telas operacionais; OS e etiqueta legíveis impressas
- [ ] 13 decisões assinadas + 46 deltas devolvidos às stories
- [ ] 5 walkthroughs gravados completos com dados reais
