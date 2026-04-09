INSERT INTO clinics VALUES
('C1', 'ABC Clinic', 'Bangalore', 'Karnataka', 'India'),
('C2', 'XYZ Clinic', 'Mysore', 'Karnataka', 'India');

INSERT INTO customer VALUES
('U1', 'John Doe', '9876543210'),
('U2', 'Jane Smith', '9123456780');


INSERT INTO clinic_sales VALUES
('O1', 'U1', 'C1', 5000, '2021-09-10 10:00:00', 'online'),
('O2', 'U2', 'C1', 7000, '2021-09-12 12:00:00', 'offline'),
('O3', 'U1', 'C2', 8000, '2021-10-05 14:00:00', 'online');

INSERT INTO expenses VALUES
('E1', 'C1', 'supplies', 2000, '2021-09-11 09:00:00'),
('E2', 'C2', 'equipment', 3000, '2021-10-06 11:00:00');






-- Q1: Revenue per sales channel (2021)

SELECT sales_channel,
       SUM(amount) AS revenue
FROM clinic_sales
WHERE strftime('%Y', datetime) = '2021'
GROUP BY sales_channel;



-- Q2: Top 10 customers (2021)

SELECT uid,
       SUM(amount) AS total_spent
FROM clinic_sales
WHERE strftime('%Y', datetime) = '2021'
GROUP BY uid
ORDER BY total_spent DESC
LIMIT 10;


-- Q3: Month-wise revenue, expense, profit, status (2021)

WITH revenue AS (
    SELECT 
        strftime('%m', datetime) AS month,
        SUM(amount) AS revenue
    FROM clinic_sales
    WHERE strftime('%Y', datetime) = '2021'
    GROUP BY month
),

expense AS (
    SELECT 
        strftime('%m', datetime) AS month,
        SUM(amount) AS expense
    FROM expenses
    WHERE strftime('%Y', datetime) = '2021'
    GROUP BY month
)

SELECT 
    r.month,
    r.revenue,
    e.expense,
    (r.revenue - e.expense) AS profit,
    CASE 
        WHEN (r.revenue - e.expense) > 0 THEN 'Profitable'
        ELSE 'Not Profitable'
    END AS status
FROM revenue r
JOIN expense e ON r.month = e.month;


-- Q4: Most profitable clinic per city (for September)

WITH profit_calc AS (
    SELECT 
        c.city,
        cs.cid,
        SUM(cs.amount) - COALESCE(SUM(e.amount), 0) AS profit
    FROM clinic_sales cs
    JOIN clinics c ON cs.cid = c.cid
    LEFT JOIN expenses e ON cs.cid = e.cid
    WHERE strftime('%m', cs.datetime) = '09'
    GROUP BY c.city, cs.cid
)

SELECT *
FROM (
    SELECT *,
           RANK() OVER (PARTITION BY city ORDER BY profit DESC) AS rnk
    FROM profit_calc
) t
WHERE rnk = 1;


INSERT INTO clinic_sales VALUES
('O4', 'U2', 'C2', 4000, '2021-09-15 10:00:00', 'online');

-- Q5: Second least profitable clinic per state (for September)

WITH profit_calc AS (
    SELECT 
        c.state,
        cs.cid,
        SUM(cs.amount) - COALESCE(SUM(e.amount), 0) AS profit
    FROM clinic_sales cs
    JOIN clinics c ON cs.cid = c.cid
    LEFT JOIN expenses e ON cs.cid = e.cid
    WHERE strftime('%m', cs.datetime) = '09'
    GROUP BY c.state, cs.cid
)

SELECT *
FROM (
    SELECT *,
           DENSE_RANK() OVER (PARTITION BY state ORDER BY profit ASC) AS rnk
    FROM profit_calc
) t
WHERE rnk = 2;