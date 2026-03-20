-- Cleaned shopping data model (SQL Server / T-SQL)
-- This script is written as if the raw dataset has already been cleaned and transformed
-- into a star schema for reporting in Power BI.
--
-- Assumptions:
-- 1. Raw source table = dbo.raw_shopping
-- 2. One row in raw_shopping = one purchase
-- 3. Purchase ID is unique after de-duplication
-- 4. This script standardizes values, removes blanks, casts data types,
--    and builds dimension + fact tables for analytics.

/*
=====================================================================
1. OPTIONAL CLEANUP
=====================================================================
*/

IF OBJECT_ID('dbo.fact_purchases', 'U') IS NOT NULL DROP TABLE dbo.fact_purchases;
IF OBJECT_ID('dbo.dim_customer', 'U') IS NOT NULL DROP TABLE dbo.dim_customer;
IF OBJECT_ID('dbo.dim_product', 'U') IS NOT NULL DROP TABLE dbo.dim_product;
IF OBJECT_ID('dbo.dim_location', 'U') IS NOT NULL DROP TABLE dbo.dim_location;
IF OBJECT_ID('dbo.dim_payment_method', 'U') IS NOT NULL DROP TABLE dbo.dim_payment_method;
IF OBJECT_ID('dbo.dim_shipping_type', 'U') IS NOT NULL DROP TABLE dbo.dim_shipping_type;
IF OBJECT_ID('dbo.dim_season', 'U') IS NOT NULL DROP TABLE dbo.dim_season;
IF OBJECT_ID('dbo.stg_shopping_clean', 'U') IS NOT NULL DROP TABLE dbo.stg_shopping_clean;

/*
=====================================================================
2. STAGING TABLE (CLEANED RAW DATA)
=====================================================================
   This step simulates cleaning work already done on the raw dataset.
*/

WITH source_data AS (
    SELECT
        TRY_CAST([Purchase ID] AS INT)                            AS PurchaseID,
        TRY_CAST([Customer ID] AS INT)                            AS CustomerID,
        TRY_CAST([Age] AS INT)                                    AS Age,
        NULLIF(LTRIM(RTRIM([Gender])), '')                        AS Gender,
        NULLIF(LTRIM(RTRIM([Item Purchased])), '')                AS ItemPurchased,
        NULLIF(LTRIM(RTRIM([Category])), '')                      AS Category,
        TRY_CAST([Purchase Amount (USD)] AS DECIMAL(10,2))        AS PurchaseAmountUSD,
        NULLIF(LTRIM(RTRIM([Location])), '')                      AS Location,
        NULLIF(LTRIM(RTRIM([Size])), '')                          AS Size,
        NULLIF(LTRIM(RTRIM([Color])), '')                         AS Color,
        NULLIF(LTRIM(RTRIM([Season])), '')                        AS Season,
        TRY_CAST([Review Rating] AS DECIMAL(3,2))                 AS ReviewRating,
        CASE
            WHEN UPPER(LTRIM(RTRIM([Subscription Status]))) IN ('YES', 'Y', 'TRUE', '1') THEN 'Yes'
            WHEN UPPER(LTRIM(RTRIM([Subscription Status]))) IN ('NO', 'N', 'FALSE', '0') THEN 'No'
            ELSE NULL
        END                                                       AS SubscriptionStatus,
        CASE
            WHEN UPPER(LTRIM(RTRIM([Discount Applied]))) IN ('YES', 'Y', 'TRUE', '1') THEN 'Yes'
            WHEN UPPER(LTRIM(RTRIM([Discount Applied]))) IN ('NO', 'N', 'FALSE', '0') THEN 'No'
            ELSE NULL
        END                                                       AS DiscountApplied,
        CASE
            WHEN UPPER(LTRIM(RTRIM([Promo Code Used]))) IN ('YES', 'Y', 'TRUE', '1') THEN 'Yes'
            WHEN UPPER(LTRIM(RTRIM([Promo Code Used]))) IN ('NO', 'N', 'FALSE', '0') THEN 'No'
            ELSE NULL
        END                                                       AS PromoCodeUsed,
        TRY_CAST([Previous Purchases] AS INT)                     AS PreviousPurchases,
        NULLIF(LTRIM(RTRIM([Payment Method])), '')                AS PaymentMethod,
        NULLIF(LTRIM(RTRIM([Frequency of Purchases])), '')        AS FrequencyOfPurchases,
        NULLIF(LTRIM(RTRIM([Shipping Type])), '')                 AS ShippingType
    FROM dbo.raw_shopping
),
deduplicated AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY PurchaseID ORDER BY PurchaseID) AS rn
    FROM source_data
),
validated AS (
    SELECT
        PurchaseID,
        CustomerID,
        Age,
        Gender,
        ItemPurchased,
        Category,
        PurchaseAmountUSD,
        Location,
        Size,
        Color,
        Season,
        ReviewRating,
        SubscriptionStatus,
        DiscountApplied,
        PromoCodeUsed,
        PreviousPurchases,
        PaymentMethod,
        FrequencyOfPurchases,
        ShippingType
    FROM deduplicated
    WHERE rn = 1
      AND PurchaseID IS NOT NULL
      AND CustomerID IS NOT NULL
      AND ItemPurchased IS NOT NULL
      AND Category IS NOT NULL
      AND PurchaseAmountUSD IS NOT NULL
      AND Location IS NOT NULL
      AND Season IS NOT NULL
      AND PaymentMethod IS NOT NULL
      AND ShippingType IS NOT NULL
)
SELECT *
INTO dbo.stg_shopping_clean
FROM validated;

