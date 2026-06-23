# Findings — First Oracle Analysis Run

This document summarizes the first verified SQL outputs from the Oracle Olist project.

Source output file:

```text
docs/06_analysis_output.txt
```

## 1. Executive Summary

Verified Oracle view: `vw_bi_executive_summary`

Key metrics:

- Total orders: **99,441**
- Total customers: **99,441**
- Total sellers: **3,095**
- Total products: **32,951**
- Total item revenue: **13,591,643.70**
- Total freight value: **2,251,909.54**
- Average review score: **4.09 / 5**
- Late delivery rate: **8.11%**

Business interpretation:

The marketplace has a generally strong customer experience based on average rating, but late delivery still affects a meaningful share of completed orders.

## 2. Sales Performance

Verified Oracle view: `vw_monthly_sales_performance`

Early sales trend shows revenue ramping strongly through 2017. Example monthly revenue:

- January 2017: **137,188.49** total revenue
- March 2017: **432,048.59** total revenue
- May 2017: **586,190.95** total revenue
- September 2017: **720,398.91** total revenue

Business interpretation:

The dataset supports time-series sales analysis, seasonal revenue comparison, and dashboard monthly-trend visuals.

## 3. Top Revenue Categories

Verified Oracle view: `vw_category_revenue_rank`

Top 10 categories by item revenue:

1. `beleza_saude`: **1,263,138.54**
2. `relogios_presentes`: **1,206,075.33**
3. `cama_mesa_banho`: **1,050,936.61**
4. `esporte_lazer`: **993,656.51**
5. `informatica_acessorios`: **919,640.54**
6. `moveis_decoracao`: **736,282.47**
7. `cool_stuff`: **637,258.51**
8. `utilidades_domesticas`: **634,542.60**
9. `automotivo`: **594,363.10**
10. `ferramentas_jardim`: **486,432.45**

Business interpretation:

Revenue is concentrated in a mix of health/beauty, watches/gifts, home, sports, and electronics accessories. These categories should be prioritized in dashboard drilldowns.

## 4. Delivery Risk by State

Verified Oracle view: `vw_state_delivery_performance`

Worst states by late delivery rate, among states with at least 100 delivered orders:

- AL: **23.93%** late delivery rate
- MA: **19.67%**
- PI: **15.97%**
- CE: **15.32%**
- SE: **15.22%**
- BA: **14.04%**
- RJ: **13.47%**
- TO: **12.77%**
- PA: **12.37%**
- ES: **12.23%**

Business interpretation:

Late-delivery risk is geographically uneven. The dashboard should highlight states where logistics performance is materially worse than average.

## 5. Seller Scorecard

Verified Oracle view: `vw_seller_scorecard`

Example high-revenue sellers flagged by risk label:

- `4869f7a5dfa277a7dca6462dcf3b52b2`: WATCHLIST, **229,472.63** revenue, **11.59%** late rate
- `7c67e1448b00f6e969d365cea6b010ab`: HIGH_RISK, **189,417.67** revenue, avg review score **3.35**
- `4a3ca9315b744ce9f8e9374361493884`: WATCHLIST, **202,999.12** revenue, avg review score **3.80**

Business interpretation:

Some sellers generate strong revenue but also carry operational or customer-experience risk. This is a strong portfolio insight because it connects commercial performance with operational quality.

## 6. Customer Repeat Proxy

Verified Oracle view: `vw_customer_rfm_proxy`

Customer groups:

- One-time customers: **92,507** customers, average monetary value **161.49**
- Repeat customers: **2,913** customers, average frequency **2.11**, average monetary value **310.49**

Business interpretation:

Most customers appear as one-time buyers. Repeat customers spend more on average, so retention analysis could be a valuable extension.

## 7. Payment Behavior

Verified Oracle view: `vw_payment_behavior`

Payment value by type:

- Credit card: **12,542,084.20**, average installments **3.51**
- Boleto: **2,869,361.27**
- Voucher: **379,436.87**
- Debit card: **217,989.79**

Business interpretation:

Credit card dominates transaction value and installment behavior. This can support a dashboard section about customer payment preferences.

## 8. Delivery Delay vs Review Score

Verified Oracle view: `vw_review_delivery_impact`

Comparison:

- On-time / not late orders:
  - Avg delivery days: **10.89**
  - Avg review score: **4.21**
  - Low-review rate: **11.38%**
- Late orders:
  - Avg delivery days: **31.53**
  - Avg review score: **2.57**
  - Low-review rate: **54.02%**

Business interpretation:

Late delivery has a very clear negative relationship with review score. This is the strongest first finding: delayed orders are much more likely to receive poor customer reviews.

## Recommended Portfolio Story

The strongest project narrative is:

> This Oracle project shows how marketplace data can be modeled into a relational database and converted into operational analytics. The strongest insight is that late delivery is strongly associated with lower customer satisfaction: late orders average 2.57 review score and 54.02% low-review rate, compared with 4.21 and 11.38% for non-late orders.

## Next Recommended Work

1. Create a dashboard/export layer from the verified views.
2. Add clean dimension/fact tables if the project needs a stronger warehouse narrative.
3. Add a short PL/SQL validation section to the README.
4. Create screenshots from SQL Developer showing schema, views, and query output.
