drop database company;
create database company;
use company;


create table employee(
	ssn varchar(35) primary key,
	ename varchar(35),
	address varchar(255),
	sex varchar(7),
	salary Decimal(10,2),
	super_ssn varchar(35),
	d_no int,
    foreign key (super_ssn) references employee(ssn) on delete set null
);

create table department(
	d_no int primary key,
	dname varchar(100),
	mgr_ssn varchar(35),
	mgr_start_date date,
	foreign key (mgr_ssn) references Employee(ssn) on delete SET NULL
);


create table dLocation(
	d_no int,
	d_loc varchar(100),
    FOREIGN KEY(d_no) REFERENCES department(d_no) ON DELETE SET NULL
);

create table project(
	p_no int primary key,
	p_name varchar(25),
	p_loc varchar(25),
	d_no int,
	foreign key (d_no) references department(d_no) on delete SET NULL
);	

create table workson(
	ssn varchar(35),
	p_no int,
	hours int,
	foreign key (ssn) references employee(ssn) on delete SET NULL,
	foreign key (p_no) references project(p_no) on delete SET NULL
);


INSERT INTO Employee VALUES
("01NB235", "Chandan_Krishna","Siddartha Nagar, Mysuru", "Male", 1500000, "01NB235", 5),
("01NB354", "Employee_2", "Lakshmipuram, Mysuru", "Female", 1200000,"01NB235", 2),
("02NB254", "Employee_3", "Pune, Maharashtra", "Male", 1000000,"01NB235", 4),
("03NB653", "Employee_4", "Hyderabad, Telangana", "Male", 2500000, "01NB354", 5),
("04NB234", "Employee_5", "JP Nagar, Bengaluru", "Female", 1700000, "01NB354", 1);


INSERT INTO Department VALUES
(001, "Human Resources", "01NB235", "2020-10-21"),
(002, "Quality Assesment", "03NB653", "2020-10-19"),
(003,"System assesment","04NB234","2020-10-27"),
(005,"Production","02NB254","2020-08-16"),
(004,"Accounts","01NB354","2020-09-4");


INSERT INTO DLocation VALUES
(001, "Jaynagar, Bengaluru"),
(002, "Vijaynagar, Mysuru"),
(003, "Chennai, Tamil Nadu"),
(004, "Mumbai, Maharashtra"),
(005, "Kuvempunagar, Mysuru");

INSERT INTO Project VALUES
(241563, "System Testing", "Mumbai, Maharashtra", 004),
(532678, "IOT", "JP Nagar, Bengaluru", 001),
(453723, "Product Optimization", "Hyderabad, Telangana", 005),
(278345, "Yeild Increase", "Kuvempunagar, Mysuru", 005),
(426784, "Product Refinement", "Saraswatipuram, Mysuru", 002);

INSERT INTO WorksOn VALUES
("01NB235", 278345, 5),
("01NB354", 426784, 6),
("04NB234", 532678, 3),
("02NB254", 241563, 3),
("03NB653", 453723, 6);

ALTER TABLE employee 
ADD CONSTRAINT
FOREIGN KEY(d_no) REFERENCES department(d_no) ON DELETE SET NULL;

