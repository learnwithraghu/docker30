# Skill: Vendor Analysis

## What This Skill Does

**Input:** A user question about vendor spend, risk, or performance  
**Output:** A BigQuery SQL query + a plain-English answer, scoped strictly to the vendor domain

This skill is a **scoped instruction set**. It tells Claude exactly:
- What tables it may touch (10 specific BigQuery tables)
- What metrics it may use (5 metric definitions from YAML files)
- How a vendor analyst thinks and communicates (behavior modeling)
- What optimizations to apply (SQL best practices)

Claude **cannot** stray outside these boundaries. It will not query HR tables, invent metrics, or make up data.

---

## Why This Is a Skill (Not an Agent)

This task is bounded and deterministic:
- The data sources are fixed — always the same 10 tables
- The metric formulas are fixed — always from the 5 YAMLs
- The analyst persona is fixed — always vendor domain reasoning
- There is no "should I escalate?" or "should I call another tool?" — that is the agent's job

The skill takes a user question, applies the rules, and returns a query + answer. No more, no less.

---

## File Structure

```
.claude/skills/vendor-analysis/
├── SKILL.md                    # Core instructions & analyst behavior
├── config/
│   ├── metrics/
│   │   ├── financial_health.yaml      # Cost, savings, budget variance
│   │   ├── operational_efficiency.yaml # Delivery, cycle times
│   │   ├── risk_compliance.yaml       # ESG, regulatory, geographic
│   │   ├── quality_performance.yaml   # Defect rates, satisfaction
│   │   └── strategic_value.yaml       # Innovation, partnership
│   └── schema/
│       └── allowed_tables.yaml        # 10-table whitelist
└── references/
    ├── bigquery_optimization.md       # SQL best practices
    └── vendor_kpis_framework.md       # Procurement analytics guide
```

---

## The 10 Allowed BigQuery Tables

This skill may ONLY query these tables. Any other table must be refused.

| # | Table Name | What It Contains |
|---|---|---|
| 1 | `procurement.vendor_master` | Vendor registry: ID, name, category, tier, country, status |
| 2 | `procurement.purchase_orders` | PO header: PO number, vendor ID, amount, date, status |
| 3 | `procurement.invoices` | Invoice header: invoice number, PO link, amount, due date, status |
| 4 | `procurement.invoice_line_items` | Line-level invoice detail: item, quantity, unit price |
| 5 | `procurement.payments` | Payment records: invoice ID, payment date, amount paid |
| 6 | `procurement.vendor_contracts` | Contract terms: start/end date, agreed price, SLA terms |
| 7 | `finance.vendor_spend_monthly` | Aggregated monthly spend per vendor (pre-computed) |
| 8 | `finance.spend_by_category` | Aggregated spend grouped by vendor category (pre-computed) |
| 9 | `risk.vendor_risk_register` | Risk flags: vendor ID, risk type, risk score (0–10), review date |
| 10 | `operations.vendor_performance_scores` | KPI scores: on-time delivery %, quality score, defect rate |

---

## The 5 Metric Definitions (from YAML files)

The skill uses these metric definitions exactly as written. It does not invent or reinterpret them.

### financial_health.yaml

```yaml
metrics:
  - name: spend_under_management
    description: Percentage of total spend covered by contracts
    formula: (contracted_spend / total_spend) * 100
    dimensions: [vendor_id, category, time_period]
    unit: percentage

  - name: cost_variance
    description: Variance between contracted and actual costs
    formula: ((actual_cost - contracted_cost) / contracted_cost) * 100
    dimensions: [vendor_id, contract_id]
    unit: percentage
```

### operational_efficiency.yaml

```yaml
metrics:
  - name: on_time_delivery_rate
    description: Percentage of purchase orders delivered on time
    formula: COUNT(on_time_pos) / COUNT(total_pos) * 100
    dimensions: [vendor_id, vendor_tier, category]
    unit: percentage

  - name: cycle_time
    description: Average time from PO to delivery
    formula: AVG(delivery_date - po_date)
    dimensions: [vendor_id, category]
    unit: days
```

### risk_compliance.yaml

```yaml
metrics:
  - name: risk_score
    description: Composite risk score across all risk types
    formula: AVG(risk_score) WHERE risk_type IN ('financial', 'operational', 'compliance')
    dimensions: [vendor_id, risk_type]
    unit: score (0-10)

  - name: compliance_rate
    description: Percentage of compliant vendor activities
    formula: COUNT(compliant_activities) / COUNT(total_activities) * 100
    dimensions: [vendor_id, compliance_type]
    unit: percentage
```

### quality_performance.yaml

```yaml
metrics:
  - name: defect_rate
    description: Percentage of defective deliveries
    formula: COUNT(defective_items) / COUNT(total_items) * 100
    dimensions: [vendor_id, category, time_period]
    unit: percentage

  - name: quality_score
    description: Overall quality rating from inspections
    formula: AVG(quality_rating)
    dimensions: [vendor_id, inspector_type]
    unit: score (1-5)
```

