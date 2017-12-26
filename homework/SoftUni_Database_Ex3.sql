SELECT DepartmentID, 
	   MIN(Salary) 
FROM dbo.Employees
WHERE HireDate > '01/01/2000'
GROUP BY DepartmentID
HAVING DepartmentID IN (2, 5, 7)

SELECT *
	INTO AvgSalary 	
	FROM dbo.Employees
	WHERE Salary > 30000
DELETE FROM dbo.AvgSalary
WHERE ManagerID = 42
UPDATE AvgSalary
SET Salary += 5000
WHERE DepartmentID = 1
SELECT DepartmentID, AVG(Salary) 
FROM dbo.AvgSalary
GROUP BY DepartmentID

SELECT DepartmentID, MAX(Salary) AS [MaxSalary]
FROM dbo.Employees 
GROUP BY DepartmentID
HAVING MAX(Salary) NOT BETWEEN 30000 AND 70000

SELECT COUNT(EmployeeID) FROM dbo.Employees
WHERE ManagerID IS NULL

SELECT DepartmentID, 
	(SELECT DISTINCT Salary 
	 FROM Employees 
	 WHERE DepartmentID = e.DepartmentID 
	 ORDER BY Salary DESC 
	 OFFSET 2 ROWS 
	 FETCH NEXT 1 ROWS ONLY) AS ThirdHighestSalary
FROM Employees e
WHERE (SELECT DISTINCT Salary 
       FROM Employees 
	   WHERE DepartmentID = e.DepartmentID 
	   ORDER BY Salary DESC 
	   OFFSET 2 ROWS 
	   FETCH NEXT 1 ROWS ONLY) IS NOT NULL
GROUP BY DepartmentID

/*
DENSE_RANK Example - No Repeat Values For Quantity

USE AdventureWorks2012;  
GO  
SELECT i.ProductID, p.Name, i.LocationID, i.Quantity  
    ,DENSE_RANK() OVER   
    (PARTITION BY i.LocationID ORDER BY i.Quantity DESC) AS Rank  
FROM Production.ProductInventory AS i   
INNER JOIN Production.Product AS p   
    ON i.ProductID = p.ProductID  
WHERE i.LocationID BETWEEN 3 AND 4  
ORDER BY i.LocationID;  
GO  

*/

/* 1st Way */
SELECT TOP 10  e.FirstName, e.LastName, e.DepartmentID
FROM Employees AS e
JOIN
(SELECT e.DepartmentID, avg(e.Salary) AS avgs
FROM Employees AS e
GROUP BY e.DepartmentID) AS avgSalaries
on e.DepartmentID = avgSalaries.DepartmentID
where e.Salary > avgSalaries.avgs
order by e.DepartmentID

/* 2nd Way*/
SELECT TOP (10) em.FirstName, em.LastName, em.DepartmentID
FROM Employees as em
join
(SELECT e.DepartmentID, AVG(e.Salary) AS AvgSalary
FROM Employees as e
GROUP BY e.DepartmentID) AS AvgSalaries
ON em.DepartmentID = AvgSalaries.DepartmentID
WHERE em.Salary > AvgSalaries.AvgSalary
ORDER BY em.DepartmentID

/* 3rd Way */
SELECT TOP (10) e.FirstName, e.LastName, e.DepartmentID
FROM Employees AS e
WHERE e.Salary > (
	SELECT AVG(Inside.Salary)
	FROM Employees AS Inside
	WHERE Inside.DepartmentID = e.DepartmentID
	GROUP BY Inside.DepartmentID
)
ORDER BY e.DepartmentID