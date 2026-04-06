# Data Dictionary

Complete schema documentation for the 10 BigQuery tables available in the vendor analysis skill. Use this to understand what data is available and how to query it.

---

## Quick Reference: Table Overview

| # | Table | Purpose | Size | Partition | Key Access Pattern |
|---|-------|---------|------|-----------|------------------|
| 1 | `procurement.vendors` | Master vendor registry | 2 GB | `updated_at` | Vendor lookups, master data |
| 2 | `procurement.spend_transactions` | Line-item spend records | 450 GB | `event_date` | **MUST have date filter** |
| 3 | `procurement.purchase_orders` | PO headers & status | 120 GB | `po_date` | Order tracking, promises |
| 4 | `procurement.contracts` | Contract terms & metadata | 8 GB | `created_at` | Terms lookup, compliance |
| 5 | `procurement.invoices` | Invoice processing data | 85 GB | `invoice_date` | Billing, payment terms |
| 6 | `procurement.delivery_receipts` | Goods receipt confirmation | 95 GB | `delivery_date` | On-time delivery metrics |
| 7 | `procurement.quality_audits` | Inspection & defect results | 45 GB | `audit_date` | Quality scoring |
| 8 | `procurement.risk_assessments` | Risk scores & factors | 12 GB | `assessment_date` | Risk metrics, ESG |
| 9 | `procurement.sustainability_metrics` | ESG data | 5 GB | `measurement_date` | Environmental, social, governance |
| 10 | `procurement.vendor_interactions` | Communication logs | 35 GB | `interaction_date` | Relationship tracking |

---

## 1. `procurement.vendors` — Master Vendor Registry

**Purpose**: Central repository of all vendors with classification and status.  
**Size**: 2 GB | **Partition**: `updated_at` | **Clustering**: `category`, `region`, `risk_tier`

### Columns

| Column | Type | Description | Example |
|--------|------|-------------|---------|
| `vendor_id` | INTEGER | Unique vendor identifier | 12345 |
| `vendor_name` | STRING | Official vendor name | "Acme Manufacturing Ltd" |
| `category` | STRING | Procurement category | "Raw Materials", "IT Services", "Janitorial" |
| `region` | STRING | Geographic region | "North America", "Europe", "APAC" |
| `country` | STRING | Country of primary operations | "USA", "Germany", "China" |
| `status` | STRING | Active/Inactive | "active", "inactive", "suspended" |
| `risk_tier` | STRING | Risk classification | "Tier-1", "Tier-2", "Tier-3" |
| `strategic_tier` | STRING | Strategic importance | "Strategic", "Preferred", "Transactional" |
| `primary_contact_email` | STRING | Main contact | "john.smith@acme.com" |
| `payment_terms_days` | INTEGER | Default payment days | 30, 45, 60 |
| `created_at` | TIMESTAMP | Record creation date | 2023-06-15 10:30:00 |
| `updated_at` | TIMESTAMP | Last update date | 2024-03-20 14:22:00 |

### Common Queries

```sql
-- Get all active vendors in a category
SELECT * FROM procurement.vendors 
WHERE status = 'active' 
  AND category = 'Raw Materials'
ORDER BY vendor_name;

-- Count vendors by region
SELECT region, COUNT(*) as vendor_count
FROM procurement.vendors
WHERE status = 'active'
GROUP BY region;

-- Get strategic tier-1 vendors
SELECT vendor_id, vendor_name, country
FROM procurement.vendors
WHERE strategic_tier = 'Tier-1'
ORDER BY vendor_name;
```

---

## 2. `procurement.spend_transactions` — Line-Item Spend Records

**Purpose**: Every purchase transaction, supporting spend analysis and metrics.  
**Size**: 450 GB ⚠️ **LARGEST TABLE** | **Partition**: `event_date` | **Clustering**: `vendor_id`, `category`, `cost_center`

### Columns

| Column | Type | Description | Example |
|--------|------|-------------|---------|
| `transaction_id` | STRING | Unique transaction ID | "TXN-2024-001234" |
| `vendor_id` | INTEGER | Vendor reference | 12345 |
| `event_date` | DATE | **PARTITION — Always filter this** | 2024-03-15 |
| `po_id` | STRING | Purchase order reference | "PO-2024-05678" |
| `contract_id` | STRING | Contract reference (null = maverick) | "C-2023-001", NULL |
| `amount` | NUMERIC | Spend amount in USD | 5000.50 |
| `quantity` | NUMERIC | Units purchased | 100 |
| `unit_price` | NUMERIC | Price per unit | 50.00 |
| `category` | STRING | Spend category | "Raw Materials" |
| `cost_center` | STRING | Charging cost center | "CC-1001" |
| `invoice_id` | STRING | Associated invoice | "INV-2024-9999" |
| `created_at` | TIMESTAMP | Record creation | 2024-03-15 09:15:00 |

