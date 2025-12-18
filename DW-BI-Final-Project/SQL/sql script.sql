------------------------------------------
-- 1) إنشاء قاعدة البيانات + السكيمات
------------------------------------------

CREATE DATABASE RetailDW;
GO
USE RetailDW;
GO

CREATE SCHEMA stg;
GO

CREATE SCHEMA dw;
GO


------------------------------------------
-- 2) إنشاء جداول الـ STAGING
------------------------------------------

-- جدول العملاء
CREATE TABLE stg.Customers (
    CustomerID NVARCHAR(50),
    CustomerName NVARCHAR(100),
    City NVARCHAR(100),
    Gender NVARCHAR(20)
);

-- جدول المنتجات
CREATE TABLE stg.Products (
    ProductID NVARCHAR(50),
    ProductName NVARCHAR(100),
    Category NVARCHAR(100),
    Price FLOAT
);

-- جدول المبيعات
CREATE TABLE stg.Sales (
    OrderID INT,
    CustomerID NVARCHAR(50),
    ProductID NVARCHAR(50),
    Quantity INT,
    OrderDate DATE
);


------------------------------------------
-- 3) إنشاء جداول الـ DATA WAREHOUSE
------------------------------------------

-- DimCustomer
CREATE TABLE dw.DimCustomer (
    CustomerKey INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID NVARCHAR(50),
    CustomerName NVARCHAR(100),
    City NVARCHAR(100),
    Gender NVARCHAR(20)
);

-- DimProduct
CREATE TABLE dw.DimProduct (
    ProductKey INT IDENTITY(1,1) PRIMARY KEY,
    ProductID NVARCHAR(50),
    ProductName NVARCHAR(100),
    Category NVARCHAR(100),
    Price FLOAT
);

-- DimDate
CREATE TABLE dw.DimDate (
    DateKey INT PRIMARY KEY,
    FullDate DATE,
    Day INT,
    Month INT,
    MonthName NVARCHAR(20),
    Year INT
);

-- FactSales
CREATE TABLE dw.FactSales (
    SalesKey INT IDENTITY(1,1) PRIMARY KEY,
    CustomerKey INT,
    ProductKey INT,
    DateKey INT,
    Quantity INT,
    TotalAmount FLOAT
);


------------------------------------------
-- 4) تعبئة جدول التاريخ DimDate
------------------------------------------

INSERT INTO dw.DimDate (DateKey, FullDate, Day, Month, MonthName, Year)
SELECT
    CONVERT(VARCHAR(8), DateValue, 112) AS DateKey,
    DateValue AS FullDate,
    DAY(DateValue),
    MONTH(DateValue),
    DATENAME(MONTH, DateValue),
    YEAR(DateValue)
FROM
(
    SELECT DATEADD(DAY, ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1, '2023-01-01') AS DateValue
    FROM master..spt_values
) AS Dates
WHERE DateValue <= '2023-12-31';


------------------------------------------
-- 5) SELECT للتأكد من البيانات
------------------------------------------

SELECT * FROM stg.Customers;
SELECT * FROM stg.Products;
SELECT * FROM stg.Sales;

SELECT * FROM dw.DimCustomer;
SELECT * FROM dw.DimProduct;
SELECT * FROM dw.DimDate;
SELECT * FROM dw.FactSales;
