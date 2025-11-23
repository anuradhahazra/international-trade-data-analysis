"""
Basic data cleaning module for trade data.
Handles date conversion, missing values, and unit standardization.
"""

import pandas as pd
import numpy as np
from datetime import datetime


def clean_base_data(df: pd.DataFrame) -> pd.DataFrame:
    """
    Perform basic cleaning operations on trade data.
    
    Args:
        df: Raw trade data DataFrame
        
    Returns:
        Cleaned DataFrame
    """
    df = df.copy()
    
    # Convert Date of Shipment to datetime
    # The column is named 'DATE' in the CSV
    date_column = 'DATE'
    if date_column in df.columns:
        df[date_column] = pd.to_datetime(df[date_column], errors='coerce')
        
        # Derive Year, Month, Quarter
        df['Year'] = df[date_column].dt.year
        df['Month'] = df[date_column].dt.month
        df['Quarter'] = df[date_column].dt.quarter
        df['Date_of_Shipment'] = df[date_column]  # Rename for clarity
    else:
        # Try alternative column names
        for col in ['Date of Shipment', 'Date', 'DATE']:
            if col in df.columns:
                df[col] = pd.to_datetime(df[col], errors='coerce')
                df['Year'] = df[col].dt.year
                df['Month'] = df[col].dt.month
                df['Quarter'] = df[col].dt.quarter
                df['Date_of_Shipment'] = df[col]
                break
    
    # Handle missing values in Total Value (INR)
    total_value_col = 'TOTAL VALUE_INR'
    if total_value_col in df.columns:
        # Fill missing values with 0 or forward fill based on context
        df[total_value_col] = pd.to_numeric(df[total_value_col], errors='coerce')
        df[total_value_col] = df[total_value_col].fillna(0)
    
    # Handle missing values in Duty Paid (INR)
    duty_paid_col = 'DUTY PAID_INR'
    if duty_paid_col in df.columns:
        df[duty_paid_col] = pd.to_numeric(df[duty_paid_col], errors='coerce')
        df[duty_paid_col] = df[duty_paid_col].fillna(0)
    
    # Handle missing values in Quantity
    quantity_col = 'QUANTITY'
    if quantity_col in df.columns:
        df[quantity_col] = pd.to_numeric(df[quantity_col], errors='coerce')
        # Fill with 0 or median based on business logic
        df[quantity_col] = df[quantity_col].fillna(0)
    
    # Standardize units (pcs, nos, pieces → pcs)
    unit_col = 'UNIT'
    if unit_col in df.columns:
        df[unit_col] = df[unit_col].astype(str).str.lower().str.strip()
        # Standardize unit names
        unit_mapping = {
            'nos': 'pcs',
            'pieces': 'pcs',
            'piece': 'pcs',
            'pc': 'pcs',
            'pcs': 'pcs',
            'set': 'set',
            'sets': 'set',
            'kgs': 'kgs',
            'kg': 'kgs',
            'kilograms': 'kgs'
        }
        df[unit_col] = df[unit_col].map(unit_mapping).fillna(df[unit_col])
    
    # Also standardize 'Unit of measure' column if it exists
    unit_measure_col = 'Unit of measure'
    if unit_measure_col in df.columns:
        df[unit_measure_col] = df[unit_measure_col].astype(str).str.lower().str.strip()
        unit_mapping = {
            'nos': 'pcs',
            'pieces': 'pcs',
            'piece': 'pcs',
            'pc': 'pcs',
            'pcs': 'pcs',
            'set': 'set',
            'sets': 'set',
            'kgs': 'kgs',
            'kg': 'kgs',
            'kilograms': 'kgs'
        }
        df[unit_measure_col] = df[unit_measure_col].map(unit_mapping).fillna(df[unit_measure_col])
    
    return df

