# Trade Data Dashboard Guide

Complete guide for building dashboards with the trade data pipeline.

## Overview

This guide covers all SQL queries and views created for analyzing trade data and building dashboards in Power BI, Tableau, or other BI tools.

## Quick Start

1. **Load Data to Database:**
   ```bash
   python src/pipeline.py
   python src/db/load_to_db.py
   ```

2. **Create Analysis Views:**
   ```bash
   # Windows
   sql\run_all_views.bat root your_password trade_db
   
   # Linux/Mac
   chmod +x sql/run_all_views.sh
   ./sql/run_all_views.sh root your_password trade_db
   ```

3. **Connect BI Tool:**
   - Power BI: Get Data → MySQL Database
   - Tableau: Connect → MySQL
   - Use database: `trade_db`

## Analysis Modules

### 1. Macro Growth Trends

**Purpose:** Calculate Year-over-Year (YoY) growth percentages for key metrics.

**Views:**
- `v_annual_growth_trends` - Annual summary with YoY calculations
- `v_quarterly_growth_trends` - Quarterly summary with QoQ calculations

**Key Metrics:**
- Total Value (INR) - YoY % growth
- Duty Paid (INR) - YoY % growth
- Grand Total (INR) - YoY % growth
- Transaction counts and quantities

**Use Cases:**
- Executive dashboards showing business growth
- Trend analysis over time
- Performance comparisons year-over-year

**Sample Query:**
```sql
SELECT 
    year,
    total_value_inr_crores,
    yoy_growth_total_value_pct,
    yoy_growth_duty_paid_pct
FROM v_annual_growth_trends
ORDER BY year;
```

### 2. Pareto Analysis

**Purpose:** Identify top 25 HSN codes by value and their contribution to total trade.

**Views:**
- `v_hsn_performance` - All HSN codes with rankings
- `v_pareto_hsn_analysis` - Top 25 + Others group
- `v_pareto_cumulative` - Cumulative contribution (80/20 analysis)

**Key Metrics:**
- Top 25 HSN codes by total value
- % contribution to total trade
- Remaining codes grouped as "Others"
- Cumulative contribution percentages

**Use Cases:**
- Product portfolio analysis
- Focus area identification
- 80/20 rule validation

**Sample Query:**
```sql
SELECT 
    hs_code,
    total_value_inr_crores,
    pct_contribution,
    rank_by_value
FROM v_pareto_hsn_analysis
ORDER BY rank_by_value;
```

### 3. Supplier Analysis

**Purpose:** Analyze supplier performance, activity, and longevity.

**Views:**
- `v_supplier_lifetime_stats` - Complete supplier statistics
- `v_supplier_active_analysis` - Active vs churned comparison
- `v_supplier_longevity` - Longevity by segment
- `v_supplier_summary_by_year` - Yearly supplier activity

**Key Metrics:**
- Active suppliers in 2025 vs historical
- Supplier longevity (years active)
- Supplier segments: Retained, New, Churned
- Lifetime value and transaction counts

**Use Cases:**
- Supplier relationship management
- Churn analysis
- Supplier performance tracking
- Strategic supplier identification

**Sample Queries:**
```sql
-- Top suppliers by value
SELECT * FROM v_supplier_lifetime_stats 
ORDER BY lifetime_total_value_inr_crores DESC LIMIT 50;

-- Active vs churned
SELECT * FROM v_supplier_active_vs_churned;

-- Supplier longevity
SELECT * FROM v_supplier_longevity;
```

### 4. Power BI / Tableau Export Queries

**Purpose:** Optimized queries for specific dashboard visualizations.

#### 4.1 Line Chart: Total Imports vs Duty Paid

**View:** `v_line_chart_imports_vs_duty`

**Visualization Setup:**
- X-axis: `year_month` (or `year` and `month` separately)
- Y-axis: `total_imports_crores`, `duty_paid_crores`
- Chart Type: Line chart with dual Y-axis

**Query:**
```sql
SELECT 
    year_month,
    total_imports_crores,
    duty_paid_crores,
    grand_total_crores
FROM v_line_chart_imports_vs_duty
ORDER BY year, month;
```

#### 4.2 YoY Growth Heatmap

**View:** `v_yoy_growth_heatmap`

**Visualization Setup:**
- Rows: `year`
- Columns: `month_name`
- Values: `yoy_growth_total_value_pct`
- Color: Gradient based on growth percentage
- Chart Type: Heatmap or Matrix

**Query:**
```sql
SELECT 
    year,
    month,
    month_name,
    yoy_growth_total_value_pct,
    yoy_growth_duty_paid_pct
FROM v_yoy_growth_heatmap
ORDER BY year, month;
```

#### 4.3 Sunburst/TreeMap: Category Hierarchy

**View:** `v_sunburst_category_hierarchy`

**Visualization Setup:**
- Hierarchy: `category` → `sub_category` → `model_name`
- Size: `total_value_inr_crores`
- Color: By category or sub-category
- Chart Type: Sunburst or TreeMap

