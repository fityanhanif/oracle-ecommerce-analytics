-- 04_add_constraints.sql
-- Run as BLAZORD_OLIST after CSV imports are complete and row counts are validated.

SET ECHO ON
SET SERVEROUTPUT ON

-- Remove duplicates in reference-ish staging tables can be handled later in clean layer.
-- These constraints are for staging tables where keys are expected to be unique.

ALTER TABLE stg_customers ADD CONSTRAINT pk_stg_customers PRIMARY KEY (customer_id);
ALTER TABLE stg_orders ADD CONSTRAINT pk_stg_orders PRIMARY KEY (order_id);
ALTER TABLE stg_products ADD CONSTRAINT pk_stg_products PRIMARY KEY (product_id);
ALTER TABLE stg_sellers ADD CONSTRAINT pk_stg_sellers PRIMARY KEY (seller_id);
-- Category translation contains a blank category row in the public Olist file,
-- so keep it as a lookup table without a primary-key constraint in staging.
-- A clean dim_category table can enforce a PK after filtering blank category names.

ALTER TABLE stg_order_items ADD CONSTRAINT pk_stg_order_items PRIMARY KEY (order_id, order_item_id);
ALTER TABLE stg_order_payments ADD CONSTRAINT pk_stg_order_payments PRIMARY KEY (order_id, payment_sequential);

-- Review IDs can repeat in some public Olist variants, so use review_id + order_id.
ALTER TABLE stg_order_reviews ADD CONSTRAINT pk_stg_order_reviews PRIMARY KEY (review_id, order_id);

ALTER TABLE stg_orders ADD CONSTRAINT fk_stg_orders_customer
  FOREIGN KEY (customer_id) REFERENCES stg_customers(customer_id);

ALTER TABLE stg_order_items ADD CONSTRAINT fk_stg_items_order
  FOREIGN KEY (order_id) REFERENCES stg_orders(order_id);

ALTER TABLE stg_order_items ADD CONSTRAINT fk_stg_items_product
  FOREIGN KEY (product_id) REFERENCES stg_products(product_id);

ALTER TABLE stg_order_items ADD CONSTRAINT fk_stg_items_seller
  FOREIGN KEY (seller_id) REFERENCES stg_sellers(seller_id);

ALTER TABLE stg_order_payments ADD CONSTRAINT fk_stg_payments_order
  FOREIGN KEY (order_id) REFERENCES stg_orders(order_id);

ALTER TABLE stg_order_reviews ADD CONSTRAINT fk_stg_reviews_order
  FOREIGN KEY (order_id) REFERENCES stg_orders(order_id);

-- Do not add FK from products to translation in staging because the translation file
-- includes a blank row and this layer preserves raw public data behavior.

CREATE INDEX idx_stg_orders_customer ON stg_orders(customer_id);
CREATE INDEX idx_stg_orders_status ON stg_orders(order_status);
CREATE INDEX idx_stg_items_product ON stg_order_items(product_id);
CREATE INDEX idx_stg_items_seller ON stg_order_items(seller_id);
CREATE INDEX idx_stg_payments_type ON stg_order_payments(payment_type);
CREATE INDEX idx_stg_reviews_score ON stg_order_reviews(review_score);
CREATE INDEX idx_stg_customers_state ON stg_customers(customer_state);
CREATE INDEX idx_stg_sellers_state ON stg_sellers(seller_state);
CREATE INDEX idx_stg_products_category ON stg_products(product_category_name);

SELECT constraint_name, table_name, constraint_type, status
FROM user_constraints
WHERE table_name LIKE 'STG_%'
ORDER BY table_name, constraint_type, constraint_name;
