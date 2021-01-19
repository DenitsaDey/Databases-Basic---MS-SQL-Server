--14. Games from 2011 and 2012 year
SELECT TOP (50)
	[Name], FORMAT([Start], 'yyyy-MM-dd') AS [Start]
	FROM Games
	WHERE DATEPART(YEAR, [Start]) BETWEEN '2011' AND '2012'
	ORDER BY [Start], [Name]
	--this would order by the new [Start] after the FORMAT

	/*
	vs 
	SELECT TOP (50)
	[Name], FORMAT([Start], 'yyyy-MM-dd') AS [Start]
	FROM Games AS g
	WHERE DATEPART(YEAR, [Start]) BETWEEN '2011' AND '2012'
	ORDER BY g.[Start], [Name]
	this would order by [Start] from the DB
	*/

--15. User Email Providers
SELECT Username
	,SUBSTRING([Email], CHARINDEX('@', Email) + 1, LEN(Email) - CHARINDEX('@', Email) + 1)
	AS [Email Provider]
FROM Users
ORDER BY [Email Provider], Username

--16. Get Users with IPAdress Like Pattern
SELECT Username, IpAddress AS [IP Address]
	FROM Users
	WHERE IpAddress LIKE '___.1_%._%.___'
	ORDER BY Username

--17. Show All Games with Duration and Part of the Day
SELECT [Name] AS [Game]
	,CASE
		WHEN DATEPART(Hour, [Start]) BETWEEN 0 AND 11 THEN 'Morning'
		WHEN DATEPART(Hour, [Start]) BETWEEN 12 AND 17 THEN 'Afternoon'
		ELSE 'Evening'
		END AS [Part of the Day]
	,CASE
		WHEN Duration <= 3 THEN 'Extra Short'
		WHEN Duration BETWEEN 4 AND 6 THEN 'Short'
		WHEN Duration >6 THEN 'Long'
		ELSE 'Extra Long'
		END AS [Duration]
	FROM Games
	ORDER BY [Name], [Duration]
