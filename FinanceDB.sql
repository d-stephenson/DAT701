USE [master]
GO
/****** Object:  Database [FinanceDB]    Script Date: 1/11/2021 3:06:18 PM ******/
CREATE DATABASE [FinanceDB]
 CONTAINMENT = NONE
 ON  PRIMARY
( NAME = N'FinanceDB', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\FinanceDB.mdf' , SIZE = 1750208KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON
( NAME = N'FinanceDB_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\FinanceDB_log.ldf' , SIZE = 19697408KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO
ALTER DATABASE [FinanceDB] SET COMPATIBILITY_LEVEL = 120
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [FinanceDB].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [FinanceDB] SET ANSI_NULL_DEFAULT OFF
GO
ALTER DATABASE [FinanceDB] SET ANSI_NULLS OFF
GO
ALTER DATABASE [FinanceDB] SET ANSI_PADDING OFF
GO
ALTER DATABASE [FinanceDB] SET ANSI_WARNINGS OFF
GO
ALTER DATABASE [FinanceDB] SET ARITHABORT OFF
GO
ALTER DATABASE [FinanceDB] SET AUTO_CLOSE OFF
GO
ALTER DATABASE [FinanceDB] SET AUTO_SHRINK OFF
GO
ALTER DATABASE [FinanceDB] SET AUTO_UPDATE_STATISTICS ON
GO
ALTER DATABASE [FinanceDB] SET CURSOR_CLOSE_ON_COMMIT OFF
GO
ALTER DATABASE [FinanceDB] SET CURSOR_DEFAULT  GLOBAL
GO
ALTER DATABASE [FinanceDB] SET CONCAT_NULL_YIELDS_NULL OFF
GO
ALTER DATABASE [FinanceDB] SET NUMERIC_ROUNDABORT OFF
GO
ALTER DATABASE [FinanceDB] SET QUOTED_IDENTIFIER OFF
GO
ALTER DATABASE [FinanceDB] SET RECURSIVE_TRIGGERS OFF
GO
ALTER DATABASE [FinanceDB] SET  DISABLE_BROKER
GO
ALTER DATABASE [FinanceDB] SET AUTO_UPDATE_STATISTICS_ASYNC OFF
GO
ALTER DATABASE [FinanceDB] SET DATE_CORRELATION_OPTIMIZATION OFF
GO
ALTER DATABASE [FinanceDB] SET TRUSTWORTHY OFF
GO
ALTER DATABASE [FinanceDB] SET ALLOW_SNAPSHOT_ISOLATION OFF
GO
ALTER DATABASE [FinanceDB] SET PARAMETERIZATION SIMPLE
GO
ALTER DATABASE [FinanceDB] SET READ_COMMITTED_SNAPSHOT OFF
GO
ALTER DATABASE [FinanceDB] SET HONOR_BROKER_PRIORITY OFF
GO
ALTER DATABASE [FinanceDB] SET RECOVERY FULL
GO
ALTER DATABASE [FinanceDB] SET  MULTI_USER
GO
ALTER DATABASE [FinanceDB] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [FinanceDB] SET DB_CHAINING OFF
GO
ALTER DATABASE [FinanceDB] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF )
GO
ALTER DATABASE [FinanceDB] SET TARGET_RECOVERY_TIME = 0 SECONDS
GO
ALTER DATABASE [FinanceDB] SET DELAYED_DURABILITY = DISABLED
GO
EXEC sys.sp_db_vardecimal_storage_format N'FinanceDB', N'ON'
GO
ALTER DATABASE [FinanceDB] SET QUERY_STORE = OFF
GO
USE [FinanceDB]
GO
/****** Object:  Table [dbo].[Country]    Script Date: 1/11/2021 3:06:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Country](
    [CountryID] [tinyint] IDENTITY(1,1) NOT NULL,
    [CountryName] [nvarchar](28) NULL,
PRIMARY KEY CLUSTERED
(
    [CountryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Product]    Script Date: 1/11/2021 3:06:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Product](
    [ProductID] [tinyint] IDENTITY(0,1) NOT NULL,
    [ProductName] [nvarchar](12) NULL,
PRIMARY KEY CLUSTERED
(
    [ProductID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ProductCost]    Script Date: 1/11/2021 3:06:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ProductCost](
    [ProductCostID] [smallint] IDENTITY(1,1) NOT NULL,
    [ProductID] [tinyint] NULL,
    [CountryID] [tinyint] NULL,
    [ManufacturingPrice] [float] NULL,
    [RRP] [float] NULL,
PRIMARY KEY CLUSTERED
(
    [ProductCostID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Promotion]    Script Date: 1/11/2021 3:06:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Promotion](
    [PromotionID] [smallint] IDENTITY(0,1) NOT NULL,
    [PromotionYear] [int] NULL,
    [ProductID] [tinyint] NULL,
    [Discount] [float] NULL,
PRIMARY KEY CLUSTERED
(
    [PromotionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Region]    Script Date: 1/11/2021 3:06:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Region](
    [RegionID] [tinyint] IDENTITY(1,1) NOT NULL,
    [CountryID] [tinyint] NULL,
    [SegmentID] [tinyint] NULL,
PRIMARY KEY CLUSTERED
(
    [RegionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SalesKPI]    Script Date: 1/11/2021 3:06:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SalesKPI](
    [KPIID] [smallint] IDENTITY(1,1) NOT NULL,
    [SalesPersonID] [tinyint] NULL,
    [SalesYear] [int] NULL,
    [KPI] [float] NULL,
PRIMARY KEY CLUSTERED
(
    [KPIID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SalesOrder]    Script Date: 1/11/2021 3:06:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SalesOrder](
    [SalesOrderID] [bigint] IDENTITY(1,1) NOT NULL,
    [SalesOrderNumber] [nvarchar](24) NULL,
    [SalesOrderDate] [datetime] NULL,
    [SalesPersonID] [tinyint] NULL,
    [SalesRegionID] [smallint] NULL,
    [SalesMonth] [date] NULL,
PRIMARY KEY CLUSTERED
(
    [SalesOrderID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SalesOrderLineItem]    Script Date: 1/11/2021 3:06:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SalesOrderLineItem](
    [SalesOrderLineItemID] [bigint] IDENTITY(1,1) NOT NULL,
    [SalesOrderID] [bigint] NULL,
    [SalesOrderLineNumber] [smallint] NULL,
    [PromotionID] [smallint] NULL,
    [ProductID] [tinyint] NULL,
    [UnitsSold] [smallint] NULL,
    [SalePrice] [float] NULL
) ON [PRIMARY]
GO
/****** Object:  Index [PK__SalesOrd__DAA33720861CAF46]    Script Date: 1/11/2021 3:06:19 PM ******/
CREATE CLUSTERED INDEX [PK__SalesOrd__DAA33720861CAF46] ON [dbo].[SalesOrderLineItem]
(
    [SalesOrderLineItemID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SalesPerson]    Script Date: 1/11/2021 3:06:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SalesPerson](
    [SalesPersonID] [tinyint] IDENTITY(1,1) NOT NULL,
    [FirstName] [nvarchar](32) NULL,
    [LastName] [nvarchar](32) NULL,
    [Gender] [nvarchar](10) NULL,
    [HireDate] [date] NULL,
    [DayOfBirth] [date] NULL,
    [DaysOfLeave] [int] NULL,
    [DaysOfSickLeave] [int] NULL,
PRIMARY KEY CLUSTERED
(
    [SalesPersonID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SalesRegion]    Script Date: 1/11/2021 3:06:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SalesRegion](
    [SalesRegionID] [smallint] IDENTITY(1,1) NOT NULL,
    [RegionID] [tinyint] NULL,
    [SalesPersonID] [tinyint] NULL,
PRIMARY KEY CLUSTERED
(
    [SalesRegionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Segment]    Script Date: 1/11/2021 3:06:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Segment](
    [SegmentID] [tinyint] IDENTITY(1,1) NOT NULL,
    [SegmentName] [nvarchar](24) NULL,
PRIMARY KEY CLUSTERED
(
    [SegmentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[stage_SalesOrder]    Script Date: 1/11/2021 3:06:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[stage_SalesOrder](
    [FirstName] [nvarchar](32) NULL,
    [LastName] [nvarchar](32) NULL,
    [SegmentName] [nvarchar](24) NULL,
    [Product] [nvarchar](12) NULL,
    [OrderNumber] [nvarchar](24) NULL,
    [OrderDate] [nvarchar](32) NULL,
    [SalesMonth] [nvarchar](32) NULL,
    [OrderLineNumber] [int] NULL,
    [Promotion] [int] NULL,
    [UnitsSold] [int] NULL,
    [SalePriceDollars] [int] NULL,
    [SalePriceCents] [int] NULL,
    [ManufacturingPrice] [int] NULL,
    [RRP] [int] NULL,
    [OrderYear] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Index [IX_calcs_cte_1]    Script Date: 1/11/2021 3:06:19 PM ******/
CREATE NONCLUSTERED INDEX [IX_calcs_cte_1] ON [dbo].[SalesOrderLineItem]
(
    [SalesOrderID] ASC,
    [UnitsSold] ASC,
    [SalePrice] ASC
)
INCLUDE([ProductID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ProductCost]  WITH CHECK ADD FOREIGN KEY([CountryID])
REFERENCES [dbo].[Country] ([CountryID])
GO
ALTER TABLE [dbo].[ProductCost]  WITH CHECK ADD FOREIGN KEY([ProductID])
REFERENCES [dbo].[Product] ([ProductID])
GO
ALTER TABLE [dbo].[Promotion]  WITH CHECK ADD FOREIGN KEY([ProductID])
REFERENCES [dbo].[Product] ([ProductID])
GO
ALTER TABLE [dbo].[Region]  WITH CHECK ADD FOREIGN KEY([CountryID])
REFERENCES [dbo].[Country] ([CountryID])
GO
ALTER TABLE [dbo].[Region]  WITH CHECK ADD FOREIGN KEY([SegmentID])
REFERENCES [dbo].[Segment] ([SegmentID])
GO
ALTER TABLE [dbo].[SalesKPI]  WITH NOCHECK ADD FOREIGN KEY([SalesPersonID])
REFERENCES [dbo].[SalesPerson] ([SalesPersonID])
GO
ALTER TABLE [dbo].[SalesOrder]  WITH CHECK ADD FOREIGN KEY([SalesPersonID])
REFERENCES [dbo].[SalesPerson] ([SalesPersonID])
GO
ALTER TABLE [dbo].[SalesOrder]  WITH CHECK ADD FOREIGN KEY([SalesRegionID])
REFERENCES [dbo].[SalesRegion] ([SalesRegionID])
GO
ALTER TABLE [dbo].[SalesOrderLineItem]  WITH CHECK ADD FOREIGN KEY([ProductID])
REFERENCES [dbo].[Product] ([ProductID])
GO
ALTER TABLE [dbo].[SalesOrderLineItem]  WITH CHECK ADD FOREIGN KEY([PromotionID])
REFERENCES [dbo].[Promotion] ([PromotionID])
GO
ALTER TABLE [dbo].[SalesOrderLineItem]  WITH CHECK ADD FOREIGN KEY([SalesOrderID])
REFERENCES [dbo].[SalesOrder] ([SalesOrderID])
GO
ALTER TABLE [dbo].[SalesRegion]  WITH CHECK ADD FOREIGN KEY([RegionID])
REFERENCES [dbo].[Region] ([RegionID])
GO
ALTER TABLE [dbo].[SalesRegion]  WITH CHECK ADD FOREIGN KEY([SalesPersonID])
REFERENCES [dbo].[SalesPerson] ([SalesPersonID])
GO
/****** Object:  StoredProcedure [dbo].[create_tables]    Script Date: 1/11/2021 3:06:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/****** Object:  StoredProcedure [dbo].[sproc_unstage_line_items]    Script Date: 1/11/2021 3:06:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[sproc_unstage_line_items]
as
begin
    insert into SalesOrder   (SalesOrderNumber, SalesOrderDate, SalesPersonID, SalesRegionID, SalesMonth)
        select distinct
            sso.OrderNumber,
            convert(date, sso.OrderDate),
            sp.SalesPersonID,
            sr.SalesRegionID,
            sso.SalesMonth
        from stage_SalesOrder sso
            inner join SalesPerson sp on sp.FirstName = sso.FirstName and sp.LastName = sso.LastName
            inner join SalesRegion sr on sr.SalesPersonID = sp.SalesPersonID
            inner join Region r on r.RegionID = sr.RegionID
            inner join Segment s on s.SegmentID = r.SegmentID and s.SegmentName = sso.SegmentName
        where sso.OrderYear < 2017;

    insert into SalesOrderLineItem (SalesOrderID, SalesOrderLineNumber, PromotionID, ProductID, UnitsSold, SalePrice)
        select
            so.SalesOrderID,
            sso.OrderLineNumber,
            case when sso.Promotion = 0 then 0 else p.PromotionID end as PromotionID,
            pr.ProductID,
            sso.UnitsSold,
            sso.SalePriceDollars + (sso.SalePriceCents / 100.0) as SalePrice
        from stage_SalesOrder sso
            inner join SalesOrder so on so.SalesOrderNumber = sso.OrderNumber
            left join Product pr on pr.ProductName = sso.Product
            left join (
                select pr.PromotionID, pr.PromotionYear, p.ProductName
                from Promotion pr
                inner join Product p on p.ProductID = pr.ProductID
            ) p on p.PromotionYear = sso.OrderYear and p.ProductName = sso.Product;

    truncate table stage_SalesOrder;

end;
GO
USE [master]
GO
ALTER DATABASE [FinanceDB] SET  READ_WRITE
GO