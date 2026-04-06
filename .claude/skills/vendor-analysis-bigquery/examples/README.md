# Query Templates & Examples

This folder contains **ready-to-use SQL templates** for every metric domain. Copy, paste, and customize for your analysis.

---

## 📋 Quick Navigation

### Financial Health (Cost Management)
- [Spend Under Management](#spend-under-management) — % of spend covered by contracts
- [Cost Avoidance](#cost-avoidance) — Savings from negotiation
- [Payment Terms Optimization](#payment-terms-optimization) — Working capital impact

**File**: [`financial-health/`](./financial-health/)

### Operational Efficiency (Delivery & Speed)
- [On-Time Delivery Rate](#on-time-delivery-rate) — % of orders arriving on time
- [Supplier Cycle Time](#supplier-cycle-time) — Days from order to delivery
- [Order Accuracy](#order-accuracy) — % of correct deliveries

**File**: [`operational-efficiency/`](./operational-efficiency/)

### Risk & Compliance (Mitigation)
- [ESG Compliance Score](#esg-compliance-score) — Environmental, Social, Governance
- [Geographic Concentration Risk](#geographic-concentration-risk) — Over-dependence by country
- [Contract Compliance Rate](#contract-compliance-rate) — % of compliant transactions

**File**: [`risk-compliance/`](./risk-compliance/)

### Quality & Performance (Defects)
- [Defect Rate](#defect-rate) — % of deliveries failing QA
- [Invoice Accuracy](#invoice-accuracy) — % of correct billing
- [Customer Satisfaction Score](#customer-satisfaction-score) — Stakeholder ratings

**File**: [`quality-performance/`](./quality-performance/)

### Strategic Value (Growth Potential)
- [Innovation Contribution](#innovation-contribution) — Ideas/solutions per year
- [Partnership Tier Alignment](#partnership-tier-alignment) — Performance vs importance

**File**: [`strategic-value/`](./strategic-value/)

---

## 📊 How to Use These Templates

### Option 1: Copy the Full Query
```sql
-- Copy the entire SQL from the template
SELECT 
  vendor_id,
  vendor_name,
  SUM(amount) as total_spend
FROM procurement.spend_transactions
WHERE event_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 12 MONTH)
GROUP BY vendor_id, vendor_name
ORDER BY total_spend DESC
```

### Option 2: Customize Parameters
Each template has **placeholders** you can customize:
- `@start_date` — Beginning of analysis period
- `@end_date` — End of analysis period
- `@vendor_id` — Specific vendor (optional)
- `@category` — Vendor category (optional)
- `@limit` — Number of results (optional)

### Option 3: Combine Multiple Templates
Chain templates together for deeper analysis:
1. Run "Spend Under Management" query
2. Identify low-scoring vendors
3. Run "On-Time Delivery" for those vendors
4. Compare financial vs operational performance

---

## 🚀 Common Workflows

### Workflow 1: Vendor Scorecard (All 5 Domains)
**Goal**: Evaluate a vendor completely

```
1. Run: spend-under-management.sql
2. Run: on-time-delivery-rate.sql
3. Run: esg-compliance-score.sql
4. Run: defect-rate.sql
5. Run: innovation-contribution.sql
→ Combine results into scorecard
```

**Time**: 5-10 minutes per vendor

### Workflow 2: Cost Optimization
**Goal**: Find savings opportunities

```
1. Run: spend-under-management.sql
2. Identify vendors <85% (target)
3. Run: cost-avoidance.sql for those vendors
4. Negotiate contracts to increase coverage
→ Track savings monthly
```

**Time**: 10-15 minutes for analysis

### Workflow 3: Risk Management
**Goal**: Identify supply chain vulnerabilities

```
1. Run: geographic-concentration-risk.sql
2. Run: contract-compliance-rate.sql
3. Run: esg-compliance-score.sql
4. Prioritize mitigation by risk score
→ Diversify suppliers or increase inventory
```

**Time**: 15-20 minutes for analysis

### Workflow 4: Quality Issues Investigation
**Goal**: Diagnose quality problems

```
1. Run: defect-rate.sql
2. Identify vendors >2% (target)
3. Run: invoice-accuracy.sql
4. Run: customer-satisfaction-score.sql
5. Cross-reference with on-time-delivery-rate.sql
→ Audit supplier's processes
```

**Time**: 10-15 minutes for analysis

---

## 🔧 Customization Guide

### Adding a Vendor Filter
Add `AND vendor_id = @vendor_id` to WHERE clause:
```sql
WHERE event_date >= @start_date
  AND event_date <= @end_date
  AND vendor_id = @vendor_id  -- NEW
```

### Adding a Category Filter
Add `AND category = @category` to WHERE clause:
```sql
WHERE event_date >= @start_date
  AND event_date <= @end_date
  AND category = @category  -- NEW
```

### Limiting Results
Add `LIMIT @limit` to end of query:
```sql
ORDER BY total_spend DESC
LIMIT 10  -- Show top 10 vendors
```

### Benchmarking (Compare to Peers)
Add window function to compare against category average:
```sql
AVG(metric_value) OVER (PARTITION BY category) as category_avg,
metric_value - AVG(metric_value) OVER (PARTITION BY category) as variance_from_avg
```

---

## 📁 File Structure

```
examples/
├── README.md (you are here)
├── financial-health/
│   ├── spend-under-management.sql
│   ├── cost-avoidance.sql
│   └── payment-terms-optimization.sql
├── operational-efficiency/
│   ├── on-time-delivery-rate.sql
│   ├── supplier-cycle-time.sql
│   └── order-accuracy.sql
├── risk-compliance/
│   ├── esg-compliance-score.sql
│   ├── geographic-concentration-risk.sql
│   └── contract-compliance-rate.sql
├── quality-performance/
│   ├── defect-rate.sql
│   ├── invoice-accuracy.sql
│   └── customer-satisfaction-score.sql
└── strategic-value/
    ├── innovation-contribution.sql
    └── partnership-tier-alignment.sql
```

---

## 💡 Tips

1. **Start with partition filters**: Always include `event_date`, `po_date`, or `invoice_date` to optimize cost
2. **Use SAFE_DIVIDE**: Prevents errors from zero denominators
3. **Limit before sharing**: Use `LIMIT 100` for exploration, no limit for final analysis
4. **Explain results**: Always translate numbers to business insights

For full SQL best practices, see [`references/bigquery_optimization.md`](../references/bigquery_optimization.md).

---

## ❓ Questions?

- **"How do I run these?"** — Copy the SQL, paste into BigQuery, change parameters
- **"Can I modify these?"** — Yes! They're templates, designed to be customized
- **"What if I get an error?"** — Check `../references/bigquery_optimization.md` for common issues
- **"How do I combine multiple metrics?"** — Use CTEs (WITH clauses) to chain queries together
