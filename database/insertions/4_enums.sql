insert into citytype values ('main', 'Main City', 5);
insert into citytype values ('secondary', 'Secondary City', 7);

insert into accounttype values ('guest', 'Guest User');
insert into accounttype values ('user', 'Normal User');
insert into accounttype values ('admin', 'Administrator');

insert into cartitemstatus values ('added', 'Added to cart');
insert into cartitemstatus values ('removed', 'Removed from cart');
insert into cartitemstatus values ('ordered', 'Added to a order');

insert into orderstatus values ('ordered', 'Ordered');
insert into orderstatus values ('completed', 'Order completed');

insert into deliverymethod values ('shop_pickup', 'Pick up from the shop');
insert into deliverymethod values ('home_delivery', 'Deliver to the home');

insert into deliverystatus values ('ongoing', 'Delivery Ongoing');
insert into deliverystatus values ('delivered', 'Delivery Completed');

insert into paymentmethod values ('card', 'Card payment');
insert into paymentmethod values ('cash', 'Cash on delivery');

insert into paymentstatus values ('payed', 'Payment done');
insert into paymentstatus values ('not_payed', 'Payment not completed');