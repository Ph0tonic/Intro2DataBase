
CREATE TABLE "state" (
  "id" integer PRIMARY KEY,

  "name" varchar NOT NULL
);

CREATE TABLE city (
  "id" integer PRIMARY KEY,
  "state_id" integer NOT NULL REFERENCES "state"(id),

  "name" varchar NOT NULL,
  "code" varchar NOT NULL
);

CREATE TABLE "user" (
  "id" integer PRIMARY KEY,

  "name" varchar UNIQUE NOT NULL,
  "yelping_since" date,
  "compliment_count" integer NOT NULL DEFAULT 0 CHECK ("compliment_count" >= 0),
  "compliment_cool" integer NOT NULL DEFAULT 0 CHECK ("compliment_cool" >= 0),
  "compliment_cute" integer NOT NULL DEFAULT 0 CHECK ("compliment_cute" >= 0),
  "compliment_funny" integer NOT NULL DEFAULT 0 CHECK ("compliment_funny" >= 0),
  "compliment_hot" integer NOT NULL DEFAULT 0 CHECK ("compliment_hot" >= 0),
  "compliment_list" integer NOT NULL DEFAULT 0 CHECK ("compliment_list" >= 0),
  "compliment_more" integer NOT NULL DEFAULT 0 CHECK ("compliment_more" >= 0),
  "compliment_note" integer NOT NULL DEFAULT 0 CHECK ("compliment_note" >= 0),
  "compliment_photos" integer NOT NULL DEFAULT 0 CHECK ("compliment_photos" >= 0),
  "compliment_plain" integer NOT NULL DEFAULT 0 CHECK ("compliment_plain" >= 0),
  "compliment_profile" integer NOT NULL DEFAULT 0 CHECK ("compliment_profile" >= 0),
  "compliment_writer" integer NOT NULL DEFAULT 0 CHECK ("compliment_writer" >= 0),
  "cool" integer NOT NULL DEFAULT 0 CHECK ("cool" >= 0),
  "elite" integer NOT NULL DEFAULT 0 CHECK ("elite" >= 0),
  "fans" integer NOT NULL DEFAULT 0 CHECK ("fans" >= 0),
  "funny" integer NOT NULL DEFAULT 0 CHECK ("funny" >= 0),
  "useful" integer NOT NULL DEFAULT 0 CHECK ("useful" >= 0),
  "average_stars" numeric(3, 2) DEFAULT NULL CHECK ("average_stars" >= 1 AND "average_stars" <= 5), 
  "review_count" integer NOT NULL DEFAULT 0 CHECK ("review_count" >= 0)
);

CREATE TABLE business (
  "id" integer PRIMARY KEY,
  "city_id" integer NOT NULL REFERENCES city(id),

  "name" varchar NOT NULL,
  "address" varchar NOT NULL,
  "is_open" boolean,
  "latitude" varchar NOT NULL,
  "longitude" varchar NOT NULL,

  /* TODO Computed */
  "review_count" integer DEFAULT 0 CHECK ("review_count" >= 0),
  "stars" numeric(3, 2) DEFAULT NULL CHECK ("average_stars" >= 1 AND "average_stars" <= 5)
);

CREATE TABLE review (
  "id" integer PRIMARY KEY,
  "user_id" integer NOT NULL REFERENCES "user"(id),
  "business_id" integer NOT NULL REFERENCES business(id),

  "date" date NOT NULL,
  "text" varchar NOT NULL,
  "cool" integer NOT NULL DEFAULT 0 CHECK ("cool" >= 0),
  "funny" integer NOT NULL DEFAULT 0 CHECK ("funny" >= 0),
  "stars" integer NOT NULL CHECK ("average_stars" >= 1 AND "average_stars" <= 5),
  "useful" integer NOT NULL DEFAULT 0 CHECK ("useful" >= 0)
);

ALTER TABLE 

CREATE TABLE tip (
  "id" integer PRIMARY KEY,
  "user_id" integer NOT NULL REFERENCES "user"(id),
  "business_id" integer NOT NULL REFERENCES business(id),

  "date" date NOT NULL,
  "text" varchar NOT NULL,
  "compliment_count" integer NOT NULL DEFAULT 0 CHECK ("compliment_count" >= 0)
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

CREATE TABLE are_friends (
  "user_id_1" integer REFERENCES "user"(id),
  "user_id_2" integer REFERENCES "user"(id),
  PRIMARY KEY ("user_id_1", "user_id_2"),
);
ALTER TABLE are_friends ADD CONSTRAINT "user_id_1" check("user_id_1" <> "user_id_2");
ALTER TABLE are_friends ADD CONSTRAINT "user_id_2" check("user_id_1" <> "user_id_2");

/* TODO Horaires */