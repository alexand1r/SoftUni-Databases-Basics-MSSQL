SELECT c.CountryCode, m.MountainRange, p.PeakName, p.Elevation
FROM dbo.Countries AS c
JOIN dbo.MountainsCountries AS mc
ON mc.CountryCode = c.CountryCode
JOIN dbo.Mountains AS m
ON mc.MountainId = m.Id
JOIN dbo.Peaks AS p
ON p.MountainId = m.Id
WHERE p.Elevation > 2835
AND c.CountryCode = 'BG'
ORDER BY p.Elevation DESC

SELECT c.CountryCode, COUNT(m.MountainRange) AS [MountainRanges]
FROM dbo.Countries AS c
JOIN dbo.MountainsCountries AS mc
ON mc.CountryCode = c.CountryCode
JOIN dbo.Mountains AS m
ON mc.MountainId = m.Id
WHERE c.CountryCode IN ('BG', 'RU', 'US')
GROUP BY c.CountryCode
ORDER BY c.CountryCode

SELECT TOP (5) c.CountryName, r.RiverName
FROM dbo.Countries AS c
LEFT JOIN dbo.CountriesRivers AS cr
ON c.CountryCode = cr.CountryCode
LEFT JOIN dbo.Rivers AS r
ON cr.RiverId = r.Id
WHERE c.ContinentCode = 'AF'
ORDER BY c.CountryName ASC

SELECT ContinentCode, 
	   CurrencyCode, 
	   CurrencyUsage 
FROM
	(SELECT ContinentCode, 
		    CurrencyCode, 
			CurrencyUsage, 
			DENSE_RANK() OVER (PARTITION BY ContinentCode ORDER BY CurrencyUsage DESC) AS [Rank] 
	 FROM
		(SELECT ContinentCode, 
				CurrencyCode, 
				COUNT(CountryCode) AS CurrencyUsage 
		 FROM Countries
		 GROUP BY ContinentCode, CurrencyCode
		 HAVING COUNT(CountryCode) > 1) AS cudata) AS rankedcudata
WHERE [Rank] = 1

SELECT COUNT(*)
FROM dbo.Countries AS c
LEFT JOIN dbo.MountainsCountries AS mc
ON mc.CountryCode = c.CountryCode
WHERE mc.MountainId IS NULL

SELECT TOP(5) CountryName, 
		[HighestPeakElevation], 
		[LongestRiverLength]
FROM
	 (SELECT c.CountryName, 
	   MAX(p.Elevation) AS [HighestPeakElevation], 
	   MAX(r.Length) AS [LongestRiverLength]
	   FROM dbo.Countries AS c
	   LEFT JOIN dbo.MountainsCountries AS mc
	   ON mc.CountryCode = c.CountryCode
	   LEFT JOIN dbo.Mountains AS m
	   ON mc.MountainId = m.Id
	   LEFT JOIN dbo.Peaks AS p
	   ON m.Id = p.MountainId
	   LEFT JOIN dbo.CountriesRivers AS cr
	   ON cr.CountryCode = c.CountryCode
	   LEFT JOIN dbo.Rivers AS r
	   ON cr.RiverId = r.Id
	   GROUP BY c.CountryName) AS cudata
ORDER BY HighestPeakElevation DESC, LongestRiverLength DESC, CountryName

SELECT TOP(5) Country, 
		[HighestPeakName],
		[HighestPeakElevation],
		[Mountain]
FROM
	 (SELECT c.CountryName AS [Country],
	   CASE WHEN p.PeakName IS NULL THEN '(no highest peak)'
	   ELSE p.PeakName END AS [HighestPeakName],
	   CASE WHEN MAX(p.Elevation) IS NULL THEN '0'
	   ELSE MAX(p.Elevation) END AS [HighestPeakElevation],
	   CASE WHEN m.MountainRange IS NULL THEN '(no mountain)'
	   ELSE m.MountainRange END AS [Mountain]
	   FROM dbo.Countries AS c
	   LEFT JOIN dbo.MountainsCountries AS mc
	   ON mc.CountryCode = c.CountryCode
	   LEFT JOIN dbo.Mountains AS m
	   ON mc.MountainId = m.Id
	   LEFT JOIN dbo.Peaks AS p
	   ON m.Id = p.MountainId
	   GROUP BY c.CountryName, p.PeakName, m.MountainRange) AS cudata
ORDER BY Country, HighestPeakName

SELECT TOP (5) WITH TIES c.CountryName, 
	ISNULL(p.PeakName,'(no highest peak)' ) AS 'HighestPeakName', 
	ISNULL(MAX(p.Elevation), 0) AS 'HighestPeakElevation', 
	ISNULL(m.MountainRange, '(no mountain)')
FROM Countries AS c
LEFT JOIN MountainsCountries AS mc
ON c.CountryCode = mc.CountryCode
LEFT JOIN Mountains AS m
ON mc.MountainId = m.Id
LEFT JOIN Peaks AS p
ON m.Id = p.MountainId
GROUP BY c.CountryName, p.PeakName, m.MountainRange
ORDER BY c.CountryName, p.PeakName