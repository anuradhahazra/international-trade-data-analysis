-- ============================================================================
-- MACRO GROWTH TRENDS ANALYSIS
-- Year-over-Year (YoY) % Growth for Total Value, Duty Paid, Grand Total
-- ============================================================================

-- View: Annual Summary with YoY Growth
CREATE OR REPLACE VIEW v_annual_growth_trends AS
WITH annual_summary AS (
    SELECT 
        year,
        SUM(total_value_inr) AS total_value_inr,
        SUM(duty_paid_inr) AS duty_paid_inr,
        SUM(grand_total_inr) AS grand_total_inr,
        COUNT(*) AS transaction_count,
        SUM(quantity) AS total_quantity
    FROM trade_data
    WHERE year IS NOT NULL
    GROUP BY year
),
yoy_calculation AS (
    SELECT 
        curr.year,
        curr.total_value_inr,
        curr.duty_paid_inr,
        curr.grand_total_inr,
        curr.transaction_count,
        curr.total_quantity,
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
        END AS yoy_growth_duty_paid_pct,
        CASE 
            WHEN prev.grand_total_inr > 0 
            THEN ((curr.grand_total_inr - prev.grand_total_inr) / prev.grand_total_inr) * 100
            ELSE NULL
        END AS yoy_growth_grand_total_pct
    FROM annual_summary curr
    LEFT JOIN annual_summary prev 
        ON curr.year = prev.year + 1
)
SELECT 
    year,
    total_value_inr,
    duty_paid_inr,
    grand_total_inr,
    transaction_count,
    total_quantity,
    prev_total_value_inr,
    prev_duty_paid_inr,
    prev_grand_total_inr,
    ROUND(yoy_growth_total_value_pct, 2) AS yoy_growth_total_value_pct,
    ROUND(yoy_growth_duty_paid_pct, 2) AS yoy_growth_duty_paid_pct,
    ROUND(yoy_growth_grand_total_pct, 2) AS yoy_growth_grand_total_pct,
    -- Additional metrics
    ROUND(total_value_inr / 10000000, 2) AS total_value_inr_crores,
    ROUND(duty_paid_inr / 10000000, 2) AS duty_paid_inr_crores,
    ROUND(grand_total_inr / 10000000, 2) AS grand_total_inr_crores
FROM yoy_calculation
ORDER BY year;

-- Query: Get annual growth trends (for dashboard)
SELECT 
    year,
    total_value_inr_crores,
    duty_paid_inr_crores,
    grand_total_inr_crores,
    yoy_growth_total_value_pct,
    yoy_growth_duty_paid_pct,
    yoy_growth_grand_total_pct,
    transaction_count,
    total_quantity
FROM v_annual_growth_trends
ORDER BY year;

-- Query: Quarterly Growth Trends
CREATE OR REPLACE VIEW v_quarterly_growth_trends AS
WITH quarterly_summary AS (
    SELECT 
        year,
        quarter,
        CONCAT(year, '-Q', quarter) AS year_quarter,
        SUM(total_value_inr) AS total_value_inr,
        SUM(duty_paid_inr) AS duty_paid_inr,
        SUM(grand_total_inr) AS grand_total_inr,
        COUNT(*) AS transaction_count
    FROM trade_data
    WHERE year IS NOT NULL AND quarter IS NOT NULL
    GROUP BY year, quarter
),
qoq_calculation AS (
    SELECT 
        curr.year,
        curr.quarter,
        curr.year_quarter,
        curr.total_value_inr,
        curr.duty_paid_inr,
        curr.grand_total_inr,
        curr.transaction_count,
        prev.total_value_inr AS prev_total_value_inr,
        prev.duty_paid_inr AS prev_duty_paid_inr,
        prev.grand_total_inr AS prev_grand_total_inr,
        CASE 
            WHEN prev.total_value_inr > 0 
            THEN ((curr.total_value_inr - prev.total_value_inr) / prev.total_value_inr) * 100
            ELSE NULL
        END AS qoq_growth_total_value_pct,
        CASE 
            WHEN prev.duty_paid_inr > 0 
            THEN ((curr.duty_paid_inr - prev.duty_paid_inr) / prev.duty_paid_inr) * 100
            ELSE NULL
        END AS qoq_growth_duty_paid_pct
    FROM quarterly_summary curr
    LEFT JOIN quarterly_summary prev 
        ON (curr.year = prev.year AND curr.quarter = prev.quarter + 1)
        OR (curr.year = prev.year + 1 AND curr.quarter = 1 AND prev.quarter = 4)
)
SELECT 
    year,
    quarter,
    year_quarter,
    ROUND(total_value_inr / 10000000, 2) AS total_value_inr_crores,
    ROUND(duty_paid_inr / 10000000, 2) AS duty_paid_inr_crores,
    ROUND(grand_total_inr / 10000000, 2) AS grand_total_inr_crores,
    ROUND(qoq_growth_total_value_pct, 2) AS qoq_growth_total_value_pct,
    ROUND(qoq_growth_duty_paid_pct, 2) AS qoq_growth_duty_paid_pct,
    transaction_count
FROM qoq_calculation
ORDER BY year, quarter;

