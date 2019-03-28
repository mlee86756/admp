source("R/functions.R")
source("R/songkick_functions.R")

# import spotify dataset
spotify <- read.csv("data/spotify.csv")

# isolate last 6 months (last 26 weeks of 200 chart positions)
#spotify_last6mo <- tail(spotify, 26*200)
spotify_2018 <- spotify[substr(spotify$Week,1,4) == "2018", ]
#spotify_data <- spotify_last6mo
spotify_data <- spotify_2018

# aggregate total plays per artists
artist_plays <- aggregate(spotify_data$Plays, by=list(Artist=spotify_data$Artist), FUN=sum)
# sort list and keep top 20
top_20 <- head(artist_plays[order(artist_plays$x, decreasing=TRUE),], 20)
rownames(top_20) <- 1:20
colnames(top_20) <- c("Artist","Total Plays")

# sapply to get songkick IDs (RUN FUNCTIONS IN functions.R)
top_20$'Songkick ID' <- sapply(as.character(top_20$Artist), artist_name_to_songkick_artist_id)
write.csv(top_20, "data/artist_data.csv")

top_20_artists_events_df <- data_frame_via_lapply(as.character(top_20$'Songkick ID'), songkick_events_by_artist_id)
write.csv(top_20_artists_events_df, "data/artist_events.csv")

# get list of distinct venues used by top 20 artists, and fetch data for each
venues_list <- unique(na.omit(as.character(top_20_artists_events_df$venueID)),incomparables=FALSE)
songkick_venues <- data_frame_via_lapply(venues_list, songkick_venue_retrieve_by_id)
write.csv(songkick_venues, "data/songkick_venues.csv")
