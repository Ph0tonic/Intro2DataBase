CREATE TABLE "state" (
  "id" integer PRIMARY KEY,
  "name" CHAR(3) NOT NULL
);

CREATE TABLE city (
  "id" integer PRIMARY KEY,
  "state_id" integer NOT NULL REFERENCES "state"(id) ON DELETE CASCADE,
  "name" varchar
);

CREATE TABLE postal_code (
  "id" integer PRIMARY KEY,
  "city_id" integer NOT NULL REFERENCES "city"(id) ON DELETE CASCADE,
  "postal_code" varchar
);

CREATE TABLE noise_level (
  "id" integer PRIMARY KEY,
  "level" varchar NOT NULL
);

CREATE TABLE business (
  "id" integer PRIMARY KEY,

  "name" varchar NOT NULL,
  "is_open" boolean,

  "review_count" integer DEFAULT 0 CHECK ("review_count" >= 0),
  "stars" numeric(3, 2) DEFAULT NULL CHECK ("stars" >= 1 AND "stars" <= 5),

  "noise_level_id" integer REFERENCES "noise_level"(id) ON DELETE CASCADE
);

CREATE TABLE business_locations (
  "postal_code_id" integer NOT NULL REFERENCES "postal_code"(id) ON DELETE CASCADE,
  "business_id" integer UNIQUE NOT NULL REFERENCES "business"(id) ON DELETE CASCADE,

  PRIMARY KEY ("postal_code_id", "business_id"),

  "address" varchar,
  "latitude" float NOT NULL,
  "longitude" float NOT NULL
);

CREATE TABLE "user" (
  "id" integer PRIMARY KEY,

  "name" varchar NOT NULL,
  "yelping_since" date NOT NULL,
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
  "fans" integer NOT NULL DEFAULT 0 CHECK ("fans" >= 0),
  "funny" integer NOT NULL DEFAULT 0 CHECK ("funny" >= 0),
  "useful" integer NOT NULL DEFAULT 0 CHECK ("useful" >= 0),
  "average_stars" numeric(3, 2) DEFAULT NULL CHECK ("average_stars" >= 1 AND "average_stars" <= 5), 
  "review_count" integer NOT NULL DEFAULT 0 CHECK ("review_count" >= 0)
);

CREATE TABLE elite_years (
  "user_id" integer NOT NULL REFERENCES "user"(id) ON DELETE CASCADE,
  "year" INTEGER NOT NULL,

  PRIMARY KEY ("user_id", "year")
);

CREATE TABLE review (
  "id" integer,
  "user_id" integer NOT NULL REFERENCES "user"(id) ON DELETE CASCADE,
  "business_id" integer REFERENCES business(id) ON DELETE CASCADE,,

  PRIMARY KEY (business_id, user_id, id),

  "date" date NOT NULL,
  "text" text NOT NULL,
  "cool" integer NOT NULL DEFAULT 0 CHECK ("cool" >= 0),
  "funny" integer NOT NULL DEFAULT 0 CHECK ("funny" >= 0),
  "stars" integer NOT NULL CHECK ("stars" >= 1 AND "stars" <= 5),
  "useful" integer NOT NULL DEFAULT 0 CHECK ("useful" >= 0)
);

CREATE TABLE tip (
  "id" integer,
  "user_id" integer NOT NULL REFERENCES "user"(id) ON DELETE CASCADE,
  "business_id" integer NOT NULL REFERENCES business(id) ON DELETE CASCADE,,

  PRIMARY KEY (business_id, user_id, id),

  "date" date NOT NULL,
  "text" varchar NOT NULL,
  "compliment_count" integer NOT NULL DEFAULT 0 CHECK ("compliment_count" >= 0)
);

CREATE TABLE categorie (
  "id" integer PRIMARY KEY,
  "name" varchar NOT NULL
);

CREATE TABLE business_categorie (
  "business_id" integer NOT NULL REFERENCES business(id) ON DELETE CASCADE,
  "categorie_id" integer NOT NULL REFERENCES categorie(id) ON DELETE CASCADE,

  PRIMARY KEY (business_id, categorie_id)
);

CREATE TABLE music (
  "id" integer PRIMARY KEY,
  "name" varchar NOT NULL
);

