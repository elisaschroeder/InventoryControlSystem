-- =====================================================
-- DELAYED DELIVERIES ANALYSIS
-- =====================================================
-- This file contains OPTIMIZED queries to analyze supplier delivery performance
-- based on lead times (OrderDate to DeliveryDate)
--
-- Author: Elisa Schroeder
-- Created: 2025
-- Optimized: November 12, 2025
-- =====================================================

USE InventoryControlDB;

-- =====================================================
-- OPTIMIZATION NOTE:
-- These queries use composite indexes and summary tables
-- for better performance. Run database_optimizations.sql first.
-- =====================================================

-- =====================================================
-- 1. TOP 3 SUPPLIERS WITH MOST DELAYED DELIVERIES (OPTIMIZED)
-- =====================================================
-- Definition: A delivery is "delayed" if lead time > 4 days
-- (based on standard 3-4 day expected lead time)
-- 
-- OPTIMIZATION: Uses composite index idx_delivery_status_dates
-- and SupplierPerformanceSummary table for faster execution

-- Option A: Using summary table (FASTEST - recommended for reports)
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
    -- Get max lead time from real-time data
    (SELECT MAX(TIMESTAMPDIFF(DAY, pd2.OrderDate, pd2.DeliveryDate))
     FROM ProductDeliveries pd2
     WHERE pd2.SupplierID = s.SupplierID
       AND pd2.DeliveryStatus = 'Delivered'
       AND pd2.OrderDate IS NOT NULL
       AND pd2.DeliveryDate IS NOT NULL) AS MaxLeadTimeDays,
    sps.TotalUnitsDelivered,
    sps.TotalValueDelivered
FROM Suppliers s
INNER JOIN SupplierPerformanceSummary sps ON s.SupplierID = sps.SupplierID
WHERE sps.DelayedDeliveryCount > 0
ORDER BY sps.DelayedDeliveryCount DESC, sps.AvgLeadTimeDays DESC
LIMIT 3;

-- Option B: Real-time calculation (use when summary table not available)
-- Uses FORCE INDEX for optimal query plan

-- Option B: Real-time calculation (use when summary table not available)
-- Uses FORCE INDEX for optimal query plan
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
        WHEN TIMESTAMPDIFF(DAY, pd.OrderDate, pd.DeliveryDate) > 4 
        THEN pd.DeliveryID 
    END) AS DelayedDeliveries,
    ROUND(AVG(CASE 
        WHEN pd.OrderDate IS NOT NULL AND pd.DeliveryDate IS NOT NULL 
        THEN TIMESTAMPDIFF(DAY, pd.OrderDate, pd.DeliveryDate) 
    END), 1) AS AvgLeadTimeDays,
    MAX(CASE 
        WHEN pd.OrderDate IS NOT NULL AND pd.DeliveryDate IS NOT NULL 
        THEN TIMESTAMPDIFF(DAY, pd.OrderDate, pd.DeliveryDate) 
    END) AS MaxLeadTimeDays,
    COALESCE(SUM(pd.QuantityDelivered), 0) AS TotalStockDelivered,
    COALESCE(SUM(pd.TotalCost), 0) AS TotalValue
FROM Suppliers s
INNER JOIN Products p ON s.SupplierID = p.SupplierID AND p.IsActive = TRUE
INNER JOIN ProductDeliveries pd FORCE INDEX (idx_delivery_status_dates)
    ON s.SupplierID = pd.SupplierID 
    AND pd.DeliveryStatus = 'Delivered'
    AND pd.OrderDate IS NOT NULL
    AND pd.DeliveryDate IS NOT NULL
GROUP BY s.SupplierID, s.SupplierName, s.ContactName, s.Email, s.Phone, s.City, s.Country, s.Rating
HAVING DelayedDeliveries > 0
ORDER BY DelayedDeliveries DESC, AvgLeadTimeDays DESC
LIMIT 3;

-- =====================================================
-- 2. ALL DELAYED DELIVERIES (> 4 DAYS LEAD TIME) - OPTIMIZED
-- =====================================================
-- OPTIMIZATION: Uses composite index for filtering
-- Pre-calculates lead time to avoid multiple function calls

-- =====================================================
-- 2. ALL DELAYED DELIVERIES (> 4 DAYS LEAD TIME) - OPTIMIZED
-- =====================================================
-- OPTIMIZATION: Uses composite index for filtering
-- Pre-calculates lead time to avoid multiple function calls

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
FROM ProductDeliveries pd FORCE INDEX (idx_delivery_status_dates)
INNER JOIN Suppliers s ON pd.SupplierID = s.SupplierID
INNER JOIN Products p ON pd.ProductID = p.ProductID
INNER JOIN Stores st ON pd.StoreID = st.StoreID
WHERE pd.DeliveryStatus = 'Delivered'
    AND pd.OrderDate IS NOT NULL
    AND pd.DeliveryDate IS NOT NULL
    AND TIMESTAMPDIFF(DAY, pd.OrderDate, pd.DeliveryDate) > 4
