library(jsonlite)

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
  # building url for further musicbrainz api query to include 'relationship' URLs
  musicbrainz_query_url <- paste('http://musicbrainz.org/ws/2/artist/', musicbrainz_gid, '?inc=url-rels', sep="")
  # execute second musicbrainz api query
  mb_json <- fromJSON(musicbrainz_query_url)
  # extract URL for specified platform
  result <- mb_json$relations$url$resource[mb_json$relations$type==platform]
  return(result)
}