CREATE TABLE music_business_relation (
  "business_id" integer REFERENCES business(id) ON DELETE CASCADE,
  "music_id" integer REFERENCES music(id) ON DELETE CASCADE,

  PRIMARY KEY (business_id, music_id)
);
/* Values :
  dj
  background_music
  no_music
  jukebox
  live
  video
  karaoke
*/

CREATE TABLE business_parking (
  "id" integer PRIMARY KEY,
  "name" varchar NOT NULL
);

CREATE TABLE parking_business_relation (
  "business_id" integer REFERENCES business(id) ON DELETE CASCADE,
  "parking_id" integer REFERENCES business_parking(id) ON DELETE CASCADE,

  PRIMARY KEY (business_id, parking_id)
);
/* Values :
  garage
  street
  validated
  lot
  valet
*/

CREATE TABLE ambience (
  "id" integer PRIMARY KEY,
  "name" varchar NOT NULL
);

CREATE TABLE ambience_business_relation (
  "business_id" integer REFERENCES business(id) ON DELETE CASCADE,
  "ambience_id" integer REFERENCES ambience(id) ON DELETE CASCADE,

  PRIMARY KEY (business_id, ambience_id)
);
/* Values :
  touristy
  hipster
  romantic
  divey
  intimate
  trendy
  upscale
  classy
  casual
*/

CREATE TABLE good_for_meal (
  "id" integer PRIMARY KEY,
  "name" varchar NOT NULL
);

CREATE TABLE good_for_meal_business_relation (
  "business_id" integer REFERENCES business(id) ON DELETE CASCADE,
  "good_for_meal_id" integer REFERENCES good_for_meal(id) ON DELETE CASCADE,

  PRIMARY KEY (business_id, good_for_meal_id)
);
/* Values :
  dessert
  latenight
  lunch
  dinner
  brunch
  breakfast
*/

CREATE TABLE dietary_restrictions (
  "id" integer PRIMARY KEY,
  "name" varchar NOT NULL
);

CREATE TABLE dietary_restrictions_business_relation (
  "business_id" integer REFERENCES business(id) ON DELETE CASCADE,
  "dietary_restrictions_id" integer REFERENCES dietary_restrictions(id) ON DELETE CASCADE,

  PRIMARY KEY (business_id, dietary_restrictions_id)
);
/* Values :
  dairy-free
  gluten-free
  vegan
  kosher
  halal
  soy-free
  vegetarian
*/

CREATE TABLE are_friends (
  "user_id_1" integer REFERENCES "user"(id),
  "user_id_2" integer REFERENCES "user"(id),

  PRIMARY KEY ("user_id_1", "user_id_2"),
  CONSTRAINT "user_id_1" check("user_id_1" <> "user_id_2"),
  CONSTRAINT "user_id_2" check("user_id_1" <> "user_id_2")
);

CREATE TABLE day (
  "id" integer PRIMARY KEY,
  "name" varchar NOT NULL
);

CREATE TABLE schedule (
  "business_id" integer REFERENCES business(id) ON DELETE CASCADE,
  "day_id" integer REFERENCES day(id) ON DELETE CASCADE,
  "start_at" time NOT NULL,
  "end_at" time NOT NULL,

  PRIMARY KEY ("business_id", "day_id")
);


/* Triggers */

CREATE FUNCTION friend_min_trigger() RETURNS trigger AS $friend_min_trigger$
  DECLARE
    min_user_id integer;
  BEGIN
    -- Qui travaille pour nous si la personne doit payer pour cela ?
    IF NEW.user_id_1 = NEW.user_id_2 THEN
      RAISE EXCEPTION '% A user cannot be friend with himself', NEW.user_id_1;
    END IF;

    IF NEW.user_id_1 > NEW.user_id_2 THEN
      min_user_id = NEW.user_id_2;
      NEW.user_id_2 = NEW.user_id_1;
      NEW.user_id_1 = min_user_id;
    END IF;

    RETURN NEW;
  END;
$friend_min_trigger$ LANGUAGE plpgsql;

CREATE TRIGGER friend_min_trigger BEFORE INSERT OR UPDATE ON are_friends
  FOR EACH ROW EXECUTE PROCEDURE friend_min_trigger();
