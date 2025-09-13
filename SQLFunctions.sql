-- FUNCTIONS prvo radim string funkcije i njih prelazim a nakon toga ostale
-- bice ispisana funkcija po funkcija i objasnjavana
-- CONCAT je funkcija koja radi spajanje dva stringa i na taj nacin ih definise
-- u  novoj koloni
SELECT
	FirstName,
	LastName,
CONCAT (FirstName, ' - ' , LastName) AS FullName,
LOWER (FirstName) AS Lw_FirstName,
UPPER (FirstName) AS Up_Name --Upper and Lower case funkcije slicno kao excel

FROM Sales.Customers;

--LEN TRIM funkcija u kombinacijama sa WHERE uslovom

SELECT
	FirstName,
	LastName,
	LEN(TRIM(FirstName)) StatusName,
	LEN(FirstName) - LEN(TRIM(FirstName)) AS Flag
FROM Sales.Customers
--WHERE LEN(FirstName) != LEN(TRIM(FirstName)) nije jednako

--REPLACE menja i uklanja odredjene vrednosti, navode se tri argumenta
-- prvo vrednost, ono sto menjas, kako ce izgledati zamena toga

SELECT
'555-333-222' as PhoneNum,
REPLACE ('555-333-222', '-', '/') as NewValue
SELECT 
'REPORT.txt' as NameColumn,
REPLACE ('REPORT.txt', '.txt', '.csv') as c2

--LEN funkcija koja prebrojava koliko znakova ima u jednom redu

SELECT
	FirstName,
	LEN(FirstName) as LenName
FROM Sales.Customers

--LEFT i RIGHT kombinacije sa TRIM i uzimanje samo jednog broja karaktera

SELECT
	FirstName,
	LEFT(TRIM(FirstName), 2) as Left2Name,
	RIGHT(FirstName, 2) as Right2Name
FROM
	Sales.Customers

--SUBSTRACT je funkcija u kojoj mozes npr.prebrojati broj slova od 
-- druge pozicije pa do kraja 

SELECT
	FirstName,
	SUBSTRING(TRIM(FirstName), 2, LEN(FirstName)) as subName
FROM Sales.Customers

--Numericke funkcije u SQL slede:
--ROUND funkcija koja definise vrednosti ili ih zaokruzuje na vise ili nize

SELECT 3.516,
ROUND(3.516, 2) as RoundNum,
ROUND(3.516, 1) AS RoundN,
ROUND(3.516, 0) AS Rnd

--ABS funkcija pretvara negativne u pozitivne vrednosti

SELECT -20,
ABS (-20)

--DATE&TIME funkcije koje regulisu datumske vrednosti
--GETDATE, HardCode nacini dobijanja datuma i vremena

SELECT 
	OrderID,
	CreationTime,
	'2025-08-05' as HardCodedDate,--jedan od nacina unosa podataka u tabelu
	GETDATE() Today --Drugi nacin unosa podataka u tabelu, dobices danasnji datum i vreme
FROM Sales.Orders

--Extraxt part of dates uzima samo neke delove datuma npr.godina,mesec,dan,vreme
-- moze se i formatirati da bude drugaciji

SELECT
OrderID,
CreationTime,
YEAR(CreationTime) Year, --samo razlazemo datumske vrednosti dan,mesec,godina
MONTH(CreationTime) Month,
DAY(CreationTime) Day
FROM Sales.Orders

--DATAPART(part, data) - navodis koji deo datuma zelis mesec, dan i kolona
--jako cesta i mocna funkcija koja sluzi za dobijanje kvartala i nedelja

SELECT
OrderID,
CreationTime,
DATEPART(YEAR, CreationTime) Yeardp, -- uzeo sam godinu i naveo za koju kolonu
DATEPART(MONTH, CreationTime) Monthdp,
DATEPART(DAY, CreationTime) Daydp,
DATEPART(HOUR, CreationTime) Hourdp,
DATEPART(WEEK, CreationTime) Weekdp,
DATEPART(QUARTER, CreationTime) Quarterdp, -- moze sam da izracuna kvartal i nedelju
YEAR(CreationTime) Year, 
MONTH(CreationTime) Month,
DAY(CreationTime) Day
FROM Sales.Orders

--DATENAME(part, date) kao i funkcija datepart i ona radi isto
--mogu se izdvajati imena meseci i dana kao string vrednosti ali i godine
SELECT
OrderID,
CreationTime,
DATENAME(MONTH, CreationTime) as NameMonth,
DATENAME(WEEKDAY, CreationTime) as DayName,
datename(Day, CreationTime) as Daydp --mora weekday da se koristi za imena dana
FROM Sales.Orders

