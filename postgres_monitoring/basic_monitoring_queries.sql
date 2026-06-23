/*
PostgreSQL Basic Monitoring Queries
Purpose: simple operational checks for reporting and database support roles.
Run section by section in psql, pgAdmin, DBeaver, or DataGrip.

Safety: read-only queries only. No credentials are stored in this file.
*/

-- 01. Database size summary
SELECT
    current_database() AS database_name,
    pg_size_pretty(pg_database_size(current_database())) AS database_size,
    now() AS checked_at;

-- 02. Largest user tables by total size
SELECT
    schemaname,
    relname AS table_name,
    pg_size_pretty(pg_total_relation_size(relid)) AS total_size,
    pg_size_pretty(pg_relation_size(relid)) AS table_size,
    pg_size_pretty(pg_total_relation_size(relid) - pg_relation_size(relid)) AS index_size,
    n_live_tup AS estimated_live_rows,
    n_dead_tup AS estimated_dead_rows,
    last_vacuum,
    last_autovacuum,
    last_analyze,
    last_autoanalyze
FROM pg_stat_user_tables
ORDER BY pg_total_relation_size(relid) DESC
LIMIT 20;

-- 03. Row-count estimates by reporting table
-- Replace the WHERE filter with your reporting schemas, for example schema IN ('public', 'mart', 'reporting').
SELECT
    schemaname,
    relname AS table_name,
    n_live_tup AS estimated_live_rows,
    n_dead_tup AS estimated_dead_rows,
    ROUND(100.0 * n_dead_tup / NULLIF(n_live_tup + n_dead_tup, 0), 2) AS dead_row_pct
FROM pg_stat_user_tables
WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
ORDER BY n_live_tup DESC;

-- 04. Data freshness check template
-- Replace table and timestamp column names with actual reporting tables.
-- Example assumes a mart table has an updated_at column.
/*
SELECT
    'mart_orders' AS table_name,
    MAX(updated_at) AS latest_updated_at,
    now() - MAX(updated_at) AS data_lag
FROM mart_orders;
*/

-- 05. Active sessions and current queries
SELECT
    pid,
    usename,
    application_name,
    client_addr,
    state,
    wait_event_type,
    wait_event,
    now() - query_start AS query_runtime,
    LEFT(query, 180) AS query_sample
FROM pg_stat_activity
WHERE pid <> pg_backend_pid()
ORDER BY query_runtime DESC NULLS LAST;

-- 06. Blocking and blocked sessions
SELECT
    blocked.pid AS blocked_pid,
    blocked.usename AS blocked_user,
    now() - blocked.query_start AS blocked_runtime,
    LEFT(blocked.query, 160) AS blocked_query,
    blocker.pid AS blocker_pid,
    blocker.usename AS blocker_user,
    now() - blocker.query_start AS blocker_runtime,
    LEFT(blocker.query, 160) AS blocker_query
FROM pg_stat_activity blocked
JOIN pg_locks blocked_locks
    ON blocked_locks.pid = blocked.pid
JOIN pg_locks blocker_locks
    ON blocker_locks.locktype = blocked_locks.locktype
   AND blocker_locks.database IS NOT DISTINCT FROM blocked_locks.database
   AND blocker_locks.relation IS NOT DISTINCT FROM blocked_locks.relation
   AND blocker_locks.page IS NOT DISTINCT FROM blocked_locks.page
   AND blocker_locks.tuple IS NOT DISTINCT FROM blocked_locks.tuple
   AND blocker_locks.virtualxid IS NOT DISTINCT FROM blocked_locks.virtualxid
   AND blocker_locks.transactionid IS NOT DISTINCT FROM blocked_locks.transactionid
   AND blocker_locks.classid IS NOT DISTINCT FROM blocked_locks.classid
   AND blocker_locks.objid IS NOT DISTINCT FROM blocked_locks.objid
   AND blocker_locks.objsubid IS NOT DISTINCT FROM blocked_locks.objsubid
   AND blocker_locks.pid <> blocked_locks.pid
JOIN pg_stat_activity blocker
    ON blocker.pid = blocker_locks.pid
WHERE NOT blocked_locks.granted
  AND blocker_locks.granted;

-- 07. Index usage review
SELECT
    schemaname,
    relname AS table_name,
    indexrelname AS index_name,
    idx_scan,
    idx_tup_read,
    idx_tup_fetch,
    pg_size_pretty(pg_relation_size(indexrelid)) AS index_size
FROM pg_stat_user_indexes
ORDER BY idx_scan ASC, pg_relation_size(indexrelid) DESC
LIMIT 30;

-- 08. Tables with sequential scans that may need review
SELECT
    schemaname,
    relname AS table_name,
    seq_scan,
    seq_tup_read,
    idx_scan,
    n_live_tup AS estimated_live_rows,
    CASE
        WHEN seq_scan > 0 THEN ROUND(seq_tup_read::numeric / seq_scan, 2)
        ELSE 0
    END AS avg_rows_per_seq_scan
FROM pg_stat_user_tables
WHERE n_live_tup > 10000
ORDER BY seq_tup_read DESC
LIMIT 20;

-- 09. Slow query review using pg_stat_statements
-- Requires: CREATE EXTENSION pg_stat_statements; and shared_preload_libraries configured.
/*
SELECT
    calls,
    ROUND(total_exec_time::numeric, 2) AS total_exec_ms,
    ROUND(mean_exec_time::numeric, 2) AS mean_exec_ms,
    ROUND(max_exec_time::numeric, 2) AS max_exec_ms,
    rows,
    LEFT(query, 220) AS query_sample
FROM pg_stat_statements
ORDER BY total_exec_time DESC
LIMIT 20;
*/

-- 10. Basic connection utilization
SELECT
    COUNT(*) AS active_connections,
    (SELECT setting::int FROM pg_settings WHERE name = 'max_connections') AS max_connections,
    ROUND(
        100.0 * COUNT(*) / NULLIF((SELECT setting::int FROM pg_settings WHERE name = 'max_connections'), 0),
        2
    ) AS connection_usage_pct
FROM pg_stat_activity;
