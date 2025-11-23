"""
Feature engineering module for trade data.
Calculates derived features like Grand Total, Category, Sub-Category.
"""

import pandas as pd
import numpy as np
from typing import Dict, Optional


def calculate_grand_total(df: pd.DataFrame) -> pd.DataFrame:
    """
    Calculate Grand Total = Total Value (INR) + Duty Paid (INR).
    
    Args:
        df: DataFrame with TOTAL VALUE_INR and DUTY PAID_INR columns
        
    Returns:
        DataFrame with Grand_Total_INR column
    """
    df = df.copy()
    
    total_value_col = 'TOTAL VALUE_INR'
    duty_paid_col = 'DUTY PAID_INR'
    
    # Ensure numeric types
    if total_value_col in df.columns:
        df[total_value_col] = pd.to_numeric(df[total_value_col], errors='coerce').fillna(0)
    else:
        df[total_value_col] = 0
    
    if duty_paid_col in df.columns:
        df[duty_paid_col] = pd.to_numeric(df[duty_paid_col], errors='coerce').fillna(0)
    else:
        df[duty_paid_col] = 0
    
    # Calculate Grand Total
    df['Grand_Total_INR'] = df[total_value_col] + df[duty_paid_col]
    
    return df


def assign_category_from_hsn(hsn_code: str) -> Optional[str]:
    """
    Assign category based on HSN code.
    HSN codes are standardized international trade classification codes.
    
    Args:
        hsn_code: HSN code string
        
    Returns:
        Category name or None
    """
    if pd.isna(hsn_code) or not hsn_code:
        return None
    
    hsn_str = str(hsn_code).strip()
    
    # HSN code mapping to categories
    # 7323 - Table, kitchen or other household articles and parts thereof, of iron or steel
    # 7324 - Sanitary ware and parts thereof, of iron or steel
    # 7325 - Other cast articles of iron or steel
    # 7326 - Other articles of iron or steel
    
    hsn_prefix = hsn_str[:4] if len(hsn_str) >= 4 else hsn_str
    
    category_mapping = {
        '7323': 'Household Articles',
        '7324': 'Sanitary Ware',
        '7325': 'Cast Articles',
        '7326': 'Other Iron Steel Articles',
        '7321': 'Space Heating Apparatus',
        '7322': 'Other Domestic Articles',
    }
    
    return category_mapping.get(hsn_prefix, 'Other')


def assign_subcategory_from_description(description: str, hsn_code: str) -> Optional[str]:
    """
    Assign sub-category based on Goods Description and HSN code.
    
    Args:
        description: Goods description string
        hsn_code: HSN code string
        
    Returns:
        Sub-category name or None
    """
    if pd.isna(description) or not description:
        return None
    
    desc_upper = str(description).upper()
    
    # Sub-category mapping based on keywords
    subcategory_keywords = {
        'CUTLERY': 'Cutlery & Utensils',
        'HOLDER': 'Holders & Stands',
        'SCRUBBER': 'Cleaning Tools',
        'STRAINER': 'Strainers & Filters',
        'BASKET': 'Baskets & Containers',
        'HANGER': 'Hangers & Hooks',
        'DRAINER': 'Drainers & Racks',
        'SPRINKLER': 'Sprinklers & Sprayers',
        'BOTTLE': 'Bottles & Containers',
        'BLENDER': 'Kitchen Appliances',
        'HOOK': 'Hooks & Hangers',
        'STAND': 'Stands & Racks',
        'CLOTH': 'Clothing Accessories',
    }
    
    for keyword, subcategory in subcategory_keywords.items():
        if keyword in desc_upper:
            return subcategory
    
    # Default subcategory based on HSN
    hsn_str = str(hsn_code).strip() if not pd.isna(hsn_code) else ''
    if hsn_str.startswith('7323'):
        return 'General Household Items'
    
    return 'Other'


def assign_categories(df: pd.DataFrame) -> pd.DataFrame:
    """
    Assign Category and Sub-Category based on HSN Code and Goods Description.
    
    Args:
        df: DataFrame with HS CODE and GOODS DESCRIPTION columns
        
    Returns:
        DataFrame with Category and Sub_Category columns
    """
    df = df.copy()
    
    hsn_col = 'HS CODE'
    desc_col = 'GOODS DESCRIPTION'
    
    # Try alternative column names
    if hsn_col not in df.columns:
        for col in ['HS CODE', 'HSN Code', 'HSN_CODE', 'HS_CODE']:
            if col in df.columns:
                hsn_col = col
                break
    
    if desc_col not in df.columns:
        for col in ['GOODS DESCRIPTION', 'Goods Description', 'Description']:
            if col in df.columns:
                desc_col = col
                break
    
    # Assign categories
    df['Category'] = df[hsn_col].apply(assign_category_from_hsn)
    
    # Assign sub-categories
    df['Sub_Category'] = df.apply(
        lambda row: assign_subcategory_from_description(
            row.get(desc_col, ''),
            row.get(hsn_col, '')
        ),
        axis=1
    )
    
    # Fill missing categories
    df['Category'] = df['Category'].fillna('Other')
    df['Sub_Category'] = df['Sub_Category'].fillna('Other')
    
    return df


def engineer_features(df: pd.DataFrame) -> pd.DataFrame:
    """
    Main function to engineer all features.
    
    Args:
        df: Input DataFrame
        
    Returns:
        DataFrame with engineered features
    """
    df = calculate_grand_total(df)
    df = assign_categories(df)
    
    return df

