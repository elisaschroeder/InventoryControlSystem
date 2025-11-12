using MySqlConnector;
using System.Data;

class Program
{
    // Database connection string - UPDATE THESE VALUES FOR YOUR MYSQL SERVER
    private static string connectionString = "Server=localhost;Port=3306;Database=InventoryControlDB;User=eschroeder;Password=elisa;";

    static async Task Main(string[] args)
    {
        Console.ForegroundColor = ConsoleColor.Cyan;
        Console.WriteLine("╔════════════════════════════════════════════════════════════╗");
        Console.WriteLine("║        INVENTORY CONTROL SYSTEM - REPORTING PORTAL        ║");
        Console.WriteLine("╚════════════════════════════════════════════════════════════╝");
        Console.ResetColor();
        Console.WriteLine();

        bool exitApp = false;

        while (!exitApp)
        {
            DisplayMainMenu();
            Console.Write("\nEnter your choice (1-9): ");
            string choice = Console.ReadLine() ?? "";

            Console.Clear();

            switch (choice)
            {
                case "1":
                    await ShowStoresReport();
                    break;
                case "2":
                    await ShowCategoriesReport();
                    break;
                case "3":
                    await ShowSuppliersReport();
                    break;
                case "4":
                    await ShowProductsReport();
                    break;
                case "5":
                    await ShowInventoryReport();
                    break;
                case "6":
                    await ShowSalesReport();
                    break;
                case "7":
                    await ShowLowStockReport();
                    break;
                case "8":
                    await ShowTopSuppliersReport();
                    break;
                case "9":
                    exitApp = true;
                    Console.ForegroundColor = ConsoleColor.Yellow;
                    Console.WriteLine("\nThank you for using the Inventory Control System!");
                    Console.ResetColor();
                    break;
                default:
                    Console.ForegroundColor = ConsoleColor.Red;
                    Console.WriteLine("\n❌ Invalid choice. Please select 1-9.");
                    Console.ResetColor();
                    break;
            }

            if (!exitApp)
            {
                Console.WriteLine("\n" + new string('─', 60));
                Console.WriteLine("Press any key to continue...");
                Console.ReadKey();
                Console.Clear();
            }
        }
    }

    static void DisplayMainMenu()
    {
        Console.ForegroundColor = ConsoleColor.Green;
        Console.WriteLine("┌────────────────────────────────────────────────────────────┐");
        Console.WriteLine("│                      MAIN MENU                             │");
        Console.WriteLine("└────────────────────────────────────────────────────────────┘");
        Console.ResetColor();
        Console.WriteLine();
        Console.WriteLine("  1. 🏢 Stores Report");
        Console.WriteLine("  2. 📦 Categories Report");
        Console.WriteLine("  3. 🚚 Suppliers Report");
        Console.WriteLine("  4. 🛍️  Products Report (with filtering)");
        Console.WriteLine("  5. 📊 Inventory Report (with filtering)");
        Console.WriteLine("  6. 💰 Sales Report (with filtering)");
        Console.WriteLine("  7. ⚠️  Low-Stock Products (with filtering)");
        Console.WriteLine("  8. 🏆 Top-Performing Suppliers");
        Console.WriteLine("  9. 🚪 Exit");
    }

    // ============================================
    // 1. STORES REPORT
    // ============================================
    static async Task ShowStoresReport()
    {
        Console.ForegroundColor = ConsoleColor.Cyan;
        Console.WriteLine("═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════");
        Console.WriteLine("                                                            STORES REPORT");
        Console.WriteLine("═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════");
        Console.ResetColor();
        Console.WriteLine();

        string query = @"
            SELECT 
                s.StoreID,
                s.StoreName,
                s.City,
                s.State,
                s.Phone,
                s.ManagerName,
                COUNT(DISTINCT i.ProductID) AS ProductCount,
                COALESCE(SUM(i.QuantityOnHand), 0) AS TotalInventory
            FROM Stores s
            LEFT JOIN Inventory i ON s.StoreID = i.StoreID
            GROUP BY s.StoreID, s.StoreName, s.City, s.State, s.Phone, s.ManagerName
            ORDER BY s.StoreName";

        // Print table header
        Console.ForegroundColor = ConsoleColor.Yellow;
        Console.WriteLine($"{"ID",-5} | {"Store Name",-25} | {"City",-18} | {"State",-6} | {"Phone",-15} | {"Manager",-20} | {"Products",8} | {"Inventory",10}");
        Console.WriteLine(new string('─', 140));
        Console.ResetColor();

        await ExecuteQuery(query, reader =>
        {
            string storeId = reader["StoreID"].ToString()!;
            string storeName = reader["StoreName"].ToString()!;
            string city = reader["City"].ToString()!;
            string state = reader["State"].ToString()!;
            string phone = reader["Phone"].ToString()!;
            string manager = reader["ManagerName"].ToString()!;
            string productCount = reader["ProductCount"].ToString()!;
            string totalInventory = reader["TotalInventory"].ToString()!;

            // Truncate long values to fit in columns
            if (storeName.Length > 25) storeName = storeName.Substring(0, 22) + "...";
            if (city.Length > 18) city = city.Substring(0, 15) + "...";
            if (manager.Length > 20) manager = manager.Substring(0, 17) + "...";

            Console.WriteLine($"{storeId,-5} | {storeName,-25} | {city,-18} | {state,-6} | {phone,-15} | {manager,-20} | {productCount,8} | {totalInventory,10}");
        });
        
        Console.WriteLine(new string('═', 140));
    }

    // ============================================
    // 2. CATEGORIES REPORT
    // ============================================
    static async Task ShowCategoriesReport()
    {
        Console.ForegroundColor = ConsoleColor.Cyan;
        Console.WriteLine("═══════════════════════════════════════════════════════════");
        Console.WriteLine("                  CATEGORIES REPORT");
        Console.WriteLine("═══════════════════════════════════════════════════════════");
        Console.ResetColor();
        Console.WriteLine();

        string query = @"
            SELECT 
                c.CategoryID,
                c.CategoryName,
                c.Description,
                COUNT(DISTINCT p.ProductID) AS ProductCount,
                COALESCE(SUM(i.QuantityOnHand), 0) AS TotalStock
            FROM Categories c
            LEFT JOIN Products p ON c.CategoryID = p.CategoryID
            LEFT JOIN Inventory i ON p.ProductID = i.ProductID
            GROUP BY c.CategoryID, c.CategoryName, c.Description
            ORDER BY c.CategoryName";

        await ExecuteQuery(query, reader =>
        {
            Console.WriteLine($"Category ID: {reader["CategoryID"]}");
            Console.WriteLine($"Name: {reader["CategoryName"]}");
            Console.WriteLine($"Description: {reader["Description"]}");
            Console.WriteLine($"Number of Products: {reader["ProductCount"]}");
            Console.WriteLine($"Total Stock Units: {reader["TotalStock"]}");
            Console.WriteLine(new string('─', 60));
        });
    }

