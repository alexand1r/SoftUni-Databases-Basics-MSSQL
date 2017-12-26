SELECT FirstName, LastName FROM dbo.Employees WHERE FirstName LIKE 'Sa%'

SELECT FirstName, LastName FROM dbo.Employees WHERE LastName LIKE '%ei%'

SELECT FirstName FROM dbo.Employees 
WHERE DepartmentID IN (3, 10) 
AND DATEPART(year, HireDate) BETWEEN 1994 AND 2006

SELECT FirstName, LastName FROM dbo.Employees WHERE JobTitle NOT LIKE '%engineer%'

SELECT Name FROM dbo.Towns WHERE LEN(Name) BETWEEN 5 AND 6 ORDER BY Name

SELECT TownId, Name FROM dbo.Towns WHERE LEFT(Name, 1) IN ('M', 'K', 'B', 'E') ORDER BY Name

SELECT TownId, Name FROM dbo.Towns WHERE LEFT(Name, 1) NOT IN ('R', 'B', 'D') ORDER BY Name

CREATE VIEW V_EmployeesHiredAfter2000 AS
SELECT FirstName, LastName FROM dbo.Employees
WHERE DATEPART(year, HireDate) > 2000

SELECT * FROM V_EmployeesHiredAfter2000

SELECT FirstName, LastName FROM dbo.Employees WHERE LEN(LastName) = 5

