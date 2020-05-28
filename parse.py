import numpy as np
import pandas as pd
import ast
import geopandas as gpd
import geopy
import re
import math
from tqdm import tqdm
tqdm.pandas()

generic = lambda x: ast.literal_eval(x)
conv = {'friends': generic}

business = pd.read_csv('csv_files/yelp_academic_dataset_business.csv')
review = pd.read_csv('csv_files/yelp_academic_dataset_review.csv')
tip = pd.read_csv('csv_files/yelp_academic_dataset_tip_transposed.csv')
user = pd.read_csv('csv_files/yelp_academic_dataset_user.csv',converters=conv)

business.index += 1
review.index += 1
tip.index += 1
user.index += 1

# Parse user
excluded_user = user[(user.name.isna())]
included_user = user[~(user.name.isna())]
user_ids = included_user['user_id'].reset_index().set_index('user_id')['index'].to_dict()
friends = included_user['friends'].progress_map(lambda friends: list(filter(lambda x: not x is None, map(lambda x: user_ids.get(x,None),friends))))
elite = included_user[included_user['elite'].progress_map(lambda x:type(x))==str]['elite'].map(lambda e:list(map(lambda x:int(x),e.split(","))))
del included_user["user_id"]
del included_user["friends"]
del included_user["elite"]
user_table = included_user.reset_index().rename(columns={'index':'id'})
user_table.to_csv('generated/user.csv', index=False)

user_temp2 = pd.read_csv('csv_files/yelp_academic_dataset_user.csv',converters=conv)

# Parse friends
friends_temp=friends.reset_index().rename(columns={'index':'id'})
chunks = np.array_split(friends_temp, 100000)

processed = []
for chunk in tqdm(chunks):
    processed.append(chunk['friends']
        .apply(lambda x: pd.Series(x))
        .stack()
        .reset_index(level=1, drop=True)
        .to_frame('friends')
        .join(chunk[['id']], how='left')
    )

friends_table = pd.concat(processed)
friends_table["friends"] = friends_table["friends"].astype(int)
friends_table=friends_table.rename(columns={'id':'user_id_1'})
friends_table=friends_table.rename(columns={'friends':'user_id_2'})

friends_table['user_id_1'], friends_table['user_id_2'] = friends_table.min(axis=1), friends_table.max(axis=1)
friends_table.drop_duplicates(inplace=True)

friends_table.to_csv('generated/are_friends.csv', index=False)

# Parse Elite years
elite_temp = elite.reset_index().rename(columns={'index':'user_id'})

elite_table = (elite_temp['elite'].progress_apply(lambda x: pd.Series(x))
   .stack()
   .reset_index(level=1, drop=True)
   .to_frame('elite')
   .join(elite_temp[['user_id']], how='left'))

elite_table["elite"] = elite_table["elite"].astype(int)
elite_table = elite_table.rename(columns={'elite':'year'})

elite_table.to_csv('generated/elite_years.csv', index=False)

# Parse business
business_ids = business["business_id"].reset_index().set_index("business_id")["index"].to_dict()
del business["business_id"]
business_table = business.reset_index().rename(columns={'index':'id'})

