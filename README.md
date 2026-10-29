# 🛒 Zepto SQL Inventory & Pricing Analysis

An end-to-end SQL Server project that cleans and analyzes Zepto quick-commerce product data to uncover insights on **pricing, discounts, stock availability, revenue potential and inventory weight**.

---

## 📌 Project Objective

Analyze Zepto product data using SQL Server to identify:

- Product categories
- Stock availability (in stock vs. out of stock)
- Duplicate products / multiple SKUs
- Pricing and discount patterns
- High-value products
- Inventory weight
- Potential revenue opportunities

---

## 📂 Repository Structure

```
zepto-sql-inventory-analysis/
├── README.md
├── data/
│   └── zepto_v2.csv                      # Raw dataset (~3,700 rows)
└── sql/
    └── Zepto_SQL_analysis_Project.sql    # Setup, cleaning & analysis queries
```

---

## 🗃️ Dataset

**File:** `data/zepto_v2.csv` (about 3,700 product records)

| Column | Description |
|---|---|
| `Category` | Product category (e.g., Fruits & Vegetables) |
| `name` | Product name |
| `mrp` | Maximum Retail Price (stored in **paise**) |
| `discountPercent` | Discount percentage on MRP |
| `availableQuantity` | Units currently available |
| `discountedSellingPrice` | Selling price after discount (in **paise**) |
| `weightInGms` | Product weight in grams |
| `outOfStock` | Stock status (`FALSE` = in stock, `TRUE` = out of stock) |
| `quantity` | Pack quantity per SKU |

---

## 🛠️ Tools Used

- **SQL Server (T-SQL)**
- **SSMS** (SQL Server Management Studio), used for importing the CSV
- **GitHub** for version control

---

## ⚙️ Project Workflow

### 1. Database & Table Setup
- Created the `ZeptoDB` database
- Created the `dbo.zepto` table with an auto-generated `sku_id` (`IDENTITY`) as the primary key

### 2. Data Import
- Imported the CSV into a raw staging table `dbo.zepto_v2` using the SSMS Import Wizard
- Transferred the data into the structured `dbo.zepto` table with `INSERT INTO ... SELECT`

### 3. Data Exploration & Quality Checks
- Previewed sample records
- Checked for `NULL` values in key columns
- Listed distinct product categories
- Compared in-stock vs. out-of-stock SKUs
- Identified duplicate product names (products with multiple SKUs)

### 4. Data Cleaning
- Identified products with zero MRP / zero selling price
- Deleted invalid records where `mrp = 0`
- Converted prices from **paise to rupees** (÷ 100)

---

## 📊 Business Questions Answered

| # | Business Question | SQL Concepts Used |
|---|---|---|
| Q1 | Top 10 products with the highest discount | `DISTINCT`, `TOP`, `ORDER BY` |
| Q2 | High-MRP products (> ₹300) that are out of stock | `WHERE`, `ORDER BY` |
| Q3 | Estimated revenue by category (price × available quantity) | `SUM`, `GROUP BY` |
| Q4 | Premium products (MRP > ₹500) with discount below 10% | Multi-condition filtering |
| Q5 | Top 5 categories by average discount | `AVG`, `ROUND`, `TOP` |
| Q6 | Best value products by price per gram (≥ 100 g) | Calculated column, `NULLIF` |
| Q7 | Weight classification: LOW / MEDIUM / BULK | `CASE WHEN` |
| Q8 | Total inventory weight by category | `SUM`, `GROUP BY` |

---

## 💡 Key Insights You Can Draw

- Which categories carry the highest revenue potential based on current stock
- Which expensive products are out of stock, representing possible lost sales
- Which categories run the deepest average discounts
- Which premium products have room for a discount-strategy review
- Which categories take up the most warehouse weight, which helps logistics planning

> 📝 *Add your actual results here (e.g., "Top revenue category: X") after running the queries.*

---

## 🚀 How to Run

1. Clone the repository
   ```bash
   git clone https://github.com/<your-username>/zepto-sql-inventory-analysis.git
   ```
2. Open **SQL Server Management Studio (SSMS)**.
3. Import `data/zepto_v2.csv` into a table named `dbo.zepto_v2`
   (right-click database → *Tasks* → *Import Flat File*).
4. Open `sql/Zepto_SQL_analysis_Project.sql` and run it section by section.

> ⚠️ The optional cleanup section at the end (DROP TABLE / DROP DATABASE) is commented out. Run it only when you intend to delete data.

---

## 🧠 Skills Demonstrated

- Database and table design
- Data import and ETL with a staging table
- Data cleaning and validation
- Aggregations and grouping
- Conditional logic with `CASE`
- Business-oriented analytical thinking

---

## 👤 Author

**Your Name**
[LinkedIn]([https://linkedin.com/in/your-profile](https://www.linkedin.com/in/nikhilesh-anamanla/)) • [GitHub](https://github.com/nikhileshanamanla123)

---

⭐ If you found this project useful, consider giving it a star!
