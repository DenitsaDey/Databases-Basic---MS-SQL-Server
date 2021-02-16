--1. Database Design
CREATE DATABASE Bitbucket

CREATE TABLE Users
(
Id INT PRIMARY KEY IDENTITY,
Username VARCHAR(30) NOT NULL,
[Password] VARCHAR(30) NOT NULL,
Email VARCHAR(50) NOT NULL
)

CREATE TABLE Repositories
(
Id INT PRIMARY KEY IDENTITY,
[Name] VARCHAR(50) NOT NULL
)

CREATE TABLE RepositoriesContributors
(
RepositoryId INT FOREIGN KEY REFERENCES Repositories(Id) NOT NULL,
ContributorId INT FOREIGN KEY REFERENCES Users(Id) NOT NULL,
PRIMARY KEY(RepositoryId, ContributorId)
)

CREATE TABLE Issues
(
Id INT PRIMARY KEY IDENTITY,
Title VARCHAR(255) NOT NULL,
IssueStatus CHAR(6) NOT NULL,
RepositoryId INT FOREIGN KEY REFERENCES Repositories(Id) NOT NULL,
AssigneeId INT FOREIGN KEY REFERENCES Users(Id) NOT NULL
)

CREATE TABLE Commits
(
Id INT PRIMARY KEY IDENTITY,
[Message] VARCHAR(255) NOT NULL,
IssueId INT FOREIGN KEY REFERENCES Issues(Id),
RepositoryId INT FOREIGN KEY REFERENCES Repositories(Id) NOT NULL,
ContributorId INT FOREIGN KEY REFERENCES Users(Id) NOT NULL
)

CREATE TABLE Files
(
Id INT PRIMARY KEY IDENTITY,
[Name] VARCHAR(100) NOT NULL,
Size DECIMAL(18,2) NOT NULL,
ParentId INT REFERENCES Files(Id),
CommitId INT FOREIGN KEY REFERENCES Commits(Id) NOT NULL
)

--2. Insert
INSERT INTO Files(Name, Size, ParentId, CommitId)
VALUES
		('Trade.idk',	2598.0,	1,	1),
		('menu.net',	9238.31,	2,	2),
		('Administrate.soshy',	1246.93,	3,	3),
		('Controller.php',	7353.15,	4,	4),
		('Find.java',	9957.86,	5,	5),
		('Controller.json',	14034.87,	3,	6),
		('Operate.xix',	7662.92,	7,	7)

INSERT INTO Issues(Title, IssueStatus, RepositoryId, AssigneeId)
VALUES
		('Critical Problem with HomeController.cs file', 'open', 1,	4),
		('Typo fix in Judge.html', 'open',	4,	3),
		('Implement documentation for UsersService.cs', 'closed',	8,	2),
		('Unreachable code in Index.cs', 'open',	9,	8)

--3. Update
UPDATE Issues
	SET IssueStatus = 'closed'
	WHERE AssigneeId = 6


--4. Delete
DELETE RepositoriesContributors
WHERE RepositoryId = (SELECT ID FROM Repositories
WHERE Name = 'Softuni-Teamwork')

DELETE Issues
WHERE RepositoryId = 
(SELECT ID FROM Repositories
WHERE Name = 'Softuni-Teamwork')

--5. Commits
SELECT Id, Message, RepositoryId, ContributorId FROM Commits
ORDER BY Id, Message, RepositoryId, ContributorId

--6.Front-End
SELECT Id, Name, Size FROM Files
WHERE Size > 1000 AND Name LIKE '%html%'
ORDER BY Size DESC, Id, Name

--7. Issue Assignment
SELECT i.Id, CONCAT(u.Username, ' : ', i.Title) FROM Issues AS i
JOIN Users AS u ON i.AssigneeId = u.Id
ORDER BY i.Id DESC, i.AssigneeId

--8. Single Files
SELECT Id, Name, CONCAT(Size,'KB') AS Size FROM Files
WHERE Id NOT IN (SELECT ParentId FROM Files WHERE ParentId IS NOT NULL)

--9. Commits in Repositories
SELECT TOP(5) c.RepositoryId AS Id, r.Name, COUNT(*) AS Commits 
FROM RepositoriesContributors AS rc
JOIN Commits AS c ON rc.RepositoryId = c.RepositoryId
JOIN Repositories AS r ON c.RepositoryId = r.Id
GROUP BY c.RepositoryId, r.Name
ORDER BY Commits DESC, c.RepositoryId, r.Name


--10. Average Size

SELECT Id AS [UserID], Username FROM Users
WHERE Id IN (SELECT ContributorId FROM Commits) --users who have commits


--new 10
SELECT u.Username, AVG(f.Size) AS Size FROM Commits AS c
JOIN Users AS u ON c.ContributorId = u.Id
JOIN Files AS f ON c.Id = f.CommitId
GROUP BY u.Username
ORDER BY Size DESC, u.Username


--11. All Users Commits
CREATE FUNCTION udf_AllUserCommits(@username VARCHAR(30))
RETURNS INT
AS
BEGIN 
	DECLARE @Count INT
	SET @Count = 
	(SELECT COUNT(*) FROM Commits
	WHERE ContributorId = (SELECT Id from Users WHERE Username = @username))
	RETURN @Count
END

--12. Search for Files
CREATE OR ALTER PROC usp_SearchForFiles(@fileExtension VARCHAR(20))
AS
	DECLARE @input VARCHAR(20)
		SET @input = @fileExtension


	SELECT Id, Name, CONCAT(Size, 'KB') AS Size FROM Files
	WHERE Name LIKE '%'+ @input
	ORDER BY Id, Name, Size DESC

GO

exec usp_SearchForFiles 'txt'