#!/usr/bin/env python
# coding: utf-8

# In[1]:


import numpy as np
import pandas as pd
import ast
#import psycopg2


# In[2]:


from tqdm import tqdm
tqdm.pandas()


# In[ ]:


get_ipython().system('ls csv_files')


# In[ ]:


generic = lambda x: ast.literal_eval(x)
conv = {'friends': generic}


# In[ ]:


business = pd.read_csv('csv_files/yelp_academic_dataset_business.csv')
review = pd.read_csv('csv_files/yelp_academic_dataset_review.csv')
tip = pd.read_csv('csv_files/yelp_academic_dataset_tip_transposed.csv')
user = pd.read_csv('csv_files/yelp_academic_dataset_user.csv',converters=conv)


# In[ ]:


business.index += 1
review.index += 1
tip.index += 1
user.index += 1


# # Parse user

# In[ ]:


excluded_user = user[(user.name.isna())]


# In[ ]:


excluded_user


# In[ ]:


included_user = user[~(user.name.isna())]


# In[ ]:


included_user.head()


# In[ ]:


user_ids = included_user['user_id'].reset_index().set_index('user_id')['index'].to_dict()


# In[ ]:


friends = included_user['friends'].progress_map(lambda friends: list(filter(lambda x: not x is None, map(lambda x: user_ids.get(x,None),friends))))


# In[ ]:


elite = included_user[included_user['elite'].progress_map(lambda x:type(x))==str]['elite'].map(lambda e:list(map(lambda x:int(x),e.split(","))))


# In[ ]:


del included_user["user_id"]
del included_user["friends"]
del included_user["elite"]
user_table = included_user.reset_index().rename(columns={'index':'id'})


# In[ ]:


user_table.head()


# In[ ]:


user_table.to_csv('generated/user.csv', index=False)


# ## Parse friends

# In[ ]:


friends_temp=friends.reset_index().rename(columns={'index':'id'})


# In[ ]:


friends_temp


# In[ ]:


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


# In[ ]:


friends_table["friends"] = friends_table["friends"].astype(int)
friends_table=friends_table.rename(columns={'id':'user_id_1'})
friends_table=friends_table.rename(columns={'friends':'user_id_2'})


# In[ ]:


friends_table['user_id_1'], friends_table['user_id_2'] = friends_table.min(axis=1), friends_table.max(axis=1)
friends_table.drop_duplicates(inplace=True)


# In[ ]:


friends_table.head()


# In[ ]:


friends_table.to_csv('generated/are_friends.csv', index=False)


# ## Parse Elite years

# In[ ]:


elite_temp=elite.reset_index().rename(columns={'index':'user_id'})


# In[ ]:


elite_temp.head()


# In[ ]:


elite_table=(elite_temp['elite'].progress_apply(lambda x: pd.Series(x))
   .stack()
   .reset_index(level=1, drop=True)
   .to_frame('elite')
   .join(elite_temp[['user_id']], how='left'))


# In[ ]:


elite_table["elite"] = elite_table["elite"].astype(int)
elite_table=elite_table.rename(columns={'elite':'year'})


# In[ ]:


elite_table.head()


# In[ ]:


elite_table.to_csv('generated/elite_years.csv', index=False)


# In[ ]:





# In[ ]:





# # Parse business

# In[ ]:


business_ids = business['business_id'].reset_index().set_index('business_id')['index'].to_dict()


# In[ ]:





# # Parse review

# In[ ]:


review_ids = review['review_id'].reset_index().set_index('review_id')['index'].to_dict()


# In[ ]:


excluded_review = review[~((review.user_id.isin(user_ids.keys()) & review.business_id.isin(business_ids.keys())))]


# In[ ]:


included_review = review[review.user_id.isin(user_ids.keys()) & review.business_id.isin(business_ids.keys())]


# In[ ]:


excluded_review


# In[ ]:


included_review['user_id'] = included_review["user_id"].progress_map(lambda x: user_ids[x])


# In[ ]:


included_review['business_id'] = included_review["business_id"].progress_map(lambda x: business_ids[x])


# In[ ]:


included_review = included_review.reset_index().rename(columns={'index':'id'})


# In[ ]:


review_table = included_review.astype({"funny":'int', "stars":'int', "useful":'int'})
del review_table["review_id"]


# In[ ]:


pd.unique(review_table["stars"])
review_table.head()


# In[ ]:


review_table.to_csv('generated/review.csv', index=False)


# In[ ]:





# # Parse tip

# In[ ]:


excluded_tip = tip[~((tip.user_id.isin(user_ids.keys()) & tip.business_id.isin(business_ids.keys())))]


# In[ ]:


included_tip = tip[tip.user_id.isin(user_ids.keys()) & tip.business_id.isin(business_ids.keys())]


# In[ ]:


included_tip = included_tip.reset_index().rename(columns={'index':'id'})


# In[ ]:


excluded_tip


# In[ ]:


included_tip['user_id'] = included_tip["user_id"].progress_map(lambda x: user_ids[x])


# In[ ]:


included_tip['business_id'] = included_tip["business_id"].progress_map(lambda x: business_ids[x])


# In[ ]:


tip_table = included_tip


# In[ ]:


tip_table.head()


# In[ ]:


tip_table["date"] = tip_table["date"].astype(str)


# In[ ]:


#only two tip without text out of 1029045 so we just drop them
tip_table = tip_table.dropna()


# In[ ]:


tip_table.to_csv('generated/tip.csv', index=False)


# In[ ]:


friends_table[friends_table["user_id_1"] == friends_table["user_id_2"]]


# In[ ]:





# In[ ]:




