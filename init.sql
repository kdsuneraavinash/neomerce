DROP TRIGGER IF EXISTS afterProductCategoryInsertTrigger ON ProductCategory;
DROP TRIGGER IF EXISTS afterProductInsertTrigger ON Product;
DROP TRIGGER IF EXISTS afterVariantInsertTrigger ON Variant;
DROP PROCEDURE IF EXISTS addVariant;
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
DROP MATERIALIZED VIEW IF EXISTS ProductBasicView cascade;



/*
      _                       _           
     | |                     (_)          
   __| | ___  _ __ ___   __ _ _ _ __  ___ 
  / _` |/ _ \| '_ ` _ \ / _` | | '_ \/ __|
 | (_| | (_) | | | | | | (_| | | | | \__ \
  \__,_|\___/|_| |_| |_|\__,_|_|_| |_|___/
*/

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


-- (DOMAIN) Heirachical Dependency
CREATE DOMAIN MONEY_UNIT AS NUMERIC(12, 2) CHECK(is_positive(VALUE));


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
account_type varchar(15) := (select account_type from session join customer using(customer_id) where session_id=$1);
customer_id2 uuid4 := (select customer_id from orderdata where order_id = $2); 
BEGIN
    if account_type = 'admin' then
        return true;
	end if; 
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


/* Refreshing Materialized Views */

-- Trigger refreshing materialized views statements
CREATE OR REPLACE FUNCTION afterProductInsertRefreshViews()
RETURNS TRIGGER AS $$
BEGIN
    raise notice 'Refreshing Materialized View';
    REFRESH MATERIALIZED VIEW CONCURRENTLY ProductBasicView;
RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Trigger refresh materialized views
CREATE TRIGGER afterProductInsertTrigger
AFTER INSERT OR UPDATE
ON Product
FOR EACH ROW EXECUTE PROCEDURE afterProductInsertRefreshViews();

CREATE TRIGGER afterVariantInsertTrigger
AFTER INSERT OR UPDATE
ON Variant
FOR EACH ROW EXECUTE PROCEDURE afterProductInsertRefreshViews();

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

-- Procedure to add a variant (productId,variantTitle,variantQuantity,
-- variantSkuId,variantListedPrice,revariantSellingPrice)
CREATE OR REPLACE PROCEDURE addVariant(
    UUID4,
   VARCHAR(255), INT, VARCHAR(127),
    MONEY_UNIT, MONEY_UNIT
) 
LANGUAGE plpgsql
AS $$
DECLARE
       var_variant_id uuid4;
BEGIN
    var_variant_id := generate_uuid4();
    insert into Variant values (default, $1, $4, $3, $2, $5, $6);
    raise notice 'Added variant with id %', var_variant_id;
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
									   TIMESTAMP, CHAR(60),VALID_PHONE)
LANGUAGE plpgsql    
AS $$
DECLARE
var_customer_id uuid4 := (select customer_id from session where session_id=$1);
var_existing_email varchar(255) := (SELECT email from userinformation where email = $2);
var_city int := (SELECT count(*) from city where city = $7);
BEGIN
    if (var_city = 0) then
        RAISE EXCEPTION 'Unknown city %. Please select a valid city.', $7;
    end if;
    if (var_existing_email is null) then
        INSERT INTO userinformation values (var_customer_id, $2, $3, $4, $5, $6, $7, $8, $9, NOW()); 
        INSERT INTO accountcredential values (var_customer_id, $10);
        INSERT INTO telephonenumber values (var_customer_id,$11); 
        UPDATE customer SET account_type = 'user' WHERE customer_id = var_customer_id;
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

-- Procedure to make a user as admin (emai)
CREATE OR REPLACE PROCEDURE makeAdmin(VALID_EMAIL)
LANGUAGE plpgsql    
AS $$
DECLARE
var_customer_id uuid4 := (select customer_id from customer join userinformation using(customer_id) where email=$1);
BEGIN
	UPDATE customer set account_type = 'admin' where customer_id=var_customer_id;
     raise notice 'Customer % with id % upgraded to ADMIN', $1, var_customer_id;
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

CREATE INDEX product_image_id ON ProductImage(product_id);
CREATE INDEX variant_product_id ON Variant(product_id);
CREATE INDEX product_title ON Product((lower(title)));
CREATE INDEX cart_items ON CartItem(variant_id, customer_id);
CREATE INDEX cities ON City((lower(city)));

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
    FROM ProductImage
	ORDER BY product_id;

-- Materialized Views
CREATE MATERIALIZED VIEW ProductBasicView AS
    SELECT product_id, title, min_selling_price, image_url, added_date
    FROM Product NATURAL JOIN ProductMinPricesView NATURAL JOIN ProductMainImageView;
CREATE UNIQUE INDEX ON ProductBasicView(product_id);

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

---------------------------------- SESSION TABLE SCHEMA -----------------------------------

CREATE TABLE session_data (
    sid varchar NOT NULL,
    sess json NOT NULL,
    expire timestamp(6) NOT NULL
)
WITH (OIDS=FALSE);

ALTER TABLE session_data ADD CONSTRAINT session_data_pkey PRIMARY KEY (sid) NOT DEFERRABLE INITIALLY IMMEDIATE;

CREATE INDEX IDX_session_expire ON session_data(expire);

---------------------------------- SCHEMA END ---------------------------------------------

delete from Category cascade;


insert into Category values('760aa25b-f984-4a3d-9c5d-d1313f49fe08', 'Electronics', null);
insert into Category values('b64542d4-328f-4670-adc9-1e9f6dc09219', 'Camera & Photo', '760aa25b-f984-4a3d-9c5d-d1313f49fe08');

insert into Category values('c7066d01-73ee-4023-a98c-70e5197d3356', 'Cell Phones & Accessories', '760aa25b-f984-4a3d-9c5d-d1313f49fe08');
insert into Category values('6238c143-4eac-4383-a348-33739390af81', 'Unlocked Cell Phones', 'c7066d01-73ee-4023-a98c-70e5197d3356');
insert into Category values('dfc64f40-2794-4eea-ace7-30a165a4619a', 'Mobile Broadband', 'c7066d01-73ee-4023-a98c-70e5197d3356');

insert into Category values('70017752-b56a-42af-b9f8-e298f65fd159', 'Computers & Accessories', '760aa25b-f984-4a3d-9c5d-d1313f49fe08');
insert into Category values('8760f5cb-beea-4380-8710-321a40eaa9d3', 'Computer Components', '70017752-b56a-42af-b9f8-e298f65fd159');
insert into Category values('824be22c-3aea-44d7-9a26-d8c4287a3283', 'Desktop Barebones', '8760f5cb-beea-4380-8710-321a40eaa9d3');
insert into Category values('b2e8eff4-3e64-4ef6-9705-1b2f106ba363', 'External Components', '8760f5cb-beea-4380-8710-321a40eaa9d3');
insert into Category values('69a02f7b-1586-431b-ba2f-08d36cf1eb93', 'Computers & Tablets', '70017752-b56a-42af-b9f8-e298f65fd159');
insert into Category values('c30b91cd-0e1c-458e-a816-a6d9a1ae9fbb', 'Laptops', '69a02f7b-1586-431b-ba2f-08d36cf1eb93');
insert into Category values('868abb7f-c889-418d-b87f-28c2b1c1441f', 'Tablets', '69a02f7b-1586-431b-ba2f-08d36cf1eb93');
insert into Category values('0894c507-4f90-450f-aac8-aec4e86203ee', 'Data Storage', '70017752-b56a-42af-b9f8-e298f65fd159');
insert into Category values('c7fc511d-8bf9-4dbd-a364-8a269844dc53', 'Monitors', '70017752-b56a-42af-b9f8-e298f65fd159');
insert into Category values('7f917bc5-de26-480b-9eaa-9ac39c6b5f35', 'Networking Products', '70017752-b56a-42af-b9f8-e298f65fd159');
insert into Category values('0fee9332-807d-4818-9bc9-9056b3557d1a', 'Servers', '70017752-b56a-42af-b9f8-e298f65fd159');

insert into Category values('24b84249-c629-4b84-991c-673c0bf73081', 'Headphones', '760aa25b-f984-4a3d-9c5d-d1313f49fe08');

insert into Category values('a09ef296-aaf7-4c88-8440-0d494b94e061', 'Television & Video', '760aa25b-f984-4a3d-9c5d-d1313f49fe08');
insert into Category values('0e82c1f2-89c3-44e3-9fe5-922b1f259296', 'DVD-VCR Combos', 'a09ef296-aaf7-4c88-8440-0d494b94e061');
insert into Category values('52426a68-76a5-4813-9943-b67f952d766b', 'HD DVD Players', 'a09ef296-aaf7-4c88-8440-0d494b94e061');
insert into Category values('3a9bce2a-624e-40a0-9fa5-25e7db99ceb9', 'Televisions', 'a09ef296-aaf7-4c88-8440-0d494b94e061');



insert into Category values('e802a9e5-ba12-4ba1-8bb3-007bff45caf6', 'Toys & Games', null);
insert into Category values('5a5c29a6-0ee5-4eac-8730-190b3364f908', 'Baby & Toddler Toys', 'e802a9e5-ba12-4ba1-8bb3-007bff45caf6');
insert into Category values('6f964b17-2d46-4c6a-a41a-f74e89eb81e3', 'Balls', '5a5c29a6-0ee5-4eac-8730-190b3364f908');
insert into Category values('876e82a1-99fa-40ca-bfa6-c687ace3cd1b', 'Spinning Tops', '5a5c29a6-0ee5-4eac-8730-190b3364f908');
insert into Category values('867a62d0-6acd-442f-ba33-dd0a0b149462', 'Bath Toys', '5a5c29a6-0ee5-4eac-8730-190b3364f908');

insert into Category values('6edf6490-5a59-4f29-96b0-d9f087fdba8a', 'Learning & Education', 'e802a9e5-ba12-4ba1-8bb3-007bff45caf6');
insert into Category values('e9273721-4744-4bf2-b210-bf63402c4eab', 'Flash Cards', '6edf6490-5a59-4f29-96b0-d9f087fdba8a');
insert into Category values('1339a83d-4176-49e1-8cb3-a703c247f211', 'Musical Instruments', '6edf6490-5a59-4f29-96b0-d9f087fdba8a');
insert into Category values('563617f8-dd6c-4a2f-baf8-445926244341', 'Reading & Writing', '6edf6490-5a59-4f29-96b0-d9f087fdba8a');

insert into Category values('48083624-045c-48d8-8b09-1b9baa46c266', 'Puzzles', 'e802a9e5-ba12-4ba1-8bb3-007bff45caf6');



insert into citytype values ('main', 'Main City', 5, 500);
insert into citytype values ('secondary', 'Secondary City', 7, 1000);

insert into accounttype values ('guest', 'Guest User');
insert into accounttype values ('user', 'Normal User');
insert into accounttype values ('admin', 'Administrator');

insert into cartitemstatus values ('added', 'Added to cart');
insert into cartitemstatus values ('removed', 'Removed from cart');
insert into cartitemstatus values ('ordered', 'Added to a order');
insert into cartitemstatus values ('merged', 'Cart items merged into a bigger cart item set');
insert into cartitemstatus values ('transferred', 'Cart items transferred from a guest account');

insert into orderstatus values ('ordered', 'Ordered');
insert into orderstatus values ('completed', 'Order completed');

insert into dispatchmethod values ('store_pickup', 'Pick up from the store');
insert into dispatchmethod values ('home_delivery', 'Deliver to the home');

insert into deliverystatus values ('ongoing', 'Delivery Ongoing');
insert into deliverystatus values ('delivered', 'Delivery Completed');
insert into deliverystatus values ('pending pick up','Pending user pick up');
insert into deliverystatus values ('picked up','User picked up');

insert into paymentmethod values ('card', 'Card payment');
insert into paymentmethod values ('cash', 'Cash on delivery');

insert into paymentstatus values ('payed', 'Payment done');
insert into paymentstatus values ('not_payed', 'Payment not completed');

insert into pickupstatus values ('pending pick up', 'The user has not picked up the order yet');
insert into pickupstatus values ('picked up', 'The user has picked up the order');



insert into city values ('Colombo 1', 'main');
insert into city values ('Colombo 10', 'main');
insert into city values ('Colombo 11', 'main');
insert into city values ('Colombo 12', 'main');
insert into city values ('Colombo 13', 'main');
insert into city values ('Colombo 14', 'main');
insert into city values ('Colombo 15', 'main');
insert into city values ('Colombo 2', 'main');
insert into city values ('Colombo 3', 'main');
insert into city values ('Colombo 4', 'main');
insert into city values ('Colombo 5', 'main');
insert into city values ('Colombo 6', 'main');
insert into city values ('Colombo 7', 'main');
insert into city values ('Colombo 8', 'main');
insert into city values ('Colombo 9', 'main');
insert into city values ('Kalutara South', 'main');
insert into city values ('Kalutara North', 'main');
insert into city values ('Trincomalee', 'main');

insert into city values ('Vavuniya', 'secondary');
insert into city values ('Horana', 'secondary');
insert into city values ('Panadura', 'secondary');
insert into city values ('Matugama', 'secondary');
insert into city values ('Bandaragama', 'secondary');
insert into city values ('Alutgama', 'secondary');
insert into city values ('Beruwala', 'secondary');
insert into city values ('Ingiriya', 'secondary');
insert into city values ('Wadduwa', 'secondary');
insert into city values ('Mullativu ', 'secondary');
insert into city values ('Matara', 'secondary');
insert into city values ('Akuressa', 'secondary');
insert into city values ('Weligama', 'secondary');
insert into city values ('Dikwella', 'secondary');
insert into city values ('Hakmana', 'secondary');
insert into city values ('Deniyaya', 'secondary');
insert into city values ('Kamburugamuwa', 'secondary');
insert into city values ('Kamburupitiya', 'secondary');
insert into city values ('Kekanadurra', 'secondary');
insert into city values ('Anuradhapura', 'secondary');
insert into city values ('Kekirawa', 'secondary');
insert into city values ('Tambuttegama', 'secondary');
insert into city values ('Medawachchiya', 'secondary');
insert into city values ('Eppawala', 'secondary');
insert into city values ('Galenbindunuwewa', 'secondary');
insert into city values ('Galnewa', 'secondary');
insert into city values ('Habarana', 'secondary');
insert into city values ('Mihintale', 'secondary');
insert into city values ('Nochchiyagama', 'secondary');
insert into city values ('Talawa', 'secondary');
insert into city values ('Kinniya', 'secondary');
insert into city values ('Galle', 'secondary');
insert into city values ('Ambalangoda', 'secondary');
insert into city values ('Elpitiya', 'secondary');
insert into city values ('Hikkaduwa', 'secondary');
insert into city values ('Baddegama', 'secondary');
insert into city values ('Ahangama', 'secondary');
insert into city values ('Batapola', 'secondary');
insert into city values ('Bentota', 'secondary');
insert into city values ('Karapitiya', 'secondary');
insert into city values ('Batticaloa', 'secondary');
insert into city values ('Matale', 'secondary');
insert into city values ('Dambulla', 'secondary');
insert into city values ('Galewela', 'secondary');
insert into city values ('Ukuwela', 'secondary');
insert into city values ('Rattota', 'secondary');
insert into city values ('Palapathwela', 'secondary');
insert into city values ('Sigiriya', 'secondary');
insert into city values ('Yatawatta', 'secondary');
insert into city values ('Moneragala', 'secondary');
insert into city values ('Buttala', 'secondary');
insert into city values ('Wellawaya', 'secondary');
insert into city values ('Bibile', 'secondary');
insert into city values ('Kataragama', 'secondary');
insert into city values ('Polonnaruwa', 'secondary');
insert into city values ('Hingurakgoda', 'secondary');
insert into city values ('Kaduruwela', 'secondary');
insert into city values ('Medirigiriya', 'secondary');
insert into city values ('Kilinochchi', 'secondary');
insert into city values ('Kandy', 'secondary');
insert into city values ('Katugastota', 'secondary');
insert into city values ('Gampola', 'secondary');
insert into city values ('Peradeniya', 'secondary');
insert into city values ('Kundasale', 'secondary');
insert into city values ('Akurana', 'secondary');
insert into city values ('Ampitiya', 'secondary');
insert into city values ('Digana', 'secondary');
insert into city values ('Galagedara', 'secondary');
insert into city values ('Gelioya', 'secondary');
insert into city values ('Kadugannawa', 'secondary');
insert into city values ('Madawala Bazaar', 'secondary');
insert into city values ('Nawalapitiya', 'secondary');
insert into city values ('Pilimatalawa', 'secondary');
insert into city values ('Wattegama', 'secondary');
insert into city values ('Ratnapura', 'secondary');
insert into city values ('Embilipitiya', 'secondary');
insert into city values ('Balangoda', 'secondary');
insert into city values ('Pelmadulla', 'secondary');
insert into city values ('Eheliyagoda', 'secondary');
insert into city values ('Kuruwita', 'secondary');
insert into city values ('Ampara', 'secondary');
insert into city values ('Akkarepattu', 'secondary');
insert into city values ('Kalmunai', 'secondary');
insert into city values ('Sainthamaruthu', 'secondary');
insert into city values ('Jaffna', 'secondary');
insert into city values ('Nallur', 'secondary');
insert into city values ('Chavakachcheri', 'secondary');
insert into city values ('Kurunegala', 'secondary');
insert into city values ('Kuliyapitiya', 'secondary');
insert into city values ('Narammala', 'secondary');
insert into city values ('Pannala', 'secondary');
insert into city values ('Mawathagama', 'secondary');
insert into city values ('Alawwa', 'secondary');
insert into city values ('Bingiriya', 'secondary');
insert into city values ('Galgamuwa', 'secondary');
insert into city values ('Giriulla', 'secondary');
insert into city values ('Hettipola', 'secondary');
insert into city values ('Ibbagamuwa', 'secondary');
insert into city values ('Nikaweratiya', 'secondary');
insert into city values ('Polgahawela', 'secondary');
insert into city values ('Wariyapola', 'secondary');
insert into city values ('Tangalla', 'secondary');
insert into city values ('Beliatta', 'secondary');
insert into city values ('Tissamaharama', 'secondary');
insert into city values ('Hambantota', 'secondary');
insert into city values ('Ambalantota', 'secondary');
insert into city values ('Nuwara Eliya', 'secondary');
insert into city values ('Hatton', 'secondary');
insert into city values ('Ginigathena', 'secondary');
insert into city values ('Madulla', 'secondary');
insert into city values ('Chilaw', 'secondary');
insert into city values ('Wennappuwa', 'secondary');
insert into city values ('Puttalam', 'secondary');
insert into city values ('Nattandiya', 'secondary');
insert into city values ('Marawila', 'secondary');
insert into city values ('Dankotuwa', 'secondary');
insert into city values ('Kegalle', 'secondary');
insert into city values ('Mawanella', 'secondary');
insert into city values ('Warakapola', 'secondary');
insert into city values ('Rambukkana', 'secondary');
insert into city values ('Ruwanwella', 'secondary');
insert into city values ('Dehiowita', 'secondary');
insert into city values ('Deraniyagala', 'secondary');
insert into city values ('Galigamuwa', 'secondary');
insert into city values ('Kitulgala', 'secondary');
insert into city values ('Yatiyantota', 'secondary');
insert into city values ('Badulla', 'secondary');
insert into city values ('Bandarawela', 'secondary');
insert into city values ('Welimada', 'secondary');
insert into city values ('Mahiyanganaya', 'secondary');
insert into city values ('Hali Ela', 'secondary');
insert into city values ('Diyatalawa', 'secondary');
insert into city values ('Ella', 'secondary');
insert into city values ('Haputale', 'secondary');
insert into city values ('Passara', 'secondary');
insert into city values ('Rajagiriya', 'secondary');
insert into city values ('Dehiwala', 'secondary');
insert into city values ('Nugegoda', 'secondary');
insert into city values ('Maharagama', 'secondary');
insert into city values ('Piliyandala', 'secondary');
insert into city values ('Angoda', 'secondary');
insert into city values ('Athurugiriya', 'secondary');
insert into city values ('Avissawella', 'secondary');
insert into city values ('Battaramulla', 'secondary');
insert into city values ('Boralesgamuwa', 'secondary');
insert into city values ('Hanwella', 'secondary');
insert into city values ('Homagama', 'secondary');
insert into city values ('Kaduwela', 'secondary');
insert into city values ('Kesbewa', 'secondary');
insert into city values ('Kohuwala', 'secondary');
insert into city values ('Kolonnawa', 'secondary');
insert into city values ('Kottawa', 'secondary');
insert into city values ('Kotte', 'secondary');
insert into city values ('Malabe', 'secondary');
insert into city values ('Moratuwa', 'secondary');
insert into city values ('Mount Lavinia', 'secondary');
insert into city values ('Nawala', 'secondary');
insert into city values ('Padukka', 'secondary');
insert into city values ('Pannipitiya', 'secondary');
insert into city values ('Ratmalana', 'secondary');
insert into city values ('Talawatugoda', 'secondary');
insert into city values ('Wellampitiya', 'secondary');
insert into city values ('Gampaha', 'secondary');
insert into city values ('Negombo', 'secondary');
insert into city values ('Kelaniya', 'secondary');
insert into city values ('Kadawatha', 'secondary');
insert into city values ('Ja-Ela', 'secondary');
insert into city values ('Delgoda', 'secondary');
insert into city values ('Divulapitiya', 'secondary');
insert into city values ('Ganemulla', 'secondary');
insert into city values ('Kandana', 'secondary');
insert into city values ('Katunayake', 'secondary');
insert into city values ('Kiribathgoda', 'secondary');
insert into city values ('Minuwangoda', 'secondary');
insert into city values ('Mirigama', 'secondary');
insert into city values ('Nittambuwa', 'secondary');
insert into city values ('Ragama', 'secondary');
insert into city values ('Veyangoda', 'secondary');
insert into city values ('Wattala', 'secondary');
insert into city values ('Mannar', 'secondary');





