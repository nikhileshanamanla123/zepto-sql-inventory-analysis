/* ============================================================
   ZEPTO DATA ANALYSIS PROJECT
   ============================================================

   Objective:
   Analyze Zepto product data using SQL Server to identify:
   - Product categories
   - Stock availability
   - Duplicate products
   - Pricing and discount patterns
   - High-value products
   - Inventory weight
   - Potential revenue opportunities

   Database: ZeptoDB
   Main Table: dbo.zepto
   ============================================================ */


/* ============================================================
   1. DATABASE SETUP
   ============================================================

   Purpose:
   Create a separate database for the Zepto data analysis project.
   ============================================================ */

CREATE DATABASE ZeptoDB;
GO

USE ZeptoDB;
GO


/* ============================================================
   2. TABLE SETUP
   ============================================================

   Purpose:
   Create the main table that will store cleaned Zepto product data.

   sku_id is generated automatically using IDENTITY because
   each product/SKU needs a unique identifier.
   ============================================================ */

DROP TABLE IF EXISTS dbo.zepto;
GO

CREATE TABLE dbo.zepto
(
    sku_id INT IDENTITY(1,1) PRIMARY KEY,
    category VARCHAR(120),
    name VARCHAR(150),
    mrp NUMERIC(8,2),
    discountPercent NUMERIC(5,2),
    availableQuantity INT,
    discountedSellingPrice NUMERIC(8,2),
    weightInGms INT,
    outOfStock BIT,
    quantity INT
);
GO


/* ============================================================
   3. CHECK TABLE
   ============================================================

   Purpose:
   Verify that the table was created successfully before
   inserting and analyzing the data.
   ============================================================ */

SELECT *
FROM dbo.zepto;


/* ============================================================
   4. VERIFY CURRENT DATABASE
   ============================================================

   Purpose:
   Confirm that SQL Server is currently using the correct
   database before performing analysis.
   ============================================================ */

SELECT DB_NAME() AS CurrentDatabase;


/* ============================================================
   5. CHECK IMPORTED RAW DATA
   ============================================================

   Purpose:
   The Excel/CSV data was first imported into zepto_v2.
   This query checks how many records were imported successfully.
   ============================================================ */

SELECT COUNT(*) AS TotalRecords
FROM dbo.zepto_v2;


/* ============================================================
   6. CHECK EMPTY MAIN TABLE
   ============================================================

   Purpose:
   Check the number of records currently available in the
   final Zepto table before transferring the imported data.
   ============================================================ */

SELECT COUNT(*) AS TotalRecords
FROM dbo.zepto;


/* ============================================================
   7. TRANSFER DATA FROM RAW TABLE TO FINAL TABLE
   ============================================================

   Purpose:
   Copy the imported data from zepto_v2 into the properly
   structured zepto table.

   sku_id is intentionally excluded because SQL Server
   automatically generates it using IDENTITY.
   ============================================================ */

INSERT INTO dbo.zepto
(
    category,
    name,
    mrp,
    discountPercent,
    availableQuantity,
    discountedSellingPrice,
    weightInGms,
    outOfStock,
    quantity
)
SELECT
    category,
    name,
    mrp,
    discountPercent,
    availableQuantity,
    discountedSellingPrice,
    weightInGms,
    outOfStock,
    quantity
FROM dbo.zepto_v2;


/* ============================================================
   8. SAMPLE DATA CHECK
   ============================================================

   Purpose:
   Display a small sample of records to verify that the
   data was inserted correctly.
   ============================================================ */

SELECT TOP 10 * FROM dbo.zepto;


/* ============================================================
   9. DATA QUALITY CHECK - NULL VALUES
   ============================================================

   Purpose:
   Identify records with missing values in important columns.
   Missing values can affect calculations and business analysis.
   ============================================================ */

SELECT *
FROM dbo.zepto
WHERE name IS NULL
   OR category IS NULL
   OR mrp IS NULL
   OR discountedSellingPrice IS NULL
   OR weightInGms IS NULL
   OR availableQuantity IS NULL
   OR outOfStock IS NULL
   OR quantity IS NULL;


/* ============================================================
   10. IDENTIFY PRODUCT CATEGORIES
   ============================================================

   Purpose:
   Understand how many unique product categories exist
   in the Zepto dataset.
   ============================================================ */

