# Agent: Vendor Analysis Agent

## What This Agent Does

This agent answers vendor-related questions end-to-end. It uses the **Vendor Analysis Skill** as its rulebook and adds the ability to take real action across four tools:

| Tool | What the agent uses it for |
|---|---|
| **BigQuery** | Run SQL queries against the 10 allowed vendor tables |
| **Tableau** | Create or update dashboards with vendor data |
| **Looker** | Fetch existing reports or explore vendor metrics |
| **Google Docs** | Write a formatted summary document with findings |

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

## The Agent System Prompt

```
You are a Vendor Analysis Agent for a procurement team.

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
      vendor_spend_rate, on_time_delivery_rate, invoice_accuracy_rate,
      vendor_risk_score, cost_savings_rate
  - You reason like a senior vendor analyst (see skill definition for full rules)

YOUR TOOLS:
  1. run_bigquery(sql)         → executes a SQL query, returns rows as a list
  2. create_tableau_dashboard(title, data, chart_type) → creates a dashboard, returns URL
  3. fetch_looker_report(report_name, filters) → fetches an existing report, returns data
  4. write_google_doc(title, content) → creates a Google Doc, returns URL

YOUR DECISION LOGIC:
  - For any data question: use run_bigquery (always)
  - If the user asks for a chart, graph, or visual: use create_tableau_dashboard
  - If the user asks for a report or dashboard that might already exist: check Looker first
  - If the user asks for a summary, findings, or wants to share results: use write_google_doc
  - If the query returns 0 rows: tell the user what you searched for and suggest alternatives

YOU ALWAYS:
  - Show the SQL query before running it (so analysts can verify)
  - State how many rows the query returned
  - Use the Vendor Analysis Skill rules for all data logic (scope, metrics, behavior)
```

---

## The Full Python Implementation

```python
import anthropic
import json
from typing import Any

client = anthropic.Anthropic()

# ─────────────────────────────────────────────────────────────────────────────
# The Vendor Analysis Skill — the rulebook the agent follows
# (Same as defined in skills/vendor-analysis-skill.md)
# ─────────────────────────────────────────────────────────────────────────────

METRIC_DEFINITIONS = """
vendor_spend_rate: SUM of approved invoices per vendor per period
on_time_delivery_rate: % of POs delivered on or before agreed date
invoice_accuracy_rate: % of invoices paid without dispute
vendor_risk_score: AVG risk score from vendor_risk_register (0-10)
cost_savings_rate: (contracted price - invoiced amount) / contracted price * 100
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
- Default time period: current quarter
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


# ─────────────────────────────────────────────────────────────────────────────
# The Agent — all reasoning and tool-use decisions live here
# ─────────────────────────────────────────────────────────────────────────────

# Keywords that tell the agent the user wants a visual output
VISUAL_KEYWORDS = ["chart", "graph", "visual", "dashboard", "plot", "visualize"]

# Keywords that tell the agent the user wants a written summary
DOC_KEYWORDS = ["summary", "doc", "document", "write up", "share", "send", "report"]

# Keywords that suggest a Looker report might already exist
LOOKER_KEYWORDS = ["existing report", "standard report", "already have", "looker"]


def vendor_analysis_agent(user_question: str) -> dict[str, Any]:
    """
    Agent: Answer a vendor question end-to-end by reasoning about
    which tools to call, in what order, for the user's specific request.

    This is where all decisions happen.
    The skill handles 'what data and how to query it'.
    The agent handles 'what to do with that data'.
    """
    print(f"\n🤖 Agent: Processing question → '{user_question}'")
    result = {}
    question_lower = user_question.lower()

    # ── STEP 1: Check if user wants a Looker report first ─────────────────────
    # The agent checks Looker before querying BigQuery to avoid duplicate work
    if any(kw in question_lower for kw in LOOKER_KEYWORDS):
        print("\n📋 Agent: Detected Looker keyword — checking for existing report first...")
        looker_result = fetch_looker_report(
            report_name="Vendor Spend Summary",
            filters={"time_period": "current_quarter", "status": "active"}
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

    # ── STEP 4: Create a Tableau dashboard if the user asked for a visual ─────
    if any(kw in question_lower for kw in VISUAL_KEYWORDS):
        print("\n📋 Agent: Detected visual request — creating Tableau dashboard...")
        dashboard_url = create_tableau_dashboard(
            title="Vendor Analysis — Current Quarter",
            data=rows,
            chart_type="bar chart"
        )
        result["tableau_dashboard_url"] = dashboard_url
        print(f"  ✅ Dashboard created: {dashboard_url}")

    # ── STEP 5: Write a Google Doc if the user asked for a summary/share ──────
    if any(kw in question_lower for kw in DOC_KEYWORDS):
        print("\n📋 Agent: Detected doc request — writing Google Doc summary...")

        # Format the rows as a readable table for the doc
        doc_content = f"## Vendor Analysis — Q{1} 2025\n\n"
        doc_content += "**Question:** " + user_question + "\n\n"
        doc_content += "**Top Results:**\n\n"
        for row in rows:
            doc_content += f"- {row.get('vendor_name', 'N/A')}: "
            doc_content += ", ".join(
                f"{k} = {v}" for k, v in row.items() if k != "vendor_name"
            )
            doc_content += "\n"
        doc_content += "\n_Generated by Vendor Analysis Agent._"

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
    if "tableau_dashboard_url" in result:
        steps_taken.append("created Tableau dashboard")
    if "google_doc_url" in result:
        steps_taken.append("wrote Google Doc summary")

    result["message"] = "Agent completed: " + ", then ".join(steps_taken) + "."
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
    r1 = vendor_analysis_agent(
        "Which vendors have the highest spend this quarter?"
    )
    print("\nResult keys:", list(r1.keys()))
    print("Message:", r1["message"])

    # Test 2: Visual request — BigQuery + Tableau
    print("\n" + "=" * 65)
    print("TEST 2: Visual request (BigQuery + Tableau)")
    print("=" * 65)
    r2 = vendor_analysis_agent(
        "Show me a chart of vendor spend by tier for this quarter"
    )
    print("\nResult keys:", list(r2.keys()))
    print("Message:", r2["message"])
    if "tableau_dashboard_url" in r2:
        print("Tableau URL:", r2["tableau_dashboard_url"])

    # Test 3: Summary + share — BigQuery + Tableau + Google Docs
    print("\n" + "=" * 65)
    print("TEST 3: Full output (BigQuery + Tableau + Google Docs)")
    print("=" * 65)
    r3 = vendor_analysis_agent(
        "Give me a chart and a written summary of top vendor spend to share with the team"
    )
    print("\nResult keys:", list(r3.keys()))
    print("Message:", r3["message"])
    if "google_doc_url" in r3:
        print("Google Doc URL:", r3["google_doc_url"])

    # Test 4: Existing report check — Looker first
    print("\n" + "=" * 65)
    print("TEST 4: Looker check (fetches existing report, skips BigQuery)")
    print("=" * 65)
    r4 = vendor_analysis_agent(
        "Is there an existing Looker report for vendor spend?"
    )
    print("\nResult keys:", list(r4.keys()))
    print("Message:", r4["message"])
```

