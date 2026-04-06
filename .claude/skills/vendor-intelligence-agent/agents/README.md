# Vendor Intelligence Agents — Index & Routing Guide

5 specialized agents, each using a different Claude model, covering all aspects of vendor analysis.

---

## 🎯 Quick Routing Guide

**Answer these questions to pick the right agent:**

### "I need a quick answer right now"
→ **Fast Analysis Agent** (Claude 3.5 Haiku)  
Example: "Top 10 vendors by spend?" | "Which vendors are late?"

### "I need to understand why something happened"
→ **Deep Analysis Agent** (Claude 3 Opus)  
Example: "Why did spend with Vendor X jump 40%?" | "What's our quality trend?"

### "I need to make a strategic decision"
→ **Strategic Advisor Agent** (Claude 3.5 Sonnet)  
Example: "Should we renew this vendor?" | "How should we consolidate?"

### "I need to assess risk and compliance"
→ **Risk Monitor Agent** (Claude 3 Opus)  
Example: "Which vendors pose supply chain risk?" | "ESG compliance status?"

### "I need to find cost savings"
→ **Cost Optimizer Agent** (Claude 3.5 Sonnet)  
Example: "Where can we cut 15% from spend?" | "Consolidation opportunities?"

---

## 📊 Agent Comparison Matrix

| Agent | Model | Best For | Speed | Cost | Depth |
|-------|-------|----------|-------|------|-------|
| **Fast Analysis** | Haiku | Quick answers, monitoring | ⚡⚡⚡ Fast | 💰 Cheap | 📊 Surface |
| **Deep Analysis** | Opus | Understanding root causes | ⚡⚡ Med | 💰💰 Mod | 📊📊📊 Deep |
| **Strategic Advisor** | Sonnet | Business decisions | ⚡⚡ Med | 💰💰 Mod | 📊📊 Strategy |
| **Risk Monitor** | Opus | Supply chain risk | ⚡⚡ Med | 💰💰 Mod | 📊📊📊 Risk |
| **Cost Optimizer** | Sonnet | Spend reduction | ⚡⚡ Med | 💰💰 Mod | 📊📊 Financial |

---

## 🤖 The Agents

### 1. Fast Analysis Agent (Claude 3.5 Haiku)
**Role**: Quick vendor analysis & query execution  
**File**: [`fast-analysis-agent.md`](./fast-analysis-agent.md)

**When to use:**
- Real-time vendor lookups
- Quick spend checks
- Simple metric queries
- Dashboard/monitoring

**Typical response time**: <5 seconds  
**Cost per query**: $0.01-0.05  

**Good questions:**
- "Top 5 vendors by spend?"
- "Which vendors are below on-time target?"
- "Defect rates by vendor"

**Hands off to:**
- Deep analysis needed → Deep Analysis Agent
- Strategic decision needed → Strategic Advisor Agent
- Risk assessment needed → Risk Monitor Agent

---

### 2. Deep Analysis Agent (Claude 3 Opus)
**Role**: Comprehensive analysis & anomaly investigation  
**File**: [`deep-analysis-agent.md`](./deep-analysis-agent.md)

**When to use:**
- Multi-metric cross-domain analysis
- Anomaly detection & investigation
- Root-cause analysis
- Complex benchmarking

**Typical response time**: 20-60 seconds  
**Cost per analysis**: $0.15-0.50  

**Good questions:**
- "Why did spend spike with Vendor X?"
- "Analyze vendor Y against all metrics"
- "Rank all vendors and identify underperformers"
- "Is this quality trend getting worse?"

**Hands off to:**
- Strategic recommendation needed → Strategic Advisor Agent
- Cost optimization needed → Cost Optimizer Agent
- Just need speed → Fast Analysis Agent

---

### 3. Strategic Advisor Agent (Claude 3.5 Sonnet)
**Role**: Vendor strategy & business recommendations  
**File**: [`strategic-advisor-agent.md`](./strategic-advisor-agent.md)

**When to use:**
- Vendor portfolio optimization
- Contract renewal decisions
- Sourcing strategy
- Strategic vendor classification
- Supply chain restructuring

**Typical response time**: 45-90 seconds  
**Cost per recommendation**: $0.15-0.35  

**Good questions:**
- "Should we renew with Vendor X?"
- "How should we consolidate our vendor base?"
- "Which vendors should be strategic partners?"
- "What's our optimal supplier diversity strategy?"

