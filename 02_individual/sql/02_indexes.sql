-- Индивидуальное задание по УП.11
-- Студент: Василенко Никита, группа 3ИП-12-24
-- Предметная область: Фитнес-клуб
-- Файл: 02_indexes.sql (Создание индексов и проверка плана выполнения)

-- Индекс 1: Ускорение поиска абонементов по клиенту и статусу
CREATE INDEX IF NOT EXISTS idx_subscriptions_client_status
ON subscriptions (client_id, status);

-- Индекс 2: Ускорение выборки расписания тренировок по дате и тренеру
CREATE INDEX IF NOT EXISTS idx_workouts_date_trainer
ON workouts (workout_date, trainer_id);

-- Индекс 3 (дополнительный): Поиск клиента по ФИО
CREATE INDEX IF NOT EXISTS idx_clients_full_name
ON clients (full_name);

-- Проверка использования индекса через EXPLAIN QUERY PLAN
EXPLAIN QUERY PLAN
SELECT workout_id, title, start_time
FROM workouts
WHERE workout_date = '2026-10-21' AND trainer_id = 1;
