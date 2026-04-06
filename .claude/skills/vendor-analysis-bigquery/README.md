# Vendor Analysis Skill (BigQuery-Only)

## Quick Start

This skill provides **scoped, rule-based vendor analysis** constrained to BigQuery data.

**Use this skill when:**
- User asks for vendor spend, performance, or risk analysis
- You need to generate optimized BigQuery SQL with analyst reasoning
- Single-tool analysis is sufficient (no dashboards or document research needed)

**Use the Agent instead when:**
- User asks for visualizations, dashboards, or multi-tool insights
- You need to orchestrate BigQuery + Tableau + Looker + Documents

---

## Files in This Skill

### Core

- **`SKILL.md`** — The skill manifest with complete instructions, constraints, and execution flow

### Configuration: Metrics (5 domains)

- **`config/metrics/financial_health.yaml`** — Spend under management, cost avoidance, payment terms
- **`config/metrics/operational_efficiency.yaml`** — On-time delivery, cycle time, order accuracy
- **`config/metrics/risk_compliance.yaml`** — ESG score, geographic risk, contract compliance
- **`config/metrics/quality_performance.yaml`** — Defect rate, invoice accuracy, satisfaction
- **`config/metrics/strategic_value.yaml`** — Innovation contribution, partnership alignment

### Configuration: Schema

- **`config/schema/allowed_tables.yaml`** — The 10 BigQuery tables this skill can query (with metadata)

### References

- **`references/bigquery_optimization.md`** — SQL best practices (partition pruning, clustering, SAFE_DIVIDE, QUALIFY, etc.)
- **`references/vendor_kpis_framework.md`** — The 5 KPI domains explained with sample queries and interview questions

---

## Example Usage

```python
from anthropic import Anthropic

client = Anthropic()

# Load the skill definition
with open('.claude/skills/vendor-analysis-bigquery/SKILL.md') as f:
    skill = f.read()

# User question
user_query = "Which vendors have the highest spend this quarter?"

# Call Claude with the skill
response = client.messages.create(
    model="claude-opus-4-5",
    max_tokens=2048,
    system=f"You are a vendor analysis expert.\n\n{skill}",
    messages=[{"role": "user", "content": user_query}]
)

print(response.content[0].text)
```

**Output**: SQL query + plain-English explanation + business recommendation

---

## The 10 Allowed Tables

| Table | Size | Partition | Use Case |
|-------|------|-----------|----------|
| `procurement.vendors` | 2 GB | `updated_at` | Vendor master registry |
| `procurement.spend_transactions` | 450 GB | `event_date` | Line-item spend (LARGE) |
| `procurement.purchase_orders` | 120 GB | `po_date` | PO headers & status |
| `procurement.contracts` | 8 GB | `created_at` | Contract terms |
| `procurement.invoices` | 85 GB | `invoice_date` | Invoice processing |
| `procurement.delivery_receipts` | 95 GB | `delivery_date` | Goods receipts |
| `procurement.quality_audits` | 45 GB | `audit_date` | Inspection results |
| `procurement.risk_assessments` | 12 GB | `assessment_date` | Risk scores |
| `procurement.sustainability_metrics` | 5 GB | `measurement_date` | ESG data |
| `procurement.vendor_interactions` | 35 GB | `interaction_date` | Communication logs |

**Critical**: Partition pruning is required on the 450 GB `spend_transactions` table. See `references/bigquery_optimization.md`.

---

## The 5 Metric Domains

```
Financial Health (Cost)          → Spend management, savings, payment terms
Operational Efficiency (Speed)   → Delivery timeliness, cycle time, accuracy
Risk & Compliance (Mitigation)   → ESG, geographic risk, contract adherence
Quality & Performance (Defects)  → Quality scores, defect rates, satisfaction
Strategic Value (Growth)         → Innovation, partnership alignment
```

For each domain, the skill has 2-3 pre-built SQL templates in YAML.

---

## Analyst Behavior

This skill emulates how a senior procurement analyst thinks:

1. **Clarify intent** — Ask user to confirm scope, time period, audience
2. **Select metrics** — Choose relevant KPIs from the 5 domains
3. **Generate SQL strategy** — Plan the query before writing it
4. **Optimize** — Apply partition pruning, clustering, SAFE_DIVIDE patterns
5. **Interpret** — Translate numbers into business insights

See `SKILL.md` for the full workflow.

---

## Key Constraints

❌ **Never violate these**:
- No `SELECT *` — specify columns explicitly
- No table access outside the 10 allowed tables
- No invented metrics — only the 5 YAML-defined domains
- No division without `SAFE_DIVIDE()`
- No ranking with subqueries — use `QUALIFY` instead

✅ **Always do this**:
- Filter on partition columns first (e.g., `event_date BETWEEN ... AND ...`)
- Use clustering columns in GROUP BY
- `LIMIT 100` for exploration, no limit for final results
- Check `EXPLAIN` plan for queries >1TB scans

---

## Integration with the Agent

The **Vendor Intelligence Agent** (sibling skill) uses this skill as its rulebook:

1. Agent receives user question
2. Agent calls `vendor_analysis_skill()` to generate SQL
3. Agent executes SQL via BigQuery MCP
4. Agent applies reasoning, searches documents, creates dashboards as needed
5. Agent synthesizes final response

**The skill is the source of truth for vendor analysis logic.**

---

## Troubleshooting

### "That table isn't available"
→ You're trying to access a table outside the 10 allowed ones. Check `config/schema/allowed_tables.yaml`.

### "Query timeout on spend_transactions"
→ You didn't partition-prune on `event_date`. See `references/bigquery_optimization.md#partition-pruning`.

### "The metric I need isn't defined"
→ It's not in the 5 YAML files. Propose the closest alternative from the domain or explain what you CAN calculate.

### "Division by zero error"
→ Use `SAFE_DIVIDE(numerator, denominator)` instead of `/`. See `references/bigquery_optimization.md#safe_divide-pattern`.

---

## Learning Path

1. **Start here**: `SKILL.md` — understand the rulebook and constraints
2. **Study metrics**: Each YAML in `config/metrics/` — understand what's computable
3. **Optimize queries**: `references/bigquery_optimization.md` — learn the 5 optimization patterns
4. **Understand frameworks**: `references/vendor_kpis_framework.md` — learn when to use each KPI domain
5. **See the agent**: Try `../vendor-intelligence-agent/SKILL.md` to see multi-tool orchestration

---

## For Developers

### Adding a New Metric

1. Edit the appropriate YAML in `config/metrics/`
2. Add `sql_template` with full query
3. Add to `SKILL.md` in the corresponding domain section
4. Test the query in BigQuery first
5. Update `vendor_kpis_framework.md` with example usage

### Making SQL Faster

See `references/bigquery_optimization.md`:
- Partition pruning (50x cost savings)
- Clustering benefits
- APPROX_COUNT_DISTINCT for cardinality
- QUALIFY over subqueries
- CTE materialization

### Integrating with the Agent

The agent loads this skill via its `orchestration/` folder. No changes needed to this skill to work with the agent — it's designed to be composable.
