-- use sakila --
USE sakila;

-- Display the first and last name of all the actors from table actor--
SELECT first_name, last_name
FROM actor;

-- Display the first and last name of each actor in a single column in upper case letters.
SELECT CONCAT(first_name, ' ', last_name) as 'Actor Name'
FROM actor;

-- find the id number, first_name and last_name where first_name = 'joe'

-- SELECT *
-- FROM actor;

SELECT actor_id, first_name, last_name
FROM actor
WHERE first_name = 'Joe';

-- 2b Find all actor whose last name contain the letters GEN

SELECT *
FROM actor
WHERE last_name LIKE '%GEN%';


-- 2c Find all actors whose last names contain the letters LI. 
-- This time, order the rows by last name and first name, in that order:

SELECT *
FROM actor
WHERE last_name LIKE '%LI%'
ORDER BY last_name AND first_name;

-- 2d. Using IN, display the country_id and country columns of the 
-- following countries: Afghanistan, Bangladesh, and China:

SELECT country_id, country
FROM country
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

-- 3a. You want to keep a description of each actor. You don't think you will 
-- be performing queries on a description, so create a column in the table actor 
-- named description and use the data type BLOB (Make sure to research the type BLOB, 
-- as the difference between it and VARCHAR are significant)

ALTER TABLE actor
ADD COLUMN description BLOB;

-- 3b. Very quickly you realize that entering descriptions for each actor is too 
-- much effort. Delete the description column.

ALTER TABLE actor
DROP description;

-- 4a. List the last names of actors, as well as how many actors have that last name.

SELECT last_name, COUNT(last_name) 
FROM actor
GROUP BY last_name;

-- 4b. List last names of actors and the number of actors who have that last name, 
-- but only for names that are shared by at least two actors

SELECT last_name, COUNT(last_name)
FROM actor
GROUP BY last_name
HAVING COUNT(last_name) >= 2;

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as 
-- GROUCHO WILLIAMS. Write a query to fix the record.

UPDATE actor
SET first_name = 'HARPO' 
WHERE first_name = 'GROUCHO' AND last_name = 'WILLIAMS';

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out 
-- that GROUCHO was the correct name after all! In a single query, if the first name 
-- of the actor is currently HARPO, change it to GROUCHO.

UPDATE actor
SET first_name = 'GROUCHO'
WHERE last_name = 'HARPO';

-- 5a. You cannot locate the schema of the address table. 
-- Which query would you use to re-create it?

SHOW CREATE TABLE address;

CREATE TABLE IF NOT EXISTS `address` (
  `address_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
  `address` varchar(50) NOT NULL,
  `address2` varchar(50) DEFAULT NULL,
  `district` varchar(20) NOT NULL,
  `city_id` smallint(5) unsigned NOT NULL,
  `postal_code` varchar(10) DEFAULT NULL,
  `phone` varchar(20) NOT NULL,
  `location` geometry NOT NULL,
  `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`address_id`),
  KEY `idx_fk_city_id` (`city_id`),
  SPATIAL KEY `idx_location` (`location`),
  CONSTRAINT `fk_address_city` FOREIGN KEY (`city_id`) REFERENCES `city` (`city_id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=606 DEFAULT CHARSET=utf8;

-- 6a. Use JOIN to display the first and last names, as well as the address, 
-- of each staff member. Use the tables staff and address:

SELECT s.first_name, s.last_name, a.address
FROM staff s
INNER JOIN
address a ON 
s.address_id = a.address_id;

-- 6b. Use JOIN to display the total amount rung up by each 
-- staff member in August of 2005. Use tables staff and payment.


SELECT SUM(staff.amount) AS 'amount rung up', username
FROM staff 
INNER JOIN payment ON 
staff.staff_id = payment.staff_id
WHERE payment_date LIKE "2005-08%";

-- 6c. List each film and the number of actors who are 
-- listed for that film. Use tables film_actor and film. Use inner join.

SELECT f.title, COUNT(fa.actor_id) AS 'Number of Actors'
FROM film_actor fa
INNER JOIN film f ON
fa.film_id = f.film_id
GROUP BY actor_id;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?

SELECT COUNT(title) AS 'Hunchback Impossible Copies'
FROM film f
INNER JOIN inventory i
ON f.film_id = i.film_id
WHERE title = 'Hunchback Impossible';

--  6e. Using the tables payment and customer and the JOIN command, list the 
-- total paid by each customer. List the customers alphabetically by last name:

SELECT SUM(p.amount) AS 'Total Per Customer', p.customer_id, c.last_name 
FROM payment p
INNER JOIN customer c
ON p.customer_id = c.customer_id
GROUP BY c.last_name;

-- 7a.Use subqueries to display the titles of movies starting 
-- with the letters K and Q whose language is English.


SELECT title
FROM film
WHERE language_id IN
(
	SELECT language_id
    FROM language
    WHERE name = 'English')
    AND title LIKE "K%" OR title LIKE "Q%";




-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
 
SELECT a.first_name, a.last_name
FROM actor a 
WHERE a.actor_id IN 
(
	SELECT fa.actor_id
    FROM film_actor fa 
    WHERE film_id IN
    (	SELECT f.film_id 
		FROM film f
		WHERE title = 'Alone Trip'));


-- 7c. You want to run an email marketing campaign in Canada, for which you will 
-- need the names and email addresses of all Canadian customers. Use joins to 
-- retrieve this information.

SELECT first_name, last_name, email, country
FROM customer 
INNER JOIN customer_list 
ON customer.customer_id = customer_list.ID
WHERE country = "Canada";


-- 7d. Sales have been lagging among young families, and you wish to target all 
-- family movies for a promotion. Identify all movies categorized as family films.

SELECT title, category
FROM film_list
WHERE category = "Family";


-- 7e Display the most frequently rented movies in descending order.
SELECT title, COUNT(title) AS "rent_count"
FROM film 
INNER JOIN rental ON
inventory.inventory_id = rental.inventory_id
GROUP BY title
ORDER BY rent_count DESC;

-- 7f Write a query to display how much business, in dollars, each store brought in.

SELECT store, total_sales
FROM sales_by_store;

-- 7g . Write a query to display for each store its store ID, city, and country.

SELECT store.store_id, city.city, country.country_id
FROM store
INNER JOIN
city ON address.city_id = address.address_id;

-- 7h  List the top five genres in gross revenue in descending order. (Hint: you may need 
-- to use the following tables: category, film_category, inventory, payment, and rental.)

SELECT *
FROM sales_by_film_category 
ORDER BY tatal_sales DESC LIMIT 5;


-- 8a. In your new role as an executive, you would like to have an easy way of viewing 
-- the Top five genres by gross revenue. Use the solution from the problem above to create 
-- a view. If you haven't solved 7h, you can substitute another query to create a view.

CREATE VIEW top_five_genres AS 
	SELECT *
    FROM sales_by_film_category
ORDER BY total_sales DESC LIMIT 5;

-- 8b. How would you display the view that you created in 8a?
SELECT *
FROM top_five_genres;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.

DROP VIEW top_five_genre;
