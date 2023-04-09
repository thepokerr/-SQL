/*По таблицам orders и user_actions для каждого дня рассчитайте следующие показатели:

Накопленную выручку на пользователя (Running ARPU).
Накопленную выручку на платящего пользователя (Running ARPPU).
Накопленную выручку с заказа, или средний чек (Running AOV).
Колонки с показателями назовите соответственно running_arpu, running_arppu, running_aov. Колонку с датами назовите date. 

При расчёте всех показателей округляйте значения до двух знаков после запятой.

Результат должен быть отсортирован по возрастанию даты. 

Поля в результирующей таблице: date, running_arpu, running_arppu, running_aov*/

SELECT date,
ROUND(running_revenue::DECIMAL/running_user_count,2) AS running_arpu,
ROUND(running_revenue::DECIMAL/runing_paying_users_count,2) AS running_arppu,
ROUND(running_revenue::DECIMAL/running_orders_count,2) AS running_aov
FROM
(SELECT *,
SUM(user_count) OVER(ORDER BY date) AS running_user_count,
SUM(paying_users_count) OVER(ORDER BY date)  AS runing_paying_users_count,
SUM(revenue) OVER(ORDER BY date) AS running_revenue,
SUM(orders_count) OVER(ORDER BY date) AS running_orders_count
FROM
(SELECT date,
COUNT(DISTINCT user_id) FILTER(WHERE date = first_time) AS user_count,
COUNT(DISTINCT user_id) FILTER(WHERE date = first_order AND  order_id NOT IN(SELECT order_id FROM user_actions WHERE action = 'cancel_order')) AS paying_users_count,
SUM(price) FILTER(WHERE order_id NOT IN(SELECT order_id FROM user_actions WHERE action = 'cancel_order')) AS revenue,
COUNT(DISTINCT order_id) FILTER(WHERE order_id NOT IN(SELECT order_id FROM user_actions WHERE action = 'cancel_order')) AS orders_count
FROM
(SELECT user_id, order_id, product_id, price, action, time::DATE AS date, 
MIN(time::DATE) OVER(PARTITION BY user_id) AS first_time,
MIN(time::DATE) FILTER(WHERE order_id NOT IN(SELECT order_id FROM user_actions WHERE action = 'cancel_order')) OVER(PARTITION BY user_id) AS first_order
FROM
(SELECT creation_time, order_id, unnest(product_ids) AS prod_id FROM orders) AS t1
LEFT JOIN products
ON product_id = prod_id
LEFT JOIN user_actions
USING(order_id)) AS t2
GROUP BY date) AS t3) AS t4
ORDER BY date

