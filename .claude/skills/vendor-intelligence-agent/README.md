# Vendor Intelligence Agent

## Quick Start

This agent provides **autonomous, multi-tool vendor analytics** by orchestrating BigQuery, Tableau, Looker, and document search.

**Use this agent when:**
- User asks complex vendor questions requiring multiple data sources
- Visualizations, dashboards, or document research is needed
- Decision-making requires cross-domain analysis (financial + operational + risk + quality + strategic)
- You need to investigate anomalies with root-cause analysis

**Use the Skill instead when:**
- Only SQL query generation is needed (no tool execution)
- You're teaching or explaining vendor analysis logic
- Single-tool analysis is sufficient

---

## Files in This Agent

### Core

- **`SKILL.md`** — The agent manifest with orchestration rules, state machine, cost management, and execution flows

### Tools & Configuration

- **`tools/mcp-servers.json`** — MCP server definitions for BigQuery, Tableau, Looker, Documents with cost tracking
- **`tools/bigquery/`** — Query templates and optimization guides (references parent skill)
- **`tools/tableau/`** — Dashboard creation procedures
- **`tools/looker/`** — Report lookup and explore definitions
- **`tools/documents/`** — Document repository index and extraction rules

### Orchestration

- **`orchestration/patterns.yaml`** — 3 common workflows:
  - Anomaly Investigation (BigQuery → Looker → Documents → Tableau)
  - Strategic Sourcing (Parallel queries → Looker → Documents → Tableau decision matrix)
  - Proactive Monitoring (Autonomous weekly vendor health checks)

- **`orchestration/state_machine.md`** — Agent state transitions (IDLE → GATHERING_DATA → ANALYZING → RESEARCHING_DOCS → VISUALIZING → SYNTHESIZING → COMPLETE)

### References

- **`references/`** — Procurement frameworks, vendor management best practices (inherited from skill)

---

## How It Works

### The Agent Loop

```
┌──────────────┐
│ User Request │
└──────┬───────┘
       │
       ▼
┌─────────────────────────┐
│ Skill: Clarify Intent   │  ← Uses vendor-analysis-bigquery skill
└──────┬──────────────────┘
       │
       ▼
┌──────────────────────────┐
│ BigQuery: Gather Data    │  ← Execute SQL
└──────┬───────────────────┘
       │
       ▼
┌──────────────────────────┐
│ Analyze Results          │  ← Hypothesis testing
├─ Anomaly detected? ──┐
├─ Needs viz? ──────────>  Looker (check existing) → Tableau (create)
└─ Complete? ───────────>  SYNTHESIZE
       │
       ▼ (if anomaly)
┌──────────────────────────┐
│ Documents: Research      │  ← Contract terms, communications
└──────┬───────────────────┘
       │
       ▼
┌──────────────────────────┐
│ Synthesize Response      │  ← Combine data + docs + visuals
└──────┬───────────────────┘
       │
       ▼
┌──────────────────────────┐
│ Return to User           │  SQL + Insights + Dashboards + Recommendations
└──────────────────────────┘
```

---

## State Machine

The agent transitions through **7 states**:

| State | Purpose | Next |
|-------|---------|------|
| **IDLE** | Waiting for user input | GATHERING_DATA |
| **GATHERING_DATA** | Running BigQuery queries | ANALYZING |
| **ANALYZING** | Applying analyst reasoning | VISUALIZING / RESEARCHING_DOCS / SYNTHESIZING |
| **RESEARCHING_DOCS** | Searching documents for context | ANALYZING or SYNTHESIZING |
| **VISUALIZING** | Creating/updating dashboards | SYNTHESIZING |
| **SYNTHESIZING** | Formatting final response | COMPLETE |
| **COMPLETE** | Response ready | IDLE (new request) or GATHERING_DATA (follow-up) |

See `orchestration/state_machine.md` for detailed transitions and context management.

---

## Tool Orchestration

### The 4 Tools

| Tool | Cost | When to Use | Persistence |
|------|------|------------|-------------|
| **BigQuery** | 15 tokens (schema) + results | Always first — raw data | Stateless |
| **Looker** | 20 tokens + results | Check before creating viz | Session ID persists |
| **Tableau** | 25 tokens (update) / 1,500 (create) | User asks for visuals | Workbook ID persists |
| **Documents** | 30 tokens/1000 pages | Anomalies, contracts, ESG | Stateless |

