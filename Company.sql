    PLocation VARCHAR(50),
    DNo INT,
    FOREIGN KEY (DNo) REFERENCES DEPARTMENT(DNo)
);

CREATE TABLE WORKS_ON (
    SSN INT,
    PNo INT,
    Hours INT,
    PRIMARY KEY (SSN, PNo),
    FOREIGN KEY (SSN) REFERENCES EMPLOYEE(SSN),
    FOREIGN KEY (PNo) REFERENCES PROJECT(PNo)
);


INSERT INTO EMPLOYEE VALUES
(1001, 'John Doe', '123 Main St', 'M', 60000, NULL, 1),
(1002, 'Alice Smith', '456 Oak St', 'F', 75000, 1001, 1),
(1003, 'Bob Johnson', '789 Pine St', 'M', 90000, 1001, 2),
(1004, 'Charlie Brown', '101 Cedar St', 'M', 80000, 1003, 2),
(1005, 'David Kumar', '202 Maple St', 'M', 70000, 1003, 3);

INSERT INTO DEPARTMENT VALUES
(1, 'HR', 1001, '2023-01-01'),
(2, 'IT', 1003, '2023-02-01'),
(3, 'Accounts', 1005, '2023-03-01');

INSERT INTO DLOCATION VALUES
(1, 'New York'),
(2, 'San Francisco'),
(3, 'Los Angeles');

INSERT INTO PROJECT VALUES
(101, 'Project A', 'New York', 1),
(102, 'Project B', 'San Francisco', 2),
(103, 'Project C', 'Los Angeles', 3),
(104, 'Project D', 'New York', 1),
(105, 'Project E', 'San Francisco', 2);

INSERT INTO WORKS_ON VALUES
(1001, 101, 40),
(1002, 102, 30),
(1003, 103, 35),
(1004, 104, 25),
(1005, 105, 20);

ALTER TABLE EMPLOYEE
ADD FOREIGN KEY (DNo) REFERENCES DEPARTMENT(DNo) ON DELETE CASCADE;

-- Make a list of all project numbers for projects that involve an employee whose last name is ‘Scott’, either as a worker or as a manager of the department that controls the project:
SELECT PNo FROM PROJECT JOIN EMPLOYEE USING(DNo) WHERE Name LIKE '%Doe';

CREATE TABLE EMPLOYEE (
    SSN INT PRIMARY KEY,
    Name VARCHAR(50),
    Address VARCHAR(100),
    Sex CHAR(1),
    Salary INT,
    SuperSSN INT,
    DNo INT,
    FOREIGN KEY (SuperSSN) REFERENCES EMPLOYEE(SSN)
);


CREATE TABLE PROJECT (
    PNo INT PRIMARY KEY,
    PName VARCHAR(50),
    PLocation VARCHAR(50),
    DNo INT,
    FOREIGN KEY (DNo) REFERENCES DEPARTMENT(DNo)
);

CREATE TABLE WORKS_ON (
    SSN INT,
    PNo INT,
    Hours INT,
    PRIMARY KEY (SSN, PNo),
    FOREIGN KEY (SSN) REFERENCES EMPLOYEE(SSN),
    FOREIGN KEY (PNo) REFERENCES PROJECT(PNo)
);

-- Show the resulting salaries if every employee working on the ‘IoT’ project is given a 10 percent raise:
SELECT ssn, name, salary as old_salary,salary*1.1 as new_salary FROM Employee JOIN WORKS_ON USING(SSN) JOIN PROJECT USING(PNo) WHERE PName="Project A";
-- OR
select w.ssn,name,salary as old_salary,salary*1.1 as new_salary from Works_On w join Employee e where w.ssn=e.ssn and w.PNo=(select PNo from Project where PName="Project A");
-- OR
UPDATE EMPLOYEE
SET Salary= Salary*1.1
WHERE SSN IN (SELECT SSN FROM WORKS_ON JOIN PROJECT USING(PNo) WHERE PName="Project A");


-- Find the sum of the salaries of all employees of the ‘Accounts’ department, as well as the maximum salary, the minimum salary, and the average salary in this department
SELECT SUM(Salary), MAX(salary), MIN(salary), AVG(salary) FROM EMPLOYEE JOIN DEPARTMENT USING(DNo) WHERE DName="Accounts";

-- Retrieve the name of each employee who works on all the projects controlled by department number 5 (use NOT EXISTS operator):
SELECT name FROM Employee;

-- For each department that has more than five employees, retrieve the department number and the number of its employees who are making more than Rs. 6,00,000:
SELECT Dno, COUNT(*) FROM Department JOIN Employee USING(Dno) WHERE Salary>=60000 GROUP BY DNo HAVING COUNT(*)>=2;
-- OR
SELECT D.DNo AS DepartmentNumber, COUNT(*) AS NumHighSalaryEmployees
FROM DEPARTMENT D
JOIN EMPLOYEE E ON D.DNo = E.DNo
WHERE E.Salary >60000
GROUP BY D.DNo
HAVING COUNT(*) >=2;

--  Create a view that shows name, dept name and location of all employees:
CREATE VIEW view_random AS
SELECT name, DName, Dloc FROM EMPLOYEE JOIN DEPARTMENT USING(DNo) JOIN DLOCATION USING(DNo);

-- Create a trigger that prevents a project from being deleted if it is currently being worked by any employee:
DELIMITER //
CREATE TRIGGER trigg
BEFORE DELETE ON PROJECT
FOR EACH ROW
BEGIN
	IF OLD.PNo IN (SELECT PNo FROM WORKS_ON) THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT="Next time fam";
	END IF;
END;
//
DELIMITER ;

-- DROP TRIGGER trigg;


DELETE FROM PROJECT WHERE PNo=102;