-- 1.	Make a list of all project numbers for projects that involve an employee whose last name is ‘Scott’('Doe in this case), either as a worker or as a manager of the department that controls the project.  
SELECT * FROM PROJECT JOIN EMPLOYEE USING(d_no) WHERE ename LIKE '%Krishna'; -- Not right approach cuz we arent conisdering works on table
-- or
SELECT * FROM PROJECT JOIN DEPARTMENT USING(d_no) JOIN EMPLOYEE USING(d_no) WHERE ename LIKE '%Krishna'; -- Not right approach cuz we arent conisdering works on table
-- or (My soln: using worksOn isntead of EMPLOYEE directly)
SELECT * FROM PROJECT WHERE 
p_no IN (SELECT p_no FROM WorksOn JOIN EMPLOYEE USING(SSN) WHERE ename LIKE "%Krishna") 
OR 
d_no IN (SELECT d_no FROM DEPARTMENT WHERE mgr_ssn IN (SELECT SSN FROM EMPLOYEE WHERE ename LIKE "%Krishna"));
-- OR (same as ADK soln)
SELECT * FROM PROJECT WHERE 
d_no IN (SELECT d_no FROM EMPLOYEE WHERE ename LIKE "%Krishna") 
OR 
d_no IN (SELECT d_no FROM DEPARTMENT WHERE mgr_ssn IN (SELECT SSN FROM EMPLOYEE WHERE ename LIKE "%Krishna"));
-- OR (ABOVE CODE USING JOIN)
SELECT * FROM PROJECT WHERE 
d_no IN (SELECT d_no FROM EMPLOYEE WHERE ename LIKE "%Krishna") 
OR 
d_no IN (SELECT DEPARTMENT.d_no FROM DEPARTMENT JOIN EMPLOYEE ON mgr_ssn=ssn  WHERE ename LIKE "%Krishna");
-- OR
-- saad soln
SELECT *
FROM PROJECT P
JOIN WorksOn W ON P.p_no = W.p_no
JOIN EMPLOYEE E ON W.SSN = E.SSN OR E.d_no = P.d_no
WHERE E.ename LIKE "%Krishna";
-- OR
-- ADK SOLN
SELECT p_no,p_name 
FROM project 
WHERE d_no IN (
	SELECT d_no
    FROM employee 
    WHERE ename LIKE '%Krishna') OR d_no IN (SELECT d_no from department WHERE mgr_ssn IN(SELECT ssn from employee WHERE ename LIKE '%krishna'));

-- 2.	Show the resulting salaries if every employee working on the ‘IoT’ project is given a 10 percent raise.  
SELECT SSN, ename, 1.1*Salary AS UpdatedSalary FROM Employee WHERE ssn IN(SELECT SSN FROM WorksON WHERE p_no IN(SELECT p_no FROM Project WHERE p_name="IoT"));
-- OR
select e.ename,e.salary as "Old Salary",e.salary*1.1 as "New Salary" 
from employee e
join  workson using(ssn)
join project using(p_no)
where p_name="IOT";

-- 3.	Find the sum of the salaries of all employees of the ‘Accounts’ department, as well as the maximum salary, the minimum salary, and the average salary in this department  
SELECT SUM(Salary),MIN(Salary),MAX(Salary),AVG(SALARY) FROM EMPLOYEE JOIN DEPARTMENT USING(d_no) WHERE dname="Production";

-- 4.	Retrieve the name of each employee who works on all the projects controlled by department number 2 (use NOT EXISTS operator). 
select Employee.ssn,ename,d_no from Employee where not exists
    (select p_no from Project p where p.d_no=2 and p_no not in
    	(select p_no from WorksOn w where w.ssn=Employee.ssn));
-- OR
SELECT E.ename
FROM EMPLOYEE E
WHERE NOT EXISTS (
  SELECT P.p_no
  FROM PROJECT P
  WHERE P.d_no = 2
    AND NOT EXISTS (
      SELECT *
      FROM WORKSON W
      WHERE W.SSN = E.SSN AND W.p_no = P.p_no
    )
);

-- 5.	For each department that has more than five employees, retrieve the department number and the number of its employees who are making more than Rs. 6,00,000. 
SELECT D.d_no, COUNT(*) FROM Department D JOIN Employee E USING(d_no) WHERE E.salary>600000 GROUP BY D.d_no HAVING COUNT(*)>5;
-- OR
SELECT D.d_no AS DepartmentNumber, COUNT(*) AS NumHighSalaryEmployees
FROM DEPARTMENT D
JOIN EMPLOYEE E ON D.d_no = E.d_no
WHERE E.Salary > 600000
GROUP BY D.d_no
HAVING COUNT(*) > 5;

-- 6.	Create a view that shows name, dept name and location of all employees. 
CREATE VIEW vi AS
SELECT E.ename, D.dname, Dl.d_loc FROM Employee E JOIN Department D USING(d_no) JOIN DLocation Dl USING(d_no);
-- OR
CREATE OR REPLACE VIEW EmployeeView AS
SELECT E.ename, D.dname AS Department, DL.d_loc AS Location
FROM EMPLOYEE E
JOIN DEPARTMENT D ON E.d_no = D.D_No
JOIN DLOCATION DL ON D.d_no = DL.d_no;

-- 7.	Create a trigger that prevents a project from being deleted if it is currently being worked by any employee.
DROP TRIGGER IF EXISTS PREVENT_DELETE;
DELIMITER //
CREATE TRIGGER PREVENT_DELETE 
BEFORE DELETE ON Project
FOR EACH ROW
BEGIN
	IF OLD.p_no IN (SELECT p_no FROM WorksOn) THEN
    -- OR IF EXISTS (SELECT p_no FROM WorksOn WHERE p_no=OLD.p_no) THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT="ERROR!";
	END IF;
END;
//
DELIMITER ;

-- New project(not in workson)
-- INSERT INTO Project VALUES
-- (241562, "System Testing", "Mumbai, Maharashtra", 004);
-- DELETE FROM PROJECT WHERE p_no=241562;

-- Active project(workson) 
-- DELETE FROM PROJECT WHERE p_no=426784;
