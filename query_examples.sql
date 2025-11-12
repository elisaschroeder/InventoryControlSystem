-- ============================================
-- Query Examples for Inventory Control System
-- ============================================

-- ============================================
-- 1. PRODUCT RETRIEVAL QUERIES
-- ============================================

-- Get all product details with name, price, and stock levels
SELECT 
    p.ProductID,
    p.ProductName,
    p.SKU,
    p.UnitPrice,
    c.CategoryName,
    s.SupplierName,
    SUM(i.QuantityOnHand) AS TotalStock,
    SUM(i.QuantityAvailable) AS TotalAvailable,
    p.IsActive
FROM Products p
LEFT JOIN Categories c ON p.CategoryID = c.CategoryID
LEFT JOIN Suppliers s ON p.SupplierID = s.SupplierID
LEFT JOIN Inventory i ON p.ProductID = i.ProductID
GROUP BY p.ProductID, p.ProductName, p.SKU, p.UnitPrice, c.CategoryName, s.SupplierName, p.IsActive
ORDER BY p.ProductName;

-- Get product details for a specific product by SKU
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
    s.Email AS SupplierEmail
FROM Products p
INNER JOIN Categories c ON p.CategoryID = c.CategoryID
INNER JOIN Suppliers s ON p.SupplierID = s.SupplierID
WHERE p.SKU = 'ELEC-001';

-- Get detailed stock levels for a product across all stores
SELECT 
    p.ProductName,
    p.SKU,
    st.StoreName,
    st.City,
    i.QuantityOnHand,
    i.QuantityReserved,
    i.QuantityAvailable,
    CASE 
        WHEN i.QuantityAvailable <= 0 THEN 'Out of Stock'
        WHEN i.QuantityAvailable <= i.MinimumStock THEN 'Low Stock'
        ELSE 'In Stock'
    END AS StockStatus
FROM Products p
INNER JOIN Inventory i ON p.ProductID = i.ProductID
INNER JOIN Stores st ON i.StoreID = st.StoreID
WHERE p.ProductName LIKE '%Headphones%'
ORDER BY st.StoreName;

-- ============================================
-- 2. FILTERING QUERIES
-- ============================================

-- Filter products by category
SELECT 
    p.ProductID,
    p.ProductName,
    p.SKU,
    p.UnitPrice,
    c.CategoryName,
    SUM(i.QuantityAvailable) AS TotalAvailable
FROM Products p
INNER JOIN Categories c ON p.CategoryID = c.CategoryID
LEFT JOIN Inventory i ON p.ProductID = i.ProductID
WHERE c.CategoryName = 'Electronics'
GROUP BY p.ProductID, p.ProductName, p.SKU, p.UnitPrice, c.CategoryName
ORDER BY p.ProductName;

-- Filter products by multiple categories
SELECT 
    p.ProductID,
    p.ProductName,
    p.SKU,
    p.UnitPrice,
    c.CategoryName,
    SUM(i.QuantityAvailable) AS TotalAvailable
FROM Products p
INNER JOIN Categories c ON p.CategoryID = c.CategoryID
LEFT JOIN Inventory i ON p.ProductID = i.ProductID
WHERE c.CategoryName IN ('Electronics', 'Office Supplies', 'Sports & Outdoors')
GROUP BY p.ProductID, p.ProductName, p.SKU, p.UnitPrice, c.CategoryName
ORDER BY c.CategoryName, p.ProductName;

-- Filter products by availability (in stock only)
SELECT 
    p.ProductID,
    p.ProductName,
    p.SKU,
    p.UnitPrice,
    c.CategoryName,
    SUM(i.QuantityAvailable) AS TotalAvailable
FROM Products p
INNER JOIN Categories c ON p.CategoryID = c.CategoryID
INNER JOIN Inventory i ON p.ProductID = i.ProductID
WHERE i.QuantityAvailable > 0 AND p.IsActive = TRUE
GROUP BY p.ProductID, p.ProductName, p.SKU, p.UnitPrice, c.CategoryName
HAVING SUM(i.QuantityAvailable) > 0
ORDER BY p.ProductName;

-- Filter products by price range
SELECT 
    p.ProductID,
    p.ProductName,
    p.SKU,
    p.UnitPrice,
    c.CategoryName
FROM Products p
INNER JOIN Categories c ON p.CategoryID = c.CategoryID
WHERE p.UnitPrice BETWEEN 20.00 AND 100.00
    AND p.IsActive = TRUE
