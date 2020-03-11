
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
  "id" integer PRIMARY KEY,
  "user_id" integer REFERENCES "user"(id),

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

  "dj" boolean NOT NULL,
  "background_music" boolean NOT NULL,
  "no_music" boolean NOT NULL,
  "jukebox" boolean NOT NULL,
  "live" boolean NOT NULL,
  "video" boolean NOT NULL,
  "karaoke" boolean NOT NULL,
);

CREATE TABLE business_parking (
  "id" integer PRIMARY KEY REFERENCES business(id),
  "garage" boolean NOT NULL,
  "street" boolean NOT NULL,
  "validated" boolean NOT NULL,
  "lot" boolean NOT NULL,
  "valet" boolean NOT NULL,
);

CREATE TABLE ambience (
  "id" integer PRIMARY KEY REFERENCES business(id),

  "touristy" boolean NOT NULL,
  "hipster" boolean NOT NULL,
  "romantic" boolean NOT NULL,
  "divey" boolean NOT NULL,
  "intimate" boolean NOT NULL,
  "trendy" boolean NOT NULL,
  "upscale" boolean NOT NULL,
  "classy" boolean NOT NULL,
  "casual" boolean NOT NULL,
);

CREATE TABLE good_for_meal (
  "id" integer PRIMARY KEY REFERENCES business(id),
  
  "dessert" boolean NOT NULL,
  "latenight" boolean NOT NULL,
  "lunch" boolean NOT NULL,
  "dinner" boolean NOT NULL,
  "brunch" boolean NOT NULL,
);

CREATE TABLE dietary_restrictions (
  "id" integer PRIMARY KEY REFERENCES business(id),

  "dairy-free" boolean NOT NULL,
  "gluten-free" boolean NOT NULL,
  "vegan" boolean NOT NULL,
  "kosher" boolean NOT NULL,
  "halal" boolean NOT NULL,
  "soy-free" boolean NOT NULL,
  "vegetarian" boolean NOT NULL,
);


/* TODO Horaires */
/* TODO Friends */