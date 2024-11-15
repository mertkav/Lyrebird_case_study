WITH cohort AS (
  --Identify the cohort for each user based on subscription start date
  SELECT
    user_id,
    DATE_TRUNC(subscription_start_date, MONTH) AS cohort_month,
    DATE(subscription_start_date) AS subscription_start_date
  FROM
    data_table.subscription
),
retention_by_day AS (
  -- Calculate retention by day
  SELECT
    c.cohort_month,
    COUNT(
      DISTINCT CASE
        WHEN e.event_date = DATE_ADD(c.subscription_start_date, INTERVAL 0 DAY) THEN e.user_id
      END
    ) AS D0_users,
    COUNT(
      DISTINCT CASE
        WHEN e.event_date = DATE_ADD(c.subscription_start_date, INTERVAL 1 DAY) THEN e.user_id
      END
    ) AS D1_retained,
    COUNT(
      DISTINCT CASE
        WHEN e.event_date = DATE_ADD(c.subscription_start_date, INTERVAL 3 DAY) THEN e.user_id
      END
    ) AS D3_retained,
    COUNT(
      DISTINCT CASE
        WHEN e.event_date = DATE_ADD(c.subscription_start_date, INTERVAL 7 DAY) THEN e.user_id
      END
    ) AS D7_retained,
    COUNT(
      DISTINCT CASE
        WHEN e.event_date = DATE_ADD(c.subscription_start_date, INTERVAL 14 DAY) THEN e.user_id
      END
    ) AS D14_retained,
    COUNT(
      DISTINCT CASE
        WHEN e.event_date = DATE_ADD(c.subscription_start_date, INTERVAL 28 DAY) THEN e.user_id
      END
    ) AS D28_retained
  FROM
    data_table.events e
    JOIN cohort c ON e.user_id = c.user_id
  GROUP BY
    c.cohort_month
) -- Calculate the retention rate 
SELECT
  rbd.cohort_month,
  D0_users,
  ROUND((D1_retained * 100.0 / D0_users), 2) AS R_1,
  ROUND((D3_retained * 100.0 / D0_users), 2) AS R_3,
  ROUND((D7_retained * 100.0 / D0_users), 2) AS R_7,
  ROUND((D14_retained * 100.0 / D0_users), 2) AS R_14,
  ROUND((D28_retained * 100.0 / D0_users), 2) AS R_28
FROM
  retention_by_day rbd
ORDER BY
  rbd.cohort_month;
