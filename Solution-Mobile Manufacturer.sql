--SQL Advance Case Study
																		
CREATE DATABASE db_SQLCaseStudies

--Q1--BEGIN 
SELECT DISTINCT State FROM DIM_LOCATION AS A
INNER JOIN FACT_TRANSACTIONS AS B
ON A.IDLocation=B.IDLocation
WHERE YEAR(DATE)>='2005'

--Q1--END

--Q2--BEGIN
SELECT TOP 1[STATE],NO_OF_CUSTOMER
FROM(
SELECT [STATE],COUNT(IDCUSTOMER)AS NO_OF_CUSTOMER FROM DIM_LOCATION AS A 
LEFT JOIN FACT_TRANSACTIONS AS B
ON A.IDLocation=B.IDLocation
LEFT JOIN DIM_MODEL AS C
ON B.IDModel=C.IDModel
LEFT JOIN DIM_MANUFACTURER AS D
ON C.IDManufacturer=D.IDManufacturer
WHERE Country='US' AND Manufacturer_Name='SAMSUNG'
GROUP BY [State])
AS X
ORDER BY NO_OF_CUSTOMER DESC


--Q2--END

--Q3--BEGIN   
SELECT Model_Name,STATE,ZipCode,COUNT(IDCustomer) AS CUST_COUNT FROM DIM_MODEL AS A
LEFT JOIN FACT_TRANSACTIONS AS B
ON A.IDModel=B.IDModel
LEFT JOIN DIM_LOCATION AS C
ON B.IDLocation=C.IDLocation
GROUP BY Model_Name,STATE,ZipCode
ORDER BY CUST_COUNT DESC
--Q3--END

--Q4--BEGIN
SELECT TOP 1 MODEL_NAME,UNIT_PRICE  FROM(
SELECT Model_Name,MIN(UNIT_PRICE)AS UNIT_PRICE FROM DIM_MODEL
GROUP BY Model_Name
) AS X

--Q4--END

--Q5--BEGIN
SELECT MODEL_NAME, AVG(UNIT_PRICE) AS AVG_PRICE FROM DIM_MODEL AS A
INNER JOIN DIM_MANUFACTURER AS B ON A.IDManufacturer = B.IDManufacturer
WHERE MANUFACTURER_NAME IN 
(
SELECT TOP 5 MANUFACTURER_NAME FROM FACT_TRANSACTIONS AS C
INNER JOIN DIM_MODEL AS D ON C.IDMODEL = D.IDMODEL
INNER JOIN DIM_MANUFACTURER AS E ON E.IDMANUFACTURER = D.IDMANUFACTURER
GROUP BY MANUFACTURER_NAME
ORDER BY SUM(QUANTITY)
)
GROUP BY MODEL_NAME
ORDER BY AVG(UNIT_PRICE) DESC


--Q5--END

--Q6--BEGIN
SELECT CUSTOMER_NAME,AVG_SPEND
FROM(
SELECT Customer_Name,YEAR(DATE) AS YEAR,AVG(TOTALPRICE) AS AVG_SPEND FROM DIM_CUSTOMER AS A
LEFT JOIN FACT_TRANSACTIONS AS B
ON A.IDCustomer=B.IDCustomer
GROUP BY Customer_Name,YEAR(DATE))AS X
WHERE YEAR='2009'
AND AVG_SPEND > 500
ORDER BY AVG_SPEND DESC

--Q6--END
	
--Q7--BEGIN  
SELECT Model_Name FROM(
SELECT TOP 5 Model_Name,SUM(Quantity) AS PIECES_SOLD,YEAR(DATE) AS YEAR FROM FACT_TRANSACTIONS AS A
LEFT JOIN DIM_MODEL AS B
ON A.IDModel=B.IDModel
WHERE YEAR(DATE)='2008'
GROUP BY Model_Name,YEAR(DATE)
ORDER BY PIECES_SOLD DESC)AS X

INTERSECT

