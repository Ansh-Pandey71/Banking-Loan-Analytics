USE banking_analytics;

-- Executive Summary
SELECT
SUM(loan_amount) as total_loan_amt,
ROUND(SUM(loan_amount * interest_rate / 100),2) as estimated_intrest_income,
SUM(paid_amount) as total_paid_amt,
SUM(outstanding_balance) as total_outstanding_balance,
COUNT(loan_id) as total_loans,
COUNT(DISTINCT customer_id) as total_customers,
SUM(CASE WHEN loan_status = 'Active' THEN 1 ELSE 0 END) as Active_loans,
SUM(CASE WHEN loan_status = 'Closed' THEN 1 ELSE 0 END) as Closed_loans,
SUM(CASE WHEN loan_status = 'Defaulted' THEN 1 ELSE 0 END) as defaulted_loans,
ROUND(SUM(CASE WHEN loan_status = 'Defaulted' THEN 1 ELSE 0 END) / COUNT(loan_id)*100.0,1) as default_rate_pct
FROM loan_details;

-- Loan Performnece Analysis
-- Loan Type-wise Total Loan Amount
SELECT lt.loan_type,
SUM(ld.loan_amount) as total_loan_amt 
FROM loan_types lt 
INNER JOIN loan_details ld ON lt.loan_type_id = ld.loan_type_id
GROUP BY lt.loan_type 
Order By total_loan_amt DESC;

-- Loan Type-wise Interest Income
SELECT lt.loan_type,
ROUND(SUM(loan_amount * interest_rate / 100),2) as estimated_intrest_income
FROM loan_types lt 
INNER JOIN loan_details ld ON lt.loan_type_id = ld.loan_type_id
GROUP BY lt.loan_type 
Order By estimated_intrest_income DESC;

-- Loan Type-wise Average Loan Amount
SELECT lt.loan_type,
AVG(ld.loan_amount) as avg_loan_amt 
FROM loan_types lt 
INNER JOIN loan_details ld ON lt.loan_type_id = ld.loan_type_id
GROUP BY lt.loan_type 
Order By avg_loan_amt DESC;

-- Loan Status Distribution
SELECT loan_status,
COUNT(loan_id) as loan_cnt 
FROM loan_details 
GROUP BY loan_status 
Order By loan_cnt DESC;

-- Top 5 Largest Loans
SELECT ld.loan_id,ld.customer_id,lt.loan_type,
ld.loan_amount
FROM loan_types lt 
INNER JOIN loan_details ld ON lt.loan_type_id = ld.loan_type_id
Order By ld.loan_amount DESC
LIMIT 5;

-- Customer Analysis
-- Top 10 Customers by Loan Amount
SELECT c.customer_id,c.customer_name,
SUM(ld.loan_amount) as total_loan_amt 
FROM customers c 
INNER JOIN loan_details ld
ON c.customer_id = ld.customer_id 
GROUP BY c.customer_id,c.customer_name
Order By total_loan_amt DESC 
LIMIT 10; 

-- Customers with Highest Outstanding Balance
SELECT c.customer_id,c.customer_name,
SUM(ld.outstanding_balance) as total_outstanding_balance 
FROM customers c 
INNER JOIN loan_details ld
ON c.customer_id = ld.customer_id 
GROUP BY c.customer_id,c.customer_name
Order By total_outstanding_balance DESC;

-- Customers with Multiple Loans
SELECT c.customer_id,c.customer_name,
COUNT(loan_id) 
FROM customers c 
INNER JOIN loan_details ld
ON c.customer_id = ld.customer_id 
GROUP BY c.customer_id,c.customer_name
HAVING COUNT(loan_id) > 1;

-- Average Loan Amount by Occupation
SELECT c.occupation,
AVG(ld.loan_amount) as avg_loan_amt
FROM customers c 
INNER JOIN loan_details ld
ON c.customer_id = ld.customer_id 
GROUP BY c.occupation;

-- Average Loan Amount by State
SELECT c.state,
AVG(ld.loan_amount) as avg_loan_amt
FROM customers c 
INNER JOIN loan_details ld
ON c.customer_id = ld.customer_id 
GROUP BY c.state;

-- Branch Analysis
-- Branch-wise Loan Amount
SELECT b.branch_name,
SUM(ld.loan_amount) as total_loan_amt
FROM branches b
INNER JOIN loan_details ld ON b.branch_id = ld.branch_id
GROUP BY b.branch_name 
Order By total_loan_amt DESC;

-- Branch-wise Interest Income
SELECT b.branch_name,
ROUND(SUM(ld.loan_amount * ld.interest_rate / 100),2) as intrest_income_amt
FROM branches b
INNER JOIN loan_details ld ON b.branch_id = ld.branch_id
GROUP BY b.branch_name 
Order By intrest_income_amt DESC;

