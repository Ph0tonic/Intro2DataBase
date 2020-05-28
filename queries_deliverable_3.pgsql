-- Can be usefull :
-- EXPLAIN ANALYZE

-- 1. What is the total number of businesses in the province of Ontario that have at least 6 reviews and a rating above 4.2
SELECT count(b.id)
FROM "state" AS s
INNER JOIN city AS c ON c.state_id = s.id
INNER JOIN postal_code AS pc ON pc.city_id = c.id
INNER JOIN business_locations AS bl ON bl.postal_code_id = pc.id
INNER JOIN business AS b ON b.id = bl.business_id
WHERE b.review_count >= 6
AND s.name = 'ON'
AND b.stars > 4.2;

-- 2. What is the average difference in review scores for businesses that are considered "good for dinner" that have noise levels "loud" or "very loud", compared to ones with noise levels "average" or "quiet"
WITH
b AS (
    SELECT b.stars AS stars, b.noise_level_id AS noise_level_id
    FROM business AS b
    INNER JOIN good_for_meal_business_relation AS gfmb ON gfmb.business_id = b.id
    INNER JOIN good_for_meal AS gfm ON gfm.id = gfmb.good_for_meal_id
    WHERE gfm.name = 'dinner'
)
SELECT abs(b1.stars_avg - b2.stars_avg) AS diff_average
FROM (
    SELECT avg(b.stars) AS stars_avg
    FROM b
    WHERE b.noise_level_id IN (
        SELECT nl.id as id
        FROM noise_level AS nl
        WHERE nl.level IN ('loud', 'very loud')
    )
) AS b1,
(
    SELECT avg(b.stars) AS stars_avg
    FROM b
    WHERE b.noise_level_id IN (
        SELECT nl.id as id
        FROM noise_level AS nl
        WHERE nl.level IN ('average', 'quiet')
    )
) AS b2;

-- 3. List the “name”, “star” rating, and “review_count” of the businesses that are tagged as “Irish Pub” and offer “live” music.
SELECT b.name, b.stars, b.review_count
FROM business AS b
INNER JOIN music_business_relation AS mbr ON mbr.business_id = b.id
INNER JOIN music AS m ON m.id = mbr.music_id
INNER JOIN business_categorie AS bc ON bc.business_id = b.id
INNER JOIN categorie AS c ON c.id = bc.categorie_id
WHERE m.name = 'live'
AND c.name = 'Irish Pub';

-- 4. Find the average number of attribute “useful” of the users whose average rating falls in the following 2 ranges:[2-4),[4-5]. Display separately these results for elite users vs. regular users(4 values total).
SELECT avg_elite_24, avg_elite_45, avg_nonelite_24, avg_nonelite_45
FROM (
    SELECT avg(u.useful)
    FROM "user" AS u
    WHERE 2 <= u.average_stars AND u.average_stars < 4 AND u.id IN (
        SELECT e.user_id
        FROM elite_years as e
        WHERE e.year = 2018 -- Not sure about that
    )
) AS avg_elite_24,
(
    SELECT avg(u.useful)
    FROM "user" AS u
    WHERE 2 <= u.average_stars AND u.average_stars < 4 AND u.id NOT IN (
        SELECT e.user_id
        FROM elite_years as e
        WHERE e.year = 2018 -- Not sure about that
    )
) AS avg_nonelite_24,
(
    SELECT avg(u.useful)
    FROM "user" AS u
    WHERE 4 <= u.average_stars AND u.average_stars <= 5 AND u.id IN (
        SELECT e.user_id
        FROM elite_years as e
        WHERE e.year = 2018 -- Not sure about that
    )
) AS avg_elite_45,
(
    SELECT avg(u.useful)
    FROM "user" AS u
    WHERE 4 <= u.average_stars AND u.average_stars <= 5 AND u.id NOT IN (
        SELECT e.user_id
        FROM elite_years as e
        WHERE e.year = 2018 -- Not sure about that
    )
) AS avg_nonelite_45;

