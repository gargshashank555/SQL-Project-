SELECT * FROM credit_card

--1)write a query to print top 5 cities with highest spends and their percentage contribution of total credit card spends??
SELECT TOP 5 City, SUM(amount) AS Total_spent, SUM(amount)/(SELECT SUM(amount) FROM credit_card) * 100 AS Spent_in_percent
FROM credit_card
GROUP BY city
ORDER BY SUM(amount) desc


--2)write a query to print highest spend month and amount spent in that month for each card type??
SELECT * FROM
(SELECT * , 
DENSE_RANK() OVER(Partition by Card_type Order by Total_spent desc) AS D_rank
FROM
(SELECT Card_type,DATEPART(year,transaction_date) AS Year,DATEPART(month,transaction_date) AS Month , SUM(amount) AS Total_spent
FROM credit_card
GROUP BY Card_type,DATEPART(year,transaction_date),DATEPART(month,transaction_date)) AS A) AS B
WHERE D_rank = 1


--3)write a query to print the transaction details(all columns from the table) for each card type when
--it reaches a cumulative of 1000000 total spends(We should have 4 rows in the o/p one for each card type)??
SELECT * FROM
(SELECT * , DENSE_RANK() OVER(Partition by Card_type Order by cumulative_sum) AS D_rank
FROM
(SELECT * FROM
(SELECT * , SUM(amount) OVER(Partition by Card_type Order by transaction_date,transaction_id) AS cumulative_sum
FROM credit_card) AS A
WHERE cumulative_sum > 999999) AS B) AS C
WHERE D_rank = 1


--4)write a query to find city which had lowest percentage spend for gold card type??
SELECT TOP 1 City, SUM(amount) AS total_spent, (SUM(amount)/(SELECT SUM(amount) FROM credit_card)*100) AS Spent_in_percentage
FROM credit_card
WHERE card_type = 'Gold'
GROUP BY City
ORDER BY Spent_in_percentage asc


--5)write a query to print 3 columns:  city, highest_expense_type , lowest_expense_type (example format : Delhi , bills, Fuel)
SELECT City, MAX(max_exp_type) AS max_exp_type , MIN(min_exp_type) AS min_exp_type
FROM
(SELECT * , CASE WHEN RN_desc = 1 THEN exp_type END AS max_exp_type,
CASE WHEN RN_asc = 1 THEN exp_type END AS min_exp_type
FROM
(SELECT * , 
RANK() OVER(Partition BY city Order by total_spend desc) AS RN_desc,
RANK() OVER(Partition BY city Order by total_spend) AS RN_asc
FROM
(SELECT city,exp_type,SUM(amount) AS total_spend
FROM credit_card
GROUP BY city,exp_type)AS A) AS B) AS C
GROUP BY City


--6)write a query to find percentage contribution of spends by females for each expense type??
SELECT exp_type , SUM(CASE WHEN Gender ='F' THEN amount END)/SUM(amount)* 100 AS Total_amount_percent
FROM credit_card
GROUP BY exp_type 
ORDER BY Total_amount_percent desc


--7)which card and expense type combination saw highest month over month growth in Jan-2014??
SELECT TOP 1 * , (Total_spent - prev_month_exp)/prev_month_exp AS MOM_growth
FROM
(SELECT * , 
LAG(Total_spent) OVER(partition by card_type, exp_type Order by yt,mt) AS prev_month_exp
FROM
(SELECT Card_type, exp_type,DATEPART(year,transaction_date) AS Yt,DATEPART(month,transaction_date) AS Mt , SUM(amount) AS Total_spent
FROM credit_card
GROUP BY Card_type, exp_type, DATEPART(year,transaction_date), DATEPART(month,transaction_date))AS A)AS B
WHERE yt = 2014 AND mt = 1
ORDER BY MOM_growth desc


--8)during weekends which city has highest total spend to total no of transcations ratio??
SELECT TOP 1 city, SUM(amount)/COUNT(1) AS Total_spend_ratio
FROM
(SELECT * 
FROM credit_card
WHERE DATEPART(weekday,transaction_date) IN (1,7))AS A
GROUP BY City
ORDER BY Total_spend_ratio desc


--9)which city took least number of days to reach its 500th transaction after the first transaction in that city??
SELECT TOP 1 *
FROM
(SELECT * , datediff(day,Day_1_date,Day_500_date) AS day_diff
FROM
(SELECT city, MIN(transaction_date) AS Day_1_date, MAX(transaction_date) AS Day_500_date
FROM
(SELECT *,Row_Number() OVER(Partition by City ORDER BY transaction_date,transaction_id) AS Rn
FROM credit_card) AS A
WHERE  rn = 1 or rn = 500
GROUP BY city
HAVING COUNT(1) = 2) AS B) AS C
Order BY day_diff asc


