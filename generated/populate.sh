#create the database
sudo -u postgres psql <<EOF
drop database introdb;
create database introdb;
\q
EOF
#create the tables
sudo -u postgres psql -d introdb -f ../creation.sql

#populate the tables
sudo -u postgres psql -d introdb <<EOF

\copy "state"(id,name) FROM 'state.csv' DELIMITER ',' CSV HEADER;
\copy city(id,state_id,name) FROM 'city.csv' DELIMITER ',' CSV HEADER;
\copy postal_code(id,city_id,postal_code) FROM 'city.csv' DELIMITER ',' CSV HEADER;
\copy noise_level(id,level) FROM 'noise_level.csv' DELIMITER ',' CSV HEADER;
\copy business(id,name,is_open,review_count,stars,noise_level_id) FROM 'business.csv' DELIMITER ',' CSV HEADER;
\copy business_locations(postal_code_id,business_id,address,latitude,longitude) FROM 'business_locations.csv' DELIMITER ',' CSV HEADER;

\copy "user"(id,average_stars,compliment_cool,compliment_cute,compliment_funny,compliment_hot,compliment_list,compliment_more,compliment_note,compliment_photos,compliment_plain,compliment_profile,compliment_writer,cool,fans,funny,name,review_count,useful,yelping_since) FROM 'user.csv' DELIMITER ',' CSV HEADER;
\copy elite_years(year,user_id) FROM 'elite_years.csv' DELIMITER ',' CSV HEADER;
\copy are_friends(user_id_2,user_id_1) FROM 'are_friends.csv' DELIMITER ',' CSV HEADER;

\copy review(id,user_id,business_id,date,text,cool,funny,stars,useful) FROM 'review.csv' DELIMITER ',' CSV HEADER;
\copy tip(id,user_id,business_id,date,text,compliment_count) FROM 'tip.csv' DELIMITER ',' CSV HEADER;

\copy categorie(id,name) FROM 'categorie.csv' DELIMITER ',' CSV HEADER;
\copy music(id,name) FROM 'music.csv' DELIMITER ',' CSV HEADER;
\copy business_parking(id,name) FROM 'business_parking.csv' DELIMITER ',' CSV HEADER;
\copy ambience(id,name) FROM 'ambience.csv' DELIMITER ',' CSV HEADER;
\copy good_for_meal(id,name) FROM 'good_for_meal.csv' DELIMITER ',' CSV HEADER;
\copy dietary_restructions(id,name) FROM 'dietary_restructions.csv' DELIMITER ',' CSV HEADER;

\copy business_categorie(business_id,categorie_ic) FROM 'categorie.csv' DELIMITER ',' CSV HEADER;
\copy music_business_relation(business_id,music_id) FROM 'music.csv' DELIMITER ',' CSV HEADER;
\copy parking_business_relation(business_id,parking_id) FROM 'business_parking.csv' DELIMITER ',' CSV HEADER;
\copy ambience_business_relation(business_id,ambience_id) FROM 'ambience.csv' DELIMITER ',' CSV HEADER;
\copy good_for_meal_business_relation(business_id,good_for_meal_id) FROM 'good_for_meal.csv' DELIMITER ',' CSV HEADER;
\copy dietary_restrictions_business_relation(business_id,dietary_restrictions_id) FROM 'dietary_restructions.csv' DELIMITER ',' CSV HEADER;


\copy day(id,name) FROM 'day.csv' DELIMITER ',' CSV HEADER;
\copy schedule(business_id,day_id,start_at,end_at) FROM 'schedule.csv' DELIMITER ',' CSV HEADER;


EOF