# Clean cities
def clean_city_name(b):
    temp = re.sub(r'\([^)]*\)', '', b.city) # Remove parenthesis and content
    temp = re.sub(' - ', '-', temp) # Remove dash with spaces
    temp = temp.lower()
    temp = temp.strip().rstrip(',').strip().rstrip(b.state.lower()).strip().rstrip(',').strip()
    
    # Some more specific rules for thoses data
    temp = re.sub(r'^n ', 'North ', temp) # Convert city starting with a single N into North
    temp = re.sub(r'^n\. ', 'North ', temp) # Convert city starting with a single N into North
    temp = re.sub(r'^[scw] ', '', temp) # Useless single character for this dataset
    temp = re.sub('las vergas', 'las vegas', temp) # City with name Las Vergas
    temp = re.sub('110 las vegas', 'las vegas', temp) # City with name Las Vergas
    temp = re.sub('ii', 'i', temp) # City with duplicates i do not exist in english
    temp = re.sub('metro are', '', temp) # Phoenix has some strange variants with metro are
    temp = re.sub('metro', '', temp) # Same but preceeded by metro
    temp = re.sub('phoenx', 'phoenix', temp) # Same but preceeded by metro
    
    # Fix Montreal specificity
    temp = re.sub('montreal-ouest', 'montreal', temp)
    temp = re.sub('montreal-west', 'montreal', temp)
    temp = re.sub('montreal-nord', 'montreal', temp)
    temp = re.sub('montreal-est', 'montreal', temp)
    temp = re.sub('montreal-quest', 'montreal', temp)
    
    temp = re.sub('ste-', 'sainte-', temp)
    temp = re.sub('st-', 'saint-', temp)
    temp = re.sub('saint-léonard', 'saint-leonard', temp)
    temp = re.sub('st. léonard', 'saint-leonard', temp)
    temp = re.sub('st. leonard', 'saint-leonard', temp)
    
    temp = re.sub('st.pittsburgh', 'pittsburgh', temp)
    temp = re.sub('chomedey, laval', 'laval', temp)
    
    temp = re.sub('mt\.', 'mount', temp)
    temp = re.sub('mt', 'mount', temp)
    
    # Remove second part if comma + remove duplicates spaces
    temp = temp.split(',', 1)[0]
    temp = " ".join(temp.title().split())
    return temp

business_table.loc[~business_table.city.isna(),'city'] = business_table[~business_table.city.isna()].progress_apply(clean_city_name, axis=1)
business_table[~business_table.city.isna()].progress_apply(clean_city_name, axis=1)



# Fix business postal_code and city
# Locators used
locator = Nominatim(user_agent="myGeocoder",timeout=3)
location = locator.reverse("36.169710,-115.123695")
mapQuestLocator=geopy.geocoders.OpenMapQuest("StxlGpGLb5EapoCXFQBf6GroFDOZTBJj",timeout=3)
location=coder.reverse("36.169710,-115.123695")
openCageLocator=geopy.geocoders.OpenCage("71ef46faea4b4e198a0891d79714905b",timeout=3)
location=coder.reverse("36.169710,-115.123695")
googleLocator=geopy.geocoders.GoogleV3(api_key=YOUR_API_KEY) # TODO: Add your own GOOGLE API Key

def get_postal_code(data):
    coordinates = f'{data.latitude},{data.longitude}'
    location = mapQuestLocator.reverse(coordinates)
    if location.raw.get("address").get("postcode") == None:
        location = locator.reverse(coordinates)
    return location.raw.get("address").get("postcode")

def get_postal_code_v2(data):
    coordinates = f'{data.latitude},{data.longitude}'
    location = googleLocator.reverse(coordinates)
    return list(filter(lambda l:l.get("types")[0]=="postal_code",location[0].raw.get("address_components")))[0].get("long_name")


def get_city_name(data):
    coordinates = f'{data.latitude},{data.longitude}'
    location = locator.reverse(coordinates)
    if location.raw.get("address").get("city") == None:
        location=mapQuestLocator.reverse(coordinates)
    return location.raw.get("address").get("city",np.NaN)


def get_address(data):
    coordinates = f'{data.latitude},{data.longitude}'
    location = locator.reverse(coordinates)
    if location.raw.get("address").get("road") == None or location.raw.get("neighbourhood") == None:
        location=mapQuestLocator.reverse(coordinates)
    return location.raw.get("address").get("road", location.raw.get("address").get("neighbourhood", np.NaN))


