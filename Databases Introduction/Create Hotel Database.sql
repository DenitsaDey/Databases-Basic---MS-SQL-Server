-- 15. Hotel Database
CREATE DATABASE Hotel

USE Hotel

CREATE TABLE Employees
(
Id INT PRIMARY KEY IDENTITY,
FirstName NVARCHAR(50) NOT NULL,
LastName NVARCHAR(50) NOT NULL,
Title NVARCHAR(30) NOT NULL,
Notes NVARCHAR(30)
)

INSERT INTO Employees (FirstName, LastName, Title, Notes)
	VALUES
		('RALITSA', 'BOZHINOVA', 'HOUSEKEEPING',NULL),
		('ATANAS', 'MELNICHARSKI', 'VALET',NULL),
		('KRISTINA','KOSANOVA', 'RECEPTIONIST', NULL)




CREATE TABLE Customers
(
AccountNumber NVARCHAR(15) PRIMARY KEY,
FirstName NVARCHAR(50) NOT NULL,
LastName NVARCHAR(50) NOT NULL,
PhoneNumber CHAR(8) NOT NULL,
EmergencyName NVARCHAR(50),
EmergencyNumber CHAR(8),
Notes NVARCHAR(150)
)

INSERT INTO Customers (AccountNumber, FirstName, LastName, PhoneNumber, EmergencyName, EmergencyNumber, Notes)
	VALUES
		('A123','Andrei','Ivanov','94563567',NULL,NULL, NULL),
		('B045','Kamelia','Borisova','23557437','Husband','38006210', NULL),
		('C789','Sasho','Genchev','45768899',NULL,NULL, NULL)




CREATE TABLE RoomStatus
(
RoomStatus NVARCHAR(25) PRIMARY KEY,
Notes NVARCHAR(80)
)

INSERT INTO RoomStatus (RoomStatus, Notes)
	VALUES
		('AVAILABLE AND READY', NULL),
		('AVAILABLE, NOT READY', NULL),
		('OCCUPIED', NULL)




CREATE TABLE RoomTypes
(
RoomType NVARCHAR(15) PRIMARY KEY NOT NULL,
Notes NVARCHAR(80)
)

INSERT INTO RoomTypes (RoomType, Notes)
	VALUES
		('Double Premier',NULL),
		('Premier SeaView', NULL),
		('Deluxe Sea View', NULL)

CREATE TABLE BedTypes
(
BedType NVARCHAR(15) PRIMARY KEY NOT NULL,
Notes NVARCHAR(80)
)

INSERT INTO BedTypes (BedType, Notes)
	VALUES
		('Double', NULL),
		('Queen', NULL),
		('King', NULL)




CREATE TABLE Rooms
(
RoomNumber INT PRIMARY KEY IDENTITY,
RoomType NVARCHAR(15) FOREIGN KEY REFERENCES RoomTypes(RoomType) NOT NULL,
BedType NVARCHAR(15) FOREIGN KEY REFERENCES BedTypes(BedType) NOT NULL,
Rate DECIMAL (5, 2) NOT NULL,
RoomStatus NVARCHAR(25) FOREIGN KEY REFERENCES RoomStatus(RoomStatus) NOT NULL,
Notes NVARCHAR(80)
)

INSERT INTO Rooms (RoomType, BedType, Rate, RoomStatus, Notes)
	VALUES
		('Double Premier','Double', 50.25,'AVAILABLE, NOT READY',NULL),
		('Premier SeaView','Queen', 83.60,'AVAILABLE AND READY',NULL),
		('Deluxe Sea View','King', 115.50,'OCCUPIED',NULL)




CREATE TABLE Payments
(
Id INT PRIMARY KEY IDENTITY,
EmployeeId INT FOREIGN KEY REFERENCES Employees(Id) NOT NULL,
PaymentDate DATE NOT NULL,
AccountNumber NVARCHAR(15) FOREIGN KEY REFERENCES Customers(AccountNumber) NOT NULL,
FirstDateOccupied DATE NOT NULL, 
LastDateOccupied DATE NOT NULL, 
TotalDays AS DATEDIFF(DAY, FirstDateOccupied, LastDateOccupied), 
AmountCharged DECIMAL(6, 2) NOT NULL, 
TaxRate DECIMAL(4, 2) NOT NULL, 
TaxAmount AS AmountCharged * TaxRate, 
PaymentTotal DECIMAL (7, 2), 
Notes NVARCHAR(80)
)

INSERT INTO Payments (EmployeeId, PaymentDate, AccountNumber,
FirstDateOccupied, LastDateOccupied,
AmountCharged, TaxRate,
PaymentTotal, Notes)
	VALUES
		('1','2021-01-13','C789','2021-01-05','2021-01-07',100,0.20,
		120,NULL),
		('2','2021-01-13','A123','2021-01-05','2021-01-07',200,0.20,
		240,NULL),
		('3','2021-01-13','B045','2021-01-05','2021-01-07',300,0.20,
		360,NULL)



CREATE TABLE Occupancies
(
Id INT PRIMARY KEY IDENTITY,
EmployeeId INT FOREIGN KEY REFERENCES Employees(Id) NOT NULL,
DateOccupied DATE NOT NULL,
AccountNumber NVARCHAR(15) FOREIGN KEY REFERENCES Customers(AccountNumber) NOT NULL,
RoomNumber INT FOREIGN KEY REFERENCES Rooms(RoomNumber) NOT NULL,
RateApplied DECIMAL (5, 2) NOT NULL,
PhoneCharge DECIMAL (5, 2), 
Notes NVARCHAR(80)
)


INSERT INTO Occupancies (EmployeeId, DateOccupied,
AccountNumber, RoomNumber, RateApplied, PhoneCharge,
Notes)
	VALUES
		('1','2021-01-05', 'C789', '5', 50.25, 30, NULL),
		('2', '2021-01-05', 'A123', '6', 83.60, 30, NULL),
		('3','2021-01-05', 'B045', '7', 115.50, 30, NULL)

-- 23. Decrease Tax Rate

UPDATE Payments
SET TaxRate -= TaxRate * 0.03

SELECT TaxRate FROM Payments

-- 24. Delete All Records
TRUNCATE TABLE Occupancies

SELECT * FROM Occupancies