**Query:**
```sql
SELECT 
    category,
    sub_category,
    model_name,
    total_value_inr_crores,
    hierarchy_path
FROM v_sunburst_category_hierarchy
ORDER BY total_value_inr_crores DESC;
```

#### 4.4 Supplier Bar Charts

**Views:** 
- `v_top_suppliers_by_value` - Top suppliers all-time
- `v_supplier_active_vs_churned` - Active vs churned comparison

**Visualization Setup:**
- X-axis: `supplier_code` or `supplier_segment`
- Y-axis: `lifetime_total_value_inr_crores` or `total_value_crores`
- Chart Type: Bar chart or Column chart

**Queries:**
```sql
-- Top suppliers
SELECT 
    supplier_code,
    lifetime_total_value_inr_crores,
    active_years
FROM v_top_suppliers_by_value
LIMIT 50;

-- Active vs churned
SELECT 
    supplier_segment,
    supplier_count,
    total_value_crores
FROM v_supplier_active_vs_churned;
```

#### 4.5 Scatter Plot: Capacity vs Cost

**View:** `v_scatter_capacity_vs_cost`

**Visualization Setup:**
- X-axis: `capacity_numeric`
- Y-axis: `cost_per_unit_inr` or `cost_per_unit_usd`
- Size: `total_value_inr`
- Color: `category` or `sub_category`
- Chart Type: Scatter plot

**Query:**
```sql
SELECT 
    category,
    sub_category,
    model_name,
    capacity_numeric,
    cost_per_unit_inr,
    cost_per_unit_usd,
    total_value_inr
FROM v_scatter_capacity_vs_cost
WHERE capacity_numeric IS NOT NULL
    AND cost_per_unit_inr IS NOT NULL;
```

## Dashboard Best Practices

### 1. Performance Optimization

- **Use Views:** Always use pre-created views instead of querying raw tables
- **Filter Early:** Apply date range filters in your BI tool
- **Limit Rows:** Use TOP/LIMIT clauses for large result sets
- **Index Usage:** Ensure indexes are being used (check EXPLAIN plans)

### 2. Data Refresh

- **Incremental Load:** For large datasets, consider incremental data loading
- **Refresh Schedule:** Set up scheduled refreshes based on data update frequency
- **Cache Management:** Clear cache when data structure changes

### 3. Visualization Design

- **Consistent Formatting:** Use consistent number formats (crores, percentages)
- **Color Coding:** Use consistent color schemes across dashboards
- **Tooltips:** Add informative tooltips with additional context
- **Filters:** Provide interactive filters for date ranges and categories

### 4. Common Patterns

**Time Series Analysis:**
```sql
-- Always include year and month for proper sorting
SELECT year, month, year_month, metric
FROM view_name
WHERE year >= 2020
ORDER BY year, month;
```

**Top N Analysis:**
```sql
-- Use LIMIT or TOP for top N queries
SELECT * FROM view_name
ORDER BY value_column DESC
LIMIT 10;
```

**Percentage Calculations:**
```sql
-- Percentages are already calculated in views
-- Use them directly in visualizations
SELECT category, pct_contribution
FROM v_pareto_hsn_analysis;
```

## Troubleshooting

### Common Issues

1. **Views Not Found**
   - Solution: Run all SQL view creation files
   - Verify: `SHOW FULL TABLES WHERE TABLE_TYPE = 'VIEW';`

2. **Slow Queries**
   - Solution: Add date range filters
   - Check: `EXPLAIN SELECT ...` to see query plan
   - Consider: Creating materialized views for frequently accessed data

3. **Missing Data**
   - Solution: Verify data is loaded: `SELECT COUNT(*) FROM trade_data;`
   - Check: Date ranges: `SELECT MIN(year), MAX(year) FROM trade_data;`

4. **NULL Values**
   - Solution: Views handle NULLs with COALESCE
   - Filter: Use `WHERE column IS NOT NULL` if needed

### Performance Tuning

1. **Add Indexes:**
   ```sql
   CREATE INDEX idx_year_month ON trade_data(year, month);
   CREATE INDEX idx_supplier_year ON trade_data(iec, year);
   ```

2. **Materialize Views:**
   ```sql
   CREATE TABLE summary_monthly AS 
   SELECT * FROM v_line_chart_imports_vs_duty;
   ```

3. **Partition Large Tables:**
   ```sql
   -- For very large datasets, consider partitioning by year
   ALTER TABLE trade_data 
   PARTITION BY RANGE (year) (...);
   ```

## Next Steps

1. **Customize Views:** Modify views to match your specific requirements
2. **Add Metrics:** Create additional calculated fields in your BI tool
3. **Create Dashboards:** Build interactive dashboards using the views
4. **Schedule Refreshes:** Set up automated data refresh schedules
5. **Share Insights:** Publish dashboards and share with stakeholders

## Support Resources

- SQL Files: `sql/` directory
- Documentation: `sql/README.md`
- Quick Reference: `dashboards/dashboard_queries_summary.md`
- Database Schema: `sql/create_trade_table.sql`

## Version History

- **v1.0** - Initial release with all analysis views
- All views are compatible with MySQL 5.7+ and MySQL 8.0+

