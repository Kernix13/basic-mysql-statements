--  KEYWORDS: 
-- all, PK = Primary Key, NN = Not Null, AI = Auto-Increment
-- *, = , =, <, >,, %, SELECT, FROM, INSERT INTO, VALUES(), WHERE, 
-- UPDATE, SET, DELETE, CREATE TABLE, NOW(), JOIN, ON, foreign keys, 
-- indexes, LIMIT, SUM, MIN, MAX, COUNT, EXPLAIN, RESTRICT, NO ACTION, 
-- CASCADE, SET NULL, LIKE, GROUP BY, HAVING, as, MATCH, AGAINST, 
-- INNER JOIN, LEFT JOIN, RIGHT JOIN, UNION, UNION ALL, ORDER BY, 
-- ASC, DESC, AND, LEFT, CONCAT, IF, ...

-- basic select statement
SELECT * FROM petfoodsreference.animals;
EXPLAIN SELECT * FROM petfoodsreference.animals;

-- to add records to a table
INSERT INTO  animals (name, species) VALUES ('Buddy', 'dog') 

-- may need to put the database name before the table name
INSERT INTO  petfoods.animals (name, species) VALUES ('Buddy', 'dog') 

-- where statement to filter records (wrap columns in backticks)
SELECT * FROM animals WHERE `species` = 'dog';
SELECT * FROM animals WHERE `weight` > 35
SELECT `name`, `email` FROM animals WHERE `weight` > 35

-- update statement to add or change a record, delete a record
UPDATE animals SET `name` = 'Bibi' WHERE `name` = 'Buddy';
UPDATE animals SET `weight` = '12', `birthdate` = '2013-02-10', `joindate` = '2018-01-01', `email` = 'meow@cats.com' WHERE `id` = 1;

DELETE FROM animals WHERE `name` = 'Barksalot'
DELETE FROM orders WHERE id = 1

-- full code to create a table
CREATE TABLE `petfoods`.`products` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(60) NULL,
  `priceusd` DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (`id`));

-- join statement
SELECT * FROM orders JOIN animals ON orders.userid = animals.id 
SELECT * FROM orderlines JOIN products ON orderlines.productid = products.id WHERE orderid = 1

-- insert multiple rows at once:
VALUES (1, 3, 4), (1, 4, 1), ...

-- aggeragte Function and alias
SELECT SUM(products.priceusd * orderlines.quantity) as 'subtotal'

-- nested query
WHERE orderid = (SELECT id FROM orders WHERE userid = 1 LIMIT 1) 

-- TO SEARCH USE PERCENTAGE SIGN
SELECT * FROM petfoods.reviews WHERE description LIKE '%great%';
SELECT * FROM table_name WHERE MATCH(col_name) AGAINST('search-string') 

-- aggregate Functions:
-- AVG(col_name) MAX(col_name) MIN(col_name) COUNT(col_name) 

-- group by - use to create 1 row for sub-groups or collections
-- https://www.mysqltutorial.org/mysql-group-by.aspx 
SELECT COUNT(species), species, weight FROM animals GROUP BY species, weight 

-- having better than where
SELECT AVG(weight) as 'Average Weight', species FROM animals GROUP BY species HAVING `Average Weight` >= 50

-- joins with nicknames, multiple left joins, 
SELECT * FROM animals a INNER JOIN orders o ON a.id = o.userid

SELECT * FROM animals a
LEFT JOIN orders o ON a.id = o.userid
LEFT JOIN orderlines ols ON ols.orderid = o.id
LEFT JOIN products p ON ols.productid = p.id

-- UNION
SELECT * FROM animals UNION SELECT * FROM orders

-- UNION with ORDER BY for sort
SELECT name FROM animals
UNION 
SELECT name FROM products ORDER BY name

-- PRACTICE REVIEW PT 1 solution
SELECT p.name, AVG(r.rating) as 'Avg Rating' FROM reviews r
JOIN products p ON r.productreviewed = p.id
GROUP BY r.productreviewed
ORDER BY `Avg Rating` DESC 
LIMIT 5

-- 2nd problem solution
SELECT p.name, COUNT(ols.id) as 'Item Count' FROM orderlines ols
JOIN orders o ON ols.orderid = o.id
JOIN animals a ON o.userid = a.id AND a.species = 'dog'
JOIN products p ON ols.productid = p.id
GROUP BY ols.productid
ORDER BY `Item Count` DESC 
LIMIT 5

-- 3rd problem solution
SELECT DISTINCT a.email FROM animals a 
JOIN orders o ON o.userid = a.id
JOIN orderlines ols ON o.id = ols.orderid AND ols.productid = 46

-- 4th problem solution
SELECT a.name, a.email, SUM(quantity * priceusd) as 'Total $' 
FROM orderlines ols
JOIN orders o ON ols.orderid = o.id
JOIN animals a ON o.userid = a.id
JOIN products p ON ols.productid = p.id
GROUP BY a.id
ORDER BY `Total $` DESC LIMIT 5

-- 5th problem - use LEFT() function
SELECT COUNT('id') as 'Count', LEFT(name, 1) as 'initial' FROM animals
GROUP BY `initial`
ORDER BY `initial`

-- stored routines, problem 1 using CONCAT
SELECT name, CONCAT(weight, IF(weight >= 75, ' which is not healthy.', ' which is healthy.')) as weight 
FROM petfoodsreference.animals;

-- create function template:
CREATE FUNCTION `new_function` ()
RETURNS INTEGER
BEGIN

RETURN 1;
END

-- finihed version:
CREATE DEFINER=`root`@`localhost` FUNCTION `weightLogic`(theweight INT) RETURNS varchar(100) CHARSET utf8mb4
    DETERMINISTIC
BEGIN