ORDER BY LeadTimeDays DESC, pd.DeliveryDate DESC;

-- =====================================================
-- 3. SUPPLIER DELIVERY PERFORMANCE SUMMARY - OPTIMIZED
-- =====================================================
-- Shows average, min, max lead times for all suppliers
-- OPTIMIZATION: Uses SupplierPerformanceSummary when available

-- Option A: Using summary table (FASTEST)
SELECT 
    s.SupplierID,
    s.SupplierName,
    s.Rating,
    sps.TotalDeliveries,
    sps.DelayedDeliveryCount,
    CONCAT(ROUND((sps.DelayedDeliveryCount * 100.0 / NULLIF(sps.TotalDeliveries, 0)), 1), '%') AS DelayRate,
    sps.AvgLeadTimeDays,
    -- Min/Max calculated from real-time data
    (SELECT MIN(TIMESTAMPDIFF(DAY, pd2.OrderDate, pd2.DeliveryDate))
     FROM ProductDeliveries pd2
     WHERE pd2.SupplierID = s.SupplierID
       AND pd2.DeliveryStatus = 'Delivered'
       AND pd2.OrderDate IS NOT NULL
       AND pd2.DeliveryDate IS NOT NULL) AS MinLeadTimeDays,
    (SELECT MAX(TIMESTAMPDIFF(DAY, pd2.OrderDate, pd2.DeliveryDate))
     FROM ProductDeliveries pd2
     WHERE pd2.SupplierID = s.SupplierID
       AND pd2.DeliveryStatus = 'Delivered'
       AND pd2.OrderDate IS NOT NULL
       AND pd2.DeliveryDate IS NOT NULL) AS MaxLeadTimeDays,
    sps.TotalValueDelivered
FROM Suppliers s
INNER JOIN SupplierPerformanceSummary sps ON s.SupplierID = sps.SupplierID
ORDER BY sps.DelayedDeliveryCount DESC, sps.AvgLeadTimeDays DESC;

-- Option B: Real-time calculation (use when summary not available)
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
        END) * 100.0 / NULLIF(COUNT(DISTINCT pd.DeliveryID), 0)), 1), 
        '%'
    ) AS DelayRate,
    ROUND(AVG(TIMESTAMPDIFF(DAY, pd.OrderDate, pd.DeliveryDate)), 1) AS AvgLeadTimeDays,
    MIN(TIMESTAMPDIFF(DAY, pd.OrderDate, pd.DeliveryDate)) AS MinLeadTimeDays,
    MAX(TIMESTAMPDIFF(DAY, pd.OrderDate, pd.DeliveryDate)) AS MaxLeadTimeDays,
    COALESCE(SUM(pd.TotalCost), 0) AS TotalValue
FROM Suppliers s
INNER JOIN ProductDeliveries pd FORCE INDEX (idx_delivery_status_dates)
    ON s.SupplierID = pd.SupplierID
WHERE pd.DeliveryStatus = 'Delivered'
    AND pd.OrderDate IS NOT NULL
    AND pd.DeliveryDate IS NOT NULL
GROUP BY s.SupplierID, s.SupplierName, s.Rating
ORDER BY DelayedDeliveries DESC, AvgLeadTimeDays DESC;

-- =====================================================
-- 4. MONTHLY DELIVERY PERFORMANCE TREND - OPTIMIZED
-- =====================================================
-- Analyzes delivery delays by month
-- OPTIMIZATION: Reduced redundant CASE expressions

SELECT 
    DATE_FORMAT(pd.DeliveryDate, '%Y-%m') AS DeliveryMonth,
    COUNT(pd.DeliveryID) AS TotalDeliveries,
    SUM(CASE WHEN TIMESTAMPDIFF(DAY, pd.OrderDate, pd.DeliveryDate) > 4 THEN 1 ELSE 0 END) AS DelayedDeliveries,
    CONCAT(
        ROUND((SUM(CASE WHEN TIMESTAMPDIFF(DAY, pd.OrderDate, pd.DeliveryDate) > 4 THEN 1 ELSE 0 END) * 100.0 / 
               NULLIF(COUNT(pd.DeliveryID), 0)), 1), 
        '%'
    ) AS DelayRate,
    ROUND(AVG(TIMESTAMPDIFF(DAY, pd.OrderDate, pd.DeliveryDate)), 1) AS AvgLeadTimeDays,
    COALESCE(SUM(pd.TotalCost), 0) AS TotalValue
