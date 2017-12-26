SELECT CountryName, IsoCode FROM dbo.Countries
WHERE LEN(CountryName) - LEN(REPLACE(CountryName, 'a', '')) >= 3
ORDER BY IsoCode

SELECT p.PeakName, r.RiverName,
	   LOWER(CONCAT(SUBSTRING(p.PeakName, 0, LEN(p.PeakName)), r.RiverName)) AS [Mix]
FROM dbo.Peaks as p, dbo.Rivers as r
WHERE RIGHT(p.PeakName, 1) = LEFT(r.RiverName, 1)
ORDER BY Mix