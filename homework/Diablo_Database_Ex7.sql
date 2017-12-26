CREATE TRIGGER tr_Items ON UserGameItems
AFTER INSERT AS
BEGIN 
BEGIN TRAN 
DECLARE @itemMinLevel INT = (SELECT i.MinLevel FROM Items AS i JOIN UserGameItems AS ugi ON ugi.ItemId = i.Id WHERE i.Id = ugi.ItemId )
DECLARE @userLevel INT = (SELECT ug.Level FROM UsersGames AS ug JOIN UserGameItems AS ugi ON ugi.UserGameId = ug.GameId WHERE ugi.UserGameId = ug.GameId)
IF(@itemMinLevel > @userLevel)
BEGIN ROLLBACK END
ELSE BEGIN COMMIT END
END
-----------------------------------------------------------------------
create function ufn_CashInUsersGames(@gameName nvarchar(50))
returns table
as
return (select sum(t1.Cash) as [SumCash] from(
select ug.Id, ug.Cash, ROW_NUMBER() OVER(ORDER BY ug.Cash desc) AS Row from UsersGames as ug
inner join Games as g
on ug.GameId = g.Id
where g.Name = @gameName
) as t1
where t1.Row%2=1)
------------------------------------------------------------------------
begin transaction
declare @level11_12ItemsPrice money = (select sum(Price) from Items where MinLevel in (11,12))
declare @availableCash money = (select Cash from UsersGames where GameId = 87)
 
-- Level 11 and 12
if ((@availableCash - @level11_12ItemsPrice) >=0)
    begin
 
    -- taking the cash out
        update UsersGames
        set Cash -= @level11_12ItemsPrice
        where Id = 110
 
        if (@@ROWCOUNT <> 1)
            begin
                rollback
                return
            end
        -- inserting the items into the game
        insert into UserGameItems (UserGameId, ItemId) select 110,i.Id from Items as i where MinLevel in (11,12)
       
                if (@@ROWCOUNT <> (select count(Price) from Items where MinLevel in (11,12)))
            begin
                rollback
                return
            end
            commit
        end else
            rollback
 
 
 
 
begin transaction
declare @availableCash2 money = (select Cash from UsersGames where GameId = 87)
declare @level19_21ItemsPrice money = (select sum(Price) from Items where MinLevel in (19,20,21))
-- Level 19,20 and 21
    if ((@availableCash2 - @level19_21ItemsPrice) >=0)
    begin
 
    -- taking the cash out
        update UsersGames
        set Cash -= @level19_21ItemsPrice
        where Id = 110
 
        if (@@ROWCOUNT <> 1)
            begin
                rollback
                return
            end
        -- inserting the items into the game
        insert into UserGameItems (UserGameId, ItemId) select 110,i.Id from Items as i where MinLevel in (19,20,21)
        select * from UserGameItems order by UserGameId
        select * from Games
                if (@@ROWCOUNT <> (select count(Price) from Items where MinLevel in (19,20,21)))
            begin
                rollback
                return
            end
            commit 
    end else
    begin
        rollback
    end
 
 
select i.Name AS 'Item Name' from UserGameItems as ugi
inner join Items as i
on ugi.ItemId = i.Id
where UserGameId = 110
order by i.Name
---------------------------------------------------------------------------
SELECT [Email Provider], COUNT(u2.Id) AS [Number Of Users]
FROM (
	SELECT Id, Email, SUBSTRING(Email, CHARINDEX('@', Email) + 1, LEN(Email)) AS [Email Provider] 
	FROM Users AS u
	GROUP BY Email,Id
) AS u2
WHERE SUBSTRING(Email, CHARINDEX('@', Email) + 1, LEN(Email)) = [Email Provider]
GROUP BY [Email Provider]
ORDER BY [Number Of Users] DESC, [Email Provider]
---------------------------------------------------------------------------
SELECT g.Name, gt.Name, u.Username, ug.Level, ug.Cash, c.Name
FROM dbo.Games AS g
JOIN dbo.GameTypes AS gt
ON gt.Id = g.GameTypeId
JOIN dbo.UsersGames AS ug
ON ug.GameId = g.Id
JOIN dbo.Users AS u
ON u.Id = ug.UserId
JOIN dbo.Characters AS c
ON c.Id = ug.CharacterId
ORDER BY ug.Level DESC, Username, g.Name
---------------------------------------------------------------------------
SELECT u.Username, g.Name, COUNT(ugi.ItemId) AS [Items Count], SUM(i.Price) AS [Items Price] 
FROM Users AS u
INNER JOIN dbo.UsersGames AS ug
ON ug.UserId = u.Id
INNER JOIN dbo.Games AS g
ON ug.GameId = g.Id
INNER JOIN dbo.UserGameItems AS ugi
ON ugi.UserGameId = ug.Id
INNER JOIN dbo.Items AS i
ON ugi.ItemId = i.Id
GROUP BY u.Username, g.Name
HAVING COUNT(ugi.ItemId) >= 10
ORDER BY [Items Count] DESC, [Items Price] DESC, u.Username
-----------------------------------------------------------------------------
SELECT u.Username, 
	   g.Name AS [Game], 
	   MAX(c.Name) AS [Character],
	   SUM(s3.Strength) + MAX(s2.Strength) + MAX(s.Strength) AS [Strength],
	   SUM(s3.Defence) + MAX(s2.Defence) + MAX(s.Defence) AS [Defence],
	   SUM(s3.Speed) + MAX(s2.Speed) + MAX(s.Speed) AS [Speed], 
	   SUM(s3.Mind) + MAX(s2.Mind) + MAX(s.Mind) AS [Mind], 
	   SUM(s3.Luck) + MAX(s2.Luck) + MAX(s.Luck) AS [Luck]
