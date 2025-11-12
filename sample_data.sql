-- ============================================
-- Sample Data for Inventory Control System
-- ============================================

USE InventoryControlDB;

-- Insert Stores
INSERT INTO Stores (StoreName, StoreAddress, City, State, ZipCode, Phone, ManagerName) VALUES
('Downtown Store', '123 Main Street', 'New York', 'NY', '10001', '212-555-0101', 'John Smith'),
('Westside Branch', '456 Oak Avenue', 'Los Angeles', 'CA', '90001', '310-555-0202', 'Sarah Johnson'),
('Northgate Mall', '789 Pine Road', 'Chicago', 'IL', '60601', '312-555-0303', 'Michael Chen'),
('Eastside Plaza', '321 Elm Street', 'Houston', 'TX', '77001', '713-555-0404', 'Emily Davis'),
('Southpoint Center', '654 Maple Drive', 'Phoenix', 'AZ', '85001', '602-555-0505', 'Robert Wilson');

-- Insert Categories
INSERT INTO Categories (CategoryName, Description) VALUES
('Electronics', 'Electronic devices and accessories'),
('Clothing', 'Apparel and fashion items'),
('Home & Garden', 'Home improvement and garden supplies'),
('Sports & Outdoors', 'Sports equipment and outdoor gear'),
('Books & Media', 'Books, magazines, and media products'),
('Toys & Games', 'Toys and gaming products'),
('Food & Beverages', 'Packaged food and drink items'),
('Health & Beauty', 'Personal care and beauty products'),
('Office Supplies', 'Office and stationery products'),
('Automotive', 'Auto parts and accessories');

-- Insert Suppliers
INSERT INTO Suppliers (SupplierName, ContactName, Email, Phone, Address, City, Country, Rating) VALUES
('TechWorld Distributors', 'David Kim', 'david@techworld.com', '555-1001', '100 Tech Blvd', 'San Francisco', 'USA', 4.5),
('Fashion Forward LLC', 'Lisa Anderson', 'lisa@fashionforward.com', '555-1002', '200 Style Street', 'Milan', 'Italy', 4.8),
('HomeGood Suppliers', 'James Brown', 'james@homegood.com', '555-1003', '300 Garden Way', 'Portland', 'USA', 4.2),
('SportsPro International', 'Maria Garcia', 'maria@sportspro.com', '555-1004', '400 Athletic Ave', 'Munich', 'Germany', 4.6),
('Media Masters Inc', 'Thomas Lee', 'thomas@mediamasters.com', '555-1005', '500 Book Lane', 'London', 'UK', 4.3),
('Global Electronics', 'Anna Martinez', 'anna@globalelec.com', '555-1006', '600 Circuit Rd', 'Shenzhen', 'China', 4.7),
('Beauty Supply Co', 'Patricia Taylor', 'patricia@beautysupply.com', '555-1007', '700 Cosmetic Dr', 'Paris', 'France', 4.9),
('Office Essentials', 'Christopher White', 'chris@officeess.com', '555-1008', '800 Paper St', 'Boston', 'USA', 4.4);

-- Insert Products
INSERT INTO Products (ProductName, SKU, CategoryID, SupplierID, UnitPrice, Description, ReorderLevel, IsActive) VALUES
-- Electronics
('Wireless Bluetooth Headphones', 'ELEC-001', 1, 1, 79.99, 'Premium noise-canceling headphones', 15, TRUE),
('Smart Watch Series 5', 'ELEC-002', 1, 6, 299.99, 'Advanced fitness and health tracking', 10, TRUE),
('USB-C Charging Cable', 'ELEC-003', 1, 1, 12.99, '6ft fast charging cable', 50, TRUE),
('Portable Power Bank', 'ELEC-004', 1, 6, 45.99, '20000mAh capacity', 25, TRUE),
('Wireless Mouse', 'ELEC-005', 1, 1, 24.99, 'Ergonomic wireless mouse', 30, TRUE),

