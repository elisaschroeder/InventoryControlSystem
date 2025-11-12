-- =====================================================
-- DELAYED DELIVERIES ANALYSIS
-- =====================================================
-- This file contains queries to analyze supplier delivery performance
-- based on lead times (OrderDate to DeliveryDate)
--
-- Author: Elisa Schroeder
-- Created: 2025
-- =====================================================

USE InventoryControlDB;

-- =====================================================
-- 1. TOP 3 SUPPLIERS WITH MOST DELAYED DELIVERIES
-- =====================================================
-- Definition: A delivery is "delayed" if lead time > 4 days
-- (based on standard 3-4 day expected lead time)

SELECT 
    s.SupplierID,
    s.SupplierName,
    s.ContactName,
    s.Email,
    s.Phone,
    s.City,
    s.Country,
    s.Rating,
    COUNT(DISTINCT p.ProductID) AS ProductCount,
    COUNT(DISTINCT pd.DeliveryID) AS TotalDeliveries,
    COUNT(DISTINCT CASE 
        WHEN pd.OrderDate IS NOT NULL 
        AND pd.DeliveryDate IS NOT NULL 
        AND TIMESTAMPDIFF(DAY, pd.OrderDate, pd.DeliveryDate) > 4 
        THEN pd.DeliveryID 
    END) AS DelayedDeliveries,
    COALESCE(AVG(CASE 
        WHEN pd.OrderDate IS NOT NULL AND pd.DeliveryDate IS NOT NULL 
        THEN TIMESTAMPDIFF(DAY, pd.OrderDate, pd.DeliveryDate) 
    END), 0) AS AvgLeadTimeDays,
    COALESCE(MAX(CASE 
        WHEN pd.OrderDate IS NOT NULL AND pd.DeliveryDate IS NOT NULL 
        THEN TIMESTAMPDIFF(DAY, pd.OrderDate, pd.DeliveryDate) 
    END), 0) AS MaxLeadTimeDays,
    COALESCE(SUM(pd.QuantityDelivered), 0) AS TotalStockDelivered,
    COALESCE(SUM(pd.TotalCost), 0) AS TotalValue
FROM Suppliers s
INNER JOIN Products p ON s.SupplierID = p.SupplierID
INNER JOIN ProductDeliveries pd ON s.SupplierID = pd.SupplierID 
    AND pd.DeliveryStatus = 'Delivered'
    AND pd.OrderDate IS NOT NULL
    AND pd.DeliveryDate IS NOT NULL
WHERE p.IsActive = TRUE
GROUP BY s.SupplierID, s.SupplierName, s.ContactName, s.Email, s.Phone, s.City, s.Country, s.Rating
HAVING DelayedDeliveries > 0
ORDER BY DelayedDeliveries DESC, AvgLeadTimeDays DESC
LIMIT 3;

-- =====================================================
-- 2. ALL DELAYED DELIVERIES (> 4 DAYS LEAD TIME)
-- =====================================================

SELECT 
    pd.DeliveryID,
    s.SupplierName,
    p.ProductName,
    pd.OrderDate,
    pd.DeliveryDate,
    TIMESTAMPDIFF(DAY, pd.OrderDate, pd.DeliveryDate) AS LeadTimeDays,
    pd.QuantityDelivered,
    pd.TotalCost,
    st.StoreName
FROM ProductDeliveries pd
INNER JOIN Suppliers s ON pd.SupplierID = s.SupplierID
INNER JOIN Products p ON pd.ProductID = p.ProductID
INNER JOIN Stores st ON pd.StoreID = st.StoreID
WHERE pd.DeliveryStatus = 'Delivered'
    AND pd.OrderDate IS NOT NULL
    AND pd.DeliveryDate IS NOT NULL
    AND TIMESTAMPDIFF(DAY, pd.OrderDate, pd.DeliveryDate) > 4
ORDER BY LeadTimeDays DESC, pd.DeliveryDate DESC;

-- =====================================================
-- 3. SUPPLIER DELIVERY PERFORMANCE SUMMARY
-- =====================================================
-- Shows average, min, max lead times for all suppliers

SELECT 
    s.SupplierID,
    s.SupplierName,
    s.Rating,
    COUNT(DISTINCT pd.DeliveryID) AS TotalDeliveries,
    COUNT(DISTINCT CASE 
        WHEN TIMESTAMPDIFF(DAY, pd.OrderDate, pd.DeliveryDate) > 4 
        THEN pd.DeliveryID 
    END) AS DelayedDeliveries,
    CONCAT(
        ROUND((COUNT(DISTINCT CASE 
            WHEN TIMESTAMPDIFF(DAY, pd.OrderDate, pd.DeliveryDate) > 4 
            THEN pd.DeliveryID 
        END) * 100.0 / COUNT(DISTINCT pd.DeliveryID)), 1), 
        '%'
    ) AS DelayRate,
    ROUND(AVG(TIMESTAMPDIFF(DAY, pd.OrderDate, pd.DeliveryDate)), 1) AS AvgLeadTimeDays,
    MIN(TIMESTAMPDIFF(DAY, pd.OrderDate, pd.DeliveryDate)) AS MinLeadTimeDays,
    MAX(TIMESTAMPDIFF(DAY, pd.OrderDate, pd.DeliveryDate)) AS MaxLeadTimeDays,
    COALESCE(SUM(pd.TotalCost), 0) AS TotalValue
