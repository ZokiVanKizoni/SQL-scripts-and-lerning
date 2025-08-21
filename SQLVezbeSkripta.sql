-- Retrive All Customer Data

SELECT *
FROM customers

--Retrvie Columns from Data

SELECT 
first_name,
country,
score
from customers 

--Retrive customers that are not equal to 0, and where is
--country = Germany
SELECT *
FROM customers
WHERE score != 0


SELECT *
FROM customers
WHERE country = 'Germany'

-- Sort the result by the score highest first

SELECT *
FROM customers
ORDER BY score DESC

-- Nested Order by functions

SELECT *
FROM customers
order by country ASC, score DESC

--Total score for each country

SELECT
	country,
	sum(score) AS Total_score,
	count (id) AS Total_customers
FROM customers
GROUP BY country

-- Practice

SELECT
	country,
	SUM(score) AS Total_score,
	COUNT(id) AS NumberOfPositins
FROM 
	customers
GROUP BY
	country

--Using two filters get data using Where and Having

SELECT 
	country,
	AVG(score) AS AvgScore
FROM 
	customers
WHERE 
	score != 0
GROUP BY 
	country
HAVING 
	avg(score) > 430

--Retrive TOP 3 customers

SELECT TOP 3 *
FROM customers
ORDER BY score ASC

-- Using Distinct

SELECT DISTINCT country
FROM customers

--Static value in query

SELECT 
id,
first_name,
'New Customer' AS Customer_type
FROM customers

--Creating New Table with diferent columns:

CREATE TABLE Persons (
id INT not null,
Person_name VARCHAR(50) NOT NULL,
Birth_date DATE,
Phone VARCHAR(15) NOT NULL,
CONSTRAINT Primarykey_perosns PRIMARY KEY (id) 
)
SELECT * FROM Persons  -- DDL - creating new blank table

-- Add a new column called email to the persons table

ALTER TABLE Persons
ADD email VARCHAR(50) not null
SELECT * FROM Persons

--Remove Column from table:
ALTER TABLE Persons
DROP COLUMN phone
SELECT*FROM Persons

--Drop Table from model
--DROP TABLE Persons

-- Inserting new rows to the table
INSERT INTO customers(id,country, score, first_name)
VALUES 
	(9, 'USA', 14 , 'Boban'),
	(14, 'Mexico', 89, 'Smith')
SELECT * FROM customers

--Insert data from one table to another
INSERT INTO Persons (id, Person_name, Birth_date, email)
SELECT 
	id,
	first_name,
	NULL,
	'Unknown'
FROM customers
SELECT * FROM Persons
SELECT * FROM customers

--New Row in Customers
INSERT INTO customers (id, first_name, country, score)
VALUES 
	( 77, 'Anna', 'Serbia', 99)
SELECT * FROM customers

--Change the score of customer 6 to 0 
UPDATE customers
SET score = 999
WHERE id = 77
SELECT * FROM customers

/*Change the score from customer 14 to 0 and update the country
to UK */

UPDATE customers
SET score = 0, country= 'UK'
WHERE id = 14
SELECT*FROM customers

--Change multiple rows where score is 0 to 50
UPDATE customers
SET score = 50
WHERE score = 0
SELECT * FROM customers




















