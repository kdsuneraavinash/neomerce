DROP TRIGGER IF EXISTS afterProductCategoryInsertTrigger ON ProductCategory;
DROP PROCEDURE IF EXISTS placeOrder;
DROP PROCEDURE IF EXISTS addVisitedRecord;
DROP PROCEDURE IF EXISTS addTagToCategory;
DROP PROCEDURE IF EXISTS addProduct;
DROP PROCEDURE IF EXISTS assignSession;
DROP PROCEDURE IF EXISTS createUser;
DROP PROCEDURE IF EXISTS assignCustomerId;
DROP PROCEDURE IF EXISTS changeCartItemQuantity;
DROP PROCEDURE IF EXISTS transferCartItem;
DROP PROCEDURE IF EXISTS addItemToCart;
DROP PROCEDURE IF EXISTS removeCartItem;
DROP TABLE IF EXISTS GuestInfomation cascade;
DROP TABLE IF EXISTS Delivery cascade;
DROP TABLE IF EXISTS DispatchMethod cascade;
DROP TABLE IF EXISTS DeliveryStatus cascade;
DROP TABLE IF EXISTS Payment cascade;
DROP TABLE IF EXISTS PaymentStatus cascade;
DROP TABLE IF EXISTS PaymentMethod cascade;
DROP TABLE IF EXISTS OrderItem cascade;
DROP TABLE IF EXISTS OrderData cascade;
DROP TABLE IF EXISTS CartItem cascade;
DROP TABLE IF EXISTS VariantAttribute cascade;
DROP TABLE IF EXISTS VisitedProduct cascade;
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
DROP TABLE IF EXISTS Pickup cascade;
DROP TABLE IF EXISTS PickupStatus cascade;
DROP DOMAIN IF EXISTS MONEY_UNIT cascade;
DROP DOMAIN IF EXISTS VALID_EMAIL cascade;
DROP DOMAIN IF EXISTS VALID_PHONE cascade;
DROP DOMAIN IF EXISTS UUID4 cascade;
DROP DOMAIN IF EXISTS SESSION_UUID cascade;
DROP DOMAIN IF EXISTS URL cascade;
DROP VIEW IF EXISTS ProductMinPricesView cascade;
DROP VIEW IF EXISTS ProductMainImageView cascade;


/*
      _                       _           
     | |                     (_)          
   __| | ___  _ __ ___   __ _ _ _ __  ___ 
  / _` |/ _ \| '_ ` _ \ / _` | | '_ \/ __|
 | (_| | (_) | | | | | | (_| | | | | \__ \
  \__,_|\___/|_| |_| |_|\__,_|_|_| |_|___/
*/

CREATE DOMAIN MONEY_UNIT AS NUMERIC(12, 2) CHECK(is_positive(VALUE));
CREATE DOMAIN VALID_EMAIL AS VARCHAR(127);
CREATE DOMAIN VALID_PHONE AS CHAR(15);
CREATE DOMAIN UUID4 AS CHAR(36) CHECK(
    VALUE ~ '[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}'
);
CREATE DOMAIN SESSION_UUID AS CHAR(32);
CREATE DOMAIN URL AS VARCHAR(1023);



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


-- Function to check for remaining stock of a certain variant.
-- Used for the checkAvailability procedure. (variant_id, quantity)
CREATE OR REPLACE FUNCTION checkVariant(UUID4, INT) RETURNS boolean AS
$$
DECLARE
inventory_count int := (select quantity from variant where variant_id=$1);
product_name varchar(255) := (select product.title from product, variant 
    where variant.product_id=product.product_id and variant.variant_id = $1);
BEGIN
	if inventory_count < $2 then 
        RAISE Exception '% out of stock. Only % items available in the stocks',product_name,inventory_count;
	else
	    return true;
	end if;
END;
$$ LANGUAGE PLpgSQL;


-- Function to reduce stock of a variant. Called inside placeOrder procedure.(variant_id, new_quantity)
CREATE OR REPLACE FUNCTION reduceStock(UUID4, INT) RETURNS boolean AS
$$
DECLARE
existing_quantity int := (SELECT quantity from variant where variant_id = $1);
new_quantity int;
BEGIN
    new_quantity := existing_quantity - $2;
	UPDATE variant SET quantity = new_quantity where variant_id = $1;
	return true;
