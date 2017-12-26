SELECT COUNT(Id) FROM dbo.WizzardDeposits

SELECT MAX(MagicWandSize) AS LongestMagicWand FROM dbo.WizzardDeposits

SELECT DepositGroup,
	   MAX(MagicWandSize) AS LongestMagicWand 
FROM dbo.WizzardDeposits
GROUP BY DepositGroup

SELECT DepositGroup
FROM WizzardDeposits
GROUP BY [DepositGroup]
HAVING AVG(MagicWandSize) <
(
SELECT AVG(MagicWandSize) FROM WizzardDeposits
)

select top 1 with ties depositgroup
from [dbo].[WizzardDeposits]
group by DepositGroup
order by avg(magicwandsize) asc

SELECT DepositGroup, 
	   SUM(DepositAmount) AS [TotalSum]
FROM dbo.WizzardDeposits
WHERE MagicWandCreator = 'Ollivander family'
GROUP BY DepositGroup
HAVING SUM(DepositAmount) < 150000
ORDER BY [TotalSum] DESC

SELECT DepositGroup, 
	   MagicWandCreator, 
	   MIN(DepositCharge) AS [MinDepositCharge] 
FROM dbo.WizzardDeposits
GROUP BY DepositGroup, MagicWandCreator
ORDER BY MagicWandCreator, DepositGroup

SELECT 
CASE 
WHEN Age BETWEEN 0 AND 10 THEN '[0-10]'
WHEN Age BETWEEN 11 AND 20 THEN '[11-20]'
WHEN Age BETWEEN 21 AND 30 THEN '[21-30]'
WHEN Age BETWEEN 31 AND 40 THEN '[31-40]'
WHEN Age BETWEEN 41 AND 50 THEN '[41-50]'
WHEN Age BETWEEN 51 AND 60 THEN '[51-60]'
WHEN Age >60 THEN '[61+]'
END AS [AgeGroups],COUNT(Id) AS WizardCount
FROM WizzardDeposits
GROUP BY CASE 
WHEN Age BETWEEN 0 AND 10 THEN '[0-10]'
WHEN Age BETWEEN 11 AND 20 THEN '[11-20]'
WHEN Age BETWEEN 21 AND 30 THEN '[21-30]'
WHEN Age BETWEEN 31 AND 40 THEN '[31-40]'
WHEN Age BETWEEN 41 AND 50 THEN '[41-50]'
WHEN Age BETWEEN 51 AND 60 THEN '[51-60]'
WHEN Age >60 THEN '[61+]'
END

SELECT w.AgeGroup, COUNT(*) AS 'WizardCount' 
FROM
(
SELECT 'AgeGroup'=
CASE
WHEN z.Age BETWEEN 0 AND 10 THEN '[0-10]'
WHEN z.Age BETWEEN 11 AND 20 THEN '[11-20]'
WHEN z.Age BETWEEN 21 AND 30 THEN '[21-30]'
WHEN z.Age BETWEEN 31 AND 40 THEN '[31-40]'
WHEN z.Age BETWEEN 41 AND 50 THEN '[41-50]'
WHEN z.Age BETWEEN 51 AND 60 THEN '[51-60]'
WHEN z.Age >= 61 THEN '[61+]'
END
FROM WizzardDeposits AS z
) AS w
GROUP BY w.AgeGroup

SELECT LEFT(FirstName, 1) AS FirstLetter 
FROM dbo.WizzardDeposits
WHERE DepositGroup = 'Troll Chest'
GROUP BY LEFT(FirstName, 1)

SELECT DepositGroup,
	   IsDepositExpired,
	   AVG(DepositInterest) AS AverageInterest 
FROM dbo.WizzardDeposits
WHERE DepositStartDate > '01/01/1985'
GROUP BY DepositGroup, IsDepositExpired
ORDER BY DepositGroup DESC, IsDepositExpired ASC

SELECT
	SUM(RichPoor.[Difference]) AS SumDifference
FROM (
	SELECT
		HostWizard.DepositAmount - (
		SELECT
			DepositAmount
		FROM
			WizzardDeposits as GuestWizard
		WHERE
			GuestWizard.Id = HostWizard.Id + 1
		) AS Difference
	FROM 
		WizzardDeposits AS HostWizard
	) AS RichPoor

SELECT  SUM(HostWizardDeposit - GuestWizardDeposit) AS [SumDifference]
FROM    (
        SELECT  Id,
                FirstName AS HostWizard,
                DepositAmount AS HostWizardDeposit
        FROM    [WizzardDeposits]
        ) AS hw
JOIN    (
        SELECT  Id - 1 AS Id,
                FirstName AS GuestWizard,
                DepositAmount AS GuestWizardDeposit
        FROM    [WizzardDeposits]
        ) AS gw ON hw.Id = gw.Id