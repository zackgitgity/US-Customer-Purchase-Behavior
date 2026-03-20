# 🛍️ US Customer Purchase Behaviour Dashboard

## 📌 Project Overview

This project demonstrates an end-to-end analytics workflow, transforming raw transactional data into a structured data model and interactive Power BI dashboard.

The goal of this project is to analyze customer purchasing behaviour, identify key revenue drivers, and uncover actionable business insights.

---

## 🎯 Objectives

* Understand customer purchasing patterns
* Identify high-value customer segments
* Analyze product and category performance
* Evaluate the impact of discounts, shipping, and payment methods
* Build a clean and scalable data model for reporting

---

## 🧱 Data Model

This project follows a **star schema design**:

### Fact Table

* `fact_purchases`

  * PurchaseID
  * CustomerID
  * ProductID
  * LocationID
  * PaymentMethodID
  * ShippingTypeID
  * SeasonID
  * PurchaseAmountUSD
  * DiscountApplied
  * PromoCodeUsed
  * ReviewRating

### Dimension Tables

* `dim_customer`
* `dim_product`
* `dim_location`
* `dim_payment_method`
* `dim_shipping_type`
* `dim_season`

This structure enables efficient filtering and scalable analytics in Power BI.

---

## ⚙️ Data Engineering Process

### 1. Data Cleaning

* Removed duplicates using PurchaseID
* Standardized categorical values (Yes/No fields)
* Trimmed whitespace and handled null values
* Casted columns to appropriate data types

### 2. Data Transformation

* Created a staging table (`stg_shopping_clean`)
* Normalized data into dimension tables
* Generated surrogate keys for dimensions

### 3. Data Modeling

* Built a star schema
* Established one-to-many relationships from dimensions to fact table
* Ensured proper filter direction for BI usage

---

## 📊 Dashboard Structure

### 🏆 Page 1 — Executive Overview

Provides a high-level summary of business performance.

Key visuals:

* KPI cards (Total Sales, Total Orders, Avg Rating, AOV)
* Sales by Category
* Sales by Shipping Type
* Sales by Season
* Sales by Location (Map)

---

### 👥 Page 2 — Customer Insights

Focuses on customer demographics and behaviour.

Key visuals:

* Frequency vs Sales (Scatter Plot)
* Sales by Gender
* Sales by Age Group
* Customer Distribution by Age
* Subscription Revenue Contribution

---

### 💰 Page 3 — Revenue Drivers

Analyzes factors influencing spending.

Key visuals:

* Discount Impact on Sales and Orders
* Payment Method vs Total Sales
* Payment Method vs Average Order Value
* Shipping Type vs Average Order Value
* Purchase Frequency Distribution

---

### 📦 Page 4 — Product & Quality Analysis

Evaluates product performance and customer satisfaction.

Key visuals:

* Sales vs Rating (Scatter Plot)
* Category vs Average Rating
* Top 10 Products by Sales
* Product Attributes (Color / Size) Performance

---

## 📈 Key Insights

* Subscribers contribute the majority of total revenue
* High-frequency customers drive disproportionate sales
* Certain high-selling products have lower ratings, indicating improvement opportunities
* Shipping type and payment method influence customer spending behaviour

---

## 🛠️ Tools & Technologies

* **Power BI** — Data visualization and dashboarding
* **SQL (T-SQL)** — Data transformation and modeling
* **Data Modeling** — Star schema design

---

## 🚀 How to Use

1. Open the Power BI file (`.pbix`)
2. Use slicers to filter by:

   * Category
   * Gender
   * Season
   * Shipping Type
3. Navigate between pages to explore different insights

---

## 💡 Future Improvements

* Add time-based analysis (date dimension)
* Implement customer segmentation (RFM)
* Build automated data pipeline (Airflow / dbt)
* Deploy dashboard to Power BI Service

---

## ⭐ Notes

This project is designed as a portfolio piece demonstrating both:

* Data engineering fundamentals
* Business-focused analytics and storytelling
