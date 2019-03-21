## This defines functions

library(dplyr)



# MUSICBRAINZ AND SONGKICK UDFs

artist_name_to_songkick_id <- function(artist_name){
  mb_gid <- artist_name_to_musicbrainz_gid(artist_name)
  mb_gid
  if (is.null(mb_gid)) {
    return("musicbrainz gid not found")
  } else {
    result <- musicbrainz_gid_to_songkick_id(mb_gid)
  }
  # Pause to avoid 503 error on loop
  Sys.sleep(0.5)
  result
  if (length(result) < 1) {
    return("NULL")
  } else {
    return(result)
  }
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

songkick_artist_id_to_songkick_event_ids <- function(songkick_artist_id) {
  library(jsonlite)
  # Build query URL and execute
  songkick_api_key <- "OdCeFTr8qFUSwUVt"
  songkick_query_url <- paste ("https://api.songkick.com/api/3.0/artists/", 
                               songkick_artist_id, "/gigography.json?apikey=", songkick_api_key, sep="")
  songkick_results <- fromJSON(songkick_query_url)
  # extract Event IDs
  eventIDs <- songkick_results[["resultsPage"]][["results"]][["event"]][["venue"]][["id"]]
  totalPages <- length(songkick_results[["resultsPage"]])
  # repeat on further pages (if any)
  if (totalPages > 1) {
    pageNums <- 2:totalPages
    for (pageNum in pageNums) {
      songkick_query_url <- paste(songkick_query_url,"&page=",pageNum,sep="")
      songkick_results <- fromJSON(songkick_query_url)
      eventIDs <- append(eventIDs, songkick_results[["resultsPage"]][["results"]][["event"]][["venue"]][["id"]])
    }
  }
  return (eventIDs)
}