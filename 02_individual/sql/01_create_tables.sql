-- Индивидуальное задание по УП.11
-- Студент: Василенко Никита, группа 3ИП-12-24
-- Предметная область: Фитнес-клуб (Вариант 5)
-- Файл: 01_create_tables.sql (Создание таблиц БД в 3НФ)

PRAGMA foreign_keys = ON;

DROP TABLE IF EXISTS bookings;
DROP TABLE IF EXISTS workouts;
DROP TABLE IF EXISTS subscriptions;
DROP TABLE IF EXISTS halls;
DROP TABLE IF EXISTS trainers;
DROP TABLE IF EXISTS membership_types;
DROP TABLE IF EXISTS clients;

-- 1. Таблица клиентов фитнес-клуба
CREATE TABLE clients (
    client_id INTEGER PRIMARY KEY AUTOINCREMENT,
    full_name TEXT NOT NULL,
    birth_date TEXT NOT NULL,
    phone TEXT NOT NULL UNIQUE,
    email TEXT UNIQUE,
    reg_date TEXT NOT NULL DEFAULT (date('now'))
);

-- 2. Таблица тарифов (видов абонементов)
CREATE TABLE membership_types (
    type_id INTEGER PRIMARY KEY AUTOINCREMENT,
    type_name TEXT NOT NULL UNIQUE,
    duration_days INTEGER NOT NULL CHECK (duration_days > 0),
    visits_limit INTEGER CHECK (visits_limit IS NULL OR visits_limit > 0),
    base_price REAL NOT NULL CHECK (base_price > 0)
);

-- 3. Таблица оформленных абонементов клиентов
CREATE TABLE subscriptions (
    subscription_id INTEGER PRIMARY KEY AUTOINCREMENT,
    client_id INTEGER NOT NULL REFERENCES clients(client_id) ON DELETE CASCADE,
    type_id INTEGER NOT NULL REFERENCES membership_types(type_id) ON DELETE RESTRICT,
    purchase_date TEXT NOT NULL DEFAULT (date('now')),
    end_date TEXT NOT NULL,
    paid_amount REAL NOT NULL CHECK (paid_amount >= 0),
    status TEXT NOT NULL DEFAULT 'активен' CHECK (status IN ('активен', 'заморожен', 'завершен'))
);

-- 4. Таблица тренеров
CREATE TABLE trainers (
    trainer_id INTEGER PRIMARY KEY AUTOINCREMENT,
    full_name TEXT NOT NULL,
    specialization TEXT NOT NULL,
    phone TEXT NOT NULL UNIQUE,
    experience_years INTEGER NOT NULL DEFAULT 1 CHECK (experience_years >= 0),
    hourly_rate REAL NOT NULL CHECK (hourly_rate > 0)
);

-- 5. Таблица залов фитнес-клуба
CREATE TABLE halls (
    hall_id INTEGER PRIMARY KEY AUTOINCREMENT,
    hall_name TEXT NOT NULL UNIQUE,
    floor INTEGER NOT NULL CHECK (floor >= 1),
    capacity INTEGER NOT NULL CHECK (capacity > 0)
);

-- 6. Таблица расписания тренировок
CREATE TABLE workouts (
    workout_id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    trainer_id INTEGER NOT NULL REFERENCES trainers(trainer_id) ON DELETE RESTRICT,
    hall_id INTEGER NOT NULL REFERENCES halls(hall_id) ON DELETE RESTRICT,
    workout_date TEXT NOT NULL,
    start_time TEXT NOT NULL,
    duration_min INTEGER NOT NULL DEFAULT 60 CHECK (duration_min > 0),
    max_participants INTEGER NOT NULL CHECK (max_participants > 0)
);

-- 7. Таблица записей клиентов на тренировки (развязка связи M:N)
CREATE TABLE bookings (
    booking_id INTEGER PRIMARY KEY AUTOINCREMENT,
    workout_id INTEGER NOT NULL REFERENCES workouts(workout_id) ON DELETE CASCADE,
    client_id INTEGER NOT NULL REFERENCES clients(client_id) ON DELETE CASCADE,
    booked_at TEXT NOT NULL DEFAULT (datetime('now')),
    attended INTEGER NOT NULL DEFAULT 1 CHECK (attended IN (0, 1)),
    UNIQUE (workout_id, client_id)
);
