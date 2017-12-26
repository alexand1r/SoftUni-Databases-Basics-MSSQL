SELECT TOP (5) e.EmployeeID, e.JobTitle, a.AddressID, a.AddressText
FROM dbo.Employees AS e
JOIN dbo.Addresses AS a
ON e.AddressID = a.AddressID
ORDER BY e.AddressID

SELECT e.FirstName, e.LastName, t.Name, a.AddressText
FROM dbo.Employees AS e
JOIN dbo.Addresses AS a
ON e.AddressID = a.AddressID
JOIN dbo.Towns AS t
ON a.TownID = t.TownID
ORDER BY e.FirstName, e.LastName
OFFSET 0 ROWS
FETCH NEXT 50 ROWS ONLY

SELECT e.EmployeeID, e.FirstName, e.LastName, d.Name
FROM dbo.Employees AS e
JOIN dbo.Departments AS d 
ON e.DepartmentID = d.DepartmentID
WHERE d.Name = 'Sales'
ORDER BY EmployeeID

SELECT TOP (5) e.EmployeeID, e.FirstName, e.Salary, d.Name AS [DepartmentName]
FROM dbo.Employees AS e
JOIN dbo.Departments AS d
ON e.DepartmentID = d.DepartmentID
WHERE Salary > 15000
ORDER BY d.DepartmentID

SELECT TOP(3) e.EmployeeID, e.FirstName 
FROM Employees AS e
    LEFT JOIN EmployeesProjects AS ep
    ON e.EmployeeID = ep.EmployeeID
	WHERE ep.ProjectID is null
ORDER BY e.EmployeeID

SELECT e.FirstName, e.LastName, e.HireDate, d.Name AS [DeptName]
FROM dbo.Employees AS e
JOIN dbo.Departments AS d
ON e.DepartmentID = d.DepartmentID
WHERE e.HireDate > '1/1/1999'
AND d.DepartmentID IN (
						SELECT d2.DepartmentID
						FROM dbo.Departments AS d2
						WHERE d2.Name IN ('Sales', 'Finance')
					  )

SELECT TOP(5) e.EmployeeID, e.FirstName, p.Name AS [ProjectName]
FROM Employees AS e
    INNER JOIN EmployeesProjects AS ep
    ON e.EmployeeID = ep.EmployeeID
	INNER JOIN Projects AS p
	ON ep.ProjectID = p.ProjectID
	WHERE p.StartDate > '8/13/2002'
	AND p.EndDate is null
ORDER BY e.EmployeeID

SELECT e.EmployeeID, e.FirstName, 
		CASE WHEN DATEPART(year, p.StartDate) >= '2005' THEN NULL
		ELSE p.Name END AS [ProjectName]
FROM Employees AS e
    INNER JOIN EmployeesProjects AS ep
    ON e.EmployeeID = ep.EmployeeID
	INNER JOIN Projects AS p
	ON ep.ProjectID = p.ProjectID
	WHERE e.EmployeeID = 24
ORDER BY e.EmployeeID

SELECT e.EmployeeID, e.FirstName, e.ManagerID, e2.FirstName AS [ManagerName]
FROM Employees AS e
    JOIN Employees AS e2
	ON e.ManagerID = e2.EmployeeID
	WHERE e.ManagerID IN (3,7)
ORDER BY e.EmployeeID

SELECT TOP (50) e.EmployeeID, 
	   e.FirstName + ' ' + e.LastName AS [EmployeeName], 
	   e2.FirstName + ' ' + e2.LastName AS [ManagerName],
	   d.Name AS [DepartmentName]
FROM Employees AS e
JOIN Employees AS e2
ON e.ManagerID = e2.EmployeeID
JOIN Departments AS d
ON e.DepartmentID = d.DepartmentID
ORDER BY e.EmployeeID

SELECT MIN(t.AverageSalary)
FROM (
	  SELECT AVG(e.Salary) AS [AverageSalary], d.DepartmentID
	  FROM dbo.Employees AS e
	  JOIN dbo.Departments AS d
	  ON d.DepartmentID = e.DepartmentID
	  GROUP BY d.DepartmentID
	 ) AS t
	  