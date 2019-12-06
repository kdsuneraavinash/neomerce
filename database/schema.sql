DROP TRIGGER IF EXISTS afterProductCategoryInsertTrigger ON ProductCategory;
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
DROP DOMAIN IF EXISTS MONEY_UNIT cascade;
DROP DOMAIN IF EXISTS VALID_EMAIL cascade;
DROP DOMAIN IF EXISTS VALID_PHONE cascade;
DROP DOMAIN IF EXISTS UUID4 cascade;
DROP DOMAIN IF EXISTS URL cascade;

/* 
   __                  _   _                 
  / _|                | | (_)                
 | |_ _   _ _ __   ___| |_ _  ___  _ __  ___ 
 |  _| | | | '_ \ / __| __| |/ _ \| '_ \/ __|
 | | | |_| | | | | (__| |_| | (_) | | | \__ \
 |_|  \__,_|_| |_|\___|\__|_|\___/|_| |_|___/                              
 */


-- Function to check if positive
CREATE OR REPLACE FUNCTION is_positive(val numeric) RETURNS BOOLEAN AS 
$$ 
BEGIN 
    if val is null then return true;
    elseif val >= 0 then return true;
    else return false;
    end if;
END;
$$ LANGUAGE PLpgSQL;

-- Function to create a UUID
-- https://stackoverflow.com/questions/12505158/generating-a-uuid-in-postgres-for-insert-statement
CREATE OR REPLACE FUNCTION generate_uuid4() RETURNS CHAR(36) AS
$$
DECLARE
    var_uuid CHAR(36);
BEGIN
    select uuid_in(
        overlay(
            overlay(
                md5(random()::text || ':' || clock_timestamp()::text) 
                placing '4' from 13
            ) 
            placing to_hex(floor(random()*(11-8+1) + 8)::int)::text from 17
        )::cstring
    ) 
    into var_uuid;
    return var_uuid;
END
$$ LANGUAGE PLpgSQL;

/*
      _                       _           
     | |                     (_)          
   __| | ___  _ __ ___   __ _ _ _ __  ___ 
  / _` |/ _ \| '_ ` _ \ / _` | | '_ \/ __|
 | (_| | (_) | | | | | | (_| | | | | \__ \
  \__,_|\___/|_| |_| |_|\__,_|_|_| |_|___/
*/

CREATE DOMAIN MONEY_UNIT AS NUMERIC(12, 2) CHECK(is_positive(VALUE));
CREATE DOMAIN VALID_EMAIL AS VARCHAR(255) CHECK(
    VALUE ~ '(([^<>()\[\]\.,;:\s@\"]+(\.[^<>()\[\]\.,;:\s@\"]+)*)|(\".+\"))@(([^<>()[\]\.,;:\s@\"]+\.)+[^<>()[\]\.,;:\s@\"]{2,})'
);
CREATE DOMAIN VALID_PHONE AS CHAR(15) CHECK(
    VALUE ~ '[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*'
);
CREATE DOMAIN UUID4 AS VARCHAR(36) CHECK(
    VALUE ~ '[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}'
);
CREATE DOMAIN URL AS VARCHAR(1023) CHECK(
    VALUE ~ 'https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,255}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)'
    OR TRUE -- TODO: Fix this bug?
);


/* 
  _        _     _           
 | |      | |   | |          
 | |_ __ _| |__ | | ___  ___ 
 | __/ _` | '_ \| |/ _ \/ __|
 | || (_| | |_) | |  __/\__ \
  \__\__,_|_.__/|_|\___||___/
 */

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
    customer_id uuid4 default generate_uuid4(),
    account_type varchar(15) not null,
    primary key (customer_id),
    foreign key (account_type) references AccountType(account_type) on update cascade
);

-- Information about each logged in user
CREATE TABLE UserInformation (
    customer_id uuid4,
    email valid_email not null,
    first_name char(255) not null,
    last_name varchar(255) not null,
    addr_line1 varchar(255) not null,
    addr_line2 varchar(255) not null,
    city varchar(127) not null,
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
    customer_id uuid4,
    phone_number valid_phone,
    primary key (customer_id, phone_number),
    foreign key (customer_id) references UserInformation(customer_id)
);