-- Clothing
('Classic Cotton T-Shirt', 'CLTH-001', 2, 2, 19.99, 'Comfortable everyday wear', 100, TRUE),
('Denim Jeans', 'CLTH-002', 2, 2, 49.99, 'Premium quality denim', 50, TRUE),
('Winter Jacket', 'CLTH-003', 2, 2, 129.99, 'Waterproof insulated jacket', 20, TRUE),
('Running Shoes', 'CLTH-004', 2, 4, 89.99, 'Lightweight performance shoes', 40, TRUE),

-- Home & Garden
('Ceramic Plant Pot Set', 'HOME-001', 3, 3, 34.99, 'Set of 3 decorative pots', 25, TRUE),
('LED Desk Lamp', 'HOME-002', 3, 3, 39.99, 'Adjustable brightness lamp', 20, TRUE),
('Kitchen Knife Set', 'HOME-003', 3, 3, 79.99, 'Professional 8-piece set', 15, TRUE),

-- Sports & Outdoors
('Yoga Mat Premium', 'SPRT-001', 4, 4, 29.99, 'Non-slip exercise mat', 35, TRUE),
('Camping Tent 4-Person', 'SPRT-002', 4, 4, 199.99, 'Weather-resistant tent', 10, TRUE),
('Stainless Water Bottle', 'SPRT-003', 4, 4, 24.99, '32oz insulated bottle', 40, TRUE),

-- Books & Media
('Bestseller Fiction Novel', 'BOOK-001', 5, 5, 14.99, 'Latest bestseller', 30, TRUE),
('Productivity Planner 2025', 'BOOK-002', 5, 5, 22.99, 'Daily goal planner', 40, TRUE),

-- Office Supplies
('Ballpoint Pen Pack', 'OFFC-001', 9, 8, 8.99, 'Pack of 12 pens', 100, TRUE),
('Spiral Notebook A4', 'OFFC-002', 9, 8, 6.99, '200 pages ruled', 80, TRUE),
('Desk Organizer', 'OFFC-003', 9, 8, 16.99, 'Multi-compartment organizer', 30, TRUE),

-- Health & Beauty
('Natural Moisturizer', 'HLTH-001', 8, 7, 24.99, 'Organic face moisturizer', 45, TRUE),
('Vitamin C Supplement', 'HLTH-002', 8, 7, 18.99, '90 tablets', 50, TRUE);

-- Insert Inventory (distributing products across stores)
INSERT INTO Inventory (ProductID, StoreID, QuantityOnHand, QuantityReserved, MinimumStock, MaximumStock, LastRestocked) VALUES
-- Store 1 (Downtown Store)
(1, 1, 45, 5, 15, 100, '2025-11-01 10:00:00'),
(2, 1, 12, 2, 10, 50, '2025-11-05 14:30:00'),
(3, 1, 150, 10, 50, 300, '2025-11-10 09:00:00'),
(4, 1, 30, 3, 25, 80, '2025-11-08 11:00:00'),
(5, 1, 55, 5, 30, 100, '2025-11-07 16:00:00'),
(6, 1, 200, 20, 100, 500, '2025-11-01 08:00:00'),
(10, 1, 40, 2, 25, 100, '2025-11-09 10:00:00'),
(18, 1, 120, 10, 100, 300, '2025-11-11 12:00:00'),

-- Store 2 (Westside Branch)
(1, 2, 38, 3, 15, 100, '2025-11-02 10:00:00'),
(2, 2, 8, 1, 10, 50, '2025-11-06 14:30:00'),
(3, 2, 175, 15, 50, 300, '2025-11-09 09:00:00'),
(7, 2, 65, 5, 50, 200, '2025-11-03 10:00:00'),
(8, 2, 15, 2, 20, 80, '2025-11-04 11:00:00'),
(13, 2, 42, 2, 35, 100, '2025-11-10 15:00:00'),
(20, 2, 55, 5, 45, 150, '2025-11-08 09:00:00'),

-- Store 3 (Northgate Mall)
(1, 3, 22, 2, 15, 100, '2025-11-03 10:00:00'),
(4, 3, 18, 2, 25, 80, '2025-11-07 11:00:00'),
(5, 3, 48, 3, 30, 100, '2025-11-06 16:00:00'),
(9, 3, 50, 5, 40, 150, '2025-11-05 13:00:00'),
(11, 3, 28, 3, 20, 80, '2025-11-08 14:00:00'),
(16, 3, 35, 5, 30, 100, '2025-11-11 10:00:00'),
(21, 3, 60, 5, 50, 200, '2025-11-09 11:00:00'),

