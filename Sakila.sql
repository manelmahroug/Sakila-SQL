 USE sakila;

-- 1a. Display the first and last names of all actors from the table actor

SELECT first_name, last_name FROM actor;

-- 1b Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name

SELECT concat(UPPER(first_name), ' ', UPPER(last_name)) AS 'Actor Name' FROM actor;

-- 2a You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe."  

SELECT actor_id, 
first_name, 
last_name 
FROM actor
WHERE
first_name = 'Joe';

-- 2b Find all actors whose last name contain the letters GEN


SELECT * FROM actor
WHERE
last_name LIKE '%gen%';

-- 2c Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order
SELECT last_name, 
first_name 
FROM actor
WHERE
last_name LIKE '%li%'
ORDER BY last_name, first_name;

-- 2d Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China

SELECT country_id, 
country 
FROM country
WHERE
country IN ('Afghanistan', 'Bangladesh', 'China');

-- 3a Add a middle_name column to the table actor. Position it between first_name and last_name

ALTER TABLE actor
ADD middle_name VARCHAR(30);
SELECT actor_id, 
	first_name, 
    middle_name, 
    last_name, 
    last_update 
FROM actor;

-- 3b You realize that some of these actors have tremendously long last names. Change the data type of the middle_name column to blobs

ALTER TABLE actor
MODIFY middle_name blob;

-- 3c Now delete the middle_name column

ALTER TABLE actor
DROP COLUMN middle_name;

-- 4a List the last names of actors, as well as how many actors have that last name

SELECT last_name, COUNT(*) from actor
GROUP BY last_name;

-- 4b List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors

SELECT last_name, COUNT(*) 
FROM actor
GROUP BY last_name
HAVING Count(last_name) > 2;

-- 4c Oh, no! The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS, 
-- the name of Harpo's second cousin's husband's yoga teacher. Write a query to fix the record.

UPDATE actor
SET first_name = 'HARPO'
WHERE last_name = 'Williams' AND first_name = 'GROUCHO';

-- 4d 

SELECT * FROM actor
WHERE
last_name = 'Williams';

UPDATE actor
SET first_name = 'GROUCHO'
WHERE actor_id = 172 AND first_name = 'HAPRO'

UPDATE actor
SET first_name = 'MUCHO GROUCHO'
WHERE actor_id = 172

-- 5a You cannot locate the schema of the address table. Which query would you use to re-create it?

SHOW CREATE TABLE address;

-- 6a Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address

SELECT * FROM staff;
SELECT * FROM address;

SELECT first_name, 
last_name, 
address, 
city, 
district, 
postal_code 
FROM staff 
JOIN address ON staff.address_id = address.address_id 
JOIN city ON address.city_id = city.city_id;


-- 6b Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment

SELECT first_name, last_name, total_amount 
FROM staff JOIN (SELECT staff_id, SUM(amount) AS 'total_amount' 
FROM payment 
WHERE payment_date 
BETWEEN '2005-08-01 00:00:00' AND '2005-08-31 00:00:00' 
GROUP BY staff_id) AS payments on staff.staff_id = payments.staff_id;

-- 6c List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.

SELECT * FROM film;
SELECT * FROM film_actor;

SELECT film_actor.film_id , film.title, COUNT(film_actor.actor_id) AS number_of_actors
FROM film
INNER JOIN film_actor ON
film.film_id = film_actor.film_id
GROUP BY film_id;

-- 6d How many copies of the film Hunchback Impossible exist in the inventory system?

SELECT * FROM inventory;
SELECT * FROM film;

SELECT title, 
copies_in_inventory 
FROM film 
JOIN (SELECT film_id, COUNT(inventory_id) AS 'copies_in_inventory' FROM inventory GROUP BY film_id) 
AS inventory_count ON film.film_id = inventory_count.film_id WHERE title = 'HUNCHBACK IMPOSSIBLE';

-- 6e  Using the tables payment and customer and the JOIN command, list the total paid by each customer. 
-- List the customers alphabetically by last name:

SELECT * FROM payment;
SELECT * FROM customer;

SELECT customer.customer_id, customer.first_name, customer.last_name, SUM(payment.amount) AS total_payment
FROM customer
JOIN payment ON
customer.customer_id = payment.customer_id
GROUP BY customer_id
ORDER BY last_name ASC;

