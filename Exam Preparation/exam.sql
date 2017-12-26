-- 1.DLL

CREATE TABLE Countries (
	Id INT IDENTITY,
	Name NVARCHAR(50) UNIQUE,
	CONSTRAINT PK_Countries PRIMARY KEY (Id)
)

CREATE TABLE Distributors (
	Id INT IDENTITY,
	Name NVARCHAR(25) UNIQUE,
	AddressText NVARCHAR(30),
	Summary NVARCHAR(200),
	CountryId INT,
	CONSTRAINT PK_Distributors PRIMARY KEY (Id),
	CONSTRAINT FK_Distributors_Countries FOREIGN KEY (CountryId) REFERENCES Countries(Id)
)

CREATE TABLE Products (
	Id INT IDENTITY,
	Name NVARCHAR(25) UNIQUE,
	Description NVARCHAR(250),
	Recipe NVARCHAR(MAX),
	Price MONEY CHECK (Price >= 0),
	CONSTRAINT PK_Products PRIMARY KEY (Id) 
)

CREATE TABLE Ingredients (
	Id INT IDENTITY,
	Name NVARCHAR(30),
	Description NVARCHAR(200),
	OriginCountryId INT,
	DistributorId INT,
	CONSTRAINT PK_Ingredients PRIMARY KEY (Id),
	CONSTRAINT FK_Ingredients_Countries FOREIGN KEY(OriginCountryId) REFERENCES Countries(Id),
	CONSTRAINT FK_Ingredients_Distributors FOREIGN KEY (DistributorId) REFERENCES Distributors(Id)
)

CREATE TABLE ProductsIngredients (
	ProductId INT,
	IngredientId INT,
	CONSTRAINT PK_ProductsIngredients PRIMARY KEY (ProductId, IngredientId),
	CONSTRAINT FK_PI_Products FOREIGN KEY (ProductId) REFERENCES Products(Id),
	CONSTRAINT FK_PI_Ingredients FOREIGN KEY (IngredientId) REFERENCES Ingredients(Id)
)

CREATE TABLE Customers (
	Id INT IDENTITY,
	FirstName NVARCHAR(25),
	LastName NVARCHAR(25),
	Gender CHAR(1) CHECK (Gender = 'M' OR Gender = 'F'),
	Age INT,
	PhoneNumber NVARCHAR(10) CHECK (LEN(PhoneNumber) = 10),
	CountryId INT,
	CONSTRAINT PK_Customers PRIMARY KEY(Id),
	CONSTRAINT FK_Customers_Countries FOREIGN KEY(CountryId) REFERENCES Countries(Id)
)

CREATE TABLE Feedbacks (
	Id INT IDENTITY,
	Description NVARCHAR(255),
	Rate DECIMAL(10,2) CHECK (Rate >= 0 AND Rate <= 10),
	ProductId INT,
	CustomerId INT,
	CONSTRAINT PK_Feedbacks PRIMARY KEY (Id),
	CONSTRAINT FK_Feedbacks_Products FOREIGN KEY (ProductId) REFERENCES Products(Id),
	CONSTRAINT FK_Feedbacks_Customers FOREIGN KEY (CustomerId) REFERENCES Customers(Id)
)

-- 2. INSERT

INSERT INTO Customers (FirstName, LastName, Gender, Age, PhoneNumber, CountryId)
VALUES('ss', 'ss', 'M', 21, '1212121212', 2)

INSERT INTO Distributors(Name, CountryId, AddressText, Summary)
VALUES
	('Deloitte & Touche', 2, '6 Arch St #9757', 'Customizable neutral traveling'),
	('Congress Title', 13, '58 Hancock St', 'Customer loyalty'),
	('Kitchen People', 1, '3 E 31st St #77', 'Triple-buffered stable delivery'),
	('General Color Co Inc', 21, '6185 Bohn St #72', 'Focus group'),
	('Beck Corporation', 23, '21 E 64th Ave', 'Quality-focused 4th generation hardware')

INSERT INTO Customers(FirstName, LastName, Age, Gender, PhoneNumber, CountryId)
VALUES 
	('Francoise', 'Rautenstrauch', 15, 'M', '0195698399', 5),
	('Kendra', 'Loud', 22, 'F', '0063631526', 11),
	('Lourdes', 'Bauswell', 50, 'M', '0139037043', 8),
	('Hannah', 'Edmison', 18, 'F', '0043343686', 1),
	('Tom', 'Loeza', 31, 'M', '0144876096', 23),
	('Queenie', 'Kramarczyk', 30, 'F', '0064215793', 29),
	('Hiu', 'Portaro', 25, 'M', '0068277755', 16),
	('Josefa', 'Opitz', 43, 'F', '0197887645', 17)