-- Store 4 (Eastside Plaza)
(2, 4, 15, 1, 10, 50, '2025-11-04 14:30:00'),
(3, 4, 140, 12, 50, 300, '2025-11-08 09:00:00'),
(6, 4, 180, 15, 100, 500, '2025-11-02 08:00:00'),
(7, 4, 70, 8, 50, 200, '2025-11-05 10:00:00'),
(12, 4, 25, 2, 15, 60, '2025-11-07 12:00:00'),
(14, 4, 5, 0, 10, 40, '2025-10-28 10:00:00'),
(19, 4, 95, 8, 80, 250, '2025-11-10 13:00:00'),

-- Store 5 (Southpoint Center)
(1, 5, 50, 4, 15, 100, '2025-11-05 10:00:00'),
(5, 5, 40, 4, 30, 100, '2025-11-09 16:00:00'),
(8, 5, 18, 3, 20, 80, '2025-11-06 11:00:00'),
(10, 5, 38, 3, 25, 100, '2025-11-11 10:00:00'),
(13, 5, 50, 3, 35, 100, '2025-11-08 15:00:00'),
(15, 5, 28, 2, 40, 120, '2025-11-07 14:00:00'),
(17, 5, 45, 5, 30, 120, '2025-11-10 11:00:00');

-- Insert Sales (sample transaction data)
INSERT INTO Sales (ProductID, StoreID, QuantitySold, SalePrice, SaleDate, TransactionID) VALUES
-- Recent sales from the last 30 days
(1, 1, 2, 79.99, '2025-11-12 10:30:00', 'TXN-20251112-001'),
(3, 1, 5, 12.99, '2025-11-12 11:15:00', 'TXN-20251112-002'),
(6, 1, 3, 19.99, '2025-11-12 14:20:00', 'TXN-20251112-003'),
(2, 1, 1, 299.99, '2025-11-11 09:45:00', 'TXN-20251111-001'),
(5, 1, 2, 24.99, '2025-11-11 16:30:00', 'TXN-20251111-002'),
(10, 1, 1, 34.99, '2025-11-10 12:00:00', 'TXN-20251110-001'),

(1, 2, 1, 79.99, '2025-11-12 13:00:00', 'TXN-20251112-004'),
(3, 2, 8, 12.99, '2025-11-11 10:30:00', 'TXN-20251111-003'),
(7, 2, 2, 49.99, '2025-11-10 15:45:00', 'TXN-20251110-002'),
(13, 2, 1, 29.99, '2025-11-09 11:20:00', 'TXN-20251109-001'),

(1, 3, 3, 79.99, '2025-11-11 14:15:00', 'TXN-20251111-004'),
(9, 3, 2, 89.99, '2025-11-10 16:00:00', 'TXN-20251110-003'),
(11, 3, 1, 39.99, '2025-11-09 13:30:00', 'TXN-20251109-002'),

(2, 4, 1, 299.99, '2025-11-12 11:00:00', 'TXN-20251112-005'),
(6, 4, 5, 19.99, '2025-11-11 12:30:00', 'TXN-20251111-005'),
(7, 4, 3, 49.99, '2025-11-10 14:45:00', 'TXN-20251110-004'),

(1, 5, 2, 79.99, '2025-11-12 15:30:00', 'TXN-20251112-006'),
(8, 5, 1, 129.99, '2025-11-11 10:00:00', 'TXN-20251111-006'),
(13, 5, 2, 29.99, '2025-11-10 17:00:00', 'TXN-20251110-005'),

-- Sales from previous weeks
(3, 1, 10, 12.99, '2025-11-05 10:00:00', 'TXN-20251105-001'),
(6, 2, 8, 19.99, '2025-11-04 14:00:00', 'TXN-20251104-001'),
(1, 3, 4, 79.99, '2025-11-03 11:00:00', 'TXN-20251103-001'),
(2, 4, 2, 299.99, '2025-11-02 16:00:00', 'TXN-20251102-001'),
(9, 3, 3, 89.99, '2025-11-01 13:00:00', 'TXN-20251101-001'),

