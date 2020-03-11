
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
  "business_id" integer,
  "categorie_id" integer,

  PRIMARY KEY (business_id, categorie_id)
);

CREATE TABLE noise_level (
  "id" integer PRIMARY KEY,
  "level" varchar NOT NULL,
);

CREATE TABLE categorie (
  "id" integer PRIMARY KEY,
  "name" varchar NOT NULL,
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

CREATE TABLE are_friends (
  "user_id_1" integer REFERENCES "user"(id),
  "user_id_2" integer REFERENCES "user"(id),

  PRIMARY KEY ("user_id_1", "user_id_2"),
);
ALTER TABLE are_friends ADD CONSTRAINT "user_id_1" check("user_id_1" <> "user_id_2");
ALTER TABLE are_friends ADD CONSTRAINT "user_id_2" check("user_id_1" <> "user_id_2");

CREATE TABLE day (
  "id" integer PRIMARY KEY,
  "name" varchar NOT NULL
);

CREATE TABLE schedule (
  "id" integer NOT NULL UNIQUE, 
  "business_id" integer REFERENCES business(id),
  "day_id" integer REFERENCES day(id),
  "start_at" time NOT NULL,
  "end_at" time NOT NULL,

  PRIMARY KEY ("id", "business_id", "day_id"),
);
