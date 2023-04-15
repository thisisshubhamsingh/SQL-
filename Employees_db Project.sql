USE employees;

/*
	Exercise 1
	Find the average salary of the male and female employees in each department. 
*/

SELECT * FROM employees;
SELECT * FROM salaries;
SELECT * FROM departments;
SELECT * FROM dept_emp;

SELECT
    de.dept_no,
    d.dept_name,
    e.gender,
    ROUND(AVG(s.salary),2) AS Avg_salary
FROM
	employees e 
		JOIN
	dept_emp de ON e.emp_no = de.emp_no
		JOIN
	departments d ON de.dept_no = d.dept_no
		JOIN
	salaries s ON s.emp_no = e.emp_no
GROUP BY de.dept_no , e.gender
ORDER BY de.dept_no;

SELECT
	de.dept_no,
    e.gender
FROM
	dept_emp de 
		JOIN
	employees e ON de.emp_no = e.emp_no
GROUP BY dept_no, gender
ORDER BY dept_no;




/*
	Exercise 2
	Find the lowest department number encountered in the 'dept_emp' table. Then, find the highest 
	department number.
*/


SELECT 
    MIN(dept_no) AS lowest_dept_no,
    MAX(dept_no) AS highest_dept_no
FROM
    dept_emp;
    
    
    
/*
	Exercise 3
	Obtain a table containing the following three fields for all individuals whose employee number is not 
	greater than 10040: 
	- employee number 
	- the lowest department number among the departments where the employee has worked in (Hint: use 
	a subquery to retrieve this value from the 'dept_emp' table) 
    
	- assign '110022' as 'manager' to all individuals whose employee number is lower than or equal to 10020, 
	and '110039' to those whose number is between 10021 and 10040 inclusive
*/


SELECT 
    e.emp_no,
    (SELECT 
            MIN(de.dept_no)
		FROM
            dept_emp de
        WHERE
            de.emp_no = e.emp_no) AS dept_no,
    CASE
        WHEN e.emp_no <= 10020 THEN 110022
        WHEN e.emp_no BETWEEN 10021 AND 10040 THEN 110039
        ELSE 0
    END AS Manager
FROM
    employees e
WHERE
    e.emp_no <= 10040;


SELECT 
    emp_no,
    MIN(dept_no)
FROM
    dept_emp
GROUP BY emp_no;


/*
	Exercise 4
	Retrieve a list of all employees that have been hired in 2000.
*/


SELECT * FROM employees;

SELECT 
	* 
FROM
	employees
WHERE
	EXTRACT(YEAR FROM hire_date) = 2000;
   
-- Or

SELECT 
	* 
FROM
	employees
WHERE
	hire_date LIKE '2000%';




/*
	Exercise 5
	Retrieve a list of all employees from the ‘titles’ table who are engineers. 
	Repeat the exercise, this time retrieving a list of all employees from the ‘titles’ table who are senior 
	engineers.
*/


SELECT * FROM titles;

SELECT
	*
FROM
	titles
WHERE 
	title LIKE ('%engineer%');
    

SELECT
	*
FROM
	titles
WHERE 
	title = 'Senior engineer';
    

/*
	Exercise 6
	Create a procedure that asks you to insert an employee number and that will obtain an output containing 
	the same number, as well as the number and name of the last department the employee has worked in. 
	Finally, call the procedure for employee number 10010. 
    
	If you've worked correctly, you should see that employee number 10010 has worked for department 
	number 6 - "Quality Management". 
*/
    
DROP PROCEDURE IF EXISTS get_emp_dept;

DELIMITER $$
CREATE PROCEDURE get_emp_dept (IN Par_emp_no INT)
BEGIN

	SELECT
		A.*
	FROM
		(SELECT
			de.emp_no,
			de.dept_no,
			MAX(from_date),
			d.dept_name
		FROM 
			dept_emp de 
				JOIN
			departments d ON de.dept_no = d.dept_no
		WHERE to_date LIKE ('9999%')
		GROUP BY de.emp_no) AS A
	WHERE emp_no = Par_emp_no;

END $$
DELIMITER ;

CALL get_emp_dept(10010);





SELECT * FROM employees;
SELECT * FROM dept_emp;
SELECT * FROM departments;

SELECT
	de.emp_no,
    de.dept_no,
    MAX(from_date),
    d.dept_name
FROM 
	dept_emp de 
		JOIN
	departments d ON de.dept_no = d.dept_no
WHERE to_date LIKE ('9999%')
GROUP BY de.emp_no;


