-- Use sakila database
USE sakila;

-- 1a. Display first AND last names of all actors
SELECT first_name, last_name FROM actor;

-- 1b. Display actor name IN one column
ALTER TABLE actor
ADD Actor_Name varchar(40);

UPDATE actor 
SET Actor_name = CONCAT(first_name, ' ', last_name);

SELECT * FROM actor;

-- 2a. Find info for actor named 'Joe'

SELECT actor_id, Actor_Name
FROM actor
WHERE first_name = 'Joe';

-- 2b. Find all actors whose last name contains the letters GEN
SELECT actor_id, Actor_Name
FROM actor
WHERE Actor_Name LIKE '%G%E%N%';

-- 2c. Find all actors whose last names contain the letters
SELECT actor_id, last_name, first_name
FROM actor
WHERE Actor_Name LIKE '%L%I%'
order by last_name, first_name;

-- 2d. Display the country_id AND country of
-- Afghanistan, Bangladesh, AND China:
SELECT country_id, country
FROM country
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

-- 3a. Create new column 'description' IN actor
-- USE type BLOB

ALTER TABLE actor
ADD description BLOB(40); 

-- 3b. delete description column
ALTER TABLE actor
DROP COLUMN description;

-- 4a. List actor last names + how many actors with that last name
SELECT last_name, COUNT(*)
FROM actor
GROUP BY last_name;

-- 4b. List names AND number of actors who have that last name
-- restrict to only last names shared by at least two actors
SELECT last_name, COUNT(*)
FROM actor
GROUP BY last_name
having count(*)>1;

-- 4c. Fix GROUCHO WILLIAMS to HARPO WILLIAMS
UPDATE actor
set first_name = 'HARPO',
	Actor_name = 'HARPO WILLIAMS'
WHERE Actor_Name = 'GROUCHO WILLIAMS';

-- 4d. Change GROUCHO back to HARPO
UPDATE actor
set first_name = 'GROUCHO',
	Actor_name = 'GROUCHO WILLIAMS'
WHERE Actor_name = 'HARPO WILLIAMS';

-- 5a. Locate schema of address table
show create table address;

-- 6a. Join first names, last names, AND address of each staff member
SELECT * FROM staff;

SELECT first_name, last_name, address
FROM staff AS s
INNER JOIN address AS a
ON s.address_id = a.address_id;

-- 6b. Join first names, last names, AND amount SUM rented by staff
SELECT * FROM payment; 

SELECT first_name, last_name, amount, payment_date
FROM staff AS s
INNER JOIN payment AS p
ON s.staff_id = p.staff_id
WHERE payment_date LIKE '%2005-08%';

-- 6c. Show film AND number of actors IN each film 
SELECT * FROM film_actor;

SELECT title, count(actor_id) AS 'Number of Actors'
FROM film AS f
INNER JOIN film_actor AS fa
ON f.film_id = fa.film_id
GROUP BY title;

-- 6d. Find number of copies of Hunchback Impossible IN inventory
SELECT * FROM inventory;

SELECT title, count(store_id) AS 'Inventory Count'
FROM film AS f
INNER JOIN inventory AS i
ON f.film_id = i.film_id
GROUP BY title
having title = 'HUNCHBACK IMPOSSIBLE';

-- 6e. Join customer names with payment amount (total)
SELECT * FROM payment;

SELECT first_name, last_name, SUM(amount) AS 'Total Amount Paid'
FROM customer AS c
INNER JOIN payment AS p
ON c.customer_id = p.customer_id
GROUP BY first_name, last_name;

-- 7a. Display movies starting with k OR q whose language is English
-- subqueries
SELECT * FROM `language`;

SELECT title
FROM film
WHERE language_id IN
	(
		SELECT language_id
        FROM `language`
        WHERE language_id = 1
	)
AND title LIKE 'K%'
OR title LIKE 'Q%';

    
-- 7b. Display all actors IN the Alone Trip film
-- subqueries

SELECT Actor_Name
FROM actor
WHERE actor_id IN
	(
		SELECT actor_id
        FROM film
        WHERE title = 'ALONE TRIP'
	)
;


-- 7c. Names AND email addresses of Canadian customers, join with address
SELECT * FROM address;

 -- subquery form to help with join below
SELECT first_name, last_name, email
FROM customer
WHERE address_id IN
	(
		SELECT address_id
        FROM address
        WHERE city_id IN
		(
			SELECT city_id
            FROM city
            WHERE country_id IN 
            (
				SELECT country_id
                FROM country
                WHERE country = 'Canada'
            
	)
		)
			)
;
 
 -- actual join of email AND country information
SELECT c.first_name, c.last_name, c.email, co.country
FROM customer c
	INNER JOIN address a 
    ON c.address_id = a.address_id
		INNER JOIN city ci
		ON a.city_id = ci.city_id
			INNER JOIN country co
			ON ci.country_id = co.country_id
            WHERE country = 'Canada';
            
-- 7d identify all family films
SELECT * FROM category;

SELECT f.title, ca.`name`
FROM film f
	INNER JOIN film_category fc
    ON f.film_id = fc.film_id
		INNER JOIN category ca
        ON fc.category_id = ca.category_id
        WHERE `name` = 'Family';
        
-- 7e Most frequently rented movies, most to least
SELECT * FROM rental;

SELECT count(r.rental_id) AS 'Times Rented', f.title
FROM rental r
	INNER JOIN inventory i
    ON r.inventory_id = i.inventory_id 
		INNER JOIN film f
        ON i.film_id = f.film_id
        GROUP BY f.title
        order by count(r.rental_id) DESC;

-- 7f Cash IN per store
        
SELECT s.store_id, SUM(p.amount) AS 'Total Purchases ($)'
FROM payment p
	INNER JOIN customer c
    ON p.customer_id = c.customer_id
		INNER JOIN store s
        ON c.store_id = s.store_id
        GROUP BY store_id;
        
-- 7g Store ID, City AND Country join

SELECT s.store_id, c.city, co.country
FROM store s
	INNER JOIN address a
    ON s.address_id = a.address_id
		INNER JOIN city c
        ON a.city_id = c.city_id
			INNER JOIN country co
            ON c.country_id = co.country_id;

-- 7h Top 5 film genres IN gross revenue IN descending order

SELECT c.`name`, SUM(p.amount) AS 'Gross Revenue'
FROM payment p
INNER JOIN rental r
ON p.rental_id = r.rental_id
	INNER JOIN inventory i
    ON r.inventory_id = i.inventory_id
		INNER JOIN film f
        ON i.film_id = f.film_id
			INNER JOIN film_category fc
			ON f.film_id = fc.film_id
				INNER JOIN category c
                ON fc.category_id = c.category_id
                GROUP BY c.`name`
                order by SUM(p.amount) DESC LIMIT 5;
                
-- 8a create view of 7h
create view Gross_Revenue AS
SELECT c.`name`, SUM(p.amount) AS 'Gross Revenue ($)'
FROM payment p
INNER JOIN rental r
ON p.rental_id = r.rental_id
	INNER JOIN inventory i
    ON r.inventory_id = i.inventory_id
		INNER JOIN film f
        ON i.film_id = f.film_id
			INNER JOIN film_category fc
			ON f.film_id = fc.film_id
				INNER JOIN category c
                ON fc.category_id = c.category_id
                GROUP BY c.`name`
                order by SUM(p.amount) DESC LIMIT 5;
                
-- 8b display view FROM 8a 
SELECT * FROM gross_revenue;

-- 8c delete gross_revenue (top_five_genres)
DROP VIEW gross_revenue;