--3. Update

UPDATE Ingredients
SET DistributorId = 35
WHERE Name IN ('Bay Leaf', 'Paprika', 'Poppy')

UPDATE Ingredients
SET OriginCountryId = 14
WHERE OriginCountryId = 8

--4. DELETE

DELETE FROM Feedbacks
WHERE CustomerId = 14 OR ProductId = 5

----

DROP DATABASE Bakery
CREATE DATABASE Bakery

----
--6. Products

SELECT Name, Price, Description
FROM Products
ORDER BY Price DESC, Name ASC

--7.Ingredients

SELECT i.Name, i.Description, i.OriginCountryId
FROM Ingredients AS i
WHERE OriginCountryId IN (1, 10, 20)
ORDER BY i.Id

--8.Ingredients From BG AND Greece

SELECT TOP (15) i.Name, i.Description, c.Name AS [CountryName]
FROM Ingredients AS i
INNER JOIN Countries AS c
ON i.OriginCountryId = c.Id
WHERE c.Name IN ('Bulgaria', 'Greece')
ORDER BY i.Name, c.Name

--8.	Best Rated Products

SELECT TOP (10) p.Name, p.Description, AVG(f.Rate) AS [AverageRate], COUNT(f.Id) AS [FeedbacksAmount]
FROM Products AS p
INNER JOIN Feedbacks AS f
ON p.Id = f.ProductId
GROUP BY p.Name, p.Description
ORDER BY [AverageRate] DESC, [FeedbacksAmount] DESC

--9.	Negative Feedback

SELECT f.ProductId, f.Rate, f.Description, f.CustomerId, c.Age, c.Gender
FROM Feedbacks AS f
INNER JOIN Customers AS c
ON c.Id = f.CustomerId
WHERE f.Rate < 5.0
ORDER BY ProductId DESC, Rate

--10.	Customers without Feedback

SELECT CONCAT(c.FirstName, ' ', c.LastName) AS CustomerName,
	   c.PhoneNumber, c.Gender
FROM Customers AS c
LEFT JOIN Feedbacks AS f
ON c.Id = f.CustomerId
WHERE f.CustomerId IS NULL
ORDER BY c.Id 

--11.	Honorable Mentions

SELECT f.ProductId, 
	   CONCAT(c.FirstName, ' ', c.LastName) AS CustomerName,
	   f.Description AS [FeedbackDescription]
FROM Feedbacks AS f
INNER JOIN Customers AS c
ON c.Id = f.CustomerId
WHERE 3 <= (SELECT COUNT(*) FROM Feedbacks AS f2 WHERE f2.CustomerId = f.CustomerId)
ORDER BY f.ProductId, [CustomerName], f.Id

--12.	Customers by Criteria

SELECT c.FirstName, c.Age, c.PhoneNumber
FROM Customers as c 
INNER JOIN Countries AS co
ON co.Id = c.CountryId
WHERE (c.Age >= 21
		AND c.FirstName LIKE '%an%')
OR (c.PhoneNumber LIKE '%38'
	AND co.Name <> 'Greece')
ORDER BY c.FirstName, c.Age DESC 

--13.	Middle Range Distributors

SELECT d.Name AS [DistributorName], i.Name AS [IngredientName], p.Name AS [ProductName], AVG(f.Rate) AS [AverageRate]
FROM Distributors AS d
INNER JOIN Ingredients AS i
ON i.DistributorId = d.Id
INNER JOIN ProductsIngredients AS pi
ON pi.IngredientId = i.Id
INNER JOIN Products AS p
ON p.Id = pi.ProductId
INNER JOIN Feedbacks AS f
ON f.ProductId = p.Id
GROUP BY d.Name, i.Name, p.Name
HAVING AVG(f.Rate) BETWEEN 5 AND 8
ORDER BY d.Name, i.Name, p.Name

--14.	The Most Positive Country

SELECT TOP (1) WITH TIES data.[CountryName], data.[FeedbackRate] FROM
	(SELECT co.Name AS [CountryName], AVG(f.Rate) AS [FeedbackRate], SUM(f.Rate) as [Sum]
	FROM Countries as co
	INNER JOIN Customers AS c
	ON c.CountryId = co.Id
	INNER JOIN Feedbacks AS f
	ON f.CustomerId = c.Id
	GROUP BY co.Name
	) AS data
ORDER BY data.[Sum] DESC

--15.	Country Representative

