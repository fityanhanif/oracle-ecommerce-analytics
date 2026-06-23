# Data Dictionary

This document defines the raw Olist dataset and the target Oracle model.

## Naming Convention

Raw CSV columns are preserved in staging when possible. Clean tables use consistent snake_case names.

Examples:

- Raw: `product_name_lenght`
- Clean: `product_name_length`
- Raw: `order_purchase_timestamp`
- Clean: `purchase_ts`

## Target Staging Tables

### `stg_customers`

| Column | Type | Description |
|---|---|---|
| `customer_id` | VARCHAR2(50) | Order-level customer ID |
| `customer_unique_id` | VARCHAR2(50) | Unique customer/person proxy |
| `customer_zip_code_prefix` | NUMBER | Customer ZIP prefix |
| `customer_city` | VARCHAR2(100) | Customer city |
| `customer_state` | VARCHAR2(5) | Customer state |

### `stg_orders`

| Column | Type | Description |
|---|---|---|
| `order_id` | VARCHAR2(50) | Order ID |
| `customer_id` | VARCHAR2(50) | Customer ID |
| `order_status` | VARCHAR2(30) | Order lifecycle status |
| `order_purchase_timestamp` | VARCHAR2(30) | Purchase timestamp as raw text |
| `order_approved_at` | VARCHAR2(30) | Approval timestamp as raw text |
| `order_delivered_carrier_date` | VARCHAR2(30) | Carrier handoff timestamp |
| `order_delivered_customer_date` | VARCHAR2(30) | Customer delivery timestamp |
| `order_estimated_delivery_date` | VARCHAR2(30) | Estimated delivery timestamp |

### `stg_order_items`

| Column | Type | Description |
|---|---|---|
| `order_id` | VARCHAR2(50) | Order ID |
| `order_item_id` | NUMBER | Item sequence within order |
| `product_id` | VARCHAR2(50) | Product ID |
| `seller_id` | VARCHAR2(50) | Seller ID |
| `shipping_limit_date` | VARCHAR2(30) | Shipping limit timestamp |
| `price` | NUMBER(12,2) | Item price |
| `freight_value` | NUMBER(12,2) | Freight value |

### `stg_order_payments`

| Column | Type | Description |
|---|---|---|
| `order_id` | VARCHAR2(50) | Order ID |
| `payment_sequential` | NUMBER | Payment sequence |
| `payment_type` | VARCHAR2(30) | Payment method |
| `payment_installments` | NUMBER | Number of installments |
| `payment_value` | NUMBER(12,2) | Payment amount |

### `stg_order_reviews`

| Column | Type | Description |
|---|---|---|
| `review_id` | VARCHAR2(50) | Review ID |
| `order_id` | VARCHAR2(50) | Order ID |
| `review_score` | NUMBER | Score from 1 to 5 |
| `review_comment_title` | VARCHAR2(500) | Review title |
| `review_comment_message` | CLOB | Review message |
| `review_creation_date` | VARCHAR2(30) | Review creation timestamp |
| `review_answer_timestamp` | VARCHAR2(30) | Seller/platform answer timestamp |

### `stg_products`

| Column | Type | Description |
|---|---|---|
| `product_id` | VARCHAR2(50) | Product ID |
| `product_category_name` | VARCHAR2(100) | Portuguese category name |
| `product_name_lenght` | NUMBER | Raw name length field |
| `product_description_lenght` | NUMBER | Raw description length field |
| `product_photos_qty` | NUMBER | Number of product photos |
| `product_weight_g` | NUMBER | Product weight in grams |
| `product_length_cm` | NUMBER | Product length in cm |
| `product_height_cm` | NUMBER | Product height in cm |
| `product_width_cm` | NUMBER | Product width in cm |

### `stg_sellers`

| Column | Type | Description |
|---|---|---|
| `seller_id` | VARCHAR2(50) | Seller ID |
| `seller_zip_code_prefix` | NUMBER | Seller ZIP prefix |
| `seller_city` | VARCHAR2(100) | Seller city |
| `seller_state` | VARCHAR2(5) | Seller state |

### `stg_geolocation`

| Column | Type | Description |
|---|---|---|
| `geolocation_zip_code_prefix` | NUMBER | ZIP prefix |
| `geolocation_lat` | NUMBER | Latitude |
| `geolocation_lng` | NUMBER | Longitude |
| `geolocation_city` | VARCHAR2(100) | City |
| `geolocation_state` | VARCHAR2(5) | State |

### `stg_category_translation`

| Column | Type | Description |
|---|---|---|
| `product_category_name` | VARCHAR2(100) | Portuguese category name |
| `product_category_name_english` | VARCHAR2(100) | English category name |

## Clean Model

### Dimensions

- `dim_customer`: customer attributes and customer unique ID.
- `dim_product`: product attributes with corrected naming and English category.
- `dim_seller`: seller attributes.
- `dim_category`: category lookup table.
- `dim_geolocation`: optional ZIP/city/state reference.

### Facts

- `fact_order`: order header, status, purchase date, delivery dates.
- `fact_order_item`: order item revenue, freight, product, seller.
- `fact_payment`: payment records.
- `fact_review`: review score and comments.

## Derived Metrics

### Sales Metrics

- `gross_item_revenue = SUM(price)`
- `freight_revenue = SUM(freight_value)`
- `total_order_value = SUM(price + freight_value)`
- `avg_order_value = total_order_value / order_count`

### Delivery Metrics

- `delivery_days = delivered_customer_date - purchase_date`
- `estimated_delivery_days = estimated_delivery_date - purchase_date`
- `is_late = delivered_customer_date > estimated_delivery_date`
- `late_delivery_rate = late_orders / delivered_orders`

### Review Metrics

- `avg_review_score = AVG(review_score)`
- `low_review_rate = COUNT(review_score <= 2) / COUNT(review_score)`
- `high_review_rate = COUNT(review_score >= 4) / COUNT(review_score)`

### Customer Proxy Metrics

- `recency = max_purchase_date - customer_last_purchase_date`
- `frequency = COUNT(DISTINCT order_id)` per `customer_unique_id`
- `monetary = SUM(order_value)` per `customer_unique_id`

## Data Caveats

- `customer_id` is order-level; `customer_unique_id` is better for retention proxy.
- Some date fields can be null for canceled/unavailable orders.
- Geolocation is not one-to-one by ZIP prefix.
- Review text is Portuguese, so first version uses numeric review score only.
- Payments can have multiple rows per order.
