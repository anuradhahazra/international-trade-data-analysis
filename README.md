# Trade Data Pipeline

A complete data pipeline for processing international trade data (2017-2025).

**Power BI Dashboard Views:**
**https://drive.google.com/file/d/1bOSzJ7a54aCfHYOCnnAfNHhnC3L9aD29/view?usp=sharing**

## Project Structure

```
siddharth_trade_pipeline/
├── data/
│   ├── raw/                    # Raw input data
│   └── processed/              # Cleaned output data
├── notebooks/                  # Jupyter notebooks for exploration
├── src/
│   ├── cleaning/               # Data cleaning modules
│   │   └── clean_base.py
│   ├── parsing/                # Data parsing modules
│   │   └── parse_goods_description.py
│   ├── feature_engineering/   # Feature engineering modules
│   │   └── features.py
│   ├── db/                     # Database loading modules
│   │   └── load_to_db.py
│   └── pipeline.py            # Main pipeline orchestrator
├── sql/                        # SQL schema files
│   └── create_trade_table.sql
├── dashboards/                 # Dashboard files (future)
├── docs/                       # Documentation (future)
└── requirements.txt
```

## Setup

1. **Install dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

2. **Configure database connection:**
   Create a `.env` file in the project root with:
   ```
   DB_USER=your_username
   DB_PASSWORD=your_password
   DB_HOST=localhost
   DB_PORT=3306
   DB_NAME=trade_db
   ```

3. **Create MySQL database:**
   ```bash
   mysql -u root -p < sql/create_trade_table.sql
   ```

## Usage

### Step 1: Run the Data Pipeline

Process the raw CSV file through cleaning, parsing, and feature engineering:

```bash
python src/pipeline.py
```

Or specify custom input/output paths:
```bash
python src/pipeline.py data/raw/import_data_2017_2025.csv data/processed/trade_cleaned.csv
```

This will:
- Clean the base data (date conversion, missing values, unit standardization)
- Parse goods descriptions to extract structured information
- Engineer features (Grand Total, Categories, Sub-Categories)
- Save cleaned data to `data/processed/trade_cleaned.csv`

### Step 2: Load Data to MySQL

Load the cleaned CSV into MySQL database:

```bash
python src/db/load_to_db.py
```

Or specify a custom CSV file:
```bash
python src/db/load_to_db.py data/processed/trade_cleaned.csv
```

## Pipeline Components

### 1. Basic Cleaning (`clean_base.py`)
- Converts `DATE` to datetime format
- Derives Year, Month, Quarter columns
- Handles missing values in `TOTAL VALUE_INR`, `DUTY PAID_INR`, `QUANTITY`
- Standardizes units (pcs, nos, pieces → pcs)

### 2. Goods Description Parsing (`parse_goods_description.py`)
- Extracts Model Name (e.g., TH5170, AM-967, SB-12)
- Extracts Model Number (e.g., RYX-02-020, 2628)
- Extracts Capacity (e.g., 10PCS SET, 6PCS SET)
- Extracts Material Type (e.g., STEEL, MILD STEEL)
- Extracts Embedded Quantity from description
- Extracts Unit Price USD from description

### 3. Feature Engineering (`features.py`)
- Calculates Grand Total = Total Value (INR) + Duty Paid (INR)
- Assigns Category based on HSN Code
- Assigns Sub-Category based on Goods Description and HSN Code

### 4. Database Loading (`load_to_db.py`)
- Maps CSV columns to database schema
- Handles data type conversions
- Loads data into MySQL with proper error handling

## Database Schema

The MySQL table includes:
- Basic trade information (port, date, IEC, HSN code)
- Goods description and parsed fields
- Quantity and pricing information (INR and USD)
- Engineered features (Grand Total, Categories)
- Indexes for common queries

See `sql/create_trade_table.sql` for complete schema.

## Output

The pipeline generates:
- **Cleaned CSV**: `data/processed/trade_cleaned.csv` with all processed columns
- **MySQL Database**: `trade_data` table with indexed, queryable data
- **Summary View**: `trade_summary` view for aggregated statistics

## Notes

- The pipeline handles missing values gracefully
- All date columns are converted to proper datetime format
- Units are standardized for consistency
- Categories are assigned based on HSN codes and product descriptions
- The database schema is designed for efficient querying and analysis

