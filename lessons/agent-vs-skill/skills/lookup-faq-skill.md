# Skill: Lookup FAQ

## What This Skill Does

**Input:** A ticket category (`"billing"`, `"technical"`, or `"general"`)  
**Output:** A list of relevant FAQ entries (question + answer pairs)

This skill just retrieves relevant knowledge. It does **not** decide whether the FAQ is sufficient, or what to do if nothing matches — that's the agent's job.

---

## Why This Is a Skill (Not an Agent)

- Given a category, the output is always predictable (pull the right FAQ items)
- No judgment about *whether* to look something up
- No judgment about *what to do* with the results
- Pure retrieval: input → lookup → output

---

## The Skill Prompt

> **Note for beginners:** In a real application, this skill would query a database or vector store. Here we simulate it with a knowledge base embedded in the prompt. The principle is the same.

```
You are a FAQ lookup assistant. Given a ticket category, return the most relevant 
FAQ entries from the knowledge base below.

Return ONLY a JSON array of objects. No extra text. Format:
[
  { "question": "...", "answer": "..." },
  { "question": "...", "answer": "..." }
]

Return at most 3 entries. If nothing is relevant, return an empty array: []

--- KNOWLEDGE BASE ---

BILLING:
Q: How do I get a refund?
A: Refunds are processed within 5-7 business days. Contact billing@company.com with your order number.

Q: How do I update my payment method?
A: Go to Settings → Billing → Payment Methods and click "Update".

Q: Why was I charged twice?
A: Duplicate charges are automatically reversed within 24 hours. If not resolved, email billing@company.com.

TECHNICAL:
Q: I can't log in — what do I do?
A: Try resetting your password at /reset-password. If the problem persists, clear your browser cache and try again.

Q: The app is running slowly — how do I fix it?
A: Try refreshing the page. If slowness continues, check our status page at status.company.com for ongoing incidents.

Q: I'm getting an error message — what does it mean?
A: Most error messages include an error code. Visit docs.company.com/errors to look up your specific code.

GENERAL:
Q: How do I change my account email?
A: Go to Settings → Profile → Contact Information and update your email address.

Q: Where can I find the documentation?
A: Full documentation is available at docs.company.com.

Q: How do I contact support?
A: You can reach us at support@company.com or via this chat system.

--- END OF KNOWLEDGE BASE ---

Category to look up: [CATEGORY]
```

---

## Example Usage

**Input:** `"technical"`

**Output:**
```json
[
  {
    "question": "I can't log in — what do I do?",
    "answer": "Try resetting your password at /reset-password. If the problem persists, clear your browser cache and try again."
  },
  {
    "question": "I'm getting an error message — what does it mean?",
    "answer": "Most error messages include an error code. Visit docs.company.com/errors to look up your specific code."
  }
]
```

---

## Code Example

```python
import anthropic
import json

client = anthropic.Anthropic()

# The full prompt template (shortened here for readability)
LOOKUP_FAQ_PROMPT = """
You are a FAQ lookup assistant. Given a ticket category, return the most relevant 
FAQ entries from the knowledge base below.

Return ONLY a JSON array. No extra text. Return at most 3 entries.
If nothing is relevant, return: []

--- KNOWLEDGE BASE ---
[... FAQ content here ...]
--- END OF KNOWLEDGE BASE ---

Category to look up: {category}
"""

def lookup_faq(category: str) -> list:
    """
    Skill: Retrieve FAQ entries for a given category.
    
    Input:  category string ("billing", "technical", or "general")
    Output: list of dicts with "question" and "answer" keys
    
    No reasoning inside — just retrieves and returns.
    """
    prompt = LOOKUP_FAQ_PROMPT.format(category=category)
    
    response = client.messages.create(
        model="claude-opus-4-5",
        max_tokens=512,
        messages=[{"role": "user", "content": prompt}]
    )
    
    return json.loads(response.content[0].text)


# --- Example usage ---
faq_entries = lookup_faq("technical")
for entry in faq_entries:
    print(f"Q: {entry['question']}")
    print(f"A: {entry['answer']}")
    print()
```

---

## Key Observations

- ✅ Pure input/output: give it a category, get back FAQ items
- ✅ No judgment about whether the FAQ answers are good enough
- ✅ No judgment about whether to escalate if nothing matches
- ✅ Can be replaced with a real database lookup without changing the agent
- ❌ Does NOT decide what to do if the FAQ is empty — that's the agent's job
- ❌ Does NOT write the reply — that's the draft-reply skill's job
