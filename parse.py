import pandas as pd
import numpy as np


generic = lambda x: ast.literal_eval(x)
conv = {'friends': generic}

user = pd.read_csv('csv_files/yelp_academic_dataset_user.csv',converters=conv)
#business = pd.read_csv('csv_files/yelp_academic_dataset_business.csv')
#review = pd.read_csv('csv_files/yelp_academic_dataset_review.csv')
#tip = pd.read_csv('csv_files/yelp_academic_dataset_tip_transposed.csv')



# PARSE USER
user_ids = user['user_id'].reset_index().set_index('user_id')['index'].to_dict()

user_table = user
friends_table = user['friends'].map(lambda friends: list(map(lambda x: user_ids[x],friends)))
elite_table = user[user['elite'].map(lambda x:type(x))==type("")]['elite'].map(lambda e:list(map(lambda x:int(x),e.split(","))))
