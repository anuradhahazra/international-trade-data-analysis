"""
Main data pipeline script.
Orchestrates data cleaning, parsing, and feature engineering steps.
"""

import pandas as pd
import sys
import os
from pathlib import Path

# Add src to path for imports
sys.path.append(str(Path(__file__).parent))

from cleaning.clean_base import clean_base_data
from parsing.parse_goods_description import parse_goods_description
from feature_engineering.features import engineer_features


def run_pipeline(input_file: str, output_file: str) -> pd.DataFrame:
    """
    Run the complete data pipeline.
    
    Args:
        input_file: Path to raw CSV file
        output_file: Path to save cleaned CSV file
        
    Returns:
        Final cleaned DataFrame
    """
    print("=" * 60)
    print("Starting Trade Data Pipeline")
    print("=" * 60)
    
    # Step 1: Load raw data
    print("\n[Step 1] Loading raw data...")
    try:
        df = pd.read_csv(input_file, low_memory=False)
        print(f"✓ Loaded {len(df)} rows from {input_file}")
    except Exception as e:
        print(f"✗ Error loading data: {e}")
        raise
    
    # Step 2: Basic cleaning
    print("\n[Step 2] Performing basic cleaning...")
    try:
        df = clean_base_data(df)
        print(f"✓ Basic cleaning completed. Rows: {len(df)}")
    except Exception as e:
        print(f"✗ Error in basic cleaning: {e}")
        raise
    
    # Step 3: Parse goods description
    print("\n[Step 3] Parsing goods description...")
    try:
        df = parse_goods_description(df)
        print(f"✓ Goods description parsing completed")
    except Exception as e:
        print(f"✗ Error parsing goods description: {e}")
        raise
    
    # Step 4: Feature engineering
    print("\n[Step 4] Engineering features...")
    try:
        df = engineer_features(df)
        print(f"✓ Feature engineering completed")
    except Exception as e:
        print(f"✗ Error in feature engineering: {e}")
        raise
    
    # Step 5: Save cleaned data
    print("\n[Step 5] Saving cleaned data...")
    try:
        # Ensure output directory exists
        output_path = Path(output_file)
        output_path.parent.mkdir(parents=True, exist_ok=True)
        
        df.to_csv(output_file, index=False)
        print(f"✓ Saved {len(df)} rows to {output_file}")
    except Exception as e:
        print(f"✗ Error saving data: {e}")
        raise
    
    # Summary
    print("\n" + "=" * 60)
    print("Pipeline Summary")
    print("=" * 60)
    print(f"Total rows processed: {len(df)}")
    print(f"Columns in output: {len(df.columns)}")
    print(f"Output file: {output_file}")
    print("=" * 60)
    
    return df


if __name__ == "__main__":
    # Default paths
    input_file = "data/raw/import_data_2017_2025.csv"
    output_file = "data/processed/trade_cleaned_new.csv"
    
    # Allow command line arguments
    if len(sys.argv) > 1:
        input_file = sys.argv[1]
    if len(sys.argv) > 2:
        output_file = sys.argv[2]
    
    # Run pipeline
    df = run_pipeline(input_file, output_file)
    print("\n✓ Pipeline completed successfully!")