    // ============================================
    // 3. SUPPLIERS REPORT
    // ============================================
    static async Task ShowSuppliersReport()
    {
        Console.ForegroundColor = ConsoleColor.Cyan;
        Console.WriteLine("═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════");
        Console.WriteLine("                                                                SUPPLIERS REPORT");
        Console.WriteLine("═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════");
        Console.ResetColor();
        Console.WriteLine();

        string query = @"
            SELECT 
                s.SupplierID,
                s.SupplierName,
                s.ContactName,
                s.Email,
                s.Phone,
                s.City,
                s.Country,
                s.Rating,
                COUNT(DISTINCT p.ProductID) AS ProductCount
            FROM Suppliers s
            LEFT JOIN Products p ON s.SupplierID = p.SupplierID
            GROUP BY s.SupplierID, s.SupplierName, s.ContactName, s.Email, s.Phone, s.City, s.Country, s.Rating
            ORDER BY s.SupplierName";

        // Print table header
        Console.ForegroundColor = ConsoleColor.Yellow;
        Console.WriteLine($"{"ID",-5} | {"Supplier Name",-25} | {"Contact Person",-22} | {"Email",-30} | {"Phone",-15} | {"City",-18} | {"Country",-15} | {"Rating",6} | {"Products",8}");
        Console.WriteLine(new string('─', 165));
        Console.ResetColor();

        await ExecuteQuery(query, reader =>
        {
            string supplierId = reader["SupplierID"].ToString()!;
            string supplierName = reader["SupplierName"].ToString()!;
            string contactName = reader["ContactName"].ToString()!;
            string email = reader["Email"].ToString()!;
            string phone = reader["Phone"].ToString()!;
            string city = reader["City"].ToString()!;
            string country = reader["Country"].ToString()!;
            string rating = reader["Rating"].ToString()!;
            string productCount = reader["ProductCount"].ToString()!;

            // Truncate long values to fit in columns
            if (supplierName.Length > 25) supplierName = supplierName.Substring(0, 22) + "...";
            if (contactName.Length > 22) contactName = contactName.Substring(0, 19) + "...";
            if (email.Length > 30) email = email.Substring(0, 27) + "...";
            if (city.Length > 18) city = city.Substring(0, 15) + "...";
            if (country.Length > 15) country = country.Substring(0, 12) + "...";

            // Format rating to 2 decimal places
            if (decimal.TryParse(rating, out decimal ratingValue))
            {
                rating = ratingValue.ToString("0.00");
            }

            Console.WriteLine($"{supplierId,-5} | {supplierName,-25} | {contactName,-22} | {email,-30} | {phone,-15} | {city,-18} | {country,-15} | {rating,6} | {productCount,8}");
        });
        
        Console.WriteLine(new string('═', 165));
    }

    // ============================================
    // 4. PRODUCTS REPORT (WITH FILTERING)
    // ============================================
    static async Task ShowProductsReport()
    {
        Console.ForegroundColor = ConsoleColor.Cyan;
        Console.WriteLine("═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════");
        Console.WriteLine("                                                                   PRODUCTS REPORT");
        Console.WriteLine("═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════");
        Console.ResetColor();
        Console.WriteLine();

        Console.WriteLine("Filter by:");
        Console.WriteLine("  1. All Products");
        Console.WriteLine("  2. By Store");
        Console.WriteLine("  3. By Category");
        Console.Write("\nEnter your choice (1-3): ");
        string filterChoice = Console.ReadLine() ?? "1";

        string query = "";
        MySqlParameter? parameter = null;

        switch (filterChoice)
        {
            case "2":
                // Filter by Store
                await ListStores();
                Console.Write("\nEnter Store ID: ");
                if (int.TryParse(Console.ReadLine(), out int storeId))
                {
                    query = @"
                        SELECT DISTINCT
                            p.ProductID,
                            p.ProductName,
                            p.SKU,
                            p.UnitPrice,
                            c.CategoryName,
                            s.SupplierName,
                            i.QuantityAvailable,
                            p.IsActive
                        FROM Products p
                        INNER JOIN Categories c ON p.CategoryID = c.CategoryID
                        INNER JOIN Suppliers s ON p.SupplierID = s.SupplierID
                        LEFT JOIN Inventory i ON p.ProductID = i.ProductID AND i.StoreID = @StoreID
                        ORDER BY c.CategoryName, p.ProductName";
                    parameter = new MySqlParameter("@StoreID", storeId);
                }
                break;

            case "3":
                // Filter by Category
                await ListCategories();
                Console.Write("\nEnter Category ID: ");
                if (int.TryParse(Console.ReadLine(), out int categoryId))
                {
                    query = @"
                        SELECT 
                            p.ProductID,
                            p.ProductName,
                            p.SKU,
                            p.UnitPrice,
                            c.CategoryName,
                            s.SupplierName,
                            COALESCE(SUM(i.QuantityAvailable), 0) AS TotalAvailable,
                            p.IsActive
                        FROM Products p
                        INNER JOIN Categories c ON p.CategoryID = c.CategoryID
                        INNER JOIN Suppliers s ON p.SupplierID = s.SupplierID
                        LEFT JOIN Inventory i ON p.ProductID = i.ProductID
                        WHERE p.CategoryID = @CategoryID
                        GROUP BY p.ProductID, p.ProductName, p.SKU, p.UnitPrice, c.CategoryName, s.SupplierName, p.IsActive
                        ORDER BY c.CategoryName, p.ProductName";
                    parameter = new MySqlParameter("@CategoryID", categoryId);
                }
                break;

            default:
                // All Products
                query = @"
                    SELECT 
                        p.ProductID,
                        p.ProductName,
                        p.SKU,
                        p.UnitPrice,
                        c.CategoryName,
                        s.SupplierName,
                        COALESCE(SUM(i.QuantityAvailable), 0) AS TotalAvailable,
                        p.IsActive
                    FROM Products p
                    INNER JOIN Categories c ON p.CategoryID = c.CategoryID
                    INNER JOIN Suppliers s ON p.SupplierID = s.SupplierID
                    LEFT JOIN Inventory i ON p.ProductID = i.ProductID
                    GROUP BY p.ProductID, p.ProductName, p.SKU, p.UnitPrice, c.CategoryName, s.SupplierName, p.IsActive
                    ORDER BY c.CategoryName, p.ProductName";
                break;
        }

        if (!string.IsNullOrEmpty(query))
        {
            Console.WriteLine();
            Console.ForegroundColor = ConsoleColor.Green;
            Console.WriteLine("PRODUCTS:");
            Console.ResetColor();
            Console.WriteLine();

            // Print table header
            Console.ForegroundColor = ConsoleColor.Yellow;
            Console.WriteLine($"{"ID",-5} | {"Product Name",-35} | {"SKU",-15} | {"Price",10} | {"Category",-18} | {"Supplier",-25} | {"Available",9} | {"Status",-8}");
            Console.WriteLine(new string('─', 170));
            Console.ResetColor();

            await ExecuteQuery(query, reader =>
            {
                string productId = reader["ProductID"].ToString()!;
                string productName = reader["ProductName"].ToString()!;
                string sku = reader["SKU"].ToString()!;
                decimal unitPrice = Convert.ToDecimal(reader["UnitPrice"]);
                string category = reader["CategoryName"].ToString()!;
                string supplier = reader["SupplierName"].ToString()!;
                string available;
                
                if (filterChoice == "2")
                {
                    var qty = reader["QuantityAvailable"];
                    available = (qty == DBNull.Value ? "0" : qty.ToString()!);
                }
                else
                {
                    available = reader["TotalAvailable"].ToString()!;
                }
                
                string status = Convert.ToBoolean(reader["IsActive"]) ? "Active" : "Inactive";

                // Truncate long values to fit in columns
                if (productName.Length > 35) productName = productName.Substring(0, 32) + "...";
                if (sku.Length > 15) sku = sku.Substring(0, 12) + "...";
                if (category.Length > 18) category = category.Substring(0, 15) + "...";
                if (supplier.Length > 25) supplier = supplier.Substring(0, 22) + "...";

                Console.WriteLine($"{productId,-5} | {productName,-35} | {sku,-15} | ${unitPrice,9:F2} | {category,-18} | {supplier,-25} | {available,9} | {status,-8}");
            }, parameter != null ? new[] { parameter } : null);
            
            Console.WriteLine(new string('═', 170));
        }
    }

