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
    book_title VARCHAR(50),
    publisher VARCHAR(50),
    author VARCHAR(50)
);

-- ALTER TABLE TEXT
-- MODIFY publisher VARCHAR(255);


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
