-- METRIC: Geographic Concentration Risk
-- DOMAIN: Risk & Compliance
-- FILE: examples/risk-compliance/geographic-concentration-risk.sql
--
-- What this shows:
-- Percentage of spend by country/region
-- Identifies concentration risk (e.g., >40% from one country)
-- Helps assess supply chain resilience
--
-- Use this when:
-- - Identifying supply chain vulnerabilities
-- - Risk management and diversification planning
-- - Geopolitical risk assessment

SELECT
  v.country,
  v.region,
  COUNT(DISTINCT v.vendor_id) as vendor_count,
  ROUND(SUM(t.amount), 2) as total_spend_usd,
  ROUND(
    SAFE_DIVIDE(
      SUM(t.amount),
      SUM(SUM(t.amount)) OVER ()
    ) * 100,
    1
  ) as pct_of_total_spend,
  ROUND(
    AVG(dr_metric.on_time_delivery_rate),
    1
  ) as avg_on_time_delivery_pct,
  CASE 
    WHEN SAFE_DIVIDE(
      SUM(t.amount),
      SUM(SUM(t.amount)) OVER ()
    ) > 0.40 THEN '🔴 High Concentration (>40%)'
    WHEN SAFE_DIVIDE(
      SUM(t.amount),
      SUM(SUM(t.amount)) OVER ()
    ) > 0.25 THEN '⚠️ Moderate Concentration (25-40%)'
    ELSE '✅ Well Diversified (<25%)'
  END as concentration_risk
FROM procurement.spend_transactions t
JOIN procurement.vendors v ON t.vendor_id = v.vendor_id
LEFT JOIN (
  SELECT 
    po.vendor_id,
    SAFE_DIVIDE(
      SUM(CASE WHEN dr.actual_delivery <= po.promised_date THEN 1 ELSE 0 END),
      COUNT(DISTINCT dr.receipt_id)
    ) * 100 as on_time_delivery_rate
  FROM procurement.purchase_orders po
  JOIN procurement.delivery_receipts dr ON po.po_id = dr.po_id
  WHERE po.po_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 12 MONTH)
  GROUP BY po.vendor_id
) dr_metric ON v.vendor_id = dr_metric.vendor_id
WHERE t.event_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 12 MONTH)
  AND v.status = 'active'
GROUP BY v.country, v.region
ORDER BY total_spend_usd DESC;

-- CUSTOMIZATION TIPS:
-- 1. Get concentration by region: GROUP BY region instead of country
-- 2. Detailed breakdown: ORDER BY pct_of_total_spend DESC
-- 3. High-risk countries only: FILTER for concentration_risk = 'High Concentration'
-- 4. Alternative sources: JOIN with vendors in other countries for mitigation
-- 5. Strategic tier: Add v.strategic_tier to GROUP BY for critical vendor analysis
