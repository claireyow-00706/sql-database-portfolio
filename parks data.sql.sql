DROP DATABASE IF EXISTS `Parks_and_Recreation`;
CREATE DATABASE `Parks_and_Recreation`;
USE `Parks_and_Recreation`;






CREATE TABLE employee_demographics (
  employee_id INT NOT NULL,
  first_name VARCHAR(50),
  last_name VARCHAR(50),
  age INT,
  gender VARCHAR(10),
  birth_date DATE,
  PRIMARY KEY (employee_id)
);

CREATE TABLE employee_salary (
  employee_id INT NOT NULL,
  first_name VARCHAR(50) NOT NULL,
  last_name VARCHAR(50) NOT NULL,
  occupation VARCHAR(50),
  salary INT,
  dept_id INT
);


INSERT INTO employee_demographics (employee_id, first_name, last_name, age, gender, birth_date)
VALUES
(1,'Leslie', 'Knope', 44, 'Female','1979-09-25'),
(3,'Tom', 'Haverford', 36, 'Male', '1987-03-04'),
(4, 'April', 'Ludgate', 29, 'Female', '1994-03-27'),
(5, 'Jerry', 'Gergich', 61, 'Male', '1962-08-28'),
(6, 'Donna', 'Meagle', 46, 'Female', '1977-07-30'),
(7, 'Ann', 'Perkins', 35, 'Female', '1988-12-01'),
(8, 'Chris', 'Traeger', 43, 'Male', '1980-11-11'),
(9, 'Ben', 'Wyatt', 38, 'Male', '1985-07-26'),
(10, 'Andy', 'Dwyer', 34, 'Male', '1989-03-25'),
(11, 'Mark', 'Brendanawicz', 40, 'Male', '1983-06-14'),
(12, 'Craig', 'Middlebrooks', 37, 'Male', '1986-07-27');


INSERT INTO employee_salary (employee_id, first_name, last_name, occupation, salary, dept_id)
VALUES
(1, 'Leslie', 'Knope', 'Deputy Director of Parks and Recreation', 75000,1),
(2, 'Ron', 'Swanson', 'Director of Parks and Recreation', 70000,1),
(3, 'Tom', 'Haverford', 'Entrepreneur', 50000,1),
(4, 'April', 'Ludgate', 'Assistant to the Director of Parks and Recreation', 25000,1),
(5, 'Jerry', 'Gergich', 'Office Manager', 50000,1),
(6, 'Donna', 'Meagle', 'Office Manager', 60000,1),
(7, 'Ann', 'Perkins', 'Nurse', 55000,4),
(8, 'Chris', 'Traeger', 'City Manager', 90000,3),
(9, 'Ben', 'Wyatt', 'State Auditor', 70000,6),
(10, 'Andy', 'Dwyer', 'Shoe Shiner and Musician', 20000, NULL),
(11, 'Mark', 'Brendanawicz', 'City Planner', 57000, 3),
(12, 'Craig', 'Middlebrooks', 'Parks Director', 65000,1);



CREATE TABLE parks_departments (
  department_id INT NOT NULL AUTO_INCREMENT,
  department_name varchar(50) NOT NULL,
  PRIMARY KEY (department_id)
);

INSERT INTO parks_departments (department_name)
VALUES
('Parks and Recreation'),
('Animal Control'),
('Public Works'),
('Healthcare'),
('Library'),
('Finance');



SELECT * FROM employee_demographics;

SELECT * 
FROM employee_demographics
WHERE employee_id IN 
                     (SELECT employee_id -- subquery acts as a filter, so this narrows down the data sql is looking at and we are telling it to only look within the narrowed data and show the specific entries we wnt
                      FROM employee_salary
                      WHERE dept_id = 1)
;


SELECT first_name,salary,
(SELECT AVG(salary) -- subquery
FROM employee_salary)
FROM employee_salary;


SELECT * 
FROM employee_salary;

SELECT 
first_name,
salary,
occupation,
CASE WHEN salary >= 60000 THEN 'High earning job'
     WHEN salary BETWEEN 20000 AND 50000 THEN 'Middle earning job'
     ELSE 'Low earning job'