    // ============================================
    // 5. INVENTORY REPORT (WITH FILTERING)
    // ============================================
    static async Task ShowInventoryReport()
    {
        Console.ForegroundColor = ConsoleColor.Cyan;
        Console.WriteLine("═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════");
        Console.WriteLine("                                                                          INVENTORY REPORT");
        Console.WriteLine("═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════");
        Console.ResetColor();
        Console.WriteLine();

        Console.WriteLine("Filter by:");
        Console.WriteLine("  1. All Inventory");
        Console.WriteLine("  2. By Store");
        Console.WriteLine("  3. By Category");
        Console.WriteLine("  4. By Product ID");
        Console.Write("\nEnter your choice (1-4): ");
        string filterChoice = Console.ReadLine() ?? "1";

        string query = "";
        MySqlParameter? parameter = null;

        switch (filterChoice)
        {
            case "2":
                // Filter by Store
                await ListStores();
                Console.Write("\nEnter Store ID: ");
                if (int.TryParse(Console.ReadLine(), out int storeId))
                {
                    query = @"
                        SELECT 
                            st.StoreName,
                            st.City,
                            p.ProductName,
                            p.SKU,
                            c.CategoryName,
                            COALESCE(i.QuantityOnHand, 0) AS QuantityOnHand,
                            COALESCE(i.QuantityReserved, 0) AS QuantityReserved,
                            COALESCE(i.QuantityAvailable, 0) AS QuantityAvailable,
                            COALESCE(i.MinimumStock, 0) AS MinimumStock,
                            CASE 
                                WHEN i.InventoryID IS NULL THEN 'Not Stocked'
                                WHEN i.QuantityAvailable <= 0 THEN 'Out of Stock'
                                WHEN i.QuantityAvailable <= i.MinimumStock THEN 'Low Stock'
                                ELSE 'In Stock'
                            END AS StockStatus
                        FROM Stores st
                        CROSS JOIN Products p
                        INNER JOIN Categories c ON p.CategoryID = c.CategoryID
                        LEFT JOIN Inventory i ON i.StoreID = st.StoreID AND i.ProductID = p.ProductID
                        WHERE st.StoreID = @StoreID
                        ORDER BY c.CategoryName, p.ProductName";
                    parameter = new MySqlParameter("@StoreID", storeId);
                }
                break;

            case "3":
                // Filter by Category
                await ListCategories();
                Console.Write("\nEnter Category ID: ");
                if (int.TryParse(Console.ReadLine(), out int categoryId))
                {
                    query = @"
                        SELECT 
                            st.StoreName,
                            st.City,
                            p.ProductName,
                            p.SKU,
                            c.CategoryName,
                            COALESCE(i.QuantityOnHand, 0) AS QuantityOnHand,
                            COALESCE(i.QuantityReserved, 0) AS QuantityReserved,
                            COALESCE(i.QuantityAvailable, 0) AS QuantityAvailable,
                            COALESCE(i.MinimumStock, 0) AS MinimumStock,
                            CASE 
                                WHEN i.InventoryID IS NULL THEN 'Not Stocked'
                                WHEN i.QuantityAvailable <= 0 THEN 'Out of Stock'
                                WHEN i.QuantityAvailable <= i.MinimumStock THEN 'Low Stock'
                                ELSE 'In Stock'
                            END AS StockStatus
                        FROM Products p
                        INNER JOIN Categories c ON p.CategoryID = c.CategoryID
                        CROSS JOIN Stores st
                        LEFT JOIN Inventory i ON i.ProductID = p.ProductID AND i.StoreID = st.StoreID
                        WHERE p.CategoryID = @CategoryID
                        ORDER BY st.StoreName, c.CategoryName, p.ProductName";
                    parameter = new MySqlParameter("@CategoryID", categoryId);
                }
                break;

            case "4":
                // Filter by Product ID
                await ListProducts();
                Console.Write("\nEnter Product ID: ");
                if (int.TryParse(Console.ReadLine(), out int productId))
                {
                    query = @"
                        SELECT 
                            st.StoreName,
                            st.City,
                            p.ProductName,
                            p.SKU,
                            c.CategoryName,
                            COALESCE(i.QuantityOnHand, 0) AS QuantityOnHand,
                            COALESCE(i.QuantityReserved, 0) AS QuantityReserved,
                            COALESCE(i.QuantityAvailable, 0) AS QuantityAvailable,
                            COALESCE(i.MinimumStock, 0) AS MinimumStock,
                            i.LastRestocked,
                            CASE 
                                WHEN i.InventoryID IS NULL THEN 'Not Stocked'
                                WHEN i.QuantityAvailable <= 0 THEN 'Out of Stock'
                                WHEN i.QuantityAvailable <= i.MinimumStock THEN 'Low Stock'
                                ELSE 'In Stock'
                            END AS StockStatus
                        FROM Products p
                        INNER JOIN Categories c ON p.CategoryID = c.CategoryID
                        CROSS JOIN Stores st
                        LEFT JOIN Inventory i ON i.ProductID = p.ProductID AND i.StoreID = st.StoreID
                        WHERE p.ProductID = @ProductID
                        ORDER BY st.StoreName";
                    parameter = new MySqlParameter("@ProductID", productId);
                }
                break;

            default:
                // All Inventory
                query = @"
                    SELECT 
                        st.StoreName,
                        st.City,
                        p.ProductName,
                        p.SKU,
                        c.CategoryName,
                        COALESCE(i.QuantityOnHand, 0) AS QuantityOnHand,
                        COALESCE(i.QuantityReserved, 0) AS QuantityReserved,
                        COALESCE(i.QuantityAvailable, 0) AS QuantityAvailable,
                        COALESCE(i.MinimumStock, 0) AS MinimumStock,
                        CASE 
                            WHEN i.InventoryID IS NULL THEN 'Not Stocked'
                            WHEN i.QuantityAvailable <= 0 THEN 'Out of Stock'
                            WHEN i.QuantityAvailable <= i.MinimumStock THEN 'Low Stock'
                            ELSE 'In Stock'
                        END AS StockStatus
                    FROM Inventory i
                    INNER JOIN Products p ON i.ProductID = p.ProductID
                    INNER JOIN Stores st ON i.StoreID = st.StoreID
                    INNER JOIN Categories c ON p.CategoryID = c.CategoryID
                    ORDER BY st.StoreName, c.CategoryName, p.ProductName
                    LIMIT 50";
                break;
        }

        if (!string.IsNullOrEmpty(query))
        {
            Console.WriteLine();
            Console.ForegroundColor = ConsoleColor.Green;
            Console.WriteLine("INVENTORY:");
            Console.ResetColor();
            Console.WriteLine();

            // Print table header
            Console.ForegroundColor = ConsoleColor.Yellow;
            Console.WriteLine($"{"Store Name",-25} | {"City",-18} | {"Category",-18} | {"Product Name",-30} | {"SKU",-12} | {"On Hand",7} | {"Reserved",8} | {"Available",9} | {"Min Stock",9} | {"Status",-13}");
            Console.WriteLine(new string('─', 195));
            Console.ResetColor();

            string currentStore = "";
            string currentCategory = "";

            await ExecuteQuery(query, reader =>
            {
                string storeName = reader["StoreName"].ToString()!;
                string city = reader["City"].ToString()!;
                string productName = reader["ProductName"].ToString()!;
                string category = reader["CategoryName"].ToString()!;
                string sku = reader["SKU"].ToString()!;
                string onHand = reader["QuantityOnHand"].ToString()!;
                string reserved = reader["QuantityReserved"].ToString()!;
                string available = reader["QuantityAvailable"].ToString()!;
                string minStock = reader["MinimumStock"].ToString()!;
                string stockStatus = reader["StockStatus"].ToString() ?? "";

                // Add separator when store changes
                if (currentStore != storeName && currentStore != "")
                {
                    Console.ForegroundColor = ConsoleColor.DarkGray;
                    Console.WriteLine(new string('─', 195));
                    Console.ResetColor();
                    currentCategory = ""; // Reset category for new store
                }
                // Add subtle separator when category changes within same store
                else if (currentStore == storeName && currentCategory != category && currentCategory != "")
                {
                    Console.ForegroundColor = ConsoleColor.DarkGray;
                    Console.WriteLine(new string('·', 195));
                    Console.ResetColor();
                }

                currentStore = storeName;
                currentCategory = category;

                // Truncate long values to fit in columns
                string displayStoreName = storeName;
                string displayCity = city;
                string displayProductName = productName;
                string displayCategory = category;
                string displaySku = sku;

                if (displayStoreName.Length > 25) displayStoreName = displayStoreName.Substring(0, 22) + "...";
                if (displayCity.Length > 18) displayCity = displayCity.Substring(0, 15) + "...";
                if (displayProductName.Length > 30) displayProductName = displayProductName.Substring(0, 27) + "...";
                if (displayCategory.Length > 18) displayCategory = displayCategory.Substring(0, 15) + "...";
                if (displaySku.Length > 12) displaySku = displaySku.Substring(0, 9) + "...";

                // Color code the status
                var statusColor = stockStatus switch
                {
                    "Out of Stock" => ConsoleColor.Red,
                    "Low Stock" => ConsoleColor.Yellow,
                    "Not Stocked" => ConsoleColor.Gray,
                    _ => ConsoleColor.Green
                };

                Console.Write($"{displayStoreName,-25} | {displayCity,-18} | {displayCategory,-18} | {displayProductName,-30} | {displaySku,-12} | {onHand,7} | {reserved,8} | {available,9} | {minStock,9} | ");
                Console.ForegroundColor = statusColor;
                Console.Write($"{stockStatus,-13}");
                Console.ResetColor();
                Console.WriteLine();
            }, parameter != null ? new[] { parameter } : null);
            
            Console.WriteLine(new string('═', 195));
        }
    }

