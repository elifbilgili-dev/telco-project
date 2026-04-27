-- SQL QUERY SOLUTIONS FOR TELCO PROJECT
-- Each query includes an explanation of the approach used.
-- The queries are written for Oracle SQL.


-- 1.1 List the customers who are subscribed to the 'Kobiye Destek' tariff.
-- This query joins the CUSTOMERS table with the TARIFFS table by using the TARIFF_ID column.
-- The WHERE condition filters only the tariff named 'Kobiye Destek'.
-- As a result, we can see the customer information together with the tariff name.

SELECT
    c.CUSTOMER_ID,
    c.NAME AS CUSTOMER_NAME,
    c.CITY,
    c.SIGNUP_DATE,
    t.NAME AS TARIFF_NAME
FROM CUSTOMERS c
JOIN TARIFFS t
    ON c.TARIFF_ID = t.TARIFF_ID
WHERE t.NAME = 'Kobiye Destek';


-- 1.2 Find the newest customer who subscribed to this tariff.
-- This query again joins CUSTOMERS and TARIFFS in order to filter customers under the 'Kobiye Destek' tariff.
-- The customers are sorted by SIGNUP_DATE in descending order, so the newest signup appears first.
-- FETCH FIRST 1 ROW ONLY is used to return only the most recent customer.

SELECT
    c.CUSTOMER_ID,
    c.NAME AS CUSTOMER_NAME,
    c.CITY,
    c.SIGNUP_DATE,
    t.NAME AS TARIFF_NAME
FROM CUSTOMERS c
JOIN TARIFFS t
    ON c.TARIFF_ID = t.TARIFF_ID
WHERE t.NAME = 'Kobiye Destek'
ORDER BY c.SIGNUP_DATE DESC
FETCH FIRST 1 ROW ONLY;


-- 2.1 Find the distribution of tariffs among the customers.
-- This query joins CUSTOMERS and TARIFFS by using the TARIFF_ID column.
-- GROUP BY is used to group customers according to their tariff names.
-- COUNT(*) calculates how many customers are subscribed to each tariff.

SELECT
    t.TARIFF_ID,
    t.NAME AS TARIFF_NAME,
    COUNT(c.CUSTOMER_ID) AS CUSTOMER_COUNT
FROM TARIFFS t
LEFT JOIN CUSTOMERS c
    ON t.TARIFF_ID = c.TARIFF_ID
GROUP BY
    t.TARIFF_ID,
    t.NAME
ORDER BY
    CUSTOMER_COUNT DESC;


-- 3.1 Identify the earliest customers to sign up.
-- This query finds the customers with the minimum SIGNUP_DATE in the CUSTOMERS table.
-- The subquery first identifies the earliest signup date in the dataset.
-- Then the main query returns all customers who signed up on that exact earliest date, because there may be more than one earliest customer.

SELECT
    CUSTOMER_ID,
    NAME AS CUSTOMER_NAME,
    CITY,
    SIGNUP_DATE,
    TARIFF_ID
FROM CUSTOMERS
WHERE SIGNUP_DATE = (
    SELECT MIN(SIGNUP_DATE)
    FROM CUSTOMERS
)
ORDER BY
    CUSTOMER_ID;


-- 3.2 Find the distribution of these earliest customers across different cities, including the total count for each city.
-- This query uses the same earliest signup date logic from the previous question.
-- It groups only the earliest customers by their CITY value.
-- COUNT(*) shows how many of the earliest customers are located in each city.

SELECT
    CITY,
    COUNT(*) AS EARLIEST_CUSTOMER_COUNT
FROM CUSTOMERS
WHERE SIGNUP_DATE = (
    SELECT MIN(SIGNUP_DATE)
    FROM CUSTOMERS
)
GROUP BY
    CITY
ORDER BY
    EARLIEST_CUSTOMER_COUNT DESC,
    CITY;


-- 4.1 Identify the IDs of customers whose monthly records are missing.
-- This query searches for customers who exist in the CUSTOMERS table but do not have a matching record in the MONTHLY_STATS table.
-- A LEFT JOIN is used so that all customers are kept in the result, even if there is no monthly usage record for them.
-- The condition ms.CUSTOMER_ID IS NULL filters only the customers whose monthly statistics are missing.

SELECT
    c.CUSTOMER_ID,
    c.NAME AS CUSTOMER_NAME,
    c.CITY,
    c.SIGNUP_DATE,
    c.TARIFF_ID
FROM CUSTOMERS c
LEFT JOIN MONTHLY_STATS ms
    ON c.CUSTOMER_ID = ms.CUSTOMER_ID
WHERE ms.CUSTOMER_ID IS NULL
ORDER BY
    c.CUSTOMER_ID;


