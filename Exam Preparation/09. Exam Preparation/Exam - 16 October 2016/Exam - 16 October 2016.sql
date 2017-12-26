--- Section 0: Database Overview ---

CREATE DATABASE [Airport Management System]

--- Section 1: Data Definition ---

CREATE TABLE Towns (
	TownID INT,
	TownName VARCHAR(30) NOT NULL,
	CONSTRAINT PK_Towns PRIMARY KEY(TownID)
)

CREATE TABLE Airports (
	AirportID INT,
	AirportName VARCHAR(50) NOT NULL,
	TownID INT NOT NULL,
	CONSTRAINT PK_Airports PRIMARY KEY(AirportID),
	CONSTRAINT FK_Airports_Towns FOREIGN KEY(TownID) REFERENCES Towns(TownID)
)

CREATE TABLE Airlines (
	AirlineID INT,
	AirlineName VARCHAR(30) NOT NULL,
	Nationality VARCHAR(30) NOT NULL,
	Rating INT DEFAULT(0),
	CONSTRAINT PK_Airlines PRIMARY KEY(AirlineID)
)

CREATE TABLE Customers (
	CustomerID INT,
	FirstName VARCHAR(20) NOT NULL,
	LastName VARCHAR(20) NOT NULL,
	DateOfBirth DATE NOT NULL,
	Gender VARCHAR(1) NOT NULL CHECK (Gender='M' OR Gender='F'),
	HomeTownID INT NOT NULL,
	CONSTRAINT PK_Customers PRIMARY KEY(CustomerID),
	CONSTRAINT FK_Customers_Towns FOREIGN KEY(HomeTownID) REFERENCES Towns(TownID)
)

CREATE TABLE Flights (
	FlightID INT,
	DepartureTime DATETIME NOT NULL,
	ArrivalTime DATETIME NOT NULL,
	Status VARCHAR(9) NOT NULL CHECK (Status='Departing' OR Status='Delayed' OR Status='Arrived' OR Status='Cancelled'),
	OriginAirportID INT NOT NULL,
	DestinationAirportID INT NOT NULL,
	AirlineID INT NOT NULL,
	CONSTRAINT PK_Flights PRIMARY KEY(FlightID),
	CONSTRAINT FK_Flights_Airports FOREIGN KEY(OriginAirportID) REFERENCES Airports(AirportID),
	CONSTRAINT FK_Flights_Airports2 FOREIGN KEY(DestinationAirportID) REFERENCES Airports(AirportID),
	CONSTRAINT FK_Flights_Airlines FOREIGN KEY(AirlineID) REFERENCES Airlines(AirlineID)
)

CREATE TABLE Tickets (
	TicketID INT,
	Price DECIMAL(8,2) NOT NULL,
	Class VARCHAR(6) NOT NULL CHECK (Class='First' OR Class='Second' OR Class='Third'),
	Seat VARCHAR(5) NOT NULL,
	CustomerID INT NOT NULL,
	FlightID INT NOT NULL,
	CONSTRAINT PK_Tickets PRIMARY KEY(TicketID),
	CONSTRAINT FK_Tickets_Customers FOREIGN KEY(CustomerID) REFERENCES Customers(CustomerID),
	CONSTRAINT FK_Tickets_Flights FOREIGN KEY(FlightID) REFERENCES Flights(FlightID)
)

--- Section 2: Database Manipulations ---

-- Task 1: Data Insertion

INSERT INTO Towns(TownID, TownName)
VALUES
(1, 'Sofia'),
(2, 'Moscow'),
(3, 'Los Angeles'),
(4, 'Athene'),
(5, 'New York')

INSERT INTO Airports(AirportID, AirportName, TownID)
VALUES
(1, 'Sofia International Airport', 1),
(2, 'New York Airport', 5),
(3, 'Royals Airport', 1),
(4, 'Moscow Central Airport', 2)

