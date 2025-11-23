-- ============================================================================
-- POWER BI / TABLEAU EXPORT QUERIES
-- Optimized queries for specific dashboard visualizations
-- ============================================================================

-- ============================================================================
-- 1. LINE CHART: Total Imports vs Duty Paid (2017-2025)
-- ============================================================================
CREATE OR REPLACE VIEW v_line_chart_imports_vs_duty AS
SELECT 
    year,
    month,
    CONCAT(year, '-', LPAD(month, 2, '0')) AS year_month,
    SUM(total_value_inr) / 10000000 AS total_imports_crores,
    SUM(duty_paid_inr) / 10000000 AS duty_paid_crores,
    SUM(grand_total_inr) / 10000000 AS grand_total_crores,
    COUNT(*) AS transaction_count
FROM trade_data
WHERE year IS NOT NULL AND month IS NOT NULL
GROUP BY year, month
ORDER BY year, month;

-- Export Query for Line Chart
SELECT 
    year_month,
    year,
    month,
    total_imports_crores,
    duty_paid_crores,
    grand_total_crores,
    transaction_count
FROM v_line_chart_imports_vs_duty;

-- ============================================================================
-- 2. YOY GROWTH HEATMAP
-- ============================================================================
CREATE OR REPLACE VIEW v_yoy_growth_heatmap AS
WITH monthly_data AS (
    SELECT 
        year,
        month,
        SUM(total_value_inr) AS total_value_inr,
        SUM(duty_paid_inr) AS duty_paid_inr,
        SUM(grand_total_inr) AS grand_total_inr
    FROM trade_data
    WHERE year IS NOT NULL AND month IS NOT NULL
    GROUP BY year, month
),
yoy_monthly AS (
    SELECT 
        curr.year,
        curr.month,
        curr.total_value_inr,
        curr.duty_paid_inr,
        curr.grand_total_inr,
        prev.total_value_inr AS prev_total_value_inr,
        prev.duty_paid_inr AS prev_duty_paid_inr,
        prev.grand_total_inr AS prev_grand_total_inr,
        CASE 
            WHEN prev.total_value_inr > 0 
            THEN ((curr.total_value_inr - prev.total_value_inr) / prev.total_value_inr) * 100
            ELSE NULL
        END AS yoy_growth_total_value_pct,
        CASE 
            WHEN prev.duty_paid_inr > 0 
            THEN ((curr.duty_paid_inr - prev.duty_paid_inr) / prev.duty_paid_inr) * 100
            ELSE NULL
        END AS yoy_growth_duty_paid_pct
    FROM monthly_data curr
    LEFT JOIN monthly_data prev 
        ON curr.year = prev.year + 1 AND curr.month = prev.month
)
SELECT 
    year,
    month,
    CASE month
        WHEN 1 THEN 'Jan'
        WHEN 2 THEN 'Feb'
        WHEN 3 THEN 'Mar'
        WHEN 4 THEN 'Apr'
        WHEN 5 THEN 'May'
        WHEN 6 THEN 'Jun'
        WHEN 7 THEN 'Jul'
        WHEN 8 THEN 'Aug'
        WHEN 9 THEN 'Sep'
        WHEN 10 THEN 'Oct'
        WHEN 11 THEN 'Nov'
        WHEN 12 THEN 'Dec'
    END AS month_name,
    ROUND(yoy_growth_total_value_pct, 2) AS yoy_growth_total_value_pct,
    ROUND(yoy_growth_duty_paid_pct, 2) AS yoy_growth_duty_paid_pct,
    ROUND(total_value_inr / 10000000, 2) AS total_value_inr_crores,
    ROUND(duty_paid_inr / 10000000, 2) AS duty_paid_inr_crores
FROM yoy_monthly
WHERE year >= 2018  -- Need previous year for YoY calculation
ORDER BY year, month;

-- Export Query for YoY Growth Heatmap
SELECT 
    year,
    month,
    month_name,
    yoy_growth_total_value_pct,
    yoy_growth_duty_paid_pct,
    total_value_inr_crores,
    duty_paid_inr_crores
FROM v_yoy_growth_heatmap;

-- ============================================================================
-- 3. SUNBURST/TREEMAP: Category → Sub-Category → Model
-- ============================================================================
CREATE OR REPLACE VIEW v_sunburst_category_hierarchy AS
SELECT 
    COALESCE(category, 'Uncategorized') AS category,
    COALESCE(sub_category, 'Uncategorized') AS sub_category,
    COALESCE(model_name_final, model_name_parsed, 'Unknown Model') AS model_name,
    COUNT(*) AS transaction_count,
    SUM(total_value_inr) / 10000000 AS total_value_inr_crores,
    SUM(duty_paid_inr) / 10000000 AS duty_paid_inr_crores,
    SUM(grand_total_inr) / 10000000 AS grand_total_inr_crores,
    SUM(quantity) AS total_quantity,
    AVG(unit_price_inr) AS avg_unit_price_inr
FROM trade_data
GROUP BY 
    COALESCE(category, 'Uncategorized'),
    COALESCE(sub_category, 'Uncategorized'),
    COALESCE(model_name_final, model_name_parsed, 'Unknown Model')
ORDER BY total_value_inr_crores DESC;

