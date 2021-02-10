--1. Database Design
CREATE DATABASE VMS

CREATE TABLE Clients
(
ClientId INT PRIMARY KEY IDENTITY,
FirstName VARCHAR(50) NOT NULL,
LastName VARCHAR(50) NOT NULL,
Phone CHAR(12) CHECK(LEN(Phone) = 12) NOT NULL
)

CREATE TABLE Mechanics
(
MechanicId INT PRIMARY KEY IDENTITY,
FirstName VARCHAR(50) NOT NULL,
LastName VARCHAR(50) NOT NULL,
Address VARCHAR(255) NOT NULL
)

CREATE TABLE Models
(
ModelId INT PRIMARY KEY IDENTITY,
Name VARCHAR(50) UNIQUE NOT NULL
)

CREATE TABLE Jobs
(
JobId INT PRIMARY KEY IDENTITY,
ModelId INT FOREIGN KEY REFERENCES Models(ModelId) NOT NULL,
Status VARCHAR(11) DEFAULT 'Pending' CHECK(STATUS IN ('Pending', 'In Progress', 'Finished')) NOT NULL,
ClientId INT FOREIGN KEY REFERENCES Clients(ClientId) NOT NULL,
MechanicId INT FOREIGN KEY REFERENCES Mechanics(MechanicId),
IssueDate DATE NOT NULL,
FinishDate DATE
)

CREATE TABLE Orders
(
OrderId INT PRIMARY KEY IDENTITY,
JobId INT FOREIGN KEY REFERENCES Jobs(JobId) NOT NULL,
IssueDate DATE,
Delivered BIT DEFAULT 0 NOT NULL
)

CREATE TABLE Vendors
(
VendorId INT PRIMARY KEY IDENTITY,
Name VARCHAR(50) UNIQUE NOT NULL,
)

CREATE TABLE Parts
(
PartId INT PRIMARY KEY IDENTITY,
SerialNumber VARCHAR(50) UNIQUE NOT NULL,
Description VARCHAR(255),
Price DECIMAL(6,2) CHECK(Price > 0 AND Price <= 9999.99) NOT NULL,
VendorId INT FOREIGN KEY REFERENCES Vendors(VendorId) NOT NULL,
StockQty INT CHECK(StockQty >= 0) DEFAULT 0 NOT NULL
)

CREATE TABLE OrderParts
(
OrderId INT FOREIGN KEY REFERENCES Orders(OrderId) NOT NULL,
PartId INT FOREIGN KEY REFERENCES Parts(PartId) NOT NULL,
Quantity INT CHECK(Quantity > 0) DEFAULT 1 NOT NULL,
PRIMARY KEY(OrderId, PartId)
)

CREATE TABLE PartsNeeded
(
JobId INT FOREIGN KEY REFERENCES Jobs(JobId) NOT NULL,
PartId INT FOREIGN KEY REFERENCES Parts(PartId) NOT NULL,
Quantity INT CHECK(Quantity > 0) DEFAULT 1 NOT NULL,
PRIMARY KEY(JobId, PartId)
)



--2. Insert
INSERT INTO Clients(FirstName, LastName, Phone)
VALUES ('Teri', 'Ennaco', '570-889-5287'),
		('Merlyn', 'Lawler', '201-588-7810'),
		('Georgene', 'Montezuma', '925-615-5185'),
		('Jettie', 'Mconnell', '908-802-3564'),
		('Lemuel', 'Latzke', '631-748-6479'),
		('Melodie', 'Knipp', '805-690-1682'),
		('Candida', 'Corbley', '908-275-8357')

INSERT INTO Parts(SerialNumber, Description, Price, VendorId)
VALUES ('WP8182119', 'Door Boot Seal', 117.86, 2),
		('W10780048', 'Suspension Rod', 42.81, 1),
		('W10841140', 'Silicone Adhesive', 6.77, 4),
		('WPY055980', 'High Temperature Adhesive', 13.94, 3)

--3. Update
UPDATE Jobs
	SET MechanicID = 3
	WHERE Status = 'Pending'

UPDATE Jobs	
	SET Status = 'In Progress'
	WHERE MechanicID = 3 AND Status = 'Pending'

/* or shorter:
UPDATE Jobs
	SET MechanicID = 3, Status = 'Pending'
	WHERE Status = 'Pending'
*/

--4. Delete
DELETE FROM OrderParts
	WHERE OrderId = 19

DELETE FROM Orders
	WHERE OrderId = 19

--5. Mechanic Assignments
SELECT CONCAT(m.FirstName,' ', m.LastName) AS [Mechanic],
		j.Status,
		j.IssueDate
FROM Jobs AS j
JOIN Mechanics AS m ON j.MechanicId = m.MechanicId
ORDER BY j.MechanicId, IssueDate, JobId

--6. Current Clients
SELECT CONCAT(c.FirstName, ' ', c.LastName) AS [Client],
		DATEDIFF(day, j.IssueDate, '2017-04-24') AS [Days going],
		j.Status
FROM Jobs AS j
JOIN Clients AS c ON j.ClientId = c.ClientId
WHERE j.Status != 'Finished'
ORDER BY [Days going] DESC, c.ClientId

--7. Mechanic Performance
SELECT  	CONCAT(m.FirstName, ' ', m.LastName) AS [Mechanic],
			AVG(DATEDIFF(day, j.IssueDate, j.FinishDate)) AS [Average Days]
		FROM Jobs AS j
		JOIN Mechanics AS m ON j.MechanicId = m.MechanicId
		GROUP BY M.MechanicId, CONCAT(m.FirstName, ' ', m.LastName)
		ORDER BY m.MechanicId