### Critical Rules

⚠️ **ALWAYS include `event_date` filter** to avoid expensive full-table scan:
```sql
WHERE event_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 12 MONTH)
```

### Common Queries

```sql
-- Top 10 vendors by spend (WITH partition filter)
SELECT 
  vendor_id,
  SUM(amount) as total_spend
FROM procurement.spend_transactions
WHERE event_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 12 MONTH)
GROUP BY vendor_id
ORDER BY total_spend DESC
LIMIT 10;

-- Maverick spend (no contract)
SELECT 
  vendor_id,
  SUM(amount) as maverick_spend
FROM procurement.spend_transactions
WHERE event_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 12 MONTH)
  AND contract_id IS NULL
GROUP BY vendor_id
ORDER BY maverick_spend DESC;

-- Spend by category
SELECT 
  category,
  COUNT(*) as transactions,
  SUM(amount) as total
FROM procurement.spend_transactions
WHERE event_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 12 MONTH)
GROUP BY category;
```

---

## 3. `procurement.purchase_orders` — PO Headers & Status

**Purpose**: Purchase order master data, including promised delivery dates.  
**Size**: 120 GB | **Partition**: `po_date` | **Clustering**: `vendor_id`, `status`, `category`

### Columns

| Column | Type | Description | Example |
|--------|------|-------------|---------|
| `po_id` | STRING | Purchase order ID | "PO-2024-05678" |
| `vendor_id` | INTEGER | Vendor reference | 12345 |
| `po_date` | DATE | **PARTITION** PO creation date | 2024-03-10 |
| `promised_date` | DATE | Promised delivery date | 2024-03-20 |
| `po_amount` | NUMERIC | Total PO value | 5000.00 |
| `quantity_ordered` | NUMERIC | Units on order | 100 |
| `status` | STRING | PO status | "open", "closed", "cancelled" |
| `category` | STRING | Procurement category | "Raw Materials" |
| `cost_center` | STRING | Charging cost center | "CC-1001" |
| `buyer_id` | STRING | Buyer identifier | "BUYER-123" |
| `created_at` | TIMESTAMP | Record creation | 2024-03-10 08:00:00 |

### Common Queries

```sql
-- POs approaching promised date
SELECT 
  po_id,
  vendor_id,
  promised_date,
  DATE_DIFF(DAY, CURRENT_DATE(), promised_date) as days_until_due
FROM procurement.purchase_orders
WHERE po_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 12 MONTH)
  AND promised_date >= CURRENT_DATE()
  AND status = 'open'
ORDER BY promised_date;

-- Count of open POs by vendor
SELECT 
  vendor_id,
  COUNT(*) as open_pos
FROM procurement.purchase_orders
WHERE status = 'open'
  AND po_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 6 MONTH)
GROUP BY vendor_id
ORDER BY open_pos DESC;
```

---

## 4. `procurement.contracts` — Contract Terms & Metadata

**Purpose**: Contract agreements with terms, values, and validity dates.  
**Size**: 8 GB | **Partition**: `created_at` | **Clustering**: `vendor_id`, `category`, `status`

### Columns

| Column | Type | Description | Example |
|--------|------|-------------|---------|
| `contract_id` | STRING | Unique contract ID | "C-2023-001" |
| `vendor_id` | INTEGER | Vendor reference | 12345 |
| `category` | STRING | Spend category covered | "Raw Materials" |
| `start_date` | DATE | Contract effective date | 2023-01-01 |
| `end_date` | DATE | Contract expiry date | 2025-12-31 |
| `contract_value` | NUMERIC | Total contract value | 100000.00 |
| `payment_term_days` | INTEGER | Payment terms | 30, 45, 60 |
| `status` | STRING | Active/Expired/Under Review | "active", "expired" |
| `negotiated_rate` | NUMERIC | Negotiated unit price | 50.00 |
| `renewal_date` | DATE | Next renewal date | 2025-10-01 |
| `created_at` | TIMESTAMP | Record creation | 2023-01-01 09:00:00 |
| `updated_at` | TIMESTAMP | Last update | 2024-02-15 11:30:00 |

### Common Queries

