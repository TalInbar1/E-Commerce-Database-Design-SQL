--creating the database
CREATE TABLE ACCOUNTS (
    Email VARCHAR(40) PRIMARY KEY not null,
    First_name VARCHAR(12) not null,
    Last_name VARCHAR(12) not null,
    Username VARCHAR(15) not null,
    Password VARCHAR(30) not null
);

CREATE TABLE CREDITCARDS (
    Card_Number CHAR(16) PRIMARY KEY not null,
    Exp_date CHAR(5) not null,
    CVV CHAR(3) not null
);

CREATE TABLE COUNTRIES (
    Country VARCHAR(15) PRIMARY KEY not null,
    Delivery_price MONEY null
);

CREATE TABLE PRICES (
    B_TYPE VARCHAR(30) not null,
    Size VARCHAR(10) not null,
    Price MONEY not null,
    PRIMARY KEY (B_TYPE, Size)
   
);

CREATE TABLE BOTTLES (
    B_TYPE VARCHAR(30) not null,
	Size VARCHAR(10) not null,
    Color VARCHAR(15) not null,
    PRIMARY KEY (B_TYPE, Size, Color),
	FOREIGN KEY (B_TYPE,Size) REFERENCES PRICES (B_TYPE,Size)
);

CREATE TABLE ORDERS (
    OrderID INT PRIMARY KEY not null,
    OrderDT DATETIME not null,
    Address_Country VARCHAR(15) not null,
    Address_City VARCHAR(20) not null,
    Address_State VARCHAR(20) null,
    Address_Zip char(7) null,
    Coupon VARCHAR(20) null,
    Card_Number char(16) not null,
    Email VARCHAR(40) not null,
    FOREIGN KEY (Address_Country) REFERENCES COUNTRIES(Country),
    FOREIGN KEY (Card_Number) REFERENCES CREDITCARDS(Card_Number),
    FOREIGN KEY (Email) REFERENCES ACCOUNTS(Email)
);


CREATE TABLE SKETCHES (
    SketchID INT PRIMARY KEY not null,
    Side VARCHAR(5) null, -- for sketchs that is not on a bottle
    Fee MONEY null,
    Email VARCHAR(40) null,
    FOREIGN KEY (Email) REFERENCES ACCOUNTS(Email)
);

CREATE TABLE PICTURES (
    SketchID INT not null,
    Picture VARCHAR(300) not null,
    PRIMARY KEY (SketchID, Picture),
    FOREIGN KEY (SketchID) REFERENCES SKETCHES(SketchID)
);

CREATE TABLE TEXTS (
    SketchID INT not null,
    Text VARCHAR(100) not null,
    PRIMARY KEY (SketchID, Text),
    FOREIGN KEY (SketchID) REFERENCES SKETCHES(SketchID)
);

CREATE TABLE SEARCHES (
    IPaddress VARCHAR(100) not null,
    SearchDT DATETIME not null,
    Keywords VARCHAR(50) NULL,
    Category VARCHAR(30) NULL,
    Email VARCHAR(40) NULL,
    OrderID INT NULL,
    PRIMARY KEY (IPaddress, SearchDT),
    FOREIGN KEY (Email) REFERENCES ACCOUNTS(Email),
    FOREIGN KEY (OrderID) REFERENCES ORDERS(OrderID)
);

CREATE TABLE Quantities (
    B_TYPE VARCHAR(30) not null,
    Size VARCHAR(10) not null,
    Color VARCHAR(15) not null,
    OrderID INT not null,
    Quantity INT not null,
    PRIMARY KEY (B_TYPE, Size, Color, OrderID),
    FOREIGN KEY (B_TYPE, Size, Color) REFERENCES BOTTLES(B_Type, Size, Color),
    FOREIGN KEY (OrderID) REFERENCES ORDERS(OrderID)
);

CREATE TABLE S_INCLUDEDS (
    OrderID INT not null,
    SketchID INT not null,
    PRIMARY KEY (OrderID, SketchID),
    FOREIGN KEY (OrderID) REFERENCES ORDERS(OrderID),
    FOREIGN KEY (SketchID) REFERENCES SKETCHES(SketchID)
);

CREATE TABLE B_DESIGNS (
    B_Type VARCHAR(30) not null,
    Size VARCHAR(10) not null,
    Color VARCHAR(15) not null,
    SketchID INT not null,
    PRIMARY KEY (B_Type, Size, Color, SketchID),
    FOREIGN KEY (B_Type, Size, Color) REFERENCES BOTTLES(B_Type, Size, Color),
    FOREIGN KEY (SketchID) REFERENCES SKETCHES(SketchID)
);

CREATE TABLE SHOWS (
    B_TYPE VARCHAR(30) not null,
    Size VARCHAR(10) not null,
    Color VARCHAR(15) not null,
    IPaddress VARCHAR(100) not null,
    SearchDT DATETIME not null,
    PRIMARY KEY (B_TYPE, Size, Color, IPaddress, SearchDT),
    FOREIGN KEY (B_TYPE, Size, Color) REFERENCES BOTTLES(B_Type, Size, Color),
    FOREIGN KEY (IPaddress, SearchDT) REFERENCES SEARCHES(IPaddress, SearchDT)
);

ALTER TABLE CREDITCARDS
ADD CONSTRAINT ck_card_number
CHECK (Card_Number Like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]');

ALTER TABLE COUNTRIES
ADD CONSTRAINT ck_delivery_price
CHECK (Delivery_price >= 0);

