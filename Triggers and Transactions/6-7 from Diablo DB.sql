--6. Trigger
SELECT * FROM UsersGames

CREATE TRIGGER tr_RestrictInsetingItems
    ON UserGameItems
    INSTEAD OF INSERT AS
BEGIN
    INSERT INTO UserGameItems
    SELECT i.Id, ug.Id
    FROM inserted
             JOIN UsersGames AS ug
                  ON UserGameId = ug.Id
             JOIN Items AS i
                  ON ItemId = i.id
    WHERE ug.Level >= i.MinLevel
END
GO

UPDATE UsersGames
SET Cash += 50000
FROM UsersGames AS ug
	JOIN Games AS g ON g.Id = ug.GameId
	JOIN Users AS u ON ug.UserId = u.Id
	WHERE g.Name = 'Bali' AND
		u.Username IN ('baleremuda', 'loosenoise', 'inguinalself', 'buildingdeltoid', 'monoxidecos')


CREATE PROC usp_BuyItems(@Username nvarchar(50))
AS
BEGIN
    DECLARE @UserId int =
        (SELECT id
         FROM Users
         WHERE Username = @Username)
    DECLARE @GameId int=
        (SELECT id
         FROM Games
         WHERE Name = 'Bali')
    DECLARE @UserGameId int=
        (SELECT Id
         FROM UsersGames
         WHERE UserId = @UserId
           AND GameId = @GameId)
    DECLARE @UserGameLevel int=
            (SELECT Level FROM UsersGames WHERE Id = @UserGameId)
    DECLARE @IdCounter int = 251;

    WHILE @IdCounter <= 539
        BEGIN
            DECLARE @ItemId int = @IdCounter;
            DECLARE @ItemPrice money=
                    (SELECT Price FROM Items WHERE Id = @ItemId)
            DECLARE @ItemLevel int=
                    (SELECT MinLevel FROM Items WHERE Id = @ItemId)
            DECLARE @UserGameCash money=
                    (SELECT Cash FROM UsersGames WHERE id = @UserGameId)

            IF (@UserGameCash >= @ItemPrice AND @UserGameLevel >= @ItemLevel)
                BEGIN
                    UPDATE UsersGames
                    SET Cash-=@ItemPrice
                    WHERE Id = @UserGameId
                    INSERT INTO UserGameItems
                    VALUES (@ItemId, @UserGameId)
                END

            SET @IdCounter+=1;
            IF (@IdCounter = 300)
                BEGIN
                    SET @IdCounter = 501;
                END
        END
END
GO

EXEC usp_BuyItems 'baleremuda'
EXEC usp_BuyItems 'loosenoise'
EXEC usp_BuyItems 'inguinalself'
EXEC usp_BuyItems 'buildingdeltoid'
EXEC usp_BuyItems 'monoxidecos'

GO


SELECT u.UserName, g.Name, Cash, i.Name AS [Item Name]
FROM UsersGames AS ug
JOIN Games AS g ON ug.GameId = g.Id
JOIN Users AS u ON ug.UserId = u.Id
JOIN UserGameItems AS ugi ON ug.Id = ugi.UserGameId
JOIN Items AS i ON ugi.ItemId = i.Id
WHERE g.Name = 'Bali'
ORDER BY Username, [Item Name]
GO

--7. Massive Shopping
DECLARE @StamatID INT = (
                        SELECT Id 
                          FROM Users 
                         WHERE Username = 'Stamat'
                      )
DECLARE @SafflowerID INT = (
                        SELECT Id 
                          FROM Games 
                         WHERE Name = 'Safflower'
                      )
DECLARE @StamatMoney MONEY = (
                        SELECT Cash 
                          FROM UsersGames
                         WHERE UserId = @StamatID AND GameId = @SafflowerID
                      )
DECLARE @itemsTotalPrice MONEY
DECLARE @StamatSafflowerID int = (
                        SELECT Id 
                          FROM UsersGames 
                         WHERE UserId = @StamatID AND GameId = @SafflowerID
                      )
 
BEGIN TRANSACTION
      SET @itemsTotalPrice = (SELECT SUM(Price) 
     FROM Items 
    WHERE MinLevel BETWEEN 11 AND 12)
 
    IF(@StamatMoney - @itemsTotalPrice >= 0)
    BEGIN
        INSERT INTO UserGameItems
        SELECT i.Id, @StamatSafflowerID FROM Items AS i
        WHERE i.Id IN (
                        SELECT Id 
                          FROM Items 
                         WHERE MinLevel BETWEEN 11 AND 12
                      )
 
        UPDATE UsersGames
        SET Cash -= @itemsTotalPrice
        WHERE GameId = @SafflowerID AND UserId = @StamatID
        COMMIT
    END
    ELSE
    BEGIN
        ROLLBACK
    END
 
SET @StamatMoney = (
                    SELECT Cash 
                      FROM UsersGames 
                     WHERE UserId = @StamatID AND GameId = @SafflowerID
                 )
BEGIN TRANSACTION
    SET @itemsTotalPrice = (SELECT SUM(Price) FROM Items WHERE MinLevel BETWEEN 19 AND 21)
 
    IF(@StamatMoney - @itemsTotalPrice >= 0)
    BEGIN
        INSERT INTO UserGameItems
        SELECT i.Id, @StamatSafflowerID FROM Items AS i
        WHERE i.Id IN (
                        SELECT Id 
                          FROM Items 
                         WHERE MinLevel BETWEEN 19 AND 21
                      )
 
        UPDATE UsersGames
        SET Cash -= @itemsTotalPrice
        WHERE GameId = @StamatSafflowerID AND UserId = @StamatID
        COMMIT
    END
    ELSE
    BEGIN
        ROLLBACK
    END
 
  SELECT Name AS [Item Name]
    FROM Items
   WHERE Id IN (
                SELECT ItemId 
                  FROM UserGameItems 
                 WHERE UserGameId = @STamatSafflowerID
               )
ORDER BY [Item Name]