ORDER BY p.UnitPrice ASC;

-- Filter products by availability at a specific store
SELECT 
    p.ProductID,
    p.ProductName,
    p.SKU,
    p.UnitPrice,
    c.CategoryName,
    st.StoreName,
    i.QuantityAvailable
FROM Products p
INNER JOIN Categories c ON p.CategoryID = c.CategoryID
INNER JOIN Inventory i ON p.ProductID = i.ProductID
INNER JOIN Stores st ON i.StoreID = st.StoreID
WHERE st.StoreName = 'Downtown Store'
    AND i.QuantityAvailable > 0
    AND p.IsActive = TRUE
ORDER BY c.CategoryName, p.ProductName;

-- Filter products by category AND availability
SELECT 
    p.ProductID,
    p.ProductName,
    p.SKU,
    p.UnitPrice,
    c.CategoryName,
    SUM(i.QuantityAvailable) AS TotalAvailable
FROM Products p
INNER JOIN Categories c ON p.CategoryID = c.CategoryID
INNER JOIN Inventory i ON p.ProductID = i.ProductID
WHERE c.CategoryName = 'Electronics'
    AND i.QuantityAvailable > 0
    AND p.IsActive = TRUE
GROUP BY p.ProductID, p.ProductName, p.SKU, p.UnitPrice, c.CategoryName
HAVING SUM(i.QuantityAvailable) > 0
ORDER BY p.ProductName;

-- ============================================
-- 3. SORTING QUERIES
-- ============================================

-- Sort products by name (alphabetically)
SELECT 
    p.ProductID,
    p.ProductName,
    p.SKU,
    p.UnitPrice,
    c.CategoryName,
    SUM(i.QuantityAvailable) AS TotalAvailable
FROM Products p
INNER JOIN Categories c ON p.CategoryID = c.CategoryID
LEFT JOIN Inventory i ON p.ProductID = i.ProductID
GROUP BY p.ProductID, p.ProductName, p.SKU, p.UnitPrice, c.CategoryName
ORDER BY p.ProductName ASC;

-- Sort products by price (lowest to highest)
SELECT 
    p.ProductID,
    p.ProductName,
    p.SKU,
    p.UnitPrice,
    c.CategoryName,
    SUM(i.QuantityAvailable) AS TotalAvailable
FROM Products p
INNER JOIN Categories c ON p.CategoryID = c.CategoryID
LEFT JOIN Inventory i ON p.ProductID = i.ProductID
GROUP BY p.ProductID, p.ProductName, p.SKU, p.UnitPrice, c.CategoryName
ORDER BY p.UnitPrice ASC;

-- Sort products by price (highest to lowest)
SELECT 
    p.ProductID,
    p.ProductName,
    p.SKU,
    p.UnitPrice,
    c.CategoryName,
    SUM(i.QuantityAvailable) AS TotalAvailable
FROM Products p
INNER JOIN Categories c ON p.CategoryID = c.CategoryID
LEFT JOIN Inventory i ON p.ProductID = i.ProductID
GROUP BY p.ProductID, p.ProductName, p.SKU, p.UnitPrice, c.CategoryName
ORDER BY p.UnitPrice DESC;

-- Sort products by stock level (highest to lowest)
SELECT 
    p.ProductID,
    p.ProductName,
    p.SKU,
    p.UnitPrice,
    c.CategoryName,
    SUM(i.QuantityAvailable) AS TotalAvailable
FROM Products p
INNER JOIN Categories c ON p.CategoryID = c.CategoryID
LEFT JOIN Inventory i ON p.ProductID = i.ProductID
GROUP BY p.ProductID, p.ProductName, p.SKU, p.UnitPrice, c.CategoryName
ORDER BY TotalAvailable DESC;

-- Sort products by category, then by name
SELECT 
    p.ProductID,
    p.ProductName,
    p.SKU,
    p.UnitPrice,
    c.CategoryName,
    SUM(i.QuantityAvailable) AS TotalAvailable
FROM Products p
INNER JOIN Categories c ON p.CategoryID = c.CategoryID
LEFT JOIN Inventory i ON p.ProductID = i.ProductID
GROUP BY p.ProductID, p.ProductName, p.SKU, p.UnitPrice, c.CategoryName
ORDER BY c.CategoryName ASC, p.ProductName ASC;

-- ============================================
-- 4. REAL-TIME INVENTORY INSIGHTS
-- ============================================

