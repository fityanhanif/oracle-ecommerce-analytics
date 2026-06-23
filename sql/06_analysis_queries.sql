-- 06_analysis_queries.sql
-- Run as BLAZORD_OLIST after views are created.

SET PAGESIZE 100
SET LINESIZE 220
SET TRIMSPOOL ON
COLUMN category_name FORMAT A35
COLUMN seller_id FORMAT A35
COLUMN customer_state FORMAT A15
COLUMN payment_type FORMAT A20
COLUMN delivery_group FORMAT A28

PROMPT === Executive Summary ===
SELECT * FROM vw_bi_executive_summary;

PROMPT === Monthly Sales Trend: Top 12 Months ===
SELECT *
FROM vw_monthly_sales_performance
ORDER BY sales_month
FETCH FIRST 12 ROWS ONLY;

PROMPT === Top 10 Categories by Revenue ===
SELECT category_name, order_count, item_count, item_revenue, freight_revenue, avg_review_score, revenue_rank
FROM vw_category_revenue_rank
ORDER BY item_revenue DESC
FETCH FIRST 10 ROWS ONLY;

PROMPT === State Delivery Performance: Worst Late Delivery Rate ===
SELECT customer_state, order_count, delivered_order_count, avg_delivery_days, late_order_count, late_delivery_rate_pct
FROM vw_state_delivery_performance
WHERE delivered_order_count >= 100
ORDER BY late_delivery_rate_pct DESC
FETCH FIRST 10 ROWS ONLY;

PROMPT === Seller Scorecard: High Revenue Sellers with Risk Label ===
SELECT seller_id, seller_state, order_count, item_revenue, avg_delivery_days, late_delivery_rate_pct, avg_review_score, seller_risk_label
FROM vw_seller_scorecard
WHERE order_count >= 50
ORDER BY item_revenue DESC
FETCH FIRST 20 ROWS ONLY;

PROMPT === Customer RFM Proxy: Repeat Customers ===
SELECT
  CASE WHEN frequency_orders = 1 THEN 'one_time' ELSE 'repeat' END AS customer_type,
  COUNT(*) AS customer_count,
  ROUND(AVG(frequency_orders),2) AS avg_frequency,
  ROUND(AVG(monetary_value),2) AS avg_monetary_value
FROM vw_customer_rfm_proxy
GROUP BY CASE WHEN frequency_orders = 1 THEN 'one_time' ELSE 'repeat' END;

PROMPT === Payment Behavior ===
SELECT payment_type, payment_rows, order_count, total_payment_value, avg_payment_value, avg_installments
FROM vw_payment_behavior
ORDER BY total_payment_value DESC;

PROMPT === Delivery Delay vs Review Score ===
SELECT delivery_group, order_count, avg_delivery_days, avg_review_score, low_review_rate_pct
FROM vw_review_delivery_impact;
