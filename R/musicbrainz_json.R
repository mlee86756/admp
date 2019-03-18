library(httr)
library(jsonlite)

# UDF  to retrieve songkick id from musicbrainz
get_songkick_id <- function(artist_name) {
  # build url for musicbrainz api query with artist search
  json_url_for_mb_gid <- URLencode(paste('http://musicbrainz.org/ws/js/artist?limit=1&q=',artist_name,sep=""))
  json_url_for_mb_gid
  # execute musicbrainz api query
  json1 <- head(fromJSON(json_url_for_mb_gid),1)
  # retrieve gid from musicbrainz data
  mb_gid <- json1$gid
  
  # building url for further musicbrainz api query to include 'relationship' URLs
  json_url_for_links <- paste('http://musicbrainz.org/ws/2/artist/', mb_gid, '?inc=url-rels', sep="")
  # execute second musicbrainz api query
  json2 <- fromJSON(json_url_for_links)
  
  # extract URLs 
  youtube_url <- json2$relations$url$resource[json2$relations$type=='youtube']
  official_url <- json2$relations$url$resource[json2$relations$type=='official homepage']
  songkick_url <- json2$relations$url$resource[json2$relations$type=='songkick']
  Sys.sleep(0.5)
  # extract songkick ID from songkick URL
  return(basename(songkick_url))
}

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

# lapply to get songkick IDs
songkick_ids <- lapply(top_20_artists$Artist, get_songkick_id)