    // ============================================
    // 6. SALES REPORT (WITH FILTERING)
    // ============================================
    static async Task ShowSalesReport()
    {
        Console.ForegroundColor = ConsoleColor.Cyan;
        Console.WriteLine("═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════");
        Console.WriteLine("                                                                      SALES REPORT");
        Console.WriteLine("═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════");
        Console.ResetColor();
        Console.WriteLine();

        Console.WriteLine("Filter by:");
        Console.WriteLine("  1. All Sales");
        Console.WriteLine("  2. By Product");
        Console.WriteLine("  3. By Store");
        Console.WriteLine("  4. By Date Range");
        Console.Write("\nEnter your choice (1-4): ");
        string filterChoice = Console.ReadLine() ?? "1";

        string query = "";
        List<MySqlParameter> parameters = new List<MySqlParameter>();

        switch (filterChoice)
        {
            case "2":
                // Filter by Product
                await ListProducts();
                Console.Write("\nEnter Product ID: ");
                if (int.TryParse(Console.ReadLine(), out int productId))
                {
                    query = @"
                        SELECT 
                            s.SaleID,
                            s.SaleDate,
                            st.StoreName,
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
                        INNER JOIN Categories c ON p.CategoryID = c.CategoryID
                        WHERE s.ProductID = @ProductID
                        ORDER BY st.StoreName, c.CategoryName, p.ProductName";
                    parameters.Add(new MySqlParameter("@ProductID", productId));
                }
                break;

            case "3":
                // Filter by Store
                await ListStores();
                Console.Write("\nEnter Store ID: ");
                if (int.TryParse(Console.ReadLine(), out int storeId))
                {
                    query = @"
                        SELECT 
                            s.SaleID,
                            s.SaleDate,
                            st.StoreName,
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
                        INNER JOIN Categories c ON p.CategoryID = c.CategoryID
                        WHERE s.StoreID = @StoreID
                        ORDER BY st.StoreName, c.CategoryName, p.ProductName";
                    parameters.Add(new MySqlParameter("@StoreID", storeId));
                }
                break;

            case "4":
                // Filter by Date Range
                Console.Write("\nEnter Start Date (yyyy-MM-dd): ");
                string startDate = Console.ReadLine() ?? "";
                Console.Write("Enter End Date (yyyy-MM-dd): ");
                string endDate = Console.ReadLine() ?? "";

                if (!string.IsNullOrEmpty(startDate) && !string.IsNullOrEmpty(endDate))
                {
                    query = @"
                        SELECT 
                            s.SaleID,
                            s.SaleDate,
                            st.StoreName,
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
                        INNER JOIN Categories c ON p.CategoryID = c.CategoryID
                        WHERE s.SaleDate BETWEEN @StartDate AND @EndDate
                        ORDER BY st.StoreName, c.CategoryName, p.ProductName";
                    parameters.Add(new MySqlParameter("@StartDate", startDate));
                    parameters.Add(new MySqlParameter("@EndDate", endDate + " 23:59:59"));
                }
                break;

            default:
                // All Sales (Last 30 days)
                query = @"
                    SELECT 
                        s.SaleID,
                        s.SaleDate,
                        st.StoreName,
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
                    INNER JOIN Categories c ON p.CategoryID = c.CategoryID
                    ORDER BY st.StoreName, c.CategoryName, p.ProductName
                    LIMIT 30";
                break;
        }

        if (!string.IsNullOrEmpty(query))
        {
            Console.WriteLine();
            Console.ForegroundColor = ConsoleColor.Green;
            Console.WriteLine("SALES:");
            Console.ResetColor();
            Console.WriteLine();

            // Print table header
            Console.ForegroundColor = ConsoleColor.Yellow;
            Console.WriteLine($"{"Sale ID",-8} | {"Date",-19} | {"Store Name",-25} | {"Product Name",-30} | {"Category",-18} | {"SKU",-12} | {"Qty",5} | {"Price",10} | {"Total",10} | {"Transaction ID",-20}");
            Console.WriteLine(new string('─', 195));
            Console.ResetColor();

            decimal totalRevenue = 0;
            int totalQuantity = 0;
            string currentStore = "";
            string currentDate = "";

            await ExecuteQuery(query, reader =>
            {
                string storeName = reader["StoreName"].ToString()!;
                DateTime saleDate = Convert.ToDateTime(reader["SaleDate"]);
                string saleDateOnly = saleDate.ToString("yyyy-MM-dd");
                
                // Add separator when store changes
                if (currentStore != storeName && currentStore != "")
                {
                    Console.ForegroundColor = ConsoleColor.DarkGray;
                    Console.WriteLine(new string('═', 195));
                    Console.ResetColor();
                    currentDate = ""; // Reset date for new store
                }
                // Add subtle separator when date changes within same store
                else if (currentStore == storeName && currentDate != saleDateOnly && currentDate != "")
                {
                    Console.ForegroundColor = ConsoleColor.DarkGray;
                    Console.WriteLine(new string('·', 195));
                    Console.ResetColor();
                }

                currentStore = storeName;
                currentDate = saleDateOnly;

                string saleId = reader["SaleID"].ToString()!;
                string dateTime = saleDate.ToString("yyyy-MM-dd HH:mm:ss");
                string productName = reader["ProductName"].ToString()!;
                string category = reader["CategoryName"].ToString()!;
                string sku = reader["SKU"].ToString()!;
                string quantity = reader["QuantitySold"].ToString()!;
                decimal salePrice = Convert.ToDecimal(reader["SalePrice"]);
                decimal totalAmount = Convert.ToDecimal(reader["TotalAmount"]);
                string transactionId = reader["TransactionID"].ToString()!;

                // Truncate long values to fit in columns
                if (storeName.Length > 25) storeName = storeName.Substring(0, 22) + "...";
                if (productName.Length > 30) productName = productName.Substring(0, 27) + "...";
                if (category.Length > 18) category = category.Substring(0, 15) + "...";
                if (sku.Length > 12) sku = sku.Substring(0, 9) + "...";
                if (transactionId.Length > 20) transactionId = transactionId.Substring(0, 17) + "...";

                Console.WriteLine($"{saleId,-8} | {dateTime,-19} | {storeName,-25} | {productName,-30} | {category,-18} | {sku,-12} | {quantity,5} | ${salePrice,9:F2} | ${totalAmount,9:F2} | {transactionId,-20}");

                totalRevenue += totalAmount;
                totalQuantity += Convert.ToInt32(reader["QuantitySold"]);
            }, parameters.Count > 0 ? parameters.ToArray() : null);

            Console.WriteLine(new string('═', 195));

            if (totalRevenue > 0)
            {
                Console.WriteLine();
                Console.ForegroundColor = ConsoleColor.Cyan;
                Console.WriteLine("SUMMARY:");
                Console.WriteLine($"Total Units Sold: {totalQuantity:N0}");
                Console.WriteLine($"Total Revenue: ${totalRevenue:N2}");
                Console.ResetColor();
            }
        }
    }