-- 7a The music of Queen and Kris Kristofferson have seen an unlikely resurgence.

SELECT * FROM film;
SELECT * FROM language;

SELECT title 
FROM film 
WHERE language_id IN 
(SELECT language_id FROM language WHERE name = 'English') 
AND title IN (SELECT title FROM film WHERE title LIKE 'K%' OR title LIKE 'Q%');
 

-- 7b Use subqueries to display all actors who appear in the film Alone Trip.
SELECT first_name, 
last_name 
FROM actor 
WHERE actor_id IN 
(SELECT actor_id FROM film_actor WHERE film_id IN 
(SELECT film_id FROM film WHERE title = 'ALONE TRIP'));

-- 7c You want to run an email marketing campaign in Canada, 
-- for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.

SELECT * FROM customer;
SELECT * FROM address;
SELECT * FROM city;
SELECT * FROM country;

SELECT customer.first_name, customer.last_name, customer.email
FROM customer
JOIN address ON
	customer.address_id = address.address_id
		JOIN city ON
			address.city_id = city.city_id
				JOIN country ON
					city.country_id = country.country_id
						WHERE country.country = 'Canada';

-- 7d Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
-- Identify all movies categorized as famiy films

SELECT * FROM film;
SELECT * FROM film_category;
SELECT * FROM category;

SELECT film_id, title
FROM film
WHERE film_id IN (
	SELECT film_id
    FROM film_category
    WHERE category_id IN (
		SELECT category_id
        FROM category
        WHERE name = 'Family'
		)
	);
    
-- 7e Display the most frequently rented movies in descending order

SELECT * FROM film;
SELECT * FROM inventory;
SELECT * FROM rental;

SELECT inventory.film_id, COUNT(rental.inventory_id) AS rental_count
FROM inventory
JOIN rental ON
inventory.inventory_id = rental.inventory_id
GROUP BY film_id
ORDER BY rental_count DESC;



-- 7f Write a query to display how much business, in dollars, each store brought in.

SELECT * FROM film;
SELECT * FROM inventory;
SELECT * FROM rental;

SELECT inventory.film_id, COUNT(rental.inventory_id) AS rental_count
FROM inventory
JOIN rental ON
inventory.inventory_id = rental.inventory_id
GROUP BY film_id
ORDER BY rental_count DESC;


SELECT * FROM payment;
SELECT * FROM customer;

SELECT customer.store_id, SUM(payment.amount) AS total_payment
FROM customer
JOIN payment ON
customer.customer_id = payment.customer_id
GROUP BY store_id;

-- 7g Write a query to display for each store its store ID, city, and country.

SELECT * FROM store;
SELECT * FROM address;
SELECT * FROM city;
SELECT * FROM country;


SELECT store.store_id, city.city, country.country
FROM store
	JOIN address ON
		store.address_id = address.address_id
			JOIN city ON
				address.city_id = city.city_id
					JOIN country ON
						city.country_id = country.country_id;


-- 7h List the top five genres in gross revenue in descending order

SELECT * FROM category;
SELECT * FROM film_category;
SELECT * FROM inventory;
SELECT * FROM payment;
SELECT * FROM rental;

SELECT category.name AS Film_Category, SUM(payment.amount) as Gross_Sum
FROM category
JOIN film_category ON
	category.category_id = film_category.category_id
		JOIN inventory ON
			film_category.film_id = inventory.film_id
				JOIN rental ON 
					inventory.inventory_id = rental.inventory_id
						JOIN payment ON 
							rental.rental_id = payment.rental_id
GROUP BY name
ORDER BY gross_sum DESC
LIMIT 5;

-- 8a create a view

CREATE VIEW category_gross_sum 
AS 
SELECT category.name AS Film_Category, SUM(payment.amount) as Gross_Sum
FROM category
JOIN film_category ON
	category.category_id = film_category.category_id
		JOIN inventory ON
			film_category.film_id = inventory.film_id
				JOIN rental ON 
					inventory.inventory_id = rental.inventory_id
						JOIN payment ON 
							rental.rental_id = payment.rental_id
GROUP BY name
ORDER BY gross_sum DESC
LIMIT 5;

-- 8b How would you display the view that you created in 8a?

SELECT * FROM category_gross_sum;

 -- 8c You find that you no longer need the view top_five_genres. Write a query to delete it.
 
DROP VIEW category_gross_sum;