"""
Database loading module for trade data.
Loads cleaned CSV data into MySQL database.
"""

import os
import pandas as pd
from sqlalchemy import create_engine
from dotenv import load_dotenv
from pathlib import Path

load_dotenv()

DB_USER = os.getenv("DB_USER", "root")
DB_PASSWORD = os.getenv("DB_PASSWORD", "")
DB_HOST = os.getenv("DB_HOST", "localhost")
DB_PORT = os.getenv("DB_PORT", "3306")
DB_NAME = os.getenv("DB_NAME", "trade_db")

# Create engine
engine = create_engine(
    f"mysql+pymysql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}",
    echo=False
)


def map_columns(df: pd.DataFrame) -> pd.DataFrame:
    """
    Map CSV column names to database column names.
    Ensures compatibility between CSV and SQL schema.
    Handles duplicate columns by keeping the most appropriate one.
    
    Args:
        df: DataFrame with CSV column names
        
    Returns:
        DataFrame with mapped column names
    """
    df = df.copy()
    
    # Handle duplicate date columns - keep Date_of_Shipment if it exists, otherwise use DATE
    if 'Date_of_Shipment' in df.columns and 'DATE' in df.columns:
        # If both exist, drop DATE and keep Date_of_Shipment
        df = df.drop(columns=['DATE'])
        print("  Note: Both DATE and Date_of_Shipment found. Using Date_of_Shipment.")
    elif 'DATE' in df.columns and 'Date_of_Shipment' not in df.columns:
        # If only DATE exists, rename it
        df = df.rename(columns={'DATE': 'Date_of_Shipment'})
    
    # Column mapping from CSV to database
    column_mapping = {
        'PORT CODE': 'port_code',
        'Date_of_Shipment': 'date_of_shipment',
        'Year': 'year',
        'Month': 'month',
        'Quarter': 'quarter',
        'IEC': 'iec',
        'HS CODE': 'hs_code',
        'GOODS DESCRIPTION': 'goods_description',
        'Master category': 'master_category',
        'Model Name': 'model_name',
        'Model Number': 'model_number',
        'Capacity': 'capacity',
        'Model_Name_Parsed': 'model_name_parsed',
        'Model_Number_Parsed': 'model_number_parsed',
        'Capacity_Parsed': 'capacity_parsed',
        'Material_Type_Parsed': 'material_type_parsed',
        'Embedded_Quantity_Parsed': 'embedded_quantity_parsed',
        'Unit_Price_USD_Parsed': 'unit_price_usd_parsed',
        'Model_Name_Final': 'model_name_final',
        'Model_Number_Final': 'model_number_final',
        'Capacity_Final': 'capacity_final',
        'Qty': 'qty',
        'Unit of measure': 'unit_of_measure',
        'Unit of measure.1': None,  # Drop this duplicate column
        'Price': 'price',
        'QUANTITY': 'quantity',
        'UNIT': 'unit',
        'UNIT PRICE_INR': 'unit_price_inr',
        'TOTAL VALUE_INR': 'total_value_inr',
        'DUTY PAID_INR': 'duty_paid_inr',
        'Grand_Total_INR': 'grand_total_inr',
        'UNIT PRICE_USD': 'unit_price_usd',
        'TOTAL VALUE_USD': 'total_value_usd',
        'Category': 'category',
        'Sub_Category': 'sub_category',
    }
    
    # Drop columns that should be removed (mapped to None)
    columns_to_drop = [k for k, v in column_mapping.items() if v is None and k in df.columns]
    if columns_to_drop:
        df = df.drop(columns=columns_to_drop)
        print(f"  Dropped unmapped columns: {columns_to_drop}")
    
    # Only map columns that exist in the DataFrame and have valid mappings
    existing_mapping = {k: v for k, v in column_mapping.items() if k in df.columns and v is not None}
    
    # Rename columns
    df = df.rename(columns=existing_mapping)
    
    return df


def prepare_dataframe_for_db(df: pd.DataFrame) -> pd.DataFrame:
    """
    Prepare DataFrame for database insertion.
    Handles data type conversions and missing values.
    
    Args:
        df: Input DataFrame
        
    Returns:
        Prepared DataFrame
    """
    # First, check for and remove duplicate column names BEFORE mapping
    if df.columns.duplicated().any():
        print("  Warning: Duplicate column names detected in CSV. Removing duplicates...")
        # Keep first occurrence of each column
        df = df.loc[:, ~df.columns.duplicated(keep='first')]
    
    df = map_columns(df)
    
    # Check again after mapping for any remaining duplicates
    if df.columns.duplicated().any():
        print("  Warning: Duplicate column names after mapping. Removing duplicates...")
        df = df.loc[:, ~df.columns.duplicated(keep='first')]
    
    # Convert date column
    if 'date_of_shipment' in df.columns:
        # Handle case where column might be duplicated (shouldn't happen now, but just in case)
        if isinstance(df['date_of_shipment'], pd.DataFrame):
            df['date_of_shipment'] = df['date_of_shipment'].iloc[:, 0]
        df['date_of_shipment'] = pd.to_datetime(df['date_of_shipment'], errors='coerce')
    
    # Convert numeric columns
    numeric_columns = [
        'year', 'month', 'quarter', 'qty', 'price', 'quantity',
        'unit_price_inr', 'total_value_inr', 'duty_paid_inr', 'grand_total_inr',
        'unit_price_usd', 'total_value_usd', 'embedded_quantity_parsed', 'unit_price_usd_parsed'
    ]
    
    for col in numeric_columns:
        if col in df.columns:
            df[col] = pd.to_numeric(df[col], errors='coerce')
    
    # Fill NaN values appropriately
    # For numeric columns, fill with 0
    for col in numeric_columns:
        if col in df.columns:
            df[col] = df[col].fillna(0)
    
    # For text columns, fill with empty string
    text_columns = [col for col in df.columns if col not in numeric_columns and col != 'date_of_shipment']
    for col in text_columns:
        if col in df.columns:
            df[col] = df[col].fillna('')
    
    return df


