-- Индивидуальное задание по УП.11
-- Студент: Василенко Никита, группа 3ИП-12-24
-- Предметная область: Фитнес-клуб
-- Файл: 03_queries.sql (15 SQL-запросов к базе данных)

-- Запрос 1. Простая выборка: список всех клиентов, отсортированный по дате регистрации (свежие сверху)
SELECT client_id, full_name, phone, email, reg_date
FROM clients
ORDER BY reg_date DESC;

-- Запрос 2. Фильтрация WHERE + BETWEEN: тарифы абонементов стоимостью от 4000 до 10000 руб.
SELECT type_id, type_name, duration_days, visits_limit, base_price
FROM membership_types
WHERE base_price BETWEEN 4000 AND 10000
ORDER BY base_price ASC;

-- Запрос 3. Фильтрация LIKE и работа с IS NULL: безлимитные тарифы (где лимит посещений NULL)
SELECT type_id, type_name, duration_days, base_price
FROM membership_types
WHERE visits_limit IS NULL AND type_name LIKE 'Безлимит%';

-- Запрос 4. Выборка тренеров со стажем от 5 лет и ставкой выше 2000 руб./час
SELECT trainer_id, full_name, specialization, experience_years, hourly_rate
FROM trainers
WHERE experience_years >= 5 AND hourly_rate > 2000
ORDER BY experience_years DESC;

-- Запрос 5. Агрегатные функции: общее число проданных абонементов, общая выручка, средний, мин. и макс. чек
SELECT
    COUNT(*) AS total_subscriptions,
    SUM(paid_amount) AS total_revenue,
    ROUND(AVG(paid_amount), 2) AS avg_check,
    MIN(paid_amount) AS min_payment,
    MAX(paid_amount) AS max_payment
FROM subscriptions;

-- Запрос 6. Группировка GROUP BY: количество абонементов и сумма выручки по каждому статусу
SELECT
    status,
    COUNT(*) AS sub_count,
    SUM(paid_amount) AS status_revenue
FROM subscriptions
GROUP BY status
ORDER BY status_revenue DESC;

-- Запрос 7. INNER JOIN (3 таблицы): список активных абонементов с ФИО клиента и названием тарифа
SELECT
    s.subscription_id,
    c.full_name AS client_name,
    mt.type_name AS tariff,
    s.purchase_date,
    s.end_date,
    s.paid_amount
FROM subscriptions s
INNER JOIN clients c ON s.client_id = c.client_id
INNER JOIN membership_types mt ON s.type_id = mt.type_id
WHERE s.status = 'активен'
ORDER BY s.end_date DESC;

-- Запрос 8. INNER JOIN (3 таблицы): полное расписание тренировок с ФИО тренера и названием зала
SELECT
    w.workout_date,
    w.start_time,
    w.title AS workout_title,
    t.full_name AS trainer_name,
    h.hall_name,
    w.duration_min
FROM workouts w
INNER JOIN trainers t ON w.trainer_id = t.trainer_id
INNER JOIN halls h ON w.hall_id = h.hall_id
ORDER BY w.workout_date, w.start_time;

-- Запрос 9. LEFT JOIN + GROUP BY: сколько тренировок проводит каждый тренер и сколько всего человек записалось
SELECT
    t.full_name AS trainer_name,
    t.specialization,
    COUNT(DISTINCT w.workout_id) AS workouts_count,
    COUNT(b.booking_id) AS total_bookings
FROM trainers t
LEFT JOIN workouts w ON t.trainer_id = w.trainer_id
LEFT JOIN bookings b ON w.workout_id = b.workout_id
GROUP BY t.trainer_id, t.full_name, t.specialization
ORDER BY total_bookings DESC;

-- Запрос 10. GROUP BY + HAVING: тренировки, на которые записалось не менее 3 клиентов
SELECT
    w.workout_id,
    w.title,
    w.workout_date,
    COUNT(b.booking_id) AS booked_clients
FROM workouts w
INNER JOIN bookings b ON w.workout_id = b.workout_id
GROUP BY w.workout_id, w.title, w.workout_date
HAVING COUNT(b.booking_id) >= 3
ORDER BY booked_clients DESC;

-- Запрос 11. LEFT JOIN + IS NULL: клиенты, которые ещё ни разу не записывались на групповые тренировки
SELECT
    c.client_id,
    c.full_name,
    c.phone
FROM clients c
LEFT JOIN bookings b ON c.client_id = b.client_id
WHERE b.booking_id IS NULL;

-- Запрос 12. Скалярный подзапрос: тарифы абонементов, стоимость которых выше средней стоимости всех тарифов
SELECT
    type_id,
    type_name,
    base_price
FROM membership_types
WHERE base_price > (SELECT AVG(base_price) FROM membership_types)
ORDER BY base_price DESC;

-- Запрос 13. Подзапрос с IN: клиенты, которые посещали тренировки у тренера Громова С.В.
SELECT
    client_id,
    full_name,
    phone
FROM clients
WHERE client_id IN (
    SELECT b.client_id
    FROM bookings b
    INNER JOIN workouts w ON b.workout_id = w.workout_id
    INNER JOIN trainers t ON w.trainer_id = t.trainer_id
    WHERE t.full_name LIKE 'Громов%' AND b.attended = 1
);

-- Запрос 14. Выражение CASE: классификация клиентов по сумме оплаченных абонементов
SELECT
    c.full_name,
    COALESCE(SUM(s.paid_amount), 0) AS total_spent,
    CASE
        WHEN COALESCE(SUM(s.paid_amount), 0) >= 40000 THEN 'VIP-клиент'
        WHEN COALESCE(SUM(s.paid_amount), 0) >= 15000 THEN 'Постоянный клиент'
        ELSE 'Базовый клиент'
    END AS client_category
FROM clients c
LEFT JOIN subscriptions s ON c.client_id = s.client_id
GROUP BY c.client_id, c.full_name
ORDER BY total_spent DESC;

-- Запрос 15. Аналитика заполняемости залов (процент занятых мест на каждой тренировке)
SELECT
    w.title AS workout_title,
    h.hall_name,
    w.max_participants,
    COUNT(b.booking_id) AS registered_count,
    ROUND(CAST(COUNT(b.booking_id) AS REAL) * 100.0 / w.max_participants, 1) AS fill_percent
FROM workouts w
INNER JOIN halls h ON w.hall_id = h.hall_id
LEFT JOIN bookings b ON w.workout_id = b.workout_id
GROUP BY w.workout_id, w.title, h.hall_name, w.max_participants
ORDER BY fill_percent DESC;
