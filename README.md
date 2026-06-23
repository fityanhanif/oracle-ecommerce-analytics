# Oracle E-Commerce Operations Analytics

Oracle SQL and PL/SQL portfolio project using the Olist Brazilian E-Commerce public dataset. The project loads 1,553,922 raw CSV rows into Oracle Database 23ai Free, builds relational constraints, creates reporting views, and turns the output into a recruiter-friendly analytics dashboard.

**Author:** Fityan Hanif / Blazord  
**Role focus:** Data Engineering, Data Analysis, Business Intelligence  
**Database:** Oracle Database 23ai Free  
**Schema:** `BLAZORD_OLIST`  
**Live dashboard:** https://oracle-ecommerce-analytics.vercel.app  
**GitHub repository:** https://github.com/fityanhanif/oracle-ecommerce-analytics  

## What this project proves

This is not a notebook-only project. The work is centered on Oracle as a real database layer:

- Designed and loaded a multi-table e-commerce schema in Oracle.
- Validated 9 raw staging tables against CSV-aware row counts.
- Added primary key, foreign key, check, and join-performance indexes.
- Created 9 SQL views for sales, seller, delivery, payment, review, and customer analysis.
- Built a PL/SQL validation package to check source load quality.
- Produced a static dashboard from verified Oracle query results.

## Key findings

1. Late delivery is the strongest customer-experience signal.
   - Late orders average **2.57 / 5** review score.
   - On-time or not-late orders average **4.21 / 5** review score.
   - Low-review rate jumps from **11.38%** to **54.02%** when orders are late.

2. Delivery risk is geographically uneven.
   - AL has the highest late-delivery rate among states with at least 100 delivered orders: **23.93%**.
   - MA follows at **19.67%**.
   - Several high-volume states still exceed the marketplace average of **8.11%**.

3. Seller quality is not the same as seller revenue.
   - Some high-revenue sellers are flagged as `WATCHLIST` or `HIGH_RISK` because review score and late rate are weaker than revenue alone suggests.
   - This is useful for marketplace operations because it separates commercial value from customer-experience risk.

4. Repeat customers spend more, but they are a small group.
   - One-time customers: **92,507**.
   - Repeat customers: **2,913**.
   - Repeat customers have higher average monetary value: **310.49** vs **161.49**.

## Executive metrics

| Metric | Value |
|---|---:|
| Total orders | 99,441 |
| Total customers | 99,441 |
| Total sellers | 3,095 |
| Total products | 32,951 |
| Total item revenue | 13,591,643.70 |
| Total freight value | 2,251,909.54 |
| Average review score | 4.09 / 5 |
| Late delivery rate | 8.11% |

## Dataset inventory

| Source file | Rows loaded | Role |
|---|---:|---|
| `olist_customers_dataset.csv` | 99,441 | Customer dimension |
| `olist_orders_dataset.csv` | 99,441 | Order header fact |
| `olist_order_items_dataset.csv` | 112,650 | Order item fact |
| `olist_order_payments_dataset.csv` | 103,886 | Payment fact |
| `olist_order_reviews_dataset.csv` | 99,224 | Review fact |
| `olist_products_dataset.csv` | 32,951 | Product dimension |
| `olist_sellers_dataset.csv` | 3,095 | Seller dimension |
| `olist_geolocation_dataset.csv` | 1,000,163 | Location reference |
| `product_category_name_translation.csv` | 71 | Category lookup |

Note: the review CSV contains quoted multiline text fields. Shell line counts overstate the row count. The verified CSV-aware and Oracle-loaded count is **99,224**.

## Database objects

Verified Oracle object status:

| Object type | Status | Count |
|---|---|---:|
| Table | Valid | 9 |
| View | Valid | 9 |
| Package | Valid | 1 |
| Package body | Valid | 1 |
| Index | Valid | 17 |
| Constraint | Valid | 13 |

## Analytics views

| View | Purpose |
|---|---|
| `VW_BI_EXECUTIVE_SUMMARY` | Single-row executive KPI summary |
| `VW_MONTHLY_SALES_PERFORMANCE` | Monthly sales and freight trend |
| `VW_CATEGORY_REVENUE_RANK` | Category revenue leaderboard |
| `VW_STATE_DELIVERY_PERFORMANCE` | Delivery performance by customer state |
| `VW_SELLER_SCORECARD` | Seller revenue, delivery, review, and risk label |
| `VW_CUSTOMER_RFM_PROXY` | Simple one-time vs repeat customer segmentation |
| `VW_PAYMENT_BEHAVIOR` | Payment value and installment analysis |
| `VW_REVIEW_DELIVERY_IMPACT` | Delivery delay vs review-score relationship |
| `VW_ORDER_ENRICHED` | Order-level joined base view for analysis |

