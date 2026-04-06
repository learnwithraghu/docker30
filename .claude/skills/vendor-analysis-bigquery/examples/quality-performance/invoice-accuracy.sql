-- METRIC: Invoice Accuracy
-- DOMAIN: Quality & Performance
-- FILE: examples/quality-performance/invoice-accuracy.sql
--
-- What this shows:
-- Percentage of invoices matching PO/receipt data
-- Higher % = better (fewer billing disputes)
-- Target: > 98%
--
-- Use this when:
-- - Reducing invoice discrepancies
-- - Managing accounts payable quality
-- - Identifying billing fraud or errors

SELECT
  v.vendor_id,
  v.vendor_name,
  v.category,
  v.strategic_tier,
  COUNT(DISTINCT i.invoice_id) as total_invoices,
  SUM(
    CASE 
      WHEN i.amount = po.po_amount THEN 1 
      ELSE 0 
    END
  ) as accurate_invoices,
  ROUND(
    SAFE_DIVIDE(
      SUM(
        CASE 
          WHEN i.amount = po.po_amount THEN 1 
          ELSE 0 
        END
      ),
      COUNT(DISTINCT i.invoice_id)
    ) * 100,
    1
  ) as invoice_accuracy_pct,
  ROUND(SUM(i.amount), 2) as total_invoiced_usd,
  ROUND(
    SUM(
      CASE 
        WHEN i.amount != po.po_amount 
          THEN ABS(i.amount - po.po_amount)
        ELSE 0 
      END
    ),
    2
  ) as total_discrepancy_usd,
  CASE 
    WHEN SAFE_DIVIDE(
      SUM(
        CASE 
          WHEN i.amount = po.po_amount THEN 1 
          ELSE 0 
        END
      ),
      COUNT(DISTINCT i.invoice_id)
    ) >= 0.98 THEN '✅ On Target'
    ELSE '⚠️ Below Target'
  END as accuracy_status,
  MAX(i.invoice_date) as latest_invoice_date
FROM procurement.invoices i
LEFT JOIN procurement.purchase_orders po ON i.po_id = po.po_id
JOIN procurement.vendors v ON i.vendor_id = v.vendor_id
WHERE i.invoice_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 12 MONTH)
  AND v.status = 'active'
GROUP BY v.vendor_id, v.vendor_name, v.category, v.strategic_tier
ORDER BY invoice_accuracy_pct ASC
LIMIT 50;

-- CUSTOMIZATION TIPS:
-- 1. Get worst performers: ORDER BY invoice_accuracy_pct ASC, LIMIT 10
-- 2. Get high-discrepancy vendors: ORDER BY total_discrepancy_usd DESC
-- 3. Get high-volume only: Add "HAVING total_invoices >= 50"
-- 4. By category: GROUP BY category for category analysis
-- 5. Recent only: Change "INTERVAL 12 MONTH" to "INTERVAL 3 MONTH"
