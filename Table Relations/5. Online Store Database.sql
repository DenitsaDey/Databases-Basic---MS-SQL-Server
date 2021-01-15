CREATE DATABASE OnlineStore

USE OnlineStore

CREATE TABLE Cities
(
CityID INT PRIMARY KEY IDENTITY,
[Name] VARCHAR(50) NOT NULL
)

INSERT INTO Cities([Name])
VALUES
	('Sofia'),
	('Plovdiv'),
	('Varna')


CREATE TABLE Customers
(
CustomerID INT PRIMARY KEY IDENTITY,
[Name] VARCHAR(50) NOT NULL,
Birthday DATE NOT NULL,
CityID INT FOREIGN KEY REFERENCES Cities(CityID)
)

INSERT INTO Customers([Name], Birthday, CityID)
VALUES
	('Nevena', '12/10/1988', 3),
	('Anton', '05/03/1995', 1),
	('Boris', '08/17/2003', 2),
	('Rada', '10/09/2010', 1)

CREATE TABLE Orders
(
OrderID INT PRIMARY KEY IDENTITY,
CustomerID INT FOREIGN KEY REFERENCES Customers(CustomerID)
)

INSERT INTO Orders(CustomerID)
VALUES
	(5),
	(6),
	(4),
	(4),
	(7)
	

CREATE TABLE ItemTypes
(
ItemTypeID INT PRIMARY KEY IDENTITY,
[Name] VARCHAR(50) NOT NULL
)

INSERT INTO ItemTypes([Name])
VALUES
	('Keyboard'),
	('Monitor'),	
	('Hard Disk')

CREATE TABLE Items
(
ItemID INT PRIMARY KEY IDENTITY,
[Name] VARCHAR(50) NOT NULL,
ItemTypeID INT FOREIGN KEY REFERENCES ItemTypes(ItemTypeID)
)

INSERT INTO Items([Name], ItemTypeID)
VALUES
	('Lenovo', 2),
	('Apple', 1),
	('HP', 2),
	('Toshiba', 3)

CREATE TABLE OrderItems
(
OrderID INT FOREIGN KEY REFERENCES Orders(OrderID),
ItemID INT FOREIGN KEY REFERENCES Items(ItemID)
PRIMARY KEY(OrderID, ItemID)
)

INSERT INTO OrderItems(OrderID, ItemID)
VALUES
	(3, 1),
	(4, 2),
	(5, 3),
	(6, 1)

/*
SELECT * FROM OrderItems
FULL JOIN Orders ON OrderItems.OrderID = Orders.OrderID
FULL JOIN Items ON OrderItems.ItemID = Items.ItemID
FULL JOIN Customers ON Orders.CustomerID = Customers.CustomerID
FULL JOIN Cities ON Customers.CityID = Cities.CityID
FULL JOIN ItemTypes ON Items.ItemTypeID = ItemTypes.ItemTypeID
*/