END AS salary_tier
FROM employee_salary;

WITH salary_category AS (
SELECT 
first_name,
salary,
dept_id,
occupation,
CASE WHEN salary >= 60000 THEN 'High earning job'
     WHEN salary BETWEEN 20000 AND 50000 THEN 'Middle earning job'
     ELSE 'Low earning job'
END AS salary_tier
FROM employee_salary
)
SELECT first_name, occupation, salary_tier, dept_id
FROM salary_category;


-- LENGTH refers to counting the number letters or numbers in text
SELECT first_name, LENGTH(first_name)
FROM employee_demographics
ORDER BY 2; -- shorthand for order by length of first name since that is the second command after select

-- UPPER capitalizes texts
SELECT first_name, UPPER(first_name)
FROM employee_demographics;

-- LOWER converts all texts into lower case

-- TRIM removes unnecessary spaces in between text
-- LEFT TRIM removes spaces of text only on the left side
-- RIGHT TRIM removes spaces of text only on the right side

SELECT
first_name,
LEFT(first_name,3) -- LEFT(TEXT, no. of charcters from the left): tells sql how many characters do you want retained from the left of the text
FROM employee_demographics;

-- RIGHT(TEXT,no. of charcters) same logic as left(text, no. of characters)

-- substring
SELECT
birth_date -- original birth date
FROM employee_demographics;

SELECT
SUBSTRING(birth_date,6,2) AS birth_month-- looks at birth date and counts 6 characters from left, and '2' means to isolate the 2 characters from the right of the text that has been narrowed down, similar to mid function from excel
FROM employee_demographics;


-- REPLACE(text,'what you want replaced within text','what you what to replace it with')
SELECT 
first_name,
REPLACE(first_name, 'a','z') -- need to be cautious of lower or upper case
FROM employee_demographics;

-- concatente; combines columns into one
SELECT
first_name, -- individual column
last_name, -- individual column
CONCAT(first_name, last_name) -- combines the 2 standalone columns into one
FROM employee_demographics;


-- Joins

-- joins allow you to combine 2 tables together (or more) if they have a common column.
-- doesn't mean they need the same column name, but the data in it are the same and can be used to join the tables together
-- there are several joins;  inner joins, outer joins, and self joins

SELECT *
FROM employee_demographics;

SELECT *
FROM employee_salary;




-- start with an inner join -- inner joins return rows that are the same in both columns
-- since we have the same columns we need to specify which table they're coming from
-- by default, JOIN represents INNER JOIN
-- INNER JOIN: only keeps rows where there are matching entries in BOTH tables, dropping the non-matching ones
SELECT *
FROM employee_demographics
JOIN employee_salary
	ON employee_demographics.employee_id = employee_salary.employee_id;


-- use aliasing! ie employee_demographics as dem, makes things easier to read
SELECT *
FROM employee_demographics AS dem
INNER JOIN employee_salary AS sal
	ON dem.employee_id = sal.employee_id;


-- OUTER JOINS = LEFT/RIGHT
-- LEFT JOIN: return all rows from the first table mentioned plus parts of the second table that match the entries in first table. Null is entered for all non matching entries from the second table
-- RIGHT JOIN; returns all rows from the second table plus matching entries from the first table, labelling everyhting that isnt matching from first table as NULL
-- left and right joins are opposites of each other. 
-- LEFT JOIN is most commonly used 
SELECT *
FROM employee_salary AS sal -- since employee_salary is the first table to be mentioned it will be the LEFT table
LEFT JOIN employee_demographics AS dem -- employee_demographics is mentioned after the first table so it is the RIGHT table. 
	ON dem.employee_id = sal.employee_id;


-- so you'll notice we have everything from the left table or the salary table. Even though there is no match to ron swanson. 
-- Since there is not match on the right table it's just all Nulls
-- if we just switch this to a right join it basically just looks like an inner join
-- that's because we are taking everything from the demographics table and only matches from the left or salary table. Since they have all the matches
-- it looks kind of like an inner join
SELECT *
FROM employee_salary sal
RIGHT JOIN employee_demographics dem
	ON dem.employee_id = sal.employee_id;