/*
=====================================================================
3. DIMENSION TABLES
=====================================================================
*/

CREATE TABLE dbo.dim_customer (
    CustomerID INT PRIMARY KEY,
    Age INT NULL,
    Gender VARCHAR(20) NULL,
    PreviousPurchases INT NULL,
    FrequencyOfPurchases VARCHAR(50) NULL,
    SubscriptionStatus VARCHAR(10) NULL
);

INSERT INTO dbo.dim_customer (
    CustomerID, Age, Gender, PreviousPurchases, FrequencyOfPurchases, SubscriptionStatus
)
SELECT DISTINCT
    CustomerID,
    Age,
    Gender,
    PreviousPurchases,
    FrequencyOfPurchases,
    SubscriptionStatus
FROM dbo.stg_shopping_clean;


CREATE TABLE dbo.dim_product (
    ProductID INT IDENTITY(1,1) PRIMARY KEY,
    ItemPurchased VARCHAR(200) NOT NULL,
    Category VARCHAR(100) NOT NULL,
    Color VARCHAR(50) NULL,
    Size VARCHAR(50) NULL
);

INSERT INTO dbo.dim_product (
    ItemPurchased, Category, Color, Size
)
SELECT DISTINCT
    ItemPurchased,
    Category,
    Color,
    Size
FROM dbo.stg_shopping_clean;


CREATE TABLE dbo.dim_location (
    LocationID INT IDENTITY(1,1) PRIMARY KEY,
    Location VARCHAR(100) NOT NULL
);

INSERT INTO dbo.dim_location (Location)
SELECT DISTINCT Location
FROM dbo.stg_shopping_clean;


CREATE TABLE dbo.dim_payment_method (
    PaymentMethodID INT IDENTITY(1,1) PRIMARY KEY,
    PaymentMethod VARCHAR(100) NOT NULL
);

INSERT INTO dbo.dim_payment_method (PaymentMethod)
SELECT DISTINCT PaymentMethod
FROM dbo.stg_shopping_clean;


CREATE TABLE dbo.dim_shipping_type (
    ShippingTypeID INT IDENTITY(1,1) PRIMARY KEY,
    ShippingType VARCHAR(100) NOT NULL
);

INSERT INTO dbo.dim_shipping_type (ShippingType)
SELECT DISTINCT ShippingType
FROM dbo.stg_shopping_clean;


CREATE TABLE dbo.dim_season (
    SeasonID INT IDENTITY(1,1) PRIMARY KEY,
    Season VARCHAR(50) NOT NULL
);

INSERT INTO dbo.dim_season (Season)
SELECT DISTINCT Season
FROM dbo.stg_shopping_clean;

/*
=====================================================================
4. FACT TABLE
=====================================================================
*/

