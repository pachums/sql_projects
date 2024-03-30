/*
CROSSTAB exercise

We have two tables:
	- accounts: id (primary key), iban
	- transactions: account_id (foreign key), dt, amount

We need to get the following table:
	> 4 rows based in each quarter of the year
	> As many columns as distinct values for iban 
	> The table is filles with the sum of the amount of transactions, i.e. the amount of money from the tranfers done by each iban in each quarter of the year.
*/

-- Let's visualize each table
select * from accounts a 
select * from transactions t 

-- Preprocess the two tables into one called iban_quarters
CREATE TABLE IF NOT EXISTS iban_quarters AS
SELECT iban,
       CASE 
           WHEN EXTRACT(month FROM TO_DATE(dt, 'DD/MM/YYYY')) BETWEEN 1 AND 3 THEN 'Q1-23'
           WHEN EXTRACT(month FROM TO_DATE(dt, 'DD/MM/YYYY')) BETWEEN 4 AND 6 THEN 'Q2-23'
           WHEN EXTRACT(month FROM TO_DATE(dt, 'DD/MM/YYYY')) BETWEEN 7 AND 9 THEN 'Q3-23'
           ELSE 'Q4-23'
       END AS quarter,
       amount
FROM transactions tr
INNER JOIN accounts ac ON ac.id = tr.account_id;

-- Let's visualize it
select * from iban_quarters 


-- it's needed for crosstab() function that we will use
CREATE EXTENSION IF NOT EXISTS tablefunc; 


-- We have many different values for iban, we need to generate a query dynamically and after execute it.
SELECT format(
$f$  -- begin dynamic query string
SELECT * FROM crosstab(
   $q$
   SELECT quarter, iban, sum(amount)
   FROM iban_quarters  
   GROUP  BY 1, 2
   ORDER  BY 1, 2
   $q$
 , $c$VALUES (%s)$c$
   ) AS ct(quarter text, %s);
$f$  -- end dynamic query string
            , string_agg(quote_literal(sub.iban), '), (')
            , string_agg(quote_ident  (sub.iban), ' int, ') || ' int'
                 ) 
               	FROM  (SELECT DISTINCT iban FROM iban_quarters ORDER BY 1) sub;


  -- Copy the query and execute it
SELECT * FROM crosstab(
   $q$
   SELECT quarter, iban, sum(amount)
   FROM iban_quarters  
   GROUP  BY 1, 2
   ORDER  BY 1, 2
   $q$
 , $c$VALUES ('ES12 2341'), ('ES12 2342'), ('ES12 2343'), ('ES12 2344'), ('ES12 2345'), ('ES12 2346'), ('ES12 2347'), ('ES12 2348'), ('ES12 2349'), ('ES12 2350')$c$
   ) AS ct(quarter text, "ES12 2341" int, "ES12 2342" int, "ES12 2343" int, "ES12 2344" int, "ES12 2345" int, "ES12 2346" int, "ES12 2347" int, "ES12 2348" int, "ES12 2349" int, "ES12 2350" int);

