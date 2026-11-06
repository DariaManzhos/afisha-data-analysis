-- Проект: исследование данных Яндекс Афиши
-- цель: расчёт выручки, заказов и пользовательских показателей.


-- 1. Общие показатели по валютам:
--    выручка, количество заказов, средняя выручка на заказ,
--    количество уникальных пользователей.
SELECT
    currency_code,
    SUM(revenue) AS total_revenue,
    COUNT(order_id) AS total_orders,
    AVG(revenue) AS avg_revenue_per_order,
    COUNT(DISTINCT user_id) AS total_users
FROM afisha.purchases
GROUP BY currency_code
ORDER BY total_revenue DESC;


-- 2. Распределение выручки по типам устройств (только рублёвые заказы).
SELECT
    device_type_canonical,
    SUM(revenue) AS total_revenue,
    COUNT(order_id) AS total_orders,
    AVG(revenue) AS avg_revenue_per_order,
    ROUND(
        (SUM(revenue)::NUMERIC / SUM(SUM(revenue)) OVER ())::NUMERIC,
        3
    ) AS revenue_share
FROM afisha.purchases
WHERE currency_code = 'rub'
GROUP BY device_type_canonical
ORDER BY revenue_share DESC;


-- 3. Распределение выручки по типам мероприятий (только рублёвые заказы).
SELECT
    event_type_main,
    SUM(revenue) AS total_revenue,
    COUNT(order_id) AS total_orders,
    AVG(revenue) AS avg_revenue_per_order,
    COUNT(DISTINCT event_name_code) AS total_event_name,
    AVG(tickets_count) AS avg_tickets,
    SUM(revenue) / SUM(tickets_count) AS avg_ticket_revenue,
    ROUND(
        CAST(SUM(revenue) AS NUMERIC)
        / NULLIF(CAST(SUM(SUM(revenue)) OVER () AS NUMERIC), 0),
        3
    ) AS revenue_share
FROM afisha.purchases
JOIN afisha.events USING (event_id)
WHERE currency_code = 'rub'
GROUP BY event_type_main
ORDER BY total_orders DESC;


-- 4. Динамика показателей по неделям (только рублёвые заказы).
SELECT
    DATE_TRUNC('week', created_dt_msk)::DATE AS week,
    SUM(revenue) AS total_revenue,
    COUNT(order_id) AS total_orders,
    COUNT(DISTINCT user_id) AS total_users,
    SUM(revenue) / COUNT(order_id) AS revenue_per_order
FROM afisha.purchases
WHERE currency_code = 'rub'
GROUP BY DATE_TRUNC('week', created_dt_msk)::DATE
ORDER BY week;


-- 5. Семь регионов с наибольшей выручкой (только рублёвые заказы).
SELECT
    region_name,
    SUM(revenue) AS total_revenue,
    COUNT(order_id) AS total_orders,
    COUNT(DISTINCT user_id) AS total_users,
    SUM(tickets_count) AS total_tickets,
    SUM(revenue) / SUM(tickets_count) AS one_ticket_cost
FROM afisha.purchases
LEFT JOIN afisha.events USING (event_id)
LEFT JOIN afisha.city USING (city_id)
LEFT JOIN afisha.regions USING (region_id)
WHERE currency_code = 'rub'
GROUP BY region_name
ORDER BY total_revenue DESC
LIMIT 7;
