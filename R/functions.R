## This defines functions

library(dplyr)



# MUSICBRAINZ UDFs

artist_name_to_songkick_id <- function(artist_name){
  mb_gid <- artist_name_to_musicbrainz_gid(artist_name)
  result <- musicbrainz_gid_to_songkick_id(mb_gid)
  Sys.sleep(0.5)
  return(result)
}

artist_name_to_musicbrainz_gid <- function(artist_name) {
  library(jsonlite)
  # build url for musicbrainz api query with artist search
  json_url_for_mb_gid <- URLencode(paste('http://musicbrainz.org/ws/js/artist?limit=1&q=',artist_name,sep=""))
  # execute musicbrainz api query
  json1 <- head(fromJSON(json_url_for_mb_gid),1)
  # retrieve gid from musicbrainz data
  return(json1$gid)
}

musicbrainz_gid_to_songkick_id <- function(musicbrainz_gid) {
  library(jsonlite)
  # building url for further musicbrainz api query to include 'relationship' URLs
  json_url_for_links <- paste('http://musicbrainz.org/ws/2/artist/', musicbrainz_gid, '?inc=url-rels', sep="")
  # execute second musicbrainz api query
  json2 <- fromJSON(json_url_for_links)
  
  # extract URLs 
  youtube_url <- json2$relations$url$resource[json2$relations$type=='youtube']
  official_url <- json2$relations$url$resource[json2$relations$type=='official homepage']
  songkick_url <- json2$relations$url$resource[json2$relations$type=='songkick']
  # extract songkick ID from songkick URL
  return(basename(songkick_url)) 
}
