SELECT
  p.plan_name,
  COUNT(DISTINCT s.user_id) AS total_users,
  AVG( (DATE_DIFF(LEAST(s.subscription_end_date, CURRENT_DATE), s.subscription_start_date, MONTH) + 1) * p.monthly_price ) AS D30_LTV,
  AVG(p.monthly_price) AS monthly_price_of_the_plan
FROM
  data_table.subscription s
JOIN
  data_table.plans p
ON
  s.plan_id = p.plan_id
GROUP BY
  p.plan_name
ORDER BY
  D30_LTV DESC;