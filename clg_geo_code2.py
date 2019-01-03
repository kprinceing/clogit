
# coding: utf-8

# In[1]:

import pandas as pd
import numpy as np
import googlemaps


# In[2]:

map_api_key = 'AIzaSyCXqQPINi9qjFnZl4fG5gtCCS85aAwUw08'
gmaps = googlemaps.Client(key=map_api_key)


# # Function Definitions

# In[3]:

def clg_geo_code(row):
    geocode_result =gmaps.geocode(row['clg_string'])
    result   = geocode_result[0]
    city     = search_city(result)
    prov     = search_prov(result)
    lat, lng = search_longitude(result)
    return city,prov,lat, lng


# In[18]:

def prov_geo_code(row):
    geocode_result =gmaps.geocode(row['prov_string'])
    result   = geocode_result[0]
    city     = search_city(result)
    prov     = search_prov(result)
    lat, lng = search_longitude(result)
    return city,prov,lat, lng


# In[4]:

def search_city(result):
    city_name = ''
    for p in result['address_components']:
            if 'locality' in p['types']:
                city_name = p['long_name']
    if city_name == '': # 直辖市
        for p in result['address_components']:
            if 'administrative_area_level_1' in p['types']:
                city_name = p['long_name']
    return city_name


# In[5]:

def search_prov(result):
    prov_name =''
    for p in result['address_components']:
            if 'administrative_area_level_1' in p['types']:
                prov_name = p['long_name']
    return prov_name


# In[6]:

def search_longitude(result):
    lat  = np.nan
    lng = np.nan
    geometry = result['geometry']
    location = geometry['location']
    lat  = location['lat']
    lng  = location['lng']
    return lat, lng


# In[138]:

def distance(row):
    prov_lat    = row['prov_lat']
    prov_lng    = row['prov_lng']
    clg_lat     = row['clg_lat']
    clg_lng     = row['clg_lng']
    d = gmaps.distance_matrix((prov_lat, prov_lng),(clg_lat,clg_lng))
    print(row['provid'])
    print(row['clg_string'])
    if clg_lng<0:
            distance    = np.nan
    else:
            distance = d['rows'][0]['elements'][0]['distance']['value']
    return distance


# # Tests

# In[8]:

# test these functions
geocode_result = gmaps.geocode('三峡大学')
result = geocode_result[0]
print(result)
print(search_city(result))
print(search_longitude(result))


# In[9]:

d = gmaps.distance_matrix((30.720482,111.318127),(31.189043,121.450955))
print(d)
print(d['rows'][0]['elements'][0]['distance']['value'])


# # Apply to dataset

# ## Gen college locations DF

# In[10]:

df = pd.read_stata('C:/Users/yan/Dropbox/college_entrance_exam/data/ncee_rank.dta')
clg= pd.DataFrame(df['clg_num'].unique().astype(str))
clg.rename(columns={0:'clg_string'},inplace=True)
z =zip(*clg.apply(clg_geo_code,axis=1)) #store the returned tuples as a zipped object
clg['clg_city'],clg['clg_prov'],clg['clg_lat'], clg['clg_lng']=z # assign the zipped object to dataframe columns
print(clg.head(5))
clg.to_excel('C:/Users/yan/Dropbox/college_entrance_exam/data/clg_geocode.xlsx') #export to excel and manually check errors


# In[133]:

clg= pd.read_excel('C:/Users/yan/Dropbox/college_entrance_exam/data/clg_geocode_correct.xlsx') #export to excel and manually check errors


# ## Gen province locations DF

# In[126]:

prov = pd.read_excel('C:/Users/yan/Dropbox/college_entrance_exam/data/prov.xlsx')
z =zip(*prov.apply(prov_geo_code,axis=1)) #store the returned tuples as a zipped object
prov['prov_city'],prov['prov_prov'],prov['prov_lat'], prov['prov_lng'] = z # assign the zipped object to dataframe columns
prov.rename(columns={'prov':'provid'},inplace=True)
prov['provid'] = prov['provid'].astype('int64') # convert provid to integer type
prov.head(5)


# In[127]:

prov['provid'].dtype


# ## Gen clg and provinces DF

# In[128]:

prov_clg =df[['score','provid','clg_num']].groupby(by=['provid','clg_num']).count().reset_index() # transform to a dataframe with the number of provinces * the number of colleges
prov_clg.drop(labels=['score'],axis=1,inplace=True)
prov_clg['provid'].astype('str',inplace=True) # convert provid to integer type
prov_clg.rename(columns={'clg_num':'clg_string'}, inplace=True)
prov_clg.head()


# In[134]:

# merge the provid with provstring
temp =prov_clg.merge(prov,how='left',on='provid')
# merge with the clg df
prov_clg_geo = temp.merge(clg,how='left',on='clg_string')


# In[136]:

print(prov_clg_geo[(prov_clg_geo['prov_lng']<0) | (prov_clg_geo['prov_lng']==np.nan)].count()) # check if the lat and lng are positive and non-missin
print(prov_clg_geo[(prov_clg_geo['prov_lat']<0) | (prov_clg_geo['prov_lat']==np.nan)].count())
print(prov_clg_geo[(prov_clg_geo['clg_lat']<0) | (prov_clg_geo['clg_lat']==np.nan)].count())
prov_clg_geo[(prov_clg_geo['clg_lng']<0) | (prov_clg_geo['clg_lng']==np.nan)].count()


# ## Calculate distance

# In[139]:

# apply the distance function on this dataframe
prov_clg['distance'] = prov_clg_geo.apply(distance,axis=1)


# In[ ]:



