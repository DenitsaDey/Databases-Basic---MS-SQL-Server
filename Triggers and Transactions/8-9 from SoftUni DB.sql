--8.	Employees with Three Projects
CREATE PROC usp_AssignProject(@emloyeeId INT, @projectID INT) 
AS
BEGIN
BEGIN TRANSACTION
	IF((SELECT COUNT(*) FROM EmployeesProjects
			WHERE EmployeeID = @emloyeeId) >=3)
			BEGIN
				THROW 50001, 'The employee has too many projects!', 1;
			END

	INSERT INTO EmployeesProjects
	VALUES (@emloyeeId, @projectID)
COMMIT
END

--9.	Delete Employees
CREATE TABLE Deleted_Employees
(
    EmployeeId int PRIMARY KEY IDENTITY ,
     FirstName varchar(50) not NULL ,
     LastName varchar(50) not NULL ,
     MiddleName varchar(50),
     JobTitle varchar(50) not NULL ,
     DepartmentId int NOT NULL ,
     Salary money not NULL
)
GO

CREATE TRIGGER tr_InsertEmployeesOnDelete
    ON Employees
    FOR DELETE AS
    BEGIN
        INSERT INTO Deleted_Employees
        SELECT d.FirstName,d.LastName,d.MiddleName,d.JobTitle,d.DepartmentID,d.Salary
        FROM deleted as d
    END
GO

	SELECT * FROM Employees
	SELECT * FROM EmployeesProjects