FROM Suppliers s
INNER JOIN ProductDeliveries pd ON s.SupplierID = pd.SupplierID
WHERE pd.DeliveryStatus = 'Delivered'
    AND pd.OrderDate IS NOT NULL
    AND pd.DeliveryDate IS NOT NULL
GROUP BY s.SupplierID, s.SupplierName, s.Rating
ORDER BY DelayedDeliveries DESC, AvgLeadTimeDays DESC;

-- =====================================================
-- 4. MONTHLY DELIVERY PERFORMANCE TREND
-- =====================================================
-- Analyzes delivery delays by month

SELECT 
    DATE_FORMAT(pd.DeliveryDate, '%Y-%m') AS DeliveryMonth,
    COUNT(DISTINCT pd.DeliveryID) AS TotalDeliveries,
    COUNT(DISTINCT CASE 
        WHEN TIMESTAMPDIFF(DAY, pd.OrderDate, pd.DeliveryDate) > 4 
        THEN pd.DeliveryID 
    END) AS DelayedDeliveries,
    CONCAT(
        ROUND((COUNT(DISTINCT CASE 
            WHEN TIMESTAMPDIFF(DAY, pd.OrderDate, pd.DeliveryDate) > 4 
            THEN pd.DeliveryID 
        END) * 100.0 / COUNT(DISTINCT pd.DeliveryID)), 1), 
        '%'
    ) AS DelayRate,
    ROUND(AVG(TIMESTAMPDIFF(DAY, pd.OrderDate, pd.DeliveryDate)), 1) AS AvgLeadTimeDays,
    COALESCE(SUM(pd.TotalCost), 0) AS TotalValue
FROM ProductDeliveries pd
WHERE pd.DeliveryStatus = 'Delivered'
    AND pd.OrderDate IS NOT NULL
    AND pd.DeliveryDate IS NOT NULL
GROUP BY DeliveryMonth
ORDER BY DeliveryMonth DESC;

-- =====================================================
-- 5. DELIVERIES BY LEAD TIME BUCKET
-- =====================================================
-- Categorizes deliveries into lead time ranges

SELECT 
    CASE 
        WHEN TIMESTAMPDIFF(DAY, pd.OrderDate, pd.DeliveryDate) <= 2 THEN '1-2 days (Express)'
        WHEN TIMESTAMPDIFF(DAY, pd.OrderDate, pd.DeliveryDate) <= 4 THEN '3-4 days (Standard)'
        WHEN TIMESTAMPDIFF(DAY, pd.OrderDate, pd.DeliveryDate) <= 7 THEN '5-7 days (Delayed)'
        WHEN TIMESTAMPDIFF(DAY, pd.OrderDate, pd.DeliveryDate) <= 14 THEN '8-14 days (Very Delayed)'
        ELSE '15+ days (Critical Delay)'
    END AS LeadTimeBucket,
    COUNT(DISTINCT pd.DeliveryID) AS DeliveryCount,
    ROUND(AVG(TIMESTAMPDIFF(DAY, pd.OrderDate, pd.DeliveryDate)), 1) AS AvgLeadTimeDays,
    COALESCE(SUM(pd.QuantityDelivered), 0) AS TotalUnitsDelivered,
    COALESCE(SUM(pd.TotalCost), 0) AS TotalValue
FROM ProductDeliveries pd
WHERE pd.DeliveryStatus = 'Delivered'
    AND pd.OrderDate IS NOT NULL
    AND pd.DeliveryDate IS NOT NULL
GROUP BY LeadTimeBucket
ORDER BY AvgLeadTimeDays;

-- =====================================================
-- 6. WORST INDIVIDUAL DELAYED DELIVERIES
-- =====================================================
-- Shows top 10 most delayed individual deliveries

SELECT 
    pd.DeliveryID,
    s.SupplierName,
    p.ProductName,
    st.StoreName,
    pd.OrderDate,
    pd.DeliveryDate,
    TIMESTAMPDIFF(DAY, pd.OrderDate, pd.DeliveryDate) AS LeadTimeDays,
    pd.QuantityDelivered,
    pd.UnitCost,
    pd.TotalCost,
    CONCAT('$', FORMAT(pd.TotalCost, 2)) AS FormattedTotalCost
FROM ProductDeliveries pd
INNER JOIN Suppliers s ON pd.SupplierID = s.SupplierID
INNER JOIN Products p ON pd.ProductID = p.ProductID
INNER JOIN Stores st ON pd.StoreID = st.StoreID
WHERE pd.DeliveryStatus = 'Delivered'
    AND pd.OrderDate IS NOT NULL
    AND pd.DeliveryDate IS NOT NULL
ORDER BY LeadTimeDays DESC
LIMIT 10;

-- =====================================================
-- END OF FILE
-- =====================================================
