DROP TABLE IF EXISTS GuestInfomation cascade;
DROP TABLE IF EXISTS Delivery cascade;
DROP TABLE IF EXISTS DeliveryMethod cascade;
DROP TABLE IF EXISTS DeliveryStatus cascade;
DROP TABLE IF EXISTS Payment cascade;
DROP TABLE IF EXISTS PaymentStatus cascade;
DROP TABLE IF EXISTS PaymentMethod cascade;
DROP TABLE IF EXISTS OrderItem cascade;
DROP TABLE IF EXISTS OrderData cascade;
DROP TABLE IF EXISTS CartItem cascade;
DROP TABLE IF EXISTS VariantAttribute cascade;
DROP TABLE IF EXISTS Variant cascade;
DROP TABLE IF EXISTS ProductAttribute cascade;
DROP TABLE IF EXISTS ProductCategory cascade;
DROP TABLE IF EXISTS Product cascade;
DROP TABLE IF EXISTS Category cascade;
DROP TABLE IF EXISTS AccountCredential cascade;
DROP TABLE IF EXISTS Session cascade;
DROP TABLE IF EXISTS TelephoneNumber cascade;
DROP TABLE IF EXISTS UserInformation cascade;
DROP TABLE IF EXISTS Customer cascade;
DROP TABLE IF EXISTS AccountType cascade;
DROP TABLE IF EXISTS City cascade;
DROP TABLE IF EXISTS CityType cascade;
DROP TABLE IF EXISTS CategorySuggestion cascade;
DROP TABLE IF EXISTS ProductImage cascade;
DROP TABLE IF EXISTS Tag cascade;
DROP TABLE IF EXISTS ProductTag cascade;
DROP TABLE IF EXISTS CartItemStatus cascade;
DROP TABLE IF EXISTS OrderStatus cascade;


-- Function to check if positive
CREATE OR REPLACE FUNCTION is_positive(val numeric) RETURNS BOOLEAN AS 
$$ 
BEGIN 
IF val IS NULL THEN RETURN true;
ELSEIF val >= 0 THEN RETURN true;
ELSE RETURN false;
END IF;
END;
$$ LANGUAGE PLpgSQL;



-- Days that would take to deliver to each city type (ENUM)
CREATE TABLE CityType (
    city_type varchar(15),
    description varchar(127),
    delivery_days int not null check(is_positive(delivery_days)),
    primary key (city_type)
);

-- Info about cities
CREATE TABLE City (
    city varchar(127),
    city_type varchar(15) not null,
    primary key (city),
    foreign key (city_type) references CityType(city_type) on update cascade
);

-- Account Types: Logged in/Guest (ENUM)
CREATE TABLE AccountType (
    account_type varchar(15),
    description varchar(127),
    primary key (account_type)
);

-- Info about guest/logged in users
CREATE TABLE Customer (
    customer_id char(36),
    account_type varchar(15) not null,
    primary key (customer_id),
    foreign key (account_type) references AccountType(account_type) on update cascade
);

-- Information about each logged in user
CREATE TABLE UserInformation (
    customer_id char(36),
    email varchar(255) not null,
    first_name char(255) not null,
    last_name varchar(255) not null,
    addr_line1 varchar(255) not null,
    addr_line2 varchar(255) not null,
    city varchar(127),
    postcode varchar(31) not null,
    dob timestamp not null,
    last_login timestamp default now(),
    primary key (customer_id),
    foreign key (customer_id) references Customer(customer_id),
    foreign key (city) references City(city) on update cascade,
    unique(email)
);

-- Store telephone numbers of users
CREATE TABLE TelephoneNumber (
    customer_id char(36),
    phone_number varchar(15),
    primary key (customer_id, phone_number),
    foreign key (customer_id) references UserInformation(customer_id)
);

-- Session table
CREATE TABLE Session (
    session_id char(36),
    customer_id char(36) not null,
    created_time timestamp not null default now(),
    updated_time timestamp default now(),
    expire_date timestamp not null,
    primary key (session_id),
    foreign key (customer_id) references Customer(customer_id)
);

-- Credential table
CREATE TABLE AccountCredential (
    customer_id char(36),
    password char(60) not null,
    primary key (customer_id),
    foreign key (customer_id) references UserInformation(customer_id)
);

-- Categories
CREATE TABLE Category (
    category_id char(36),
    title varchar(255),
    parent_id char(36),
    primary key (category_id),
    foreign key (parent_id) references Category(category_id)
);

-- Category Relations for suggestions
CREATE TABLE CategorySuggestion (
    category_id char(36),
    suggestion_category_id char(36),
    primary key (category_id, suggestion_category_id),
    foreign key (category_id) references Category(category_id),
    foreign key (suggestion_category_id) references Category(category_id)
);

-- Products
CREATE TABLE Product (
    product_id char(36),
    title varchar(255) not null,
    description text not null,
    weight_kilos numeric(7, 2) check(is_positive(weight_kilos)),
    brand varchar(255),
    primary key (product_id)
);

-- Categoories that products belong to
CREATE TABLE ProductCategory (
    category_id char(36),
    product_id char(36),
    primary key (category_id, product_id),
    foreign key (category_id) references Category(category_id),
    foreign key (product_id) references Product(product_id)
);

