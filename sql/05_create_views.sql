-- 05_create_views.sql
-- Run as BLAZORD_OLIST after staging CSV imports are complete.

SET ECHO ON

CREATE OR REPLACE VIEW vw_order_enriched AS
SELECT
  o.order_id,
  o.customer_id,
  c.customer_unique_id,
  c.customer_city,
  c.customer_state,
  o.order_status,
  CAST(TO_TIMESTAMP(NULLIF(o.order_purchase_timestamp,''), 'YYYY-MM-DD HH24:MI:SS') AS DATE) AS purchase_date,
  CAST(TO_TIMESTAMP(NULLIF(o.order_delivered_customer_date,''), 'YYYY-MM-DD HH24:MI:SS') AS DATE) AS delivered_customer_date,
  CAST(TO_TIMESTAMP(NULLIF(o.order_estimated_delivery_date,''), 'YYYY-MM-DD HH24:MI:SS') AS DATE) AS estimated_delivery_date,
  CASE
    WHEN o.order_delivered_customer_date IS NOT NULL
     AND o.order_estimated_delivery_date IS NOT NULL
     AND CAST(TO_TIMESTAMP(NULLIF(o.order_delivered_customer_date,''), 'YYYY-MM-DD HH24:MI:SS') AS DATE) >
         CAST(TO_TIMESTAMP(NULLIF(o.order_estimated_delivery_date,''), 'YYYY-MM-DD HH24:MI:SS') AS DATE)
    THEN 1 ELSE 0
  END AS is_late,
  CASE
    WHEN o.order_delivered_customer_date IS NOT NULL
     AND o.order_purchase_timestamp IS NOT NULL
    THEN CAST(TO_TIMESTAMP(NULLIF(o.order_delivered_customer_date,''), 'YYYY-MM-DD HH24:MI:SS') AS DATE) -
         CAST(TO_TIMESTAMP(NULLIF(o.order_purchase_timestamp,''), 'YYYY-MM-DD HH24:MI:SS') AS DATE)
  END AS delivery_days
FROM stg_orders o
LEFT JOIN stg_customers c ON c.customer_id = o.customer_id;

CREATE OR REPLACE VIEW vw_monthly_sales_performance AS
SELECT
  TRUNC(e.purchase_date, 'MM') AS sales_month,
  COUNT(DISTINCT e.order_id) AS order_count,
  COUNT(*) AS item_count,
  ROUND(SUM(i.price), 2) AS item_revenue,
  ROUND(SUM(i.freight_value), 2) AS freight_revenue,
  ROUND(SUM(i.price + i.freight_value), 2) AS total_revenue,
  ROUND(SUM(i.price + i.freight_value) / NULLIF(COUNT(DISTINCT e.order_id),0), 2) AS avg_order_value
FROM vw_order_enriched e
JOIN stg_order_items i ON i.order_id = e.order_id
WHERE e.purchase_date IS NOT NULL
GROUP BY TRUNC(e.purchase_date, 'MM');

CREATE OR REPLACE VIEW vw_category_revenue_rank AS
SELECT
  COALESCE(t.product_category_name_english, p.product_category_name, 'unknown') AS category_name,
  COUNT(DISTINCT i.order_id) AS order_count,
  COUNT(*) AS item_count,
  ROUND(SUM(i.price), 2) AS item_revenue,
  ROUND(SUM(i.freight_value), 2) AS freight_revenue,
  ROUND(AVG(r.review_score), 2) AS avg_review_score,
  RANK() OVER (ORDER BY SUM(i.price) DESC) AS revenue_rank
FROM stg_order_items i
LEFT JOIN stg_products p ON p.product_id = i.product_id
LEFT JOIN stg_category_translation t ON t.product_category_name = p.product_category_name
LEFT JOIN stg_order_reviews r ON r.order_id = i.order_id
GROUP BY COALESCE(t.product_category_name_english, p.product_category_name, 'unknown');

CREATE OR REPLACE VIEW vw_state_delivery_performance AS
SELECT
  customer_state,
  COUNT(*) AS order_count,
  SUM(CASE WHEN delivered_customer_date IS NOT NULL THEN 1 ELSE 0 END) AS delivered_order_count,
  ROUND(AVG(delivery_days), 2) AS avg_delivery_days,
  SUM(is_late) AS late_order_count,
  ROUND(SUM(is_late) / NULLIF(SUM(CASE WHEN delivered_customer_date IS NOT NULL THEN 1 ELSE 0 END),0) * 100, 2) AS late_delivery_rate_pct
FROM vw_order_enriched
GROUP BY customer_state;

