--database creation and table setup for freshmart stock health report
CREATE DATABASE IF NOT EXISTS freshmart;
USE freshmart;

DROP TABLE IF EXISTS SalesTransactions;
DROP TABLE IF EXISTS Products;
DROP TABLE IF EXISTS Categories;


-- Table Creation
CREATE TABLE Categories (
    CategoryID INT PRIMARY KEY,
    CategoryName VARCHAR(100) NOT NULL UNIQUE
);
desc Categories ;

CREATE TABLE Products (
    ProductID INT NOT NULL AUTO_INCREMENT,
    ProductName VARCHAR(150) NOT NULL,
    CategoryID INT NOT NULL,
    UnitPrice DECIMAL(10,2) NOT NULL,
    StockCount INT NOT NULL,
    ExpiryDate DATE NOT NULL,
    PRIMARY KEY (ProductID),
    CONSTRAINT FK_Products_Categories
        FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID)
);
desc Products ;

CREATE TABLE SalesTransactions (
    TransactionID INT NOT NULL AUTO_INCREMENT,
    ProductID INT NOT NULL,
    QuantitySold INT NOT NULL,
    UnitPrice DECIMAL(10,2) NOT NULL,
    TransactionDate DATE NOT NULL,
    PRIMARY KEY (TransactionID),
    CONSTRAINT FK_SalesTransactions_Products
        FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);
desc SalesTransactions ;

-- sample data insertion
INSERT INTO Categories (CategoryID, CategoryName) VALUES
(1, 'Dairy'),
(2, 'Bakery'),
(3, 'Beverages'),
(4, 'Snacks'),
(5, 'Produce');
select * from Categories ;

INSERT INTO Products (ProductID, ProductName, CategoryID, UnitPrice, StockCount, ExpiryDate) VALUES
(101, 'Whole Milk 1L', 1, 2.80, 75, DATE_ADD(CURDATE(), INTERVAL 3 DAY)),
(102, 'Greek Yogurt', 1, 4.20, 65, DATE_ADD(CURDATE(), INTERVAL 6 DAY)),
(103, 'Cheddar Cheese', 1, 5.50, 30, DATE_ADD(CURDATE(), INTERVAL 20 DAY)),
(104, 'Brown Bread', 2, 1.90, 55, DATE_ADD(CURDATE(), INTERVAL 2 DAY)),
(105, 'Butter Croissant', 2, 1.25, 25, DATE_ADD(CURDATE(), INTERVAL 1 DAY)),
(106, 'Orange Juice', 3, 3.60, 80, DATE_ADD(CURDATE(), INTERVAL 15 DAY)),
(107, 'Cola 2L', 3, 2.20, 120, DATE_ADD(CURDATE(), INTERVAL 180 DAY)),
(108, 'Potato Chips', 4, 1.75, 90, DATE_ADD(CURDATE(), INTERVAL 120 DAY)),
(109, 'Granola Bars', 4, 3.10, 60, DATE_ADD(CURDATE(), INTERVAL 90 DAY)),
(110, 'Bananas', 5, 1.10, 70, DATE_ADD(CURDATE(), INTERVAL 5 DAY)),
(111, 'Spinach Pack', 5, 2.40, 58, DATE_ADD(CURDATE(), INTERVAL 4 DAY)),
(112, 'Canned Soup', 4, 2.90, 140, DATE_ADD(CURDATE(), INTERVAL 365 DAY)),
(113, 'Herbal Tea', 3, 4.80, 45, DATE_ADD(CURDATE(), INTERVAL 240 DAY)),
(114, 'Frozen Peas', 5, 3.20, 85, DATE_ADD(CURDATE(), INTERVAL 300 DAY));
select * from Products ;

INSERT INTO SalesTransactions (TransactionID, ProductID, QuantitySold, UnitPrice, TransactionDate) VALUES
(1001, 101, 40, 2.80, DATE_SUB(CURDATE(), INTERVAL 5 DAY)),
(1002, 102, 22, 4.20, DATE_SUB(CURDATE(), INTERVAL 8 DAY)),
(1003, 104, 48, 1.90, DATE_SUB(CURDATE(), INTERVAL 3 DAY)),
(1004, 106, 35, 3.60, DATE_SUB(CURDATE(), INTERVAL 10 DAY)),
(1005, 107, 60, 2.20, DATE_SUB(CURDATE(), INTERVAL 12 DAY)),
(1006, 108, 55, 1.75, DATE_SUB(CURDATE(), INTERVAL 9 DAY)),
(1007, 109, 28, 3.10, DATE_SUB(CURDATE(), INTERVAL 14 DAY)),
(1008, 110, 75, 1.10, DATE_SUB(CURDATE(), INTERVAL 2 DAY)),
(1009, 111, 30, 2.40, DATE_SUB(CURDATE(), INTERVAL 6 DAY)),
(1010, 101, 18, 2.80, DATE_SUB(CURDATE(), INTERVAL 18 DAY)),
(1011, 106, 20, 3.60, DATE_SUB(CURDATE(), INTERVAL 21 DAY)),
(1012, 110, 40, 1.10, DATE_SUB(CURDATE(), INTERVAL 25 DAY)),
(1013, 114, 12, 3.20, DATE_SUB(CURDATE(), INTERVAL 28 DAY)),
(1014, 103, 15, 5.50, DATE_SUB(CURDATE(), INTERVAL 95 DAY)),
(1015, 105, 10, 1.25, DATE_SUB(CURDATE(), INTERVAL 120 DAY)),
(1016, 113, 8, 4.80, DATE_SUB(CURDATE(), INTERVAL 75 DAY));
select * from SalesTransactions ;

# Expiring Soon Query
SELECT
    ProductID,
    ProductName,
    StockCount,
    ExpiryDate
FROM Products
WHERE ExpiryDate BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 7 DAY)
  AND StockCount > 50
ORDER BY ExpiryDate, ProductName;

# Dead Stock Analysis query
SELECT
    p.ProductID,
    p.ProductName,
    p.StockCount,
    p.ExpiryDate
FROM Products p
LEFT JOIN SalesTransactions st
    ON p.ProductID = st.ProductID
   AND st.TransactionDate >= DATE_SUB(CURDATE(), INTERVAL 2 MONTH)
WHERE st.TransactionID IS NULL
ORDER BY p.ProductName;

# Revenue Contribution query
SELECT
    c.CategoryName,
    SUM(st.QuantitySold * st.UnitPrice) AS TotalRevenue
FROM SalesTransactions st
JOIN Products p
    ON st.ProductID = p.ProductID
JOIN Categories c
    ON p.CategoryID = c.CategoryID
WHERE st.TransactionDate >= DATE_FORMAT(DATE_SUB(CURDATE(), INTERVAL 1 MONTH), '%Y-%m-01')
  AND st.TransactionDate < DATE_FORMAT(CURDATE(), '%Y-%m-01')
GROUP BY c.CategoryID, c.CategoryName
ORDER BY TotalRevenue DESC;
