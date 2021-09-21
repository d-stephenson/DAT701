
-- https://www.sqlshack.com/how-to-use-sargable-expressions-in-t-sql-queries-performance-advantages-and-examples/

use AdventureWorks2017
    
DROP TABLE IF EXISTS Dummy_PersonTable
CREATE TABLE Dummy_PersonTable
(    ID [int] NOT NULL PRIMARY KEY IDENTITY(1,1),
    [PersonType] [nchar](2) NOT NULL,
    [NameStyle] [dbo].[NameStyle] NOT NULL,
    [Title] [nvarchar](8) NULL,
    [FirstName] [dbo].[Name] NOT NULL,
    [MiddleName] [dbo].[Name] NULL,
    [LastName] [dbo].[Name] NOT NULL,
    [Suffix] [nvarchar](10) NULL,
    [EmailPromotion] [int] NOT NULL,
    [AdditionalContactInfo] [xml](CONTENT [Person].[AdditionalContactInfoSchemaCollection]) NULL,
    [Demographics] [xml](CONTENT [Person].[IndividualSurveySchemaCollection]) NULL,
    [rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
    [ModifiedDate] [datetime] NOT NULL )
 
CREATE NONCLUSTERED INDEX [NonClustered_FirstName] ON [dbo].[Dummy_PersonTable]
(
    [FirstName] ASC
 
)
CREATE NONCLUSTERED INDEX [NonClustered_ModifiedDate] ON [dbo].[Dummy_PersonTable]
(
    [ModifiedDate] ASC
)
 
CREATE NONCLUSTERED INDEX [NonClustered_MiddleName] ON [dbo].[Dummy_PersonTable]
(
    [MiddleName] ASC
)
 
 
INSERT INTO Dummy_PersonTable
    SELECT
      [PersonType]
      ,[NameStyle]
      ,[Title]
      ,[FirstName]
      ,[MiddleName]
      ,[LastName]
      ,[Suffix]
      ,[EmailPromotion]
      ,[AdditionalContactInfo]
      ,[Demographics]
      ,[rowguid]
      ,[ModifiedDate]
  FROM [Person].[Person]
  GO 100

  SELECT FirstName  FROM Dummy_PersonTable where LEFT(FirstName,1)='K'

  SELECT FirstName  FROM Dummy_PersonTable where FirstName  LIKE 'K%'

DROP INDEX IF EXISTS FirstName_Left ON Dummy_PersonTable
ALTER TABLE dbo.Dummy_PersonTable  ADD FirstName_Left   AS LEFT(FirstName,1)
CREATE NONCLUSTERED INDEX [NonClusteredIndex_LeftFirstName] ON [dbo].[Dummy_PersonTable]
(
    [FirstName_Left] ASC
)
INCLUDE (     [FirstName])

SELECT ModifiedDate FROM Dummy_PersonTable where YEAR(ModifiedDate)=2009

     
SELECT ModifiedDate FROM Dummy_PersonTable where ModifiedDate BETWEEN '20090101' AND '20091231'

SELECT MiddleName FROM Dummy_PersonTable where ISNULL(MiddleName,'E') ='E'

SELECT MiddleName FROM Dummy_PersonTable where  (MiddleName IS NULL OR MiddleName='E')