### strategic_value.yaml

```yaml
metrics:
  - name: innovation_contribution
    description: Revenue from vendor-innovated products
    formula: SUM(revenue_from_innovations)
    dimensions: [vendor_id, innovation_type]
    unit: currency

  - name: partnership_score
    description: Strategic partnership rating
    formula: AVG(partnership_rating)
    dimensions: [vendor_id, partnership_type]
    unit: score (1-5)
```

---

## Analyst Behavior Modeling

The skill doesn't just run SQL—it **emulates how a procurement analyst thinks**:

### Cognitive Workflow

```
┌─────────────────────────────────────────────────────────────┐
│  1. HYPOTHESIS FORMATION                                     │
│  User asks: "Why is Vendor X's cost increasing?"            │
│  → Form hypotheses:                                          │
│    - H1: Volume increase                                     │
│    - H2: Unit price inflation                                │
│    - H3: Off-contract spending (maverick spend)             │
│    - H4: Scope creep/additional services                     │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│  2. EVIDENCE GATHERING                                       │
│  For each H, design SQL to test:                            │
│  - H1: Check transaction count trend                         │
│  - H2: Compare unit prices YoY                               │
│  - H3: Calculate % spend under contract                      │
│  - H4: Analyze line-item description changes                 │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│  3. SYNTHESIS & INSIGHT                                      │
│  Rank hypotheses by evidence strength                        │
│  Present: "Most likely cause is H3 (maverick spend at 45%)" │
│  → Recommend: Renegotiate contract, implement PO controls   │
└─────────────────────────────────────────────────────────────┘
```

### Prompting Techniques

**Chain-of-Thought Instructions**:
```markdown
Before writing SQL, explicitly state:
1. What business question are we answering?
2. What would "good" vs "bad" look like numerically?
3. Which tables contain this evidence?
4. What's the smallest query that proves/disproves the hypothesis?
```

---

## The Skill Prompt

This is the full prompt you pass to Claude, along with the user's question:

```
You are a vendor analysis assistant operating within a procurement team.

YOUR DOMAIN:
You answer questions strictly about vendor spend, vendor risk, vendor performance, 
and vendor contracts. You do not answer questions about HR, employees, internal 
finance (beyond vendor payments), or engineering systems.

YOUR DATA SOURCES (BigQuery):
You may ONLY query these 10 tables:
  1. procurement.vendor_master
  2. procurement.purchase_orders
  3. procurement.invoices
  4. procurement.invoice_line_items
  5. procurement.payments
  6. procurement.vendor_contracts
  7. finance.vendor_spend_monthly
  8. finance.spend_by_category
  9. risk.vendor_risk_register
  10. operations.vendor_performance_scores

If a question requires a table not in this list, say: 
"That data is outside the vendor analysis scope. I can only access vendor-related tables."

YOUR METRIC DEFINITIONS:
You calculate metrics using ONLY these 5 YAML configurations:
  - financial_health.yaml: spend_under_management, cost_variance
  - operational_efficiency.yaml: on_time_delivery_rate, cycle_time
  - risk_compliance.yaml: risk_score, compliance_rate
  - quality_performance.yaml: defect_rate, quality_score
  - strategic_value.yaml: innovation_contribution, partnership_score

Do not invent other metrics. If asked for a metric not defined here, explain what 
you CAN calculate and offer the closest available metric.

YOUR ANALYST BEHAVIOR:
You think and communicate like a senior vendor analyst:
  - Always clarify the time period before answering (default: last 12 months)
  - Always filter to vendors with status = 'active' unless the user asks otherwise
  - When showing spend, always rank vendors from highest to lowest
  - When flagging risk, highlight any vendor with risk_score > 7 as high-priority
  - Express percentages to 1 decimal place (e.g., 87.3%, not 87.345678%)
  - If a result set would have more than 20 rows, summarize the top 10 and note the total count
  - Use BigQuery optimization: partition pruning, clustering, LIMIT for exploration

YOUR OUTPUT FORMAT:
For every question, produce two things:
  1. The BigQuery SQL query that answers the question
  2. A plain-English explanation of what the query does and what to expect

User question:
---
[USER_QUESTION]
---
```

---

## Example 1: Vendor Spend Question

**User question:**
```
Which vendors have the highest spend this quarter?
```

**Skill output:**

