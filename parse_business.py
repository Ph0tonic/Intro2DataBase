#!/usr/bin/env python
# coding: utf-8

# In[ ]:


import numpy as np
import pandas as pd
from tqdm import tqdm
tqdm.pandas()


# In[ ]:


import geopandas as gpd
import geopy
import re
import math


# In[ ]:


business_raw = pd.read_csv('csv_files/yelp_academic_dataset_business.csv')
business_raw.index +=1


# In[ ]:


business_raw.head()


# In[ ]:


business_raw.shape


# In[ ]:


business_raw[business_raw["address"].isna()].shape


# In[ ]:


business_raw[business_raw["attributes"].isna()].shape


# In[ ]:


business_raw[business_raw["business_id"].isna()].shape


# In[ ]:


business_raw[business_raw["categories"].isna()].shape


# In[ ]:


business_raw[business_raw["city"].isna()]


# In[ ]:


business_raw[business_raw["hours"].isna()].shape


# In[ ]:


business_raw[business_raw["is_open"].isna()].shape


# In[ ]:


business_raw[business_raw["latitude"].isna()].shape


# In[ ]:


business_raw[business_raw["longitude"].isna()].shape


# In[ ]:


business_raw[business_raw["name"].isna()].shape


# In[ ]:


business_raw[business_raw["postal_code"].isna()].shape


# In[ ]:


business_raw[business_raw["review_count"].isna()].shape


# In[ ]:


business_raw[business_raw["stars"].isna()].shape


# In[ ]:


business_raw[business_raw["state"].isna()].shape


# In[ ]:


business_raw[business_raw["is_open"] == 1][business_raw["hours"].isna()]


# In[ ]:


business_raw[business_raw["postal_code"].isna()][business_raw["address"].isna() == False]


# We have 0 business without a state, 1 business without a city, 659 businesses without a postal_code, 7682 businesses without an address among which only 545 has no postal_code, so we have 114 businesses with an address but no postal_code

# In[ ]:


eval(business_raw["attributes"][2])


# 
# # Parse businesses ids

# In[ ]:


business_ids = business_raw["business_id"].reset_index().set_index("business_id")["index"].to_dict()
del business_raw["business_id"]
business_table = business_raw.reset_index().rename(columns={'index':'id'})
business_table


# ## Fix business postal_code and city

# In[ ]:


business_table[business_table.postal_code.isna()]


# ## Clean cities name

# In[ ]:


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
    temp = re.sub('saint-leonard', 'saint-leonard', temp)
    temp = re.sub('st. leonard', 'saint-leonard', temp)
    
    temp = re.sub('st.pittsburgh', 'pittsburgh', temp)
    temp = re.sub('chomedey, laval', 'laval', temp)
    
    temp = re.sub('mt\.', 'mount', temp)
    temp = re.sub('mt', 'mount', temp)
    
    
    # Remove duplicates spaces
    temp = temp.split(',', 1)[0]
    temp = " ".join(temp.title().split())
    return temp


# In[ ]:


business_table.loc[~business_table.city.isna(),'city'] = business_table[~business_table.city.isna()].progress_apply(clean_city_name, axis=1)


# In[ ]:


business_table[~business_table.city.isna()].progress_apply(clean_city_name, axis=1)


# In[ ]:


business_table[~business_table.city.isna()][business_table[~business_table.city.isna()].city.str.contains('egas')]


# In[ ]:





# In[ ]:





# ### Locators used

# In[ ]:


locator = geopy.Nominatim(user_agent="myGeocoder",timeout=3)
location = locator.reverse("36.169710,-115.123695")
location.raw


# In[ ]:


mapQuestLocator=geopy.geocoders.OpenMapQuest("StxlGpGLb5EapoCXFQBf6GroFDOZTBJj",timeout=3)
location=mapQuestLocator.reverse("36.169710,-115.123695")
location.raw


# In[ ]:





# In[ ]:


googleLocator=geopy.geocoders.GoogleV3(api_key="YOUR_API_KEY")


# In[ ]:





# In[ ]:





# In[ ]:





# In[ ]:


business_table[business_table.address.isna()]


# In[ ]:


business_table[business_table.city.isna()]


# In[ ]:


business_table[business_table.postal_code.isna()]


# In[ ]:





# In[ ]:


def get_postal_code(data):
    coordinates = f'{data.latitude},{data.longitude}'
    location = mapQuestLocator.reverse(coordinates)
    if location.raw.get("address").get("postcode") == None:
        location = locator.reverse(coordinates)
    return location.raw.get("address").get("postcode")


# In[ ]:


def get_postal_code_v2(data):
    coordinates = f'{data.latitude},{data.longitude}'
    location = googleLocator.reverse(coordinates)
    return list(filter(lambda l:l.get("types")[0]=="postal_code",location[0].raw.get("address_components")))[0].get("long_name")


# In[ ]:


def get_city_name(data):
    coordinates = f'{data.latitude},{data.longitude}'
    location = locator.reverse(coordinates)
    if location.raw.get("address").get("city") == None:
        location=mapQuestLocator.reverse(coordinates)
    return location.raw.get("address").get("city",np.NaN)


# In[ ]:


def get_address(data):
    coordinates = f'{data.latitude},{data.longitude}'
    location = locator.reverse(coordinates)
    if location.raw.get("address").get("road") == None or location.raw.get("neighbourhood") == None:
        location=locator.reverse(coordinates)
    return location.raw.get("address").get("road", location.raw.get("address").get("neighbourhood", np.NaN))


# In[ ]:


def get_address_v2(data):
    coordinates = f'{data.latitude},{data.longitude}'
    locations = googleLocator.reverse(coordinates)
    res=format(locations[0].raw)
    if res == None and len(locations)>0:
        res=format(locations[1].raw)
    return res
def format(locs):
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


# In[ ]:





# In[ ]:





# In[ ]:





# In[ ]:


business_table.loc[business_table.postal_code.isna(),'postal_code'] = business_table[business_table.postal_code.isna()].progress_apply(get_postal_code, axis=1)


# In[ ]:


business_table.loc[business_table.city.isna(),'city'] = business_table[business_table.city.isna()].progress_apply(get_city_name, axis=1)


# In[ ]:


business_table.loc[business_table.address.isna(),'address'] = business_table[business_table.address.isna()].progress_apply(get_address, axis=1)


# In[ ]:





# In[ ]:


business_table.loc[business_table.postal_code.isna(),'postal_code'] = business_table[business_table.postal_code.isna()].progress_apply(get_postal_code_v2, axis=1)


# In[ ]:


business_table.loc[business_table.address.isna(),'address'] = business_table[business_table.address.isna()].progress_apply(get_address_v2, axis=1)


# In[ ]:





# In[ ]:





# In[ ]:


business_table[business_table.address.isna()]


# In[ ]:





# In[ ]:





# # Parse Locations

# In[ ]:


locations = business_table[["id", "address", "city", "latitude", "longitude", "postal_code", "state"]]
del business_table["address"]
del business_table["city"]
del business_table["latitude"]
del business_table["longitude"]
del business_table["postal_code"]
del business_table["state"]
locations = locations.rename(columns={'id':'business_id'})
locations


# ## States

# In[ ]:


state_table = locations["state"].drop_duplicates()
state_table = state_table.sort_values().reset_index()
state_table.index += 1
del state_table["index"]
state_table = state_table.reset_index().rename(columns={"index":"id", "state": "name"})
state_table


# In[ ]:


state_dict = state_table.set_index("name")["id"].to_dict()
locations["state_id"] = locations["state"].progress_apply(lambda s: state_dict[s])
del locations["state"]
locations


# ## Cities

# In[ ]:


city_table = locations[["city", "state_id"]].drop_duplicates()
city_table = city_table.reset_index()
del city_table["index"]
city_table.index += 1
city_table = city_table.reset_index()
city_table = city_table.rename(columns={"index":"id", "city":"name"})
city_table


# In[ ]:


city_dict = city_table.set_index(["name", "state_id"])["id"].to_dict()