-- Export Query for Sunburst/TreeMap
SELECT 
    category,
    sub_category,
    model_name,
    transaction_count,
    total_value_inr_crores,
    duty_paid_inr_crores,
    grand_total_inr_crores,
    total_quantity,
    avg_unit_price_inr,
    CONCAT(category, ' > ', sub_category, ' > ', model_name) AS hierarchy_path
FROM v_sunburst_category_hierarchy;

-- ============================================================================
-- 4. SUPPLIER BAR CHARTS
-- ============================================================================

-- 4a. Top Suppliers by Value (All Time)
CREATE OR REPLACE VIEW v_top_suppliers_by_value AS
SELECT 
    supplier_code,
    lifetime_total_value_inr_crores,
    lifetime_grand_total_inr_crores,
    active_years,
    total_transactions,
    supplier_status,
    supplier_segment,
    first_transaction_date,
    last_transaction_date
FROM v_supplier_lifetime_stats
ORDER BY lifetime_total_value_inr_crores DESC
LIMIT 50;

-- Export Query for Top Suppliers by Value
SELECT 
    supplier_code,
    lifetime_total_value_inr_crores,
    lifetime_grand_total_inr_crores,
    active_years,
    total_transactions,
    supplier_status,
    supplier_segment
FROM v_top_suppliers_by_value;

-- 4b. Active vs Churned Suppliers
CREATE OR REPLACE VIEW v_supplier_active_vs_churned AS
SELECT 
    supplier_segment,
    COUNT(*) AS supplier_count,
    SUM(lifetime_total_value_inr_crores) AS total_value_crores,
    AVG(lifetime_total_value_inr_crores) AS avg_value_crores,
    SUM(total_transactions) AS total_transactions,
    AVG(active_years) AS avg_active_years
FROM v_supplier_lifetime_stats
GROUP BY supplier_segment
ORDER BY 
    CASE supplier_segment
        WHEN 'Retained' THEN 1
        WHEN 'New' THEN 2
        WHEN 'Churned (Recent)' THEN 3
        WHEN 'Churned (Old)' THEN 4
    END;

-- Export Query for Active vs Churned
SELECT 
    supplier_segment,
    supplier_count,
    total_value_crores,
    avg_value_crores,
    total_transactions,
    avg_active_years
FROM v_supplier_active_vs_churned;

-- ============================================================================
-- 5. SCATTER PLOT: Capacity/Spec vs Per Unit Cost
-- ============================================================================
CREATE OR REPLACE VIEW v_scatter_capacity_vs_cost AS
SELECT 
    hs_code,
    category,
    sub_category,
    model_name_final AS model_name,
    capacity_parsed AS capacity,
    material_type_parsed AS material_type,
    quantity,
    unit,
    unit_price_inr,
    unit_price_usd,
    total_value_inr,
    total_value_usd,
    duty_paid_inr,
    grand_total_inr,
    date_of_shipment,
    year,
    quarter,
    -- Derived metrics for scatter plot
    CASE 
        WHEN capacity_parsed IS NOT NULL AND capacity_parsed != '' 
        THEN CAST(REPLACE(capacity_parsed, ',', '') AS UNSIGNED)
        ELSE NULL
    END AS capacity_numeric,
    CASE 
        WHEN quantity > 0 THEN total_value_inr / quantity
        ELSE NULL
    END AS cost_per_unit_inr,
    CASE 
        WHEN quantity > 0 THEN unit_price_usd
        ELSE NULL
    END AS cost_per_unit_usd
FROM trade_data
WHERE quantity > 0 
    AND (unit_price_inr > 0 OR unit_price_usd > 0)
    AND capacity_parsed IS NOT NULL
    AND capacity_parsed != '';

-- Export Query for Scatter Plot
SELECT 
    hs_code,
    category,
    sub_category,
    model_name,
    capacity,
    capacity_numeric,
    material_type,
    quantity,
    unit,
    unit_price_inr,
    unit_price_usd,
    cost_per_unit_inr,
    cost_per_unit_usd,
    total_value_inr,
    total_value_usd,
    year,
    quarter
FROM v_scatter_capacity_vs_cost
WHERE capacity_numeric IS NOT NULL
    AND cost_per_unit_inr IS NOT NULL
ORDER BY year DESC, total_value_inr DESC;

-- ============================================================================
-- COMPREHENSIVE DASHBOARD EXPORT (All metrics in one query)
-- ============================================================================
CREATE OR REPLACE VIEW v_dashboard_comprehensive AS
SELECT 
    -- Time dimensions
    year,
    quarter,
    month,
    date_of_shipment,
    -- Product dimensions
    hs_code,
    category,
    sub_category,
    model_name_final AS model_name,
    model_number_final AS model_number,
    capacity_parsed AS capacity,
    material_type_parsed AS material_type,
    -- Supplier dimensions
    iec AS supplier_code,
    port_code,
    -- Metrics
    quantity,
    unit,
    unit_price_inr,
    unit_price_usd,
    total_value_inr,
    total_value_usd,
    duty_paid_inr,
    grand_total_inr,
    -- Calculated fields
    ROUND(total_value_inr / 10000000, 2) AS total_value_inr_crores,
    ROUND(duty_paid_inr / 10000000, 2) AS duty_paid_inr_crores,
    ROUND(grand_total_inr / 10000000, 2) AS grand_total_inr_crores
FROM trade_data
WHERE year IS NOT NULL;

-- Export Query for Comprehensive Dashboard
SELECT * FROM v_dashboard_comprehensive
ORDER BY date_of_shipment DESC, total_value_inr DESC;

