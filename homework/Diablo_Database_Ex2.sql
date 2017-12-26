SELECT TOP (50) Name, CONVERT(char(10), Start, 126) FROM dbo.Games
WHERE DATEPART(year, Start) IN (2011, 2012)
ORDER BY Start

SELECT Username, 
	   SUBSTRING(Email, CHARINDEX('@', Email, 0) + 1, LEN(Email)) AS [Email Provider] 
FROM dbo.Users 
ORDER BY [Email Provider], 
		 Username

SELECT Username, IpAddress FROM dbo.Users
WHERE IpAddress LIKE '___!.1[0-9]%!.[0-9]%!.___' ESCAPE '!'
ORDER BY Username

SELECT Name,
	   CASE WHEN DatePart(hour, Start) < 12 THEN 'Morning' 
	    WHEN DatePart(hour, Start) < 18 THEN 'Afternoon' 
	    WHEN DatePart(hour, Start) < 24 THEN 'Evening' END AS [Part of the Day],
	   CASE WHEN Duration <= 3 THEN 'Extra Short' 
	    WHEN Duration <= 6 THEN 'Short' 
	    WHEN Duration > 6 THEN 'Long' 
	    WHEN Duration is null THEN 'Extra Long' END AS [Duration]
FROM dbo.Games
ORDER BY Name, Duration, [Part of the Day]

