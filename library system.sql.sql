CREATE TABLE authors (
    author_id INT PRIMARY KEY,
    author_name VARCHAR(100),
    nationality VARCHAR(50)
);

INSERT INTO authors (author_id, author_name, nationality) VALUES
(1, 'Haruki Murakami', 'Japanese'),
(2, 'Jane Austen', 'British'),
(3, 'George Orwell', 'British'),
(4, 'Gabriel Garcia Marquez', 'Colombian');

CREATE TABLE books (
    book_id INT PRIMARY KEY,
    title VARCHAR(150),
    author_id INT, -- This links to authors(author_id)
    genre VARCHAR(50),
    published_year INT,
    FOREIGN KEY (author_id) REFERENCES authors(author_id) -- tells you information linking to author table
);

SELECT * FROM books;

INSERT INTO books (book_id, title, author_id, genre, published_year) VALUES
(101, 'Norwegian Wood', 1, 'Fiction', 1987),
(102, 'Kafka on the Shore', 1, 'Fiction', 2002),
(103, 'Pride and Prejudice', 2, 'Classic', 1813),
(104, 'Emma', 2, 'Classic', 1815),
(105, '1984', 3, 'Dystopian', 1949),
(106, 'Animal Farm', 3, 'Dystopian', 1945),
(107, 'One Hundred Years of Solitude', 4, 'Magical Realism', 1967);

CREATE TABLE loans (
    loan_id INT PRIMARY KEY,
    book_id INT, -- This connects to our books table
    student_name VARCHAR(100),
    loan_date DATE,
    return_date DATE,
    FOREIGN KEY (book_id) REFERENCES books(book_id)
);

INSERT INTO loans (loan_id, book_id, student_name, loan_date, return_date) VALUES
(1, 101, 'Alice Tan', '2026-07-01', '2026-07-15'),
(2, 103, 'Bob Lim', '2026-07-05', NULL), -- NULL means it hasn't been returned yet
(3, 105, 'Alice Tan', '2026-07-10', '2026-07-20'),
(4, 107, 'Charlie Goh', '2026-07-12', NULL);


SELECT 
l.student_name,
b.title,
a.author_name
FROM loans AS l
JOIN books AS b ON l.book_id = b.book_id
JOIN authors AS a ON b.author_id = a.author_id
WHERE l.return_date IS NULL; -- shows you who havent returned their books

SELECT 
a.author_name,
COUNT(*) AS total_loans 
FROM loans AS l
JOIN books AS b ON l.book_id = b.book_id 
JOIN authors AS a ON b.author_id = a.author_id
GROUP BY a.author_name
ORDER BY total_loans DESC;

-- option 1
SELECT 
student_name,
title,
author_name,
COUNT(*) OVER(PARTITION BY student_name) AS total_loans -- sees how many books each student borrowed
FROM loans AS l
JOIN books AS b ON b.book_id = l.book_id -- bridges loans and books table together by common book id
JOIN authors AS a ON a.author_id = b.author_id; -- matches author id from books table to tell you which author id it is frm authors table based on common id


-- option 2 building CTE **** (better option!)
WITH borrower_count AS (
SELECT 
student_name,
title,
author_name,
COUNT(*) OVER(PARTITION BY student_name) AS total_loans
FROM loans AS l 
JOIN books AS b ON b.book_id = l.book_id 
JOIN authors AS a ON a.author_id = a.author_id 
)
SELECT * FROM borrower_count 
WHERE total_loans > 1
ORDER BY total_loans DESC; 


WITH book_counts AS (
    -- Step 1: Get unique count per book
    SELECT 
        b.title,
        a.author_name,
        COUNT(*) AS total_loans
    FROM loans l
    JOIN books b ON l.book_id = b.book_id
    JOIN authors a ON b.author_id = a.author_id
    GROUP BY b.title, a.author_name
)
SELECT 
    title,
    author_name,
    total_loans,
    -- Step 2: Rank the results
    DENSE_RANK() OVER(ORDER BY total_loans DESC) AS popularity_rank
FROM book_counts;

-- *** reminder for SQL execution order ****
-- 1) FROM / JOIN: "First, find the data."

-- 2) WHERE: "Filter out the rows I don't need."

-- 3) GROUP BY: "Now, organize what's left into the buckets/groups I asked for."

-- 4) HAVING: "Filter out the groups I don't want."

-- 5) SELECT: "Now that I've done all the math (counts, sums), finally show the user the columns they asked for."

-- 6) ORDER BY: "Sort the final result."


-- Self Join; comparing one row to another row within the same table 
-- purpose;find r/s within a single list, and/or to identify if 2 different records share a common trait

SELECT 
    l1.student_name AS student_a,
    l2.student_name AS student_b,
    title
FROM loans AS l1
JOIN loans AS l2 ON l1.book_id = l2.book_id -- Find rows with the same book
WHERE l1.student_name < l2.student_name;




-- union all: combines everything and doesnt exclude duplicates
-- union: combines everything that is distinct, removes duplicates

CREATE TABLE old_loans(
student_name VARCHAR(40),
book_id INT,
loan_date DATE 
);

INSERT INTO old_loans (student_name, book_id, loan_date) VALUES 
('Alice Tan', 101, '2026-01-05'),
('Charlie Tan',103,'2026-02-12');

SELECT student_name, book_id, loan_date FROM loans 
UNION
SELECT student_name, book_id, loan_date FROM old_loans;


-- 'current' tells SQL to label each row as current and each row as historical for old loans
WITH master_loan_details AS (
    SELECT student_name, book_id, loan_date,'Current' AS source FROM loans -- 'current' acts as a tag to distinguish between current loans and old loans so we know where each count is from
    UNION ALL -- d
    SELECT student_name, book_id, loan_date,'Historical'AS source FROM old_loans
)
SELECT 
student_name,
source, -- column that shows where the loan came from; old or new loan
COUNT(*) AS total_loans_count
FROM master_loan_details
GROUP BY student_name, source; -- tells SQL to count for EACH student and the source, bec grouping creates seperate piles and it counts each pile


WITH master_loan_details AS (
SELECT student_name, book_id,loan_date, 'Current' AS source FROM loans
UNION ALL 
SELECT student_name, book_id, loan_date, 'Historical' AS source from old_loans
)
SELECT 
student_name,
COUNT(*) AS total_loans
FROM master_loan_details
GROUP BY student_name, source -- gives 2 rows per student. one for current one for historical
HAVING COUNT(*) > 1;






