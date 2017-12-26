SELECT PeakName FROM dbo.Peaks ORDER BY PeakName

SELECT TOP (30) CountryName, Population FROM dbo.Countries
WHERE ContinentCode = 'EU'
ORDER BY Population DESC, CountryName

SELECT CountryName,
	   CountryCode,
	   CASE WHEN CurrencyCode = 'EUR' 
	   THEN 'Euro' ELSE 'Not Euro' END AS [Currency]
	   FROM dbo.Countries
	   ORDER BY CountryName