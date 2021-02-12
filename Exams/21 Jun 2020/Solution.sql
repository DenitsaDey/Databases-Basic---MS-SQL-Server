--1. Database Design
CREATE DATABASE TripService

CREATE TABLE Cities
(
Id INT PRIMARY KEY IDENTITY,
Name NVARCHAR(20) NOT NULL,
CountryCode CHAR(2) NOT NULL
)

CREATE TABLE Hotels
(
Id INT PRIMARY KEY IDENTITY,
Name NVARCHAR(30) NOT NULL,
CityId INT FOREIGN KEY REFERENCES Cities(Id) NOT NULL,
EmployeeCount INT NOT NULL,
BaseRate DECIMAL (18,2)
)

CREATE TABLE Rooms
(
Id INT PRIMARY KEY IDENTITY,
Price DECIMAL(18,2) NOT NULL,
Type NVARCHAR(20) NOT NULL,
Beds INT NOT NULL,
HotelId INT FOREIGN KEY REFERENCES Hotels(Id) NOT NULL
)

CREATE TABLE Trips
(
Id INT PRIMARY KEY IDENTITY,
RoomId INT FOREIGN KEY REFERENCES Rooms(Id) NOT NULL,
BookDate DATETIME NOT NULL,
ArrivalDate DATETIME NOT NULL,
ReturnDate DATETIME NOT NULL,
CancelDate DATETIME,
CONSTRAINT bookValid CHECK(BookDate < ArrivalDate ),
CONSTRAINT arrivalValid CHECK(ArrivalDate < ReturnDate)
)


	

CREATE TABLE Accounts
(
Id INT PRIMARY KEY IDENTITY,
FirstName NVARCHAR(50) NOT NULL,
MiddleName NVARCHAR(20),
LastName NVARCHAR(50) NOT NULL,
CityId INT FOREIGN KEY REFERENCES Cities(Id) NOT NULL,
BirthDate DATETIME NOT NULL,
Email VARCHAR(100) UNIQUE NOT NULL
)

CREATE TABLE AccountsTrips
(
AccountId INT FOREIGN KEY REFERENCES Accounts(Id) NOT NULL,
TripId INT FOREIGN KEY REFERENCES Trips(Id) NOT NULL,
Luggage INT CHECK(Luggage >=0) NOT NULL,
PRIMARY KEY(AccountId, TripId)
)

--2. Insert
INSERT INTO Accounts(FirstName, MiddleName, LastName, CityId, BirthDate, Email)
VALUES
	('John', 'Smith', 'Smith', 	34, '1975-07-21', 'j_smith@gmail.com'),
	('Gosho', NULL, 'Petrov', 	11, '1978-05-16', 'g_petrov@gmail.com'),
	('Ivan', 'Petrovich', 'Pavlov', 	59, '1849-09-26', 'i_pavlov@softuni.bg'),
	('Friedrich', 'Wilhelm', 'Nietzsche', 	2, '1844-10-15', 'f_nietzsche@softuni.bg')

INSERT INTO Trips(RoomId, BookDate, ArrivalDate, ReturnDate, CancelDate)
VALUES
	(101, '2015-04-12', '2015-04-14', '2015-04-20', '2015-02-02'),
	(102, '2015-07-07', '2015-07-15', '2015-07-22', '2015-04-29'),
	(103, '2013-07-17', '2013-07-23', '2013-07-24', NULL),
	(104, '2012-03-17', '2012-03-31', '2012-04-01', '2012-01-10'),
	(109, '2017-08-07', '2017-08-28', '2017-08-29', NULL)

--3. Update
UPDATE Rooms
SET Price *= 1.14
WHERE HotelId IN (5, 7, 9)
SELECT * FROM Rooms

--4. Delete
DELETE AccountsTrips
WHERE AccountId = 47

--5. EEE-mails
SELECT FirstName, LastName, FORMAT(BirthDate, 'MM-dd-yyyy') AS BirthDate, c.Name AS [Hometown], Email
FROM Accounts AS a
LEFT JOIN Cities AS c ON a.CityId = c.Id
WHERE Email LIKE 'e%'
ORDER BY c.Name

--6. City Statistics
SELECT c.Name AS [City],
COUNT(*) AS [Hotels]
FROM Cities AS c
JOIN Hotels AS h ON c.Id = h.CityId
GROUP BY c.Name
ORDER BY COUNT(*) DESC, c.Name

--7. Longest and Shortest Trip
SELECT a.Id AS [AccountId],
	a.FirstName + ' ' + a.LastName AS [FullName],
	MAX(DATEDIFF(day, ArrivalDate, ReturnDate)) AS [LongestTrip],
	MIN(DATEDIFF(day, ArrivalDate, ReturnDate)) AS [ShortestTrip]
FROM Accounts AS a
JOIN AccountsTrips AS atr ON atr.AccountId = a.Id
JOIN Trips AS t ON atr.TripId = t.Id
WHERE a.MiddleName IS NULL AND t.CancelDate IS NULL
GROUP BY a.Id, a.FirstName, a.LastName
ORDER BY LongestTrip DESC, ShortestTrip

--8. Metropolis
SELECT TOP(10) c.Id,
		c.Name,
		c.CountryCode,
		NumberOfAccounts AS [Accounts]
