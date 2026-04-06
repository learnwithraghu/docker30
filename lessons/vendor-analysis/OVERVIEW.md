# Vendor Analysis — Complete Guide

Welcome to the vendor analysis lesson! This guide explains **what vendor analysis is**, **why it matters**, and **how to use the vendor-analysis-bigquery skill**.

---

## 📚 What is Vendor Analysis?

**Vendor analysis** is the process of evaluating suppliers on multiple dimensions to:
- Understand how much we spend with each supplier
- Assess whether suppliers are delivering on time and with good quality
- Identify risks (concentration, ESG, compliance)
- Optimize relationships (negotiate better terms, identify strategic partners)

Think of it like a **report card for suppliers** — you grade them on Performance, Cost, Quality, Risk, and Strategic Value.

---

## 🎯 The 5 Metric Domains

We evaluate vendors across 5 domains:

### 1️⃣ Financial Health (Cost Management)
**"Are we getting good value for money?"**
- Spend Under Management: % of purchases covered by negotiated contracts
- Cost Avoidance: How much we saved through negotiation
- Payment Terms Optimization: Impact on cash flow

**Sample Question**: "Which vendors have maverick spend (purchases outside contracts)?"

---

### 2️⃣ Operational Efficiency (Delivery & Speed)
**"Are vendors delivering on time and accurately?"**
- On-Time Delivery Rate: % of orders arriving when promised
- Supplier Cycle Time: Average days from order to delivery
- Order Accuracy: % of correct deliveries (right quantity, right item)

**Sample Question**: "Which vendors are missing our 95% on-time-delivery target?"

---

### 3️⃣ Risk & Compliance (Mitigation)
**"Are we vulnerable to supply chain disruptions?"**
- ESG Compliance Score: Environmental, Social, Governance practices
- Geographic Concentration Risk: Over-dependence on one country/region
- Contract Compliance Rate: % of purchases following agreed terms

**Sample Question**: "How much of our spend is in China? What if that becomes unavailable?"

---

### 4️⃣ Quality & Performance (Defects)
**"Are our suppliers delivering quality products/services?"**
- Defect Rate: % of deliveries failing quality inspection
- Invoice Accuracy: % of billing being correct  
- Customer Satisfaction Score: Internal stakeholder ratings

**Sample Question**: "Which vendors have high defect rates affecting our manufacturing?"

---

### 5️⃣ Strategic Value (Growth Potential)
**"Are vendors strategic partners or just transactional?"**
- Innovation Contribution: Ideas/solutions submitted per year
- Partnership Tier Alignment: Actual performance vs importance to us

**Sample Question**: "Which vendors are truly strategic partners vs ones we should replace?"

---

## 🔄 The Vendor Analysis Workflow

Here's what happens when you ask a vendor question:

```
Step 1: You ask a question
   ↓
"Show me vendors with quality issues"
   ↓
Step 2: Analyst clarifies context (if needed)
   ↓
"Showing vendors with defect rates above 2%..."
   ↓
Step 3: Generate optimized SQL query
   ↓
"SELECT vendor_name, defect_rate FROM quality_audits..."
   ↓
Step 4: Execute via BigQuery MCP
   ↓
[BigQuery returns real data with results]
   ↓
Step 5: Interpret results in business terms
   ↓
"Vendor X has 4.2% defect rate (target: 2%). 
Root cause: quality control gaps. 
Recommendation: audit their process or replace them."
```

---

## 🚀 Using the Skill

### Quick Start (3 Ways)

**Option 1: Use the Shorthand (Fastest)**
```
/vendor-analysis Top 10 vendors by spend
/vendor-analysis Which vendors are missing on-time delivery?
/vendor-analysis Show vendors with low ESG scores
```

**Option 2: Ask Directly (Detailed)**
```
I need to understand our vendor concentration risk.
Show geographic distribution and top vendors.
```

**Option 3: Load the Skill Manually (if custom)**
Load `.claude/skills/vendor-analysis-bigquery/SKILL.md` in your system prompt.

---

## 📊 Example Scenarios

### Scenario 1: Cost Optimization
**Question**: "Which vendors have high maverick spend?"
**Metric Used**: Financial Health → Spend Under Management
**Result**: Identifies vendors where <70% of spend is covered by contracts
**Action**: Renegotiate contracts or consolidate purchases

### Scenario 2: Risk Management
**Question**: "Are we over-dependent on any single country?"
**Metric Used**: Risk & Compliance → Geographic Concentration Risk
**Result**: Shows spend by country; identifies if >40% from one location
**Action**: Diversify supplier base to reduce supply chain risk

