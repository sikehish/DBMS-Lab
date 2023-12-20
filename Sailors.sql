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
  PRIMARY KEY(sid,bid);
	foreign key (sid) references Sailors(sid) on delete cascade,
	foreign key (bid) references Boat(bid) on delete cascade
);

insert into Sailors values
(1,"Albert", 5, 40),
(2, "Einstein", 5, 49),
(3, "Hisham", 9, 18),
(4, "Yohan", 2, 68),
(5, "Smith", 7, 19);


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

-- Find the colours of the boats reserved by Albert
SELECT DISTINCT(color) FROM (RESERVES JOIN Boat USING(bid)) JOIN Sailors USING(sid) WHERE sname='Albert';

-- Find all the sailor sids who have rating atleast 8 or reserved boat 103
SELECT DISTINCT S.sid
FROM SAILORS S
JOIN RESERVES R ON S.sid = R.sid
WHERE S.rating >= 8 OR R.bid = 103;
-- OR
SELECT DISTINCT S.sid
FROM SAILORS S
LEFT JOIN RESERVES R ON S.sid = R.sid
WHERE S.rating >= 8 OR R.bid = 103;



-- Find the names of the sailor who have not reserved a boat whose name contains the string "storm". Order the name in the ascending order

-- Issue with the below stmt is that it searches for "storm" in sname  rather than bname
-- select sname FROM Sailors
-- WHERE sname LIKE '%storm%'
-- AND sid NOT IN(SELECT DISTINCT(sid) FROM RESERVES);

-- Checking for 3 instead of storm 
select sid,sname FROM Sailors
WHERE sid NOT IN(SELECT sid FROM ((SAILORS JOIN RESERVES USING(sid)) JOIN BOAT USING(bid)) WHERE bname LIKE '%3%');
-- OR
select sid,sname FROM SAILORS Where sid NOT IN (select s.sid from SAILORS s join RESERVES r on r.sid=s.sid join BOAT b on b.bid=r.bid WHERE b.bname LIKE '%3%');

-- Find the names of sailors who have reserved all boats 
-- SET @numOfBoats = (SELECT COUNT(*) FROM Boat);
-- SELECT @numOfBoats;
SELECT sname AS ReservationCount
FROM ((SAILORS JOIN RESERVES USING(sid)) JOIN BOAT USING(bid))
GROUP BY sname
HAVING COUNT(DISTINCT(bid)) >= (SELECT COUNT(*) FROM Boat);
-- OR
select sname from Sailors s where not exists
	(select * from Boat b where not exists
		(select * from reserves r where r.sid=s.sid and b.bid=r.bid));
        
-- Find the name and age of the oldest sailor.  
SELECT sname,age FROM SAILORS ORDER BY age DESC LIMIT 1;

-- For each boat which was reserved by at least 2 sailors with age >= 40, find the boat id and  the average age of such sailors.
SELECT bid, AVG(Sailors.age), COUNT(*) FROM (SAILORS JOIN RESERVES USING(sid)) JOIN BOAT USING(bid) WHERE Sailors.age>=40 GROUP BY bid HAVING COUNT(sid)>=2;

-- Create a view that shows the names and colours of all the boats that have been reserved by a sailor with a specific rating. 
CREATE OR REPLACE VIEW view_lol AS
SELECT DISTINCT Boat.bname, Boat.color
FROM Reserves
JOIN Boat USING (bid)
JOIN Sailors USING (sid)
WHERE rating=5;

SELECT * FROM view_lol;

-- A trigger that prevents boats from being deleted If they have active reservations. 
DELIMITER // 
CREATE TRIGGER delete_trigger
BEFORE DELETE ON Boat
FOR EACH ROW
BEGIN
	IF OLD.bid IN (SELECT bid FROM RESERVES) THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT ='HAHAHAHAH';
	END IF;
END;
//
DELIMITER ;


