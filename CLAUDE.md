# CLAUDE.md — Project Context for Claude AI

This file tells Claude AI about this repository so it can assist you better.

---

## 📁 What is this repository?

**claude-sessions** is a learning repository used for teaching beginners how to:
- Work with Claude AI (agents, skills, prompts)
- Learn Docker through 30 hands-on lessons

The audience is **complete beginners**, so all explanations should use simple language, real-world analogies, and step-by-step guidance.

---

## 🗂️ Repository Structure

```
claude-sessions/
├── README.md           ← Main landing page
├── CLAUDE.md           ← This file (Claude project context)
├── agents/             ← Claude AI agent examples for beginners
│   ├── README.md
│   ├── tutor-agent.md
│   └── code-reviewer-agent.md
├── skills/             ← Reusable skill/prompt examples for beginners
│   ├── README.md
│   ├── summarize-skill.md
│   └── explain-code-skill.md
└── lesson-01/ ... lesson-30/   ← Docker bootcamp lessons
```

---

## 🎯 Coding Guidelines

When generating or reviewing code in this repo:

1. **Always explain each step** — students are beginners
2. **Use real-world analogies** — e.g., "an agent is like a specialist employee"
3. **Keep examples short** — do not overwhelm with complexity
4. **Add comments** — every non-obvious line should be commented
5. **Prefer clarity over cleverness** — readable code over concise tricks

---

## 🤖 Agents

An **agent** is Claude configured with:
- A **role** (e.g., tutor, code reviewer, DevOps helper)
- **Tools** it can use (e.g., web search, code execution)
- A **personality/tone** (friendly, formal, patient)

See [`agents/README.md`](./agents/README.md) for examples.

---

## 🛠️ Skills

A **skill** is a reusable prompt template or capability that can be plugged into an agent or used directly. Think of it as a "power-up" for Claude.

See [`skills/README.md`](./skills/README.md) for examples.

---

## 🚫 What to Avoid

- Do NOT use jargon without explaining it first
- Do NOT skip steps assuming the student knows them
- Do NOT produce production-grade complexity for beginner examples