def get_table_columns(table_name: str = "trade_data"):
    """
    Get the list of columns that exist in the database table.
    
    Args:
        table_name: Name of the target table
        
    Returns:
        List of column names
    """
    try:
        from sqlalchemy import inspect
        inspector = inspect(engine)
        columns = [col['name'] for col in inspector.get_columns(table_name)]
        return columns
    except Exception as e:
        print(f"  Warning: Could not fetch table columns: {e}")
        return None


def load_dataframe(df: pd.DataFrame, table_name: str = "trade_data", if_exists: str = "append"):
    """
    Load DataFrame into MySQL table.
    
    Args:
        df: DataFrame to load
        table_name: Name of the target table
        if_exists: What to do if table exists ('fail', 'replace', 'append')
    """
    try:
        # Prepare dataframe
        df_prepared = prepare_dataframe_for_db(df)
        print(f"  Prepared {len(df_prepared.columns)} columns for database")
        
        # Get table columns to ensure we only insert valid columns
        table_columns = get_table_columns(table_name)
        if table_columns:
            # Filter to only include columns that exist in the table (excluding id, created_at, updated_at)
            exclude_columns = ['id', 'created_at', 'updated_at']
            valid_table_columns = [col for col in table_columns if col not in exclude_columns]
            valid_columns = [col for col in df_prepared.columns if col in valid_table_columns]
            missing_columns = [col for col in df_prepared.columns if col not in valid_table_columns]
            extra_columns = [col for col in valid_table_columns if col not in df_prepared.columns]
            
            if missing_columns:
                print(f"  Warning: Dropping {len(missing_columns)} columns not in table: {missing_columns[:5]}...")
            if extra_columns:
                print(f"  Note: Table has {len(extra_columns)} columns not in CSV (will use defaults)")
            
            df_prepared = df_prepared[valid_columns]
            print(f"  Inserting {len(valid_columns)} columns into database")
        
        # Load to database
        # Removed method='multi' to avoid parameter naming conflicts
        # Using chunksize for better performance with large datasets
        df_prepared.to_sql(
            table_name,
            engine,
            if_exists=if_exists,
            index=False,
            chunksize=500
        )
        print(f"✓ Successfully loaded {len(df_prepared)} rows into table '{table_name}'.")
    except Exception as e:
        print(f"✗ Error loading data: {e}")
        print(f"  Error type: {type(e).__name__}")
        import traceback
        print(f"  Full error: {traceback.format_exc()}")
        raise


def load_from_csv(csv_file: str, table_name: str = "trade_data", if_exists: str = "append"):
    """
    Load cleaned CSV file into MySQL database.
    
    Args:
        csv_file: Path to cleaned CSV file
        table_name: Name of the target table
        if_exists: What to do if table exists ('fail', 'replace', 'append')
    """
    print(f"Loading data from {csv_file}...")
    
    try:
        # Read CSV
        df = pd.read_csv(csv_file, low_memory=False)
        print(f"✓ Loaded {len(df)} rows from CSV")
        print(f"  CSV has {len(df.columns)} columns")
        
        # Check for duplicate columns in CSV
        if df.columns.duplicated().any():
            dup_cols = df.columns[df.columns.duplicated()].tolist()
            print(f"  Warning: Found duplicate columns in CSV: {dup_cols}")
        
        # Load to database
        load_dataframe(df, table_name, if_exists)
        
    except Exception as e:
        print(f"✗ Error loading from CSV: {e}")
        raise


if __name__ == "__main__":
    import sys
    
    # Default path
    csv_file = "data/processed/trade_cleaned.csv"
    
    if len(sys.argv) > 1:
        csv_file = sys.argv[1]
    
    if not Path(csv_file).exists():
        print(f"✗ Error: File not found: {csv_file}")
        print("Please run the pipeline first to generate the cleaned CSV.")
        sys.exit(1)
    
    print("=" * 60)
    print("Loading Trade Data to MySQL")
    print("=" * 60)
    print(f"Database: {DB_NAME}")
    print(f"Host: {DB_HOST}:{DB_PORT}")
    print(f"CSV File: {csv_file}")
    print("=" * 60)
    
    load_from_csv(csv_file)
    print("\n✓ Data loading completed successfully!")
