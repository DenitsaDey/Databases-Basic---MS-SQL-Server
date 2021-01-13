-- 2. All Information About Departments
SELECT * FROM Departments

--3. All Departments Names
SELECT [Name] FROM Departments

--4. Salary of Each Employee
SELECT FirstName, LastName, Salary FROM Employees

--5. Full Name of Each Employee
SELECT FirstName, MiddleName, LastName FROM Employees

--6. Email Address of Each Employee
SELECT FirstName + '.' + LastName + '@softuni.bg' AS [Full Email Address] FROM Employees 

--7. All Different Employee's Salaries
SELECT DISTINCT Salary FROM Employees

--8. All Information About Employees by JobTitle
SELECT * FROM Employees
	WHERE JobTitle = 'Sales Representative'

--9. Names of All Employees by Salary in Range
SELECT FirstName, LastName, JobTitle FROM Employees
	WHERE Salary BETWEEN 20000 AND 30000

--10. Names of All Employees by Salary
/*
SELECT FirstName + ' ' + MiddleName + ' ' + LastName AS [Full Name] => returns 
	NULL on [Full Name], when middle name is NULL
	in cases when MiddleName is NULL => NULL + ' ' = ''
*/
SELECT CONCAT(FirstName, ' ', MiddleName + ' ', LastName) AS [Full Name]
	FROM Employees
		WHERE Salary IN (25000, 14000, 12500, 23600)

--11. All Employees Without Manager
SELECT FirstName, LastName FROM Employees
	WHERE ManagerID IS NULL

--12. All Employees With Salary More Than 50000
SELECT FirstName, LastName, Salary FROM Employees
	WHERE Salary > 50000
	ORDER BY Salary DESC

--13. 5 Best Paid Employees
SELECT TOP(5) FirstName, LastName
	FROM Employees
	ORDER BY Salary DESC
/* 
SELECT FirstName, LastName
	FROM Employees
	ORDER BY Salary DESC
	OFFSET 5 ROWS - all except top 5
	FETCH NEXT 10 ROWS ONLY - 10 rows after top 5
*/
	

--14. All Employees Except Marketing
SELECT FirstName, LastName FROM Employees
	WHERE DepartmentID != '4'

--15. Sort Employees Table
SELECT * FROM Employees
	ORDER BY Salary DESC, FirstName, LastName DESC, MiddleName

--16. Create View Employees with Salaries
CREATE VIEW V_EmployeesSalaries AS
SELECT FirstName, LastName, Salary
	FROM Employees

--17. Create View Employees with Job Titles
CREATE VIEW V_EmployeeNameJobTitle AS
--SELECT CONCAT(FirstName, ' ', MiddleName,' ', LastName) AS [Full Name]
SELECT FirstName + ' ' + ISNULL(MiddleName,'') + ' ' + LastName AS [Full Name], 
		JobTitle AS [Job Title]
	FROM Employees

--18. Distinct Job Titles
SELECT DISTINCT JobTitle
	FROM Employees

--19. Find First 10 Started Projects
SELECT TOP(10)*
	FROM Projects
	ORDER BY StartDate, Name

--20. Last 7 Hired Employees 
SELECT TOP(7)
	FirstName, LastName, HireDate
	FROM Employees
	ORDER BY HireDate Desc

--21. Increase Salaries
UPDATE Employees
	SET Salary *= 1.12
	WHERE DepartmentID IN(1, 2, 4, 11)

SELECT Salary	
	FROM Employees



