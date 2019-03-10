# This script is getting data from api

# Upload libraries
library(httr)
library(jsonlite)
library(xml2)
library(dplyr)

#get data from songkick
# artist <- GET("https://api.songkick.com/api/3.0/search/artists.json?apikey={your_api_key}&query={Sia}") %>%
#   content()


#get data from ticketmaster: I used my own apiKey, this needs replacing 
events <- GET("https://app.ticketmaster.com/discovery/v2/events.json?classificationName=music&city=Sheffield&apikey=NqcnLGc44dacGS0uZClA8U3L5Gj3OnEs") %>%
  content()

# events <- GET("https://app.ticketmaster.com/discovery/v2/events.json?classificationName=music&dmaID=604&apikey=NqcnLGc44dacGS0uZClA8U3L5Gj3OnEs") %>%
#   content()

# events$`_embedded`$events[[20]]$name
# events$`_embedded`$events[[20]]$dates$start$localDate
# events$`_embedded`$events[[20]]$dates$start$localTime
# events$`_embedded`$events[[20]]$classifications[[1]]$genre$name
# events$`_embedded`$events[[20]]$priceRanges[[1]]$min
# events$`_embedded`$events[[20]]$priceRanges[[1]]$max

collect_events <- function(i) {
  name <- ifelse(is.null(events$`_embedded`$events[[i]]$name), NA, events$`_embedded`$events[[i]]$name)
  date <- ifelse(is.null(events$`_embedded`$events[[i]]$dates$start$localDate), NA, events$`_embedded`$events[[i]]$dates$start$localDate)
  time <- ifelse(is.null(events$`_embedded`$events[[i]]$dates$start$localTime), NA, events$`_embedded`$events[[i]]$dates$start$localTime)
  genre <- ifelse(is.null(events$`_embedded`$events[[i]]$classifications[[1]]$genre$name), NA, events$`_embedded`$events[[i]]$classifications[[1]]$genre$name)
  pricemin <- ifelse(is.null(events$`_embedded`$events[[i]]$priceRanges[[1]]$min), NA, events$`_embedded`$events[[i]]$priceRanges[[1]]$min)
  pricemax <- ifelse(is.null(events$`_embedded`$events[[i]]$priceRanges[[1]]$min), NA, events$`_embedded`$events[[i]]$priceRanges[[1]]$min)
  data.frame("name" = name,
            "date" = date,
            "time" = time, 
            "genre" = genre,
            "min price" = pricemin,
            "max price" = pricemax)
}

events_tb <- lapply(1:length(events$`_embedded`$events), collect_events) %>% 
  bind_rows() 

events_tb$date <- as.Date(events_tb$date)

events_tb <- events_tb %>% 
  arrange(date)


