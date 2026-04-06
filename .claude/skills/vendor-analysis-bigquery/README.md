# Vendor Analysis Skill (BigQuery MCP Execution)

## Quick Start

This skill provides **scoped, rule-based vendor analysis** that generates optimized BigQuery SQL and **executes it via BigQuery MCP** to provide real-time insights.

**Use this skill when:**
- User asks for vendor spend, performance, or risk analysis with real data
- You need to execute SQL and interpret results automatically
- Single-tool analysis is sufficient (BigQuery only, no dashboards)

**Use the Agent instead when:**
- User asks for visualizations, dashboards, or multi-tool insights
- You need to orchestrate BigQuery + Tableau + Looker + Documents

---

## 📋 Generic Prompts (Copy & Use)

Here are ready-to-use prompts you can run with this skill:

### Financial Health Questions
```
/vendor-analysis What is our total vendor spend this year and
 what percentage is covered by contracts?
```

```
/vendor-analysis Show me the top 10 vendors by spend with their
 contract coverage percentage. Which ones have maverick spend issues?
```

```
/vendor-analysis Compare our top 5 vendors against category benchmarks
 for cost management. Who's performing below target?
```

### Operational Efficiency Questions
```
/vendor-analysis What's our on-time delivery rate this quarter?
 Which vendors are underperforming?
```

```
/vendor-analysis Show vendors ranked by delivery speed (cycle time).
 How many are below the 95% on-time target?
```

```
/vendor-analysis Which vendors have order accuracy issues? Show me
 deliveries with wrong quantities or items.
```

### Risk & Compliance Questions
```
/vendor-analysis Show our geographic concentration risk. How much
 of our spend is in China? What if that country is unavailable?
```

```
/vendor-analysis Which vendors are failing ESG compliance? Show
 the environmental, social, and governance scores.
```

```
/vendor-analysis List of high-risk vendors with low contract compliance.
 Which ones should we audit or replace?
```

### Quality & Performance Questions
```
/vendor-analysis What's our overall quality metrics? Show vendors
 with high defect rates and invoice errors.
```

```
/vendor-analysis Customer satisfaction scores by vendor. Which ones
 have low ratings and need intervention?
```

### Strategic Value Questions
```
/vendor-analysis Which vendors are strategic partners vs transactional?
 Show innovation contributions and alignment scores.
```

```
/vendor-analysis Vendor scorecard: Show all 5 metrics (financial,
 operational, risk, quality, strategic) for our top 5 vendors.
```

---

## Shorthand: Using `/vendor-analysis` Command

For quick access, you can use the `/vendor-analysis` shorthand in VS Code:

```
/vendor-analysis What's our spend by vendor category?
/vendor-analysis Top 5 vendors by on-time delivery rate
/vendor-analysis Vendors with ESG compliance issues
```

This shorthand is configured in [copilot-instructions.md](copilot-instructions.md) and automatically:
1. Routes your query to this skill
2. Generates optimized SQL
3. Executes via BigQuery MCP
4. Returns interpreted results

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

## 🚀 Ready-to-Use Query Templates

Don't want to generate SQL? We have **15 pre-built, copy-paste templates** for every metric:

- **Financial Health**: [Spend Under Management](./examples/financial-health/spend-under-management.sql), [Cost Avoidance](./examples/financial-health/cost-avoidance.sql), [Payment Terms](./examples/financial-health/payment-terms-optimization.sql)
- **Operational Efficiency**: [On-Time Delivery](./examples/operational-efficiency/on-time-delivery-rate.sql), [Cycle Time](./examples/operational-efficiency/supplier-cycle-time.sql), [Order Accuracy](./examples/operational-efficiency/order-accuracy.sql)
- **Risk & Compliance**: [ESG Score](./examples/risk-compliance/esg-compliance-score.sql), [Geographic Risk](./examples/risk-compliance/geographic-concentration-risk.sql), [Contract Compliance](./examples/risk-compliance/contract-compliance-rate.sql)
- **Quality**: [Defect Rate](./examples/quality-performance/defect-rate.sql), [Invoice Accuracy](./examples/quality-performance/invoice-accuracy.sql), [Satisfaction](./examples/quality-performance/customer-satisfaction-score.sql)
- **Strategic Value**: [Innovation](./examples/strategic-value/innovation-contribution.sql), [Partnership Alignment](./examples/strategic-value/partnership-tier-alignment.sql)