-- Images of a product
CREATE TABLE ProductImage (
    image_id char(36),
    product_id char(36),
    image_url varchar(255) not null,
    primary key (image_id),
    foreign key (product_id) references Product(product_id)
);

-- Tags
CREATE TABLE Tag (
    tag_id char(36),
    tag varchar(255) not null,
    primary key (tag_id)
);

-- Tags of a product
CREATE TABLE ProductTag (
    product_id char(36),
    tag_id char(36),
    primary key (product_id, tag_id),
    foreign key (product_id) references Product(product_id),
    foreign key (tag_id) references Tag(tag_id)
);

-- Attributes common to a product
CREATE TABLE ProductAttribute (
    product_id char(36),
    attribute_name char(31) not null,
    attribute_value varchar(255) not null,
    primary key (product_id, attribute_name),
    foreign key (product_id) references Product(product_id)
);

-- Variants
CREATE TABLE Variant (
    variant_id char(36),
    product_id char(36) not null,
    sku_id varchar(127),
    quantity int not null check(is_positive(quantity)),
    title varchar(255) not null,
    description text not null,
    listed_price numeric(12, 2) not null check(is_positive(listed_price)),
    selling_price numeric(12, 2) not null check(is_positive(selling_price)),
    primary key (variant_id),
    foreign key (product_id) references Product(product_id),
    unique(sku_id)
);

-- Attributes common to a variant
CREATE TABLE VariantAttribute (
    variant_id char(36),
    attribute_name char(31) not null,
    attribute_value varchar(255) not null,
    primary key (variant_id, attribute_name),
    foreign key (variant_id) references Variant(variant_id)
);

-- Cart Item State (ENUM)
CREATE TABLE CartItemStatus (
    cart_item_status varchar(15),
    description varchar(127),
    primary key (cart_item_status)
);

-- Items in cart
CREATE TABLE CartItem (
    customer_id char(36),
    variant_id char(36),
    cart_item_status varchar(15) not null,
    quantity int not null check(is_positive(quantity)),
    added_time timestamp not null default now(),
    primary key (customer_id, variant_id),
    foreign key (customer_id) references Customer(customer_id),
    foreign key (cart_item_status) references CartItemStatus(cart_item_status),
    foreign key (variant_id) references Variant(variant_id)
);

-- Order Status (ENUM)
CREATE TABLE OrderStatus (
    order_status varchar(15),
    description varchar(127),
    primary key (order_status)
);

-- Orders
CREATE TABLE OrderData (
    order_id char(36),
    customer_id char(36) not null,
    order_status varchar(15) not null,
    order_date timestamp,
    primary key (order_id),
    foreign key (order_status) references OrderStatus(order_status),
    foreign key (customer_id) references Customer(customer_id)
);

-- items in order
CREATE TABLE OrderItem (
    variant_id char(36),
    order_id char(36),
    quantity int not null check(is_positive(quantity)),
    primary key (variant_id, order_id),
    foreign key (variant_id) references Variant(variant_id),
    foreign key (order_id) references OrderData(order_id)
);

-- Payment Methods: Card/PayOnDelivery (ENUM)
CREATE TABLE PaymentMethod (
    payment_method varchar(15),
    description varchar(127),
    primary key (payment_method)
);

-- Payment Status: Payed/NotPayed (ENUM)
CREATE TABLE PaymentStatus (
    payment_status varchar(15),
    description varchar(127),
    primary key (payment_status)
);

-- Payment Information
CREATE TABLE Payment (
    order_id char(36),
    payment_method varchar(15) not null,
    payment_status varchar(15) not null,
    payment_date timestamp,
    payment_amount numeric(12, 2) check(is_positive(payment_amount)),
    primary key (order_id),
    foreign key (order_id) references OrderData(order_id),
    foreign key (payment_method) references PaymentMethod(payment_method) on update cascade,
    foreign key (payment_status) references PaymentStatus(payment_status) on update cascade
);

-- Delivery Status: Delivered/NotDelivered (ENUM)
CREATE TABLE DeliveryStatus (
    delivery_status varchar(15),
    description varchar(127),
    primary key (delivery_status)
);

-- Delivery Method: Shipping/StorePickup (ENUM)
CREATE TABLE DeliveryMethod (
    delivery_method varchar(15),
    description varchar(127),
    primary key (delivery_method)
);

-- Delivery Information
CREATE TABLE Delivery (
    order_id char(36),
    delivery_method varchar(15) not null,
    delivery_status varchar(15) not null,
    addr_line1 varchar(12) not null,
    addr_line2 varchar(32) not null,
    city varchar(127) not null,
    postcode varchar(31) not null,
    delivered_date timestamp,
    primary key (order_id),
    foreign key (order_id) references OrderData(order_id),
    foreign key (delivery_method) references DeliveryMethod(delivery_method) on update cascade,
    foreign key (delivery_status) references DeliveryStatus(delivery_status) on update cascade,
    foreign key (city) references City(city) on update cascade
);

-- User Inforation (If user is a guest)
CREATE TABLE GuestInfomation (
    order_id char(36),
    first_name varchar(255) not null,
    last_name varchar(255) not null,
    email varchar(255) not null,
    phone_number varchar(15) not null,
    primary key (order_id),
    foreign key (order_id) references OrderData(order_id)
);