def format_google_maps_res(locs):
    res=None
    route=list(filter(lambda x: x.get("types")[0]=="route", locs.get("address_components")))
    nb=list(filter(lambda x: x.get("types")[0]=="street_number", locs.get("address_components")))
    neighborhood=list(filter(lambda x: x.get("types")[0]=="neighborhood", locs.get("address_components")))
    if(len(route)>0):
        res=route[0].get("long_name")
    if(not res == None and len(nb)>0):
        res=res+" "+nb[0].get("long_name")
    if(res == None and len(neighborhood)>0):
        res=neighborhood[0].get("long_name")
    return res

def get_address_v2(data):
    coordinates = f'{data.latitude},{data.longitude}'
    locations = googleLocator.reverse(coordinates)
    res=format_google_maps_res(locations[0].raw)
    if res == None and len(locations)>0:
        res=format_google_maps_res(locations[1].raw)
    return res

business_table.loc[business_table.postal_code.isna(),'postal_code'] = business_table[business_table.postal_code.isna()].progress_apply(get_postal_code, axis=1)
business_table.loc[business_table.city.isna(),'city'] = business_table[business_table.city.isna()].progress_apply(get_city_name, axis=1)
business_table.loc[business_table.address.isna(),'address'] = business_table[business_table.address.isna()].progress_apply(get_address, axis=1)
business_table.loc[business_table.postal_code.isna(),'postal_code'] = business_table[business_table.postal_code.isna()].progress_apply(get_postal_code_v2, axis=1)
business_table.loc[business_table.address.isna(),'address'] = business_table[business_table.address.isna()].progress_apply(get_address_v2, axis=1)

# Parse Locations
locations = business_table[["id", "address", "city", "latitude", "longitude", "postal_code", "state"]]
del business_table["address"]
del business_table["city"]
del business_table["latitude"]
del business_table["longitude"]
del business_table["postal_code"]
del business_table["state"]
locations = locations.rename(columns={'id':'business_id'})

# States
state_table = locations["state"].drop_duplicates()
state_table = state_table.sort_values().reset_index()
state_table.index += 1
del state_table["index"]
state_table = state_table.reset_index().rename(columns={"index":"id", "state": "name"})

state_dict = state_table.set_index("name")["id"].to_dict()
locations["state_id"] = locations["state"].progress_apply(lambda s: state_dict[s])
del locations["state"]

# Cities
city_table = locations[["city", "state_id"]].drop_duplicates()
city_table = city_table.reset_index()
del city_table["index"]
city_table.index += 1
city_table = city_table.reset_index()
city_table = city_table.rename(columns={"index":"id", "city":"name"})
city_dict = city_table.set_index(["name", "state_id"])["id"].to_dict()
locations["city_id"] = locations[["city", "state_id"]].progress_apply(lambda row: city_dict[(row[0], row[1])], axis=1, raw=True)
del locations["state_id"]
del locations["city"]

# Postal codes
postal_codes_table = locations[["city_id", "postal_code"]].drop_duplicates()
postal_codes_table = postal_codes_table.reset_index()
del postal_codes_table["index"]
postal_codes_table.index += 1
postal_codes_table = postal_codes_table.reset_index().rename(columns={"index":"id"})
postal_code_dict = postal_codes_table.set_index(["postal_code", "city_id"])["id"].to_dict()
locations["postal_code_id"] = locations[["postal_code", "city_id"]].progress_apply(lambda row: postal_code_dict[(row[0], row[1])], axis=1, raw=True)
del locations["city_id"]
del locations["postal_code"]

# Parse categories
business_categories_temp = business_table[["id", "categories"]][business_table["categories"].progress_map(lambda x: type(x) == str)]
business_categories_temp["categories"] = business_categories_temp["categories"].progress_map(lambda cats: list(map(str.strip, cats.split(","))))
business_categories = (business_categories_temp['categories']
    .progress_apply(lambda x: pd.Series(x))
    .stack()
    .reset_index(level=1, drop=True)
    .to_frame('categories')
    .join(business_categories_temp[['id']], how='left'))
