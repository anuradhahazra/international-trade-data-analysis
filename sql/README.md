# SQL Queries and Dashboard Structure

This directory contains SQL queries and views for analyzing trade data and building dashboards in Power BI or Tableau.

## File Structure

```
sql/
├── 00_setup_all_views.sql          # Master setup script (reference)
├── 01_macro_growth_trends.sql      # YoY growth analysis
├── 02_pareto_analysis.sql          # Top 25 HSN codes analysis
├── 03_supplier_analysis.sql        # Supplier performance & longevity
├── 04_powerbi_tableau_export.sql   # Export queries for BI tools
├── create_trade_table.sql          # Database schema
└── README.md                       # This file
```

## Setup Instructions

### 1. Create Database and Load Data

First, ensure your database is set up and data is loaded:

```bash
# Create database schema
mysql -u root -p < sql/create_trade_table.sql

# Load data (using Python script)
python src/db/load_to_db.py
```

### 2. Create Analysis Views

Run each SQL file in order to create the analysis views:

```bash
# Option 1: Run individually
mysql -u root -p trade_db < sql/01_macro_growth_trends.sql
mysql -u root -p trade_db < sql/02_pareto_analysis.sql
mysql -u root -p trade_db < sql/03_supplier_analysis.sql
mysql -u root -p trade_db < sql/04_powerbi_tableau_export.sql

# Option 2: Run all at once (if using MySQL client)
mysql -u root -p trade_db < sql/00_setup_all_views.sql
```

Or execute directly in MySQL Workbench or your preferred SQL client.

## Analysis Queries

### 1. Macro Growth Trends (`01_macro_growth_trends.sql`)

**Views Created:**
- `v_annual_growth_trends` - Annual summary with YoY growth percentages
- `v_quarterly_growth_trends` - Quarterly summary with QoQ growth

**Key Metrics:**
- Year-over-Year (YoY) % growth for Total Value
- YoY % growth for Duty Paid
- YoY % growth for Grand Total
- Values in Crores (10 million INR)

**Usage:**
```sql
SELECT * FROM v_annual_growth_trends ORDER BY year;
SELECT * FROM v_quarterly_growth_trends ORDER BY year, quarter;
```

### 2. Pareto Analysis (`02_pareto_analysis.sql`)

**Views Created:**
- `v_hsn_performance` - HSN code performance with rankings
- `v_pareto_hsn_analysis` - Top 25 HSN codes + Others group
- `v_pareto_cumulative` - Cumulative contribution analysis (80/20 rule)

**Key Metrics:**
- Top 25 HSN codes by value
- % contribution to total trade
- Remaining HSN codes grouped as "Others"
- Cumulative contribution percentages

**Usage:**
```sql
-- Get Pareto analysis
SELECT * FROM v_pareto_hsn_analysis ORDER BY rank_by_value;

-- Get cumulative contribution
SELECT * FROM v_pareto_cumulative WHERE cumulative_pct_contribution <= 80;
```

### 3. Supplier Analysis (`03_supplier_analysis.sql`)

**Views Created:**
- `v_supplier_summary_by_year` - Supplier activity by year
- `v_supplier_lifetime_stats` - Complete supplier lifetime statistics
- `v_supplier_active_analysis` - Active vs churned suppliers
- `v_supplier_longevity` - Supplier longevity by segment

**Key Metrics:**
- Active suppliers in 2025 vs historical
- Supplier longevity (years active)
- Supplier segments: Retained, New, Churned (Recent), Churned (Old)
- Lifetime value and transaction counts

**Usage:**
```sql
-- Top suppliers by value
SELECT * FROM v_supplier_lifetime_stats 
ORDER BY lifetime_total_value_inr_crores DESC LIMIT 50;

-- Active vs churned analysis
SELECT * FROM v_supplier_active_vs_churned;

-- Supplier longevity
SELECT * FROM v_supplier_longevity;
```

### 4. Power BI / Tableau Export (`04_powerbi_tableau_export.sql`)

**Views Created for Specific Visualizations:**

#### 4.1 Line Chart: Total Imports vs Duty Paid
- **View:** `v_line_chart_imports_vs_duty`
- **Use Case:** Time series line chart showing imports and duty paid over time
- **Columns:** year_month, total_imports_crores, duty_paid_crores

#### 4.2 YoY Growth Heatmap
- **View:** `v_yoy_growth_heatmap`
- **Use Case:** Heatmap showing YoY growth by month and year
- **Columns:** year, month, month_name, yoy_growth_total_value_pct

#### 4.3 Sunburst/TreeMap: Category Hierarchy
- **View:** `v_sunburst_category_hierarchy`
- **Use Case:** Hierarchical visualization of Category → Sub-Category → Model
- **Columns:** category, sub_category, model_name, total_value_inr_crores

#### 4.4 Supplier Bar Charts
- **Views:** 
  - `v_top_suppliers_by_value` - Top suppliers all-time
  - `v_supplier_active_vs_churned` - Active vs churned comparison
- **Use Case:** Bar charts for supplier performance analysis