INSERT INTO Airlines(AirlineID, AirlineName, Nationality, Rating)
VALUES
(1, 'Royal Airline', 'Bulgarian', 200),
(2, 'Russia Airlines', 'Russian', 150),
(3, 'USA Airlines', 'American', 100),
(4, 'Dubai Airlines', 'Arabian', 149),
(5, 'South African Airlines', 'African', 50),
(6, 'Sofia Air', 'Bulgarian', 199),
(7, 'Bad Airlines', 'Bad', 10)

INSERT INTO Customers(CustomerID, FirstName, LastName, DateOfBirth, Gender, HomeTownID)
VALUES
(1, 'Cassidy', 'Isacc', '19971020', 'F', 1),
(2, 'Jonathan', 'Half', '19830322', 'M', 2),
(3, 'Zack', 'Cody', '19890808', 'M', 4),
(4, 'Joseph', 'Priboi', '19500101', 'M', 5),
(5, 'Ivy', 'Indigo', '19931231', 'F', 1)

INSERT INTO Flights(FlightID, DepartureTime, ArrivalTime, Status, OriginAirportID, DestinationAirportID, AirlineID)
VALUES
(1, '20161013 06:00:00 AM', '20161013 10:00:00 AM', 'Delayed', 1, 4, 1),
(2, '20161012 12:00:00 PM', '20161012 12:01:00 PM', 'Departing', 1, 3, 2),
(3, '20161014 03:00:00 PM', '20161020 04:00:00 AM', 'Delayed', 4, 2, 4),
(4, '20161012 01:24:00 PM', '20161012 4:31:00 PM', 'Departing', 3, 1, 3),
(5, '20161012 08:11:00 AM', '20161012 11:22:00 PM', 'Departing', 4, 1, 1),
(6, '19950621 12:30:00 PM', '19950622 08:30:00 PM', 'Arrived', 2, 3, 5),
(7, '20161012 11:34:00 PM', '20161013 03:00:00 AM', 'Departing', 2, 4, 2),
(8, '20161111 01:00:00 PM', '20161112 10:00:00 PM', 'Delayed', 4, 3, 1),
(9, '20151001 12:00:00 PM', '20151201 01:00:00 AM', 'Arrived', 1, 2, 1),
(10, '20161012 07:30:00 PM', '20161013 12:30:00 PM', 'Departing', 2, 1, 7)

INSERT INTO Tickets(TicketID, Price, Class, Seat, CustomerID, FlightID)
VALUES
(1, 3000.00, 'First', '233-A', 3, 8),
(2, 1799.90, 'Second', '123-D', 1, 1),
(3, 1200.50, 'Second', '12-Z', 2, 5),
(4, 410.68, 'Third', '45-Q', 2, 8),
(5, 560.00, 'Third', '201-R', 4, 6),
(6, 2100.00, 'Second', '13-T', 1, 9),
(7, 5500.00, 'First', '98-O', 2, 7)

-- Task 2: Update Arrived Flights

UPDATE Flights
SET AirlineID = 1
WHERE Status = 'Arrived'

-- Task 3: Update Tickets

UPDATE Tickets
SET Price += 0.5 * Price
WHERE FlightID IN (SELECT FlightID
				   FROM Flights
				   WHERE AirlineID = (SELECT TOP(1) AirlineID 
									  FROM Airlines
									  ORDER BY Rating DESC
									  )
				   )

-- Task 4: Table Creation

CREATE TABLE CustomerReviews(
	ReviewID INT,
	ReviewContent VARCHAR(255) NOT NULL,
	ReviewGrade INT NOT NULL CHECK (ReviewGrade >= 0 AND ReviewGrade <= 10),
	AirlineID INT NOT NULL,
	CustomerID INT NOT NULL,
	CONSTRAINT PK_CustomerReviews PRIMARY KEY(ReviewID),
	CONSTRAINT FK_CustomerReviews_Airlines FOREIGN KEY (AirlineID) REFERENCES Airlines(AirlineID),
	CONSTRAINT FK_CustomerReviews_Customers FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
)

