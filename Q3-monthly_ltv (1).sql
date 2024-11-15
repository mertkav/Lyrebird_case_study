SELECT
  p.plan_name,
  COUNT(DISTINCT s.user_id) AS total_users,
  -- Calculates the average total revenue generated by users for their subscription.
  -- LEAST ensures the subscription doesn't go beyond the current date.
  AVG( (DATE_DIFF(LEAST(s.subscription_end_date, CURRENT_DATE), s.subscription_start_date, MONTH) + 1) * p.monthly_price ) AS D30_LTV,
  -- Provides the average monthly price of each plan.
  AVG(p.monthly_price) AS monthly_price_of_the_plan
FROM
  data_table.subscription s
JOIN
  -- Joins the plans table to access plan details using plan_id.
  data_table.plans p
ON
  s.plan_id = p.plan_id
GROUP BY
  -- Groups results by plan name to calculate metrics plan_name.
  p.plan_name
ORDER BY
  D30_LTV DESC;