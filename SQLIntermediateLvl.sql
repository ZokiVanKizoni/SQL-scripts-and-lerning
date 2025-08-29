-- Comparison Operators (<,>,<>, <=,>=, !=, =)
SELECT *
FROM customers
WHERE country = 'UK'

SELECT *
FROM customers
WHERE country != 'UK'

SELECT *
FROM customers
WHERE score>500

SELECT *
FROM customers
WHERE score <=750

SELECT *
FROM customers
WHERE id != 9

--Logical operators (NOT, OR, AND)

SELECT *
FROM customers
WHERE country = 'Germany' AND score>=350  --oba uslova mora da ispn

SELECT*
FROM customers
WHERE country = 'uk' OR score <=350 --jedan od dva uslova mora da...

SELECT *
FROM customers
WHERE NOT country = 'USA'

-- BETWEEN Range Operator

SELECT *
FROM customers
WHERE score BETWEEN 350 AND 750 --obuhvata vrednosti <= i >=

--IN and NOT IN lists

SELECT *
FROM customers
WHERE country IN ('UK', 'USA') 

SELECT *
FROM customers
WHERE country NOT IN ('UK', 'USA') --pravi listu i gleda te vrednosti

-- Search Operator LIKE

SELECT *
FROM customers
WHERE first_name LIKE '%A' -- % = Ne zanima te sta se ispred nalazi

SELECT *
FROM customers
WHERE first_name LIKE 'M%'  -- Naveseds filter slovo i % 

SELECT *
FROM customers
WHERE first_name LIKE '_A%' -- _ brojis mesta do trazenog slova

--JOINS in SQL practice
--INNER JOIN search for matching values in both tables

SELECT 
	c.id,
	c.first_name,
	c.country,
	c.score,
	o.order_id,
	o.order_date,
	o.sales
FROM customers AS c 
INNER JOIN orders AS o
ON c.id = o.customer_id
WHERE sales >15

--LEFT JOIN
--uzima levu tabelu kao primarnu i samo zajednicke vrednosti iz desn

SELECT
	customers.id,
	customers.first_name,
	customers.country,
	customers.score,
	orders.order_id,
	orders.order_date,
	orders.sales
FROM customers
left JOIN orders
ON customers.id = orders.order_id

--RIGHT JOIN ista stvar samo posmatra desnu tabelu

SELECT
	customers.id,
	customers.first_name,
	customers.country,
	customers.score,
	orders.order_id,
	orders.order_date,
	orders.sales
FROM customers
RIGHT JOIN orders
ON customers.id = orders.order_id

--FULL JOIN kombinuje sve sto se nalazi u obe tabele

SELECT
	customers.id,
	customers.first_name,
	customers.country,
	customers.score,
	orders.order_id,
	orders.order_date,
	orders.sales
FROM customers
FULL JOIN orders
ON customers.id = orders.order_id

--Advance type of JOINS
-- LEFT and RIGHT ANTI JOIN

SELECT
	c.id,
	c.first_name,
	c.country,
	c.score,
	o.order_id,
	o.order_date,
	o.sales
FROM customers AS c
LEFT JOIN orders AS o
ON c.id = o.customer_id
WHERE o.customer_id IS NULL

--FULL ANTI JOIN same as FULL JOIN 
-- ovde navodis sve sem zajednickih vrednosti gde god ima NULL

SELECT
	customers.id,
	customers.first_name,
	customers.country,
	customers.score,
	orders.order_id,
	orders.order_date,
	orders.sales
FROM customers
FULL JOIN orders
ON customers.id = orders.order_id
WHERE customer_id IS NULL 
OR	  orders.order_id IS NULL

SELECT *
FROM customers
FULL JOIN orders
ON id = customer_id
WHERE order_id IS NOT NULL

-- CROSS JOIN kombinuje sve vrednosti sa svakom u tabeli
--sve sa svim

SELECT
	customers.id,
	customers.first_name,
	customers.country,
	customers.score,
	orders.order_id,
	orders.order_date,
	orders.sales
FROM orders
CROSS JOIN customers
ORDER BY id ASC

--Task to create table with different columns using Left join

--USE SalesDB

SELECT
	o.OrderID,
	o.Sales,
	c.FirstName AS FirstN,
	c.LastName AS LastN,
	p.Product AS ProductName,
	p.Price,
	e.FirstName AS EmployeeFirstN,
	e.LastName AS EmployeeLastN
FROM Sales.Orders AS o
LEFT JOIN Sales.Customers AS c
ON o.CustomerID = c.CustomerID 
LEFT JOIN Sales.Products AS p
ON o.ProductID = p.ProductID
LEFT JOIN Sales.Employees AS e
ON o.SalesPersonID = e.EmployeeID
