-- 02_create_tables.sql
-- Run as BLAZORD_OLIST.
-- Creates staging tables for the Olist CSV files.

SET ECHO ON
SET SERVEROUTPUT ON

BEGIN
  FOR t IN (
    SELECT table_name
    FROM user_tables
    WHERE table_name IN (
      'STG_CUSTOMERS','STG_ORDERS','STG_ORDER_ITEMS','STG_ORDER_PAYMENTS',
      'STG_ORDER_REVIEWS','STG_PRODUCTS','STG_SELLERS','STG_GEOLOCATION',
      'STG_CATEGORY_TRANSLATION'
    )
  ) LOOP
    EXECUTE IMMEDIATE 'DROP TABLE ' || t.table_name || ' CASCADE CONSTRAINTS PURGE';
    DBMS_OUTPUT.PUT_LINE('Dropped ' || t.table_name);
  END LOOP;
END;
/

CREATE TABLE stg_customers (
  customer_id               VARCHAR2(64),
  customer_unique_id        VARCHAR2(64),
  customer_zip_code_prefix  NUMBER,
  customer_city             VARCHAR2(120),
  customer_state            VARCHAR2(5)
);

CREATE TABLE stg_orders (
  order_id                         VARCHAR2(64),
  customer_id                      VARCHAR2(64),
  order_status                     VARCHAR2(40),
  order_purchase_timestamp         VARCHAR2(30),
  order_approved_at                VARCHAR2(30),
  order_delivered_carrier_date     VARCHAR2(30),
  order_delivered_customer_date    VARCHAR2(30),
  order_estimated_delivery_date    VARCHAR2(30)
);

CREATE TABLE stg_order_items (
  order_id              VARCHAR2(64),
  order_item_id         NUMBER,
  product_id            VARCHAR2(64),
  seller_id             VARCHAR2(64),
  shipping_limit_date   VARCHAR2(30),
  price                 NUMBER(12,2),
  freight_value         NUMBER(12,2)
);

CREATE TABLE stg_order_payments (
  order_id              VARCHAR2(64),
  payment_sequential    NUMBER,
  payment_type          VARCHAR2(40),
  payment_installments  NUMBER,
  payment_value         NUMBER(12,2)
);

CREATE TABLE stg_order_reviews (
  review_id                VARCHAR2(64),
  order_id                 VARCHAR2(64),
  review_score             NUMBER,
  review_comment_title     VARCHAR2(1000),
  review_comment_message   CLOB,
  review_creation_date     VARCHAR2(30),
  review_answer_timestamp  VARCHAR2(30)
);

CREATE TABLE stg_products (
  product_id                    VARCHAR2(64),
  product_category_name          VARCHAR2(120),
  product_name_lenght            NUMBER,
  product_description_lenght     NUMBER,
  product_photos_qty             NUMBER,
  product_weight_g               NUMBER,
  product_length_cm              NUMBER,
  product_height_cm              NUMBER,
  product_width_cm               NUMBER
);

CREATE TABLE stg_sellers (
  seller_id               VARCHAR2(64),
  seller_zip_code_prefix  NUMBER,
  seller_city             VARCHAR2(120),
  seller_state            VARCHAR2(5)
);

CREATE TABLE stg_geolocation (
  geolocation_zip_code_prefix  NUMBER,
  geolocation_lat              NUMBER,
  geolocation_lng              NUMBER,
  geolocation_city             VARCHAR2(120),
  geolocation_state            VARCHAR2(5)
);

CREATE TABLE stg_category_translation (
  product_category_name          VARCHAR2(120),
  product_category_name_english  VARCHAR2(120)
);

SELECT table_name FROM user_tables WHERE table_name LIKE 'STG_%' ORDER BY table_name;