/*
	Exercise 7
	How many contracts have been registered in the ‘salaries’ table with duration of more than one year and 
	of value higher than or equal to $100,000? 
	Hint: You may wish to compare the difference between the start and end date of the salaries contracts
*/

SELECT
	COUNT(*) AS Num_of_contract
FROM
	(SELECT
		A.*
	FROM
		(SELECT 
			*,
			EXTRACT(YEAR FROM to_date)-EXTRACT(YEAR FROM from_date) AS year_diff
		FROM
			salaries) AS A
	WHERE 
		year_diff > 1 AND salary >= 100000) AS B;



/*
	Exercise 8
	Create a trigger that checks if the hire date of an employee is higher than the current date. If true, set the 
	hire date to equal the current date. Format the output appropriately (YY-mm-dd). 
	Extra challenge: You can try to declare a new variable called 'today' which stores today's data, and then 
	use it in your trigger! 
	After creating the trigger, execute the following code to see if it's working properly
*/

SELECT * FROM employees;

DROP TRIGGER IF EXISTS check_hire_date;

DELIMITER $$
CREATE TRIGGER check_hire_date
AFTER INSERT ON employees
FOR EACH ROW
BEGIN
	DECLARE today DATE ;
    SELECT 
		MAX(hire_date)
	INTO today
    FROM 
		employees;
	
	IF today > CURRENT_DATE
	THEN
		UPDATE employees
		SET hire_date = CURRENT_DATE()
        WHERE hire_date = NEW.hire_date;
	END IF;
    
END$$
DELIMITER ;

SELECT * FROM employees;

INSERT INTO employees 
VALUES (9999905 , '1977-09-14' , 'shubham' , 'singh' , 'M' , '2023-04-24');






/*
	Exercise 9
	Define a function that retrieves the largest contract salary value of an employee. Apply it to employee 
	number 11356. 
	In addition, what is the lowest contract salary value of the same employee? You may want to create a new 
	function that to obtain the result. 
*/


SELECT * FROM salaries;

DROP FUNCTION IF EXISTS  get_highest_emp_salary;

DELIMITER $$ 
CREATE FUNCTION get_highest_emp_salary (Par_emp_no INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
	DECLARE Max_salary DECIMAL(10,2);
    
    SELECT
		MAX(salary)
	INTO Max_salary
	FROM
		salaries
	WHERE 
		emp_no = Par_emp_no
	GROUP BY emp_no;
		
RETURN Max_salary ;
END$$
DELIMITER ;

SELECT  get_highest_emp_salary(11356) AS Highest_salary;





DROP FUNCTION IF EXISTS  get_lowest_emp_salary;

DELIMITER $$ 
CREATE FUNCTION get_lowest_emp_salary (Par_emp_no INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
	DECLARE Min_salary DECIMAL(10,2);
    
    SELECT
		MIN(salary)
	INTO Min_salary
	FROM
		salaries
	WHERE 
		emp_no = Par_emp_no
	GROUP BY emp_no;
		
RETURN Min_salary ;
END$$
DELIMITER ;

SELECT  get_lowest_emp_salary(11356) AS lowest_salary;




/*
	Exercise 10
	Based on the previous exercise, you can now try to create a third function that also accepts a second 
	parameter. Let this parameter be a character sequence. Evaluate if its value is 'min' or 'max' and based on 
	that retrieve either the lowest or the highest salary, respectively (using the same logic and code structure 
	from Exercise 9). If the inserted value is any string value different from ‘min’ or ‘max’, let the function 
	return the difference between the highest and the lowest salary of that employee. 
*/


DROP FUNCTION IF EXISTS emp_salary_info;

DELIMITER $$
CREATE FUNCTION emp_salary_info (Par_emp_no INT , Par_min_or_max VARCHAR(10))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
	
	DECLARE emp_salary_info DECIMAL(10,2);
    
    SELECT
		CASE
			WHEN Par_min_or_max = 'min' THEN MIN(s.salary)
            WHEN Par_min_or_max = 'max' THEN MAX(s.salary)
            ELSE
				MAX(s.salary) - MIN(s.salary)
		END AS salary_diff
	INTO emp_salary_info
    FROM
		employees e
			JOIN
		salaries s ON e.emp_no = s.emp_no
	WHERE
		e.emp_no = Par_emp_no;
	
RETURN emp_salary_info;

END$$
DELIMITER ;


SELECT
	emp_no,
    MAX(salary),
    MIN(salary)
FROM
    salaries
GROUP BY emp_no;

SELECT emp_salary_info(10001 , 'max') AS max_salary;
SELECT emp_salary_info(10001 , 'min') AS min_salary;
SELECT emp_salary_info(10001 , 'abc') AS salary_diff;