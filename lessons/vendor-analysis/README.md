# Lesson: Vendor Analysis — Skill vs Agent

## 🚀 Quick Start

**Want to learn what vendor analysis is?** Start with [OVERVIEW.md](./OVERVIEW.md) — beginner-friendly guide with examples.

**Want the technical details?** Go to `.claude/skills/vendor-analysis-bigquery/` for the complete skill.

---

## What This Lesson Teaches

This lesson uses a real-world **Vendor Analysis** use case to show the difference between a **skill** and an **agent**.

You will see the same domain — answering questions about vendor spend, risk, and performance — built two ways:

| | What it is | What it can do |
|--|---|---|
| **Skill** | A scoped prompt template | Answer vendor questions using BigQuery + MCP, guided by analyst rules and 5 metric definitions |
| **Agent** | A full AI assistant | Do everything the skill does, PLUS connect to Tableau, Looker, and Docs for visualization and reporting |

---

## Structure: Lessons vs Skills

We've restructured to separate **educational content** from **technical implementation**:

```
📁 lessons/vendor-analysis/
  ├── README.md         ← You are here (overview of lesson structure)
  ├── OVERVIEW.md       ← 📚 START HERE (what is vendor analysis + examples)
  ├── idea.md           ← Original design doc
  ├── agent/            ← Full orchestration agent (agent + todos)
  └── skills/           ← Specific, reusable skills

📁 .claude/skills/vendor-analysis-bigquery/   ← 🛠️ Technical implementation
  ├── SKILL.md          ← The actual skill definition
  ├── README.md         ← Generic prompts + quick reference
  ├── copilot-instructions.md ← Enables /vendor-analysis shorthand
  ├── config/           ← YAML metric definitions
  ├── references/       ← SQL & KPI best practices
  └── ...
```

**Philosophy:**
- **Lessons/** = "Here's what this is and why it matters" (educational)
- **Skills/** = "Here are the rules and execution flow" (technical)
- Links between them help beginners navigate

---

## The Real-World Scenario

Your company works with hundreds of vendors. A procurement analyst or finance manager might ask:

- *"Which vendors have the highest spend this quarter?"* ← Skill handles
- *"Show me vendors with risk scores above 7."* ← Skill handles  
- *"What's our on-time delivery rate for Tier-1 vendors?"* ← Skill handles
- *"Create a slide with our top 5 vendor spend breakdown."* ← Agent handles

The **skill** returns data + insights (BigQuery MCP).  
The **agent** does everything + visualizes it (Tableau, Looker, Docs).

---

## Why a Skill First?

Before building the agent, you define the skill. The skill is the **rulebook** that says:

- These are the ONLY 10 tables you may query
- These are the ONLY 5 metric definitions you may use
- You reason like a vendor analyst — not a generic assistant
- The output is always: SQL + Results + Business Interpretation

The agent then *follows this rulebook* while adding multi-tool orchestration.

---

## 📁 Files in This Lesson

### Tutorial & Overview

| File | Purpose |
|------|---------|
| **[OVERVIEW.md](./OVERVIEW.md)** | 📚 Complete beginner guide to vendor analysis (start here!) |
| [idea.md](./idea.md) | Original design document |

### The Skill (Technical)

Located in: [`.claude/skills/vendor-analysis-bigquery/`](../../.claude/skills/vendor-analysis-bigquery/)

| File | What it does |
|------|-------------|
| `SKILL.md` | Scoped prompt that constrains Claude to vendor data only, executes via BigQuery MCP, with 5 metric definitions |
| `README.md` | Overview + generic prompts + workflow |
| `copilot-instructions.md` | Enables the `/vendor-analysis <prompt>` shorthand |
| `data-dictionary.md` | **Complete schema reference** for all 10 BigQuery tables |
| `examples/` | **15 ready-to-use SQL query templates** (copy & customize) |
| `config/metrics/*.yaml` | Metric definitions for all 5 domains (Financial, Operational, Risk, Quality, Strategic) |
| `references/` | SQL best practices & KPI framework documentation |

### The Agent

| File | What it does |
|------|-------------|
| [`agent/vendor-analysis-agent.md`](./agent/vendor-analysis-agent.md) | Full agent that uses the skill as its rulebook and adds tools: BigQuery execution, Tableau, Looker, and Google Docs with orchestration logic |

---

## 🔑 The Key Insight

> **A skill tells Claude *what world it lives in*.  
> An agent tells Claude *what it can do inside that world*.**

The vendor analysis skill creates a fence: "You are a vendor analyst. Stay inside these 10 tables."  
The vendor analysis agent gives Claude legs to walk around inside that fence — querying, visualizing, and documenting.

---

## 🚀 Read in This Order

### For Beginners (Start Here)
1. **[OVERVIEW.md](./OVERVIEW.md)** — What is vendor analysis + examples + scenarios
2. **[.claude/skills/vendor-analysis-bigquery/README.md](../../.claude/skills/vendor-analysis-bigquery/README.md)** — Generic prompts to copy & use
3. **Try it**: Use `/vendor-analysis Your question here`

### For Technical Understanding
1. **[.claude/skills/vendor-analysis-bigquery/SKILL.md](../../.claude/skills/vendor-analysis-bigquery/SKILL.md)** — Understand the skill rules and BigQuery MCP execution
2. **[agent/vendor-analysis-agent.md](./agent/vendor-analysis-agent.md)** — See how agent orchestrates multiple tools
3. **[.claude/skills/vendor-analysis-bigquery/config/](../../.claude/skills/vendor-analysis-bigquery/config/)** — Review metric definitions