    // ============================================
    // 7. LOW-STOCK PRODUCTS REPORT (WITH FILTERING)
    // ============================================
    static async Task ShowLowStockReport()
    {
        Console.ForegroundColor = ConsoleColor.Cyan;
        Console.WriteLine("═══════════════════════════════════════════════════════════");
        Console.WriteLine("              LOW-STOCK PRODUCTS REPORT");
        Console.WriteLine("═══════════════════════════════════════════════════════════");
        Console.ResetColor();
        Console.WriteLine();

        Console.WriteLine("Filter by:");
        Console.WriteLine("  1. All Low-Stock Products");
        Console.WriteLine("  2. By Store");
        Console.WriteLine("  3. By Category");
        Console.WriteLine("  4. By Store AND Category");
        Console.Write("\nEnter your choice (1-4): ");
        string filterChoice = Console.ReadLine() ?? "1";

        string query = "";
        List<MySqlParameter> parameters = new List<MySqlParameter>();

        switch (filterChoice)
        {
            case "2":
                // Filter by Store
                await ListStores();
                Console.Write("\nEnter Store ID: ");
                if (int.TryParse(Console.ReadLine(), out int storeId))
                {
                    query = @"
                        SELECT 
                            st.StoreName,
                            st.City,
                            p.ProductName,
                            p.SKU,
                            c.CategoryName,
                            i.QuantityAvailable,
                            i.MinimumStock,
                            (i.MinimumStock - i.QuantityAvailable) AS UnitsNeeded,
                            s.SupplierName,
                            s.Phone AS SupplierPhone,
                            s.Email AS SupplierEmail,
                            i.LastRestocked
                        FROM Inventory i
                        INNER JOIN Products p ON i.ProductID = p.ProductID
                        INNER JOIN Stores st ON i.StoreID = st.StoreID
                        INNER JOIN Categories c ON p.CategoryID = c.CategoryID
                        INNER JOIN Suppliers s ON p.SupplierID = s.SupplierID
                        WHERE i.QuantityAvailable <= i.MinimumStock
                            AND p.IsActive = TRUE
                            AND i.StoreID = @StoreID
                        ORDER BY i.QuantityAvailable ASC, p.ProductName";
                    parameters.Add(new MySqlParameter("@StoreID", storeId));
                }
                break;

            case "3":
                // Filter by Category
                await ListCategories();
                Console.Write("\nEnter Category ID: ");
                if (int.TryParse(Console.ReadLine(), out int categoryId))
                {
                    query = @"
                        SELECT 
                            st.StoreName,
                            st.City,
                            p.ProductName,
                            p.SKU,
                            c.CategoryName,
                            i.QuantityAvailable,
                            i.MinimumStock,
                            (i.MinimumStock - i.QuantityAvailable) AS UnitsNeeded,
                            s.SupplierName,
                            s.Phone AS SupplierPhone,
                            s.Email AS SupplierEmail,
                            i.LastRestocked
                        FROM Inventory i
                        INNER JOIN Products p ON i.ProductID = p.ProductID
                        INNER JOIN Stores st ON i.StoreID = st.StoreID
                        INNER JOIN Categories c ON p.CategoryID = c.CategoryID
                        INNER JOIN Suppliers s ON p.SupplierID = s.SupplierID
                        WHERE i.QuantityAvailable <= i.MinimumStock
                            AND p.IsActive = TRUE
                            AND p.CategoryID = @CategoryID
                        ORDER BY st.StoreName, i.QuantityAvailable ASC";
                    parameters.Add(new MySqlParameter("@CategoryID", categoryId));
                }
                break;

            case "4":
                // Filter by Store AND Category
                await ListStores();
                Console.Write("\nEnter Store ID: ");
                if (int.TryParse(Console.ReadLine(), out int storeId2))
                {
                    await ListCategories();
                    Console.Write("\nEnter Category ID: ");
                    if (int.TryParse(Console.ReadLine(), out int categoryId2))
                    {
                        query = @"
                            SELECT 
                                st.StoreName,
                                st.City,
                                p.ProductName,
                                p.SKU,
                                c.CategoryName,
                                i.QuantityAvailable,
                                i.MinimumStock,
                                (i.MinimumStock - i.QuantityAvailable) AS UnitsNeeded,
                                s.SupplierName,
                                s.Phone AS SupplierPhone,
                                s.Email AS SupplierEmail,
                                i.LastRestocked
                            FROM Inventory i
                            INNER JOIN Products p ON i.ProductID = p.ProductID
                            INNER JOIN Stores st ON i.StoreID = st.StoreID
                            INNER JOIN Categories c ON p.CategoryID = c.CategoryID
                            INNER JOIN Suppliers s ON p.SupplierID = s.SupplierID
                            WHERE i.QuantityAvailable <= i.MinimumStock
                                AND p.IsActive = TRUE
                                AND i.StoreID = @StoreID
                                AND p.CategoryID = @CategoryID
                            ORDER BY i.QuantityAvailable ASC, p.ProductName";
                        parameters.Add(new MySqlParameter("@StoreID", storeId2));
                        parameters.Add(new MySqlParameter("@CategoryID", categoryId2));
                    }
                }
                break;

            default:
                // All Low-Stock Products
                query = @"
                    SELECT 
                        st.StoreName,
                        st.City,
                        p.ProductName,
                        p.SKU,
                        c.CategoryName,
                        i.QuantityAvailable,
                        i.MinimumStock,
                        (i.MinimumStock - i.QuantityAvailable) AS UnitsNeeded,
                        s.SupplierName,
                        s.Phone AS SupplierPhone,
                        s.Email AS SupplierEmail,
                        i.LastRestocked
                    FROM Inventory i
                    INNER JOIN Products p ON i.ProductID = p.ProductID
                    INNER JOIN Stores st ON i.StoreID = st.StoreID
                    INNER JOIN Categories c ON p.CategoryID = c.CategoryID
                    INNER JOIN Suppliers s ON p.SupplierID = s.SupplierID
                    WHERE i.QuantityAvailable <= i.MinimumStock
                        AND p.IsActive = TRUE
                    ORDER BY i.QuantityAvailable ASC, st.StoreName, p.ProductName";
                break;
        }

        if (!string.IsNullOrEmpty(query))
        {
            Console.WriteLine();
            Console.ForegroundColor = ConsoleColor.Yellow;
            Console.WriteLine("⚠️  LOW-STOCK ALERTS:");
            Console.ResetColor();
            Console.WriteLine();

            int totalProducts = 0;
            int totalUnitsNeeded = 0;

            await ExecuteQuery(query, reader =>
            {
                Console.ForegroundColor = reader["QuantityAvailable"].ToString() == "0" ? ConsoleColor.Red : ConsoleColor.Yellow;
                Console.WriteLine($"Store: {reader["StoreName"]} ({reader["City"]})");
                Console.ResetColor();
                
                Console.WriteLine($"Product: {reader["ProductName"]}");
                Console.WriteLine($"SKU: {reader["SKU"]}");
                Console.WriteLine($"Category: {reader["CategoryName"]}");
                
                Console.ForegroundColor = ConsoleColor.Red;
                Console.WriteLine($"Available: {reader["QuantityAvailable"]} (Minimum: {reader["MinimumStock"]})");
                Console.ResetColor();
                
                int unitsNeeded = Convert.ToInt32(reader["UnitsNeeded"]);
                Console.ForegroundColor = ConsoleColor.Cyan;
                Console.WriteLine($"Units Needed: {unitsNeeded}");
                Console.ResetColor();
                
                Console.WriteLine($"Supplier: {reader["SupplierName"]}");
                Console.WriteLine($"Supplier Phone: {reader["SupplierPhone"]}");
                Console.WriteLine($"Supplier Email: {reader["SupplierEmail"]}");
                
                if (reader["LastRestocked"] != DBNull.Value)
                {
                    Console.WriteLine($"Last Restocked: {reader["LastRestocked"]:yyyy-MM-dd HH:mm}");
                }
                
                Console.WriteLine(new string('─', 60));
                
                totalProducts++;
                totalUnitsNeeded += unitsNeeded;
            }, parameters.Count > 0 ? parameters.ToArray() : null);

            if (totalProducts > 0)
            {
                Console.WriteLine();
                Console.ForegroundColor = ConsoleColor.Cyan;
                Console.WriteLine("SUMMARY:");
                Console.WriteLine($"Total Low-Stock Products: {totalProducts}");
                Console.WriteLine($"Total Units Needed to Restock: {totalUnitsNeeded}");
                Console.ResetColor();
            }
        }
    }

