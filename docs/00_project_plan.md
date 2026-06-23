# Oracle E-Commerce Analytics Implementation Plan

> **For Hermes:** Build this project step-by-step. Verify each step with real Oracle output before moving forward.

**Goal:** Build a complete Oracle SQL portfolio project using the Olist e-commerce dataset.

**Architecture:** Raw CSV files are loaded into Oracle staging tables, transformed into relational fact/dimension tables, then exposed through analytics views and optional BI exports.

**Tech Stack:** Oracle Database 23ai Free, SQLPlus/SQLcl, Oracle SQL Developer, SQL, PL/SQL, CSV, optional Python for preprocessing, optional Power BI/dashboard.

---

## Phase 0 — Project Setup

### Task 0.1: Confirm local environment

**Objective:** Verify Oracle and project files exist.

**Files:** none

**Commands:**

```bash
powershell.exe -NoProfile -Command 'Get-Service | Where-Object { $_.Name -match "^Oracle" } | Select Name,Status'
netstat -ano | grep -E ':(1521)[[:space:]]'
```

**Expected:**

- `OracleServiceFREE` running
- `OracleOraDB23Home1TNSListener` running
- port `1521` listening

### Task 0.2: Verify Oracle connection

**Objective:** Confirm admin connection works.

**Command:**

```bash
/c/app/lenovo/product/23ai/dbhomeFree/bin/sqlplus.exe -L system/OraclePass123@localhost:1521/FREEPDB1
```

**Expected:** SQLPlus connects to `FREEPDB1`.

### Task 0.3: Confirm raw data files

**Objective:** Verify all 9 Olist files are present.

**Path:**

```text
C:\Users\lenovo\Projects\oracle-ecommerce-analytics\data\raw
```

**Expected:** 9 CSV files.

---

## Phase 1 — Oracle User & Schema

### Task 1.1: Create project user

**Objective:** Create a dedicated schema instead of using `SYSTEM`.

**File:**

- Create: `sql/01_create_user.sql`

**Planned content:**

```sql
ALTER SESSION SET CONTAINER = FREEPDB1;

CREATE USER BLAZORD_OLIST IDENTIFIED BY BlazordOlist123
  DEFAULT TABLESPACE USERS
  TEMPORARY TABLESPACE TEMP
  QUOTA UNLIMITED ON USERS;

GRANT CREATE SESSION TO BLAZORD_OLIST;
GRANT CREATE TABLE TO BLAZORD_OLIST;
GRANT CREATE VIEW TO BLAZORD_OLIST;
GRANT CREATE PROCEDURE TO BLAZORD_OLIST;
GRANT CREATE SEQUENCE TO BLAZORD_OLIST;
```

**Verification:**

```sql
SELECT username FROM dba_users WHERE username = 'BLAZORD_OLIST';
```

### Task 1.2: Test project user connection

**Objective:** Confirm day-to-day project connection works.

**Command:**

```bash
sqlplus -L BLAZORD_OLIST/BlazordOlist123@localhost:1521/FREEPDB1
```

**Expected:** connected as `BLAZORD_OLIST`.

---

## Phase 2 — Staging Tables

### Task 2.1: Create raw staging tables

**Objective:** Mirror CSV files with Oracle-friendly column names and data types.

**File:**

- Create: `sql/02_create_tables.sql`

**Tables:**

- `stg_customers`
- `stg_orders`
- `stg_order_items`
- `stg_order_payments`
- `stg_order_reviews`
- `stg_products`
- `stg_sellers`
- `stg_geolocation`
- `stg_category_translation`

**Design rule:** Use `VARCHAR2` for raw dates initially, then convert in clean views/tables. This avoids load failures from date-format mismatches.

### Task 2.2: Create row-count validation query

**Objective:** Make sure Oracle row counts match CSV row counts.

**Expected counts:**

- customers: 99,441
- orders: 99,441
- order_items: 112,650
- payments: 103,886
- reviews: 99,224
- products: 32,951
- sellers: 3,095
- geolocation: 1,000,163
- category_translation: 71

---

## Phase 3 — CSV Import

### Task 3.1: Import CSV files

**Objective:** Load Olist CSVs into Oracle staging tables.

**Preferred method:** Oracle SQL Developer Import Data wizard for first version.

**Alternative:** SQLcl `LOAD` command or SQLLoader control files.

**File:**

- Create: `sql/03_load_data_notes.md`

**Verification:** Run `COUNT(*)` on every staging table.

