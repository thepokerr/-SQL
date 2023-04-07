/*Для каждого дня в таблицах orders и user_actions рассчитайте следующие показатели:

Выручку на пользователя (ARPU) за текущий день.
Выручку на платящего пользователя (ARPPU) за текущий день.
Выручку с заказа, или средний чек (AOV) за текущий день.
Колонки с показателями назовите соответственно arpu, arppu, aov. Колонку с датами назовите date. */


WITH table1 AS (SELECT *, SUM(price) OVER(PARTITION BY user_id, user_actions.time::DATE) AS orders_value FROM(SELECT * FROM products
JOIN (SELECT creation_time, order_id, UNNEST(product_ids) AS prod_id FROM orders) AS t1
ON product_id = prod_id) AS t2
LEFT JOIN user_actions
USING(order_id))

SELECT date, ROUND(revenue/active_users::DECIMAL,2) AS arpu,
ROUND(revenue/paying_users::DECIMAL,2) AS arppu,
ROUND(revenue/payed_orders::DECIMAL,2) AS aov
FROM
(SELECT time::DATE AS date, SUM(price) AS sum_orders_value, 
SUM(price) FILTER(WHERE order_id NOT IN (SELECT order_id FROM user_actions WHERE action = 'cancel_order')) AS revenue,
COUNT(DISTINCT user_id) AS active_users, 
COUNT(DISTINCT user_id) FILTER(WHERE order_id NOT IN (SELECT order_id FROM user_actions WHERE action = 'cancel_order')) AS paying_users,
COUNT(DISTINCT order_id) FILTER(WHERE order_id NOT IN(SELECT order_id FROM user_actions WHERE action = 'cancel_order')) AS payed_orders
FROM table1
GROUP BY  date) AS tt
ORDER BY date