-- 5. Find the average rating and number of reviews for all businesses which have at least two categories and more than(or equal to)one parking type.
-- TODO Ask assistant about global or local average
SELECT B.stars, B.review_count
FROM business AS b
WHERE b.id IN (
    SELECT DISTINCT pbr.business_id AS ids
    FROM parking_business_relation AS pbr

    INTERSECT

    SELECT bc.business_id as ids
    FROM business_categorie AS bc
    GROUP BY bc.business_id
    HAVING count(bc.categorie_id) >= 2
);

-- 6. What is the fraction of businesses (of the total number of businesses) that are considered "good for late night meals"
SELECT b_late.nb / b_all.nb AS good_for_late_fraction
FROM (
    SELECT count(*)::decimal AS nb
    FROM business
) AS b_all,
(
    SELECT count(*)::decimal as nb
    FROM business AS b
    INNER JOIN good_for_meal_business_relation AS gfmbr ON gfmbr.business_id = b.id
    INNER JOIN good_for_meal AS gfm ON gfm.id = gfmbr.good_for_meal_id
    WHERE gfm.name = 'latenight'
) AS b_late;

-- 7. Find the names of the cities where all businesses are closed on Sundays.
SELECT DISTINCT c.name
FROM city AS c
WHERE c.id NOT IN (
    SELECT pc.city_id
    FROM postal_code AS pc
    WHERE pc.id IN (
        SELECT DISTINCT bl.postal_code_id
        FROM business_locations AS bl
        INNER JOIN business AS b ON b.id = bl.business_id
        INNER JOIN schedule AS s ON b.id = s.business_id
        WHERE b.is_open AND s.day_id IN (
            SELECT d.id 
            FROM day AS d 
            WHERE d.name = 'Sunday'
        )
    )
);

-- 8. Find the ids of the businesses that have been reviewed by more than 1030 unique users.
SELECT b.id 
FROM business AS b
WHERE b.id IN (
    SELECT r.business_id as ids
    FROM review AS r
    GROUP BY r.business_id
    HAVING count(DISTINCT r.user_id) > 1030
);

-- 9. Find the top-10 (by the number of stars) businesses (business name, number of stars) in the state of California.
SELECT b.name, b.stars
FROM "state" AS s
INNER JOIN city AS c ON c.state_id = s.id
INNER JOIN postal_code AS pc ON pc.city_id = c.id
INNER JOIN business_locations AS bl ON bl.postal_code_id = pc.id
INNER JOIN business AS b ON b.id = bl.business_id
WHERE b.review_count > 6
AND s.name = 'CA'
ORDER BY b.stars DESC
LIMIT 10;

-- 10. Find the top-10 (by number of stars) ids of businesses per state. Show the results per state, in a descending order of number of stars.
SELECT br.business_id, br.name
FROM (
    SELECT 
        b.id AS business_id, s.name,
        row_number() OVER(PARTITION BY c.state_id ORDER BY b.stars DESC) AS rank
    FROM business AS b 
    INNER JOIN business_locations AS bl ON bl.business_id = b.id 
    INNER JOIN postal_code AS pc ON pc.id = bl.postal_code_id
    INNER JOIN city AS c ON c.id = pc.city_id
    INNER JOIN state AS s ON s.id = c.state_id
) AS br
WHERE br.rank <= 10;

-- 11. Find and display all the cities that satisfy the following: each business in the city has at least two reviews.
SELECT c.name
FROM city AS c
WHERE c.id NOT IN (
    SELECT pc.city_id
    FROM business AS b
    INNER JOIN business_locations AS bl ON b.id = bl.business_id
    INNER JOIN postal_code as pc ON bl.postal_code_id = pc.id
    WHERE b.review_count < 2
);

