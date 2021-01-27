--9. Find Full Name
CREATE PROC usp_GetHoldersFullName 
AS
	SELECT CONCAT(FirstName, ' ', LastName) AS [Full Name]
		FROM AccountHolders
GO

EXEC usp_GetHoldersFullName 

--10.	People with Balance Higher Than
CREATE OR ALTER PROC usp_GetHoldersWithBalanceHigherThan (@balance DECIMAL(18, 4))
AS
	SELECT FirstName AS [First Name],
			LastName AS [Last Name]
	FROM AccountHolders AS ah
	JOIN Accounts AS a ON ah.Id = a.AccountHolderId
	GROUP BY FirstName, LastName
	HAVING SUM(Balance) > @balance
	ORDER BY FirstName, LastName
GO

EXEC usp_GetHoldersWithBalanceHigherThan 25000

--11.	Future Value Function
CREATE FUNCTION ufn_CalculateFutureValue (@sum DECIMAL (18, 4), 
										  @yearlyInterestRate FLOAT, 
										  @years INT)
RETURNS DECIMAL(18,4)
AS
BEGIN
	DECLARE @futureValue DECIMAL(18, 4)
	SET @futureValue = @sum * POWER((1 + @yearlyInterestRate), @years)
	RETURN @futureValue
END
GO

SELECT dbo.ufn_CalculateFutureValue(1000, 0.1, 5) AS [Output]

--12. Calculating Interest
CREATE PROC usp_CalculateFutureValueForAccount (@accountId INT, @interestRate FLOAT)
AS
	SELECT a.Id AS [Account Id],
		   FirstName AS [First Name],
		   LastName AS [Last Name],
		   Balance AS [Current Balance],
		   dbo.ufn_CalculateFutureValue(Balance, @interestRate, 5) AS [Balance in 5 years]
		FROM AccountHolders AS ah
		JOIN Accounts AS a ON ah.Id = a.AccountHolderId
		WHERE a.Id = @accountId
GO
	
EXEC usp_CalculateFutureValueForAccount 1, 0.1