SELECT DISTINCT category
FROM dbo.zepto
ORDER BY category;


/* ============================================================
   11. STOCK AVAILABILITY ANALYSIS
   ============================================================

   Purpose:
   Compare the number of products that are in stock versus
   out of stock.

   outOfStock:
   0 = In Stock
   1 = Out of Stock
   ============================================================ */

SELECT
    outOfStock,
    COUNT(sku_id) AS TotalSKUs
FROM dbo.zepto
GROUP BY outOfStock;


/* ============================================================
   12. IDENTIFY DUPLICATE PRODUCT NAMES
   ============================================================

   Purpose:
   Find products that appear multiple times in the dataset.

   This helps identify products with multiple SKUs or possible
   duplicate records.
   ============================================================ */

SELECT
    name,
    COUNT(sku_id) AS NumberOfSKUs
FROM dbo.zepto
GROUP BY name
HAVING COUNT(sku_id) > 1
ORDER BY NumberOfSKUs DESC;


/* ============================================================
   13. DATA CLEANING - ZERO PRICE PRODUCTS
   ============================================================

   Purpose:
   Identify products where MRP or selling price is zero.

   Zero prices may represent invalid or incomplete records
   and can distort pricing and revenue analysis.
   ============================================================ */

SELECT *
FROM dbo.zepto
WHERE mrp = 0
   OR discountedSellingPrice = 0;


/* ============================================================
   14. REMOVE INVALID ZERO-MRP RECORDS
   ============================================================

   Purpose:
   Remove products with an MRP of zero because they cannot
   provide meaningful pricing or discount analysis.
   ============================================================ */

DELETE FROM dbo.zepto
WHERE mrp = 0;


/* ============================================================
   15. CONVERT PAISE TO RUPEES
   ============================================================

   Purpose:
   The original price values are stored in paise.

   Example:
   10000 paise = 100 rupees

   Dividing by 100 converts the values into Indian Rupees.
   ============================================================ */

UPDATE dbo.zepto
SET
    mrp = mrp / 100.0,
    discountedSellingPrice = discountedSellingPrice / 100.0;


/* Verify the converted prices */

SELECT
    mrp,
    discountedSellingPrice
FROM dbo.zepto;


/* ============================================================
   16. BUSINESS ANALYSIS
   ============================================================ */


/* ============================================================
   Q1. TOP 10 PRODUCTS WITH THE HIGHEST DISCOUNT
   ============================================================

   Business Question:
   Which products provide the highest percentage discount?

   Business Use:
   Helps identify products that may attract customers through
   aggressive discounts.
   ============================================================ */

SELECT DISTINCT TOP 10
    name,
    mrp,
    discountPercent
FROM dbo.zepto
ORDER BY discountPercent DESC;


/* ============================================================
   Q2. PRODUCTS WITH HIGH MRP BUT CURRENTLY OUT OF STOCK
   ============================================================

   Business Question:
   Which high-priced products are unavailable?

   Business Use:
   These products may represent potential lost sales or
   inventory replenishment opportunities.
   ============================================================ */

SELECT DISTINCT
    name,
    mrp
FROM dbo.zepto
WHERE outOfStock = 1
  AND mrp > 300
ORDER BY mrp DESC;


/* ============================================================
   Q3. ESTIMATED REVENUE BY CATEGORY
   ============================================================

   Business Question:
   Which product categories generate the highest estimated
   revenue based on current inventory?

   Formula:
   Discounted Selling Price × Available Quantity

   Business Use:
   Helps identify categories with higher revenue potential.

   NOTE:
   Multiplication is used here, not addition.
   ============================================================ */

SELECT
    category,
    SUM(discountedSellingPrice * availableQuantity) AS total_revenue
FROM dbo.zepto
GROUP BY category
ORDER BY total_revenue DESC;


/* ============================================================
   Q4. HIGH-MRP PRODUCTS WITH LOW DISCOUNTS
   ============================================================

   Business Question:
   Which expensive products have discounts below 10%?

   Business Use:
   Helps identify premium products where pricing or discount
   strategy could potentially be reviewed.
   ============================================================ */

SELECT DISTINCT
    name,
    mrp,
    discountPercent