categories = business_categories["categories"]
categories = categories.drop_duplicates().reset_index()
del categories["index"]
categories.index += 1
categories = categories.reset_index().rename(columns={"index":"id", "categories": "name"})
categories.index += 1
categories_dict = categories.reset_index().set_index("name")["index"].to_dict()
business_categories["categorie_id"] = business_categories["categories"].progress_map(lambda cat: categories_dict[cat])
del business_categories["categories"]
del business_table["categories"]
business_categories = business_categories.rename(columns={"id":"business_id"}).drop_duplicates()

# Parse attributes
attributes = business[business["attributes"].map(lambda x: type(x)==str)]["attributes"].progress_apply(eval)
del business_table["attributes"]

# Noise level
noise_level_temp = attributes[attributes.map(lambda x: "NoiseLevel" in x)].map(lambda x: eval(x["NoiseLevel"]))
noise_level = noise_level_temp.drop_duplicates().reset_index()
del noise_level["index"]
noise_level.index += 1
noise_level = noise_level.reset_index().rename(columns={"index":"id", "attributes":"level"})
noise_level_dict = noise_level.set_index("level")["id"].to_dict()
business_table["noise_level_id"] = noise_level_temp.map(lambda x: noise_level_dict[x])
#uses that NaN != NaN
business_table["noise_level_id"] = business_table["noise_level_id"].apply(lambda x: int(x) if x == x else "")
#ugly but working for now
business_table["noise_level_id"] = business_table["noise_level_id"].apply(lambda x: x if x != 5 else "")
noise_level = noise_level.dropna()

# Music
music_temp = attributes[attributes.map(lambda x: "Music" in x)].map(lambda x: eval(x["Music"]))
music_temp = music_temp[music_temp.map(lambda x: x != None)]
music_temp = music_temp.progress_map(lambda m: [key for key in m.keys() if m[key]])
music_temp = music_temp[music_temp.map(lambda l: len(l) > 0)].reset_index().rename(columns={"index":"business_id", "attributes":"name"})
music_business_relation_table = (music_temp['name']
    .progress_apply(lambda x: pd.Series(x))
    .stack()
    .reset_index(level=1, drop=True)
    .to_frame('name')
    .join(music_temp[['business_id']], how='left'))

music_table = music_business_relation_table["name"].drop_duplicates().reset_index()
del music_table["index"]
music_table.index += 1
music_table = music_table.reset_index().rename(columns={"index":"id"})
music_dict = music_table.set_index("name")["id"].to_dict()
music_business_relation_table["music_id"] = music_business_relation_table["name"].map(lambda x: music_dict[x])
del music_business_relation_table["name"]

# Business parking 
parking_temp = attributes[attributes.map(lambda x: "BusinessParking" in x)].map(lambda x: eval(x["BusinessParking"]))
parking_temp = parking_temp[parking_temp.map(lambda x: x != None)]
parking_temp = parking_temp.progress_map(lambda m: [key for key in m.keys() if m[key]])
parking_temp = parking_temp[parking_temp.map(lambda l: len(l) > 0)].reset_index().rename(columns={"index":"business_id", "attributes":"name"})
parking_business_relation_table = (parking_temp['name']
    .progress_apply(lambda x: pd.Series(x))
    .stack()
    .reset_index(level=1, drop=True)
    .to_frame('name')
    .join(parking_temp[['business_id']], how='left'))
business_parking_table = parking_business_relation_table["name"].drop_duplicates().reset_index()
business_parking_table.index += 1
del business_parking_table["index"]
business_parking_table = business_parking_table.reset_index().rename(columns={"index":"id"})
parking_dict = business_parking_table.set_index("name")["id"].to_dict()
parking_business_relation_table["parking_id"] = parking_business_relation_table["name"].map(lambda x: parking_dict[x])
del parking_business_relation_table["name"]