```sql
-- Active contracts expiring soon
SELECT 
  contract_id,
  vendor_id,
  category,
  end_date,
  DATE_DIFF(DAY, CURRENT_DATE(), end_date) as days_until_expiry
FROM procurement.contracts
WHERE status = 'active'
  AND end_date >= CURRENT_DATE()
  AND end_date <= DATE_ADD(CURRENT_DATE(), INTERVAL 90 DAY)
ORDER BY end_date;

-- Contracts by category
SELECT 
  category,
  COUNT(*) as contract_count,
  SUM(contract_value) as total_value
FROM procurement.contracts
WHERE status = 'active'
GROUP BY category;
```

---

## 5. `procurement.invoices` — Invoice Processing Data

**Purpose**: Invoice transactions for payment, discrepancy, and accuracy tracking.  
**Size**: 85 GB | **Partition**: `invoice_date` | **Clustering**: `vendor_id`, `status`

### Columns

| Column | Type | Description | Example |
|--------|------|-------------|---------|
| `invoice_id` | STRING | Unique invoice ID | "INV-2024-9999" |
| `vendor_id` | INTEGER | Vendor reference | 12345 |
| `po_id` | STRING | Related PO | "PO-2024-05678" |
| `contract_id` | STRING | Related contract | "C-2023-001" |
| `invoice_date` | DATE | **PARTITION** Invoice date | 2024-03-15 |
| `amount` | NUMERIC | Invoice amount USD | 5000.00 |
| `quantity_invoiced` | NUMERIC | Units billed | 100 |
| `status` | STRING | Payment status | "pending", "paid", "disputed" |
| `payment_date` | DATE | Date payment made | 2024-04-15 |
| `created_at` | TIMESTAMP | Record creation | 2024-03-15 14:00:00 |

### Common Queries

```sql
-- Invoices pending payment
SELECT 
  invoice_id,
  vendor_id,
  amount,
  invoice_date,
  DATE_DIFF(DAY, invoice_date, CURRENT_DATE()) as days_pending
FROM procurement.invoices
WHERE invoice_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 12 MONTH)
  AND status = 'pending'
ORDER BY invoice_date;

-- Invoice accuracy (match PO amount)
SELECT 
  vendor_id,
  COUNT(*) as total_invoices,
  SUM(CASE WHEN amount != po.po_amount THEN 1 ELSE 0 END) as mismatched
FROM procurement.invoices inv
LEFT JOIN procurement.purchase_orders po ON inv.po_id = po.po_id
WHERE inv.invoice_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 12 MONTH)
GROUP BY vendor_id;
```

---

## 6. `procurement.delivery_receipts` — Goods Receipt Confirmation

**Purpose**: Delivery confirmations showing actual delivery date and quantities.  
**Size**: 95 GB | **Partition**: `delivery_date` | **Clustering**: `vendor_id`, `status`

### Columns

| Column | Type | Description | Example |
|--------|------|-------------|---------|
| `receipt_id` | STRING | Unique receipt ID | "REC-2024-7777" |
| `po_id` | STRING | Related PO | "PO-2024-05678" |
| `vendor_id` | INTEGER | Vendor reference | 12345 |
| `delivery_date` | DATE | **PARTITION** Actual delivery date | 2024-03-18 |
| `promised_date` | DATE | Original promised date | 2024-03-20 |
| `quantity_received` | NUMERIC | Units actually received | 100 |
| `quantity_ordered` | NUMERIC | Units ordered | 100 |
| `inspection_status` | STRING | QA result | "passed", "failed", "pending" |
| `notes` | STRING | Delivery notes | "Delivered to dock 3" |
| `created_at` | TIMESTAMP | Record creation | 2024-03-18 16:45:00 |

### Common Queries

```sql
-- On-time delivery metric
SELECT 
  vendor_id,
  COUNT(*) as total_deliveries,
  SUM(CASE WHEN delivery_date <= promised_date THEN 1 ELSE 0 END) as on_time,
  ROUND(100.0 * SUM(CASE WHEN delivery_date <= promised_date THEN 1 ELSE 0 END) / COUNT(*), 1) as on_time_pct
FROM procurement.delivery_receipts
WHERE delivery_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 12 MONTH)
GROUP BY vendor_id;

-- Delivery accuracy (match quantities)
SELECT 
  vendor_id,
  SUM(CASE WHEN quantity_received = quantity_ordered THEN 1 ELSE 0 END) as accurate,
  SUM(CASE WHEN quantity_received < quantity_ordered THEN 1 ELSE 0 END) as short_shipments
FROM procurement.delivery_receipts
WHERE delivery_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 12 MONTH)
GROUP BY vendor_id;
```

---

## 7. `procurement.quality_audits` — Inspection & Defect Results

**Purpose**: Quality audit records with defect tracking.  
**Size**: 45 GB | **Partition**: `audit_date` | **Clustering**: `vendor_id`, `category`

