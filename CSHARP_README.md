# Inventory Control System - C# Console Application

## Overview
A comprehensive C# console application for managing and reporting on inventory data across multiple stores. This application connects to the MySQL Inventory Control Database and provides interactive reports with filtering capabilities.

## Features

### 📊 Report Options

1. **Stores Report** - View all stores with inventory statistics
2. **Categories Report** - Product categories with stock counts
3. **Suppliers Report** - Supplier information with ratings
4. **Products Report** - Detailed product listings with filtering:
   - All products
   - By specific store
   - By category
5. **Inventory Report** - Stock levels with filtering:
   - All inventory
   - By store
   - By category
   - By product ID
6. **Sales Report** - Transaction history with filtering:
   - All sales
   - By product
   - By store
   - By date range

## Prerequisites

- .NET 9.0 SDK or higher
- MySQL Server 8.0 or higher
- Inventory Control Database (setup instructions in `/database_schema.sql`)

## Setup Instructions

### 1. Database Setup

First, create and populate the MySQL database:

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
```

### 2. Configure Connection String

Update the connection string in `Program.cs` (line 7):

```csharp
private static string connectionString = "Server=localhost;Port=3306;Database=InventoryControlDB;User=root;Password=YOUR_PASSWORD;";
```

**Replace:**
- `localhost` with your MySQL server address
- `3306` with your MySQL port (if different)
- `root` with your MySQL username
- `YOUR_PASSWORD` with your MySQL password

### 3. Restore NuGet Packages

```bash
dotnet restore
```

### 4. Build the Application

```bash
dotnet build
```

### 5. Run the Application

```bash
dotnet run
```

## Usage Guide

### Main Menu
When you launch the application, you'll see an interactive menu:

```
┌────────────────────────────────────────────────────────────┐
│                      MAIN MENU                             │
└────────────────────────────────────────────────────────────┘

  1. 🏢 Stores Report
  2. 📦 Categories Report
  3. 🚚 Suppliers Report
  4. 🛍️  Products Report (with filtering)
  5. 📊 Inventory Report (with filtering)
  6. 💰 Sales Report (with filtering)
  7. 🚪 Exit
```

### Report Examples

#### Stores Report
Displays all stores with:
- Store details (name, location, manager)
- Number of unique products
- Total inventory units

#### Products Report with Filtering
Choose from:
1. **All Products** - Complete product catalog
2. **By Store** - Products available at a specific store
3. **By Category** - Products in a specific category

#### Inventory Report with Filtering
Filter inventory by:
1. **All Inventory** - Complete stock overview (limited to 50 records)
2. **By Store** - Stock levels at a specific location
3. **By Category** - Stock for products in a category
4. **By Product ID** - Track a specific product across all stores

Stock status indicators:
- 🔴 **Out of Stock** - No available inventory
- 🟡 **Low Stock** - Below minimum stock level
- 🟢 **In Stock** - Normal stock levels

#### Sales Report with Filtering
View sales data filtered by:
1. **All Sales** - Recent transactions (last 30)
2. **By Product** - Sales history for a specific product
3. **By Store** - Sales at a specific location
4. **By Date Range** - Custom date range (format: yyyy-MM-dd)

Includes sales summary with total units sold and revenue.

## Project Structure

```
InventoryControlSystem/
├── Program.cs                 # Main application with all reports
├── InventoryControlSystem.csproj  # Project configuration
├── appsettings.json          # Configuration settings (optional)
├── database_schema.sql       # Database schema
├── sample_data.sql          # Sample data
├── query_examples.sql       # SQL query reference
└── README.md                # This file
```

## Key Components

### Database Connection
- Uses `MySqlConnector` for MySQL connectivity
- Connection string configured in `Program.cs`
- Async/await pattern for database operations

### Helper Methods
- `ExecuteQuery()` - Generic query execution with error handling
- `ListStores()` - Display available stores for filtering
- `ListCategories()` - Display available categories
- `ListProducts()` - Display product list for selection

### Error Handling
- MySQL exception handling with error codes
- User-friendly error messages
- Graceful fallback for invalid inputs

## Dependencies

```xml
<PackageReference Include="MySqlConnector" Version="2.3.7" />
```

## Color Coding

The application uses color-coded output for better readability:
- 🔵 **Cyan** - Headers and titles
- 🟢 **Green** - Section labels and success messages
- 🟡 **Yellow** - Warnings and "no data" messages
- 🔴 **Red** - Errors and critical alerts
- ⚪ **Gray** - Record counts and metadata

## Sample Output

```
═══════════════════════════════════════════════════════════
                  INVENTORY REPORT
═══════════════════════════════════════════════════════════

Store: Downtown Store (New York)
Product: Wireless Bluetooth Headphones
SKU: ELEC-001
Category: Electronics
On Hand: 45
Reserved: 5
Available: 40
Minimum Stock: 15
Status: In Stock
────────────────────────────────────────────────────────────
```

## Troubleshooting

### Connection Issues
```
❌ Database Error: Unable to connect to any of the specified MySQL hosts
```
**Solution:** Verify MySQL is running and connection string is correct.

### Authentication Failed
```
❌ Database Error: Access denied for user
```
**Solution:** Check username and password in connection string.

### Database Not Found
```
❌ Database Error: Unknown database 'InventoryControlDB'
```
**Solution:** Run the database setup scripts first.

## Performance Notes

- Large result sets are limited (e.g., 50 records for all inventory)
- Queries use proper indexing from database schema
- Async operations prevent UI blocking
- Parameterized queries prevent SQL injection

## Future Enhancements

Potential features to add:
- Export reports to CSV/Excel
- Advanced filtering combinations
- Data visualization/charts
- Real-time inventory alerts
- User authentication
- Configuration file support
- Logging system

## Support

For database schema questions, refer to:
- `database_schema.sql` - Table definitions
- `query_examples.sql` - SQL query patterns
- Database README.md - Schema documentation

## Version Information

- **Application Version:** 1.0
- **.NET Version:** 9.0
- **MySQL Connector:** 2.3.7
- **Last Updated:** November 12, 2025

---

**Note:** Remember to update your MySQL credentials before running the application!
