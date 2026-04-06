-- METRIC: Contract Compliance Rate
-- DOMAIN: Risk & Compliance
-- FILE: examples/risk-compliance/contract-compliance-rate.sql
--
-- What this shows:
-- Percentage of transactions adhering to contract terms
-- Higher % = better (fewer breaches)
-- Target: > 90%
--
-- Use this when:
-- - Monitoring contract enforcement
-- - Identifying rogue procurement
-- - Risk and compliance auditing

SELECT
  v.vendor_id,
  v.vendor_name,
  v.category,
  c.contract_id,
  c.start_date,
  c.end_date,
  COUNT(DISTINCT t.transaction_id) as total_transactions,
  SUM(t.amount) as total_spend_usd,
  SUM(
    CASE 
      WHEN t.contract_id = c.contract_id THEN 1 
      ELSE 0 
    END
  ) as compliant_transactions,
  ROUND(
    SAFE_DIVIDE(
      SUM(
        CASE 
          WHEN t.contract_id = c.contract_id THEN 1 
          ELSE 0 
        END
      ),
      COUNT(DISTINCT t.transaction_id)
    ) * 100,
    1
  ) as contract_compliance_rate_pct,
  CASE 
    WHEN SAFE_DIVIDE(
      SUM(
        CASE 
          WHEN t.contract_id = c.contract_id THEN 1 
          ELSE 0 
        END
      ),
      COUNT(DISTINCT t.transaction_id)
    ) >= 0.90 THEN '✅ Compliant'
    ELSE '⚠️ Non-Compliant'
  END as compliance_status
FROM procurement.contracts c
JOIN procurement.vendors v ON c.vendor_id = v.vendor_id
JOIN procurement.spend_transactions t ON v.vendor_id = t.vendor_id
  AND t.event_date BETWEEN c.start_date AND c.end_date
WHERE c.end_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 12 MONTH)
  AND v.status = 'active'
GROUP BY v.vendor_id, v.vendor_name, v.category, c.contract_id, c.start_date, c.end_date
ORDER BY contract_compliance_rate_pct ASC
LIMIT 50;

-- CUSTOMIZATION TIPS:
-- 1. Get active contracts only: Add "AND c.end_date >= CURRENT_DATE()"
-- 2. Get non-compliant: Filter for compliance_status = 'Non-Compliant'
-- 3. Get by category: GROUP BY category for category-level analysis
-- 4. Get high-spend only: Add "HAVING total_spend_usd > 100000"
-- 5. Recent only: Filter for c.start_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 6 MONTH)
