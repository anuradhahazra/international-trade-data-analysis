-- ============================================================================
-- PARETO ANALYSIS
-- Top 25 HSN Codes by Value with % Contribution
-- Remaining HSN codes grouped as "Others"
-- ============================================================================

-- View: HSN Code Performance with Rankings
CREATE OR REPLACE VIEW v_hsn_performance AS
WITH hsn_summary AS (
    SELECT 
        hs_code,
        COUNT(*) AS transaction_count,
        SUM(total_value_inr) AS total_value_inr,
        SUM(duty_paid_inr) AS duty_paid_inr,
        SUM(grand_total_inr) AS grand_total_inr,
        SUM(quantity) AS total_quantity,
        AVG(unit_price_inr) AS avg_unit_price_inr,
        MIN(date_of_shipment) AS first_transaction_date,
        MAX(date_of_shipment) AS last_transaction_date
    FROM trade_data
    WHERE hs_code IS NOT NULL
    GROUP BY hs_code
),
total_summary AS (
    SELECT 
        SUM(total_value_inr) AS grand_total_value_inr
    FROM hsn_summary
),
ranked_hsn AS (
    SELECT 
        h.hs_code,
        h.transaction_count,
        h.total_value_inr,
        h.duty_paid_inr,
        h.grand_total_inr,
        h.total_quantity,
        h.avg_unit_price_inr,
        h.first_transaction_date,
        h.last_transaction_date,
        ROUND((h.total_value_inr / t.grand_total_value_inr) * 100, 2) AS pct_contribution,
        ROW_NUMBER() OVER (ORDER BY h.total_value_inr DESC) AS rank_by_value
    FROM hsn_summary h
    CROSS JOIN total_summary t
)
SELECT 
    hs_code,
    transaction_count,
    ROUND(total_value_inr / 10000000, 2) AS total_value_inr_crores,
    ROUND(duty_paid_inr / 10000000, 2) AS duty_paid_inr_crores,
    ROUND(grand_total_inr / 10000000, 2) AS grand_total_inr_crores,
    total_quantity,
    ROUND(avg_unit_price_inr, 2) AS avg_unit_price_inr,
    first_transaction_date,
    last_transaction_date,
    pct_contribution,
    rank_by_value
FROM ranked_hsn
ORDER BY rank_by_value;

-- Query: Top 25 HSN Codes with Others Group
CREATE OR REPLACE VIEW v_pareto_hsn_analysis AS
WITH top_25 AS (
    SELECT 
        hs_code,
        transaction_count,
        total_value_inr_crores,
        duty_paid_inr_crores,
        grand_total_inr_crores,
        total_quantity,
        pct_contribution,
        rank_by_value,
        'Top 25' AS hsn_group
    FROM v_hsn_performance
    WHERE rank_by_value <= 25
),
others_summary AS (
    SELECT 
        'Others' AS hs_code,
        SUM(transaction_count) AS transaction_count,
        SUM(total_value_inr_crores) AS total_value_inr_crores,
        SUM(duty_paid_inr_crores) AS duty_paid_inr_crores,
        SUM(grand_total_inr_crores) AS grand_total_inr_crores,
        SUM(total_quantity) AS total_quantity,
        SUM(pct_contribution) AS pct_contribution,
        26 AS rank_by_value,
        'Others' AS hsn_group
    FROM v_hsn_performance
    WHERE rank_by_value > 25
)
SELECT 
    hs_code,
    transaction_count,
    total_value_inr_crores,
    duty_paid_inr_crores,
    grand_total_inr_crores,
    total_quantity,
    pct_contribution,
    rank_by_value,
    hsn_group
FROM top_25
UNION ALL
SELECT 
    hs_code,
    transaction_count,
    total_value_inr_crores,
    duty_paid_inr_crores,
    grand_total_inr_crores,
    total_quantity,
    pct_contribution,
    rank_by_value,
    hsn_group
FROM others_summary
ORDER BY rank_by_value;

-- Query: Get Pareto Analysis (for dashboard)
SELECT 
    hs_code,
    hsn_group,
    total_value_inr_crores,
    pct_contribution,
    transaction_count,
    rank_by_value
FROM v_pareto_hsn_analysis
ORDER BY rank_by_value;

-- Query: Cumulative Contribution Analysis (80/20 Rule)
CREATE OR REPLACE VIEW v_pareto_cumulative AS
WITH ranked_data AS (
    SELECT 
        hs_code,
        total_value_inr_crores,
        pct_contribution,
        rank_by_value
    FROM v_hsn_performance
    ORDER BY rank_by_value
),
cumulative_data AS (
    SELECT 
        hs_code,
        total_value_inr_crores,
        pct_contribution,
        rank_by_value,
        SUM(pct_contribution) OVER (ORDER BY rank_by_value) AS cumulative_pct_contribution,
        SUM(total_value_inr_crores) OVER (ORDER BY rank_by_value) AS cumulative_value_crores
    FROM ranked_data
)
SELECT 
    hs_code,
    total_value_inr_crores,
    pct_contribution,
    rank_by_value,
    ROUND(cumulative_pct_contribution, 2) AS cumulative_pct_contribution,
    ROUND(cumulative_value_crores, 2) AS cumulative_value_crores,
    CASE 
        WHEN cumulative_pct_contribution <= 80 THEN 'Top 80%'
        WHEN cumulative_pct_contribution <= 95 THEN 'Next 15%'
        ELSE 'Bottom 5%'
    END AS pareto_segment
FROM cumulative_data
ORDER BY rank_by_value;