-- October sales
(1, 1, 5, 79.99, '2025-10-28 10:00:00', 'TXN-20251028-001'),
(5, 2, 4, 24.99, '2025-10-25 14:00:00', 'TXN-20251025-001'),
(7, 4, 6, 49.99, '2025-10-22 15:00:00', 'TXN-20251022-001'),
(13, 2, 3, 29.99, '2025-10-20 11:00:00', 'TXN-20251020-001'),
(18, 1, 12, 8.99, '2025-10-18 09:00:00', 'TXN-20251018-001');

-- ============================================
-- Insert Product Deliveries (tracking supplier deliveries)
-- ============================================
INSERT INTO ProductDeliveries (ProductID, SupplierID, StoreID, QuantityDelivered, OrderDate, DeliveryDate, UnitCost, DeliveryStatus, Notes) VALUES
-- November deliveries
(1, 1, 1, 50, '2025-10-25 08:00:00', '2025-11-01 10:00:00', 45.00, 'Delivered', 'Wireless Bluetooth Headphones restocking'),
(2, 6, 1, 15, '2025-10-31 09:00:00', '2025-11-05 14:30:00', 180.00, 'Delivered', 'Smart Watch Series 5 delivery'),
(3, 1, 1, 200, '2025-11-04 08:00:00', '2025-11-10 09:00:00', 6.50, 'Delivered', 'USB-C Charging Cable bulk order'),
(3, 1, 2, 200, '2025-11-03 08:00:00', '2025-11-09 09:00:00', 6.50, 'Delivered', 'USB-C Charging Cable bulk order'),
(4, 6, 1, 35, '2025-11-02 10:00:00', '2025-11-08 11:00:00', 25.00, 'Delivered', 'Portable Power Bank'),

(1, 1, 2, 45, '2025-10-29 08:00:00', '2025-11-02 10:00:00', 45.00, 'Delivered', 'Headphones for Westside Branch'),
(2, 6, 2, 10, '2025-11-02 09:00:00', '2025-11-06 14:30:00', 180.00, 'Delivered', 'Smart Watch delivery'),
(7, 2, 2, 70, '2025-10-30 10:00:00', '2025-11-03 10:00:00', 28.00, 'Delivered', 'Denim Jeans restocking'),
(8, 2, 2, 20, '2025-10-31 11:00:00', '2025-11-04 11:00:00', 70.00, 'Delivered', 'Winter Jacket delivery'),

(1, 1, 3, 25, '2025-10-30 08:00:00', '2025-11-03 10:00:00', 45.00, 'Delivered', 'Headphones for Northgate Mall'),
(5, 1, 3, 55, '2025-11-02 16:00:00', '2025-11-06 16:00:00', 14.00, 'Delivered', 'Wireless Mouse restocking'),
(9, 4, 3, 60, '2025-11-01 13:00:00', '2025-11-05 13:00:00', 50.00, 'Delivered', 'Running Shoes delivery'),

(2, 6, 4, 18, '2025-10-31 14:00:00', '2025-11-04 14:30:00', 180.00, 'Delivered', 'Smart Watch for Eastside Plaza'),
(3, 1, 4, 180, '2025-11-04 08:00:00', '2025-11-08 09:00:00', 6.50, 'Delivered', 'USB-C Cable restocking'),
(6, 2, 4, 200, '2025-10-29 07:00:00', '2025-11-02 08:00:00', 11.00, 'Delivered', 'T-Shirt bulk order'),
(7, 2, 4, 80, '2025-11-01 10:00:00', '2025-11-05 10:00:00', 28.00, 'Delivered', 'Denim Jeans delivery'),

(1, 1, 5, 55, '2025-11-01 10:00:00', '2025-11-05 10:00:00', 45.00, 'Delivered', 'Headphones for Southpoint Center'),
(5, 1, 5, 45, '2025-11-05 16:00:00', '2025-11-09 16:00:00', 14.00, 'Delivered', 'Wireless Mouse delivery'),
(8, 2, 5, 22, '2025-11-02 11:00:00', '2025-11-06 11:00:00', 70.00, 'Delivered', 'Winter Jacket restocking'),