**Hands off to:**
- Risk assessment needed → Risk Monitor Agent
- Cost optimization needed → Cost Optimizer Agent
- Need data deep-dive → Deep Analysis Agent

---

### 4. Risk Monitor Agent (Claude 3 Opus)
**Role**: Vendor risk & compliance monitoring  
**File**: [`risk-monitor-agent.md`](./risk-monitor-agent.md)

**When to use:**
- Supply chain risk identification
- ESG and compliance due diligence
- Financial health assessment
- Regulatory and audit risk
- Proactive risk mitigation
- Vendor remediation monitoring

**Typical response time**: 30-90 seconds  
**Cost per assessment**: $0.15-0.50  

**Good questions:**
- "Which vendors pose supply chain risk?"
- "Assess geography concentration risk"
- "ESG compliance audit — who fails?"
- "Which vendors have financial health concerns?"
- "Contract compliance — who's violating terms?"

**Hands off to:**
- Cost optimization needed → Cost Optimizer Agent
- Strategic decision needed → Strategic Advisor Agent
- Performance analysis needed → Deep Analysis Agent

---

### 5. Cost Optimizer Agent (Claude 3.5 Sonnet)
**Role**: Spend analysis & cost reduction  
**File**: [`cost-optimizer-agent.md`](./cost-optimizer-agent.md)

**When to use:**
- Cost reduction initiatives
- Spend consolidation analysis
- Contract renegotiation strategy
- Payment terms optimization
- Maverick spend identification
- Competitive benchmark analysis

**Typical response time**: 45-75 seconds  
**Cost per analysis**: $0.12-0.35  

**Good questions:**
- "Where can we cut 10% from spend?"
- "Should we consolidate in this category?"
- "What's our maverick spend percentage?"
- "Optimize payment terms for working capital"
- "How do our prices compare to market?"

**Hands off to:**
- Strategic decision needed → Strategic Advisor Agent
- Risk assessment needed → Risk Monitor Agent
- Just need numbers → Fast Analysis Agent

---

## 📋 Routing Decision Tree

```
User asks vendor question
│
├─ "I need it NOW" or "Just show me data"
│  └─ → FAST ANALYSIS AGENT
│
├─ "Why did X happen?" or "Deep investigation"
│  └─ → DEEP ANALYSIS AGENT
│
├─ "Should we..?" or "What's the strategy?"
│  ├─ About vendor selection/renewal
│  │  └─ → STRATEGIC ADVISOR AGENT
│  │
│  ├─ About cost/savings
│  │  └─ → COST OPTIMIZER AGENT
│  │
│  └─ About risk/compliance
│     └─ → RISK MONITOR AGENT
│
└─ "Can you help me understand multiple aspects?"
   └─ Route to 2-3 agents in sequence
      (e.g., Deep Analysis + Risk Monitor)
```

---

## 🔄 Multi-Agent Workflows

### Workflow 1: Vendor Evaluation (Buy/Renew Decision)
1. **Fast Analysis Agent** → Pull basic metrics
2. **Deep Analysis Agent** → Analyze against targets and peers
3. **Risk Monitor Agent** → Assess risks
4. **Strategic Advisor Agent** → Recommend decision

**Time**: 5 minutes total  
**Output**: Complete vendor scorecard + recommendation

### Workflow 2: Cost Reduction Initiative
1. **Cost Optimizer Agent** → Identify savings levers
2. **Deep Analysis Agent** → Validate assumptions (if needed)
3. **Strategic Advisor Agent** → Develop implementation strategy

**Time**: 3-4 minutes  
**Output**: Savings plan with phased roadmap

### Workflow 3: Risk Mitigation
1. **Risk Monitor Agent** → Full risk assessment
2. **Deep Analysis Agent** → Root cause analysis (if issues found)
3. **Strategic Advisor Agent** → Create mitigation strategy

**Time**: 5-10 minutes  
**Output**: Risk report + mitigation roadmap

### Workflow 4: Vendor Consolidation
1. **Cost Optimizer Agent** → Consolidation savings analysis
2. **Risk Monitor Agent** → Supply chain risk assessment
3. **Strategic Advisor Agent** → Consolidation strategy & timeline

**Time**: 5-7 minutes  
**Output**: Consolidation plan with financial + risk assessment

---

## 📞 How to Use These Agents

