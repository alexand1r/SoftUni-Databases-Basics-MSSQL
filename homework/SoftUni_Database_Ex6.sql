CREATE PROC usp_GetEmployeesSalaryAbove35000 
AS
	SELECT FirstName, LastName
	FROM dbo.Employees
	WHERE Salary > 35000
	 
EXEC dbo.usp_GetEmployeesSalaryAbove35000
---------------------------------------------------------------------
CREATE PROC usp_GetEmployeesSalaryAboveNumber(@Salary money)
AS
	SELECT FirstName, LastName 
	FROM dbo.Employees
	WHERE Salary >= @Salary

EXEC dbo.usp_GetEmployeesSalaryAboveNumber
	@Salary = 35000
---------------------------------------------------------------------
CREATE PROC usp_GetTownsStartingWith(@WORD varchar(50))
AS
	SELECT Name
	FROM dbo.Towns
	WHERE LEFT(Name, LEN(@WORD)) = @WORD

EXEC dbo.usp_GetTownsStartingWith @WORD = b
---------------------------------------------------------------------
CREATE PROC usp_GetEmployeesFromTown(@TOWN varchar(50))
AS
	SELECT FirstName, LastName
	FROM Employees as e
	JOIN Addresses as a
	ON e.AddressID = a.AddressID
	JOIN Towns as t
	ON a.TownID = t.TownID
	WHERE t.Name = @TOWN

EXEC dbo.usp_GetEmployeesFromTown @TOWN = Sofia
---------------------------------------------------------------------
CREATE FUNCTION ufn_GetSalaryLevel(@salary MONEY)
returns varchar(10)
AS
BEGIN
	IF (@salary < 30000)
		return 'Low';
	ELSE IF(@salary > 50000)
		return 'High';
	
	return 'Average';
END;

SELECT Salary, dbo.ufn_GetSalaryLevel(Salary) FROM dbo.Employees
---------------------------------------------------------------------
CREATE PROC usp_EmployeesBySalaryLevel(@LEVEL varchar(10))
AS
	SELECT FirstName, LastName
	FROM dbo.Employees
	WHERE dbo.ufn_GetSalaryLevel(Salary) = @LEVEL

EXEC dbo.usp_EmployeesBySalaryLevel @LEVEL = High
---------------------------------------------------------------------
CREATE FUNCTION ufn_IsWordComprised(@setOfLetters varchar(10), @word varchar(10))
RETURNS BIT
BEGIN 
	 DECLARE @index INT = 1
     DECLARE @length INT = LEN(@word)
     DECLARE @letter CHAR(1)
     WHILE (@index <= @length)
     BEGIN
          SET @letter = SUBSTRING(@word, @index, 1)
          IF (CHARINDEX(@letter, @setOfLetters) > 0)
             SET @index = @index + 1
          ELSE
             RETURN 0
     END
     RETURN 1
END;
---------------------------------------------------------------------
 ALTER TABLE Departments
 ALTER COLUMN ManagerID int null

 DELETE FROM EmployeesProjects
 WHERE EmployeeID IN (
	 SELECT EmployeeID 
	 FROM Employees AS e
	 INNER JOIN Departments AS d
	 ON e.DepartmentID = d.DepartmentID
	 WHERE d.Name IN ('Production', 'Production Control')
 )

 UPDATE Employees
 SET ManagerID = NULL
 WHERE ManagerID IN (
	 SELECT EmployeeID 
	 FROM Employees AS e
	 INNER JOIN Departments AS d
	 ON e.DepartmentID = d.DepartmentID
	 WHERE d.Name IN ('Production', 'Production Control')
 )

 UPDATE Departments
 SET ManagerID = NULL
 WHERE ManagerID IN (
	 SELECT EmployeeID 
	 FROM Employees AS e
	 INNER JOIN Departments AS d
	 ON e.DepartmentID = d.DepartmentID
	 WHERE d.Name IN ('Production', 'Production Control')
 )

 DELETE FROM Employees
 WHERE EmployeeID IN (
	 SELECT EmployeeID 
	 FROM Employees AS e
	 INNER JOIN Departments AS d
	 ON e.DepartmentID = d.DepartmentID
	 WHERE d.Name IN ('Production', 'Production Control')
 )

 DELETE FROM Departments
 WHERE Name IN ('Production', 'Production Control')
 ------------------------------------------------------------------
 CREATE PROCEDURE usp_AssignProject
(@EmployeeID INT, @ProjectID INT)
AS
BEGIN
	DECLARE @maxEmployeeProjectsCount INT = 3
	DECLARE @employeeProjectsCount INT
	SET @employeeProjectsCount = (SELECT COUNT(*)
	FROM [dbo].[EmployeesProjects] AS ep
	WHERE ep.EmployeeId = @EmployeeID)
	BEGIN TRAN
		INSERT INTO [dbo].[EmployeesProjects]
		(EmployeeID, ProjectID)
		VALUES (@EmployeeID, @ProjectID)
		IF(@employeeProjectsCount >= @maxEmployeeProjectsCount)
		BEGIN
		RAISERROR('The employee has too many projects!', 16, 1)
		ROLLBACK
	END
	ELSE
	COMMIT
END
-----------------------------------------------------------------
