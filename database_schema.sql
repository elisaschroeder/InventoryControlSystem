-- ============================================
-- Inventory Control System Database Schema
-- Multi-Store Inventory Management System
-- ============================================

-- Drop existing tables if they exist (in correct order to handle foreign keys)

USE InventoryControlDB;

DROP TABLE IF EXISTS Sales;
DROP TABLE IF EXISTS ProductDeliveries;
DROP TABLE IF EXISTS Inventory;
DROP TABLE IF EXISTS Products;
DROP TABLE IF EXISTS Categories;
DROP TABLE IF EXISTS Suppliers;
DROP TABLE IF EXISTS Stores;

-- ============================================
-- 1. STORES TABLE
-- ============================================
CREATE TABLE Stores (
    StoreID INT PRIMARY KEY AUTO_INCREMENT,
    StoreName VARCHAR(100) NOT NULL,
    StoreAddress VARCHAR(255),
    City VARCHAR(100),
    State VARCHAR(50),
    ZipCode VARCHAR(20),
    Phone VARCHAR(20),
    ManagerName VARCHAR(100),
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_store_city (City),
    INDEX idx_store_state (State)
) ENGINE=InnoDB;

-- ============================================
-- 2. CATEGORIES TABLE
-- ============================================
CREATE TABLE Categories (
    CategoryID INT PRIMARY KEY AUTO_INCREMENT,
    CategoryName VARCHAR(100) NOT NULL UNIQUE,
    Description TEXT,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_category_name (CategoryName)
) ENGINE=InnoDB;

-- ============================================
-- 3. SUPPLIERS TABLE
-- ============================================
CREATE TABLE Suppliers (
    SupplierID INT PRIMARY KEY AUTO_INCREMENT,
    SupplierName VARCHAR(150) NOT NULL,
    ContactName VARCHAR(100),
    Email VARCHAR(100),
    Phone VARCHAR(20),
    Address VARCHAR(255),
    City VARCHAR(100),
    Country VARCHAR(100),
    Rating DECIMAL(3,2) CHECK (Rating >= 0 AND Rating <= 5),
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_supplier_name (SupplierName),
    INDEX idx_supplier_rating (Rating)
) ENGINE=InnoDB;

-- ============================================
-- 4. PRODUCTS TABLE
-- ============================================
CREATE TABLE Products (
    ProductID INT PRIMARY KEY AUTO_INCREMENT,
    ProductName VARCHAR(200) NOT NULL,
    SKU VARCHAR(50) UNIQUE NOT NULL,
    CategoryID INT NOT NULL,
    SupplierID INT NOT NULL,
    UnitPrice DECIMAL(10,2) NOT NULL CHECK (UnitPrice >= 0),
    Description TEXT,
    Weight DECIMAL(8,2),
    Dimensions VARCHAR(50),
    ReorderLevel INT DEFAULT 10,
    IsActive BOOLEAN DEFAULT TRUE,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID) ON DELETE RESTRICT,
    FOREIGN KEY (SupplierID) REFERENCES Suppliers(SupplierID) ON DELETE RESTRICT,
    INDEX idx_product_name (ProductName),
    INDEX idx_product_sku (SKU),
    INDEX idx_product_category (CategoryID),
    INDEX idx_product_supplier (SupplierID),
    INDEX idx_product_active (IsActive)
) ENGINE=InnoDB;

