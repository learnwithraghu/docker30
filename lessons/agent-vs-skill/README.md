# Lesson: When to Use a Skill vs When to Use an Agent

## The Question That Started This Lesson

> *"I see a Skill as equivalent to a function — it takes an input and produces an output based on predefined steps, with no brain or reasoning. So if a task requires reasoning and decision-making, that's Agent territory, not Skill territory. An Agent should orchestrate a group of Skills and handle the thinking."*

**That's exactly right.** This lesson will make that crystal clear with a hands-on example.

---

## The Mental Model

### Skill = A Function

A skill is like a function in programming:

```
input → [fixed steps, no judgment] → output
```

- It **always does the same thing** given the same input
- It has **no opinion** about whether it should run
- It has **no awareness** of the bigger picture
- It does **one job**, and does it well

### Agent = A Manager with a Toolbox

An agent is the reasoning layer:

```
situation → [thinks, decides, calls skills, handles surprises] → result
```

- It **reads the situation** and decides what to do
- It **chooses which skills** to call, and in what order
- It **handles unexpected cases** — what if a skill returns nothing useful?
- It **connects the dots** between multiple skill outputs

---

## The "Wrong Way" Trap (Habib's Mistake)

Imagine you want to build a customer support assistant. You might be tempted to create a skill like this:

```
Skill: "Handle Customer Ticket"

Input: customer email
Steps:
  1. Figure out what the customer wants
  2. Decide if it's urgent
  3. Look up the right answer
  4. Decide on the tone to use
  5. Write a reply
  6. If still unsatisfied, escalate

Output: reply email
```

**This is wrong.** Steps 1, 2, 4, and 6 require *judgment* — they are reasoning steps, not mechanical steps. You've accidentally built an agent disguised as a skill.

**The problem:** That "skill" is not reusable. It does everything, so you can't reuse any part of it. It's also impossible to test, debug, or improve individual steps.

---

## The Right Architecture

Break it apart:

```
┌─────────────────────────────────────────────────┐
│                  SUPPORT AGENT                  │  ← Reasoning lives here
│  "What should I do with this ticket?"           │
│                                                 │
│   Calls Skills:                                 │
│     1. classify-ticket   → category + urgency   │
│     2. lookup-faq        → relevant answers     │
│     3. draft-reply       → formatted email      │
└────────────┬────────────────────────────────────┘
             │ orchestrates
    ┌────────┼────────────────────────────┐
    ▼        ▼                            ▼
┌────────┐ ┌──────────┐           ┌──────────────┐
│classify│ │lookup-faq│           │ draft-reply  │
│-ticket │ │  skill   │           │    skill     │
│ skill  │ │          │           │              │
│        │ │input:    │           │input:        │
│input:  │ │ category │           │ faq_content  │
│ email  │ │          │           │ tone         │
│        │ │output:   │           │              │
│output: │ │ faq list │           │output:       │
│category│ └──────────┘           │ email draft  │
│urgency │                        └──────────────┘
└────────┘
```

Each skill is a pure function. The agent does all the thinking.

---

## Side-by-Side Comparison

| | Skill | Agent |
|--|-------|-------|
| **Does it reason?** | ❌ No | ✅ Yes |
| **Does it make decisions?** | ❌ No | ✅ Yes |
| **Can it call other tools?** | ❌ No | ✅ Yes |
| **Is it reusable?** | ✅ Very reusable | Less reusable |
| **Is it testable?** | ✅ Easy to unit-test | Harder to test |
| **Does it know "why" it's running?** | ❌ No | ✅ Yes |
| **Equivalent to in programming** | A function | A controller/orchestrator |

---

## 📁 Files in This Lesson

### Skills (the "functions")

| File | What it does |
|------|-------------|
| [`skills/classify-ticket-skill.md`](./skills/classify-ticket-skill.md) | Takes a customer email → outputs category + urgency. No judgment about what to *do* with that info. |
| [`skills/lookup-faq-skill.md`](./skills/lookup-faq-skill.md) | Takes a category → returns relevant FAQ entries. Doesn't decide *whether* to look up FAQs. |
| [`skills/draft-reply-skill.md`](./skills/draft-reply-skill.md) | Takes FAQ content + a tone → writes a reply email. Doesn't decide the tone itself. |

### Agent (the "manager")

| File | What it does |
|------|-------------|
| [`agent/support-agent.md`](./agent/support-agent.md) | Reads the ticket, decides which skills to call, handles edge cases, produces the final reply. |

---

## 🔑 The Rule of Thumb

> **If you find yourself writing "decide", "figure out", "choose", or "if this then that" inside a skill — stop. That logic belongs in the agent.**

A skill should read like a recipe with no choices:
- ✅ "Take the email text. Extract the topic and urgency level. Return them as JSON."
- ❌ "Take the email text. Figure out what the customer really wants. Decide if it needs escalation."

---

## 🚀 What to Do Next

1. Read each skill file — notice how they are simple and mechanical
2. Read the agent file — notice how all the reasoning and "what if" logic lives there
3. Try modifying one skill without touching the agent — that's the power of separation
