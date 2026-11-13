# База данных `topotun` (MySQL 8.0)

## Файлы

| Файл | Что это | Пара |
|---|---|---|
| `import/*.csv` | 10 файлов данных, полученных из 4 файлов импорта ДЭ (UTF-8, разделитель — запятая) | 9 |
| `topotun.mwb` | Модель MySQL Workbench (EER-диаграмма) | 10 |
| `create_v1.sql` | Скрипт создания схемы: 10 таблиц, типы, PK + AUTO_INCREMENT, FK, CHECK | 10–11 |
| `insert_data.sql` | Загрузка всех данных из CSV одним скриптом (без мастера импорта) | 11 |
| `checks.sql` | Проверочные запросы: число строк, каталог, подсветка, заказы, вход, FK | 11–12 |
| `backup/topotun_backup_*.sql` | Полная резервная копия (структура + данные) | 12 |
| `backup.bat` | Создаёт свежий дамп через `mysqldump` в `backup/` | 12 |
| `restore.bat` | Восстанавливает БД из последнего (или указанного) дампа | 12 |

## Как развернуть БД с нуля

1. MySQL Workbench → **File → Open SQL Script…** → `create_v1.sql` → выполнить (⚡).
2. Так же открыть и выполнить `insert_data.sql`.
3. Открыть `checks.sql`, выполнить запрос 1 — должно получиться
   **2 / 6 / 2 / 30 / 3 / 10 / 36 / 2 / 10 / 20** строк.

Альтернатива шагу 2 — мастер импорта (пара 10): правый клик по схеме → **Table Data Import Wizard** →
файл из `import/` → *Use existing table*.

## Резервная копия и восстановление

```bat
db\backup.bat            :: дамп в db\backup\topotun_dump_ГГГГ-ММ-ДД_ЧЧММ.sql
db\restore.bat           :: восстановить из последнего дампа
db\restore.bat файл.sql  :: восстановить из конкретного файла
```

Через Workbench: **Server → Data Export** (Export to Self-Contained File) и **Server → Data Import**.
Если MySQL установлен не в `C:\Program Files\MySQL\MySQL Server 8.0`, поправьте переменную `MYSQL_BIN` в начале `.bat`-файлов.

## Схема

| Таблица | Ключевые поля | Ссылки (FK) |
|---|---|---|
| categories, manufacturers, suppliers | id, name | — |
| products | id, article (уникальный), price DECIMAL(10,2), discount, stock_qty | category_id, manufacturer_id, supplier_id |
| roles | id, name | — |
| users | id, full_name, login (уникальный), password | role_id |
| pvz | id, postcode, city, street, house (NULL) | — |
| orderstatus | id, name | — |
| orders | id, order_date, delivery_date, receive_code | pvz_id, user_id, status_id |
| prodorders | id, qty | order_id (**ON DELETE CASCADE**), product_id |

Удаление заказа удаляет его строки (`CASCADE`); удалить товар, который есть в заказе, нельзя (`NO ACTION`) —
это требование модуля 3. Проверено: попытка вставить товар с `category_id = 99` даёт ошибку 1452,
удаление товара из заказа — ошибку 1451, отрицательная цена — ошибку CHECK.

## Что исправлено при подготовке данных (исходные xlsx не менялись)

| Где | Проблема в исходнике | Решение в CSV |
|---|---|---|
| Все файлы | Пустые строки после данных | Удалены |
| Пункты выдачи | Нет заголовков, адрес одной ячейкой | Разбит на postcode, city, street, house; убраны «г.» и «ул.» |
| ПВЗ 19 | Нет номера дома | `house` пустой (NULL) |
| ПВЗ 33 | Нет запятой между городом и улицей | Разделено вручную |
| ПВЗ 13, 14, 16, 20, 25 | «г.Лесной» без пробела, двойные пробелы | Нормализовано |
| Заказ 7 | Дата 30.02.2025 (не существует) | 2025-03-30 (по соседним заказам — март) |
| Заказы | Статус «Новый » с пробелом | «Новый» |
| Заказы | ФИО клиента текстом | `user_id` (первая учётная запись с этим ФИО) |
| Заказы | Несколько товаров в ячейке «Артикул заказа» | 20 строк в `prodorders.csv` |
