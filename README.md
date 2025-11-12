# 📦 Inventory Control System

> A full-stack multi-store inventory management system with MySQL database backend and C# console application frontend

[![.NET Version](https://img.shields.io/badge/.NET-9.0-purple.svg)](https://dotnet.microsoft.com/)
[![MySQL](https://img.shields.io/badge/MySQL-8.0+-blue.svg)](https://www.mysql.com/)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

## 🌟 Overview

This comprehensive inventory management system enables real-time tracking and analysis of inventory data across multiple store locations. Built with a robust MySQL database backend and an interactive C# console application, it provides powerful reporting and filtering capabilities for efficient inventory control.

## 🌟 Overview

This comprehensive inventory management system enables real-time tracking and analysis of inventory data across multiple store locations. Built with a robust MySQL database backend and an interactive C# console application, it provides powerful reporting and filtering capabilities for efficient inventory control.

### ✨ Key Features

#### 📊 **Database Capabilities**
- **Multi-store inventory tracking** with real-time stock levels across 5+ locations
- **Product catalog management** with 20+ products across 10 categories
- **Sales tracking & trend analysis** with transaction history
- **Low stock alerts** with automated reorder recommendations
- **Supplier relationship management** with performance tracking
- **Delivery performance monitoring** with lead time analysis

#### 💻 **C# Console Application**
- **Interactive menu system** with 9 comprehensive report types
- **Advanced filtering options** by store, category, product, and date range
- **Color-coded output** for enhanced readability
- **Real-time database connectivity** with async operations
- **Low-stock product alerts** with supplier information
- **Top-performing supplier rankings** with multiple criteria
- **Delayed delivery analysis** for supplier performance tracking

---

## 📋 Table of Contents

- [System Architecture](#-system-architecture)
- [Database Schema](#️-database-schema)
- [Quick Start Guide](#-quick-start-guide)
- [C# Application Guide](#-c-application-guide)
- [Reports & Features](#-reports--features)
- [Query Examples](#-query-examples)
- [Project Structure](#-project-structure)
- [Troubleshooting](#-troubleshooting)
- [Future Enhancements](#-future-enhancements)

---

## 🏗️ System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                  C# Console Application                     │
│  ┌────────────┐ ┌────────────┐ ┌────────────┐             │
│  │  Reports   │ │  Filters   │ │   Alerts   │             │
│  └────────────┘ └────────────┘ └────────────┘             │
└────────────────────────┬────────────────────────────────────┘
                         │ MySqlConnector 2.3.7
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                    MySQL Database 8.0+                      │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐      │
│  │  Stores  │ │ Products │ │Inventory │ │  Sales   │      │
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘      │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐                   │
│  │Categories│ │Suppliers │ │Deliveries│                   │
│  └──────────┘ └──────────┘ └──────────┘                   │
└─────────────────────────────────────────────────────────────┘
```

---

---

## 🗂️ Database Schema

### Core Tables (7 Tables)

#### 1️⃣ **Stores** - Physical store locations
- Store details (name, address, contact info, manager)
- **Sample Data:** 5 stores across different cities (New York, Los Angeles, Chicago, Houston, Miami)
- **Key Fields:** StoreID, StoreName, Address, City, State, ZipCode, Phone, Email, ManagerName

#### 2️⃣ **Categories** - Product categorization system
- **Sample Data:** 10 categories (Electronics, Clothing, Home & Garden, Sports, Books, Office Supplies, Health & Beauty, Media, Toys & Games, Automotive)
- **Key Fields:** CategoryID, CategoryName, Description

#### 3️⃣ **Suppliers** - Vendor information & ratings
- Contact details, ratings, and location
- **Sample Data:** 8 suppliers with specialties and ratings (4.20-4.90/5.00)
- **Key Fields:** SupplierID, SupplierName, ContactName, Email, Phone, Address, City, Country, Rating

#### 4️⃣ **Products** - Complete product catalog
- Product details (name, SKU, price, description)
- Links to categories and suppliers
- Active/inactive status with reorder levels
- **Sample Data:** 21+ products across various categories
- **Key Fields:** ProductID, ProductName, SKU, CategoryID, SupplierID, UnitPrice, ReorderLevel, IsActive

#### 5️⃣ **Inventory** - Store-specific stock levels
- Quantity on hand, reserved, and available (computed)
- Minimum/maximum stock levels
- Last restocked timestamp
- **Sample Data:** 35+ inventory records
- **Key Fields:** InventoryID, StoreID, ProductID, QuantityOnHand, QuantityReserved, QuantityAvailable, MinStockLevel, MaxStockLevel
- **Computed Column:** `QuantityAvailable = QuantityOnHand - QuantityReserved`

#### 6️⃣ **ProductDeliveries** - Supplier delivery tracking
- Tracks product deliveries from suppliers to stores
- **OrderDate** and **DeliveryDate** for lead time analysis
- Delivery status (Pending, Delivered, Partial, Cancelled)
- Cost tracking per delivery
- **Sample Data:** 50+ delivery records with realistic lead times (3-7 days)
- **Key Fields:** DeliveryID, SupplierID, ProductID, StoreID, QuantityDelivered, UnitCost, TotalCost, OrderDate, DeliveryDate, DeliveryStatus
- **Computed Column:** `TotalCost = QuantityDelivered * UnitCost`

#### 7️⃣ **Sales** - Transaction records
- Sale details, pricing, and transaction tracking
- **Sample Data:** 29+ sales transactions
- **Key Fields:** SaleID, StoreID, ProductID, QuantitySold, SalePrice, SaleDate, TransactionID
- **Computed Column:** `TotalAmount = QuantitySold * SalePrice`

### 🔗 Entity Relationships

```
                    ┌──────────────┐
                    │   Suppliers  │
                    └──────┬───────┘
                           │
                           │ (1:M)
                           │
    ┌──────────┐    ┌─────▼──────┐    ┌──────────────┐
    │Categories├────►  Products  ◄────┤ProductDeliv. │
    └──────────┘    └─────┬──────┘    └──────┬───────┘
        (1:M)             │ (1:M)            │ (M:1)
                          │                   │
                    ┌─────▼──────┐    ┌──────▼───────┐
                    │ Inventory  │    │    Stores    │
                    └─────┬──────┘    └──────┬───────┘
                          │ (M:1)            │ (1:M)
                          │                   │
                          └─────────┬─────────┘
                                    │
                              ┌─────▼──────┐
                              │   Sales    │
                              └────────────┘
```

### 📐 Database Views (3 Views)

1. **vw_ProductDetails** - Complete product information with category and supplier details
2. **vw_InventoryStatus** - Real-time inventory status with stock level indicators (Out of Stock, Low Stock, In Stock, Overstocked)
3. **vw_SalesTrends** - Sales data aggregated with product and store information

### ⚙️ Stored Procedures (2 Procedures)

1. **sp_GetProductsByCategory** - Filter products by category with optional availability filter
   ```sql
   CALL sp_GetProductsByCategory(1, TRUE);  -- Electronics, in stock only
   ```

2. **sp_GetLowStockAlerts** - Get products below minimum stock levels, optionally filtered by store
   ```sql
   CALL sp_GetLowStockAlerts(NULL);  -- All stores
   CALL sp_GetLowStockAlerts(1);     -- Specific store
   ```

### 🔍 Database Indexes

Optimized indexes for performance:
- **Products:** ProductName, SKU, CategoryID, SupplierID
- **Inventory:** StoreID, ProductID, QuantityOnHand
- **Sales:** SaleDate, StoreID, ProductID, TransactionID
- **Suppliers:** SupplierName, Rating
- **ProductDeliveries:** SupplierID, ProductID, StoreID, DeliveryDate, OrderDate, DeliveryStatus

---

---

## 🚀 Quick Start Guide

### Prerequisites

- **MySQL:** 8.0 or higher
- **.NET SDK:** 9.0 or higher
- **MySQL Client:** MySQL Workbench, command line client, or similar
- **Git:** (optional) for cloning the repository

### 📦 Installation Steps

#### Step 1: Clone or Download the Repository

```bash
git clone https://github.com/elisaschroeder/InventoryControlSystem.git
cd InventoryControlSystem
```

#### Step 2: Database Setup

**Option A: Using MySQL Command Line**

```bash
# Connect to MySQL
mysql -u root -p

# Create the database
CREATE DATABASE InventoryControlDB;
USE InventoryControlDB;

# Run the schema script
source database_schema.sql;

# Load sample data
source sample_data.sql;

# Verify installation
SHOW TABLES;
SELECT COUNT(*) FROM Products;
```

**Option B: Using MySQL Workbench**

1. Open MySQL Workbench
2. Connect to your MySQL server
3. File → Run SQL Script
4. Select `database_schema.sql`
5. Repeat for `sample_data.sql`

**Option C: Windows PowerShell/Command Prompt**

```powershell
# Navigate to project directory
cd "C:\path\to\InventoryControlSystem"

# Run schema
mysql -u root -p < database_schema.sql

# Load sample data
mysql -u root -p < sample_data.sql
```

#### Step 3: Configure C# Application

Open `Program.cs` and update the connection string (line 7):

```csharp
private static string connectionString = 
    "Server=localhost;Port=3306;Database=InventoryControlDB;User=root;Password=YOUR_PASSWORD;";
```

**Update these values:**
- `localhost` → Your MySQL server address
- `3306` → Your MySQL port (default is 3306)
- `root` → Your MySQL username
- `YOUR_PASSWORD` → Your MySQL password

#### Step 4: Restore NuGet Packages

```bash
dotnet restore
```

#### Step 5: Build the Application

```bash
dotnet build
```

#### Step 6: Run the Application

```bash
dotnet run
```

### ✅ Verify Installation

You should see the main menu:

```
╔════════════════════════════════════════════════════════════╗
║        INVENTORY CONTROL SYSTEM - REPORTING PORTAL        ║
╚════════════════════════════════════════════════════════════╝

┌────────────────────────────────────────────────────────────┐
│                      MAIN MENU                             │
└────────────────────────────────────────────────────────────┘

  1. 🏢 Stores Report
  2. 📦 Categories Report
  3. 🚚 Suppliers Report
  4. 🛍️  Products Report (with filtering)
  5. 📊 Inventory Report (with filtering)
  6. 💰 Sales Report (with filtering)
  7. ⚠️  Low-Stock Products Report
  8. 🏆 Top-Performing Suppliers
  9. 🚪 Exit

Enter your choice (1-9): 
```

---

---

## � C# Application Guide

### Application Features

The console application provides **9 comprehensive report types** with advanced filtering capabilities:

#### 1️⃣ **Stores Report**
- View all stores with complete details
- Inventory statistics per store
- Total unique products and inventory units
- Manager and contact information

**Sample Output:**
```
Store: Downtown Store
Location: 123 Main St, New York, NY 10001
Manager: John Smith
Products: 18 unique items
Total Inventory: 532 units
```

#### 2️⃣ **Categories Report**
- All product categories with descriptions
- Product count per category
- Total stock levels by category

**Sample Output:**
```
Category: Electronics
Description: Electronic devices and accessories
Products: 4
Total Stock: 285 units
```

#### 3️⃣ **Suppliers Report**
- Complete supplier directory
- Contact information and ratings
- Location details

**Sample Output:**
```
Supplier: TechWorld Distributors
Contact: David Kim
Rating: 4.50/5.00 ⭐⭐⭐⭐
Location: San Francisco, USA
Email: david@techworld.com
Phone: 555-1001
```

#### 4️⃣ **Products Report** (with Filtering)
Filter products by:
- **All Products** - Complete product catalog
- **By Store** - Products available at specific location
- **By Category** - Products in selected category

**Features:**
- Product details (name, SKU, price, description)
- Category and supplier information
- Active/inactive status
- Reorder levels

**Sample Output:**
```
Product: Wireless Bluetooth Headphones
SKU: ELEC-001
Category: Electronics
Supplier: TechWorld Distributors
Price: $79.99
Reorder Level: 15 units
Status: Active
```

#### 5️⃣ **Inventory Report** (with Filtering)
Filter inventory by:
- **All Inventory** - Overview (limited to 50 records)
- **By Store** - Stock at specific location
- **By Category** - Stock for category products
- **By Product ID** - Track specific product across stores

**Stock Status Indicators:**
- 🔴 **Out of Stock** - QuantityAvailable = 0
- 🟡 **Low Stock** - Below minimum stock level
- 🟢 **In Stock** - Normal stock levels
- 🔵 **Overstocked** - Above maximum stock level

**Sample Output:**
```
Store: Downtown Store (New York)
Product: Wireless Bluetooth Headphones
SKU: ELEC-001
Category: Electronics
On Hand: 45 units
Reserved: 5 units
Available: 40 units
Minimum Stock: 15 units
Maximum Stock: 100 units
Status: 🟢 In Stock
Last Restocked: 2025-11-01
```

#### 6️⃣ **Sales Report** (with Filtering)
Filter sales by:
- **All Sales** - Recent transactions (last 30)
- **By Product** - Sales history for specific product
- **By Store** - Sales at specific location
- **By Date Range** - Custom date range (format: yyyy-MM-dd)

**Features:**
- Transaction details and pricing
- Quantity sold and total amount
- Date and transaction ID
- Sales summary with totals

**Sample Output:**
```
Sale ID: 12
Date: 2025-11-10 16:00:00
Store: Northgate Mall
Product: Running Shoes (CLTH-004)
Category: Clothing
Quantity Sold: 2
Sale Price: $89.99
Total Amount: $179.98
Transaction ID: TXN-20251110-003
────────────────────────────────────────
SALES SUMMARY:
Total Units Sold: 15
Total Revenue: $1,247.85
```

#### 7️⃣ **Low-Stock Products Report**
Comprehensive low-stock alert system with **4 filtering options**:

1. **All Low-Stock Products** - System-wide alerts
2. **By Store** - Low-stock items at specific location
3. **By Category** - Low-stock items in category
4. **By Store AND Category** - Combined filtering

**Features:**
- Products below minimum stock threshold
- Current vs. required stock levels
- Supplier contact information for reordering
- Recommended reorder quantities

**Sample Output:**
```
⚠️  LOW STOCK ALERT

Product: USB-C Charging Cable
SKU: ELEC-003
Category: Electronics
Store: Downtown Store

Current Stock: 8 units
Minimum Required: 20 units
🚨 Shortage: 12 units

Supplier: TechWorld Distributors
Contact: David Kim
Email: david@techworld.com
Phone: 555-1001
Supplier Rating: 4.50/5.00 ⭐⭐⭐⭐

Recommended Action: Reorder immediately
```

#### 8️⃣ **Top-Performing Suppliers Report**
Rank suppliers by **4 different criteria**:

1. **Total Stock Delivered (All-Time)**
   - Suppliers ranked by total units delivered
   - Shows product count, deliveries, and total value
   - Top 10 suppliers

2. **Number of Products Supplied**
   - Suppliers with most diverse product offerings
   - Product variety and stock levels
   - Top 10 suppliers

3. **Supplier Rating**
   - Highest-rated suppliers (5.00 to 1.00)
   - Rating stars visualization
   - Top 10 suppliers

4. **Most Delayed Deliveries (Top 3)** ⚠️
   - Identifies problematic suppliers
   - Delayed delivery count and percentage
   - Average and maximum lead times
   - Performance concern indicator
   - **Only shows top 3 worst performers**

**Sample Output (Total Stock Delivered):**
```
🏆 TOP 10 SUPPLIERS - Ranked by Total Stock Delivered:

#1 RANK (Gold)
Supplier: TechWorld Distributors
Contact: David Kim
Location: San Francisco, USA
Rating: 4.50/5.00 ⭐⭐⭐⭐
Total Stock Delivered: 5,235 units
Total Deliveries: 18
Products Supplied: 3
Average Delivery Cost: $28.72 per unit
Total Value Delivered: $91,140.00
════════════════════════════════════════════════════════════

OVERALL SUMMARY:
Total Stock from Top Suppliers: 10,881 units
Total Products from Top Suppliers: 24
Average Stock per Supplier: 1,088 units
```

**Sample Output (Most Delayed Deliveries):**
```
⚠️  TOP 3 SUPPLIERS - Most Delayed Deliveries:

#1 RANK (Gold)
Supplier: Global Electronics
Contact: Anna Martinez
Location: Shenzhen, China
Rating: 4.70/5.00 ⭐⭐⭐⭐⭐
Delayed Deliveries: 4 out of 6 (66.7%)
Average Lead Time: 6.2 days
Longest Lead Time: 8 days
Total Stock Delivered: 220 units
Products Supplied: 2
Total Value Delivered: $28,750.00
════════════════════════════════════════════════════════════

OVERALL SUMMARY:
Total Delayed Deliveries (Top 3): 9
Average Lead Time Across Top 3: 5.8 days
Total Stock from These Suppliers: 1,590 units
```

#### 9️⃣ **Exit**
- Safely closes the application
- Displays goodbye message

### Color Coding System

The application uses intuitive color coding:

| Color | Usage |
|-------|-------|
| 🟢 **Green** | Headers, section titles, success messages |
| 🔵 **Cyan** | Data fields, metrics, summaries |
| 🟡 **Yellow** | Warnings, "no data" messages, supplier ratings |
| 🔴 **Red** | Errors, critical alerts, out of stock |
| ⚪ **Gray** | Record counts, metadata |
| 🟠 **Dark Yellow** | Bronze rank, moderate alerts |

### Navigation Tips

- **Enter number (1-9)** to select report
- **Follow prompts** for filtering options
- **Press any key** to return to main menu after viewing report
- **Invalid input** shows error and returns to menu
- **Ctrl+C** to exit at any time

---

## 🔍 Query Examples

### Essential Database Queries

#### Get Product Details with Stock Levels
```sql
SELECT 
    p.ProductName,
    p.UnitPrice,
    c.CategoryName,
    SUM(i.QuantityAvailable) AS TotalAvailable
FROM Products p
JOIN Categories c ON p.CategoryID = c.CategoryID
LEFT JOIN Inventory i ON p.ProductID = i.ProductID
GROUP BY p.ProductID
ORDER BY p.ProductName;
```

### Filter Products by Category and Availability
```sql
SELECT * FROM Products p
JOIN Inventory i ON p.ProductID = i.ProductID
WHERE p.CategoryID = 1 
  AND i.QuantityAvailable > 0
ORDER BY p.ProductName;
```

### Get Low Stock Alerts
```sql
CALL sp_GetLowStockAlerts(NULL);  -- All stores
CALL sp_GetLowStockAlerts(1);     -- Specific store ID
```

#### Analyze Supplier Delivery Performance
```sql
-- Top suppliers by total stock delivered
SELECT 
    s.SupplierName,
    COUNT(DISTINCT pd.ProductID) AS ProductCount,
    COALESCE(SUM(pd.QuantityDelivered), 0) AS TotalStockDelivered,
    COUNT(DISTINCT pd.DeliveryID) AS TotalDeliveries,
    COALESCE(AVG(pd.UnitCost), 0) AS AvgDeliveryCost
FROM Suppliers s
INNER JOIN ProductDeliveries pd ON s.SupplierID = pd.SupplierID
WHERE pd.DeliveryStatus = 'Delivered'
GROUP BY s.SupplierID, s.SupplierName
ORDER BY TotalStockDelivered DESC
LIMIT 10;
```

#### Identify Delayed Deliveries
```sql
-- Deliveries with lead time > 4 days
SELECT 
    s.SupplierName,
    p.ProductName,
    pd.OrderDate,
    pd.DeliveryDate,
    TIMESTAMPDIFF(DAY, pd.OrderDate, pd.DeliveryDate) AS LeadTimeDays,
    pd.QuantityDelivered,
    st.StoreName
FROM ProductDeliveries pd
INNER JOIN Suppliers s ON pd.SupplierID = s.SupplierID
INNER JOIN Products p ON pd.ProductID = p.ProductID
INNER JOIN Stores st ON pd.StoreID = st.StoreID
WHERE pd.DeliveryStatus = 'Delivered'
    AND TIMESTAMPDIFF(DAY, pd.OrderDate, pd.DeliveryDate) > 4
ORDER BY LeadTimeDays DESC;
```

#### Top-Selling Products (Last 30 Days)
```sql
SELECT 
    p.ProductName,
    c.CategoryName,
    SUM(s.QuantitySold) AS TotalSold,
    SUM(s.TotalAmount) AS TotalRevenue
FROM Sales s
JOIN Products p ON s.ProductID = p.ProductID
JOIN Categories c ON p.CategoryID = c.CategoryID
WHERE s.SaleDate >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
GROUP BY p.ProductID, p.ProductName, c.CategoryName
ORDER BY TotalSold DESC
LIMIT 10;
```

#### Check Inventory at Specific Store
```sql
SELECT * FROM vw_InventoryStatus
WHERE StoreName = 'Downtown Store'
ORDER BY CategoryName, ProductName;
```

#### Find All Electronics in Stock
```sql
SELECT * FROM vw_InventoryStatus
WHERE CategoryName = 'Electronics'
  AND StockStatus = 'In Stock'
ORDER BY StoreName;
```

For more examples, see `query_examples.sql` (50+ query patterns)

---

## 📁 Project Structure

```
InventoryControlSystem/
├── 📊 Database Files
│   ├── database_schema.sql              # Complete schema (7 tables, 3 views, 2 procedures)
│   ├── sample_data.sql                  # Sample data (50+ deliveries, 29 sales, 21 products)
│   ├── query_examples.sql               # 50+ example queries
│   ├── ProductDeliveries_Reference.sql  # Delivery tracking query examples
│   └── DelayedDeliveries_Analysis.sql   # Supplier performance analysis queries
│
├── 💻 C# Application Files
│   ├── Program.cs                       # Main console application (1,200+ lines)
│   ├── InventoryControlSystem.csproj    # .NET project file with dependencies
│   └── appsettings.json                 # Configuration template (optional)
│
├── 📖 Documentation
│   ├── README.md                        # This comprehensive guide
│   └── CSHARP_README.md                 # C# application detailed documentation
│
└── 🔧 Build Artifacts (auto-generated)
    ├── bin/                             # Compiled binaries
    ├── obj/                             # Build objects
    └── .config/                         # .NET tools configuration
```

### File Descriptions

| File | Purpose | Lines/Size |
|------|---------|------------|
| `database_schema.sql` | Database structure with tables, views, procedures, indexes | ~500 lines |
| `sample_data.sql` | Test data for all tables | ~800 lines |
| `query_examples.sql` | SQL query reference library | ~1,000 lines |
| `Program.cs` | C# console application with 9 report types | ~1,200 lines |
| `DelayedDeliveries_Analysis.sql` | Supplier performance queries | ~200 lines |
| `ProductDeliveries_Reference.sql` | Delivery tracking examples | ~150 lines |

---

## 🔐 Security & Best Practices

### Database Security

✅ **Implemented:**
- Foreign key constraints prevent orphaned records
- Check constraints ensure data validity (positive prices, quantities)
- Indexes optimize query performance
- Computed columns maintain data consistency
- ENUM types enforce valid status values

⚠️ **Production Recommendations:**
- Create dedicated MySQL user with limited privileges
- Use encrypted connections (SSL/TLS)
- Implement regular backup schedule
- Enable audit logging for sensitive operations
- Use views to restrict sensitive data access

### Application Security

✅ **Implemented:**
- Parameterized queries prevent SQL injection
- Async operations for better performance
- Error handling with user-friendly messages
- Input validation for all user inputs

⚠️ **Production Recommendations:**
- Store connection strings in secure configuration (environment variables, Azure Key Vault)
- Implement user authentication and authorization
- Add logging for audit trails
- Use connection pooling for scalability
- Implement retry logic for transient failures

### Code Quality

- **Async/Await Pattern:** All database operations use async methods
- **Dependency Management:** NuGet packages properly versioned
- **Error Handling:** Try-catch blocks with specific MySQL exceptions
- **Code Organization:** Helper methods for reusability
- **Readable Output:** Color-coded console with clear formatting

---

## 🛠️ Troubleshooting

### Common Issues and Solutions

#### ❌ Database Connection Failed
```
Error: Unable to connect to any of the specified MySQL hosts
```
**Solutions:**
1. Verify MySQL service is running: `services.msc` (Windows) or `sudo systemctl status mysql` (Linux)
2. Check connection string parameters (host, port, username, password)
3. Verify firewall allows MySQL port (default 3306)
4. Test connection: `mysql -u username -p`

#### ❌ Authentication Failed
```
Error: Access denied for user 'username'@'localhost'
```
**Solutions:**
1. Verify username and password in connection string
2. Check user exists: `SELECT user, host FROM mysql.user;`
3. Grant privileges if needed: `GRANT ALL ON InventoryControlDB.* TO 'username'@'localhost';`
4. Flush privileges: `FLUSH PRIVILEGES;`

#### ❌ Database Not Found
```
Error: Unknown database 'InventoryControlDB'
```
**Solutions:**
1. Create database: `CREATE DATABASE InventoryControlDB;`
2. Run schema script: `mysql -u username -p < database_schema.sql`
3. Verify database exists: `SHOW DATABASES;`

#### ❌ Build Errors (.NET)
```
Error: The command could not be loaded
```
**Solutions:**
1. Install .NET 9.0 SDK: https://dotnet.microsoft.com/download
2. Restore packages: `dotnet restore`
3. Clean build: `dotnet clean` then `dotnet build`
4. Verify SDK: `dotnet --version`

#### ❌ NuGet Package Errors
```
Error: Unable to find package 'MySqlConnector'
```
**Solutions:**
1. Restore packages: `dotnet restore`
2. Manual install: `dotnet add package MySqlConnector --version 2.3.7`
3. Clear NuGet cache: `dotnet nuget locals all --clear`

#### ❌ Application Runs But No Data Shows
```
Warning: No data found
```
**Solutions:**
1. Verify sample data loaded: `SELECT COUNT(*) FROM Products;`
2. Run sample_data.sql: `mysql -u username -p InventoryControlDB < sample_data.sql`
3. Check table contents in MySQL Workbench

#### ❌ Port Already in Use (MySQL)
```
Error: Can't connect to MySQL server on 'localhost' (10061)
```
**Solutions:**
1. Check if MySQL is running on different port
2. Update connection string with correct port
3. Verify port: `SHOW VARIABLES LIKE 'port';` in MySQL

### Debug Mode

To enable detailed error messages, modify `Program.cs`:

```csharp
catch (MySqlException ex)
{
    Console.ForegroundColor = ConsoleColor.Red;
    Console.WriteLine($"❌ Database Error: {ex.Message}");
    Console.WriteLine($"Error Code: {ex.ErrorCode}");
    Console.WriteLine($"SQL State: {ex.SqlState}");
    Console.WriteLine($"Stack Trace: {ex.StackTrace}");  // Add for debugging
    Console.ResetColor();
}
```

---

## 🛠️ Maintenance

### Regular Tasks
- Monitor low stock alerts
- Review sales trends weekly
- Update product prices as needed
- Archive old sales data quarterly
- Verify inventory counts monthly

## 📝 Notes

- All timestamps use `CURRENT_TIMESTAMP` with automatic updates
- Computed columns automatically calculate available quantities and totals
- Indexes optimize common query patterns
- Sample data represents a realistic multi-store scenario

---

## 🚀 Future Enhancements

### Planned Features

#### Database Enhancements
- [ ] **Customer Management Table** - Track customer information and purchase history
- [ ] **Purchase Orders Table** - Manage orders to suppliers
- [ ] **Returns/Refunds Table** - Track product returns and refunds
- [ ] **Warehouse Management** - Multi-warehouse support within stores
- [ ] **Product Variants** - Size, color, and other variant tracking
- [ ] **Pricing History** - Track price changes over time
- [ ] **Promotional Campaigns** - Discount and promotion tracking

#### Application Enhancements
- [ ] **Export Reports** - CSV, Excel, PDF export functionality
- [ ] **Data Visualization** - Charts and graphs for trends
- [ ] **Real-Time Alerts** - Email/SMS notifications for low stock
- [ ] **User Authentication** - Multi-user access with role-based permissions
- [ ] **Configuration File** - External config for connection strings
- [ ] **Logging System** - Comprehensive audit and error logging
- [ ] **Web Interface** - ASP.NET Core web application
- [ ] **REST API** - API endpoints for third-party integration
- [ ] **Dashboard** - Executive summary dashboard
- [ ] **Mobile App** - Cross-platform mobile application

#### Advanced Analytics
- [ ] **Predictive Analytics** - ML-based demand forecasting
- [ ] **ABC Analysis** - Classify inventory by value/importance
- [ ] **Seasonality Detection** - Identify seasonal patterns
- [ ] **Automated Reordering** - Smart reorder point calculations
- [ ] **Supplier Scorecards** - Comprehensive supplier evaluation
- [ ] **Cost Analysis** - Carrying costs and inventory valuation

---

## 📚 Dependencies & Technologies

### Database
- **MySQL:** 8.0 or higher
- **Storage Engine:** InnoDB (default)
- **Character Set:** utf8mb4
- **Collation:** utf8mb4_general_ci

### C# Application
| Package | Version | Purpose |
|---------|---------|---------|
| MySqlConnector | 2.3.7 | MySQL database connectivity |
| Microsoft.Extensions.Logging.Abstractions | 9.0.0 | Logging infrastructure (dependency) |
| .NET SDK | 9.0 | Runtime and compiler |

### Development Tools
- **IDE:** Visual Studio Code, Visual Studio 2022, or JetBrains Rider
- **Database Client:** MySQL Workbench, DBeaver, or command-line client
- **Version Control:** Git

---

## 📝 Changelog

### Version 1.0 (November 12, 2025)
- ✅ Initial release
- ✅ 7-table database schema with relationships
- ✅ 50+ sample records across all tables
- ✅ 3 database views for common queries
- ✅ 2 stored procedures for complex operations
- ✅ C# console application with 9 report types
- ✅ Low-stock alert system with filtering
- ✅ Top-performing suppliers ranking (4 criteria)
- ✅ Delivery tracking and performance analysis
- ✅ Delayed delivery identification
- ✅ Comprehensive documentation

---

## 📄 License

This project is provided as-is for educational and development purposes.

---

## 👤 Author

**Elisa Schroeder**
- GitHub: [@elisaschroeder](https://github.com/elisaschroeder)
- Repository: [InventoryControlSystem](https://github.com/elisaschroeder/InventoryControlSystem)

---

## 📊 Project Statistics

- **Total Lines of Code:** ~3,500+
  - Database SQL: ~1,500 lines
  - C# Application: ~1,200 lines
  - Documentation: ~800 lines
  
- **Database Objects:**
  - 7 Tables
  - 3 Views
  - 2 Stored Procedures
  - 15+ Indexes
  
- **Sample Data:**
  - 5 Stores
  - 10 Categories
  - 8 Suppliers
  - 21 Products
  - 35+ Inventory Records
  - 50+ Deliveries
  - 29 Sales Transactions
  
- **Application Features:**
  - 9 Report Types
  - 15+ Filtering Options
  - Color-Coded Output
  - Async Database Operations

---

## 🎯 Use Cases

This system is ideal for:

✅ **Small to Medium Retail Businesses**
- Multi-location inventory tracking
- Sales trend analysis
- Supplier management

✅ **Educational Projects**
- Database design learning
- C# application development
- SQL query practice

✅ **Prototyping & POC**
- Inventory management system demos
- Feature validation
- Architecture exploration

✅ **Portfolio Projects**
- Demonstrating full-stack skills
- Database design capabilities
- Application development proficiency

---

<div align="center">

### 🌟 Star this repository if you found it helpful! 🌟

**Built with ❤️ by Elisa Schroeder**

**Version 1.0** | **Last Updated: November 12, 2025**

[⬆ Back to Top](#-inventory-control-system)

</div>

---

**Note:** Remember to update your MySQL credentials in `Program.cs` before running the application!
 
 