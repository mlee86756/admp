library(httr)
library(jsonlite)

# define artist string to search for
artist <- 'eminem'

# build url for musicbrainz api query with artist search
json_url_for_mb_gid <- paste('http://musicbrainz.org/ws/js/artist?limit=1&q=',artist,'&inc=url-rels',sep="")
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

# extract songkick ID from songkick URL
songkick_id <- basename(songkick_url)