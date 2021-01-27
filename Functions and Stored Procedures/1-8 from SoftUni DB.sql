--1. Employees with Salary Above 35000
CREATE PROC usp_GetEmployeesSalaryAbove35000 
AS
	SELECT FirstName AS [First Name], LastName AS [Last Name]
	FROM Employees
	WHERE Salary > 35000
GO

--2.	Employees with Salary Above Number
CREATE PROC usp_GetEmployeesSalaryAboveNumber (@minimum DECIMAL(18,4))
AS
	SELECT FirstName AS [First Name], LastName AS [Last Name]
	FROM Employees
	WHERE Salary >= @minimum
GO

EXEC usp_GetEmployeesSalaryAboveNumber 48100

--3.	Town Names Starting With
CREATE OR ALTER PROC usp_GetTownsStartingWith (@string NVARCHAR(10))
AS
	SELECT t.[Name] AS [Town]
		FROM Towns AS t
		WHERE t.[Name] LIKE @string + '%'
GO

EXEC usp_GetTownsStartingWith 'b'

--4.	Employees from Town
CREATE OR ALTER PROC usp_GetEmployeesFromTown (@townName NVARCHAR(20))
AS
	SELECT FirstName AS [First Name], LastName AS [Last Name]
	FROM Employees AS e
	JOIN Addresses AS a ON e.AddressID = a.AddressID
	JOIN Towns AS t ON a.TownID = t.TownID
	WHERE t.Name = @townName
GO

EXEC usp_GetEmployeesFromTown 'Sofia'

--5. Salary Level Function
CREATE OR ALTER FUNCTION ufn_GetSalaryLevel(@salary DECIMAL(18,4))
RETURNS NVARCHAR(10)
AS
	BEGIN
		DECLARE @salaryGrade NVARCHAR(10)
		IF (@salary < 30000) SET @salaryGrade = 'Low'
		ELSE IF(@salary <=50000) SET @salaryGrade = 'Average'
		ELSE IF (@salary > 50000) SET @salaryGrade = 'High'
		RETURN @salaryGrade
	END

SELECT Salary,
       dbo.ufn_GetSalaryLevel(Salary) AS 'Salary Level'
FROM Employees

--6.	Employees by Salary Level
CREATE OR ALTER PROC usp_EmployeesBySalaryLevel (@salaryLevel NVARCHAR(10))
AS 
	SELECT FirstName AS [First Name], LastName AS [Last Name]
	FROM Employees
	WHERE dbo.ufn_GetSalaryLevel(Salary) = @salaryLevel
GO

EXEC usp_EmployeesBySalaryLevel 'High'

--7.	Define Function
CREATE FUNCTION ufn_IsWordComprised(@setOfLetters NVARCHAR(MAX), @word NVARCHAR(MAX)) 
RETURNS BIT
AS
BEGIN
	DECLARE @wordLength TINYINT = LEN(@word)
	DECLARE @index INT = 1

	WHILE (@index <= @wordLength)
		BEGIN
			IF(CHARINDEX(SUBSTRING(@word, @index, 1), @setOfLetters) = 0)
				RETURN 0
			SET @index += 1
		END
	RETURN 1
END
GO

SELECT dbo.ufn_IsWordComprised('oistmiahf', 'Sofia')
SELECT dbo.ufn_IsWordComprised('oistmiahf', 'halves')
SELECT dbo.ufn_IsWordComprised('bobr', 'Rob')
SELECT dbo.ufn_IsWordComprised('pppp', 'Guy')		

--8.	* Delete Employees and Departments
CREATE PROC usp_DeleteEmployeesFromDepartment (@departmentId INT) 
AS
BEGIN
    --first delete all records from EmployeesProjects where EmployeeId is in to-be-deleted IDs

    DELETE
    FROM EmployeesProjects
    WHERE EmployeeID IN (SELECT EmployeeID
                         FROM Employees
                         WHERE DepartmentID = @departmentId);
    --set managerId to null where Manager is an Employee who is going to be deleted

    UPDATE Employees
    SET ManagerID=NULL
    WHERE ManagerID IN (SELECT EmployeeID
                        FROM Employees
                        WHERE DepartmentID = @departmentId);
--Alter column ManagerId in Departments table and make it nullable

    ALTER TABLE Departments
        ALTER COLUMN ManagerID int;

    UPDATE Departments
    SET ManagerID = NULL
    WHERE ManagerID IN (SELECT EmployeeID
                        FROM Employees
                        WHERE DepartmentID = @departmentId);

    --delete employees from departments

    DELETE FROM Employees
    WHERE DepartmentID=@departmentId

    DELETE FROM Departments
    where DepartmentID=@departmentId

    SELECT count(*)
    FROM Employees
    where DepartmentID=@departmentId

END