    // ============================================
    // 8. TOP-PERFORMING SUPPLIERS REPORT
    // ============================================
    static async Task ShowTopSuppliersReport()
    {
        Console.ForegroundColor = ConsoleColor.Cyan;
        Console.WriteLine("═══════════════════════════════════════════════════════════");
        Console.WriteLine("           TOP-PERFORMING SUPPLIERS REPORT");
        Console.WriteLine("═══════════════════════════════════════════════════════════");
        Console.ResetColor();
        Console.WriteLine();

        Console.WriteLine("Rank suppliers by:");
        Console.WriteLine("  1. Total Stock Delivered (All-Time)");
        Console.WriteLine("  2. Number of Products Supplied");
        Console.WriteLine("  3. Supplier Rating");
        Console.WriteLine("  4. Most Delayed Deliveries (Top 3)");
        Console.Write("\nEnter your choice (1-4): ");
        string rankChoice = Console.ReadLine() ?? "1";

        string query = "";
        string rankBy = "";

        switch (rankChoice)
        {
            case "2":
                // Rank by Number of Products
                rankBy = "Number of Products";
                query = @"
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
                        COALESCE(SUM(pd.QuantityDelivered), 0) AS TotalStockDelivered,
                        COUNT(DISTINCT pd.DeliveryID) AS TotalDeliveries,
                        COALESCE(AVG(pd.UnitCost), 0) AS AvgDeliveryCost,
                        COALESCE(SUM(pd.TotalCost), 0) AS TotalValue
                    FROM Suppliers s
                    INNER JOIN Products p ON s.SupplierID = p.SupplierID
                    LEFT JOIN ProductDeliveries pd ON s.SupplierID = pd.SupplierID AND pd.DeliveryStatus = 'Delivered'
                    WHERE p.IsActive = TRUE
                    GROUP BY s.SupplierID, s.SupplierName, s.ContactName, s.Email, s.Phone, s.City, s.Country, s.Rating
                    ORDER BY ProductCount DESC, TotalStockDelivered DESC
                    LIMIT 10";
                break;

            case "3":
                // Rank by Rating
                rankBy = "Supplier Rating";
                query = @"
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
                        COALESCE(SUM(pd.QuantityDelivered), 0) AS TotalStockDelivered,
                        COUNT(DISTINCT pd.DeliveryID) AS TotalDeliveries,
                        COALESCE(AVG(pd.UnitCost), 0) AS AvgDeliveryCost,
                        COALESCE(SUM(pd.TotalCost), 0) AS TotalValue
                    FROM Suppliers s
                    LEFT JOIN Products p ON s.SupplierID = p.SupplierID AND p.IsActive = TRUE
                    LEFT JOIN ProductDeliveries pd ON s.SupplierID = pd.SupplierID AND pd.DeliveryStatus = 'Delivered'
                    GROUP BY s.SupplierID, s.SupplierName, s.ContactName, s.Email, s.Phone, s.City, s.Country, s.Rating
                    ORDER BY s.Rating DESC, TotalStockDelivered DESC
                    LIMIT 10";
                break;

            default:
                // Rank by Total Stock Delivered
                rankBy = "Total Stock Delivered";
                query = @"
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
                        COALESCE(SUM(pd.QuantityDelivered), 0) AS TotalStockDelivered,
                        COUNT(DISTINCT pd.DeliveryID) AS TotalDeliveries,
                        COALESCE(AVG(pd.UnitCost), 0) AS AvgDeliveryCost,
                        COALESCE(SUM(pd.TotalCost), 0) AS TotalValue
                    FROM Suppliers s
                    INNER JOIN Products p ON s.SupplierID = p.SupplierID
                    LEFT JOIN ProductDeliveries pd ON s.SupplierID = pd.SupplierID AND pd.DeliveryStatus = 'Delivered'
                    WHERE p.IsActive = TRUE
                    GROUP BY s.SupplierID, s.SupplierName, s.ContactName, s.Email, s.Phone, s.City, s.Country, s.Rating
                    ORDER BY TotalStockDelivered DESC
                    LIMIT 10";
                break;

            case "4":
                // Rank by Most Delayed Deliveries
                rankBy = "Most Delayed Deliveries";
                query = @"
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
                    LIMIT 3";
                break;
        }

        Console.WriteLine();
        Console.ForegroundColor = ConsoleColor.Green;
        
        // Different heading for delayed deliveries (TOP 3 instead of TOP 10)
        if (rankChoice == "4")
        {
            Console.WriteLine($"⚠️  TOP 3 SUPPLIERS - Most Delayed Deliveries:");
        }
        else
        {
            Console.WriteLine($"🏆 TOP 10 SUPPLIERS - Ranked by {rankBy}:");
        }
        Console.ResetColor();
        Console.WriteLine();

        int rank = 1;
        long grandTotalStock = 0;
        int grandTotalProducts = 0;
        int grandTotalDelays = 0;
        decimal grandTotalAvgDelay = 0;

        await ExecuteQuery(query, reader =>
        {
            // Ranking badge
            Console.ForegroundColor = rank switch
            {
                1 => ConsoleColor.Yellow,    // Gold
                2 => ConsoleColor.Gray,      // Silver
                3 => ConsoleColor.DarkYellow, // Bronze
                _ => ConsoleColor.White
            };
            Console.WriteLine($"#{rank} RANK");
            Console.ResetColor();

            Console.WriteLine($"Supplier: {reader["SupplierName"]}");
            Console.WriteLine($"Contact: {reader["ContactName"]}");
            Console.WriteLine($"Location: {reader["City"]}, {reader["Country"]}");
            Console.WriteLine($"Email: {reader["Email"]}");
            Console.WriteLine($"Phone: {reader["Phone"]}");
            
            // Supplier Rating with stars
            decimal rating = Convert.ToDecimal(reader["Rating"]);
            string stars = new string('⭐', (int)Math.Round(rating));
            Console.ForegroundColor = ConsoleColor.Yellow;
            Console.WriteLine($"Rating: {rating:F2}/5.00 {stars}");
            Console.ResetColor();

            long totalStock = Convert.ToInt64(reader["TotalStockDelivered"]);
            int productCount = Convert.ToInt32(reader["ProductCount"]);
            int totalDeliveries = Convert.ToInt32(reader["TotalDeliveries"]);
            
            Console.ForegroundColor = ConsoleColor.Cyan;
            
            // For delayed deliveries report, show delay-specific metrics
            if (rankChoice == "4")
            {
                int delayedDeliveries = Convert.ToInt32(reader["DelayedDeliveries"]);
                decimal avgLeadTime = Convert.ToDecimal(reader["AvgLeadTimeDays"]);
                int maxLeadTime = Convert.ToInt32(reader["MaxLeadTimeDays"]);
                decimal totalValue = Convert.ToDecimal(reader["TotalValue"]);
                
                Console.ForegroundColor = ConsoleColor.Red;
                Console.WriteLine($"Delayed Deliveries: {delayedDeliveries} out of {totalDeliveries} ({(delayedDeliveries * 100.0 / totalDeliveries):F1}%)");
                Console.ForegroundColor = ConsoleColor.Yellow;
                Console.WriteLine($"Average Lead Time: {avgLeadTime:F1} days");
                Console.WriteLine($"Longest Lead Time: {maxLeadTime} days");
                Console.ForegroundColor = ConsoleColor.Cyan;
                Console.WriteLine($"Total Stock Delivered: {totalStock:N0} units");
                Console.WriteLine($"Products Supplied: {productCount}");
                Console.WriteLine($"Total Value Delivered: ${totalValue:N2}");
                
                grandTotalDelays += delayedDeliveries;
                grandTotalAvgDelay += avgLeadTime;
            }
            else
            {
                // Standard display for other ranking criteria
                decimal avgCost = Convert.ToDecimal(reader["AvgDeliveryCost"]);
                decimal totalValue = Convert.ToDecimal(reader["TotalValue"]);
                
                Console.WriteLine($"Total Stock Delivered: {totalStock:N0} units");
                Console.WriteLine($"Total Deliveries: {totalDeliveries}");
                Console.WriteLine($"Products Supplied: {productCount}");
                Console.WriteLine($"Average Delivery Cost: ${avgCost:F2} per unit");
                Console.WriteLine($"Total Value Delivered: ${totalValue:N2}");
            }
            Console.ResetColor();

            Console.WriteLine(new string('═', 60));

            grandTotalStock += totalStock;
            grandTotalProducts += productCount;
            rank++;
        });

        if (rank > 1)
        {
            Console.WriteLine();
            Console.ForegroundColor = ConsoleColor.Cyan;
            Console.WriteLine("OVERALL SUMMARY:");
            
            if (rankChoice == "4")
            {
                // Summary for delayed deliveries
                Console.ForegroundColor = ConsoleColor.Red;
                Console.WriteLine($"Total Delayed Deliveries (Top 3): {grandTotalDelays}");
                Console.ForegroundColor = ConsoleColor.Yellow;
                Console.WriteLine($"Average Lead Time Across Top 3: {(grandTotalAvgDelay / (rank - 1)):F1} days");
                Console.ForegroundColor = ConsoleColor.Cyan;
                Console.WriteLine($"Total Stock from These Suppliers: {grandTotalStock:N0} units");
                Console.WriteLine($"Total Products from These Suppliers: {grandTotalProducts}");
            }
            else
            {
                // Standard summary for other criteria
                Console.WriteLine($"Total Stock from Top Suppliers: {grandTotalStock:N0} units");
                Console.WriteLine($"Total Products from Top Suppliers: {grandTotalProducts}");
                Console.WriteLine($"Average Stock per Supplier: {(grandTotalStock / (rank - 1)):N0} units");
            }
            Console.ResetColor();
        }
    }

