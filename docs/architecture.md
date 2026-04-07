# 🏗️ Architecture Overview

## 📌 Project: Business Insights Engine

This project follows a structured data pipeline to transform raw e-commerce data into actionable business insights.

---

## 🔄 End-to-End Pipeline

Raw CSV Data → Data Cleaning (Python) → Structured Storage (MySQL) → Analysis (SQL) → Visualization (Power BI)



---

## 🧱 Components

### 1. 📥 Data Source
- Dataset: Brazilian E-commerce (Olist)
- Format: CSV files
- Tables:
  - customers
  - orders
  - order_items
  - payments
  - products

---

### 2. 🧹 Data Cleaning (Python - Pandas)
- Removed duplicate records
- Standardized categorical fields (city, state, payment type)
- Converted timestamps to datetime format
- Handled missing values without breaking relationships
- Exported cleaned datasets for database ingestion

---

### 3. 🗄️ Data Storage (MySQL)
- Designed normalized relational schema
- Established relationships using foreign keys:
  - customers → orders
  - orders → order_items
  - orders → payments
  - products → order_items
- Loaded cleaned data using bulk ingestion (`LOAD DATA INFILE`)
- Ensured referential integrity across tables

---

### 4. 📊 Data Analysis (SQL)
Performed analytical queries including:
- Monthly revenue trends
- Top customers by spending
- Product category performance
- Customer segmentation (RFM logic)
- Delivery delay analysis
- Payment method distribution

Used advanced SQL concepts:
- JOINs
- GROUP BY & aggregations
- Window functions (RANK)
- Common Table Expressions (CTEs)

---

### 5. 📈 Visualization (Power BI)
- Connected directly to MySQL database
- Built interactive dashboard with:
  - KPI cards (Revenue, Orders, Customers)
  - Time-series revenue trends
  - Category-wise performance
  - Customer insights
  - Payment distribution
- Implemented DAX measures for dynamic calculations

---

## 🧠 Key Design Decisions

- Used Python for flexible preprocessing
- Used SQL for structured and scalable analysis
- Used Power BI for interactive visualization
- Maintained clean separation between data layers

---

## 🚀 Outcome

A complete data pipeline that:
- Cleans and structures raw data
- Ensures data integrity
- Generates business insights
- Presents findings through an interactive dashboard