SELECT Model_Name FROM (
SELECT TOP 5 Model_Name,SUM(Quantity) AS PIECES_SOLD,YEAR(DATE) AS YEAR FROM FACT_TRANSACTIONS AS A
LEFT JOIN DIM_MODEL AS B
ON A.IDModel=B.IDModel
WHERE YEAR(DATE)='2009'
GROUP BY Model_Name,YEAR(DATE)
ORDER BY PIECES_SOLD DESC)  AS Y

INTERSECT

SELECT Model_Name FROM (
SELECT TOP 5 Model_Name,SUM(Quantity) AS PIECES_SOLD,YEAR(DATE) AS YEAR FROM FACT_TRANSACTIONS AS A
LEFT JOIN DIM_MODEL AS B
ON A.IDModel=B.IDModel
WHERE YEAR(DATE)='2010'
GROUP BY Model_Name,YEAR(DATE)
ORDER BY PIECES_SOLD DESC) AS Z
	
	
--Q7--END	


--Q8--BEGIN
SELECT Manufacturer_Name,YEAR FROM(
SELECT Manufacturer_Name,SUM(TOTALPRICE)AS TOT_SALES,YEAR(DATE)AS [YEAR] FROM FACT_TRANSACTIONS AS A
LEFT JOIN DIM_MODEL AS B
ON A.IDModel=B.IDModel
LEFT JOIN DIM_MANUFACTURER AS C
ON B.IDManufacturer=C.IDManufacturer
WHERE YEAR(DATE) IN ('2009')
GROUP BY Manufacturer_Name,YEAR(DATE)
ORDER BY TOT_SALES DESC
OFFSET 1 ROW
 FETCH NEXT 1 ROW ONLY) AS X

 UNION ALL

 SELECT Manufacturer_Name,YEAR  FROM (
 SELECT Manufacturer_Name,SUM(TOTALPRICE)AS TOT_SALES,YEAR(DATE)AS [YEAR] FROM FACT_TRANSACTIONS AS A
LEFT JOIN DIM_MODEL AS B
ON A.IDModel=B.IDModel
LEFT JOIN DIM_MANUFACTURER AS C
ON B.IDManufacturer=C.IDManufacturer
WHERE YEAR(DATE) IN ('2010')
GROUP BY Manufacturer_Name,YEAR(DATE)
ORDER BY TOT_SALES DESC
OFFSET 1 ROW
 FETCH NEXT 1 ROW ONLY) AS Y

--Q8--END

--Q9--BEGIN
SELECT DISTINCT  Manufacturer_Name FROM FACT_TRANSACTIONS AS A
LEFT JOIN DIM_MODEL AS B
ON A.IDModel=B.IDModel
LEFT JOIN DIM_MANUFACTURER AS C
ON B.IDManufacturer=C.IDManufacturer
WHERE YEAR(DATE)='2010'
AND  Manufacturer_Name NOT IN ( SELECT Manufacturer_Name FROM FACT_TRANSACTIONS AS A
LEFT JOIN DIM_MODEL AS B
ON A.IDModel=B.IDModel
LEFT JOIN DIM_MANUFACTURER AS C
ON B.IDManufacturer=C.IDManufacturer
WHERE YEAR(DATE)='2009')

--Q9--END

--Q10--BEGIN

SELECT *,(((AVERAGE -PREVIOUS_YEAR)/(PREVIOUS_YEAR)) *100) AS YOY FROM (
SELECT *,(
LAG(AVERAGE, 1) OVER (PARTITION BY IDCUSTOMER ORDER BY YEARS)
) AS PREVIOUS_YEAR FROM (SELECT C.IDCustomer, Customer_Name, DATEPART(YEAR, [DATE]) AS [Years], AVG(TotalPrice)AS AVERAGE, AVG(QUANTITY) AS AVG_QUANTITY
FROM DIM_CUSTOMER AS C
INNER JOIN FACT_TRANSACTIONS AS T
ON C.IDCustomer =T.IDCustomer
WHERE C.IDCustomer in (SELECT TOP 10 IDCustomer FROM FACT_TRANSACTIONS
WHERE TotalPrice> 0
GROUP BY IDCustomer
ORDER BY sum(TotalPrice) DESC )
GROUP BY C.IDCustomer, Customer_Name, DATEPART(YEAR, [DATE])
) AS Y) AS Z














--Q10--END
	