# Olist E-Commerce Performance Dashboard

**An end-to-end analytics project covering SQL data preparation, dimensional data modeling, DAX, and interactive Power BI reporting — built on the public Olist Brazilian E-Commerce dataset.**

![Tools](https://img.shields.io/badge/SQL_Server-T--SQL-blue) ![Tools](https://img.shields.io/badge/Power_BI-Data_Modeling_%7C_DAX-yellow) ![Status](https://img.shields.io/badge/status-complete-brightgreen)

---

## Overview

Olist is a Brazilian e-commerce platform that connects small merchants to major online marketplaces. This project turns Olist's public order-level data (~100K orders, 2016–2018, across multiple Brazilian marketplaces) into a decision-ready reporting tool covering **sales performance, logistics efficiency, and customer satisfaction**.

The workflow follows a realistic analytics pipeline:

1. **SQL Server** — explore the raw relational tables and validate data quality before trusting them
2. **Power BI (Power Query + Data Model)** — build a clean, relationship-driven data model
3. **DAX** — build a reusable measures layer (28 measures) on top of the model
4. **Power BI Report** — a 5-page interactive report for different stakeholder questions

## Business Questions Answered

- How is revenue trending, and which states and categories drive it?
- Are orders being delivered on time, and where are the delays concentrated?
- How does delivery performance relate to freight cost?
- How satisfied are customers, and which categories generate the most negative reviews?
- Which payment methods and installment patterns do customers use?

## Dataset

[Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) (Kaggle) — real, anonymized commercial data covering ~100K orders placed between 2016 and 2018. Tables used: `orders`, `customers`, `order_items`, `order_payments`, `order_reviews`, `products`, `sellers`, and `product_category_name_translation`.

## Tech Stack

| Layer | Tools |
|---|---|
| Data storage & querying | SQL Server (T-SQL) |
| ETL / transformation | Power Query (M) |
| Data modeling | Power BI Desktop (star-schema relationships) |
| Calculations | DAX |
| Reporting & visualization | Power BI Desktop |

---

## 1. SQL — Data Exploration & Quality Checks

Before any modeling, the raw tables were explored and validated directly in SQL Server. The script (`SQLQuery2.sql`) is organized in two parts:

**Part 1 — Exploration:** row counts and distincts (customer states, delivered vs. total orders), top 10 highest-priced products, transaction counts by payment type, top seller cities, review score distribution, price/freight summary statistics, and orders ranked by installment count.

**Part 2 — Data Quality Checks:**
- Delivered orders with a missing delivery date
- Zero/negative prices or negative freight values
- Discrepancies between the sum of item + freight values and the actual amount paid
- Logically invalid dates (delivery date earlier than purchase or carrier hand-off date)
- Average delivery time vs. the estimated delivery date, to quantify delay
- Revenue ranked by product category and by customer state

This phase also produced a reporting view joining orders to customer location, used as a clean base for downstream analysis:

```sql
CREATE VIEW vw_orders_master AS
SELECT 
    o.order_id, o.customer_id, o.order_status,
    o.order_purchase_timestamp, o.order_delivered_customer_date,
    o.order_estimated_delivery_date,
    c.customer_city, c.customer_state
FROM dbo.orders o
JOIN dbo.customers c ON o.customer_id = c.customer_id;
```

## 2. Data Model

The Power BI model connects the core Olist entities in a star-schema style layout, with `orders` at the center and `customers`, `order_items`, `order_payments`, `order_reviews`, `products` (translated to English category names via `product_category_name_translation`), and `sellers` as supporting tables — plus a standalone Date Hierarchy used for all time-based analysis.

## 3. DAX Measures

A dedicated measures table (`Measures_`) holds **28 DAX measures**, grouped into three families that map directly to the report's three analytical pillars:

| Sales & Revenue | Logistics & Delivery | Customer Satisfaction |
|---|---|---|
| Total Revenue | AVG Delivery Days | Avg Review Score |
| Total Orders | AVG Estimated Delivery Days | Total Reviews |
| Total Customers | ON-Time Delivery Rate | Positive Reviews |
| Total Items | Total Freight | Negative Reviews |
| | Late Deliveries Count | Positive Review Rate |
| | | Negative Review Rate |

## 4. Report — 5 Pages

| Page | Purpose |
|---|---|
| **Welcome Page** | Landing/navigation page with a top-line summary of each section (logistics, payments, top categories, customer experience) plus a monthly revenue & order volume chart |
| **Executive Overview** | KPI cards (revenue, orders, customers, delivery days, review score), revenue trend over time, review score & payment-type breakdowns, revenue by category and by state, with state/payment/review/year slicers |
| **Sales & Product** | Category-level performance: revenue by category, a review-score-vs-revenue ribbon chart, a category summary table, and freight cost by category |
| **Logistics & Operation** | Actual vs. estimated delivery time trend, order status breakdown, a delivery-time-vs-freight scatter plot by state, and on-time delivery / late order KPIs |
| **Customer Experience & Reviews** | Positive vs. negative review split, review-score distribution, and a category-level table of review and on-time rates |

---

## Repository Structure

```
├── olist.pbix          # Final Power BI file (data model + report)
├── SQLQuery2.sql        # SQL exploration & data quality checks
└── README.md
```

## Skills Demonstrated

`SQL (T-SQL)` · `Data Quality Auditing` · `Data Modeling` · `DAX` · `Power BI Report Design` · `Business/Stakeholder Analysis`

## Author

**Mostafa Saber** — Data Analyst
🔗 [LinkedIn](#) · [GitHub](#)
