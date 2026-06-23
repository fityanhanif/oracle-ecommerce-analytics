# Runbook — Oracle Olist Project

This runbook is the execution checklist from raw data to final portfolio package.

## 0. Paths

Project:

```text
C:\Users\lenovo\Projects\oracle-ecommerce-analytics
```

Oracle SQLPlus:

```text
C:\app\lenovo\product\23ai\dbhomeFree\bin\sqlplus.exe
```

Oracle SQL Developer:

```text
C:\Users\lenovo\Apps\Oracle\SQLDeveloper\sqldeveloper\sqldeveloper.exe
```

Raw data:

```text
C:\Users\lenovo\Projects\oracle-ecommerce-analytics\data\raw
```

## 1. Check Oracle Status

```bash
powershell.exe -NoProfile -Command 'Get-Service | Where-Object { $_.Name -match "^Oracle" } | Select Name,Status'
netstat -ano | grep -E ':(1521)[[:space:]]'
```

Expected:

- `OracleServiceFREE` is `Running`
- `OracleOraDB23Home1TNSListener` is `Running`
- port `1521` is listening

## 2. Admin Connection Test

```bash
/c/app/lenovo/product/23ai/dbhomeFree/bin/sqlplus.exe -L system/OraclePass123@localhost:1521/FREEPDB1
```

Inside SQLPlus:

```sql
SELECT sys_context('USERENV','DB_NAME') AS db_name,
       sys_context('USERENV','CON_NAME') AS con_name
FROM dual;
```

Expected:

```text
FREEPDB1 / FREEPDB1
```

## 3. Create Project User

Run:

```bash
/c/app/lenovo/product/23ai/dbhomeFree/bin/sqlplus.exe system/OraclePass123@localhost:1521/FREEPDB1 @sql/01_create_user.sql
```

Then test:

```bash
/c/app/lenovo/product/23ai/dbhomeFree/bin/sqlplus.exe -L BLAZORD_OLIST/BlazordOlist123@localhost:1521/FREEPDB1
```

## 4. Create Tables

Run:

```bash
/c/app/lenovo/product/23ai/dbhomeFree/bin/sqlplus.exe BLAZORD_OLIST/BlazordOlist123@localhost:1521/FREEPDB1 @sql/02_create_tables.sql
```

Verify:

```sql
SELECT table_name FROM user_tables ORDER BY table_name;
```

## 5. Load CSV Files

Recommended first version: use Oracle SQL Developer Import Data wizard.

Steps:

1. Open Oracle SQL Developer.
2. Create connection:
   - Name: `BLAZORD_OLIST_LOCAL`
   - Username: `BLAZORD_OLIST`
   - Password: `BlazordOlist123`
   - Hostname: `localhost`
   - Port: `1521`
   - Service name: `FREEPDB1`
3. Right-click target staging table.
4. Choose **Import Data**.
5. Select matching CSV from `data/raw`.
6. Confirm delimiter is comma and first row is header.
7. Map columns.
8. Finish import.
9. Repeat for all staging tables.

See:

```text
sql/03_load_data_notes.md
```

## 6. Validate Row Counts

Run:

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

Expected:

- customers: 99,441
- orders: 99,441
- order_items: 112,650
- payments: 103,886
- reviews: 99,224
- products: 32,951
- sellers: 3,095
- geolocation: 1,000,163
- category_translation: 71

## 7. Add Constraints and Indexes

After row counts pass:

```bash
/c/app/lenovo/product/23ai/dbhomeFree/bin/sqlplus.exe BLAZORD_OLIST/BlazordOlist123@localhost:1521/FREEPDB1 @sql/04_add_constraints.sql
```

Verify constraints:

```sql
SELECT constraint_name, table_name, constraint_type, status
FROM user_constraints
ORDER BY table_name, constraint_name;
```

## 8. Create Views

```bash
/c/app/lenovo/product/23ai/dbhomeFree/bin/sqlplus.exe BLAZORD_OLIST/BlazordOlist123@localhost:1521/FREEPDB1 @sql/05_create_views.sql
```

Verify:

```sql
SELECT view_name FROM user_views ORDER BY view_name;
```

## 9. Run Analysis Queries

```bash
/c/app/lenovo/product/23ai/dbhomeFree/bin/sqlplus.exe BLAZORD_OLIST/BlazordOlist123@localhost:1521/FREEPDB1 @sql/06_analysis_queries.sql
```

Save important output into:

```text
docs/06_findings.md
```

## 10. Optional PL/SQL

```bash
/c/app/lenovo/product/23ai/dbhomeFree/bin/sqlplus.exe BLAZORD_OLIST/BlazordOlist123@localhost:1521/FREEPDB1 @sql/07_plsql_refresh_package.sql
```

## 11. Final Project Checklist

- [ ] Oracle services running
- [ ] `BLAZORD_OLIST` schema created
- [ ] 9 staging tables created
- [ ] 9 CSV files imported
- [ ] row counts match source files
- [ ] constraints created
- [ ] indexes created
- [ ] analytics views created
- [ ] analysis queries run
- [ ] findings documented
- [ ] README finalized
- [ ] optional dashboard/BI export created

## Troubleshooting

### SQLPlus cannot connect

Check service and listener:

```bash
powershell.exe -NoProfile -Command 'Get-Service OracleServiceFREE, OracleOraDB23Home1TNSListener'
netstat -ano | grep ':1521'
```

### Import fails because of date columns

Load date columns as text into staging first. Convert dates later in clean tables/views.

### Review comments fail because text is long

Use `CLOB` for `review_comment_message`.

### Geolocation import is slow

This file has 1M rows. It is okay to postpone geolocation import for the first Oracle MVP, as long as the limitation is documented.