-- Session table
CREATE TABLE Session (
    session_id uuid4 default generate_uuid4(),
    customer_id uuid4 not null,
    created_time timestamp not null default now(),
    updated_time timestamp default now(),
    expire_date timestamp not null,
    primary key (session_id),
    foreign key (customer_id) references Customer(customer_id)
);

-- Credential table
CREATE TABLE AccountCredential (
    customer_id uuid4,
    password char(60) not null,
    primary key (customer_id),
    foreign key (customer_id) references UserInformation(customer_id)
);

-- Categories
CREATE TABLE Category (
    category_id uuid4 default generate_uuid4(),
    title varchar(255),
    parent_id uuid4,
    primary key (category_id),
    foreign key (parent_id) references Category(category_id)
);

-- Category Relations for suggestions
CREATE TABLE CategorySuggestion (
    category_id uuid4,
    suggestion_category_id uuid4,
    primary key (category_id, suggestion_category_id),
    foreign key (category_id) references Category(category_id),
    foreign key (suggestion_category_id) references Category(category_id)
);

-- Products
CREATE TABLE Product (
    product_id uuid4 default generate_uuid4(),
    title varchar(255) not null,
    description text not null,
    weight_kilos numeric(7, 2) check(is_positive(weight_kilos)),
    brand varchar(255),
    primary key (product_id)
);

-- Categories that products belong to
CREATE TABLE ProductCategory (
    category_id uuid4,
    product_id uuid4,
    primary key (category_id, product_id),
    foreign key (category_id) references Category(category_id),
    foreign key (product_id) references Product(product_id)
);

-- Images of a product
CREATE TABLE ProductImage (
    image_id uuid4 default generate_uuid4(),
    product_id uuid4,
    image_url URL not null,
    primary key (image_id),
    foreign key (product_id) references Product(product_id)
);

-- Tags
CREATE TABLE Tag (
    tag_id uuid4 default generate_uuid4(),
    tag varchar(255) not null,
    primary key (tag_id)
);

-- Tags of a product
CREATE TABLE ProductTag (
    product_id uuid4,
    tag_id uuid4,
    primary key (product_id, tag_id),
    foreign key (product_id) references Product(product_id),
    foreign key (tag_id) references Tag(tag_id)
);

-- Attributes common to a product
CREATE TABLE ProductAttribute (
    product_id uuid4,
    attribute_name char(31) not null,
    attribute_value varchar(255) not null,
    primary key (product_id, attribute_name),
    foreign key (product_id) references Product(product_id)
);

-- Variants
CREATE TABLE Variant (
    variant_id uuid4 default generate_uuid4(),
    product_id uuid4 not null,
    sku_id varchar(127),
    quantity int not null check(is_positive(quantity)),
    title varchar(255) not null,
    listed_price money_unit not null,
    selling_price money_unit not null,
    primary key (variant_id),
    foreign key (product_id) references Product(product_id),
    unique(sku_id)
);

-- Attributes common to a variant
CREATE TABLE VariantAttribute (
    variant_id uuid4,
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
    customer_id uuid4,
    variant_id uuid4,
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
    order_id uuid4 default generate_uuid4(),
    customer_id uuid4 not null,
    order_status varchar(15) not null,
    order_date timestamp,
    primary key (order_id),
    foreign key (order_status) references OrderStatus(order_status),
    foreign key (customer_id) references Customer(customer_id)
);

-- items in order
CREATE TABLE OrderItem (
    variant_id uuid4,
    order_id uuid4,
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
    order_id uuid4,
    payment_method varchar(15) not null,
    payment_status varchar(15) not null,
    payment_date timestamp,
    payment_amount money_unit,
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
    order_id uuid4,
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
    order_id uuid4,
    first_name varchar(255) not null,
    last_name varchar(255) not null,
    email valid_email not null,
    phone_number valid_phone not null,
    primary key (order_id),
    foreign key (order_id) references OrderData(order_id)
);


/*
  _        _                           
 | |      (_)                          
 | |_ _ __ _  __ _  __ _  ___ _ __ ___ 
 | __| '__| |/ _` |/ _` |/ _ \ '__/ __|
 | |_| |  | | (_| | (_| |  __/ |  \__ \
  \__|_|  |_|\__, |\__, |\___|_|  |___/
              __/ | __/ |              
             |___/ |___/               
*/