CREATE TABLE CustomerBankAccounts(
	AccountID INT,
	AccountNumber VARCHAR(10) NOT NULL UNIQUE,
	Balance DECIMAL(10,2) NOT NULL,
	CustomerID INT,
	CONSTRAINT PK_CustomerBankAccounts PRIMARY KEY(AccountID),
	CONSTRAINT FK_CustomerBankAccounts_Customers FOREIGN KEY(CustomerID) REFERENCES Customers(CustomerID)
)

-- Task 5: Fill the new Tables with Data

INSERT INTO CustomerReviews(ReviewID, ReviewContent, ReviewGrade, AirlineID, CustomerID)
VALUES
(1, 'Me is very happy. Me likey this airline. Me good.', 10, 1, 1),
(2, 'Ja, Ja, Ja... Ja, Gut, Gut, Ja Gut! Sehr Gut!', 10, 1, 4),
(3, 'Meh...', 5, 4, 3),
(4, 'Well Ive seen better, but Ive certainly seen a lot worse...', 7, 3, 5)

INSERT INTO CustomerBankAccounts(AccountID, AccountNumber, Balance, CustomerID)
VALUES
(1, '123456790', 2569.23, 1),
(2, '18ABC23672', 14004568.23, 2),
(3, 'F0RG0100N3', 19345.20, 5)

--- Section 3: Querying ---

-- Task 1: Extract All Tickets

SELECT TicketID, Price, Class, Seat
FROM Tickets
ORDER BY TicketID

-- Task 2: Extract All Customers 

SELECT CustomerID, FirstName + ' ' + LastName AS [FullName], Gender
FROM Customers
ORDER BY [FullName], CustomerID

-- Task 3: Extract Delayed Flights 

SELECT FlightID, DepartureTime, ArrivalTime
FROM Flights
WHERE Status = 'Delayed'
ORDER BY FlightID

-- Task 4: Extract Top 5 Most Highly Rated Airlines which have any Flights

SELECT TOP(5) a.AirlineID, AirlineName, Nationality, Rating
FROM Airlines AS a
LEFT JOIN Flights AS f
ON f.AirlineID = a.AirlineID
WHERE f.AirlineID IS NOT NULL
GROUP BY a.AirlineID, AirlineName, Nationality, Rating
ORDER BY Rating DESC, a.AirlineID

-- Task 5: Extract all Tickets with price below 5000, for First Class

SELECT t.TicketID, a.AirportName, c.FirstName + ' ' + c.LastName AS [CustomerName]
FROM Tickets AS t
JOIN Flights AS f
ON t.FlightID = f.FlightID
JOIN Airports AS a
ON f.DestinationAirportID = a.AirportID
JOIN Customers AS c
ON t.CustomerID = c.CustomerID
WHERE t.Price < 5000 AND t.Class = 'First'
ORDER BY TicketID 

-- Task 6: Extract all Customers which are departing from their Home Town

SELECT c.CustomerID, c.FirstName + ' ' + c.LastName AS [FullName], towns.TownName AS [HomeTown]
FROM Customers AS c
JOIN Tickets AS t
ON t.CustomerID = c.CustomerID
JOIN Flights AS f
ON f.FlightID = t.FlightID
JOIN Airports AS a
ON f.OriginAirportID = a.AirportID
JOIN Towns AS towns
ON towns.TownID = a.TownID
WHERE c.HomeTownID = towns.TownID
GROUP BY c.CustomerID, c.FirstName + ' ' + c.LastName, towns.TownName
ORDER BY CustomerID 

-- Task 7: Extract all Customers which will fly

SELECT c.CustomerID, 
	   c.FirstName + ' ' + c.LastName AS [FullName],
	   DATEDIFF(year, CAST(DATEPART(year, c.DateOfBirth) AS varchar), '2016') AS [Age]
FROM Customers AS c
LEFT JOIN Tickets AS t
ON c.CustomerID = t.CustomerID
LEFT JOIN Flights AS f
ON f.FlightID = t.FlightID
WHERE t.TicketID IS NOT NULL
AND f.Status = 'Departing'
GROUP BY c.CustomerID, c.FirstName + ' ' + c.LastName, DATEDIFF(year, CAST(DATEPART(year, c.DateOfBirth) AS varchar), '2016')
ORDER BY Age, CustomerID

