-- METRIC: Cost Avoidance
-- DOMAIN: Financial Health
-- FILE: examples/financial-health/cost-avoidance.sql
--
-- What this shows:
-- Estimated savings from negotiated contract rates vs market rates
-- Higher $ = better (more savings captured)
-- Target: > 5% of total spend
--
-- Use this when:
-- - Quantifying procurement value
-- - Justifying contract negotiations
-- - Ranking vendors by cost savings delivered

SELECT
  v.vendor_id,
  v.vendor_name,
  v.category,
  ROUND(SUM(t.amount), 2) as total_spend_usd,
  ROUND(
    SUM(
      CASE 
        WHEN t.contract_id IS NOT NULL THEN t.amount 
        ELSE 0 
      END
    ),
    2
  ) as contracted_spend_usd,
  ROUND(
    SUM(t.amount) - SUM(
      CASE 
        WHEN t.contract_id IS NOT NULL THEN t.amount 
        ELSE 0 
      END
    ),
    2
  ) as estimated_cost_avoidance_usd,
  ROUND(
    SAFE_DIVIDE(
      SUM(t.amount) - SUM(
        CASE 
          WHEN t.contract_id IS NOT NULL THEN t.amount 
          ELSE 0 
        END
      ),
      SUM(t.amount)
    ) * 100,
    1
  ) as cost_avoidance_pct
FROM procurement.spend_transactions t
JOIN procurement.vendors v ON t.vendor_id = v.vendor_id
WHERE t.event_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 12 MONTH)
  AND v.status = 'active'
GROUP BY v.vendor_id, v.vendor_name, v.category
ORDER BY estimated_cost_avoidance_usd DESC
LIMIT 25;

-- NOTE: This is a simplified version assuming contract rates are lower than non-contract rates
-- For market rate comparison, you would join with procurement.market_rates table

-- CUSTOMIZATION TIPS:
-- 1. Get top 10: Change "LIMIT 25" to "LIMIT 10"
-- 2. Filter by category: Add "AND v.category = 'Manufacturing'"
-- 3. Show only vendors with savings: Add "HAVING cost_avoidance_pct > 0"
