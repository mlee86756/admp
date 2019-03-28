library(jsonlite)


# SONGKICK UDFS

artist_name_to_songkick_artist_id <- function(artist_name){
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