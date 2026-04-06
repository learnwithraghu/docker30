-- METRIC: Innovation Contribution
-- DOMAIN: Strategic Value
-- FILE: examples/strategic-value/innovation-contribution.sql
--
-- What this shows:
-- Number of ideas, improvements, or innovations submitted by vendor per year
-- Higher count = better (more strategic partnership)
-- Target: > 2 ideas/year for strategic vendors
--
-- Use this when:
-- - Evaluating strategic vendor relationships
-- - Identifying innovation partnerships
-- - Assessing vendor development potential

SELECT
  v.vendor_id,
  v.vendor_name,
  v.category,
  v.strategic_tier,
  EXTRACT(YEAR FROM ra.assessment_date) as year,
  COUNT(DISTINCT ra.assessment_id) as innovation_ideas_submitted,
  ROUND(AVG(ra.innovation_impact_score), 2) as avg_innovation_impact,
  STRING_AGG(DISTINCT ra.innovation_category, ', ') as innovation_types,
  CASE 
    WHEN COUNT(DISTINCT ra.assessment_id) >= 2 THEN '✅ Strategic'
    WHEN COUNT(DISTINCT ra.assessment_id) = 1 THEN '⚠️ Developing'
    ELSE '🔴 Transactional'
  END as partnership_tier
FROM procurement.risk_assessments ra
JOIN procurement.vendors v ON ra.vendor_id = v.vendor_id
WHERE EXTRACT(YEAR FROM ra.assessment_date) >= EXTRACT(YEAR FROM DATE_SUB(CURRENT_DATE(), INTERVAL 2 YEAR))
  AND v.status = 'active'
  AND ra.innovation_category IS NOT NULL
GROUP BY v.vendor_id, v.vendor_name, v.category, v.strategic_tier, EXTRACT(YEAR FROM ra.assessment_date)
ORDER BY year DESC, innovation_ideas_submitted DESC
LIMIT 50;

-- NOTE: This assumes innovation-related fields exist in risk_assessments
-- Adjust column names and table references based on actual schema

-- CUSTOMIZATION TIPS:
-- 1. Get strategic vendors only: FILTER for partnership_tier = 'Strategic'
-- 2. Get recent year: Change year filter for current year only
-- 3. Get by innovation type: GROUP BY innovation_category instead of vendor
-- 4. Get top contributors: ORDER BY innovation_ideas_submitted DESC, LIMIT 10
-- 5. Benchmark: Compare innovation by category
