# 🛠️ Skills — What Are They and How Do They Work?

## What is a Skill?

A **skill** is a reusable prompt template that tells Claude *how* to do a specific task.

Think of it like a **recipe card**:
- A recipe tells you exactly what steps to follow to make a dish
- A skill tells Claude exactly what steps to follow to complete a task

You can use skills:
1. **Directly** — paste the skill template and fill in the blanks
2. **Inside an agent** — give an agent a set of skills it knows how to use

---

## Real-World Analogy

Imagine you're training a new employee:
- You write a **procedure document** for "How to handle a customer complaint"
- Any employee can follow this procedure — it produces consistent, high-quality results

Skills are Claude's procedure documents.

---

## Skill vs Agent — What's the Difference?

| | Skill | Agent |
|--|-------|-------|
| **What it is** | A reusable task template | A configured AI assistant |
| **Has a personality?** | No | Yes |
| **Has memory?** | No | Yes (in conversation) |
| **Has tools?** | No | Yes (web, code, etc.) |
| **Best for** | A single, well-defined task | Ongoing conversations & complex workflows |

**Simple rule:** Use a skill for a one-off task. Use an agent for an ongoing assistant.

---

## 📁 Examples in This Folder

| File | What it shows |
|------|--------------|
| [`summarize-skill.md`](./summarize-skill.md) | Summarize any text in different styles |
| [`explain-code-skill.md`](./explain-code-skill.md) | Explain code to a beginner |

---

## How to Read the Examples

Each example has:
1. **Purpose** — what this skill does
2. **The Skill Template** — the reusable prompt with `[PLACEHOLDERS]`
3. **Filled-in Example** — see it in action with real content
4. **Output** — what Claude produces
5. **Variations** — ways to customize the skill

---

## 🚀 Try it Yourself

After reading the examples, create your own skill! Ideas for beginners:
- A **bug finder** skill that analyzes code for errors
- A **flashcard maker** skill that turns notes into study cards
- A **plain English** skill that rewrites technical docs for non-technical readers
