# Agent: Customer Support Assistant

## What This Agent Does

This agent handles incoming customer support tickets end-to-end. Unlike the skills, **all the reasoning and decision-making lives here**.

The agent:
1. **Reads** the ticket
2. **Classifies** it (using the classify-ticket skill)
3. **Looks up** relevant FAQ content (using the lookup-faq skill)
4. **Decides** what tone to use based on urgency
5. **Drafts** the reply (using the draft-reply skill)
6. **Handles edge cases** — what if the FAQ has no answer? What if it's a legal threat?

---

## Why This Is an Agent (Not a Skill)

This task requires judgment at every step:
- *Should I escalate this ticket?* → decision
- *Which tone is appropriate?* → decision
- *Is the FAQ answer good enough, or should I flag for human review?* → decision
- *What if the customer is threatening legal action?* → exception handling

None of these decisions belong in a skill. They all live here, in the agent.

---

## The Agent System Prompt

```
You are a customer support agent for a software company. You handle incoming 
support tickets and produce a final reply for the customer.

You have access to three tools (skills):
1. classify_ticket(email_text) → returns { category, urgency, reason }
2. lookup_faq(category) → returns a list of FAQ entries [{ question, answer }]
3. draft_reply(faq_content, tone) → returns a formatted email reply

Your decision-making process:
1. Use classify_ticket to understand the ticket
2. Use lookup_faq to find relevant answers
3. Decide the right tone based on urgency:
   - urgency "high"   → use tone "empathetic_urgent"
   - urgency "medium" → use tone "friendly_helpful"
   - urgency "low"    → use tone "brief_professional"
4. Use draft_reply to write the email

Special cases you must handle with your own judgment:
- If lookup_faq returns empty results → flag the ticket for human review instead of drafting a reply
- If the ticket mentions legal threats, account hacking, or financial fraud → immediately escalate; do NOT draft a reply
- If the ticket is abusive or contains profanity → draft a short, firm, professional reply without engaging with the tone

Your final output must always be one of:
A) The draft reply email (ready to send)
B) An escalation notice explaining why the ticket needs human review
```

---

## The Full Python Implementation

This is where you see all three skills being orchestrated:

