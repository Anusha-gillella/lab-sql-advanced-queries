use sakila;

-- Query 1: List each pair of actors that have worked together.
select r1.actor_id as actor_a, r2.actor_id as actor_b,
	count(r1.film_id) as casted_together
	from film_actor r1
join film_actor r2
	on r1.film_id = r2.film_id
	and r1.actor_id > r2.actor_id
group by r1.actor_id, r2.actor_id
order by casted_together desc;


 -- correlated subquery
select sub.* from 
	(select f.actor_id as actor1, fm.actor_id as actor2, count(*),
		row_number() over (partition by f.actor_id order by count(*) desc) as flag
	from film_actor as f
	join film_actor as fm on f.film_id = fm.film_id and f.actor_id > fm.actor_id
	group by actor1, actor2
    order by count(*) desc)sub
where flag = 1;
        


-- Query 2: For each film, list actor that has acted in more films.
with cte as (
	select *, 
    row_number() over(partition by film_id order by total_films desc) as flag
    from(
		select film_id, actor_id, total_films from (
			select actor_id, count(film_id) as total_films
			from film_actor
			group by actor_id) sub1
		join film_actor using(actor_id)
		)sub2
)
select film_id, actor_id, total_films from cte
where flag = 1;


-- same query
with cte as
	(select actor_id, count(film_id) as total_movies from film_actor
	group by actor_id
	order by actor_id),
cte2 as (
	select film_id, actor_id, total_movies,
    row_number() over (partition by film_id order by total_movies desc) as flag
    from cte
    join film_actor using(actor_id)
    order by film_id asc, total_movies desc)
select film_id, actor_id, total_movies from cte2
where flag = 1;