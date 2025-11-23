-- MySQL schema for trade data table
-- Compatible with cleaned CSV structure

CREATE DATABASE IF NOT EXISTS trade_db;
USE trade_db;

DROP TABLE IF EXISTS trade_data;

CREATE TABLE trade_data (
    id INT AUTO_INCREMENT PRIMARY KEY,
    
    -- Basic Information
    port_code VARCHAR(50),
    date_of_shipment DATE,
    year INT,
    month INT,
    quarter INT,
    iec VARCHAR(50),
    hs_code VARCHAR(20),
    
    -- Goods Information
    goods_description TEXT,
    master_category VARCHAR(100),
    model_name VARCHAR(100),
    model_number VARCHAR(100),
    capacity VARCHAR(50),
    
    -- Parsed Information
    model_name_parsed VARCHAR(100),
    model_number_parsed VARCHAR(100),
    capacity_parsed VARCHAR(50),
    material_type_parsed VARCHAR(100),
    embedded_quantity_parsed DECIMAL(15, 2),
    unit_price_usd_parsed DECIMAL(10, 4),
    
    -- Final Parsed Fields
    model_name_final VARCHAR(100),
    model_number_final VARCHAR(100),
    capacity_final VARCHAR(50),
    
    -- Quantity and Units
    qty DECIMAL(15, 2),
    unit_of_measure VARCHAR(20),
    price DECIMAL(15, 4),
    quantity DECIMAL(15, 2),
    unit VARCHAR(20),
    
    -- Pricing Information (INR)
    unit_price_inr DECIMAL(15, 4),
    total_value_inr DECIMAL(15, 2),
    duty_paid_inr DECIMAL(15, 2),
    grand_total_inr DECIMAL(15, 2),
    
    -- Pricing Information (USD)
    unit_price_usd DECIMAL(10, 4),
    total_value_usd DECIMAL(15, 2),
    
    -- Categories
    category VARCHAR(100),
    sub_category VARCHAR(100),
    
    -- Metadata
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Indexes for common queries
    INDEX idx_date (date_of_shipment),
    INDEX idx_year (year),
    INDEX idx_hs_code (hs_code),
    INDEX idx_category (category),
    INDEX idx_sub_category (sub_category),
    INDEX idx_port_code (port_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- View for summary statistics
CREATE OR REPLACE VIEW trade_summary AS
SELECT 
    year,
    quarter,
    category,
    sub_category,
    COUNT(*) as transaction_count,
    SUM(total_value_inr) as total_value_inr_sum,
    SUM(duty_paid_inr) as total_duty_paid_inr_sum,
    SUM(grand_total_inr) as total_grand_total_inr_sum,
    AVG(total_value_inr) as avg_value_inr,
    SUM(quantity) as total_quantity
FROM trade_data
GROUP BY year, quarter, category, sub_category;

