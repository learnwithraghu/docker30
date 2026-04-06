-- METRIC: On-Time Delivery Rate
-- DOMAIN: Operational Efficiency
-- FILE: examples/operational-efficiency/on-time-delivery-rate.sql
--
-- What this shows:
-- Percentage of deliveries arriving on or before promised date
-- Higher % = better (more reliable supplier)
-- Target: > 95%
--
-- Use this when:
-- - Evaluating vendor reliability
-- - Identifying shipping/logistics issues
-- - Prioritizing vendors for critical orders

SELECT
  v.vendor_id,
  v.vendor_name,
  v.category,
  v.strategic_tier,
  COUNT(DISTINCT dr.receipt_id) as total_deliveries,
  SUM(
    CASE 
      WHEN dr.actual_delivery <= po.promised_date THEN 1 
      ELSE 0 
    END
  ) as on_time_deliveries,
  ROUND(
    SAFE_DIVIDE(
      SUM(
        CASE 
          WHEN dr.actual_delivery <= po.promised_date THEN 1 
          ELSE 0 
        END
      ),
      COUNT(DISTINCT dr.receipt_id)
    ) * 100,
    1
  ) as on_time_delivery_rate_pct,
  ROUND(
    AVG(
      CASE 
        WHEN dr.actual_delivery > po.promised_date 
          THEN DATE_DIFF(DAY, po.promised_date, dr.actual_delivery)
        ELSE 0 
      END
    ),
    1
  ) as avg_days_late,
  CASE 
    WHEN SAFE_DIVIDE(
      SUM(
        CASE 
          WHEN dr.actual_delivery <= po.promised_date THEN 1 
          ELSE 0 
        END
      ),
      COUNT(DISTINCT dr.receipt_id)
    ) >= 0.95 THEN '✅ On Target'
    ELSE '⚠️ Below Target'
  END as status
FROM procurement.delivery_receipts dr
JOIN procurement.purchase_orders po ON dr.po_id = po.po_id
JOIN procurement.vendors v ON po.vendor_id = v.vendor_id
WHERE dr.delivery_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 12 MONTH)
  AND v.status = 'active'
GROUP BY v.vendor_id, v.vendor_name, v.category, v.strategic_tier
ORDER BY on_time_delivery_rate_pct ASC
LIMIT 50;

-- CUSTOMIZATION TIPS:
-- 1. Get worst performers: ORDER BY ... ASC, LIMIT 10
-- 2. Get best performers: ORDER BY ... DESC, LIMIT 10
-- 3. Filter by category: Add "AND v.category = 'Raw Materials'"
-- 4. Get high-impact vendors: Add "HAVING total_deliveries > 50"
-- 5. Get recent analysis: Change "INTERVAL 12 MONTH" to "INTERVAL 3 MONTH"
