--1. Find Names of All Employees by First Name
SELECT FirstName, LastName
FROM Employees
WHERE SUBSTRING(FirstName,1,2) = 'Sa'

--2. Find Names of All employees by Last Name
SELECT FirstName, LastName
FROM Employees
WHERE LastName LIKE '%ei%'

--3. Find First Names of All Employees
SELECT FirstName
FROM Employees
WHERE DepartmentID IN (3, 10)
AND YEAR(HireDate) BETWEEN 1995 AND 2005

--4. Find All Employees Except Engineers
SELECT FirstName, LastName
FROM Employees
WHERE JobTitle NOT LIKE '%engineer%'

--5. Find Towns with Name Length
SELECT [Name]
FROM Towns
WHERE LEN([Name]) IN (5,6)
ORDER BY [Name]

--6. Firnd Towns Starting With
SELECT TownID, [Name]
FROM Towns
WHERE SUBSTRING([Name], 1, 1) LIKE '[MKBE]'
ORDER BY [Name]	
--WHERE LEFT(Name, 1) IN ('M', 'K', 'B', 'E')
--WHERE LEFT(Name, 1) like '[MKBE]'

--7. Find Towns Not Starting With
SELECT TownID, [Name]
FROM Towns
WHERE SUBSTRING([Name], 1, 1) NOT LIKE '[RBD]'
ORDER BY [Name]	

--8. Create View Employees Hired After 2000 Year
CREATE VIEW V_EmployeesHiredAfter2000 AS
SELECT FirstName, LastName
	FROM Employees
	Where YEAR(HireDate) > 2000

--9. Length of Last Name
SELECT FirstName, LastName	
	FROM Employees
	WHERE LEN(LastName) = 5

--10. Rank Employees By Salary
SELECT EmployeeID, FirstName, LastName, Salary,
	DENSE_RANK() OVER
	(PARTITION BY Salary
	ORDER BY EmployeeID) AS [Rank]
	FROM Employees
	WHERE Salary BETWEEN 10000 AND 50000
	ORDER BY Salary DESC

--11. Find All Employees with Rank 2*
SELECT*
FROM
(SELECT EmployeeID, FirstName, LastName, Salary,
	DENSE_RANK() OVER
	(PARTITION BY Salary
	ORDER BY EmployeeID) AS [Rank]
	FROM Employees
	WHERE Salary BETWEEN 10000 AND 50000) AS Rank2
	WHERE [Rank] = 2
	ORDER BY Salary DESC
	

	