END;
$$ LANGUAGE PLpgSQL;


-- Function to add order items into the orderitem table. Called inside placeOrder procedure.
--                                  (variant_id, order_id, quantity)
CREATE OR REPLACE FUNCTION addOrderItem(UUID4, UUID4, INT) RETURNS boolean AS
$$
DECLARE
orderitem_id uuid4 := generate_uuid4();
BEGIN
	INSERT INTO orderitem values (orderitem_id, $1, $2, $3);
	return true;
END;
$$ LANGUAGE PLpgSQL;



-- Function to check user priviledges to view order history
CREATE OR REPLACE FUNCTION checkOrderHistoryPriviledge(SESSION_UUID,UUID4) RETURNS boolean AS
$$
DECLARE
customer_id1 uuid4 := (select customer_id from session where session_id=$1);
customer_id2 uuid4 := (select customer_id from orderdata where order_id = $2); 
BEGIN
	if customer_id1 = customer_id2 then 
        return true;
	else
	    return false;
	end if;
END;
$$ LANGUAGE PLpgSQL;



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
    delivery_charge money_unit not null,
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
    deleted boolean default false,
    primary key (customer_id),
    foreign key (account_type) references AccountType(account_type) on update cascade
);

-- Information about each logged in user
CREATE TABLE UserInformation (
    customer_id uuid4,
    email valid_email not null,
    first_name varchar(255) not null,
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
    session_id session_uuid,
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
    added_date timestamp not null default NOW(),
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

-- Products Visited by a Customer
CREATE TABLE VisitedProduct (
    entry_id uuid4 default generate_uuid4(),
    product_id uuid4,
    customer_id uuid4,
    visited_date timestamp not null default NOW(),
    foreign key (product_id) references Product(product_id),
    foreign key (customer_id) references Customer(customer_id)
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
    cart_item_id uuid4 default generate_uuid4(),
    customer_id uuid4 not null,
    variant_id uuid4 not null,
    cart_item_status varchar(15) not null,
    quantity int not null check(is_positive(quantity)),
    added_time timestamp not null default now(),
    primary key (cart_item_id),
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


-- Dispatch Method: HomeDelivery/StorePickup (ENUM)
CREATE TABLE DispatchMethod (
    dispatch_method varchar(15),
    description varchar(127),
    primary key (dispatch_method)
);

-- Orders
CREATE TABLE OrderData (
    order_id uuid4 default generate_uuid4(),
    customer_id uuid4 not null,
    order_status varchar(15) not null,
    dispatch_method varchar(15) not null,
    order_date timestamp not null,
    primary key (order_id),
    foreign key (dispatch_method) references DispatchMethod(dispatch_method) on update cascade,
    foreign key (order_status) references OrderStatus(order_status),
    foreign key (customer_id) references Customer(customer_id)
);

-- items in order
CREATE TABLE OrderItem (
    orderitem_id uuid4 default generate_uuid4(),
    variant_id uuid4,
    order_id uuid4,
    quantity int not null check(is_positive(quantity)),
    primary key (orderitem_id),
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

-- Delivery Information
CREATE TABLE Delivery (
    order_id uuid4,
    delivery_status varchar(15) not null,
    addr_line1 varchar(255),
    addr_line2 varchar(255),
    city varchar(127),
    postcode varchar(31),
    delivered_date timestamp,
    primary key (order_id),
    foreign key (order_id) references OrderData(order_id),
    foreign key (delivery_status) references DeliveryStatus(delivery_status) on update cascade,
    foreign key (city) references City(city) on update cascade
);

--Pick up status
CREATE TABLE PickupStatus (
    pickup_status varchar(15),
    description varchar(127),
    primary key (pickup_status)
);


-- Pick up details
CREATE TABLE Pickup (
    order_id uuid4,
    pickup_status varchar(15) not null,
    pickedup_date timestamp,
    primary key (order_id),
    foreign key (order_id) references OrderData(order_id),
    foreign key (pickup_status) references PickupStatus(pickup_status) on update cascade
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

-- Procedure to add a product (
--  product_id (if null generates new), cariant_id (if null generates new),
--  title, description, weight, brand, 
--  default_variant_title, default_variant_quantity, default_variant_sku_id, 
--  default_variant_listed_price, default_variant_selling_price,
--  default_image_url, default_leaf_category_id)
CREATE OR REPLACE PROCEDURE addProduct(
    UUID4, UUID4,
    VARCHAR(255), TEXT, NUMERIC(7, 2), VARCHAR(255),
    VARCHAR(255), INT, VARCHAR(127),
    MONEY_UNIT, MONEY_UNIT,
    URL, UUID4
) 
LANGUAGE plpgsql
AS $$
DECLARE
       var_default_image_id uuid4;
BEGIN
    -- set default_variant_selling_price as same as default_variant_listed_price if null
    if $11 is null then $11 := $10;
    end if;

    -- set product_id
    if $1 is null then $1 := generate_uuid4();
    end if;

    if $2 is null then $2 := generate_uuid4();
    end if;

    -- add rows
    var_default_image_id := generate_uuid4();
    insert into Product values ($1, $3, $4, $5, $6);
    insert into ProductImage values (var_default_image_id, $1, $12);
    insert into Variant values ($2, $1, $9, $8, $7, $10, $11);
    insert into ProductCategory values ($13, $1);
    raise notice 'Added product with id %', $1;
END;
$$;

-- Procedure to assign a session to a user (session_id)
CREATE OR REPLACE PROCEDURE assignSession(SESSION_UUID)
LANGUAGE plpgsql    
AS $$
DECLARE
customer_id uuid4 := (SELECT customer_id from session where session_id=$1);
BEGIN
    if customer_id is null then 
        customer_id := generate_uuid4();
        INSERT INTO customer values (customer_id,'guest'); 
        -- inserting to session table, change session duration here
        INSERT INTO session values ($1, customer_id, NOW(), NOW(), NOW() + interval '1 day'); 
    end if;
END;
$$;

-- Procedure to create a user (session_id, email, first_name, last_name, addr_line1,
--   addr_line2, city, post_code, dob, last_login)
CREATE OR REPLACE PROCEDURE createUser(SESSION_UUID, VARCHAR(255), VARCHAR(255), VARCHAR(255),
										VARCHAR(255), VARCHAR(255), VARCHAR(127), VARCHAR(31),
									   TIMESTAMP, CHAR(60))
LANGUAGE plpgsql    
AS $$
DECLARE
customer_id uuid4 := (select customer_id from session where session_id=$1);
var_existing_email varchar(255) := (SELECT email from userinformation where email = $2);
var_city int := (SELECT count(*) from city where city = $7);
BEGIN
    if (var_city = 0) then
        RAISE EXCEPTION 'Unknown city %. Please select a valid city.', $7;
    end if;
    if (var_existing_email is null) then
        INSERT INTO userinformation values (customer_id, $2, $3, $4, $5, $6, $7, $8, $9, NOW()); 
        INSERT INTO accountcredential values (customer_id, $10); 
        UPDATE customer SET account_type = 'user' WHERE customer_id = customer_id;
    else
        RAISE EXCEPTION 'Email % is already registered', $2;
    end if;
END;
$$;

-- Procedure to assign a customer id for a logged in session (session_id, email)
CREATE OR REPLACE PROCEDURE assignCustomerId(SESSION_UUID, VARCHAR(255))
LANGUAGE plpgsql    
AS $$
DECLARE
new_id uuid4 := (select customer_id from userinformation where email=$2);
old_id uuid4 := (select customer_id from session where session_id = $1);
old_account_type varchar(15) := (select account_type from customer where customer_id = old_id);
cart_items int := (select count(*) from cartitem where cart_item_status = 'added' and customer_id = old_id);
BEGIN
	UPDATE Session SET customer_id = new_id where session_id = $1;
	UPDATE Customer SET deleted = true where customer_id = old_id;
    if (old_account_type = 'guest' and cart_items > 0) then
        -- set old items to transferred and add new items to cart
        UPDATE CartItem SET cart_item_status = 'transferred' where customer_id = new_id and cart_item_status = 'added';
        UPDATE CartItem SET customer_id = new_id where customer_id = old_id and cart_item_status = 'added';
    end if;
END;
$$;

-- Procedure to add item to cart (session_id, variant_id, quantity)
CREATE OR REPLACE PROCEDURE addItemToCart(SESSION_UUID, UUID4, INT)
LANGUAGE plpgsql
AS $$
DECLARE
var_customer_id uuid4 := (select customer_id from session where session_id = $1);
var_same_item_qty int := (select sum(quantity) from CartItem where customer_id = var_customer_id and variant_id = $2 and cart_item_status = 'added');
var_max_quantity int := (select quantity from variant where variant_id = $2);
BEGIN
    if (var_same_item_qty is null) then
        var_same_item_qty := 0;
    end if;
    if (var_max_quantity < ($3 + var_same_item_qty)) then
        RAISE EXCEPTION 'Your item quantity exceeds stock quantity'; 
    end if;

    if (var_same_item_qty > 0) then
        -- previous items exists, have to merge
        UPDATE CartItem SET cart_item_status = 'merged' WHERE customer_id = var_customer_id AND variant_id = $2 AND cart_item_status = 'added';
    end if;

    if ($3 > 0) then
        -- quantity is valid
        INSERT INTO CartItem VALUES(default, var_customer_id, $2, 'added', $3 + var_same_item_qty);
    else
        RAISE EXCEPTION 'Quantity must be bigger than zero';
    end if;
END;
$$;

-- Procedure to remove item from cart (session_id, cart_item_id)
CREATE OR REPLACE PROCEDURE removeCartItem(SESSION_UUID, UUID4)
LANGUAGE plpgsql    
AS $$
DECLARE
var_customer_id uuid4 := (select customer_id from session where session_id = $1);
BEGIN
    UPDATE CartItem SET cart_item_status = 'removed' WHERE cart_item_id = $2 and customer_id = var_customer_id and 
        (cart_item_status = 'added' or cart_item_status = 'transferred') ;
END;
$$;

-- Procedure to remove item from cart (session_id, cart_item_id, new_quantity)
CREATE OR REPLACE PROCEDURE changeCartItemQuantity(SESSION_UUID, UUID4, INT)
LANGUAGE plpgsql    
AS $$
DECLARE
var_customer_id uuid4 := (select customer_id from session where session_id = $1);
var_max_quantity int := (select variant.quantity from variant join cartitem using(variant_id) where cart_item_id = $2);
BEGIN
    if ($3 = 0) then
        CALL removeCartItem($1, $2);
    else 
		if (var_max_quantity < $3) then
        	RAISE EXCEPTION 'Your item quantity exceeds stock quantity which is %', var_max_quantity; 
    	else
			UPDATE CartItem SET quantity = $3 WHERE cart_item_id = $2 and customer_id = var_customer_id and 
				(cart_item_status = 'added' or cart_item_status = 'transferred') ;
		end if;
    end if;
END;
$$;

-- Procedure to remove item from transferred state and add to added state (session_id, cart_item_id)
CREATE OR REPLACE PROCEDURE transferCartItem(SESSION_UUID, UUID4)
LANGUAGE plpgsql    
AS $$
DECLARE
var_customer_id uuid4 := (select customer_id from session where session_id = $1);
var_variant_id uuid4;
var_qty int;
var_current_state varchar(15);
BEGIN
    SELECT variant_id, quantity, cart_item_status into var_variant_id, var_qty, var_current_state
        from CartItem WHERE cart_item_id = $2 and customer_id = var_customer_id;

    if (var_current_state != 'transferred') then
        RAISE EXCEPTION 'Invalid transfer state';
    end if;

    CALL removeCartItem($1, $2);
    CALL addItemToCart($1, var_variant_id, var_qty);
END;
$$;



-- Procedure to check availability of items in a cart (session_id)
CREATE OR REPLACE PROCEDURE checkAvailability(SESSION_UUID)
LANGUAGE plpgsql    
AS $$
DECLARE
customer_id_ uuid4 := (select customer_id from session where session_id=$1);
BEGIN
	PERFORM variant_id,quantity 
        from cartitem , LATERAL checkVariant(variant_id,quantity) 
        where customer_id = customer_id_ and cart_item_status='added'; 
END;
$$;

-- Procedure to place an order(session_id, first_name, last_name, email, 
--                                phone_number, delivery_method, addr_line1, addr_line2, city, post_code,
--                                payment_method, order_id, payment_amount)
CREATE OR REPLACE PROCEDURE placeOrder(SESSION_UUID, VARCHAR(255), VARCHAR(255), VARCHAR(127), CHAR(15),
									   VARCHAR(15), VARCHAR(255), VARCHAR(255), VARCHAR(127), VARCHAR(31),
                                       VARCHAR(15), UUID4, MONEY_UNIT)
LANGUAGE plpgsql    
AS $$
DECLARE
customer_id_ uuid4 := (select customer_id from session where session_id=$1);
customer_type varchar(15) := (select account_type from customer where customer_id=customer_id_);
payment_status varchar(15);
BEGIN

	if $11 = 'card' then
	    payment_status := 'payed';
	else
	    payment_status := 'not_payed';
	end if;

    if $6 = 'store_pickup' then
        INSERT into orderdata values ($12,customer_id_, 'ordered','store_pickup',NOW());
    else
        INSERT into orderdata values ($12,customer_id_, 'ordered','home_delivery',NOW());
	end if;

	PERFORM variant_id, quantity from ProductVariantView, LATERAL reduceStock(variant_id, quantity) where customer_id = customer_id_;
	PERFORM variant_id, quantity from ProductVariantView, LATERAL addOrderItem(variant_id, $12, quantity) where customer_id = customer_id_;
	UPDATE cartitem SET cart_item_status = 'ordered' where customer_id = customer_id_ and cart_item_status = 'added';
	
	if $6 = 'store_pickup' then
	    INSERT INTO pickup values ($12,'pending pick up');
	else
	    INSERT INTO delivery values ($12,'ongoing', $7, $8, $9, $10, NOW());
	end if;
	INSERT INTO payment values ($12, $11, payment_status, NOW(), $13);
	If customer_type = 'guest' then
	    INSERT INTO guestinfomation values ($12, $2, $3, $4, $5);
	End if;								   
END;
$$;

-- Procedure to add a record to denote that user viewed item (session_id, product_id)
CREATE OR REPLACE PROCEDURE addVisitedRecord(SESSION_UUID, UUID4)
LANGUAGE plpgsql    
AS $$
DECLARE
var_customer_id uuid4 := (select customer_id from session where session_id=$1);
BEGIN
	INSERT INTO VisitedProduct values (default, $2, var_customer_id); 
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
CREATE INDEX ON Variant(product_id);
CREATE INDEX ON Product((lower(title)));
CREATE INDEX ON CartItem(variant_id, customer_id);
CREATE INDEX ON City((lower(city)));

/*
        _                   
       (_)                  
 __   ___  _____      _____ 
 \ \ / / |/ _ \ \ /\ / / __|
  \ V /| |  __/\ V  V /\__ \
   \_/ |_|\___| \_/\_/ |___/ 
*/

CREATE VIEW ProductMinPricesView AS
    SELECT product_id, min(selling_price) as min_selling_price
    FROM Variant
    GROUP BY product_id;

CREATE VIEW ProductMainImageView AS
    SELECT DISTINCT ON (product_id) product_id, image_url
    FROM ProductImage;

CREATE VIEW ProductBasicView AS
    SELECT product_id, title, min_selling_price, image_url, added_date
    FROM Product NATURAL JOIN ProductMinPricesView NATURAL JOIN ProductMainImageView;


CREATE OR REPLACE VIEW ProductVariantView AS
    SELECT c.customer_id,c.variant_id,v.product_id,c.quantity,v.title variant_title,v.selling_price,p.title product_title,p.brand FROM
    cartitem as c 
    LEFT JOIN variant as v ON c.variant_id = v.variant_id
    LEFT JOIN product as p ON v.product_id = p.product_id where c.cart_item_status = 'added';


CREATE OR REPLACE VIEW UserDeliveryView AS
    SELECT u.customer_id, u.email, u.first_name, u.last_name, u.addr_line1,
        u.addr_line2, u.city, u.postcode, t.phone_number, ct.delivery_days, ct.delivery_charge 
    FROM userinformation as u 
        LEFT JOIN telephonenumber as t ON u.customer_id = t.customer_id
        LEFT JOIN city as c ON u.city = c.city
        LEFT JOIN citytype as ct ON ct.city_type=c.city_type;    