```python
import anthropic
import json

client = anthropic.Anthropic()

# ─────────────────────────────────────────
# Import the three skills
# (In a real project these would be in separate files)
# ─────────────────────────────────────────

def classify_ticket(email_text: str) -> dict:
    """Skill: classify a ticket → {category, urgency, reason}"""
    prompt = f"""
    Classify this support email. Return ONLY valid JSON:
    {{"category": "billing|technical|general", "urgency": "high|medium|low", "reason": "..."}}
    
    Email: ---
    {email_text}
    ---
    """
    response = client.messages.create(
        model="claude-opus-4-5",
        max_tokens=256,
        messages=[{"role": "user", "content": prompt}]
    )
    return json.loads(response.content[0].text)


def lookup_faq(category: str) -> list:
    """Skill: look up FAQ entries for a category → [{question, answer}]"""
    # Simplified inline FAQ for this example
    faqs = {
        "billing": [
            {"question": "How do I get a refund?", "answer": "Refunds take 5-7 days. Email billing@company.com with your order number."},
            {"question": "How do I update my payment method?", "answer": "Go to Settings → Billing → Payment Methods and click Update."},
        ],
        "technical": [
            {"question": "I can't log in", "answer": "Reset your password at /reset-password. Then clear your browser cache."},
            {"question": "The app is slow", "answer": "Check status.company.com for outages. Try refreshing the page."},
        ],
        "general": [
            {"question": "How do I change my email?", "answer": "Go to Settings → Profile → Contact Information."},
            {"question": "Where are the docs?", "answer": "Full documentation is at docs.company.com."},
        ]
    }
    return faqs.get(category, [])


def draft_reply(faq_content: str, tone: str) -> str:
    """Skill: write a support reply email given FAQ content and a tone"""
    tone_instructions = {
        "empathetic_urgent": "warm, reassuring, fast-paced — the customer is blocked",
        "friendly_helpful": "casual and helpful — the customer is frustrated but can continue",
        "brief_professional": "concise and formal — routine request"
    }
    prompt = f"""
    Write a customer support reply email.
    Tone: {tone_instructions.get(tone, 'professional')}
    Base it ONLY on this FAQ content:
    ---
    {faq_content}
    ---
    Write the email body only (no subject line):
    """
    response = client.messages.create(
        model="claude-opus-4-5",
        max_tokens=512,
        messages=[{"role": "user", "content": prompt}]
    )
    return response.content[0].text


# ─────────────────────────────────────────
# The Agent — all reasoning lives here
# ─────────────────────────────────────────

ESCALATION_KEYWORDS = ["lawyer", "lawsuit", "sue", "fraud", "hack", "stolen"]

def support_agent(email_text: str) -> str:
    """
    Agent: Handle a customer support ticket end-to-end.
    
    This is where all the decision-making happens.
    The skills are called based on what the agent decides to do.
    """
    print("🤖 Agent: Starting ticket processing...")

    # ── REASONING STEP 1: Check for immediate escalation triggers ──────────
    # The agent uses its own judgment before calling any skills
    email_lower = email_text.lower()
    if any(keyword in email_lower for keyword in ESCALATION_KEYWORDS):
        print("⚠️  Agent: Escalation trigger detected. Skipping skills.")
        return (
            "ESCALATION REQUIRED\n"
            "Reason: Ticket contains legal or security-related language.\n"
            "Action: Route to senior support team immediately. Do not send automated reply."
        )

    # ── SKILL CALL 1: Classify the ticket ──────────────────────────────────
    print("📋 Agent: Calling classify_ticket skill...")
    classification = classify_ticket(email_text)
    category = classification["category"]
    urgency = classification["urgency"]
    print(f"   Result → category={category}, urgency={urgency}")

    # ── SKILL CALL 2: Look up FAQ ───────────────────────────────────────────
    print("🔍 Agent: Calling lookup_faq skill...")
    faq_entries = lookup_faq(category)
    print(f"   Result → {len(faq_entries)} FAQ entries found")

    # ── REASONING STEP 2: Handle the case where no FAQ matches ─────────────
    # The agent makes a judgment call — don't draft a bad reply, escalate instead
    if not faq_entries:
        print("🤔 Agent: No FAQ found. Deciding to escalate for human review.")
        return (
            f"HUMAN REVIEW REQUIRED\n"
            f"Reason: No FAQ entry found for category '{category}'.\n"
            f"Urgency: {urgency}\n"
            f"Action: Assign to a support specialist for a manual response."
        )

    # ── REASONING STEP 3: Choose the tone based on urgency ─────────────────
    # The agent decides the tone — the skill just executes it
    tone_map = {
        "high": "empathetic_urgent",
        "medium": "friendly_helpful",
        "low": "brief_professional"
    }
    tone = tone_map[urgency]
    print(f"🎭 Agent: Decided tone → {tone}")

    # Combine FAQ answers into a single content block for the draft skill
    faq_content = "\n\n".join(
        f"Q: {entry['question']}\nA: {entry['answer']}"
        for entry in faq_entries
    )

    # ── SKILL CALL 3: Draft the reply ──────────────────────────────────────
    print("✍️  Agent: Calling draft_reply skill...")
    reply = draft_reply(faq_content=faq_content, tone=tone)
    print("✅ Agent: Reply drafted successfully.\n")

    return reply


# ─────────────────────────────────────────
# Test it with three different tickets
# ─────────────────────────────────────────

if __name__ == "__main__":

    # Test 1: High urgency technical issue
    print("=" * 60)
    print("TEST 1: High urgency login problem")
    print("=" * 60)
    ticket_1 = """
    Subject: URGENT - Can't log in, have a demo in 1 hour!
    I've been trying to log in since this morning and keep getting 
    "Invalid credentials". I have a client demo in one hour and 
    need access to my files NOW. Please help immediately!
    """
    print(support_agent(ticket_1))

    # Test 2: Low urgency billing question
    print("\n" + "=" * 60)
    print("TEST 2: Low urgency billing question")
    print("=" * 60)
    ticket_2 = """
    Subject: Billing address update
    Hi, I recently moved and just want to update my billing address 
    for future invoices. No rush, thanks!
    """
    print(support_agent(ticket_2))

    # Test 3: Legal threat — agent escalates without using skills
    print("\n" + "=" * 60)
    print("TEST 3: Legal threat — agent escalates")
    print("=" * 60)
    ticket_3 = """
    Subject: I'm calling my lawyer
    Your app deleted all my data. I'm going to sue your company 
    if this isn't resolved by end of day.
    """
    print(support_agent(ticket_3))
```

---

## Reading the Output

When you run Test 1, you'll see:

```
🤖 Agent: Starting ticket processing...
📋 Agent: Calling classify_ticket skill...
   Result → category=technical, urgency=high
🔍 Agent: Calling lookup_faq skill...
   Result → 2 FAQ entries found
🎭 Agent: Decided tone → empathetic_urgent
✍️  Agent: Calling draft_reply skill...
✅ Agent: Reply drafted successfully.

Hi there,

I completely understand how urgent this is — I'm going to help you 
get back in right away...
[rest of reply]
```

When you run Test 3:

```
🤖 Agent: Starting ticket processing...
⚠️  Agent: Escalation trigger detected. Skipping skills.

ESCALATION REQUIRED
Reason: Ticket contains legal or security-related language.
Action: Route to senior support team immediately.
```

Notice: **the agent never called any skills** for Test 3. It made that decision itself.

---

## The Key Insight

Look at where decisions are made vs. where work is done:

| Decision | Made by | Executed by |
|----------|---------|-------------|
| Is this a legal threat? | Agent | Agent (no skill needed) |
| What category is this? | Agent (decides to ask) | `classify_ticket` skill |
| Is the FAQ sufficient? | Agent | Agent (no skill needed) |
| What tone should we use? | Agent | Agent passes to skill |
| How to write the email | Agent (decides to ask) | `draft_reply` skill |

**The skills never make decisions. The agent never does the execution work directly.**

That's the separation of concerns — and it's what makes the system maintainable, testable, and extendable.
