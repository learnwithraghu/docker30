# Agent: Vendor Intelligence Agent

## What This Agent Does

This agent answers vendor-related questions end-to-end. It uses the **Vendor Analysis Skill** as its rulebook and adds the ability to take real action across four tools:

| Tool | What the agent uses it for | Cost/Token Budget |
|---|---|---|
| **BigQuery** | Run SQL queries against the 10 allowed vendor tables | 15 tokens/call + query results |
| **Tableau** | Create or update dashboards with vendor data | 25 tokens/call |
| **Looker** | Fetch existing reports or explore vendor metrics | 20 tokens/call |
| **Google Docs** | Write a formatted summary document with findings | 30 tokens/1000 pages |

The agent **decides** which tools to use for each question. The skill decides **what data to look at**.

---

## Why This Is an Agent (Not Just a Skill)

The skill produces a SQL query and an explanation. That's all it does.  
The agent decides what to *do* with that output:

- *Should I run this query in BigQuery and show the numbers?* → decision
- *Did the user ask for a visual? Should I push this to Tableau?* → decision
- *Is there an existing Looker report that already answers this?* → decision
- *Should I write a Google Doc summary for the team?* → decision
- *What if the query returns zero rows? What do I tell the user?* → exception handling

None of these decisions belong in the skill. They all live here, in the agent.

---

## Tool Orchestration Architecture

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

### Orchestration Rules

**Rule 1: Tool Selection Strategy**

For any request, determine the **information architecture**:

| Need | Primary Tool | Secondary Tool |
|------|-------------|----------------|
| Raw transaction analysis | BigQuery | Looker (for semantic context) |
| Executive dashboard update | Tableau | BigQuery (for data validation) |
| Contract terms research | Documents | BigQuery (for spend correlation) |
| Trend exploration | Looker | Tableau (for dashboard creation) |

**Rule 2: Context Preservation**

**State Management Strategy**:

```python
# Pseudo-code for context handling
session_state = {
    "current_vendor_id": None,      # Persist across tool calls
    "active_time_period": "last_12_months",  # Default time filter
    "document_insights": []         # Accumulated findings
}
```

**Critical**: When switching tools, explicitly pass context:

```
BigQuery Result: "Vendor X spend increased 40% in Q3"
→ Tableau Action: "Update Vendor Performance dashboard highlighting Q3 anomaly for Vendor X"
→ Document Action: "Search for Q3 contract amendments or pricing changes for Vendor X"
```

**Rule 3: Cost-Aware Execution**

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

---

## The Agent System Prompt

```
You are a Vendor Intelligence Agent for a procurement team.

You help procurement managers and analysts answer questions about vendor spend, 
risk, performance, and contracts.

YOUR RULEBOOK (the Vendor Analysis Skill):
  - You ONLY answer questions within the vendor domain
  - You ONLY query these 10 BigQuery tables:
      procurement.vendor_master, procurement.purchase_orders,
      procurement.invoices, procurement.invoice_line_items,
      procurement.payments, procurement.vendor_contracts,
      finance.vendor_spend_monthly, finance.spend_by_category,
      risk.vendor_risk_register, operations.vendor_performance_scores
  - You ONLY use these 5 metrics:
      financial_health, operational_efficiency, risk_compliance,
      quality_performance, strategic_value
  - You reason like a senior vendor analyst (see skill definition for full rules)

YOUR TOOLS:
  1. run_bigquery(sql)         → executes a SQL query, returns rows as a list
  2. create_tableau_dashboard(title, data, chart_type) → creates a dashboard, returns URL
  3. fetch_looker_report(report_name, filters) → fetches an existing report, returns data
  4. write_google_doc(title, content) → creates a Google Doc, returns URL
  5. search_documents(query, vendor_id) → searches contracts/emails, returns insights

YOUR DECISION LOGIC:
  - For any data question: use run_bigquery (always)
  - If the user asks for a chart, graph, or visual: use create_tableau_dashboard
  - If the user asks for a report or dashboard that might already exist: check Looker first
  - If the user asks for a summary, findings, or wants to share results: use write_google_doc
  - If the query returns 0 rows: tell the user what you searched for and suggest alternatives
  - If investigating cost increases: search_documents for contract changes

YOU ALWAYS:
  - Show the SQL query before running it (so analysts can verify)
  - State how many rows the query returned
  - Use the Vendor Analysis Skill rules for all data logic (scope, metrics, behavior)
  - Preserve context across tool calls (pass vendor_id, time_period, etc.)
  - Stay within 5,000 token budget per request
```

