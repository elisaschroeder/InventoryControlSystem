-- ============================================
-- DATABASE OPTIMIZATIONS
-- Inventory Control System - Performance Enhancements
-- ============================================
-- Author: Elisa Schroeder
-- Date: November 12, 2025
-- ============================================

USE InventoryControlDB;

-- ============================================
-- PART 1: COMPOSITE INDEXES FOR COMMON QUERY PATTERNS
-- ============================================

-- These composite indexes optimize frequently-used query combinations
-- that appear in your application and analytical queries

-- Optimize ProductDeliveries filtering by status and date range
-- Used in: Top Suppliers report, Delayed Deliveries analysis
ALTER TABLE ProductDeliveries 
ADD INDEX idx_delivery_status_dates (DeliveryStatus, OrderDate, DeliveryDate);

-- Optimize Inventory low-stock queries with store filtering
-- Used in: Low-Stock Products report with store/category filters
ALTER TABLE Inventory
ADD INDEX idx_inventory_lowstock (QuantityAvailable, MinimumStock, StoreID, ProductID);

-- Optimize Sales queries by date range and store
-- Used in: Sales Report with date filtering
ALTER TABLE Sales
ADD INDEX idx_sales_date_store (SaleDate, StoreID, ProductID);

-- Optimize Products filtering by active status and category
-- Used in: Products Report, multiple analytical queries
ALTER TABLE Products
ADD INDEX idx_product_active_category (IsActive, CategoryID, SupplierID);

-- Optimize supplier-product-delivery joins (most common pattern)
-- Used in: Top-Performing Suppliers, Delivery Performance analysis
ALTER TABLE ProductDeliveries
ADD INDEX idx_delivery_supplier_status (SupplierID, DeliveryStatus, ProductID, StoreID);

-- Optimize inventory availability checks across stores
-- Used in: vw_InventoryStatus view, Products Report filtering
ALTER TABLE Inventory
ADD INDEX idx_inventory_store_product (StoreID, ProductID, QuantityAvailable);

-- ============================================
-- PART 2: OPTIMIZED VIEWS (MATERIALIZED ALTERNATIVES)
-- ============================================

-- While MySQL doesn't support true materialized views, we can create
-- optimized summary tables for frequently accessed aggregations

