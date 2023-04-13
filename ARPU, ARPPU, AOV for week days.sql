/*Для каждого дня недели в таблицах orders и user_actions рассчитайте следующие показатели:

Выручку на пользователя (ARPU).
Выручку на платящего пользователя (ARPPU).
Выручку на заказ (AOV).
При расчётах учитывайте данные только за период с 26 августа 2022 года по 8 сентября 2022 года включительно — так,
чтобы в анализ попало одинаковое количество всех дней недели (ровно по два дня).

В результирующую таблицу включите как наименования дней недели (например, Monday), 
так и порядковый номер дня недели (от 1 до 7, где 1 — это Monday, 7 — это Sunday).

Колонки с показателями назовите соответственно arpu, arppu, aov. Колонку с наименованием дня
недели назовите weekday, а колонку с порядковым номером дня недели weekday_number.

При расчёте всех показателей округляйте значения до двух знаков после запятой.

Результат должен быть отсортирован по возрастанию порядкового номера дня недели.

Поля в результирующей таблице: 

weekday, weekday_number, arpu, arppu, aov */

WITH table1 AS (SELECT * FROM (SELECT creation_time, order_id, UNNEST(product_ids) AS prod_id FROM orders) AS t1
LEFT JOIN user_actions
USING(order_id)
LEFT JOIN products
ON product_id = prod_id
WHERE time::DATE >= '08-26-2022' AND time::DATE <= '09-08-2022')

SELECT weekday, weekday_number,
ROUND(daily_rev/users_count::DECIMAL,2) AS arpu,
ROUND(daily_rev/paying_users_count::DECIMAL,2) AS arppu,
ROUND(daily_rev/order_count::DECIMAL,2) AS aov
FROM
(SELECT weekday, weekday_number,
SUM(price) FILTER(WHERE order_id NOT IN (SELECT order_id FROM user_actions WHERE action = 'cancel_order')) AS daily_rev,
COUNT(distinct user_id) AS users_count,
COUNT(distinct user_id) FILTER(WHERE order_id NOT IN (SELECT order_id FROM user_actions WHERE action = 'cancel_order')) AS paying_users_count,
COUNT(distinct order_id) FILTER(WHERE order_id NOT IN (SELECT order_id FROM user_actions WHERE action = 'cancel_order')) AS order_count
FROM
(SELECT order_id, user_id, time::DATE AS date, TO_CHAR(time::DATE, 'Day') AS weekday,
DATE_PART('isodow', time::DATE) AS weekday_number, action, price FROM table1) AS t2
GROUP BY weekday, weekday_number) AS t3
ORDER BY weekday_number

