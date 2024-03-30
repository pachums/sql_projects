#BBDD_EVALUACION
#Francisco Martínez Serrano
#Primera version 03/02/21
#Version actual: 16/02/21
#secure-file-serv: me dio problemas modificarlo, reinstalé MySQL y almacene los datos en la url por defecto.


#DATA PROCESSING

SHOW DATABASES;
DROP DATABASE IF EXISTS researchpapers;
CREATE DATABASE researchpapers;
USE researchpapers;

# AFILIATIONS | Create table and load data 
DROP TABLE IF EXISTS afiliations;
CREATE TABLE afiliations (ref_afiliation INTEGER, university VARCHAR(65), webpage VARCHAR(30), country VARCHAR(15), PRIMARY KEY(ref_afiliation));
LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\tablas_evaluacion\\BDAfiliations.txt' INTO TABLE afiliations  
CHARACTER SET latin1 FIELDS TERMINATED BY ',' ENCLOSED BY ' ' LINES TERMINATED BY '\r\n';

# AUTHORS | Create table and load data 
DROP TABLE IF EXISTS authors;
CREATE TABLE authors (ref_author INTEGER, name VARCHAR(25), PRIMARY KEY( ref_author));
LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\tablas_evaluacion\\BDAuthors.txt' INTO TABLE authors 
CHARACTER SET latin1 FIELDS TERMINATED BY ',' ENCLOSED BY ' ' LINES TERMINATED BY '\r\n';

# AUTHORS_AFILIATION | Create table and load data 
DROP TABLE IF EXISTS authorafiliation;
CREATE TABLE authorafiliation (ref_author INTEGER, ref_afiliation INTEGER, PRIMARY KEY(ref_author,ref_afiliation));
LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\tablas_evaluacion\\BDAuthors_afiliation.txt' INTO TABLE authorafiliation
CHARACTER SET latin1 FIELDS TERMINATED BY ',' ENCLOSED BY ' ' LINES TERMINATED BY '\r\n';

# PAPERSINFO | Create table and load data 
DROP TABLE IF EXISTS papersinfo;
CREATE TABLE papersinfo (ref_paper INTEGER PRIMARY KEY, title VARCHAR(200), publiyear INTEGER,  publisher VARCHAR(40), url VARCHAR(200));
LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\tablas_evaluacion\\BDPaperinfo.txt' INTO TABLE papersinfo  
CHARACTER SET latin1 FIELDS TERMINATED BY ',' ENCLOSED BY ' ' LINES TERMINATED BY '\r\n';

# PAPERSAUTHORS | Create table and load data 
DROP TABLE IF EXISTS papersauthors;
CREATE TABLE papersauthors (ref_paper INTEGER, ref_author INTEGER, PRIMARY KEY(ref_paper,ref_author));
LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\tablas_evaluacion\\BDPapers_authors.txt' INTO TABLE papersauthors 
CHARACTER SET latin1 FIELDS TERMINATED BY ',' ENCLOSED BY ' ' LINES TERMINATED BY '\r\n';

# PAPERSREFERENCES | Create table and load data 
DROP TABLE IF EXISTS papersreferences;
CREATE TABLE papersreferences (ref_paper INTEGER, biblioreference INTEGER, PRIMARY KEY(ref_paper,biblioreference));
LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\tablas_evaluacion\\BDPapers_references.txt' INTO TABLE papersreferences 
CHARACTER SET latin1 FIELDS TERMINATED BY ',' ENCLOSED BY ' ' LINES TERMINATED BY '\r\n';

# DISPLAY DATA
SELECT * FROM afiliations;
SELECT * FROM authorafiliation;
SELECT * FROM authors;
SELECT * FROM papersauthors;
SELECT * FROM papersinfo;
SELECT * FROM papersreferences;

# SAVE DATA LOCALLY
SELECT ref_paper, title  INTO OUTFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\BDpapertitle.txt'
FIELDS TERMINATED BY ','  LINES TERMINATED BY '\r\n' FROM papersinfo;

