# Lesson: Vendor Analysis — Skill vs Agent

## What This Lesson Teaches

This lesson uses a real-world **Vendor Analysis** use case to show the difference between a **skill** and an **agent**.

You will see the same domain — answering questions about vendor spend, risk, and performance — built two ways:

| | What it is | What it can do |
|--|---|---|
| **Skill** | A scoped prompt template | Answer vendor questions using BigQuery only, guided by analyst rules |
| **Agent** | A full AI assistant | Do everything the skill does, PLUS connect to Tableau, Looker, and Docs |

---

## The Real-World Scenario

Your company works with hundreds of vendors. A procurement analyst or finance manager might ask:

- *"Which vendors have the highest spend this quarter?"*
- *"Show me vendors with risk scores above 7."*
- *"What's our on-time delivery rate for Tier-1 vendors?"*
- *"Create a slide with our top 5 vendor spend breakdown."*

The **skill** handles the first three (data questions, BigQuery only).  
The **agent** handles all four — including generating Tableau dashboards, Looker reports, and writing a Google Doc summary.

---

## Why a Skill First?

Before building the agent, you define the skill. The skill is the **rulebook** that says:

- These are the ONLY 10 tables you may query
- These are the ONLY 5 metric definitions you may use
- You reason like a vendor analyst — not a generic assistant
- You do not wander into HR, finance, or engineering data

The agent then *follows this rulebook* while adding the ability to take action across tools.

---

## 📁 Files in This Lesson

### The Skill

| File | What it does |
|------|-------------|
| [`skills/vendor-analysis-skill.md`](./skills/vendor-analysis-skill.md) | Scoped prompt that constrains Claude to vendor data only, with BigQuery queries guided by 5 metric definitions |

### The Agent

| File | What it does |
|------|-------------|
| [`agent/vendor-analysis-agent.md`](./agent/vendor-analysis-agent.md) | Full agent that uses the skill as its rulebook and adds tools: BigQuery execution, Tableau, Looker, and Google Docs |

---

## 🔑 The Key Insight

> **A skill tells Claude *what world it lives in*.  
> An agent tells Claude *what it can do inside that world*.**

The vendor analysis skill creates a fence: "You are a vendor analyst. Stay inside these 10 tables."  
The vendor analysis agent gives Claude legs to walk around inside that fence — querying, visualizing, and documenting.

---

## 🚀 Read in This Order

1. [`skills/vendor-analysis-skill.md`](./skills/vendor-analysis-skill.md) — understand the scoped rulebook
2. [`agent/vendor-analysis-agent.md`](./agent/vendor-analysis-agent.md) — see how the agent wraps the skill with tools