---

## Context Management Across Tools

### The Multi-Tool Context Problem

Each tool adds to context window usage. With 4 tools, we risk hitting limits quickly.

**Baseline Costs** (per our analysis):
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
    action: "load_tableau_tool"
  - condition: "user_mentions existing report"
    action: "load_looker_tool"
  - condition: "user_mentions contract OR document"
    action: "load_document_tool"
```

### Session Memory Management

```yaml
# Keep in context permanently (small, critical)
persistent_context:
  - Current vendor ID being analyzed
  - Active time period filter
  - User role (executive vs analyst)

# Keep in context temporarily (prune after 3 turns)
working_memory:
  - Last query results summary
  - Active dashboard IDs
  - Document search results

# Offload to filesystem (load on demand)
external_memory:
  - Full query results (save to /tmp/)
  - Historical analysis cache
  - Document analysis summaries
```

---

## Execution Patterns

### Pattern 1: Anomaly Investigation

**Trigger**: "Why did Vendor X's cost spike?"

```yaml
steps:
  1. bigquery_query: Run spend trend analysis
  2. analyze_results: Identify spike period
  3. document_search: Look for contract changes in spike period
  4. tableau_update: Create dashboard highlighting anomaly
  5. google_doc_write: Summarize findings and recommendations
```

### Pattern 2: Strategic Sourcing

**Trigger**: "Should we renew Vendor Y or switch to Vendor Z?"

```yaml
steps:
  1. parallel_execution:
     - bigquery_query: Vendor Y performance metrics
     - bigquery_query: Vendor Z performance metrics
  2. looker_explore: Compare against category benchmarks
  3. tableau_update: Create comparison dashboard
  4. google_doc_write: Decision framework and recommendation
```

### Pattern 3: Proactive Monitoring (Autonomous)

**Trigger**: Scheduled execution (no user prompt)

```yaml
schedule: "weekly"
steps:
  1. bigquery_query: Risk score monitoring
  2. conditional: if high_risk_vendors > 0
     - tableau_update: Update risk dashboard
     - google_doc_write: Weekly risk report
```

---

## The Full Python Implementation

```python
import anthropic
import json
from typing import Any, Dict, List

client = anthropic.Anthropic()

# ─────────────────────────────────────────────────────────────────────────────
# The Vendor Analysis Skill — the rulebook the agent follows
# (Same as defined in skills/vendor-analysis-skill.md)
# ─────────────────────────────────────────────────────────────────────────────

METRIC_DEFINITIONS = """
financial_health: spend_under_management, cost_variance
operational_efficiency: on_time_delivery_rate, cycle_time
risk_compliance: risk_score, compliance_rate
quality_performance: defect_rate, quality_score
strategic_value: innovation_contribution, partnership_score
"""

ALLOWED_TABLES = """
procurement.vendor_master, procurement.purchase_orders, procurement.invoices,
procurement.invoice_line_items, procurement.payments, procurement.vendor_contracts,
finance.vendor_spend_monthly, finance.spend_by_category,
risk.vendor_risk_register, operations.vendor_performance_scores
"""

VENDOR_ANALYSIS_SKILL_PROMPT = """
You are a vendor analysis assistant. Answer using only the vendor domain.

ALLOWED TABLES (BigQuery):
{allowed_tables}

METRIC DEFINITIONS:
{metric_definitions}

ANALYST RULES:
- Default time period: last 12 months
- Filter to active vendors unless told otherwise
- Rank spend results highest to lowest
- Flag risk_score > 7 as high-priority
- Percentages to 1 decimal place
- Top 10 summary if results > 20 rows

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
    Skill: Produce a BigQuery SQL query + explanation for a vendor question.
    Scoped to 10 tables and 5 metric definitions. No tool calls, no execution.
    """
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


# ─────────────────────────────────────────────────────────────────────────────
# The four tool implementations
# (In production these would connect to real APIs — here they simulate responses)
# ─────────────────────────────────────────────────────────────────────────────

def run_bigquery(sql: str) -> list[dict]:
    """
    Tool: Execute a SQL query in BigQuery and return rows.

    In production: uses google-cloud-bigquery client.
    Here: returns simulated data so the lesson works without GCP credentials.
    """
    print(f"  🔵 BigQuery: Running query...")
    print(f"     SQL (first 120 chars): {sql[:120].strip()}...")

    # Simulated result — in production this would be real query output
    return [
        {"vendor_name": "Acme Supplies",    "vendor_tier": "Tier-1", "total_spend_usd": 4_200_000},
        {"vendor_name": "GlobalParts Co",   "vendor_tier": "Tier-1", "total_spend_usd": 3_100_000},
        {"vendor_name": "FastShip Ltd",     "vendor_tier": "Tier-2", "total_spend_usd": 1_800_000},
        {"vendor_name": "SteelWorks Inc",   "vendor_tier": "Tier-2", "total_spend_usd":   950_000},
        {"vendor_name": "QuickBuild Corp",  "vendor_tier": "Tier-3", "total_spend_usd":   420_000},
    ]


