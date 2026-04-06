-- METRIC: ESG Compliance Score
-- DOMAIN: Risk & Compliance
-- FILE: examples/risk-compliance/esg-compliance-score.sql
--
-- What this shows:
-- Environmental, Social, and Governance compliance scores
-- Higher score = better ESG practices
-- Target: > 80/100
--
-- Use this when:
-- - Evaluating sustainability practices
-- - Managing ESG risk in supply chain
-- - Identifying vendors needing remediation

SELECT
  v.vendor_id,
  v.vendor_name,
  v.category,
  v.country,
  v.strategic_tier,
  ROUND(AVG(rm.environmental_score), 1) as environmental_score,
  ROUND(AVG(rm.social_score), 1) as social_score,
  ROUND(AVG(rm.governance_score), 1) as governance_score,
  ROUND(
    (
      AVG(rm.environmental_score) + 
      AVG(rm.social_score) + 
      AVG(rm.governance_score)
    ) / 3,
    1
  ) as overall_esg_score,
  CASE 
    WHEN (AVG(rm.environmental_score) + AVG(rm.social_score) + AVG(rm.governance_score)) / 3 >= 80 
      THEN '✅ Strong'
    WHEN (AVG(rm.environmental_score) + AVG(rm.social_score) + AVG(rm.governance_score)) / 3 >= 70 
      THEN '⚠️ Fair'
    ELSE '🔴 Weak'
  END as esg_rating,
  COUNT(DISTINCT rm.assessment_id) as assessment_count,
  MAX(rm.assessment_date) as latest_assessment_date
FROM procurement.sustainability_metrics rm
JOIN procurement.vendors v ON rm.vendor_id = v.vendor_id
WHERE rm.measurement_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 24 MONTH)
  AND v.status = 'active'
GROUP BY v.vendor_id, v.vendor_name, v.category, v.country, v.strategic_tier
ORDER BY overall_esg_score DESC
LIMIT 50;

-- CUSTOMIZATION TIPS:
-- 1. Get weak performers: ORDER BY ... ASC or FILTER for esg_rating = 'Weak'
-- 2. Get by country: GROUP BY country to see regional patterns
-- 3. Environmental focus: ORDER BY environmental_score DESC
-- 4. High spend only: JOIN with spend_transactions and filter for high spenders
-- 5. Recent only: Change "INTERVAL 24 MONTH" to "INTERVAL 6 MONTH"