FROM dbo.Users AS u
INNER JOIN dbo.UsersGames AS ug
ON ug.UserId = u.Id
INNER JOIN dbo.Games AS g
ON ug.GameId = g.Id
INNER JOIN dbo.Characters AS c
ON ug.CharacterId = c.Id
INNER JOIN [dbo].[Statistics] AS s
ON s.Id = c.StatisticId
INNER JOIN dbo.GameTypes AS gt
ON g.GameTypeId = gt.Id
INNER JOIN [dbo].[Statistics] AS s2
ON gt.BonusStatsId = s2.Id
INNER JOIN dbo.UserGameItems AS ugi
ON ugi.UserGameId = ug.Id
INNER JOIN dbo.Items AS i
ON ugi.ItemId = i.Id
INNER JOIN [dbo].[Statistics] AS s3
ON s3.Id = i.StatisticId
GROUP BY u.Username, g.Name
ORDER BY [Strength] DESC, [Defence] DESC, [Speed] DESC, [Mind] DESC, [Luck] DESC
-----------------------------------------------------------------------------
SELECT i.Name, i.Price, i.MinLevel, s.Strength, s.Defence, s.Speed, s.Luck, s.Mind
FROM dbo.Items AS i
INNER JOIN [dbo].[Statistics] AS s
ON s.Id = i.StatisticId
WHERE s.Speed > (SELECT AVG(s2.Speed)
				 FROM [dbo].[Statistics] AS s2)
AND s.Mind > (SELECT AVG(s2.Mind)
				 FROM [dbo].[Statistics] AS s2)
AND s.Luck > (SELECT AVG(s2.Luck)
				 FROM [dbo].[Statistics] AS s2)
ORDER BY i.Name
-----------------------------------------------------------------------------
SELECT i.Name AS [Item], i.Price, i.MinLevel, gt.Name AS [Forbidden Game Type]
FROM dbo.Items AS i
LEFT JOIN dbo.GameTypeForbiddenItems AS gtfi
ON gtfi.ItemId = i.Id
LEFT JOIN dbo.GameTypes AS gt
ON gtfi.GameTypeId = gt.Id
ORDER BY gt.Name DESC, i.Name
-----------------------------------------------------------------------------
DECLARE @userId INT =
(
    SELECT ug.Id
      FROM Users AS u
     INNER JOIN UsersGames AS ug
        ON u.Id = ug.UserId
     INNER JOIN Games AS g
        ON g.Id = ug.GameId
     WHERE u.Username = 'Alex' AND g.Name = 'Edinburgh'
)
 
INSERT INTO UserGameItems (ItemId, UserGameId)
SELECT i.Id, @userId
  FROM Items AS i
 WHERE i.Name IN ('Blackguard', 'Bottomless Potion of Amplification',
                  'Eye of Etlich (Diablo III)', 'Gem of Efficacious Toxin',
                  'Golden Gorget of Leoric', 'Hellfire Amulet')
 
UPDATE UsersGames
   SET Cash -=
(
    SELECT SUM(i.Price)
      FROM Items AS i
     WHERE i.Name IN ('Blackguard', 'Bottomless Potion of Amplification',
                  'Eye of Etlich (Diablo III)', 'Gem of Efficacious Toxin',
                  'Golden Gorget of Leoric', 'Hellfire Amulet')
)
 WHERE Id =
(
    SELECT ug.Id
      FROM Users AS u
     INNER JOIN UsersGames AS ug
        ON u.Id = ug.UserId
     INNER JOIN Games AS g
        ON g.Id = ug.GameId
     WHERE u.Username = 'Alex' AND g.Name = 'Edinburgh'
)
 
SELECT u.Username, g.Name, ug.Cash, i.Name AS [Item Name]
  FROM Users AS u
 INNER JOIN UsersGames AS ug
    ON u.Id = ug.UserId
 INNER JOIN Games AS g
    ON ug.GameId = g.Id
 INNER JOIN UserGameItems AS ugi
    ON ugi.UserGameId = ug.Id
 INNER JOIN Items AS i
    ON ugi.ItemId = i.Id
 WHERE g.Name = 'Edinburgh'
 ORDER BY i.Name