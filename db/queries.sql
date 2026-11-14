-- =====================================================================
--  ShoeShop · queries.sql — SQL-запросы для приложения
--  СУБД: MySQL 8.0
--
--  Знак ? обозначает параметр MySqlCommand. Для проверки в Workbench
--  замените его реальным значением соответствующего типа.
-- =====================================================================

USE topotun;

-- ---------------------------------------------------------------------
-- 1. Авторизация пользователя (чек-лист 2.5, 2.6, 3.17)
-- Параметры: login, password. Успешный вход возвращает одну строку.
-- ---------------------------------------------------------------------
SELECT u.id,
       u.full_name,
       r.name AS role
FROM users AS u
JOIN roles AS r ON r.id = u.role_id
WHERE u.login = ?
  AND u.password = ?;

-- ---------------------------------------------------------------------
-- 2. Каталог товаров для гостя и авторизованных ролей (2.7–2.11)
-- Названия справочников возвращаются сразу, без дополнительных запросов.
-- ---------------------------------------------------------------------
SELECT p.id,
       p.article,
       p.name,
       p.unit,
       p.price,
       p.discount,
       ROUND(p.price * (100 - p.discount) / 100, 2) AS final_price,
       p.stock_qty,
       p.description,
       p.photo,
       c.name AS category,
       m.name AS manufacturer,
       s.name AS supplier
FROM products AS p
JOIN categories AS c ON c.id = p.category_id
JOIN manufacturers AS m ON m.id = p.manufacturer_id
JOIN suppliers AS s ON s.id = p.supplier_id
ORDER BY p.name;

-- ---------------------------------------------------------------------
-- 3. Совместные поиск, фильтр и сортировка по возрастанию (3.2–3.6)
-- Параметры: search_text, supplier_id, supplier_id.
-- Передайте NULL в оба параметра supplier_id для «Все поставщики».
-- Пустая строка search_text показывает весь каталог.
-- ---------------------------------------------------------------------
SELECT p.id,
       p.article,
       p.name,
       p.unit,
       p.price,
       p.discount,
       ROUND(p.price * (100 - p.discount) / 100, 2) AS final_price,
       p.stock_qty,
       p.description,
       p.photo,
       c.name AS category,
       m.name AS manufacturer,
       s.name AS supplier
FROM products AS p
JOIN categories AS c ON c.id = p.category_id
JOIN manufacturers AS m ON m.id = p.manufacturer_id
JOIN suppliers AS s ON s.id = p.supplier_id
WHERE CONCAT_WS(' ',
        p.article,
        p.name,
        p.unit,
        p.description,
        c.name,
        m.name,
        s.name
      ) LIKE CONCAT('%', ?, '%')
  AND (? IS NULL OR p.supplier_id = ?)
ORDER BY p.stock_qty ASC;

-- Тот же набор условий, сортировка по убыванию (3.2–3.6).
-- Параметры передаются в том же порядке.
SELECT p.id,
       p.article,
       p.name,
       p.unit,
       p.price,
       p.discount,
       ROUND(p.price * (100 - p.discount) / 100, 2) AS final_price,
       p.stock_qty,
       p.description,
       p.photo,
       c.name AS category,
       m.name AS manufacturer,
       s.name AS supplier
FROM products AS p
JOIN categories AS c ON c.id = p.category_id
JOIN manufacturers AS m ON m.id = p.manufacturer_id
JOIN suppliers AS s ON s.id = p.supplier_id
WHERE CONCAT_WS(' ',
        p.article,
        p.name,
        p.unit,
        p.description,
        c.name,
        m.name,
        s.name
      ) LIKE CONCAT('%', ?, '%')
  AND (? IS NULL OR p.supplier_id = ?)
ORDER BY p.stock_qty DESC;

-- ---------------------------------------------------------------------
-- 4. Справочники для выпадающих списков формы товара (3.7, 3.10)
-- ---------------------------------------------------------------------
SELECT id, name FROM categories ORDER BY name;
SELECT id, name FROM manufacturers ORDER BY name;
SELECT id, name FROM suppliers ORDER BY name;

-- ---------------------------------------------------------------------
-- 5. Добавление товара (3.7, 3.12, 3.19)
-- Параметры соответствуют перечисленным столбцам слева направо.
-- ---------------------------------------------------------------------
INSERT INTO products
    (article,
     name,
     unit,
     price,
     discount,
     stock_qty,
     description,
     photo,
     category_id,
     manufacturer_id,
     supplier_id)
VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);

-- ---------------------------------------------------------------------
-- 6. Открытие товара для редактирования (3.10)
-- Параметр: id.
-- ---------------------------------------------------------------------
SELECT id,
       article,
       name,
       unit,
       price,
       discount,
       stock_qty,
       description,
       photo,
       category_id,
       manufacturer_id,
       supplier_id
FROM products
WHERE id = ?;

-- ---------------------------------------------------------------------
-- 7. Сохранение изменений товара (3.12, 3.19)
-- Последний параметр — id редактируемого товара.
-- ---------------------------------------------------------------------
UPDATE products
SET article = ?,
    name = ?,
    unit = ?,
    price = ?,
    discount = ?,
    stock_qty = ?,
    description = ?,
    photo = ?,
    category_id = ?,
    manufacturer_id = ?,
    supplier_id = ?
WHERE id = ?;

-- ---------------------------------------------------------------------
-- 8. Проверка товара перед удалением (3.16)
-- Если used_in_orders > 0, приложение показывает предупреждение.
-- ---------------------------------------------------------------------
SELECT COUNT(*) AS used_in_orders
FROM prodorders
WHERE product_id = ?;

-- Удаление разрешено только при used_in_orders = 0. Параметр: id.
-- Внешний ключ prodorders → products дополнительно защищает данные.
DELETE FROM products
WHERE id = ?;
