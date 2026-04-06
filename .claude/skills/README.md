# Claude Skills for Procurement Analytics

This directory contains production-grade Claude skills and agents for vendor analysis and procurement intelligence.

## Structure

```
.claude/skills/
├── README.md                                    ← You are here
├── vendor-analysis-bigquery/                    ← The Skill (SQL generation)
│   ├── README.md                                ← Quick start & usage
│   ├── SKILL.md                                 ← Full skill definition
│   ├── config/
│   │   ├── metrics/                             ← 5 YAML metric domains
│   │   │   ├── financial_health.yaml
│   │   │   ├── operational_efficiency.yaml
│   │   │   ├── risk_compliance.yaml
│   │   │   ├── quality_performance.yaml
│   │   │   └── strategic_value.yaml
│   │   └── schema/
│   │       └── allowed_tables.yaml              ← 10 BigQuery tables whitelist
│   └── references/
│       ├── bigquery_optimization.md             ← SQL best practices
│       └── vendor_kpis_framework.md             ← Metric definitions & interview questions
│
└── vendor-intelligence-agent/                   ← The Agent (multi-tool orchestration)
    ├── README.md                                ← Quick start & patterns
    ├── SKILL.md                                 ← Full agent definition
    ├── tools/
    │   ├── mcp-servers.json                     ← Tool definitions & costs
    │   ├── bigquery/                            ← Query templates
    │   ├── tableau/                             ← Dashboard procedures
    │   ├── looker/                              ← Report lookup
    │   └── documents/                           ← Document repositories
    └── orchestration/
        ├── patterns.yaml                        ← 3 executable workflows
        ├── state_machine.md                     ← Agent decision flow
        └── patterns/
            ├── anomaly_investigation.yaml
            ├── strategic_sourcing.yaml
            └── proactive_monitoring.yaml
```

---

## Quick Navigation

### I want to...

| Goal | Go to |
|------|-------|
| **Generate vendor analysis SQL** | `vendor-analysis-bigquery/README.md` |
| **Analyze vendor data end-to-end** | `vendor-intelligence-agent/README.md` |
| **Learn BigQuery optimization** | `vendor-analysis-bigquery/references/bigquery_optimization.md` |
| **Understand vendor KPIs** | `vendor-analysis-bigquery/references/vendor_kpis_framework.md` |
| **See workflow examples** | `vendor-intelligence-agent/orchestration/patterns.yaml` |
| **Understand agent logic** | `vendor-intelligence-agent/orchestration/state_machine.md` |
| **Configure tools** | `vendor-intelligence-agent/tools/mcp-servers.json` |

---

## The Skill vs Agent

### Vendor Analysis Skill (`vendor-analysis-bigquery/`)

**Purpose**: Teach analyst thinking and generate optimized BigQuery SQL

**What it does**:
- Constrains Claude to 10 BigQuery tables
- Defines 5 metric domains (financial, operational, risk, quality, strategic)
- Applies analyst behavior protocol (clarify → select → generate → execute → interpret)
- Optimizes SQL with partition pruning, clustering, SAFE_DIVIDE patterns

**What it doesn't do**:
- Execute queries (you run the SQL yourself)
- Create visualizations
- Search documents
- Make decisions across tools

**Use when**: You need SQL generation with expert reasoning

---

### Vendor Intelligence Agent (`vendor-intelligence-agent/`)

**Purpose**: Autonomous end-to-end vendor intelligence with multi-tool orchestration

**What it does**:
- Executes the skill as its rulebook (uses the same constraints and metrics)
- Orchestrates 4 tools (BigQuery, Tableau, Looker, Documents)
- Makes autonomous decisions (which tools to use, when to research docs, whether to visualize)
- Manages state machine, cost tracking, and context preservation
- Investigates anomalies, compares vendors, runs proactive monitoring

**What it doesn't do**:
- Deviate from the skill's 10 tables or 5 metrics
- Create new metric definitions
- Access data outside vendor domain

**Use when**: User asks complex vendor questions requiring multiple data sources and insights

---

## Architecture Principles

### 1. Skill is the Source of Truth

The agent uses the skill as its **rulebook**. The skill is not dependent on the agent.

```
vendor-analysis-bigquery (SKILL)
    ↑
    │ (used by)
    │
vendor-intelligence-agent (AGENT)
```

**Implication**: You can use the skill independently without the agent. The agent cannot override skill rules.

### 2. Progressive Disclosure

Skills and agents are organized by complexity:

1. **Skill (Beginner)**: Learn to think like an analyst. Generate SQL.
2. **Agent (Intermediate)**: Execute the skill. Orchestrate tools.
3. **Patterns (Advanced)**: Multi-step workflows for real problems.

### 3. Constrained Autonomy

The agent is autonomous **within constraints**:
- ✅ Can decide which tools to use
- ✅ Can reason about anomalies
- ✅ Can investigate root causes
- ✅ Can create visualizations
- ❌ Cannot access unauthorized tables
- ❌ Cannot invent metrics
- ❌ Cannot deviate from analyst behavior protocol

---

## Key Concepts

### The 5 Metric Domains

All vendor analysis is organized into 5 domains:

| Domain | Focus | Metrics | Use Case |
|--------|-------|---------|----------|
| **Financial** | Cost management | Spend under mgmt, cost avoidance, payment terms | "How much do we spend?" |
| **Operational** | Speed & reliability | On-time delivery, cycle time, accuracy | "How fast do they deliver?" |
| **Risk** | Mitigation | ESG score, geographic risk, compliance | "What are the risks?" |
| **Quality** | Defects & satisfaction | Defect rate, invoice accuracy, satisfaction | "What's the quality?" |
| **Strategic** | Growth potential | Innovation, partnership | "Are they strategic?" |

Every vendor question maps to one or more domains.

