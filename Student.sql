DROP DATABASE IF EXISTS Student_enrollment;
CREATE DATABASE Student_enrollment;
USE Student_enrollment;

CREATE TABLE STUDENT (
    regno VARCHAR(20) PRIMARY KEY,
    name VARCHAR(50),
    major VARCHAR(50),
    bdate DATE
);

CREATE TABLE COURSE (
    course_id INT PRIMARY KEY,
    cname VARCHAR(50),
    dept VARCHAR(50)
);

CREATE TABLE ENROLL (
    regno VARCHAR(20),
    course_id INT,
    sem INT,
    marks INT,
    PRIMARY KEY (regno, course_id, sem),
    FOREIGN KEY (regno) REFERENCES STUDENT(regno),
    FOREIGN KEY (course_id) REFERENCES COURSE(course_id)
);


CREATE TABLE TEXT (
    book_ISBN INT PRIMARY KEY,
    book_title VARCHAR(250),
    publisher VARCHAR(50),
    author VARCHAR(50)
);

CREATE TABLE BOOK_ADOPTION (
    course_id INT,
    sem INT,
    book_ISBN INT,
    PRIMARY KEY (course_id, sem, book_ISBN),
    FOREIGN KEY (course_id) REFERENCES COURSE(course_id),
    FOREIGN KEY (book_ISBN) REFERENCES TEXT(book_ISBN)
);

INSERT INTO STUDENT VALUES
('S1', 'John Doe', 'Computer Science', '2000-01-15'),
('S2', 'Alice Smith', 'Electrical Engineering', '1999-05-20'),
('S3', 'Bob Johnson', 'Mechanical Engineering', '2001-09-10'),
('S4', 'Charlie Brown', 'Physics', '1998-04-15'),
('S5', 'David Kumar', 'Mathematics', '2002-03-25');

INSERT INTO COURSE VALUES
(101, 'Database Systems', 'CS'),
(102, 'Algorithms', 'CS'),
(103, 'Electromagnetics', 'EE'),
(104, 'Thermodynamics', 'ME'),
(105, 'Calculus', 'MATH');

INSERT INTO ENROLL VALUES
('S1', 101, 1, 85),
('S2', 101, 1, 78),
('S3', 102, 1, 92),
('S4', 102, 1, 88),
('S5', 103, 1, 95);


INSERT INTO TEXT VALUES
(1001, 'Database Systems: Concepts, Design, and Applications', 'Pearson', 'Alice Smith'),
(1002, 'Introduction to Algorithms', 'MIT Press', 'Thomas H. Cormen'),
(1003, 'Electromagnetic Field Theory', 'Wiley', 'John A. Buck'),
(1004, 'Thermodynamics: An Engineering Approach', 'McGraw-Hill', 'Yunus A. Cengel'),
(1005, 'Calculus: Early Transcendentals', 'Stewart', 'James Stewart');

INSERT INTO BOOK_ADOPTION VALUES
(101, 1, 1001),
(102, 1, 1002),
(103, 1, 1003),
(104, 1, 1004),
(105, 1, 1005);

-- 1. 	Demonstrate how you add a new text book to the database and make this book be adopted by some department:
INSERT INTO TEXT VALUES(
	1006, 'NoSQL for beginners', 'ADK Publishers', 'Dong T'
);

INSERT INTO BOOK_ADOPTION VALUES(
	101, 1, 1006
);


-- 2.	Produce a list of text books (include Course #, Book-ISBN, Book-title) in the alphabetical order for courses offered by the ‘CS’ department that use more than two books.  
SELECT course_id, book_isbn, book_title FROM BOOK_ADOPTION JOIN COURSE USING(course_id) JOIN TEXT USING(book_isbn) WHERE dept="CS" 
AND course_id IN(SELECT course_id FROM BOOK_ADOPTION GROUP BY course_id HAVING COUNT(*)>=2) ORDER BY book_title DESC;
-- OR
SELECT course_id, book_ISBN, book_title 
FROM TEXT JOIN BOOK_ADOPTION USING(book_ISBN) 
JOIN COURSE USING(course_id) 
 WHERE dept="CS" AND 
 (SELECT COUNT(course_id) FROM BOOK_ADOPTION WHERE course_id=Course.course_id)>=2;

-- 3.	List any department that has all its adopted books published by a specific publisher. 
SELECT dept FROM
COURSE WHERE dept IN(
	SELECT dept FROM COURSE JOIN BOOK_ADOPTION USING(course_id) JOIN TEXT USING(book_ISBN) WHERE publisher='Stewart'
)
AND 
dept NOT IN(
	SELECT dept FROM COURSE JOIN BOOK_ADOPTION USING(course_id) JOIN TEXT USING(book_ISBN) WHERE publisher<>'Stewart'
);


-- 4.	List the students who have scored maximum marks in ‘DBMS’ course. 
SELECT regno, name, marks FROM ENROLL JOIN Student USING(regno) WHERE course_id IN(SELECT course_id FROM Course WHERE cname="Database Systems") ORDER BY marks DESC LIMIT 1;
-- OR
SELECT * FROM Student JOIN Enroll USING(regno) JOIN Course USING(course_id) WHERE cname='Database Systems' ORDER BY marks DESC LIMIT 1;

-- 5.	Create a view to display all the courses opted by a student along with marks obtained.
CREATE VIEW vi AS
SELECT regno, name,cname,marks FROM COURSE JOIN ENROLL USING(course_id) JOIN STUDENT USING(regno) WHERE regno="S1";

-- 6.	Create a trigger that prevents a student from enrolling in a course if the marks prerequisite is less than  40.
DELIMITER //
CREATE TRIGGER tr
BEFORE INSERT ON ENROLL 
FOR EACH ROW 
BEGIN
	IF NEW.marks<40 THEN
		SIGNAL SQLSTATE '45000'
        SET message_text="ERRR!";
        END IF;
END;
//
DELIMITER ;
-- Testing the trigger
INSERT INTO ENROLL VALUES
('S1', 103, 1, 33);
