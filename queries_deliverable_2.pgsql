-- 1. What is the average review count over all the users?
SELECT avg(review_count)
FROM "user";

-- 2. How many businesses are in the provinces of Québec and Alberta?
-- false according to pandas
-- SELECT count(lr.business_id)
-- FROM business_locations AS lr
-- WHERE lr.postal_code_id IN (
--     SELECT c.state_id 
--     FROM city AS c
--     WHERE c.state_id in (
--         SELECT s.id
--         FROM state AS S
--         WHERE s.name = 'AB' OR
--               s.name = 'QC'
--     )
-- );
SELECT count(bl.business_id)
FROM business_locations AS bl
INNER JOIN postal_code AS pc ON pc.id = bl.postal_code_id
INNER JOIN city AS c ON c.id = pc.city_id
INNER JOIN state AS s ON s.id = c.state_id
WHERE s.name = 'AB' OR
      s.name = 'QC';

-- 3. What is the maximum number of categories assigned to a business? Show the business name and the previously described count.

SELECT b.id AS bid, count(bc.categorie_id) AS results
FROM business AS b
LEFT JOIN business_categorie AS bc ON bc.business_id = b.id
GROUP BY b.id
ORDER BY results DESC
LIMIT 1;

-- 4. How many businesses are labelled as "Dry Cleaners" or “Dry Cleaning”?
SELECT count(DISTINCT bc.business_id)
FROM business_categorie AS bc, categorie AS c
WHERE bc.categorie_id = c.id
AND (
    lower(c.name) LIKE '%dry cleaners%'
    OR lower(c.name) LIKE '%dry cleaning%'
);

-- 5. Find the overall number of reviews for all the businesses that have more than 150 reviews and have at least 2 (any 2) dietary restriction categories.
SELECT count(r)
FROM review AS r
WHERE r.business_id IN (
    SELECT b.id
    FROM business AS b
    INNER JOIN dietary_restrictions_business_relation AS drbr1 ON b.id = drbr1.business_id
    INNER JOIN dietary_restrictions_business_relation AS drbr2 ON drbr1.business_id = drbr2.business_id AND drbr1.dietary_restrictions_id <> drbr2.dietary_restrictions_id
    WHERE b.review_count > 150
);

-- 6. Display the user id and the number of friends of the top 10 users by number of friends.
-- Order the results by the number of users descending (the user with the highest number of friends first).
-- In case there are multiple users with the same number of students, show only top 10.
SELECT u.id, count(*)
FROM "user" AS u
INNER JOIN are_friends AS f ON u.id = f.user_id_1 OR u.id = f.user_id_2
GROUP BY u.id
ORDER BY count(*) DESC
LIMIT 10;

-- 7. Show the business name, number of stars, and the business review count of the top-5 businesses based on their review count that are currently open in the city of San Diego.
SELECT b.name, b.stars, b.review_count AS reviews
FROM business AS b
where b.is_open = TRUE AND
    b.id in (
        SELECT bl.business_id
        FROM business_locations AS bl, postal_code AS pc, city AS c
        WHERE bl.postal_code_id = pc.id
        AND pc.city_id = c.id
        AND c.name = 'San Diego'
    )
ORDER BY reviews DESC
LIMIT 5;

-- 8. Show the state name and the number of businesses for the state with the highest number of businesses.
SELECT s.name, count(bl.business_id)
FROM state AS s
INNER JOIN city AS c ON c.state_id = s.id
INNER JOIN postal_code AS pc ON pc.city_id = c.id
INNER JOIN business_locations AS bl ON bl.postal_code_id = pc.id
group by s.id
order by count(bl.business_id) desc
limit 1;

-- 9. Find the total average of “average star” of elite users, grouped by the year in which 
-- they started to be elite users. Display the required averages next to the appropriate years.
SELECT e.year, avg(u.average_stars)
FROM "user" AS u
INNER JOIN (
    SELECT min(e.year) as year, e.user_id as user_id
    FROM elite_years AS e
    GROUP BY e.user_id
) e ON e.user_id = u.id
GROUP BY e.year
ORDER BY e.year; -- NOT NECESSARY BUT NICER

-- 10. List the names of the top-10 businesses based on the median “star” rating,
-- that are currently open in the city of New York.
SELECT b.name
FROM business AS b
INNER JOIN business_locations AS bl ON bl.business_id = B.id
INNER JOIN postal_code AS pc ON pc.id = bl.postal_code_id
INNER JOIN city AS c ON c.id = pc.city_id
INNER JOIN review AS r ON r.business_id = b.id
WHERE b.is_open = true AND c.name = 'New York'
GROUP BY b.name
ORDER BY (percentile_cont(0.5) WITHIN GROUP (ORDER BY r.stars)) DESC
LIMIT 10;

-- 11. Find and show the minimum, maximum, mean, and median number of categories per business. 
-- Show the final statistic (4 numbers respectively, aggregated over all the businesses).
SELECT min(results), max(results), avg(results), percentile_cont(0.5) WITHIN GROUP (ORDER BY results)
FROM (
    SELECT count(bc.categorie_id) AS results
    FROM business AS b
    LEFT JOIN business_categorie AS bc ON bc.business_id = b.id
    GROUP BY b.id
) AS categorie_amounts;

-- 12. Find the businesses (show 'name', 'stars', 'review count') 
-- in the city of Las Vegas possessing 'valet' parking and open 
-- between '19:00' and '23:00' hours on a Friday.
SELECT b.name, b.stars, b.review_count
FROM business AS b
--join business with city
INNER JOIN business_locations AS bl ON bl.business_id = b.id
INNER JOIN postal_code AS pc ON pc.id = bl.postal_code_id
INNER JOIN city AS c ON c.id = pc.city_id
--join business with its parking attribute
INNER JOIN parking_business_relation AS pbr ON pbr.business_id = b.id
INNER JOIN business_parking AS bp ON bp.id = pbr.parking_id
--join business with its schedule ON friday
INNER JOIN schedule AS s ON s.business_id = b.id
INNER JOIN "day" AS d ON d.id = s.day_id
WHERE c.name = 'Las Vegas' AND
      bp.name = 'valet' AND
      d.name = 'Friday' AND
      s.start_at <= TIME '19:00' AND
      s.end_at >= TIME '23:00';
