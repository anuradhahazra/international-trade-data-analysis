-- ============================================================================
-- MASTER SETUP SCRIPT
-- Creates all views and queries for dashboard analysis
-- Run this script after loading data to set up all analysis views
-- ============================================================================

USE trade_db;

-- Source all analysis SQL files
-- Note: In MySQL, you may need to run each file separately
-- This file serves as a reference for the order of execution

-- 1. Macro Growth Trends
SOURCE sql/01_macro_growth_trends.sql;

-- 2. Pareto Analysis
SOURCE sql/02_pareto_analysis.sql;

-- 3. Supplier Analysis
SOURCE sql/03_supplier_analysis.sql;

-- 4. Power BI / Tableau Export Queries
SOURCE sql/04_powerbi_tableau_export.sql;

-- ============================================================================
-- VERIFICATION QUERIES
-- Run these to verify all views are created successfully
-- ============================================================================

-- Check all views
SELECT 
    TABLE_NAME AS view_name,
    TABLE_TYPE
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'trade_db'
    AND TABLE_TYPE = 'VIEW'
ORDER BY TABLE_NAME;

-- Quick data validation
SELECT 
    'trade_data' AS table_name,
    COUNT(*) AS row_count,
    MIN(date_of_shipment) AS earliest_date,
    MAX(date_of_shipment) AS latest_date,
    MIN(year) AS min_year,
    MAX(year) AS max_year
FROM trade_data
UNION ALL
SELECT 
    'v_annual_growth_trends' AS table_name,
    COUNT(*) AS row_count,
    NULL AS earliest_date,
    NULL AS latest_date,
    MIN(year) AS min_year,
    MAX(year) AS max_year
FROM v_annual_growth_trends;