/* Adding to all parent categories on new product category addition */

-- Procedure to add all parent categories to a product (category_id, product_id)
CREATE OR REPLACE PROCEDURE addProductToCategories(UUID4, UUID4)
LANGUAGE plpgsql    
AS $$
DECLARE
       var_parent_id uuid4;
BEGIN
    -- ignore if category_id is null
    if $1 is null then return;
    end if;
    -- get parent_id of the category
    select parent_id into var_parent_id from Category where category_id=$1;
	-- ignore if parent_id is null
	if var_parent_id is null then return;
	end if;
	-- add product to parent category as well
    insert into ProductCategory values (var_parent_id, $2);
END;
$$;

-- Trigger afterProductCategoryInsert statements
CREATE OR REPLACE FUNCTION afterProductCategoryInsert()
RETURNS TRIGGER AS $$
BEGIN
    raise notice 'Trigger on Category % (Adding to parent category)', NEW.category_id;
    call addProductToCategories(NEW.category_id, NEW.product_id);
RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to add product to parent categories as well
CREATE TRIGGER afterProductCategoryInsertTrigger
AFTER INSERT
ON ProductCategory 
FOR EACH ROW EXECUTE PROCEDURE afterProductCategoryInsert();


/*
                               _                     
                              | |                    
  _ __  _ __ ___   ___ ___  __| |_   _ _ __ ___  ___ 
 | '_ \| '__/ _ \ / __/ _ \/ _` | | | | '__/ _ \/ __|
 | |_) | | | (_) | (_|  __/ (_| | |_| | | |  __/\__ \
 | .__/|_|  \___/ \___\___|\__,_|\__,_|_|  \___||___/
 | |                                                 
 |_|                                                 
*/

-- Procedure to a tag to a product (product_id, tag)
CREATE OR REPLACE PROCEDURE addTagToCategory(UUID4, VARCHAR(255))
LANGUAGE plpgsql
AS $$
DECLARE
       var_tag_id uuid4;
BEGIN
    -- get tag_id of the given tag
    select tag_id into var_tag_id from Tag where tag=$2;
    -- if tag id is null add it
    if var_tag_id is null then
        raise notice 'Creating the tag % because it did not exist', $2;
        var_tag_id := generate_uuid4();
        insert into Tag values (var_tag_id, $2);
    end if;
    insert into ProductTag values ($1, var_tag_id);
END;
$$;

-- Procedure to add a product (title, description, weight, brand, 
--  default_variant_title, default_variant_quantity, default_variant_sku_id, 
--  default_variant_listed_price, default_variant_selling_price,
--  default_image_url, default_leaf_category_id)
CREATE OR REPLACE PROCEDURE addProduct(
    VARCHAR(255), TEXT, NUMERIC(7, 2), VARCHAR(255),
    VARCHAR(255), INT, VARCHAR(127),
    MONEY_UNIT, MONEY_UNIT,
    URL, UUID4
) 
LANGUAGE plpgsql
AS $$
DECLARE
       var_product_id uuid4;
       var_default_image_id uuid4;
BEGIN
    -- set default_variant_selling_price as same as default_variant_listed_price if null
    if $9 is null then $9 := $8;
    end if;
    -- add rows
    var_product_id := generate_uuid4();
    var_default_image_id := generate_uuid4();
    insert into Product values (var_product_id, $1, $2, $3, $4);
    insert into ProductImage values (var_default_image_id, var_product_id, $10);
    insert into Variant values (default, var_product_id, $7, $6, $5, $8, $9);
    insert into ProductCategory values ($11, var_product_id);
    raise notice 'Added product with id %', var_product_id;
END;
$$;


/*
  _           _                    
 (_)         | |                   
  _ _ __   __| | _____  _____  ___ 
 | | '_ \ / _` |/ _ \ \/ / _ \/ __|
 | | | | | (_| |  __/>  <  __/\__ \
 |_|_| |_|\__,_|\___/_/\_\___||___/
*/

CREATE INDEX ON ProductImage(product_id);