-- October deliveries
(6, 2, 1, 250, '2025-10-11 07:00:00', '2025-10-15 08:00:00', 11.00, 'Delivered', 'Large T-Shirt order'),
(18, 8, 1, 150, '2025-10-16 11:00:00', '2025-10-20 12:00:00', 4.50, 'Delivered', 'Ballpoint Pen bulk order'),
(1, 1, 1, 60, '2025-10-06 08:00:00', '2025-10-10 10:00:00', 45.00, 'Delivered', 'Headphones monthly restock'),
(3, 1, 1, 180, '2025-10-04 08:00:00', '2025-10-08 09:00:00', 6.50, 'Delivered', 'USB-C Cable order'),
(2, 6, 1, 12, '2025-10-18 14:00:00', '2025-10-22 14:30:00', 180.00, 'Delivered', 'Smart Watch delivery'),

(7, 2, 2, 80, '2025-10-14 09:00:00', '2025-10-18 10:00:00', 28.00, 'Delivered', 'Denim Jeans delivery'),
(13, 4, 2, 50, '2025-10-21 14:00:00', '2025-10-25 15:00:00', 18.00, 'Delivered', 'Yoga Mat delivery'),
(20, 7, 2, 60, '2025-10-08 08:00:00', '2025-10-12 09:00:00', 12.00, 'Delivered', 'Vitamin C Supplement'),

(9, 4, 3, 65, '2025-10-12 12:00:00', '2025-10-16 13:00:00', 50.00, 'Delivered', 'Running Shoes delivery'),
(1, 1, 3, 30, '2025-10-07 08:00:00', '2025-10-11 10:00:00', 45.00, 'Delivered', 'Headphones delivery'),

-- September deliveries
(1, 1, 1, 70, '2025-09-16 08:00:00', '2025-09-20 10:00:00', 45.00, 'Delivered', 'Headphones quarterly order'),
(3, 1, 2, 220, '2025-09-11 07:00:00', '2025-09-15 09:00:00', 6.50, 'Delivered', 'USB-C Cable large order'),
(6, 2, 1, 280, '2025-09-06 06:00:00', '2025-09-10 08:00:00', 11.00, 'Delivered', 'T-Shirt seasonal order'),
(7, 2, 2, 90, '2025-09-08 09:00:00', '2025-09-12 10:00:00', 28.00, 'Delivered', 'Denim Jeans fall collection'),
(2, 6, 4, 20, '2025-09-21 13:00:00', '2025-09-25 14:30:00', 180.00, 'Delivered', 'Smart Watch delivery'),

-- August deliveries
(1, 1, 1, 55, '2025-08-14 08:00:00', '2025-08-18 10:00:00', 45.00, 'Delivered', 'Headphones summer restock'),
(1, 1, 2, 50, '2025-08-16 08:00:00', '2025-08-20 10:00:00', 45.00, 'Delivered', 'Headphones delivery'),
(1, 1, 3, 35, '2025-08-18 08:00:00', '2025-08-22 10:00:00', 45.00, 'Delivered', 'Headphones delivery'),
(3, 1, 1, 190, '2025-08-06 07:00:00', '2025-08-10 09:00:00', 6.50, 'Delivered', 'USB-C Cable order'),
(6, 2, 4, 220, '2025-08-11 06:00:00', '2025-08-15 08:00:00', 11.00, 'Delivered', 'T-Shirt summer order'),
(13, 4, 2, 55, '2025-08-21 14:00:00', '2025-08-25 15:00:00', 18.00, 'Delivered', 'Yoga Mat summer stock'),

-- Pending/Partial deliveries (for realistic data)
(10, 3, 1, 25, '2025-11-10 13:00:00', '2025-11-12 14:00:00', 20.00, 'Pending', 'Ceramic Plant Pot Set - expected delivery'),
(11, 3, 3, 15, '2025-11-10 14:00:00', '2025-11-12 15:00:00', 22.00, 'Pending', 'LED Desk Lamp order'),
(14, 4, 4, 8, '2025-11-08 15:00:00', '2025-11-11 16:00:00', 120.00, 'Partial', 'Camping Tent - partial delivery, 2 more expected');

