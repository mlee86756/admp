library(httr)
library(jsonlite)


# import spotify dataset
spotify <- read.csv("Excel/spotify.csv")

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
top_20$'Songkick ID' <- sapply(as.character(top_20$Artist), artist_name_to_songkick_id)

write.csv(top_20, "R/artist_data.csv")

top_20_artists_event_data_list <- lapply(as.character(top_20$'Songkick ID'), songkick_artist_id_to_event_data)
top_20_artists_event_data_df <- as.data.frame(do.call(rbind, top_20_artists_event_data_list))
colnames(top_20_artists_event_data_df) <- c("Artist ID", "Event ID", "Event Date", "Event City", "Event Longitude", "Event Latitude")
write.csv(top_20_artists_event_data_df, "R/artist_events.csv")