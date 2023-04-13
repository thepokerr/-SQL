/*Для каждого дня в таблице orders рассчитайте следующие показатели:

Выручку, полученную в этот день.
Суммарную выручку на текущий день.
Прирост выручки, полученной в этот день, относительно значения выручки за предыдущий день.
Колонки с показателями назовите соответственно revenue, total_revenue, revenue_change. Колонку с датами назовите date.*/

SELECT date, revenue, total_revenue,
ROUND((revenue-lag(revenue) OVER(ORDER BY date))::DECIMAL/LAG(revenue) OVER(ORDER BY date)*100,2) AS revenue_change
FROM
(SELECT date, revenue,
SUM(revenue) OVER(ORDER BY date) AS total_revenue
FROM
(SELECT date, SUM(price) AS revenue FROM
(SELECT creation_time::DATE AS date, order_id, UNNEST(product_ids) AS prod_ids FROM orders) AS t1
LEFT JOIN products 
ON prod_ids = product_id
WHERE order_id NOT IN (SELECT order_id FROM user_actions WHERE action = 'cancel_order') 
GROUP BY date) AS t2) AS t3
ORDER BY date


<h3 align="center">Результат</h3>
<img src="https://github.com/thepokerr/111/blob/main/revenue_table.png" height="220"/>
