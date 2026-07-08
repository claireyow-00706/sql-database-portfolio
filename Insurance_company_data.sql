CREATE TABLE employees (
    employees_id INT PRIMARY KEY,
    first_names VARCHAR(40),
    last_names VARCHAR(40),
    birth_day DATE,
    Sex VARCHAR(2),
    salary INT,
    super_id INT,
    outlet_id INT
);

CREATE TABLE outlet (
    outlet_id INT PRIMARY KEY,
    outlet_name VARCHAR(40),
    mgr_id INT,
    mgr_start_date DATE,
    FOREIGN KEY(mgr_id) REFERENCES employees (employees_id) ON DELETE SET NULL
); 

ALTER TABLE employees
ADD FOREIGN KEY (outlet_id)
REFERENCES outlet(outlet_id)
ON DELETE SET NULL; 

ALTER TABLE employees
ADD FOREIGN KEY (super_id)
REFERENCES employees (employees_id)
ON DELETE SET NULL;

CREATE TABLE outlet_supplier (
    outlet_id INT,
    supplier_name VARCHAR(40),
    supply_type VARCHAR(40),
    PRIMARY KEY (outlet_id,supplier_name),
    FOREIGN KEY(outlet_id) REFERENCES outlet(outlet_id) ON DELETE CASCADE
);

CREATE TABLE Clients (
    client_id INT PRIMARY KEY,
    first_name VARCHAR(40),
    last_name VARCHAR(40),
    outlet_id INT,
    FOREIGN KEY(outlet_id) REFERENCES outlet(outlet_id)
);

CREATE TABLE collab_with (
    employees_id INT,
    client_id INT,
    total_sales INT,
    PRIMARY KEY (employees_id, client_id), 
    FOREIGN KEY(employees_id) REFERENCES employees(employees_id) ON DELETE CASCADE,
    FOREIGN KEY(client_id) REFERENCES Clients(client_id) ON DELETE CASCADE 
);

-- insurance 
INSERT INTO employees VALUES (20,'Finn','Muller','1967-05-12','M',85000,NULL,NULL);
INSERT INTO outlet VALUES (1,'insurance',20,'2022-02-06');

UPDATE employees
SET outlet_id = 1
WHERE employees_id = 20;

INSERT INTO employees VALUES (21,'Lucus','Schmidt','1972-08-30','M',200000,20,1);

-- account
INSERT INTO employees VALUES (22,'Jonas','Fischer','1983-01-01','M',65000,NULL,NULL);
INSERT INTO outlet VALUES (2,'account',22,'2022-04-01');

UPDATE employees
SET outlet_id = 2
WHERE employees_id = 22;

INSERT INTO employees VALUES (23,'Ella','Weber','1964-05-22','F',1700000,22,2);
INSERT INTO employees VALUES (24,'Ida','Wagner','1970-03-07','F',90000,22,2);
INSERT INTO employees VALUES (25,'Ben','Schneider','1973-08-25','M',72000,22,2);

-- energy
INSERT INTO employees VALUES (26,'Oliver','Brown','1989-03-02','M',199000,NULL,NULL);
INSERT INTO outlet VALUES (3,'energy',26,'2019-02-24');

UPDATE employees
SET outlet_id = 3
WHERE employees_id = 26;

INSERT INTO employees VALUES (27,'Leonie','Williams','1977-07-07','M',80000,26,3);
INSERT INTO employees VALUES (28,'Lea','Zimmerman','1983-12-05','F',62000,26,3);


-- outlet_supplier
INSERT INTO outlet_supplier VALUES (1,'S_Direkt','insurance');
INSERT INTO outlet_supplier VALUES (1,'Inshared','insurance');
INSERT INTO outlet_supplier VALUES (2,'Deutsche_bank','credit');
INSERT INTO outlet_supplier VALUES (2,'Commerzbank','credit');
INSERT INTO outlet_supplier VALUES (3,'Ostrom','renewable');
INSERT INTO outlet_supplier VALUES (3,'E.On_energy','Electricity');


-- Client
INSERT INTO Clients VALUES (10,'daneil','maier',2);
INSERT INTO Clients VALUES (11,'ella','walter',2);
INSERT INTO Clients VALUES (12,'zhang','wei',1);
INSERT INTO Clients VALUES (13,'ivan','kirillov',3);
INSERT INTO Clients VALUES (14,'john','smith',3);
INSERT INTO Clients VALUES (15,'dirk','pellter',1);
INSERT INTO Clients VALUES (16,'tobias','roth',1);
INSERT INTO Clients VALUES (17,'leanne','louis',1);

