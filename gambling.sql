use gambling;

#Question 01
SELECT 
    Title,
    FirstName,
    LastName,
    DateOfBirth
FROM Customer;

#Question 02
SELECT 
    CustomerGroup,
    COUNT(*) AS CustomerCount
FROM Customer
GROUP BY CustomerGroup
ORDER BY CustomerGroup;

#Question 03
SELECT 
    c.*,
    a.CurrencyCode
FROM Customer c
LEFT JOIN Account a ON c.CustId = a.CustId;

#Question 04
SELECT 
    b.BetDate,
    p.product,
    SUM(b.Bet_Amt) AS TotalBetAmount
FROM Betting_main b
INNER JOIN Product p 
    ON b.ClassId = p.CLASSID 
    AND b.CategoryId = p.CATEGORYID
GROUP BY b.BetDate, p.product
ORDER BY b.BetDate, p.product;

#Question 05
SELECT 
    p.product,
    b.BetDate,
    SUM(b.Bet_Amt) as Total_Bet_Amount
FROM Betting_main b
JOIN Product p ON b.ClassId = p.CLASSID AND b.CategoryId = p.CATEGORYID
WHERE b.BetDate >= '2012-11-01'  
  AND p.product = 'Sportsbook'
GROUP BY p.product, b.BetDate
ORDER BY b.BetDate;

#Question 06
SELECT 
    a.CurrencyCode,
    c.CustomerGroup,
    p.product,
    SUM(b.Bet_Amt) AS TotalBetAmount
FROM Betting_main b
INNER JOIN Product p 
    ON b.ClassId = p.CLASSID 
    AND b.CategoryId = p.CATEGORYID
INNER JOIN Account a 
    ON b.AccountNo = a.AccountNo
INNER JOIN Customer c 
    ON a.CustId = c.CustId
WHERE b.BetDate > '2012-12-01'
GROUP BY a.CurrencyCode, c.CustomerGroup, p.product
ORDER BY a.CurrencyCode, c.CustomerGroup, p.product;

#Question 07
SELECT 
    c.Title,
    c.FirstName,
    c.LastName,
    COALESCE(SUM(b.Bet_Amt), 0) AS TotalBetAmount
FROM Customer c
LEFT JOIN Account a ON c.CustId = a.CustId
LEFT JOIN Betting_main b ON a.AccountNo = b.AccountNo 
    AND b.BetDate >= '2012-11-01' 
    AND b.BetDate < '2012-12-01'
GROUP BY c.CustId, c.Title, c.FirstName, c.LastName
ORDER BY c.LastName, c.FirstName;

#Question 08
#Query 1 - Number of products per player:
SELECT 
    c.FirstName,
    c.LastName,
    COUNT(DISTINCT p.product) AS ProductCount
FROM Customer c
INNER JOIN Account a ON c.CustId = a.CustId
INNER JOIN Betting_main b ON a.AccountNo = b.AccountNo
INNER JOIN Product p ON b.ClassId = p.CLASSID 
    AND b.CategoryId = p.CATEGORYID
WHERE b.Bet_Amt > 0
GROUP BY c.CustId, c.FirstName, c.LastName
ORDER BY ProductCount DESC, c.LastName;

#Query 2 - Players who play both Sportsbook and Vegas:
SELECT DISTINCT
    c.FirstName,
    c.LastName
FROM Customer c
INNER JOIN Account a ON c.CustId = a.CustId
WHERE EXISTS (
    SELECT 1 FROM Betting_main b
    INNER JOIN Product p ON b.ClassId = p.CLASSID 
        AND b.CategoryId = p.CATEGORYID
    WHERE b.AccountNo = a.AccountNo 
        AND p.product = 'Sportsbook' 
        AND b.Bet_Amt > 0
)
AND EXISTS (
    SELECT 1 FROM Betting_main b
    INNER JOIN Product p ON b.ClassId = p.CLASSID 
        AND b.CategoryId = p.CATEGORYID
    WHERE b.AccountNo = a.AccountNo 
        AND p.product = 'Vegas' 
        AND b.Bet_Amt > 0
);

#Question 09
SELECT 
    c.FirstName,
    c.LastName,
    SUM(CASE WHEN p.product = 'Sportsbook' THEN b.Bet_Amt ELSE 0 END) AS Sportsbook_Bets,
    SUM(CASE WHEN p.product = 'Vegas' THEN b.Bet_Amt ELSE 0 END) AS Vegas_Bets
FROM Customer c
INNER JOIN Account a ON c.CustId = a.CustId
LEFT JOIN Betting_main b ON a.AccountNo = b.AccountNo
LEFT JOIN Product p ON b.ClassId = p.CLASSID 
    AND b.CategoryId = p.CATEGORYID
GROUP BY c.CustId, c.FirstName, c.LastName
HAVING SUM(CASE WHEN p.product = 'Sportsbook' THEN b.Bet_Amt ELSE 0 END) > 0
    AND SUM(CASE WHEN p.product != 'Sportsbook' THEN b.Bet_Amt ELSE 0 END) = 0;

#Question 10
WITH PlayerProductBets AS (
    SELECT 
        c.CustId,
        c.FirstName,
        c.LastName,
        p.product,
        SUM(b.Bet_Amt) AS TotalBetAmount,
        ROW_NUMBER() OVER (PARTITION BY c.CustId ORDER BY SUM(b.Bet_Amt) DESC) AS rn
    FROM Customer c
    INNER JOIN Account a ON c.CustId = a.CustId
    INNER JOIN Betting_main b ON a.AccountNo = b.AccountNo
    INNER JOIN Product p ON b.ClassId = p.CLASSID 
        AND b.CategoryId = p.CATEGORYID
    WHERE b.Bet_Amt > 0
    GROUP BY c.CustId, c.FirstName, c.LastName, p.product
)
SELECT 
    FirstName,
    LastName,
    product AS FavoriteProduct,
    TotalBetAmount
FROM PlayerProductBets
WHERE rn = 1
ORDER BY LastName, FirstName;

#Question 11
SELECT 
    student_name,
    grade AS GPA
FROM student
ORDER BY grade DESC
LIMIT 5;

#Question 12
SELECT 
    s.school_name,
    COUNT(st.student_id) AS StudentCount
FROM school s
LEFT JOIN student st ON s.location = st.city
GROUP BY s.school_id, s.school_name
ORDER BY s.school_name;

#Question 13
WITH RankedStudents AS (
    SELECT 
        st.student_name,
        st.grade AS GPA,
        s.school_name,
        ROW_NUMBER() OVER (PARTITION BY s.school_id ORDER BY st.grade DESC) AS `rank`
    FROM student st
    INNER JOIN school s ON st.city = s.location
)
SELECT 
    school_name,
    student_name,
    GPA
FROM RankedStudents
WHERE `rank` <= 3
ORDER BY school_name, `rank`;