def create_tableau_dashboard(title: str, data: list[dict], chart_type: str) -> str:
    """
    Tool: Create a Tableau dashboard and return its URL.

    In production: uses Tableau REST API to publish a workbook.
    Here: simulates a successful creation with a fake URL.
    """
    print(f"  📊 Tableau: Creating '{chart_type}' dashboard titled '{title}'...")
    print(f"     Data rows: {len(data)}")
    # Simulated URL — in production this is returned by the Tableau API
    return f"https://tableau.company.com/dashboards/vendor/{title.lower().replace(' ', '-')}"


def fetch_looker_report(report_name: str, filters: dict) -> dict:
    """
    Tool: Fetch an existing Looker report or Explore result.

    In production: uses Looker SDK (looker_sdk) to run a Look or query an Explore.
    Here: simulates a report response.
    """
    print(f"  🔍 Looker: Fetching report '{report_name}' with filters {filters}...")
    # Simulated response — in production this is real Looker output
    return {
        "report_name": report_name,
        "found": True,
        "last_updated": "2025-04-01",
        "url": f"https://looker.company.com/looks/{report_name.lower().replace(' ', '_')}",
        "row_count": 47,
        "note": "Report exists and is up to date for current quarter."
    }


def write_google_doc(title: str, content: str) -> str:
    """
    Tool: Create a Google Doc and return its URL.

    In production: uses Google Docs API (google-api-python-client).
    Here: simulates a successful doc creation.
    """
    print(f"  📄 Google Docs: Writing document '{title}'...")
    # Simulated URL — in production this is returned by the Docs API
    return f"https://docs.google.com/document/d/simulated-id-{hash(title) % 99999}/edit"


def search_documents(query: str, vendor_id: str = None) -> list[dict]:
    """
    Tool: Search unstructured documents (contracts, emails, notes).

    In production: uses document search API or vector database.
    Here: simulates document search results.
    """
    print(f"  📑 Documents: Searching for '{query}'{' for vendor ' + vendor_id if vendor_id else ''}...")
    # Simulated results — in production this would search actual documents
    return [
        {
            "document_type": "contract_amendment",
            "title": "Q3 Price Increase Agreement",
            "date": "2025-07-15",
            "key_insights": ["5% price increase effective Q3", "Volume commitment required"],
            "relevance_score": 0.95
        }
    ]


# ─────────────────────────────────────────────────────────────────────────────
# Session Context Management
# ─────────────────────────────────────────────────────────────────────────────

class AgentContext:
    """Manages context across tool calls within a session."""
    
    def __init__(self):
        self.persistent = {
            "current_vendor_id": None,
            "active_time_period": "last_12_months",
            "user_role": "analyst"
        }
        self.working = {
            "last_query_results": None,
            "active_dashboards": [],
            "document_insights": []
        }
        self.token_budget = 5000
        self.tokens_used = 0
    
    def update_vendor(self, vendor_id: str):
        """Update the current vendor being analyzed."""
        self.persistent["current_vendor_id"] = vendor_id
    
    def add_document_insight(self, insight: dict):
        """Add a document search result to context."""
        self.working["document_insights"].append(insight)
    
    def get_context_summary(self) -> str:
        """Get a summary of current context for tool calls."""
        vendor = self.persistent.get("current_vendor_id", "unknown")
        period = self.persistent.get("active_time_period", "unknown")
        docs = len(self.working.get("document_insights", []))
        return f"Current analysis: Vendor {vendor}, Time period: {period}, Document insights: {docs}"


# ─────────────────────────────────────────────────────────────────────────────
# The Agent — all reasoning and tool-use decisions live here
# ─────────────────────────────────────────────────────────────────────────────

# Keywords that tell the agent the user wants a visual output
VISUAL_KEYWORDS = ["chart", "graph", "visual", "dashboard", "plot", "visualize"]

# Keywords that tell the agent the user wants a written summary
DOC_KEYWORDS = ["summary", "doc", "document", "write up", "share", "send", "report"]