ALTER TABLE PRICES
ADD CONSTRAINT ck_price
CHECK (Price >= 0);

ALTER TABLE SKETCHES
ADD CONSTRAINT ck_fee
CHECK (Fee >= 0);

ALTER TABLE Quantities
ADD CONSTRAINT ck_quantity
CHECK (Quantity >= 0);

ALTER TABLE SKETCHES
ADD CONSTRAINT ck__side
CHECK (side IN ('Back','Front'));

ALTER TABLE CREDITCARDS
ADD CONSTRAINT ck_cvv
CHECK (CVV LIKE '[0-9][0-9][0-9]')

ALTER TABLE CREDITCARDS
ADD CONSTRAINT ck_exp_date
CHECK (Exp_date LIKE '[0-9][0-9]/[0-9][0-9]');

ALTER TABLE ACCOUNTS
ADD CONSTRAINT ck_password
CHECK (LEN(password) >= 5) --on the site you must have at least 5 chars

ALTER TABLE ACCOUNTS
ADD CONSTRAINT ck_email
CHECK (Email LIKE '%@%.%')

ALTER TABLE PICTURES
ADD CONSTRAINT ck_picture
CHECK (Picture LIKE 'http://%.jpg' OR Picture LIKE 'https://%.jpg')

CREATE TABLE LOOKUP_TYPE_COLOR (
    B_TYPE VARCHAR(30) NOT NULL,
    Color  VARCHAR(15) NOT NULL,
    CONSTRAINT pk_lookup_type_color PRIMARY KEY (B_TYPE, Color)
);

CREATE TABLE LOOKUP_TYPE_SIZE (
    B_TYPE VARCHAR(30) NOT NULL,
    Size   VARCHAR(10) NOT NULL,
    CONSTRAINT pk_lookup_type_size PRIMARY KEY (B_TYPE, Size)
);

CREATE TABLE LOOKUP_CATEGORY (
 Category VARCHAR(30) NOT NULL,
 CONSTRAINT pk_lookup_category PRIMARY KEY (Category)
);

CREATE TABLE LOOKUP_COUPON (
	Coupon VARCHAR(20) NOT NULL,
	CONSTRAINT pk_lookup_coupon PRIMARY KEY (Coupon)
);

ALTER TABLE BOTTLES
ADD CONSTRAINT fk_type_color
FOREIGN KEY (B_TYPE, Color)
REFERENCES LOOKUP_TYPE_COLOR (B_TYPE, Color)

ALTER TABLE BOTTLES
ADD CONSTRAINT fk_type_size
FOREIGN KEY (B_TYPE, Size)
REFERENCES LOOKUP_TYPE_SIZE (B_TYPE, Size)

ALTER TABLE SEARCHES
ADD CONSTRAINT fk_category_lookup
FOREIGN KEY (Category)
REFERENCES LOOKUP_CATEGORY (Category);

ALTER TABLE ORDERS
ADD CONSTRAINT fk_coupon_lookup
FOREIGN KEY (Coupon)
REFERENCES LOOKUP_COUPON (Coupon);


--task 1
--Not nested queries
--first not nested
SELECT TOP 3 
    O.Address_Country AS Country,
    COUNT(O.OrderID) AS TotalOrders,
    COUNT(DISTINCT O.Email) AS UniqueCustomers
FROM ORDERS AS O
JOIN COUNTRIES AS C ON O.Address_Country = C.Country
JOIN ACCOUNTS AS A ON O.Email = A.Email
WHERE O.OrderDT >= DATEADD(YEAR, -2, GETDATE())
GROUP BY O.Address_Country
HAVING COUNT(DISTINCT O.Email) >= 10
ORDER BY TotalOrders DESC;


