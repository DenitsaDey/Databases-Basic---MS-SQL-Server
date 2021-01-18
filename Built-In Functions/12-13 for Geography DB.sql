--12. Countries Holding ‘A’ 3 or More Times
SELECT CountryName AS [Country Name], IsoCode AS [ISO Code]
	FROM Countries
	WHERE CountryName LIKE '%a%a%a%'
	ORDER BY IsoCode

--13.Mix of Peak and River Names
SELECT PeakName, RiverName,
LOWER(CONCAT(PeakName, SUBSTRING(RiverName,2, LEN(RiverName) -1))) AS [Mix]
	FROM Peaks as P, Rivers AS r
	WHERE RIGHT(PeakName, 1) =  LEFT(RiverName,1)
	ORDER BY Mix

/* 
SELECT PeakName, RiverName,
LOWER(CONCAT(PeakName, SUBSTRING(RiverName,2, LEN(RiverName) -1))) AS [Mix]
	FROM Peaks as P
	JOIN Rivers AS R ON RIGHT(PeakName, 1) =  LEFT(RiverName,1)
	ORDER BY Mix
*/