### Progressive Tool Loading

Only load tools when needed:

```yaml
initial:     ["bigquery"]           # Always loaded
triggers:
  chart:     load tableau           # +25K tokens
  report:    load looker            # +20K tokens
  contract:  load documents         # +30K tokens
```

**Token budget per request: 5,000**

Typical workflows:
- Simple query: 200 tokens (4% of budget)
- Anomaly investigation: 1,100 tokens (22% of budget)
- Sourcing decision: 2,300 tokens (46% of budget)
- Deep dive: 4,200 tokens (84% of budget, maximum)

---

## Common Workflows

### 1. Anomaly Investigation

**User**: "Why did Vendor X's cost spike?"

**Agent flow**:
1. BigQuery: Quantify the spike (200 tokens)
2. Looker: Get business context (300 tokens)
3. Documents: Find contract changes, emails (500 tokens)
4. Tableau: Create anomaly visualization (400 tokens)
5. Synthesize: Root cause with evidence

**Result**: Actionable insight + dashboard link

**Example output**:
> "Vendor X spend increased 40% in Q3 due to:
> - Volume increase: +30% more units (operational decision)
> - Price increase: +10% per unit (new contract as of July 1, confirmed in docs)
> - No maverick spend: 95% still under contract
> 
> Recommendations: Review if price increase is competitive vs peers, consider renegotiating Q4."

---

### 2. Strategic Sourcing / Renewal Decision

**User**: "Should we renew with Vendor Y or switch to Vendor Z?"

**Agent flow**:
1. BigQuery: 3-year performance comparison (400 tokens)
2. BigQuery: Calculate switching costs (200 tokens)
3. Looker: Category benchmarks (300 tokens)
4. Documents: Extract contract terms (500 tokens)
5. Tableau: Create decision matrix dashboard (400 tokens)
6. Synthesize: Recommendation with scoring

**Result**: Vendor comparison scorecard + financial impact

---

### 3. Proactive Monitoring (Autonomous)

**Trigger**: Runs weekly without user input

**Agent flow**:
1. BigQuery: Detect >20% spend anomalies (200 tokens)
2. Looker: Check vendor risk scores (300 tokens)
3. Documents: If anomaly detected, search (500 tokens)
4. Tableau: Update Risk Watch dashboard (400 tokens)
5. Notify: Send Slack/email alerts

**Result**: Weekly vendor health report + alerts for issues

See `orchestration/patterns.yaml` for full YAML definitions of all 3 patterns.

---

## Rulebook: The Vendor Analysis Skill

**This agent always follows the rules from the sibling `vendor-analysis-bigquery` skill:**

- ✅ Only the 10 allowed BigQuery tables
- ✅ Only the 5 defined metric domains (financial, operational, risk, quality, strategic)
- ✅ Analyst behavior protocol (clarify → select → generate → execute → interpret)
- ✅ BigQuery optimization rules (partition pruning, SAFE_DIVIDE, clustering, etc.)

**Deviation is not permitted.** If a question falls outside the skill's scope, the agent must refuse gracefully.

---

## Specialized Agents (New)

**Don't want to build your own agent?** Use one of the 5 pre-built agents in [`agents/`](./agents/).

Each agent is optimized for a different use case with a different Claude model:

| Agent | Model | Purpose | Response Time |
|-------|-------|---------|---|
| **[Fast Analysis](./agents/fast-analysis-agent.md)** | Claude 3.5 Haiku | Quick vendor lookups | <5 sec |
| **[Deep Analysis](./agents/deep-analysis-agent.md)** | Claude 3 Opus | Root cause investigation | 20-60 sec |
| **[Strategic Advisor](./agents/strategic-advisor-agent.md)** | Claude 3.5 Sonnet | Business decisions | 45-90 sec |
| **[Risk Monitor](./agents/risk-monitor-agent.md)** | Claude 3 Opus | Supply chain risk | 30-90 sec |
| **[Cost Optimizer](./agents/cost-optimizer-agent.md)** | Claude 3.5 Sonnet | Spend reduction | 45-75 sec |

→ **See [`agents/README.md`](./agents/README.md)** for routing guide & examples.

All agents derive from this parent agent and follow the same vendor-analysis-bigquery skill rules.