-- 12. Find the number of businesses for which every user that gave the business a positive tip (containing 'awesome') has also given some business a positive tip within the previous day.
SELECT count(*) AS nb_business
FROM (
    SELECT t.business_id, count(DISTINCT t.user_id)
    FROM tip as t
    WHERE LOWER(t.text) like'%awesome%'
    GROUP BY t.business_id
    
    INTERSECT
    
    SELECT t1.business_id, count(DISTINCT t1.user_id)
    FROM tip AS t1
    INNER JOIN tip AS t2 ON t1.user_id = t2.user_id
    WHERE LOWER(t1.text) like'%awesome%'
    AND LOWER(t2.text) like'%awesome%'
    AND t1.date::TIMESTAMP::DATE - INTERVAL '1 DAY' = t2.date::TIMESTAMP::DATE
    GROUP BY t1.business_id
) as b;

-- 13. Find the maximum number of different businesses any user has ever reviewed.
SELECT max(business_reviewed.business_count)
FROM (
    SELECT count(DISTINCT r.business_id) AS business_count
    FROM review AS r 
    GROUP BY r.user_id
) AS business_reviewed;

-- 14. What is the difference between the average useful rating of reviews given by elite and non-elite users
--proposed update v2 (If no cache is force at all then the query is able to manage it even better)
SELECT abs(avg_useful_elite.average - avg_useful_non_elite.average)
FROM (
    SELECT avg(r.useful) AS average
    FROM review AS r
    WHERE r.user_id IN (
        SELECT DISTINCT e.user_id
        FROM elite_years AS e
        WHERE e.year = 2018
   )
) AS avg_useful_elite,
(
    SELECT avg(r.useful) AS average
    FROM review AS r
    WHERE r.user_id NOT IN (
        SELECT DISTINCT e.user_id
        FROM elite_years AS e
        WHERE e.year = 2018
    )
) AS avg_useful_non_elite;

-- 15. List the name of the businesses that are currently 'open', possess a median star rating of 4.5 or above, considered good for 'brunch', and open on weekends.
SELECT b.name
FROM (
    SELECT r.business_id AS id
    FROM review AS r
    GROUP BY r.business_id
    HAVING percentile_disc(0.5) WITHIN GROUP (ORDER BY r.stars) >= 4.5
) AS b1
INNER JOIN business AS b ON b.id = b1.id
INNER JOIN good_for_meal_business_relation AS gfmbr ON gfmbr.business_id = b.id
INNER JOIN good_for_meal AS gfm ON gfm.id = gfmbr.good_for_meal_id
INNER JOIN schedule AS s1 ON s1.business_id = b.id
INNER JOIN schedule AS s2 ON s2.business_id = b.id
WHERE b.is_open = true
AND gfm.name = 'brunch'
AND s1.day_id = (
    SELECT d.id
    FROM "day" AS d
    WHERE d.name = 'Saturday'
)
AND s2.day_id = (
    SELECT d.id
    FROM "day" AS d
    WHERE d.name = 'Sunday'
);

-- 16. List the 'name', 'star' rating, and 'review_count' of the top-5 businesses in the city of 'los angeles' based on the average 'star' rating that serve both 'vegetarian' and 'vegan' food and open between '14:00' and '16:00' hours. Note: The average star rating should be computed by taking the mean of 'star' ratings provided in each review of this business.
-- ~ 5 ms
SELECT b.name, b.stars, b.review_count
FROM business AS b
INNER JOIN (
    SELECT r.business_id AS business_id, avg(r.stars) AS avg
    FROM review AS r 
    GROUP BY r.business_id
) AS stars ON stars.business_id = b.id 
INNER JOIN schedule AS s ON s.business_id = b.id
WHERE b.id IN (
    SELECT bl.business_id
    FROM business_locations AS bl
    INNER JOIN postal_code AS pc ON bl.postal_code_id = pc.id 
    INNER JOIN city AS c ON c.id = pc.city_id
    WHERE c.name = 'Los Angeles'

    INTERSECT

    SELECT dbr.business_id
    FROM dietary_restrictions_business_relation AS dbr 
    INNER JOIN dietary_restrictions AS dr ON dbr.dietary_restrictions_id = dr.id 
    WHERE dr.name = 'vegetarian'
   
    INTERSECT

    SELECT dbr.business_id
    FROM dietary_restrictions_business_relation AS dbr 
    INNER JOIN dietary_restrictions AS dr ON dbr.dietary_restrictions_id = dr.id 
    WHERE dr.name = 'vegan'
) AND b.is_open AND s.start_at <= '14:00' AND '16:00' <= s.end_at
ORDER BY stars.avg DESC
LIMIT 5;


