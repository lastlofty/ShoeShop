-- =====================================================================
--  ShoeShop · база данных магазина обуви «Топотун»
--  create_v1.sql — создание схемы (10 таблиц, 3НФ, PK/FK)
--  СУБД: MySQL 8.0 (проверено также на MariaDB 10.11)
--  Запуск: MySQL Workbench → File → Open SQL Script → Execute (Ctrl+Shift+Enter)
-- =====================================================================

DROP SCHEMA IF EXISTS topotun;
CREATE SCHEMA topotun DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE topotun;

-- ---------- справочники товаров ----------
CREATE TABLE categories (
    id   INT         NOT NULL AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uq_categories_name (name)
) ENGINE = InnoDB;

CREATE TABLE manufacturers (
    id   INT         NOT NULL AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uq_manufacturers_name (name)
) ENGINE = InnoDB;

CREATE TABLE suppliers (
    id   INT         NOT NULL AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uq_suppliers_name (name)
) ENGINE = InnoDB;

-- ---------- товары ----------
CREATE TABLE products (
    id              INT           NOT NULL AUTO_INCREMENT,
    article         VARCHAR(10)   NOT NULL,
    name            VARCHAR(50)   NOT NULL,
    unit            VARCHAR(10)   NOT NULL,
    price           DECIMAL(10,2) NOT NULL,
    discount        INT           NOT NULL DEFAULT 0,
    stock_qty       INT           NOT NULL DEFAULT 0,
    description     TEXT          NULL,
    photo           VARCHAR(100)  NULL,
    category_id     INT           NOT NULL,
    manufacturer_id INT           NOT NULL,
    supplier_id     INT           NOT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uq_products_article (article),
    KEY fk_products_category_idx (category_id),
    KEY fk_products_manufacturer_idx (manufacturer_id),
    KEY fk_products_supplier_idx (supplier_id),
    -- требования модуля 3: цена и количество не могут быть отрицательными
    CONSTRAINT chk_products_price    CHECK (price >= 0),
    CONSTRAINT chk_products_stock    CHECK (stock_qty >= 0),
    CONSTRAINT chk_products_discount CHECK (discount BETWEEN 0 AND 100),
    CONSTRAINT fk_products_category FOREIGN KEY (category_id)
        REFERENCES categories (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT fk_products_manufacturer FOREIGN KEY (manufacturer_id)
        REFERENCES manufacturers (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT fk_products_supplier FOREIGN KEY (supplier_id)
        REFERENCES suppliers (id) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE = InnoDB;

-- ---------- пользователи ----------
CREATE TABLE roles (
    id   INT         NOT NULL AUTO_INCREMENT,
    name VARCHAR(30) NOT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uq_roles_name (name)
) ENGINE = InnoDB;

CREATE TABLE users (
    id        INT         NOT NULL AUTO_INCREMENT,
    full_name VARCHAR(60) NOT NULL,
    login     VARCHAR(50) NOT NULL,
    password  VARCHAR(30) NOT NULL,
    role_id   INT         NOT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uq_users_login (login),
    KEY fk_users_role_idx (role_id),
    CONSTRAINT fk_users_role FOREIGN KEY (role_id)
        REFERENCES roles (id) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE = InnoDB;

-- ---------- заказы ----------
CREATE TABLE pvz (
    id       INT         NOT NULL AUTO_INCREMENT,
    postcode CHAR(6)     NOT NULL,
    city     VARCHAR(30) NOT NULL,
    street   VARCHAR(30) NOT NULL,
    house    VARCHAR(5)  NULL,
    PRIMARY KEY (id)
) ENGINE = InnoDB;

CREATE TABLE orderstatus (
    id   INT         NOT NULL AUTO_INCREMENT,
    name VARCHAR(20) NOT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uq_orderstatus_name (name)
) ENGINE = InnoDB;

CREATE TABLE orders (
    id            INT         NOT NULL AUTO_INCREMENT,
    order_date    DATETIME    NOT NULL,
    delivery_date DATETIME    NULL,
    pvz_id        INT         NOT NULL,
    user_id       INT         NOT NULL,
    receive_code  VARCHAR(10) NOT NULL,
    status_id     INT         NOT NULL,
    PRIMARY KEY (id),
    KEY fk_orders_pvz_idx (pvz_id),
    KEY fk_orders_user_idx (user_id),
    KEY fk_orders_status_idx (status_id),
    CONSTRAINT fk_orders_pvz FOREIGN KEY (pvz_id)
        REFERENCES pvz (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT fk_orders_user FOREIGN KEY (user_id)
        REFERENCES users (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT fk_orders_status FOREIGN KEY (status_id)
        REFERENCES orderstatus (id) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE = InnoDB;

CREATE TABLE prodorders (
    id         INT NOT NULL AUTO_INCREMENT,
    order_id   INT NOT NULL,
    product_id INT NOT NULL,
    qty        INT NOT NULL,
    PRIMARY KEY (id),
    KEY fk_prodorders_order_idx (order_id),
    KEY fk_prodorders_product_idx (product_id),
    CONSTRAINT chk_prodorders_qty CHECK (qty > 0),
    -- строки заказа не должны оставаться без заказа: удаляются вместе с ним
    CONSTRAINT fk_prodorders_order FOREIGN KEY (order_id)
        REFERENCES orders (id) ON DELETE CASCADE ON UPDATE NO ACTION,
    -- товар из заказа удалить нельзя (требование модуля 3)
    CONSTRAINT fk_prodorders_product FOREIGN KEY (product_id)
        REFERENCES products (id) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE = InnoDB;
