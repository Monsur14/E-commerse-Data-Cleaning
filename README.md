# E-commerse-Data-Cleaning

This project demonstrates end-to-end data cleaning and exploratory analysis of an e-commerce transactions dataset. Starting from messy raw data, I cleaned and standardized the dataset using SQL, then performed exploratory data analysis (EDA) to uncover key business insights. The cleaned dataset is analysis-ready and can be used for visualization in Tableau.

EcommerseRaw.csv → Original raw dataset.

EcommerseCleaned.csv → Cleaned and standardized dataset.

CleaningEcommerse.sql → SQL script for step-by-step data cleaning.

EDAEcommerse.sql → SQL queries for exploratory data analysis.

Data cleaning steps:
Removed duplicates.

Standardized Transaction IDs (e.g., T12345).

Fixed inconsistent date formats to YYYY-MM-DD.

Cleaned Product Numbers (digits only).

Normalized Prices:

Removed currency symbols

Converted "Free" → 0.00

Mapped currencies by country

Standardized Quantities (converted words to numbers, removed negatives/decimals).

Unified Country names (e.g., UK, England → United Kingdom).

Applied appropriate data types (DATE, DECIMAL, INT, etc.).

EDA steps:
Total revenue, transactions, products, and customers.

Top 10 products by revenue and by quantity.

Revenue by country and top 5 countries by orders.

Monthly and yearly revenue trends.

Customer insights → top customers, repeat vs. new customers.

Currency distribution across transactions.
