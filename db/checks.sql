-- =====================================================================
--  ShoeShop · checks.sql — проверка рабочей БД после импорта
--  Каждый блок можно выполнять отдельно (Ctrl+Enter на строке).
-- =====================================================================

USE topotun;

-- 1. Количество строк должно совпадать с импортом ДЭ:
--    2 / 6 / 2 / 30 / 3 / 10 / 36 / 2 / 10 / 20
SELECT 'categories' AS tbl, COUNT(*) AS cnt FROM categories
UNION ALL SELECT 'manufacturers', COUNT(*) FROM manufacturers
UNION ALL SELECT 'suppliers',     COUNT(*) FROM suppliers
UNION ALL SELECT 'products',      COUNT(*) FROM products
UNION ALL SELECT 'roles',         COUNT(*) FROM roles
UNION ALL SELECT 'users',         COUNT(*) FROM users
UNION ALL SELECT 'pvz',           COUNT(*) FROM pvz
UNION ALL SELECT 'orderstatus',   COUNT(*) FROM orderstatus
UNION ALL SELECT 'orders',        COUNT(*) FROM orders
UNION ALL SELECT 'prodorders',    COUNT(*) FROM prodorders;

-- 2. Каталог так, как его покажет приложение (все справочники через JOIN)
SELECT p.article, p.name, c.name AS category, m.name AS manufacturer, s.name AS supplier,
       p.price, p.discount,
       ROUND(p.price * (100 - p.discount) / 100, 2) AS final_price,
       p.stock_qty, p.unit
FROM products p
JOIN categories    c ON c.id = p.category_id
JOIN manufacturers m ON m.id = p.manufacturer_id
JOIN suppliers     s ON s.id = p.supplier_id
ORDER BY p.stock_qty;

-- 3. Подсветка из ТЗ: скидка > 15% (#2E8B57) и нет на складе (голубой)
SELECT article, name, discount, stock_qty,
       CASE WHEN discount > 15 THEN '#2E8B57'
            WHEN stock_qty = 0 THEN '#ADD8E6'
            ELSE '' END AS row_color
FROM products
WHERE discount > 15 OR stock_qty = 0;

-- 4. Заказы с клиентом, адресом ПВЗ, статусом и суммой
SELECT o.id, o.order_date, o.delivery_date, u.full_name,
       CONCAT_WS(', ', z.postcode, z.city, z.street, z.house) AS pvz_address,
       st.name AS status, o.receive_code,
       SUM(po.qty * p.price * (100 - p.discount) / 100) AS total
FROM orders o
JOIN users       u  ON u.id  = o.user_id
JOIN pvz         z  ON z.id  = o.pvz_id
JOIN orderstatus st ON st.id = o.status_id
JOIN prodorders  po ON po.order_id = o.id
JOIN products    p  ON p.id  = po.product_id
GROUP BY o.id, o.order_date, o.delivery_date, u.full_name, pvz_address, st.name, o.receive_code
ORDER BY o.id;

-- 5. Вход: найти пользователя и роль по логину/паролю
SELECT u.id, u.full_name, r.name AS role
FROM users u JOIN roles r ON r.id = u.role_id
WHERE u.login = '94d5ous@gmail.com' AND u.password = 'uzWC67';

-- 6. Товары, которые удалить нельзя (есть в заказах)
SELECT DISTINCT p.id, p.article, p.name
FROM products p JOIN prodorders po ON po.product_id = p.id
ORDER BY p.id;

-- 7. Проверка, что внешние ключи реально защищают данные.
--    Обе команды ДОЛЖНЫ завершиться ошибкой 1452 / 1451:
-- INSERT INTO products (article, name, unit, price, discount, stock_qty, category_id, manufacturer_id, supplier_id)
--     VALUES ('TEST01', 'Тест', 'шт.', 100, 0, 1, 99, 1, 1);
--   → Cannot add or update a child row: a foreign key constraint fails
-- DELETE FROM products WHERE id = 1;
--   → Cannot delete or update a parent row: a foreign key constraint fails
