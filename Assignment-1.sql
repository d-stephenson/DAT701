-- Assignment 1 | DAT701

USE FinanceDB
GO
SELECT SUSER_SNAME(sid), * from sys.database_principals

ALTER AUTHORIZATION ON DATABASE::[FinanceDB] TO [sa]
GO

