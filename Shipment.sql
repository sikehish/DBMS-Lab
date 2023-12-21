drop database if exists order_processing;
create database order_processing;
use order_processing;

create table if not exists Customers (
	cust_id int primary key,
	cname varchar(35) not null,
	city varchar(35) not null
);

create table if not exists Orders (
	order_id int primary key,
	odate date not null,
	cust_id int,
	order_amt int not null,
	foreign key (cust_id) references Customers(cust_id) on delete cascade
);

create table if not exists Items (
	item_id  int primary key,
	unitprice int not null
);

create table if not exists OrderItems (
	order_id int not null,
	item_id int not null,
	qty int not null,
	foreign key (order_id) references Orders(order_id) on delete cascade,
	foreign key (item_id) references Items(item_id) on delete cascade
);

create table if not exists Warehouses (
	warehouse_id int primary key,
	city varchar(35) not null
);

create table if not exists Shipments (
	order_id int not null,
	warehouse_id int not null,
	ship_date date not null,
	foreign key (order_id) references Orders(order_id) on delete cascade,
	foreign key (warehouse_id) references Warehouses(warehouse_id) on delete cascade
);

INSERT INTO Customers VALUES
(0001, "Customer_1", "Mysuru"),
(0002, "Customer_2", "Bengaluru"),
(0003, "Kumar", "Mumbai"),
(0004, "Customer_4", "Dehli"),
(0005, "Customer_5", "Bengaluru");

INSERT INTO Orders VALUES
(001, "2020-01-14", 0001, 2000),
(002, "2021-04-13", 0002, 500),
(003, "2019-10-02", 0003, 2500),
(004, "2019-05-12", 0005, 1000),
(005, "2020-12-23", 0004, 1200);

INSERT INTO Items VALUES
(0001, 400),
(0002, 200),
(0003, 1000),
(0004, 100),
(0005, 500);

INSERT INTO Warehouses VALUES
(0001, "Mysuru"),
(0002, "Bengaluru"),
(0003, "Mumbai"),
(0004, "Dehli"),
(0005, "Chennai");

INSERT INTO OrderItems VALUES 
(001, 0001, 5),
(002, 0005, 1),
(003, 0005, 5),
(004, 0003, 1),
(005, 0004, 12);

INSERT INTO Shipments VALUES
(001, 0002, "2020-01-16"),
(002, 0001, "2021-04-14"),
(003, 0004, "2019-10-07"),
(004, 0003, "2019-05-16"),
(005, 0005, "2020-12-23");


SELECT * FROM Customers;
SELECT * FROM Orders;
SELECT * FROM OrderItems;
SELECT * FROM Items;
SELECT * FROM Shipments;
SELECT * FROM Warehouses;


-- List the Order# and Ship_date for all orders shipped from Warehouse# "1".
SELECT order_id,ship_date FROM Shipments WHERE warehouse_id=1;


-- List warehouse info from which the Customer named "Kumar" was supplied his orders. Produce a listing of Order #, Warehouse #.
SELECT order_id, warehouse_id, Warehouses.city FROM Shipments JOIN Orders USING(order_id) JOIN Customers USING(cust_id) JOIN Warehouses USING(warehouse_id) WHERE cname="Kumar";

-- Produce a listing: Cname, #ofOrders, Avg_Order_Amt, where the middle column is the total number of orders by the customer and the last column is the average order amount for that customer. (Use aggregate functions)
SELECT cname, COUNT(*) AS numOrders, AVG(order_amt) AS Avg_Order_Amt FROM CUSTOMERS JOIN Orders USING(cust_id) GROUP BY cname;

-- Delete all orders for customer named "Kumar"
DELETE FROM Orders WHERE cust_id IN (SELECT cust_id FROM Customers WHERE name="Kumar");

-- Find the item with the maximum unit price
SELECT item_id,MAX(unitprice) FROM Items;
-- OR
SELECT * FROM Items ORDER BY unitprice DESC LIMIT 1;



-- Trigger that updates order_amount based on quantity and unitprice of order_amount
DELIMITER //
CREATE TRIGGER update_order
BEFORE INSERT ON OrderItems
FOR EACH ROW 
BEGIN
UPDATE Orders SET order_amt=(NEW.qty * (SELECT unitprice FROM Items WHERE Items.item_id=NEW.item_id)) WHERE Orders.order_id = NEW.order_id;
END;
//
DELIMITER ;

-- DROP TRIGGER update_order;
-- SELECT * FROM OrderItems;
-- SELECT * FROM Orders;

INSERT INTO Items (item_id, unitprice) VALUES (1006, 600);
-- Insert a new order with the new item
INSERT INTO Orders (order_id, odate, cust_id, order_amt) VALUES (206, '2023-04-16', 5, '1');
-- Insert the new item into the order
INSERT INTO OrderItems (order_id, item_id, qty) VALUES (206, 1006, 5);

-- Create a view to display orderID and shipment date of all orders shipped from a warehouse
CREATE VIEW OrderShimpent AS
SELECT order_id, ship_date FROM Shipments WHERE warehouse_id=1;
