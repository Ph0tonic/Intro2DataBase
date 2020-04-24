import numpy as np
import pandas as pd
import ast
#import psycopg2

from tqdm import tqdm
tqdm.pandas()

#!ls csv_files

generic = lambda x: ast.literal_eval(x)
conv = {'friends': generic}

# business = pd.read_csv('csv_files/yelp_academic_dataset_business.csv')
# review = pd.read_csv('csv_files/yelp_academic_dataset_review.csv')
# tip = pd.read_csv('csv_files/yelp_academic_dataset_tip_transposed.csv')
user = pd.read_csv('csv_files/yelp_academic_dataset_user.csv',converters=conv)

business.index += 1
# review.index += 1
# tip.index += 1
# user.index += 1

user_ids = user['user_id'].reset_index().set_index('user_id')['index'].to_dict()
friends = user['friends'].progress_map(lambda friends: list(map(lambda x: user_ids[x],friends)))
elite = user[user['elite'].progress_map(lambda x:type(x))==type("")]['elite'].map(lambda e:list(map(lambda x:int(x),e.split(","))))

del user["user_id"]
del user["friends"]
del user["elite"]
user_table = user.reset_index().rename(columns={'index':'id'})

user_table.head()
user_table.to_csv('generated/user.csv', index=False)
friends_temp=friends.reset_index().rename(columns={'index':'id'})

friends_table=(friends_temp['friends'].progress_apply(lambda x: pd.Series(x))
   .progress_stack()
   .reset_index(level=1, drop=True)
   .to_frame('friends')
   .join(friends_temp[['id']], how='left'))