-- collab_with
INSERT INTO collab_with VALUES (28, 14, 120000);
INSERT INTO collab_with VALUES (27, 15, 6000);   
INSERT INTO collab_with VALUES (20, 15, 6000);  
INSERT INTO collab_with VALUES (25, 10, 55000);  
INSERT INTO collab_with VALUES (21, 11, 40000);  

SELECT*FROM employees;




-- 1. Drop the table first if a broken/partial version exists
DROP TABLE IF EXISTS collab_with;

-- 2. Create the table cleanly with the correct singular name
CREATE TABLE collab_with (
    employees_id INT,
    client_id INT,
    total_sales INT,
    PRIMARY KEY (employees_id, client_id),
    FOREIGN KEY(employees_id) REFERENCES employees(employees_id) ON DELETE CASCADE,
    FOREIGN KEY(client_id) REFERENCES Clients(client_id) ON DELETE CASCADE 
);

-- 3. Insert the corrected data values (fixing the invalid IDs from before)
INSERT INTO collab_with VALUES (28, 14, 120000);
INSERT INTO collab_with VALUES (27, 15, 6000);
INSERT INTO collab_with VALUES (20, 15, 6000);
INSERT INTO collab_with VALUES (25, 10, 55000);
INSERT INTO collab_with VALUES (21, 11, 40000);


-- 1. Drop the child table first, then the parent table to avoid constraint blocks
DROP TABLE IF EXISTS collab_with;
DROP TABLE IF EXISTS employees;

-- 2. Re-create the employees table cleanly
CREATE TABLE employees (
    employees_id INT PRIMARY KEY, -- Ensure this matches exactly
    first_names VARCHAR(40),
    last_names VARCHAR(40),
    birth_day DATE,
    Sex VARCHAR(2),
    salary INT,
    super_id INT,
    outlet_id INT
);

-- 3. Create the collab_with table referencing 'employees_id'
CREATE TABLE collab_with (
    employees_id INT,
    client_id INT,
    total_sales INT,
    PRIMARY KEY (employees_id, client_id),
    -- References employees(employees_id) matches the parent table exactly
    FOREIGN KEY(employees_id) REFERENCES employees(employees_id) ON DELETE CASCADE,
    FOREIGN KEY(client_id) REFERENCES Clients(client_id) ON DELETE CASCADE 
);

-- 1. Drop the tables in correct order to avoid constraint blocks
DROP TABLE IF EXISTS collab_with;
DROP TABLE IF EXISTS Clients;

-- 2. Re-create the Clients table cleanly
CREATE TABLE Clients (
    client_id INT PRIMARY KEY,
    first_name VARCHAR(40),
    last_name VARCHAR(40),
    outlet_id INT,
    FOREIGN KEY(outlet_id) REFERENCES outlet(outlet_id)
);

-- 3. Re-create the collab_with table with matching references
CREATE TABLE collab_with (
    employees_id INT,
    client_id INT,
    total_sales INT,
    PRIMARY KEY (employees_id, client_id),
    FOREIGN KEY(employees_id) REFERENCES employees(employees_id) ON DELETE CASCADE,
    FOREIGN KEY(client_id) REFERENCES Clients(client_id) ON DELETE CASCADE 
);










-- 1. Drop child tables first to clear dependencies
DROP TABLE IF EXISTS collab_with;
DROP TABLE IF EXISTS Clients;
DROP TABLE IF EXISTS outlet_supplier;

-- 2. Drop parent tables last
DROP TABLE IF EXISTS employees;
DROP TABLE IF EXISTS outlet;


-- 3. Create the OUTLET table first (Core parent table)
CREATE TABLE outlet (
    outlet_id INT PRIMARY KEY,
    outlet_name VARCHAR(40),
    mgr_id INT,
    mgr_start_date DATE
); 


-- 4. Create the EMPLOYEES table
CREATE TABLE employees (
    employees_id INT PRIMARY KEY,
    first_names VARCHAR(40),
    last_names VARCHAR(40),
    birth_day DATE,
    Sex VARCHAR(2),
    salary INT,
    super_id INT,
    outlet_id INT
);


-- 5. Link the circular Foreign Keys safely via ALTER statements
ALTER TABLE outlet
ADD FOREIGN KEY(mgr_id) 
REFERENCES employees(employees_id) 
ON DELETE SET NULL;

