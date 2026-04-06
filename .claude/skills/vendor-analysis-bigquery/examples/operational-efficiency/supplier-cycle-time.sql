-- METRIC: Supplier Cycle Time
-- DOMAIN: Operational Efficiency
-- FILE: examples/operational-efficiency/supplier-cycle-time.sql
--
-- What this shows:
-- Average days from purchase order to delivery
-- Lower days = faster turnaround (preferred)
-- Target: < Industry average (varies by category)
--
-- Use this when:
-- - Evaluating supplier responsiveness
-- - Optimizing supply chain speed
-- - Identifying bottleneck suppliers

SELECT
  v.vendor_id,
  v.vendor_name,
  v.category,
  v.strategic_tier,
  COUNT(DISTINCT po.po_id) as total_orders,
  ROUND(
    AVG(DATE_DIFF(DAY, po.po_date, dr.actual_delivery)),
    1
  ) as avg_cycle_time_days,
  ROUND(
    PERCENTILE_CONT(DATE_DIFF(DAY, po.po_date, dr.actual_delivery), 0.5) 
      OVER (PARTITION BY v.vendor_id),
    0
  ) as median_cycle_time_days,
  MIN(DATE_DIFF(DAY, po.po_date, dr.actual_delivery)) as fastest_delivery_days,
  MAX(DATE_DIFF(DAY, po.po_date, dr.actual_delivery)) as slowest_delivery_days,
  ROUND(
    AVG(DATE_DIFF(DAY, po.po_date, dr.actual_delivery)) 
      OVER (PARTITION BY v.category),
    1
  ) as category_avg_cycle_days
FROM procurement.purchase_orders po
JOIN procurement.delivery_receipts dr ON po.po_id = dr.po_id
JOIN procurement.vendors v ON po.vendor_id = v.vendor_id
WHERE po.po_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 12 MONTH)
  AND v.status = 'active'
GROUP BY v.vendor_id, v.vendor_name, v.category, v.strategic_tier
ORDER BY avg_cycle_time_days ASC
LIMIT 50;

-- CUSTOMIZATION TIPS:
-- 1. Get slowest vendors: ORDER BY ... DESC, LIMIT 10
-- 2. Get fastest vendors: ORDER BY ... ASC, LIMIT 10
-- 3. Compare to category: See category_avg_cycle_days column
-- 4. Identify outliers: Add HAVING avg_cycle_time_days > 2 * category_avg_cycle_days
-- 5. Recent only: Change "INTERVAL 12 MONTH" to "INTERVAL 6 MONTH"