-- ============================================
-- 5. INVENTORY TABLE
-- ============================================
CREATE TABLE Inventory (
    InventoryID INT PRIMARY KEY AUTO_INCREMENT,
    ProductID INT NOT NULL,
    StoreID INT NOT NULL,
    QuantityOnHand INT NOT NULL DEFAULT 0 CHECK (QuantityOnHand >= 0),
    QuantityReserved INT DEFAULT 0 CHECK (QuantityReserved >= 0),
    QuantityAvailable INT GENERATED ALWAYS AS (QuantityOnHand - QuantityReserved) STORED,
    LastRestocked TIMESTAMP NULL,
    MinimumStock INT DEFAULT 5,
    MaximumStock INT DEFAULT 100,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID) ON DELETE CASCADE,
    FOREIGN KEY (StoreID) REFERENCES Stores(StoreID) ON DELETE CASCADE,
    UNIQUE KEY unique_product_store (ProductID, StoreID),
    INDEX idx_inventory_product (ProductID),
    INDEX idx_inventory_store (StoreID),
    INDEX idx_inventory_quantity (QuantityOnHand),
    INDEX idx_inventory_available (QuantityAvailable)
) ENGINE=InnoDB;

-- ============================================
-- 6. PRODUCT DELIVERIES TABLE
-- ============================================
CREATE TABLE ProductDeliveries (
    DeliveryID INT PRIMARY KEY AUTO_INCREMENT,
    ProductID INT NOT NULL,
    SupplierID INT NOT NULL,
    StoreID INT NOT NULL,
    QuantityDelivered INT NOT NULL CHECK (QuantityDelivered > 0),
    OrderDate TIMESTAMP NULL,
    DeliveryDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UnitCost DECIMAL(10,2) CHECK (UnitCost >= 0),
    TotalCost DECIMAL(12,2) GENERATED ALWAYS AS (QuantityDelivered * UnitCost) STORED,
    DeliveryStatus ENUM('Pending', 'Delivered', 'Partial', 'Cancelled') DEFAULT 'Delivered',
    Notes TEXT,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID) ON DELETE RESTRICT,
    FOREIGN KEY (SupplierID) REFERENCES Suppliers(SupplierID) ON DELETE RESTRICT,
    FOREIGN KEY (StoreID) REFERENCES Stores(StoreID) ON DELETE RESTRICT,
    INDEX idx_delivery_product (ProductID),
    INDEX idx_delivery_supplier (SupplierID),
    INDEX idx_delivery_store (StoreID),
    INDEX idx_delivery_date (DeliveryDate),
    INDEX idx_delivery_order_date (OrderDate),
    INDEX idx_delivery_status (DeliveryStatus)
) ENGINE=InnoDB;

-- ============================================
-- 7. SALES TABLE
-- ============================================
CREATE TABLE Sales (
    SaleID INT PRIMARY KEY AUTO_INCREMENT,
    ProductID INT NOT NULL,
    StoreID INT NOT NULL,
    QuantitySold INT NOT NULL CHECK (QuantitySold > 0),
    SalePrice DECIMAL(10,2) NOT NULL CHECK (SalePrice >= 0),
    TotalAmount DECIMAL(12,2) GENERATED ALWAYS AS (QuantitySold * SalePrice) STORED,
    SaleDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CustomerID INT,
    TransactionID VARCHAR(100),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID) ON DELETE RESTRICT,
    FOREIGN KEY (StoreID) REFERENCES Stores(StoreID) ON DELETE RESTRICT,
    INDEX idx_sales_product (ProductID),
    INDEX idx_sales_store (StoreID),
    INDEX idx_sales_date (SaleDate),
    INDEX idx_sales_transaction (TransactionID)
) ENGINE=InnoDB;

-- ============================================
-- VIEWS FOR REPORTING
-- ============================================

-- View: Product details with category and supplier info
CREATE OR REPLACE VIEW vw_ProductDetails AS
SELECT 
    p.ProductID,
    p.ProductName,
    p.SKU,
    p.UnitPrice,
    p.Description,
    c.CategoryName,
    s.SupplierName,
    s.ContactName AS SupplierContact,
    s.Phone AS SupplierPhone,
    p.IsActive,
    p.ReorderLevel
FROM Products p
INNER JOIN Categories c ON p.CategoryID = c.CategoryID
INNER JOIN Suppliers s ON p.SupplierID = s.SupplierID;

