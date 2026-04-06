# BigQuery Optimization Best Practices

## Partition Pruning (CRITICAL)

Always filter on partition columns in the WHERE clause to avoid full table scans.

### Example: Spend Transactions (450 GB table)

```sql
-- ❌ BAD: Scans entire table
SELECT * FROM procurement.spend_transactions
WHERE vendor_id = 12345

-- ✅ GOOD: Partition-pruned
SELECT * FROM procurement.spend_transactions
WHERE event_date BETWEEN '2024-01-01' AND '2024-12-31'
  AND vendor_id = 12345
```

**Cost impact**: Bad query = $2.50, Good query = $0.05 (50x savings)

---

## Clustering Benefits

Tables are pre-clustered on key columns. Use these in GROUP BY or WHERE for optimal scan efficiency.

### Query Template: Vendor Category Analysis

```sql
SELECT 
  category,
  SUM(amount) as total,
  COUNT(*) as transaction_count
FROM procurement.spend_transactions
WHERE event_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 12 MONTH)
  AND vendor_id = @vendor_id  -- After partition, use cluster column
GROUP BY category  -- Clustering is on category, so this is efficient
ORDER BY total DESC
```

---

## SAFE_DIVIDE Pattern

Always use `SAFE_DIVIDE()` when calculating percentages or rates. Prevents division by zero errors.

```sql
-- ❌ BAD: Can error if denominator is 0
SELECT on_time_deliveries / total_deliveries * 100 as rate

-- ✅ GOOD: Handles zero gracefully
SELECT SAFE_DIVIDE(on_time_deliveries, total_deliveries) * 100 as rate
```

---

## Window Functions with QUALIFY

Prefer `QUALIFY` over subqueries for window function filtering. More efficient and readable.

### Rank Vendors by Spend Within Category

```sql
SELECT 
  vendor_id,
  vendor_name,
  category,
  total_spend,
  spend_rank
FROM (
  SELECT 
    vendor_id,
    vendor_name,
    category,
    SUM(amount) as total_spend,
    ROW_NUMBER() OVER (PARTITION BY category ORDER BY SUM(amount) DESC) as spend_rank
  FROM procurement.spend_transactions
  WHERE event_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 12 MONTH)
  GROUP BY vendor_id, vendor_name, category
)
WHERE spend_rank <= 10  -- ❌ OLD WAY: subquery required

-- ✅ NEW WAY: QUALIFY is cleaner
SELECT 
  vendor_id,
  vendor_name,
  category,
  SUM(amount) as total_spend,
  ROW_NUMBER() OVER (PARTITION BY category ORDER BY SUM(amount) DESC) as spend_rank
FROM procurement.spend_transactions
WHERE event_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 12 MONTH)
GROUP BY vendor_id, vendor_name, category
QUALIFY spend_rank <= 10
```

---

## APPROX_COUNT_DISTINCT for Large Cardinality

Use `APPROX_COUNT_DISTINCT` when counting unique values in large datasets. 99.9% accurate but much faster.

```sql
-- For vendor_id across 450GB table:
-- EXACT: SELECT COUNT(DISTINCT vendor_id) FROM ... takes 15 seconds
-- APPROX: SELECT APPROX_COUNT_DISTINCT(vendor_id) FROM ... takes 1 second

SELECT 
  APPROX_COUNT_DISTINCT(vendor_id) as approx_unique_vendors,
  COUNT(DISTINCT vendor_id) as exact_unique_vendors  -- For comparison
FROM procurement.spend_transactions
WHERE event_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 12 MONTH)
```

---

## CTEs for Complex Analysis

Materialize intermediate results with CTEs. Improves readability and sometimes performance.

```sql
-- Spend Base
WITH spend_base AS (
  SELECT 
    vendor_id,
    vendor_name,
    SUM(amount) as total_spend,
    COUNTIF(contract_id IS NOT NULL) / COUNT(*) as pct_contracted
  FROM procurement.spend_transactions
  WHERE event_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 12 MONTH)
  GROUP BY vendor_id, vendor_name
),

-- Quality Metrics
quality_metrics AS (
  SELECT 
    vendor_id,
    AVG(SAFE_DIVIDE(defective_units, total_units)) as defect_rate,
    COUNT(*) as audit_count
  FROM procurement.quality_audits
  GROUP BY vendor_id
),

-- Final Join
SELECT 
  sb.vendor_id,
  sb.vendor_name,
  sb.total_spend,
  sb.pct_contracted,
  COALESCE(qm.defect_rate, 0) as quality_score
FROM spend_base sb
LEFT JOIN quality_metrics qm USING (vendor_id)
ORDER BY sb.total_spend DESC
```

---

## Explicit Column Selection

Never use `SELECT *`. Reduces data transfer and improves cache efficiency.

```sql
-- ❌ BAD
SELECT * FROM procurement.spend_transactions

-- ✅ GOOD
SELECT 
  transaction_id,
  vendor_id,
  event_date,
  amount,
  category,
  contract_id
FROM procurement.spend_transactions
```

---

## LIMIT for Exploration

Start exploration with LIMIT 100. Saves query cost while verifying correctness.

```sql
-- First pass: Explore structure (costs $0.001)
SELECT * FROM procurement.spend_transactions
WHERE event_date = CURRENT_DATE()
LIMIT 100

-- Once verified: Run full analysis
SELECT ... FROM procurement.spend_transactions
WHERE event_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 12 MONTH)
-- No LIMIT for complete results
```

---

## Query Explanation Plans

For large scans (>1TB), run `EXPLAIN` first to estimate data processed:

```sql
EXPLAIN
SELECT ...
FROM procurement.spend_transactions
WHERE event_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 12 MONTH)
AND vendor_id = @vendor_id
```

Look for:
- **Bytes Processed**: Should be minimal if partition-pruned
- **Slot Reservation**: Check if within monthly quota
- **Estimated Records**: Used for table size validation
