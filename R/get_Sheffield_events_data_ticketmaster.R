# This script is getting data on events in Sheffield

# Upload libraries
library(httr)
library(jsonlite)
library(xml2)
library(dplyr)
library(rlist)


# Create API elements -----------------------------------------------------

url <- "https://app.ticketmaster.com/discovery/v2/events"
apikey <- "?apikey=NqcnLGc44dacGS0uZClA8U3L5Gj3OnEs"
SheffieldCityCentre <- "&latlong=53.3812013,-1.4723287"
radius <- "&radius=10&unit=km"
source <- "&source=ticketmaster"
dates <- "&startDateTime=2019-03-29T10:59:00Z&endDateTime=2019-12-31T11:00:00Z"
page <- "&page="

# Create functions --------------------------------------------------------

# this function gets data from different places of the api content and puts it in a dataframe

#
apicontent <- GET(paste0(url, apikey, SheffieldCityCentre, radius, source, dates)) %>% 
  content()
totalPages <- apicontent$page$totalPages


loop_pages <- function(i) {
events_on_page <- GET(paste0(url, apikey, SheffieldCityCentre, radius, source, dates, page, i)) %>% content()
list_events <- events_on_page[[1]]
all_events <- list.append(list_events)
}

all_events <- lapply(1:totalPages, loop_pages)

collect_events <- function(i, j) {
  event_name <- ifelse(is.null(all_events[[i]]$events[[j]]$name), NA, all_events[[i]]$events[[1]]$name)
  event_date <- ifelse(is.null(all_events[[i]]$events[[j]]$dates$start$localDate), NA, all_events[[i]]$events[[1]]$dates$start$localDate)
  event_time <- ifelse(is.null(all_events[[i]]$events[[j]]$dates$start$localTime), NA, all_events[[i]]$events[[1]]$dates$start$localTime)
  event_type <- ifelse(is.null(all_events[[i]]$events[[j]]$classifications[[1]]$genre$name), NA, all_events[[i]]$events[[1]]$classifications[[1]]$genre$name)
  price_min <- ifelse(is.null(all_events[[i]]$events[[j]]$priceRanges[[1]]$max), NA, all_events[[i]]$events[[1]]$priceRanges[[1]]$max)
  price_max <- ifelse(is.null(all_events[[i]]$events[[j]]$priceRanges[[1]]$min), NA, all_events[[i]]$events[[1]]$priceRanges[[1]]$min)
  venue_name <- ifelse(is.null(all_events[[i]]$events[[j]]$name), NA, all_events[[i]]$events[[1]]$name)
  venue_postalcode <- ifelse(is.null(all_events[[i]]$events[[j]]$`_embedded`$venues[[1]]$postalCode), NA, all_events[[i]]$events[[1]]$`_embedded`$venues[[1]]$postalCode)
  longitude <- ifelse(is.null(all_events[[i]]$events[[j]]$`_embedded`$venues[[1]]$location$longitude), NA, all_events[[i]]$events[[1]]$`_embedded`$venues[[1]]$location$longitude)
  latitude <- ifelse(is.null(all_events[[i]]$events[[j]]$`_embedded`$venues[[1]]$location$latitude), NA, all_events[[i]]$events[[1]]$`_embedded`$venues[[1]]$location$latitude)
  parking <- ifelse(is.null(all_events[[i]]$events[[j]]$`_embedded`$venues[[1]]$parkingDetail), NA, all_events[[i]]$events[[1]]$`_embedded`$venues[[1]]$parkingDetail)
  data.frame("Event Name" = event_name,
             "Event Date" = event_date,
             "Event Time" = event_time, 
             "Event Type" = event_type,
             "Standard Price Min" = price_min,
             "Standard Price Max" = price_max, 
             "Venue Name" = venue_name,
             "Venue Postcode" = venue_postalcode,
             "Venue Latitude" = latitude,
             "Venue Longitude" = longitude, 
             "Venue Parking" = parking)
}


events_data <- lapply(1:length(all_events), collect_events) %>% 
  bind_rows() 







# Get data from Ticketmaster ----------------------------------------------
# I used my own api Key, this needs replacing with your own key from: https://developer.ticketmaster.com/products-and-docs/apis/getting-started/


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



# create table with data 
events_tb <- lapply(1:length(events$`_embedded`$events), collect_events) %>% 
  bind_rows() 

# format date from character to date
events_tb$date <- as.Date(events_tb$date)

# sort in date ascending order 
events_tb <- events_tb %>% 
  arrange(date)


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



event_name <- all_events[[i]]$events[[j]]$name
event_date <- all_events[[i]]$events[[j]]$dates$start$localDate
event_type <- all_events[[i]]$events[[j]]$classifications[[1]]$genre$name
price_min <- all_events[[i]]$events[[j]]$priceRanges[[1]]$min
price_max <- all_events[[i]]$events[[j]]$priceRanges[[1]]$max
venue_name <- all_events[[i]]$events[[j]]$`_embedded`$venues[[1]]$name
venue_postalcode <- all_events[[i]]$events[[j]]$`_embedded`$venues[[1]]$postalCode
venue_longitude <- all_events[[i]]$events[[j]]$`_embedded`$venues[[1]]$location$longitude
venue_latitude <- all_events[[i]]$events[[j]]$`_embedded`$venues[[1]]$location$latitude
parking_info <- all_events[[i]]$events[[j]]$`_embedded`$venues[[1]]$parkingDetail