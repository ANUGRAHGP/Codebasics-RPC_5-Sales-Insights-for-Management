# Codebasics-RPC_5-Sales-Insights-for-Management
Sales Insights based on data  extracted from AtliQ  sql database 
SQL Business Analytics Exercises

This repository contains a collection of SQL queries and insights designed to practice solving real-world business problems using structured data from sales, customer, and product tables.

📌 Objectives

Strengthen SQL query writing skills.

Translate business questions into SQL queries.

Analyze sales performance, customer trends, and product demand.

Apply aggregate and window functions to derive business insights.

🗂️ Datasets Used

fact_sales_monthly – monthly sales transactions (date, sold quantity, fiscal year).

fact_gross_price – product pricing details.

fact_pre_invoice_deductions – discount data.

fact_manufacturing_cost – manufacturing costs by product.

dim_customer – customer and market/channel info.

dim_product – product categories and segments.

🔑 Key Learnings

Conditional Aggregation → Using CASE WHEN to compare year-over-year product counts.

Aggregate Functions → SUM(), COUNT(), AVG() for reporting KPIs.

Date Functions → DATE_FORMAT(), MONTH(), QUARTER() to extract months/quarters aligned to fiscal years.

Window Functions → RANK(), ROW_NUMBER(), OVER(PARTITION BY ...) for ranking products within divisions.

Percentage Contribution → Calculating share of sales by channel using SUM() OVER().

Joins → Combining fact and dimension tables to enrich insights.

Ordering & Grouping → Ensuring correct time-series analysis by grouping on fiscal years and months.

📊 Example Business Questions Solved

Which segment saw the highest growth in unique products between 2020 and 2021?

What are the highest and lowest manufacturing cost products?

Who are the Top 5 Indian customers with the highest average discounts in FY21?

Which channel contributed the most to gross sales in FY21 and what was its % share?

Which division’s top 3 products had the highest sales in FY21?

In which quarter of 2020 did we sell the most units?

What is the monthly sales trend for the customer Atliq Exclusive?