--second not nested
SELECT 
    O.Address_Country AS Country,
    CASE 
        WHEN LEFT(O.Card_Number, 4) = '4580' THEN 'VISA'
        WHEN LEFT(O.Card_Number, 4) = '5326' THEN 'MASTERCARD'
    END AS CardType,
    COUNT(DISTINCT O.Email) AS DistinctCustomers,
    SUM(Q.Quantity) AS TotalBottles,
    COUNT(CASE WHEN O.Coupon IS NOT NULL THEN 1 END) AS OrdersWithCoupon,
    COUNT(CASE WHEN O.Coupon IS NULL THEN 1 END) AS OrdersWithoutCoupon,
    CAST(COUNT(CASE WHEN O.Coupon IS NOT NULL THEN 1 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS CouponUsagePercentage
FROM 
    ORDERS AS O
JOIN 
    ACCOUNTS AS A ON O.Email = A.Email
JOIN 
    QUANTITIES AS Q ON O.OrderID = Q.OrderID
WHERE 
    LEFT(O.Card_Number, 4) IN ('4580', '5326')
GROUP BY 
    O.Address_Country,
    CASE 
        WHEN LEFT(O.Card_Number, 4) = '4580' THEN 'VISA'
        WHEN LEFT(O.Card_Number, 4) = '5326' THEN 'MASTERCARD'
    END
ORDER BY 
    O.Address_Country,
  CardType;



--Nested queries
--first nested
SELECT TOP 3
    CountryOrderStats.Country,
    CountryOrderStats.TotalOrders,
    CountryOrderStats.UniqueCustomers,
    CAST(CountryOrderStats.TotalOrders AS FLOAT) / CountryOrderStats.UniqueCustomers AS AvgOrdersPerCustomer
FROM (
    SELECT 
        O.Address_Country AS Country,
        COUNT(O.OrderID) AS TotalOrders,
        COUNT(DISTINCT O.Email) AS UniqueCustomers
    FROM ORDERS AS O
    GROUP BY O.Address_Country
) AS CountryOrderStats
WHERE CountryOrderStats.TotalOrders > 2
ORDER BY AvgOrdersPerCustomer DESC;


--second nested
SELECT 
    A.First_name, 
    A.Last_name, 
    A.Email,
    O.Address_Country AS Country
FROM ACCOUNTS AS A
JOIN ORDERS AS O ON A.Email = O.Email
WHERE A.Email NOT IN (
    SELECT DISTINCT S.Email
    FROM SKETCHES AS S
)
GROUP BY  A.First_name, A.Last_name, A.Email, O.Address_Country
ORDER BY O.Address_Country;


--Queries with Window Functions
--first query window function
SELECT 
    A.First_name + ' ' + A.Last_name AS FullName,
    O.Address_Country AS Country,
    COUNT(*) AS TotalOrders,
    RANK() OVER (PARTITION BY O.Address_Country ORDER BY COUNT(*) DESC) AS CountryRank,
    NTILE(4) OVER (PARTITION BY O.Address_Country ORDER BY COUNT(*) DESC) AS Quartile
FROM ORDERS O
JOIN ACCOUNTS A ON O.Email = A.Email
WHERE O.Coupon IS NOT NULL
GROUP BY A.First_name, A.Last_name, O.Address_Country
ORDER BY O.Address_Country, CountryRank;

--second query window function
SELECT 
    FullName,
    Email,
    MIN(CASE WHEN OrderRank = 1 THEN OrderDT END) AS FirstOrderDate,
    MAX(CASE WHEN OrderRank = TotalOrders - 1 THEN OrderDT END) AS SecondLastOrderDate,
    MAX(CASE WHEN OrderRank = TotalOrders THEN OrderDT END) AS LastOrderDate,
    MAX(CASE WHEN OrderRank = TotalOrders THEN DATEDIFF(DAY, PrevOrderDT, OrderDT) END) AS DaysBetweenLastTwoOrders,
    AVG(CASE WHEN PrevOrderDT IS NOT NULL THEN DATEDIFF(DAY, PrevOrderDT, OrderDT) * 1.0 END) AS AvgDaysBetweenOrders
FROM (
    SELECT 
        O.Email,
        A.First_name + ' ' + A.Last_name AS FullName,
        O.OrderDT,
        ROW_NUMBER() OVER (PARTITION BY O.Email ORDER BY O.OrderDT ASC) AS OrderRank,
        LAG(O.OrderDT) OVER (PARTITION BY O.Email ORDER BY O.OrderDT ASC) AS PrevOrderDT,
        (SELECT COUNT(*) FROM ORDERS O2 WHERE O2.Email = O.Email) AS TotalOrders
    FROM ORDERS O
    JOIN ACCOUNTS A ON O.Email = A.Email
) AS Ranked
WHERE TotalOrders >= 3
GROUP BY FullName, Email
ORDER BY Email;


--Nested Query with CTE (with)
WITH OrdersPrevYear AS (
    SELECT 
        Q.B_TYPE,
        SUM(Q.Quantity) AS PrevYearSales
    FROM ORDERS AS O
    JOIN QUANTITIES AS Q ON O.OrderID = Q.OrderID
    WHERE O.OrderDT >= DATEADD(YEAR, -2, GETDATE())
      AND O.OrderDT < DATEADD(YEAR, -1, GETDATE())
    GROUP BY Q.B_TYPE
),
OrdersCurrYear AS (
    SELECT 
        Q.B_TYPE,
        SUM(Q.Quantity) AS CurrYearSales
    FROM ORDERS AS O
    JOIN QUANTITIES AS Q ON O.OrderID = Q.OrderID
    WHERE O.OrderDT >= DATEADD(YEAR, -1, GETDATE())
      AND O.OrderDT <= GETDATE()
    GROUP BY Q.B_TYPE
),
SalesSummary AS (
    SELECT 
        P.B_TYPE,
        P.PrevYearSales,
        ISNULL(C.CurrYearSales, 0) AS CurrYearSales
    FROM OrdersPrevYear AS P
    LEFT JOIN OrdersCurrYear AS C ON P.B_TYPE = C.B_TYPE
),
DropDetection AS (
    SELECT 
        B_TYPE,
        PrevYearSales,
        CurrYearSales,
        ROUND(100.0 * (PrevYearSales - CurrYearSales) / PrevYearSales, 2) AS DropPercent,
        RANK() OVER (ORDER BY ROUND(100.0 * (PrevYearSales - CurrYearSales) / PrevYearSales, 2) DESC) AS DropRank,
        CASE 
            WHEN ROUND(100.0 * (PrevYearSales - CurrYearSales) / PrevYearSales, 2) > 25 THEN 'Significant Drop'
            WHEN ROUND(100.0 * (PrevYearSales - CurrYearSales) / PrevYearSales, 2) > 17 THEN 'Moderate Drop'
            WHEN ROUND(100.0 * (PrevYearSales - CurrYearSales) / PrevYearSales, 2) >= 10 THEN 'Light Drop'
            ELSE 'NO DROP'
        END AS DropLevel
    FROM SalesSummary
    WHERE PrevYearSales >= 50
)

SELECT *
FROM (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY DropLevel ORDER BY DropPercent DESC) AS rn
    FROM DropDetection
    WHERE DropPercent >= 10
) AS RankedDrops
WHERE rn <= 3
ORDER BY DropLevel, DropPercent DESC;


--task 2
--View
CREATE VIEW OrderSummary AS
WITH BottleFees AS (
    SELECT
        bd.B_TYPE,
        bd.Size,
        bd.Color,
        si.OrderID,
        SUM(s.Fee) AS TotalFee
    FROM B_DESIGNS bd
    INNER JOIN S_INCLUDEDS si
        ON bd.SketchID = si.SketchID
    INNER JOIN SKETCHES s
        ON s.SketchID = si.SketchID
    GROUP BY
        bd.B_TYPE, bd.Size, bd.Color, si.OrderID
)
SELECT
    o.OrderID,
    o.OrderDT AS OrderDate,
    a.First_name + ' ' + a.Last_name AS FullName,
    a.Email,
    o.Address_Country AS Country,
    o.Address_City AS City,
	c.Delivery_price AS DeliveryPrice,
    CASE 
        WHEN lc.Coupon IS NOT NULL THEN
            SUM(
                p.Price * q.Quantity +
                ISNULL(bf.TotalFee, 0) * q.Quantity
            ) - 10 + c.Delivery_price
        ELSE
            SUM(
                p.Price * q.Quantity +
                ISNULL(bf.TotalFee, 0) * q.Quantity
            ) + c.Delivery_price
    END AS TotalFinalPrice,

    SUM(q.Quantity) AS TotalBottleCount,
    COUNT(DISTINCT CONCAT(q.B_TYPE, '|', q.Size)) AS DistinctBottleTypes,
    ISNULL(lc.Coupon, 'No Coupon') AS ValidCoupon

FROM ORDERS o
INNER JOIN ACCOUNTS a
    ON o.Email = a.Email

INNER JOIN Quantities q
    ON o.OrderID = q.OrderID

INNER JOIN PRICES p
    ON q.B_TYPE = p.B_TYPE
   AND q.Size = p.Size

INNER JOIN BOTTLES b
    ON q.B_TYPE = b.B_TYPE
   AND q.Size = b.Size
   AND q.Color = b.Color

LEFT JOIN BottleFees bf
    ON bf.OrderID = o.OrderID
   AND bf.B_TYPE = q.B_TYPE
   AND bf.Size = q.Size
   AND bf.Color = q.Color

LEFT JOIN LOOKUP_COUPON lc
    ON o.Coupon = lc.Coupon

INNER JOIN COUNTRIES c 
	ON o.Address_Country = c.Country

GROUP BY
    o.OrderID, o.OrderDT,
    a.First_name, a.Last_name, a.Email,
    o.Address_Country, o.Address_City,
    lc.Coupon,c.Delivery_price;

--code to check view
SELECT *
FROM OrderSummary
WHERE OrderID = 101;

--First Function
CREATE FUNCTION fn_GetOrderCountByCouponInDateRange (
    @Coupon VARCHAR(20),
    @FromDate DATE,
    @ToDate DATE
)
RETURNS INT
AS
BEGIN
    DECLARE @OrderCount INT;

    SELECT @OrderCount = COUNT(*)
    FROM OrderSummary
    WHERE ValidCoupon = @Coupon
      AND OrderDate BETWEEN @FromDate AND @ToDate;

    RETURN @OrderCount;
END;

--code to check first function
SELECT dbo.fn_GetOrderCountByCouponInDateRange(
	'SAVE10',
	'2024-01-01',
	'2024-12-31'
	) AS CouponUsageCount;

--Second Function
CREATE FUNCTION fn_GetCustomerQuarterlySummary (
    @Email VARCHAR(40),
    @Year INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        DATEPART(QUARTER, OrderDate) AS Quarter,
        COUNT(*) AS OrderCount,
        SUM(TotalFinalPrice) AS TotalSpent,
        SUM(TotalBottleCount) AS TotalBottles,
		FullName
    FROM OrderSummary
    WHERE Email = @Email
      AND YEAR(OrderDate) = @Year
    GROUP BY  FullName, DATEPART(QUARTER, OrderDate)
);

--code to check second function
SELECT *
FROM dbo.fn_GetCustomerQuarterlySummary ('michael.johnson@gmail.com', 2024);

--Trigger 
-- Add a column to store total bottle count per account
ALTER TABLE ACCOUNTS
ADD TotalBottleCount INT DEFAULT 0

--Build the trigger that updates total bottle count after any change in Quantities
CREATE TRIGGER trg_UpdateTotalBottleCount
ON Quantities
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    -- Identify all customers affected (via OrderID)
    DECLARE @Emails TABLE (Email VARCHAR(40));
    -- From inserted rows
    INSERT INTO @Emails
    SELECT DISTINCT o.Email
    FROM INSERTED i
    JOIN Orders o ON i.OrderID = o.OrderID;
    -- From deleted rows
    INSERT INTO @Emails
    SELECT DISTINCT o.Email
    FROM DELETED d
    JOIN Orders o ON d.OrderID = o.OrderID;
    -- Recalculate total bottle count for each affected custome
    UPDATE a
    SET TotalBottleCount = (
        SELECT SUM(q.Quantity)
        FROM Orders o
        JOIN Quantities q ON o.OrderID = q.OrderID
        WHERE o.Email = a.Email
    )
    FROM Accounts a
    WHERE a.Email IN (SELECT Email FROM @Emails);
END;

-- Test the trigger: add 5 to the quantity of all orders belonging to a specific customer
--check the quantitues before updating
SELECT *
FROM Quantities
WHERE OrderID IN (
    SELECT OrderID
    FROM Orders
    WHERE Email = 'sarah.miller@post.bgu.ac.il'
);

UPDATE Quantities
SET Quantity = Quantity + 5
WHERE OrderID IN (
    SELECT OrderID
    FROM Orders
    WHERE Email = 'sarah.miller@post.bgu.ac.il'
);

--Check that quantities were updated
SELECT *
FROM Quantities
WHERE OrderID IN (
    SELECT OrderID
    FROM Orders
    WHERE Email = 'sarah.miller@post.bgu.ac.il'
);

--Check that TotalBottleCount column was updated
SELECT Email, TotalBottleCount
FROM Accounts
WHERE Email = 'sarah.miller@post.bgu.ac.il';

--Procedure
CREATE OR ALTER PROCEDURE usp_GetReturningSearchers
    @FromDate DATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Step 1: Get the last order date for each account from orders
    WITH LastOrders AS (
        SELECT 
            Email,
            MAX(OrderDT) AS LastOrderDate
        FROM Orders
        GROUP BY Email
    ),

    -- Step 2: Searches within the range, by registered users, that did not result in an order, and occurred after their last order
    BaseSearches AS (
        SELECT s.*
        FROM Searches s
        LEFT JOIN LastOrders o ON s.Email = o.Email
        WHERE s.SearchDT >= @FromDate
          AND s.Email IS NOT NULL
          AND s.OrderID IS NULL
          AND s.SearchDT > ISNULL(o.LastOrderDate, '1900-01-01')
    ),

    -- Step 3: Summarize number of searches and last search date per account
    Summary AS (
        SELECT 
            Email,
            COUNT(*) AS SearchCount,
            MAX(SearchDT) AS LastSearchDate
        FROM BaseSearches
        GROUP BY Email
    ),

    -- Step 4: Count and get last date per category per account
    CategoryCounts AS (
        SELECT 
            Email,
            ISNULL(Category, 'Uncategorized') AS Category,
            COUNT(*) AS CategoryCount,
            MAX(SearchDT) AS LastSearchDT
        FROM BaseSearches
        GROUP BY Email, ISNULL(Category, 'Uncategorized')
    ),

    -- Select the top category (if tie – pick the most recent one)
    TopCategory AS (
        SELECT Email, Category
        FROM (
            SELECT 
                Email,
                Category,
                ROW_NUMBER() OVER (
                    PARTITION BY Email 
                    ORDER BY CategoryCount DESC, LastSearchDT DESC
                ) AS rn
            FROM CategoryCounts
        ) Ranked
        WHERE rn = 1
    )

    -- Step 6: Final combined and accurate result
    SELECT 
        s.Email,
        s.LastSearchDate,
        s.SearchCount,
        tc.Category AS TopCategory
    FROM Summary s
    LEFT JOIN TopCategory tc ON s.Email = tc.Email
    ORDER BY s.SearchCount DESC;
END;

--Execute the procedure
EXEC usp_GetReturningSearchers @FromDate = '2024-05-03';


--task 3
--view for dashboard
-- Detailed view per Quantities row, including order data and revenue
CREATE VIEW OrderItemDetails_FromSummary AS
WITH TotalQuantities AS (
    SELECT OrderID, SUM(Quantity) AS TotalOrderQuantity
    FROM Quantities
    GROUP BY OrderID
)
SELECT
    os.OrderID,
    os.OrderDate,
    FORMAT(os.OrderDate, 'yyyy/MM') AS YearMonth,
    os.Email,
    os.FullName,
    os.Country,
    os.City,
    q.B_TYPE,
    q.Size,
    q.Color,
    q.Quantity,
    
    -- Calculate revenue for each product line
    CAST(os.TotalFinalPrice * 1.0 * q.Quantity / tq.TotalOrderQuantity AS MONEY) AS LineRevenue

FROM OrderSummary os
JOIN Quantities q ON os.OrderID = q.OrderID
JOIN (
    SELECT OrderID, SUM(Quantity) AS TotalOrderQuantity
    FROM Quantities
    GROUP BY OrderID
) tq ON q.OrderID = tq.OrderID;

--views for report
--Monthly Sales and Revenue (without delivery fee and coupon discount) per Product Last Year
CREATE VIEW V_Sales_Monthly_Summary AS
SELECT 
    FORMAT(O.OrderDT, 'yyyy-MM') AS MonthYear,
    Q.B_TYPE,
    SUM(Q.Quantity) AS Total_Units_Sold,
    SUM(Q.Quantity * P.Price) AS Total_Revenue
FROM 
    ORDERS O
JOIN 
    Quantities Q ON O.OrderID = Q.OrderID
JOIN 
    PRICES P ON Q.B_TYPE = P.B_TYPE AND Q.Size = P.Size
WHERE 
    O.OrderDT >= '2024-06-01' AND O.OrderDT < '2025-06-01'
GROUP BY 
    FORMAT(O.OrderDT, 'yyyy-MM'), Q.B_TYPE;
	  

-- Monthly orders per counrty using coupons last year 
CREATE VIEW V_Orders_With_Coupon_By_Country AS
SELECT 
    FORMAT(OrderDT, 'yyyy-MM') AS MonthYear,
    Address_Country AS Country,
    Coupon,
    COUNT(*) AS Orders_With_Coupon
FROM 
    ORDERS
WHERE 
    OrderDT >= '2024-06-01' AND OrderDT < '2025-06-01'
    AND Coupon IS NOT NULL
GROUP BY 
    FORMAT(OrderDT, 'yyyy-MM'), Address_Country, Coupon;

--Total revenue (without delivery fee and coupon discount) per country and month
CREATE VIEW V_Revenue_By_Country_Month AS
SELECT 
    FORMAT(O.OrderDT, 'yyyy-MM') AS MonthYear,
    O.Address_Country AS Country,
    Q.B_TYPE,
    Q.Color,
    Q.Size,
    SUM(Q.Quantity * P.Price) AS Total_Revenue
FROM 
    ORDERS O
JOIN 
    Quantities Q ON O.OrderID = Q.OrderID
JOIN 
    PRICES P ON Q.B_TYPE = P.B_TYPE AND Q.Size = P.Size
WHERE 
    O.OrderDT >= '2024-06-01' AND O.OrderDT < '2025-06-01'
GROUP BY 
    FORMAT(O.OrderDT, 'yyyy-MM'),
    O.Address_Country,
    Q.B_TYPE,
    Q.Color,
    Q.Size;

-- Search to purchase and revenue conversion rates last year
CREATE VIEW V_Search_Conversion_Stats AS
WITH TotalSearches AS (
    SELECT COUNT(*) AS Total FROM SEARCHES
),
SearchesWithOrder AS (
    SELECT COUNT(*) AS WithOrder 
    FROM SEARCHES 
    WHERE OrderID IS NOT NULL
),
RevenueFromSearches AS (
    SELECT 
        SUM(Q.Quantity * P.Price) AS Revenue_Searches
    FROM 
        SEARCHES S
    JOIN ORDERS O ON S.OrderID = O.OrderID
    JOIN Quantities Q ON O.OrderID = Q.OrderID
    JOIN PRICES P ON Q.B_TYPE = P.B_TYPE AND Q.Size = P.Size
    WHERE 
        S.OrderID IS NOT NULL
        AND O.OrderDT >= '2024-06-01' AND O.OrderDT < '2025-06-01'
),
TotalRevenue AS (
    SELECT 
        SUM(Q.Quantity * P.Price) AS Total_Revenue
    FROM 
        ORDERS O
    JOIN Quantities Q ON O.OrderID = Q.OrderID
    JOIN PRICES P ON Q.B_TYPE = P.B_TYPE AND Q.Size = P.Size
    WHERE 
        O.OrderDT >= '2024-06-01' AND O.OrderDT < '2025-06-01'
)
SELECT 
    CAST(1.0 * SWO.WithOrder / TS.Total AS DECIMAL(5,4)) AS Searches_Lead_To_Order_Percent,
    CAST(1.0 * RFS.Revenue_Searches / TR.Total_Revenue AS DECIMAL(5,4)) AS Revenue_From_Searches_Percent
FROM 
    TotalSearches TS,
    SearchesWithOrder SWO,
    RevenueFromSearches RFS,
    TotalRevenue TR;

--Monthly breakdown of orders and revenue by credit card type last year
CREATE VIEW V_Orders_By_CreditCard_Type_Monthly AS
SELECT 
    FORMAT(O.OrderDT, 'yyyy-MM') AS MonthYear,
    CASE 
        WHEN LEFT(Card_Number, 4) = '5326' THEN 'MASTERCARD'
        WHEN LEFT(Card_Number, 4) = '4580' THEN 'VISA'
        ELSE 'OTHER'
    END AS CreditCardType,
    COUNT(*) AS Total_Orders,
    SUM(Q.Quantity * P.Price) AS Total_Revenue
FROM 
    ORDERS O
JOIN 
    Quantities Q ON O.OrderID = Q.OrderID
JOIN 
    PRICES P ON Q.B_TYPE = P.B_TYPE AND Q.Size = P.Size
WHERE 
    O.OrderDT >= '2024-06-01' AND O.OrderDT < '2025-06-01'
GROUP BY 
    FORMAT(O.OrderDT, 'yyyy-MM'),
    CASE 
        WHEN LEFT(Card_Number, 4) = '5326' THEN 'MASTERCARD'
        WHEN LEFT(Card_Number, 4) = '4580' THEN 'VISA'
        ELSE 'OTHER'
    END;


--KPI summary of orders, customers, revenue and averages last year
CREATE VIEW V_KPI_Summary AS
SELECT
    COUNT(DISTINCT O.OrderID) AS Total_Orders,
    SUM(Q.Quantity * P.Price) AS Total_Revenue,
    COUNT(DISTINCT O.Email) AS Active_Customers,
    CAST(SUM(Q.Quantity * P.Price) * 1.0 / NULLIF(COUNT(DISTINCT O.OrderID), 0) AS DECIMAL(10,2)) AS Avg_Revenue_Per_Order,
    CAST(SUM(Q.Quantity) * 1.0 / NULLIF(COUNT(DISTINCT O.OrderID), 0) AS DECIMAL(10,2)) AS Avg_Units_Per_Order
FROM 
    ORDERS O
JOIN 
    Quantities Q ON O.OrderID = Q.OrderID
JOIN 
    PRICES P ON Q.B_TYPE = P.B_TYPE AND Q.Size = P.Size
WHERE 
    O.OrderDT >= '2024-06-01' AND O.OrderDT < '2025-06-01';


--total sketch revenue and it's share of overall revenue last year
CREATE VIEW V_KPI_Sketch_Revenue_Only AS
WITH SketchRevenue AS (
    SELECT 
        SUM(Q.Quantity * S.Fee) AS Total_Sketch_Revenue
    FROM 
        S_INCLUDEDS SI
    JOIN SKETCHES S ON SI.SketchID = S.SketchID
    JOIN ORDERS O ON SI.OrderID = O.OrderID
    JOIN B_DESIGNS BD ON BD.SketchID = SI.SketchID
    JOIN Quantities Q 
        ON Q.OrderID = SI.OrderID 
        AND Q.B_TYPE = BD.B_TYPE 
        AND Q.Size = BD.Size 
        AND Q.Color = BD.Color
    WHERE 
        O.OrderDT >= '2024-06-01' AND O.OrderDT < '2025-06-01'
),
TotalRevenue AS (
    SELECT 
        SUM(Q.Quantity * P.Price) +
        ISNULL((
            SELECT SUM(Q.Quantity * S.Fee)
            FROM S_INCLUDEDS SI
            JOIN SKETCHES S ON SI.SketchID = S.SketchID
            JOIN ORDERS O ON SI.OrderID = O.OrderID
            JOIN B_DESIGNS BD ON BD.SketchID = SI.SketchID
            JOIN Quantities Q 
                ON Q.OrderID = SI.OrderID 
                AND Q.B_TYPE = BD.B_TYPE 
                AND Q.Size = BD.Size 
                AND Q.Color = BD.Color
            WHERE O.OrderDT >= '2024-06-01' AND O.OrderDT < '2025-06-01'
        ), 0) AS Total_Revenue
    FROM 
        ORDERS O
    JOIN Quantities Q ON O.OrderID = Q.OrderID
    JOIN PRICES P ON Q.B_TYPE = P.B_TYPE AND Q.Size = P.Size
    WHERE 
        O.OrderDT >= '2024-06-01' AND O.OrderDT < '2025-06-01'
)
SELECT 
    SR.Total_Sketch_Revenue,
    TR.Total_Revenue,
    CAST(100.0 * SR.Total_Sketch_Revenue / NULLIF(TR.Total_Revenue, 0) AS DECIMAL(5,2)) AS Sketch_Revenue_Percent
FROM 
    SketchRevenue SR,
    TotalRevenue TR;


--task 4
-- first after fixing

-- index for filtering by coupon and date
CREATE NONCLUSTERED INDEX idx_orders_coupon_date
ON ORDERS (Coupon, OrderDT);

CREATE OR ALTER FUNCTION fn_GetOrderCountByCouponInDateRange_Optimized (
    @Coupon VARCHAR(20),
    @FromDate DATE,
    @ToDate DATE
)
RETURNS INT
AS
BEGIN
    DECLARE @OrderCount INT;

    SELECT @OrderCount = COUNT(DISTINCT o.OrderID)
    FROM ORDERS o
    INNER JOIN LOOKUP_COUPON lc
        ON o.Coupon = lc.Coupon
    WHERE o.Coupon = @Coupon
      AND o.OrderDT BETWEEN @FromDate AND @ToDate;

    RETURN @OrderCount;
END;



-- second after fixing

--index for filtering by customer and date in orders
CREATE NONCLUSTERED INDEX idx_orders_email_date
ON ORDERS (Email, OrderDT);

--index for joining Quantities to Orders quickly
CREATE NONCLUSTERED INDEX idx_quantities_orderid
ON Quantities (OrderID, B_TYPE, Size, Color, Quantity);

CREATE OR ALTER FUNCTION fn_GetCustomerQuarterlySummary_Optimized (
    @Email VARCHAR(40),
    @Year INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        DATEPART(QUARTER, o.OrderDT) AS Quarter,
        COUNT(*) AS OrderCount,
        SUM(
            p.Price * q.Quantity +
            ISNULL(s.Fee, 0) * q.Quantity +
            ISNULL(c.Delivery_price, 0)
        ) AS TotalSpent,
        SUM(q.Quantity) AS TotalBottles,
        a.First_name + ' ' + a.Last_name AS FullName
    FROM ORDERS o
    INNER JOIN ACCOUNTS a ON o.Email = a.Email
    INNER JOIN Quantities q ON o.OrderID = q.OrderID
    INNER JOIN PRICES p ON q.B_TYPE = p.B_TYPE AND q.Size = p.Size
    INNER JOIN BOTTLES b ON q.B_TYPE = b.B_TYPE AND q.Size = b.Size AND q.Color = b.Color
    LEFT JOIN COUNTRIES c ON o.Address_Country = c.Country
    LEFT JOIN S_INCLUDEDS si ON si.OrderID = o.OrderID
    LEFT JOIN SKETCHES s ON s.SketchID = si.SketchID
    WHERE o.Email = @Email
      AND YEAR(o.OrderDT) = @Year
    GROUP BY DATEPART(QUARTER, o.OrderDT), a.First_name, a.Last_name
);

--task BONUS
--first bonus - pivot
WITH SketchTypes AS (
    SELECT 
        S.SketchID,
        CASE 
            WHEN T.SketchID IS NOT NULL AND P.SketchID IS NULL THEN 'Text Only'
            WHEN T.SketchID IS NULL AND P.SketchID IS NOT NULL THEN 'Picture Only'
            WHEN T.SketchID IS NOT NULL AND P.SketchID IS NOT NULL THEN 'Text and Picture'
        END AS SketchType
    FROM SKETCHES AS S
    LEFT JOIN TEXTS AS T ON S.SketchID = T.SketchID
    LEFT JOIN PICTURES AS P ON S.SketchID = P.SketchID
),
OrdersWithSketches AS (
    SELECT 
        O.OrderID,
        FORMAT(O.OrderDT, 'yyyy-MM') AS YearMonth,
        ST.SketchType
    FROM ORDERS AS O
    JOIN S_INCLUDEDS AS SI ON O.OrderID = SI.OrderID
    JOIN SketchTypes AS ST ON SI.SketchID = ST.SketchID
    WHERE O.OrderDT >= '2024-06-01' AND O.OrderDT < '2025-06-01'
),
MonthlySketchSummary AS (
    SELECT 
        YearMonth,
        SketchType,
        COUNT(DISTINCT OrderID) AS OrdersWithSketch
    FROM OrdersWithSketches
    GROUP BY YearMonth, SketchType
)
SELECT *
FROM MonthlySketchSummary
PIVOT (
    SUM(OrdersWithSketch)
    FOR SketchType IN ([Text Only], [Picture Only], [Text and Picture])
) AS PivotSketches
ORDER BY YearMonth;

--second bonus - try catch

CREATE TABLE ErrorLog (
    ErrorID INT PRIMARY KEY IDENTITY,        
    ErrorTime DATETIME DEFAULT GETDATE(), 
    ProcedureName VARCHAR(100),
    ErrorMessage VARCHAR(400),
    Email VARCHAR(40),
    CouponUsed VARCHAR(20)
);

CREATE PROCEDURE usp_AddOrder
    @OrderID INT,
    @OrderDT DATETIME,
    @Address_Country VARCHAR(15),
    @Address_City VARCHAR(20),
    @Address_State VARCHAR(20),
    @Address_Zip CHAR(7),
    @Coupon VARCHAR(20) = NULL,
    @Card_Number CHAR(16),
    @Email VARCHAR(40)
AS
BEGIN
    BEGIN TRY
        INSERT INTO ORDERS
        VALUES (
            @OrderID,
            @OrderDT,
            @Address_Country,
            @Address_City,
            @Address_State,
            @Address_Zip,
            @Coupon,
            @Card_Number,
            @Email
        );
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(400) = ERROR_MESSAGE();
        DECLARE @UserMessage NVARCHAR(200);

        IF @ErrorMessage LIKE '%LOOKUP_COUPON%'
            SET @UserMessage = 'Invalid coupon provided. Please try again.';
        ELSE IF @ErrorMessage LIKE '%PRIMARY KEY%'
            SET @UserMessage = 'Order ID already exists. Please use a different Order ID.';
        ELSE IF @ErrorMessage LIKE '%ACCOUNTS%'
            SET @UserMessage = 'Invalid email. This email address does not exist.';
        ELSE IF @ErrorMessage LIKE '%CREDITCARDS%'
            SET @UserMessage = 'Invalid card number. Please check your credit card.';
        ELSE IF @ErrorMessage LIKE '%COUNTRIES%'
            SET @UserMessage = 'Invalid country. Please select a valid shipping country.';
        ELSE
            SET @UserMessage = 'An unexpected error occurred. Please try again.';
	    -- Log the technical error
        INSERT INTO ErrorLog (
            ProcedureName,
            ErrorMessage,
            Email,
            CouponUsed
        )
        VALUES (
            'usp_AddOrder',
            @ErrorMessage,
            @Email,
            @Coupon
        );
		--Return a clear message to the user
        RAISERROR(@UserMessage, 16, 1);
    END CATCH
END;

--checking the second bonus
EXEC usp_AddOrder
    @OrderID = 201,
    @OrderDT = '2025-06-21 11:50:00',
    @Address_Country = 'Australia',
    @Address_City = 'Melbourne',
    @Address_State = 'Victoria',
    @Address_Zip = '100034',
    @Coupon = 'HI',
    @Card_Number = '4580423446399660',
    @Email = 'melissa.hill@post.bgu.ac.il';

EXEC usp_AddOrder
    @OrderID = 1,
    @OrderDT = '2025-06-21 11:50:00',
    @Address_Country = 'Australia',
    @Address_City = 'Melbourne',
    @Address_State = 'Victoria',
    @Address_Zip = '100034',
    @Coupon = NULL,
    @Card_Number = '4580423446399660',
    @Email = 'melissa.hill@post.bgu.ac.il';

EXEC usp_AddOrder
    @OrderID = 201,
    @OrderDT = '2025-06-21 11:50:00',
    @Address_Country = 'Australia',
    @Address_City = 'Melbourne',
    @Address_State = 'Victoria',
    @Address_Zip = '100034',
    @Coupon = 'NULL',
    @Card_Number = '4580423446399660',
    @Email = 'melissa@gmail.com';

EXEC usp_AddOrder
    @OrderID = 201,
    @OrderDT = '2025-06-21 11:50:00',
    @Address_Country = 'Australia',
    @Address_City = 'Melbourne',
    @Address_State = 'Victoria',
    @Address_Zip = '100034',
    @Coupon = 'NULL',
    @Card_Number = '1234567891234567',
    @Email = 'melissa.hill@post.bgu.ac.il';

	EXEC usp_AddOrder
    @OrderID = 201,
    @OrderDT = '2025-06-21 11:50:00',
    @Address_Country = 'Greece',
    @Address_City = 'Melbourne',
    @Address_State = 'Victoria',
    @Address_Zip = '100034',
    @Coupon = 'NULL',
    @Card_Number = '4580423446399660',
    @Email = 'melissa.hill@post.bgu.ac.il';


SELECT * FROM ErrorLog;