-- Top Performing Branches
SELECT b.branch_name,
SUM(ld.loan_amount) as total_loan_amt
FROM branches b
INNER JOIN loan_details ld ON b.branch_id = ld.branch_id
GROUP BY b.branch_name 
Order By total_loan_amt DESC
LIMIT 5;

-- Region-wise Loan Distribution
SELECT b.region,
SUM(ld.loan_amount) as total_loan_amt
FROM branches b
INNER JOIN loan_details ld ON b.branch_id = ld.branch_id
GROUP BY b.region
Order By total_loan_amt DESC;

-- Region-wise Outstanding Balance
SELECT b.region,
SUM(ld.outstanding_balance) as outstanding_balance_amt
FROM branches b
INNER JOIN loan_details ld ON b.branch_id = ld.branch_id
GROUP BY b.region
Order By outstanding_balance_amt DESC;

-- Branch-wise Average Loan Amount
SELECT b.branch_name,
ROUND(AVG(ld.loan_amount),2) as avg_loan_amt
FROM branches b
INNER JOIN loan_details ld ON b.branch_id = ld.branch_id
GROUP BY b.branch_name 
Order By avg_loan_amt DESC;

-- Branch-wise Total Customers
SELECT b.branch_name,
COUNT(DISTINCT ld.customer_id) as total_cust
FROM branches b
INNER JOIN loan_details ld ON b.branch_id = ld.branch_id
GROUP BY b.branch_name;

-- Payment Analysis
-- Total Payments Received
SELECT SUM(payment_amount) as total_payment FROM payments;

-- Payment Status Distribution
SELECT payment_status,
COUNT(payment_id) as total_payment
FROM payments
GROUP BY payment_status;

-- Monthly Payment Collection
SELECT DATE_FORMAT(payment_date,'%Y-%m') as month_no,
SUM(payment_amount) as total_payment
FROM payments
GROUP BY DATE_FORMAT(payment_date,'%Y-%m')
Order By month_no;

-- Average Payment Amount
SELECT AVG(payment_amount) as avg_payment_amt FROM payments;

-- Loans with Missed Payments
SELECT ld.loan_id,ld.customer_id,ld.loan_amount,
SUM(CASE WHEN p.payment_status = 'Missed' THEN 1 ELSE 0 END) as missed_payment
FROM payments p 
INNER JOIN loan_details ld ON p.loan_id = ld.loan_id
GROUP BY ld.loan_id,ld.customer_id,ld.loan_amount
HAVING missed_payment > 0;

-- Default & Risk Analysis
-- Total Defaulted Loans
SELECT loan_status,
COUNT(loan_id) as total_loans 
FROM loan_details 
WHERE loan_status = 'Defaulted'
GROUP BY loan_status;
-- Default Rate by Region
SELECT b.region,
ROUND(SUM(CASE WHEN loan_status = 'Defaulted' THEN 1 ELSE 0 END)
 / COUNT(loan_id)*100.0,1) as default_rate_pct
FROM branches b 
INNER JOIN loan_details ld ON b.branch_id = ld.branch_id
GROUP BY b.region
Order By default_rate_pct DESC;

-- Default Rate by Loan Type
SELECT lt.loan_type,
ROUND(SUM(CASE WHEN loan_status = 'Defaulted' THEN 1 ELSE 0 END)
 / COUNT(loan_id)*100.0,1) as default_rate_pct
FROM loan_types lt
INNER JOIN loan_details ld ON lt.loan_type_id = ld.loan_type_id
GROUP BY lt.loan_type
Order By default_rate_pct DESC;

-- Default Rate by Branch
SELECT b.branch_name,
ROUND(SUM(CASE WHEN loan_status = 'Defaulted' THEN 1 ELSE 0 END)
 / COUNT(loan_id)*100.0,1) as default_rate_pct
FROM branches b 
INNER JOIN loan_details ld ON b.branch_id = ld.branch_id
GROUP BY b.branch_name
Order By default_rate_pct DESC;

-- Outstanding Balance of Defaulted Loans
SELECT loan_status,
SUM(outstanding_balance) as outstanding_balance
FROM loan_details
GROUP BY loan_status
HAVING loan_status = 'Defaulted';

-- Active vs Closed vs Defaulted
SELECT loan_status,
SUM(loan_amount) as total_loan_amt 
FROM loan_details 
GROUP BY loan_status;

-- Time Series Analysis
-- Monthly Loan Disbursement Trend
SELECT DATE_FORMAT(disbursement_date,'%Y-%m') as month_no,
SUM(loan_amount) as monthly_loan_amt 
FROM loan_details
GROUP BY DATE_FORMAT(disbursement_date,'%Y-%m') 
Order BY month_no;

