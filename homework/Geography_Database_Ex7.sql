SELECT p.PeakName, m.MountainRange AS [Mountain], p.Elevation 
FROM dbo.Peaks AS p
INNER JOIN dbo.Mountains AS m
ON m.Id = p.MountainId
ORDER BY p.Elevation DESC, p.PeakName
-------------------------------------------------------------------
SELECT p.PeakName, m.MountainRange AS [Mountain], c.CountryName, c2.ContinentName
FROM dbo.Peaks AS p
INNER JOIN dbo.Mountains AS m
ON m.Id = p.MountainId
INNER JOIN dbo.MountainsCountries AS mc
ON mc.MountainId = m.Id
INNER JOIN dbo.Countries AS c
ON c.CountryCode = mc.CountryCode
INNER JOIN dbo.Continents as c2
ON c2.ContinentCode = c.ContinentCode
ORDER BY p.PeakName, c.CountryName
-------------------------------------------------------------------
SELECT c.CountryName, 
	   c2.ContinentName, 
	   CASE WHEN COUNT(cr.RiverId) = 0 THEN '0'
	   ELSE COUNT(cr.RiverId) END AS [RiversCount], 
	   CASE WHEN COUNT(cr.RiverId) = 0 THEN '0'
	   ELSE SUM(r.Length) END AS [TotalLength]
FROM dbo.Countries AS c
LEFT JOIN dbo.Continents AS c2
ON c.ContinentCode = c2.ContinentCode
LEFT JOIN dbo.CountriesRivers AS cr
ON c.CountryCode = cr.CountryCode
LEFT JOIN dbo.Rivers AS r
ON cr.RiverId = r.Id
GROUP BY c.CountryName, c2.ContinentName
ORDER BY [RiversCount] DESC, [TotalLength] DESC, c.CountryName 
--------------------------------------------------------------------
SELECT cu.CurrencyCode, 
	   cu.Description AS [Currency], 
	   COUNT(c.CurrencyCode) AS [NumberOfCountries]
FROM dbo.Currencies AS cu
LEFT JOIN dbo.Countries AS c
ON c.CurrencyCode = cu.CurrencyCode
GROUP BY cu.CurrencyCode, cu.Description
ORDER BY [NumberOfCountries] DESC, cu.Description
--------------------------------------------------------------------
SELECT c2.ContinentName, 
	   SUM(CAST(c.AreaInSqKm AS bigint)) AS [CountriesArea], 
	   SUM(CAST(c.Population AS bigint)) AS [CountriesPopulation]
FROM dbo.Continents AS c2
JOIN dbo.Countries AS c
ON c.ContinentCode = c2.ContinentCode
GROUP BY c2.ContinentName
ORDER BY [CountriesPopulation] DESC
--------------------------------------------------------------------
CREATE TABLE Monasteries
(
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(50),
    CountryCode CHAR(2),
    CONSTRAINT FK_Monasteries_Countries FOREIGN KEY (CountryCode)
    REFERENCES Countries(CountryCode)
)
 
INSERT INTO Monasteries(Name, CountryCode) VALUES
('Rila Monastery “St. Ivan of Rila”', 'BG'),
('Bachkovo Monastery “Virgin Mary”', 'BG'),
('Troyan Monastery “Holy Mother''s Assumption”', 'BG'),
('Kopan Monastery', 'NP'),
('Thrangu Tashi Yangtse Monastery', 'NP'),
('Shechen Tennyi Dargyeling Monastery', 'NP'),
('Benchen Monastery', 'NP'),
('Southern Shaolin Monastery', 'CN'),
('Dabei Monastery', 'CN'),
('Wa Sau Toi', 'CN'),
('Lhunshigyia Monastery', 'CN'),
('Rakya Monastery', 'CN'),
('Monasteries of Meteora', 'GR'),
('The Holy Monastery of Stavronikita', 'GR'),
('Taung Kalat Monastery', 'MM'),
('Pa-Auk Forest Monastery', 'MM'),
('Taktsang Palphug Monastery', 'BT'),
('Sümela Monastery', 'TR')
 
ALTER TABLE Countries
ADD IsDeleted SET DEFAULT 0

UPDATE Countries
SET IsDeleted = 1
    WHERE CountryCode IN (
        SELECT c.CountryCode FROM Countries c
         INNER JOIN CountriesRivers cr ON cr.CountryCode = c.CountryCode
         INNER JOIN Rivers r ON r.Id = cr.RiverId
         GROUP BY c.CountryCode
         HAVING COUNT(r.Id) > 3 )
 
SELECT m.Name , c.CountryName FROM Monasteries AS m
    INNER JOIN Countries c ON c.CountryCode = m.CountryCode
WHERE c.IsDeleted = 0
ORDER BY m.Name
-------------------------------------------------------------------------
UPDATE Countries
SET CountryName = 'Burma'
WHERE CountryName = 'Myanmar'
 
INSERT INTO Monasteries VALUES ('Hanga Abbey', (SELECT CountryCode FROM Countries WHERE CountryName = 'Tanzania'))
INSERT INTO Monasteries VALUES ('Myin-Tin-Daik', (SELECT CountryCode FROM Countries WHERE CountryName = 'Myanmar'))
 
SELECT con.ContinentName, c.CountryName, COUNT(m.Id) AS 'MonasteriesCount' FROM Monasteries AS m
    RIGHT OUTER JOIN Countries AS c
    ON m.CountryCode = c.CountryCode
    RIGHT OUTER JOIN Continents AS con
    ON con.ContinentCode = c.ContinentCode
WHERE c.IsDeleted = 0
GROUP BY con.ContinentName, c.CountryName
ORDER BY COUNT(m.Id) DESC, c.CountryName