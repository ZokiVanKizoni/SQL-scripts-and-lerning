--SET operators and ther uses

SELECT 
	FirstName,
	LastName
FROM Sales.Customers

UNION  --SPAJA dve tabele u uniju bitno je da imaju isti broj kolona
		-- u suprotnom ce se javiti greska
SELECT
	FirstName,
	LastName
FROM Sales.Employees