👉 **See [examples/README.md](./examples/README.md)** for navigation, workflows, and customization tips.

---

## 📚 Schema Reference: Data Dictionary

Not sure what data is available? Check the **[data-dictionary.md](./data-dictionary.md)**:
- Complete documentation of all 10 BigQuery tables
- Column descriptions with examples
- Common query patterns
- Performance tips & troubleshooting

**Quick table reference**:
| Table | Purpose | Partition | Size |
|-------|---------|-----------|------|
| `procurement.vendors` | Master vendor data | `updated_at` | 2 GB |
| `procurement.spend_transactions` | Line-item spend | `event_date` ⚠️ | 450 GB |
| `procurement.purchase_orders` | PO headers | `po_date` | 120 GB |
| `procurement.contracts` | Contract terms | `created_at` | 8 GB |
| `procurement.invoices` | Invoice data | `invoice_date` | 85 GB |
| `procurement.delivery_receipts` | Delivery tracking | `delivery_date` | 95 GB |
| `procurement.quality_audits` | Quality results | `audit_date` | 45 GB |
| `procurement.risk_assessments` | Risk scores | `assessment_date` | 12 GB |
| `procurement.sustainability_metrics` | ESG data | `measurement_date` | 5 GB |
| `procurement.vendor_interactions` | Communication logs | `interaction_date` | 35 GB |

---

## How It Works (5-Step Workflow)

```
1. User asks a vendor question  
   "Show me vendors with quality issues"

2. Skill clarifies (if needed)  
   "Showing vendors with defect rates above 2%..."

3. Skill generates optimized SQL  
   "SELECT v.vendor_name, defect_rate FROM ..."

4. Skill executes via BigQuery MCP  
   [BigQuery returns results]

5. Skill interprets results  
   "Vendor X has 4.2% defect rate (target 2%), 
    suggesting quality control issues..."
```

---

## Example Usage

### Python with BigQuery MCP

```python
from anthropic import Anthropic

client = Anthropic()

# Load skill
with open('.claude/skills/vendor-analysis-bigquery/SKILL.md') as f:
    skill = f.read()

# User question
user_query = "Which vendors have the highest spend this quarter?"

# Call Claude with the skill + MCP integration
response = client.messages.create(
    model="claude-opus-4-5",
    max_tokens=2048,
    system=f"You are a vendor analysis expert. Use BigQuery MCP to execute queries.\n\n{skill}",
    messages=[{"role": "user", "content": user_query}],
    tools=[
        {
            "name": "bigquery",
            "description": "Execute BigQuery SQL queries",
            "input_schema": {
                "type": "object",
                "properties": {
                    "query": {"type": "string"},
                    "project_id": {"type": "string"}
                }
            }
        }
    ]
)

print(response.content[0].text)
```

**Output**:
```
SQL Query:
SELECT v.vendor_name, SUM(t.amount) as spend ...

[Results from BigQuery]
Vendor         | Spend       | Trend
Acme Corp      | $2,100,000  | ↑ 12%
GlobalParts    | $1,800,000  | ↓ 3%
FastShip       | $1,500,000  | ↑ 8%

Interpretation:
Acme Corp leads with $2.1M (12% growth). This concentration 
suggests dependency risk. Recommend: diversify sourcing for 
critical components or negotiate volume discounts.
```

---

## Example Usage (Simple)

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
