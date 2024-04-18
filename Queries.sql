CREATE SCHEMA IF NOT EXISTS pandemic;
USE pandemic;

#2
CREATE TABLE countries(
    id INT PRIMARY KEY AUTO_INCREMENT,
    code VARCHAR(8) UNIQUE,
    country VARCHAR(32) NOT NULL UNIQUE
);

INSERT INTO countries (code, country)
SELECT DISTINCT code, entity FROM infectious_cases;

CREATE TABLE cases_normalized
AS SELECT * FROM infectious_cases;

ALTER TABLE cases_normalized
ADD id INT PRIMARY KEY AUTO_INCREMENT FIRST,
ADD country_id INT AFTER id,
ADD CONSTRAINT fk_country_id FOREIGN KEY (country_id) REFERENCES countries(id);

UPDATE cases_normalized i
JOIN countries c ON (i.code = c.code AND i.entity = c.country)
SET i.country_id = c.id
WHERE i.id > 0;

ALTER TABLE cases_normalized
DROP COLUMN entity,
DROP COLUMN code;

SELECT * FROM cases_normalized;

#3
SELECT id, MAX(number_rabies) AS max_value, 
MIN(number_rabies) AS min_value,
AVG(number_rabies) AS average_value,
SUM(number_rabies) AS sum_value
FROM cases_normalized
WHERE number_rabies IS NOT NULL AND number_rabies <> ''
GROUP BY id
ORDER BY average_value DESC
LIMIT 10;


#4
SELECT Entity, Code, Year, 
CONCAT(Year, "-01-01") AS year_start_date
FROM infectious_cases;

SELECT Entity, Code, Year, 
CURDATE() AS year_current_date
FROM infectious_cases;

SELECT Entity, Code, Year,
TIMESTAMPDIFF(YEAR, CONCAT(Year, '-01-01'), CURDATE()) AS difference_year
FROM infectious_cases;


#5
DROP FUNCTION IF EXISTS fn_subtract_now_year;

DELIMITER //

CREATE FUNCTION fn_subtract_now_year(year_value INT)
RETURNS INT
DETERMINISTIC
NO SQL
BEGIN
    DECLARE result INT;
    SET result = YEAR(CURDATE()) - year_value;
    RETURN result;
END //

DELIMITER ;

SELECT fn_subtract_now_year(1984);


DROP FUNCTION IF EXISTS fn_calc_illnesses;

DELIMITER //

CREATE FUNCTION fn_calc_illnesses(num_illnesses_per_year DOUBLE, period INT)
RETURNS DOUBLE
DETERMINISTIC 
NO SQL
BEGIN
    DECLARE result DOUBLE;
    SET result = num_illnesses_per_year / period;
    RETURN result;
END //

DELIMITER ;

SELECT fn_calc_illnesses(20000, 4);