-- Get current inventory status across all stores
SELECT 
    st.StoreName,
    st.City,
    COUNT(DISTINCT i.ProductID) AS UniqueProducts,
    SUM(i.QuantityOnHand) AS TotalOnHand,
    SUM(i.QuantityReserved) AS TotalReserved,
    SUM(i.QuantityAvailable) AS TotalAvailable
FROM Stores st
LEFT JOIN Inventory i ON st.StoreID = i.StoreID
GROUP BY st.StoreID, st.StoreName, st.City
ORDER BY st.StoreName;

-- Get low stock alerts (products below minimum stock level)
SELECT 
    st.StoreName,
    p.ProductName,
    p.SKU,
    c.CategoryName,
    i.QuantityAvailable,
    i.MinimumStock,
    (i.MinimumStock - i.QuantityAvailable) AS UnitsNeeded,
    s.SupplierName,
    s.Phone AS SupplierPhone
FROM Inventory i
INNER JOIN Products p ON i.ProductID = p.ProductID
INNER JOIN Stores st ON i.StoreID = st.StoreID
INNER JOIN Categories c ON p.CategoryID = c.CategoryID
INNER JOIN Suppliers s ON p.SupplierID = s.SupplierID
WHERE i.QuantityAvailable <= i.MinimumStock
    AND p.IsActive = TRUE
ORDER BY i.QuantityAvailable ASC, st.StoreName;

-- Get out of stock products
SELECT 
    st.StoreName,
    p.ProductName,
    p.SKU,
    c.CategoryName,
    i.QuantityOnHand,
    i.QuantityReserved,
    s.SupplierName
FROM Inventory i
INNER JOIN Products p ON i.ProductID = p.ProductID
INNER JOIN Stores st ON i.StoreID = st.StoreID
INNER JOIN Categories c ON p.CategoryID = c.CategoryID
INNER JOIN Suppliers s ON p.SupplierID = s.SupplierID
WHERE i.QuantityAvailable <= 0
    AND p.IsActive = TRUE
ORDER BY st.StoreName, p.ProductName;

-- Get overstocked products
SELECT 
    st.StoreName,
    p.ProductName,
    p.SKU,
    i.QuantityAvailable,
    i.MaximumStock,
    (i.QuantityAvailable - i.MaximumStock) AS ExcessUnits
FROM Inventory i
INNER JOIN Products p ON i.ProductID = p.ProductID
INNER JOIN Stores st ON i.StoreID = st.StoreID
WHERE i.QuantityAvailable >= i.MaximumStock
ORDER BY ExcessUnits DESC;

-- ============================================
-- 5. SALES TREND ANALYSIS
-- ============================================

-- Get total sales by product (last 30 days)
SELECT 
    p.ProductName,
    p.SKU,
    c.CategoryName,
    COUNT(s.SaleID) AS NumberOfSales,
    SUM(s.QuantitySold) AS TotalUnitsSold,
    SUM(s.TotalAmount) AS TotalRevenue,
    AVG(s.SalePrice) AS AveragePrice
FROM Sales s
INNER JOIN Products p ON s.ProductID = p.ProductID
INNER JOIN Categories c ON p.CategoryID = c.CategoryID
WHERE s.SaleDate >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
GROUP BY p.ProductID, p.ProductName, p.SKU, c.CategoryName
ORDER BY TotalRevenue DESC;

-- Get sales performance by store (last 30 days)
SELECT 
    st.StoreName,
    st.City,
    COUNT(s.SaleID) AS NumberOfTransactions,
    SUM(s.QuantitySold) AS TotalUnitsSold,
    SUM(s.TotalAmount) AS TotalRevenue,
    AVG(s.TotalAmount) AS AverageTransactionValue
FROM Sales s
INNER JOIN Stores st ON s.StoreID = st.StoreID
WHERE s.SaleDate >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
GROUP BY st.StoreID, st.StoreName, st.City
ORDER BY TotalRevenue DESC;

-- Get top selling products (last 30 days)
SELECT 
    p.ProductName,
    p.SKU,
    c.CategoryName,
    SUM(s.QuantitySold) AS TotalUnitsSold,
    SUM(s.TotalAmount) AS TotalRevenue
FROM Sales s
INNER JOIN Products p ON s.ProductID = p.ProductID
INNER JOIN Categories c ON p.CategoryID = c.CategoryID
WHERE s.SaleDate >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
GROUP BY p.ProductID, p.ProductName, p.SKU, c.CategoryName
ORDER BY TotalUnitsSold DESC
LIMIT 10;

