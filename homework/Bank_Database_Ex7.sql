CREATE PROC usp_GetHoldersFullName
AS
	SELECT FirstName + ' ' + LastName AS [Full Name]
	FROM AccountHolders

EXEC usp_GetHoldersFullName
-------------------------------------------------------
CREATE PROC usp_GetHoldersWithBalanceHigherThan(@LIMIT MONEY)
AS 
BEGIN
	SELECT FirstName, LastName
	FROM AccountHolders AS ac
	LEFT JOIN Accounts AS a 
	ON a.AccountHolderId = ac.Id
	GROUP BY FirstName, LastName
	HAVING SUM(a.Balance) >= @LIMIT
END

EXEC usp_GetHoldersWithBalanceHigherThan @LIMIT = 20000
-------------------------------------------------------------
CREATE FUNCTION ufn_CalculateFutureValue(
	@S MONEY, @R float, @T INT
) RETURNS MONEY
BEGIN
	DECLARE @RESULT MONEY = @S
	WHILE @T > 0
	BEGIN 
		SET @RESULT += @R * @RESULT;
		SET @T -= 1; 
	END

	RETURN @RESULT
END

SELECT dbo.ufn_CalculateFutureValue(1000,0.1,5)
----------------------------------------------------
CREATE PROC usp_CalculateFutureValueForAccount(@ACCID INT, @INTRATE float)
AS 
BEGIN
	SELECT a.AccountHolderId AS [Account Id], 
		   ac.FirstName AS [First Name], 
		   ac.LastName AS [Last Name], 
		   a.Balance AS [Current Balance], 
		   dbo.ufn_CalculateFutureValue(a.Balance, @INTRATE, 5) AS [Balance in 5 years] 
	FROM AccountHolders AS ac
	JOIN Accounts AS a
	ON ac.Id = a.AccountHolderId
	WHERE a.Id = @ACCID
END

EXEC usp_CalculateFutureValueForAccount @ACCID = 1, @INTRATE = 0.1
--------------------------------------------------------------------
CREATE PROC usp_DepositMoney(@AccountId INT, @moneyAmount MONEY)
AS
	BEGIN
		BEGIN TRANSACTION
		UPDATE Accounts SET Balance = Balance + @moneyAmount
		WHERE Id = @AccountId
		IF @@ROWCOUNT <> 1
		BEGIN 
			ROLLBACK;
			RAISERROR('Invalid Account!', 16, 1);
			RETURN;
		END

		COMMIT
	END
----------------------------------------------------------------------
CREATE PROC usp_WithdrawMoney(@AccountId INT, @moneyAmount MONEY)
AS
	BEGIN
		BEGIN TRANSACTION
		UPDATE Accounts SET Balance = Balance - @moneyAmount
		WHERE Id = @AccountId
		IF @@ROWCOUNT <> 1
		BEGIN 
			ROLLBACK;
			RAISERROR('Invalid Account', 16, 1);
			RETURN;
		END

		COMMIT
	END
---------------------------------------------------------------------
CREATE PROC usp_TransferMoney(@senderId INT, @receiverId INT, @amount MONEY)
AS
	BEGIN
		BEGIN TRANSACTION
		DECLARE @amountSender money = (SELECT Balance FROM Accounts WHERE Id = @senderId)
		IF @amount >= 0 AND (@amountSender - @amount) >= 0
			BEGIN
				EXEC usp_WithdrawMoney @AccountId = @senderId, @moneyAmount = @amount
				IF @@ROWCOUNT <> 1
					BEGIN 
						ROLLBACK;
						RAISERROR('Invalid Account', 16, 1);
						RETURN;
					END
				ELSE
				EXEC usp_DepositMoney @AccountId = @receiverId, @moneyAmount = @amount
				IF @@ROWCOUNT <> 1
					BEGIN 
						ROLLBACK;
						RAISERROR('Invalid Account', 16, 1);
						RETURN;
					END
			END	
		COMMIT	
	END
----------------------------------------------------------------
CREATE TABLE Logs (
	LogId INT IDENTITY,
	AccountId INT,
	OldSum MONEY,
	NewSum MONEY,
	CONSTRAINT PK_Logs PRIMARY KEY (LogId),
	CONSTRAINT FK_Logs_Accounts FOREIGN KEY(AccountId) REFERENCES Accounts(Id)
)

CREATE TRIGGER T_Accounts_After_Update ON Accounts AFTER UPDATE
AS
BEGIN
	INSERT INTO Logs (AccountId, OldSum, NewSum)
	SELECT i.Id, d.Balance, i.Balance FROM inserted AS i
	INNER JOIN deleted AS d ON d.Id = i.Id 
END
----------------------------------------------------------------
CREATE TABLE NotificationEmails(
	Id INT IDENTITY,
	Recipient INT,
	Subject varchar(max),
	Body varchar(max),
	CONSTRAINT PK_NE PRIMARY KEY (Id),
	CONSTRAINT FK_NE_Accounts FOREIGN KEY(Recipient) REFERENCES Accounts(Id)
)

CREATE TRIGGER T_Accounts_After_Insert ON Logs AFTER INSERT
AS
BEGIN
	INSERT INTO NotificationEmails (Recipient, Subject, Body)
	SELECT i.AccountId, 
		   'Balance change for account: ' + CAST(i.AccountId AS varchar(max)),  
		   'On ' + CAST(GETDATE() AS varchar(max)) + ' your balance was changed from ' + CAST(i.OldSum AS varchar(max)) + ' to ' + CAST(i.NewSum AS varchar(max)) + '.'
	FROM inserted AS i
END

UPDATE Accounts
SET Balance += 10
WHERE Id = 1

