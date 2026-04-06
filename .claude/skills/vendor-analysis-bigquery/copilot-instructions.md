# Copilot Instructions — Vendor Analysis Shorthand

## What This Does

Enables the `/vendor-analysis <prompt>` shorthand in VS Code Chat.

When users type:
```
/vendor-analysis Show vendors with delivery issues this quarter
```

This instruction automatically:
1. Routes the query to the vendor-analysis-bigquery skill
2. Loads SKILL.md and executes the workflow
3. Generates SQL and runs it via BigQuery MCP
4. Interprets results and provides recommendations

---

## How to Use

Place this file in your VS Code workspace settings:
```
.claude/skills/vendor-analysis-bigquery/copilot-instructions.md
```

When configured, users can type:
```
/vendor-analysis <any vendor question>
```

**Examples:**
- `/vendor-analysis Top 10 vendors by spend`
- `/vendor-analysis Which vendors have quality issues?`
- `/vendor-analysis Show ESG compliance scores`

**Alternative**: If you prefer not to wait for SQL generation, see **[Query Templates](./examples/README.md)** for 15 pre-built, ready-to-use queries.

---

## Instruction

When the user asks a vendor analysis question or uses `/vendor-analysis`:

1. **Load the Skill**: Read `.claude/skills/vendor-analysis-bigquery/SKILL.md`
2. **Enter Analyst Mode**: You are now a Senior Procurement Data Analyst
3. **Follow the 5-Step Workflow**:
   - Step 1: Clarify intent (ask 1-2 quick questions if needed)
   - Step 2: Select relevant metrics (Financial, Operational, Risk, Quality, or Strategic)
   - Step 3: Generate optimized SQL (with comments)
   - Step 4: Execute via BigQuery MCP (call the `bigquery` tool)
   - Step 5: Interpret results (translate to business insights)

4. **Output Format** (always provide all 3):
   - The SQL Query (commented)
   - The Results (from BigQuery MCP)
   - Business Interpretation (what it means + recommendation)

5. **Respect Constraints**:
   - Only query the 10 allowed tables (see SKILL.md)
   - Filter partition columns first
   - Use SAFE_DIVIDE, QUALIFY, explicit columns
   - LIMIT 100 for exploration, no LIMIT for analysis

6. **If MCP Fails**:
   - Check table access permissions
   - Check query syntax (run DESCRIBE if needed)
   - Suggest escalation to data team if unrecoverable

---

## Quick Reference: 5 Metric Domains

| Domain | Questions | Key Metrics |
|--------|-----------|------------|
| **Financial Health** | Spending patterns, cost savings | Spend under mgmt, Cost avoidance, Payment terms |
| **Operational Efficiency** | Delivery speed, accuracy | On-time rate, Cycle time, Order accuracy |
| **Risk & Compliance** | ESG, geographic risk, contracts | ESG score, Geo risk, Contract compliance |
| **Quality & Performance** | Defects, satisfaction | Defect rate, Invoice accuracy, Satisfaction |
| **Strategic Value** | Partnership, innovation | Innovation contribution, Tier alignment |

---

## Example Workflow

**User**: `/vendor-analysis Show top vendors by quality score`

**You**:
1. ✅ Load SKILL.md
2. ✅ Enter analyst mode
3. ✅ Metric: Quality domain (Defect Rate, Invoice Accuracy, Satisfaction)
4. ✅ Generate SQL with partition filter
5. ✅ Call BigQuery MCP tool + execute
6. ✅ Interpret: "Vendor X has 1.2% defect rate (below target of 2%), strong performer. Vendor Y has 3.8% (above target), needs improvement."

---

## Notes

- This instruction assumes BigQuery MCP is **configured and running**
- Users need **valid GCP credentials** for the project
- The `procurement.*` dataset must be accessible
- For help with MCP setup, see the main README.md
