sudo -u postgres psql

# Then run the following commands inside psql

\dt # to see tables
\c postgres
drop database introdb;
create database introdb;
\c introdb




\copy "user"(id,average_stars,compliment_cool,compliment_cute,compliment_funny,compliment_hot,compliment_list,compliment_more,compliment_note,compliment_photos,compliment_plain,compliment_profile,compliment_writer,cool,fans,funny,name,review_count,useful,yelping_since) FROM 'user.csv' DELIMITER ',' CSV HEADER;


\copy are_friends(user_id_2,user_id_1) FROM 'are_friends.csv' DELIMITER ',' CSV HEADER;

\copy elite_years(year,user_id) FROM 'elite_years.csv' DELIMITER ',' CSV HEADER;
