-- METRIC: Spend Under Management
-- DOMAIN: Financial Health
-- FILE: examples/financial-health/spend-under-management.sql
-- 
-- What this shows:
-- Percentage of vendor spend covered by negotiated contracts
-- Higher % = better (less maverick spend)
-- Target: > 85%
--
-- Use this when:
-- - Finding vendors with uncontrolled spending
-- - Identifying contract consolidation opportunities
-- - Calculating maverick spend for procurement initiatives

SELECT
  v.vendor_id,
  v.vendor_name,
  v.category,
  v.strategic_tier,
  ROUND(SUM(t.amount), 2) as total_spend_usd,
  ROUND(
    SUM(CASE WHEN t.contract_id IS NOT NULL THEN t.amount ELSE 0 END),
    2
  ) as contracted_spend_usd,
  ROUND(
    SAFE_DIVIDE(
      SUM(CASE WHEN t.contract_id IS NOT NULL THEN t.amount ELSE 0 END),
      SUM(t.amount)
    ) * 100,
    1
  ) as spend_under_management_pct,
  CASE 
    WHEN SAFE_DIVIDE(
      SUM(CASE WHEN t.contract_id IS NOT NULL THEN t.amount ELSE 0 END),
      SUM(t.amount)
    ) >= 0.85 THEN '✅ On Target'
    ELSE '⚠️ Below Target'
  END as status
FROM procurement.spend_transactions t
JOIN procurement.vendors v ON t.vendor_id = v.vendor_id
WHERE t.event_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 12 MONTH)
  AND v.status = 'active'
GROUP BY v.vendor_id, v.vendor_name, v.category, v.strategic_tier
ORDER BY spend_under_management_pct ASC
LIMIT 50;

-- CUSTOMIZATION TIPS:
-- 1. Filter by category: Add "AND v.category = 'IT Services'"
-- 2. Filter by vendor: Add "AND v.vendor_id = 12345"
-- 3. Filter by tier: Add "AND v.strategic_tier = 'Tier-1'"
-- 4. Change time period: Replace "INTERVAL 12 MONTH" with your range
-- 5. Get top performers: ORDER BY ... DESC instead of ASC