FROM ProductDeliveries pd FORCE INDEX (idx_delivery_status_dates)
WHERE pd.DeliveryStatus = 'Delivered'
    AND pd.OrderDate IS NOT NULL
    AND pd.DeliveryDate IS NOT NULL
GROUP BY DeliveryMonth
ORDER BY DeliveryMonth DESC;

-- =====================================================
-- 5. DELIVERIES BY LEAD TIME BUCKET - OPTIMIZED
-- =====================================================
-- Categorizes deliveries into lead time ranges
-- OPTIMIZATION: Calculate lead time once, use in CASE

SELECT 
    LeadTimeBucket,
    COUNT(DeliveryID) AS DeliveryCount,
    ROUND(AVG(LeadTimeDays), 1) AS AvgLeadTimeDays,
    SUM(QuantityDelivered) AS TotalUnitsDelivered,
    SUM(TotalCost) AS TotalValue
FROM (
    SELECT 
        pd.DeliveryID,
        pd.QuantityDelivered,
        pd.TotalCost,
        TIMESTAMPDIFF(DAY, pd.OrderDate, pd.DeliveryDate) AS LeadTimeDays,
        CASE 
            WHEN TIMESTAMPDIFF(DAY, pd.OrderDate, pd.DeliveryDate) <= 2 THEN '1-2 days (Express)'
            WHEN TIMESTAMPDIFF(DAY, pd.OrderDate, pd.DeliveryDate) <= 4 THEN '3-4 days (Standard)'
            WHEN TIMESTAMPDIFF(DAY, pd.OrderDate, pd.DeliveryDate) <= 7 THEN '5-7 days (Delayed)'
            WHEN TIMESTAMPDIFF(DAY, pd.OrderDate, pd.DeliveryDate) <= 14 THEN '8-14 days (Very Delayed)'
            ELSE '15+ days (Critical Delay)'
        END AS LeadTimeBucket
    FROM ProductDeliveries pd FORCE INDEX (idx_delivery_status_dates)
    WHERE pd.DeliveryStatus = 'Delivered'
        AND pd.OrderDate IS NOT NULL
        AND pd.DeliveryDate IS NOT NULL
) AS DeliveryWithBuckets
GROUP BY LeadTimeBucket
ORDER BY AvgLeadTimeDays;

-- =====================================================
-- 6. WORST INDIVIDUAL DELAYED DELIVERIES - OPTIMIZED
-- =====================================================
-- Shows top 10 most delayed individual deliveries
-- OPTIMIZATION: Uses STRAIGHT_JOIN to force join order

SELECT STRAIGHT_JOIN
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
FROM ProductDeliveries pd FORCE INDEX (idx_delivery_status_dates)
INNER JOIN Suppliers s ON pd.SupplierID = s.SupplierID
INNER JOIN Products p ON pd.ProductID = p.ProductID
INNER JOIN Stores st ON pd.StoreID = st.StoreID
WHERE pd.DeliveryStatus = 'Delivered'
    AND pd.OrderDate IS NOT NULL
    AND pd.DeliveryDate IS NOT NULL
ORDER BY LeadTimeDays DESC, pd.DeliveryDate DESC
LIMIT 10;

-- =====================================================
-- 7. SUPPLIER DELAY HEATMAP - NEW OPTIMIZED QUERY
-- =====================================================
-- Shows which suppliers have delays for which product categories
-- Useful for identifying patterns

SELECT 
    s.SupplierName,
    c.CategoryName,
    COUNT(pd.DeliveryID) AS TotalDeliveries,
    SUM(CASE WHEN TIMESTAMPDIFF(DAY, pd.OrderDate, pd.DeliveryDate) > 4 THEN 1 ELSE 0 END) AS DelayedCount,
    ROUND(AVG(TIMESTAMPDIFF(DAY, pd.OrderDate, pd.DeliveryDate)), 1) AS AvgLeadTime,
    MAX(TIMESTAMPDIFF(DAY, pd.OrderDate, pd.DeliveryDate)) AS MaxLeadTime
FROM ProductDeliveries pd FORCE INDEX (idx_delivery_status_dates)
INNER JOIN Suppliers s ON pd.SupplierID = s.SupplierID
INNER JOIN Products p ON pd.ProductID = p.ProductID
INNER JOIN Categories c ON p.CategoryID = c.CategoryID
WHERE pd.DeliveryStatus = 'Delivered'
    AND pd.OrderDate IS NOT NULL
    AND pd.DeliveryDate IS NOT NULL
GROUP BY s.SupplierID, s.SupplierName, c.CategoryID, c.CategoryName
HAVING DelayedCount > 0
ORDER BY DelayedCount DESC, AvgLeadTime DESC;

-- =====================================================
-- END OF FILE
-- =====================================================
