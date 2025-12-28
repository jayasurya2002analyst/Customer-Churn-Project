create database customer_churn_project ;

use customer_churn_project ;

--- SQL Tasks ---

-- (1) Total customers count ? ---

select count(*)
from customer_churn ;

-- (2) Total churned customers ? --

select count(Churn)
from customer_churn
where churn = 'yes' ;

-- (3) Overall churn rate (%) ? --

SELECT 
    CAST(SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS Churn_Rate_Percent
FROM customer_churn;

-- (4) Contract-wise churn rate ? --
select
       contract,
       cast(sum(case when churn = 'yes' then 1 else 0 end) * 100.0/count(*) as decimal(5,2)) as churn_rate_percent
from customer_churn
group by Contract
order by churn_rate_percent desc ;

-- (5) Average MonthlyCharges (Churn = Yes vs No) ? --

select Churn,
       CAST(avg(MonthlyCharges) AS DECIMAL(10,2)) AS Avg_Month_Charges
FROM customer_churn
group by Churn;


-- (6) Tenure Buckets ? --

SELECT 
    CASE 
        WHEN tenure <= 12 THEN '0-1 Year'
        WHEN tenure > 12 AND tenure <= 24 THEN '1-2 Years'
        WHEN tenure > 24 AND tenure <= 48 THEN '2-4 Years'
        ELSE '4+ Years'
    END AS Tenure_Group,
    COUNT(*) AS Total_Customers,
    CAST(SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS Churn_Rate
FROM customer_churn
GROUP BY 
    CASE 
        WHEN tenure <= 12 THEN '0-1 Year'
        WHEN tenure > 12 AND tenure <= 24 THEN '1-2 Years'
        WHEN tenure > 24 AND tenure <= 48 THEN '2-4 Years'
        ELSE '4+ Years'
    END
ORDER BY Tenure_Group;


-- (7️) High-value customers (MonthlyCharges > average) of churn rate -- 

WITH User_Segments AS (
    SELECT 
        Churn,
        CASE 
            WHEN MonthlyCharges > (SELECT AVG(MonthlyCharges) FROM customer_churn) THEN 'High Value'
            ELSE 'Low Value' 
        END AS Customer_Value
    FROM customer_churn
)
SELECT 
    Customer_Value,
    COUNT(*) AS Total_Customers,
    CAST(SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS Churn_Rate
FROM User_Segments
GROUP BY Customer_Value;