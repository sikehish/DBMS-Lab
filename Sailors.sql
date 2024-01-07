drop database if exists sailors;

create database sailors;
use sailors;

create table if not exists Sailors(
	sid int primary key,
	sname varchar(35) not null,
	rating float not null,
	age int not null
);

create table if not exists Boat(
	bid int primary key,
	bname varchar(35) not null,
	color varchar(25) not null
);

create table if not exists reserves(
	sid int not null,
	bid int not null,
	sdate date not null,
    PRIMARY KEY(sid,bid),
	foreign key (sid) references Sailors(sid) on delete cascade,
	foreign key (bid) references Boat(bid) on delete cascade
);


insert into Sailors values
(1,"Albert", 5.0, 40),
(2, "Nakul", 5.0, 49),
(3, "Darshan", 9, 18),
(4, "Astorm Gowda", 2, 68),
(5, "Armstormin", 7, 19);

insert into Boat values
(1,"Boat_1", "Green"),
(2,"Boat_2", "Red"),
(103,"Boat_3", "Blue");

insert into reserves values
(1,103,"2023-01-01"),
(1,2,"2023-02-01"),
(2,1,"2023-02-05"),
(3,2,"2023-03-06"),
(5,103,"2023-03-06"),
(1,1,"2023-03-06");

SELECT * FROM Sailors;
SELECT * FROM Boat;
SELECT * FROM reserves;


--     Find the colours of boats reserved by Albert
SELECT color FROM Boat JOIN reserves USING(bid) JOIN Sailors USING(sid) WHERE sname="Albert";

--     Find all sailor id’s of sailors who have a rating of at least 8 or reserved boat 103
(SELECT sid FROM Sailors WHERE rating>=8)
UNION  
(SELECT sid FROM reserves where bid=103); 
-- OR
SELECT sid 
FROM Sailors JOIN reserves USING(sid)
WHERE rating>=8 OR bid=103;

--     Find the names of sailors who have not reserved a boat whose name contains the string “storm”. Order the names in ascending order.
-- (3 in this case for convinience) 

-- Where  bname isnt containing  strorm(3 in this case for convinience)
 SELECT * FROM sailors WHERE sid NOT IN (SELECT sid FROM Boat JOIN reserves USING(bid) WHERE bname LIKE "%3");
 -- OR
SELECT * FROM Sailors WHERE sid NOT IN(SELECT sid FROM RESERVES WHERE bid IN (SELECT bid FROM Boat WHERE bname LIKE "%3"));
-- Where sname isnt containing storm(Gowda in this case for convinience)
SELECT * FROM Sailors WHERE
sname NOT LIKE "%Gowda%" AND
sid NOT IN (SELECT sid FROM RESERVES);

--     Find the names of sailors who have reserved all boats.
SELECT sname FROM Sailors
JOIN Reserves USING (sid) JOIN Boat USING(bid)
GROUP BY sname
HAVING COUNT(*)>=(SELECT COUNT(*) FROM Boat);
-- OR
select sname from sailors s where not exists
	(select * from boat b where not exists
		(select * from reserves r where r.sid=s.sid and b.bid=r.bid)); 
        
--     Find the name and age of the oldest sailor.
SELECT sname, age FROM Sailors ORDER BY age DESC LIMIT 1;

--     For each boat which was reserved by at least 2 sailors with age >= 40, find the boat id and the average age of such sailors.
SELECT bid, AVG(age) FROM Boat JOIN reserves USING(bid) JOIN Sailors USING(sid) WHERE age>=40 GROUP BY bid HAVING COUNT(*)>=2;

--     Create a view that shows the names and colours of all the boats that have been reserved by a sailor with a specific rating.
CREATE VIEW view1 AS 
SELECT bname, color FROM Boat WHERE bid IN(SELECT bid FROM reserves WHERE sid IN(SELECT sid FROM sailors where rating>5));
-- OR
CREATE VIEW view2 AS 
SELECT bname,color FROM Boat join reserves using(bid) join sailors using(sid) where rating>5;

--     A trigger that prevents boats from being deleted If they have active reservations.
DROP TRIGGER tr_1
DELIMITER //
CREATE TRIGGER tr_1
BEFORE DELETE ON Boat
FOR EACH ROW
BEGIN
	IF OLD.bid IN(SELECT bid FROM reserves) THEN 
    -- OR IF OLD.bid IN(SELECT bid FROM reserves WHERE bid=OLD.bid) THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT='Boat has active reservations and cannot be deleted';
	END IF;
END;
//
DELIMITER ;

DELETE FROM BOAT WHERE bid=103;