CREATE TABLE dbo.fact_purchases (
    PurchaseID INT PRIMARY KEY,
    CustomerID INT NOT NULL,
    ProductID INT NOT NULL,
    LocationID INT NOT NULL,
    PaymentMethodID INT NOT NULL,
    ShippingTypeID INT NOT NULL,
    SeasonID INT NOT NULL,
    PurchaseAmountUSD DECIMAL(10,2) NOT NULL,
    DiscountApplied VARCHAR(10) NULL,
    PromoCodeUsed VARCHAR(10) NULL,
    ReviewRating DECIMAL(3,2) NULL,
    CONSTRAINT FK_fact_customer FOREIGN KEY (CustomerID) REFERENCES dbo.dim_customer(CustomerID),
    CONSTRAINT FK_fact_product FOREIGN KEY (ProductID) REFERENCES dbo.dim_product(ProductID),
    CONSTRAINT FK_fact_location FOREIGN KEY (LocationID) REFERENCES dbo.dim_location(LocationID),
    CONSTRAINT FK_fact_payment FOREIGN KEY (PaymentMethodID) REFERENCES dbo.dim_payment_method(PaymentMethodID),
    CONSTRAINT FK_fact_shipping FOREIGN KEY (ShippingTypeID) REFERENCES dbo.dim_shipping_type(ShippingTypeID),
    CONSTRAINT FK_fact_season FOREIGN KEY (SeasonID) REFERENCES dbo.dim_season(SeasonID)
);

INSERT INTO dbo.fact_purchases (
    PurchaseID,
    CustomerID,
    ProductID,
    LocationID,
    PaymentMethodID,
    ShippingTypeID,
    SeasonID,
    PurchaseAmountUSD,
    DiscountApplied,
    PromoCodeUsed,
    ReviewRating
)
SELECT
    s.PurchaseID,
    s.CustomerID,
    p.ProductID,
    l.LocationID,
    pm.PaymentMethodID,
    st.ShippingTypeID,
    se.SeasonID,
    s.PurchaseAmountUSD,
    s.DiscountApplied,
    s.PromoCodeUsed,
    s.ReviewRating
FROM dbo.stg_shopping_clean s
JOIN dbo.dim_product p
    ON s.ItemPurchased = p.ItemPurchased
   AND s.Category = p.Category
   AND ISNULL(s.Color, '') = ISNULL(p.Color, '')
   AND ISNULL(s.Size, '') = ISNULL(p.Size, '')
JOIN dbo.dim_location l
    ON s.Location = l.Location
JOIN dbo.dim_payment_method pm
    ON s.PaymentMethod = pm.PaymentMethod
JOIN dbo.dim_shipping_type st
    ON s.ShippingType = st.ShippingType
JOIN dbo.dim_season se
    ON s.Season = se.Season;

/*
=====================================================================
5. OPTIONAL DATA QUALITY CHECKS
=====================================================================
*/

-- Check row counts
SELECT 'stg_shopping_clean' AS TableName, COUNT(*) AS RowCount FROM dbo.stg_shopping_clean
UNION ALL
SELECT 'dim_customer', COUNT(*) FROM dbo.dim_customer
UNION ALL
SELECT 'dim_product', COUNT(*) FROM dbo.dim_product
UNION ALL
SELECT 'dim_location', COUNT(*) FROM dbo.dim_location
UNION ALL
SELECT 'dim_payment_method', COUNT(*) FROM dbo.dim_payment_method
UNION ALL
SELECT 'dim_shipping_type', COUNT(*) FROM dbo.dim_shipping_type
UNION ALL
SELECT 'dim_season', COUNT(*) FROM dbo.dim_season
UNION ALL
SELECT 'fact_purchases', COUNT(*) FROM dbo.fact_purchases;

-- Check for orphan keys (should return 0 rows)
SELECT *
FROM dbo.fact_purchases f
LEFT JOIN dbo.dim_customer c ON f.CustomerID = c.CustomerID
WHERE c.CustomerID IS NULL;

SELECT *
FROM dbo.fact_purchases f
LEFT JOIN dbo.dim_product p ON f.ProductID = p.ProductID
WHERE p.ProductID IS NULL;

/*
=====================================================================
6. SAMPLE ANALYTICS QUERY
=====================================================================
*/

SELECT
    l.Location,
    SUM(f.PurchaseAmountUSD) AS TotalSales,
    COUNT(*) AS TotalOrders,
    AVG(f.ReviewRating) AS AvgRating
FROM dbo.fact_purchases f
JOIN dbo.dim_location l ON f.LocationID = l.LocationID
GROUP BY l.Location
ORDER BY TotalSales DESC;
