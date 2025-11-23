# International Trade Data Analysis Pipeline

A complete end-to-end data pipeline for analyzing international trade data (2017-2025) using Python, MySQL, and Power BI/Tableau.

---

## 📋 Table of Contents

1. [What is This Project?](#what-is-this-project)
2. [Project Structure Explained](#project-structure-explained)
3. [Why Each Step? Understanding the Pipeline](#why-each-step-understanding-the-pipeline)
4. [Prerequisites](#prerequisites)
5. [Step-by-Step Setup Guide](#step-by-step-setup-guide)
6. [How to Run the Complete Pipeline](#how-to-run-the-complete-pipeline)
7. [Understanding Key Concepts](#understanding-key-concepts)
8. [Complete Workflow](#complete-workflow)
9. [Troubleshooting](#troubleshooting)

---

## 🎯 What is This Project?

This project processes **raw international trade data** (import/export records) and transforms it into **clean, structured data** ready for analysis and visualization. Think of it as a factory assembly line:

1. **Raw Data** (messy CSV file) → 
2. **Python Cleaning** (fixes errors, standardizes format) → 
3. **Data Parsing** (extracts hidden information) → 
4. **Feature Engineering** (creates new useful columns) → 
5. **MySQL Database** (stores data efficiently) → 
6. **SQL Analysis** (calculates insights) → 
7. **Power BI/Tableau** (beautiful dashboards)

---

## 📁 Project Structure Explained

Let's understand what each folder and file does:

```
siddharth_trade_pipeline/
│
├── data/                          # All data files live here
│   ├── raw/                       # 📥 INPUT: Your original messy data
│   │   └── import_data_2017_2025.csv
│   └── processed/                 # 📤 OUTPUT: Clean, ready-to-use data
│       └── trade_cleaned.csv      # (Created after running pipeline)
│
├── notebooks/                     # 📓 Jupyter notebooks for exploration
│   ├── 01_data_inspection.ipynb  # Explore raw data structure
│   └── 02_parsing_and_cleaning.ipynb  # Test cleaning steps
│
├── src/                           # 🐍 Python code (the "workers")
│   ├── cleaning/                  # Step 1: Clean the data
│   │   └── clean_base.py          # Fixes dates, missing values, units
│   │
│   ├── parsing/                   # Step 2: Extract hidden information
│   │   └── parse_goods_description.py  # Pulls out model names, prices, etc.
│   │
│   ├── feature_engineering/       # Step 3: Create new useful columns
│   │   └── features.py            # Calculates totals, categories
│   │
│   ├── db/                        # Step 4: Load to database
│   │   └── load_to_db.py          # Puts data into MySQL
│   │
│   └── pipeline.py                # 🎯 MAIN SCRIPT: Runs everything in order
│
├── sql/                           # 🗄️ Database queries and setup
│   ├── create_trade_table.sql     # Creates the MySQL table structure
│   ├── 01_macro_growth_trends.sql # Year-over-year growth analysis
│   ├── 02_pareto_analysis.sql     # Top 25 HSN codes analysis
│   ├── 03_supplier_analysis.sql    # Supplier performance insights
│   ├── 04_powerbi_tableau_export.sql  # Ready-to-use dashboard queries
│   ├── run_all_views.bat          # Windows script to create all views
│   └── run_all_views.sh           # Linux/Mac script to create all views
│
├── dashboards/                    # 📊 Dashboard documentation
│   └── dashboard_queries_summary.md  # Quick reference for dashboard queries
│
├── docs/                          # 📚 Detailed documentation
│   └── DASHBOARD_GUIDE.md         # Complete dashboard setup guide
│
├── requirements.txt               # Python package dependencies
└── README.md                      # This file!
```

---

## 🤔 Why Each Step? Understanding the Pipeline

### Why Do We Need Data Cleaning?

**Problem:** Raw data is messy!
- Dates might be in different formats: "2025-10-28", "28/10/2025", "Oct 28, 2025"
- Missing values: Some rows have empty cells
- Inconsistent units: "pcs", "nos", "pieces" all mean the same thing
- Wrong data types: Numbers stored as text

**Solution:** `clean_base.py` standardizes everything so we can analyze it properly.

**Example:**
```
Before: "pcs", "nos", "pieces", "PCS", "Nos"
After:  "pcs", "pcs", "pcs", "pcs", "pcs"  (all standardized!)
```

---

### Why Do We Parse Goods Description?

**Problem:** Important information is buried in long text descriptions!

**Example Goods Description:**
```
"TH5170 STEEL CUTLERY HOLDER (QTY:600 PCS/USD 2.03 PER PCS)"
```

This contains:
- Model Name: `TH5170`
- Material: `STEEL`
- Quantity: `600`
- Unit Price: `USD 2.03`

**Solution:** `parse_goods_description.py` uses **regex patterns** (smart text matching) to extract this information into separate columns.

**Why This Matters:** Now we can filter by model name, analyze prices, or group by material type!

---

### Why Feature Engineering?

**Problem:** We need calculated values that don't exist in raw data.

**Examples:**
1. **Grand Total** = Total Value + Duty Paid (we need to add two columns)
2. **Category** = Based on HSN code (7323 = Household Articles)
3. **Sub-Category** = Based on description keywords ("CUTLERY" → "Cutlery & Utensils")

**Solution:** `features.py` creates these new columns automatically.

**Why This Matters:** These features make analysis much easier. Instead of manually calculating totals, we have a ready-made column!

---

### Why Load to MySQL Database?

**Problem:** CSV files are slow for large datasets and can't handle complex queries.

**Benefits of MySQL:**
- ⚡ **Fast queries** even with millions of rows
- 🔍 **Complex filtering** (e.g., "Show all steel products imported in Q3 2024")
- 📊 **Aggregations** (e.g., "Total value by year")
- 🔗 **Relationships** between tables (future expansion)
- 👥 **Multiple users** can access data simultaneously

**Solution:** `load_to_db.py` reads the cleaned CSV and inserts it into MySQL.

---

### Why SQL Analysis Views?

**Problem:** We need specific insights (YoY growth, top products, supplier analysis) but writing queries every time is tedious.

**Solution:** SQL views are **saved queries** that you can run anytime:
- `v_annual_growth_trends` - Shows year-over-year growth automatically
- `v_pareto_hsn_analysis` - Shows top 25 products with percentages
- `v_supplier_lifetime_stats` - Shows supplier performance metrics

**Why This Matters:** Instead of writing complex SQL every time, just run: `SELECT * FROM v_annual_growth_trends;`

---

### Why Power BI/Tableau?

**Problem:** Numbers in tables are hard to understand. People need visualizations!

**Solution:** Connect Power BI/Tableau to MySQL and create:
- 📈 Line charts showing trends over time
- 🎯 Heatmaps showing growth patterns
- 🥧 Pie charts showing product distribution
- 📊 Bar charts comparing suppliers

**Why This Matters:** Visual dashboards help stakeholders understand data instantly!

---

## 📦 Prerequisites

Before starting, make sure you have:

1. **Python 3.7+** installed
   - Check: `python --version` or `python3 --version`
   - Download: [python.org](https://www.python.org/downloads/)

2. **MySQL Server** installed and running
   - Check: `mysql --version`
   - Download: [mysql.com](https://dev.mysql.com/downloads/mysql/)

3. **Jupyter Notebook** (optional, for exploration)
   - Install: `pip install jupyter`

4. **Power BI Desktop** or **Tableau** (for dashboards)
   - Power BI: [powerbi.microsoft.com](https://powerbi.microsoft.com/desktop/)
   - Tableau: [tableau.com](https://www.tableau.com/products/desktop)

---

## 🚀 Step-by-Step Setup Guide

### Step 1: Install Python Packages

Open your **terminal/command prompt** and navigate to the project folder:

```bash
cd D:\siddharth_trade_pipeline
```

Install required packages:

```bash
pip install -r requirements.txt
```

**What this does:** Installs pandas, numpy, sqlalchemy, pymysql, and python-dotenv.

**Where to run:** Python terminal/command prompt

---

### Step 2: Configure Database Connection

Create a file named `.env` in the project root folder with your MySQL credentials:

```
DB_USER=root
DB_PASSWORD=your_mysql_password
DB_HOST=localhost
DB_PORT=3306
DB_NAME=trade_db
```

**What this does:** Stores database credentials securely (not in code).

**Where to create:** In the project root folder (`siddharth_trade_pipeline/`)

**Example:**
- If your MySQL username is `root` and password is `mypassword123`, your `.env` file should contain:
  ```
  DB_USER=root
  DB_PASSWORD=mypassword123
  DB_HOST=localhost
  DB_PORT=3306
  DB_NAME=trade_db
  ```

---

### Step 3: Create MySQL Database and Table

Open **MySQL Command Line** or **MySQL Workbench** and run:

```bash
mysql -u root -p < sql/create_trade_table.sql
```

Or manually in MySQL:

```sql
-- Connect to MySQL
mysql -u root -p

-- Then run:
source sql/create_trade_table.sql;
```

**What this does:**
- Creates a database called `trade_db`
- Creates a table called `trade_data` with all necessary columns
- Creates indexes for fast queries
- Creates a summary view `trade_summary`

**Where to run:** MySQL command line or MySQL Workbench

**Expected output:**
```
Database created.
Table created.
View created.
```

---

## 🔄 How to Run the Complete Pipeline

### Workflow Overview

```
Raw CSV → Python Cleaning → Parsed Data → Features → Cleaned CSV → MySQL → SQL Views → Dashboard
```

---

### Step 1: Run the Data Pipeline (Python)

This is the **main step** that does all the cleaning, parsing, and feature engineering.

**Command:**
```bash
python src/pipeline.py
```

**What it does:**
1. Reads `data/raw/import_data_2017_2025.csv`
2. Cleans the data (dates, missing values, units)
3. Parses goods descriptions (extracts model names, prices, etc.)
4. Engineers features (Grand Total, Categories)
5. Saves to `data/processed/trade_cleaned.csv`

**Where to run:** Python terminal/command prompt

**Expected output:**
```
============================================================
Starting Trade Data Pipeline
============================================================

[Step 1] Loading raw data...
✓ Loaded 2079 rows from data/raw/import_data_2017_2025.csv

[Step 2] Performing basic cleaning...
✓ Basic cleaning completed. Rows: 2079

[Step 3] Parsing goods description...
✓ Goods description parsing completed

[Step 4] Engineering features...
✓ Feature engineering completed

[Step 5] Saving cleaned data...
✓ Saved 2079 rows to data/processed/trade_cleaned.csv

============================================================
Pipeline Summary
============================================================
Total rows processed: 2079
Columns in output: 45
Output file: data/processed/trade_cleaned.csv
============================================================

✓ Pipeline completed successfully!
```

**Custom input/output:**
```bash
python src/pipeline.py data/raw/my_custom_file.csv data/processed/my_output.csv
```

---

### Step 2: Load Data to MySQL (Python)

This takes the cleaned CSV and puts it into the MySQL database.

**Command:**
```bash
python src/db/load_to_db.py
```

**What it does:**
1. Reads `data/processed/trade_cleaned.csv`
2. Maps CSV columns to database columns
3. Converts data types (text to numbers, dates, etc.)
4. Inserts data into `trade_data` table in MySQL

**Where to run:** Python terminal/command prompt

**Expected output:**
```
============================================================
Loading Trade Data to MySQL
============================================================
Database: trade_db
Host: localhost:3306
CSV File: data/processed/trade_cleaned.csv
============================================================
Loading data from data/processed/trade_cleaned.csv...
✓ Loaded 2079 rows from CSV
✓ Successfully loaded 2079 rows into table 'trade_data'.

✓ Data loading completed successfully!
```

**Custom CSV file:**
```bash
python src/db/load_to_db.py data/processed/my_custom_file.csv
```

---

### Step 3: Create SQL Analysis Views (MySQL)

This creates all the analysis views for dashboards.

**Option A: Run all at once (Windows):**
```bash
sql\run_all_views.bat root your_password trade_db
```

**Option B: Run all at once (Linux/Mac):**
```bash
chmod +x sql/run_all_views.sh
./sql/run_all_views.sh root your_password trade_db
```

**Option C: Run individually (MySQL CLI):**
```bash
mysql -u root -p trade_db < sql/01_macro_growth_trends.sql
mysql -u root -p trade_db < sql/02_pareto_analysis.sql
mysql -u root -p trade_db < sql/03_supplier_analysis.sql
mysql -u root -p trade_db < sql/04_powerbi_tableau_export.sql
```

**What this does:**
- Creates views for YoY growth analysis
- Creates views for Pareto (top 25) analysis
- Creates views for supplier analysis
- Creates views optimized for Power BI/Tableau

**Where to run:** MySQL command line or MySQL Workbench

**Expected output:**
```
Running 01_macro_growth_trends.sql...
✓ 01_macro_growth_trends.sql completed successfully

Running 02_pareto_analysis.sql...
✓ 02_pareto_analysis.sql completed successfully

Running 03_supplier_analysis.sql...
✓ 03_supplier_analysis.sql completed successfully

Running 04_powerbi_tableau_export.sql...
✓ 04_powerbi_tableau_export.sql completed successfully

All views created!
```

**Verify views were created:**
```sql
-- In MySQL
SHOW FULL TABLES WHERE TABLE_TYPE = 'VIEW';
```

You should see views like:
- `v_annual_growth_trends`
- `v_pareto_hsn_analysis`
- `v_supplier_lifetime_stats`
- `v_line_chart_imports_vs_duty`
- And many more...

---

### Step 4: Connect Power BI/Tableau

#### For Power BI Desktop:

1. **Open Power BI Desktop**
2. **Click "Get Data"** → **"Database"** → **"MySQL database"**
3. **Enter connection details:**
   - Server: `localhost`
   - Database: `trade_db`
   - Username: `root`
   - Password: (your MySQL password)
4. **Select views to import:**
   - `v_line_chart_imports_vs_duty`
   - `v_yoy_growth_heatmap`
   - `v_sunburst_category_hierarchy`
   - `v_top_suppliers_by_value`
   - `v_supplier_active_vs_churned`
   - `v_scatter_capacity_vs_cost`
5. **Click "Load"**
6. **Create visualizations** using the imported data

#### For Tableau:

1. **Open Tableau Desktop**
2. **Click "Connect"** → **"To a Server"** → **"MySQL"**
3. **Enter connection details:**
   - Server: `localhost`
   - Port: `3306`
   - Database: `trade_db`
   - Username: `root`
   - Password: (your MySQL password)
4. **Drag views** from the schema into the data source
5. **Create worksheets** and dashboards

**Where to run:** Power BI Desktop or Tableau Desktop

---

## 📚 Understanding Key Concepts

### 1. What is "Parsing Goods Description"?

**The Problem:**
Your raw data has a column called "GOODS DESCRIPTION" with long text like:
```
"TH5170 STEEL CUTLERY HOLDER (QTY:600 PCS/USD 2.03 PER PCS)"
```

**The Solution:**
We use **regex (regular expressions)** - think of it as a smart text pattern matcher - to find and extract:
- Model Name: `TH5170` (pattern: letters + numbers)
- Material: `STEEL` (pattern: specific keywords)
- Quantity: `600` (pattern: "QTY:" followed by numbers)
- Price: `USD 2.03` (pattern: "USD" followed by decimal number)

**How it works:**
```python
# Example regex pattern
pattern = r'QTY[:\s]+([\d,]+)\s*PCS'
# This finds: "QTY:600 PCS" and extracts "600"
```

**Result:**
Instead of one long text column, we get separate columns:
- `Model_Name_Parsed`: TH5170
- `Material_Type_Parsed`: STEEL
- `Embedded_Quantity_Parsed`: 600
- `Unit_Price_USD_Parsed`: 2.03

---

### 2. What is "Feature Engineering"?

**Feature Engineering** = Creating new columns from existing data.

**Example 1: Grand Total**
```
Grand Total = Total Value (INR) + Duty Paid (INR)
```
**Why?** We need the total cost including duty for financial analysis.

**Example 2: Category Assignment**
```
HSN Code 7323 → Category: "Household Articles"
HSN Code 7324 → Category: "Sanitary Ware"
```
**Why?** Grouping products by category makes analysis easier.

**Example 3: Sub-Category from Description**
```
Description contains "CUTLERY" → Sub-Category: "Cutlery & Utensils"
Description contains "SCRUBBER" → Sub-Category: "Cleaning Tools"
```
**Why?** More detailed grouping for better insights.

---

### 3. What are SQL Aggregations?

**Aggregation** = Combining multiple rows into summary statistics.

**Example: Macro Growth Trends**

**Raw Data:**
```
Year | Total Value
-----|------------
2023 | 1000000
2024 | 1200000
2025 | 1500000
```

**SQL Aggregation (YoY Growth):**
```sql
SELECT 
    year,
    total_value,
    -- Calculate growth from previous year
    ((total_value - prev_total_value) / prev_total_value) * 100 AS yoy_growth_pct
FROM ...
```

**Result:**
```
Year | Total Value | YoY Growth %
-----|-------------|-------------
2023 | 1000000     | NULL
2024 | 1200000     | 20.00%
2025 | 1500000     | 25.00%
```

**Why?** Shows business growth at a glance!

---

### 4. What is Pareto Analysis?

**Pareto Principle (80/20 Rule):** 80% of results come from 20% of causes.

**In our case:** 80% of trade value comes from top 20% of HSN codes.

**What we do:**
1. Rank all HSN codes by total value
2. Calculate % contribution of each
3. Identify top 25 codes
4. Group remaining as "Others"

**Example Result:**
```
HSN Code | Value (Crores) | % Contribution
---------|----------------|----------------
73239990 | 50.5           | 35.2%
73231000 | 32.1           | 22.4%
...      | ...            | ...
Others   | 15.2           | 10.6%
```

**Why?** Focus analysis on high-value products!

---

### 5. What is Supplier Analysis?

**Supplier Analysis** = Understanding your suppliers' performance.

**Key Metrics:**
- **Active Suppliers:** Suppliers who imported in 2025
- **Churned Suppliers:** Suppliers who stopped importing
- **New Suppliers:** Suppliers who started in 2025
- **Retained Suppliers:** Suppliers active in both 2024 and 2025
- **Longevity:** How many years a supplier has been active

**Example Query:**
```sql
SELECT 
    supplier_code,
    first_year,
    last_year,
    active_years,
    lifetime_total_value_inr_crores
FROM v_supplier_lifetime_stats
WHERE is_active_2025 = 1
ORDER BY lifetime_total_value_inr_crores DESC;
```

**Why?** Identify key suppliers, understand churn, and manage relationships!

---

## 🔄 Complete Workflow

Here's the **complete workflow** from start to finish:

### Phase 1: Setup (One-Time)

1. **Install Python packages:**
   ```bash
   pip install -r requirements.txt
   ```

2. **Create `.env` file** with MySQL credentials

3. **Create MySQL database:**
   ```bash
   mysql -u root -p < sql/create_trade_table.sql
   ```

---

### Phase 2: Data Processing (Every Time You Get New Data)

1. **Place raw CSV** in `data/raw/import_data_2017_2025.csv`

2. **Run Python pipeline:**
   ```bash
   python src/pipeline.py
   ```
   - **Where:** Python terminal
   - **Output:** `data/processed/trade_cleaned.csv`

3. **Load to MySQL:**
   ```bash
   python src/db/load_to_db.py
   ```
   - **Where:** Python terminal
   - **Output:** Data in `trade_data` table

4. **Create SQL views:**
   ```bash
   sql\run_all_views.bat root your_password trade_db
   ```
   - **Where:** Command prompt (Windows) or terminal (Linux/Mac)
   - **Output:** Analysis views in MySQL

---

### Phase 3: Analysis & Visualization (Ongoing)

1. **Query data in MySQL:**
   ```sql
   -- Example: Get annual growth
   SELECT * FROM v_annual_growth_trends;
   
   -- Example: Get top products
   SELECT * FROM v_pareto_hsn_analysis LIMIT 10;
   ```
   - **Where:** MySQL Workbench or MySQL CLI

2. **Connect Power BI/Tableau:**
   - Connect to MySQL database
   - Import views
   - Create visualizations

3. **Build dashboards:**
   - Line charts for trends
   - Heatmaps for growth
   - Bar charts for comparisons
   - Scatter plots for relationships

---

## 🛠️ Troubleshooting

### Problem: "ModuleNotFoundError: No module named 'pandas'"

**Solution:**
```bash
pip install -r requirements.txt
```

**Why:** Python packages aren't installed yet.

---

### Problem: "Access denied for user 'root'@'localhost'"

**Solution:**
1. Check your `.env` file has correct credentials
2. Verify MySQL is running: `mysql -u root -p`
3. Check MySQL user permissions

**Why:** Database credentials are incorrect or MySQL isn't running.

---

### Problem: "Table 'trade_data' doesn't exist"

**Solution:**
```bash
mysql -u root -p < sql/create_trade_table.sql
```

**Why:** Database table wasn't created yet.

---

### Problem: "File not found: data/processed/trade_cleaned.csv"

**Solution:**
1. Run the pipeline first: `python src/pipeline.py`
2. Check if `data/raw/import_data_2017_2025.csv` exists

**Why:** Pipeline hasn't been run yet, or input file is missing.

---

### Problem: "View does not exist"

**Solution:**
```bash
# Run all view creation scripts
sql\run_all_views.bat root your_password trade_db
```

**Why:** SQL views weren't created yet.

---

### Problem: "Slow queries in Power BI"

**Solution:**
1. Add date filters in Power BI (e.g., `WHERE year >= 2020`)
2. Use views instead of raw table
3. Consider creating materialized views for large datasets

**Why:** Querying all data without filters is slow.

---

## 📖 Additional Resources

- **SQL Documentation:** See `sql/README.md` for detailed SQL query documentation
- **Dashboard Guide:** See `docs/DASHBOARD_GUIDE.md` for complete dashboard setup
- **Quick Reference:** See `dashboards/dashboard_queries_summary.md` for query examples

---

## 🎓 Learning Path for Beginners

If you're new to data pipelines, here's a suggested learning order:

1. **Start with Jupyter Notebooks:**
   - Open `notebooks/01_data_inspection.ipynb`
   - Explore the raw data structure
   - Understand what columns exist

2. **Run Individual Python Scripts:**
   - Read `src/cleaning/clean_base.py` (understand cleaning)
   - Read `src/parsing/parse_goods_description.py` (understand parsing)
   - Run them individually to see what each does

3. **Run the Full Pipeline:**
   - Execute `python src/pipeline.py`
   - Check the output CSV to see transformations

4. **Learn SQL Basics:**
   - Read `sql/create_trade_table.sql` (understand table structure)
   - Try simple queries: `SELECT * FROM trade_data LIMIT 10;`

5. **Explore Analysis Views:**
   - Run: `SELECT * FROM v_annual_growth_trends;`
   - Understand what each view provides

6. **Build Your First Dashboard:**
   - Connect Power BI to MySQL
   - Import one view
   - Create a simple bar chart

---

## ✅ Summary

**What this project does:**
- Takes messy raw trade data
- Cleans and standardizes it
- Extracts hidden information
- Creates useful features
- Stores in MySQL database
- Provides analysis views
- Enables beautiful dashboards

**Key Commands:**
```bash
# Process data
python src/pipeline.py

# Load to database
python src/db/load_to_db.py

# Create analysis views
sql\run_all_views.bat root your_password trade_db
```

**Where things run:**
- **Python scripts:** Command prompt/terminal
- **SQL scripts:** MySQL Workbench or MySQL CLI
- **Dashboards:** Power BI Desktop or Tableau Desktop
- **Exploration:** Jupyter Notebooks

---

## 📞 Need Help?

1. Check the documentation in `docs/` folder
2. Review SQL queries in `sql/README.md`
3. Verify your setup matches the prerequisites
4. Check troubleshooting section above

---

**Happy Analyzing! 📊**