CREATE OR REPLACE VIEW vw_seller_scorecard AS
SELECT
  i.seller_id,
  s.seller_city,
  s.seller_state,
  COUNT(DISTINCT i.order_id) AS order_count,
  COUNT(*) AS item_count,
  ROUND(SUM(i.price), 2) AS item_revenue,
  ROUND(AVG(e.delivery_days), 2) AS avg_delivery_days,
  ROUND(SUM(e.is_late) / NULLIF(SUM(CASE WHEN e.delivered_customer_date IS NOT NULL THEN 1 ELSE 0 END),0) * 100, 2) AS late_delivery_rate_pct,
  ROUND(AVG(r.review_score), 2) AS avg_review_score,
  CASE
    WHEN AVG(r.review_score) < 3.5 OR (SUM(e.is_late) / NULLIF(SUM(CASE WHEN e.delivered_customer_date IS NOT NULL THEN 1 ELSE 0 END),0)) > 0.20 THEN 'HIGH_RISK'
    WHEN AVG(r.review_score) < 4.0 OR (SUM(e.is_late) / NULLIF(SUM(CASE WHEN e.delivered_customer_date IS NOT NULL THEN 1 ELSE 0 END),0)) > 0.10 THEN 'WATCHLIST'
    ELSE 'HEALTHY'
  END AS seller_risk_label
FROM stg_order_items i
LEFT JOIN stg_sellers s ON s.seller_id = i.seller_id
LEFT JOIN vw_order_enriched e ON e.order_id = i.order_id
LEFT JOIN stg_order_reviews r ON r.order_id = i.order_id
GROUP BY i.seller_id, s.seller_city, s.seller_state;

CREATE OR REPLACE VIEW vw_customer_rfm_proxy AS
SELECT
  customer_unique_id,
  MAX(purchase_date) AS last_purchase_date,
  COUNT(DISTINCT order_id) AS frequency_orders,
  ROUND(SUM(order_value), 2) AS monetary_value,
  ROUND(AVG(order_value), 2) AS avg_order_value
FROM (
  SELECT
    e.customer_unique_id,
    e.order_id,
    e.purchase_date,
    SUM(i.price + i.freight_value) AS order_value
  FROM vw_order_enriched e
  JOIN stg_order_items i ON i.order_id = e.order_id
  GROUP BY e.customer_unique_id, e.order_id, e.purchase_date
)
GROUP BY customer_unique_id;

CREATE OR REPLACE VIEW vw_payment_behavior AS
SELECT
  payment_type,
  COUNT(*) AS payment_rows,
  COUNT(DISTINCT order_id) AS order_count,
  ROUND(SUM(payment_value), 2) AS total_payment_value,
  ROUND(AVG(payment_value), 2) AS avg_payment_value,
  ROUND(AVG(payment_installments), 2) AS avg_installments
FROM stg_order_payments
GROUP BY payment_type;

CREATE OR REPLACE VIEW vw_review_delivery_impact AS
SELECT
  CASE WHEN e.is_late = 1 THEN 'Late' ELSE 'On time / not delivered late' END AS delivery_group,
  COUNT(DISTINCT e.order_id) AS order_count,
  ROUND(AVG(e.delivery_days), 2) AS avg_delivery_days,
  ROUND(AVG(r.review_score), 2) AS avg_review_score,
  ROUND(SUM(CASE WHEN r.review_score <= 2 THEN 1 ELSE 0 END) / NULLIF(COUNT(r.review_score),0) * 100, 2) AS low_review_rate_pct
FROM vw_order_enriched e
LEFT JOIN stg_order_reviews r ON r.order_id = e.order_id
GROUP BY CASE WHEN e.is_late = 1 THEN 'Late' ELSE 'On time / not delivered late' END;

CREATE OR REPLACE VIEW vw_bi_executive_summary AS
SELECT
  (SELECT COUNT(*) FROM stg_orders) AS total_orders,
  (SELECT COUNT(*) FROM stg_customers) AS total_customers,
  (SELECT COUNT(*) FROM stg_sellers) AS total_sellers,
  (SELECT COUNT(*) FROM stg_products) AS total_products,
  (SELECT ROUND(SUM(price),2) FROM stg_order_items) AS total_item_revenue,
  (SELECT ROUND(SUM(freight_value),2) FROM stg_order_items) AS total_freight_value,
  (SELECT ROUND(AVG(review_score),2) FROM stg_order_reviews) AS avg_review_score,
  (SELECT ROUND(SUM(is_late) / NULLIF(SUM(CASE WHEN delivered_customer_date IS NOT NULL THEN 1 ELSE 0 END),0) * 100,2) FROM vw_order_enriched) AS late_delivery_rate_pct
FROM dual;

SELECT view_name FROM user_views WHERE view_name LIKE 'VW_%' ORDER BY view_name;
