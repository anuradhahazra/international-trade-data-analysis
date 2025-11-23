"""
Parse Goods Description to extract structured information.
Extracts Model Name, Model Number, Capacity, Material Type, Embedded Quantity, Unit Price USD.
"""

import pandas as pd
import re
from typing import Dict, Optional


def extract_model_name(description: str) -> Optional[str]:
    """
    Extract model name from goods description.
    Model names are often in format like "TH5170", "AM-967", "SB-12", etc.
    """
    if pd.isna(description) or not description:
        return None
    
    description = str(description).upper()
    
    # Pattern: Alphanumeric codes like TH5170, AM-967, SB-12, NP-55, etc.
    patterns = [
        r'\b([A-Z]{1,3}[-]?\d{1,5})\b',  # Pattern like AM-967, SB-12
        r'\(([A-Z]{1,3}[-]?\d{1,5})\)',  # Pattern in parentheses
        r'MODEL[:\s]+([A-Z]{1,3}[-]?\d{1,5})',  # Explicit MODEL: prefix
    ]
    
    for pattern in patterns:
        match = re.search(pattern, description)
        if match:
            return match.group(1).strip()
    
    return None


def extract_model_number(description: str) -> Optional[str]:
    """
    Extract model number from goods description.
    Often found in parentheses or after model name.
    """
    if pd.isna(description) or not description:
        return None
    
    description = str(description)
    
    # Look for patterns like (RYX-02-020), (2628), (3888)
    patterns = [
        r'\(([A-Z]{2,4}[-]?\d{1,3}[-]?\d{1,3})\)',  # Pattern like RYX-02-020
        r'\((\d{3,6})\)',  # Pattern like (2628), (3888)
        r'MODEL\s+NO[:\s]+([A-Z0-9-]+)',  # Explicit MODEL NO: prefix
    ]
    
    for pattern in patterns:
        match = re.search(pattern, description)
        if match:
            return match.group(1).strip()
    
    return None


def extract_capacity(description: str) -> Optional[str]:
    """
    Extract capacity information from goods description.
    """
    if pd.isna(description) or not description:
        return None
    
    description = str(description).upper()
    
    # Look for capacity patterns like "10PCS SET", "6PCS SET", "2PCS SET"
    patterns = [
        r'(\d+)\s*PCS?\s*SET',
        r'CAPACITY[:\s]+([\d.]+)',
        r'(\d+)\s*L',
        r'(\d+)\s*ML',
    ]
    
    for pattern in patterns:
        match = re.search(pattern, description)
        if match:
            return match.group(1).strip()
    
    return None


def extract_material_type(description: str) -> Optional[str]:
    """
    Extract material type from goods description.
    """
    if pd.isna(description) or not description:
        return None
    
    description = str(description).upper()
    
    # Common materials
    materials = ['STEEL', 'MILD STEEL', 'STAINLESS STEEL', 'ALUMINUM', 
                 'PLASTIC', 'WOOD', 'GLASS', 'CERAMIC', 'BRASS', 'COPPER']
    
    for material in materials:
        if material in description:
            return material.replace('MILD STEEL', 'MILD_STEEL').replace('STAINLESS STEEL', 'STAINLESS_STEEL')
    
    return None


def extract_embedded_quantity(description: str) -> Optional[float]:
    """
    Extract quantity embedded in goods description.
    Pattern: QTY: 600 PCS, QTY:336000 SETS, etc.
    """
    if pd.isna(description) or not description:
        return None
    
    description = str(description).upper()
    
    # Pattern: QTY: 600 PCS, QTY:336000 SETS, QTY 6336 PCS
    patterns = [
        r'QTY[:\s]+([\d,]+)\s*(?:PCS?|SETS?|NOS?|KGS?|KG)',
        r'QUANTITY[:\s]+([\d,]+)',
    ]
    
    for pattern in patterns:
        match = re.search(pattern, description)
        if match:
            qty_str = match.group(1).replace(',', '').strip()
            try:
                return float(qty_str)
            except ValueError:
                return None
    
    return None


def extract_unit_price_usd(description: str) -> Optional[float]:
    """
    Extract unit price in USD from goods description.
    Pattern: USD 2.03 PER PCS, USD 0.139 PER SETS, etc.
    """
    if pd.isna(description) or not description:
        return None
    
    description = str(description).upper()
    
    # Pattern: USD 2.03 PER PCS, USD:0.139 PER SETS, USD 0.9718 PER PCS
    patterns = [
        r'USD[:\s]+([\d.]+)\s*PER\s*(?:PCS?|SETS?|NOS?|KGS?|KG)',
        r'USD\s+([\d.]+)\s*PER',
        r'\$([\d.]+)\s*PER',
    ]
    
    for pattern in patterns:
        match = re.search(pattern, description)
        if match:
            try:
                return float(match.group(1).strip())
            except ValueError:
                return None
    
    return None


def parse_goods_description(df: pd.DataFrame) -> pd.DataFrame:
    """
    Parse Goods Description column and extract structured fields.
    
    Args:
        df: DataFrame with 'GOODS DESCRIPTION' column
        
    Returns:
        DataFrame with additional parsed columns
    """
    df = df.copy()
    
    desc_col = 'GOODS DESCRIPTION'
    if desc_col not in df.columns:
        # Try alternative column names
        for col in ['Goods Description', 'GOODS DESCRIPTION', 'Description']:
            if col in df.columns:
                desc_col = col
                break
        else:
            print("Warning: Goods Description column not found")
            return df
    
    # Extract information
    df['Model_Name_Parsed'] = df[desc_col].apply(extract_model_name)
    df['Model_Number_Parsed'] = df[desc_col].apply(extract_model_number)
    df['Capacity_Parsed'] = df[desc_col].apply(extract_capacity)
    df['Material_Type_Parsed'] = df[desc_col].apply(extract_material_type)
    df['Embedded_Quantity_Parsed'] = df[desc_col].apply(extract_embedded_quantity)
    df['Unit_Price_USD_Parsed'] = df[desc_col].apply(extract_unit_price_usd)
    
    # Use existing columns if parsed values are missing
    if 'Model Name' in df.columns:
        df['Model_Name_Final'] = df['Model_Name_Parsed'].fillna(df['Model Name'])
    else:
        df['Model_Name_Final'] = df['Model_Name_Parsed']
    
    if 'Model Number' in df.columns:
        df['Model_Number_Final'] = df['Model_Number_Parsed'].fillna(df['Model Number'])
    else:
        df['Model_Number_Final'] = df['Model_Number_Parsed']
    
    if 'Capacity' in df.columns:
        df['Capacity_Final'] = df['Capacity_Parsed'].fillna(df['Capacity'])
    else:
        df['Capacity_Final'] = df['Capacity_Parsed']
    
    return df

