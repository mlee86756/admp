## This defines functions

library(dplyr)



#*********************************************************************************************************

# SONGKICK UDFS

artist_name_to_songkick_id <- function(artist_name){
  library(jsonlite)
  sk_api_key <- "OdCeFTr8qFUSwUVt"
  sk_query_url <- paste ("https://api.songkick.com/api/3.0/search/artists.json?apikey=", sk_api_key,
                               "&query=", URLencode(artist_name), sep="")
  sk_json <- fromJSON(sk_query_url)
  # Pause to avoid 503 error on loop
  Sys.sleep(0.5)
  result <- as.character(sk_json[['resultsPage']][['results']][['artist']][['id']][1])
  return(result)
}

songkick_artist_id_to_event_data <- function(sk_artist_id) {
  library(jsonlite)
  # Build query URL and execute
  sk_api_key <- "OdCeFTr8qFUSwUVt"
  sk_query_url <- paste("https://api.songkick.com/api/3.0/artists/", sk_artist_id, 
                        "/gigography.json?apikey=", sk_api_key, sep="")
  sk_json <- fromJSON(sk_query_url)
  # extract Event IDs
  eventIDs <- as.character(sk_json[["resultsPage"]][["results"]][["event"]][["id"]])
  eventDates <- sk_json[["resultsPage"]][["results"]][["event"]][["start"]][["date"]]
  eventCities <- sk_json[["resultsPage"]][["results"]][["event"]][["location"]][["city"]]
  eventLngs <- as.double(sk_json[["resultsPage"]][["results"]][["event"]][["location"]][["lng"]])
  eventLats <- as.double(sk_json[["resultsPage"]][["results"]][["event"]][["location"]][["lat"]])
  # repeat on further pages (if any)
  totalPages <- ceiling(sk_json[["resultsPage"]][['totalEntries']] / sk_json[["resultsPage"]][['perPage']])
  if (totalPages > 1) {
    pageNums <- 2:totalPages
    for (pageNum in pageNums) {
      sk_query_url <- paste(sk_query_url,"&page=",pageNum,sep="")
      sk_json <- fromJSON(sk_query_url)
      eventIDs <- append(eventIDs, as.character(sk_json[["resultsPage"]][["results"]][["event"]][["id"]]))
      eventDates <- append(eventDates, sk_json[["resultsPage"]][["results"]][["event"]][["start"]][["date"]])
      eventCities <- append(eventCities, sk_json[["resultsPage"]][["results"]][["event"]][["location"]][["city"]])
      eventLngs <- append(eventLngs, as.double(sk_json[["resultsPage"]][["results"]][["event"]][["location"]][["lng"]]))
      eventLats <- append(eventLats, as.double(sk_json[["resultsPage"]][["results"]][["event"]][["location"]][["lat"]]))
    }
  }
  return (cbind(sk_artist_id, eventIDs, eventDates, eventCities, eventLngs, eventLats))
}


#*********************************************************************************************************

# MUSICBRAINZ UDFs

artist_name_to_platform_URL <- function(artist_name, platform){
  mb_gid <- artist_name_to_musicbrainz_gid(artist_name)
  mb_gid
  if (is.null(mb_gid)) {
    return("musicbrainz gid not found")
  } else {
    result <- musicbrainz_gid_to_platform_URLs(mb_gid, platform)
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

musicbrainz_gid_to_platform_URL <- function(musicbrainz_gid, platform) {
  if (is.null(musicbrainz_gid)) {
    return(NULL)
  }
  library(jsonlite)
  # building url for further musicbrainz api query to include 'relationship' URLs
  musicbrainz_query_url <- paste('http://musicbrainz.org/ws/2/artist/', musicbrainz_gid, '?inc=url-rels', sep="")
  # execute second musicbrainz api query
  mb_json <- fromJSON(musicbrainz_query_url)
  # extract URL for specified platform
  result <- mb_json$relations$url$resource[mb_json$relations$type==platform]
  return(result)
}