# In[ ]:


locations["city_id"] = locations[["city", "state_id"]].progress_apply(lambda row: city_dict[(row[0], row[1])], axis=1, raw=True)
del locations["state_id"]
del locations["city"]
locations


# ## Postal codes

# In[ ]:


postal_codes_table = locations[["city_id", "postal_code"]].drop_duplicates()
postal_codes_table = postal_codes_table.reset_index()
del postal_codes_table["index"]
postal_codes_table.index += 1
postal_codes_table = postal_codes_table.reset_index().rename(columns={"index":"id"})
postal_codes_table


# In[ ]:


postal_code_dict = postal_codes_table.set_index(["postal_code", "city_id"])["id"].to_dict()


# In[ ]:


locations["postal_code_id"] = locations[["postal_code", "city_id"]].progress_apply(lambda row: postal_code_dict[(row[0], row[1])], axis=1, raw=True)
del locations["city_id"]
del locations["postal_code"]
locations


# # Parse categories

# In[ ]:


business_categories_temp = business_table[["id", "categories"]][business_table["categories"].progress_map(lambda x: type(x) == str)]
business_categories_temp["categories"] = business_categories_temp["categories"].progress_map(lambda cats: list(map(str.strip, cats.split(","))))

business_categories_temp


# In[ ]:


business_categories = (business_categories_temp['categories']
    .progress_apply(lambda x: pd.Series(x))
    .stack()
    .reset_index(level=1, drop=True)
    .to_frame('categories')
    .join(business_categories_temp[['id']], how='left'))
business_categories


# In[ ]:


categories = business_categories["categories"]
categories = categories.drop_duplicates().reset_index()
del categories["index"]
categories.index += 1
categories = categories.reset_index().rename(columns={"index":"id", "categories": "name"})
categories.index += 1
categories


# In[ ]:


categories_dict = categories.reset_index().set_index("name")["index"].to_dict()
business_categories["categorie_id"] = business_categories["categories"].progress_map(lambda cat: categories_dict[cat])
del business_categories["categories"]
del business_table["categories"]
business_categories = business_categories.rename(columns={"id":"business_id"}).drop_duplicates()
business_categories


# In[ ]:





# # Parse attributes

# In[ ]:


attributes = business_raw[business_raw["attributes"].map(lambda x: type(x)==str)]["attributes"].progress_apply(eval)
del business_table["attributes"]
attributes


# ## Noise level

# In[ ]:


noise_level_temp = attributes[attributes.map(lambda x: "NoiseLevel" in x)].map(lambda x: eval(x["NoiseLevel"]))
noise_level = noise_level_temp.drop_duplicates().reset_index()
del noise_level["index"]
noise_level.index += 1
noise_level = noise_level.reset_index().rename(columns={"index":"id", "attributes":"level"})
noise_level


# In[ ]:


noise_level_dict = noise_level.set_index("level")["id"].to_dict()
business_table["noise_level_id"] = noise_level_temp.map(lambda x: noise_level_dict[x])
#uses that NaN != NaN
business_table["noise_level_id"] = business_table["noise_level_id"].apply(lambda x: int(x) if x == x else "")
#ugly but working for now
business_table["noise_level_id"] = business_table["noise_level_id"].apply(lambda x: x if x != 5 else "")
noise_level = noise_level.dropna()
business_table


# ## Music

# In[ ]:


music_temp = attributes[attributes.map(lambda x: "Music" in x)].map(lambda x: eval(x["Music"]))
music_temp = music_temp[music_temp.map(lambda x: x != None)]
music_temp = music_temp.progress_map(lambda m: [key for key in m.keys() if m[key]])
music_temp = music_temp[music_temp.map(lambda l: len(l) > 0)].reset_index().rename(columns={"index":"business_id", "attributes":"name"})
music_temp


# In[ ]:


music_business_relation_table = (music_temp['name']
    .progress_apply(lambda x: pd.Series(x))
    .stack()
    .reset_index(level=1, drop=True)
    .to_frame('name')
    .join(music_temp[['business_id']], how='left'))
