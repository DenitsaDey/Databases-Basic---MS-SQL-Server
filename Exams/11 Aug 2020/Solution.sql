--1. Database Design
CREATE DATABASE Bakery

CREATE TABLE Countries
(
Id INT PRIMARY KEY IDENTITY,
Name NVARCHAR(50) UNIQUE NOT NULL
)

CREATE TABLE Customers
(
Id INT PRIMARY KEY IDENTITY,
FirstName NVARCHAR(25) NOT NULL,
LastName NVARCHAR(25) NOT NULL,
Gender CHAR(1) CHECK(Gender IN ('M', 'F')) NOT NULL,
Age INT NOT NULL,
PhoneNumber CHAR(10) CHECK(LEN(PhoneNumber) = 10) NOT NULL,
CountryId INT FOREIGN KEY REFERENCES Countries(Id)
)

CREATE TABLE Products
(
Id INT PRIMARY KEY IDENTITY,
Name NVARCHAR(25) UNIQUE NOT NULL,
Description NVARCHAR(250),
Recipe NVARCHAR(MAX),
Price DECIMAL(18,2) CHECK(Price >= 0) NOT NULl
)

CREATE TABLE Feedbacks
(
Id INT PRIMARY KEY IDENTITY,
Description NVARCHAR(250),
Rate DECIMAL (4,2) CHECK(Rate>=0 AND Rate <=10),
ProductId INT FOREIGN KEY REFERENCES Products(Id),
CustomerId INT FOREIGN KEY REFERENCES Customers(Id)
)

CREATE TABLE Distributors
(
Id INT PRIMARY KEY IDENTITY,
Name NVARCHAR(25) UNIQUE NOT NULL,
AddressText NVARCHAR(30),
Summary NVARCHAR(200),
CountryId INT FOREIGN KEY REFERENCES Countries(Id)
)

CREATE TABLE Ingredients
(
Id INT PRIMARY KEY IDENTITY,
Name NVARCHAR(30) NOT NULL,
Description NVARCHAR(200),
OriginCountryId INT FOREIGN KEY REFERENCES Countries(Id),
DistributorId INT FOREIGN KEY REFERENCES Distributors(Id)
)

CREATE TABLE ProductsIngredients
(
ProductId INT FOREIGN KEY REFERENCES Products(Id),
IngredientId INT FOREIGN KEY REFERENCES Ingredients(Id),
PRIMARY KEY(ProductId, IngredientId)
)


--2. Insert
INSERT INTO Distributors(Name, CountryId, AddressText, Summary)
VALUES
	('Deloitte & Touche',	2, '6 Arch St #9757',	'Customizable neutral traveling'),
	('Congress Title',	13,	'58 Hancock St',	'Customer loyalty'),
	('Kitchen People',	1,	'3 E 31st St #77',	'Triple-buffered stable delivery'),
	('General Color Co Inc',	21,	'6185 Bohn St #72',	'Focus group'),
	('Beck Corporation',	23,	'21 E 64th Ave',	'Quality-focused 4th generation hardware')

INSERT INTO Customers(FirstName, LastName, Age, Gender, PhoneNumber, CountryId)
VALUES
		('Francoise', 'Rautenstrauch',	15, 'M',	'0195698399', 5),
		('Kendra', 'Loud',	22, 'F',	'0063631526',	11),
		('Lourdes', 'Bauswell',	50, 'M',	'0139037043',	8),
		('Hannah', 'Edmison',	18, 'F',	'0043343686',	1),
		('Tom', 'Loeza',	31, 'M',	'0144876096',	23),
		('Queenie', 'Kramarczyk',	30, 'F',	'0064215793',	29),
		('Hiu', 'Portaro',	25, 'M',	'0068277755',	16),
		('Josefa', 'Opitz',	43, 'F',	'0197887645',	17)

--3. Update
UPDATE Ingredients
	SET DistributorId = 35
	WHERE Name IN ('Bay Leaf', 'Paprika', 'Poppy')

UPDATE Ingredients
	SET OriginCountryId = 14
	WHERE OriginCountryId = 8

--4. Delete
DELETE Feedbacks
	WHERE CustomerId = 14 OR ProductId = 5

--5. Products by Price
SELECT Name, Price, Description FROM Products
ORDER BY Price DESC, Name

--6. Negative Feedback
SELECT ProductId, Rate, Description, f.CustomerId, c.Age, c.Gender 
FROM Feedbacks AS f
LEFT JOIN Customers AS c ON f.CustomerId = c.Id
WHERE Rate < 5.0
ORDER BY ProductId DESC, Rate

--7. Customers without Feedback
SELECT CONCAT(FirstName, ' ', LastName),
		PhoneNumber,
		Gender
FROM Customers AS c
LEFT JOIN Feedbacks AS f on c.Id = f.CustomerId
WHERE f.CustomerId IS NULL
ORDER BY c.Id

--8. Customers by Criteria
SELECT FirstName, Age, PhoneNumber FROM Customers
WHERE (Age >= 21 AND FirstName LIKE '%an%') OR
	(PhoneNumber LIKE '%38' AND CountryId !=(SELECT Id FROM Countries WHERE Name = 'Greece'))
ORDER BY FirstName, Age DESC

--9. Middle Range Distributors
SELECT DistributorName, IngredientName, ProductName, AVG
FROM (
SELECT D.Name AS DistributorName,
       I.Name AS IngredientName,
        P.Name AS ProductName,
        AVG(F.Rate) AS AVG
FROM Distributors AS D
JOIN Ingredients I on D.Id = I.DistributorId
JOIN ProductsIngredients PI on I.Id = PI.IngredientId
JOIN Products P on P.Id = PI.ProductId
JOIN Feedbacks F on P.Id = F.ProductId
GROUP BY D.Name, I.Name, P.Name) AS RANK
WHERE AVG BETWEEN 5.0 AND 8.0
ORDER BY DistributorName, IngredientName,ProductName

--10. Country
select rankQuery.Name, rankQuery.DistributorName
from (
select c.Name, d.Name as DistributorName,
       dense_rank() over (partition by c.Name order by count(i.Id) desc) as rank
from Countries as c
      join  Distributors D on c.Id = D.CountryId
     left join Ingredients I on D.Id = I.DistributorId
group by  c.Name, d.Name
) as rankQuery
where rankQuery.rank=1
 ORDER BY rankQuery.Name, rankQuery.DistributorName

 --11. Customers With Countries
 CREATE VIEW v_UserWithCountries 
 AS 
 SELECT c.FirstName + ' ' + c.LastName AS CustomerName, 
		c.Age,
		c.Gender,
		cntr.Name AS CountryName
	FROM Customers AS c, Countries AS cntr
	WHERE c.CountryId = cntr.Id;

--12. Delete Products
CREATE TRIGGER dbo.DeleteRelatedRecord
ON Products INSTEAD OF DELETE
AS
BEGIN
	
	DELETE FROM ProductsIngredients
		WHERE ProductId IN (SELECT p.Id FROM Products AS p
							JOIN deleted AS d ON d.Id = p.Id)
	DELETE FROM Feedbacks
		WHERE ProductId IN (SELECT p.Id FROM Products AS p
							JOIN deleted AS d ON d.Id = p.Id)
	DELETE FROM Products 
		WHERE Id IN (SELECT p.Id FROM Products AS p
							JOIN deleted AS d ON d.Id = p.Id)
END

