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
(1, "John Kumar", "Mysuru"),
  (2, "Alice", "Bengaluru"),
(3, "Bob Kumar", "Mumbai"),
(4, "Chrlie", "Dehli"),
(5, "David Kumar", "Bengaluru");

INSERT INTO Orders VALUES
(101, "2020-01-14", 1, 2000),
(102, "2021-04-13", 2, 500),
(103, "2019-10-02", 3, 2500),
(104, "2019-05-12", 5, 1000),
(105, "2020-12-23", 4, 1200);

INSERT INTO Items VALUES
(1, 400),
(2, 200),
(3, 1000),
(4, 100),
(5, 500);

INSERT INTO Warehouses VALUES
(0001, "Mysuru"),
(0002, "Bengaluru"),
(0003, "Mumbai"),
(0004, "Dehli"),
(0005, "Chennai");

INSERT INTO OrderItems VALUES 
(101, 1, 5),
(102, 5, 1),
(103, 5, 5),
(104, 3, 1),
(105, 4, 12);

INSERT INTO Shipments VALUES
(101, 2, "2020-01-16"),
(102, 1, "2021-04-14"),
(103, 4, "2019-10-07"),
(104, 3, "2019-05-16"),
(105, 5, "2020-12-23");


SELECT * FROM Customers;
SELECT * FROM Orders;
SELECT * FROM OrderItems;
SELECT * FROM Items;
SELECT * FROM Shipments;
SELECT * FROM Warehouses;


-- List the Order# and Ship_date for all orders shipped from Warehouse# "2".
select order_id,ship_date from Shipments where warehouse_id=0001;