-- Task 8: Extract Top 3 Customers which have Delayed Flights

SELECT TOP(3) c.CustomerID, 
	   c.FirstName + ' ' + c.LastName AS [FullName],
	   t.Price AS [TicketPrice],
	   a.AirportName AS [Destination]
FROM Customers AS c
JOIN Tickets AS t
ON c.CustomerID = t.CustomerID
JOIN Flights AS f
ON f.FlightID = t.FlightID
JOIN Airports AS a
ON a.AirportID = f.DestinationAirportID
AND f.Status = 'Delayed'
GROUP BY c.CustomerID, c.FirstName + ' ' + c.LastName, t.Price, a.AirportName
ORDER BY t.Price DESC, CustomerID

-- Task 9: Extract the Last 5 Flights, which are departing.

SELECT * FROM(
SELECT TOP(5) f.FlightID, f.DepartureTime, f.ArrivalTime,b.AirportName AS Origin, a.AirportName AS Destination
FROM  Flights AS f, Airports AS a, Airports AS b
WHERE a.AirportID = f.DestinationAirportID AND b.AirportID = f.OriginAirportID
AND Status = 'Departing' ORDER BY f.DepartureTime DESC) AS asd ORDER BY DepartureTime, FlightID
 
--
 
SELECT sdf.FlightID, sdf.DepartureTime, sdf.ArrivalTime, sdf.Origin,
 sdf.Destination FROM
(SELECT TOP (5) f.FlightID, f.DepartureTime, f.ArrivalTime, a2.AirportName AS Origin,
 a.AirportName AS Destination, RANK() OVER (ORDER BY f.DepartureTime DESC, f.FlightID) AS DEP  FROM  Flights AS f
INNER JOIN Airports AS a ON a.AirportID = f.DestinationAirportID
INNER JOIN Airports AS a2 ON a2.AirportID = f.OriginAirportID
WHERE  f.Status = 'Departing') AS sdf
ORDER BY sdf.DEP DESC, sdf.FlightID

-- Task 10: Extract all Customers below 21 years, which have already flew at least once

SELECT c.CustomerID, 
	   c.FirstName + ' ' + c.LastName AS [FullName],
	   DATEDIFF(year, CAST(DATEPART(year, c.DateOfBirth) AS varchar), '2016') AS [Age]
FROM Customers AS c
LEFT JOIN Tickets AS t
ON c.CustomerID = t.CustomerID
LEFT JOIN Flights AS f
ON f.FlightID = t.FlightID
WHERE t.TicketID IS NOT NULL
AND f.Status = 'Arrived'
GROUP BY c.CustomerID, c.FirstName + ' ' + c.LastName, DATEDIFF(year, CAST(DATEPART(year, c.DateOfBirth) AS varchar), '2016')
HAVING DATEDIFF(year, CAST(DATEPART(year, c.DateOfBirth) AS varchar), '2016') < 21
ORDER BY Age DESC, CustomerID

-- Task 11: Extract all Airports and the Count of People departing from them

SELECT a.AirportID,
	   a.AirportName,
	   COUNT(c.CustomerID) AS [Passengers]
FROM Airports AS a
LEFT JOIN Flights AS f
ON a.AirportID = f.OriginAirportID
LEFT JOIN Tickets AS t
ON t.FlightID = f.FlightID
LEFT JOIN Customers AS c 
ON c.CustomerID = t.CustomerID
WHERE f.Status = 'Departing'
GROUP BY a.AirportID, a.AirportName
HAVING COUNT(c.CustomerID) > 0
ORDER BY a.AirportID

--- Section 4: Programmability ---

-- Task 1: Review Registering Procedure