    // ============================================
    // HELPER METHODS
    // ============================================

    static async Task ExecuteQuery(string query, Action<MySqlDataReader> processRow, MySqlParameter[]? parameters = null)
    {
        try
        {
            using var connection = new MySqlConnection(connectionString);
            await connection.OpenAsync();

            using var command = new MySqlCommand(query, connection);
            if (parameters != null)
            {
                command.Parameters.AddRange(parameters);
            }

            using var reader = await command.ExecuteReaderAsync();
            
            int count = 0;
            while (await reader.ReadAsync())
            {
                processRow(reader);
                count++;
            }

            if (count == 0)
            {
                Console.ForegroundColor = ConsoleColor.Yellow;
                Console.WriteLine("No records found.");
                Console.ResetColor();
            }
            else
            {
                Console.WriteLine();
                Console.ForegroundColor = ConsoleColor.Gray;
                Console.WriteLine($"Total records: {count}");
                Console.ResetColor();
            }
        }
        catch (MySqlException ex)
        {
            Console.ForegroundColor = ConsoleColor.Red;
            Console.WriteLine($"\n❌ Database Error: {ex.Message}");
            Console.WriteLine($"Error Code: {ex.Number}");
            Console.ResetColor();
        }
        catch (Exception ex)
        {
            Console.ForegroundColor = ConsoleColor.Red;
            Console.WriteLine($"\n❌ Error: {ex.Message}");
            Console.ResetColor();
        }
    }

    static async Task ListStores()
    {
        Console.WriteLine("\nAvailable Stores:");
        string query = "SELECT StoreID, StoreName, City FROM Stores ORDER BY StoreName";
        await ExecuteQuery(query, reader =>
        {
            Console.WriteLine($"  [{reader["StoreID"]}] {reader["StoreName"]} - {reader["City"]}");
        });
    }

    static async Task ListCategories()
    {
        Console.WriteLine("\nAvailable Categories:");
        string query = "SELECT CategoryID, CategoryName FROM Categories ORDER BY CategoryName";
        await ExecuteQuery(query, reader =>
        {
            Console.WriteLine($"  [{reader["CategoryID"]}] {reader["CategoryName"]}");
        });
    }

    static async Task ListProducts()
    {
        Console.WriteLine("\nAvailable Products (first 20):");
        string query = "SELECT ProductID, ProductName, SKU FROM Products ORDER BY ProductName LIMIT 20";
        await ExecuteQuery(query, reader =>
        {
            Console.WriteLine($"  [{reader["ProductID"]}] {reader["ProductName"]} ({reader["SKU"]})");
        });
    }
}
