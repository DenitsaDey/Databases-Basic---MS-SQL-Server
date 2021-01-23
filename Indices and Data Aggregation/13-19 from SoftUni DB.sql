--13. Departments Total Salaries
SELECT DepartmentID, SUM(Salary) AS TotalSalary
	FROM Employees
	GROUP BY DepartmentID
	ORDER BY DepartmentID

--14. Employees Minimum Salaries
SELECT DepartmentID, MIN(Salary) AS MinimumSalary
	FROM Employees
	WHERE DepartmentID IN (2, 5, 7) AND
		HireDate > '2000-01-01'
	GROUP BY DepartmentID
	ORDER BY DepartmentID

--15. Employees Average Salaries
SELECT * INTO EmployeesWithHightSalaries
	FROM Employees
	WHERE Salary>30000

DELETE
	FROM EmployeesWithHightSalaries
	WHERE ManagerID=42

UPDATE EmployeesWithHightSalaries
	SET Salary += 5000
	WHERE DepartmentID = 1

SELECT DepartmentID, AVG(Salary) as AverageSalary
	FROM EmployeesWithHightSalaries
	GROUP BY DepartmentID

--16. Employees Maximum Salaries
SELECT DepartmentID, MAX(Salary) AS MaxSalary
	FROM Employees
	GROUP BY DepartmentID
	HAVING MAX(Salary) < 30000 OR
		MAX(Salary) > 70000

--17. Employees Count Salaries
SELECT COUNT(Salary) AS [Count]
	FROM Employees
	WHERE ManagerID IS NULL
	
--18. *3rd Highest Salary
SELECT DISTINCT DepartmentId, Salary AS ThirdHigestSalary
FROM
(SELECT DepartmentId,
	   Salary,
		DENSE_RANK() OVER(	
					PARTITION BY DepartmentId
					ORDER BY Salary DESC) AS SalaryRank
	FROM Employees) AS SalaryRankingQuery
	WHERE SalaryRank = 3
	
--19. **Salary Challenge

Select DepartmentID, AVG(Salary) AS AverageSalary
	INTO AverageSalaryQuery
	FROM Employees AS e
	GROUP BY DepartmentID

SELECT TOP(10) e.FirstName, e.LastName, e.DepartmentID
	FROM Employees AS e
	JOIN AverageSalaryQuery AS asq ON e.DepartmentID = asq.DepartmentID
	WHERE e.Salary > asq.AverageSalary
	ORDER BY DepartmentID

--OR:
SELECT TOP (10) E.FirstName, E.LastName, E.DepartmentID
FROM Employees AS E
WHERE E.Salary >
      (
          SELECT AVG(Salary) AS AverageSalary
          FROM Employees AS eAverageSalary
          WHERE eAverageSalary.DepartmentID = E.DepartmentID
          GROUP BY DepartmentID)
ORDER BY DepartmentID

