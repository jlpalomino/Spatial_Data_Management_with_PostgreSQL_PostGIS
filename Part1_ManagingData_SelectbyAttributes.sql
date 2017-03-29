/* To run a query, highlight the line(s) to include the ; and click on the Executy Query icon above (looks like a Play button). */

/* Section 1 - Introduction to working with tables in PostgreSQL */
/* Create a new table */
/* Primary Key is the unique ID for each record in the table. It has a constraint that it must be unique for each record */
/* varchar is a text field of variable length with the limit set by the number in the () */
CREATE TABLE employees (
	uid integer PRIMARY KEY,
	firstname varchar(50) NOT NULL,
    lastname varchar(50) NOT NULL,
	department varchar(50) NOT NULL
);

/* Populate table with values */
INSERT INTO employees (uid, firstname, lastname, department) VALUES (1, 'Elizabeth', 'Smith', 'Public Health');
INSERT INTO employees (uid, firstname, lastname, department) VALUES (2, 'Edward', 'Jones', 'Transportation');
INSERT INTO employees (uid, firstname, lastname, department) VALUES (3, 'Kelly', 'Johnson', 'Education');
INSERT INTO employees (uid, firstname, lastname, department) VALUES (4, 'Thomas', 'Peters', 'Financial');
INSERT INTO employees (uid, firstname, lastname, department) VALUES (5, 'Patty', 'Jackson', 'Financial');

/* If we try to assign a duplicate uid, we will get an error that the uid already exists*/
INSERT INTO employees (uid, firstname, lastname, department) VALUES (5, 'Mary', 'Anderson', 'Public Works');


/* */
/* Task #1: Add yourself to this table in the Education department */
/* */


/* Get a count of the number of records in the table */
SELECT count(*) from employees;

/* View all records and columns in the table */
SELECT * FROM employees;

/* View specific columns only */
SELECT lastname, department FROM employees;

/* Sort the table values */
/* DESC is used for descending order */
SELECT * FROM employees order by firstname ASC;

/* You can also limit the number of results that are returned by the query */
SELECT * FROM employees order by firstname ASC limit 2;

/* Select the unique values from a column */
/* This is helpful so that you know what values can be used to query the data */
SELECT distinct(department) FROM employees;

/* Select the records that meet a certain criteria */
SELECT * FROM employees where department = 'Financial';

/* Count these records that meet a certain criteria */
SELECT count(*) FROM employees where department = 'Financial';

/* Or get a list of counts for all values of a column */
SELECT department, count(*) FROM employees group by department;

/* Then order the list of counts by department */
SELECT department, count(*) FROM employees group by department order by department;

/* Delete certain values from table */
DELETE FROM employees WHERE department = 'Financial';

/* Add new column to table */
ALTER TABLE employees ADD officeloc varchar(50);

/* Add data to this new column */
UPDATE employees SET officeloc = '124 Mulford' WHERE department = 'Education';


/* */
/* Task #2: Add an office location to whoever is left in the table as either 103, 111, or 132 Mulford */
/* Hint: you will first need to query the table to see who is left without a value for office */
/* */



/* */
/* Task #3: Get a count of employees in each office location */
/* Hint: you will need to use a group by clause along with the count records */
/* */


/* Delete columns from tables */
ALTER TABLE employees DROP officeloc;

/* Delete the whole table */
DROP TABLE employees;


/* Section 2 - Loading Tabular Data into PostgreSQL */
/* Create new table to store imported csv data */
/* Remember that you are assigning the column names in this create query */

CREATE TABLE lymedisease (
	county varchar(50),
	y2005 integer,
	y2006 integer,
    y2007 integer,
    y2008 integer,
    y2009 integer,
    y2010 integer,
    y2011 integer,
    y2012 integer,
    y2013 integer,
    y2014 integer,
	population integer,
	incidence float
);

/* Import csv data */
/* The WITH clause holds the options where we set the column delimiter and exclude the first row that has the headers */
COPY lymedisease FROM '/home/ubuntu/Downloads/Spatial_Data_Management_with_PostgreSQL_PostGIS-master/csv/Lyme disease CA 05-14 report year.csv' WITH DELIMITER ',' HEADER CSV;


/* */
/* Task #4 - Query this table to find the record for Alameda county*/
/* Hint: it could be helpful to query for the unique values in the county column so you can see how the county names are listed*/
/* */



/* */
/* Task #5 - Sort the table to find which county has the highest value in 2005 */
/* Hint: you will need to sort the table using DESC */
/* */



/* Query this table to see only counties that have at least one lyme disease case in 2005 */
SELECT * from lymedisease where y2005 > 0;

/* Get a count of the number of records that fill that criteria (only counties that have at least one lyme disease case in 2005)*/
SELECT count(*) from lymedisease where y2005 > 0;

/* Create a new column to label these counties (only counties that have at least one lyme disease case in 2005)*/
ALTER TABLE lymedisease ADD y2005label varchar(50);


/* */
/* Task #6 - Modify y2005label depending on 2005 value */
/* For counties that have at least one lyme disease case in 2005, set equal to value of "YES" */
/* For counties that do NOT have at least one lyme disease case in 2005, set equal to value of "NO" */
/* Hint: review your answer for Task #2 */
/* */




/* Export the revised table to csv */
COPY lymedisease TO '/home/ubuntu/Downloads/RevisedLymeDisease.csv' WITH DELIMITER ',' HEADER CSV;


/* Section 3 - Managing User Access to Data */ 
/* */
/* Task #7 - Create a new user for yourself (ex: jpalomino) */
/* Step 1: in the pgAdmin Object browser menu (left side of pgadmin), right-click on Login Roles and select New Login Role */
/* Step 2: assign a Role name in the Properties tab and a password in the Defintion tab */
/* */



/* */
/* Task #8 - Grant permissions to the new user by updating queries below */
/* */
/* Granting permissions or privileges: https://www.postgresql.org/docs/9.6/static/sql-grant.html */

/* Grant certain permissions such as select and insert of new records to new user on table lymedisease */
GRANT SELECT, INSERT ON lymedisease TO jpalomino;

/* We can grant other permissions too to allow updating and deleting of records in the table */
GRANT UPDATE, DELETE ON lymedisease TO jpalomino; 

/* You can also specify the columns that these permissions apply to */
/* GRANT SELECT (column_name), INSERT ON (columnname) ON lymedisease TO jpalomino;*/

/* Or you can assign the permissions to the entire database */
GRANT CONNECT ON DATABASE bootcamp TO jpalomino; 
GRANT ALL PRIVILEGES ON DATABASE bootcamp TO jpalomino;


/* For information about creating new users in pqsql: https://www.postgresql.org/docs/current/static/app-createuser.html */

