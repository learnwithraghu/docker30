-- METRIC: Order Accuracy
-- DOMAIN: Operational Efficiency
-- FILE: examples/operational-efficiency/order-accuracy.sql
--
-- What this shows:
-- Percentage of orders delivered with correct quantity and item
-- Higher % = better (fewer receiving issues)
-- Target: > 98%
--
-- Use this when:
-- - Evaluating receiving quality
-- - Identifying picking/packing issues
-- - Analyzing shortage and overage frequency

SELECT
  v.vendor_id,
  v.vendor_name,
  v.category,
  v.strategic_tier,
  COUNT(DISTINCT dr.receipt_id) as total_receipts,
  SUM(
    CASE 
      WHEN dr.quantity_received = po.quantity_ordered THEN 1 
      ELSE 0 
    END
  ) as accurate_receipts,
  ROUND(
    SAFE_DIVIDE(
      SUM(
        CASE 
          WHEN dr.quantity_received = po.quantity_ordered THEN 1 
          ELSE 0 
        END
      ),
      COUNT(DISTINCT dr.receipt_id)
    ) * 100,
    1
  ) as order_accuracy_pct,
  SUM(
    CASE 
      WHEN dr.quantity_received < po.quantity_ordered THEN 1 
      ELSE 0 
    END
  ) as short_shipments,
  SUM(
    CASE 
      WHEN dr.quantity_received > po.quantity_ordered THEN 1 
      ELSE 0 
    END
  ) as over_shipments,
  CASE 
    WHEN SAFE_DIVIDE(
      SUM(
        CASE 
          WHEN dr.quantity_received = po.quantity_ordered THEN 1 
          ELSE 0 
        END
      ),
      COUNT(DISTINCT dr.receipt_id)
    ) >= 0.98 THEN '✅ On Target'
    ELSE '⚠️ Below Target'
  END as status
FROM procurement.delivery_receipts dr
JOIN procurement.purchase_orders po ON dr.po_id = po.po_id
JOIN procurement.vendors v ON po.vendor_id = v.vendor_id
WHERE dr.delivery_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 12 MONTH)
  AND v.status = 'active'
GROUP BY v.vendor_id, v.vendor_name, v.category, v.strategic_tier
ORDER BY order_accuracy_pct ASC
LIMIT 50;

-- CUSTOMIZATION TIPS:
-- 1. Get worst performers: ORDER BY ... ASC, LIMIT 10
-- 2. Get vendors with short shipments: Filter for short_shipments > 0
-- 3. Get vendors with over shipments: Filter for over_shipments > 0
-- 4. High-volume only: Add "HAVING total_receipts >= 100"
-- 5. By category: GROUP BY category instead
