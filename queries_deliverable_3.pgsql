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
b AS (SELECT b.stars AS stars, b.noise_level_id AS noise_level_id
      FROM business AS b
      INNER JOIN good_for_meal_business_relation AS gfmb ON gfmb.business_id = b.id
      INNER JOIN good_for_meal AS gfm ON gfm.id = gfmb.good_for_meal_id
      WHERE gfm.name = 'dinner')
SELECT avg(b1.stars) - avg(b2.stars) AS diff_average
FROM b AS b1, b AS b2
WHERE b1.noise_level_id IN (
      SELECT nl.id as id
      FROM noise_level AS nl
      WHERE nl.level IN ('loud', 'very loud')
)
AND b2.noise_level_id IN (
      SELECT nl.id as id
      FROM noise_level AS nl
      WHERE nl.level IN ('average', 'quiet')
);

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
SELECT avg0, avg1, avg2, avg3
FROM (
   SELECT avg(u.useful)
   FROM "user" AS u
   WHERE 2 <= u.average_stars AND u.average_stars < 4 AND u.id IN (
      SELECT e.user_id
      FROM elite_years as e
      WHERE e.year = 2018 -- Not sure about that
   )
) AS avg0,
(
   SELECT avg(u.useful)
   FROM "user" AS u
   WHERE 2 <= u.average_stars AND u.average_stars < 4 AND u.id NOT IN (
      SELECT e.user_id
      FROM elite_years as e
      WHERE e.year = 2018 -- Not sure about that
   )
) AS avg1,
(
   SELECT avg(u.useful)
   FROM "user" AS u
   WHERE 4 <= u.average_stars AND u.average_stars <= 5 AND u.id IN (
      SELECT e.user_id
      FROM elite_years as e
      WHERE e.year = 2018 -- Not sure about that
   )
) AS avg2,
(
   SELECT avg(u.useful)
   FROM "user" AS u
   WHERE 4 <= u.average_stars AND u.average_stars <= 5 AND u.id NOT IN (
      SELECT e.user_id
      FROM elite_years as e
      WHERE e.year = 2018 -- Not sure about that
   )
) AS avg3;

-- 5. Find the average rating and number of reviews for all businesses which have at least two categories and more than(or equal to)one parking type.
SELECT B.stars, B.review_count
FROM business AS b
WHERE b.id IN 
    (SELECT businesses.ids
    FROM (
        SELECT pbr.business_id AS ids, count(pbr.parking_id) AS amount_relations
        FROM parking_business_relation AS pbr
        GROUP BY pbr.business_id
    ) AS businesses
    WHERE businesses.amount_relations >= 1
) AND b.id IN (
    SELECT businesses.ids
    FROM (
        SELECT bc.business_id as ids, count(bc.categorie_id) as amount_relations
        FROM business_categorie AS bc
        GROUP BY bc.business_id
    ) AS businesses
    where businesses.amount_relations >= 2
);
--proposed with having
SELECT B.stars, B.review_count
FROM business AS b
WHERE b.id IN (
   SELECT pbr.business_id AS ids
   FROM parking_business_relation AS pbr
   GROUP BY pbr.business_id
   HAVING count(pbr.parking_id) >= 1

   INTERSECT

   SELECT bc.business_id as ids
   FROM business_categorie AS bc
   GROUP BY bc.business_id
   HAVING count(bc.categorie_id) >= 2
);

-- 6. What is the fraction of businesses(of the total number of businesses) that are considered "good for late night meals"
SELECT count(b_late)::decimal/count(b_all) AS good_for_late_fraction
FROM (
   SELECT count(*)
   FROM business
) AS b_all,
(
   SELECT count(*)
   FROM business AS b
   INNER JOIN good_for_meal_business_relation AS gfmbr ON gfmbr.business_id = b.id
   INNER JOIN good_for_meal AS gfm ON gfm.id = gfmbr.good_for_meal_id
   WHERE gfm.name = 'latenight'
) AS b_late;