RETURN CONCAT(theweight, IF(theweight >= 75, ' which is not healthy.', ' which is healthy.'));
END

-- next function, query first
SELECT name, discountLogic(priceusd, name) FROM petfoodsreference.products;

CREATE DEFINER=`root`@`localhost` FUNCTION `discountLogic`(theprice decimal(10, 2), thename varchar(60)) RETURNS decimal(10,2)
    DETERMINISTIC
BEGIN

RETURN CASE LEFT(thename, 1)
WHEN 'A' THEN theprice * 0.5
WHEN 'F' THEN 0
ELSE theprice
END;
END

-- boilerplate stored proceedure
CREATE PROCEDURE `new_procedure` ()
BEGIN

END

-- solution to problem
CREATE DEFINER=`root`@`localhost` PROCEDURE `commonlyordered`(IN species varchar(100))
BEGIN
SELECT p.name, COUNT(ols.id) as 'The Count' FROM orderlines ols
JOIN orders o ON ols.orderid = o.id
JOIN animals a ON o.userid = a.id AND a.species = species
JOIN products p ON ols.productid = p.id
GROUP BY ols.productid
ORDER BY `The Count` DESC
LIMIT 5;
END

-- created petfoodsref to see if I don't get the error
CREATE SCHEMA `petfoodsref` DEFAULT CHARACTER SET utf8mb4;

-- fix: add this on any line with = sign: COLLATE utf8mb4_0900_ai_ci
CREATE DEFINER=`root`@`localhost` PROCEDURE `commonordered`(IN species varchar(100))
BEGIN
SELECT p.name, COUNT(ols.id) as 'The Count' FROM orderlines ols
JOIN orders o ON ols.orderid = o.id COLLATE utf8mb4_0900_ai_ci
JOIN animals a ON o.userid = a.id AND a.species = species COLLATE utf8mb4_0900_ai_ci
JOIN products p ON ols.productid = p.id COLLATE utf8mb4_0900_ai_ci
GROUP BY ols.productid
ORDER BY `The Count` DESC
LIMIT 5;
END

-- resulting 'call' code for the procedure
call petfoodsreference.commonlyordered('hamster');

-- View boilerplate
CREATE VIEW `new_view` AS

-- View example
CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `root`@`localhost` 
    SQL SECURITY DEFINER
VIEW `commondogproducts` AS
    SELECT 
        `p`.`name` AS `name`, COUNT(`ols`.`id`) AS `The Count`
    FROM
        (((`orderlines` `ols`
        JOIN `orders` `o` ON ((`ols`.`orderid` = `o`.`id`)))
        JOIN `animals` `a` ON (((`o`.`userid` = `a`.`id`)
            AND (`a`.`species` = `a`.`species`))))
        JOIN `products` `p` ON ((`ols`.`productid` = `p`.`id`)))
    GROUP BY `ols`.`productid`
    ORDER BY `The Count` DESC
    LIMIT 5

-- copy and paste COMPLEX procedure
CREATE PROCEDURE `placeOrder`(IN user INT, IN items JSON)
BEGIN
  INSERT INTO orders (date, userid) VALUES (NOW(), user);
  SET @thelast = LAST_INSERT_ID();
  SET @i = 0;
  WHILE @i < JSON_LENGTH(items) DO
    INSERT INTO orderlines (productid, orderid, quantity) VALUES (JSON_EXTRACT(items, CONCAT("$[", @i, "].product")), @thelast, JSON_EXTRACT(items, CONCAT("$[", @i, "].quantity")));
    SET @i = @i + 1;
  END WHILE;
  SELECT * FROM orderlines JOIN orders ON orderlines.orderid = orders.id AND orderlines.orderid = @thelast JOIN products ON orderlines.productid = products.id JOIN animals ON orders.userid = animals.id;
END

-- json order:
-- [{"product": 1, "quantity": 50}, {"product": 46, "quantity": 100}]

-- create table from posts.js in db.executoe()
CREATE TABLE `ournodeapp`.`posts` (
  `_id` INT NOT NULL AUTO_INCREMENT,
  `title` MEDIUMTEXT NOT NULL,
  `body` LONGTEXT NOT NULL,
  `author` INT NOT NULL,
  `createdDate` DATETIME NOT NULL,
  PRIMARY KEY (`_id`));

-- create a post
INSERT INTO  posts (title, body, author, createdDate)
VALUES ('My first post', 'The body content goes here. It should probably be a lot of text.', 1, NOW())

-- update a title and body 
UPDATE posts SET title = 'Hello test', body = 'Test again' WHERE _id = 2

-- this is the logic for anytime an id is needed
SELECT p.title, p.body, p._id, p.author, p.createdDate, u.username, u.avatar FROM posts p JOIN users u  ON p.author = u._id WHERE p._id = 2

-- search lesson, creating compound index:
ALTER TABLE `ournodeapp`.`posts` 
ADD FULLTEXT INDEX `titlebodysearch` (`title`, `body`) VISIBLE;
;

-- query to leverage that index: 
SELECT * FROM posts WHERE MATCH(title, body) AGAINST('again')

-- follow query
INSERT INTO `ournodeapp`.`follows` (`followedId`, `authorId`) VALUES ('1', '2');

-- delete our one follow
DELETE FROM follows

-- follow for user 3 
SELECT * FROM posts p JOIN users u ON p.author = u._id WHERE author = 1 OR author = 2 

-- below IN () clause
SELECT * FROM posts p JOIN users u ON p.author = u._id WHERE author IN (1, 2)
SELECT followedId FROM follows WHERE authorId = 3

-- nested version
SELECT posts._id, title, createdDate, username, avatar FROM posts JOIN users ON posts.author = users._id WHERE author IN (SELECT followedId FROM follows WHERE authorId = 3) ORDER BY createdDate DESC