# Keywords that suggest a Looker report might already exist
LOOKER_KEYWORDS = ["existing report", "standard report", "already have", "looker"]

# Keywords that suggest document investigation
DOCUMENT_KEYWORDS = ["contract", "agreement", "terms", "why", "investigate", "spike", "increase"]


def vendor_intelligence_agent(user_question: str) -> dict[str, Any]:
    """
    Agent: Answer a vendor question end-to-end by reasoning about
    which tools to call, in what order, for the user's specific request.

    This is where all decisions happen.
    The skill handles 'what data and how to query it'.
    The agent handles 'what to do with that data'.
    """
    print(f"\n🤖 Agent: Processing question → '{user_question}'")
    context = AgentContext()
    result = {}
    question_lower = user_question.lower()

    # ── STEP 1: Check if user wants a Looker report first ─────────────────────
    # The agent checks Looker before querying BigQuery to avoid duplicate work
    if any(kw in question_lower for kw in LOOKER_KEYWORDS):
        print("\n📋 Agent: Detected Looker keyword — checking for existing report first...")
        looker_result = fetch_looker_report(
            report_name="Vendor Spend Summary",
            filters={"time_period": context.persistent["active_time_period"], "status": "active"}
        )
        result["looker_report"] = looker_result

        if looker_result["found"]:
            print(f"  ✅ Agent: Found existing Looker report. Returning URL without re-querying.")
            result["message"] = (
                f"An existing Looker report was found: '{looker_result['report_name']}'. "
                f"It was last updated {looker_result['last_updated']} and has {looker_result['row_count']} rows. "
                f"View it here: {looker_result['url']}"
            )
            return result

    # ── STEP 2: Use the Vendor Analysis Skill to generate a BigQuery query ─────
    # The agent delegates to the skill — it does NOT write the SQL itself
    print("\n📋 Agent: Calling Vendor Analysis Skill to generate query...")
    skill_output = vendor_analysis_skill(user_question)
    result["skill_output"] = skill_output
    print("  ✅ Skill returned SQL + explanation.")

    # Extract the SQL block from the skill output for execution
    # In production, use a more robust parser; here we use a simple heuristic
    sql_start = skill_output.find("```sql")
    sql_end = skill_output.find("```", sql_start + 3)
    if sql_start != -1 and sql_end != -1:
        sql = skill_output[sql_start + 6:sql_end].strip()
    else:
        # Fallback if the skill didn't wrap SQL in a code block
        sql = "SELECT * FROM finance.vendor_spend_monthly LIMIT 10"

    # ── STEP 3: Run the query in BigQuery ──────────────────────────────────────
    print("\n📋 Agent: Running query in BigQuery...")
    rows = run_bigquery(sql)
    result["bigquery_rows"] = rows
    context.working["last_query_results"] = rows
    print(f"  ✅ BigQuery returned {len(rows)} rows.")

    # ── REASONING: Handle empty result ────────────────────────────────────────
    # The agent decides what to do — the skill has no opinion about this
    if not rows:
        print("  🤔 Agent: Zero rows returned. Suggesting alternatives to user.")
        result["message"] = (
            "The query returned no results for the current quarter with active vendors. "
            "This could mean: (1) no approved invoices exist yet this quarter, or "
            "(2) the filter criteria are too narrow. "
            "Try asking for last quarter, or removing the active-vendor filter."
        )
        return result

    # ── STEP 4: Investigate documents if this is an anomaly question ──────────
    if any(kw in question_lower for kw in DOCUMENT_KEYWORDS):
        print("\n📋 Agent: Detected investigation keywords — searching documents...")
        # Extract vendor from query results if available
        vendor_id = None
        if rows and "vendor_id" in rows[0]:
            vendor_id = rows[0]["vendor_id"]
            context.update_vendor(vendor_id)
        
        doc_results = search_documents(
            query=user_question,
            vendor_id=vendor_id
        )
        result["document_insights"] = doc_results
        for insight in doc_results:
            context.add_document_insight(insight)
        print(f"  ✅ Found {len(doc_results)} relevant documents.")

    # ── STEP 5: Create a Tableau dashboard if the user asked for a visual ─────
    if any(kw in question_lower for kw in VISUAL_KEYWORDS):
        print("\n📋 Agent: Detected visual request — creating Tableau dashboard...")
        dashboard_url = create_tableau_dashboard(
            title="Vendor Analysis — Current Quarter",
            data=rows,
            chart_type="bar chart"
        )
        result["tableau_dashboard_url"] = dashboard_url
        context.working["active_dashboards"].append(dashboard_url)
        print(f"  ✅ Dashboard created: {dashboard_url}")

    # ── STEP 6: Write a Google Doc if the user asked for a summary/share ──────
    if any(kw in question_lower for kw in DOC_KEYWORDS):
        print("\n📋 Agent: Detected doc request — writing Google Doc summary...")

        # Format the rows as a readable table for the doc
        doc_content = f"## Vendor Analysis — {context.persistent['active_time_period'].replace('_', ' ').title()}\n\n"
        doc_content += "**Question:** " + user_question + "\n\n"
        doc_content += "**Top Results:**\n\n"
        for row in rows:
            doc_content += f"- {row.get('vendor_name', 'N/A')}: "
            doc_content += ", ".join(
                f"{k} = {v}" for k, v in row.items() if k != "vendor_name"
            )
            doc_content += "\n"
        
        # Add document insights if available
        if context.working["document_insights"]:
            doc_content += "\n**Document Insights:**\n"
            for insight in context.working["document_insights"]:
                doc_content += f"- {insight['title']}: {', '.join(insight['key_insights'])}\n"
        
        doc_content += "\n_Generated by Vendor Intelligence Agent._"

        doc_url = write_google_doc(
            title="Vendor Analysis Summary",
            content=doc_content
        )
        result["google_doc_url"] = doc_url
        print(f"  ✅ Google Doc created: {doc_url}")

    # ── FINAL: Summarize what the agent did ───────────────────────────────────
    steps_taken = []
    if "bigquery_rows" in result:
        steps_taken.append(f"queried BigQuery ({len(rows)} rows returned)")
    if "document_insights" in result:
        steps_taken.append(f"searched documents ({len(result['document_insights'])} insights)")
    if "tableau_dashboard_url" in result:
        steps_taken.append("created Tableau dashboard")
    if "google_doc_url" in result:
        steps_taken.append("wrote Google Doc summary")

    result["message"] = "Agent completed: " + ", then ".join(steps_taken) + "."
    result["context_summary"] = context.get_context_summary()
    print(f"\n✅ Agent: Done. {result['message']}")
    return result


