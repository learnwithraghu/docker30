# Vendor KPIs Framework

## The Procurement Analytics Hierarchy

Vendor analysis is organized into **5 performance domains**, each with 2-3 measurable KPIs:

```
VENDOR PERFORMANCE
    ├── 💰 FINANCIAL HEALTH (Cost management)
    │   ├── Spend Under Management
    │   ├── Cost Avoidance
    │   └── Payment Terms Optimization
    │
    ├── ⚙️ OPERATIONAL EFFICIENCY (Delivery & speed)
    │   ├── On-Time Delivery Rate
    │   ├── Supplier Cycle Time
    │   └── Order Accuracy
    │
    ├── ⚠️ RISK & COMPLIANCE (Mitigation)
    │   ├── ESG Compliance Score
    │   ├── Geographic Concentration Risk
    │   └── Contract Compliance Rate
    │
    ├── 🔧 QUALITY & PERFORMANCE (Defects)
    │   ├── Defect Rate
    │   ├── Invoice Accuracy
    │   └── Customer Satisfaction Score
    │
    └── 🚀 STRATEGIC VALUE (Growth potential)
        ├── Innovation Contribution
        └── Partnership Tier Alignment
```

---

## Domain 1: Financial Health

### When to Use?
User asks about: spending, costs, savings, budget, price negotiations, contract value

### Key Metrics

| Metric | Formula | Target | Insight |
|--------|---------|--------|---------|
| **Spend Under Management** | (Contract $ / Total $) × 100 | >85% | % of spend negotiated vs maverick |
| **Cost Avoidance** | Σ(Market price - Negotiated) × volume | >5% of spend | Savings from negotiation |
| **Payment Terms** | AVG(Days to pay) × Daily spend | Optimized | Working capital impact |

### Sample Analysis Query

```sql
-- Financial health scorecard for single vendor
WITH spend_data AS (
  SELECT 
    vendor_id,
    SUM(amount) as total_spend,
    COUNTIF(contract_id IS NOT NULL) as contracted_transactions,
    COUNT(*) as total_transactions
  FROM procurement.spend_transactions
  WHERE event_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 12 MONTH)
  GROUP BY vendor_id
),
contract_data AS (
  SELECT 
    vendor_id,
    AVG(payment_term_days) as avg_payment_days
  FROM procurement.contracts
  GROUP BY vendor_id
)
SELECT 
  s.vendor_id,
  s.total_spend,
  SAFE_DIVIDE(s.contracted_transactions, s.total_transactions) * 100 as spend_under_mgmt_pct,
  c.avg_payment_days
FROM spend_data s
LEFT JOIN contract_data c USING (vendor_id)
```

---

## Domain 2: Operational Efficiency

### When to Use?
User asks about: delivery, timeliness, speed, cycle time, order accuracy

### Key Metrics

| Metric | Formula | Target | Insight |
|--------|---------|--------|---------|
| **On-Time Delivery** | (On-time POs / Total POs) × 100 | >95% | Reliability for operations |
| **Cycle Time** | AVG(Delivery date - PO date) | <days | Production planning impact |
| **Order Accuracy** | (Correct orders / Total orders) × 100 | >98% | Rework & quality issues |

### Sample Analysis Query

```sql
-- Operational performance dashboard
SELECT 
  p.vendor_id,
  COUNT(*) as total_pos,
  COUNTIF(d.actual_delivery <= p.promised_date) as on_time_pos,
  SAFE_DIVIDE(COUNTIF(d.actual_delivery <= p.promised_date), COUNT(*)) * 100 as otd_rate,
  AVG(DATE_DIFF(DAY, p.po_date, d.actual_delivery)) as avg_cycle_days
FROM procurement.purchase_orders p
JOIN procurement.delivery_receipts d ON p.po_id = d.po_id
WHERE p.po_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 12 MONTH)
GROUP BY p.vendor_id
ORDER BY otd_rate DESC
```

---

## Domain 3: Risk & Compliance

### When to Use?
User asks about: risk, compliance, ESG, regulatory, geography, contracts

### Key Metrics

| Metric | Formula | Target | Insight |
|--------|---------|--------|---------|
| **ESG Score** | (Env × 0.4) + (Soc × 0.3) + (Gov × 0.3) | >80/100 | Sustainability exposure |
| **Geographic Risk** | MAX(Country $) / Total $ | <40% any country | Supply chain concentration |
| **Contract Compliance** | (Compliant txns / Total txns) × 100 | >90% | Vendor adherence |

### Sample Analysis Query