CREATE PROCEDURE usp_SubmitReview (@CustomerID INT,	@ReviewContent VARCHAR(255), @ReviewGrade INT, @AirlineName VARCHAR(30))
AS 
BEGIN
	BEGIN TRANSACTION

	DECLARE @CheckName VARCHAR(30) = (SELECT AirlineName FROM Airlines WHERE AirlineName = @AirlineName) 

	IF (@CheckName IS NULL)
		BEGIN
			ROLLBACK;
			RAISERROR('Airline does not exist.', 16, 1);
			RETURN;
		END
		
	DECLARE @Id INT = (
                SELECT TOP 1 cr.ReviewID
                FROM CustomerReviews AS cr
                ORDER BY cr.ReviewID DESC
            ) + 1

	INSERT INTO CustomerReviews(ReviewID, ReviewContent, ReviewGrade, AirlineID, CustomerID)
	VALUES (@Id,
			@ReviewContent, 
			@ReviewGrade, 
			(SELECT AirlineID FROM Airlines WHERE AirlineName = @AirlineName),
			@CustomerID)
			
	COMMIT
END

EXEC usp_SubmitReview 
		@ReviewContent = 'test', 
		@ReviewGrade = 6, 
		@AirlineName = 'Royal Airline',
		@CustomerID = 1

-- Task 2: Ticket Purchase Procedure

CREATE PROCEDURE usp_PurchaseTicket (@CustomerID INT, @FlightID INT, @TicketPrice MONEY, @Class VARCHAR(6), @Seat VARCHAR(5))
AS
BEGIN
    BEGIN TRANSACTION
   
    DECLARE @customerBallance MONEY =
    (
        SELECT cba.Balance
          FROM Customers AS c
          LEFT JOIN CustomerBankAccounts AS cba
            ON cba.CustomerID = c.CustomerID
         WHERE c.CustomerID = @CustomerID
    )
 
    IF(@customerBallance IS NULL)
        SET @customerBallance = 0
 
    IF(@customerBallance < @TicketPrice)
    BEGIN
        ROLLBACK
        RAISERROR('Insufficient bank account balance for ticket purchase.', 16, 1)
        RETURN
    END
 
    UPDATE CustomerBankAccounts
       SET Balance -= @TicketPrice
     WHERE CustomerID =
                         (
                             SELECT c.CustomerID
                              FROM Customers AS c
                             INNER JOIN CustomerBankAccounts AS cba
                                ON cba.CustomerID = c.CustomerID
                             WHERE c.CustomerID = @CustomerID
                         ) 
 
    DECLARE @Id INT = (
                          SELECT TOP 1 t.TicketID
                            FROM Tickets AS t
                           ORDER BY t.TicketID DESC
                      ) + 1
   
    INSERT INTO Tickets (TicketID, Price, Class, Seat, CustomerID, FlightID)
    VALUES(@Id, @TicketPrice, @Class, @Seat, @CustomerID, @FlightID)
   
    COMMIT
END

--- Section 5 (BONUS): Update Trigger ---

CREATE TABLE ArrivedFlights(
	FlightID INT,
	ArrivalTime DATETIME NOT NULL,
	Origin VARCHAR(50) NOT NULL,
	Destination VARCHAR(50) NOT NULL,
	Passengers INT NOT NULL,
	CONSTRAINT PK_ArrivedFlights PRIMARY KEY(FlightID)
)

CREATE TRIGGER T_ArrivedFlights
ON Flights  
AFTER UPDATE  
as begin
 
	if((select
	count(*)
	from inserted i
	join deleted d on i.FlightID = d.FlightID
	where i.Status = 'Arrived' and d.Status <> 'Arrived') = 0)
		return
 
	insert into [dbo].[ArrivedFlights]
	select FlightID,ArrivalTime, a.AirportName,aa.AirportName,
		(select count(*) from Flights f
		join Tickets t on t.FlightID = f.FlightID
		where t.FlightID in (select FlightID from inserted))
	from inserted i
	join Airports a on a.AirportID = i.OriginAirportID
	join Airports aa on aa.AirportID = i.DestinationAirportID
 
end