-- ~ 10 ms
SELECT b.name, b.stars, b.review_count
FROM business AS b
INNER JOIN (
    SELECT r.business_id AS business_id, avg(r.stars) AS avg
    FROM review AS r 
    GROUP BY r.business_id
) AS stars ON stars.business_id = b.id 
INNER JOIN schedule AS s ON s.business_id = b.id
INNER JOIN business_locations AS bl ON bl.business_id = b.id 
INNER JOIN postal_code AS pc ON bl.postal_code_id = pc.id 
INNER JOIN city AS c ON c.id = pc.city_id
INNER JOIN dietary_restrictions_business_relation AS dbr1 ON dbr1.business_id = b.id
INNER JOIN dietary_restrictions AS dr1 ON dbr1.dietary_restrictions_id = dr1.id 
INNER JOIN dietary_restrictions_business_relation AS dbr2 ON dbr2.business_id = b.id
INNER JOIN dietary_restrictions AS dr2 ON dbr2.dietary_restrictions_id = dr2.id 
WHERE dr1.name = 'vegetarian' AND dr2.name = 'vegan' AND c.name = 'Los Angeles' 
    AND b.is_open AND s.start_at <= '14:00' AND '16:00' <= s.end_at
ORDER BY stars.avg DESC
LIMIT 5;


-- ~ 200 ms
SELECT b.name, b.stars, b.review_count
FROM business AS b
INNER JOIN (
    SELECT r.business_id AS business_id, avg(r.stars) AS avg
    FROM review AS r 
    GROUP BY r.business_id
) AS stars ON stars.business_id = b.id 
WHERE b.id IN (
    SELECT bl.business_id
    FROM business_locations AS bl
    INNER JOIN postal_code AS pc ON bl.postal_code_id = pc.id 
    INNER JOIN city AS c ON c.id = pc.city_id
    WHERE c.name = 'Los Angeles'

    INTERSECT

    SELECT dbr.business_id
    FROM dietary_restrictions_business_relation AS dbr 
    INNER JOIN dietary_restrictions AS dr ON dbr.dietary_restrictions_id = dr.id 
    WHERE dr.name = 'vegetarian'
   
    INTERSECT

    SELECT dbr.business_id
    FROM dietary_restrictions_business_relation AS dbr 
    INNER JOIN dietary_restrictions AS dr ON dbr.dietary_restrictions_id = dr.id 
    WHERE dr.name = 'vegan'

    INTERSECT

    SELECT s.business_id
    FROM schedule AS s 
    WHERE s.start_at <= '14:00' AND '16:00' <= s.end_at
) AND b.is_open
ORDER BY stars.avg DESC
LIMIT 5;

-- ~ 430 ms
SELECT b.name, b.stars, b.review_count
FROM business AS b
INNER JOIN (
    SELECT r.business_id AS business_id, avg(r.stars) AS avg
    FROM review AS r 
    GROUP BY r.business_id
) AS stars ON stars.business_id = b.id 
INNER JOIN schedule AS s ON s.business_id = b.id
INNER JOIN business_locations AS bl ON bl.business_id = b.id 
INNER JOIN postal_code AS pc ON bl.postal_code_id = pc.id 
INNER JOIN city AS c ON c.id = pc.city_id
WHERE c.name = 'Los Angeles' AND b.id IN (
    SELECT dbr.business_id
    FROM dietary_restrictions_business_relation AS dbr 
    INNER JOIN dietary_restrictions AS dr ON dbr.dietary_restrictions_id = dr.id 
    WHERE dr.name = 'vegetarian'
   
    INTERSECT

    SELECT dbr.business_id
    FROM dietary_restrictions_business_relation AS dbr 
    INNER JOIN dietary_restrictions AS dr ON dbr.dietary_restrictions_id = dr.id 
    WHERE dr.name = 'vegan'
) AND b.is_open AND s.start_at <= '14:00' AND '16:00' <= s.end_at
ORDER BY stars.avg DESC
LIMIT 5;

