## This defines functions

library(dplyr)




#*********************************************************************************************************

# GENERIC UDFS

data_frame_via_lapply <- function(data, udf) {
  results <- lapply(data, udf)
  return(as.data.frame(do.call(rbind, results)))
}


#*********************************************************************************************************

# SONGKICK UDFS

artist_name_to_songkick_artist_id <- function(artist_name){
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

songkick_events_by_artist_id <- function(artistID) {
  library(jsonlite)
  # Build query URL and execute
  sk_api_key <- "OdCeFTr8qFUSwUVt"
  sk_query_url <- paste("https://api.songkick.com/api/3.0/artists/", artistID, 
                        "/gigography.json?apikey=", sk_api_key, sep="")
  sk_json <- fromJSON(sk_query_url)
  # extract Event IDs
  eventID <- as.character(sk_json[["resultsPage"]][["results"]][["event"]][["id"]])
  venueID <- as.character(sk_json[["resultsPage"]][["results"]][["event"]][["venue"]][["id"]])
  eventDate <- sk_json[["resultsPage"]][["results"]][["event"]][["start"]][["date"]]
  eventCity <- sk_json[["resultsPage"]][["results"]][["event"]][["location"]][["city"]]
  eventLng <- as.double(sk_json[["resultsPage"]][["results"]][["event"]][["location"]][["lng"]])
  eventLat <- as.double(sk_json[["resultsPage"]][["results"]][["event"]][["location"]][["lat"]])
  # repeat on further pages (if any)
  totalPages <- ceiling(sk_json[["resultsPage"]][['totalEntries']] / sk_json[["resultsPage"]][['perPage']])
  if (totalPages > 1) {
    pageNums <- 2:totalPages
    for (pageNum in pageNums) {
      sk_query_url <- paste(sk_query_url,"&page=",pageNum,sep="")
      sk_json <- fromJSON(sk_query_url)
      eventID <- append(eventID, as.character(sk_json[["resultsPage"]][["results"]][["event"]][["id"]]))
      venueID <- append(venueID, as.character(sk_json[["resultsPage"]][["results"]][["event"]][["venue"]][["id"]]))
      eventDate <- append(eventDate, sk_json[["resultsPage"]][["results"]][["event"]][["start"]][["date"]])
      eventCity <- append(eventCity, sk_json[["resultsPage"]][["results"]][["event"]][["location"]][["city"]])
      eventLng <- append(eventLng, as.double(sk_json[["resultsPage"]][["results"]][["event"]][["location"]][["lng"]]))
      eventLat <- append(eventLat, as.double(sk_json[["resultsPage"]][["results"]][["event"]][["location"]][["lat"]]))
    }
  }
  return (cbind(artistID, eventID, venueID, eventDate, eventCity, eventLng, eventLat))
}

songkick_venue_retrieve_by_id <- function(venueID) {
  library(jsonlite)
  sk_api_key <- "OdCeFTr8qFUSwUVt"
  sk_venue_query_url <- paste("https://api.songkick.com/api/3.0/venues/", venueID, 
                              ".json?apikey=", sk_api_key, sep="")
  sk_json <- fromJSON(sk_venue_query_url)
  venueCapacity <- as.integer(sk_json[["resultsPage"]][["results"]][["venue"]][["capacity"]])
  if(length(venueCapacity) < 1) { venueCapacity = NA }
  venueLng <- as.double(sk_json[["resultsPage"]][["results"]][["venue"]][["lng"]])
  if(length(venueLng) < 1) { venueLng = NA }
  venueLat <- as.double(sk_json[["resultsPage"]][["results"]][["venue"]][["lat"]])
  if(length(venueLat) < 1) { venueLat = NA }
  return (cbind(venueID, venueCapacity, venueLng, venueLat))
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