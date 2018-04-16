use sakila;

SELECT * FROM sakila.actor;

#1a-Display the first and last names of all actors from the table actor.
#https://www.w3schools.com/sql/sql_select.asp
select first_name,last_name
from actor;

#1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name. 
#https://www.sqlbook.com/sql-string-functions/sql-concatenate/
#concatenate in sql

#ALREADY ALL CAPS
SELECT CONCAT((first_name)," ",(last_name)) as "Actor Name"
From actor;

#2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
Select actor_id, first_name, last_name 
from actor
where first_name="Joe";


#2b. Find all actors whose last name contain the letters GEN:

#USING WILDCARDS: http://www-db.deis.unibo.it/courses/TW/DOCS/w3schools/sql/sql_wildcards.asp.html
select * from actor
where last_name like "%gen%";

#2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
#ORDERING: http://www.dofactory.com/sql/order-by

SELECT*FROM actor
where last_name like "%li%" ORDER BY last_name, first_name;

#2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
#USING IN: https://www.techonthenet.com/sql/in.php

select*from country
where country in('Afghanistan','Bangladesh','China');

#3a. Add a middle_name column to the table actor. Position it between first_name and last_name. Hint: you will need to specify the data type.
#Alter: https://www.w3schools.com/sql/sql_alter.asp
alter table actor
add column middle_name varchar(30)
after first_name;
select*from actor;
#3b. You realize that some of these actors have tremendously long last names. Change the data type of the middle_name column to blobs.
#BLOB: https://stackoverflow.com/questions/5414551/what-is-it-exactly-a-blob-in-a-dbms-context
alter table actor MODIFY middle_name BLOB;
select*from actor;

#3c. Now delete the middle_name column.
#DROPPING COLUMNS:https://www.1keydata.com/sql/alter-table-drop-column.html
alter table actor 
drop middle_name;

select*from actor;
#4a. List the last names of actors, as well as how many actors have that last name.
#COUNT: https://stackoverflow.com/questions/59294/in-sql-whats-the-difference-between-countcolumn-and-count
select last_name, count(last_name) as "Number of Actors"
from actor
group by last_name;

#4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
select last_name, count(last_name) as "Number of Actors"
from actor
group by last_name
having count(last_name)>1;

#4c. Oh, no! The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS, the name of Harpo's second cousin's husband's yoga teacher. Write a query to fix the record.
update actor set first_name = 'Harpo'
where first_name = "Groucho" AND last_name="Williams";

#4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO. Otherwise, change the first name to MUCHO GROUCHO, as that is exactly what the actor will be with the grievous error. BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY ACTOR TO MUCHO GROUCHO, HOWEVER! (Hint: update the record using a unique identifier.)
update actor
set first_name=
	Case
	When first_name = "Harpo"
	Then "Groucho"
    Else "Mucho Groucho"
    End;


#5a. You cannot locate the schema of the address table. Which query would you use to re-create it? 
#SELECT * FROM sakila.address;

#Hint: https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html
show columns from sakila.address;
show create table sakila.address;


#6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
select first_name, last_name, address from staff 
inner join address actor on staff.address_id = actor.address_id;

#6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment. 
select staff.staff_id, first_name, last_name, sum(amount) as "Total Amount"FROM staff
inner join payment
on staff.staff_id = payment.staff_id
group by staff.staff_id;


#6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
select f.title, count(fa.actor_id) as "Number of Actors"
From film f
left join film_actor fa
on f.film_id = fa.film_id
group by f.film_id;

#6d. How many copies of the film Hunchback Impossible exist in the inventory system?
select f.title, count(i.inventory_id) as "Number in Stock"
From film f
inner join inventory i
on f.film_id = i.film_id
group by f.film_id
having title = "Hunchback Impossible";

#6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
#    ![Total amount paid](Images/total_payment.png)
#http://www.dofactory.com/sql/order-by

select customer.last_name, customer.first_name, sum(payment.amount) as "Total"
from customer
inner join payment
on customer.customer_id = payment.customer_id
group by payment.customer_id
order by last_name, first_name;


#7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English. 
select title from film
where language_id in
(select language_id from language where name = "English")
and (title like "K%") or (title like "Q%");
#7b. Use subqueries to display all actors who appear in the film Alone Trip.
select first_name, last_name from actor
where actor_id in 
	(select actor_id from film_actor
	where film_id in
		(select film_id from film
        where title = "Alone Trip"));

#7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
select customer.first_name, customer.last_name, customer.email, country.country from customer
left join address
on customer.address_id = address.address_id
where country = "Canada";

#7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as famiy films.
select * from film
where film_id in
	(select film_id from film_category
    where category_id in
		(select category_id from category
        where name = "Family"));

#7e. Display the most frequently rented movies in descending order.
select film.title, count(rental.rental_id) as "Number of Rentals" from film
right join inventory
on film.film_id = inventory.film_id
join rental
on rental.inventory_id = inventory.inventory_id
group by film.title
order by count(rental.rental_id) DESC;

#7f. Write a query to display how much business, in dollars, each store brought in.
select store.store_id, sum(amount) as "Revenue" from store
right join staff
on store.store_id = staff.store_id
left join payment
on staff.staff_id = payment.staff_id
group by store.store_id;

#7g. Write a query to display for each store its store ID, city, and country.
select store.store_id, city.city, country.country from store
join address
on store.address_id = address.address_id
join city
on address.city_id = city.city_id
join country
on city.country_id = country.country_id;

#7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
select category.name, sum(payment.amount) as "Rev. Per Category" from category
join film_category
on category.category_id = film_category.category_id
join inventory
on film_category.film_id = inventory.film_id
join rental
on rental.inventory_id = inventory.inventory_id
join payment
on payment.rental_id = rental.rental_id
group by name;

#8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
create view top_5 as
select category.name, sum(payment.amount) as "Rev. Per Category" from category
join film_category
on category.category_id = film_category.category_id
join inventory
on film_category.film_id = inventory.film_id
join rental
on rental.inventory_id = inventory.inventory_id
join payment
on payment.rental_id = rental.rental_id
group by name
limit 5;


#8b. How would you display the view that you created in 8a?
select * from top_5;

#8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
drop view top_5;