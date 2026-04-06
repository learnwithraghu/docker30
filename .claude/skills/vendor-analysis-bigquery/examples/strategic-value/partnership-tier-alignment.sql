-- METRIC: Partnership Tier Alignment
-- DOMAIN: Strategic Value
-- FILE: examples/strategic-value/partnership-tier-alignment.sql
--
-- What this shows:
-- Alignment between vendor actual performance and strategic importance
-- Goal: Strategic vendors perform strong, transactional vendors baseline acceptable
-- Identifies misalignment: high spenders underperforming or low spenders over-invested
--
-- Use this when:
-- - Evaluating vendor portfolio balance
-- - Identifying underperforming strategic vendors
-- - Resource allocation optimization

SELECT
  v.vendor_id,
  v.vendor_name,
  v.category,
  v.strategic_tier,
  ROUND(SUM(t.amount), 2) as total_spend_usd,
  ROUND(
    SAFE_DIVIDE(
      SUM(t.amount),
      SUM(SUM(t.amount)) OVER (PARTITION BY v.category)
    ) * 100,
    1
  ) as pct_of_category_spend,
  -- Financial metric
  ROUND(
    SAFE_DIVIDE(
      SUM(CASE WHEN t.contract_id IS NOT NULL THEN t.amount ELSE 0 END),
      SUM(t.amount)
    ) * 100,
    1
  ) as spend_under_management_pct,
  -- Operational metric
  ROUND(
    SAFE_DIVIDE(
      SUM(CASE WHEN dr.actual_delivery <= po.promised_date THEN 1 ELSE 0 END),
      COUNT(DISTINCT dr.receipt_id)
    ) * 100,
    1
  ) as on_time_delivery_pct,
  -- Quality metric
  ROUND(
    SAFE_DIVIDE(
      SUM(CASE WHEN qa.defective_units = 0 THEN 1 ELSE 0 END),
      COUNT(DISTINCT qa.audit_id)
    ) * 100,
    1
  ) as zero_defect_audits_pct,
  CASE 
    WHEN v.strategic_tier = 'Tier-1' AND 
          ROUND(SAFE_DIVIDE(SUM(CASE WHEN t.contract_id IS NOT NULL THEN t.amount ELSE 0 END), SUM(t.amount)) * 100) >= 85 AND
          ROUND(SAFE_DIVIDE(SUM(CASE WHEN dr.actual_delivery <= po.promised_date THEN 1 ELSE 0 END), COUNT(DISTINCT dr.receipt_id)) * 100) >= 95
      THEN '✅ Aligned'
    WHEN v.strategic_tier = 'Tier-1' 
      THEN '⚠️ Under-Performing (needs attention)'
    WHEN v.strategic_tier = 'Transactional' AND 
          ROUND(SAFE_DIVIDE(SUM(CASE WHEN t.contract_id IS NOT NULL THEN t.amount ELSE 0 END), SUM(t.amount)) * 100) >= 75 AND
          ROUND(SAFE_DIVIDE(SUM(CASE WHEN dr.actual_delivery <= po.promised_date THEN 1 ELSE 0 END), COUNT(DISTINCT dr.receipt_id)) * 100) >= 90
      THEN '✅ Aligned'
    ELSE '⚠️ Misaligned (review tier)'
  END as alignment_status
FROM procurement.spend_transactions t
JOIN procurement.vendors v ON t.vendor_id = v.vendor_id
LEFT JOIN procurement.purchase_orders po ON t.vendor_id = po.vendor_id
LEFT JOIN procurement.delivery_receipts dr ON po.po_id = dr.po_id
LEFT JOIN procurement.quality_audits qa ON po.po_id = qa.po_id
WHERE t.event_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 12 MONTH)
  AND v.status = 'active'
GROUP BY v.vendor_id, v.vendor_name, v.category, v.strategic_tier
ORDER BY v.strategic_tier DESC, alignment_status
LIMIT 50;

-- CUSTOMIZATION TIPS:
-- 1. Get misaligned vendors: FILTER for alignment_status != 'Aligned'
-- 2. Get Tier-1 issues: FILTER for v.strategic_tier = 'Tier-1' AND alignment_status != 'Aligned'
-- 3. Get over-invested low performers: FILTER for high spend + low performance
-- 4. By category: GROUP BY category for category analysis
-- 5. Adjust thresholds: Change 85%, 95%, 75%, 90% based on your targets