FROM(SELECT a.CityId,
	COUNT(*) AS [NumberOfAccounts]
	FROM Accounts AS a
	GROUP BY a.CityId) AS [CityQuery]
JOIN Cities as c ON CityQuery.CityId = c.Id
Order By NumberOfAccounts DESC

--9. Romantic Getaways
SELECT Id, Email, City, Count(*) AS [Trips]
FROM (SELECT a.Id, a.Email, c.Name AS [City]
FROM Accounts AS a
LEFT JOIN AccountsTrips AS atr ON atr.AccountId = a.Id
LEFT JOIN Trips AS t ON atr.TripId = t.Id
LEFT JOIN Rooms AS r ON t.RoomId = r.Id
LEFT JOIN Hotels AS h on r.HotelId = h.Id
LEFT JOIN Cities AS c ON h.CityId = c.Id
WHERE A.CityId = H.CityId) AS [NumberOfTripsQuery]
GROUP BY City, Id, Email
ORDER BY Trips DESC, Id

--10. GDPR Violation
SELECT t.Id, CONCAT(a.FirstName, ' ', ISNull(a.MiddleName + ' ', ''), a.LastName) AS [Full Name],
(SELECT Name FROM Cities WHERE Id = a.CityId) AS [From],
RoomsCitiesQuery.Name AS [To],
CASE	
	WHEN t.CancelDate IS NOT NULL THEN 'Canceled'
	ELSE CONCAT(DATEDIFF(day, t.ArrivalDate, t.ReturnDate), ' days')
	END AS [Duration]
FROM Trips AS t
JOIN AccountsTrips AS atr ON t.Id = atr.TripId
JOIN Accounts AS a on atr.AccountId = a.Id
JOIN Cities AS c ON a.CityId = c.Id
JOIN (SELECT c.Name, r.Id AS [RoomId] FROM Cities AS c
JOIN Hotels AS h ON h.CityId = c.Id
JOIN Rooms AS r ON r.HotelId = h.Id) AS [RoomsCitiesQuery] ON t.RoomId = RoomsCitiesQuery.RoomId
ORDER BY [Full Name], Id

--11. Available Room
CREATE OR ALTER FUNCTION udf_GetAvailableRoom(@HotelId INT, @Date DATETIME, @People INT)
RETURNS NVARCHAR(MAX)
AS
	BEGIN
	
	DECLARE @RoomId INT= (SELECT TOP(1) RoomId FROM Trips AS t
	JOIN Rooms AS r ON t.RoomId = r.Id
	WHERE ((CancelDate IS NOT NULL) OR (ArrivalDate > @Date OR ReturnDate < @Date)) 
	AND RoomId IN (SELECT Id FROM Rooms
	WHERE HotelId = @HotelId 
		AND Beds >= @People)
	AND YEAR(@Date) = YEAR(ArrivalDate)
	ORDER BY Price DESC)

	IF(@RoomId IS NULL)
	BEGIN 
	RETURN 'No rooms available.'
	END

	ELSE
	
	DECLARE @HighestPrice DECIMAL(18,2) = (SELECT Price FROM Rooms WHERE Id = @RoomId)
	DECLARE @RoomType NVARCHAR(20) = (SELECT Type FROM Rooms WHERE Id = @RoomId)
	DECLARE @Beds INT = (SELECT Beds FROM Rooms WHERE Id = @RoomId)
	DECLARE @TotalRoomPrice DECIMAL(18, 2) = ((SELECT BaseRate FROM Hotels
	WHERE Id = @HotelId) + @HighestPrice) * @People;

	DECLARE @Result NVARCHAR(MAX) = CONCAT('Room ', @RoomId, ': ', @RoomType, ' (', @Beds, ' beds) - $', @TotalRoomPrice);
	RETURN @Result;
	
END

SELECT dbo.udf_GetAvailableRoom(112, '2011-12-17', 2)
SELECT dbo.udf_GetAvailableRoom(94, '2015-07-26', 3)

--12. Switch Room
CREATE PROC usp_SwitchRoom(@TripId INT, @TargetRoomId INT)
AS
BEGIN
	
	DECLARE @CurrentRoomHotelId INT= (SELECT HotelId FROM Trips AS t
									JOIN Rooms AS r ON t.RoomId = r.Id
								WHERE t.Id = @TripId)
	DECLARE @TargetRoomHotelId INT= (SELECT HotelId FROM Rooms 
								WHERE Id = @TargetRoomId)
	IF(@CurrentRoomHotelId != @TargetRoomHotelId)
		THROW 50001, 'Target room is in another hotel!', 1;

	DECLARE @CountTripAccounts INT= (SELECT COUNT(AccountId) FROM AccountsTrips
								WHERE TripId = @TripId)
	DECLARE @TargetRoomBeds INT= (SELECT Beds FROM Rooms 
								WHERE Id = @TargetRoomId)
	IF(@CountTripAccounts > @TargetRoomBeds)
		THROW 50002, 'Not enough beds in target room!', 1;

	ELSE
		UPDATE TRIPS
		SET RoomId = @TargetRoomId
		WHERE Id = @TripId
	
END

EXEC usp_SwitchRoom 10, 11
SELECT RoomId FROM Trips WHERE Id = 10
EXEC usp_SwitchRoom 10, 7
EXEC usp_SwitchRoom 10, 8