## Tech stack

| Layer | Tools | Why |
|---|---|---|
| Database | Oracle Database 23ai Free | Shows real Oracle SQL, schema design, and PL/SQL workflow |
| SQL | Views, constraints, indexes | Rebuildable analytics layer, not one-off spreadsheet work |
| PL/SQL | Validation package | Demonstrates Oracle procedural logic and data quality checks |
| Python | `oracledb`, CSV loader | Repeatable ingestion from raw CSV into Oracle |
| Frontend | Static HTML, CSS, JavaScript, Chart.js | Free hosting, fast load, simple deployment to Vercel |
| Documentation | Markdown | Recruiter-readable methodology, limitations, and findings |

## Repository structure

```text
oracle-ecommerce-analytics/
├── index.html                         # Static dashboard for Vercel
├── README.md                          # Portfolio README
├── vercel.json                        # Static deployment config
├── data/
│   └── raw/                           # Original Olist CSV files
├── docs/
│   ├── 00_project_plan.md
│   ├── 01_data_profile.md
│   ├── 02_data_dictionary.md
│   ├── 03_oracle_schema_design.md
│   ├── 04_analysis_framework.md
│   ├── 05_runbook.md
│   ├── 06_analysis_output.txt
│   ├── 06_findings.md
│   └── cv_portfolio_summary.md
├── scripts/
│   └── load_olist_to_oracle.py
└── sql/
    ├── 01_create_user.sql
    ├── 02_create_tables.sql
    ├── 04_add_constraints.sql
    ├── 05_create_views.sql
    ├── 06_analysis_queries.sql
    └── 07_plsql_refresh_package.sql
```

## How to run locally

### 1. Prepare Oracle

Install Oracle Database 23ai Free and create the project schema:

```sql
@sql/01_create_user.sql
```

### 2. Create tables

```sql
@sql/02_create_tables.sql
```

### 3. Load raw CSV files

Install the Python dependency:

```bash
python -m pip install oracledb
```

Run the loader from the repository root:

```bash
python scripts/load_olist_to_oracle.py
```

### 4. Add constraints, views, and PL/SQL

```sql
@sql/04_add_constraints.sql
@sql/05_create_views.sql
@sql/07_plsql_refresh_package.sql
```

### 5. Run the analysis queries

```sql
@sql/06_analysis_queries.sql
```

The verified output from the first run is saved in:

```text
docs/06_analysis_output.txt
```

### 6. Run the dashboard locally

```bash
python -m http.server 8000
```

Open:

```text
http://localhost:8000
```

## Skills demonstrated

### Data Engineering

Built a repeatable ingestion path from raw public CSV files into Oracle staging tables, including CSV-aware validation for multiline review text and load-count checks across 1.5M+ rows.

### Data Analysis

Created SQL views and queries to analyze revenue, delivery risk, customer review outcomes, payment behavior, product category performance, and seller scorecards.

### Business Intelligence

Translated Oracle query outputs into executive KPIs, risk labels, dashboard sections, and portfolio-ready recommendations for marketplace operations.

### Database Development

Used Oracle Database 23ai Free, SQL constraints, indexes, views, and PL/SQL package logic to show database skills beyond basic SELECT statements.

## Limitations

- The dataset is public and anonymized, not a live production marketplace feed.
- The data represents a Brazilian marketplace, so the business pattern should not be generalized directly to Indonesian e-commerce without local validation.
- Review text is mostly Portuguese. This version focuses on Oracle operations analytics, not NLP sentiment analysis.
- Customer repeat behavior is a proxy because the public dataset uses anonymized customer identifiers.
- The dashboard is static by design. It uses verified Oracle outputs, not a live database connection.

## Interview summary

> I built an Oracle Database analytics project using 1.5M+ public e-commerce rows. I created staging tables, constraints, indexes, SQL views, and a PL/SQL validation package, then converted the Oracle outputs into a BI-style dashboard. The strongest insight is that late delivery is strongly associated with poor customer experience: late orders average 2.57 review score and 54.02% low-review rate, compared with 4.21 and 11.38% for non-late orders.

## Author

Fityan Hanif / Blazord  
Data Scientist and analytics portfolio builder  
