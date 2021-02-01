--1. Create Table Logs
CREATE TABLE Logs
(
LogId INT PRIMARY KEY IDENTITY,
AccountId INT FOREIGN KEY REFERENCES Accounts(Id),
OldSum DECIMAL(10, 2) NOT NULL,
NewSum DECIMAL(10,2) NOT NULL
)
	
CREATE TRIGGER tr_LogsOfAccountChanges ON Accounts 
FOR UPDATE
AS
INSERT INTO Logs(AccountId, OldSum,NewSum)
SELECT i.Id, d.Balance, i.Balance
FROM inserted AS i
JOIN deleted AS d ON i.Id = d.Id
WHERE i.Balance != d.Balance
GO

--2. Create Table Emails
CREATE TABLE NotificationEmails
(
Id INT PRIMARY KEY IDENTITY,
Recipient INT FOREIGN KEY REFERENCES Accounts(Id),
[Subject] NVARCHAR(MAX) NOT NULL,
Body NVARCHAR(MAX) NOT NULL
)

CREATE OR ALTER TRIGGER tr_CreateNewEmail ON Logs 
FOR INSERT
AS
INSERT INTO NotificationEmails(Recipient, Subject, Body)
SELECT i.AccountId, 
	'Balance change for account: ' + CAST(i.AccountId AS NVARCHAR(20)),
	'On ' + CONVERT(NVARCHAR(20),GETDATE(),100) + ' your balance was changed from ' + CAST(i.OldSum AS NVARCHAR(20)) + ' to ' + CAST(i.NewSum AS NVARCHAR(20)) + '.'
	FROM inserted AS i


/* from the Lab
CREATE PROC usp_TransferFunds(@FromAccountID int, @ToAccountID int, @Amount money)
AS
    BEGIN TRANSACTION
    IF (@Amount <= 0)
        BEGIN
            --  ROLLBACK -revert the transaction that has began
            THROW 50004,'Invalid amount value.',1;
            -- return
        END
    IF ((SELECT COUNT(*)
         FROM Accounts
         WHERE Id = @FromAccountID) != 1)
        BEGIN
            THROW 50001, 'Invalid account sender.',1;
        END
    IF ((SELECT COUNT(*)
         FROM Accounts
         WHERE Id = @ToAccountID) != 1)
        BEGIN
            THROW 50002, 'Invalid account receiver.',1;
        END
    IF (SELECT Balance
        FROM Accounts
        WHERE id = @FromAccountID )< @Amount
        BEGIN
            THROW 50003,'Insufficient funds to execute this transaction.',1;
        END

UPDATE Accounts
SET Balance=Balance - @Amount
WHERE id = @FromAccountID
UPDATE Accounts
SET Balance= Balance + @Amount
WHERE id = @ToAccountID
    COMMIT
GO
*/

exec usp_TransferFunds 12, 15,1000

SELECT * from Logs
SELECT *
FROM NotificationEmails;

--3. Deposit Money
CREATE PROC usp_DepositMoney (@AccountId INT, @MoneyAmount MONEY)
AS
BEGIN TRANSACTION
	IF((SELECT COUNT(*) 
			FROM Accounts
			WHERE Id = @AccountId) < 1) 
		BEGIN
			THROW 50001, 'Not existing account',1;
		END
	IF(@MoneyAmount < 0)
	BEGIN
		THROW 50002, 'Invalid money amount',1;
	END

UPDATE Accounts
SET Balance += @MoneyAmount
WHERE Id = @AccountId
COMMIT
GO

exec usp_DepositMoney 1, 10

SELECT * FROM Logs
SELECT * FROM NotificationEmails

--4. Withdraw Money
CREATE OR ALTER PROC usp_WithdrawMoney (@AccountId INT, @MoneyAmount DECIMAL(18,4))
AS
BEGIN TRANSACTION 
	IF (@MoneyAmount < 0)
		BEGIN
			THROW 50001, 'Amount cannot be negative',1;
		END
	IF((SELECT COUNT(*) 
		FROM Accounts
		WHERE Id = @AccountID) != 1)
		BEGIN
			THROW 50002, 'Invalid account Id', 1;
		END

	UPDATE Accounts
	SET Balance -= @MoneyAmount
	WHERE Id = @AccountId
COMMIT
GO

EXEC usp_WithdrawMoney 5, 25
SELECT * FROM Logs
SELECT * FROM NotificationEmails

--5. Money Transfer
CREATE PROC usp_TransferMoney(@SenderId INT, @ReceiverId INT, @Amount DECIMAL(18,4)) 
AS
BEGIN TRANSACTION 
	EXEC usp_DepositMoney @ReceiverId, @Amount
	EXEC usp_WithdrawMoney @SenderId, @Amount
COMMIT
GO

EXEC usp_TransferMoney 5, 1, 5000