-- 4.2 Find the distribution of these missing customers across different cities.
-- This query uses the same LEFT JOIN logic from the previous question to detect missing monthly records.
-- After finding the customers without monthly statistics, it groups them by city.
-- COUNT(*) gives the total number of missing monthly records for each city.

SELECT
    c.CITY,
    COUNT(*) AS MISSING_CUSTOMER_COUNT
FROM CUSTOMERS c
LEFT JOIN MONTHLY_STATS ms
    ON c.CUSTOMER_ID = ms.CUSTOMER_ID
WHERE ms.CUSTOMER_ID IS NULL
GROUP BY
    c.CITY
ORDER BY
    MISSING_CUSTOMER_COUNT DESC,
    c.CITY;


-- 5.1 Find the customers who have used at least 75% of their data limit.
-- This query joins CUSTOMERS, TARIFFS, and MONTHLY_STATS to compare customer usage with tariff limits.
-- DATA_USAGE is compared with 75% of the DATA_LIMIT value from the related tariff.
-- The condition t.DATA_LIMIT > 0 is added to avoid checking tariffs that do not include a data package.

SELECT
    c.CUSTOMER_ID,
    c.NAME AS CUSTOMER_NAME,
    c.CITY,
    t.NAME AS TARIFF_NAME,
    t.DATA_LIMIT,
    ms.DATA_USAGE,
    ROUND((ms.DATA_USAGE / t.DATA_LIMIT) * 100, 2) AS DATA_USAGE_PERCENTAGE
FROM CUSTOMERS c
JOIN TARIFFS t
    ON c.TARIFF_ID = t.TARIFF_ID
JOIN MONTHLY_STATS ms
    ON c.CUSTOMER_ID = ms.CUSTOMER_ID
WHERE
    t.DATA_LIMIT > 0
    AND ms.DATA_USAGE >= t.DATA_LIMIT * 0.75
ORDER BY
    DATA_USAGE_PERCENTAGE DESC;


-- 5.2 Identify the customers who have completely exhausted all of their package limits.
-- This query checks whether each customer's monthly usage is greater than or equal to all limits in their tariff.
-- The customer must reach the data, minute, and SMS limits at the same time to be included in the result.
-- This allows us to identify customers who fully consumed every part of their package.

SELECT
    c.CUSTOMER_ID,
    c.NAME AS CUSTOMER_NAME,
    c.CITY,
    t.NAME AS TARIFF_NAME,
    t.DATA_LIMIT,
    ms.DATA_USAGE,
    t.MINUTE_LIMIT,
    ms.MINUTE_USAGE,
    t.SMS_LIMIT,
    ms.SMS_USAGE
FROM CUSTOMERS c
JOIN TARIFFS t
    ON c.TARIFF_ID = t.TARIFF_ID
JOIN MONTHLY_STATS ms
    ON c.CUSTOMER_ID = ms.CUSTOMER_ID
WHERE
    ms.DATA_USAGE >= t.DATA_LIMIT
    AND ms.MINUTE_USAGE >= t.MINUTE_LIMIT
    AND ms.SMS_USAGE >= t.SMS_LIMIT
ORDER BY
    c.CUSTOMER_ID;


-- 6.1 Find the customers who have unpaid fees.
-- This query joins CUSTOMERS with MONTHLY_STATS to reach the payment status information of each customer.
-- The WHERE condition filters only the records where PAYMENT_STATUS is 'UNPAID'.
-- As a result, the query lists the customers whose monthly fee has not been paid.

SELECT
    c.CUSTOMER_ID,
    c.NAME AS CUSTOMER_NAME,
    c.CITY,
    ms.PAYMENT_STATUS
FROM CUSTOMERS c
JOIN MONTHLY_STATS ms
    ON c.CUSTOMER_ID = ms.CUSTOMER_ID
WHERE
    ms.PAYMENT_STATUS = 'UNPAID'
ORDER BY
    c.CUSTOMER_ID;


-- 6.2 Find the distribution of all payment statuses across the different tariffs.
-- This query joins CUSTOMERS, TARIFFS, and MONTHLY_STATS to analyze payment statuses by tariff.
-- GROUP BY is used with tariff name and payment status to calculate the distribution.
-- COUNT(*) shows how many customers fall into each payment status group for each tariff.

SELECT
    t.TARIFF_ID,
    t.NAME AS TARIFF_NAME,
    ms.PAYMENT_STATUS,
    COUNT(*) AS CUSTOMER_COUNT
FROM CUSTOMERS c
JOIN TARIFFS t
    ON c.TARIFF_ID = t.TARIFF_ID
JOIN MONTHLY_STATS ms
    ON c.CUSTOMER_ID = ms.CUSTOMER_ID
GROUP BY
    t.TARIFF_ID,
    t.NAME,
    ms.PAYMENT_STATUS
ORDER BY
    t.TARIFF_ID,
    ms.PAYMENT_STATUS;