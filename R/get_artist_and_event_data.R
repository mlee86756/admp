### This script creates datasets for top 20 artists, events and venues fromn Songkick


# Load libraries
library(httr)
library(jsonlite)
library(stringr)
library(dplyr)
library(lubridate)

# Source functions
source("R/functions.R")

# import spotify dataset
spotify <- read.csv("data/raw-data/spotify.csv")

# split week column into start and end of the week
spotify_wks <- as.data.frame(str_match(spotify$Week, "^(.*)--(.*)$")[,-1]) 
colnames(spotify_wks) <- c("Start Wk", "End Wk") 
spotify_wks[,1:2] <- lapply(spotify_wks[,1:2], as.Date)

# combine week's start and end dates columns with spotify dataframe, get last 6 months,summarise total plays, keep top20
top_20 <- spotify_wks %>% 
  cbind(spotify) %>%
  filter(`Start Wk` >= max(`Start Wk`)-days(180) ) %>%
  select(Artist, Plays) %>%
  group_by(Artist) %>%
  summarise(`Total plays` = sum(Plays)) %>%
  arrange(desc(`Total plays`)) %>%
  top_n(20)

# sapply to get songkick IDs (RUN FUNCTIONS IN functions.R)
top_20$'Songkick ID' <- sapply(as.character(top_20$Artist), artist_name_to_songkick_artist_id)
top_20_artists_events_df <- data_frame_via_lapply(as.character(top_20$'Songkick ID'), songkick_events_by_artist_id)

# create a list of all venues
venue_list <- as.character(unique(top_20_artists_events_df$venueID))

# make a dataframe of all venues
songkick_venues <- data_frame_via_lapply(venues_list, songkick_venue_retrieve_by_id)

# save all as csv files
write.csv(songkick_venues, "data/raw-data/songkick_venues.csv")
write.csv(top_20_artists_events_df, "data/raw-data/artist_events.csv")
write.csv(top_20, "data/raw-data/artist_data.csv")