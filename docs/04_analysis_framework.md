# Analysis Framework

This document defines the analytical storyline for the Oracle Olist project.

## Portfolio Narrative

The project analyzes marketplace operations from four angles:

1. **Commercial Performance** — sales, categories, sellers, states.
2. **Operational Performance** — delivery speed and late delivery risk.
3. **Customer Experience** — review scores and complaint proxy.
4. **Payment Behavior** — payment method and installment behavior.

The goal is not just to write SQL queries. The goal is to show how Oracle can support an end-to-end analytics layer for business decision-making.

## Dashboard / Reporting Pages

### Page 1 — Executive Overview

Main questions:

- How big is the marketplace dataset?
- How much revenue did it generate?
- What is the average review score?
- What share of delivered orders were late?

KPI cards:

- Total Orders
- Total Customers
- Total Sellers
- Total Item Revenue
- Average Review Score
- Late Delivery Rate

Primary view:

```sql
vw_bi_executive_summary
```

### Page 2 — Sales Performance

Main questions:

- Which months generated the most revenue?
- Which categories are the highest revenue drivers?
- Which states are the strongest customer markets?

Views:

- `vw_monthly_sales_performance`
- `vw_category_revenue_rank`
- `vw_state_revenue`

Example metrics:

- monthly revenue
- order count
- item count
- average order value
- freight ratio

### Page 3 — Delivery Operations

Main questions:

- Which states have the worst delivery performance?
- Which sellers have high late delivery rates?
- How does estimated vs actual delivery behave?

Views:

- `vw_state_delivery_performance`
- `vw_seller_delivery_performance`

Example metrics:

- delivered orders
- average delivery days
- average estimated days
- late deliveries
- late delivery rate

### Page 4 — Customer Experience

Main questions:

- How are reviews distributed from 1 to 5?
- Do delayed orders receive lower review scores?
- Which product categories trigger low review rates?

Views:

- `vw_review_distribution`
- `vw_review_delivery_impact`
- `vw_category_review_score`

Example metrics:

- average review score
- count by score
- low-review rate
- review score by delivery status

### Page 5 — Seller & Product Scorecard

Main questions:

- Which sellers generate revenue but have weak customer experience?
- Which categories combine high demand and low satisfaction?
- Which sellers need operational attention?

Views:

- `vw_seller_scorecard`
- `vw_category_scorecard`

Example metrics:

- seller revenue
- seller order count
- average delivery days
- late delivery rate
- average review score
- risk label

### Page 6 — Payment Behavior

Main questions:

- Which payment methods are used most?
- Do installment purchases have higher order values?
- What is the relationship between payment type and revenue?

Views:

- `vw_payment_behavior`
- `vw_installment_value_distribution`

Example metrics:

- payment type share
- average payment value
- average installments
- total payment value

## Suggested Finding Format

Each final finding should be written like this:

```text
Finding: [Specific insight]
Evidence: [Metric and view/query used]
Business meaning: [Why it matters]
Recommendation: [What a business user should do]
```

Example:

```text
Finding: Some high-revenue sellers have below-average review scores and above-average delivery delays.
Evidence: vw_seller_scorecard combines revenue, late delivery rate, and average review score.
Business meaning: Revenue concentration can hide operational risk.
Recommendation: Prioritize seller quality monitoring for high-revenue sellers with late-delivery risk.
```

## Minimum Analysis Query Set

1. Monthly revenue trend
2. Top categories by revenue
3. Top sellers by revenue
4. Revenue by customer state
5. Late delivery rate by state
6. Late delivery rate by seller
7. Review score distribution
8. Delivery delay vs review score
9. Payment type breakdown
10. Installment count vs average order value
11. Customer repeat-order proxy
12. Seller scorecard ranking

## Skills Demonstrated

### Data Engineering

- Structured public CSV files into staging tables.
- Designed clean relational tables.
- Created validation steps for row counts and joins.
- Prepared BI-ready analytics views.

### Data Analysis

- Built KPI logic for revenue, delivery, review, and payment analysis.
- Compared performance across categories, states, sellers, and months.
- Converted raw transactions into business-readable insights.

### Database / Oracle SQL

- Used Oracle Database 23ai Free locally.
- Created schema, tables, constraints, indexes, views, and optional PL/SQL routines.
- Applied date conversion, joins, aggregations, and conditional metrics.

### Business Intelligence

- Designed executive-level reporting views.
- Framed operational risk and customer satisfaction insights.
- Prepared metrics that can feed Power BI or a static dashboard.

## Out of Scope for Version 1

- Full NLP sentiment on Portuguese review text.
- Machine learning prediction.
- Real-time data pipeline.
- Production orchestration.

These can be added later after the Oracle SQL version is complete.