-- 7. Find the names of the cities where all businesses are closed on Sundays.
SELECT c.name
FROM city AS c
WHERE c.id NOT IN (
   SELECT DISTINCT pc.city_id -- DISTINCT not necessary -> SPEED UP
   FROM postal_code AS pc
   WHERE pc.id IN (
      SELECT DISTINCT bl.postal_code_id -- DISTINCT not necessary -> SPEED UP
      FROM business_locations AS bl
      INNER JOIN business AS b ON b.id = bl.business_id -- Not necessary, not require to check is_open
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
    SELECT businesses.ids
    FROM (
        SELECT r.business_id as ids, count(r.user_id) as review_amount
        FROM review AS r
        GROUP BY r.business_id
    ) as businesses
    WHERE businesses.review_amount > 1030
);
--proposed update with having
SELECT b.id 
FROM business AS b
WHERE b.id IN (
   SELECT r.business_id as ids
   FROM review AS r
   GROUP BY r.business_id
   HAVING count(r.user_id) > 1030
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

-- 11. Find and display all the cities that satisfy the following: each business in the city has at least two reviews.
-- version on the attribute
SELECT c.name
FROM city AS c
WHERE NOT EXISTS (
    SELECT b.id
    FROM business AS b
    INNER JOIN business_locations AS bl ON b.id = bl.business_id
    INNER JOIN postal_code as pc ON bl.postal_code_id = pc.id AND pc.city_id = c.id  
    WHERE b.review_count < 2  
);
--proposed update
SELECT c.name
FROM city AS c
WHERE c.id NOT IN (
    SELECT pc.city_id
    FROM business AS b
    INNER JOIN business_locations AS bl ON b.id = bl.business_id
    INNER JOIN postal_code as pc ON bl.postal_code_id = pc.id
    WHERE b.review_count < 2  
);

--version on the relation
SELECT c.name
FROM city AS c
WHERE NOT EXISTS (
    SELECT b.id
    FROM business AS b
    INNER JOIN business_locations AS bl ON b.id = bl.business_id
    INNER JOIN postal_code AS pc ON bl.postal_code_id = pc.id AND pc.city_id = c.id  
    WHERE b.id IN (
        SELECT res.ids
        FROM (
            SELECT r.business_id AS ids, count(r.user_id) AS amount
            FROM review AS r
            GROUP BY r.business_id
        ) AS res
        where res.amount < 2
    )
);
-- proposed update :
SELECT c.name
FROM city AS c
WHERE c.id NOT IN (
    SELECT pc.city_id as id
    FROM business_locations AS bl
    INNER JOIN postal_code AS pc ON bl.postal_code_id = pc.id
    WHERE bl.business_id IN (
      SELECT r.business_id AS ids
      FROM review AS r
      GROUP BY r.business_id
      HAVING count(r.id) < 2
    )
);

-- 12. Find the number of businesses for which every user that gave the business a positive tip (containing 'awesome') has also given some business a positive tip within the previous day.
SELECT count(*) AS nb_business
FROM (
   SELECT t.business_id, count(t.user_id)
   FROM tip as t
   WHERE t.text like'awesome'
   GROUP BY t.business_id
   
   INTERSECT
   
   SELECT t1.business_id, count(t1.user_id)
   FROM tip AS t1
   INNER JOIN tip AS t2 ON t1.user_id = t2.user_id
   WHERE t1.text like'awesome'
   AND t1.date::TIMESTAMP - INTERVAL '1 DAY' = t2.date::TIMESTAMP
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
WITH elite_users AS (
    SELECT DISTINCT ey.user_id
    FROM elite_years AS ey
), avg_useful_elite AS (
    SELECT avg(r.useful) AS average
    FROM review AS r
    WHERE r.user_id IN (SELECT * FROM elite_users)
), avg_useful_non_elite AS (
    SELECT avg(r.useful) AS average
    FROM review AS r
    WHERE r.user_id NOT IN (SELECT * FROM elite_users)
)
SELECT abs(aue.average - aune.average)
FROM avg_useful_elite as aue, avg_useful_non_elite as aune;

-- proposed update (we do not need to force cache for avg_useful_elite)
WITH elite_users AS (
    SELECT DISTINCT ey.user_id
    FROM elite_years AS ey
)
SELECT abs(avg_useful_elite.average - avg_useful_non_elite.average)
FROM (
    SELECT avg(r.useful) AS average
    FROM review AS r
    WHERE r.user_id IN (SELECT * FROM elite_users)
) AS avg_useful_elite,
(
    SELECT avg(r.useful) AS average
    FROM review AS r
    WHERE r.user_id NOT IN (SELECT * FROM elite_users)
) AS avg_useful_non_elite;
--proposed update v2 (If no cache is force at all then the query is able to manage it even better)
SELECT abs(avg_useful_elite.average - avg_useful_non_elite.average)
FROM (
    SELECT avg(r.useful) AS average
    FROM review AS r
    WHERE r.user_id IN (
      SELECT DISTINCT ey.user_id
      FROM elite_years AS ey
   )
) AS avg_useful_elite,
(
    SELECT avg(r.useful) AS average
    FROM review AS r
    WHERE r.user_id NOT IN (
      SELECT DISTINCT ey.user_id
      FROM elite_years AS ey
   )
) AS avg_useful_non_elite;

-- 15. List the name of the businesses that are currently 'open', possess a median star rating of 4.5 or above, considered good for 'brunch', and open on weekends.
EXPLAIN ANALYZE
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
   FROM day as d
   WHERE d.name = 'Saturday'
)
AND s2.day_id = (
   SELECT d.id
   FROM day as d
   WHERE d.name = 'Sunday'
);

-- 16. List the 'name', 'star' rating, and 'review_count' of the top-5 businesses in the city of 'los angeles' based on the average 'star' rating that serve both 'vegetarian' and 'vegan' food and open between '14:00' and '16:00' hours. Note: The average star rating should be computed by taking the mean of 'star' ratings provided in each review of this business.
SELECT b.name, b.stars, b.review_count
FROM business AS b 
INNER JOIN business_locations AS bl ON bl.business_id = b.id 
INNER JOIN postal_code AS pc ON bl.postal_code_id = pc.id 
INNER JOIN city AS c ON c.id = pc.city_id 
INNER JOIN (
   SELECT r.business_id AS business_id, avg(r.stars) AS avg
   FROM review AS r 
   GROUP BY r.business_id
) AS stars ON stars.business_id = b.id 
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

      INTERSECT

   SELECT s.business_id
   FROM schedule AS s 
   WHERE s.start_at <= '14:00' AND '16:00' <= s.end_at
) AND b.is_open -- Not sure
ORDER BY stars.avg DESC
LIMIT 5;

-- 17. Compute the difference between the average 'star' ratings (use the reviews for each business to compute its average star rating) of businesses considered 'good for dinner' with a (1) "divey" and (2) an "upscale" ambience.
-- 17. Compute the difference between the average 'star' ratings 
-- (use the reviews for each business to compute its average star rating) 
-- of businesses considered 'good for dinner' with a (1) "divey" and (2) an "upscale" ambience.
WITH good_for_dinner_business AS (
    SELECT gfmbr.business_id as id
    FROM good_for_meal_business_relation as gfmbr
    INNER JOIN good_for_meal AS gfm ON gfmbr.good_for_meal_id = gfm.id
    WHERE gfm.name = 'dinner'
), divey_business_stars AS (
    SELECT avg(r.stars) AS avg_stars
    FROM review AS r 
    WHERE r.business_id IN (SELECT * FROM good_for_dinner_business) AND
          r.business_id IN(
              SELECT abr.business_id 
              FROM ambience_business_relation AS abr
              INNER JOIN ambience AS a on a.id = abr.ambience_id
              WHERE a.name = 'divey'
          )
), upscale_business_stars AS (
    SELECT avg(r.stars) AS avg_stars
    FROM review AS r 
    WHERE r.business_id IN (SELECT * FROM good_for_dinner_business) AND
          r.business_id IN(
              SELECT abr.business_id 
              FROM ambience_business_relation AS abr
              INNER JOIN ambience AS a on a.id = abr.ambience_id
              WHERE a.name = 'upscale'
          )
)
select abs(dbs.avg_stars - ubs.avg_stars)
from divey_business_stars as dbs, upscale_business_stars as ubs;

-- proposed update (More straightforward and no need of caching all subquery but performance still remaining the same)
WITH good_for_dinner_business AS (
    SELECT gfmbr.business_id as id
    FROM good_for_meal_business_relation as gfmbr
    INNER JOIN good_for_meal AS gfm ON gfmbr.good_for_meal_id = gfm.id
    WHERE gfm.name = 'dinner'
)
select abs(divey_business_stars.avg_stars - upscale_business_stars.avg_stars)
from (
    SELECT avg(r.stars) AS avg_stars
    FROM review AS r 
    WHERE r.business_id IN (SELECT * FROM good_for_dinner_business) AND
          r.business_id IN(
              SELECT abr.business_id 
              FROM ambience_business_relation AS abr
              INNER JOIN ambience AS a on a.id = abr.ambience_id
              WHERE a.name = 'divey'
          )
) AS divey_business_stars,
(
    SELECT avg(r.stars) AS avg_stars
    FROM review AS r 
    WHERE r.business_id IN (SELECT * FROM good_for_dinner_business) AND
          r.business_id IN(
              SELECT abr.business_id 
              FROM ambience_business_relation AS abr
              INNER JOIN ambience AS a on a.id = abr.ambience_id
              WHERE a.name = 'upscale'
          )
) AS upscale_business_stars;

-- 18. Find the number of cities that satisfy the following: the city has at least five businesses and each of the top-5 (in terms of number of reviews) businesses in the city has a minimum of 100 reviews.
SELECT count(*) as nb_cities
FROM (
   SELECT count(c.id)
   FROM city as c
   INNER JOIN postal_code AS pc ON pc.city_id = c.id
   INNER JOIN business_locations AS bl ON bl.postal_code_id = pc.id
   INNER JOIN (
      SELECT r.business_id AS id
      FROM review AS r
      GROUP BY r.business_id
      HAVING count(r.id) > 100
   ) AS b ON b.id = bl.business_id
   GROUP BY c.id
   HAVING count(b.id) >= 5
) AS c;

-- 19. Find the names of the cities that satisfy the following: the combined number of reviews for the top-100 (by reviews) businesses in the city is at least double the combined number of reviews for the rest of the businesses in the city.

-- 20. For each of the top-10 (by the number of reviews) businesses, find the top-3 reviewersby activity among those who reviewed the business. Reviewers by activity are defined and ordered as the users that have the highest numbers of total reviews across all the businesses(the users that review the most).



-- -------------------------------------------
-- FOLLOWING LINES JUST FOR AUTO-COMPLETION --
-- -------------------------------------------



-- 1. What is the average review count over all the users?
SELECT avg(review_count)
FROM "user";

-- 2. How many businesses are in the provinces of Québec and Alberta?
-- false according to pandas
-- SELECT count(lr.business_id)
-- FROM business_locations as lr
-- WHERE lr.postal_code_id IN (
--   SELECT c.state_id 
--   FROM city as c
--   WHERE c.state_id in (
--     SELECT s.id
--     FROM state as S
--     where s.name = 'AB' OR
--        s.name = 'QC'
--   )
-- );
SELECT count(bl.business_id)
FROM business_locations as bl
INNER JOIN postal_code AS pc on pc.id = bl.postal_code_id
INNER JOIN city as c on c.id = pc.city_id
INNER JOIN state as s on s.id = c.state_id
WHERE s.name = 'AB' OR
   s.name = 'QC';

-- 3. What is the maximum number of categories assigned to a business? Show the business name and the previously described count.

SELECT b.id as bid, count(bc.categorie_id) AS results
FROM business AS b
LEFT JOIN business_categorie AS bc ON bc.business_id = b.id
GROUP BY b.id
ORDER BY results DESC
LIMIT 1;

-- 4. How many businesses are labelled as "Dry Cleaners" or “Dry Cleaning”?
SELECT count(DISTINCT bc.business_id)
FROM business_categorie as bc, categorie as c
WHERE bc.categorie_id = c.id and (c.name = 'Dry Cleaners' or c.name = 'Dry Cleaning');

-- 5. Find the overall number of reviews for all the businesses that have more than 150 reviews and have at least 2 (any 2) dietary restriction categories.
SELECT count(r)
FROM review AS r
WHERE r.business_id IN (
  SELECT b.id
  FROM business AS b, dietary_restrictions_business_relation AS drbr1,
     dietary_restrictions_business_relation AS drbr2
  WHERE b.review_count > 150 AND drbr1.business_id = drbr2.business_id AND b.id = drbr1.business_id
);

-- 6. Display the user id and the number of friends of the top 10 users by number of friends.
-- Order the results by the number of users descending (the user with the highest number of friends first).
-- In case there are multiple users with the same number of students, show only top 10.

--Validated
SELECT u.id, count(*)
FROM "user" as u, are_friends AS f
WHERE u.id = f.user_id_1 OR 
   u.id = f.user_id_2
GROUP BY u.id
ORDER BY count(*) DESC
LIMIT 10;

-- 7. Show the business name, number of stars, and the business review count of the top-5 businesses based on their review count that are currently open in the city of San Diego.
SELECT b.name, b.stars, b.review_count AS reviews
FROM business as b
where b.is_open = TRUE AND
   b.id in (
    SELECT bl.business_id
    FROM business_locations as bl, postal_code as pc, city as c
    WHERE bl.postal_code_id = pc.id AND pc.city_id = c.id AND c.name = 'San Diego'
   )
ORDER BY reviews DESC
LIMIT 5;

-- 8. Show the state name and the number of businesses for the state with the highest number of businesses.
SELECT s.name, count(bl.business_id)
FROM state AS s
INNER JOIN city AS c ON c.state_id = s.id
INNER JOIN postal_code as pc on pc.city_id = c.id
INNER JOIN business_locations as bl on bl.postal_code_id = pc.id
group by s.id
order by count(bl.business_id) desc
limit 1;

-- 9. Find the total average of “average star” of elite users, grouped by the year in which 
-- they started to be elite users. Display the required averages next to the appropriate years.
SELECT min(e.year), avg(u.average_stars)
FROM elite_years AS e
INNER JOIN "user" AS u ON u.id = e.user_id
GROUP BY e.year;

-- 10. List the names of the top-10 businesses based on the median “star” rating,
-- that are currently open in the city of New York.
SELECT b.name
FROM business as b
INNER JOIN business_locations as bl on bl.business_id = B.id
INNER JOIN postal_code as pc on pc.id = bl.postal_code_id
INNER JOIN city as c on c.id = pc.city_id
INNER JOIN review as r on r.business_id = b.id
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
FROM business as b
--join business with city
INNER JOIN business_locations as bl on bl.business_id = b.id
INNER JOIN postal_code as pc on pc.id = bl.postal_code_id
INNER JOIN city as c on c.id = pc.city_id
--join business with its parking attribute
INNER JOIN parking_business_relation AS pbr ON pbr.business_id = b.id
INNER JOIN business_parking AS bp ON bp.id = pbr.parking_id
--join business with its schedule on friday
INNER JOIN schedule AS s ON s.business_id = b.id
INNER JOIN "day" AS d on d.id = s.day_id
WHERE c.name = 'Las Vegas' AND
   bp.name = 'valet' AND
   d.name = 'Friday' AND
   s.start_at <= TIME '19:00' AND
   s.end_at >= TIME '23:00';