# ─────────────────────────────────────────────────────────────────────────────
# Test with four different questions
# ─────────────────────────────────────────────────────────────────────────────

if __name__ == "__main__":

    # Test 1: Simple data question — BigQuery only
    print("=" * 65)
    print("TEST 1: Data question (BigQuery only)")
    print("=" * 65)
    r1 = vendor_intelligence_agent(
        "Which vendors have the highest spend this quarter?"
    )
    print("\nResult keys:", list(r1.keys()))
    print("Message:", r1["message"])

    # Test 2: Visual request — BigQuery + Tableau
    print("\n" + "=" * 65)
    print("TEST 2: Visual request (BigQuery + Tableau)")
    print("=" * 65)
    r2 = vendor_intelligence_agent(
        "Show me a chart of vendor spend by tier for this quarter"
    )
    print("\nResult keys:", list(r2.keys()))
    print("Message:", r2["message"])
    if "tableau_dashboard_url" in r2:
        print("Tableau URL:", r2["tableau_dashboard_url"])

    # Test 3: Investigation — BigQuery + Documents + Google Docs
    print("\n" + "=" * 65)
    print("TEST 3: Investigation (BigQuery + Documents + Google Docs)")
    print("=" * 65)
    r3 = vendor_intelligence_agent(
        "Why did vendor costs spike this quarter? Please investigate and summarize findings."
    )
    print("\nResult keys:", list(r3.keys()))
    print("Message:", r3["message"])
    if "google_doc_url" in r3:
        print("Google Doc URL:", r3["google_doc_url"])

    # Test 4: Existing report check — Looker first
    print("\n" + "=" * 65)
    print("TEST 4: Looker check (fetches existing report, skips BigQuery)")
    print("=" * 65)
    r4 = vendor_intelligence_agent(
        "Is there an existing Looker report for vendor spend?"
    )
    print("\nResult keys:", list(r4.keys()))
    print("Message:", r4["message"])
```

---

## Reading the Output

The agent now demonstrates **true multi-tool orchestration**:

- **Context preservation** across tool calls (vendor_id, time_period)
- **Cost-aware execution** (BigQuery first, documents last)
- **Progressive tool loading** (only load tools when needed)
- **Investigation patterns** (BigQuery → Documents → Tableau → Docs)
- **Autonomous decision-making** based on user intent

This is the difference between a **skill** (reactive, single-tool) and an **agent** (proactive, multi-tool).