-- Self Join
-- a self join is where you tie a table to itself
SELECT *
FROM employee_salary;
-- what we could do is a secret santa so the person with the higher ID is the person's secret santa

SELECT *
FROM employee_salary AS emp1
JOIN employee_salary AS emp2
	ON emp1.employee_id = emp2.employee_id
    ;

-- now let's change it to give them their secret santa
SELECT *
FROM employee_salary emp1
JOIN employee_salary emp2
	ON emp1.employee_id + 1  = emp2.employee_id -- idea is; emp_id 2 is assigned to emp_id 1 as secret santa
    ;



SELECT emp1.employee_id as emp_santa, emp1.first_name as santa_first_name, emp1.last_name as santa_last_name, emp2.employee_id, emp2.first_name, emp2.last_name
FROM employee_salary emp1
JOIN employee_salary emp2
	ON emp1.employee_id + 1  = emp2.employee_id
    ;-- So leslie is Ron's secret santa and so on -- Mark Brandanowitz didn't get a secret santa




-- Joining multiple tables
SELECT * 
FROM parks_and_recreation.parks_departments;


SELECT *
FROM employee_demographics dem
INNER JOIN employee_salary sal
	ON dem.employee_id = sal.employee_id
JOIN parks_departments dept
	ON dept.department_id = sal.dept_id;

-- now notice when we did that, since it's an inner join it got rid of andy because he wasn't a part of any department
-- if we do a left join we would still include him because we are taking everything from the left table which is the salary table in this instance
SELECT *
FROM employee_demographics dem
INNER JOIN employee_salary sal
	ON dem.employee_id = sal.employee_id
LEFT JOIN parks_departments dept
	ON dept.department_id = sal.dept_id;


-- first 6 lines of command represents the columns i wanna show from the table
-- recall that JOIN represents INNER JOIN by default, and inner join shows all matching entries from BOTH tables, whilst dropping any non-matching ones. 
SELECT 
emp1.employee_id AS emp_santa,
emp1.first_name AS first_name_santa,
emp1.last_name AS last_name_santa,
emp2.employee_id AS emp_name,
emp2.first_name AS first_name_emp,
emp2.last_name AS last_name_emp
FROM employee_salary AS emp1 -- left table
JOIN employee_salary AS emp2  -- right table
ON emp1.employee_id +1 = emp2.employee_id; -- shows me who is the secret santa for whom



-- Joining multiple tables
-- the second and third join can join to either tables that as the same TYPE of data entry ie emp_id with emp_id, NOT emp_id with emp_name
-- in the example below, the second join, joins the parks department table to the second table simply because there isnt any department_id entry in the first table. 
-- example below uses INNER JOIN, ie, includes all matching entries from the tables and drops everything that is not matching, doesnt label them as null unlike outer join. 
SELECT 
dem.employee_id,
age,
occupation
FROM employee_demographics AS dem
JOIN employee_salary AS sal -- INNER JOIN
ON dem.employee_id = sal.employee_id 
JOIN parks_departments AS pd
ON sal.dept_id = pd.department_id;




#UNIONS
#A union is how you can combine rows together- not columns like we have been doing with joins where one column is put next to another
#Joins allow you to combine the rows of data otherwise it would be really confusing

SELECT first_name, last_name
FROM employee_demographics
UNION
SELECT occupation, salary
FROM employee_salary;


#So we basically combined the data together, but not side by side in different columns, but one on top of the other in the same columns
SELECT first_name, last_name
FROM employee_demographics
UNION
SELECT first_name, last_name
FROM employee_salary;


-- notice it gets rid of duplicates? Union is actually shorthand for Union Distinct
SELECT first_name, last_name
FROM employee_demographics
UNION DISTINCT
SELECT first_name, last_name
FROM employee_salary;


-- we can use UNION ALL to show all values
SELECT first_name, last_name
FROM employee_demographics
UNION ALL
SELECT first_name, last_name
FROM employee_salary;




# The Parks department is trying to cut their budget and wants to identify older employees they can push out or high paid employees who they can reduce pay or push out
-- let's create some queries to help with this

SELECT first_name, last_name, 'Old'
FROM employee_demographics
WHERE age > 50;