### Task 3.2: Fix common import issues

**Potential issues:**

- blank review title/message fields
- decimal separator handling
- long text review comments
- date columns imported as text
- geolocation file is large and may import slowly

**Rule:** Do not proceed to clean tables until row counts match or any intentional sampling is documented.

---

## Phase 4 — Clean Model & Constraints

### Task 4.1: Create clean dimension/fact tables

**Objective:** Convert raw staging into clean relational tables.

**Core tables:**

- `dim_customer`
- `dim_product`
- `dim_seller`
- `dim_category`
- `dim_geolocation`
- `fact_order`
- `fact_order_item`
- `fact_payment`
- `fact_review`

### Task 4.2: Add constraints

**Objective:** Prove relational modeling skills.

**File:**

- Create: `sql/04_add_constraints.sql`

**Constraints:**

- PK on natural IDs where valid
- FK `fact_order.customer_id -> dim_customer.customer_id`
- FK `fact_order_item.order_id -> fact_order.order_id`
- FK `fact_order_item.product_id -> dim_product.product_id`
- FK `fact_order_item.seller_id -> dim_seller.seller_id`
- FK `fact_payment.order_id -> fact_order.order_id`
- FK `fact_review.order_id -> fact_order.order_id`

### Task 4.3: Add indexes

**Objective:** Improve join and analytics query performance.

**Indexes:**

- order purchase date
- customer ID
- product ID
- seller ID
- order status
- state/category fields

---

## Phase 5 — Analytics Views

### Task 5.1: Build sales views

**Views:**

- `vw_monthly_sales_performance`
- `vw_category_revenue_rank`
- `vw_state_revenue`

**Metrics:**

- total revenue
- freight value
- order count
- item count
- average order value

### Task 5.2: Build delivery views

**Views:**

- `vw_state_delivery_performance`
- `vw_seller_delivery_performance`

**Metrics:**

- average delivery days
- average estimated delivery days
- late delivery count
- late delivery rate

### Task 5.3: Build review/customer views

**Views:**

- `vw_review_delivery_impact`
- `vw_customer_rfm_proxy`
- `vw_seller_scorecard`

**Metrics:**

- average review score
- low-review rate
- repeat-order proxy
- revenue per customer
- seller revenue and complaint score

---

## Phase 6 — PL/SQL Layer

### Task 6.1: Create refresh procedure

**Objective:** Show Oracle-specific PL/SQL, not only generic SQL.

**File:**

- Create: `sql/07_plsql_refresh_package.sql`

**Package idea:**

- `pkg_olist_analytics.refresh_summary_tables`
- `pkg_olist_analytics.validate_row_counts`

### Task 6.2: Create validation output

**Objective:** Make the project reproducible and auditable.

**Output:** table or query showing row count status for all tables.

---

## Phase 7 — Analysis Queries & Findings

### Task 7.1: Write analysis queries

**File:**

- Create: `sql/06_analysis_queries.sql`

**Minimum query set:**

1. monthly revenue trend
2. top 10 product categories by revenue
3. top 10 sellers by revenue
4. states with highest late delivery rate
5. review score distribution
6. payment type breakdown
7. delivery delay vs review score
8. repeat customer proxy

### Task 7.2: Document findings

**File:**

- Create: `docs/06_findings.md`

**Format:**

- Finding
- Evidence query/view
- Business interpretation
- Recommendation

---

## Phase 8 — Portfolio Packaging

### Task 8.1: Create final README

**Objective:** Make the project recruiter-friendly.

**Sections:**

- What this project is
- Dataset overview
- Database architecture
- Key findings
- SQL/Oracle skills demonstrated
- How to run locally
- Limitations

### Task 8.2: Optional dashboard/export

**Objective:** Add BI layer if needed.

**Options:**

- export views to CSV and build Power BI dashboard
- build static HTML/Chart.js dashboard
- keep Oracle SQL-only for first version

### Task 8.3: Final verification checklist

**Must prove:**

- SQL scripts run successfully
- row counts match source files
- views return rows
- analysis queries return business metrics
- README explains limitations honestly

---

## Done Definition

The project is complete when:

- Oracle schema `BLAZORD_OLIST` exists.
- All raw Olist CSVs are loaded or documented if sampled.
- Clean relational model exists with constraints.
- Analytics views return valid metrics.
- At least 8 analysis queries are documented.
- README and docs tell the project story clearly.
- The project can be explained in an interview in under 2 minutes.