#EXERCISES
#(APARTADO I)
SELECT ref_paper, title, MAX(number_references) AS number_references FROM (
SELECT ref_paper, title, COUNT(biblioreference) AS number_references 
FROM papersinfo NATURAL JOIN papersreferences 
GROUP BY biblioreference ORDER BY number_references DESC) AS t1;

#(APARTADO II)              
SELECT ref_paper, title FROM papersinfo WHERE ref_paper = ANY(
SELECT ref_paper FROM papersauthors WHERE ref_author = ANY 
(SELECT ref_author FROM authors WHERE (name LIKE 'J_Gray %' OR name LIKE 'A_Szalay%')));
##
SELECT ref_paper FROM papersauthors WHERE ref_paper = ANY
SELECT ref_paper FROM papersauthors WHERE ref_author IN (
SELECT ref_author FROM authors WHERE name LIKE 'A_Szalay%');


#(APARTADO III)
SELECT COUNT(ref_paper) AS num_papers_period FROM papersinfo WHERE ref_paper IN(
SELECT ref_paper FROM papersauthors WHERE ref_author IN(
SELECT ref_author FROM authors WHERE name LIKE 'G_Bell%')) AND publiyear>=2000 AND publiyear<=2007;


#(APARTADO IV)
SELECT name, ref_author FROM authors WHERE ref_author IN(
SELECT ref_author FROM papersauthors WHERE ref_paper IN(
SELECT ref_paper FROM papersauthors WHERE ref_author IN(
SELECT ref_author FROM authors WHERE name LIKE 'J_Gray %')) GROUP BY ref_author) AND 
ref_author NOT IN (SELECT ref_author FROM authors WHERE name LIKE 'J_Gray %');

#(APARTADO V)
SELECT COUNT(ref_paper) AS num_papers_period, name FROM afiliations 
NATURAL JOIN authorafiliation NATURAL JOIN papersauthors NATURAL JOIN papersinfo NATURAL JOIN authors
WHERE afiliations.university LIKE 'Stanford_University' AND publiyear>=1998 AND publiyear<=2008 
GROUP BY name ORDER BY num_papers_period DESC;

SET @v1 = (SELECT SUM(num_papers_period) FROM (
SELECT COUNT(ref_paper) AS num_papers_period, name FROM afiliations 
NATURAL JOIN authorafiliation NATURAL JOIN papersauthors NATURAL JOIN papersinfo NATURAL JOIN authors
WHERE afiliations.university LIKE 'Stanford_University' AND publiyear>=1998 AND publiyear<=2008 
GROUP BY name ORDER BY num_papers_period DESC) AS t1);
SET @v2 = (SELECT COUNT(name) FROM (
SELECT COUNT(ref_paper) AS num_papers_period, name FROM afiliations 
NATURAL JOIN authorafiliation NATURAL JOIN papersauthors NATURAL JOIN papersinfo NATURAL JOIN authors
WHERE afiliations.university LIKE 'Stanford_University' AND publiyear>=1998 AND publiyear<=2008 
GROUP BY name ORDER BY num_papers_period DESC) AS t1);
SET @v3 = (SELECT @v1 / (@v2 * (2008 - 1998 + 1)));

SELECT @v1 AS total_num_papers,@v2 AS total_num_authors,@v3 AS productivity;

#(APARTADO VI)
SELECT ref_paper, title, GROUP_CONCAT(name) AS authors FROM papersinfo 
NATURAL JOIN papersauthors NATURAL JOIN authors
WHERE title LIKE '%data%' GROUP BY ref_paper;

#EJERCICIO 3. SUBPROGRAMAS MYSQL, FUNCIONES
SET GLOBAL log_bin_trust_function_creators = 1; #para solvernar error code 1418

DROP FUNCTION IF EXISTS simulacredito;
DELIMITER //
CREATE FUNCTION simulacredito(euros FLOAT(8,2), meses INT, interes FLOAT(8,2)) returns FLOAT(8,2) 
  BEGIN
	DECLARE i_efectivo FLOAT(10,4);
	SET i_efectivo = (power(1+interes,1/12)-1);
    RETURN euros*i_efectivo / (1-power(1+i_efectivo,-meses)) ;
  END //
DELIMITER ;

SELECT simulacredito(5000, 3, 0.05);

