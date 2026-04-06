# Skill: Classify Ticket

## What This Skill Does

**Input:** A raw customer support email (plain text)  
**Output:** A JSON object with `category` and `urgency`

That's it. This skill has **no opinion** about what to do with the result. It just labels the ticket.

---

## Why This Is a Skill (Not an Agent)

This task is mechanical and deterministic:
- Given any support email, there's a clear set of categories it can fall into
- The same email should always produce the same category
- There is no "should I run?" judgment needed — that's the agent's job
- There are no follow-up decisions to make — just extract and return labels

---

## The Skill Prompt

```
You are a ticket classifier. Your only job is to read a customer support email 
and return a classification in JSON format.

Categories (pick exactly one):
- "billing"    → questions about payments, invoices, refunds, pricing
- "technical"  → app errors, bugs, login issues, performance problems
- "general"    → account info, feature questions, feedback, anything else

Urgency levels (pick exactly one):
- "high"    → customer is blocked from using the product, or mentions legal/financial loss
- "medium"  → customer is frustrated but can still use the product
- "low"     → general question, no urgency expressed

Return ONLY valid JSON. No explanation, no extra text. Format:
{
  "category": "<category>",
  "urgency": "<urgency>",
  "reason": "<one sentence explaining why>"
}

Email to classify:
---
[PASTE EMAIL HERE]
---
```

---

## Example: Using the Skill

**Input email:**
```
Subject: Can't log in since this morning!!

Hi, I've been trying to log in to my account since 9am and keep getting 
"Invalid credentials" even though my password is correct. I have a presentation 
in 2 hours and NEED to access my files. Please help urgently!
```

**Output:**
```json
{
  "category": "technical",
  "urgency": "high",
  "reason": "User is locked out of the product and has a time-sensitive business need."
}
```

---

## Example: Another Input

**Input email:**
```
Subject: How do I change my billing address?

Hello, I recently moved and need to update my billing address for future invoices. 
Not urgent, just want to keep things up to date. Thanks!
```

**Output:**
```json
{
  "category": "billing",
  "urgency": "low",
  "reason": "Simple billing update request with no expressed urgency."
}
```

---

## Code Example

```python
import anthropic
import json

client = anthropic.Anthropic()

# The skill prompt — fixed, reusable, no reasoning inside
CLASSIFY_TICKET_PROMPT = """
You are a ticket classifier. Your only job is to read a customer support email 
and return a classification in JSON format.

Categories (pick exactly one):
- "billing"    → questions about payments, invoices, refunds, pricing
- "technical"  → app errors, bugs, login issues, performance problems
- "general"    → account info, feature questions, feedback, anything else

Urgency levels (pick exactly one):
- "high"    → customer is blocked from using the product, or mentions legal/financial loss
- "medium"  → customer is frustrated but can still use the product
- "low"     → general question, no urgency expressed

Return ONLY valid JSON. No explanation, no extra text. Format:
{{
  "category": "<category>",
  "urgency": "<urgency>",
  "reason": "<one sentence explaining why>"
}}

Email to classify:
---
{email}
---
"""

def classify_ticket(email_text: str) -> dict:
    """
    Skill: Classify a support ticket.
    
    Input:  raw email text (string)
    Output: dict with category, urgency, and reason
    
    This function has NO reasoning — it just runs the prompt and returns the result.
    """
    prompt = CLASSIFY_TICKET_PROMPT.format(email=email_text)
    
    response = client.messages.create(
        model="claude-opus-4-5",
        max_tokens=256,
        messages=[{"role": "user", "content": prompt}]
    )
    
    # Parse the JSON output and return it
    return json.loads(response.content[0].text)


# --- Example usage ---
email = """
Subject: Can't log in since this morning!!
I've been trying to log in since 9am and keep getting "Invalid credentials". 
I have a presentation in 2 hours. Please help!
"""

result = classify_ticket(email)
print(result)
# {'category': 'technical', 'urgency': 'high', 'reason': '...'}
```

---

## Key Observations

- ✅ The function `classify_ticket()` takes input, runs fixed steps, returns output
- ✅ It contains **zero decision-making** — it will run regardless of context
- ✅ It can be unit-tested easily: given email X, expect category Y
- ✅ It can be reused by any agent that needs ticket classification
- ❌ It does NOT decide "should I escalate this?" — that's the agent's job
- ❌ It does NOT look up answers — that's a different skill
