-- METRIC: Payment Terms Optimization
-- DOMAIN: Financial Health
-- FILE: examples/financial-health/payment-terms-optimization.sql
--
-- What this shows:
-- Average payment days and working capital impact
-- Lower days = faster cash out (less working capital benefit)
-- Higher days = delayed payment risk (supplier relationship risk)
-- Target: Balanced (industry-dependent, typically 30-60 days)
--
-- Use this when:
-- - Optimizing working capital
-- - Balancing supplier relationships with cash flow
-- - Analyzing payment risk across vendor base

SELECT
  v.vendor_id,
  v.vendor_name,
  v.category,
  v.strategic_tier,
  ROUND(AVG(c.payment_term_days), 0) as avg_payment_days,
  COUNT(DISTINCT c.contract_id) as active_contracts,
  ROUND(SUM(i.amount), 2) as total_invoiced_usd,
  ROUND(
    AVG(c.payment_term_days) * 
    SAFE_DIVIDE(SUM(i.amount), COUNT(DISTINCT DATE(i.invoice_date))),
    2
  ) as estimated_daily_cash_impact_usd,
  CASE 
    WHEN AVG(c.payment_term_days) < 30 THEN '⚡ Fast (Cash pressure)'
    WHEN AVG(c.payment_term_days) BETWEEN 30 AND 60 THEN '✅ Balanced'
    WHEN AVG(c.payment_term_days) > 60 THEN '⏸️ Extended (Supplier risk)'
    ELSE '❓ Unknown'
  END as working_capital_impact
FROM procurement.invoices i
JOIN procurement.vendors v ON i.vendor_id = v.vendor_id
JOIN procurement.contracts c ON i.contract_id = c.contract_id
WHERE i.invoice_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 12 MONTH)
  AND v.status = 'active'
GROUP BY v.vendor_id, v.vendor_name, v.category, v.strategic_tier
ORDER BY avg_payment_days DESC
LIMIT 30;

-- CUSTOMIZATION TIPS:
-- 1. Get vendors with extended terms: Filter for AVG(c.payment_term_days) > 60
-- 2. Filter by strategic tier: Add "AND v.strategic_tier = 'Tier-1'"
-- 3. Compare categories: GROUP BY also v.category, then ORDER BY that
-- 4. Get only recent contracts: Filter c.end_date >= CURRENT_DATE()
