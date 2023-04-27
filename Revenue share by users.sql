/* Для каждого дня в таблицах orders и user_actions рассчитайте следующие показатели:

Выручку, полученную в этот день.
Выручку с заказов новых пользователей, полученную в этот день.
Долю выручки с заказов новых пользователей в общей выручке, полученной за этот день.
Долю выручки с заказов остальных пользователей в общей выручке, полученной за этот день.
Колонки с показателями назовите соответственно revenue, new_users_revenue, new_users_revenue_share, old_users_revenue_share. Колонку с датами назовите date. 

Все показатели долей необходимо выразить в процентах. При их расчёте округляйте значения до двух знаков после запятой.

Результат должен быть отсортирован по возрастанию даты. */

WITH t AS (SELECT *,
MIN(date) OVER(PARTITION BY user_id) AS first_order
FROM (SELECT DATE(creation_time) AS date, order_id, UNNEST(product_ids) AS prod_id FROM orders) AS t1
LEFT JOIN user_actions
USING(order_id)
LEFT JOIN products
ON prod_id = product_id)

SELECT date, revenue, new_users_revenue, ROUND(new_users_revenue::DECIMAL/revenue*100,2) AS new_users_revenue_share,
ROUND((revenue - new_users_revenue)/revenue::DECIMAL*100,2) AS old_users_revenue_share
FROM
(SELECT date, SUM(price) FILTER(WHERE order_id NOT IN (SELECT order_id FROM user_actions WHERE action = 'cancel_order')) AS revenue,
SUM(price) FILTER(WHERE order_id NOT IN (SELECT order_id FROM user_actions WHERE action = 'cancel_order') AND date = first_order) AS new_users_revenue
FROM t
GROUP BY date
ORDER BY date) as t2
