#!/bin/bash
# Script to run all SQL view creation files
# Usage: ./run_all_views.sh [mysql_user] [mysql_password] [database_name]

DB_USER=${1:-root}
DB_PASS=${2:-}
DB_NAME=${3:-trade_db}

if [ -z "$DB_PASS" ]; then
    echo "Usage: $0 [mysql_user] [mysql_password] [database_name]"
    echo "Or set MYSQL_PWD environment variable"
    exit 1
fi

export MYSQL_PWD=$DB_PASS

echo "Creating all analysis views..."
echo "Database: $DB_NAME"
echo "User: $DB_USER"
echo ""

# Run each SQL file
for sql_file in 01_macro_growth_trends.sql 02_pareto_analysis.sql 03_supplier_analysis.sql 04_powerbi_tableau_export.sql; do
    if [ -f "$sql_file" ]; then
        echo "Running $sql_file..."
        mysql -u "$DB_USER" "$DB_NAME" < "$sql_file"
        if [ $? -eq 0 ]; then
            echo "✓ $sql_file completed successfully"
        else
            echo "✗ Error running $sql_file"
        fi
        echo ""
    else
        echo "Warning: $sql_file not found"
    fi
done

echo "All views created!"
echo ""
echo "Verifying views..."
mysql -u "$DB_USER" "$DB_NAME" -e "SHOW FULL TABLES WHERE TABLE_TYPE = 'VIEW';"

