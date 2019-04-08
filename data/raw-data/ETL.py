# -*- coding: utf-8 -*-
"""
Created on Wed Apr 7 17:08:20 2019

@author: Michael
"""

#########################
#### Import Libaries ####
#########################

import pandas as pd
import os

###########################
#### declare variables ####
###########################

mydir = os.path.dirname(os.path.realpath(__file__))+"\ADM crime data"
crime = pd.DataFrame()
crime_months = pd.DataFrame()
long_lat_mile = ((1/69)/2)

######################
#### Import files ####
######################

### import songkick_venues.csv
songkick_venues = pd.read_csv("songkick_venues.csv")

### import artist_events.csv
songkick_events = pd.read_csv("artist_events.csv", encoding = "ISO-8859-1")

### import spotify.csv (chart data)
spotify_chart = pd.read_csv("spotify.csv", encoding = "ISO-8859-1")


### import and combine crime csvs in ADM crime data folder
for root, dirs, files in os.walk(mydir):
    for file in files:
        if file.endswith(".csv"):
            filePath = os.path.join(root, file)
            crime_csv = pd.read_csv(filePath)
            crime = crime.append(crime_csv)  

#########################
#### Data Validation ####
#########################

################
## Crime data ##
################

### verifies that crime occured within sheffield by checking long and lat fall inside sheffield

crime = crime[(crime['Latitude'] > 53.34168) & (crime['Latitude'] < 53.426865)]
crime = crime[(crime['Longitude'] > -1.548107) & (crime['Longitude'] < -1.392925)]

######################
#### Charts Table ####
######################

### create charts_table
charts_table = spotify_chart

### cleanse dateID column
charts_table['Week'] = charts_table['Week'].str[:10]

### drop unwanted columns
charts_table = charts_table.drop(columns=['Track', 'Position', 'Track URL'])

### sum each of each week for artists
charts_table = charts_table.groupby(['Week','Artist',])['Plays'].sum().reset_index() 

### rename columns
charts_table.rename(columns={'Week':'dateID'}, inplace=True)


#####################
#### Venue Table ####
#####################

### combine songkick_venues and songkick_events on venueID (songkick_venues doesn't have venue city and country)
venue_table = pd.merge(songkick_venues, songkick_events, on='venueID', how='inner')
venue_table = venue_table.drop_duplicates(subset=['venueID'])

### drop unwanted columns
venue_table = venue_table.drop(columns=['Unnamed: 0_x', 'Unnamed: 0_y', 'artistID', 'eventID', 'eventDate', 'eventLng', 'eventLat'])

### seperate city and country into seperate columns

### rename columns
venue_table.rename(columns={'venueCapacity':'attendence', 'Unnamed: 0_y':'crimeRate', 'eventDate':'dateID'}, inplace=True)

######################
#### Events Table ####
######################

### combine songkick_venues and songkick_events on venueID
events_table = pd.merge(songkick_events, songkick_venues, on='venueID', how='outer')
events_table = events_table.drop_duplicates(subset=['eventID'])
events_table = events_table.dropna(subset=['venueID'])
events_table['Month'] = events_table['eventDate'].str[:7]
events_table = events_table.drop(columns=['Unnamed: 0_x', 'eventLng', 'eventLat', 'Unnamed: 0_y', 'venueLng', 'venueLat'])

### creates dataframe for events that occured in sheffield and adds min and max long and lat within a "mile box" of event (approxamitley without going into complex equations)
songkick_events_sheff = songkick_events[(songkick_events['eventLat'] > 53.34168) & (songkick_events['eventLat'] < 53.426865)]
songkick_events_sheff = songkick_events_sheff[(songkick_events_sheff['eventLng'] > -1.548107) & (songkick_events_sheff['eventLng'] < -1.392925)]    
songkick_events_sheff['Month'] = songkick_events_sheff['eventDate'].str[:7]

songkick_events_sheff['eventLatMax'] = songkick_events_sheff['eventLat'] + long_lat_mile
songkick_events_sheff['eventLatMin'] = songkick_events_sheff['eventLat'] - long_lat_mile

songkick_events_sheff['eventLngMax'] = songkick_events_sheff['eventLng'] + long_lat_mile
songkick_events_sheff['eventLngMin'] = songkick_events_sheff['eventLng'] - long_lat_mile


### loop over all songkick_events_sheff
for index, row in songkick_events_sheff.iterrows():    
    
    lat_min = row['eventLatMin']
    lat_max = row['eventLatMax']
    long_min = row['eventLngMin']
    long_max = row['eventLngMax']
    
    ### filters crime data through each row
    crime_loop = crime
    crime_loop = crime_loop[(crime_loop['Latitude'] > lat_min) & (crime_loop['Latitude'] < lat_max)]
    crime_loop = crime_loop[(crime_loop['Longitude'] > long_min) & (crime_loop['Longitude'] < long_max)]
    
    ### counts number of crimes and appends to crime_month_event 
    charts_table = charts_table.groupby(['Week','Artist',])['Plays'].sum().reset_index() 
    
    crime_count = crime_loop.groupby('Month').size()
    crime_event = pd.DataFrame(crime_count)    
    crime_event['venueID'] = row['venueID']    
    crime_months = crime_months.append(crime_event)  
    
### Fixes dateID being index and not column    
crime_months.reset_index(level=0, inplace=True)

### join to insert crime data into events_table
events_table = pd.merge(events_table, crime_months, on=['Month', 'venueID'], how = 'left')
events_table = events_table.drop_duplicates(subset=['eventID'])

### drop unwanted columns
events_table = events_table.drop(columns=['Month'])
    
### rename columns
events_table.rename(columns={'0':'crimeRate', 'venueCapacity':'attendence', 'eventDate':'dateID'}, inplace=True)

#########################
#### Export to excel ####
#########################
charts_table.to_excel(r"output\charts_table.xlsx") 

venue_table.to_excel(r"output\venue_table.xlsx") 

events_table.to_excel(r"output\events_table.xlsx") 