FROM dbo.zepto
WHERE mrp > 500
  AND discountPercent < 10
ORDER BY mrp DESC,
         discountPercent DESC;


/* ============================================================
   Q5. TOP 5 CATEGORIES WITH THE HIGHEST AVERAGE DISCOUNT
   ============================================================

   Business Question:
   Which categories provide the largest average discounts?

   Business Use:
   Helps understand category-level pricing and promotional
   strategies.
   ============================================================ */

SELECT TOP 5
    category,
    ROUND(AVG(discountPercent), 2) AS avg_discount
FROM dbo.zepto
GROUP BY category
ORDER BY avg_discount DESC;


/* ============================================================
   Q6. PRICE PER GRAM ANALYSIS
   ============================================================

   Business Question:
   Which products provide the best price per gram for products
   weighing at least 100 grams?

   Formula:
   Discounted Selling Price ÷ Weight in Grams

   Business Use:
   Helps compare product value based on quantity/weight.
   Lower price per gram indicates better value.
   ============================================================ */

SELECT DISTINCT
    name,
    weightInGms,
    discountedSellingPrice,
    ROUND(
        discountedSellingPrice / NULLIF(weightInGms, 0),
        2
    ) AS price_per_gram
FROM dbo.zepto
WHERE weightInGms >= 100
ORDER BY price_per_gram;


/* ============================================================
   Q7. CLASSIFY PRODUCTS BY WEIGHT
   ============================================================

   Business Question:
   How can products be grouped based on their weight?

   Categories:
   Less than 1000g  = LOW
   1000g–4999g      = MEDIUM
   5000g or more    = BULK

   Business Use:
   Helps analyze product packaging, inventory and logistics.
   ============================================================ */

SELECT DISTINCT
    name,
    weightInGms,
    CASE
        WHEN weightInGms < 1000 THEN 'LOW'
        WHEN weightInGms < 5000 THEN 'MEDIUM'
        ELSE 'BULK'
    END AS weight_category
FROM dbo.zepto;


/* ============================================================
   Q8. TOTAL INVENTORY WEIGHT BY CATEGORY
   ============================================================

   Business Question:
   How much total product weight is currently available
   in each category?

   Formula:
   Weight × Available Quantity

   Business Use:
   Useful for inventory planning, warehouse capacity and
   logistics analysis.
   ============================================================ */

SELECT
    category,
    SUM(weightInGms * availableQuantity) AS total_weight
FROM dbo.zepto
GROUP BY category
ORDER BY total_weight DESC;


/* ============================================================
   17. FINAL DATASET CHECK
   ============================================================

   Purpose:
   Check the final number of records after data cleaning
   and analysis preparation.
   ============================================================ */

SELECT COUNT(*) AS FinalRecordCount
FROM dbo.zepto;


/* ============================================================
   18. OPTIONAL - CHECK TABLE STRUCTURE
   ============================================================

   Purpose:
   View the columns and data types of the final table.
   ============================================================ */

EXEC sp_help 'dbo.zepto';


/* ============================================================
   19. OPTIONAL CLEANUP - DELETE TABLE
   ============================================================

   WARNING:
   This permanently deletes the zepto table and all its data.

   Run ONLY when you intentionally want to remove the table.

   The imported zepto_v2 table will remain.
   ============================================================ */

-- DROP TABLE IF EXISTS dbo.zepto;


/* ============================================================
   20. OPTIONAL CLEANUP - DELETE IMPORTED RAW TABLE
   ============================================================

   WARNING:
   This permanently deletes the imported zepto_v2 table.

   Run ONLY after confirming that you no longer need the
   original imported data.
   ============================================================ */

-- DROP TABLE IF EXISTS dbo.zepto_v2;


/* ============================================================
   21. OPTIONAL CLEANUP - DELETE ENTIRE DATABASE
   ============================================================

   WARNING:
   THIS DELETES THE ENTIRE DATABASE AND ALL TABLES/DATA.

   Before executing, switch to another database such as master.
   ============================================================ */

-- USE master;
-- GO
-- DROP DATABASE IF EXISTS ZeptoDB;
-- GO


/* ============================================================
   END OF ZEPTO DATA ANALYSIS PROJECT
   ============================================================ */