--1.DataBase Design
CREATE DATABASE ColonialJourney

CREATE TABLE Planets
(
Id INT PRIMARY KEY IDENTITY,
Name VARCHAR(30) NOT NULL
)

CREATE TABLE Spaceports
(
Id INT PRIMARY KEY IDENTITY,
Name VARCHAR(50) NOT NULL,
PlanetId INT FOREIGN KEY REFERENCES Planets(Id) NOT NULL
)

CREATE TABLE Spaceships
(
Id INT PRIMARY KEY IDENTITY,
Name VARCHAR(50) NOT NULL,
Manufacturer VARCHAR(30) NOT NULL,
LightSpeedRate INT DEFAULT 0
)

CREATE TABLE Colonists
(
Id INT PRIMARY KEY IDENTITY,
FirstName VARCHAR(20) NOT NULL,
LastName VARCHAR(20) NOT NULL,
Ucn VARCHAR(10) UNIQUE NOT NULL,
BirthDate DATE NOT NULL
)

CREATE TABLE Journeys
(
Id INT PRIMARY KEY IDENTITY,
JourneyStart DATETIME NOT NULL,
JourneyEnd DATETIME NOT NULL,
Purpose VARCHAR(11) CHECK(Purpose IN ('Medical', 'Technical', 'Educational', 'Military')) NOT NULL,
DestinationSpaceportId INT FOREIGN KEY REFERENCES Spaceports(Id) NOT NULL,
SpaceshipId INT FOREIGN KEY REFERENCES Spaceships(Id) NOT NULL
)

CREATE TABLE TravelCards
(
Id INT PRIMARY KEY IDENTITY,
CardNumber CHAR(10) UNIQUE NOT NULL,
JobDuringJourney VARCHAR(8) CHECK(JobDuringJourney IN ('Pilot', 'Engineer', 'Trooper', 'Cleaner', 'Cook')),
ColonistId INT FOREIGN KEY REFERENCES Colonists(Id) NOT NULL,
JourneyId INT FOREIGN KEY REFERENCES Journeys(Id) NOT NULL
)

--2. Insert
INSERT INTO Planets(Name)
VALUES
	('Mars'),
	('Earth'),
	('Jupiter'),
	('Saturn')

INSERT INTO Spaceships(Name, Manufacturer, LightSpeedRate)
VALUES
	('Golf', 'VW',	3),
	('WakaWaka', 'Wakanda',	4),
	('Falcon9', 'SpaceX',	1),
	('Bed', 'Vidolov',	6)

--3. Update
UPDATE Spaceships
SET LightSpeedRate += 1
WHERE Id BETWEEN 8 AND 12

--4. Delete
Delete TravelCards
where JourneyId In (SELECT top(3)Id FROM Journeys)

DELETE TOP(3) Journeys

--5. Select All Military Journeys
SELECT Id, FORMAT(JourneyStart, 'dd/MM/yyyy') AS JourneyStart,
FORMAT(JourneyEnd, 'dd/MM/yyyy') AS JourneyEnd
FROM Journeys
WHERE Purpose = 'Military'
ORDER BY JourneyStart

--6. Select All Pilots
SELECT c.Id, CONCAT(FirstName, ' ', LastName) AS [full_name] FROM Colonists AS c
JOIN TravelCards AS tc ON c.Id = tc.ColonistId
WHERE JobDuringJourney = 'Pilot'
ORDER BY c.Id


--7. Count Colonists
SELECT COUNT(ColonistId) FROM TravelCards AS tc
JOIN Journeys AS j ON tc.JourneyId = j.Id
WHERE Purpose = 'Technical'


--8.	Select spaceships with pilots younger than 30 years

SELECT spsh.Name, spsh.Manufacturer 
FROM Spaceships AS spsh
	JOIN Journeys AS j ON spsh.Id = j.SpaceshipId
	JOIN TravelCards AS tc ON j.Id = tc.JourneyId
	JOIN Colonists AS c ON tc.ColonistId = c.Id
WHERE tc.ColonistId IN (SELECT c.Id FROM Colonists AS c
						JOIN TravelCards AS tc ON c.Id = tc.ColonistId
						WHERE JobDuringJourney = 'Pilot' AND 
						BirthDate BETWEEN '1989-01-01' AND '2019-01-01')
ORDER BY spsh.Name

--9.	Select all planets and their journey count

SELECT p.Name AS [PlanetName],
COUNT(*) AS [JourneysCount]
FROM Journeys AS j
JOIN Spaceports AS sp ON j.DestinationSpaceportId = sp.Id
JOIN Planets AS p ON sp.PlanetId = p.Id
GROUP BY p.Name
ORDER BY JourneysCount DESC, p.Name

--10.	Select Second Oldest Important Colonist
SELECT JobDuringJourney, FullName, Rank AS [JobRank]
FROM (SELECT tc.JobDuringJourney, 
CONCAT(FirstName, ' ', LastName) AS [FullName],
(DENSE_RANK() OVER(Partition BY tc.JobDuringJourney ORDER BY c.BirthDate)) AS Rank
FROM TravelCards AS tc
JOIN Colonists AS c ON tc.ColonistId = c.Id) AS [RankQuery]
WHERE Rank = 2

--11. Get Colonists Count
CREATE FUNCTION dbo.udf_GetColonistsCount(@PlanetName VARCHAR (30)) 
RETURNS INT
AS
BEGIN
	DECLARE @Count INT=
	(SELECT COUNT(tc.ColonistId) 
	FROM TravelCards AS tc
	JOIN Journeys AS j ON tc.JourneyId = j.Id
	JOIN Spaceports AS sp ON j.DestinationSpaceportId = sp.Id
	JOIN Planets AS p ON sp.PlanetId = p.Id
	WHERE p.Name = @PlanetName)

	RETURN @Count

END

SELECT dbo.udf_GetColonistsCount('Otroyphus')

--12.	Change Journey Purpose
CREATE PROC usp_ChangeJourneyPurpose(@JourneyId INT, @NewPurpose varchar(11))
AS
	IF((SELECT Id FROM Journeys WHERE Id =@JourneyId) IS NULL)
	THROW 50001, 'The journey does not exist!', 1;

	IF(@NewPurpose IN (SELECT Purpose FROM Journeys WHERE Id =@JourneyId))
	THROW 50002, 'You cannot change the purpose!', 1;

	ELSE 
	UPDATE Journeys
	SET Purpose = @NewPurpose
	WHERE Id = @JourneyId

GO

EXEC usp_ChangeJourneyPurpose 4, 'Technical'

EXEC usp_ChangeJourneyPurpose 2, 'Educational'

EXEC usp_ChangeJourneyPurpose 196, 'Technical'


	SELECT * FROM Journeys