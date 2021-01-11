--13. Movies Database
CREATE DATABASE Movies

USE Movies

CREATE TABLE Directors
(
Id INT PRIMARY KEY IDENTITY,
DirectorName NVARCHAR(30) NOT NULL,
Notes NVARCHAR(80)
)

INSERT INTO Directors(DirectorName, Notes)
VALUES
	('Людмил Кирков', NULL),
	('Ники Илиев' , NULL),
	('Стефан Сърчаджиев', NULL),	
	('Борислав Шаралиев', NULL),
	('Николай Волев', NULL)



CREATE TABLE Genres
(
Id INT PRIMARY KEY IDENTITY,
GenreName NVARCHAR(20) NOT NULL,
Notes NVARCHAR(MAX)
)

INSERT INTO Genres(GenreName, Notes)
	VALUES
		('комедия', NULL),
		('драма', NULL),
		('мелодрама', NULL),
		('исторически', NULL),
		('трагикомедия', NULL)



CREATE TABLE Categories
(
Id INT PRIMARY KEY IDENTITY,
CategoryName NVARCHAR(50) NOT NULL,
Notes NVARCHAR(50)
)

INSERT INTO Categories(CategoryName,Notes)
	VALUES
		('Най-добър актьор - Рачко Ябанджиев', NULL),
		('Най-добър режисьор', NULL),
		('Награда за операторска работа', NULL),
		('Награда за костюми - Николай Иванов ', NULL),
		('Най-добра женска роля - Невена Коканова', NULL)



CREATE TABLE Movies
(
Id INT PRIMARY KEY IDENTITY,
Title NVARCHAR(40) NOT NULL,
DirectorId INT FOREIGN KEY REFERENCES Directors(Id),
CopyrightYear DATE NOT NULL,
[Length] TIME NOT NULL,
GenreId INT FOREIGN KEY REFERENCES Genres(Id),
CategoryId INT FOREIGN KEY REFERENCES Categories(Id),
Rating DECIMAL(3, 1),
Notes NVARCHAR(MAX)
)

INSERT INTO Movies(Title, DirectorId,CopyrightYear,
[Length],GenreId, CategoryId, Rating, Notes)
	VALUES
		('Хитър Петър',3,'1960','01:41',
		1,1,9.2,NULL),
		('Живи легенди',2,'2014','01:35',
		3,2,9.2, NULL),
		('Да обичаш на инат',5,'1986','01:15',
		2,3,8.9, NULL),
		('Борис I',4,'1985','02:21',
		4,4,8.9, NULL),
		('Момчето си отива',1,'1994','02:34',
		5,5,8.9, NULL)