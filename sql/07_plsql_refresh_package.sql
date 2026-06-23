-- 07_plsql_refresh_package.sql
-- Optional PL/SQL package for validation and portfolio Oracle-specific demonstration.

SET ECHO ON
SET SERVEROUTPUT ON

CREATE OR REPLACE PACKAGE pkg_olist_analytics AS
  PROCEDURE validate_row_counts;
END pkg_olist_analytics;
/

CREATE OR REPLACE PACKAGE BODY pkg_olist_analytics AS
  PROCEDURE validate_row_counts IS
  BEGIN
    DBMS_OUTPUT.PUT_LINE('Olist staging row-count validation');

    FOR r IN (
      SELECT 'stg_customers' table_name, COUNT(*) actual_count, 99441 expected_count FROM stg_customers
      UNION ALL SELECT 'stg_orders', COUNT(*), 99441 FROM stg_orders
      UNION ALL SELECT 'stg_order_items', COUNT(*), 112650 FROM stg_order_items
      UNION ALL SELECT 'stg_order_payments', COUNT(*), 103886 FROM stg_order_payments
      UNION ALL SELECT 'stg_order_reviews', COUNT(*), 99224 FROM stg_order_reviews
      UNION ALL SELECT 'stg_products', COUNT(*), 32951 FROM stg_products
      UNION ALL SELECT 'stg_sellers', COUNT(*), 3095 FROM stg_sellers
      UNION ALL SELECT 'stg_geolocation', COUNT(*), 1000163 FROM stg_geolocation
      UNION ALL SELECT 'stg_category_translation', COUNT(*), 71 FROM stg_category_translation
    ) LOOP
      DBMS_OUTPUT.PUT_LINE(
        RPAD(r.table_name, 28) ||
        ' actual=' || LPAD(r.actual_count, 10) ||
        ' expected=' || LPAD(r.expected_count, 10) ||
        ' status=' || CASE WHEN r.actual_count = r.expected_count THEN 'OK' ELSE 'CHECK' END
      );
    END LOOP;
  END validate_row_counts;
END pkg_olist_analytics;
/

SHOW ERRORS PACKAGE pkg_olist_analytics
SHOW ERRORS PACKAGE BODY pkg_olist_analytics

BEGIN
  pkg_olist_analytics.validate_row_counts;
END;
/