### Scenario 3: Quality Control
**Question**: "Which vendor is causing our manufacturing defects?"
**Metric Used**: Quality & Performance → Defect Rate
**Result**: Shows defect rates by vendor compared to target <2%
**Action**: Audit supplier's QA process or find alternative

### Scenario 4: Strategic **Decision
**Question**: "Should we renew contracts with our top 5 vendors?"
**Metric Used**: All 5 domains (full scorecard)
**Result**: Performance against all metrics for decision making
**Action**: Fast-track renewals for strong performers, negotiate harder with weak ones

---

## 📁 Skill Files (Technical Details)

For the technical implementation and constraints, see:

- **[SKILL.md](./../.claude/skills/vendor-analysis-bigquery/SKILL.md)** — Complete skill definition with execution rules
- **[README.md](./../.claude/skills/vendor-analysis-bigquery/README.md)** — Overview, workflows, and usage examples  
- **[copilot-instructions.md](./../.claude/skills/vendor-analysis-bigquery/copilot-instructions.md)** — How to enable `/vendor-analysis` shorthand

### Ready-to-Use Resources

⭐ **Don't want to generate SQL? Use these:**

- **[Query Templates](./../../.claude/skills/vendor-analysis-bigquery/examples/README.md)** — 15 copy-paste SQL queries for each metric domain
- **[Data Dictionary](./../../.claude/skills/vendor-analysis-bigquery/data-dictionary.md)** — Complete schema reference for all 10 BigQuery tables

### Configuration Files

- **`config/metrics/financial_health.yaml`** — Spend metrics definitions
- **`config/metrics/operational_efficiency.yaml`** — Delivery metrics
- **`config/metrics/risk_compliance.yaml`** — Risk metrics
- **`config/metrics/quality_performance.yaml`** — Quality metrics
- **`config/metrics/strategic_value.yaml`** — Strategic metrics
- **`config/schema/allowed_tables.yaml`** — The 10 BigQuery tables we can access

### Reference Guides

- **`references/bigquery_optimization.md`** — SQL best practices
- **`references/vendor_kpis_framework.md`** — Detailed KPI definitions and interview questions

---

## ⚙️ Setup Requirements

### Prerequisites
1. ✅ BigQuery MCP server configured in VS Code
2. ✅ Valid GCP credentials for your project
3. ✅ Access to `procurement.*` BigQuery dataset
4. ✅ 10 vendor tables available (see config/schema/allowed_tables.yaml)

### Enable `/vendor-analysis` Shorthand
Copy `copilot-instructions.md` from the skill folder or use directly in VS Code Copilot settings.

---

## 💡 Pro Tips

1. **Be specific with time periods**: "This quarter" vs "All time"
2. **Ask for benchmarks**: "Compare against top quartile performers"
3. **Get context first**: "Show me the top 5 vendors, then deep-dive into Acme"
4. **Request comparisons**: "Vendor X vs Category average"
5. **Always ask for recommendations**: Metrics + interpretation = better decisions

---

## 🔗 Links & Resources

- **Skill Directory**: [.claude/skills/vendor-analysis-bigquery/](./../.claude/skills/vendor-analysis-bigquery/)
- **Main README**: [README.md](./../.claude/skills/vendor-analysis-bigquery/README.md)
- **Skill Definition**: [SKILL.md](./../.claude/skills/vendor-analysis-bigquery/SKILL.md)
- **Instructions**: [copilot-instructions.md](./../.claude/skills/vendor-analysis-bigquery/copilot-instructions.md)

---

## ❓ FAQ

**Q: What if I ask about data outside these 10 tables?**  
A: The skill will politely decline and suggest alternative questions within scope.

**Q: Can I customize the metrics?**  
A: Yes! Edit the YAML files in `config/metrics/` to define your own KPI thresholds.

**Q: How long does a query take?**  
A: Most queries <10 seconds. Large tables (spend_transactions) optimized with partition pruning.

**Q: What if BigQuery MCP disconnects?**  
A: The skill will show you the SQL query. You can run it manually or reconnect.

**Q: Can I compare multiple vendors in one query?**  
A: Yes! Use the benchmark queries (see SKILL.md examples).

---

## 🎓 Next Steps

1. **Try a quick question**: Use `/vendor-analysis` shorthand
2. **Explore a scenario**: Pick one of the 4 scenarios above
3. **Read the skill**: Understand the constraints and 10 allowed tables
4. **Customize metrics**: Adjust YAML files for your business needs
5. **Build on it**: Use results to inform procurement strategy

Good luck with your vendor analysis! 🚀