---

## Reading the Output

**Test 1 output (BigQuery only):**
```
🤖 Agent: Processing question → 'Which vendors have the highest spend this quarter?'

📋 Agent: Calling Vendor Analysis Skill to generate query...
  ✅ Skill returned SQL + explanation.

📋 Agent: Running query in BigQuery...
  🔵 BigQuery: Running query...
  ✅ BigQuery returned 5 rows.

✅ Agent: Done. queried BigQuery (5 rows returned).
```

**Test 4 output (Looker short-circuits BigQuery):**
```
🤖 Agent: Processing question → 'Is there an existing Looker report for vendor spend?'

📋 Agent: Detected Looker keyword — checking for existing report first...
  🔍 Looker: Fetching report 'Vendor Spend Summary'...
  ✅ Agent: Found existing Looker report. Returning URL without re-querying.
```

Notice: **the agent never called BigQuery for Test 4** — it decided that was unnecessary once Looker had the answer.

---

## Where Decisions Live vs. Where Work Is Done

| Decision | Made by | Executed by |
|---|---|---|
| What tables am I allowed to query? | Skill (rulebook) | — |
| How should I calculate this metric? | Skill (rulebook) | — |
| Should I check Looker first? | **Agent** | `fetch_looker_report` tool |
| What SQL answers this question? | **Agent** (calls skill) | `vendor_analysis_skill` |
| Should I run the query? | **Agent** | `run_bigquery` tool |
| Does the user want a visual? | **Agent** | `create_tableau_dashboard` tool |
| Does the user want a doc? | **Agent** | `write_google_doc` tool |
| What if the query returns 0 rows? | **Agent** | Agent explains and suggests alternatives |

**The skill never decides what tool to use. The agent never writes SQL directly.**

---

## The Architecture at a Glance

```
User question
      ↓
┌──────────────────────────────────────────────────────────┐
│               VENDOR ANALYSIS AGENT                      │
│  Reads intent → decides which tools to call → assembles  │
│  the final answer                                        │
│                                                          │
│   Uses skill as rulebook for all data logic              │
│   Calls tools based on what the user actually needs      │
└────┬──────────┬──────────┬──────────┬────────────────────┘
     ↓          ↓          ↓          ↓
┌─────────┐ ┌────────┐ ┌────────┐ ┌────────────┐
│ Vendor  │ │BigQuery│ │Tableau │ │   Looker   │
│Analysis │ │  tool  │ │  tool  │ │    tool    │
│  Skill  │ │        │ │        │ │            │
│(rulebook│ │runs SQL│ │creates │ │fetches     │
│ 10 tbls │ │returns │ │dashbrd │ │existing    │
│ 5 yaml) │ │rows    │ │ret URL │ │reports     │
└─────────┘ └────────┘ └────────┘ └────────────┘
                                        +
                               ┌────────────────┐
                               │  Google Docs   │
                               │     tool       │
                               │ writes summary │
                               │ returns URL    │
                               └────────────────┘
```

---

## 🔑 The Core Insight

> **Skill = the vendor analyst's knowledge and constraints**  
> **Agent = the vendor analyst's ability to act**

The skill knows *what* to look at and *how* to measure it.  
The agent knows *when* to look, *what to do with what it finds*, and *how to present it*.

Together: a governed, scoped, multi-tool assistant that stays in its lane.
