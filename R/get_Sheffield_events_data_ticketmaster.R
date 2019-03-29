# This script is getting data using api

# Upload libraries
library(httr)
library(jsonlite)
library(xml2)
library(dplyr)



url <- "https://app.ticketmaster.com/discovery/v2/events"
apikey <- "apikey=NqcnLGc44dacGS0uZClA8U3L5Gj3OnEs"
SheffieldCityCentre <- "&latlong=53.3812013,-1.4723287"
radius <- "&radius=10&unit=km"
source <- "&source=ticketmaster"
dates <- "&startDateTime=2019-03-29T10:59:00Z&endDateTime=2019-12-31T11:00:00Z"
page1 <- "&page=1"
page2 <- "&page=2"

# Get data from Ticketmaster ----------------------------------------------
# I used my own api Key, this needs replacing with your own key from: https://developer.ticketmaster.com/products-and-docs/apis/getting-started/


url <- "https://app.ticketmaster.com/discovery/v2/events"
apikey <- "apikey=NqcnLGc44dacGS0uZClA8U3L5Gj3OnEs"
SheffieldCityCentre <- "&latlong=53.3812013,-1.4723287"
radius <- "&radius=10&unit=km"
source <- "&source=ticketmaster"
dates <- "&startDateTime=2019-03-29T10:59:00Z&endDateTime=2019-12-31T11:00:00Z"
page1 <- "&page=1"
page2 <- "&page=2"



events <- GET("https://app.ticketmaster.com/discovery/v2/events.json?classificationName=music&city=Sheffield&apikey=NqcnLGc44dacGS0uZClA8U3L5Gj3OnEs&page=2") %>%
  content()

events2 <- GET("https://app.ticketmaster.com/discovery/v2/events?apikey=NqcnLGc44dacGS0uZClA8U3L5Gj3OnEs&latlong=53.3812013,-1.4723287&radius=10&unit=km&source=ticketmaster&startDateTime=2019-03-29T10:59:00Z&endDateTime=2019-12-31T11:00:00Z&page=2") %>%
  content()

events1 <- GET("https://app.ticketmaster.com/discovery/v2/events?apikey=NqcnLGc44dacGS0uZClA8U3L5Gj3OnEs&latlong=53.3812013,-1.4723287&radius=10&unit=km&source=ticketmaster&startDateTime=2019-03-29T10:59:00Z&endDateTime=2019-12-31T11:00:00Z&page=1") %>%
  content()

events_1 <- lapply(1:length(events$`_embedded`$events1), collect_events) %>% 
  bind_rows() 

events_2 <- lapply(1:length(events$`_embedded`$events2), collect_events) %>% 
  bind_rows() 

# this function gets data from different places of the api content and puts it in a dataframe
collect_events <- function(i) {
  name <- ifelse(is.null(events$`_embedded`$events[[i]]$name), NA, events$`_embedded`$events[[i]]$name)
  date <- ifelse(is.null(events$`_embedded`$events[[i]]$dates$start$localDate), NA, events$`_embedded`$events[[i]]$dates$start$localDate)
  time <- ifelse(is.null(events$`_embedded`$events[[i]]$dates$start$localTime), NA, events$`_embedded`$events[[i]]$dates$start$localTime)
  genre <- ifelse(is.null(events$`_embedded`$events[[i]]$classifications[[1]]$genre$name), NA, events$`_embedded`$events[[i]]$classifications[[1]]$genre$name)
  pricemin <- ifelse(is.null(events$`_embedded`$events[[i]]$priceRanges[[1]]$min), NA, events$`_embedded`$events[[i]]$priceRanges[[1]]$min)
  pricemax <- ifelse(is.null(events$`_embedded`$events[[i]]$priceRanges[[1]]$min), NA, events$`_embedded`$events[[i]]$priceRanges[[1]]$min)
  venue <- ifelse(is.null(events$`_embedded`$events[[i]]$`_embedded`$venues[[1]]$name), NA, events$`_embedded`$events[[i]]$`_embedded`$venues[[1]]$name)
  longitude <- ifelse(is.null(events$`_embedded`$events[[i]]$`_embedded`$venues[[1]]$location$longitude), NA, events$`_embedded`$events[[i]]$`_embedded`$venues[[1]]$location$longitude)
  latitude <- ifelse(is.null(events$`_embedded`$events[[i]]$`_embedded`$venues[[1]]$location$latitude), NA, events$`_embedded`$events[[i]]$`_embedded`$venues[[1]]$location$latitude)
  parking <- ifelse(is.null(events$`_embedded`$events[[i]]$`_embedded`$venues[[1]]$parkingDetail), NA, events$`_embedded`$events[[i]]$`_embedded`$venues[[1]]$parkingDetail)
  data.frame("name" = name,
            "date" = date,
            "time" = time, 
            "genre" = genre,
            "min price" = pricemin,
            "max price" = pricemax, 
            "venue" = venue,
            "latitude" = latitude,
            "longitude" = longitude, 
            "parking" = parking)
}

# create table with data 
events_tb <- lapply(1:length(events$`_embedded`$events), collect_events) %>% 
  bind_rows() 

# format date from character to date
events_tb$date <- as.Date(events_tb$date)

# sort in date ascending order 
events_tb <- events_tb %>% 
  arrange(date)


