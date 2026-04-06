# 🤖 Agents — What Are They and How Do They Work?

## What is a Claude Agent?

Think of a **Claude Agent** like hiring a specialist employee.

Instead of asking a generic assistant "do everything", you create a focused assistant with:
- A clear **job title** (role)
- Specific **tools** they are allowed to use
- A defined **personality and tone**
- A **goal** they are optimizing for

---

## Real-World Analogy

Imagine you run a school:
- You hire a **Math Tutor** — explains math patiently, shows working step-by-step
- You hire a **Code Reviewer** — reads student code, finds bugs, gives constructive feedback
- You hire a **DevOps Helper** — helps with servers, Docker, and deployment

Each "employee" has the same base intelligence, but a different **focus** and **behavior**.

That's exactly what a Claude Agent is!

---

## Agent Building Blocks

Every agent is defined by three things:

| Building Block | What it does | Example |
|----------------|-------------|---------|
| **System Prompt** | Gives Claude its role & personality | "You are a patient tutor for beginners..." |
| **Tools** | What the agent is allowed to do | Web search, run code, read files |
| **Memory** | What context the agent remembers | Previous messages, student history |

---

## 📁 Examples in This Folder

| File | What it shows |
|------|--------------|
| [`tutor-agent.md`](./tutor-agent.md) | A beginner-friendly tutor agent |
| [`code-reviewer-agent.md`](./code-reviewer-agent.md) | A code review agent |

---

## How to Read the Examples

Each example has:
1. **Purpose** — what this agent does
2. **System Prompt** — the instructions you give Claude
3. **Example Conversation** — see it in action
4. **Key Points** — what makes it work

---

## 🚀 Try it Yourself

After reading the examples, try creating your own agent! Ideas for beginners:
- A **recipe helper** that suggests meals based on ingredients
- A **quiz master** that tests you on topics
- A **rubber duck debugger** that helps you think through code problems
