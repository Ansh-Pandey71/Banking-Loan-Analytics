CREATE DATABASE banking_analytics;
USE banking_analytics;

-- First Table Customer---
CREATE TABLE customers (
    customer_id VARCHAR(10) PRIMARY KEY,
    customer_name VARCHAR(100),
    gender VARCHAR(10),
    age INT,
    occupation VARCHAR(50),
    annual_income DECIMAL(12,2),
    city VARCHAR(50),
    state VARCHAR(50),
    join_date VARCHAR(20)
);
SELECT COUNT(*) FROM customers;

SET SQL_SAFE_UPDATES = 0;

ALTER TABLE customers
ADD COLUMN new_join_date DATE;

UPDATE customers
SET new_join_date =
STR_TO_DATE(join_date,'%d-%m-%y');

ALTER TABLE customers
DROP COLUMN join_date;

ALTER TABLE customers
CHANGE new_join_date join_date DATE;

SELECT * FROM customers;
-- Second Table Branch--
CREATE TABLE branches (
    branch_id VARCHAR(10) PRIMARY KEY,
    branch_name VARCHAR(100),
    city VARCHAR(50),
    region VARCHAR(20)
);
SELECT COUNT(*) FROM branches;
SELECT * FROM branches;
-- Third Table Loan --
CREATE TABLE loan_types (
    loan_type_id INT PRIMARY KEY,
    loan_type VARCHAR(50)
);
SELECT COUNT(*) FROM loan_types;
SELECT * FROM loan_types;
-- Fourth Table Loan_Details
CREATE TABLE loan_details (
    loan_id VARCHAR(10) PRIMARY KEY,
    customer_id VARCHAR(10),
    branch_id VARCHAR(10),
    loan_type_id INT,
    disbursement_date VARCHAR(20),
    due_date VARCHAR(20),
    loan_amount DECIMAL(15,2),
    interest_rate DECIMAL(5,2),
    emi_amount DECIMAL(15,2),
    paid_amount DECIMAL(15,2),
    outstanding_balance DECIMAL(15,2),
    loan_status VARCHAR(20),
    default_flag VARCHAR(5)
);
SELECT COUNT(*) FROM loan_details;
ALTER TABLE loan_details 
ADD COLUMN new_disbursement_date DATE;

UPDATE loan_details
SET new_disbursement_date = STR_TO_DATE(disbursement_date,'%d-%m-%y');

ALTER TABLE loan_details 
DROP COLUMN disbursement_date;

ALTER TABLE loan_details
CHANGE new_disbursement_date disbursement_date DATE;

ALTER TABLE loan_details 
ADD COLUMN new_due_date DATE;

UPDATE loan_details
SET new_due_date = STR_TO_DATE(due_date,'%d-%m-%y');

ALTER TABLE loan_details 
DROP COLUMN due_date;

ALTER TABLE loan_details
CHANGE new_due_date due_date DATE;

SELECT * FROM loan_details;
-- Five Table Payment--
CREATE TABLE payments (
    payment_id VARCHAR(10) PRIMARY KEY,
    loan_id VARCHAR(10),
    payment_date VARCHAR(20),
    payment_amount DECIMAL(15,2),
    payment_status VARCHAR(20)
);
SELECT COUNT(*) FROM payments;

ALTER TABLE payments
ADD COLUMN new_payment_date DATE;

UPDATE payments
SET new_payment_date = STR_TO_DATE(payment_date,'%d-%m-%y');

ALTER TABLE payments
DROP COLUMN payment_date;

ALTER TABLE payments
CHANGE new_payment_date payment_date DATE;

SELECT * FROM payments;

-- Add Foreign Keys
-- Add first key cust to loan_details
ALTER TABLE loan_details
ADD CONSTRAINT fk_customer
FOREIGN KEY (customer_id)
REFERENCES customers(customer_id);

-- Second key branches to loan_details
ALTER TABLE loan_details
ADD CONSTRAINT fk_branch
FOREIGN KEY (branch_id)
REFERENCES branches(branch_id);

-- Third key loan_type to loan_details
ALTER TABLE loan_details
ADD CONSTRAINT fk_loan_type
FOREIGN KEY (loan_type_id)
REFERENCES loan_types(loan_type_id);

-- Fourth Key loan to payment
ALTER TABLE payments
ADD CONSTRAINT fk_loan
FOREIGN KEY (loan_id)
REFERENCES loan_details(loan_id);