-- View: Real-time inventory status across all stores
CREATE OR REPLACE VIEW vw_InventoryStatus AS
SELECT 
    st.StoreName,
    st.City,
    p.ProductName,
    p.SKU,
    p.UnitPrice,
    c.CategoryName,
    i.QuantityOnHand,
    i.QuantityReserved,
    i.QuantityAvailable,
    i.MinimumStock,
    i.MaximumStock,
    CASE 
        WHEN i.QuantityAvailable <= 0 THEN 'Out of Stock'
        WHEN i.QuantityAvailable <= i.MinimumStock THEN 'Low Stock'
        WHEN i.QuantityAvailable >= i.MaximumStock THEN 'Overstocked'
        ELSE 'In Stock'
    END AS StockStatus,
    i.LastRestocked,
    i.UpdatedAt
FROM Inventory i
INNER JOIN Products p ON i.ProductID = p.ProductID
INNER JOIN Stores st ON i.StoreID = st.StoreID
INNER JOIN Categories c ON p.CategoryID = c.CategoryID;

-- View: Sales trends with product and store information
CREATE OR REPLACE VIEW vw_SalesTrends AS
SELECT 
    s.SaleID,
    s.SaleDate,
    st.StoreName,
    st.City AS StoreCity,
    p.ProductName,
    p.SKU,
    c.CategoryName,
    s.QuantitySold,
    s.SalePrice,
    s.TotalAmount,
    s.TransactionID
FROM Sales s
INNER JOIN Products p ON s.ProductID = p.ProductID
INNER JOIN Stores st ON s.StoreID = st.StoreID
INNER JOIN Categories c ON p.CategoryID = c.CategoryID;

-- ============================================
-- STORED PROCEDURES
-- ============================================

DELIMITER //

-- Procedure: Get products by category with availability filter
CREATE PROCEDURE sp_GetProductsByCategory(
    IN p_CategoryID INT,
    IN p_AvailableOnly BOOLEAN
)
BEGIN
    IF p_AvailableOnly THEN
        SELECT DISTINCT
            p.ProductID,
            p.ProductName,
            p.SKU,
            p.UnitPrice,
            c.CategoryName,
            SUM(i.QuantityAvailable) AS TotalAvailable
        FROM Products p
        INNER JOIN Categories c ON p.CategoryID = c.CategoryID
        INNER JOIN Inventory i ON p.ProductID = i.ProductID
        WHERE p.CategoryID = p_CategoryID 
            AND p.IsActive = TRUE
            AND i.QuantityAvailable > 0
        GROUP BY p.ProductID, p.ProductName, p.SKU, p.UnitPrice, c.CategoryName
        ORDER BY p.ProductName;
    ELSE
        SELECT 
            p.ProductID,
            p.ProductName,
            p.SKU,
            p.UnitPrice,
            c.CategoryName,
            p.IsActive
        FROM Products p
        INNER JOIN Categories c ON p.CategoryID = c.CategoryID
        WHERE p.CategoryID = p_CategoryID
        ORDER BY p.ProductName;
    END IF;
END //

-- Procedure: Get low stock alerts
CREATE PROCEDURE sp_GetLowStockAlerts(IN p_StoreID INT)
BEGIN
    SELECT 
        st.StoreName,
        p.ProductName,
        p.SKU,
        i.QuantityAvailable,
        i.MinimumStock,
        s.SupplierName,
        s.Phone AS SupplierPhone
    FROM Inventory i
    INNER JOIN Products p ON i.ProductID = p.ProductID
    INNER JOIN Stores st ON i.StoreID = st.StoreID
    INNER JOIN Suppliers s ON p.SupplierID = s.SupplierID
    WHERE i.QuantityAvailable <= i.MinimumStock
        AND (p_StoreID IS NULL OR i.StoreID = p_StoreID)
        AND p.IsActive = TRUE
    ORDER BY i.QuantityAvailable ASC, p.ProductName;
END //

DELIMITER ;
