--Ovo je nestovanje tj.redjanje više SQL upita u jedan korsiti se filter Where sa Exists, i u zagradi definiše upit

SELECT *
FROM Sales.Orders AS o
WHERE EXISTS ( 
				SELECT 1
				FROM Sales.Customers AS c
				WHERE Country= 'Germany'
				AND o.CustomerID = c.CustomerID)
--SUBQUERY
---Takodje moze se koristiti i obrnuta logika NOT EXIST, mora se kao u JOIN spajati sa ključevima

SELECT *
FROM Sales.Orders AS o
WHERE NOT EXISTS ( 
				SELECT 1
				FROM Sales.Customers AS c
				WHERE Country= 'Germany'
				AND o.CustomerID = c.CustomerID)

-- Sada prelazimo na rad sa CTE upitima

WITH CTETotalSales AS
(
	SELECT 
		CustomerID,
		SUM(Sales) AS TotalSales
	FROM SalesDB.Sales.Orders
	GROUP BY CustomerID
)

, CTESecondName AS
(
	SELECT
		CustomerID,
		MAX(OrderDate) AS MaxOrder
	FROM SalesDB.Sales.Orders
	Group BY CustomerID

)

SELECT
	c.CustomerID,
	c.FirstName,
	c.LastName,
	cts.TotalSales,
	cts.CustomerID
	,sc.MaxOrder
FROM SalesDB.Sales.Customers AS c
left join CTETotalSales AS cts ON
cts.CustomerID=c.CustomerID
left join CTESecondName AS clo ON
clo.CustomerID=c.CustomerID
left join CTESecondName AS sc ON
clo.CustomerID = sc.CustomerID


--Nestovanje CTE jedan CTE pa jos CTE u njemu - tako sto se pozivas samo u FROM na prethodni CTE i tako ih nestujes
-- spajaš ih JOIN opcijama
--CTAS i TEMP
-- Primer pravljenja DDL upita gde kreiramo novu tabelu preko INTO funkcije i zatim uzimamo sve
SELECT
DATENAME(MONTH, OrderDate) OrderMonth,
COUNT(OrderID) TotalOrders
INTO Sales.MontlyOrders
FROM SalesDB.sales.Orders
GROUP BY DATENAME(month,OrderDate)

SELECT * FROM SalesDB.Sales.MontlyOrders

DROP TABLE SalesDB.Sales.MontlyOrders --mozemo je obrisati

-- koriscenjem T-SQL mozemo preko IF da refresujemo podatke tako sto cemo odbacivati stari i nadovezivati novi upit

IF OBJECT_ID('Sales.MontlyOrders', 'U') IS NOT NULL 
	DROP TABLE Sales.MontlyOrders;
	GO --kako bi izvrsio i naredni upit T-SQL

SELECT
DATENAME(MONTH, OrderDate) OrderMonth,
COUNT(OrderID) TotalOrders
INTO Sales.MontlyOrders
FROM SalesDB.sales.Orders
GROUP BY DATENAME(month,OrderDate)

--Pravimo Temp table to jest privremenu tabelu koja ce nestati cim se ugasi softver 

SELECT *
INTO #ORDERS 
FROM SalesDB.Sales.Orders

SELECT * FROM SalesDB.Sales.Orders

DELETE FROM #ORDERS
WHERE OrderStatus = 'Delivered'

-- View je prozor ka podacima koji su azurirani i uvek svezi koriste se jako cesto od strane DB prema ostalim 
-- userima kako ne bi oni njihovim upitima narusili fizicke tabele zato se prave virtuelne tablice pogleda

WITH CTE_Monthly_Summary AS (
SELECT 
DATETRUNC(MONTH, OrderDate) OrderMonth,
SUM(Sales) AS TotalSales,
COUNT(OrderID) AS TotalID,
SUM(Quantity) AS TotalQ
FROM SalesDB.Sales.Orders
GROUP BY DATETRUNC(MONTH, OrderDate)
)
SELECT 
OrderMonth,
TotalSales,
TotalID,
SUM(TotalSales) OVER (ORDER BY OrderMonth) AS RunningTotal
FROM CTE_Monthly_Summary 
--Primer upita koji je tezi i kompleksinji ali koji useri moraju da pisu stalno kako bi
--dobili neke podatke, umesto toga napravicemo VIEW gde user nece morati da pise ili cita logiku iza dobijene tabele
--Ovo gore je trenutno CTE upit koji nestuje upite a napravicemo VIEW