music_business_relation_table


# In[ ]:


music_table = music_business_relation_table["name"].drop_duplicates().reset_index()
del music_table["index"]
music_table.index += 1
music_table = music_table.reset_index().rename(columns={"index":"id"})
music_table


# In[ ]:


music_dict = music_table.set_index("name")["id"].to_dict()
music_business_relation_table["music_id"] = music_business_relation_table["name"].map(lambda x: music_dict[x])
del music_business_relation_table["name"]
music_business_relation_table


# ## Business parking 

# In[ ]:


parking_temp = attributes[attributes.map(lambda x: "BusinessParking" in x)].map(lambda x: eval(x["BusinessParking"]))
parking_temp = parking_temp[parking_temp.map(lambda x: x != None)]
parking_temp = parking_temp.progress_map(lambda m: [key for key in m.keys() if m[key]])
parking_temp = parking_temp[parking_temp.map(lambda l: len(l) > 0)].reset_index().rename(columns={"index":"business_id", "attributes":"name"})
parking_temp


# In[ ]:


parking_business_relation_table = (parking_temp['name']
    .progress_apply(lambda x: pd.Series(x))
    .stack()
    .reset_index(level=1, drop=True)
    .to_frame('name')
    .join(parking_temp[['business_id']], how='left'))
parking_business_relation_table


# In[ ]:


business_parking_table = parking_business_relation_table["name"].drop_duplicates().reset_index()
business_parking_table.index += 1
del business_parking_table["index"]
business_parking_table = business_parking_table.reset_index().rename(columns={"index":"id"})
business_parking_table


# In[ ]:


parking_dict = business_parking_table.set_index("name")["id"].to_dict()
parking_business_relation_table["parking_id"] = parking_business_relation_table["name"].map(lambda x: parking_dict[x])
del parking_business_relation_table["name"]
parking_business_relation_table


# ## Ambience

# In[ ]:


ambience_temp = attributes[attributes.map(lambda x: "Ambience" in x)].map(lambda x: eval(x["Ambience"]))
ambience_temp = ambience_temp[ambience_temp.map(lambda x: x != None)]
ambience_temp = ambience_temp.progress_map(lambda m: [key for key in m.keys() if m[key]])
ambience_temp = ambience_temp[ambience_temp.map(lambda l: len(l) > 0)].reset_index().rename(columns={"index":"business_id", "attributes":"name"})
ambience_temp


# In[ ]:


ambience_business_relation_table = (ambience_temp['name']
    .progress_apply(lambda x: pd.Series(x))
    .stack()
    .reset_index(level=1, drop=True)
    .to_frame('name')
    .join(ambience_temp[['business_id']], how='left'))
ambience_business_relation_table


# In[ ]:


ambience_table = ambience_business_relation_table["name"].drop_duplicates().reset_index()
ambience_table.index += 1
del ambience_table["index"]
ambience_table = ambience_table.reset_index().rename(columns={"index":"id"})
ambience_table


# In[ ]:


ambience_dict = ambience_table.set_index("name")["id"].to_dict()
ambience_business_relation_table["ambience_id"] = ambience_business_relation_table["name"].map(lambda x: ambience_dict[x])
del ambience_business_relation_table["name"]
ambience_business_relation_table


# ## Good for meal

# In[ ]:


good_for_meal_temp = attributes[attributes.map(lambda x: "GoodForMeal" in x)].map(lambda x: eval(x["GoodForMeal"]))
good_for_meal_temp = good_for_meal_temp[good_for_meal_temp.map(lambda x: x != None)]
good_for_meal_temp = good_for_meal_temp.progress_map(lambda m: [key for key in m.keys() if m[key]])
good_for_meal_temp = good_for_meal_temp[good_for_meal_temp.map(lambda l: len(l) > 0)].reset_index().rename(columns={"index":"business_id", "attributes":"name"})
good_for_meal_temp


# In[ ]:


good_for_meal_business_relation_table = (good_for_meal_temp['name']
    .progress_apply(lambda x: pd.Series(x))
    .stack()
    .reset_index(level=1, drop=True)
    .to_frame('name')
    .join(good_for_meal_temp[['business_id']], how='left'))