ALTER TABLE employees
ADD FOREIGN KEY (outlet_id)
REFERENCES outlet(outlet_id)
ON DELETE SET NULL; 

ALTER TABLE employees
ADD FOREIGN KEY (super_id)
REFERENCES employees(employees_id)
ON DELETE SET NULL;


-- 6. Create OUTLET_SUPPLIER (Safe now because 'outlet' definitely exists)
CREATE TABLE outlet_supplier (
    outlet_id INT,
    supplier_name VARCHAR(40),
    supply_type VARCHAR(40),
    PRIMARY KEY (outlet_id, supplier_name),
    FOREIGN KEY(outlet_id) REFERENCES outlet(outlet_id) ON DELETE CASCADE
);


-- 7. Create CLIENTS (Safe now because 'outlet' definitely exists)
CREATE TABLE Clients (
    client_id INT PRIMARY KEY,
    first_name VARCHAR(40),
    last_name VARCHAR(40),
    outlet_id INT,
    FOREIGN KEY(outlet_id) REFERENCES outlet(outlet_id)
);


-- 8. Create COLLAB_WITH (Safe now because 'employees' and 'Clients' exist)
CREATE TABLE collab_with (
    employees_id INT,
    client_id INT,
    total_sales INT,
    PRIMARY KEY (employees_id, client_id),
    FOREIGN KEY(employees_id) REFERENCES employees(employees_id) ON DELETE CASCADE,
    FOREIGN KEY(client_id) REFERENCES Clients(client_id) ON DELETE CASCADE 
);

-- insurance 
INSERT INTO employees VALUES (20,'Finn','Muller','1967-05-12','M',85000,NULL,NULL);
INSERT INTO outlet VALUES (1,'insurance',20,'2022-02-06');

UPDATE employees
SET outlet_id = 1
WHERE employees_id = 20;

INSERT INTO employees VALUES (21,'Lucus','Schmidt','1972-08-30','M',200000,20,1);

-- account
INSERT INTO employees VALUES (22,'Jonas','Fischer','1983-01-01','M',65000,NULL,NULL);
INSERT INTO outlet VALUES (2,'account',22,'2022-04-01');

UPDATE employees
SET outlet_id = 2
WHERE employees_id = 22;

INSERT INTO employees VALUES (23,'Ella','Weber','1964-05-22','F',1700000,22,2);
INSERT INTO employees VALUES (24,'Ida','Wagner','1970-03-07','F',90000,22,2);

-- energy
INSERT INTO employees VALUES (26,'Oliver','Brown','1989-03-02','M',199000,NULL,NULL);
INSERT INTO outlet VALUES (3,'energy',26,'2019-02-24');

UPDATE employees
SET outlet_id = 3
WHERE employees_id = 26;

INSERT INTO employees VALUES (27,'Leonie','Williams','1977-07-07','M',80000,26,3);
INSERT INTO employees VALUES (28,'Lea','Zimmerman','1983-12-05','F',62000,26,3);


-- outlet_supplier
INSERT INTO outlet_supplier VALUES (1,'S_Direkt','insurance');
INSERT INTO outlet_supplier VALUES (1,'Inshared','insurance');
INSERT INTO outlet_supplier VALUES (2,'Deutsche_bank','credit');
INSERT INTO outlet_supplier VALUES (2,'Commerzbank','credit');
INSERT INTO outlet_supplier VALUES (3,'Ostrom','renewable');
INSERT INTO outlet_supplier VALUES (3,'E.On_energy','Electricity');


-- Client
INSERT INTO Clients VALUES (10,'daneil','maier',2);
INSERT INTO Clients VALUES (11,'ella','walter',2);
INSERT INTO Clients VALUES (12,'zhang','wei',1);
INSERT INTO Clients VALUES (13,'ivan','kirillov',3);
INSERT INTO Clients VALUES (14,'john','smith',3);
INSERT INTO Clients VALUES (15,'dirk','pellter',1);
INSERT INTO Clients VALUES (16,'tobias','roth',1);
INSERT INTO Clients VALUES (17,'leanne','louis',1);

-- collab_with
INSERT INTO collab_with VALUES (28, 14, 120000);
INSERT INTO collab_with VALUES (27, 15, 6000);   
INSERT INTO collab_with VALUES (20, 15, 6000);  
INSERT INTO collab_with VALUES (25, 10, 55000);  
INSERT INTO collab_with VALUES (21, 11, 40000);  