# Ambience
ambience_temp = attributes[attributes.map(lambda x: "Ambience" in x)].map(lambda x: eval(x["Ambience"]))
ambience_temp = ambience_temp[ambience_temp.map(lambda x: x != None)]
ambience_temp = ambience_temp.progress_map(lambda m: [key for key in m.keys() if m[key]])
ambience_temp = ambience_temp[ambience_temp.map(lambda l: len(l) > 0)].reset_index().rename(columns={"index":"business_id", "attributes":"name"})
ambience_business_relation_table = (ambience_temp['name']
    .progress_apply(lambda x: pd.Series(x))
    .stack()
    .reset_index(level=1, drop=True)
    .to_frame('name')
    .join(ambience_temp[['business_id']], how='left'))
ambience_table = ambience_business_relation_table["name"].drop_duplicates().reset_index()
ambience_table.index += 1
del ambience_table["index"]
ambience_table = ambience_table.reset_index().rename(columns={"index":"id"})
ambience_dict = ambience_table.set_index("name")["id"].to_dict()
ambience_business_relation_table["ambience_id"] = ambience_business_relation_table["name"].map(lambda x: ambience_dict[x])
del ambience_business_relation_table["name"]

# ## Good for meal
good_for_meal_temp = attributes[attributes.map(lambda x: "GoodForMeal" in x)].map(lambda x: eval(x["GoodForMeal"]))
good_for_meal_temp = good_for_meal_temp[good_for_meal_temp.map(lambda x: x != None)]
good_for_meal_temp = good_for_meal_temp.progress_map(lambda m: [key for key in m.keys() if m[key]])
good_for_meal_temp = good_for_meal_temp[good_for_meal_temp.map(lambda l: len(l) > 0)].reset_index().rename(columns={"index":"business_id", "attributes":"name"})
good_for_meal_business_relation_table = (good_for_meal_temp['name']
    .progress_apply(lambda x: pd.Series(x))
    .stack()
    .reset_index(level=1, drop=True)
    .to_frame('name')
    .join(good_for_meal_temp[['business_id']], how='left'))
good_for_meal_table = good_for_meal_business_relation_table["name"].drop_duplicates().reset_index()
good_for_meal_table.index += 1
del good_for_meal_table["index"]
good_for_meal_table = good_for_meal_table.reset_index().rename(columns={"index":"id"})
good_for_meal_dict = good_for_meal_table.set_index("name")["id"].to_dict()
good_for_meal_business_relation_table["ambience_id"] = good_for_meal_business_relation_table["name"].map(lambda x: good_for_meal_dict[x])
del good_for_meal_business_relation_table["name"]
# dietary restrictions
dietary_restrictions_temp = attributes[attributes.map(lambda x: "DietaryRestrictions" in x)].map(lambda x: eval(x["DietaryRestrictions"]))
dietary_restrictions_temp = dietary_restrictions_temp[dietary_restrictions_temp.map(lambda x: x != None)]
dietary_restrictions_temp = dietary_restrictions_temp.progress_map(lambda m: [key for key in m.keys() if m[key]])
dietary_restrictions_temp = dietary_restrictions_temp[dietary_restrictions_temp.map(lambda l: len(l) > 0)].reset_index().rename(columns={"index":"business_id", "attributes":"name"})
dietary_restrictions_business_relation_table = (dietary_restrictions_temp['name']
    .progress_apply(lambda x: pd.Series(x))
    .stack()
    .reset_index(level=1, drop=True)
    .to_frame('name')
    .join(dietary_restrictions_temp[['business_id']], how='left'))
