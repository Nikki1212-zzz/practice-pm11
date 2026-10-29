-- КИМ ДЭ 09.02.07-2 (Модуль 1. Разработка базы данных «Чудо Обувь»)
-- Студент: Василенко Никита, группа 3ИП-12-24

PRAGMA foreign_keys = ON;

DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS stock_items;
DROP TABLE IF EXISTS sizes;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS roles;

CREATE TABLE roles (
    role_id INTEGER PRIMARY KEY,
    role_name TEXT NOT NULL UNIQUE
);

CREATE TABLE users (
    user_id INTEGER PRIMARY KEY,
    last_name TEXT NOT NULL,
    first_name TEXT NOT NULL,
    middle_name TEXT,
    login TEXT NOT NULL UNIQUE,
    role_id INTEGER NOT NULL,
    FOREIGN KEY (role_id) REFERENCES roles(role_id)
);

CREATE TABLE products (
    product_id INTEGER PRIMARY KEY,
    category TEXT NOT NULL,
    subcategory TEXT,
    product_name TEXT NOT NULL,
    manufacturer TEXT,
    image_path TEXT,
    description TEXT,
    composition TEXT,
    price NUMERIC NOT NULL CHECK (price >= 0)
);

CREATE TABLE sizes (
    size_id INTEGER PRIMARY KEY,
    size_value TEXT NOT NULL UNIQUE
);

CREATE TABLE stock_items (
    stock_item_id INTEGER PRIMARY KEY,
    product_id INTEGER NOT NULL,
    size_id INTEGER NOT NULL,
    quantity_available INTEGER NOT NULL CHECK (quantity_available >= 0),
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (size_id) REFERENCES sizes(size_id),
    UNIQUE (product_id, size_id)
);

CREATE TABLE orders (
    order_id INTEGER PRIMARY KEY,
    order_date DATE NOT NULL,
    user_id INTEGER NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE TABLE order_items (
    order_item_id INTEGER PRIMARY KEY,
    order_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    size_id INTEGER NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    price NUMERIC NOT NULL CHECK (price >= 0),
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (size_id) REFERENCES sizes(size_id)
);
