--- Section 1. DDL ---

-- 1. Database design 

CREATE TABLE Users(
	Id INT IDENTITY(1,1),
	Nickname VARCHAR(25),
	Gender CHAR,
	Age INT,
	LocationId INT,
	CredentialId INT UNIQUE,
	CONSTRAINT PK_Users PRIMARY KEY (Id),
	CONSTRAINT FK_Users_Locations FOREIGN KEY (LocationId) REFERENCES Locations(Id),
	CONSTRAINT FK_Users_Credentials FOREIGN KEY (CredentialId) REFERENCES Credentials(Id)
)

CREATE TABLE Locations(
	Id INT,
	Latitude float,
	Longitude float,
	CONSTRAINT PK_Locations PRIMARY KEY (Id)
)

CREATE TABLE Credentials(
	Id INT,
	Email VARCHAR(30),
	Password VARCHAR(20),
	CONSTRAINT PK_Credentials PRIMARY KEY (Id)
)

CREATE TABLE Chats(
	Id INT,
	Title VARCHAR(32),
	StartDate DATE,
	IsActive BIT,
	CONSTRAINT PK_Chats PRIMARY KEY (Id)
)

CREATE TABLE Messages(
	Id INT,
	Content VARCHAR(200),
	SentOn DATE,
	ChatId INT,
	UserId INT,
	CONSTRAINT PK_Messages PRIMARY KEY (Id),
	CONSTRAINT FK_Messages_Chats FOREIGN KEY (ChatId) REFERENCES Chats(Id),
	CONSTRAINT FK_Messages_Users FOREIGN KEY (UserId) REFERENCES Users(Id)
)

CREATE TABLE UsersChats(
	UserId INT,
	ChatId INT,
	CONSTRAINT PK_UsersChats PRIMARY KEY (ChatId, UserId),
	CONSTRAINT FK_UsersChats_Users FOREIGN KEY (UserId) REFERENCES Users(Id),
	CONSTRAINT FK_UsersChats_Chats FOREIGN KEY (ChatId) REFERENCES Chats(Id)
)

--- Section 2. DML ---

-- 2. Insert

INSERT Messages (Content, SentOn, ChatId, UserId)
SELECT 
  CONCAT(u.Age, '-', u.Gender, '-', l.Latitude, '-', l.Longitude),
  CONVERT(DATE, GETDATE()),
  [ChatId] = CASE
    WHEN u.Gender = 'F' THEN CEILING(SQRT((u.Age * 2)))
    WHEN u.Gender = 'M' THEN CEILING(POWER((u.Age / 18), 3))
  END,
  u.Id
FROM Users AS u
INNER JOIN Locations AS l
ON l.Id = u.LocationId
WHERE u.Id >= 10 AND u.Id <= 20

-- 3. Update
      
Update Chats
set StartDate = 
m.SentOn from Chats c
join Messages m on m.ChatId =c.Id
where StartDate > SentOn

-- 4. Delete

DELETE FROM Locations 
WHERE Id NOT IN (
	SELECT l.Id
	FROM Locations AS l
	INNER JOIN Users AS u
	ON u.LocationId = l.Id)

--- Section 3. Querying ---

-- 5. Age Range
      
SELECT Nickname, Gender, Age
FROM Users 
WHERE Age BETWEEN 21 AND 38

-- 6. Messages

SELECT Content, SentOn
FROM Messages
WHERE SentOn > '20140512'
AND Content LIKE '%just%'
ORDER BY Id DESC
      
-- 7. Chats
      
SELECT Title, IsActive
FROM Chats
WHERE (IsActive = 0
AND LEN(Title) < 5)
OR Title LIKE '__tl%'
ORDER BY Title DESC

-- 8. Chat Messages
      
SELECT c.Id, c.Title, m.Id
FROM Chats AS c
JOIN Messages AS m
ON m.ChatId = c.Id
WHERE m.SentOn < '20120326'
AND RIGHT(Title, 1) = 'x'
ORDER BY c.Id, m.Id

-- 9. Message Count

SELECT TOP(5) c.Id, COUNT(m.Id) AS [TotalMessages]
FROM Chats AS c
RIGHT JOIN Messages AS m
ON m.ChatId = c.Id
WHERE m.Id < 90
GROUP BY c.Id
ORDER BY [TotalMessages] DESC, c.Id

-- 10 .Credentials
      
SELECT Nickname, Email, Password
FROM Credentials
JOIN Users
ON Users.CredentialId = Credentials.Id
WHERE Email LIKE '%co.uk'
ORDER BY Email

