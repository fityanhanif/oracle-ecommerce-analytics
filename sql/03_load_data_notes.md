# CSV Load Notes

This file documents how to load Olist CSV files into Oracle staging tables.

## Preferred First Method: Oracle SQL Developer GUI

Use SQL Developer for the first iteration because it is easier to debug column mapping issues.

Connection details:

```text
Connection name: BLAZORD_OLIST_LOCAL
Username: BLAZORD_OLIST
Password: BlazordOlist123
Hostname: localhost
Port: 1521
Service name: FREEPDB1
```

Raw data path:

```text
C:\Users\lenovo\Projects\oracle-ecommerce-analytics\data\raw
```

## Load Mapping

| CSV file | Target table |
|---|---|
| `olist_customers_dataset.csv` | `stg_customers` |
| `olist_orders_dataset.csv` | `stg_orders` |
| `olist_order_items_dataset.csv` | `stg_order_items` |
| `olist_order_payments_dataset.csv` | `stg_order_payments` |
| `olist_order_reviews_dataset.csv` | `stg_order_reviews` |
| `olist_products_dataset.csv` | `stg_products` |
| `olist_sellers_dataset.csv` | `stg_sellers` |
| `olist_geolocation_dataset.csv` | `stg_geolocation` |
| `product_category_name_translation.csv` | `stg_category_translation` |

## Import Rules

- Delimiter: comma
- Header row: yes
- Encoding: UTF-8
- Empty strings: treat as null
- Date fields: import as text in staging
- Review message: use CLOB
- Decimal fields: use dot decimal separator

## Post-Import Validation

Run row counts immediately after import.

```sql
SELECT 'customers' table_name, COUNT(*) row_count FROM stg_customers
UNION ALL SELECT 'orders', COUNT(*) FROM stg_orders
UNION ALL SELECT 'order_items', COUNT(*) FROM stg_order_items
UNION ALL SELECT 'payments', COUNT(*) FROM stg_order_payments
UNION ALL SELECT 'reviews', COUNT(*) FROM stg_order_reviews
UNION ALL SELECT 'products', COUNT(*) FROM stg_products
UNION ALL SELECT 'sellers', COUNT(*) FROM stg_sellers
UNION ALL SELECT 'geolocation', COUNT(*) FROM stg_geolocation
UNION ALL SELECT 'category_translation', COUNT(*) FROM stg_category_translation;
```

## Expected Row Counts

| Table | Expected rows |
|---|---:|
| `stg_customers` | 99,441 |
| `stg_orders` | 99,441 |
| `stg_order_items` | 112,650 |
| `stg_order_payments` | 103,886 |
| `stg_order_reviews` | 99,224 |
| `stg_products` | 32,951 |
| `stg_sellers` | 3,095 |
| `stg_geolocation` | 1,000,163 |
| `stg_category_translation` | 71 |

## Notes

If SQL Developer import is slow for `stg_geolocation`, postpone that file and complete the main analytics first. Sales, delivery, customer, product, seller, payment, and review analysis can run without geolocation.