--DATETRUNCK radi resetovanje odredjenih vrednosti stavljajuci ih na 00
--kada je u pitanju vreme, 01 kada je u pitanju dan i mesec, radi kao i prethodne dve funkcije
-- DATETRUNCK(part,data)
SELECT
OrderID,
CreationTime,
DATETRUNC(MONTH, CreationTime) as MonthTrunck,
DATETRUNC(HOUR, CreationTime) as HourTrunck, --odbacuje/resetuje sve iza sata
DATETRUNC(MINUTE, CreationTime) as MinuteTrunck
FROM Sales.Orders

--EOMONTH(column) unosi se samo jedan parametar kao i kod delova day,month,year
--ovde se vide svi poslednji dani u mesecu
SELECT
OrderID,
CreationTime,
EOMONTH(CreationTime) as Emonth
FROM Sales.Orders

SELECT
	OrderID,
	CreationTime,
	EOMONTH(CreationTime) as EmonthD,
	CAST(DATETRUNC(month, CreationTime)as date) as TrunckD --cast brise nule koje ostaju od Datetrunc
FROM Sales.Orders

--CAST je obrisao nulte vrednosti minute,sekunde i sate kako bi kolona bila
--preglednija i manja bez suvisnih nula

--zadatak: po imenima meseci poredjaj koliko je bilo ordera ukupno

SELECT 
	DATENAME(MONTH, OrderDate) Monthcr,
	COUNT(*) Counting
FROM Sales.Orders
GROUP BY DATENAME(MONTH, OrderDate)

SELECT 
	OrderDate
from Sales.Orders

--Prikazi sve ordere za mesec februar

SELECT
	*	
FROM Sales.Orders
WHERE MONTH(OrderDate)= 2 -- samo filtriras preko WHERE za koji mesec ti treba


-- FORMAT je funkcija koja formatira odredjene vrednosti koje u okviru nje navedes
-- FORMAT(value, format, [type])

SELECT
	OrderID,
	CreationTime,
	FORMAT(CreationTime, 'MMM-dd-yy') Foramt,
	FORMAT(CreationTime, 'dddd') dd --izbacio sam sate,sekunde i minute 
FROM Sales.Orders

--razlika je sa velikim i malim slovom M - mesec m - minut, tri je skracen 
-- naziv a cetiri je pun

--zadatak: napravi datum  Day Wed Jan Q1 2025 12:09:45 PM

SELECT 
	OrderID,
	OrderDate,
	CreationTime,
	'Day ' + FORMAT(CreationTime, 'ddd MMM') + ' Q' + 
	DATENAME(quarter, CreationTime) + FORMAT(CreationTime, 'yyyy hh:mm:ss tt')
FROM Sales.Orders

--CONVERT function koja pretvara jedne vrednosti u druge
-- CONVERT (data_type, value, [style]) su radnje koje se redom izvode

SELECT
	CreationTime,
	CONVERT(DATE, CreationTime) [Pretvranje u Datumsku vrednost],
	CONVERT(INT, '2334') [Pretvara u numericku vrednost kolonu],
	CONVERT(varchar, CreationTime, 32) [USA standard za datum], --32 je sifra
	CONVERT(VARCHAR, CreationTime, 34) [EU standard za datum] --34 je sifra
FROM Sales.Orders

--CAST(Value as data_type) konvertuje vrednost u datum slicno kao CONVERT

SELECT 
	CreationTime,
	CAST(CreationTime AS date) [Konverzija String u Date],
	CAST(123 AS varchar) [Int to String],
	CAST('123' AS int) [String to Int]
FROM Sales.Orders

--DATEADD(Part, Interval, Date) odnosno npr DATEADD(year, 2, OrderDate)
-- ovim nacinom ce dodati +2godine na godinu u datumu moze i oduzimati
SELECT 
	OrderDate,
	DATEADD(YEAR, 2, OrderDate) [Plus 2 godine],
	DATEADD(MONTH, -4, OrderDate) [Manje 4 meseca]
FROM Sales.Orders

--DATEDIFF vraca izracunatu vrednost izmedju zadatih kriterijuma
--DATEDIFF(date, StartDate, EndDate) npr. DATEDIFF(year, Birthday, Today)

SELECT 
	EmployeeID,
	DATEDIFF(YEAR, BirthDate, GETDATE()) Age --GETDATE() je zapravo Today u DAXu
FROM Sales.Employees

--zadatak: koliko je dana proslo od isporuka materijala

SELECT
	MONTH(OrderDate) AS OrderDate,
	AVG(DATEDIFF(DAY, OrderDate, ShipDate)) AVGOrderDays
FROM Sales.Orders
GROUP BY MONTH(OrderDate)

--ISDATE(value) u okviru ove funkcije mozes proveriti da li je neka vrednost
--datum ili nije 1 ako jeste 0 ako nije ce biti vraceno

SELECT
	OrderID,
	OrderDate,
	ShipDate,
	ISDATE('2025-12-31') Provera
FROM Sales.Orders












