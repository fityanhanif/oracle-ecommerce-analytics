# PostgreSQL Basic Monitoring Add-on

This folder is a small job-description alignment add-on for the Oracle E-Commerce Operations Analytics project. The main project proves Oracle SQL, PL/SQL, data extraction, validation, and dashboard reporting. This folder adds portable PostgreSQL operational monitoring examples for roles that mention PostgreSQL basics.

## What this add-on covers

- Daily database health checks.
- Table size and row-count monitoring.
- Data freshness checks for reporting tables.
- Active session and blocking-query checks.
- Slow-query monitoring through `pg_stat_statements` when enabled.
- Index usage review for tables that support reporting workloads.
- CSV templates for daily, weekly, and monthly reporting routines.

## Files

| File | Purpose |
|---|---|
| `basic_monitoring_queries.sql` | Copy-ready PostgreSQL monitoring queries for psql or SQL clients |
| `daily_report_template.csv` | Daily operational checklist for row counts, freshness, blocking sessions, and slow queries |
| `weekly_report_template.csv` | Weekly review template for table growth, index usage, and query patterns |
| `monthly_report_template.csv` | Monthly summary template for capacity, reliability, and stakeholder reporting |

## How to use

Connect to a PostgreSQL database with `psql`, DBeaver, DataGrip, pgAdmin, or another SQL client, then run the relevant query blocks from:

```text
postgres_monitoring/basic_monitoring_queries.sql
```

Example with `psql`:

```bash
psql "postgresql://USER:PASSWORD@HOST:5432/DBNAME" -f postgres_monitoring/basic_monitoring_queries.sql
```

Do not commit credentials. Use environment variables or a local `.pgpass` file for real systems.

## Interview framing

> My main portfolio project uses Oracle because the role prioritizes Oracle. I also added this PostgreSQL monitoring folder to show that the same database discipline can be applied to PostgreSQL operations: table size checks, row-count checks, freshness checks, active sessions, blocking queries, slow-query review, and simple reporting cadences.

## Mapping to job requirements

| Requirement | Evidence in this repository |
|---|---|
| Strong SQL | Oracle analytics views plus PostgreSQL monitoring SQL |
| Oracle preferred | Full Oracle 23ai schema, views, constraints, indexes, PL/SQL package |
| PostgreSQL basic usage | Monitoring query examples in this folder |
| Database monitoring | Daily, weekly, and monthly report templates |
| Reporting support | Dashboard, SQL views, and CSV-ready monitoring templates |
| Data validation | Oracle load validation plus PostgreSQL row-count and freshness checks |

## Limitations

- The PostgreSQL scripts are portable examples. They are not tied to a live production database in this repository.
- Some queries require PostgreSQL catalog permissions.
- Slow-query analysis requires `pg_stat_statements` to be installed and enabled.
