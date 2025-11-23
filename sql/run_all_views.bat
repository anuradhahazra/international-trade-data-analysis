@echo off
REM Script to run all SQL view creation files on Windows
REM Usage: run_all_views.bat [mysql_user] [mysql_password] [database_name]

set DB_USER=%1
set DB_PASS=%2
set DB_NAME=%3

if "%DB_USER%"=="" set DB_USER=root
if "%DB_NAME%"=="" set DB_NAME=trade_db

echo Creating all analysis views...
echo Database: %DB_NAME%
echo User: %DB_USER%
echo.

REM Run each SQL file
for %%f in (01_macro_growth_trends.sql 02_pareto_analysis.sql 03_supplier_analysis.sql 04_powerbi_tableau_export.sql) do (
    if exist "%%f" (
        echo Running %%f...
        mysql -u %DB_USER% -p%DB_PASS% %DB_NAME% < %%f
        if errorlevel 1 (
            echo Error running %%f
        ) else (
            echo ✓ %%f completed successfully
        )
        echo.
    ) else (
        echo Warning: %%f not found
    )
)

echo All views created!
echo.
echo Verifying views...
mysql -u %DB_USER% -p%DB_PASS% %DB_NAME% -e "SHOW FULL TABLES WHERE TABLE_TYPE = 'VIEW';"