IF OBJECT_ID('VMonthlyView', 'V') IS NOT NULL  -- T-SQL logika petlje preko logike sa zavrsetkom GO da se vrati na SQL
DROP VIEW VMonthlyView ;
GO
Create view VMonthlyView AS
(
	SELECT 
	DATETRUNC(MONTH, OrderDate) OrderMonth,
	SUM(Sales) AS TotalSales,
	COUNT(OrderID) AS TotalID,
	SUM(Quantity) AS TotalQ
	FROM SalesDB.Sales.Orders
	GROUP BY DATETRUNC(MONTH, OrderDate)
)
--Pozivamo VIEW kao najporstiji upit ne znajuci da je privremena tabela napravljena iz kompleksnije logike

SELECT * FROM VMonthlyView

DROP VIEW VMonthlyView

--Kreiranje narednog VIEW radi sagledanja kompleksnosti prvog upita

CREATE VIEW ViewCustomer AS (

SELECT
	o.OrderID,
	o.OrderDate,
	o.Sales,
	o.Quantity,
	p.Product,
	p.Category,
	e.Department,
	COALESCE(e.FirstName, ' ') + ' ' + COALESCE (e.LastName, ' ') AS SalesName,
	c.Country,
	COALESCE(c.FirstName, ' ') + ' ' + COALESCE(c.LastName, ' ') AS CustomerName
FROM SalesDB.Sales.Orders o
LEFT JOIN SalesDB.Sales.Products p
ON p.ProductID = o.ProductID
LEFT JOIN SalesDB.Sales.Customers c
ON c.CustomerID = p.ProductID
LEFT JOIN SalesDB.Sales.Employees e
ON e.EmployeeID = o.SalesPersonID
WHERE c.Country != 'USA'
)

-- pisemo SQL upit kao user da dobijemo tabelu koja nam treba ne znajuci logiku i zastitu iza nje

SELECT * FROM ViewCustomer

--Stored Procedures SP su posebne procedure za definisanje nekih procesa u bazama podataka korsitimo programski SQL

-- Define the Stored Procedure

CREATE PROCEDURE GetCustomerSummary AS
BEGIN
    SELECT
        COUNT(*) AS TotalCustomers,
        AVG(Score) AS AvgScore
    FROM Sales.Customers
    WHERE Country = 'USA';
END
GO

--Procedura se izvrsava pozivanjem iste preko funkcije

EXEC GetCustomerSummary;

--Parametri u okvirima SP

ALTER PROCEDURE GetCustomerSummary @Country NVARCHAR(50) = 'USA' AS
BEGIN
    -- Reports: Summary from Customers and Orders
    SELECT
        COUNT(*) AS TotalCustomers,
        AVG(Score) AS AvgScore
    FROM Sales.Customers
    WHERE Country = @Country;
END
GO

--Execute Stored Procedure
EXEC GetCustomerSummary @Country = 'Germany';
EXEC GetCustomerSummary @Country = 'USA';
EXEC GetCustomerSummary;

-- Edit the Stored Procedure
ALTER PROCEDURE GetCustomerSummary @Country NVARCHAR(50) = 'USA' AS
BEGIN
    -- Query 1: Find the Total Nr. of Customers and the Average Score
    SELECT
        COUNT(*) AS TotalCustomers,
        AVG(Score) AS AvgScore
    FROM Sales.Customers
    WHERE Country = @Country;

    -- Query 2: Find the Total Nr. of Orders and Total Sales
    SELECT
        COUNT(OrderID) AS TotalOrders,
        SUM(Sales) AS TotalSales
    FROM Sales.Orders AS o
    JOIN Sales.Customers AS c
        ON c.CustomerID = o.CustomerID
    WHERE c.Country = @Country;
END
GO

--Execute Stored Procedure
EXEC GetCustomerSummary @Country = 'Germany';
EXEC GetCustomerSummary @Country = 'USA';
EXEC GetCustomerSummary;

-- Edit the Stored Procedure
ALTER PROCEDURE GetCustomerSummary @Country NVARCHAR(50) = 'USA' AS
BEGIN
    -- Declare Variables
    DECLARE @TotalCustomers INT, @AvgScore FLOAT;
                
    -- Query 1: Find the Total Nr. of Customers and the Average Score
    SELECT
		@TotalCustomers = COUNT(*),
		@AvgScore = AVG(Score)
    FROM Sales.Customers
    WHERE Country = @Country;

	PRINT('Total Customers from ' + @Country + ':' + CAST(@TotalCustomers AS NVARCHAR));
	PRINT('Average Score from ' + @Country + ':' + CAST(@AvgScore AS NVARCHAR));

    -- Query 2: Find the Total Nr. of Orders and Total Sales
    SELECT
        COUNT(OrderID) AS TotalOrders,
        SUM(Sales) AS TotalSales
    FROM Sales.Orders AS o
    JOIN Sales.Customers AS c
        ON c.CustomerID = o.CustomerID
    WHERE c.Country = @Country;
END
GO

--Execute Stored Procedure
EXEC GetCustomerSummary @Country = 'Germany';
EXEC GetCustomerSummary @Country = 'USA';
EXEC GetCustomerSummary;