---

## Cost Management

### Token Budget: 5,000 per request

```yaml
tracking:
  GATHERING_DATA:   15 (BigQuery base) + query results
  ANALYZING:        0 (no tool use)
  RESEARCHING_DOCS: 30 (document search base) + 30/1000 pages
  VISUALIZING:      25 (Looker check) or 400 (Tableau update)
  SYNTHESIZING:     0 (no tool use)

optimization:
  1. "Try BigQuery first" (cheapest)
  2. "Check Looker before creating" (20 vs 400+ tokens)
  3. "Batch document searches" (expensive, be targeted)
  4. "Reuse existing Tableau dashboards" (400 to update vs 1,500 to create)
  5. "Compress context" (never pass full result sets to next tool)
```

### Example Budgets

| Workflow | Cost | % of Budget |
|----------|------|-----------|
| "Top 10 vendors by spend" | 200 | 4% |
| "Why did cost spike?" | 1,100 | 22% |
| "Renewal vs switch decision?" | 2,300 | 46% |
| "Deep dive multi-vendor analysis" | 4,200 | 84% |

---

## Architecture

### Skills vs Agents

This repository demonstrates the skill-agent hierarchy:

```
SKILL (vendor-analysis-bigquery/)
  └── Teaches analyst thinking
  └── Generates SQL only
  └── No tool execution
  └── 10 rules + 5 metrics + optimization guides

AGENT (vendor-intelligence-agent/)
  └── Executes skill as rulebook
  └── Orchestrates 4 tools
  └── Makes autonomous decisions
  └── Manages state, cost, context
```

**The agent is not independent** — it depends on the skill for its reasoning framework.

---

## Integration & Deployment

### Phase 1: BigQuery Only
- Load `vendor-analysis-bigquery` skill
- Test SQL generation and execution
- **No Tableau, Looker, or Documents yet**

### Phase 2: Add Visualization (Week 1)
- Enable Tableau tool
- Test dashboard creation
- Validate cost tracking

### Phase 3: Add Semantic Layer (Week 2)
- Enable Looker tool
- Test report lookup
- Integrate with existing reports

### Phase 4: Add Document Research (Week 4)
- Enable Documents tool
- Test contract extraction
- Monitor cost (expensive)

### Full Deployment (Month 2)
- Enable autonomous monitoring pattern
- Set up alerts
- Full multi-tool orchestration

---

## Troubleshooting

### Agent tries to use unauthorized table
→ The skill is enforcing table constraints. This is correct behavior.

### BigQuery query is slow
→ Check `vendor-analysis-bigquery/references/bigquery_optimization.md#partition-pruning`

### Tableau dashboard creation fails
→ Agent falls back to Looker report or Slack message. Check dashboard permissions.

### Document search times out
→ Agent skips documents, proceeds with query data. Reduce search scope.

### Token budget exceeded
→ Reduce tool usage (skip visualization if not requested), compress context between tools

---

## Learning Path

1. **Start here**: `SKILL.md` — understand agent architecture and state machine
2. **Study patterns**: `orchestration/patterns.yaml` — see 3 real workflows
3. **Understand state machine**: `orchestration/state_machine.md` — see decision flow
4. **Learn the skill**: `../vendor-analysis-bigquery/SKILL.md` — understand the rulebook
5. **Optimize queries**: `../vendor-analysis-bigquery/references/bigquery_optimization.md`
6. **Study KPIs**: `../vendor-analysis-bigquery/references/vendor_kpis_framework.md`

---

## For Developers

### Adding a New Tool

1. Define in `tools/mcp-servers.json` with cost estimates
2. Add trigger in `tools/mcp-servers.json` lazy loading section
3. Add state transitions in `orchestration/state_machine.md`
4. Add example in `orchestration/patterns.yaml`

### Adding a New Pattern

1. Create `.yaml` file in `orchestration/patterns/`
2. Define steps with costs
3. Add state transitions
4. Document expected budget

### Monitoring & Alerting

Track these metrics:
- Avg tokens per request (target: <3,000)
- Tool success rates
- Dashboard creation latency
- Document search accuracy
- User satisfaction (post-response surveys)

---

## Examples in Action

See `orchestration/patterns.yaml` for executable workflow definitions with exact SQL, tool parameters, and cost tracking.