#### 4.5 Scatter Plot: Capacity vs Cost
- **View:** `v_scatter_capacity_vs_cost`
- **Use Case:** Scatter plot showing relationship between capacity/specs and per-unit cost
- **Columns:** capacity_numeric, cost_per_unit_inr, cost_per_unit_usd

#### 4.6 Comprehensive Dashboard
- **View:** `v_dashboard_comprehensive`
- **Use Case:** Single view with all dimensions and metrics for flexible dashboard building
- **Columns:** All key dimensions and metrics in one table

## Connecting to Power BI

### Step 1: Connect to MySQL Database

1. Open Power BI Desktop
2. Click "Get Data" → "Database" → "MySQL database"
3. Enter connection details:
   - Server: `localhost` (or your MySQL host)
   - Database: `trade_db`
   - Authentication: Username/Password

### Step 2: Import Views

1. In Power BI Navigator, select the views you need:
   - `v_line_chart_imports_vs_duty`
   - `v_yoy_growth_heatmap`
   - `v_sunburst_category_hierarchy`
   - `v_top_suppliers_by_value`
   - `v_supplier_active_vs_churned`
   - `v_scatter_capacity_vs_cost`
   - `v_dashboard_comprehensive` (for flexible analysis)

2. Click "Load" to import data

### Step 3: Create Visualizations

**Line Chart (Total Imports vs Duty Paid):**
- X-axis: `year_month`
- Y-axis: `total_imports_crores`, `duty_paid_crores`
- Visualization: Line chart

**YoY Growth Heatmap:**
- Rows: `year`
- Columns: `month_name`
- Values: `yoy_growth_total_value_pct`
- Visualization: Matrix or Heatmap

**Sunburst/TreeMap:**
- Hierarchy: `category` → `sub_category` → `model_name`
- Values: `total_value_inr_crores`
- Visualization: Sunburst or TreeMap

**Supplier Bar Charts:**
- X-axis: `supplier_code`
- Y-axis: `lifetime_total_value_inr_crores`
- Visualization: Bar chart

**Scatter Plot:**
- X-axis: `capacity_numeric`
- Y-axis: `cost_per_unit_inr`
- Size: `total_value_inr`
- Color: `category`
- Visualization: Scatter chart

## Connecting to Tableau

### Step 1: Connect to MySQL Database

1. Open Tableau Desktop
2. Click "Connect" → "To a Server" → "MySQL"
3. Enter connection details:
   - Server: `localhost`
   - Port: `3306`
   - Database: `trade_db`
   - Username/Password

### Step 2: Use Views as Data Sources

1. Drag the views from the schema into the data source
2. Create relationships between views if needed
3. Build worksheets using the imported views

### Step 3: Create Visualizations

Similar to Power BI, use the appropriate columns from each view to create:
- Line charts for time series
- Heatmaps for YoY growth
- Tree maps for category hierarchy
- Bar charts for supplier analysis
- Scatter plots for capacity vs cost

## Performance Tips

1. **Indexes:** The base table already has indexes on key columns (year, hs_code, category, etc.)

2. **Materialized Views:** For very large datasets, consider creating materialized views or summary tables:
   ```sql
   CREATE TABLE summary_monthly AS 
   SELECT * FROM v_line_chart_imports_vs_duty;
   ```

3. **Filtering:** Always filter by date range in your BI tool to improve query performance:
   ```sql
   WHERE year >= 2020 AND year <= 2025
   ```

4. **Aggregation:** Use aggregated views instead of querying raw data when possible

## Troubleshooting

### Views Not Found
If you get "View does not exist" errors:
1. Ensure you've run all SQL files in order
2. Check that you're connected to the correct database (`trade_db`)
3. Verify views exist: `SHOW FULL TABLES WHERE TABLE_TYPE = 'VIEW';`

### Performance Issues
1. Check if indexes are being used: `EXPLAIN SELECT ...`
2. Consider adding indexes on frequently filtered columns
3. Use date range filters to limit data volume

### Data Quality Issues
1. Check for NULL values in key columns
2. Verify date ranges: `SELECT MIN(year), MAX(year) FROM trade_data;`
3. Validate supplier codes: `SELECT COUNT(DISTINCT iec) FROM trade_data;`

## Example Queries

### Quick Dashboard Summary
```sql
SELECT 
    (SELECT COUNT(*) FROM trade_data) AS total_transactions,
    (SELECT COUNT(DISTINCT iec) FROM trade_data) AS total_suppliers,
    (SELECT COUNT(DISTINCT hs_code) FROM trade_data) AS unique_hsn_codes,
    (SELECT SUM(total_value_inr) / 10000000 FROM trade_data) AS total_value_crores,
    (SELECT SUM(duty_paid_inr) / 10000000 FROM trade_data) AS total_duty_crores;
```

### Top 10 Categories by Value
```sql
SELECT 
    category,
    SUM(total_value_inr) / 10000000 AS value_crores,
    COUNT(*) AS transaction_count
FROM trade_data
GROUP BY category
ORDER BY value_crores DESC
LIMIT 10;
```

## Support

For issues or questions:
1. Check the view definitions: `SHOW CREATE VIEW view_name;`
2. Verify data exists: `SELECT COUNT(*) FROM trade_data;`
3. Review error messages in MySQL logs

