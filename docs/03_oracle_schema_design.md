# Oracle Schema Design

## Schema Name

```sql
BLAZORD_OLIST
```

Use this schema for all project work. Do not use `SYSTEM` except for admin setup.

## Layered Design

```text
CSV files
   ↓
Staging tables: stg_*
   ↓
Clean dimension/fact tables: dim_* and fact_*
   ↓
Analytics views: vw_*
   ↓
BI exports / dashboard / portfolio findings
```

## Entity Relationship Overview

```text
DIM_CUSTOMER 1 ──── * FACT_ORDER 1 ──── * FACT_ORDER_ITEM * ──── 1 DIM_PRODUCT
                         │                         │
                         │                         └──── 1 DIM_SELLER
                         │
                         ├──── * FACT_PAYMENT
                         │
                         └──── * FACT_REVIEW

DIM_PRODUCT * ──── 1 DIM_CATEGORY

DIM_GEOLOCATION is optional/reference by ZIP prefix, city, and state.
```

## Recommended Table Grain

### `dim_customer`

One row per `customer_id`.

Reason: `orders` joins to `customer_id`, not directly to `customer_unique_id`.

### `fact_order`

One row per `order_id`.

Contains:

- `order_id`
- `customer_id`
- order status
- purchase timestamp
- approved timestamp
- delivered carrier timestamp
- delivered customer timestamp
- estimated delivery timestamp
- derived date fields

### `fact_order_item`

One row per `order_id + order_item_id`.

Contains:

- `order_id`
- `order_item_id`
- `product_id`
- `seller_id`
- price
- freight value
- shipping limit timestamp

### `fact_payment`

One row per `order_id + payment_sequential`.

Contains:

- payment type
- installments
- payment value

### `fact_review`

One row per review record.

Contains:

- review score
- optional text fields
- creation and answer timestamps

## Constraint Strategy

Start by loading staging tables without constraints. Add constraints only after row counts and basic data quality checks pass.

### Primary Keys

- `dim_customer(customer_id)`
- `dim_product(product_id)`
- `dim_seller(seller_id)`
- `dim_category(product_category_name)`
- `fact_order(order_id)`
- `fact_order_item(order_id, order_item_id)`
- `fact_payment(order_id, payment_sequential)`
- `fact_review(review_id, order_id)` if review IDs are not globally unique

### Foreign Keys

- `fact_order.customer_id -> dim_customer.customer_id`
- `fact_order_item.order_id -> fact_order.order_id`
- `fact_order_item.product_id -> dim_product.product_id`
- `fact_order_item.seller_id -> dim_seller.seller_id`
- `fact_payment.order_id -> fact_order.order_id`
- `fact_review.order_id -> fact_order.order_id`
- `dim_product.product_category_name -> dim_category.product_category_name`

## Index Strategy

Add indexes after data loading.

Recommended indexes:

```sql
CREATE INDEX idx_fact_order_purchase_date ON fact_order(purchase_date);
CREATE INDEX idx_fact_order_customer ON fact_order(customer_id);
CREATE INDEX idx_order_item_product ON fact_order_item(product_id);
CREATE INDEX idx_order_item_seller ON fact_order_item(seller_id);
CREATE INDEX idx_payment_order ON fact_payment(order_id);
CREATE INDEX idx_review_order ON fact_review(order_id);
CREATE INDEX idx_customer_state ON dim_customer(customer_state);
CREATE INDEX idx_seller_state ON dim_seller(seller_state);
CREATE INDEX idx_product_category ON dim_product(product_category_name);
```

## Date Handling

Olist timestamp format is usually:

```text
YYYY-MM-DD HH24:MI:SS
```

Use Oracle conversion:

```sql
TO_TIMESTAMP(order_purchase_timestamp, 'YYYY-MM-DD HH24:MI:SS')
```

For date-only analytics:

```sql
CAST(TO_TIMESTAMP(order_purchase_timestamp, 'YYYY-MM-DD HH24:MI:SS') AS DATE)
```

Null-safe conversion should be used when creating clean tables because canceled orders can have missing delivery timestamps.

## Clean Table Transformation Pattern

Example pattern:

```sql
CREATE TABLE fact_order AS
SELECT
    order_id,
    customer_id,
    order_status,
    CAST(TO_TIMESTAMP(order_purchase_timestamp, 'YYYY-MM-DD HH24:MI:SS') AS DATE) AS purchase_date,
    CAST(TO_TIMESTAMP(order_approved_at, 'YYYY-MM-DD HH24:MI:SS') AS DATE) AS approved_date,
    CAST(TO_TIMESTAMP(order_delivered_carrier_date, 'YYYY-MM-DD HH24:MI:SS') AS DATE) AS delivered_carrier_date,
    CAST(TO_TIMESTAMP(order_delivered_customer_date, 'YYYY-MM-DD HH24:MI:SS') AS DATE) AS delivered_customer_date,
    CAST(TO_TIMESTAMP(order_estimated_delivery_date, 'YYYY-MM-DD HH24:MI:SS') AS DATE) AS estimated_delivery_date
FROM stg_orders;
```

If this fails because of blank timestamps, use `NULLIF(column, '')` or a `CASE WHEN column IS NOT NULL THEN ... END` pattern.

## Analytics View Categories

### Executive Summary

- total orders
- total item revenue
- total freight
- total customers
- total sellers
- average review score
- late delivery rate

### Sales

- monthly revenue trend
- category revenue
- seller revenue
- state revenue

### Delivery

- average delivery days
- late delivery rate by state
- late delivery rate by seller
- late delivery rate by category

### Customer Experience

- review distribution
- average review score by delivery status
- low-review rate by state/category/seller

### Payment

- payment type mix
- installment behavior
- payment value distribution

## Portfolio Strength

This design proves Oracle skills because it includes:

- schema isolation
- staging vs clean modeling
- relational joins
- constraints
- indexing
- date transformations
- views
- optional PL/SQL validation
- reporting-ready marts
