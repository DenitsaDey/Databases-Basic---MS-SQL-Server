CREATE DATABASE TableRelations

USE TableRelations

CREATE TABLE Customers
(
PersonID INT PRIMARY KEY IDENTITY(1,1),
FirstName NVARCHAR(10) NOT NULL,
Salary DECIMAL(7,2) NOT NULL,
PassportID INT UNIQUE NOT NULL
)

INSERT INTO Customers (FirstName, Salary, PassportID)
VALUES
	('Roberto', 43300.00, 102),
	('Tom', 56100.00, 103),
	('Yana', 60200.00, 101)


CREATE TABLE Passports
(
PassportID INT PRIMARY KEY IDENTITY(101,1),
PassportNumber NVARCHAR(10) NOT NULL
)

INSERT INTO Passports (PassportNumber)
VALUES
	('N34FG21B'),
	('K65LO4R7'),
	('ZE657QP2')

ALTER TABLE Customers
ADD CONSTRAINT FK_Customers 
FOREIGN KEY (PassportID)
REFERENCES Passports(PassportID)

