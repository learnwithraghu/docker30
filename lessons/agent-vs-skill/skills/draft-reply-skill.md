# Skill: Draft Reply

## What This Skill Does

**Input:** FAQ content (the answer text) + a tone instruction  
**Output:** A polished, ready-to-send customer support reply email

This skill just writes. It does **not** decide what tone to use, or whether the FAQ content is adequate — those decisions come from the agent.

---

## Why This Is a Skill (Not an Agent)

- Given FAQ content and a tone, the output is always a well-formatted reply
- No judgment about *which* FAQ to use — that was already decided upstream
- No judgment about *what tone* to adopt — the agent passes that in
- Pure transformation: (content + tone) → formatted email

---

## The Skill Prompt

```
You are a customer support email writer. Write a professional reply email 
to a customer support ticket.

Use the provided FAQ content as the basis for your answer.
Follow the tone instruction exactly.

Tone options:
- "empathetic_urgent"  → warm, reassuring, fast-paced — for high urgency tickets
- "friendly_helpful"   → casual and helpful — for medium urgency tickets  
- "brief_professional" → concise and formal — for low urgency tickets

Rules:
- Start with a brief acknowledgment of the customer's issue
- Provide the answer from the FAQ content
- End with an offer to help further
- Do NOT make up information not present in the FAQ content
- Do NOT include subject line — just the email body

Tone: [TONE]

FAQ content to base the answer on:
---
[FAQ_CONTENT]
---

Write the reply email body now:
```

---

## Example Usage

**Input tone:** `"empathetic_urgent"`

**Input FAQ content:**
```
Q: I can't log in — what do I do?
A: Try resetting your password at /reset-password. If the problem persists, 
   clear your browser cache and try again.
```

**Output:**
```
Hi there,

I completely understand how stressful it is to be locked out, especially 
when you have something important coming up — I'm here to help you get 
back in right away.

The quickest fix is to reset your password at /reset-password. Once you've 
done that, if you're still seeing the issue, try clearing your browser cache 
and logging in again — that resolves the majority of login problems.

Please reply to this email immediately if you're still stuck and I'll escalate 
this to our technical team as a priority.

We've got you — you'll be back in shortly!

Best,
Support Team
```

---

## Example: Low Urgency Tone

**Input tone:** `"brief_professional"`

**Input FAQ content:**
```
Q: How do I update my payment method?
A: Go to Settings → Billing → Payment Methods and click "Update".
```

**Output:**
```
Hello,

Thank you for reaching out.

To update your payment method, navigate to Settings → Billing → Payment Methods 
and click "Update".

Please let us know if you need any further assistance.

Best regards,
Support Team
```

Notice how the **same skill** produces very different outputs based on the tone input. The tone decision was made by the **agent**, not by this skill.

---

## Code Example

```python
import anthropic

client = anthropic.Anthropic()

DRAFT_REPLY_PROMPT = """
You are a customer support email writer. Write a professional reply email 
to a customer support ticket.

Use the provided FAQ content as the basis for your answer.
Follow the tone instruction exactly.

Tone:
- "empathetic_urgent"  → warm, reassuring, fast-paced
- "friendly_helpful"   → casual and helpful
- "brief_professional" → concise and formal

Rules:
- Acknowledge the issue briefly
- Answer using the FAQ content
- End with an offer to help further
- Do NOT make up information not in the FAQ content
- Do NOT include a subject line

Tone: {tone}

FAQ content:
---
{faq_content}
---

Write the reply email body now:
"""

def draft_reply(faq_content: str, tone: str) -> str:
    """
    Skill: Draft a customer support reply email.
    
    Input:  faq_content (str) — the answer to base the reply on
            tone (str)        — "empathetic_urgent", "friendly_helpful", or "brief_professional"
    Output: email body (str)
    
    No reasoning inside — just formats the given content into an email.
    """
    prompt = DRAFT_REPLY_PROMPT.format(faq_content=faq_content, tone=tone)
    
    response = client.messages.create(
        model="claude-opus-4-5",
        max_tokens=512,
        messages=[{"role": "user", "content": prompt}]
    )
    
    return response.content[0].text


# --- Example usage ---
faq = "Try resetting your password at /reset-password. If the problem persists, clear your browser cache."
reply = draft_reply(faq_content=faq, tone="empathetic_urgent")
print(reply)
```

---

## Key Observations

- ✅ Two clear inputs, one clear output — pure function behaviour
- ✅ The `tone` parameter is decided by the agent and passed in — not decided here
- ✅ Easily testable: given the same FAQ and tone, always produces a similar reply
- ✅ Swap this skill with a different writing style without touching the agent
- ❌ Does NOT decide whether the FAQ is sufficient — that's the agent's job
- ❌ Does NOT decide the tone — the agent does, based on urgency