good_for_meal_business_relation_table


# In[ ]:


good_for_meal_table = good_for_meal_business_relation_table["name"].drop_duplicates().reset_index()
good_for_meal_table.index += 1
del good_for_meal_table["index"]
good_for_meal_table = good_for_meal_table.reset_index().rename(columns={"index":"id"})
good_for_meal_table


# In[ ]:


good_for_meal_dict = good_for_meal_table.set_index("name")["id"].to_dict()
good_for_meal_business_relation_table["ambience_id"] = good_for_meal_business_relation_table["name"].map(lambda x: good_for_meal_dict[x])
del good_for_meal_business_relation_table["name"]
good_for_meal_business_relation_table


# ## dietary restrictions

# In[ ]:


dietary_restrictions_temp = attributes[attributes.map(lambda x: "DietaryRestrictions" in x)].map(lambda x: eval(x["DietaryRestrictions"]))
dietary_restrictions_temp = dietary_restrictions_temp[dietary_restrictions_temp.map(lambda x: x != None)]
dietary_restrictions_temp = dietary_restrictions_temp.progress_map(lambda m: [key for key in m.keys() if m[key]])
dietary_restrictions_temp = dietary_restrictions_temp[dietary_restrictions_temp.map(lambda l: len(l) > 0)].reset_index().rename(columns={"index":"business_id", "attributes":"name"})
dietary_restrictions_temp


# In[ ]:


dietary_restrictions_business_relation_table = (dietary_restrictions_temp['name']
    .progress_apply(lambda x: pd.Series(x))
    .stack()
    .reset_index(level=1, drop=True)
    .to_frame('name')
    .join(dietary_restrictions_temp[['business_id']], how='left'))
dietary_restrictions_business_relation_table


# In[ ]:


dietary_restrictions_table = dietary_restrictions_business_relation_table["name"].drop_duplicates().reset_index()
dietary_restrictions_table.index += 1
del dietary_restrictions_table["index"]
dietary_restrictions_table = dietary_restrictions_table.reset_index().rename(columns={"index":"id"})
dietary_restrictions_table


# In[ ]:


dietary_restrictions_dict = dietary_restrictions_table.set_index("name")["id"].to_dict()
dietary_restrictions_business_relation_table["dietary_restrictions_id"] = dietary_restrictions_business_relation_table["name"].map(lambda x: dietary_restrictions_dict[x])
del dietary_restrictions_business_relation_table["name"]
dietary_restrictions_business_relation_table


# # Parse schedule

# In[ ]:


schedule_temp = business_raw["hours"]
del business_table["hours"]
schedule_temp = schedule_temp[schedule_temp.map(lambda x: type(x) == str)].progress_map(eval)
schedule_temp


# In[ ]:


days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
day_table = pd.DataFrame(days, columns=["name"])
day_table.index += 1
day_table = day_table.reset_index().rename(columns={"index": "id"})
day_dict = day_table.set_index("name")["id"].to_dict()
day_table


# In[ ]:


def schedules_on(day):
    temp = schedule_temp[schedule_temp.map(lambda m: day in m)].progress_map(lambda m: m[day]).reset_index().rename(columns={"index": "business_id"})
    temp["day_id"] = day_dict[day]
    temp["start_at"] = temp["hours"].map(lambda s: s.split("-")[0])
    temp["end_at"] = temp["hours"].map(lambda s: s.split("-")[1])
    del temp["hours"]
    return temp


# In[ ]:


schedule_table = pd.concat([schedules_on(day) for day in days])
schedule_table


# In[ ]:


business_raw[business_raw["city"] == "New York"]


# In[ ]:


locations.loc[119357]


# In[ ]:


postal_codes_table[postal_codes_table["id"] == 119358]


# In[ ]:


city_table[city_table["id"] == 119358]


# In[ ]:


business_raw


# In[ ]:


business_table


# In[ ]:





# # Store results

# In[ ]:


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


# In[ ]:




