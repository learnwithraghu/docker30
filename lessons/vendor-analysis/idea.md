I'll create a comprehensive follow-up document covering vendor analysis skills and multi-tool agents. This will build on the previous README's technical foundations.
I'll now create a comprehensive 20-minute follow-up document covering vendor analysis skills and multi-tool agents. This builds on the previous technical foundations.

---

# Advanced Claude Skills: Vendor Analysis & Multi-Tool Agents

> **Reading time:** ~20 minutes  
> **Prerequisites:** Understanding of Claude Skills architecture (see previous README)  
> **Audience:** Data engineers, procurement analysts, AI infrastructure teams

---

## Table of Contents
1. [Introduction: From Single-Tool to Multi-Tool Intelligence](#1-introduction-from-single-tool-to-multi-tool-intelligence)
2. [Part 1: The Vendor Analysis Skill (BigQuery-Only)](#2-part-1-the-vendor-analysis-skill-bigquery-only)
3. [Metrics Configuration: The 5 YAML Files](#3-metrics-configuration-the-5-yaml-files)
4. [Analyst Behavior Modeling](#4-analyst-behavior-modeling)
5. [Part 2: The Multi-Tool Vendor Intelligence Agent](#5-part-2-the-multi-tool-vendor-intelligence-agent)
6. [Tool Orchestration Architecture](#6-tool-orchestration-architecture)
7. [Context Management Across Tools](#7-context-management-across-tools)
8. [Building the Agent: Implementation Guide](#8-building-the-agent-implementation-guide)
9. [Advanced Patterns: Reasoning & Delegation](#9-advanced-patterns-reasoning--delegation)
10. [Production Deployment & Monitoring](#10-production-deployment--monitoring)

---

## 1. Introduction: From Single-Tool to Multi-Tool Intelligence

The previous README established how individual Claude Skills work through progressive disclosure. Now we'll advance to **two complex scenarios**:

| Scenario | Complexity | Tools | Use Case |
|----------|-----------|-------|----------|
| **Vendor Analysis Skill** | Intermediate | BigQuery only | Structured SQL analytics on vendor data |
| **Vendor Intelligence Agent** | Advanced | BigQuery + Tableau + Looker + Docs | Cross-platform vendor research & visualization |

**Key insight**: Moving from a skill to an agent isn't just adding tools—it's adding **orchestration logic**, **cross-tool context preservation**, and **autonomous decision-making capabilities**.

---

## 2. Part 1: The Vendor Analysis Skill (BigQuery-Only)

This skill demonstrates **constrained domain expertise**—it knows everything about vendor analysis but only within BigQuery.

### Architecture Overview

```
User Query → Skill Trigger → BigQuery Schema Load → SQL Generation → Results → Analysis
```

### File Structure

```
.claude/skills/vendor-analysis-bigquery/
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

### The SKILL.md File

```markdown
---
name: vendor-analysis-bigquery
description: Analyze vendor performance using BigQuery SQL. Use when user asks about vendor metrics, supplier performance, spend analysis, or procurement KPIs. Requires BigQuery access.
---

# Vendor Analysis Skill (BigQuery)

## Role Definition
You are a Senior Procurement Data Analyst with 10+ years experience in vendor performance analytics. You specialize in translating business questions about vendors into optimized BigQuery SQL.

## Domain Expertise Areas
- Spend analysis and cost optimization 
- Supplier performance scorecards 
- Risk assessment and compliance monitoring 
- Contract lifecycle analytics 

## Constraints & Rules

### 1. Table Access Limitations
You may ONLY query these 10 tables:
1. `procurement.vendors` - Master vendor data
2. `procurement.spend_transactions` - Line-item spend
3. `procurement.purchase_orders` - PO headers and status
4. `procurement.contracts` - Contract terms and metadata
5. `procurement.invoices` - Invoice processing data
6. `procurement.delivery_receipts` - Goods receipt confirmation
7. `procurement.quality_audits` - Inspection results
8. `procurement.risk_assessments` - Risk scores and factors
9. `procurement.sustainability_metrics` - ESG data
10. `procurement.vendor_interactions` - Communication logs

### 2. Query Optimization Mandates 
- **NEVER use `SELECT *`** - Always specify columns explicitly
- **Always filter on partition columns first** (event_date, vendor_id)
- **Use clustering columns in WHERE clauses** (category, region)
- **Limit initial exploration to 100 rows** (`LIMIT 100`)
- **Materialize intermediate results** for complex multi-step analysis

### 3. Analyst Behavior Protocol

When receiving a vendor question:

1. **Clarify Intent** (1-2 questions max)
   - "Are you looking at specific vendors or category-wide trends?"
   - "What time period should I analyze? (default: last 12 months)"

2. **Select Relevant Metrics** (from config/metrics/)
   - Load appropriate YAML metric definitions
   - Explain which KPIs apply and why

3. **Generate SQL Strategy**
   - Start with partition pruning (date filters)
   - Join in order: small tables first (vendors) → large tables (transactions)
   - Use `APPROX_COUNT_DISTINCT` for large cardinality estimates
   - Prefer `QUALIFY` over subqueries for window functions

4. **Execute & Validate**
   - Run explain plan first for large scans (>1TB)
   - Validate row counts match expectations
   - Check for NULL handling in critical fields

5. **Interpret Results**
   - Translate SQL output to business insights
   - Flag anomalies (sudden spend drops, quality spikes)
   - Recommend actions based on procurement best practices 

## Execution Flow

### Phase 1: Discovery
```sql
-- Always start with vendor context
SELECT 
  vendor_id,
  vendor_name,
  category,
  risk_tier,
  contract_value
FROM procurement.vendors
WHERE vendor_id = @vendor_id
```

### Phase 2: Metric Calculation
Load metrics from YAML and translate to SQL:

```sql
-- Example: Spend Under Management (from financial_health.yaml)
WITH spend_base AS (
  SELECT 
    vendor_id,
    SUM(transaction_amount) as total_spend,
    SUM(CASE WHEN contract_id IS NOT NULL THEN transaction_amount END) as contracted_spend
  FROM procurement.spend_transactions
  WHERE event_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 12 MONTH)
    AND vendor_id = @vendor_id
  GROUP BY 1
)
SELECT 
  vendor_id,
  total_spend,
  contracted_spend,
  SAFE_DIVIDE(contracted_spend, total_spend) * 100 as spend_under_management_pct
FROM spend_base
```

### Phase 3: Benchmarking
Compare against category peers:
```sql
-- Category percentile ranking
SELECT 
  PERCENT_RANK() OVER (PARTITION BY category ORDER BY on_time_delivery_rate) as delivery_percentile
FROM procurement.operational_metrics
```

## Error Handling

If query fails:
1. Check table existence in allowed list
2. Verify partition column usage
3. Suggest schema inspection: `DESCRIBE procurement.transactions`
4. Escalate to user with specific error and remediation

## Reference Materials
- See `references/bigquery_optimization.md` for partitioning strategies 
- See `references/vendor_kpis_framework.md` for metric definitions 
```

---

## 3. Metrics Configuration: The 5 YAML Files

These files define **computable metrics** that the skill can map to SQL. They stay in `config/metrics/` and are loaded on-demand.

### financial_health.yaml

```yaml
metrics:
  - name: spend_under_management
    description: Percentage of spend covered by negotiated contracts
    formula: (contracted_spend / total_spend) * 100
    target: "> 85%"
    tables: [spend_transactions, contracts]
    sql_template: |
      SELECT 
        SAFE_DIVIDE(
          SUM(CASE WHEN c.contract_id IS NOT NULL THEN t.amount END),
          SUM(t.amount)
        ) * 100 as pct
      FROM procurement.spend_transactions t
      LEFT JOIN procurement.contracts c ON t.contract_id = c.contract_id
      WHERE t.event_date BETWEEN @start_date AND @end_date
      
  - name: cost_avoidance
    description: Estimated savings from negotiation vs market rates
    formula: sum((market_rate - negotiated_rate) * volume)
    target: "> 5% of spend"
    tables: [spend_transactions, contracts, market_rates]
    
  - name: payment_terms_optimization
    description: Working capital impact from payment terms
    formula: avg(payment_term_days) * daily_spend
    target: "Maximize without damaging supplier relations"
    tables: [invoices, vendors]
```

### operational_efficiency.yaml

```yaml
metrics:
  - name: on_time_delivery_rate
    description: Percentage of orders delivered by promised date 
    formula: (on_time_deliveries / total_deliveries) * 100
    target: "> 95%"
    tables: [purchase_orders, delivery_receipts]
    sql_template: |
      SELECT 
        COUNTIF(d.actual_delivery <= p.promised_date) / COUNT(*) * 100 as rate
      FROM procurement.purchase_orders p
      JOIN procurement.delivery_receipts d ON p.po_id = d.po_id
      WHERE p.vendor_id = @vendor_id
      
  - name: supplier_cycle_time
    description: Days from PO issuance to delivery 
    formula: AVG(DATE_DIFF(delivery_date, po_date, DAY))
    target: "< industry benchmark"
    tables: [purchase_orders, delivery_receipts]
    
  - name: order_accuracy
    description: Rate of correct quantity/item deliveries
    formula: (accurate_orders / total_orders) * 100
    target: "> 98%"
    tables: [purchase_orders, delivery_receipts, quality_audits]
```

### risk_compliance.yaml

```yaml
metrics:
  - name: esg_compliance_score
    description: Weighted score of environmental, social, governance factors 
    formula: (environmental_score * 0.4) + (social_score * 0.3) + (governance_score * 0.3)
    target: "> 80/100"
    tables: [risk_assessments, sustainability_metrics]
    
  - name: geographic_concentration_risk
    description: Dependency on single region/country
    formula: MAX(spend_by_country) / total_spend
    target: "< 40% for any single country"
    tables: [vendors, spend_transactions]
    
  - name: contract_compliance_rate
    description: Adherence to contracted terms vs actuals
    formula: (compliant_transactions / total_transactions) * 100
    target: "> 90%"
    tables: [contracts, spend_transactions]
```

### quality_performance.yaml

```yaml
metrics:
  - name: defect_rate
    description: Percentage of deliveries failing quality standards 
    formula: (defective_units / total_units) * 100
    target: "< 2%"
    tables: [delivery_receipts, quality_audits]
    
  - name: invoice_accuracy
    description: Rate of correct billing vs PO/contract
    formula: (accurate_invoices / total_invoices) * 100
    target: "> 98%"
    tables: [invoices, purchase_orders, contracts]
    
  - name: customer_satisfaction_score
    description: Internal stakeholder rating of vendor
    formula: AVG(satisfaction_rating)
    target: "> 4.0/5.0"
    tables: [vendor_interactions]
```

### strategic_value.yaml

```yaml
metrics:
  - name: innovation_contribution
    description: Process improvements or cost savings initiated by vendor 
    formula: COUNT(innovation_submissions) / year
    target: "> 2 per year for strategic vendors"
    tables: [vendor_interactions]
    
  - name: partnership_tier_alignment
    description: Vendor performance vs strategic importance
    formula: CASE WHEN tier = 'strategic' AND performance_score > 80 THEN 'aligned' ELSE 'misaligned'
    target: "100% of strategic vendors > 80 score"
    tables: [vendors, vendor_scorecard]
```

### schema/allowed_tables.yaml

```yaml
table_whitelist:
  - name: procurement.vendors
    description: Master vendor registry
    partition_column: updated_at
    cluster_columns: [category, region, risk_tier]
    estimated_size_gb: 2
    
  - name: procurement.spend_transactions
    description: Individual spend transactions
    partition_column: event_date
    cluster_columns: [vendor_id, category, cost_center]
    estimated_size_gb: 450
    requires_filter: true  # Must filter on event_date
    
  - name: procurement.purchase_orders
    description: Purchase order headers
    partition_column: po_date
    cluster_columns: [vendor_id, status, category]
    estimated_size_gb: 120
    
  # ... remaining 7 tables with metadata
```

---

## 4. Analyst Behavior Modeling

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

### Prompting Techniques in SKILL.md

**Chain-of-Thought Instructions**:
```markdown
Before writing SQL, explicitly state:
1. What business question are we answering?
2. What would "good" vs "bad" look like numerically?
3. Which tables contain this evidence?
4. What's the smallest query that proves/disproves the hypothesis?
```

**Few-Shot SQL Patterns**:
```markdown
## SQL Pattern: Year-over-Year Comparison
When comparing periods, always use:
- Same number of days (28-day periods avoid month-length bias)
- Weekday alignment (exclude weekends for B2B vendors)
- Partition pruning (push date filters to subquery)

Example:
```sql
WITH current_period AS (
  SELECT * FROM procurement.spend_transactions
  WHERE event_date BETWEEN '2024-01-01' AND '2024-01-28'
),
prior_period AS (
  SELECT * FROM procurement.spend_transactions  
  WHERE event_date BETWEEN '2023-01-01' AND '2023-01-28'
)
-- comparison logic
```
```

---

## 5. Part 2: The Multi-Tool Vendor Intelligence Agent

Now we evolve from a **skill** (reactive, single-tool) to an **agent** (proactive, multi-tool).

### Capabilities Comparison

| Capability | BigQuery Skill | Full Agent |
|-----------|---------------|------------|
| **Data sources** | BigQuery only | BigQuery + Tableau + Looker + Docs |
| **Visualization** | Text tables | Native dashboard updates |
| **Research** | Structured queries | Unstructured document analysis |
| **Reasoning** | SQL generation | Cross-tool hypothesis testing |
| **Action** | Returns data | Updates dashboards, sends alerts |
| **Autonomy** | Executes on request | Proactive monitoring & recommendations |

### Architecture: The Agent Loop

```
┌─────────────┐     ┌──────────────┐     ┌─────────────────┐
│   USER      │────▶│   ORCHESTRATOR│────▶│   TOOL SELECTOR │
│   REQUEST   │     │   (Claude)    │     │   (Planning)    │
└─────────────┘     └──────────────┘     └─────────────────┘
                                                  │
                    ┌─────────────────────────────┼─────────────┐
                    │                             │             │
                    ▼                             ▼             ▼
            ┌─────────────┐              ┌─────────────┐ ┌─────────────┐
            │  BIGQUERY   │              │   TABLEAU   │ │   LOOKER    │
            │  (Data)     │              │ (Dashboards)│ │  (Explores) │
            └─────────────┘              └─────────────┘ └─────────────┘
                    │                             │             │
                    └─────────────────────────────┼─────────────┘
                                                  │
                                                  ▼
                                         ┌─────────────┐
                                         │   DOCUMENTS │
                                         │  (Research) │
                                         └─────────────┘
                                                  │
                                                  ▼
                                         ┌─────────────────┐
                                         │  SYNTHESIS &    │
                                         │  RESPONSE       │
                                         └─────────────────┘
```

---

## 6. Tool Orchestration Architecture

### Tool Definitions (MCP Servers)

The agent uses **4 MCP tools**, each requiring careful context management:

```yaml
# Tool 1: BigQuery MCP
name: bigquery_query
description: Execute SQL queries against BigQuery. Use for structured data analysis.
cost: 15 tokens per call (schema) + query results
context_preserved: false  # Stateless, must pass full context each time

# Tool 2: Tableau MCP  
name: tableau_update
description: Update dashboards, workbooks, or extract data. Use for visualization.
cost: 25 tokens per call
context_preserved: true   # Dashboard ID persists in session

# Tool 3: Looker MCP
name: looker_explore
description: Query Looker explores and run Looks. Use for semantic layer analytics.
cost: 20 tokens per call
context_preserved: true   # Connection persists

# Tool 4: Document MCP
name: document_search
description: Search and analyze unstructured documents (contracts, emails, notes).
cost: 30 tokens per 1000 pages
context_preserved: false  # Each search is independent
```

### The Agent SKILL.md

```markdown
---
name: vendor-intelligence-agent
description: Autonomous vendor analysis agent with access to BigQuery, Tableau, Looker, and documents. Use for complex vendor research requiring data, visualization, and document analysis.
---

# Vendor Intelligence Agent

## Agent Manifest

You are an autonomous procurement intelligence agent. Your goal is to provide comprehensive vendor insights by orchestrating multiple tools. You can:

1. **Query** structured data (BigQuery)
2. **Visualize** findings (Tableau)
3. **Explore** semantic models (Looker)
4. **Research** unstructured documents (Docs)

## Orchestration Rules

### Rule 1: Tool Selection Strategy

For any request, determine the **information architecture**:

| Need | Primary Tool | Secondary Tool |
|------|-------------|----------------|
| Raw transaction analysis | BigQuery | Looker (for semantic context) |
| Executive dashboard update | Tableau | BigQuery (for data validation) |
| Contract terms research | Documents | BigQuery (for spend correlation) |
| Trend exploration | Looker | Tableau (for dashboard creation) |

### Rule 2: Context Preservation

**State Management Strategy**:

```python
# Pseudo-code for context handling
session_state = {
    "current_vendor_id": None,      # Persist across tool calls
    "active_dashboard": None,       # Tableau workbook ID
    "looker_explore_context": {},   # Filter states
    "last_query_results": None,     # For follow-up questions
    "document_insights": []         # Accumulated findings
}
```

**Critical**: When switching tools, explicitly pass context:

```
BigQuery Result: "Vendor X spend increased 40% in Q3"
→ Tableau Action: "Update Vendor Performance dashboard highlighting Q3 anomaly for Vendor X"
→ Document Action: "Search for Q3 contract amendments or pricing changes for Vendor X"
```

### Rule 3: Cost-Aware Execution

Token budget per request: **5,000 tokens maximum**

| Action | Token Cost | When to Use |
|--------|-----------|-------------|
| BigQuery: Simple aggregation | 200 | Quick validation |
| BigQuery: Complex multi-table | 800 | Deep analysis |
| Tableau: Update existing viz | 400 | Communication |
| Tableau: Create new workbook | 1,500 | Rare, high-value only |
| Looker: Run existing Look | 300 | Standard reporting |
| Looker: New explore | 600 | Ad-hoc investigation |
| Documents: Search (100 docs) | 500 | Contract research |
| Documents: Deep analysis (1000 docs) | 3,000 | Due diligence only |

**Optimization**: Always try BigQuery first (cheapest). Escalate to documents only when structured data is insufficient.

## Execution Patterns

### Pattern 1: Anomaly Investigation

**Trigger**: "Why did Vendor X's cost spike?"

```yaml
steps:
  1. bigquery_query:
     sql: "SELECT monthly_spend FROM transactions WHERE vendor_id = X ORDER BY month"
     goal: "Quantify the spike"
     
  2. looker_explore:
     explore: "vendor_performance"
     filters: {"vendor_id": "X", "timeframe": "last_6_months"}
     goal: "Get business context (category, PO count)"
     
  3. document_search:
     query: "Vendor X pricing change contract amendment 2024"
     goal: "Find contractual explanation"
     
  4. tableau_update:
     dashboard: "Vendor Spend Anomalies"
     action: "highlight_vendor"
     params: {"vendor_id": "X", "anomaly_date": "2024-03"}
     goal: "Visualize for stakeholders"
     
  5. synthesis:
     format: "Executive summary with data evidence, document citations, and dashboard link"
```

### Pattern 2: Strategic Sourcing

**Trigger**: "Should we renew Vendor Y or switch to Vendor Z?"

```yaml
steps:
  1. parallel_execution:
     - bigquery_query: "Compare 3-year spend, quality scores, delivery metrics for Y vs Z"
     - document_search: "Contract terms, SLAs, exit clauses for both vendors"
     
  2. looker_explore:
     explore: "category_benchmarks"
     filters: {"category": "current_category"}
     goal: "Compare against category averages"
     
  3. conditional:
     if: "Contract expires < 90 days"
     then:
       - document_search: "Renewal terms, price escalation clauses"
       - bigquery_query: "Calculate switching costs (setup, training, transition)"
       
  4. tableau_update:
     dashboard: "Sourcing Decisions"
     action: "create_comparison_view"
     
  5. synthesis:
     format: "Recommendation matrix with quantitative scores and risk assessment"
```

### Pattern 3: Proactive Monitoring (Autonomous)

**Trigger**: Scheduled execution (no user prompt)

```yaml
schedule: "weekly"
steps:
  1. bigquery_query:
     sql: "SELECT vendor_id, spend_variance FROM weekly_monitoring WHERE abs(variance) > 0.2"
     goal: "Detect >20% spend changes"
     
  2. for_each: vendor in results
     - looker_explore: "Quick health check"
     - conditional:
         if: "risk_score > 7"
         then:
           - document_search: "Recent communications"
           - tableau_update: "Add to Risk Watch dashboard"
           - notify: "Procurement manager"
```

## Cross-Tool Context Passing

### Critical: Avoid Information Silos

**Bad** (loses context):
```
BigQuery: "Spend is $5M"
Tableau: "Update dashboard"  # Which vendor? What metric?
```

**Good** (preserves context):
```
BigQuery: "Vendor X (ID: 12345) Q3 spend is $5M, up 40% YoY"
Tableau: "Update 'Vendor Performance' dashboard, Sheet 'Spend Trends', 
          highlight Vendor ID 12345 Q3 data point with annotation '40% increase'"
```

### Context Compression Strategy

When tool outputs are large, compress for downstream tools:

```yaml
bigquery_output: "10,000 rows of transaction data"
compression: "Summarize to key statistics for tableau"
tableau_input: "Vendor X: $5M (+40%), 3 categories affected, top category: Hardware (+65%)"
```

---

## 7. Context Management Across Tools

### The Multi-Tool Context Problem

Each tool adds to context window usage. With 4 tools, we risk hitting limits quickly.

**Baseline Costs** (per our previous analysis):
- BigQuery MCP: ~15K tokens (schema + query capabilities)
- Tableau MCP: ~25K tokens
- Looker MCP: ~20K tokens  
- Document MCP: ~30K tokens
- **Total: ~90K tokens** just for tool definitions!

### Solution: Progressive Tool Loading

```yaml
strategy: "Lazy tool initialization"

initial_state:
  available_tools: ["bigquery_query"]  # Only load cheapest tool
  
triggers:
  - condition: "user_mentions dashboard OR visualization"
    action: "load_tableau_mcp"
    cost: "+25K tokens"
    
  - condition: "user_mentions explore OR semantic model"
    action: "load_looker_mcp"  
    cost: "+20K tokens"
    
  - condition: "user_mentions contract OR document"
    action: "load_document_mcp"
    cost: "+30K tokens"
```

### Session Memory Management

```yaml
# Keep in context permanently (small, critical)
persistent_context:
  - Current vendor ID being analyzed
  - Active investigation hypothesis
  - User role (executive vs analyst)

# Keep in context temporarily (prune after 3 turns)
working_memory:
  - Last query results summary
  - Intermediate calculations
  - Tool-specific session IDs

# Offload to filesystem (load on demand)
external_memory:
  - Full query results (save to /tmp/)
  - Large document extracts
  - Historical analysis
```

---

## 8. Building the Agent: Implementation Guide

### Step 1: Directory Structure

```
.claude/
├── skills/
│   └── vendor-intelligence-agent/
│       ├── SKILL.md                    # This manifest
│       ├── tools/
│       │   ├── bigquery/
│       │   │   ├── schema_cache.yaml   # Table schemas (updated weekly)
│       │   │   ├── query_templates/    # Reusable SQL patterns
│       │   │   └── cost_tracker.yaml   # Query cost history
│       │   ├── tableau/
│       │   │   ├── workbook_registry.yaml
│       │   │   └── update_procedures/
│       │   ├── looker/
│       │   │   ├── explore_definitions.yaml
│       │   │   └── look_registry.yaml
│       │   └── documents/
│       │       ├── index_config.yaml   # Searchable doc repositories
│       │       └── extraction_rules/   # Entity extraction patterns
│       ├── orchestration/
│       │   ├── patterns/               # Common execution flows
│       │   │   ├── anomaly_detection.yaml
│       │   │   ├── strategic_sourcing.yaml
│       │   │   └── compliance_audit.yaml
│       │   └── state_machine.yaml      # Agent state transitions
│       └── references/
│           ├── procurement_frameworks/
│           └── vendor_management_best_practices/
```

### Step 2: Tool Configuration

**~/.claude/mcp-servers.json**:
```json
{
  "bigquery": {
    "command": "python -m bigquery_mcp_server",
    "env": {
      "GOOGLE_APPLICATION_CREDENTIALS": "/path/to/creds.json",
      "PROJECT_ID": "procurement-data-warehouse",
      "ALLOWED_DATASETS": "procurement,vendors,contracts"
    }
  },
  "tableau": {
    "command": "node tableau-mcp-server/index.js",
    "env": {
      "TABLEAU_SERVER": "https://tableau.company.com",
      "SITE_ID": "ProcurementAnalytics"
    }
  },
  "looker": {
    "command": "python looker_mcp/main.py",
    "env": {
      "LOOKER_BASE_URL": "https://looker.company.com:19999",
      "CLIENT_ID": "claude_agent"
    }
  },
  "documents": {
    "command": "python document_mcp/server.py",
    "env": {
      "DOC_REPOSITORIES": "contracts:s3://contracts-bucket,emails:gmail-api,notes:confluence-api"
    }
  }
}
```

### Step 3: State Machine Definition

```yaml
# orchestration/state_machine.yaml
states:
  - IDLE
  - GATHERING_DATA
  - ANALYZING
  - VISUALIZING
  - RESEARCHING_DOCS
  - SYNTHESIZING
  - COMPLETE

transitions:
  IDLE:
    on_user_request: GATHERING_DATA
    
  GATHERING_DATA:
    on_data_received: ANALYZING
    on_insufficient_data: RESEARCHING_DOCS
    
  ANALYZING:
    on_anomaly_detected: VISUALIZING
    on_needs_context: RESEARCHING_DOCS
    on_complete: SYNTHESIZING
    
  VISUALIZING:
    on_dashboard_updated: SYNTHESIZING
    
  RESEARCHING_DOCS:
    on_docs_found: ANALYZING
    on_no_docs: SYNTHESIZING
    
  SYNTHESIZING:
    on_complete: COMPLETE
    
  COMPLETE:
    on_follow_up: GATHERING_DATA
    on_new_request: IDLE
```

### Step 4: Prompt Engineering for Tool Use

**System Prompt Addition** (injected when agent loads):

```markdown
## Tool Use Protocol

When using tools, follow this exact format:

### 1. Tool Selection Justification
Before calling any tool, state:
- "I need [capability] because [reason]"
- "The best tool for this is [tool_name] because [comparison with alternatives]"

### 2. Parameter Specification
Provide all parameters explicitly:
```yaml
tool: bigquery_query
parameters:
  sql: "SELECT ..."  # Complete, valid SQL
  timeout: 30s
  max_results: 1000
context_from_previous: "From Tableau step, I know vendor_id = 12345"
```

### 3. Result Interpretation
After receiving results:
- Validate: "Results show X rows, which matches expectation Y"
- Connect: "This relates to [previous finding] by..."
- Decide: "Next I should [action] because [reasoning]"
```

---

## 9. Advanced Patterns: Reasoning & Delegation

### Pattern 1: Subagent Delegation

For complex multi-vendor analysis, delegate to specialized subagents:

```yaml
orchestration:
  parent_agent: vendor-intelligence-agent
  
  subagents:
    - name: "sql-optimizer"
      model: "haiku"  # Cheaper for SQL generation
      task: "Generate optimal BigQuery SQL"
      handoff_context: ["schema_info", "metric_definitions"]
      
    - name: "document-analyst"
      model: "sonnet"
      task: "Extract contract terms and risks"
      handoff_context: ["vendor_name", "contract_ids"]
      
    - name: "visualization-designer"
      model: "sonnet"
      task: "Design Tableau dashboard updates"
      handoff_context: ["key_metrics", "anomaly_points"]

delegation_flow:
  1: "Parent analyzes request and identifies parallel workstreams"
  2: "Spawn subagents with specific contexts (not full history)"
  3: "Collect results and synthesize final response"
  4: "Update shared state for future reference"
```

**Token Savings**: Subagents use ~2K tokens each vs 15K for full context.

### Pattern 2: Hypothesis-Driven Reasoning

```markdown
## Reasoning Framework: "Investigate like an Analyst"

When presented with a vendor question:

1. **Generate Hypotheses** (divergent thinking)
   - List 4-6 possible explanations
   - Prioritize by likelihood and data availability

2. **Design Falsification Tests** (critical thinking)
   - For each hypothesis, define what data would disprove it
   - Start with tests that eliminate multiple hypotheses

3. **Execute Efficiently** (tool orchestration)
   - Use BigQuery for bulk elimination (cheap)
   - Use Documents for targeted confirmation (expensive)
   - Use Tableau only for final communication

4. **Synthesize Confidence Levels**
   - "H1 (volume increase): CONFIRMED - data shows +30% units"
   - "H2 (price inflation): PARTIAL - +10% price, but market rate"
   - "H3 (maverick spend): ELIMINATED - 95% under contract"
```

### Pattern 3: Continuous Learning

```yaml
learning_loop:
  feedback_collection:
    - "Was this analysis accurate?" (user rating)
    - "Did you need additional tools?" (coverage check)
    - "Was the visualization effective?" (communication check)
    
  model_updates:
    - Update query templates based on common patterns
    - Refine tool selection rules based on success rates
    - Compress context passing based on user follow-ups
    
  knowledge_accumulation:
    - Save successful investigation paths as "recipes"
    - Build vendor-specific context (relationship history)
    - Track metric thresholds that indicate issues
```

---

## 10. Production Deployment & Monitoring

### Deployment Checklist

```yaml
pre_deployment:
  - [ ] All MCP servers tested in isolation
  - [ ] Tool fallback strategies defined (e.g., BigQuery down → use Looker cache)
  - [ ] Rate limiting configured (max 10 BigQuery queries/minute)
  - [ ] Cost alerts set (notify if >$50/query)
  - [ ] PII masking rules applied to document search

deployment:
  - [ ] Start with BigQuery-only mode
  - [ ] Enable Tableau after 1 week stability
  - [ ] Enable Looker after 2 weeks
  - [ ] Enable Documents after 1 month

post_deployment:
  - [ ] Daily: Check token usage patterns
  - [ ] Weekly: Review tool selection accuracy
  - [ ] Monthly: Update SKILL.md with new patterns
```

### Monitoring Dashboard

Track these metrics:

| Metric | Target | Alert If |
|--------|--------|----------|
| Avg tokens per request | <3,000 | >5,000 |
| Tool switch frequency | <3 per request | >5 (inefficient planning) |
| BigQuery cost per query | <$1 | >$10 |
| User satisfaction | >4.5/5 | <4.0 |
| Subagent delegation rate | 30% | <10% (overworking parent) |

### Error Handling Matrix

| Failure | Fallback | User Communication |
|---------|----------|-------------------|
| BigQuery timeout | Retry with date range reduced | "Analyzing last 3 months instead of 12 for speed" |
| Tableau auth fail | Generate static image link | "Dashboard update failed; here's a static view" |
| Looker explore error | Fall back to raw SQL | "Semantic model unavailable; using direct query" |
| Document search empty | Expand search terms | "No documents found; broadening search criteria" |
| Token limit approaching | Compress context, summarize | "Analysis depth reduced to complete request" |

---

## Summary: Skill vs Agent

| Dimension | Vendor Analysis Skill | Vendor Intelligence Agent |
|-----------|----------------------|---------------------------|
| **Scope** | BigQuery SQL only | Multi-tool orchestration |
| **Autonomy** | Executes queries | Plans investigations |
| **Context** | Single-turn SQL | Multi-turn, cross-tool state |
| **Cost** | ~500 tokens/request | ~2,000 tokens/request |
| **Latency** | 2-5 seconds | 10-30 seconds |
| **Best for** | Known questions, structured data | Unknown questions, exploration |
| **Maintenance** | SQL templates | Orchestration logic, tool configs |

### When to Use Which

**Use the Skill when**:
- User asks specific SQL-compatible questions
- Cost sensitivity is high
- Speed is priority
- Data is entirely in BigQuery

**Use the Agent when**:
- Question spans multiple systems
- Requires visualization updates
- Needs document research
- Problem definition is unclear
- User wants proactive monitoring

---

## Quick Reference: Token Budgets

For a 200K context window with this agent:

| Configuration | Tool Defs | Working Context | Available |
|--------------|-----------|-----------------|-----------|
| **Minimal** (BigQuery only) | 15K | 5K | 180K |
| **Standard** (BQ + Tableau + Looker) | 60K | 10K | 130K |
| **Full** (All 4 tools) | 90K | 15K | 95K |

**Recommendation**: Start with Standard. Load Document MCP only when explicitly needed.

---

*This document builds on the Claude Skills Technical Architecture guide. Together they provide a complete framework for building production-grade AI analytics systems.*

*Last updated: April 2026*