-- 1. What is the average review count over all the users?
SELECT avg(review_count)
FROM "user";

-- 2. How many businesses are in the provinces of Québec and Alberta?
-- false according to pandas
SELECT count(LR.business_id)
FROM business_locations as LR 
WHERE LR.postal_code_id IN (
    SELECT C.state_id 
    FROM city as C
    WHERE C.state_id in (
        SELECT S.id
        FROM state as S
        where S.name = 'AB' OR
              S.name = 'QC'
    )
);

SELECT count(BL.business_id)
FROM business_locations as BL
INNER JOIN postal_code AS pc on pc.id = bl.postal_code_id
INNER JOIN city as c on c.id = pc.city_id
INNER JOIN state as s on s.id = c.state_id
where S.name = 'AB' OR
      S.name = 'QC';

-- 3. What is the maximum number of categories assigned to a business? Show the business name and the previously described count.

SELECT B.id as BID, count(BC.categorie_id) AS results
FROM business AS B
LEFT JOIN business_categorie AS BC ON BC.business_id = B.id
GROUP BY B.id
ORDER BY results DESC
LIMIT 1;

-- 4. How many businesses are labelled as "Dry Cleaners" or “Dry Cleaning”?
SELECT count(DISTINCT BC.business_id)
FROM business_categorie as BC, categorie as C
WHERE BC.categorie_id = C.id and (C.name = 'Dry Cleaners' or C.name = 'Dry Cleaning');

-- 5. Find the overall number of reviews for all the businesses that have more than 150 reviews and have at least 2 (any 2) dietary restriction categories.
SELECT count(R)
FROM review AS R
WHERE R.business_id IN (
    SELECT B.id
    FROM business AS B, dietary_restrictions_business_relation AS DRBR1, 
         dietary_restrictions_business_relation AS DRBR2
    WHERE B.review_count > 150 AND DRBR1.business_id = DRBR2.business_id AND B.id = DRBR1.business_id         
);

-- 6. Display the user id and the number of friends of the top 10 users by number of friends.
-- Order the results by the number of users descending (the user with the highest number of friends first).
-- In case there are multiple users with the same number of students, show only top 10.

--Validated
SELECT U.id, count(*)
FROM "user" as U, are_friends AS F
WHERE U.id = F.user_id_1 OR 
      U.id = F.user_id_2
GROUP BY U.id
ORDER BY count(*) DESC
LIMIT 10;

-- 7. Show the business name, number of stars, and the business review count of the top-5 businesses based on their review count that are currently open in the city of San Diego.
SELECT B.name, B.stars, B.review_count AS reviews
FROM business as B
where B.is_open = TRUE AND
      B.id in (
        SELECT BL.business_id
        FROM business_locations as BL, postal_code as PC, city as C
        WHERE BL.postal_code_id = PC.id AND PC.city_id = C.id AND C.name = 'San Diego'
      )
ORDER BY reviews DESC
LIMIT 5;

-- 8. Show the state name and the number of businesses for the state with the highest number of businesses.
SELECT S.name, count(BL.business_id)
FROM state AS S
INNER JOIN city AS c ON c.state_id = s.id
INNER JOIN postal_code as PC on PC.city_id = c.id
INNER JOIN business_locations as BL on BL.postal_code_id = PC.id
group by S.id
order by count(BL.business_id) desc
limit 1;

-- 9. Find the total average of “average star” of elite users, grouped by the year in which 
-- they started to be elite users. Display the required averages next to the appropriate years.
SELECT min(E.year), avg(U.average_stars)
FROM elite_years AS E
INNER JOIN "user" AS U ON U.id = E.user_id
GROUP BY E.year;

-- 10. List the names of the top-10 businesses based on the median “star” rating,
-- that are currently open in the city of New York.
SELECT B.name
FROM business as B
INNER JOIN business_locations as BL on BL.business_id = B.id
INNER JOIN postal_code as PC on PC.id = BL.postal_code_id
INNER JOIN city as C on C.id = PC.city_id
INNER JOIN review as R on R.business_id = B.id
WHERE B.is_open = true AND C.name = 'New York'
GROUP BY B.name
ORDER BY (percentile_cont(0.5) WITHIN GROUP (ORDER BY R.stars)) DESC
LIMIT 10;

-- 11. Find and show the minimum, maximum, mean, and median number of categories per business. 
-- Show the final statistic (4 numbers respectively, aggregated over all the businesses).
SELECT min(results), max(results), avg(results), percentile_cont(0.5) WITHIN GROUP (ORDER BY results)
FROM (
    SELECT count(BC.categorie_id) AS results
    FROM business AS B
    LEFT JOIN business_categorie AS BC ON BC.business_id = B.id
    GROUP BY B.id
) AS categorie_amounts;


-- 12. Find the businesses (show 'name', 'stars', 'review count') 
-- in the city of Las Vegas possessing 'valet' parking and open 
-- between '19:00' and '23:00' hours on a Friday.
SELECT B.name, B.stars, B.review_count
FROM business as B
--join business with city
INNER JOIN business_locations as BL on BL.business_id = B.id
INNER JOIN postal_code as PC on PC.id = BL.postal_code_id
INNER JOIN city as C on C.id = PC.city_id
--join business with its parking attribute
INNER JOIN parking_business_relation AS PBR ON PBR.business_id = B.id
INNER JOIN business_parking AS BP ON BP.id = PBR.parking_id
--join business with its schedule on friday
INNER JOIN schedule AS S ON S.business_id = B.id
INNER JOIN "day" AS D on d.id = S.day_id
WHERE C.name = 'Las Vegas' AND
      BP.name = 'valet' AND
      D.name = 'Friday' AND
      S.start_at <= TIME '19:00' AND
      S.end_at >= TIME '23:00';