### The 10 BigQuery Tables

Only these tables can be queried:

1. `procurement.vendors` — Master registry
2. `procurement.spend_transactions` — Line items (450 GB, LARGE)
3. `procurement.purchase_orders` — PO headers
4. `procurement.contracts` — Terms & conditions
5. `procurement.invoices` — Billing
6. `procurement.delivery_receipts` — Goods receipts
7. `procurement.quality_audits` — Inspection results
8. `procurement.risk_assessments` — Risk scores
9. `procurement.sustainability_metrics` — ESG data
10. `procurement.vendor_interactions` — Communications

**Critical**: Partition pruning required on `spend_transactions` (450 GB table).

### 3 Common Workflows

#### 1. Anomaly Investigation
"Why did vendor cost spike?"

→ BigQuery (quantify) → Looker (context) → Documents (root cause) → Tableau (viz)

Cost: ~1,100 tokens

#### 2. Strategic Sourcing
"Renew with X or switch to Y?"

→ BigQuery (3-year comparison) → Looker (benchmarks) → Documents (terms) → Tableau (decision matrix)

Cost: ~2,300 tokens

#### 3. Proactive Monitoring
Weekly autonomous vendor health checks

→ BigQuery (anomalies) → Looker (risk) → Documents (if needed) → Tableau (dashboard) → Alerts

Cost: ~700 tokens/week

See `vendor-intelligence-agent/orchestration/patterns.yaml` for full definitions.

---

## Token Budget & Cost Management

### Budget Per Request: 5,000 tokens

```yaml
typical_costs:
  simple_query:              200 (4%)      # "Top 10 vendors"
  anomaly_investigation:   1,100 (22%)     # "Why did cost spike?"
  sourcing_decision:       2,300 (46%)     # "Renew or switch?"
  deep_dive:               4,200 (84%)     # Multi-vendor analysis
```

### Tool Costs

| Tool | Per-Call Cost | Persistence | Notes |
|------|---------------|-------------|-------|
| BigQuery | 15 tokens (schema) + results | Stateless | Always use first |
| Looker | 20 tokens + results | Session ID persists | Check before creating |
| Tableau | 400 tokens (update) / 1,500+ (create) | Workbook persists | Reuse dashboards |
| Documents | 30 tokens / 1,000 pages | Stateless | Use only if needed |

### Optimization Rules

1. **Try BigQuery first** (cheapest)
2. **Check Looker before creating** (20 vs 400+ tokens)
3. **Batch document searches** (expensive, be targeted)
4. **Reuse Tableau dashboards** (400 to update vs 1,500 to create)
5. **Compress context** (never pass full result sets to next tool)

---

## Deployment Phases

### Phase 1: BigQuery Only (Week 0)
- Load `vendor-analysis-bigquery` skill
- Test SQL generation
- Validate model behavior

### Phase 2: Visualization (Week 1)
- Enable Tableau tool
- Test dashboard creation
- Monitor costs

### Phase 3: Semantic Layer (Week 2)
- Enable Looker tool
- Integrate with existing reports
- Reduce query redundancy

### Phase 4: Document Research (Week 4)
- Enable Documents tool
- Test contract extraction
- Monitor costs (expensive)

### Phase 5: Autonomous Monitoring (Month 2)
- Enable proactive monitoring pattern
- Set up alerts
- Full production deployment

---

## Learning Resources

### For Users

1. **Start with the skill**: `vendor-analysis-bigquery/README.md` — understand what's possible
2. **Learn KPIs**: `vendor-analysis-bigquery/references/vendor_kpis_framework.md` — understand metrics
3. **See examples**: `vendor-intelligence-agent/README.md` — see workflows in action
4. **Deep dive**: `vendor-intelligence-agent/orchestration/patterns.yaml` — see exact execution

### For Developers

1. **Skill architecture**: `vendor-analysis-bigquery/SKILL.md` — rules and constraints
2. **Agent architecture**: `vendor-intelligence-agent/SKILL.md` — orchestration logic
3. **SQL optimization**: `vendor-analysis-bigquery/references/bigquery_optimization.md` — performance tuning
4. **State machine**: `vendor-intelligence-agent/orchestration/state_machine.md` — decision flow
5. **Tool config**: `vendor-intelligence-agent/tools/mcp-servers.json` — MCP server setup

---

## Troubleshooting

### "I'm getting unauthorized table errors"
→ You're trying to query a table outside the 10 allowed ones. Check `vendor-analysis-bigquery/config/schema/allowed_tables.yaml`.

### "Queries are timing out"
→ Missing partition pruning on the 450 GB `spend_transactions` table. See `vendor-analysis-bigquery/references/bigquery_optimization.md#partition-pruning`.

### "The metric I need isn't available"
→ It's not in the 5 YAML metric domains. Propose the closest alternative or check `vendor-kpis_framework.md` for definitions.

### "Agent is using too many tokens"
→ Reduce tool usage (skip visualization if not needed), compress context between tools. See token budget section above.

### "I don't know which tool to use"
→ Start with BigQuery, then decide based on findings. See decision trees in `vendor-intelligence-agent/SKILL.md#tool-selection-strategy`.

---

## Version History

- **v1.0** (April 2026)
  - Initial release: Vendor Analysis Skill with BigQuery foundation
  - Vendor Intelligence Agent with full multi-tool orchestration
  - 5 metric domains, 10 tables, 3 common workflows
  - Production-ready token budgeting and state management

---

## Support

For questions or issues:
1. Check the relevant README (skill or agent)
2. Review the troubleshooting section above
3. Consult references (optimization guide, KPI framework)
4. Review execution patterns for workflow examples

---

**Last Updated**: April 2026
**Status**: Production Ready
**Maintained by**: Procurement Data Engineering Team