dietary_restrictions_table = dietary_restrictions_business_relation_table["name"].drop_duplicates().reset_index()
dietary_restrictions_table.index += 1
del dietary_restrictions_table["index"]
dietary_restrictions_table = dietary_restrictions_table.reset_index().rename(columns={"index":"id"})
dietary_restrictions_dict = dietary_restrictions_table.set_index("name")["id"].to_dict()
dietary_restrictions_business_relation_table["dietary_restrictions_id"] = dietary_restrictions_business_relation_table["name"].map(lambda x: dietary_restrictions_dict[x])
del dietary_restrictions_business_relation_table["name"]

# Parse schedule
schedule_temp = business["hours"]
del business_table["hours"]
schedule_temp = schedule_temp[schedule_temp.map(lambda x: type(x) == str)].progress_map(eval)
days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
day_table = pd.DataFrame(days, columns=["name"])
day_table.index += 1
day_table = day_table.reset_index().rename(columns={"index": "id"})
day_dict = day_table.set_index("name")["id"].to_dict()

def schedules_on(day):
    temp = schedule_temp[schedule_temp.map(lambda m: day in m)].progress_map(lambda m: m[day]).reset_index().rename(columns={"index": "business_id"})
    temp["day_id"] = day_dict[day]
    temp["start_at"] = temp["hours"].map(lambda s: s.split("-")[0])
    temp["end_at"] = temp["hours"].map(lambda s: s.split("-")[1])
    del temp["hours"]
    return temp

schedule_table = pd.concat([schedules_on(day) for day in days])

# Store results
def store_table(table, file_name):
    table.to_csv("generated/{}.csv".format(file_name), index=False)
store_table(state_table, "state")
store_table(city_table, "city")
store_table(postal_codes_table, "postal_code")
store_table(business_table, "business")
store_table(locations, "business_locations")
store_table(categories, "categorie")
store_table(business_categories, "business_categorie")
store_table(noise_level, "noise_level")
store_table(music_table, "music")
store_table(music_business_relation_table, "music_business_relation")
store_table(business_parking_table, "business_parking")
store_table(parking_business_relation_table, "parking_business_relation")
store_table(ambience_table, "ambience")
store_table(ambience_business_relation_table, "ambience_business_relation")
store_table(good_for_meal_table, "good_for_meal")
store_table(good_for_meal_business_relation_table, "good_for_meal_business_relation")
store_table(dietary_restrictions_table, "dietary_restrictions")
store_table(dietary_restrictions_business_relation_table, "dietary_restrictions_business_relation")
store_table(day_table, "day")
store_table(schedule_table, "schedule")

# Parse review
review_ids = review['review_id'].reset_index().set_index('review_id')['index'].to_dict()
excluded_review = review[~((review.user_id.isin(user_ids.keys()) & review.business_id.isin(business_ids.keys())))]
included_review = review[review.user_id.isin(user_ids.keys()) & review.business_id.isin(business_ids.keys())]
included_review['user_id'] = included_review["user_id"].progress_map(lambda x: user_ids[x])
included_review['business_id'] = included_review["business_id"].progress_map(lambda x: business_ids[x])
included_review = included_review.reset_index().rename(columns={'index':'id'})
review_table = included_review.astype({"funny":'int', "stars":'int', "useful":'int'})
del review_table["review_id"]
pd.unique(review_table["stars"])
review_table.to_csv('generated/review.csv', index=False)

# Parse tip
excluded_tip = tip[~((tip.user_id.isin(user_ids.keys()) & tip.business_id.isin(business_ids.keys())))]
included_tip = tip[tip.user_id.isin(user_ids.keys()) & tip.business_id.isin(business_ids.keys())]
included_tip = included_tip.reset_index().rename(columns={'index':'id'})
included_tip['user_id'] = included_tip["user_id"].progress_map(lambda x: user_ids[x])
included_tip['business_id'] = included_tip["business_id"].progress_map(lambda x: business_ids[x])
tip_table = included_tip
tip_table["date"] = tip_table["date"].astype(str)
# only two tip without text out of 1029045 so we just drop them
tip_table = tip_table.dropna()
tip_table.to_csv('generated/tip.csv', index=False)
