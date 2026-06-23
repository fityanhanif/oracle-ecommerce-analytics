# Data Profile — Olist Dataset

Source folder:

```text
C:\Users\lenovo\Projects\oracle-ecommerce-analytics\data\raw
```

## Dataset Inventory

| File | Rows | Columns | Oracle staging table |
|---|---:|---:|---|
| `olist_customers_dataset.csv` | 99,441 | 5 | `stg_customers` |
| `olist_geolocation_dataset.csv` | 1,000,163 | 5 | `stg_geolocation` |
| `olist_order_items_dataset.csv` | 112,650 | 7 | `stg_order_items` |
| `olist_order_payments_dataset.csv` | 103,886 | 5 | `stg_order_payments` |
| `olist_order_reviews_dataset.csv` | 99,224 | 7 | `stg_order_reviews` |
| `olist_orders_dataset.csv` | 99,441 | 8 | `stg_orders` |
| `olist_products_dataset.csv` | 32,951 | 9 | `stg_products` |
| `olist_sellers_dataset.csv` | 3,095 | 4 | `stg_sellers` |
| `product_category_name_translation.csv` | 71 | 2 | `stg_category_translation` |

## Raw File Details

### Customers

File: `olist_customers_dataset.csv`

Columns:

- `customer_id`
- `customer_unique_id`
- `customer_zip_code_prefix`
- `customer_city`
- `customer_state`

Purpose: customer dimension and regional segmentation.

### Orders

File: `olist_orders_dataset.csv`

Columns:

- `order_id`
- `customer_id`
- `order_status`
- `order_purchase_timestamp`
- `order_approved_at`
- `order_delivered_carrier_date`
- `order_delivered_customer_date`
- `order_estimated_delivery_date`

Purpose: order header, status, and delivery lifecycle analysis.

### Order Items

File: `olist_order_items_dataset.csv`

Columns:

- `order_id`
- `order_item_id`
- `product_id`
- `seller_id`
- `shipping_limit_date`
- `price`
- `freight_value`

Purpose: sales fact table at order-line grain.

### Payments

File: `olist_order_payments_dataset.csv`

Columns:

- `order_id`
- `payment_sequential`
- `payment_type`
- `payment_installments`
- `payment_value`

Purpose: payment behavior and installment analysis.

### Reviews

File: `olist_order_reviews_dataset.csv`

Columns:

- `review_id`
- `order_id`
- `review_score`
- `review_comment_title`
- `review_comment_message`
- `review_creation_date`
- `review_answer_timestamp`

Purpose: customer satisfaction and delivery/review relationship.

### Products

File: `olist_products_dataset.csv`

Columns:

- `product_id`
- `product_category_name`
- `product_name_lenght`
- `product_description_lenght`
- `product_photos_qty`
- `product_weight_g`
- `product_length_cm`
- `product_height_cm`
- `product_width_cm`

Purpose: product dimension and category analysis.

Note: original Olist column names use `lenght`, not `length`. Keep raw columns in staging, then fix naming in clean layer.

### Sellers

File: `olist_sellers_dataset.csv`

Columns:

- `seller_id`
- `seller_zip_code_prefix`
- `seller_city`
- `seller_state`

Purpose: seller dimension and seller-region performance.

### Geolocation

File: `olist_geolocation_dataset.csv`

Columns:

- `geolocation_zip_code_prefix`
- `geolocation_lat`
- `geolocation_lng`
- `geolocation_city`
- `geolocation_state`

Purpose: optional geographic enrichment.

Note: this is the largest table. First iteration may use it only for state/city lookup or sampled geospatial analysis.

### Product Category Translation

File: `product_category_name_translation.csv`

Columns:

- `product_category_name`
- `product_category_name_english`

Purpose: translate Portuguese category names into English labels for dashboard/reporting.

## Data Grain

- `customers`: one row per `customer_id`
- `orders`: one row per `order_id`
- `order_items`: one row per `order_id + order_item_id`
- `payments`: one row per `order_id + payment_sequential`
- `reviews`: one or more review records per order depending on dataset behavior
- `products`: one row per `product_id`
- `sellers`: one row per `seller_id`
- `geolocation`: many rows per zip prefix because multiple lat/lng points can exist

## Important Join Keys

- `orders.customer_id = customers.customer_id`
- `order_items.order_id = orders.order_id`
- `order_items.product_id = products.product_id`
- `order_items.seller_id = sellers.seller_id`
- `payments.order_id = orders.order_id`
- `reviews.order_id = orders.order_id`
- `products.product_category_name = category_translation.product_category_name`

## Initial Quality Checks

Run after loading to Oracle:

```sql
SELECT 'customers' AS table_name, COUNT(*) AS row_count FROM stg_customers
UNION ALL SELECT 'orders', COUNT(*) FROM stg_orders
UNION ALL SELECT 'order_items', COUNT(*) FROM stg_order_items
UNION ALL SELECT 'payments', COUNT(*) FROM stg_order_payments
UNION ALL SELECT 'reviews', COUNT(*) FROM stg_order_reviews
UNION ALL SELECT 'products', COUNT(*) FROM stg_products
UNION ALL SELECT 'sellers', COUNT(*) FROM stg_sellers
UNION ALL SELECT 'geolocation', COUNT(*) FROM stg_geolocation
UNION ALL SELECT 'category_translation', COUNT(*) FROM stg_category_translation;
```

Expected counts must match the inventory table above unless a deliberate sample is documented.
