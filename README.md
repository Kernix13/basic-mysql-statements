# MySQL Notes

## Table of contents

1. [Basic SQL Statements](#basic-sql-statements)
1. [Intermediate SQL Statements](#intermediate-sql-statements)
1. [Advanced SQL Statements](#advanced-sql-statements)
1. [WordPress examples](#wordpress-examples)
1. [JavaScript examples](#javascript-examples)

The notes in these markdown files are from the Udemy course [MySQL For Beginners](https://www.udemy.com/course/mysql-for-beginners-real-database-experience-real-fast/) by Brad Schiff. We built a database for pet food orders so you'll see table and field names related to pets.

### Useful Links

- [MySQL 8.0 Reference Manual](https://dev.mysql.com/doc/refman/8.0/en/)
- MySQL data types: here is a link to all the [data types](https://dev.mysql.com/doc/refman/8.0/en/ 'MySQL Data Types').
- [MySQL Functions list](https://www.techonthenet.com/mysql/functions/index.php)
- [HeidiSQL](https://www.heidisql.com/): see and edit data and structures from computers running one of the database systems MariaDB, MySQL, Microsoft SQL, PostgreSQL and SQLite

#### Importing a CSV file links

- [Import CSV File Into MySQL Table](https://www.mysqltutorial.org/import-csv-file-mysql-table/)
- [Table Data Export and Import Wizard](https://dev.mysql.com/doc/workbench/en/wb-admin-export-import-table.html)
- [How to Import CSV File into MySQL Table](https://skyvia.com/blog/how-to-import-csv-file-into-mysql-table-in-4-different-ways)
- [MYSQL Import Data from CSV File](https://linuxhint.com/import-data-csv-file-mysql/)

## Basic SQL Statements

**NOTE**: You can write upper or lowercase and the query will work. However, it’s more readable if the code is uppercase – so commands in UPPERCASE, values in lowercase.

**KEYWORDS**:

```sql
-- all, PK = Primary Key, NN = Not Null, AI = Auto-Increment
-- *, = , =, <, >,, %, SELECT, FROM, INSERT INTO, VALUES(), WHERE,
-- UPDATE, SET, DELETE, CREATE TABLE, NOW(), JOIN, ON, foreign keys,
-- indexes, LIMIT, SUM, MIN, MAX, COUNT, EXPLAIN, RESTRICT, NO ACTION,
-- CASCADE, SET NULL, LIKE, GROUP BY, HAVING, as, MATCH, AGAINST,
-- INNER JOIN, LEFT JOIN, RIGHT JOIN, UNION, UNION ALL, ORDER BY,
-- ASC, DESC, AND, LEFT, CONCAT, IF, IF NOT EXISTS,
```

Select all the records in a table:

```sql
SELECT * FROM database_name.table_name;
```

Using `EXPLAIN` before `SELECT` optimizes queries. It provides information about how MySQL executes statements:

- `EXPLAIN` works with `SELECT`, `DELETE`, `INSERT`, `REPLACE`, and `UPDATE` statements
- With the help of `EXPLAIN`, you can see where you should add indexes to tables so that the statement executes faster by using indexes to find rows
- `EXPLAIN` can also be used to obtain information about the columns in a table

```sql
EXPLAIN SELECT * FROM petfoodsreference.animals;
```

You will usually be connecting to a particular database, so you don't need to include `database_name.`.

To add records to a table:

```sql
INSERT INTO  animals (name, species) VALUES ('Buddy', 'dog')
```

**NOTE**: It's best practice to wrap a column in backticks. That is because if a column header is a generic name, MySQL can get confused. You MUST wrap a column header in backticks if it’s name includes spaces.

`WHERE` statement to filter records:

```sql
SELECT * FROM animals WHERE `species` = 'dog';
SELECT * FROM animals WHERE `weight` > 35
SELECT `name`, `email` FROM animals WHERE `weight` > 35
```

`UPDATE` statement to add or change a record:

```sql
UPDATE animals SET `name` = 'Bibi' WHERE `name` = 'Buddy';

UPDATE animals SET `weight` = '12', `birthdate` = '2013-02-10', `joindate` = '2018-01-01', `email` = 'meow@cats.com' WHERE `id` = 1;
```

`DELETE` to delete a record:

```sql
DELETE FROM animals WHERE `name` = 'Barksalot'
DELETE FROM orders WHERE id = 1
```

That covers the basic CRUD operations. Look into Primary Keys, Auto-increment, Not Null

---

## Intermediate SQL Statements

Create a table:

```sql
CREATE TABLE `petfoods`.`products` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(60) NULL,
  `priceusd` DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (`id`));
```

`JOIN` statement to 2 or more tables together:

```sql
SELECT * FROM orders JOIN animals ON orders.userid = animals.id

SELECT * FROM orderlines JOIN products ON orderlines.productid = products.id WHERE orderid = 1
```

Joins with nicknames, multiple left joins:

```sql
SELECT * FROM animals a INNER JOIN orders o ON a.id = o.userid

SELECT * FROM animals a
LEFT JOIN orders o ON a.id = o.userid
LEFT JOIN orderlines ols ON ols.orderid = o.id
LEFT JOIN products p ON ols.productid = p.id
```

**NOTE**: When joining tables together by looking for certain ID values, we want to make sue to do that in the fastest most efficient way possible → `foreignkeys` and `indexes`.

Why not index EVERY column in EVERY table?

1. It would be a waste of hard-drive space,
2. It would slow down create and update operations

If it is a column that is likely to be queried or searched, especially often, then an index is a good idea – on the other hand, if it is a table that you will be creating new records frequently or updating frequently – AND it’s a column that you won’t search/query then do NOT index it.

Insert multiple rows at once: `VALUES (1, 3, 4), (1, 4, 1), ...`

Aggregate Functions (common or useful ones IMO):

```sql
-- AVG(col_name) MAX(col_name) MIN(col_name) COUNT(col_name)
-- STD() STDDEV() COUNT(DISTINCT) GROUP_CONCAT() JSON_ARRAYAGG() JSON_OBJECTAGG()
```

Aggeragte Function and alias:

```sql
SELECT SUM(products.priceusd * orderlines.quantity) as 'subtotal'
```

You don't need to spell out the agregate again, just create an alias using the `as` keyword. Also, notice the quotes vs backticks. Look into `WITH ROLLUP`.

`GROUP BY`: Use to create 1 row for sub-groups or collections - it makes aggreagte Fxs more powerful - is often used with aggregate functions to group the result-set by one or more columns

```sql
SELECT COUNT(species), species, weight FROM animals GROUP BY species, weight
```

`HAVING` better than `WHERE`:

```sql
SELECT AVG(weight) as 'Average Weight', species FROM animals GROUP BY species HAVING `Average Weight` >= 50
```

**NOTE**: `WHERE` filters the data before the items get grouped into their subgroups. Instead use the `HAVING` clause and it filters AFTER the items are grouped into their sub-groups. Use `HAVING` when you want to filter based on a calculated value from an aggregate function.

Nested query:

```sql
WHERE orderid = (SELECT id FROM orders WHERE userid = 1 LIMIT 1)
```

To search, use the percentage sign (`%`) along with `WHERE` and `LIKE`. The percentage sign is basically saying: "Any combination of characters, 0 or more of them, can come befoe the phrase". And the same if you include `%` at the end of your phrase:

```sql
SELECT * FROM petfoods.reviews WHERE description LIKE '%great%';
```

That way is a quick and dirty way to perform a search. However, when you are working with really large datasets, and/or with really long text values, then this method of searching is very inefficient. That is because this approach will perform a full-table scan on every row in the table.

The better approach in that case is to add an index on a column that you tend to need to search often and set it to the type of `FULLTEXT`.

Yu use `MATCH()` long with `AGAINST()` vs `%`:

```sql
EXPLAIN SELECT * FROM table_name WHERE MATCH(col_name_to_search) AGAINST('search-string')
```

Using `EXPLAIN` improves efficiency in the search because it does not have to perform a full table scan because it can just look at the `fulltext` index.

`UNION` - UNION combines the result from multiple SELECT statements into a single result set:

```sql
SELECT * FROM animals UNION SELECT * FROM orders
-- query1 UNION query2
```

`UNION` with `ORDER BY` for sort:

```sql
SELECT name FROM animals
UNION
SELECT name FROM products ORDER BY name
```

`DATETIME`: The format for `DATETIME` datatype: `yyyy-mm-dd hh:mm:ss`. To pull in the current time, the time when you execute the sql statement, remove everything from the parens and use `NOW()`, or `VALUES (NOW())`.

## Advanced SQL Statements

When I used the word "advanced", I mean advanced to me. I'm sure to a professional that these would be considered intermediate SQL statements.

**Create function** template:

```sql
CREATE FUNCTION `new_function` ()
RETURNS INTEGER
BEGIN

RETURN 1;
END
```

**STORED FUNCTION**: use this when what you want can be boiled down to a single return value or you will be using it a lot.

Finished example:

```sql
CREATE DEFINER=`root`@`localhost` FUNCTION `weightLogic`(theweight INT) RETURNS varchar(100) CHARSET utf8mb4
    DETERMINISTIC
BEGIN

RETURN CONCAT(theweight, IF(theweight >= 75, ' which is not healthy.', ' which is healthy.'));
END
```

**NOTE**: I got an error using his database:

```
Error Code: 1267. Illegal mix of collations (utf8mb4_general_ci,IMPLICIT) and (utf8mb4_0900_ai_ci,IMPLICIT) for operation '='
```

I had to add `COLLATE utf8mb4_0900_ai_ci` at the end of each line that had an equal sign, or the 3 JOIN lines.

Boilerplate **Stored Procedure**:

```sql
CREATE PROCEDURE `new_procedure` ()
BEGIN

END
```

**STORED PROCEDURE**: use when you are trying to string together multiple operations.

Example:

```sql
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
```

**Create database**:

```sql
CREATE SCHEMA `petfoodsref` DEFAULT CHARACTER SET utf8mb4;
```

**View** boilerplate:

```sql
CREATE VIEW `new_view` AS
```

Creating **compound index**:

```sql
ALTER TABLE `ournodeapp`.`posts`
ADD FULLTEXT INDEX `titlebodysearch` (`title`, `body`) VISIBLE;
```

`IN ()` clause:

```sql
SELECT * FROM posts p JOIN users u ON p.author = u._id WHERE author IN (1, 2)
SELECT followedId FROM follows WHERE authorId = 3
```

Techincally you are supposed to end every statement with a semi-colon but since we were only running one statement, mysql could figure it out

```sql
SHOW tables;
SELECT * from animals;
CREATE SCHEMA testing;
```

---

> **DON’T EVER EVER EVER STORE USERS’ REAL PASSWORDS IN PLAIN TEXT! USe `bcrypt` to hash the real Password.**

---

The wrong thing to do is to replace the hard-coded post data with incoming variables. That is what you are ultimately going to do but you need to be very careful in the way that you do that, otherwise you are vulnerable to a SQL injection attack.

There are several ways to protect against it, but a great option is to use something called a prepared statement: You send along your query totally separate from the actual values. The `?` in place of the values lets mysql know in this prepared statement this is where a value is going to be placed.

**REMEMBER**: It’s very important to have the right index in MySQL – so based on the users search query, we want to search both the title value and the body value – in mysql you use like and % to search – that is fine if you don’t have a lot of rows in a table, but when your table gets large that type of search is slow – this relates to "**full text indexes**".

**NOTE**: you don’t want to make a lot of indexes of indexes that will rarely be used b\c every time someone creates or edits a post, mysql needs to update and maintain the indexes – and that will take more time the more indexes there are to maintain – but it’s worth it if your users will performing searches like that -> compound index

**NOTE**: when you have multiple columns acting as your PK, it is called a Composite Primary Key

## WordPress examples

Examples of Woocommerce code to remove their records from your database tables using `$wpdb`:

```php
// Delete options.
$wpdb->query( "DELETE FROM $wpdb->options WHERE option_name LIKE 'woocommerce\_%';" );
$wpdb->query( "DELETE FROM $wpdb->options WHERE option_name LIKE 'widget\_woocommerce\_%';" );

// Delete usermeta.
$wpdb->query( "DELETE FROM $wpdb->usermeta WHERE meta_key LIKE 'woocommerce\_%';" );

// Delete posts + data.
$wpdb->query( "DELETE FROM {$wpdb->posts} WHERE post_type IN ( 'product', 'product_variation', 'shop_coupon', 'shop_order', 'shop_order_refund' );" );
$wpdb->query( "DELETE meta FROM {$wpdb->postmeta} meta LEFT JOIN {$wpdb->posts} posts ON posts.ID = meta.post_id WHERE posts.ID IS NULL;" );

$wpdb->query( "DELETE FROM {$wpdb->comments} WHERE comment_type IN ( 'order_note' );" );
$wpdb->query( "DELETE meta FROM {$wpdb->commentmeta} meta LEFT JOIN {$wpdb->comments} comments ON comments.comment_ID = meta.comment_id WHERE comments.comment_ID IS NULL;" );

$wpdb->query( "DROP TABLE IF EXISTS {$wpdb->prefix}woocommerce_order_items" );
$wpdb->query( "DROP TABLE IF EXISTS {$wpdb->prefix}woocommerce_order_itemmeta" );
```

Example from WPCasts YouTube video titled [Custom Queries In WordPress](https://youtu.be/9LzTss23xgU). He prefers using `wpdb` for faster queries:

```php
$results = $wpdb->get_results(
  *SELECT post_title, post_excerpt, ID
  FROM $wpdb->posts
  LEFT JOIN $wpdb->term_relationships as t
  ON ID = t.object_id
  WHERE post_type = 'some-type-here'
  AND post_status = 'publish'
  AND t.term_taxonomy_id = 3
  LIMIT 25*
);
```

**NOTE**: I got errors trying to run this for a recent posts function. VS Code was not accepting the asterisks (`*`) at the beginning and ending of the SQL statements. My code was exactly the same as his with opening and closing `php` tags. He may have had a node package running to accept the syntax but that is just a guess. Would backticks have helped?

## JavaScript examples

Here are some examples of the code in the Udemy course mentioned at the top of this document.

Create tables and columns if they do not already exist:

```js
function shapeDatabase(db) {
  db.query(`CREATE TABLE IF NOT EXISTS users (
  _id int NOT NULL AUTO_INCREMENT,
  username varchar(45) DEFAULT NULL,
  email varchar(100) DEFAULT NULL,
  password varchar(200) DEFAULT NULL,
  avatar varchar(100) GENERATED ALWAYS AS (concat(_utf8mb4'https://gravatar.com/avatar/',md5(email),_utf8mb4'?s=128')) VIRTUAL,
  PRIMARY KEY (_id)
);
```

Find all posts by author ID:

```js
Post.findByAuthorId = async function (authorId) {
  let [posts] = await db.execute(
    'SELECT p.title, p.body, p._id, p.author, p.createdDate, u.username, u.avatar FROM posts p JOIN users u  ON p.author = u._id WHERE p.author = ? ORDER BY p.createdDate DESC',
    [authorId]
  );
  return posts;
};
```