/**
21 Products
============

pg_dump --table product --data-only --column-inserts -U neomerce_app neomerce > data.sql
pg_dump --table productimage --data-only --column-inserts -U neomerce_app neomerce > data.sql
pg_dump --table variant --data-only --column-inserts -U neomerce_app neomerce > data.sql
pg_dump --table productcategory --data-only --column-inserts -U neomerce_app neomerce > data.sql
pg_dump --table tag --data-only --column-inserts -U neomerce_app neomerce > data.sql
pg_dump --table producttag --data-only --column-inserts -U neomerce_app neomerce > data.sql   
**/

INSERT INTO public.product (product_id, title, description, weight_kilos, brand, added_date) VALUES ('5f6aff49-c20b-456d-8938-dea885941365', 'Samsung 128GB 100MB/s (U3) MicroSDXC EVO Select Memory Card with Full-Size Adapter (MB-ME128GA/AM)', 'IDEAL FOR RECORDING 4K UHD VIDEO: Samsung MicroSD EVO is perfect for high-res photos, gaming, music, tablets, laptops, action cameras, DSLR''s, drones, smartphones (Galaxy S10, S10+, S10e, S9, S9+, Note9, S8, S8+, Note8, S7, S7 Edge, etc.), Android devices and more
ULTRA-FAST READ WRITE SPEEDS: Up to 100MB/s read and 90MB/s write speeds; UHS Speed Class U3 and Speed Class 10 (performance may vary based on host device, interface, usage conditions, and other factors)
BUILT TO LAST RELIABILITY: Shock proof memory card is also water proof, temperature proof, x-ray proof and magnetic proof
EXTENDED COMPATIBILITY: Includes full-size adapter for use in cameras, laptops and desktop computers
10-YEAR LIMITED WARRANTY: 10-year limited warranty does not extend to dashcam, CCTV, surveillance camera and other write-intensive uses; Warranty for SD adapter is limited to 1 year', 0.00, 'Samsung', '2019-12-31 21:56:18.212725');
INSERT INTO public.product (product_id, title, description, weight_kilos, brand, added_date) VALUES ('738426aa-35ea-4d96-b839-d0902d084672', 'Wyze Cam 1080p HD Indoor Wireless Smart Home Camera with Night Vision, 2-Way Audio, Works with Alexa & the Google Assistant, One Pack, White - WYZEC2', 'Live Stream from Anywhere in 1080p -1080p Full HD live streaming lets you see inside your home from anywhere in real time using your mobile device. While live streaming, use two-way audio to speak with your friends and family through the Wyze app.
Motion/Sound Recording with Free Cloud Storage - Wyze Cam can automatically record a 12-second video clip when motion or sound is detected and saves that video to the cloud for 14-days, for free. Mobile push notifications can be enabled so you’re only alerted when something is detected letting you stay on top of things without having to constantly monitor the app. Or, record continuously to a MicroSD card (sold separately) regardless of motion and sound. Compatible with 8GB, 16GB, or 32GB FAT32 MicroSD cards.
See in the dark - Night vision lets you see up to 30’ in absolute darkness using 4 infrared (IR) LEDs. Note: IR does not work through glass windows.
Voice Controlled? You got it! - Works with Alexa and Google Assistant (US only) so you can use your voice to see who’s at your front door, how your baby’s doing, or if your 3D printer has finished printing. Wyze Cam is only compatible with the 2. 4GHz WiFi network (does not support 5GHz Wi-Fi) and Apple (iOS) and Android mobile devices.
Share with those who care - One Wyze Cam can be shared with multiple family members so everyone can have access to its live stream and video recordings. Just have your family members download the Wyze app and invite them to your account. Camera sharing can also be easily removed.', 1.50, 'Wyze', '2019-12-31 22:02:21.602658');
INSERT INTO public.product (product_id, title, description, weight_kilos, brand, added_date) VALUES ('1f6c20e0-8af5-4ad6-ae98-026bc7741670', 'Nixplay Smart Digital Photo Frame 10.1 Inch - Share Moments Instantly via E-Mail or App', 'AMERICA’S NUMBER ONE SELLING FRAME with over 2 million units sold. Nixplay has been serving America’s families for over 10 years. A great gift for new parents, grandparents, newlyweds, college kids or families separated by distance
SHARE PHOTOS AND VIDEO PRIVATELY, SAFELY: Share images to your loved ones'' frames and invite others to share pictures to your frame; Send unique photos or playlists to separate frames and grow your private family sharing network
PRINT PHOTO SERVICE WITH FUJI: The Nixplay App for iOS and Android gives you full control over your frame; Connect to Google Photos to ensure your frame is always up to date; Dropbox, Facebook and Instagram also supported from website
A WALL-MOUNTABLE SMART FRAME THAT IS TRULY SMART: 1280x800 HD IPS display with 16:10 aspect ratio auto adjusts to portrait or landscape placement; Motion sensor turns the frame on/off automatically; Works with Amazon Alexa, Google Assistant, just ask for the playlist you want
FRIENDLY CUSTOMER CALL SERVICE, EMAIL OR LIVE CHAT: Get support when you need it – even during the Holidays! We have hundreds of thousands of happy customers, and we want to do everything we can to make you happy with your frame', 4.00, 'Nixplay', '2019-12-31 22:15:11.46212');
INSERT INTO public.product (product_id, title, description, weight_kilos, brand, added_date) VALUES ('18fdb12a-f34f-441e-adf3-01106905e5e5', 'Wyze Cam Pan 1080p Pan/Tilt/Zoom Wi-Fi Indoor Smart Home Camera with Night Vision, 2-Way Audio, Works with Alexa & the Google Assistant, White - WYZECP1', 'Pan, tilt, and zoom (PTZ) lets you control Wyze Cam Pan remotely using the Wyze app so you can see every angle of your room while you’re away, on demand. Or, have Wyze Cam Pan monitor your room automatically with the Pan Scan feature by setting 4 predefined waypoints. Panning has a 360° left/right rotation range and tilting has a 93° vertical up/down range.
Live Stream from Anywhere in 1080p - 1080p Full HD live streaming lets you see inside your home from anywhere in real time using your mobile device. While live streaming, use two-way audio to speak with your friends and family through the Wyze app.
Motion/Sound Recording with Free Cloud Storage - Wyze Cam Pan can automatically record a 12-second video clip when motion or sound is detected and saves that video to the cloud for 14-days, for free. Mobile push notifications can be enabled so you’re only alerted when something is detected letting you stay on top of things without having to constantly monitor the app. Or, record continuously to a MicroSD card (sold separately) regardless of motion and sound. Compatible with 8GB, 16GB, or 32GB FAT32 MicroSD cards.
See in the dark - Night vision lets you see up to 30’ in absolute darkness using 6 infrared (IR) LEDs. Note: IR does not work through glass windows.
Voice Controlled? You got it! - Works with Alexa and Google Assistant (US only) so you can use your voice to see who’s at your front door, how your baby’s doing, or if your 3D printer has finished printing. Wyze Cam Pan is only compatible with the 2. 4GHz WiFi network (does not support 5GHz Wi-Fi) and Apple (iOS) and Android mobile devices.
Share with those who care - One Wyze Cam can be shared with multiple family members so everyone can have access to its live stream and video recordings. Just have your family members download the Wyze app and invite them to your account. Camera sharing can also be easily removed.', 8.00, 'Wyze', '2019-12-31 22:19:03.665441');
INSERT INTO public.product (product_id, title, description, weight_kilos, brand, added_date) VALUES ('529c3f21-ff14-4976-a8d5-8b56b7bab356', 'SanDisk 128GB Extreme MicroSDXC UHS-I Memory Card with Adapter - C10, U3, V30, 4K, A2, Micro SD - SDSQXA1-128G-GN6MA', 'Up to 160MB/s read speeds to save time transferring high res images and 4K UHD videos (2); Requires compatible devices capable of reaching such speeds
Up to 90MB/s write speeds for fast Shooting; Requires compatible devices capable of reaching such speeds
4K UHD and Full HD Ready(2) with UHS Speed Class 3 (U3) and video Speed Class 30 (V30)(5)
Rated A2 for faster loading and in app Performance (8)
Built for and tested in harsh conditions: temperature Proof, Water Proof, shock Proof and x ray Proof(4)
Get the SanDisk Memory Zone app for Easy file management (available on Google Play)(3)
Manufacturer lifetime Warranty (30 year Warranty in Germany and regions Not recognizing lifetime; See official SanDisk website for more Details regarding Warranty in Your region)
Order with Your Alexa Enabled device; Just ask ''Alexa, order SanDisk microSD''', 0.00, 'SanDisk', '2019-12-31 22:21:50.562829');
INSERT INTO public.product (product_id, title, description, weight_kilos, brand, added_date) VALUES ('06945798-726c-4ce4-9bb5-ba0ef2da97e9', 'Samsung Galaxy S10 Factory Unlocked Phone with 128GB - Prism Black', 'An immersive Cinematic Infinity Display, Pro grade Camera and Wireless PowerShare The next generation is here
Ultrasonic in display fingerprint ID protects and unlocks with the first touch
Pro grade Camera effortlessly captures epic, pro quality images of the world as you see it
Intelligently accesses power by learning how and when you use your phone. Wi Fi Connectivity 802.11 a/b/g/n/ac/ax 2.4G+5GHz, HE80, MIMO, 1024 QAM. Wi Fi Direct Yes', 0.00, 'Samsung', '2019-12-31 22:40:11.566452');
INSERT INTO public.product (product_id, title, description, weight_kilos, brand, added_date) VALUES ('4ca81e74-fa61-4747-851c-9212457aebfb', 'Google - Pixel 3a with 64GB Memory Cell Phone (Unlocked) - Just Black - G020G', 'Capture stunning photos with features like night sight, portrait mode, and HDR+.
Save every photo with free, unlimited storage at high quality through Google photos [1].
The Google assistant is the easiest way to get things done – including screening calls.[2]
Fast Charging battery delivers up to 7 hours of use with just a 15-minute charge.[3]
Comes with 3 years of OS and security updates] and the custom-built Titan M chip.[5]
Switch seamlessly and keep all your stuff [6]. Plus your favorite Google apps are built in.', 0.00, 'Google Pixel', '2019-12-31 22:44:41.560134');
INSERT INTO public.product (product_id, title, description, weight_kilos, brand, added_date) VALUES ('3ec1789e-f976-4e3e-84bf-ac0b566b4189', 'Samsung Galaxy A50 US Version Factory Unlocked Cell Phone with 64GB Memory, 6.4 Screen, Black, [SM-A505UZKNXAA]', 'With an all day battery that lasts up to 35 hours, The Galaxy A50 keeps up with your fast pace throughout the day and into the night; When you need a boost, power back up quickly with fast charging
Featuring three specialized lenses, The Galaxy A50 is the only camera you’ll ever need; Capture more of what you see in every shot, thanks to our advanced Ultra wide 123 degrees field of vision; Shoot vibrant photos with a 25MP Main Camera or take flattering selfies with a depth lens that puts the focus squarely on you by softening the background', 0.00, 'Samsung', '2019-12-31 22:47:00.165348');
INSERT INTO public.product (product_id, title, description, weight_kilos, brand, added_date) VALUES ('9e1c2494-fcb6-4af6-9b3c-16c1695c32c7', 'Moto G7 – Unlocked – 64 GB – Ceramic Black (US Warranty) - Verizon, AT&T, T-Mobile, Sprint, Boost, Cricket, & Metro', 'Unlocked for the freedom to choose your carrier. Compatible with AT&T, Sprint, T-Mobile, and Verizon networks. Sim card not included. Customers may need to contact Sprint for activation on Sprint’s network.
6. 2" Full HD+ Max Vision display (2270 x 1080) with 19: 9 Aspect ratio, 4 GB of RAM and 64 GB of internal storage with option to add up to 512 GB of Micro SD expandable memory, and Android 9. 0.
Qualcomm Snapdragon 632 processor with 1. 8 GHz Octa-Core CPU and Adreno 506 GPU.
12MP + 5MP dual camera with LED flash, 8 MP front-facing camera with screen flash for low light selfies.
3, 000 mAh non-removable battery with USB Type-C 18W charger.
Facial recognition and fingerprint sensor to instantly unlock your phone.
Reliable design: water protection design with IP54, enjoy a comfortable grip with a scratch-resistant, contoured 3D Corning Gorilla glass design.
Operating System: Android', 0.00, 'Unbranded', '2019-12-31 22:53:03.75859');
INSERT INTO public.product (product_id, title, description, weight_kilos, brand, added_date) VALUES ('48549fd0-d87c-4d63-8728-a44cea1cad4d', 'Apple iPhone 8, 64GB, Gold - Fully Unlocked (Renewed)', 'Product works and looks like new. Backed by the 90-day Amazon Renewed Guarantee.
Renewed products work and look like new. These pre-owned products are not Apple certified but have been inspected and tested by Amazon-qualified suppliers. Box and accessories (no headphones included) may be generic. Wireless devices come with the 90-day Amazon Renewed Guarantee. Learn more
4.7-Inch (diagonal) widescreen LCD multi-touch display with IPS technology and Retina HD display
12MP camera with Optical image stabilization and Six-element lens
4K video recording at 24 fps, 30 fps, or 60 fps
Rated IP67 (maximum depth of 1 meter up to 30 minutes) under IEC standard 60529
A11 Bionic chip Neural Engine', 0.00, 'Apple', '2019-12-31 23:09:51.069478');
INSERT INTO public.product (product_id, title, description, weight_kilos, brand, added_date) VALUES ('9ece6c0b-7c80-4c3c-afe1-33abfcd52fac', 'GlocalMe G4 4G LTE Mobile Hotspot, Worldwide High Speed WiFi Hotspot with 1GB Global Data & 8GB US Data, No SIM Card Roaming Charges International Pocket WiFi Hotspot MIFI Device - Black', '【1.1GB initial Global Data & 8GB North America Data】GlocalMe G4 comes with 1.1GB global data（1 year validity). And the 8GB North America Data can be used in USA, Canada and Mexico, please contact seller to activate by offer your Imei number.
【Lastest Version of GlocalMe】GlocalMe G4 is the upgraded version of G3. Not only Provides an reliable and ultra fast 4G Internet, Moreover, comes with some very useful App for Trip such as TripAdvisor. Work for 15 hours with 3900mAh battery which could also recharge your smartphone on the road.All of our Self shipment Item are delivered by UPS, it only takes around 3 days to reach you after delivery.
【Perfect Travel Wi-Fi Hotspot】GlocalMe allows travelers to get online in over 140 countries and regions without any SIM cards. You don''t need to wait in line or rent mobile routers but enjoy a super-fast and stable 4G internet at the speed of 150 Mbps download/50 Mbps upload. For detailed coverage information please pay a visit to our website: www.glocalme.com.
【Unlocked to all networks】Connect up to 5 Wi-Fi enabled gadgets including your laptop, smart phone, kindle plus more, acts like your personal reliable and secure Wi-Fi hotspot. Moreover, via the user-friendly App, you can easily manage and purchase extra data packages at a low cost if you need, such as 1GB for US is about $ 6 . No contract or roaming charge, only pay for the exact data you used.
【Multifunctional Slot Design & User-friendly App 】G4 also works as a traditional unlocked Wi-Fi hotspot with two SIM card slots. With GlocalMe App, you could manage your data smartly by topping up your balance, purchasing data packages and easily track detailed interaction with the data', 1.00, 'Unbranded', '2019-12-31 23:15:37.003829');
INSERT INTO public.product (product_id, title, description, weight_kilos, brand, added_date) VALUES ('86b4d6b3-ce8c-46fe-92c6-13c5310a43b9', 'Netgear Unite AC770S | Mobile Wifi Hotspot 4G LTE | Up to 300Mbps Download Speed | Connect Up to 10 Devices | Create A WLAN Anywhere | 2 MIMO TS-9 external antenna connectors | GSM Unlocked - White', 'OES THIS DEVICE NEED A SIM CARD: Yes it does Being that this device is GSM unlocked it will work on any GSM Network with a Standard size SIM Card (This is the Larges size sim card) The sim card does NOT come included and you will need to contact your Network Provider to acquire your complimentary Sim card (Free from most Carriers with activating of an account)
WHAT NETWORK FREQUENCIES ARE SUPPORTED BY THIS DEVICE: This device will support B17 (700) and B4 (1700/2100) on the 4G Spectrum. and B5 (850), and B2 (1900) on the 3G Spectrum.
HOW LONG CAN I EXPECT THE BATTERY TO LAST ME: Well the battery has 2500mAh which in a Usage time frame means 10 solid hours of Usage streaming at 4G LTE speeds as well it has a Standby time of up to 10 days before you need to recharge the battery
WHAT DOES UNLOCKED REALLY MEAN: Unlocked devices are compatible with GSM carriers the kinds that Use SIM Cards for Service like AT&T and T-Mobile as well as with GSM SIM cards (e.g. H20, Straight Talk, and select prepaid carriers) Unlocked Devices will not work with CDMA Carriers the kinds that dont use sim cards for service like Sprint, Verizon, Boost or Virgin
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! WILL NOT WORK ON VERIZON OR SPRINT !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!', 0.00, 'Unbranded', '2019-12-31 23:18:31.300932');
INSERT INTO public.product (product_id, title, description, weight_kilos, brand, added_date) VALUES ('ac616902-6f70-4fff-85fc-2e46ed0e3d7e', 'Alcatel LINKZONE | Mobile WiFi Hotspot | 4G LTE Router MW41TM | Up to 150Mbps Download Speed | WiFi Connect Up to 15 Devices | Create A WLAN Anywhere | T-Mobile', 'DOES THIS DEVICE NEED A SIM CARD: Yes it does Being that this device is T-Mobile it will work on any T-Mobile with a Micro size ACTIVE SIM Card The sim card does not come included, you will need to contact T-Mobile to acquire your complimentary Sim card (activating on T-Mobile Costs Approx $10 at any T-Mobile Store or over the phone).
WHAT NETWORK FREQUENCIES ARE SUPPORTED BY THIS DEVICE: The device supports Bands FDD LTE: B2/4/12 WCDMA: B1/2/4/5 GSM: B2/3/5/8. Please contact T-Mobile and inquire whether they support these bands in your area to ensure the device will work Properly
WELL, HOW LONG CAN IT LAST ME: A removable 1,800mAh battery that lasted for 6 hours of continuous streaming in our tests that''s reasonable for a Small slick hotspot as well as a STANDBY TIME of 300 hours.
This device will not work on any other network besides of the T-Mobile network it is a T-Mobile branded device and will only function for their Network, A mobile hotspot provides Wi-Fi to up to 15 devices within 150 ft so that they can all access Internet on the blazingly fast 4G LTE Spectrum
IS THIS DEVICE UNLOCKED: No. this device will be locked unto the T-Mobile Network for the first 2 Years after that period you can contact T-Mobile to Unlock the device. THIS DEVICE WILL ONLY WORK ON THE T-Mobile NETWORK OUT OF THE BOX.', 1.00, 'Alcatel', '2019-12-31 23:25:56.389156');
INSERT INTO public.product (product_id, title, description, weight_kilos, brand, added_date) VALUES ('c6f66840-acfd-4e18-8a45-100138e4c54b', 'Alcatel Link Zone 4G LTE Global MW41NF-2AOFUS1 Mobile Wifi Hotspot Factory Unlocked GSM Up to 15 Wifi Users USA Latin Caribbean Europe MW41NF', '4G LTE Unlocked GSM Carrier Desbloqueados GSM (Router Does NOT Work on Verizon Sprint Net10 or Any CDMA Carrier)
Factory Unlocked "NO LOGOS" 1 Micro Sim Card 4G Lte bands:B1 (2100) B2 (1900) B3 (1800) B4 (AWS) B5 (850) B7 (2600) B8 (900) B12 (700) B13 (700) B20 (800) 3G UTMS: 850/900/1700/1900/2100 2G: 850/900/1800/1900 MHZ
4G LTE WORLDWIDE Up to 150 MBPS and 15 Wifi Users / Cat 4 / Spanish English Interface
Router uses Micro Sim Card Hotspot Service is required. (No sim card or Services included).
Wi-Fi Specs 802.11 b/g/n – 2.4 GHz Use the hotspot with up to 15 different wifi devices including laptops, iPhone, smartphone, iPad, tablet, gaming consoles and many more.', 1.00, 'Alcatel', '2019-12-31 23:30:07.450814');
INSERT INTO public.product (product_id, title, description, weight_kilos, brand, added_date) VALUES ('6f066264-fee9-4d75-8640-f9047e1b5904', 'Verizon Jetpack 4G LTE Mobile Hotspot - AC791L With Accessory Port (Renewed) Includes JPO Car Bullet charger head', 'Product works and looks like new. Backed by the 90-day Amazon Renewed Guarantee.

Renewed products work and look like new. These pre-owned products have been inspected and tested by Amazon-qualified suppliers. Box and accessories (no headphones included) may be generic. Wireless devices come with the 90-day Amazon Renewed Guarantee. Learn more

4G LTE Advanced-capable device for ultimate download speeds
Up to 24 hours of battery life on a single charge
Charge your smartphone or small portable USB device
Secure with Guest WiFi, password protection, and the latest WiFi security
World Device for easy Internet access when traveling internationally', 1.00, 'Verizon', '2019-12-31 23:31:21.480522');
INSERT INTO public.product (product_id, title, description, weight_kilos, brand, added_date) VALUES ('e6965dfc-6775-4e81-8ab2-bafbe1534530', 'CanaKit Raspberry Pi 3 B+ (B Plus) with 2.5A Power Supply (UL Listed)', 'Includes Raspberry Pi 3 B+ (B Plus) with 1.4 GHz 64-bit Quad-Core Processor, 1 GB RAM
CanaKit 2.5A USB Power Supply with Micro USB Cable and Noise Filter - Specially designed for the Raspberry Pi 3 B+ (UL Listed)
Dual Band 2.4GHz and 5GHz IEEE 802.11.b/g/n/ac Wireless LAN, Enhanced Ethernet Performance
Set of 2 Aluminum Heat Sinks
CanaKit Quick-Start Guide', 1.50, 'Unbranded', '2019-12-31 23:44:07.813207');
INSERT INTO public.product (product_id, title, description, weight_kilos, brand, added_date) VALUES ('78f1645e-8694-4e36-93e8-5f14dea416b8', 'Corsair One i164 Compact Gaming PC, i9-9900K, Liquid-Cooled RTX 2080 Ti, 960GB M.2, 2TB HDD, 32GB', 'Corsair One i164 redefines what you can expect from a high performance PC. Incredibly fast, amazingly compact, and quiet, With a sophisticated design that lives on your desk, not under it.
Corsair One i164 boasts the latest in performance PC technology, with an Intel Core i9-9900k Eight-Core Processor, NVIDIA GeForce RTX 2080 Ti graphics and award-winning Corsair DDR4 memory.
Clad in a 2mm thick bead-blasted aluminum shell. Corsair ONE i164’s minimalist ultra-small form factor is crafted to sit on top of your desk, not under it.
Zero RPM mode allows for quiet fanless operation when idle. Form Factor Mini-ITX
Corsair One i164’s processor and graphics card are cooled using a patented assisted convection liquid cooling system, achieving higher clock speeds, lower temperatures, and minimal noise.', 5.90, 'Corsair', '2019-12-31 23:46:16.724689');
INSERT INTO public.product (product_id, title, description, weight_kilos, brand, added_date) VALUES ('45ee0b20-0530-4d90-b8e6-1bb406d8e870', 'ASRock System DESKMINI A300W AMD AM4 Max.32GB DDR4 HDMI DP D-Sub USB Retail', 'Supports AMD AM4 socket CPUs (Raven Ridge, Bristol Ridge, up to 65W)
Supports AMD AM4 CPU cooler (Max. Height ≦ 46mm)
Mad A300 Promontory
2x 2. 5” SATA6Gb Hard Drive
1 x M. 2 (key E 2230) slot for Wi-Fi + BT module', 3.00, 'Unbranded', '2019-12-31 23:57:51.035079');
INSERT INTO public.product (product_id, title, description, weight_kilos, brand, added_date) VALUES ('22ef01c0-af1e-4087-ade5-1e547e59c4d2', 'Intel NUC Kit NUC6i5SYK', '6th generation Intel Core i5-6260U
Intel Iris graphics 540
Up to 7.1 surround audio via HDMI and Mini DisplayPort
Internal support for M.2 SSD card (22x42 or 22x80)
Support for user-replaceable 3rdparty lids
Intel Wireless-AC 8260 M.2 soldered-down, wireless antennas (IEEE 802.11ac, Bluetooth 4.1, Intel Wireless Display 6.0)
19V, 65W wall-mount AC-DC power adapter
Multi-country plugs(US, UK, EU, AU)', 6.00, 'Intel', '2020-01-01 00:08:54.973785');
INSERT INTO public.product (product_id, title, description, weight_kilos, brand, added_date) VALUES ('43656a7f-e326-443a-b91b-54c31d6ca2e3', 'Thermaltake Core G3 Black Slim Small Form Factor ATX Perforated Metal Front and Top Panel Gaming Computer Case with Two 120mm Front Fan Pre-Installed CA-1G6-00S1WN-A0', 'Stay slim: A perfect compact micro slim chassis design fit at your desk or living room
Dual placements layout: Designed for horizontal or Vertical layouts, the Core G3 takes both angles for even more
Lan party ready: GPU padded braces and travel foams to secure your hardware while traveling
Floating GPU design: Bring your GPU power to the forefront With a custom GPU mount, turning the GPU face front for an unprecedented look
Fully modular: Provides multiple configurations and flexibility for custom PC enthusiasts
2 Drive bay: 2. 5"/3. 5” x 2 with HDD cage
Optimize system ventilation: 2 120mm front fan pre installed', 2.90, 'Unbranded', '2020-01-01 00:11:23.904866');
INSERT INTO public.product (product_id, title, description, weight_kilos, brand, added_date) VALUES ('82ce8f16-b9cb-4c66-a2ba-b9608393bdc2', 'WD 2TB Elements Portable External Hard Drive - USB 3.0 - WDBU6Y0020BBK', 'USB 3.0 and USB 2.0 Compatibility
Fast data transfers
Improve PC Performance
High Capacity; Compatibility Formatted NTFS for Windows 10, Windows 8.1, Windows 7; Reformatting may be required for other operating systems; Compatibility may vary depending on user’s hardware configuration and operating system
2 year manufacturer''s limited warranty', 0.50, 'WD', '2020-01-01 00:19:27.690199');
-- Products

INSERT INTO public.productimage (image_id, product_id, image_url) VALUES ('632b7e2e-b315-43bb-b7cc-441232c37eee', '5f6aff49-c20b-456d-8938-dea885941365', 'https://images-na.ssl-images-amazon.com/images/I/817wkPGulTL._AC_SL1500_.jpg');
INSERT INTO public.productimage (image_id, product_id, image_url) VALUES ('569efeb9-41a1-46c6-94b7-9480a72f2a41', '5f6aff49-c20b-456d-8938-dea885941365', 'https://images-na.ssl-images-amazon.com/images/I/61kxjADwqlL._AC_SL1000_.jpg');
INSERT INTO public.productimage (image_id, product_id, image_url) VALUES ('3d52766d-edc3-4dec-a427-0186348b9191', '5f6aff49-c20b-456d-8938-dea885941365', 'https://images-na.ssl-images-amazon.com/images/I/815KXesPOtL._AC_SL1500_.jpg');
INSERT INTO public.productimage (image_id, product_id, image_url) VALUES ('ddfa3aa4-2971-40ba-a72b-de1caf380e02', '738426aa-35ea-4d96-b839-d0902d084672', 'https://images-na.ssl-images-amazon.com/images/I/51H5U1Q8RRL._AC_SL1234_.jpg');
INSERT INTO public.productimage (image_id, product_id, image_url) VALUES ('7b93e759-7126-40a4-b2ed-b6da103fe2dc', '738426aa-35ea-4d96-b839-d0902d084672', 'https://images-na.ssl-images-amazon.com/images/I/61jV1-4PxXL._AC_SL1500_.jpg');
INSERT INTO public.productimage (image_id, product_id, image_url) VALUES ('6f923089-8442-4df6-8f5a-d71ebfd0674a', '738426aa-35ea-4d96-b839-d0902d084672', 'https://images-na.ssl-images-amazon.com/images/I/61RqrX5A2OL._AC_SL1500_.jpg');
INSERT INTO public.productimage (image_id, product_id, image_url) VALUES ('18f6bb90-f6d8-42ed-bd59-4c7cc0c833f0', '1f6c20e0-8af5-4ad6-ae98-026bc7741670', 'https://images-na.ssl-images-amazon.com/images/I/81g-euOr3%2BL._AC_SL1500_.jpg');
INSERT INTO public.productimage (image_id, product_id, image_url) VALUES ('45d8a5bc-0ef5-4f54-ad58-46414ad64634', '1f6c20e0-8af5-4ad6-ae98-026bc7741670', 'https://images-na.ssl-images-amazon.com/images/I/71wYKCierZL._AC_SL1500_.jpg');
INSERT INTO public.productimage (image_id, product_id, image_url) VALUES ('c4caf2ae-d3e7-410b-878b-ab26ee5606c6', '1f6c20e0-8af5-4ad6-ae98-026bc7741670', 'https://images-na.ssl-images-amazon.com/images/I/71PhTotGCOL._AC_SL1500_.jpg');
INSERT INTO public.productimage (image_id, product_id, image_url) VALUES ('8a71ecd1-b873-49dd-aea6-ca3d3dfeb0a1', '18fdb12a-f34f-441e-adf3-01106905e5e5', 'https://images-na.ssl-images-amazon.com/images/I/31dz6wCIWML._AC_.jpg');
INSERT INTO public.productimage (image_id, product_id, image_url) VALUES ('615e6ba4-a15a-4071-8685-822e4b11b627', '18fdb12a-f34f-441e-adf3-01106905e5e5', 'https://images-na.ssl-images-amazon.com/images/I/31Y8NH8Ia5L._AC_.jpg');
INSERT INTO public.productimage (image_id, product_id, image_url) VALUES ('86d7590d-d4f8-4b45-a495-eb21d8655078', '529c3f21-ff14-4976-a8d5-8b56b7bab356', 'https://images-na.ssl-images-amazon.com/images/I/71f0i4j9wGL._AC_SL1500_.jpg');
INSERT INTO public.productimage (image_id, product_id, image_url) VALUES ('2e2b228d-5a43-4704-ac7f-58b73f66ff69', '529c3f21-ff14-4976-a8d5-8b56b7bab356', 'https://images-na.ssl-images-amazon.com/images/I/81PC94JVGkL._AC_SL1500_.jpg');
INSERT INTO public.productimage (image_id, product_id, image_url) VALUES ('7c8bc11e-3186-4dc3-99bc-09c886d014d9', '529c3f21-ff14-4976-a8d5-8b56b7bab356', 'https://images-na.ssl-images-amazon.com/images/I/81DAzeX7Z4L._AC_SL1500_.jpg');
INSERT INTO public.productimage (image_id, product_id, image_url) VALUES ('6c0415c1-ff1e-435b-87f1-2df34230173e', '06945798-726c-4ce4-9bb5-ba0ef2da97e9', 'https://images-na.ssl-images-amazon.com/images/I/51x8eZ8JbKL._AC_SL1000_.jpg');
INSERT INTO public.productimage (image_id, product_id, image_url) VALUES ('a7058605-b2ee-4216-beb7-dbf71c62d83d', '4ca81e74-fa61-4747-851c-9212457aebfb', 'https://images-na.ssl-images-amazon.com/images/I/81T-FKC695L._AC_SL1500_.jpg');
INSERT INTO public.productimage (image_id, product_id, image_url) VALUES ('b425c44d-f961-4f44-8c4c-1acfebcab4ec', '3ec1789e-f976-4e3e-84bf-ac0b566b4189', 'https://images-na.ssl-images-amazon.com/images/I/71kLFOLKN3L._AC_SL1500_.jpg');
INSERT INTO public.productimage (image_id, product_id, image_url) VALUES ('9154782d-605c-4dc8-be67-6dca209ec2aa', '9e1c2494-fcb6-4af6-9b3c-16c1695c32c7', 'https://images-na.ssl-images-amazon.com/images/I/81Vobb06FVL._AC_SL1500_.jpg');
INSERT INTO public.productimage (image_id, product_id, image_url) VALUES ('9d13c23b-91fd-47f9-a721-18a6a67c136f', '06945798-726c-4ce4-9bb5-ba0ef2da97e9', 'https://images-na.ssl-images-amazon.com/images/I/61GUOlgK7GL._AC_SL1500_.jpg');
INSERT INTO public.productimage (image_id, product_id, image_url) VALUES ('819f36b6-5e83-4831-add5-0e127b1d880d', '48549fd0-d87c-4d63-8728-a44cea1cad4d', 'https://images-na.ssl-images-amazon.com/images/I/61pRPj%2B-IYL._AC_SL1500_.jpg');
INSERT INTO public.productimage (image_id, product_id, image_url) VALUES ('e18214e6-481b-4430-b86d-0d98c21763b0', '9ece6c0b-7c80-4c3c-afe1-33abfcd52fac', 'https://images-na.ssl-images-amazon.com/images/I/41J545bt3JL._AC_.jpg');
INSERT INTO public.productimage (image_id, product_id, image_url) VALUES ('c0c85697-17da-4dde-ab35-143e1aaed306', '86b4d6b3-ce8c-46fe-92c6-13c5310a43b9', 'https://images-na.ssl-images-amazon.com/images/I/51a6d27Dc%2BL._AC_SL1049_.jpg');
INSERT INTO public.productimage (image_id, product_id, image_url) VALUES ('eff0f075-840d-4a68-9f25-70fe1cefdd1f', 'ac616902-6f70-4fff-85fc-2e46ed0e3d7e', 'https://images-na.ssl-images-amazon.com/images/I/61cMxSggndL._AC_SL1500_.jpg');
INSERT INTO public.productimage (image_id, product_id, image_url) VALUES ('008d401a-02be-4177-9f51-1230f82f1b6b', 'c6f66840-acfd-4e18-8a45-100138e4c54b', 'https://images-na.ssl-images-amazon.com/images/I/71sXcEUxlqL._AC_SL1300_.jpg');
INSERT INTO public.productimage (image_id, product_id, image_url) VALUES ('5c9cbeba-69e0-4f29-bf80-5a76796c6fba', '6f066264-fee9-4d75-8640-f9047e1b5904', 'https://images-na.ssl-images-amazon.com/images/I/412BQqDj9UL._AC_.jpg');
INSERT INTO public.productimage (image_id, product_id, image_url) VALUES ('7d93f7e3-9843-4d74-bd03-7ba2a48cc83f', 'e6965dfc-6775-4e81-8ab2-bafbe1534530', 'https://images-na.ssl-images-amazon.com/images/I/817pW0tRRuL._AC_SL1500_.jpg');
INSERT INTO public.productimage (image_id, product_id, image_url) VALUES ('6748056b-2a67-46ad-bb90-cf285174e103', '78f1645e-8694-4e36-93e8-5f14dea416b8', 'https://images-na.ssl-images-amazon.com/images/I/61fBJ-%2BRONL._AC_SL1500_.jpg');
INSERT INTO public.productimage (image_id, product_id, image_url) VALUES ('8af781b1-f447-4b77-abfd-6b2f005b13ce', '78f1645e-8694-4e36-93e8-5f14dea416b8', 'https://images-na.ssl-images-amazon.com/images/I/71MtOi5vpRL._AC_SL1500_.jpg');
INSERT INTO public.productimage (image_id, product_id, image_url) VALUES ('d343fddc-b360-42a5-bbc7-3aba99210a2b', '78f1645e-8694-4e36-93e8-5f14dea416b8', 'https://images-na.ssl-images-amazon.com/images/I/71MtOi5vpRL._AC_SL1500_.jpg');
INSERT INTO public.productimage (image_id, product_id, image_url) VALUES ('66063d61-ba24-4ea9-b273-0a3bb4f1ef72', '45ee0b20-0530-4d90-b8e6-1bb406d8e870', 'https://images-na.ssl-images-amazon.com/images/I/61rxF7qctmL._AC_SL1200_.jpg');
INSERT INTO public.productimage (image_id, product_id, image_url) VALUES ('56e90d1b-a4c0-4060-a273-d3101d48c59b', '22ef01c0-af1e-4087-ade5-1e547e59c4d2', 'https://images-na.ssl-images-amazon.com/images/I/619unAHNLqL._AC_SL1490_.jpg');
INSERT INTO public.productimage (image_id, product_id, image_url) VALUES ('f85fe6f8-b92c-4d38-a2b2-2868a50603cd', '43656a7f-e326-443a-b91b-54c31d6ca2e3', 'https://images-na.ssl-images-amazon.com/images/I/81wF0U6-PmL._AC_SL1500_.jpg');
INSERT INTO public.productimage (image_id, product_id, image_url) VALUES ('df4338f2-2ae5-4fc9-9605-88a41bd153d8', '43656a7f-e326-443a-b91b-54c31d6ca2e3', 'https://images-na.ssl-images-amazon.com/images/I/81ROx1BIb%2BL._AC_SL1500_.jpg');
INSERT INTO public.productimage (image_id, product_id, image_url) VALUES ('fa973739-6e75-4401-b44d-6e08ce227f63', '82ce8f16-b9cb-4c66-a2ba-b9608393bdc2', 'https://images-na.ssl-images-amazon.com/images/I/61AjtL1R%2BgL._AC_SL1500_.jpg');
-- Images

INSERT INTO public.variant (variant_id, product_id, sku_id, quantity, title, listed_price, selling_price) VALUES ('39fdcf10-c37d-434e-9ace-3854e0af4c0a', '5f6aff49-c20b-456d-8938-dea885941365', '1577808562', 50, '128 GB', 4250.00, 4000.00);
INSERT INTO public.variant (variant_id, product_id, sku_id, quantity, title, listed_price, selling_price) VALUES ('38af28dc-cfb2-4493-b863-2862344ea69f', '5f6aff49-c20b-456d-8938-dea885941365', '15778085622', 56, '256 GB', 9000.00, 8500.00);
INSERT INTO public.variant (variant_id, product_id, sku_id, quantity, title, listed_price, selling_price) VALUES ('efd7b85d-b897-420b-a165-e53f79f174ff', '738426aa-35ea-4d96-b839-d0902d084672', '1577809888', 54, 'One Pack', 4600.00, 4300.00);
INSERT INTO public.variant (variant_id, product_id, sku_id, quantity, title, listed_price, selling_price) VALUES ('849d0f81-11fe-431b-9290-1990d1ed1265', '1f6c20e0-8af5-4ad6-ae98-026bc7741670', '575686111R', 9, '13.3 Inch', 33000.00, 29950.00);
INSERT INTO public.variant (variant_id, product_id, sku_id, quantity, title, listed_price, selling_price) VALUES ('f590db01-d29f-4044-8232-7f203a7adb7d', '18fdb12a-f34f-441e-adf3-01106905e5e5', '662382858', 56, 'Default', 45000.00, 42000.00);
INSERT INTO public.variant (variant_id, product_id, sku_id, quantity, title, listed_price, selling_price) VALUES ('4690dfa6-4d44-423e-becb-ac0ca897c594', '529c3f21-ff14-4976-a8d5-8b56b7bab356', '757506702R', 56, '256 GB', 8600.00, 7500.00);
INSERT INTO public.variant (variant_id, product_id, sku_id, quantity, title, listed_price, selling_price) VALUES ('13344e0c-f7e8-4de7-a224-c8ef3332ad60', '738426aa-35ea-4d96-b839-d0902d084672', '1577809888R', 10, 'One Pack + SD Card', 5900.00, 5850.00);
INSERT INTO public.variant (variant_id, product_id, sku_id, quantity, title, listed_price, selling_price) VALUES ('fe190bc9-0a2c-4774-bbf1-8b66e07af1f3', '738426aa-35ea-4d96-b839-d0902d084672', '1577809888S', 4, 'Two Pack Camera', 18000.00, 16999.00);
INSERT INTO public.variant (variant_id, product_id, sku_id, quantity, title, listed_price, selling_price) VALUES ('b0b91471-18b8-425f-9e20-8bea7fdaa751', '06945798-726c-4ce4-9bb5-ba0ef2da97e9', '591827728R', 8, 'S10e', 135000.00, 120000.00);
INSERT INTO public.variant (variant_id, product_id, sku_id, quantity, title, listed_price, selling_price) VALUES ('c815c070-56d6-472c-ae24-76a249c9bede', '06945798-726c-4ce4-9bb5-ba0ef2da97e9', '591827728', 4, 'S10', 120000.00, 112000.00);
INSERT INTO public.variant (variant_id, product_id, sku_id, quantity, title, listed_price, selling_price) VALUES ('1d9b0bbb-fbf7-4c40-b326-85a6e064655e', '4ca81e74-fa61-4747-851c-9212457aebfb', '870747987', 2, '3A', 90000.00, 78000.00);
INSERT INTO public.variant (variant_id, product_id, sku_id, quantity, title, listed_price, selling_price) VALUES ('04aa1f0c-35b6-4f8a-bec9-a4eb3e8d0950', '3ec1789e-f976-4e3e-84bf-ac0b566b4189', '991851629', 3, 'A50', 68000.00, 66000.00);
INSERT INTO public.variant (variant_id, product_id, sku_id, quantity, title, listed_price, selling_price) VALUES ('e82c2fbc-365a-439d-ab5d-c1e138bfa0de', '9e1c2494-fcb6-4af6-9b3c-16c1695c32c7', '812738244', 56, 'G7', 25000.00, 22500.00);
INSERT INTO public.variant (variant_id, product_id, sku_id, quantity, title, listed_price, selling_price) VALUES ('96aa2f9d-b6fe-4860-86ac-789a91569a4b', '9e1c2494-fcb6-4af6-9b3c-16c1695c32c7', '812738244T', 65, 'G7 Play', 29000.00, 28500.00);
INSERT INTO public.variant (variant_id, product_id, sku_id, quantity, title, listed_price, selling_price) VALUES ('43282f65-922f-490b-8c1a-309c929ceb2a', '48549fd0-d87c-4d63-8728-a44cea1cad4d', '477545419', 5, '64 GB', 48000.00, 45000.00);
INSERT INTO public.variant (variant_id, product_id, sku_id, quantity, title, listed_price, selling_price) VALUES ('fe58f106-37a3-40b9-9a05-bf1ed2d09da7', '9ece6c0b-7c80-4c3c-afe1-33abfcd52fac', '298253076', 5, 'Default', 220000.00, 199000.00);
INSERT INTO public.variant (variant_id, product_id, sku_id, quantity, title, listed_price, selling_price) VALUES ('d1444c76-1ce6-47a2-b202-676310cc93f9', 'ac616902-6f70-4fff-85fc-2e46ed0e3d7e', '940567204', 99, 'Default', 78000.00, 75000.00);
INSERT INTO public.variant (variant_id, product_id, sku_id, quantity, title, listed_price, selling_price) VALUES ('5e131d01-74c9-41db-b2bc-77875162919d', 'c6f66840-acfd-4e18-8a45-100138e4c54b', '379803353', 20, 'Default', 75000.00, 70000.00);
INSERT INTO public.variant (variant_id, product_id, sku_id, quantity, title, listed_price, selling_price) VALUES ('5a4f6a69-d1d7-404e-856a-b405c1ecce7a', '6f066264-fee9-4d75-8640-f9047e1b5904', '187195688', 10, 'Default', 7500.00, 7000.00);
INSERT INTO public.variant (variant_id, product_id, sku_id, quantity, title, listed_price, selling_price) VALUES ('9c1933ba-d4bd-46e4-8a8e-312a865850bd', '86b4d6b3-ce8c-46fe-92c6-13c5310a43b9', '910039752', 4, 'Default', 68000.00, 64000.00);
INSERT INTO public.variant (variant_id, product_id, sku_id, quantity, title, listed_price, selling_price) VALUES ('a2a8fc3e-0e66-4d91-a124-f85cfb8d8ba6', 'e6965dfc-6775-4e81-8ab2-bafbe1534530', '651316561', 5, 'Default', 8000.00, 7500.00);
INSERT INTO public.variant (variant_id, product_id, sku_id, quantity, title, listed_price, selling_price) VALUES ('16e975e2-8b6f-45c8-af72-4795b5b0ba0b', '78f1645e-8694-4e36-93e8-5f14dea416b8', '451495971R', 0, 'i9-9920X - 32 GB DRAM', 650000.00, 599900.00);
INSERT INTO public.variant (variant_id, product_id, sku_id, quantity, title, listed_price, selling_price) VALUES ('8405292a-6720-46d2-afea-62bda36ddafb', '78f1645e-8694-4e36-93e8-5f14dea416b8', '451495971X', 2, 'i9-9920X - 64GB DRAM', 780000.00, 749050.00);
INSERT INTO public.variant (variant_id, product_id, sku_id, quantity, title, listed_price, selling_price) VALUES ('09c0f1c8-b576-4f19-8e85-d5efa21d2940', '45ee0b20-0530-4d90-b8e6-1bb406d8e870', '670805553', 20, 'Default', 22000.00, 19900.00);
INSERT INTO public.variant (variant_id, product_id, sku_id, quantity, title, listed_price, selling_price) VALUES ('0a47fdbf-47f8-4783-8a31-4f4f2bc314ee', '78f1645e-8694-4e36-93e8-5f14dea416b8', '451495971', 4, '  i9-9900K - 32GB DRAM', 650000.00, 599000.00);
INSERT INTO public.variant (variant_id, product_id, sku_id, quantity, title, listed_price, selling_price) VALUES ('0b39b5e2-1c59-41f0-9a67-fbc479f83d19', '529c3f21-ff14-4976-a8d5-8b56b7bab356', '757506702', 13, '128 GB', 4000.00, 3750.00);
INSERT INTO public.variant (variant_id, product_id, sku_id, quantity, title, listed_price, selling_price) VALUES ('06fdbe95-ac66-4184-8782-dab7cd18570c', '22ef01c0-af1e-4087-ade5-1e547e59c4d2', '395822611', 5, 'Default', 70000.00, 68500.00);
INSERT INTO public.variant (variant_id, product_id, sku_id, quantity, title, listed_price, selling_price) VALUES ('9cd23c74-279f-433b-832c-2a115d423f58', '43656a7f-e326-443a-b91b-54c31d6ca2e3', '395822611R', 5, 'G3', 13000.00, 11900.00);
INSERT INTO public.variant (variant_id, product_id, sku_id, quantity, title, listed_price, selling_price) VALUES ('31af930d-de0a-46e0-b6e3-6ca3ebeb2345', '43656a7f-e326-443a-b91b-54c31d6ca2e3', '395822611T', 5, 'X31', 16000.00, 12500.00);
INSERT INTO public.variant (variant_id, product_id, sku_id, quantity, title, listed_price, selling_price) VALUES ('34381d8c-8fc6-49ad-86bd-a6807468a5e9', '43656a7f-e326-443a-b91b-54c31d6ca2e3', '395822611RGB', 0, 'X31 RGB', 19000.00, 17900.00);
INSERT INTO public.variant (variant_id, product_id, sku_id, quantity, title, listed_price, selling_price) VALUES ('8c3ad6b2-f4ba-4bc5-ab44-db3f8683877e', '43656a7f-e326-443a-b91b-54c31d6ca2e3', '39582261121', 5, 'G21', 21000.00, 19900.00);
INSERT INTO public.variant (variant_id, product_id, sku_id, quantity, title, listed_price, selling_price) VALUES ('bd37442d-d2dd-48f0-97f7-dca900dcea9c', '1f6c20e0-8af5-4ad6-ae98-026bc7741670', '575686111', 21, '10.1 Inch', 25000.00, 22950.00);
INSERT INTO public.variant (variant_id, product_id, sku_id, quantity, title, listed_price, selling_price) VALUES ('2ef51cc5-5368-4131-84d2-4e1b0f95996a', '82ce8f16-b9cb-4c66-a2ba-b9608393bdc2', '187801461', 5, '1TB', 8500.00, 8300.00);
INSERT INTO public.variant (variant_id, product_id, sku_id, quantity, title, listed_price, selling_price) VALUES ('03c9e865-6bec-47b5-aa3e-1c6030be0773', '82ce8f16-b9cb-4c66-a2ba-b9608393bdc2', '187801461RT', 6, '2TB', 10000.00, 9800.00);
INSERT INTO public.variant (variant_id, product_id, sku_id, quantity, title, listed_price, selling_price) VALUES ('f0b56e42-3309-4959-9347-73d8acab81b1', '82ce8f16-b9cb-4c66-a2ba-b9608393bdc2', '1878014614TB', 5, '4TB', 14000.00, 12800.00);
INSERT INTO public.variant (variant_id, product_id, sku_id, quantity, title, listed_price, selling_price) VALUES ('e4d391d0-c26e-4889-95ef-9200a35b26b4', '82ce8f16-b9cb-4c66-a2ba-b9608393bdc2', '1878014618TB', 8, '8TB', 19500.00, 18900.00);
-- Variant

INSERT INTO public.productcategory (category_id, product_id) VALUES ('b64542d4-328f-4670-adc9-1e9f6dc09219', '5f6aff49-c20b-456d-8938-dea885941365');
INSERT INTO public.productcategory (category_id, product_id) VALUES ('b64542d4-328f-4670-adc9-1e9f6dc09219', '738426aa-35ea-4d96-b839-d0902d084672');
INSERT INTO public.productcategory (category_id, product_id) VALUES ('b64542d4-328f-4670-adc9-1e9f6dc09219', '1f6c20e0-8af5-4ad6-ae98-026bc7741670');
INSERT INTO public.productcategory (category_id, product_id) VALUES ('b64542d4-328f-4670-adc9-1e9f6dc09219', '18fdb12a-f34f-441e-adf3-01106905e5e5');
INSERT INTO public.productcategory (category_id, product_id) VALUES ('b64542d4-328f-4670-adc9-1e9f6dc09219', '529c3f21-ff14-4976-a8d5-8b56b7bab356');
INSERT INTO public.productcategory (category_id, product_id) VALUES ('dfc64f40-2794-4eea-ace7-30a165a4619a', '9ece6c0b-7c80-4c3c-afe1-33abfcd52fac');
INSERT INTO public.productcategory (category_id, product_id) VALUES ('dfc64f40-2794-4eea-ace7-30a165a4619a', '86b4d6b3-ce8c-46fe-92c6-13c5310a43b9');
INSERT INTO public.productcategory (category_id, product_id) VALUES ('dfc64f40-2794-4eea-ace7-30a165a4619a', '6f066264-fee9-4d75-8640-f9047e1b5904');
INSERT INTO public.productcategory (category_id, product_id) VALUES ('dfc64f40-2794-4eea-ace7-30a165a4619a', 'ac616902-6f70-4fff-85fc-2e46ed0e3d7e');
INSERT INTO public.productcategory (category_id, product_id) VALUES ('dfc64f40-2794-4eea-ace7-30a165a4619a', 'c6f66840-acfd-4e18-8a45-100138e4c54b');
INSERT INTO public.productcategory (category_id, product_id) VALUES ('6238c143-4eac-4383-a348-33739390af81', '06945798-726c-4ce4-9bb5-ba0ef2da97e9');
INSERT INTO public.productcategory (category_id, product_id) VALUES ('6238c143-4eac-4383-a348-33739390af81', '4ca81e74-fa61-4747-851c-9212457aebfb');
INSERT INTO public.productcategory (category_id, product_id) VALUES ('6238c143-4eac-4383-a348-33739390af81', '3ec1789e-f976-4e3e-84bf-ac0b566b4189');
INSERT INTO public.productcategory (category_id, product_id) VALUES ('6238c143-4eac-4383-a348-33739390af81', '9e1c2494-fcb6-4af6-9b3c-16c1695c32c7');
INSERT INTO public.productcategory (category_id, product_id) VALUES ('6238c143-4eac-4383-a348-33739390af81', '48549fd0-d87c-4d63-8728-a44cea1cad4d');
INSERT INTO public.productcategory (category_id, product_id) VALUES ('824be22c-3aea-44d7-9a26-d8c4287a3283', 'e6965dfc-6775-4e81-8ab2-bafbe1534530');
INSERT INTO public.productcategory (category_id, product_id) VALUES ('824be22c-3aea-44d7-9a26-d8c4287a3283', '78f1645e-8694-4e36-93e8-5f14dea416b8');
INSERT INTO public.productcategory (category_id, product_id) VALUES ('824be22c-3aea-44d7-9a26-d8c4287a3283', '45ee0b20-0530-4d90-b8e6-1bb406d8e870');
INSERT INTO public.productcategory (category_id, product_id) VALUES ('824be22c-3aea-44d7-9a26-d8c4287a3283', '22ef01c0-af1e-4087-ade5-1e547e59c4d2');
INSERT INTO public.productcategory (category_id, product_id) VALUES ('824be22c-3aea-44d7-9a26-d8c4287a3283', '43656a7f-e326-443a-b91b-54c31d6ca2e3');
INSERT INTO public.productcategory (category_id, product_id) VALUES ('b2e8eff4-3e64-4ef6-9705-1b2f106ba363', '82ce8f16-b9cb-4c66-a2ba-b9608393bdc2');
-- Categories

INSERT INTO public.tag (tag_id, tag) VALUES ('52fd88ca-b9ba-4ba3-81fb-05c2dffad9f6', 'memory');
INSERT INTO public.tag (tag_id, tag) VALUES ('c1fff244-dfb0-4ed0-8433-6066b7f8fca7', 'card');
INSERT INTO public.tag (tag_id, tag) VALUES ('6ab6980f-c2d1-4e46-8bfb-958fe8f527e4', 'sd');
INSERT INTO public.tag (tag_id, tag) VALUES ('466db086-e1d2-49ca-8133-6489eca0fa69', 'camera');
INSERT INTO public.tag (tag_id, tag) VALUES ('7361a39e-4205-4cbe-8a48-62a762fa4b1d', 'security');
INSERT INTO public.tag (tag_id, tag) VALUES ('d73d96d9-0b90-42f2-963e-07c6d3d157ad', 'privacy');
INSERT INTO public.tag (tag_id, tag) VALUES ('c8ceb7bd-2090-41e7-a9a6-af657abb62de', 'mobile');
INSERT INTO public.tag (tag_id, tag) VALUES ('65e6deda-4dd6-41bd-8c63-5a5f96561712', 'phone');
INSERT INTO public.tag (tag_id, tag) VALUES ('de2d616d-8d5f-4323-8b43-53d95ffe0013', 'internet');
INSERT INTO public.tag (tag_id, tag) VALUES ('987b2540-5ef1-4963-95a7-2dcce5dcf97c', 'connect');
INSERT INTO public.tag (tag_id, tag) VALUES ('c2c37357-fb20-4e74-87fd-a96153dc5238', 'network');
INSERT INTO public.tag (tag_id, tag) VALUES ('bd1a378b-f198-4fe6-9776-0414cc421038', 'connection');
INSERT INTO public.tag (tag_id, tag) VALUES ('873c360f-73b5-42b1-b7de-6e839b782888', 'gaming');
INSERT INTO public.tag (tag_id, tag) VALUES ('08846a00-e6f8-4474-ab95-83486f701b8c', 'workstation');
INSERT INTO public.tag (tag_id, tag) VALUES ('dc9bff23-f812-48ff-8da5-36119254fabb', 'games');
INSERT INTO public.tag (tag_id, tag) VALUES ('b38f667d-3676-41df-87ee-e5be3c49a14c', 'pc');
INSERT INTO public.tag (tag_id, tag) VALUES ('d09dd9a9-d754-4f32-a2ca-5076293e4002', 'case');
INSERT INTO public.tag (tag_id, tag) VALUES ('d79c919d-7f55-41fc-bcce-5fd3ba8d1ef5', 'hard');
INSERT INTO public.tag (tag_id, tag) VALUES ('8b7e845a-3359-4e5a-83e8-a37127582028', 'disk');
-- Tags

INSERT INTO public.producttag (product_id, tag_id) VALUES ('5f6aff49-c20b-456d-8938-dea885941365', '52fd88ca-b9ba-4ba3-81fb-05c2dffad9f6');
INSERT INTO public.producttag (product_id, tag_id) VALUES ('5f6aff49-c20b-456d-8938-dea885941365', 'c1fff244-dfb0-4ed0-8433-6066b7f8fca7');
INSERT INTO public.producttag (product_id, tag_id) VALUES ('5f6aff49-c20b-456d-8938-dea885941365', '6ab6980f-c2d1-4e46-8bfb-958fe8f527e4');
INSERT INTO public.producttag (product_id, tag_id) VALUES ('738426aa-35ea-4d96-b839-d0902d084672', '466db086-e1d2-49ca-8133-6489eca0fa69');
INSERT INTO public.producttag (product_id, tag_id) VALUES ('738426aa-35ea-4d96-b839-d0902d084672', '7361a39e-4205-4cbe-8a48-62a762fa4b1d');
INSERT INTO public.producttag (product_id, tag_id) VALUES ('738426aa-35ea-4d96-b839-d0902d084672', 'd73d96d9-0b90-42f2-963e-07c6d3d157ad');
INSERT INTO public.producttag (product_id, tag_id) VALUES ('1f6c20e0-8af5-4ad6-ae98-026bc7741670', '466db086-e1d2-49ca-8133-6489eca0fa69');
INSERT INTO public.producttag (product_id, tag_id) VALUES ('1f6c20e0-8af5-4ad6-ae98-026bc7741670', '52fd88ca-b9ba-4ba3-81fb-05c2dffad9f6');
INSERT INTO public.producttag (product_id, tag_id) VALUES ('18fdb12a-f34f-441e-adf3-01106905e5e5', '466db086-e1d2-49ca-8133-6489eca0fa69');
INSERT INTO public.producttag (product_id, tag_id) VALUES ('18fdb12a-f34f-441e-adf3-01106905e5e5', '7361a39e-4205-4cbe-8a48-62a762fa4b1d');
INSERT INTO public.producttag (product_id, tag_id) VALUES ('18fdb12a-f34f-441e-adf3-01106905e5e5', 'd73d96d9-0b90-42f2-963e-07c6d3d157ad');
INSERT INTO public.producttag (product_id, tag_id) VALUES ('529c3f21-ff14-4976-a8d5-8b56b7bab356', '52fd88ca-b9ba-4ba3-81fb-05c2dffad9f6');
INSERT INTO public.producttag (product_id, tag_id) VALUES ('529c3f21-ff14-4976-a8d5-8b56b7bab356', '6ab6980f-c2d1-4e46-8bfb-958fe8f527e4');
INSERT INTO public.producttag (product_id, tag_id) VALUES ('529c3f21-ff14-4976-a8d5-8b56b7bab356', 'c1fff244-dfb0-4ed0-8433-6066b7f8fca7');
INSERT INTO public.producttag (product_id, tag_id) VALUES ('06945798-726c-4ce4-9bb5-ba0ef2da97e9', 'c8ceb7bd-2090-41e7-a9a6-af657abb62de');
INSERT INTO public.producttag (product_id, tag_id) VALUES ('06945798-726c-4ce4-9bb5-ba0ef2da97e9', '65e6deda-4dd6-41bd-8c63-5a5f96561712');
INSERT INTO public.producttag (product_id, tag_id) VALUES ('4ca81e74-fa61-4747-851c-9212457aebfb', 'c8ceb7bd-2090-41e7-a9a6-af657abb62de');
INSERT INTO public.producttag (product_id, tag_id) VALUES ('4ca81e74-fa61-4747-851c-9212457aebfb', '65e6deda-4dd6-41bd-8c63-5a5f96561712');
INSERT INTO public.producttag (product_id, tag_id) VALUES ('3ec1789e-f976-4e3e-84bf-ac0b566b4189', 'c8ceb7bd-2090-41e7-a9a6-af657abb62de');
INSERT INTO public.producttag (product_id, tag_id) VALUES ('3ec1789e-f976-4e3e-84bf-ac0b566b4189', '65e6deda-4dd6-41bd-8c63-5a5f96561712');
INSERT INTO public.producttag (product_id, tag_id) VALUES ('9e1c2494-fcb6-4af6-9b3c-16c1695c32c7', 'c8ceb7bd-2090-41e7-a9a6-af657abb62de');
INSERT INTO public.producttag (product_id, tag_id) VALUES ('9e1c2494-fcb6-4af6-9b3c-16c1695c32c7', '65e6deda-4dd6-41bd-8c63-5a5f96561712');
INSERT INTO public.producttag (product_id, tag_id) VALUES ('9ece6c0b-7c80-4c3c-afe1-33abfcd52fac', 'de2d616d-8d5f-4323-8b43-53d95ffe0013');
INSERT INTO public.producttag (product_id, tag_id) VALUES ('9ece6c0b-7c80-4c3c-afe1-33abfcd52fac', '987b2540-5ef1-4963-95a7-2dcce5dcf97c');
INSERT INTO public.producttag (product_id, tag_id) VALUES ('86b4d6b3-ce8c-46fe-92c6-13c5310a43b9', 'c2c37357-fb20-4e74-87fd-a96153dc5238');
INSERT INTO public.producttag (product_id, tag_id) VALUES ('86b4d6b3-ce8c-46fe-92c6-13c5310a43b9', '987b2540-5ef1-4963-95a7-2dcce5dcf97c');
INSERT INTO public.producttag (product_id, tag_id) VALUES ('ac616902-6f70-4fff-85fc-2e46ed0e3d7e', 'bd1a378b-f198-4fe6-9776-0414cc421038');
INSERT INTO public.producttag (product_id, tag_id) VALUES ('c6f66840-acfd-4e18-8a45-100138e4c54b', 'bd1a378b-f198-4fe6-9776-0414cc421038');
INSERT INTO public.producttag (product_id, tag_id) VALUES ('6f066264-fee9-4d75-8640-f9047e1b5904', 'bd1a378b-f198-4fe6-9776-0414cc421038');
INSERT INTO public.producttag (product_id, tag_id) VALUES ('78f1645e-8694-4e36-93e8-5f14dea416b8', '873c360f-73b5-42b1-b7de-6e839b782888');
INSERT INTO public.producttag (product_id, tag_id) VALUES ('78f1645e-8694-4e36-93e8-5f14dea416b8', '08846a00-e6f8-4474-ab95-83486f701b8c');
INSERT INTO public.producttag (product_id, tag_id) VALUES ('78f1645e-8694-4e36-93e8-5f14dea416b8', 'dc9bff23-f812-48ff-8da5-36119254fabb');
INSERT INTO public.producttag (product_id, tag_id) VALUES ('78f1645e-8694-4e36-93e8-5f14dea416b8', 'b38f667d-3676-41df-87ee-e5be3c49a14c');
INSERT INTO public.producttag (product_id, tag_id) VALUES ('45ee0b20-0530-4d90-b8e6-1bb406d8e870', 'd09dd9a9-d754-4f32-a2ca-5076293e4002');
INSERT INTO public.producttag (product_id, tag_id) VALUES ('43656a7f-e326-443a-b91b-54c31d6ca2e3', 'b38f667d-3676-41df-87ee-e5be3c49a14c');
INSERT INTO public.producttag (product_id, tag_id) VALUES ('43656a7f-e326-443a-b91b-54c31d6ca2e3', 'd09dd9a9-d754-4f32-a2ca-5076293e4002');
INSERT INTO public.producttag (product_id, tag_id) VALUES ('82ce8f16-b9cb-4c66-a2ba-b9608393bdc2', 'd79c919d-7f55-41fc-bcce-5fd3ba8d1ef5');
INSERT INTO public.producttag (product_id, tag_id) VALUES ('82ce8f16-b9cb-4c66-a2ba-b9608393bdc2', '8b7e845a-3359-4e5a-83e8-a37127582028');
-- Product Tags


delete from producttag where product_id='30a5ebdd-ad0a-479b-8e6c-476b4e5cffca';
delete from variant where product_id='30a5ebdd-ad0a-479b-8e6c-476b4e5cffca';
delete from productimage where product_id='30a5ebdd-ad0a-479b-8e6c-476b4e5cffca';
delete from productcategory where product_id='30a5ebdd-ad0a-479b-8e6c-476b4e5cffca';
delete from visitedproduct where product_id='30a5ebdd-ad0a-479b-8e6c-476b4e5cffca';
delete from product where product_id='30a5ebdd-ad0a-479b-8e6c-476b4e5cffca';






INSERT INTO public.product (
    product_id,
    title,
    description,
    weight_kilos,
    brand,
    added_date
  )
VALUES
  (
    '51107a91-bff2-4b6e-94f0-18d2eb13e26a',
    'Bose QuietComfort 35 II Wireless Bluetooth Headphones, Noise-Cancelling, with Alexa voice control, enabled with Bose AR',
    'Bose QuietComfort 35 II Wireless Bluetooth Headphones, Noise-Cancelling, with Alexa voice control, enabled with Bose AR',
    0.30,
    'Bose',
    '2020-01-01 12:50:02.101429'
  );
INSERT INTO public.product (
    product_id,
    title,
    description,
    weight_kilos,
    brand,
    added_date
  )
VALUES
  (
    'eeb0e488-a73f-42d6-b45a-7939f099d214',
    'Mpow 059 Bluetooth Headphones Over Ear, Hi-Fi Stereo Wireless Headset, Foldable, Soft Memory-Protein Earmuffs, w/Built-in Mic Wired Mode PC/Cell Phones/TV',
    'IMPRESSIVE SOUND QUALITY IS THE ULTIMATE GOAL: The High-fidelity stereo sound benefits from the 40mm neodymium driver, CSR chip, and the around-ear cushion design which provide a well-closed and immersed enviroment for your ears, Just lose yourself in the music! NOTE: Mpow 059 headphones is passive noise isolating, NOT active noise cancellation(ANC), it can''t cancel the noise completely but it won''t drain the battery and damage the sound. 2. The closed-back design provides immersive Hi-Fi sound with CSR chip and 40mm driver together, it is better than ANC in term of sounds quality.',
    0.20,
    'Mpow',
    '2020-01-01 12:57:23.844329'
  );
INSERT INTO public.product (
    product_id,
    title,
    description,
    weight_kilos,
    brand,
    added_date
  )
VALUES
  (
    '40302d39-b546-4919-8643-f6381ad58913',
    'Samsung DVD-VR375/DVD-VR375A Tunerless DVD Recorder VHS Combo',
    'Samsung DVD-VR375/DVD-VR375A Tunerless DVD Recorder VHS Combo',
    1.00,
    'Samsung',
    '2020-01-01 13:05:02.649361'
  );
INSERT INTO public.product (
    product_id,
    title,
    description,
    weight_kilos,
    brand,
    added_date
  )
VALUES
  (
    '4e160a95-2cbd-4c1e-9b09-b5909896ea30',
    'ELECTCOM DVD Player, DVD Player for TV HDMI with Remote, Region Free DVD Player USB',
    'πÇÉIMMERSIVE VIDEO EXPERIENCEπÇæThis Region Free DVD player features 1080p to experience near HD picture quality and solid sound in a compact design. This Region Free DVD player shows subtle shades and smoother graduation of colors, resulting in a more vibrant and natural picture. Providing you with multiple video output connections.

πÇÉSUPER COMPATIBLEπÇæThis Region Free DVD player works as DVD player, CD player, U disk files player. This Region Free DVD player allow you to play distinctive file formats including DVD/DVD+RW/DVD-RW/DVD+R/DVD-R/HDCD/VCD/CD/CD+R/CD-R/MP3/KODAK PICTURE CD/DIVX for maximum viewing and listening pleasure.',
    1.50,
    'ELECTCOM',
    '2020-01-01 13:14:19.877123'
  );
INSERT INTO public.product (
    product_id,
    title,
    description,
    weight_kilos,
    brand,
    added_date
  )
VALUES
  (
    '68437cbe-8dc1-4320-bdbf-ed4e3f3a94e6',
    'LG Electronics 24LH4830-PU 24-Inch Smart LED TV (2016 Model)',
    '24 Inch Simple Smart LED HD TV

Screen Share (Miracast & WiDi)

Wi-Fi Direct

Wide Viewing Angle Screen

HDMI (x2)

TV with Stand (WxHxD) 21.9" x 5.',
    2.00,
    'LG',
    '2020-01-01 13:18:38.929729'
  );
INSERT INTO public.product (
    product_id,
    title,
    description,
    weight_kilos,
    brand,
    added_date
  )
VALUES
  (
    '68d3cd99-6fa3-4fab-b44f-23916e34acd7',
    'Sony KDL32W600D 32-Inch HD Smart TV - Black',
    'Beautiful HD TV with the clarity and sharpness of X-Reality PRO, Access YouTube and more with built-in Wi-Fi

Living-room friendly, slim design, Keep wires out of sight, Precise motion clarity with Motion flow XR 240. No MHL

Enjoy pure, natural audio with smooth reproduction. Wi-Fi Standard : Wi-Fi Certified 802.11b/g/n. HDCP : HDCP1.4

Operating System: Linux. Sleep timer - yes',
    5.00,
    'Sony',
    '2020-01-01 13:23:43.85259'
  );
INSERT INTO public.product (
    product_id,
    title,
    description,
    weight_kilos,
    brand,
    added_date
  )
VALUES
  (
    '311a6378-14b2-4884-8884-a71741691dcf',
    'Hisense 40H5590F 40-inch 1080p Android Smart LED TV (2019)',
    'Hisense 40H5590F 40-inch 1080p Android Smart LED TV (2019)',
    5.00,
    'Hisense',
    '2020-01-01 13:27:42.678863'
  );
INSERT INTO public.product (
    product_id,
    title,
    description,
    weight_kilos,
    brand,
    added_date
  )
VALUES
  (
    '0c3529a6-604e-4d82-aa47-2e156e75174a',
    'Becko Puzzle Roll Jigsaw Storage Felt Mat, Jigroll Up to 1,500 Pieces, Environmental Friendly Material for Jigsaw Puzzle Player, Box with Drawstring Storage Bag',
    'Becko Puzzle Roll Jigsaw Storage Felt Mat, Jigroll Up to 1,500 Pieces, Environmental Friendly Material for Jigsaw Puzzle Player, Box with Drawstring Storage Bag',
    0.30,
    'Becko',
    '2020-01-01 13:35:07.99173'
  );
INSERT INTO public.product (
    product_id,
    title,
    description,
    weight_kilos,
    brand,
    added_date
  )
VALUES
  (
    'ba3251e2-dd59-4861-8e7e-0c8b5cd93ce9',
    'D-FantiX Cyclone Boys 3x3 Speed Cube Stickerless Magic Cube 3x3x3 Puzzles Toys (56mm)',
    'D-FantiX Cyclone Boys 3x3 Speed Cube Stickerless Magic Cube 3x3x3 Puzzles Toys (56mm)',
    0.20,
    'FantiX',
    '2020-01-01 13:37:44.929551'
  );
INSERT INTO public.product (
    product_id,
    title,
    description,
    weight_kilos,
    brand,
    added_date
  )
VALUES
  (
    '50c06458-db27-489e-aa16-be3e418597fd',
    'Coogam Wooden Tetris Puzzle Brain Teasers Toy Tangram Jigsaw Intelligence Colorful 3D Russian Blocks Game STEM Montessori Educational Gift for Baby Kids',
    'The simple design and bright colors are perfect for sparking any imagination, and it feels great to challenge kids with this tangram jigsaw puzzle but also to just take on an easy challenge that you can complete differently every time. Perfect for times when you or your child just need to calm down or relax.

Geometric Assembling Russian Blocks use common geometric patterns and colors to keep children busy for different options to play. Solving it themselves helps to keep kidsΓÇÖ brain focused and adds creativity to eye-hand coordination and color & shape recognition. It''s better than on screen!

Awesome wooden Intelligence puzzle for kids, and great fidget toy for adults. This traditional teaching mathematics puzzle always being attracted in both young kids and elderly people. Perfect ultimate gift idea as Christmas Gift / Birthday Gift/ Festival Gift.',
    0.35,
    'Coogam',
    '2020-01-01 13:41:52.615664'
  );
---------------------------------------------------------------------------
INSERT INTO public.productimage (image_id, product_id, image_url)
VALUES
  (
    'f3084a8b-95e4-4b2c-881d-b776a7a9f6c1',
    '51107a91-bff2-4b6e-94f0-18d2eb13e26a',
    'https://images-na.ssl-images-amazon.com/images/I/61F4RAS5snL._SL1000_.jpg'
  );
INSERT INTO public.productimage (image_id, product_id, image_url)
VALUES
  (
    'bff610c0-f842-494c-8768-bf6ad0cbd646',
    'eeb0e488-a73f-42d6-b45a-7939f099d214',
    'https://images-na.ssl-images-amazon.com/images/I/61S3vMe2vgL._SL1280_.jpg'
  );
INSERT INTO public.productimage (image_id, product_id, image_url)
VALUES
  (
    'a397e785-5cb9-46b7-ba9f-35696d28fa30',
    '40302d39-b546-4919-8643-f6381ad58913',
    'https://images-na.ssl-images-amazon.com/images/I/319zwaj98JL.jpg'
  );
INSERT INTO public.productimage (image_id, product_id, image_url)
VALUES
  (
    '4209129c-48ad-495b-9227-a79233458ff1',
    '4e160a95-2cbd-4c1e-9b09-b5909896ea30',
    'https://images-na.ssl-images-amazon.com/images/I/61YQyhH4P3L._SL1000_.jpg'
  );
INSERT INTO public.productimage (image_id, product_id, image_url)
VALUES
  (
    '5956a469-a648-4e78-b042-a086fd8676e2',
    '68437cbe-8dc1-4320-bdbf-ed4e3f3a94e6',
    'https://images-na.ssl-images-amazon.com/images/I/810nIV2UfVL._SL1500_.jpg'
  );
INSERT INTO public.productimage (image_id, product_id, image_url)
VALUES
  (
    'a41cb5a7-6a31-49de-b0bd-5b4ae81a95b4',
    '68d3cd99-6fa3-4fab-b44f-23916e34acd7',
    'https://images-na.ssl-images-amazon.com/images/I/81oa9MlP9XL._SL1500_.jpg'
  );
INSERT INTO public.productimage (image_id, product_id, image_url)
VALUES
  (
    '5110b009-8e06-4564-90a8-934ed24834ad',
    '311a6378-14b2-4884-8884-a71741691dcf',
    'https://images-na.ssl-images-amazon.com/images/I/71ZRTMwE3NL._SL1500_.jpg'
  );
INSERT INTO public.productimage (image_id, product_id, image_url)
VALUES
  (
    '1df55657-7f8b-4cda-97ff-fb901d8b85a5',
    '311a6378-14b2-4884-8884-a71741691dcf',
    'https://images-na.ssl-images-amazon.com/images/I/81cWMLiflNL._SL1500_.jpg'
  );
INSERT INTO public.productimage (image_id, product_id, image_url)
VALUES
  (
    '71142e69-26cb-4ac4-80d3-108a243c1c5b',
    '0c3529a6-604e-4d82-aa47-2e156e75174a',
    'https://images-na.ssl-images-amazon.com/images/I/81svMasJVLL._SL1500_.jpg'
  );
INSERT INTO public.productimage (image_id, product_id, image_url)
VALUES
  (
    'a946f7da-8330-4559-a1c5-cdd9e9ee0251',
    '0c3529a6-604e-4d82-aa47-2e156e75174a',
    'https://images-na.ssl-images-amazon.com/images/I/81SQczLeuCL._SL1500_.jpg'
  );
INSERT INTO public.productimage (image_id, product_id, image_url)
VALUES
  (
    '5356d179-dc46-463a-bb05-d0bc12f66326',
    'ba3251e2-dd59-4861-8e7e-0c8b5cd93ce9',
    'https://images-na.ssl-images-amazon.com/images/I/510d4FRcqUL._SL1000_.jpg'
  );
INSERT INTO public.productimage (image_id, product_id, image_url)
VALUES
  (
    '528b5fe9-bb2c-4f20-9640-a1bcb4fa94bf',
    '50c06458-db27-489e-aa16-be3e418597fd',
    'https://images-na.ssl-images-amazon.com/images/I/61eO9R4k-RL._SL1000_.jpg'
  );
INSERT INTO public.productimage (image_id, product_id, image_url)
VALUES
  (
    'abee4fa0-460f-4fdc-aca5-b677065b05d3',
    '50c06458-db27-489e-aa16-be3e418597fd',
    'https://images-na.ssl-images-amazon.com/images/I/61mQVJl0cEL._SL1000_.jpg'
  );
-----------------------------------------------------------
INSERT INTO public.variant (
    variant_id,
    product_id,
    sku_id,
    quantity,
    title,
    listed_price,
    selling_price
  )
VALUES
  (
    '9e86aba5-f372-4a2d-b2a8-41409e3d1a22',
    '51107a91-bff2-4b6e-94f0-18d2eb13e26a',
    '74822057',
    23,
    'Black',
    50000.00,
    45000.00
  );
INSERT INTO public.variant (
    variant_id,
    product_id,
    sku_id,
    quantity,
    title,
    listed_price,
    selling_price
  )
VALUES
  (
    '848d658f-f09f-4725-919d-e80cfdd05465',
    '51107a91-bff2-4b6e-94f0-18d2eb13e26a',
    '95731867',
    21,
    'Black',
    48000.00,
    44000.00
  );
INSERT INTO public.variant (
    variant_id,
    product_id,
    sku_id,
    quantity,
    title,
    listed_price,
    selling_price
  )
VALUES
  (
    'fddffddb-0db9-4c6e-98af-68af3dca5536',
    '51107a91-bff2-4b6e-94f0-18d2eb13e26a',
    '95731845',
    12,
    'White',
    49000.00,
    45500.00
  );
INSERT INTO public.variant (
    variant_id,
    product_id,
    sku_id,
    quantity,
    title,
    listed_price,
    selling_price
  )
VALUES
  (
    '72302698-cd31-4830-94b6-3cbe827cfd03',
    '51107a91-bff2-4b6e-94f0-18d2eb13e26a',
    '95731878',
    15,
    'Red',
    50000.00,
    46000.00
  );
INSERT INTO public.variant (
    variant_id,
    product_id,
    sku_id,
    quantity,
    title,
    listed_price,
    selling_price
  )
VALUES
  (
    'b568a441-3a2f-4a5c-8552-0ccf883e7d6c',
    'eeb0e488-a73f-42d6-b45a-7939f099d214',
    '34765458',
    65,
    'Black',
    10000.00,
    9500.00
  );
INSERT INTO public.variant (
    variant_id,
    product_id,
    sku_id,
    quantity,
    title,
    listed_price,
    selling_price
  )
VALUES
  (
    'e9291577-cfcd-4c7f-bf77-ab538a399d6c',
    'eeb0e488-a73f-42d6-b45a-7939f099d214',
    '28308013',
    68,
    'Black',
    9500.00,
    9000.00
  );
INSERT INTO public.variant (
    variant_id,
    product_id,
    sku_id,
    quantity,
    title,
    listed_price,
    selling_price
  )
VALUES
  (
    'ea2c0713-7dc7-4f62-b918-2dd794ce8f6a',
    'eeb0e488-a73f-42d6-b45a-7939f099d214',
    '28308078',
    57,
    'White',
    9500.00,
    9100.00
  );
INSERT INTO public.variant (
    variant_id,
    product_id,
    sku_id,
    quantity,
    title,
    listed_price,
    selling_price
  )
VALUES
  (
    '78e8f9d6-6a8d-48c9-b339-9d005c25c21d',
    'eeb0e488-a73f-42d6-b45a-7939f099d214',
    '28308034',
    90,
    'Red',
    9500.00,
    9400.00
  );
INSERT INTO public.variant (
    variant_id,
    product_id,
    sku_id,
    quantity,
    title,
    listed_price,
    selling_price
  )
VALUES
  (
    '28d77f08-d674-4f3d-a10e-e8f1433f4ad2',
    '40302d39-b546-4919-8643-f6381ad58913',
    '62151691',
    45,
    'Black',
    35000.00,
    34000.00
  );
INSERT INTO public.variant (
    variant_id,
    product_id,
    sku_id,
    quantity,
    title,
    listed_price,
    selling_price
  )
VALUES
  (
    '0940bbb9-5104-4078-bab5-f5ec7a67b255',
    '40302d39-b546-4919-8643-f6381ad58913',
    '62151678',
    56,
    'White',
    34000.00,
    33000.00
  );
INSERT INTO public.variant (
    variant_id,
    product_id,
    sku_id,
    quantity,
    title,
    listed_price,
    selling_price
  )
VALUES
  (
    'accf02f7-bf7e-4495-b7ed-9e0424165340',
    '4e160a95-2cbd-4c1e-9b09-b5909896ea30',
    '74822678',
    54,
    'Black',
    3500.00,
    3400.00
  );
INSERT INTO public.variant (
    variant_id,
    product_id,
    sku_id,
    quantity,
    title,
    listed_price,
    selling_price
  )
VALUES
  (
    '2bf183da-665b-4464-985b-77cac1dc1cfb',
    '4e160a95-2cbd-4c1e-9b09-b5909896ea30',
    '78485341',
    54,
    'Red',
    3000.00,
    2700.00
  );
INSERT INTO public.variant (
    variant_id,
    product_id,
    sku_id,
    quantity,
    title,
    listed_price,
    selling_price
  )
VALUES
  (
    '60e74cfc-9f7f-4f10-8c13-2540ba083c05',
    '68437cbe-8dc1-4320-bdbf-ed4e3f3a94e6',
    '13695122',
    34,
    'Black',
    40000.00,
    39000.00
  );
INSERT INTO public.variant (
    variant_id,
    product_id,
    sku_id,
    quantity,
    title,
    listed_price,
    selling_price
  )
VALUES
  (
    '19622108-857c-471b-83f6-c3208775be7a',
    '68437cbe-8dc1-4320-bdbf-ed4e3f3a94e6',
    '81172020',
    34,
    'Red',
    45000.00,
    44000.00
  );
INSERT INTO public.variant (
    variant_id,
    product_id,
    sku_id,
    quantity,
    title,
    listed_price,
    selling_price
  )
VALUES
  (
    'e77e61a9-18ee-4b3e-a196-a545dca96424',
    '68d3cd99-6fa3-4fab-b44f-23916e34acd7',
    '30443722',
    16,
    '32"',
    55000.00,
    54000.00
  );
INSERT INTO public.variant (
    variant_id,
    product_id,
    sku_id,
    quantity,
    title,
    listed_price,
    selling_price
  )
VALUES
  (
    '62854078-4e75-418e-aaf3-3f8347b90322',
    '68d3cd99-6fa3-4fab-b44f-23916e34acd7',
    '30443778',
    26,
    '42"',
    53000.00,
    52000.00
  );
INSERT INTO public.variant (
    variant_id,
    product_id,
    sku_id,
    quantity,
    title,
    listed_price,
    selling_price
  )
VALUES
  (
    '5152807d-b6b2-4d0a-80fa-80824f778b8d',
    '311a6378-14b2-4884-8884-a71741691dcf',
    '72916977',
    15,
    '42"',
    55000.00,
    53000.00
  );
INSERT INTO public.variant (
    variant_id,
    product_id,
    sku_id,
    quantity,
    title,
    listed_price,
    selling_price
  )
VALUES
  (
    'b92980b6-09ab-4232-ae01-2ea480646f70',
    '311a6378-14b2-4884-8884-a71741691dcf',
    '72916989',
    13,
    '64"',
    75000.00,
    73000.00
  );
INSERT INTO public.variant (
    variant_id,
    product_id,
    sku_id,
    quantity,
    title,
    listed_price,
    selling_price
  )
VALUES
  (
    'a35e052a-d8e7-4bb2-abed-286fb3e19a48',
    '0c3529a6-604e-4d82-aa47-2e156e75174a',
    '42534442',
    60,
    'Default',
    2500.00,
    2300.00
  );
INSERT INTO public.variant (
    variant_id,
    product_id,
    sku_id,
    quantity,
    title,
    listed_price,
    selling_price
  )
VALUES
  (
    '92f7fccf-4898-4268-b74d-e3ffc61c3d70',
    'ba3251e2-dd59-4861-8e7e-0c8b5cd93ce9',
    '25304371',
    67,
    'Defalut',
    1000.00,
    900.00
  );
INSERT INTO public.variant (
    variant_id,
    product_id,
    sku_id,
    quantity,
    title,
    listed_price,
    selling_price
  )
VALUES
  (
    '841e5b7b-44cd-46ba-8e6f-fa95d29f4e72',
    '50c06458-db27-489e-aa16-be3e418597fd',
    '94061339',
    45,
    'Default',
    900.00,
    850.00
  );
-----------------------------------------------------
INSERT INTO public.productcategory (category_id, product_id)
VALUES
  (
    '24b84249-c629-4b84-991c-673c0bf73081',
    '51107a91-bff2-4b6e-94f0-18d2eb13e26a'
  );
INSERT INTO public.productcategory (category_id, product_id)
VALUES
  (
    '24b84249-c629-4b84-991c-673c0bf73081',
    'eeb0e488-a73f-42d6-b45a-7939f099d214'
  );
INSERT INTO public.productcategory (category_id, product_id)
VALUES
  (
    '3a9bce2a-624e-40a0-9fa5-25e7db99ceb9',
    '68437cbe-8dc1-4320-bdbf-ed4e3f3a94e6'
  );
INSERT INTO public.productcategory (category_id, product_id)
VALUES
  (
    '3a9bce2a-624e-40a0-9fa5-25e7db99ceb9',
    '68d3cd99-6fa3-4fab-b44f-23916e34acd7'
  );
INSERT INTO public.productcategory (category_id, product_id)
VALUES
  (
    '3a9bce2a-624e-40a0-9fa5-25e7db99ceb9',
    '311a6378-14b2-4884-8884-a71741691dcf'
  );
INSERT INTO public.productcategory (category_id, product_id)
VALUES
  (
    '52426a68-76a5-4813-9943-b67f952d766b',
    '4e160a95-2cbd-4c1e-9b09-b5909896ea30'
  ); 
INSERT INTO public.productcategory (category_id, product_id)
VALUES
  (
    '0e82c1f2-89c3-44e3-9fe5-922b1f259296',
    '40302d39-b546-4919-8643-f6381ad58913'
  );
INSERT INTO public.productcategory (category_id, product_id)
VALUES
  (
    '48083624-045c-48d8-8b09-1b9baa46c266',
    '0c3529a6-604e-4d82-aa47-2e156e75174a'
  );
INSERT INTO public.productcategory (category_id, product_id)
VALUES
  (
    '48083624-045c-48d8-8b09-1b9baa46c266',
    'ba3251e2-dd59-4861-8e7e-0c8b5cd93ce9'
  );
INSERT INTO public.productcategory (category_id, product_id)
VALUES
  (
    '48083624-045c-48d8-8b09-1b9baa46c266',
    '50c06458-db27-489e-aa16-be3e418597fd'
  );
----------------------------------------------
INSERT INTO public.tag (tag_id, tag)
VALUES
  (
    '30d76955-ad93-41b7-8e8a-d4bbbf93c3dc',
    'noicecancellling'
  );
INSERT INTO public.tag (tag_id, tag)
VALUES
  ('4cfdd485-f829-4a0c-9fa8-45a83c2bbc87', 'bose');
INSERT INTO public.tag (tag_id, tag)
VALUES
  (
    '07a6ba6c-ec86-4d55-8b3c-f1b51d21aebd',
    'blutooth'
  );
INSERT INTO public.tag (tag_id, tag)
VALUES
  ('d0bee308-6c6c-4c78-b622-160072dfe955', 'dvd');
INSERT INTO public.tag (tag_id, tag)
VALUES
  ('a5a2cc5a-46f6-4b02-b5e0-fd64c7b17993', 'smart');
------------------------------------------------------
INSERT INTO public.producttag (product_id, tag_id)
VALUES
  (
    '51107a91-bff2-4b6e-94f0-18d2eb13e26a',
    '30d76955-ad93-41b7-8e8a-d4bbbf93c3dc'
  );
INSERT INTO public.producttag (product_id, tag_id)
VALUES
  (
    '51107a91-bff2-4b6e-94f0-18d2eb13e26a',
    '4cfdd485-f829-4a0c-9fa8-45a83c2bbc87'
  );
INSERT INTO public.producttag (product_id, tag_id)
VALUES
  (
    'eeb0e488-a73f-42d6-b45a-7939f099d214',
    '07a6ba6c-ec86-4d55-8b3c-f1b51d21aebd'
  );
INSERT INTO public.producttag (product_id, tag_id)
VALUES
  (
    '40302d39-b546-4919-8643-f6381ad58913',
    'd0bee308-6c6c-4c78-b622-160072dfe955'
  );
INSERT INTO public.producttag (product_id, tag_id)
VALUES
  (
    '68437cbe-8dc1-4320-bdbf-ed4e3f3a94e6',
    'a5a2cc5a-46f6-4b02-b5e0-fd64c7b17993'
  );








INSERT INTO public.product (product_id, title, description, weight_kilos, brand, added_date) VALUES ('183c1d6b-3eba-4b9b-8d3a-b58f7eb9deca', 'Edushape See-Me Sensory Balls, 4 Inch, Translucent, 4 Ball Set', 'plastic

SENSORY ENGAGEMENT: Nubbly surface engages the senses and enhances tactile development

MOTOR SKILL DEVELOPMENT: Gripping, tossing, bouncing, and rolling encourage growth of fine and gross motor skills

ENHANCE LOGIC AND REASONING: Rolling, tracking, and bouncing enhance hand-eye coordination, visual sensory development, and logic & reasoning skills

VISUALLY STIMULATING: Bright, colorful design engages visual senses and encourages color recognition skills

Contains 4 pieces; Recommended for ages 6 months and up; Edushape products are made with BPA and phthalate free plastic', 0.35, 'Edushape ', '2020-01-01 13:09:50.230688');
INSERT INTO public.product (product_id, title, description, weight_kilos, brand, added_date) VALUES ('f1175767-1333-438d-9125-2f16cd1d416c', 'BalanceFrom 2.3-Inch Phthalate Free BPA Free Non-Toxic Crush Proof Play Balls Pit Balls', 'Safety - Made from non-toxic material, non-recycled & non-PVC plastic, BPA free, Phthalate free and lead free

Colorful - each ball measures 2. 3 inches in diameter, a perfect size for small child''s hand. 6 bright & attractive Colors: blue, red, pink, green, orange and yellow

Quality - crush-proof balls are designed to withstand ~100lbs that is strong enough for adult and soft enough for children

Organize - strong and reusable mesh bag for re-storing the balls when not in Use. Great for filling any ball pit, tent, playhouse, kiddie pool, playpen and bounce house

Happiness - All genuine Balance From products are covered by a 100% Balance From satisfaction support and 2-year Balance From support', 3.00, 'BalanceFrom', '2020-01-01 13:15:52.927203');
INSERT INTO public.product (product_id, title, description, weight_kilos, brand, added_date) VALUES ('7f7db4e0-4008-4612-b286-47a7a3e65408', 'ForeverSpin Titanium Spinning Top - World Famous Spinning Tops', 'TIMELESS ART — Your spinning top will forever remain a timeless, elegant piece of art that will be loved by you and your children''s children

PRECISION-MACHINED — Every top is checked for perfection. Tops are precision-machined using only the purest metals and alloys from around the world. Only the finest tops receive the ForeverSpinTM seal

BOOST CREATIVITY & FOCUS — According to recent studies, fiddling with items at your desk can aid in thought process and improve productivity!

CHALLENGE YOURSELF — We all love to challenge ourselves. Beat your own spin times or, better yet, compete with your friends for pizza or drinks

THE PERFECT SIZE — Dimensions expertly calculated to allow for minimal friction and stress on the tops'' tips while still allowing handling with hands of all sizes. 1.4 tall" x 1.125" diameter. 0.6oz.', 0.10, 'ForeverSpin ', '2020-01-01 13:22:09.499674');
INSERT INTO public.product (product_id, title, description, weight_kilos, brand, added_date) VALUES ('6fd11314-3b1d-4efc-854a-2c27607fc951', '12 PCS Handmade Painted Wood Spinning Tops, Kids Novelty Wooden Colorful Gyroscopes Toy, Assorted Standard Tops, Flip Tops, kindergarten education Toys - Great Party Favors, Fun, Gift, Prize', '12 fingertips gyro, rainbow color, to give you more fun.

Made of high quality lotus wood, tough, wear-resistant, non-cracking, environmentally friendly and safe waterborne paint, bright color, soft luster.

Size:Approx.1.8 x 1.6 inches, Material: wooden, Color: 6 different colors.

Small and delicate, polished, smooth, burr free, not hurt.

Fast rotation can show children different visual effects and enhance children''s hand eye coordination.', 0.05, ' PPXMEEUDC', '2020-01-01 13:26:52.304957');
INSERT INTO public.product (product_id, title, description, weight_kilos, brand, added_date) VALUES ('64376ad6-fa23-4667-ab3a-7cb70200ba92', 'Dwi Dowellin Baby Bath Toys Mold Free Fishing Games Water Pool Bathtub Toy for Toddlers Kids Infant Girls and Boys Fun Bath Time Bathroom Tub Wind Up Swimming Whales Fish Set', 'NO HOLES, MOLD FREE, MORE SAFER: These fish toys are completely sealed, so you don''t have to worry about water getting in and causing mold in them like those rubber squeeze squirt water toys do. Don'' t buy your baby a rubber squeeze squirt water toys any more as all babies first thing they do are put everything in their mouth when they are given a toy. Just imagine how dangerous if a toy gets moldy inside but your baby keeps it in mouth.

MAKE BATH TIME MORE FUN: The cute whale can swims through the tub once you clockwise rotate the small whale and release it in the water. Help to make bath time enjoyable, and it swims longer distance than other swimming toys do. (others: easy to be submerged and doesn'' t float for long.)

LEARNING TOYS FOR TODDLERS: Kids would try to hook fishes, at first hooking 1 fish, then 2 fishes, 3 fishes, which will strengthen kids confidence and patience and developing the hand-eye coordination and body balance ability. It also help toddlers to identify the blue, green, orange ''''fish'''' and catch each one when asked. Colorful and fun bath toys in the tub.

GREAT FOR PLAY AT ANYWHERE: This baby bath toys is great for in or out of the water. You can play it in bathtub, pool, beach or on the floor. If the floating fish is a little challenge for your little baby, then play fishing game on the floor now, and fishing in the water in not longer future. Bath toy set contains: 1pcs fishing pole, 1pcs fishing net, 4pcs fish(no holes) and 2pcs swimming whales. Suitable for baby Ages 18 months and up.

Quality Assurance: Order from Dwi Dowellin for a truly worry free experience. If there are any issues or you think everything is not as advertised, please feel free to contact us, we will refund every penny of your money or give you a replacement without charging. Just enjoy this absolutely RISK FREE purchase.', 0.10, ' Dwi Dowellin', '2020-01-01 13:33:25.103232');
INSERT INTO public.product (product_id, title, description, weight_kilos, brand, added_date) VALUES ('7d52e29e-34f2-4f02-ba6e-bb5dd8acd9ec', '3 Bees & Me Bath Toys for Boys and Girls - Magnet Boat Set for Toddlers & Kids - Fun & Educational', 'BEST VALUE - Why pay extra for separate toddler bath toys when you can get this most popular 4 boats in 1 playset deal today?

MAKES A GREAT GIFT - bathtime toys kids will play with and love you for! For every preschool boy or girl

SAFE FOR KIDS & THE ENVIRONMENT – certified BPA free, phthalate free and lead free and built to last!

EDUCATIONAL - Fun new way to learn about colors and numbers; enhances motor skills and imagination

SATISFACTION GUARANTEED - Order today. All 3 Bees and Me toys are 100% Risk Free. 60 Day Return. We stand behind our bathtub toys!', 0.10, '3 Bees & Me ', '2020-01-01 13:36:57.206503');
INSERT INTO public.product (product_id, title, description, weight_kilos, brand, added_date) VALUES ('37f067d6-03f6-42d2-a156-49058f42c9f5', 'CogAT Test Flash Cards - 4th - 5th Grade (Level 10-11) - 72 Cards - 140+ Practice Questions - Tips for Scoring Higher on The CogAT - Verbal, Non-Verbal and Quantitative Concepts', 'Teach children the verbal, quantitative and non-verbal concepts they need for the CogAT Form 7, CogAT Form 8, and other gifted and talented and GATE tests!

These cards will strengthen your child’s abilities in the following areas: Verbal Analogies, Sentence Completion, Verbal Classification; Number Analogies, Number Puzzles, Number Series, Figure Matrices, Paper Folding; Figure Classification and more.

Includes over 144 questions, learning activities and tips for scoring higher on the CogAT to reinforce verbal, quantitative and non-verbal concepts through playful parent-child interaction.

Not just for students taking the CogAT Test or applying to gifted programs - these cards cover the abilities all children are expected to demonstrate for 4th to 5th Grade readiness and success.

If the cards ever get dirty, you can easily wipe them off – the smudge proof finish makes them easy to clean.', 0.25, 'TeachingMom', '2020-01-01 13:41:42.240316');
INSERT INTO public.product (product_id, title, description, weight_kilos, brand, added_date) VALUES ('b1a5adcc-e409-4edb-92b8-81f0c9ac5398', 'Star Right Flash Cards Set of 4 - Numbers, Alphabets, First Words, Colors & Shapes - Value Pack Flash Cards with Rings for Pre K - K', '✔ FOUR FLASH CARDS SETS – These 4 sets will teach your 3-5 year old Math, Language and Basic Skills.

✔ MATH, BASIC SKILLS AND LANGUAGE – The numbers set will teach your child math. The Colors & Shapes will teach your child basic skills and the First Words and Alphabets will teach them language

✔ RINGS INCLUDED – This set of flash cards includes a ring for every set to keep it neat and organized and for easy sorting

✔ LARGE FONTS with REALISTIC ART – These flash cards are the perfect hand-held size with large, clear and bold fonts so it easy to see even from afar. The realistic art makes it exciting and practical for teaching your child.

✔ TEACH AND REVIEW – It is deal for teaching, reviewing and practicing sight words, in the classroom as a whole or each child individually or in groups, at their level.', 0.25, 'Star Right', '2020-01-01 13:44:30.701134');
INSERT INTO public.product (product_id, title, description, weight_kilos, brand, added_date) VALUES ('9ad61079-ef48-46aa-a6fb-2f099b00459d', 'Time2Play Wooden Musical Instruments for Toddlers, Children & Babies Includes 2 Maracas, 1 Tambourine, 2 Castanets, 1 Hand Bell Perfect Music Toys to Create a Wonderful Family Band', '✅ SET OF 6 MUSICAL INSTRUMENTS: Give your children the opportunity to learn rhythm and melody using Time2Play’s 6-piece musical set for babies. It includes 2 Castanets, 2 Maracas, 1 Tambourine, and 1 Handbell that will keep them occupied for hours.

✅ DISCOVER THE MUSICIAN IN YOUR BABY: Our assortment of musical instruments is a great way of introducing young children to music. Encourages rhythm and social interaction, and is great fun for jam sessions and group play. Lets your kids be the stars of the show. Makes for a creative, entertaining gift too.

✅ SAFE FOR YOUR CHILDREN: All the instruments in our musical set for toddlers have smooth, rounded corners making them completely safe for your children. You can therefore let them play unattended to without worrying that they will get injured.

✅ MADE WITH QUALITY MATERIALS: Our wooden children’s musical instruments are made using high quality wood. They are strong and sturdy, and we only used non-toxic paints on them. They can therefore take several bumps and drops and still look good.

✅ 100% MONEYBACK GUARANTEE: We are confident about the quality of our 6-piece musical set for babies and toddlers. That is why we are sure you will love it too. If you are not happy with it, please send it back and we will issue a full refund no questions asked. The recommended age is 3 years and up. Click ‘Add to Cart’ now.', 0.35, 'Time2Play ', '2020-01-01 13:51:08.577499');
INSERT INTO public.product (product_id, title, description, weight_kilos, brand, added_date) VALUES ('30a5ebdd-ad0a-479b-8e6c-476b4e5cffca', 'Woodstock Kid''s Accordion- Music Collection', 'From the Woodstock Music Collection, here''s a fun-yet-sensible introduction to the accordian

Detailed playing instructions and eight easy-to-play songs

This music machine is just the right size for young hands, has an authentic accordion sound and 2-octave range in the key of C

Includes detailed playing instructions and 8 easy-to-play songs', 1.00, 'Woodstock ', '2020-01-01 13:54:20.471921');
INSERT INTO public.product (product_id, title, description, weight_kilos, brand, added_date) VALUES ('8ea3c469-6790-43bc-99e1-4660e59403d8', 'Woodstock Kid''s Accordion- Music Collection', 'From the Woodstock Music Collection, here''s a fun-yet-sensible introduction to the accordian

Detailed playing instructions and eight easy-to-play songs

This music machine is just the right size for young hands, has an authentic accordion sound and 2-octave range in the key of C

Includes detailed playing instructions and 8 easy-to-play songs', 1.00, 'Woodstock', '2020-01-01 14:01:25.111221');
INSERT INTO public.product (product_id, title, description, weight_kilos, brand, added_date) VALUES ('7196948e-3011-4c86-a623-191fc4b4ccd0', 'Trend Enterprises Sight Words Bingo', 'Sight Words Level 1 includes 36 Playing Cards measuring 6.5 inches by 9 inches

Ideal for teaching

For ages 5 and up

Set includes 36 playing cards, 264 playing chips, caller''s mat and cards and a sturdy storage box', 1.00, 'Trend Enterprises', '2020-01-01 14:04:44.360005');
INSERT INTO public.product (product_id, title, description, weight_kilos, brand, added_date) VALUES ('a71c6a34-af43-4261-8ee5-34234bb5b61b', 'Brain Games Kids: Kindergarten Activity Workbook - PI Kids Spiral-bound', 'Interactive questions are a great way to engage with your child

Content teaches new skills in reading comprehension, addition, subtraction, and more

Fold-over answers on each page let kindergartners test their knowledge and get immediate feedback', 1.00, 'Brain Games', '2020-01-01 14:07:41.562225');




--------------------------------------------------------------------



INSERT INTO public.productimage (image_id, product_id, image_url) VALUES ('57fa2548-fe64-404f-bba8-48a1eeee3170', '183c1d6b-3eba-4b9b-8d3a-b58f7eb9deca', 'https://images-na.ssl-images-amazon.com/images/I/91JUlsib-JL._SL1500_.jpg');
INSERT INTO public.productimage (image_id, product_id, image_url) VALUES ('03fa0099-230f-484e-9da9-715ee2f545b1', 'f1175767-1333-438d-9125-2f16cd1d416c', 'https://images-na.ssl-images-amazon.com/images/I/B1boTsIjuvS._SL1500_.jpg');
INSERT INTO public.productimage (image_id, product_id, image_url) VALUES ('63a55f91-26fa-4488-a53c-33d03ffec94f', '7f7db4e0-4008-4612-b286-47a7a3e65408', 'https://images-na.ssl-images-amazon.com/images/I/51uvscuhh4L._SL1000_.jpg');
INSERT INTO public.productimage (image_id, product_id, image_url) VALUES ('ffb16ba8-2334-4fa0-9231-c70ff7b0e901', '6fd11314-3b1d-4efc-854a-2c27607fc951', 'https://images-na.ssl-images-amazon.com/images/I/81cggcU7v9L._SL1500_.jpg');
INSERT INTO public.productimage (image_id, product_id, image_url) VALUES ('09ea6ae7-a275-437e-9712-215bc5b5aff6', '64376ad6-fa23-4667-ab3a-7cb70200ba92', 'https://images-na.ssl-images-amazon.com/images/I/61VJgM-XzAL._SL1300_.jpg');
INSERT INTO public.productimage (image_id, product_id, image_url) VALUES ('5e4f9c66-1669-473b-8e59-19dab57c3c0a', '7d52e29e-34f2-4f02-ba6e-bb5dd8acd9ec', 'https://images-na.ssl-images-amazon.com/images/I/71USy1M7XRL._SL1500_.jpg');
INSERT INTO public.productimage (image_id, product_id, image_url) VALUES ('460d9316-77d9-49b5-a97b-afc581100b84', '37f067d6-03f6-42d2-a156-49058f42c9f5', 'https://images-na.ssl-images-amazon.com/images/I/612jmxL%2BFbL.jpg');
INSERT INTO public.productimage (image_id, product_id, image_url) VALUES ('3a294953-6038-4be5-9ad9-728c58621d37', 'b1a5adcc-e409-4edb-92b8-81f0c9ac5398', 'https://images-na.ssl-images-amazon.com/images/I/81tHcFMdfML._SL1500_.jpg');
INSERT INTO public.productimage (image_id, product_id, image_url) VALUES ('fdeacce5-a30a-49ae-8be5-253cb3abd5a5', '9ad61079-ef48-46aa-a6fb-2f099b00459d', 'https://images-na.ssl-images-amazon.com/images/I/619cJlW4ZFL._SL1080_.jpg');
INSERT INTO public.productimage (image_id, product_id, image_url) VALUES ('38b286a0-b80c-4cbb-9311-7bd7dcfe7d77', '30a5ebdd-ad0a-479b-8e6c-476b4e5cffca', 'https://images-na.ssl-images-amazon.com/images/I/51-4ZXcUOwL.jpg');
INSERT INTO public.productimage (image_id, product_id, image_url) VALUES ('5d78470f-b10e-4270-95b2-10e939919cf7', '8ea3c469-6790-43bc-99e1-4660e59403d8', 'https://images-na.ssl-images-amazon.com/images/I/51-4ZXcUOwL.jpg');
INSERT INTO public.productimage (image_id, product_id, image_url) VALUES ('8ecc025d-24c7-4bef-b6c4-e088aedadbb5', '7196948e-3011-4c86-a623-191fc4b4ccd0', 'https://images-na.ssl-images-amazon.com/images/I/71S2E31-OyL._SL1000_.jpg');
INSERT INTO public.productimage (image_id, product_id, image_url) VALUES ('0b772f9a-1ec2-4018-b5e6-e889bfbf629b', 'a71c6a34-af43-4261-8ee5-34234bb5b61b', 'https://images-na.ssl-images-amazon.com/images/I/61OkEWYb%2BFL._SX258_BO1,204,203,200_.jpg');

--------------------------------------------------------------------------------------------------------

INSERT INTO public.variant (variant_id, product_id, sku_id, quantity, title, listed_price, selling_price) VALUES ('5e844822-dad4-4de1-b4f1-1312d5b8e3c9', '183c1d6b-3eba-4b9b-8d3a-b58f7eb9deca', '7875579', 78, 'Black', 400.00, 350.00);
INSERT INTO public.variant (variant_id, product_id, sku_id, quantity, title, listed_price, selling_price) VALUES ('456d7db3-c8d1-4d53-813c-963185e43d2a', '183c1d6b-3eba-4b9b-8d3a-b58f7eb9deca', '4181932', 35, 'white', 400.00, 375.00);
INSERT INTO public.variant (variant_id, product_id, sku_id, quantity, title, listed_price, selling_price) VALUES ('00d5cd80-00ba-468e-83fb-d63bbc37b08f', 'f1175767-1333-438d-9125-2f16cd1d416c', '9925572', 29, '200-count', 1600.00, 1550.00);
INSERT INTO public.variant (variant_id, product_id, sku_id, quantity, title, listed_price, selling_price) VALUES ('bec88942-978b-451c-bb99-1fa2fa3addf3', 'f1175767-1333-438d-9125-2f16cd1d416c', '446066', 34, '400-count', 3800.00, 3600.00);
INSERT INTO public.variant (variant_id, product_id, sku_id, quantity, title, listed_price, selling_price) VALUES ('d9383acd-c170-4c9a-9845-25ac48bbe3a5', '7f7db4e0-4008-4612-b286-47a7a3e65408', '841414', 100, 'Silver', 4800.00, 4700.00);
INSERT INTO public.variant (variant_id, product_id, sku_id, quantity, title, listed_price, selling_price) VALUES ('625847b0-a775-4a67-9f4b-fee5a83c3af8', '7f7db4e0-4008-4612-b286-47a7a3e65408', '590890', 56, 'Metal', 4900.00, 4700.00);
INSERT INTO public.variant (variant_id, product_id, sku_id, quantity, title, listed_price, selling_price) VALUES ('0cb8bd6f-1f58-42d9-ac23-e9574821b3eb', '6fd11314-3b1d-4efc-854a-2c27607fc951', '5886345', 45, 'Rainbow', 1500.00, 1400.00);
INSERT INTO public.variant (variant_id, product_id, sku_id, quantity, title, listed_price, selling_price) VALUES ('be5abb82-7fd5-4090-a752-7c8ad993f501', '6fd11314-3b1d-4efc-854a-2c27607fc951', '7640858', 56, 'strips', 1600.00, 1600.00);
INSERT INTO public.variant (variant_id, product_id, sku_id, quantity, title, listed_price, selling_price) VALUES ('5186494e-6210-4122-9069-c9ae7490803f', '64376ad6-fa23-4667-ab3a-7cb70200ba92', '8987369', 78, 'whales', 3700.00, 3650.00);
INSERT INTO public.variant (variant_id, product_id, sku_id, quantity, title, listed_price, selling_price) VALUES ('15bf9620-342f-42f9-b253-92eb8babccbb', '64376ad6-fa23-4667-ab3a-7cb70200ba92', '616156', 80, 'sharks', 1600.00, 1600.00);
INSERT INTO public.variant (variant_id, product_id, sku_id, quantity, title, listed_price, selling_price) VALUES ('ce085d06-fb77-4abf-bd6f-411777675e97', '7d52e29e-34f2-4f02-ba6e-bb5dd8acd9ec', '6030006', 45, 'solid', 2200.00, 2100.00);
INSERT INTO public.variant (variant_id, product_id, sku_id, quantity, title, listed_price, selling_price) VALUES ('77cb4180-6596-4718-b60f-7fb3c04bace5', '7d52e29e-34f2-4f02-ba6e-bb5dd8acd9ec', '8190622', 56, 'stripes', 2300.00, 2100.00);
INSERT INTO public.variant (variant_id, product_id, sku_id, quantity, title, listed_price, selling_price) VALUES ('de6e1d01-39de-49ff-a8e5-ac132080f9c6', '37f067d6-03f6-42d2-a156-49058f42c9f5', '5796538', 56, 'Small', 5700.00, 5600.00);
INSERT INTO public.variant (variant_id, product_id, sku_id, quantity, title, listed_price, selling_price) VALUES ('8cbf507e-6cea-43d4-81fe-ec125e241f2d', '37f067d6-03f6-42d2-a156-49058f42c9f5', '8107784', 23, 'large', 6800.00, 6900.00);
INSERT INTO public.variant (variant_id, product_id, sku_id, quantity, title, listed_price, selling_price) VALUES ('321215dd-aae4-4b41-9f6a-10fd22b18477', 'b1a5adcc-e409-4edb-92b8-81f0c9ac5398', '8008460', 56, 'Black', 1600.00, 1550.00);
INSERT INTO public.variant (variant_id, product_id, sku_id, quantity, title, listed_price, selling_price) VALUES ('d028cfa7-5dd0-40cc-aaf6-f52f24c3971f', 'b1a5adcc-e409-4edb-92b8-81f0c9ac5398', '8423680', 45, 'white', 1600.00, 1600.00);
INSERT INTO public.variant (variant_id, product_id, sku_id, quantity, title, listed_price, selling_price) VALUES ('f749105f-2fb0-497d-a8c6-d45c4fd8948c', '9ad61079-ef48-46aa-a6fb-2f099b00459d', '1267417', 78, 'small', 4600.00, 4500.00);
INSERT INTO public.variant (variant_id, product_id, sku_id, quantity, title, listed_price, selling_price) VALUES ('31f9235f-c91f-41d8-b99a-1c8eba619c03', '9ad61079-ef48-46aa-a6fb-2f099b00459d', '5939468', 90, 'large', 5600.00, 5500.00);
INSERT INTO public.variant (variant_id, product_id, sku_id, quantity, title, listed_price, selling_price) VALUES ('593821e4-1cf2-4f30-b5db-8c662db39d96', '30a5ebdd-ad0a-479b-8e6c-476b4e5cffca', '1359268', 56, 'vivid', 3700.00, 3600.00);
INSERT INTO public.variant (variant_id, product_id, sku_id, quantity, title, listed_price, selling_price) VALUES ('f3ac8258-0dc1-46ac-a6b9-5e2f481a9220', '30a5ebdd-ad0a-479b-8e6c-476b4e5cffca', '7371139', 67, 'classic', 3700.00, 3600.00);
INSERT INTO public.variant (variant_id, product_id, sku_id, quantity, title, listed_price, selling_price) VALUES ('54e1535a-d472-44d2-9284-0c8c33a76b2a', '30a5ebdd-ad0a-479b-8e6c-476b4e5cffca', '194638', 45, 'classic', 3600.00, 3500.00);
INSERT INTO public.variant (variant_id, product_id, sku_id, quantity, title, listed_price, selling_price) VALUES ('d8af8193-77e7-4fce-9a19-c583e6eaa7a8', '30a5ebdd-ad0a-479b-8e6c-476b4e5cffca', '3108269', 34, 'vivid', 3700.00, 3500.00);
INSERT INTO public.variant (variant_id, product_id, sku_id, quantity, title, listed_price, selling_price) VALUES ('cf29a0cd-1cd0-4ddb-aaa1-31de83ad0de5', '8ea3c469-6790-43bc-99e1-4660e59403d8', '5710870', 45, 'vivid', 3600.00, 3500.00);
INSERT INTO public.variant (variant_id, product_id, sku_id, quantity, title, listed_price, selling_price) VALUES ('b95bb667-4cab-42c4-8c8d-fc38975f6eff', '8ea3c469-6790-43bc-99e1-4660e59403d8', '2791444', 34, 'classic', 3700.00, 3500.00);
INSERT INTO public.variant (variant_id, product_id, sku_id, quantity, title, listed_price, selling_price) VALUES ('69cbbd36-fb19-42a1-9943-64ee67cef3ce', '7196948e-3011-4c86-a623-191fc4b4ccd0', '3757835', 78, 'Black', 1200.00, 1100.00);
INSERT INTO public.variant (variant_id, product_id, sku_id, quantity, title, listed_price, selling_price) VALUES ('32f818bb-956d-46a7-9ab0-38fcef67b7f2', '7196948e-3011-4c86-a623-191fc4b4ccd0', '4223210', 45, 'white', 1200.00, 1100.00);
INSERT INTO public.variant (variant_id, product_id, sku_id, quantity, title, listed_price, selling_price) VALUES ('bf2ac581-631e-43d7-ba2f-8aa46e0e8ae8', 'a71c6a34-af43-4261-8ee5-34234bb5b61b', '7329327', 67, 'Black', 1000.00, 900.00);
INSERT INTO public.variant (variant_id, product_id, sku_id, quantity, title, listed_price, selling_price) VALUES ('deed5f90-6c20-41fc-a4ef-7626cf4325ea', 'a71c6a34-af43-4261-8ee5-34234bb5b61b', '9317702', 46, 'white', 900.00, 800.00);


--------------------------------------------------------------------------------------------------------
INSERT INTO public.productcategory (category_id, product_id) VALUES ('b64542d4-328f-4670-adc9-1e9f6dc09219', '30a5ebdd-ad0a-479b-8e6c-476b4e5cffca');
INSERT INTO public.productcategory (category_id, product_id) VALUES ('6f964b17-2d46-4c6a-a41a-f74e89eb81e3', '183c1d6b-3eba-4b9b-8d3a-b58f7eb9deca');
INSERT INTO public.productcategory (category_id, product_id) VALUES ('6f964b17-2d46-4c6a-a41a-f74e89eb81e3', 'f1175767-1333-438d-9125-2f16cd1d416c');
INSERT INTO public.productcategory (category_id, product_id) VALUES ('876e82a1-99fa-40ca-bfa6-c687ace3cd1b', '7f7db4e0-4008-4612-b286-47a7a3e65408');
INSERT INTO public.productcategory (category_id, product_id) VALUES ('876e82a1-99fa-40ca-bfa6-c687ace3cd1b', '6fd11314-3b1d-4efc-854a-2c27607fc951');
INSERT INTO public.productcategory (category_id, product_id) VALUES ('867a62d0-6acd-442f-ba33-dd0a0b149462', '64376ad6-fa23-4667-ab3a-7cb70200ba92');
INSERT INTO public.productcategory (category_id, product_id) VALUES ('867a62d0-6acd-442f-ba33-dd0a0b149462', '7d52e29e-34f2-4f02-ba6e-bb5dd8acd9ec');
INSERT INTO public.productcategory (category_id, product_id) VALUES ('e9273721-4744-4bf2-b210-bf63402c4eab', '37f067d6-03f6-42d2-a156-49058f42c9f5');
INSERT INTO public.productcategory (category_id, product_id) VALUES ('e9273721-4744-4bf2-b210-bf63402c4eab', 'b1a5adcc-e409-4edb-92b8-81f0c9ac5398');
INSERT INTO public.productcategory (category_id, product_id) VALUES ('1339a83d-4176-49e1-8cb3-a703c247f211', '9ad61079-ef48-46aa-a6fb-2f099b00459d');
INSERT INTO public.productcategory (category_id, product_id) VALUES ('1339a83d-4176-49e1-8cb3-a703c247f211', '8ea3c469-6790-43bc-99e1-4660e59403d8');
INSERT INTO public.productcategory (category_id, product_id) VALUES ('563617f8-dd6c-4a2f-baf8-445926244341', '7196948e-3011-4c86-a623-191fc4b4ccd0');
INSERT INTO public.productcategory (category_id, product_id) VALUES ('563617f8-dd6c-4a2f-baf8-445926244341', 'a71c6a34-af43-4261-8ee5-34234bb5b61b');

---------------------------------------------------------------------------------------------------------------

INSERT INTO public.tag (tag_id, tag) VALUES ('5de37cd9-af93-437f-9b4f-b568be4d6e89', 'ball');

---------------------------------------------------------------------------------------------------------

INSERT INTO public.producttag (product_id, tag_id) VALUES ('183c1d6b-3eba-4b9b-8d3a-b58f7eb9deca', '5de37cd9-af93-437f-9b4f-b568be4d6e89');






insert into productattribute values('529c3f21-ff14-4976-a8d5-8b56b7bab356', 'Flash Memory Type', 'MicroSDXC');
insert into productattribute values('529c3f21-ff14-4976-a8d5-8b56b7bab356', 'Item Dimensions', '0.04 x 0.59 x 0.43 in');
insert into productattribute values('529c3f21-ff14-4976-a8d5-8b56b7bab356', 'SDA Speed Class', 'Class 10');

insert into variantattribute values('0b39b5e2-1c59-41f0-9a67-fbc479f83d19', 'Color', 'Red and Gold');
insert into variantattribute values('0b39b5e2-1c59-41f0-9a67-fbc479f83d19', 'Digital Storage Capacity', '128 GB');
insert into variantattribute values('0b39b5e2-1c59-41f0-9a67-fbc479f83d19', 'Memory Storage Capacity', '128 GB');
insert into variantattribute values('4690dfa6-4d44-423e-becb-ac0ca897c594', 'Color', 'Green and Gold');
insert into variantattribute values('4690dfa6-4d44-423e-becb-ac0ca897c594', 'Digital Storage Capacity', '256 GB');
insert into variantattribute values('4690dfa6-4d44-423e-becb-ac0ca897c594', 'Memory Storage Capacity', '256 GB');
insert into variantattribute values('4690dfa6-4d44-423e-becb-ac0ca897c594', 'Adapter Type', 'C10, U3, V30, 4K, A2, Micro SD');
