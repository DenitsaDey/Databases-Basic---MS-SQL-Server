--12. Highet Peaks in Bulgaria
SELECT CountryCode, m.MountainRange, PeakName, Elevation
	FROM Peaks as p
	JOIN Mountains as m ON p.MountainId = m.Id
	JOIN MountainsCountries as mc ON m.Id = mc.MountainId
	WHERE CountryCode = 'BG' AND Elevation > 2835
	ORDER BY Elevation DESC

--13. Count Mountain Ranges
SELECT CountryCode, COUNT(MountainId) AS MountainRanges
	FROM MountainsCountries
	WHERE CountryCode IN ('BG', 'RU', 'US')
	GROUP BY CountryCode
	
--14. Countries With Rivers
SELECT TOP(5) CountryName, RiverName	
	FROM Countries AS c
	LEFT JOIN CountriesRivers AS cr ON c.CountryCode = cr.CountryCode
	LEFT JOIN Rivers AS r ON cr.RiverId = r.Id
	JOIN Continents AS cnt ON c.ContinentCode = cnt.ContinentCode
	WHERE cnt.ContinentName = 'Africa'
	ORDER BY c.CountryName

--15. Countries And Currencies
SELECT ContinentCode, CurrencyCode, CurrencyCount AS [CurrencyUsage]
	FROM
	(SELECT ContinentCode, CurrencyCode, [CurrencyCount],
		DENSE_RANK() OVER(PARTITION BY ContinentCode ORDER BY [CurrencyCount] DESC) AS [CurrencyRank]
		FROM
		(SELECT ContinentCode
			, CurrencyCode
			, COUNT(*) AS [CurrencyCount]
			FROM Countries
			GROUP BY ContinentCode, CurrencyCode) AS [CurrencyCountQuery]
		WHERE CurrencyCount > 1) AS [CurrencyRankingQuery]
	WHERE CurrencyRank = 1
	ORDER BY ContinentCode
		
--16. Countries Without Any Mountains
SELECT COUNT(NoMountains.CountryName) AS [Count]
FROM
(SELECT CountryName
	FROM Countries AS c
	LEFT JOIN MountainsCountries AS mc ON c.CountryCode = mc.CountryCode
	WHERE mc.MountainId IS NULL) as NoMountains

--17. Highest Peak and Longest River by Country
SELECT TOP(5) CountryName, Max(p.Elevation) AS HighestPeakElevation
	, Max(r.Length) AS LongestRiverLength
	FROM Countries AS c
	LEFT JOIN CountriesRivers AS cr ON c.CountryCode = cr.CountryCode
	LEFT JOIN Rivers AS r ON cr.RiverId = r.Id
	LEFT JOIN MountainsCountries AS mc ON c.CountryCode = mc.CountryCode
	LEFT JOIN Mountains AS m ON mc.MountainId = m.Id
	LEFT JOIN Peaks AS p ON m.Id = p.MountainId
	GROUP BY c.CountryName
	ORDER BY HighestPeakElevation DESC,
			LongestRiverLength DESC,
			CountryName

--18. Highest Peak Name and Elevation by Country
SELECT TOP(5)
	Country
	, CASE
		WHEN PeakName IS NULL THEN '(no highest peak)'
		ELSE PeakName
		END AS [Highest Peak Name]
	, CASE
		WHEN Elevation IS NULL THEN 0
		ELSE Elevation
		END AS [Highest Peak Elevation]
	, CASE
		WHEN MountainRange IS NULL THEN '(no mountain)'
		ELSE MountainRange
		END AS [Mountain]
	FROM
	(SELECT *,
		DENSE_RANK() OVER(PARTITION BY [Country] ORDER BY Elevation DESC) AS [PeakRank]
		FROM
		(SELECT CountryName as [Country]
		, PeakName
		, Elevation
		, MountainRange
		FROM Countries AS c
		LEFT JOIN MountainsCountries AS mc ON c.CountryCode = mc.CountryCode
		LEFT JOIN Mountains AS m ON mc.MountainId = m.Id
		LEFT JOIN Peaks AS p ON m.Id = p.MountainId) 
		AS [FullInfoQuery]) 
	AS [PeakRankingQuery]
	WHERE PeakRank = 1
	ORDER BY Country, [Highest Peak Name]

			

	