SELECT first_name, last_name, 'Old Lady' as Label
FROM employee_demographics
WHERE age > 40 AND gender = 'Female'
UNION
SELECT first_name, last_name, 'Old Man'
FROM employee_demographics
WHERE age > 40 AND gender = 'Male'
UNION
SELECT first_name, last_name, 'Highly Paid Employee'
FROM employee_salary
WHERE salary >= 70000
ORDER BY first_name
;


-- shows you only first and last names from the 2 tables. 
-- UNION ALL doesnt remove duplicates ie you will get 2 copies of Leslie Knope
SELECT first_name, last_name
FROM employee_demographics 
UNION DISTINCT -- removes duplicates
SELECT first_name, last_name
FROM employee_salary;

-- union extracts data according to my comands and shows them as ONE table instead of placing them side by side unlike JOINS
SELECT first_name, last_name, 'Old Man' AS label -- identifies columns to show
FROM employee_demographics -- souce of columns
WHERE age > 40 AND gender = 'Male' -- condition
UNION 
SELECT first_name, last_name, 'Old Lady' AS label
FROM employee_demographics 
WHERE age > 40 AND gender = 'Female'
UNION -- extracts data from emp salary table 
SELECT first_name, last_name, 'Highly Paid Employee' AS label
FROM employee_salary 
WHERE salary  > 70000
;


SELECT
first_name,
last_name,
age,
CASE WHEN age <= 30 THEN 'Young'
     WHEN age BETWEEN 31 and 50 THEN 'Old'
END AS age_category
FROM employee_demographics;


-- pay increase and bonus
-- < 50000 = 5% raise
-- > 50000 = 7% raise
-- finance = 10% bonus
SELECT 
first_name,
last_name,
salary,
CASE WHEN salary <= 50000 THEN salary + (salary * 0.05)-- salary with the 5% raise
     WHEN salary > 50000 THEN salary + (salary * 0.07)
END AS salary_details
FROM employee_salary;


-- attempted CTE 
WITH salary_rank AS (
SELECT 
first_name,
last_name,
salary,
CASE WHEN salary <= 50000 THEN salary + (salary * 0.05)-- salary with the 5% raise
     WHEN salary > 50000 THEN salary + (salary * 0.07)
END AS salary_details
FROM employee_salary
)
SELECT
first_name,
last_name,
salary,
salary_details,
RANK() OVER(ORDER BY salary_details DESC) AS new_salary_rank
FROM salary_rank;

-- Window Functions
SELECT 
gender,
AVG(salary) AS avg_salary
FROM employee_demographics AS dem
JOIN employee_salary AS sal
ON dem.employee_id = sal.employee_id 
GROUP BY gender; 


SELECT 
gender,
AVG(salary) OVER(PARTITION BY gender)
FROM employee_demographics AS dem
JOIN employee_salary AS sal
ON dem.employee_id = sal.employee_id;

SELECT
dem.first_name,
dem.last_name,
gender,
salary,
SUM(salary) OVER(PARTITION BY gender ORDER BY dem.employee_id) AS Rolling_Total
FROM employee_demographics AS dem
JOIN employee_salary AS sal
ON dem.employee_id = sal.employee_id;

SELECT 
dem.first_name,
dem.last_name,
gender,
salary,
ROW_NUMBER ()OVER()
FROM employee_demographics AS dem
JOIN employee_salary AS sal
ON dem.employee_id = sal.employee_id; 



SELECT 
dem.first_name,
dem.last_name,
gender,
salary,
ROW_NUMBER ()OVER(PARTITION BY gender
ORDER BY salary DESC) -- row number is shown per gender ie it analyses by each gender and the rank is given within each gender
FROM employee_demographics AS dem
JOIN employee_salary AS sal
ON dem.employee_id = sal.employee_id; 



SELECT 
dem.first_name,
dem.last_name,
gender,
salary,
DENSE_RANK() OVER(PARTITION BY gender ORDER BY salary DESC) rank_number -- analyses within each bucket, ie how i have partitioned the data
FROM employee_demographics AS dem
JOIN employee_salary AS sal
ON dem.employee_id = sal.employee_id; 