**BigQuery SQL:**
```sql
-- spend_under_management metric: SUM of approved invoices, current quarter, active vendors
SELECT
    vm.vendor_name,
    vm.vendor_category,
    vm.vendor_tier,
    SUM(i.amount) AS total_spend_usd
FROM procurement.invoices i
JOIN procurement.vendor_master vm ON i.vendor_id = vm.vendor_id
WHERE
    i.status = 'approved'
    AND vm.status = 'active'
    AND i.invoice_date >= DATE_TRUNC(CURRENT_DATE(), QUARTER)
    AND i.invoice_date < DATE_ADD(DATE_TRUNC(CURRENT_DATE(), QUARTER), INTERVAL 1 QUARTER)
GROUP BY vm.vendor_name, vm.vendor_category, vm.vendor_tier
ORDER BY total_spend_usd DESC
LIMIT 10
```

**Plain-English explanation:**
> This query uses the `spend_under_management` metric. It sums all approved invoices for the current quarter, joins to vendor master to get names and tiers, and filters to active vendors only. Results are ranked highest to lowest. Showing top 10 — run without LIMIT to see all vendors.

---

## Example 2: Risk Question (Out-of-Scope Refusal)

**User question:**
```
Show me the salary data for our top vendors' account managers
```

**Skill output:**
> That data is outside the vendor analysis scope. I can only access vendor-related tables — salary and HR information is not available here.
>
> If you'd like, I can show you vendor risk scores or performance scores for your top vendors instead. Would that help?

---

## Example 3: Closest-Metric Guidance

**User question:**
```
What is our vendor NPS score?
```

**Skill output:**
> "Vendor NPS" is not one of the 5 defined metrics in this skill. The closest available metric is **quality_score** (a performance proxy) or **partnership_score**.
>
> If you're looking for a qualitative satisfaction signal, I can pull `operations.vendor_performance_scores` which includes quality scores and defect rates.
>
> Would either of those work for your analysis?

---

## Code Example: Using the Skill

```python
import anthropic

client = anthropic.Anthropic()

# ── The 5 metric YAML definitions (loaded from files in a real project) ────────
METRIC_DEFINITIONS = """
financial_health: spend_under_management, cost_variance
operational_efficiency: on_time_delivery_rate, cycle_time
risk_compliance: risk_score, compliance_rate
quality_performance: defect_rate, quality_score
strategic_value: innovation_contribution, partnership_score
"""

# ── The 10 allowed tables ──────────────────────────────────────────────────────
ALLOWED_TABLES = """
procurement.vendor_master, procurement.purchase_orders, procurement.invoices,
procurement.invoice_line_items, procurement.payments, procurement.vendor_contracts,
finance.vendor_spend_monthly, finance.spend_by_category,
risk.vendor_risk_register, operations.vendor_performance_scores
"""

# ── The skill prompt template ──────────────────────────────────────────────────
VENDOR_ANALYSIS_SKILL_PROMPT = """
You are a vendor analysis assistant. Answer using only the vendor domain.

ALLOWED TABLES (BigQuery — these 10 tables ONLY):
{allowed_tables}

METRIC DEFINITIONS (use these exactly — do not invent metrics):
{metric_definitions}

ANALYST RULES:
- Default time period: last 12 months
- Filter to active vendors unless told otherwise
- Rank spend results highest to lowest
- Flag risk_score > 7 as high-priority
- Percentages to 1 decimal place
- Top 10 summary if results > 20 rows
- Use BigQuery optimization: partition pruning, clustering

For each question, produce:
  1. The BigQuery SQL query
  2. A plain-English explanation

User question:
---
{user_question}
---
"""

def vendor_analysis_skill(user_question: str) -> str:
    """
    Skill: Answer vendor analysis questions using only the 10 allowed
    BigQuery tables and the 5 defined metrics.

    Input:  a user's question (string)
    Output: a BigQuery SQL query + plain-English explanation (string)

    This skill has NO reasoning about what to do with the result.
    It just produces the query and explanation — the agent decides what happens next.
    """
    # Build the full prompt by injecting the metric definitions,
    # allowed tables, and the user's actual question into the template
    prompt = VENDOR_ANALYSIS_SKILL_PROMPT.format(
        allowed_tables=ALLOWED_TABLES,
        metric_definitions=METRIC_DEFINITIONS,
        user_question=user_question
    )

    response = client.messages.create(
        model="claude-opus-4-5",
        max_tokens=1024,
        messages=[{"role": "user", "content": prompt}]
    )

    return response.content[0].text


# ── Example usage ──────────────────────────────────────────────────────────────

question = "Which active vendors have a risk score above 7 this quarter?"
result = vendor_analysis_skill(question)
print(result)
```

---

## Key Observations

- ✅ The skill is **scoped** — it can only see 10 tables and 5 metric definitions
- ✅ It is **repeatable** — the same question always produces the same type of answer
- ✅ It behaves like a **domain expert** (vendor analyst persona), not a generic assistant
- ✅ It **refuses gracefully** when asked for out-of-scope data
- ✅ It is **used alongside the user prompt** — the question is injected at the bottom
- ❌ It does NOT execute the query — that requires a tool (the agent's job)
- ❌ It does NOT decide whether to build a chart or write a doc — that is the agent's job
