INSERT INTO users VALUES
('U1', 'John Doe', '9876543210', 'john@example.com', 'ABC City'),
('U2', 'Jane Smith', '9123456780', 'jane@example.com', 'XYZ City');

INSERT INTO bookings VALUES
('B1', '2021-11-10 10:00:00', '101', 'U1'),
('B2', '2021-11-15 12:00:00', '102', 'U2');

INSERT INTO items VALUES
('I1', 'Tawa Paratha', 18),
('I2', 'Mix Veg', 89);

INSERT INTO booking_commercials VALUES
('C1', 'B1', 'BL1', '2021-11-10 12:00:00', 'I1', 2),
('C2', 'B1', 'BL1', '2021-11-10 12:00:00', 'I2', 1),
('C3', 'B2', 'BL2', '2021-11-15 13:00:00', 'I2', 3);

-- Q1: Last booked room per user
SELECT user_id, room_no
FROM (
    SELECT user_id, room_no, booking_date,
           ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY booking_date DESC) AS rn
    FROM bookings
) t
WHERE rn = 1;

-- Q2: Total billing in November 2021
SELECT bc.booking_id,
       SUM(bc.item_quantity * i.item_rate) AS total_bill
FROM booking_commercials bc
JOIN items i ON bc.item_id = i.item_id
WHERE strftime('%m', bc.bill_date) = '11'
  AND strftime('%Y', bc.bill_date) = '2021'
GROUP BY bc.booking_id;


INSERT INTO booking_commercials VALUES
('C4', 'B1', 'BL3', '2021-10-12 10:00:00', 'I2', 20);

-- Q3: Bills in October 2021 with amount > 1000
SELECT bc.bill_id,
       SUM(bc.item_quantity * i.item_rate) AS bill_amount
FROM booking_commercials bc
JOIN items i ON bc.item_id = i.item_id
WHERE strftime('%m', bc.bill_date) = '10'
  AND strftime('%Y', bc.bill_date) = '2021'
GROUP BY bc.bill_id
HAVING bill_amount > 1000;



-- Q4: Most & Least ordered item each month (2021)

WITH item_orders AS (
    SELECT 
        item_id,
        strftime('%m', bill_date) AS month,
        SUM(item_quantity) AS total_qty
    FROM booking_commercials
    WHERE strftime('%Y', bill_date) = '2021'
    GROUP BY item_id, month
)

SELECT *
FROM (
    SELECT *,
           RANK() OVER (PARTITION BY month ORDER BY total_qty DESC) AS most_rank,
           RANK() OVER (PARTITION BY month ORDER BY total_qty ASC) AS least_rank
    FROM item_orders
) t
WHERE most_rank = 1 OR least_rank = 1;



-- Q5: Second highest bill per month (2021)

WITH bill_values AS (
    SELECT 
        b.user_id,
        bc.booking_id,
        strftime('%m', bc.bill_date) AS month,
        SUM(bc.item_quantity * i.item_rate) AS total_bill
    FROM booking_commercials bc
    JOIN bookings b ON bc.booking_id = b.booking_id
    JOIN items i ON bc.item_id = i.item_id
    WHERE strftime('%Y', bc.bill_date) = '2021'
    GROUP BY b.user_id, bc.booking_id, month
)

SELECT *
FROM (
    SELECT *,
           DENSE_RANK() OVER (PARTITION BY month ORDER BY total_bill DESC) AS rnk
    FROM bill_values
) t
WHERE rnk = 2;

INSERT INTO booking_commercials VALUES
('C5', 'B2', 'BL4', '2021-11-16 14:00:00', 'I1', 10);