-- 11 .Locations
      
SELECT Id, Nickname, Age
FROM Users AS u
WHERE LocationId IS NULL

-- 12 .Left Users

SELECT m.Id, m.ChatId, m.UserId
  FROM Messages AS m
 WHERE (m.UserId NOT IN (SELECT uc.UserId
                           FROM UsersChats AS uc
                          INNER JOIN Messages AS m
                             ON uc.ChatId = m.ChatId
                          WHERE uc.UserId = m.UserId
                            AND m.ChatId = 17 )
        OR m.UserId is null)
AND m.ChatId = 17
ORDER BY m.Id DESC

-- 13 .Users in Bulgaria
      
SELECT Nickname, Title, Latitude, Longitude
FROM Users AS u
LEFT JOIN UsersChats AS uc
ON u.Id = uc.UserId
LEFT JOIN Chats AS c
ON c.Id = uc.ChatId
LEFT JOIN Locations AS l
ON u.LocationId = l.Id
WHERE Latitude BETWEEN 41.14 AND CAST(44.13 AS NUMERIC)
AND Longitude BETWEEN 22.21 AND CAST(28.36 AS NUMERIC)
ORDER BY Title

-- 14 .Last Chat

SELECT TOP (1) WITH TIES c.Title, m.Content
FROM Chats AS c
LEFT JOIN Messages AS m
ON m.ChatId = c.Id
ORDER BY c.StartDate DESC

--- Section 4. Programmability ---

-- 15. Radians

CREATE FUNCTION udf_GetRadians(@Degrees FLOAT)
RETURNS FLOAT
AS 
BEGIN	
	RETURN (@Degrees * PI()) / 180;
END

SELECT dbo.udf_GetRadians(22.12);
       
-- 16. Change Password
       
CREATE PROCEDURE udp_ChangePassword(@Email VARCHAR(max), @NewPassword VARCHAR(max))
AS 
BEGIN
	BEGIN TRANSACTION

	IF NOT EXISTS(SELECT Email FROM Credentials WHERE Email = @Email)
		BEGIN
			ROLLBACK;
			RAISERROR('The email does''t exist!', 16, 1);
			RETURN;
		END
	ELSE
		BEGIN
			UPDATE Credentials
			SET Password = @NewPassword
			WHERE Email = @Email
		END

	COMMIT
END

-- 17. Send Message
       
ALTER PROCEDURE udp_SendMessage(@UserId INT, @ChatId INT, @Content varchar(max))
AS
BEGIN
	BEGIN TRANSACTION

	IF NOT EXISTS(SELECT ChatId FROM UsersChats WHERE ChatId = @ChatId AND UserId = @UserId)
		BEGIN
			ROLLBACK;
			RAISERROR('There is no chat with that user!', 16, 1);
			RETURN;
		END
	ELSE
		BEGIN
			DECLARE @Id INT = (SELECT MAX(Id) FROM Messages) + 1;
			INSERT INTO Messages (Id, Content, SentOn, ChatId, UserId)
			VALUES(@Id, @Content, GETDATE(), @ChatId, @UserId) 
		END

	COMMIT
END

EXEC dbo.udp_SendMessage 19, 17, 'Awesome'

-- 18. Log Messages

CREATE TABLE MessageLogs(
	Id INT,
	Content VARCHAR(200),
	SentOn DATE,
	ChatId INT,
	UserId INT,
	CONSTRAINT PK_MessageLogs PRIMARY KEY (Id),
	CONSTRAINT FK_MessageLogs_Chats FOREIGN KEY (ChatId) REFERENCES Chats(Id),
	CONSTRAINT FK_MessageLogs_Users FOREIGN KEY (UserId) REFERENCES Users(Id)
)

CREATE TRIGGER tr_DeleteMessages
ON Messages
INSTEAD OF DELETE
AS

DECLARE @DeletedId INT = (SELECT Id FROM deleted)

INSERT INTO MessageLogs SELECT Id, Content, SentOn, ChatId, UserId FROM deleted

DELETE FROM Messages
WHERE Id = @DeletedId

--- Section 5. Bonus ---

-- 19. Delete users

CREATE TRIGGER tr_DeleteUserRelations
ON Users
INSTEAD OF DELETE
AS
 
DECLARE @deletedUserId int = (SELECT Id FROM deleted)
 
DELETE FROM UsersChats
WHERE UserId = @deletedUserId
 
DELETE FROM Messages
WHERE UserId = @deletedUserId
 
DELETE FROM Users
WHERE Id = @deletedUserId