-- Summary table for product inventory totals (updated via triggers)
CREATE TABLE IF NOT EXISTS ProductInventorySummary (
    ProductID INT PRIMARY KEY,
    TotalQuantityOnHand INT DEFAULT 0,
    TotalQuantityReserved INT DEFAULT 0,
    TotalQuantityAvailable INT DEFAULT 0,
    StoreCount INT DEFAULT 0,
    OutOfStockStores INT DEFAULT 0,
    LowStockStores INT DEFAULT 0,
    LastUpdated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Populate initial data
INSERT INTO ProductInventorySummary (ProductID, TotalQuantityOnHand, TotalQuantityReserved, 
    TotalQuantityAvailable, StoreCount, OutOfStockStores, LowStockStores)
SELECT 
    p.ProductID,
    COALESCE(SUM(i.QuantityOnHand), 0) AS TotalQuantityOnHand,
    COALESCE(SUM(i.QuantityReserved), 0) AS TotalQuantityReserved,
    COALESCE(SUM(i.QuantityAvailable), 0) AS TotalQuantityAvailable,
    COUNT(DISTINCT i.StoreID) AS StoreCount,
    SUM(CASE WHEN i.QuantityAvailable = 0 THEN 1 ELSE 0 END) AS OutOfStockStores,
    SUM(CASE WHEN i.QuantityAvailable > 0 AND i.QuantityAvailable <= i.MinimumStock THEN 1 ELSE 0 END) AS LowStockStores
FROM Products p
LEFT JOIN Inventory i ON p.ProductID = i.ProductID
GROUP BY p.ProductID
ON DUPLICATE KEY UPDATE
    TotalQuantityOnHand = VALUES(TotalQuantityOnHand),
    TotalQuantityReserved = VALUES(TotalQuantityReserved),
    TotalQuantityAvailable = VALUES(TotalQuantityAvailable),
    StoreCount = VALUES(StoreCount),
    OutOfStockStores = VALUES(OutOfStockStores),
    LowStockStores = VALUES(LowStockStores);

-- Supplier performance summary table
CREATE TABLE IF NOT EXISTS SupplierPerformanceSummary (
    SupplierID INT PRIMARY KEY,
    TotalDeliveries INT DEFAULT 0,
    TotalUnitsDelivered BIGINT DEFAULT 0,
    TotalValueDelivered DECIMAL(15,2) DEFAULT 0,
    AvgUnitCost DECIMAL(10,2) DEFAULT 0,
    DelayedDeliveryCount INT DEFAULT 0,
    AvgLeadTimeDays DECIMAL(5,2) DEFAULT 0,
    ProductCount INT DEFAULT 0,
    LastDeliveryDate TIMESTAMP NULL,
    LastUpdated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (SupplierID) REFERENCES Suppliers(SupplierID) ON DELETE CASCADE,
    INDEX idx_perf_deliveries (TotalUnitsDelivered),
    INDEX idx_perf_delayed (DelayedDeliveryCount)
) ENGINE=InnoDB;

-- Populate supplier performance data
INSERT INTO SupplierPerformanceSummary (SupplierID, TotalDeliveries, TotalUnitsDelivered, 
    TotalValueDelivered, AvgUnitCost, DelayedDeliveryCount, AvgLeadTimeDays, ProductCount, LastDeliveryDate)
SELECT 
    s.SupplierID,
    COUNT(DISTINCT pd.DeliveryID) AS TotalDeliveries,
    COALESCE(SUM(pd.QuantityDelivered), 0) AS TotalUnitsDelivered,
    COALESCE(SUM(pd.TotalCost), 0) AS TotalValueDelivered,
    COALESCE(AVG(pd.UnitCost), 0) AS AvgUnitCost,
    COUNT(DISTINCT CASE 
        WHEN pd.OrderDate IS NOT NULL 
        AND pd.DeliveryDate IS NOT NULL 
        AND TIMESTAMPDIFF(DAY, pd.OrderDate, pd.DeliveryDate) > 4 
        THEN pd.DeliveryID 
    END) AS DelayedDeliveryCount,
    COALESCE(AVG(CASE 
        WHEN pd.OrderDate IS NOT NULL AND pd.DeliveryDate IS NOT NULL 
        THEN TIMESTAMPDIFF(DAY, pd.OrderDate, pd.DeliveryDate) 
    END), 0) AS AvgLeadTimeDays,
    COUNT(DISTINCT p.ProductID) AS ProductCount,
    MAX(pd.DeliveryDate) AS LastDeliveryDate
FROM Suppliers s
LEFT JOIN Products p ON s.SupplierID = p.SupplierID
LEFT JOIN ProductDeliveries pd ON s.SupplierID = pd.SupplierID AND pd.DeliveryStatus = 'Delivered'
GROUP BY s.SupplierID
ON DUPLICATE KEY UPDATE
    TotalDeliveries = VALUES(TotalDeliveries),
    TotalUnitsDelivered = VALUES(TotalUnitsDelivered),
    TotalValueDelivered = VALUES(TotalValueDelivered),
    AvgUnitCost = VALUES(AvgUnitCost),
    DelayedDeliveryCount = VALUES(DelayedDeliveryCount),
    AvgLeadTimeDays = VALUES(AvgLeadTimeDays),
    ProductCount = VALUES(ProductCount),
    LastDeliveryDate = VALUES(LastDeliveryDate);

-- ============================================
-- PART 3: TRIGGERS TO MAINTAIN SUMMARY TABLES
-- ============================================

DELIMITER //

-- Trigger to update ProductInventorySummary when Inventory changes
DROP TRIGGER IF EXISTS trg_inventory_update_summary//
CREATE TRIGGER trg_inventory_update_summary
AFTER INSERT ON Inventory
FOR EACH ROW
BEGIN
    INSERT INTO ProductInventorySummary (ProductID, TotalQuantityOnHand, TotalQuantityReserved, 
        TotalQuantityAvailable, StoreCount, OutOfStockStores, LowStockStores)
    SELECT 
        p.ProductID,
        COALESCE(SUM(i.QuantityOnHand), 0),
        COALESCE(SUM(i.QuantityReserved), 0),
        COALESCE(SUM(i.QuantityAvailable), 0),
        COUNT(DISTINCT i.StoreID),
        SUM(CASE WHEN i.QuantityAvailable = 0 THEN 1 ELSE 0 END),
        SUM(CASE WHEN i.QuantityAvailable > 0 AND i.QuantityAvailable <= i.MinimumStock THEN 1 ELSE 0 END)
    FROM Products p
    LEFT JOIN Inventory i ON p.ProductID = i.ProductID
    WHERE p.ProductID = NEW.ProductID
    GROUP BY p.ProductID
    ON DUPLICATE KEY UPDATE
        TotalQuantityOnHand = VALUES(TotalQuantityOnHand),
        TotalQuantityReserved = VALUES(TotalQuantityReserved),
        TotalQuantityAvailable = VALUES(TotalQuantityAvailable),
        StoreCount = VALUES(StoreCount),
        OutOfStockStores = VALUES(OutOfStockStores),
        LowStockStores = VALUES(LowStockStores);
END//

DROP TRIGGER IF EXISTS trg_inventory_update_summary_upd//
CREATE TRIGGER trg_inventory_update_summary_upd
AFTER UPDATE ON Inventory
FOR EACH ROW
BEGIN
    INSERT INTO ProductInventorySummary (ProductID, TotalQuantityOnHand, TotalQuantityReserved, 
        TotalQuantityAvailable, StoreCount, OutOfStockStores, LowStockStores)
    SELECT 
        p.ProductID,
        COALESCE(SUM(i.QuantityOnHand), 0),
        COALESCE(SUM(i.QuantityReserved), 0),
        COALESCE(SUM(i.QuantityAvailable), 0),
        COUNT(DISTINCT i.StoreID),
        SUM(CASE WHEN i.QuantityAvailable = 0 THEN 1 ELSE 0 END),
        SUM(CASE WHEN i.QuantityAvailable > 0 AND i.QuantityAvailable <= i.MinimumStock THEN 1 ELSE 0 END)
    FROM Products p
    LEFT JOIN Inventory i ON p.ProductID = i.ProductID
    WHERE p.ProductID = NEW.ProductID
    GROUP BY p.ProductID
    ON DUPLICATE KEY UPDATE
        TotalQuantityOnHand = VALUES(TotalQuantityOnHand),
        TotalQuantityReserved = VALUES(TotalQuantityReserved),
        TotalQuantityAvailable = VALUES(TotalQuantityAvailable),
        StoreCount = VALUES(StoreCount),
        OutOfStockStores = VALUES(OutOfStockStores),
        LowStockStores = VALUES(LowStockStores);
END//

-- Trigger to update SupplierPerformanceSummary when ProductDeliveries changes
DROP TRIGGER IF EXISTS trg_delivery_update_summary//
CREATE TRIGGER trg_delivery_update_summary
AFTER INSERT ON ProductDeliveries
FOR EACH ROW
BEGIN
    INSERT INTO SupplierPerformanceSummary (SupplierID, TotalDeliveries, TotalUnitsDelivered, 
        TotalValueDelivered, AvgUnitCost, DelayedDeliveryCount, AvgLeadTimeDays, ProductCount, LastDeliveryDate)
    SELECT 
        s.SupplierID,
        COUNT(DISTINCT pd.DeliveryID),
        COALESCE(SUM(pd.QuantityDelivered), 0),
        COALESCE(SUM(pd.TotalCost), 0),
        COALESCE(AVG(pd.UnitCost), 0),
        COUNT(DISTINCT CASE 
            WHEN pd.OrderDate IS NOT NULL 
            AND pd.DeliveryDate IS NOT NULL 
            AND TIMESTAMPDIFF(DAY, pd.OrderDate, pd.DeliveryDate) > 4 
            THEN pd.DeliveryID 
        END),
        COALESCE(AVG(CASE 
            WHEN pd.OrderDate IS NOT NULL AND pd.DeliveryDate IS NOT NULL 
            THEN TIMESTAMPDIFF(DAY, pd.OrderDate, pd.DeliveryDate) 
        END), 0),
        COUNT(DISTINCT p.ProductID),
        MAX(pd.DeliveryDate)
    FROM Suppliers s
    LEFT JOIN Products p ON s.SupplierID = p.SupplierID
    LEFT JOIN ProductDeliveries pd ON s.SupplierID = pd.SupplierID AND pd.DeliveryStatus = 'Delivered'
    WHERE s.SupplierID = NEW.SupplierID
    GROUP BY s.SupplierID
    ON DUPLICATE KEY UPDATE
        TotalDeliveries = VALUES(TotalDeliveries),
        TotalUnitsDelivered = VALUES(TotalUnitsDelivered),
        TotalValueDelivered = VALUES(TotalValueDelivered),
        AvgUnitCost = VALUES(AvgUnitCost),
        DelayedDeliveryCount = VALUES(DelayedDeliveryCount),
        AvgLeadTimeDays = VALUES(AvgLeadTimeDays),
        ProductCount = VALUES(ProductCount),
        LastDeliveryDate = VALUES(LastDeliveryDate);
END//

DELIMITER ;

-- ============================================
-- PART 4: OPTIMIZED STORED PROCEDURES
-- ============================================

DELIMITER //

-- Optimized version of low stock alerts with better index usage
DROP PROCEDURE IF EXISTS sp_GetLowStockAlertsOptimized//
CREATE PROCEDURE sp_GetLowStockAlertsOptimized(
    IN p_StoreID INT,
    IN p_CategoryID INT
)
BEGIN
    -- This version uses the composite index and avoids unnecessary joins
    SELECT 
        st.StoreName,
        p.ProductName,
        p.SKU,
        c.CategoryName,
        i.QuantityAvailable,
        i.MinimumStock,
        (i.MinimumStock - i.QuantityAvailable) AS ShortageAmount,
        s.SupplierName,
        s.ContactName,
        s.Phone AS SupplierPhone,
        s.Email AS SupplierEmail,
        s.Rating
    FROM Inventory i
    FORCE INDEX (idx_inventory_lowstock)
    INNER JOIN Products p ON i.ProductID = p.ProductID
    INNER JOIN Stores st ON i.StoreID = st.StoreID
    INNER JOIN Categories c ON p.CategoryID = c.CategoryID
    INNER JOIN Suppliers s ON p.SupplierID = s.SupplierID
    WHERE i.QuantityAvailable <= i.MinimumStock
        AND (p_StoreID IS NULL OR i.StoreID = p_StoreID)
        AND (p_CategoryID IS NULL OR p.CategoryID = c.CategoryID)
        AND p.IsActive = TRUE
    ORDER BY i.QuantityAvailable ASC, ShortageAmount DESC, p.ProductName;
END//

-- Optimized supplier ranking using summary table
DROP PROCEDURE IF EXISTS sp_GetTopSuppliersOptimized//
CREATE PROCEDURE sp_GetTopSuppliersOptimized(
    IN p_RankBy VARCHAR(20),  -- 'STOCK', 'PRODUCTS', 'RATING', 'DELAYS'
    IN p_Limit INT
)
BEGIN
    IF p_RankBy = 'STOCK' THEN
        SELECT 
            s.SupplierID,
            s.SupplierName,
            s.ContactName,
            s.Email,
            s.Phone,
            s.City,
            s.Country,
            s.Rating,
            sps.ProductCount,
            sps.TotalUnitsDelivered,
            sps.TotalDeliveries,
            sps.AvgUnitCost,
            sps.TotalValueDelivered
        FROM Suppliers s
        INNER JOIN SupplierPerformanceSummary sps ON s.SupplierID = sps.SupplierID
        ORDER BY sps.TotalUnitsDelivered DESC
        LIMIT p_Limit;
        
    ELSEIF p_RankBy = 'PRODUCTS' THEN
        SELECT 
            s.SupplierID,
            s.SupplierName,
            s.ContactName,
            s.Email,
            s.Phone,
            s.City,
            s.Country,
            s.Rating,
            sps.ProductCount,
            sps.TotalUnitsDelivered,
            sps.TotalDeliveries,
            sps.AvgUnitCost,
            sps.TotalValueDelivered
        FROM Suppliers s
        INNER JOIN SupplierPerformanceSummary sps ON s.SupplierID = sps.SupplierID
        ORDER BY sps.ProductCount DESC, sps.TotalUnitsDelivered DESC
        LIMIT p_Limit;
        
    ELSEIF p_RankBy = 'RATING' THEN
        SELECT 
            s.SupplierID,
            s.SupplierName,
            s.ContactName,
            s.Email,
            s.Phone,
            s.City,
            s.Country,
            s.Rating,
            sps.ProductCount,
            sps.TotalUnitsDelivered,
            sps.TotalDeliveries,
            sps.AvgUnitCost,
            sps.TotalValueDelivered
        FROM Suppliers s
        INNER JOIN SupplierPerformanceSummary sps ON s.SupplierID = sps.SupplierID
        ORDER BY s.Rating DESC, sps.TotalUnitsDelivered DESC
        LIMIT p_Limit;
        
    ELSEIF p_RankBy = 'DELAYS' THEN
        SELECT 
            s.SupplierID,
            s.SupplierName,
            s.ContactName,
            s.Email,
            s.Phone,
            s.City,
            s.Country,
            s.Rating,
            sps.ProductCount,
            sps.TotalDeliveries,
            sps.DelayedDeliveryCount,
            ROUND((sps.DelayedDeliveryCount * 100.0 / NULLIF(sps.TotalDeliveries, 0)), 1) AS DelayPercentage,
            sps.AvgLeadTimeDays,
            sps.TotalUnitsDelivered,
            sps.TotalValueDelivered
        FROM Suppliers s
        INNER JOIN SupplierPerformanceSummary sps ON s.SupplierID = sps.SupplierID
        WHERE sps.DelayedDeliveryCount > 0
        ORDER BY sps.DelayedDeliveryCount DESC, sps.AvgLeadTimeDays DESC
        LIMIT p_Limit;
    END IF;
END//

DELIMITER ;

-- ============================================
-- PART 5: QUERY OPTIMIZATION EXAMPLES
-- ============================================

-- OPTIMIZED: Get products with total available inventory
-- BEFORE: Multiple SUM operations per query
-- AFTER: Use summary table
SELECT 
    p.ProductID,
    p.ProductName,
    p.SKU,
    p.UnitPrice,
    c.CategoryName,
    s.SupplierName,
    pis.TotalQuantityAvailable,
    pis.StoreCount,
    pis.LowStockStores,
    pis.OutOfStockStores
FROM Products p
INNER JOIN Categories c ON p.CategoryID = c.CategoryID
INNER JOIN Suppliers s ON p.SupplierID = s.SupplierID
LEFT JOIN ProductInventorySummary pis ON p.ProductID = pis.ProductID
WHERE p.IsActive = TRUE
ORDER BY p.ProductName;

-- OPTIMIZED: Get sales trends with forced index
-- Use composite index for better date range queries
SELECT 
    DATE(s.SaleDate) AS SaleDate,
    st.StoreName,
    COUNT(s.SaleID) AS NumberOfTransactions,
    SUM(s.QuantitySold) AS TotalUnitsSold,
    SUM(s.TotalAmount) AS TotalRevenue
FROM Sales s
FORCE INDEX (idx_sales_date_store)
INNER JOIN Stores st ON s.StoreID = st.StoreID
WHERE s.SaleDate >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
GROUP BY DATE(s.SaleDate), st.StoreID, st.StoreName
ORDER BY SaleDate DESC, TotalRevenue DESC;

-- ============================================
-- PART 6: MAINTENANCE PROCEDURES
-- ============================================

DELIMITER //

-- Procedure to refresh all summary tables (run nightly or as needed)
DROP PROCEDURE IF EXISTS sp_RefreshSummaryTables//
CREATE PROCEDURE sp_RefreshSummaryTables()
BEGIN
    -- Refresh ProductInventorySummary
    TRUNCATE TABLE ProductInventorySummary;
    
    INSERT INTO ProductInventorySummary (ProductID, TotalQuantityOnHand, TotalQuantityReserved, 
        TotalQuantityAvailable, StoreCount, OutOfStockStores, LowStockStores)
    SELECT 
        p.ProductID,
        COALESCE(SUM(i.QuantityOnHand), 0),
        COALESCE(SUM(i.QuantityReserved), 0),
        COALESCE(SUM(i.QuantityAvailable), 0),
        COUNT(DISTINCT i.StoreID),
        SUM(CASE WHEN i.QuantityAvailable = 0 THEN 1 ELSE 0 END),
        SUM(CASE WHEN i.QuantityAvailable > 0 AND i.QuantityAvailable <= i.MinimumStock THEN 1 ELSE 0 END)
    FROM Products p
    LEFT JOIN Inventory i ON p.ProductID = i.ProductID
    GROUP BY p.ProductID;
    
    -- Refresh SupplierPerformanceSummary
    TRUNCATE TABLE SupplierPerformanceSummary;
    
    INSERT INTO SupplierPerformanceSummary (SupplierID, TotalDeliveries, TotalUnitsDelivered, 
        TotalValueDelivered, AvgUnitCost, DelayedDeliveryCount, AvgLeadTimeDays, ProductCount, LastDeliveryDate)
    SELECT 
        s.SupplierID,
        COUNT(DISTINCT pd.DeliveryID),
        COALESCE(SUM(pd.QuantityDelivered), 0),
        COALESCE(SUM(pd.TotalCost), 0),
        COALESCE(AVG(pd.UnitCost), 0),
        COUNT(DISTINCT CASE 
            WHEN pd.OrderDate IS NOT NULL 
            AND pd.DeliveryDate IS NOT NULL 
            AND TIMESTAMPDIFF(DAY, pd.OrderDate, pd.DeliveryDate) > 4 
            THEN pd.DeliveryID 
        END),
        COALESCE(AVG(CASE 
            WHEN pd.OrderDate IS NOT NULL AND pd.DeliveryDate IS NOT NULL 
            THEN TIMESTAMPDIFF(DAY, pd.OrderDate, pd.DeliveryDate) 
        END), 0),
        COUNT(DISTINCT p.ProductID),
        MAX(pd.DeliveryDate)
    FROM Suppliers s
    LEFT JOIN Products p ON s.SupplierID = p.SupplierID
    LEFT JOIN ProductDeliveries pd ON s.SupplierID = pd.SupplierID AND pd.DeliveryStatus = 'Delivered'
    GROUP BY s.SupplierID;
    
    SELECT 'Summary tables refreshed successfully' AS Status;
END//

-- Procedure to analyze and optimize tables
DROP PROCEDURE IF EXISTS sp_OptimizeTables//
CREATE PROCEDURE sp_OptimizeTables()
BEGIN
    OPTIMIZE TABLE Stores;
    OPTIMIZE TABLE Categories;
    OPTIMIZE TABLE Suppliers;
    OPTIMIZE TABLE Products;
    OPTIMIZE TABLE Inventory;
    OPTIMIZE TABLE ProductDeliveries;
    OPTIMIZE TABLE Sales;
    OPTIMIZE TABLE ProductInventorySummary;
    OPTIMIZE TABLE SupplierPerformanceSummary;
    
    SELECT 'All tables optimized' AS Status;
END//

DELIMITER ;

-- ============================================
-- PERFORMANCE MONITORING QUERIES
-- ============================================

-- Query to check index usage
SELECT 
    TABLE_NAME,
    INDEX_NAME,
    SEQ_IN_INDEX,
    COLUMN_NAME,
    CARDINALITY
FROM information_schema.STATISTICS
WHERE TABLE_SCHEMA = 'InventoryControlDB'
    AND TABLE_NAME IN ('Products', 'Inventory', 'Sales', 'ProductDeliveries', 'Suppliers')
ORDER BY TABLE_NAME, INDEX_NAME, SEQ_IN_INDEX;

-- Query to identify slow queries (requires slow query log enabled)
-- SET GLOBAL slow_query_log = 'ON';
-- SET GLOBAL long_query_time = 2; -- log queries taking > 2 seconds

-- ============================================
-- END OF OPTIMIZATIONS
-- ============================================

SELECT 'Database optimizations applied successfully!' AS Status;
SELECT 'Run sp_RefreshSummaryTables() to populate summary tables' AS NextStep;
