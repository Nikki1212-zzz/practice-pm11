-- Аналитические и рабочие SQL-запросы для системы «Чудо Обувь» (КИМ ДЭ 09.02.07-2)
-- Студент: Василенко Никита, группа 3ИП-12-24

-- 1. Каталог моделей обуви с суммарным остатком по всем размерам и расчётом скидки 25%
-- (скидка 25% предоставляется на товары, на которые не было заказов за предыдущий месяц)
SELECT
    p.product_id,
    p.category,
    p.product_name,
    p.manufacturer,
    p.price AS base_price,
    CASE
        WHEN p.product_id NOT IN (
            SELECT DISTINCT oi.product_id
            FROM order_items oi
            JOIN orders o ON oi.order_id = o.order_id
            WHERE o.order_date BETWEEN '2026-04-01' AND '2026-04-30'
        ) THEN ROUND(p.price * 0.75, 2)
        ELSE p.price
    END AS final_price_with_discount,
    COALESCE(SUM(si.quantity_available), 0) AS total_stock,
    CASE
        WHEN COALESCE(SUM(si.quantity_available), 0) <= 3 THEN 'Подсветка #ff8080 (<= 3 пар)'
        ELSE 'Обычный фон'
    END AS row_highlight
FROM products p
LEFT JOIN stock_items si ON p.product_id = si.product_id
GROUP BY p.product_id
ORDER BY p.product_id;

-- 2. Список заказов с датой заказа, ФИО клиента и итоговой суммой заказа (Модуль 1 / Модуль 4)
SELECT
    o.order_id,
    o.order_date,
    u.last_name || ' ' || u.first_name || ' ' || COALESCE(u.middle_name, '') AS client_fio,
    COUNT(oi.order_item_id) AS positions_count,
    SUM(oi.quantity * oi.price) AS order_total_rub
FROM orders o
JOIN users u ON o.user_id = u.user_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY o.order_id, o.order_date, client_fio
ORDER BY o.order_id;
