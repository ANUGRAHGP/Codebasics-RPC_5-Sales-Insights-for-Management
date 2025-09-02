Use gdb023;
Select* from dim_customer;
-- 1.Provide the list of markets in which customer "Atliq Exclusive" operates its business in the APAC region.
Select customer ,region, market
from dim_customer
where customer ="Atliq Exclusive" and region ="APAC";

-- 2.What is the percentage of unique product increase in 2021 vs. 2020?
SELECT 
    COUNT(DISTINCT CASE WHEN fiscal_year = 2020 THEN product_code END) AS unique_products_2020,
    COUNT(DISTINCT CASE WHEN fiscal_year = 2021 THEN product_code END) AS unique_products_2021,
    ROUND(
        (
            (COUNT(DISTINCT CASE WHEN fiscal_year = 2021 THEN product_code END) * 1.0
           - COUNT(DISTINCT CASE WHEN fiscal_year = 2020 THEN product_code END) * 1.0)
            / NULLIF(COUNT(DISTINCT CASE WHEN fiscal_year = 2020 THEN product_code END), 0)
        ) * 100, 2
    ) AS percentage_chg
FROM fact_sales_monthly;

-- 3.Provide a report with all the unique product counts for each segment and sort them in descending order of product counts. 
Select segment,COUNT(DISTINCT product_code) as unique_product_count
from dim_product
group by segment
order by unique_product_count DESC;

-- 4.Follow-up: Which segment had the most increase in unique products in 2021 vs 2020?
SELECT 
    dp.segment,
    COUNT(DISTINCT CASE WHEN fm.fiscal_year = 2020 THEN fm.product_code END) AS unique_products_2020,
    COUNT(DISTINCT CASE WHEN fm.fiscal_year = 2021 THEN fm.product_code END) AS unique_products_2021,
    COUNT(DISTINCT CASE WHEN fm.fiscal_year = 2021 THEN fm.product_code END)
      - COUNT(DISTINCT CASE WHEN fm.fiscal_year = 2020 THEN fm.product_code END) AS difference
FROM fact_sales_monthly AS fm
JOIN dim_product AS dp 
    ON dp.product_code = fm.product_code
GROUP BY dp.segment
ORDER BY difference DESC;

-- 5.Get the products that have the highest and lowest manufacturing costs.
SELECT product_code, product, manufacturing_cost
FROM (
    SELECT 
        fmc.product_code,
        dp.product,
        fmc.manufacturing_cost,
        RANK() OVER (ORDER BY fmc.manufacturing_cost ASC) AS min_rank,
        RANK() OVER (ORDER BY fmc.manufacturing_cost DESC) AS max_rank
    FROM fact_manufacturing_cost AS fmc
    JOIN dim_product AS dp 
        ON dp.product_code = fmc.product_code
) ranked
WHERE min_rank = 1 OR max_rank = 1;

-- 6.Generate a report which contains the top 5 customers who received an
-- average high pre_invoice_discount_pct for the fiscal year 2021 and in the Indian market.
SELECT fpid.customer_code,dc.customer,
ROUND(AVG(pre_invoice_discount_pct)*100,2)  as average_discount_percentage 
from fact_pre_invoice_deductions as fpid
join dim_customer as dc 
on dc.customer_code=fpid.customer_code
where fpid.fiscal_year = 2021 and dc.market = 'India'
group by fpid.customer_code,dc.customer
order by average_discount_percentage DESC
limit 5 ;

-- 7.Get the complete report of the Gross sales amount for the customer “Atliq Exclusive” for each month
SELECT DATE_FORMAT(fm.date, '%b') AS MONTH,fm.fiscal_year as Year, 
ROUND(SUM(fgp.gross_price*fm.sold_quantity),2) AS Gross_Sales_Amount
from fact_sales_monthly as fm
join fact_gross_price as fgp
on fgp.product_code=fm.product_code
join dim_customer as dc
on dc.customer_code=fm.customer_code
where dc.customer = 'Atliq Exclusive'
Group by fm.fiscal_year, MONTH(fm.date),DATE_FORMAT(fm.date, '%b')
ORDER BY fm.fiscal_year,MONTH(fm.date);

-- 8.In which quarter of 2020, got the maximum total_sold_quantity?
SELECT 
    CASE 
        WHEN MONTH(date) BETWEEN 4 AND 6 THEN 'Q1'
        WHEN MONTH(date) BETWEEN 7 AND 9 THEN 'Q2'
        WHEN MONTH(date) BETWEEN 10 AND 12 THEN 'Q3'
        WHEN MONTH(date) BETWEEN 1 AND 3 THEN 'Q4'
    END AS fiscal_quarter,
    SUM(sold_quantity) AS total_sold_quantity
FROM fact_sales_monthly
WHERE fiscal_year = 2020
GROUP BY fiscal_quarter
ORDER BY total_sold_quantity DESC
LIMIT 1;


-- Which channel helped to bring more gross sales in the fiscal year 2021 and the percentage of contribution?
SELECT dc.channel, 
ROUND(SUM(fgp.gross_price*fm.sold_quantity)/1000000,2) AS Gross_Sales_Amount_mln,
ROUND(
        100 * SUM(fgp.gross_price * fm.sold_quantity) 
        / SUM(SUM(fgp.gross_price * fm.sold_quantity)) OVER (), 
        2
    ) AS pct_contribution
from fact_sales_monthly as fm
join fact_gross_price as fgp
on fgp.product_code=fm.product_code
join dim_customer as dc
on dc.customer_code=fm.customer_code
where fm.fiscal_year = 2021
Group by dc.channel
ORDER BY Gross_Sales_Amount_mln DESC;

-- 10. Get the Top 3 products in each division that have a high total_sold_quantity in the fiscal_year 2021? 
WITH ranked_products AS (
    SELECT 
        dp.division,
        fm.product_code,
        dp.product,
        SUM(fm.sold_quantity) AS total_sold_quantity,
        RANK() OVER (
            PARTITION BY dp.division
            ORDER BY SUM(fm.sold_quantity) DESC
        ) AS rank_order
    FROM fact_sales_monthly AS fm
    JOIN dim_product AS dp 
        ON dp.product_code = fm.product_code
    WHERE fm.fiscal_year = 2021
    GROUP BY dp.division, fm.product_code, dp.product
)
SELECT *
FROM ranked_products
WHERE rank_order <= 3
ORDER BY division, rank_order;


