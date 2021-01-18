--18. Orders Table
SELECT ProductName, OrderDate
	, DATEADD(DAY, 3, ORDERDATE) AS [Pay Due]
	, DATEADD(MONTH, 1,ORDERDATE) AS [Deliver Due]
	FROM Orders