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
top_20_artists <- top_20[1]

# lapply to get songkick IDs (RUN FUNCTIONS IN functions.R)
songkick_ids <- lapply(top_20_artists$Artist, artist_name_to_songkick_id)

# trying songkick query (results need decoding...)
songkick_api_key <- "OdCeFTr8qFUSwUVt"
songkick_artist_id <- artist_name_to_songkick_id("Eminem")
songkick_query_url <- paste ("https://api.songkick.com/api/3.0/artists/", 
  songkick_artist_id, "/gigography.json?apikey=", songkick_api_key, sep="")
library(jsonlite)
songkick_results <- fromJSON(songkick_query_url)
