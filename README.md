# MySQL Notes

The notes in these markdown files are from the Udemy course [MySQL For Beginners](https://www.udemy.com/course/mysql-for-beginners-real-database-experience-real-fast/) by Brad Schiff.

MySQL data types: here is a link to all the [data types](https://dev.mysql.com/doc/refman/8.0/en/ 'MySQL Data Types').

## Basic SQL Statements

**NOTE**: You can write upper or lowercase and the query will work. However, it’s more readable if the code is uppercase – so commands in UPPERCASE, values in lowercase.

Select all the records in a table:

```sql
SELECT * FROM database_name.table_name;
```

You will usually be connecting to a particular database, so you don't need to include `database_name.`.

To add records to a table:

```sql
INSERT INTO  animals (name, species) VALUES ('Buddy', 'dog')
```

`WHERE` statement to filter records (wrap columns in backticks):

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

Code to create a table:

```sql
CREATE TABLE `petfoods`.`products` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(60) NULL,
  `priceusd` DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (`id`));
```

`JOIN` statement:

```sql
SELECT * FROM orders JOIN animals ON orders.userid = animals.id

SELECT * FROM orderlines JOIN products ON orderlines.productid = products.id WHERE orderid = 1
```

```sql
EXPLAIN SELECT * FROM petfoodsreference.animals;
```

```sql

```