-- 17. Compute the difference between the average 'star' ratings (use the reviews for each business to compute its average star rating) of businesses considered 'good for dinner' with a (1) "divey" and (2) an "upscale" ambience.
WITH good_for_dinner_business AS (
    SELECT gfmbr.business_id as id
    FROM good_for_meal_business_relation as gfmbr
    INNER JOIN good_for_meal AS gfm ON gfmbr.good_for_meal_id = gfm.id
    WHERE gfm.name = 'dinner'
)
SELECT abs(divey_business_stars.avg_stars - upscale_business_stars.avg_stars)
FROM (
    SELECT avg(r.stars) AS avg_stars
    FROM review AS r
    WHERE r.business_id IN (SELECT * FROM good_for_dinner_business)
    AND r.business_id IN (
        SELECT abr.business_id 
        FROM ambience_business_relation AS abr
        INNER JOIN ambience AS a on a.id = abr.ambience_id
        WHERE a.name = 'divey'
    )
) AS divey_business_stars,
(
    SELECT avg(r.stars) AS avg_stars
    FROM review AS r 
    WHERE r.business_id IN (SELECT * FROM good_for_dinner_business)
    AND r.business_id IN (
        SELECT abr.business_id 
        FROM ambience_business_relation AS abr
        INNER JOIN ambience AS a on a.id = abr.ambience_id
        WHERE a.name = 'upscale'
    )
) AS upscale_business_stars;

-- 18. Find the number of cities that satisfy the following: the city has at least five businesses and each of the top-5 (in terms of number of reviews) businesses in the city has a minimum of 100 reviews.
SELECT count(*) as nb_cities
FROM (
   SELECT c.id
   FROM city as c
   INNER JOIN postal_code AS pc ON pc.city_id = c.id
   INNER JOIN business_locations AS bl ON bl.postal_code_id = pc.id
   INNER JOIN business AS b ON b.id = bl.business_id
   WHERE b.review_count >= 100
   GROUP BY c.id
   HAVING count(b.id) >= 5
) AS c;

-- 19. Find the names of the cities that satisfy the following: the combined number of reviews for the top-100 (by reviews) businesses in the city is at least double the combined number of reviews for the rest of the businesses in the city.
-- assumption if there is less than 100 business in a city then this city is included in the result
WITH c AS (
    SELECT cr.id, sum(cr.review_count), cr.rank <= 100 AS in_top_100
    FROM (
        SELECT 
            pc.city_id AS "id",
            b.review_count AS review_count,
            row_number() OVER(PARTITION BY pc.city_id ORDER BY b.review_count DESC) AS rank 
        FROM postal_code AS pc
        INNER JOIN business_locations AS bl ON bl.postal_code_id = pc.id 
        INNER JOIN business AS b ON bl.business_id = b.id 
    ) AS cr
    GROUP BY cr.id, cr.rank <= 100
)
SELECT city.name
FROM city
WHERE city.id IN (
    SELECT c1.id
    FROM c AS c1
    INNER JOIN c AS c2 ON c2.id = c1.id 
    WHERE c1.sum > 2 * COALESCE(c2.sum, 0)
    AND c1.in_top_100

    UNION

    SELECT pc.city_id AS id
    FROM postal_code AS pc
    INNER JOIN business_locations AS bl ON bl.postal_code_id = pc.id 
    INNER JOIN business AS b ON bl.business_id = b.id 
    GROUP BY pc.city_id
    HAVING count(b.id) <= 100
);

-- 20. For each of the top-10 (by the number of reviews) businesses, find the top-3 reviewers by activity among those who reviewed the business. Reviewers by activity are defined and ordered as the users that have the highest numbers of total reviews across all the businesses(the users that review the most).
