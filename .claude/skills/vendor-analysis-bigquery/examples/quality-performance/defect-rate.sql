-- METRIC: Defect Rate
-- DOMAIN: Quality & Performance
-- FILE: examples/quality-performance/defect-rate.sql
--
-- What this shows:
-- Percentage of deliveries with quality defects detected
-- Lower % = better (fewer defective units)
-- Target: < 2%
--
-- Use this when:
-- - Identifying quality issues
-- - Managing vendor quality scores
-- - Planning quality improvement initiatives

SELECT
  v.vendor_id,
  v.vendor_name,
  v.category,
  v.strategic_tier,
  SUM(qa.total_units) as total_units_inspected,
  SUM(qa.defective_units) as total_defective_units,
  ROUND(
    SAFE_DIVIDE(
      SUM(qa.defective_units),
      SUM(qa.total_units)
    ) * 100,
    2
  ) as defect_rate_pct,
  COUNT(DISTINCT qa.audit_id) as total_audits,
  COUNT(DISTINCT qa.po_id) as affected_purchase_orders,
  CASE 
    WHEN SAFE_DIVIDE(
      SUM(qa.defective_units),
      SUM(qa.total_units)
    ) < 0.02 THEN '✅ On Target'
    WHEN SAFE_DIVIDE(
      SUM(qa.defective_units),
      SUM(qa.total_units)
    ) < 0.05 THEN '⚠️ Monitor'
    ELSE '🔴 High Risk'
  END as quality_status,
  MAX(qa.audit_date) as latest_audit_date
FROM procurement.quality_audits qa
JOIN procurement.vendors v ON qa.vendor_id = v.vendor_id
WHERE qa.audit_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 12 MONTH)
  AND v.status = 'active'
GROUP BY v.vendor_id, v.vendor_name, v.category, v.strategic_tier
ORDER BY defect_rate_pct DESC
LIMIT 50;

-- CUSTOMIZATION TIPS:
-- 1. Get worst performers: ORDER BY defect_rate_pct DESC, LIMIT 10
-- 2. Get best performers: ORDER BY defect_rate_pct ASC, LIMIT 10
-- 3. Get high-risk only: FILTER for quality_status = 'High Risk'
-- 4. By category: GROUP BY category for category-level analysis
-- 5. Recent trend: Compare last quarter vs last 12 months
