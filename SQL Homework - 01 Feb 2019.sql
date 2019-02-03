-- use the sakila database:
USE sakila;

-- 1a. Display the first and last names of all actors from the table `actor`.
SELECT first_name, last_name
FROM actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.
SELECT CONCAT(UPPER(first_name), ' ',UPPER(last_name)) AS 'Actor Name'
FROM actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
SELECT actor_id, first_name, last_name
FROM actor
WHERE first_name = 'Joe';

-- 2b. Find all actors whose last name contain the letters `GEN`:
SELECT Actor_Name
FROM actor
WHERE last_name LIKE '%GEN';

-- 2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:
SELECT first_name, last_name
FROM actor
WHERE last_name LIKE '%LI%'
ORDER BY last_name, first_name;

-- 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country_id, country
FROM country
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table `actor` named `description` and use the data type `BLOB` (Make sure to research the type `BLOB`, as the difference between it and `VARCHAR` are significant).
ALTER TABLE actor
ADD COLUMN description BLOB;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the `description` column.
ALTER TABLE actor DROP description;

-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, COUNT(last_name)
FROM actor
GROUP BY last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name, COUNT(last_name)
FROM actor
GROUP BY last_name
HAVING COUNT(last_name) >1;

-- 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. Write a query to fix the record.
UPDATE actor
SET first_name = 'HARPO'
WHERE first_name = 'GROUCHO' AND last_name = 'WILLIAMS';

-- 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.
UPDATE actor
SET first_name = 'GROUCHO'
WHERE first_name = 'HARPO' AND last_name = 'WILLIAMS';

-- 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?
desc address;
SHOW CREATE TABLE address;

-- 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:

SELECT first_name, last_name, address
FROM staff
JOIN address
USING (address_id);

-- 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`.
SELECT s.first_name, s.last_name, sum(p.amount) AS TOTAL_AMOUNT
FROM staff s
JOIN payment p
USING (staff_id)
WHERE p.payment_date LIKE '%2005-08%'
GROUP BY p.staff_id;


-- 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.
SELECT f.title, COUNT(actor_id) AS Number_Actors
FROM film f
INNER JOIN film_actor fa
ON f.film_id = fa.film_id
GROUP BY title;

-- 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
SELECT f.title, COUNT(store_id) AS film_copies
FROM film f
INNER JOIN inventory i
ON f.film_id = i.film_id
WHERE f.title = 'Hunchback Impossible';

-- 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers alphabetically by last name:
SELECT c.first_name, c.last_name, SUM(p.amount) AS TOTAL_PAID
FROM customer c
JOIN payment p
USING (customer_id)
GROUP BY c.last_name;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity. Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.

SELECT f.title AS Film_Title, l.name AS Film_Language
FROM film f
JOIN language l
USING (language_id)
WHERE f.title LIKE 'K%'OR f.title LIKE 'Q%' AND l.name = 'English';

-- 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
SELECT a.first_name, a.last_name
FROM actor AS a
WHERE actor_id IN
(
  SELECT actor_id
  FROM film_actor
  WHERE film_id IN
  (
   SELECT film_id
   FROM film
   WHERE title = 'Alone Trip'
   ) 
);

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
SELECT cu.first_name, cu.last_name, cu.email
from customer AS cu
INNER JOIN address AS a ON cu.address_id = a.address_id
INNER JOIN city AS ci ON ci.city_id = a.city_id
INNER JOIN country AS co ON co.country_id = ci.country_id
WHERE co.country = 'Canada';

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as _family_ films.
SELECT fi.title, ca.name AS film_category
from film AS fi
INNER JOIN film_category AS fc ON fc.film_id = fi.film_id
INNER JOIN category AS ca ON ca.category_id = fc.category_id
WHERE ca.name = 'Family';

-- 7e. Display the most frequently rented movies in descending order.
SELECT fi.title, COUNT(re.inventory_ID) AS NUMBER_OF_RENTALS
FROM film fi
INNER JOIN inventory AS inv ON inv.film_id = fi.film_id
INNER JOIN rental AS re ON re.inventory_id = inv.inventory_id
GROUP BY fi.title
ORDER BY COUNT(re.inventory_ID) DESC;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT st.store_id, SUM(pa.amount) AS REVENUE
FROM store AS st
INNER JOIN customer AS cu ON cu.store_id = st.store_id
INNER JOIN payment AS pa ON pa.customer_id = cu.customer_id
GROUP BY st.store_id
ORDER BY SUM(pa.amount) DESC;

-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT st.store_id, ci.city, co.country
FROM store AS st
INNER JOIN address AS ad ON ad.address_id = st.address_id
INNER JOIN city AS ci ON ci.city_id = ad.city_id
INNER JOIN country AS co ON co.country_id = ci.country_id
GROUP BY st.store_id;

-- 7h. List the top five genres in gross revenue in descending order. (**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT ca.name AS genre, SUM(pa.amount) AS GROSS_REVENUE
FROM category AS ca
INNER JOIN film_category AS fc ON fc.category_id = ca.category_id
INNER JOIN inventory AS inv ON inv.film_id = fc.film_id
INNER JOIN rental AS re ON re.inventory_id = inv.inventory_id
INNER JOIN payment AS pa ON pa.rental_id = re.rental_id
GROUP BY ca.name
ORDER BY SUM(pa.amount) DESC LIMIT 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.

CREATE VIEW Top_Five_Genres AS
SELECT ca.name AS genre, SUM(pa.amount) AS GROSS_REVENUE
FROM category AS ca
INNER JOIN film_category AS fc ON fc.category_id = ca.category_id
INNER JOIN inventory AS inv ON inv.film_id = fc.film_id
INNER JOIN rental AS re ON re.inventory_id = inv.inventory_id
INNER JOIN payment AS pa ON pa.rental_id = re.rental_id
GROUP BY ca.name
ORDER BY SUM(pa.amount) DESC LIMIT 5;

-- 8b. How would you display the view that you created in 8a?
SHOW CREATE VIEW Top_Five_Genres;

-- 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
DROP VIEW IF EXISTS Top_Five_Genres;




