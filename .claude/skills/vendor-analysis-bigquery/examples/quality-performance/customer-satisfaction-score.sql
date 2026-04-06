-- METRIC: Customer Satisfaction Score
-- DOMAIN: Quality & Performance
-- FILE: examples/quality-performance/customer-satisfaction-score.sql
--
-- What this shows:
-- Average satisfaction score from internal stakeholders
-- Higher score = better (scale: 1-5)
-- Target: > 4.0/5
--
-- Use this when:
-- - Measuring overall vendor performance perception
-- - Identifying vendors needing improvement
-- - Supporting renewal/replacement decisions

SELECT
  v.vendor_id,
  v.vendor_name,
  v.category,
  v.strategic_tier,
  COUNT(DISTINCT ra.assessment_id) as total_assessments,
  ROUND(AVG(ra.satisfaction_score), 2) as avg_satisfaction_score,
  ROUND(AVG(ra.overall_performance_score), 2) as overall_performance_score,
  ROUND(AVG(ra.responsiveness_score), 2) as responsiveness_score,
  ROUND(AVG(ra.communication_score), 2) as communication_score,
  MIN(ra.assessment_date) as first_assessment_date,
  MAX(ra.assessment_date) as latest_assessment_date,
  CASE 
    WHEN AVG(ra.satisfaction_score) >= 4.0 THEN '✅ Strong'
    WHEN AVG(ra.satisfaction_score) >= 3.0 THEN '⚠️ Fair'
    ELSE '🔴 Weak'
  END as satisfaction_rating
FROM procurement.risk_assessments ra
JOIN procurement.vendors v ON ra.vendor_id = v.vendor_id
WHERE ra.assessment_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 24 MONTH)
  AND v.status = 'active'
  AND ra.satisfaction_score IS NOT NULL
GROUP BY v.vendor_id, v.vendor_name, v.category, v.strategic_tier
ORDER BY avg_satisfaction_score DESC
LIMIT 50;

-- NOTE: This assumes satisfaction_score and related fields exist in risk_assessments
-- If your schema differs, adjust column names accordingly

-- CUSTOMIZATION TIPS:
-- 1. Get weak performers: ORDER BY ... ASC or FILTER for satisfaction_rating = 'Weak'
-- 2. Get strong performers: ORDER BY ... DESC, LIMIT 10
-- 3. By department: Add department feedback if available
-- 4. Recent only: Change "INTERVAL 24 MONTH" to "INTERVAL 12 MONTH"
-- 5. Trend analysis: GROUP BY DATE_TRUNC(assessment_date, MONTH) to see improvement/decline