-- Monthly Loan Growth %
WITH monthly_loan AS ( 
 SELECT DATE_FORMAT(disbursement_date,'%Y-%m') as month_no,
SUM(loan_amount) as total_loan_amt 
FROM loan_details
GROUP BY DATE_FORMAT(disbursement_date,'%Y-%m') 
Order BY month_no
)
SELECT *,
LAG(total_loan_amt) OVER(Order By month_no) as prev_sales,
total_loan_amt - LAG(total_loan_amt) OVER(Order By month_no) as sales_change,
ROUND((total_loan_amt - LAG(total_loan_amt) OVER(Order By month_no))/
LAG(total_loan_amt) OVER(Order By month_no)*100.0,1) as growth_pct
FROM monthly_loan; 

-- Running Loan Portfolio
SELECT loan_id,loan_amount,
SUM(loan_amount) OVER(Order By disbursement_date
ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as running_loan
FROM loan_details;

-- 3-Month Moving Average
WITH monthly_avg AS (
SELECT DATE_FORMAT(disbursement_date,'%Y-%m') as month_no,
SUM(loan_amount) as total_loan_amt 
FROM loan_details
GROUP BY DATE_FORMAT(disbursement_date,'%Y-%m') 
Order BY month_no
)
SELECT *,
ROUND(AVG(total_loan_amt) OVER(Order By month_no
ROWS BETWEEN 2 PRECEDING AND CURRENT ROW),2) as moving_avg 
FROM monthly_avg;

-- Year-wise Loan Growth
WITH YOY AS ( 
SELECT YEAR(disbursement_date) as year_no,
SUM(loan_amount) as total_loan_amt 
FROM loan_details
GROUP BY YEAR(disbursement_date) 
Order BY year_no
)
SELECT *,
LAG(total_loan_amt) OVER(Order By year_no) as prev_sales,
total_loan_amt - LAG(total_loan_amt) OVER(Order By year_no) as sales_change,
ROUND((total_loan_amt - LAG(total_loan_amt) OVER(Order By year_no))/
LAG(total_loan_amt) OVER(Order By year_no)*100.0,1) as growth_pct
FROM YOY; 

-- Advanced SQL
-- Top 3 Customers in Every Region
WITH top_cust AS ( 
SELECT c.customer_name,b.region,
SUM(ld.loan_amount) as total_loan_amt 
FROM customers c 
INNER JOIN loan_details ld ON c.customer_id = ld.customer_id
INNER JOIN branches b ON ld.branch_id = b.branch_id 
GROUP BY c.customer_name,b.region
)SELECT * FROM (
SELECT *,
ROW_NUMBER() OVER(partition by region Order By total_loan_amt DESC) as rn 
FROM top_cust)x
WHERE rn <= 3;

-- Highest Loan in Every Loan Type
WITH high_loan AS ( 
SELECT lt.loan_type,
ld.loan_id,ld.customer_id,
ld.loan_amount
FROM loan_types lt  
INNER JOIN loan_details ld ON lt.loan_type_id = ld.loan_type_id
)SELECT * FROM (
SELECT *,
RANK() OVER(partition by loan_type Order By loan_amount DESC) as rnk
FROM high_loan)x
WHERE rnk = 1;

-- Rank Branches by Loan Amount
WITH branch_rnk AS ( 
SELECT b.branch_name,
SUM(ld.loan_amount) as total_loan_amt 
FROM branches b 
INNER JOIN loan_details ld ON b.branch_id = ld.branch_id
GROUP BY b.branch_name
)
SELECT *,
RANK() OVER(Order By total_loan_amt DESC) as rnk 
FROM branch_rnk;

-- Dense Rank Customers
WITH cust_rnk AS ( 
SELECT c.customer_name,
SUM(ld.loan_amount) as total_loan_amt 
FROM customers c 
INNER JOIN loan_details ld ON c.customer_id = ld.customer_id
GROUP BY c.customer_name
)
SELECT *,
DENSE_RANK() OVER(Order By total_loan_amt DESC) as drnk 
FROM cust_rnk;

-- Running Outstanding Balance
SELECT loan_id,disbursement_date,outstanding_balance,
SUM(outstanding_balance) OVER(Order By disbursement_date
ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as running_balance
FROM loan_details;

-- Business Report
SELECT 
SUM(loan_amount) as total_loan,
ROUND(SUM(loan_amount * interest_rate / 100),2) as estimated_intrest_income,
SUM(outstanding_balance) as outstanding_balance,
COUNT(DISTINCT customer_id) as total_customers,
COUNT(loan_id) as total_loans,
ROUND(SUM(CASE WHEN loan_status = 'Defaulted' THEN 1 ELSE 0 END) / COUNT(loan_id)*100.0,1) as default_pct,
AVG(loan_amount) as avg_loan_amt
FROM loan_details;