```sql
-- Risk assessment scorecard
WITH esg_base AS (
  SELECT 
    vendor_id,
    COALESCE(environmental_score, 50) * 0.4 +
    COALESCE(social_score, 50) * 0.3 +
    COALESCE(governance_score, 50) * 0.3 as esg_score
  FROM procurement.sustainability_metrics
),
geo_risk AS (
  SELECT 
    t.vendor_id,
    v.country,
    SUM(t.amount) as country_spend,
    SUM(SUM(t.amount)) OVER (PARTITION BY t.vendor_id) as total_spend,
    SAFE_DIVIDE(SUM(t.amount), SUM(SUM(t.amount)) OVER (PARTITION BY t.vendor_id)) * 100 as pct_spend
  FROM procurement.spend_transactions t
  JOIN procurement.vendors v ON t.vendor_id = v.vendor_id
  WHERE t.event_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 12 MONTH)
  GROUP BY t.vendor_id, v.country
)
SELECT 
  e.vendor_id,
  ROUND(e.esg_score, 1) as esg_score,
  MAX(g.pct_spend) as max_country_concentration
FROM esg_base e
LEFT JOIN geo_risk g USING (vendor_id)
GROUP BY e.vendor_id
```

---

## Domain 4: Quality & Performance

### When to Use?
User asks about: quality, defects, errors, satisfaction, accuracy, rework

### Key Metrics

| Metric | Formula | Target | Insight |
|--------|---------|--------|---------|
| **Defect Rate** | (Defective units / Total units) × 100 | <2% | Manufacturing quality |
| **Invoice Accuracy** | (Correct invoices / Total invoices) × 100 | >98% | Admin burden |
| **Satisfaction** | AVG(Internal ratings) | >4.0/5 | Stakeholder confidence |

### Sample Analysis Query

```sql
-- Quality metrics summarized
SELECT 
  q.vendor_id,
  SUM(q.total_units) as total_units,
  SUM(q.defective_units) as defective_units,
  SAFE_DIVIDE(SUM(q.defective_units), SUM(q.total_units)) * 100 as defect_rate_pct,
  COALESCE(AVG(vi.satisfaction_rating), 0) as avg_satisfaction
FROM procurement.quality_audits q
LEFT JOIN procurement.vendor_interactions vi 
  ON q.vendor_id = vi.vendor_id 
  AND vi.interaction_type = 'satisfaction_survey'
GROUP BY q.vendor_id
ORDER BY defect_rate_pct ASC
```

---

## Domain 5: Strategic Value

### When to Use?
User asks about: innovation, partnership, strategic importance, collaboration, growth

### Key Metrics

| Metric | Formula | Target | Insight |
|--------|---------|--------|---------|
| **Innovation** | Innovation ideas submitted / year | >2/yr for strategic | Partnership vs vendor |
| **Tier Alignment** | Strategic vendors with score >80 | 100% | Strategic execution |

### Sample Analysis Query

```sql
-- Strategic partnership assessment
SELECT 
  v.vendor_id,
  v.vendor_name,
  v.strategic_tier,
  COUNTIF(vi.interaction_type = 'innovation') as innovation_count,
  SUM(CASE WHEN estimated_savings IS NOT NULL THEN estimated_savings ELSE 0 END) as total_innovation_savings
FROM procurement.vendors v
LEFT JOIN procurement.vendor_interactions vi ON v.vendor_id = vi.vendor_id
WHERE EXTRACT(YEAR FROM vi.interaction_date) = EXTRACT(YEAR FROM CURRENT_DATE())
  OR vi.interaction_type = 'innovation'
GROUP BY v.vendor_id, v.vendor_name, v.strategic_tier
```

---

## Choosing the Right Domain

### Interview Questions to Ask User:

1. **"What business problem are you trying to solve?"**
   - Cost reduction → Financial Health
   - Operational delays → Operational Efficiency
   - Supply chain risk → Risk & Compliance
   - Quality issues → Quality & Performance
   - Long-term partnership → Strategic Value

2. **"What time period?"** (default: 12 months)
   
3. **"Single vendor or category comparison?"**

### Example Dialog:

**User**: "Vendor XYZ's costs are increasing"

**Agent**: "I can help analyze this. Quick clarification:
- Are you concerned about **price increases** (Financial), or **quantity increasing** (Operational)?
- Do you want to compare **against other vendors** in their category?
- What time period? (I'll default to last 12 months if not specified)"

---

## Integration: Multi-Domain Analysis

Most business issues require **cross-domain analysis**:

### Example: "Why should we drop Vendor Q4?"

```sql
-- Integrated scorecard
SELECT 
  'Financial' as domain,
  v.vendor_id,
  CASE 
    WHEN SUM(t.amount) > category_avg * 1.5 THEN 'HIGH COST' 
    ELSE 'OK' 
  END as status
UNION ALL
SELECT 
  'Operational',
  p.vendor_id,
  CASE 
    WHEN AVG(DATE_DIFF(DAY, po_date, delivered_date)) > 30 THEN 'SLOW DELIVERY'
    ELSE 'OK'
  END
UNION ALL
SELECT 
  'Quality',
  q.vendor_id,
  CASE 
    WHEN SUM(defective_units) / SUM(total_units) > 0.05 THEN 'HIGH DEFECTS'
    ELSE 'OK'
  END
```

This gives a **holistic view** for a retention vs switch decision.
