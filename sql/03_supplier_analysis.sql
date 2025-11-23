-- ============================================================================
-- SUPPLIER ANALYSIS
-- Active Suppliers in 2025 vs Historical Data
-- Supplier Longevity Analysis
-- ============================================================================

-- View: Supplier Summary by Year
CREATE OR REPLACE VIEW v_supplier_summary_by_year AS
SELECT 
    iec AS supplier_code,
    year,
    COUNT(*) AS transaction_count,
    SUM(total_value_inr) AS total_value_inr,
    SUM(duty_paid_inr) AS duty_paid_inr,
    SUM(grand_total_inr) AS grand_total_inr,
    SUM(quantity) AS total_quantity,
    MIN(date_of_shipment) AS first_transaction_date,
    MAX(date_of_shipment) AS last_transaction_date,
    COUNT(DISTINCT hs_code) AS unique_hsn_codes,
    COUNT(DISTINCT category) AS unique_categories
FROM trade_data
WHERE iec IS NOT NULL AND year IS NOT NULL
GROUP BY iec, year;

-- View: Supplier Lifetime Statistics
CREATE OR REPLACE VIEW v_supplier_lifetime_stats AS
WITH supplier_years AS (
    SELECT 
        iec AS supplier_code,
        MIN(year) AS first_year,
        MAX(year) AS last_year,
        COUNT(DISTINCT year) AS active_years,
        COUNT(*) AS total_transactions,
        SUM(total_value_inr) AS lifetime_total_value_inr,
        SUM(duty_paid_inr) AS lifetime_duty_paid_inr,
        SUM(grand_total_inr) AS lifetime_grand_total_inr,
        MIN(date_of_shipment) AS first_transaction_date,
        MAX(date_of_shipment) AS last_transaction_date,
        COUNT(DISTINCT hs_code) AS unique_hsn_codes,
        COUNT(DISTINCT category) AS unique_categories
    FROM trade_data
    WHERE iec IS NOT NULL
    GROUP BY iec
),
supplier_2025_status AS (
    SELECT 
        iec AS supplier_code,
        CASE WHEN MAX(year) = 2025 THEN 1 ELSE 0 END AS is_active_2025,
        SUM(CASE WHEN year = 2025 THEN total_value_inr ELSE 0 END) AS value_2025,
        COUNT(CASE WHEN year = 2025 THEN 1 END) AS transactions_2025
    FROM trade_data
    WHERE iec IS NOT NULL
    GROUP BY iec
)
SELECT 
    s.supplier_code,
    s.first_year,
    s.last_year,
    s.active_years,
    s.total_transactions,
    ROUND(s.lifetime_total_value_inr / 10000000, 2) AS lifetime_total_value_inr_crores,
    ROUND(s.lifetime_duty_paid_inr / 10000000, 2) AS lifetime_duty_paid_inr_crores,
    ROUND(s.lifetime_grand_total_inr / 10000000, 2) AS lifetime_grand_total_inr_crores,
    s.first_transaction_date,
    s.last_transaction_date,
    s.unique_hsn_codes,
    s.unique_categories,
    CASE 
        WHEN s.last_year = 2025 THEN 'Active'
        WHEN s.last_year >= 2023 THEN 'Recent'
        WHEN s.last_year >= 2020 THEN 'Dormant'
        ELSE 'Inactive'
    END AS supplier_status,
    st.is_active_2025,
    ROUND(st.value_2025 / 10000000, 2) AS value_2025_crores,
    st.transactions_2025,
    CASE 
        WHEN s.last_year = 2025 AND s.first_year < 2025 THEN 'Retained'
        WHEN s.last_year = 2025 AND s.first_year = 2025 THEN 'New'
        WHEN s.last_year < 2025 AND s.last_year >= 2023 THEN 'Churned (Recent)'
        ELSE 'Churned (Old)'
    END AS supplier_segment
FROM supplier_years s
LEFT JOIN supplier_2025_status st ON s.supplier_code = st.supplier_code
ORDER BY s.lifetime_total_value_inr DESC;

