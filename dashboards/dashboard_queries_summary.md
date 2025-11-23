# Dashboard Queries Summary

Quick reference guide for dashboard developers.

## Quick Access Queries

### 1. Line Chart: Total Imports vs Duty Paid
```sql
SELECT 
    year_month,
    year,
    month,
    total_imports_crores,
    duty_paid_crores,
    grand_total_crores
FROM v_line_chart_imports_vs_duty
ORDER BY year, month;
```

### 2. YoY Growth Heatmap
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

### 3. Sunburst/TreeMap: Category Hierarchy
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

### 4. Top Suppliers by Value
```sql
SELECT 
    supplier_code,
    lifetime_total_value_inr_crores,
    active_years,
    supplier_segment
FROM v_top_suppliers_by_value
LIMIT 50;
```

### 5. Active vs Churned Suppliers
```sql
SELECT 
    supplier_segment,
    supplier_count,
    total_value_crores,
    avg_value_crores
FROM v_supplier_active_vs_churned;
```

### 6. Scatter Plot: Capacity vs Cost
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

### 7. Pareto Analysis: Top 25 HSN Codes
```sql
SELECT 
    hs_code,
    hsn_group,
    total_value_inr_crores,
    pct_contribution,
    transaction_count
FROM v_pareto_hsn_analysis
ORDER BY rank_by_value;
```

### 8. Annual Growth Trends
```sql
SELECT 
    year,
    total_value_inr_crores,
    duty_paid_inr_crores,
    grand_total_inr_crores,
    yoy_growth_total_value_pct,
    yoy_growth_duty_paid_pct,
    yoy_growth_grand_total_pct
FROM v_annual_growth_trends
ORDER BY year;
```

## Data Export Formats

### CSV Export (for external tools)
```sql
-- Export to CSV (run in MySQL command line)
SELECT * FROM v_dashboard_comprehensive
INTO OUTFILE '/tmp/trade_dashboard_export.csv'
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n';
```

### JSON Export (for web dashboards)
```sql
-- Use JSON functions (MySQL 5.7+)
SELECT JSON_OBJECT(
    'year', year,
    'total_value', total_value_inr_crores,
    'duty_paid', duty_paid_inr_crores
) AS json_data
FROM v_annual_growth_trends;
```

## Filtering Examples

### Filter by Date Range
```sql
SELECT * FROM v_dashboard_comprehensive
WHERE year >= 2020 AND year <= 2025;
```

### Filter by Category
```sql
SELECT * FROM v_sunburst_category_hierarchy
WHERE category = 'Household Articles';
```

### Filter Active Suppliers Only
```sql
SELECT * FROM v_supplier_lifetime_stats
WHERE is_active_2025 = 1
ORDER BY value_2025_crores DESC;
```