SELECT k.CountryName, k.DisributorName FROM (
SELECT
    *,
    RANK() OVER (PARTITION BY t.CountryName ORDER BY cnt DESC) AS rid
FROM (
SELECT
    c.Name AS [CountryName],
    d.Name AS [DisributorName],
    COUNT(i.Name) cnt  
FROM Countries c
LEFT JOIN Distributors d ON d.CountryId = c.Id
LEFT JOIN Ingredients i ON i.DistributorId = d.Id
GROUP BY c.Name, d.Name ) t
 
) k
WHERE rid = 1
ORDER BY k.CountryName, k.DisributorName

--16.	Customers with Countries

CREATE VIEW [v_UserWithCountries] AS
SELECT CONCAT(c.FirstName, ' ', c.LastName) AS [CustomerName], c.Age, c.Gender, co.Name as [CountryName]
FROM Customers AS c
INNER JOIN Countries AS co
ON co.Id = c.CountryId

SELECT TOP 5 *
  FROM v_UserWithCountries
 ORDER BY Age

--17.	Feedback by Product Name

CREATE FUNCTION udf_GetRating(@ProductName NVARCHAR(MAX))
RETURNS NVARCHAR(MAX)
AS
BEGIN
	DECLARE @AVGRATE DECIMAL(10,2) = 
		(SELECT AVG(f.Rate) 
		 FROM Products as p
		 LEFT JOIN Feedbacks as f
		 ON f.ProductId = p.Id
		 WHERE p.Name = @ProductName)
		 
	IF @AVGRATE IS NULL
		BEGIN
			RETURN 'No rating' 
		END  
	ELSE IF @AVGRATE < 5
		BEGIN
			RETURN 'Bad'; 
		END
	ELSE IF @AVGRATE >= 5 AND @AVGRATE <= 8
		BEGIN
			 RETURN 'Average';
		END

	RETURN 'Good';
END

SELECT TOP 5 Id, Name, dbo.ufn_FeedbackByProductName(Name)--dbo.udf_GetRating(Octinoxate)
  FROM Products
 ORDER BY Id

 --18.	Send Feedback

 CREATE PROCEDURE usp_SendFeedback (@CustomerId INT, @ProductId INT, @Rate DECIMAL(10,2), @Description NVARCHAR(MAX))
 AS
 BEGIN

	BEGIN TRANSACTION
	
	DECLARE @UserFeedBacks INT = 
			(SELECT COUNT(f.Id)
			 FROM Feedbacks AS f
			 LEFT JOIN Products AS p
			 ON p.Id = f.ProductId
			 LEFT JOIN Customers as c
			 ON c.Id = f.CustomerId
			 WHERE f.CustomerId = @CustomerId);

	IF @UserFeedBacks >= 3
		BEGIN
			ROLLBACK;
			RAISERROR('You are limited to only 3 feedbacks per product!', 16, 1);
			RETURN;
		END
	ELSE 
		BEGIN
			INSERT INTO Feedbacks(CustomerId, ProductId, Rate, Description)
			VALUES(@CustomerId, @ProductId, @Rate, @Description)
		END

	COMMIT
 END

 EXEC usp_SendFeedback 1, 5, 7.50, 'Average experience';
SELECT COUNT(*) FROM Feedbacks WHERE CustomerId = 1 AND ProductId = 5;

--19.	Delete Products

CREATE TRIGGER tr_DeleteProduct ON Products INSTEAD OF DELETE
AS

DECLARE @ProductId INT = (SELECT Id FROM deleted);

DELETE FROM ProductsIngredients
WHERE ProductId = @ProductId

DELETE FROM Feedbacks 
WHERE ProductId = @ProductId

DELETE FROM Products WHERE Id = @ProductId

--BEGIN TRANSACTION

--DELETE FROM Products WHERE Id = 7

--ROLLBACK

--20.	Products by One Distributor

SELECT p.Name AS [ProductName], 
	   AVG(f.Rate) AS [ProductAverageRate], 
	   d.Name AS [DistributorName], 
	   co.Name AS [DistributorCountry]
FROM Ingredients as i
INNER JOIN ProductsIngredients AS pi
ON pi.IngredientId = i.Id 
INNER JOIN Products AS p
ON p.Id = pi.ProductId
INNER JOIN Feedbacks as f
ON f.ProductId = p.Id
INNER JOIN Distributors AS d
ON d.CountryId = i.DistributorId
INNER JOIN Countries AS co
ON co.Id = d.CountryId
GROUP BY p.Id, p.Name, d.Name, co.Name
ORDER BY p.Id