--Primena i upotreba IF ELSE petlji u okvirima SP

ALTER PROCEDURE GetCustomerSummary @Country NVARCHAR(50) = 'USA' AS
BEGIN
	-- Declare Variables
	DECLARE @TotalCustomers INT, @AvgScore FLOAT;     

	/* --------------------------------------------------------------------------
	   Prepare & Cleanup Data
	-------------------------------------------------------------------------- */

	IF EXISTS (SELECT 1 FROM Sales.Customers WHERE Score IS NULL AND Country = @Country)
	BEGIN
		PRINT('Updating NULL Scores to 0');
		UPDATE Sales.Customers
		SET Score = 0
		WHERE Score IS NULL AND Country = @Country;
	END
	ELSE
	BEGIN
		PRINT('No NULL Scores found');
	END;

	/* --------------------------------------------------------------------------
	   Generating Reports
	-------------------------------------------------------------------------- */
	SELECT
		@TotalCustomers = COUNT(*),
		@AvgScore = AVG(Score)
	FROM Sales.Customers
	WHERE Country = @Country;

	PRINT('Total Customers from ' + @Country + ':' + CAST(@TotalCustomers AS NVARCHAR));
	PRINT('Average Score from ' + @Country + ':' + CAST(@AvgScore AS NVARCHAR));

	SELECT
		COUNT(OrderID) AS TotalOrders,
		SUM(Sales) AS TotalSales,
		1/0 AS FaultyCalculation  -- Intentional error for demonstration
	FROM Sales.Orders AS o
	JOIN Sales.Customers AS c
		ON c.CustomerID = o.CustomerID
	WHERE c.Country = @Country;
END
GO

--Execute Stored Procedure
EXEC GetCustomerSummary @Country = 'Germany';
EXEC GetCustomerSummary @Country = 'USA';
EXEC GetCustomerSummary;


-- Rad sa Eror porukama kako da se hendluju i upotreba TRY i CATCH funkcija i metoda rada

ALTER PROCEDURE GetCustomerSummary @Country NVARCHAR(50) = 'USA' AS
    
BEGIN
    BEGIN TRY
        -- Declare Variables
        DECLARE @TotalCustomers INT, @AvgScore FLOAT;     

        /* --------------------------------------------------------------------------
           Prepare & Cleanup Data
        -------------------------------------------------------------------------- */

        IF EXISTS (SELECT 1 FROM Sales.Customers WHERE Score IS NULL AND Country = @Country)
        BEGIN
            PRINT('Updating NULL Scores to 0');
            UPDATE Sales.Customers
            SET Score = 0
            WHERE Score IS NULL AND Country = @Country;
        END
        ELSE
        BEGIN
            PRINT('No NULL Scores found');
        END;

        /* --------------------------------------------------------------------------
           Generating Reports
        -------------------------------------------------------------------------- */
        SELECT
            @TotalCustomers = COUNT(*),
            @AvgScore = AVG(Score)
        FROM Sales.Customers
        WHERE Country = @Country;

        PRINT('Total Customers from ' + @Country + ':' + CAST(@TotalCustomers AS NVARCHAR));
        PRINT('Average Score from ' + @Country + ':' + CAST(@AvgScore AS NVARCHAR));

        SELECT
            COUNT(OrderID) AS TotalOrders,
            SUM(Sales) AS TotalSales,
            1/0 AS FaultyCalculation  -- Intentional error for demonstration
        FROM Sales.Orders AS o
        JOIN Sales.Customers AS c
            ON c.CustomerID = o.CustomerID
        WHERE c.Country = @Country;
    END TRY
    BEGIN CATCH
        /* --------------------------------------------------------------------------
           Error Handling
        -------------------------------------------------------------------------- */
        PRINT('An error occurred.');
        PRINT('Error Message: ' + ERROR_MESSAGE());
        PRINT('Error Number: ' + CAST(ERROR_NUMBER() AS NVARCHAR));
        PRINT('Error Severity: ' + CAST(ERROR_SEVERITY() AS NVARCHAR));
        PRINT('Error State: ' + CAST(ERROR_STATE() AS NVARCHAR));
        PRINT('Error Line: ' + CAST(ERROR_LINE() AS NVARCHAR));
        PRINT('Error Procedure: ' + ISNULL(ERROR_PROCEDURE(), 'N/A'));
    END CATCH;
END
GO

--Execute Stored Procedure
EXEC GetCustomerSummary @Country = 'Germany';
EXEC GetCustomerSummary @Country = 'USA';
EXEC GetCustomerSummary;

--Sve ovo nije preporuka za rad u praksi jer su kodovi dugacki, kompleksni i cesto konfuzni. Kada god smo u prilici
-- trebamo koristiti programske jezike poput Pythona za rad sa ovakvim stvarima.