### Columns

| Column | Type | Description | Example |
|--------|------|-------------|---------|
| `audit_id` | STRING | Unique audit ID | "AUD-2024-6666" |
| `po_id` | STRING | Related PO | "PO-2024-05678" |
| `vendor_id` | INTEGER | Vendor reference | 12345 |
| `audit_date` | DATE | **PARTITION** Audit date | 2024-03-20 |
| `total_units` | NUMERIC | Units sampled/inspected | 100 |
| `defective_units` | NUMERIC | Defects found | 2 |
| `defect_rate_pct` | NUMERIC | Percentage defect | 2.0 |
| `audit_result` | STRING | Pass/Fail/Review | "passed", "failed" |
| `defect_category` | STRING | Type of defect | "dimensional", "functional", "cosmetic" |
| `auditor_id` | STRING | QA person | "QA-456" |
| `notes` | STRING | Audit notes | "Minor scratches found" |

### Common Queries

```sql
-- Defect rates by vendor
SELECT 
  vendor_id,
  SUM(total_units) as units_audited,
  SUM(defective_units) as total_defects,
  ROUND(100.0 * SUM(defective_units) / SUM(total_units), 2) as defect_rate_pct
FROM procurement.quality_audits
WHERE audit_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 12 MONTH)
GROUP BY vendor_id
ORDER BY defect_rate_pct DESC;

-- Failed audits
SELECT 
  vendor_id,
  COUNT(*) as failed_audits,
  SUM(defective_units) as defects
FROM procurement.quality_audits
WHERE audit_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 12 MONTH)
  AND audit_result = 'failed'
GROUP BY vendor_id;
```

---

## 8. `procurement.risk_assessments` — Risk Scores & Factors

**Purpose**: Risk evaluations including satisfaction, financial health, and performance.  
**Size**: 12 GB | **Partition**: `assessment_date` | **Clustering**: `vendor_id`, `risk_type`

### Columns

| Column | Type | Description | Example |
|--------|------|-------------|---------|
| `assessment_id` | STRING | Unique assessment ID | "RA-2024-5555" |
| `vendor_id` | INTEGER | Vendor reference | 12345 |
| `assessment_date` | DATE | **PARTITION** Assessment date | 2024-03-01 |
| `risk_type` | STRING | Type of risk | "financial", "operational", "compliance" |
| `overall_risk_score` | NUMERIC | 1-10 scale (higher = riskier) | 3.5 |
| `financial_score` | NUMERIC | Financial stability | 7.0 |
| `operational_score` | NUMERIC | Operational capability | 6.5 |
| `satisfaction_score` | NUMERIC | Internal satisfaction (1-5) | 4.2 |
| `responsiveness_score` | NUMERIC | Responsiveness rating | 4.0 |
| `communication_score` | NUMERIC | Communication quality | 3.8 |
| `overall_performance_score` | NUMERIC | Composite performance | 4.0 |
| `risk_level` | STRING | Risk classification | "low", "medium", "high" |
| `innovation_category` | STRING | Type of innovation | "product", "process", NULL |

### Common Queries

```sql
-- High-risk vendors
SELECT 
  vendor_id,
  overall_risk_score,
  risk_level
FROM procurement.risk_assessments
WHERE assessment_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 6 MONTH)
  AND overall_risk_score > 7
ORDER BY overall_risk_score DESC;

-- Satisfaction trends
SELECT 
  vendor_id,
  EXTRACT(YEAR FROM assessment_date) as year,
  EXPORT(MONTH FROM assessment_date) as month,
  AVG(satisfaction_score) as avg_satisfaction
FROM procurement.risk_assessments
WHERE assessment_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 24 MONTH)
GROUP BY vendor_id, year, month
ORDER BY vendor_id, year, month;
```

---

## 9. `procurement.sustainability_metrics` — ESG Data

**Purpose**: Environmental, Social, Governance compliance tracking.  
**Size**: 5 GB | **Partition**: `measurement_date` | **Clustering**: None

### Columns

| Column | Type | Description | Example |
|--------|------|-------------|---------|
| `assessment_id` | STRING | Unique assessment ID | "ESG-2024-4444" |
| `vendor_id` | INTEGER | Vendor reference | 12345 |
| `measurement_date` | DATE | **PARTITION** Measurement date | 2024-03-01 |
| `environmental_score` | NUMERIC | 0-100 scale | 75.5 |
| `social_score` | NUMERIC | 0-100 scale | 82.0 |
| `governance_score` | NUMERIC | 0-100 scale | 88.5 |
| `overall_esg_score` | NUMERIC | Average of the three | 82.0 |
| `carbon_emissions_tons` | NUMERIC | Annual CO2 | 500.0 |
| `labor_practices_status` | STRING | Compliance status | "compliant", "non-compliant" |
| `board_diversity_pct` | NUMERIC | % diverse board | 35.0 |
| `certification_list` | STRING | Certifications held | "ISO-14001, B-Corp" |

