SELECT * FROM dbo.Departments

SELECT Name FROM dbo.Departments

SELECT FirstName, LastName, Salary FROM [SoftUni].[dbo].[Employees]

SELECT FirstName, MiddleName, LastName FROM dbo.Employees

SELECT FirstName + '.' + LastName + '@softuni.bg' AS [Full Email Address] FROM dbo.Employees

SELECT DISTINCT Salary FROM dbo.Employees

SELECT * FROM dbo.Employees as e WHERE e.JobTitle = 'Sales Representative'

SELECT FirstName, LastName, JobTitle FROM dbo.Employees as e WHERE e.Salary BETWEEN 20000 AND 30000

SELECT FirstName + ' ' + MiddleName +  ' ' + LastName AS [Full Name] FROM dbo.Employees as e
WHERE e.Salary IN (25000, 14000, 12500, 23600)

SELECT FirstName, LastName FROM dbo.Employees as e WHERE e.ManagerID is null

SELECT FirstName, LastName, Salary FROM dbo.Employees as e WHERE e.Salary > 50000 ORDER BY e.Salary DESC

SELECT TOP (5) FirstName, LastName FROM dbo.Employees as e ORDER BY e.Salary DESC

SELECT FirstName, LastName FROM dbo.Employees as e WHERE e.DepartmentID != 4

SELECT * FROM dbo.Employees as e ORDER BY e.Salary DESC, e.FirstName, e.LastName DESC, e.MiddleName

CREATE VIEW V_EmployeesSalaries AS 
SELECT FirstName, LastName, Salary FROM dbo.Employees

CREATE VIEW V_EmployeeNameJobTitle AS
SELECT 
CASE WHEN MiddleName is null 
THEN FirstName + ' ' + '' + ' ' +  LastName 
ELSE FirstName + ' ' + MiddleName + ' ' + LastName  END
AS [Full Name], JobTitle FROM dbo.Employees

SELECT * FROM V_EmployeeNameJobTitle

SELECT DISTINCT JobTitle FROM dbo.Employees

SELECT TOP (10) * FROM dbo.Projects as p ORDER BY StartDate, Name

SELECT TOP (7) FirstName, LastName, HireDate FROM dbo.Employees ORDER BY HireDate DESC

UPDATE dbo.Employees
SET Salary += Salary * 0.12
WHERE DepartmentID IN (1, 2, 4, 11)

SELECT Salary FROM dbo.Employees

