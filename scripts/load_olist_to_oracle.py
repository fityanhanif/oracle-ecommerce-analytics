"""Load Olist CSV files into Oracle staging tables.

Run from project root:
    python scripts/load_olist_to_oracle.py

Connection defaults target local Oracle Free/XE:
    BLAZORD_OLIST@localhost:1521/FREEPDB1
"""

from __future__ import annotations

import csv
import os
from pathlib import Path
from typing import Callable, Iterable

import oracledb

PROJECT_ROOT = Path(__file__).resolve().parents[1]
RAW_DIR = PROJECT_ROOT / "data" / "raw"

USER = os.getenv("OLIST_ORACLE_USER", "BLAZORD_OLIST")
PASSWORD = os.getenv("OLIST_ORACLE_PASSWORD", "BlazordOlist123")
DSN = os.getenv("OLIST_ORACLE_DSN", "localhost:1521/FREEPDB1")
BATCH_SIZE = int(os.getenv("OLIST_LOAD_BATCH_SIZE", "5000"))


def none_if_blank(value: str | None) -> str | None:
    if value is None:
        return None
    value = value.strip()
    return value if value != "" else None


def to_int(value: str | None) -> int | None:
    value = none_if_blank(value)
    return int(value) if value is not None else None


def to_float(value: str | None) -> float | None:
    value = none_if_blank(value)
    return float(value) if value is not None else None


def passthrough(row: dict[str, str], columns: list[str]) -> tuple:
    return tuple(none_if_blank(row.get(c)) for c in columns)


def read_rows(csv_path: Path, mapper: Callable[[dict[str, str]], tuple]) -> Iterable[tuple]:
    with csv_path.open("r", newline="", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        for row in reader:
            yield mapper(row)


def load_table(conn: oracledb.Connection, table: str, csv_name: str, columns: list[str], mapper: Callable[[dict[str, str]], tuple]) -> int:
    path = RAW_DIR / csv_name
    placeholders = ", ".join(f":{i}" for i in range(1, len(columns) + 1))
    column_sql = ", ".join(columns)
    insert_sql = f"INSERT INTO {table} ({column_sql}) VALUES ({placeholders})"

    cur = conn.cursor()
    cur.execute(f"TRUNCATE TABLE {table}")

    total = 0
    batch: list[tuple] = []
    for mapped in read_rows(path, mapper):
        batch.append(mapped)
        if len(batch) >= BATCH_SIZE:
            cur.executemany(insert_sql, batch)
            conn.commit()
            total += len(batch)
            print(f"{table}: loaded {total:,}")
            batch.clear()

    if batch:
        cur.executemany(insert_sql, batch)
        conn.commit()
        total += len(batch)
        print(f"{table}: loaded {total:,}")

    return total


def main() -> None:
    tables = [
        (
            "stg_customers",
            "olist_customers_dataset.csv",
            ["customer_id", "customer_unique_id", "customer_zip_code_prefix", "customer_city", "customer_state"],
            lambda r: (
                none_if_blank(r["customer_id"]),
                none_if_blank(r["customer_unique_id"]),
                to_int(r["customer_zip_code_prefix"]),
                none_if_blank(r["customer_city"]),
                none_if_blank(r["customer_state"]),
            ),
        ),
        (
            "stg_orders",
            "olist_orders_dataset.csv",
            [
                "order_id", "customer_id", "order_status", "order_purchase_timestamp",
                "order_approved_at", "order_delivered_carrier_date",
                "order_delivered_customer_date", "order_estimated_delivery_date",
            ],
            lambda r: passthrough(r, [
                "order_id", "customer_id", "order_status", "order_purchase_timestamp",
                "order_approved_at", "order_delivered_carrier_date",
                "order_delivered_customer_date", "order_estimated_delivery_date",
            ]),
        ),
        (
            "stg_order_items",
            "olist_order_items_dataset.csv",
            ["order_id", "order_item_id", "product_id", "seller_id", "shipping_limit_date", "price", "freight_value"],
            lambda r: (
                none_if_blank(r["order_id"]),
                to_int(r["order_item_id"]),
                none_if_blank(r["product_id"]),
                none_if_blank(r["seller_id"]),
                none_if_blank(r["shipping_limit_date"]),
                to_float(r["price"]),
                to_float(r["freight_value"]),
            ),
        ),
        (
            "stg_order_payments",
            "olist_order_payments_dataset.csv",
            ["order_id", "payment_sequential", "payment_type", "payment_installments", "payment_value"],
            lambda r: (
                none_if_blank(r["order_id"]),
                to_int(r["payment_sequential"]),
                none_if_blank(r["payment_type"]),
                to_int(r["payment_installments"]),
                to_float(r["payment_value"]),
            ),
        ),
        (
            "stg_order_reviews",
            "olist_order_reviews_dataset.csv",
            ["review_id", "order_id", "review_score", "review_comment_title", "review_comment_message", "review_creation_date", "review_answer_timestamp"],
            lambda r: (
                none_if_blank(r["review_id"]),
                none_if_blank(r["order_id"]),
                to_int(r["review_score"]),
                none_if_blank(r["review_comment_title"]),
                none_if_blank(r["review_comment_message"]),
                none_if_blank(r["review_creation_date"]),
                none_if_blank(r["review_answer_timestamp"]),
            ),
        ),
        (
            "stg_products",
            "olist_products_dataset.csv",
            [
                "product_id", "product_category_name", "product_name_lenght", "product_description_lenght",
                "product_photos_qty", "product_weight_g", "product_length_cm", "product_height_cm", "product_width_cm",
            ],
            lambda r: (
                none_if_blank(r["product_id"]),
                none_if_blank(r["product_category_name"]),
                to_int(r["product_name_lenght"]),
                to_int(r["product_description_lenght"]),
                to_int(r["product_photos_qty"]),
                to_int(r["product_weight_g"]),
                to_int(r["product_length_cm"]),
                to_int(r["product_height_cm"]),
                to_int(r["product_width_cm"]),
            ),
        ),
        (
            "stg_sellers",
            "olist_sellers_dataset.csv",
            ["seller_id", "seller_zip_code_prefix", "seller_city", "seller_state"],
            lambda r: (
                none_if_blank(r["seller_id"]),
                to_int(r["seller_zip_code_prefix"]),
                none_if_blank(r["seller_city"]),
                none_if_blank(r["seller_state"]),
            ),
        ),
        (
            "stg_geolocation",
            "olist_geolocation_dataset.csv",
            ["geolocation_zip_code_prefix", "geolocation_lat", "geolocation_lng", "geolocation_city", "geolocation_state"],
            lambda r: (
                to_int(r["geolocation_zip_code_prefix"]),
                to_float(r["geolocation_lat"]),
                to_float(r["geolocation_lng"]),
                none_if_blank(r["geolocation_city"]),
                none_if_blank(r["geolocation_state"]),
            ),
        ),
        (
            "stg_category_translation",
            "product_category_name_translation.csv",
            ["product_category_name", "product_category_name_english"],
            lambda r: passthrough(r, ["product_category_name", "product_category_name_english"]),
        ),
    ]

    print(f"Connecting to Oracle DSN={DSN} USER={USER}")
    with oracledb.connect(user=USER, password=PASSWORD, dsn=DSN) as conn:
        for table, csv_name, columns, mapper in tables:
            total = load_table(conn, table, csv_name, columns, mapper)
            print(f"DONE {table}: {total:,} rows")

    print("All Olist staging tables loaded.")


if __name__ == "__main__":
    main()
