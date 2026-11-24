-- =============================================================
-- SQL Practice: PostgreSQL dvdrental sample database
-- Written in DBeaver
-- Topics: filtering, aggregates, GROUP BY, multi-table JOINs
-- =============================================================


-- -------------------------------------------------------------
-- 1. BASIC FILTERING
-- -------------------------------------------------------------

-- What films were released before 2010?
SELECT f.title, f.release_year
FROM film f
WHERE f.release_year < 2010
LIMIT 10;


-- -------------------------------------------------------------
-- 2. AGGREGATES & GROUP BY
-- -------------------------------------------------------------

-- How many films are in each category?
SELECT c.category_id, c.name, COUNT(fc.film_id) AS film_count
FROM film_category fc
JOIN category c ON c.category_id = fc.category_id
GROUP BY c.category_id, c.name
ORDER BY film_count DESC;

-- How many films has each actor acted in?
SELECT a.actor_id, a.first_name, a.last_name, COUNT(fa.film_id) AS film_count
FROM actor a
JOIN film_actor fa ON fa.actor_id = a.actor_id
GROUP BY a.actor_id, a.first_name, a.last_name
ORDER BY film_count DESC;

-- How many films are in English?
SELECT l.language_id, l.name, COUNT(f.film_id) AS film_count
FROM film f
JOIN language l ON l.language_id = f.language_id
WHERE l.name = 'English'
GROUP BY l.language_id, l.name;

-- How many copies of each film does each store have?
SELECT f.film_id, f.title, i.store_id, COUNT(i.inventory_id) AS copies
FROM inventory i
JOIN film f ON f.film_id = i.film_id
GROUP BY f.film_id, f.title, i.store_id
ORDER BY f.title, i.store_id;


-- -------------------------------------------------------------
-- 3. JOINS: FILMS & ACTORS
-- -------------------------------------------------------------

-- What films has each actor acted in?
SELECT a.actor_id, a.first_name, a.last_name, f.film_id, f.title
FROM film f
JOIN film_actor fa ON fa.film_id = f.film_id
JOIN actor a ON a.actor_id = fa.actor_id
ORDER BY a.last_name, a.first_name, f.title;

-- Which actors appear in each film? (full cast list per film)
SELECT f.film_id, f.title, a.actor_id, a.first_name, a.last_name
FROM actor a
JOIN film_actor fa ON fa.actor_id = a.actor_id
JOIN film f ON f.film_id = fa.film_id
ORDER BY f.title, a.last_name;


-- -------------------------------------------------------------
-- 4. REVENUE ANALYSIS
-- -------------------------------------------------------------

-- What is the average spend per rental?
SELECT AVG(p.amount) AS avg_spend_per_rental
FROM payment p;

-- What is the average payment for each film?
SELECT f.film_id, f.title, AVG(p.amount) AS avg_payment
FROM film f
JOIN inventory i ON i.film_id = f.film_id
JOIN rental r ON r.inventory_id = i.inventory_id
JOIN payment p ON p.rental_id = r.rental_id
GROUP BY f.film_id, f.title
ORDER BY avg_payment DESC;

-- Which film generated the most revenue?
SELECT f.film_id, f.title, SUM(p.amount) AS revenue
FROM film f
JOIN inventory i ON i.film_id = f.film_id
JOIN rental r ON r.inventory_id = i.inventory_id
JOIN payment p ON p.rental_id = r.rental_id
GROUP BY f.film_id, f.title
ORDER BY revenue DESC
LIMIT 1;

-- How much revenue has each category made?
SELECT c.category_id, c.name, SUM(p.amount) AS revenue
FROM category c
JOIN film_category fc ON fc.category_id = c.category_id
JOIN inventory i ON i.film_id = fc.film_id
JOIN rental r ON r.inventory_id = i.inventory_id
JOIN payment p ON p.rental_id = r.rental_id
GROUP BY c.category_id, c.name
ORDER BY revenue DESC;

-- Which store made more money?
SELECT s.store_id, SUM(p.amount) AS revenue
FROM store s
JOIN staff st ON st.store_id = s.store_id
JOIN payment p ON p.staff_id = st.staff_id
GROUP BY s.store_id
ORDER BY revenue DESC;

-- What films did each customer rent, and how much did they pay for each?
SELECT cu.customer_id, cu.first_name, cu.last_name, f.film_id, f.title,
       SUM(p.amount) AS total_paid
FROM customer cu
JOIN rental r ON r.customer_id = cu.customer_id
JOIN inventory i ON i.inventory_id = r.inventory_id
JOIN film f ON f.film_id = i.film_id
JOIN payment p ON p.rental_id = r.rental_id
GROUP BY cu.customer_id, cu.first_name, cu.last_name, f.film_id, f.title
ORDER BY cu.customer_id, f.title;


-- -------------------------------------------------------------
-- 5. REVENUE BY LOCATION
-- -------------------------------------------------------------

-- Which city generated the most revenue?
SELECT ci.city_id, ci.city, SUM(p.amount) AS revenue
FROM city ci
JOIN address ad ON ad.city_id = ci.city_id
JOIN customer cu ON cu.address_id = ad.address_id
JOIN payment p ON p.customer_id = cu.customer_id
GROUP BY ci.city_id, ci.city
ORDER BY revenue DESC
LIMIT 1;

-- Which country generated the least revenue?
SELECT co.country_id, co.country, SUM(p.amount) AS revenue
FROM country co
JOIN city ci ON ci.country_id = co.country_id
JOIN address ad ON ad.city_id = ci.city_id
JOIN customer cu ON cu.address_id = ad.address_id
JOIN payment p ON p.customer_id = cu.customer_id
GROUP BY co.country_id, co.country
ORDER BY revenue ASC
LIMIT 1;

-- Who are the top 5 customers by spend, and which country are they from?
SELECT cu.customer_id, cu.first_name, cu.last_name, co.country,
       SUM(p.amount) AS total_spend
FROM customer cu
JOIN address ad ON ad.address_id = cu.address_id
JOIN city ci ON ci.city_id = ad.city_id
JOIN country co ON co.country_id = ci.country_id
JOIN payment p ON p.customer_id = cu.customer_id
GROUP BY cu.customer_id, cu.first_name, cu.last_name, co.country
ORDER BY total_spend DESC
LIMIT 5;


-- -------------------------------------------------------------
-- 6. DATES
-- -------------------------------------------------------------

-- Which month had the most rentals?
SELECT DATE_TRUNC('month', r.rental_date) AS rental_month,
       COUNT(*) AS rental_count
FROM rental r
GROUP BY rental_month
ORDER BY rental_count DESC
LIMIT 1;
