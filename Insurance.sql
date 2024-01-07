DROP DATABASE IF EXISTS insurance;
CREATE DATABASE insurance;
USE insurance;

CREATE TABLE IF NOT EXISTS person (
driver_id VARCHAR(255) NOT NULL,
driver_name TEXT NOT NULL,
address TEXT NOT NULL,
PRIMARY KEY (driver_id)
);

CREATE TABLE IF NOT EXISTS car (
reg_no VARCHAR(255) NOT NULL,
model TEXT NOT NULL,
c_year INTEGER,
PRIMARY KEY (reg_no)
);

CREATE TABLE IF NOT EXISTS accident (
report_no INTEGER NOT NULL,
accident_date DATE,
location TEXT,
PRIMARY KEY (report_no)
);

CREATE TABLE IF NOT EXISTS owns (
driver_id VARCHAR(255) NOT NULL,
reg_no VARCHAR(255) NOT NULL,
FOREIGN KEY (driver_id) REFERENCES person(driver_id) ON DELETE CASCADE,
FOREIGN KEY (reg_no) REFERENCES car(reg_no) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS participated (
driver_id VARCHAR(255) NOT NULL,
reg_no VARCHAR(255) NOT NULL,
report_no INTEGER NOT NULL,
damage_amount FLOAT NOT NULL,
FOREIGN KEY (driver_id) REFERENCES person(driver_id) ON DELETE CASCADE,
FOREIGN KEY (reg_no) REFERENCES car(reg_no) ON DELETE CASCADE,
FOREIGN KEY (report_no) REFERENCES accident(report_no)
);

INSERT INTO person VALUES
("D111", "Driver_1", "Kuvempunagar, Mysuru"),
("D222", "Smith", "JP Nagar, Mysuru"),
("D333", "Driver_3", "Udaygiri, Mysuru"),
("D444", "Driver_4", "Rajivnagar, Mysuru"),
("D555", "Driver_5", "Vijayanagar, Mysore");

INSERT INTO car VALUES
("KA-20-AB-4223", "Swift", 2020),
("KA-20-BC-5674", "Mazda", 2017),
("KA-21-AC-5473", "Alto", 2015),
("KA-21-BD-4728", "Triber", 2019),
("KA-09-MA-1234", "Tiago", 2018);

INSERT INTO accident VALUES
(43627, "2020-04-05", "Nazarbad, Mysuru"),
(56345, "2019-12-16", "Gokulam, Mysuru"),
(63744, "2020-05-14", "Vijaynagar, Mysuru"),
(54634, "2019-08-30", "Kuvempunagar, Mysuru"),
(65738, "2021-01-21", "JSS Layout, Mysuru"),
(66666, "2021-01-21", "JSS Layout, Mysuru");

INSERT INTO owns VALUES
("D111", "KA-20-AB-4223"),
("D222", "KA-20-BC-5674"),
("D333", "KA-21-AC-5473"),
("D444", "KA-21-BD-4728"),
("D222", "KA-09-MA-1234");

INSERT INTO participated VALUES
("D111", "KA-20-AB-4223", 43627, 20000),
("D222", "KA-20-BC-5674", 56345, 49500),
("D333", "KA-21-AC-5473", 63744, 15000),
("D444", "KA-21-BD-4728", 54634, 5000),
("D222", "KA-09-MA-1234", 65738, 25000);

SELECT * FROM participated;

--     Find the total number of people who owned cars that were involved in accidents in 2021.
SELECT COUNT(*) FROM participated JOIN accident USING(report_no) WHERE accident_date>='2021-01-01' AND accident_date<='2021-12-31';
-- OR
SELECT COUNT(*) FROM participated JOIN accident USING(report_no) WHERE accident_date LIKE '2021%';
-- OR
SELECT COUNT(*) FROM participated JOIN accident USING(report_no) WHERE year(accident_date)='2021';
-- OR
SELECT COUNT(*) FROM participated JOIN accident USING(report_no) JOIN OWNS USING(reg_no) WHERE accident_date>='2021-01-01' AND accident_date<='2021-12-31';


--     Find the number of accidents in which the cars belonging to “Smith” were involved.
SELECT COUNT(*) FROM participated JOIN person using(driver_id) WHERE driver_name LIKE '%Smith%';
-- OR
SELECT COUNT(*)
FROM participated 
WHERE driver_id IN (
	SELECT driver_id FROM 
    person WHERE driver_name LIKE "%smith%");


--     Add a new accident to the database; assume any values for required attributes.
insert into accident values
(45562, "2024-04-05", "Mandya");
insert into participated values
("D222", "KA-21-BD-4728", 45562, 50000);

--     Delete the Mazda belonging to “Smith”.
DELETE FROM CAR
WHERE model="Mazda" AND reg_no IN (SELECT reg_no FROM owns JOIN person USING(driver_id) WHERE driver_name="Smith");  

-- 5.Update the damage amount for the car with license number “KA09MA1234” in the accident with report number 65738.
UPDATE participated 
SET damage_amount=750000 
WHERE reg_no="KA-09-MA-1234"
AND report_no=65738;

SELECT * FROM participated;

--     A view that shows models and year of cars that are involved in accident.
CREATE VIEW hoo AS
SELECT model,c_year FROM Car
WHERE reg_no IN (SELECT reg_no FROM participated);
-- OR
CREATE OR REPLACE VIEW cars_data AS
SELECT DISTINCT model, c_year
FROM car JOIN participated USING(reg_no); 

--     A trigger that prevents a driver from participating in more than 3 accidents(overall) - EASY.

-- DROP TRIGGER IF EXISTS tr2;
-- DELIMITER //
-- CREATE TRIGGER tr2
-- BEFORE INSERT ON participated
-- FOR EACH ROW
-- BEGIN
-- 	IF (SELECT COUNT(*) FROM participated WHERE driver_id=NEW.driver_id) >=2 THEN
-- 		SIGNAL SQLSTATE '45000'
--         SET MESSAGE_TEXT="ERRRRRR";
-- 	END IF;
-- END;
-- //
-- DELIMITER ;

--     A trigger that prevents a driver from participating in more than 3 accidents in a given year.

DROP TRIGGER IF EXISTS tr2;
DELIMITER //
CREATE TRIGGER tr2
BEFORE INSERT ON participated
FOR EACH ROW
BEGIN
	IF (
        SELECT COUNT(*) AS accident_count
        FROM participated
        JOIN accident USING(report_no)
        WHERE driver_id = NEW.driver_id
        AND year(accident_date)=(SELECT year(accident_date) FROM accident WHERE report_no=NEW.report_no)
    ) >= 3 THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ERRRRRR';
	END IF;
END;
//
DELIMITER ;


INSERT INTO participated VALUES
("D222", "KA-20-AB-4223", 66666, 20000);

-- DELETE FROM participated 
-- WHERE driver_id="D111" AND reg_no="KA-20-AB-4223";

SELECT * FROM participated;