-- Query: Active Suppliers in 2025 vs Historical
CREATE OR REPLACE VIEW v_supplier_active_analysis AS
WITH historical_suppliers AS (
    SELECT DISTINCT iec AS supplier_code
    FROM trade_data
    WHERE iec IS NOT NULL AND year < 2025
),
active_2025_suppliers AS (
    SELECT DISTINCT iec AS supplier_code
    FROM trade_data
    WHERE iec IS NOT NULL AND year = 2025
),
supplier_comparison AS (
    SELECT 
        COALESCE(h.supplier_code, a.supplier_code) AS supplier_code,
        CASE WHEN h.supplier_code IS NOT NULL THEN 1 ELSE 0 END AS is_historical,
        CASE WHEN a.supplier_code IS NOT NULL THEN 1 ELSE 0 END AS is_active_2025,
        CASE 
            WHEN h.supplier_code IS NOT NULL AND a.supplier_code IS NOT NULL THEN 'Retained'
            WHEN h.supplier_code IS NOT NULL AND a.supplier_code IS NULL THEN 'Churned'
            WHEN h.supplier_code IS NULL AND a.supplier_code IS NOT NULL THEN 'New'
        END AS supplier_type
    FROM historical_suppliers h
    LEFT JOIN active_2025_suppliers a ON h.supplier_code = a.supplier_code
    UNION
    SELECT 
        a.supplier_code,
        CASE WHEN h.supplier_code IS NOT NULL THEN 1 ELSE 0 END AS is_historical,
        CASE WHEN a.supplier_code IS NOT NULL THEN 1 ELSE 0 END AS is_active_2025,
        CASE 
            WHEN h.supplier_code IS NOT NULL AND a.supplier_code IS NOT NULL THEN 'Retained'
            WHEN h.supplier_code IS NOT NULL AND a.supplier_code IS NULL THEN 'Churned'
            WHEN h.supplier_code IS NULL AND a.supplier_code IS NOT NULL THEN 'New'
        END AS supplier_type
    FROM active_2025_suppliers a
    LEFT JOIN historical_suppliers h ON a.supplier_code = h.supplier_code
    WHERE h.supplier_code IS NULL
)
SELECT 
    supplier_type,
    COUNT(*) AS supplier_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM supplier_comparison), 2) AS pct_of_total
FROM supplier_comparison
GROUP BY supplier_type
ORDER BY 
    CASE supplier_type
        WHEN 'Retained' THEN 1
        WHEN 'New' THEN 2
        WHEN 'Churned' THEN 3
    END;

-- Query: Supplier Longevity Analysis
CREATE OR REPLACE VIEW v_supplier_longevity AS
SELECT 
    supplier_segment,
    COUNT(*) AS supplier_count,
    AVG(active_years) AS avg_active_years,
    MIN(active_years) AS min_active_years,
    MAX(active_years) AS max_active_years,
    SUM(lifetime_total_value_inr_crores) AS total_value_crores,
    AVG(lifetime_total_value_inr_crores) AS avg_value_crores,
    SUM(total_transactions) AS total_transactions,
    AVG(total_transactions) AS avg_transactions_per_supplier
FROM v_supplier_lifetime_stats
GROUP BY supplier_segment
ORDER BY 
    CASE supplier_segment
        WHEN 'Retained' THEN 1
        WHEN 'New' THEN 2
        WHEN 'Churned (Recent)' THEN 3
        WHEN 'Churned (Old)' THEN 4
    END;

-- Query: Top Suppliers by Value (All Time)
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

-- Query: Top Active Suppliers in 2025
SELECT 
    supplier_code,
    value_2025_crores,
    transactions_2025,
    lifetime_total_value_inr_crores,
    active_years,
    supplier_segment
FROM v_supplier_lifetime_stats
WHERE is_active_2025 = 1
ORDER BY value_2025_crores DESC
LIMIT 50;

-- Query: Churned Suppliers Analysis
SELECT 
    supplier_code,
    lifetime_total_value_inr_crores,
    last_year,
    active_years,
    total_transactions,
    supplier_segment
FROM v_supplier_lifetime_stats
WHERE supplier_segment LIKE 'Churned%'
ORDER BY lifetime_total_value_inr_crores DESC
LIMIT 50;