### In VS Code Chat
```
/vendor-quick What's our top vendor by spend?
  → Routes to: Fast Analysis Agent

/vendor-analyze Why did we spike with Vendor X?
  → Routes to: Deep Analysis Agent

/vendor-strategy Should we renew this contract?
  → Routes to: Strategic Advisor Agent

/vendor-risk ESG compliance check
  → Routes to: Risk Monitor Agent

/vendor-finance Where can we save money?
  → Routes to: Cost Optimizer Agent
```

### As System Prompts
Load the agent markdown into your Claude system prompt:
```
You are the [Agent Name].
[Load entire agent.md file]
User query: [questions]
```

### In Python/API
```python
# Route to appropriate agent based on question
def route_vendor_question(question):
    if "quick" in question or "fast" in question:
        return "fast_analysis_agent"
    elif "why" in question or "analyze" in question:
        return "deep_analysis_agent"
    elif "strategy" in question or "should we" in question:
        return "strategic_advisor_agent"
    elif "risk" in question or "esg" in question or "compliance" in question:
        return "risk_monitor_agent"
    elif "cost" in question or "save" in question or "price" in question:
        return "cost_optimizer_agent"
    else:
        return "strategic_advisor_agent"  # default

agent_name = route_vendor_question(user_question)
response = load_agent_and_execute(agent_name, user_question)
```

---

## ⚙️ Technical Details

### Models Used
- **Claude 3.5 Haiku** → Fast Analysis (speed + cost priority)
- **Claude 3 Opus** → Deep Analysis & Risk Monitor (reasoning depth priority)
- **Claude 3.5 Sonnet** → Strategic Advisor & Cost Optimizer (balanced)

### Shared Foundation
All agents:
- ✅ Follow `.claude/skills/vendor-analysis-bigquery/SKILL.md` rules
- ✅ Can access the 10 allowed BigQuery tables
- ✅ Use 5 metric domains (Financial, Operational, Risk, Quality, Strategic)
- ✅ Reference query templates from `examples/`
- ✅ Use data dictionary for schema knowledge

### Constraints
- All agents honor the **Vendor Analysis Skill's rules** (table whitelist, metric constraints)
- No agent can exceed its scope (e.g., Fast Analysis won't do deep anomaly investigation)
- When question is out of scope, agent gracefully redirects to appropriate peer

---

## 💡 Best Practices

1. **Start with Fast Analysis** — Get baseline numbers quickly
2. **Escalate as needed** — If you need depth, move to Deep Analysis
3. **Use the right tool** — Match question complexity to agent choice
4. **Combine agents** — Use multi-agent workflows for complex decisions
5. **Know the costs** — Haiku is cheap, Opus is best for reasoning

---

## 📊 Performance Summary

| Agent | Strength | Best Case | Trade-off |
|-------|----------|-----------|-----------|
| **Fast** | Speed & cost | Dashboard, monitoring | Low depth |
| **Deep** | Reasoning & analysis | Anomaly investigation | Slower, higher cost |
| **Strategic** | Business judgment | Portfolio decisions | Less technical depth |
| **Risk** | Risk expertise | Compliance, mitigation | Limited on financials |
| **Cost** | Financial analysis | Savings opportunities | Less strategic context |

---

## 🆘 Troubleshooting

**Q: My question isn't being routed correctly**  
A: Check the routing decision tree. If still unsure, default to Strategic Advisor (best for ambiguous questions).

**Q: I'm not getting deep enough analysis**  
A: You picked Fast Analysis Agent. Move to Deep Analysis Agent for more depth.

**Q: Agent says "not in scope"**  
A: Question likely falls outside vendor analysis domain (e.g., employee HR). Reframe as vendor question or contact appropriate team.

---

## 📚 Agent Files

- [`fast-analysis-agent.md`](./fast-analysis-agent.md) — Claude Haiku, quick queries
- [`deep-analysis-agent.md`](./deep-analysis-agent.md) — Claude Opus, root cause analysis
- [`strategic-advisor-agent.md`](./strategic-advisor-agent.md) — Claude Sonnet, business strategy
- [`risk-monitor-agent.md`](./risk-monitor-agent.md) — Claude Opus, risk assessment
- [`cost-optimizer-agent.md`](./cost-optimizer-agent.md) — Claude Sonnet, cost reduction

---

Ready to choose your agent! 🚀
