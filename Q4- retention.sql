WITH cohort AS (
    -- Identify the cohort for each user based on their subscription start month
    SELECT 
        user_id,
        DATE_TRUNC(subscription_start_date, MONTH) AS cohort_month,
        DATE(subscription_start_date) AS subscription_start_date
    FROM 
        data_table.subscription
),

activity AS (
    -- Track user activity by event date
    SELECT 
        e.user_id,
        c.cohort_month,
        c.subscription_start_date,
        DATE(e.event_date) AS event_date,
        DATE_DIFF(DATE(e.event_date), c.subscription_start_date, DAY) AS days_since_start
    FROM 
        data_table.events e
    JOIN 
        cohort c ON e.user_id = c.user_id
),

retention_days AS (
    -- Calculate active users for specific retention days (D1, D3, D7, D14, D28)
    SELECT 
        cohort_month,
        CASE
            WHEN days_since_start = 1 THEN 'D1'
            WHEN days_since_start = 3 THEN 'D3'
            WHEN days_since_start = 7 THEN 'D7'
            WHEN days_since_start = 14 THEN 'D14'
            WHEN days_since_start = 28 THEN 'D28'
        END AS retention_day,
        COUNT(user_id) AS active_users
    FROM 
        activity
    WHERE 
        days_since_start BETWEEN 1 AND 28
    GROUP BY 
        cohort_month, retention_day
),

cohort_size AS (
    -- Calculate the size of each cohort
    SELECT 
        cohort_month,
        COUNT(DISTINCT user_id) AS cohort_size
    FROM 
        cohort
    GROUP BY 
        cohort_month
)

-- Calculate retention rate for each cohort and retention day
SELECT 
    rd.cohort_month,
    rd.retention_day,
    rd.active_users,
    cs.cohort_size,
    ROUND((rd.active_users * 100.0 / cs.cohort_size), 2) AS retention_rate
FROM 
    retention_days rd
JOIN 
    cohort_size cs ON rd.cohort_month = cs.cohort_month
ORDER BY 
    rd.cohort_month, 
    CASE rd.retention_day
        WHEN 'D1' THEN 1
        WHEN 'D3' THEN 2
        WHEN 'D7' THEN 3
        WHEN 'D14' THEN 4
        WHEN 'D28' THEN 5
    END;
