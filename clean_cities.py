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