--8. Available Mechanics
SELECT CONCAT(m.FirstName, ' ', m.LastName) AS [Mechanic]
	FROM Mechanics AS m
	LEFT JOIN Jobs As j ON m.MechanicId = j.MechanicId
	WHERE j.JobId IS NULL OR (SELECT COUNT(JobId)
									FROM Jobs
									WHERE Status != 'Finished' AND MechanicId = m.MechanicId
								GROUP BY MechanicId, Status) IS NULL
GROUP BY m.MechanicId, CONCAT(m.FirstName, ' ', m.LastName)
ORDER BY m.MechanicId

--9. Past Expenses
SELECT j.JobId,
	ISNULL(SUM(p.Price * op.Quantity),0) AS [Total]
	FROM Jobs AS j
LEFT JOIN Orders As o ON j.JobId = o.JobId
LEFT JOIN OrderParts AS op ON o.OrderId = op.OrderId
LEFT JOIN Parts AS p ON op.PartId = p.PartId
	WHERE j.Status = 'Finished'
	GROUP BY j.JobId
	ORDER BY SUM(p.Price) DESC, j.JobId

-- 10. Missing Parts
SELECT p.PartId, 
		p.Description,
		pn.Quantity AS [Required], 
		p.StockQty AS [In Stock],
		IIF(o.Delivered = 0, op.Quantity, 0) AS Ordered
		FROM Parts AS p
LEFT JOIN PartsNeeded AS pn ON p.PartId = pn.PartId
LEFT JOIN OrderParts AS op ON op.PartId = p.PartId
LEFT JOIN Jobs AS j ON pn.JobId = j.JobId
LEFT JOIN Orders AS o ON j.JobId = o.JobId
WHERE j.Status != 'FINISHED' AND 
	p.StockQty + IIF(o.Delivered = 0, op.Quantity, 0) < pn.Quantity
ORDER BY PartId

--OR:
SELECT p.PartId, 
		p.Description,
		SUM(pn.Quantity) AS [Required], 
		SUM(p.StockQty) AS [In Stock],
		0 AS Delivered
		FROM Jobs AS j
	FULL JOIN Orders AS o ON j.JobId = o.JobId
		 JOIN PartsNeeded AS pn ON j.JobId = pn.JobId
		 JOIN Parts AS p ON p.PartId = pn.PartId
WHERE j.Status != 'FINISHED' AND o.Delivered IS NULL
GROUP BY p.PartId, p.Description
HAVING SUM(p.StockQty) < SUM(pn.Quantity);

--11. Place Order
CREATE PROCEDURE usp_PlaceOrder(@JobId INT, @PartSerialNumber VARCHAR(50), @Quantity INT)
AS
    IF ((SELECT Status
         FROM Jobs
         WHERE JobId = @JobId) = 'Finished')
        THROW 50011, 'This job is not active!', 1
    IF (@Quantity <= 0)
        THROW 50012, 'Part quantity must be more than zero!', 1

DECLARE
    @job INT = (SELECT JobId
                FROM Jobs
                WHERE JobId = @JobId)
    IF (@job IS NULL)
        THROW 50013, 'Job not found!', 1

DECLARE
    @partId INT = (SELECT PartId
                   FROM Parts
                   WHERE SerialNumber = @PartSerialNumber)
    IF (@partId IS NULL)
        begin
            THROW 50014, 'Part not found!', 1
        end
    IF ((SELECT OrderId
         FROM Orders
         WHERE JobId = @JobId
           AND IssueDate IS NULL) IS NULL)
        BEGIN
            INSERT INTO Orders (JobId, IssueDate, Delivered)
            VALUES (@JobId, NULL, 0)
        END

declare
    @orderId int= (
        SELECT OrderId
        FROM Orders
        WHERE JobId = @JobId
          AND IssueDate IS NULL
    )

DECLARE
    @orderPartsQuantity INT = (SELECT Quantity
                               FROM OrderParts
                               WHERE OrderId = @orderId
                                 AND PartId = @partId)
    IF (@orderPartsQuantity IS NULL)
        BEGIN
            INSERT INTO OrderParts (OrderId, PartId, Quantity)
            VALUES (@orderId, @partId, @Quantity)
        END
    ELSE
        BEGIN
            UPDATE OrderParts
            SET Quantity += @Quantity
            WHERE OrderId = @orderId
              AND PartId = @partId
        END

--12. Cost of Order
CREATE FUNCTION udf_GetCost(@jobId INT)
RETURNS DECIMAL (18, 2)
AS
BEGIN
	DECLARE @TotalSum DECIMAL(18,2)

		SET @TotalSum = (SELECT SUM(p.Price * op.Quantity) AS [TotalSum]
						FROM Jobs AS j
						JOIn Orders AS o ON j.JobId = o.JobId
						JOIN OrderParts AS op ON o.OrderId = op.OrderId
						JOIN Parts AS p ON op.PartId = p.PartId
						WHERE j.JobId = @jobId
						GROUP BY j.JobId)

	IF(@TotalSum IS NULL)
	BEGIN
		SET @TotalSum = 0
	END
	
	RETURN @TotalSum
	
END 
GO

SELECT dbo.udf_GetCost(1)



