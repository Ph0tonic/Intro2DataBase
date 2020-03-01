
CREATE TABLE "state" (
  "id" integer PRIMARY KEY,

  "name" varchar
);

CREATE TABLE city (
  "id" integer PRIMARY KEY,
  "state_id" integer REFERENCES "state"(id),

  "name" varchar,
  "code" varchar
);

CREATE TABLE "user" (
  "id" int PRIMARY KEY,
  "user_id" integer REFERENCES "user"(id),
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
  "id" integer PRIMARY KEY,
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
  "id" integer PRIMARY KEY,
  "user_id" integer REFERENCES "user"(id),
  "business_id" integer REFERENCES business(id),

  "date" date,
  "text" varchar,
  "cool" integer,
  "funny" integer,
  "stars" integer,
  "useful" integer
);

CREATE TABLE tip (
  "id" integer PRIMARY KEY,
  "user_id" integer REFERENCES "user"(id),
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

CREATE TABLE noise_level (
  "id" integer PRIMARY KEY,
  "level" varchar,
);

CREATE TABLE categorie (
  "id" integer PRIMARY KEY,
  "name" varchar,
);

CREATE TABLE music (
  "id" integer PRIMARY KEY REFERENCES business(id),

  "dj" boolean,
  "background_music" boolean,
  "no_music" boolean,
  "jukebox" boolean,
  "live" boolean,
  "video" boolean,
  "karaoke" boolean,
);

CREATE TABLE business_parking (
  "id" integer PRIMARY KEY REFERENCES business(id),
  "garage" boolean,
  "street" boolean,
  "validated" boolean,
  "lot" boolean,
  "valet" boolean,
);

CREATE TABLE ambience (
  "id" integer PRIMARY KEY REFERENCES business(id),

  "touristy" boolean,
  "hipster" boolean,
  "romantic" boolean,
  "divey" boolean,
  "intimate" boolean,
  "trendy" boolean,
  "upscale" boolean,
  "classy" boolean,
  "casual" boolean,
);

CREATE TABLE good_for_meal (
  "id" integer PRIMARY KEY REFERENCES business(id),
  
  "dessert" boolean,
  "latenight" boolean,
  "lunch" boolean,
  "dinner" boolean,
  "brunch" boolean,
);

CREATE TABLE dietary_restrictions (
  "id" integer PRIMARY KEY REFERENCES business(id),

  "dairy-free" boolean,
  "gluten-free" boolean,
  "vegan" boolean,
  "kosher" boolean,
  "halal" boolean,
  "soy-free" boolean,
  "vegetarian" boolean,
);


/* TODO Horaires */
/* TODO Friends */