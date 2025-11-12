-- ============================================
-- Product Deliveries Table - Quick Reference
-- ============================================

-- Purpose: Track all product deliveries from suppliers to stores
-- This table enables accurate performance tracking of suppliers

-- Table Structure:
-- - DeliveryID: Unique identifier for each delivery
-- - ProductID: Foreign key to Products table
-- - SupplierID: Foreign key to Suppliers table
-- - StoreID: Foreign key to destination store
-- - QuantityDelivered: Number of units delivered
-- - DeliveryDate: When the delivery occurred
-- - UnitCost: Cost per unit from supplier
-- - TotalCost: Auto-calculated (QuantityDelivered * UnitCost)
-- - DeliveryStatus: Pending, Delivered, Partial, or Cancelled
-- - Notes: Additional delivery information

-- ============================================
-- EXAMPLE QUERIES
-- ============================================

-- Get all deliveries for a specific supplier
SELECT 
    pd.DeliveryID,
    p.ProductName,
    st.StoreName,
    pd.QuantityDelivered,
    pd.TotalCost,
    pd.DeliveryDate,
    pd.DeliveryStatus
FROM ProductDeliveries pd
INNER JOIN Products p ON pd.ProductID = p.ProductID
INNER JOIN Stores st ON pd.StoreID = st.StoreID
INNER JOIN Suppliers s ON pd.SupplierID = s.SupplierID
WHERE s.SupplierName = 'TechWorld Distributors'
ORDER BY pd.DeliveryDate DESC;

-- Get delivery summary by supplier (for performance ranking)
SELECT 
    s.SupplierName,
    COUNT(*) AS TotalDeliveries,
    SUM(pd.QuantityDelivered) AS TotalUnitsDelivered,
    SUM(pd.TotalCost) AS TotalValueDelivered,
    AVG(pd.UnitCost) AS AvgCostPerUnit
FROM ProductDeliveries pd
INNER JOIN Suppliers s ON pd.SupplierID = s.SupplierID
WHERE pd.DeliveryStatus = 'Delivered'
GROUP BY s.SupplierID, s.SupplierName
ORDER BY TotalUnitsDelivered DESC;

-- Get recent deliveries (last 30 days)
SELECT 
    pd.DeliveryDate,
    s.SupplierName,
    p.ProductName,
    st.StoreName,
    pd.QuantityDelivered,
    pd.UnitCost,
    pd.TotalCost,
    pd.DeliveryStatus
FROM ProductDeliveries pd
INNER JOIN Suppliers s ON pd.SupplierID = s.SupplierID
INNER JOIN Products p ON pd.ProductID = p.ProductID
INNER JOIN Stores st ON pd.StoreID = st.StoreID
WHERE pd.DeliveryDate >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
ORDER BY pd.DeliveryDate DESC;

-- Get pending/partial deliveries
SELECT 
    pd.DeliveryID,
    s.SupplierName,
    p.ProductName,
    st.StoreName,
    pd.QuantityDelivered,
    pd.DeliveryStatus,
    pd.Notes
FROM ProductDeliveries pd
INNER JOIN Suppliers s ON pd.SupplierID = s.SupplierID
INNER JOIN Products p ON pd.ProductID = p.ProductID
INNER JOIN Stores st ON pd.StoreID = st.StoreID
WHERE pd.DeliveryStatus IN ('Pending', 'Partial')
ORDER BY pd.DeliveryDate;

-- Get delivery performance by month
SELECT 
    DATE_FORMAT(pd.DeliveryDate, '%Y-%m') AS Month,
    s.SupplierName,
    COUNT(*) AS DeliveryCount,
    SUM(pd.QuantityDelivered) AS TotalUnits,
    SUM(pd.TotalCost) AS TotalSpent
FROM ProductDeliveries pd
INNER JOIN Suppliers s ON pd.SupplierID = s.SupplierID
WHERE pd.DeliveryStatus = 'Delivered'
GROUP BY DATE_FORMAT(pd.DeliveryDate, '%Y-%m'), s.SupplierID, s.SupplierName
ORDER BY Month DESC, TotalUnits DESC;

-- Compare supplier delivery costs
SELECT 
    p.ProductName,
    s.SupplierName,
    AVG(pd.UnitCost) AS AvgCost,
    COUNT(*) AS DeliveryCount,
    SUM(pd.QuantityDelivered) AS TotalQuantity
FROM ProductDeliveries pd
INNER JOIN Products p ON pd.ProductID = p.ProductID
INNER JOIN Suppliers s ON pd.SupplierID = s.SupplierID
WHERE pd.DeliveryStatus = 'Delivered'
GROUP BY p.ProductID, p.ProductName, s.SupplierID, s.SupplierName
ORDER BY p.ProductName, AvgCost ASC;

-- ============================================
-- STORED PROCEDURE FOR RECORDING NEW DELIVERY
-- ============================================

DELIMITER //

CREATE PROCEDURE sp_RecordDelivery(
    IN p_ProductID INT,
    IN p_SupplierID INT,
    IN p_StoreID INT,
    IN p_QuantityDelivered INT,
    IN p_UnitCost DECIMAL(10,2),
    IN p_DeliveryStatus VARCHAR(20),
    IN p_Notes TEXT
)
BEGIN
    -- Insert the delivery record
    INSERT INTO ProductDeliveries (
        ProductID, 
        SupplierID, 
        StoreID, 
        QuantityDelivered, 
        UnitCost, 
        DeliveryStatus, 
        Notes
    ) VALUES (
        p_ProductID,
        p_SupplierID,
        p_StoreID,
        p_QuantityDelivered,
        p_UnitCost,
        p_DeliveryStatus,
        p_Notes
    );
    
    -- If delivery is complete, update inventory
    IF p_DeliveryStatus = 'Delivered' THEN
        UPDATE Inventory
        SET QuantityOnHand = QuantityOnHand + p_QuantityDelivered,
            LastRestocked = CURRENT_TIMESTAMP
        WHERE ProductID = p_ProductID AND StoreID = p_StoreID;
    END IF;
    
    SELECT LAST_INSERT_ID() AS DeliveryID;
END //

DELIMITER ;

-- ============================================
-- USAGE EXAMPLE
-- ============================================

-- Record a new delivery
-- CALL sp_RecordDelivery(1, 1, 1, 50, 45.00, 'Delivered', 'Regular monthly restock');
