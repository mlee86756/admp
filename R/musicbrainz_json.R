library(httr)
library(jsonlite)


# import spotify dataset
spotify <- read.csv("Excel/spotify.csv")
# isolate last 6 months (last 26 weeks of 200 chart positions)
spotify_last6mo <- tail(spotify, 26*200)

# aggregate total plays per artists
artist_plays <- aggregate(spotify_last6mo$Plays, by=list(Artist=spotify_last6mo$Artist), FUN=sum)
# sort list and keep top 20
top_20 <- head(artist_plays[order(artist_plays$x, decreasing=TRUE),], 20)
rownames(top_20) <- 1:20
colnames(top_20) <- c("Artist","Plays last 6mo")

# lapply to get songkick IDs (RUN FUNCTIONS IN functions.R)
songkick_ids <- sapply(top_20$Artist, artist_name_to_songkick_id)
top_20$Songkick <- songkick_ids

write.csv(top_20, "R/artist_data.csv")

eminemEventIDs <- songkick_artist_id_to_songkick_event_ids(artist_name_to_songkick_id("Eminem"))