# 📝 Skill: Summarize Text

## Purpose

Summarize any block of text in a chosen style. Useful for:
- Turning long articles into short notes
- Creating an executive summary for a report
- Making technical content beginner-friendly
- Creating bullet-point study notes

---

## The Skill Template

Copy this template, fill in the `[PLACEHOLDERS]`, and paste it to Claude:

```
Please summarize the following text.

Summary style: [STYLE]
Target audience: [AUDIENCE]
Maximum length: [LENGTH]

Text to summarize:
---
[PASTE YOUR TEXT HERE]
---

Format the summary as: [FORMAT]
```

### Placeholder Guide

| Placeholder | Options / Examples |
|-------------|-------------------|
| `[STYLE]` | `concise`, `detailed`, `bullet points`, `story-style`, `ELI5 (explain like I'm 5)` |
| `[AUDIENCE]` | `a 10-year-old`, `a beginner developer`, `a business executive`, `a technical expert` |
| `[LENGTH]` | `3 sentences`, `100 words`, `5 bullet points`, `1 paragraph` |
| `[FORMAT]` | `plain paragraph`, `bullet list`, `numbered list`, `table` |

---

## Example 1: Simple Summary

**Filled-in template:**

```
Please summarize the following text.

Summary style: concise
Target audience: a beginner developer
Maximum length: 3 sentences

Text to summarize:
---
Docker is a platform that enables developers to package applications and their 
dependencies into standardized units called containers. Containers are isolated 
environments that include everything needed to run an application: code, runtime, 
system tools, libraries, and settings. Unlike virtual machines, containers share 
the host operating system's kernel, making them lightweight and fast to start.
---

Format the summary as: plain paragraph
```

**Claude's output:**

> Docker packages your app and everything it needs into a "container" that runs the same way on any computer. Containers are much lighter and faster than virtual machines because they share the computer's operating system. This solves the "it works on my machine" problem in software development.

---

## Example 2: Bullet-Point Study Notes

**Filled-in template:**

```
Please summarize the following text.

Summary style: bullet points
Target audience: a student preparing for an exam
Maximum length: 5 bullet points

Text to summarize:
---
HTTP (HyperText Transfer Protocol) is the foundation of data communication on 
the Web. It is a request-response protocol where a client sends a request to a 
server and the server returns a response. The most common HTTP methods are GET 
(retrieve data), POST (send data), PUT (update data), and DELETE (remove data). 
HTTP status codes indicate the result of a request: 200 means success, 404 means 
not found, and 500 means server error. HTTPS is the secure version of HTTP and 
encrypts data using TLS/SSL.
---

Format the summary as: bullet list
```

**Claude's output:**

> - **HTTP** is how web browsers and servers talk to each other (request → response)
> - **Main methods:** GET (read), POST (create), PUT (update), DELETE (remove)
> - **Status codes:** 200 = OK, 404 = Not Found, 500 = Server Error
> - **HTTPS** = secure HTTP with encrypted data (uses TLS/SSL)
> - Rule of thumb: 2xx = success, 4xx = client error, 5xx = server error

---

## Example 3: ELI5 (Explain Like I'm 5)

**Filled-in template:**

```
Please summarize the following text.

Summary style: ELI5 (explain like I'm 5)
Target audience: someone who has never coded before
Maximum length: 2-3 sentences

Text to summarize:
---
An API (Application Programming Interface) is a set of rules and protocols that 
allows different software applications to communicate with each other. APIs define 
the methods and data formats that applications can use to request and exchange 
information, acting as an intermediary layer between different systems.
---

Format the summary as: plain paragraph
```

**Claude's output:**

> Imagine two toy robots that don't speak the same language. An API is like a translator that sits between them and helps them understand each other and share information. When your weather app gets today's forecast, it's using an API to "ask" a weather server for the data.

---

## 🛠️ How to Use This Skill

### Option A: Direct (Claude.ai)
1. Copy the template above
2. Fill in the placeholders
3. Paste into Claude chat
4. Get your summary!

### Option B: In Code (API)
```python
import anthropic

client = anthropic.Anthropic()

# Define the skill as a function
def summarize(text, style="concise", audience="a beginner", length="3 sentences", format="bullet list"):
    prompt = f"""Please summarize the following text.

Summary style: {style}
Target audience: {audience}
Maximum length: {length}

Text to summarize:
---
{text}
---

Format the summary as: {format}"""

    response = client.messages.create(
        model="claude-opus-4-5",
        max_tokens=512,
        messages=[{"role": "user", "content": prompt}]
    )
    return response.content[0].text

# Use the skill
my_text = "Docker is a platform that enables developers to package applications..."
result = summarize(my_text, style="bullet points", audience="a student", length="5 bullet points")
print(result)
```

---

## 🚀 Variations to Try

| Variation | Change this in the template |
|-----------|---------------------------|
| **Tweet-size summary** | Length: "1 tweet (max 280 characters)" |
| **Technical deep dive** | Style: "detailed technical", Audience: "senior engineer" |
| **Meeting notes** | Style: "action items and key decisions", Format: "numbered list" |
| **Flashcard** | Format: "a question on one side and the answer on the other" |