### Common Queries

```sql
-- ESG scores by vendor
SELECT 
  vendor_id,
  overall_esg_score,
  environmental_score,
  social_score,
  governance_score
FROM procurement.sustainability_metrics
WHERE measurement_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 12 MONTH)
  AND overall_esg_score < 70
ORDER BY overall_esg_score;
```

---

## 10. `procurement.vendor_interactions` — Communication Logs

**Purpose**: Relationship tracking and communication history.  
**Size**: 35 GB | **Partition**: `interaction_date` | **Clustering**: `vendor_id`, `interaction_type`

### Columns

| Column | Type | Description | Example |
|--------|------|-------------|---------|
| `interaction_id` | STRING | Unique interaction ID | "INT-2024-3333" |
| `vendor_id` | INTEGER | Vendor reference | 12345 |
| `interaction_date` | DATE | **PARTITION** Date of interaction | 2024-03-15 |
| `interaction_type` | STRING | Type of contact | "meeting", "call", "email", "issue" |
| `subject` | STRING | Interaction topic | "Delivery delay discussion", "Price negotiation" |
| `participant_id` | STRING | Internal participant | "EMP-789" |
| `outcome` | STRING | Result of interaction | "resolved", "pending", "escalated" |
| `priority` | STRING | Priority level | "low", "medium", "high" |
| `notes` | STRING | Details | "Discussed Q2 pricing..." |
| `created_at` | TIMESTAMP | Record creation | 2024-03-15 10:00:00 |

### Common Queries

```sql
-- Recent issues with vendors
SELECT 
  vendor_id,
  COUNT(*) as issue_count
FROM procurement.vendor_interactions
WHERE interaction_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 3 MONTH)
  AND interaction_type = 'issue'
  AND outcome IN ('pending', 'escalated')
GROUP BY vendor_id
ORDER BY issue_count DESC;
```

---

## 🔗 Joining Tables — Common Patterns

### Pattern 1: Vendor + Spend
```sql
SELECT 
  v.vendor_name,
  SUM(t.amount) as total_spend
FROM procurement.spend_transactions t
JOIN procurement.vendors v ON t.vendor_id = v.vendor_id
WHERE t.event_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 12 MONTH)
GROUP BY v.vendor_id, v.vendor_name;
```

### Pattern 2: Vendor + Contracts + Spend
```sql
SELECT 
  v.vendor_name,
  c.contract_id,
  SUM(CASE WHEN t.contract_id = c.contract_id THEN t.amount ELSE 0 END) as contract_spend,
  SUM(t.amount) as total_spend
FROM procurement.vendors v
JOIN procurement.contracts c ON v.vendor_id = c.vendor_id
LEFT JOIN procurement.spend_transactions t ON v.vendor_id = t.vendor_id
WHERE t.event_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 12 MONTH)
GROUP BY v.vendor_id, v.vendor_name, c.contract_id;
```

### Pattern 3: On-Time Delivery
```sql
SELECT 
  po.vendor_id,
  COUNT(*) as total_pos,
  SUM(CASE WHEN dr.delivery_date <= po.promised_date THEN 1 ELSE 0 END) as on_time
FROM procurement.purchase_orders po
LEFT JOIN procurement.delivery_receipts dr ON po.po_id = dr.po_id
WHERE po.po_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 12 MONTH)
GROUP BY po.vendor_id;
```

---

## 📊 Performance Tips

1. **Always partition filter**: Use `event_date`, `po_date`, `invoice_date`, or `delivery_date` in WHERE clause
2. **Limit before joining**: Filter large tables (spend_transactions, invoices) first
3. **Use clustering columns**: Include `vendor_id`, `category` in GROUP BY when possible
4. **APPROX_COUNT_DISTINCT**: For unique vendor counts (faster than COUNT DISTINCT)
5. **LIMIT for exploration**: Use LIMIT 100 when testing queries, remove for final analysis

---

## 🆘 Troubleshooting

**"Cannot read partition column"** → Ensure you're filtering on the correct partition column for the table  
**"Permission denied"** → Check that your GCP user has BigQuery dataset access  
**"Table not found"** → Verify you're using backticks for project.dataset.table if needed  
**"Query too slow"** → Check if you forgot the partition filter on spend_transactions
