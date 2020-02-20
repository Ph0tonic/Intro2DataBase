
CREATE TABLE county (
  "id" integer PRIMARY KEY,

  "name" varchar
);

CREATE TABLE city (
  "id" integer PRIMARY KEY,
  "state_id" integer REFERENCES county(id),

  "name" varchar,
  "code" varchar
);

CREATE TABLE user (
  "id" int PRIMARY KEY,
  "user_id" integer REFERENCES user(id),
  "business_id" integer REFERENCES business(id),

  "name" varchar,
  "yelping_since" date,
  "compliment_count" integer,
  "compliment_cool" integer,
  "compliment_cute" integer,
  "compliment_funny" integer,
  "compliment_hot" integer,
  "compliment_list" integer,
  "compliment_more" integer,
  "compliment_note" integer,
  "compliment_photos" integer,
  "compliment_plain" integer,
  "compliment_profile" integer,
  "compliment_writer" integer,
  "cool" integer,
  "elite" integer,
  "fans" integer,
  "funny" integer,
  "useful" integer,
  "average_stars" integer,
  "review_count" integer
);

CREATE TABLE business (
  "id" integer  PRIMARY KEY,
  "city_id" integer REFERENCES city(id),

  "name" varchar,
  "address" varchar,
  "is_open" boolean,
  "latitude" varchar,
  "longitude" varchar,

  /* TODO Computed */
  "review_count" integer,
  "stars" integer
);

CREATE TABLE review (
  "id" integer  PRIMARY KEY,
  "user_id" integer REFERENCES user(id),
  "business_id" integer REFERENCES business(id),

  "date" date,
  "text" varchar,
  "cool" integer,
  "funny" integer,
  "stars" integer,
  "useful" integer
);

CREATE TABLE tip (
  "id" integer  PRIMARY KEY,
  "user_id" integer REFERENCES user(id),
  "business_id" integer REFERENCES business(id),

  "date" date,
  "text" varchar,
  "compliment_count" integer
);

CREATE TABLE business_categorie (
  "business_id" integer ,
  "categorie_id" integer,

  PRIMARY KEY (business_id,categorie_id)
);

CREATE TABLE categorie (
  "id" int PRIMARY KEY,
  "name" varchar,
);

/* TODO Horraires */

/* Attributes */
/*
- NoiseLevel
  - quiet
  - average
  - u'quiet
  - u'average
  - u'loud
  - u'very_loud
- Music
  - dj
  - background_music
  - no_music
  - jukebox
  - live
  - video
  - karaoke
- BusinessParking
  - garage
  - street
  - validated
  - lot
  - valet
- Ambience
  - touristy
  - hipster
  - romantic'
  - divey
  - intimate
  - trendy
  - upscale
  - classy
  - casual
- GoodForMeal
  - dessert
  - latenight
  - lunch
  - dinner
  - brunch
  - breakfast
- DietaryRestrictions
  - dairy-free
  - gluten-free
  - vegan
  - kosher
  - halal
  - soy-free
  - vegetarian
*/