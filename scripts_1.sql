-- THESE Querries require PostgreSQL

-- 1. What is the average review count over all the users?
select avg(review_count)
from user;

-- 2. How many businesses are in the provinces of Québec and Alberta?
select count(*)
from business as b
where b.city_id in {
    select c.id
    from city as c
    where lower(unaccent(c.name)) = "quebec"
    or lower(unaccent(c.name)) = "alberta"
};

-- 3. What is the maximum number of categories assigned to a business? Show the business name and the previously described count.
select b.name, count(bc.id)
from business as b, business_categorie as bc
where b.id = bc.business_id
group by b.id
order by count(bc.id) desc
limit 1;

-- 4. How many businesses are labelled as "Dry Cleaners" or “Dry Cleaning”?
select count(distinct b.id)
from business as b
inner join business_categorie as bc on b.id = bc.business_id
inner join categories as c on bc.categorie_id = c.id
where c.name = 'Dry Cleaners'
or c.name = 'Dry Cleaning';

-- 5. Find the overall number of reviews for all the businesses that have more than 150 reviews and have at least 2 (any 2) dietary restriction categories.
-- TODO: Seems bad regarding our modeling

-- 6. Display the user id and the number of friends of the top 10 users by number of friends. Order the results by the number of users descending (the user with the highest number of friends first). In case there are multiple users with the same number of students, show only top 10.
select u.id, count(*)
from user as u, are_friends as f
where u.id = f.user_id_1
or u.id = f.user_id_2
group by u.id
order by count(*) desc
limit 10;

-- 7. Show the business name, number of stars, and the business review count of the top-5 businesses based on their review count that are currently open in the city of San Diego.
select b.name, b.stars, b.review_count
from business as b
inner join city as c on c.id = b.city_id
where b.is_open = true
and c.name = 'San Diego'
group by b.review_count desc
limit 5;

-- 8. Show the state name and the number of businesses for the state with the highest number of businesses.
select s.name, count(b.id)
from 'state' as s
inner join city as c on c.state_id = s.id
inner join business as b on b.city_id = c.id
group by s.id
order by count(b.id) desc
limit 1;

-- 9. Find the total average of “average star” of elite users, grouped by the year in which they started to be elite users. Display the required averages next to the appropriate years.
-- TODO: Fix model

-- 10. List the names of the top-10 businesses based on the median “star” rating, that are currently open in the city of New York.

-- 11. Find and show the minimum, maximum, mean, and median number of categories per business. Show the final statistic (4 numbers respectively, aggregated over all the businesses).
select min(b.nb), max(b.nb), avg(b.nb), TODO: median
from {
    select count(bc.id)
    from business as b
    left join business_categorie as bc on bc.business_id = b.id
    group by b.id
};


-- 12. Find the businesses (show 'name', 'stars', 'review count') in the city of Las Vegas possessing 'valet' parking and open between '19:00' and '23:00' hours on a Friday.