-- Get sales trends by category (last 30 days)
SELECT 
    c.CategoryName,
    COUNT(DISTINCT s.SaleID) AS NumberOfSales,
    SUM(s.QuantitySold) AS TotalUnitsSold,
    SUM(s.TotalAmount) AS TotalRevenue,
    AVG(s.SalePrice) AS AveragePrice
FROM Sales s
INNER JOIN Products p ON s.ProductID = p.ProductID
INNER JOIN Categories c ON p.CategoryID = c.CategoryID
WHERE s.SaleDate >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
GROUP BY c.CategoryID, c.CategoryName
ORDER BY TotalRevenue DESC;

-- Get daily sales trend (last 7 days)
SELECT 
    DATE(s.SaleDate) AS SaleDate,
    COUNT(s.SaleID) AS NumberOfTransactions,
    SUM(s.QuantitySold) AS TotalUnitsSold,
    SUM(s.TotalAmount) AS TotalRevenue
FROM Sales s
WHERE s.SaleDate >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)
GROUP BY DATE(s.SaleDate)
ORDER BY SaleDate DESC;

-- ============================================
-- 6. SUPPLIER INFORMATION QUERIES
-- ============================================

-- Get all suppliers with their product counts
SELECT 
    s.SupplierID,
    s.SupplierName,
    s.ContactName,
    s.Phone,
    s.Email,
    s.Country,
    s.Rating,
    COUNT(p.ProductID) AS NumberOfProducts
FROM Suppliers s
LEFT JOIN Products p ON s.SupplierID = p.SupplierID
GROUP BY s.SupplierID, s.SupplierName, s.ContactName, s.Phone, s.Email, s.Country, s.Rating
ORDER BY s.Rating DESC;

-- Get supplier details for products needing restock
SELECT DISTINCT
    s.SupplierName,
    s.ContactName,
    s.Phone,
    s.Email,
    COUNT(DISTINCT p.ProductID) AS ProductsNeedingRestock
FROM Suppliers s
INNER JOIN Products p ON s.SupplierID = p.SupplierID
INNER JOIN Inventory i ON p.ProductID = i.ProductID
WHERE i.QuantityAvailable <= i.MinimumStock
    AND p.IsActive = TRUE
GROUP BY s.SupplierID, s.SupplierName, s.ContactName, s.Phone, s.Email
ORDER BY ProductsNeedingRestock DESC;

-- Get products by supplier with current stock levels
SELECT 
    s.SupplierName,
    p.ProductName,
    p.SKU,
    p.UnitPrice,
    c.CategoryName,
    SUM(i.QuantityAvailable) AS TotalAvailable
FROM Suppliers s
INNER JOIN Products p ON s.SupplierID = p.SupplierID
INNER JOIN Categories c ON p.CategoryID = c.CategoryID
LEFT JOIN Inventory i ON p.ProductID = i.ProductID
WHERE s.SupplierName = 'TechWorld Distributors'
GROUP BY s.SupplierName, p.ProductID, p.ProductName, p.SKU, p.UnitPrice, c.CategoryName
ORDER BY p.ProductName;

-- ============================================
-- 7. USING STORED PROCEDURES
-- ============================================

-- Get products by category with availability filter (available only)
CALL sp_GetProductsByCategory(1, TRUE);

-- Get products by category (all products, regardless of availability)
CALL sp_GetProductsByCategory(2, FALSE);

-- Get low stock alerts for all stores
CALL sp_GetLowStockAlerts(NULL);

-- Get low stock alerts for specific store
CALL sp_GetLowStockAlerts(1);

-- ============================================
-- 8. USING VIEWS
-- ============================================

-- Query product details view
SELECT * FROM vw_ProductDetails
WHERE IsActive = TRUE
ORDER BY ProductName;

-- Query inventory status view
SELECT * FROM vw_InventoryStatus
WHERE StockStatus IN ('Low Stock', 'Out of Stock')
ORDER BY StoreName, StockStatus;

-- Query sales trends view
SELECT * FROM vw_SalesTrends
WHERE SaleDate >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)
ORDER BY SaleDate DESC;

-- Get inventory status for specific category
SELECT * FROM vw_InventoryStatus
WHERE CategoryName = 'Electronics'
ORDER BY StoreName, ProductName;
