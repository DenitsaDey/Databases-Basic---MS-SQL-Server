-- 8. Create Table Users
CREATE TABLE Users
(
Id BIGINT PRIMARY KEY IDENTITY NOT NULL,
Username VARCHAR(30) UNIQUE NOT NULL,
[Password] VARCHAR(26) NOT NULL,
ProfilePicture VARBINARY(MAX)
CHECK(DATALENGTH(ProfilePicture)<=900*1024),
LastLoginTime DATETIME2 NOT NULL,
IsDeleted BIT NOT NULL
)

INSERT INTO Users(Username, [Password], LastLoginTime, IsDeleted)
VALUES
	('Deni53', 'sunny999', '01.07.2021', 0),
	('Deni43', 'sunny999', '01.07.2021', 1),
	('Deni33', 'sunny999', '01.07.2021', 0),
	('Deni23', 'sunny999', '01.07.2021', 0),
	('Deni13', 'sunny999', '01.07.2021', 1)

-- 9. Change Primary Key
ALTER TABLE Users
DROP CONSTRAINT [PK__Users__3214EC0746423206]

ALTER TABLE Users
ADD CONSTRAINT PK__Users__CompositeIdUsername
PRIMARY KEY(Id, Username)

-- 10. Add Check Constraint
ALTER TABLE Users
ADD CONSTRAINT CK_Users_PasswordLength
CHECK(LEN([Password]) >= 5)

-- 11. Set Default Value of a field
ALTER TABLE Users
ADD CONSTRAINT DF_Users_LastLoginTime
DEFAULT GETDATE() FOR LastLoginTime

-- 12. Set Unique Field
ALTER TABLE Users
DROP CONSTRAINT PK__Users__CompositeIdUsername

ALTER TABLE Users
ADD CONSTRAINT PK_Users_Id
PRIMARY KEY (Id)

ALTER TABLE Users
ADD CONTRAINT CK_Users_UsernameLength
CHECK(LEN(Username) >=3)
