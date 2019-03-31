# This script is getting data on events in Sheffield

# Upload libraries
library(httr)
library(jsonlite)
library(xml2)
library(dplyr)
library(rlist)
library(tidyverse)


# Create API elements -----------------------------------------------------

url <- "https://app.ticketmaster.com/discovery/v2/events"
apikey <- "?apikey=NqcnLGc44dacGS0uZClA8U3L5Gj3OnEs"
SheffieldCityCentre <- "&latlong=53.3812013,-1.4723287"
radius <- "&radius=20&unit=km"
source <- "&source=ticketmaster"
dates <- "&startDateTime=2019-03-29T10:59:00Z&endDateTime=2019-12-31T11:00:00Z"
page <- "&page="

# Get events nested list --------------------------------------------------------

# count total number of pages
apicontent <- GET(paste0(url, apikey, SheffieldCityCentre, radius, source, dates)) %>% 
  content()
totalPages <- apicontent$page$totalPages

# function that loops through pages getting a list of all elements
get_content <- function(page_number) {
events_on_page <- GET(paste0(url, apikey, SheffieldCityCentre, radius, source, dates, page, page_number)) %>% content()
}

# list of list for all events from all pages
events <- lapply(1:totalPages, get_content)


# Get data from the API ----------------------------------------------------


# initialise lists & variable
events_list <- list()
dates_list <- list()
times_list <- list()
genres_list <- list()
minprices_list <- list()
maxprices_list <- list()
venues_list <- list()
lon_list <- list()
lat_list <- list()
parking_list <- list()

all_events_list <- list()
all_dates_list <- list()
all_times_list <- list()
all_genres_list <- list()
all_minprices_list <- list()
all_maxprices_list <- list()
all_venues_list <- list()
all_lon_list <- list()
all_lat_list <- list()
all_parking_list <- list()

j <- 1

# loop through pages and get all events
while (j < 11) {
  for (i in 1:20) {
    # get names
    event_name <- paste0('name:', i)
    name <- list(events[[j]]$`_embedded`$events[[i]]$name)
    events_list[[event_name]] <- name
    # get dates
    date_name <- paste0('name:', i)
    dates <- list(events[[j]]$`_embedded`$events[[i]]$dates$start$localDate)
    dates_list[[date_name]] <- dates
    # get time
    time_name <- paste0('name:', i)
    times <- list(events[[j]]$`_embedded`$events[[i]]$dates$start$localTime)
    times_list[[time_name]] <- times
    # get genre
    genre_name <- paste0('name:', i)
    genres <- list(events[[j]]$`_embedded`$events[[i]]$classifications[[1]]$genre$name)
    genres_list[[genre_name]] <- genres
    # get standard minimum price
    minprice_name <- paste0('name:', i)
    minprices <- list(events[[j]]$`_embedded`$events[[i]]$priceRanges[[1]]$min)
    minprices_list[[minprice_name]] <- minprices
    # get standard maximum price
    maxprice_name <- paste0('name:', i)
    maxprices <- list(events[[j]]$`_embedded`$events[[i]]$priceRanges[[1]]$max)
    maxprices_list[[maxprice_name]] <- maxprices
    # get venues
    venue_name <- paste0('name:', i)
    venues <- list(events[[j]]$`_embedded`$events[[i]]$`_embedded`$venues[[1]]$name)
    venues_list[[venue_name]] <- venues
    # get longitude for venue
    lon_name <- paste0('name:', i)
    longs <- list(events[[j]]$`_embedded`$events[[i]]$`_embedded`$venues[[1]]$location$longitude)
    lon_list[[lon_name]] <- longs
    # get latitude for venue
    lat_name <- paste0('name:', i)
    lats <- list(events[[j]]$`_embedded`$events[[i]]$`_embedded`$venues[[1]]$location$latitude)
    lat_list[[lat_name]] <- lats
    # get parking information
    parking_name <- paste0('name:', i)
    parking <- list(events[[j]]$`_embedded`$events[[i]]$`_embedded`$venues[[1]]$parkingDetail)
    parking_list[[parking_name]] <- parking
    }
  
  all_events_list[[j]] <- unlist(events_list, recursive = FALSE, use.names = FALSE)
  all_dates_list[[j]] <- unlist(dates_list, recursive = FALSE, use.names = FALSE)
  all_times_list[[j]] <- unlist(times_list, recursive = FALSE, use.names = FALSE)
  all_genres_list[[j]] <- unlist(genres_list, recursive = FALSE, use.names = FALSE)
  all_minprices_list[[j]] <- unlist(minprices_list, recursive = FALSE, use.names = FALSE)
  all_maxprices_list[[j]] <- unlist(maxprices_list, recursive = FALSE, use.names = FALSE)
  all_venues_list[[j]] <- unlist(venues_list, recursive = FALSE, use.names = FALSE)
  all_lon_list[[j]] <- unlist(lon_list, recursive = FALSE, use.names = FALSE)
  all_lat_list[[j]] <- unlist(lat_list, recursive = FALSE, use.names = FALSE)
  all_parking_list[[j]] <- unlist(parking_list, recursive = FALSE, use.names = FALSE)
  
  j = j + 1
}

rm()

# simplify lists to ease manipulation into a dataframe 
events_final <- unlist(all_events_list, recursive = FALSE, use.names = FALSE)
dates_final <- unlist(all_dates_list, recursive = FALSE, use.names = FALSE)
times_final <- unlist(all_times_list, recursive = FALSE, use.names = FALSE)
genres_final <- unlist(all_genres_list, recursive = FALSE, use.names = FALSE)
minprices_final <- unlist(all_minprices_list, recursive = FALSE, use.names = FALSE)
maxprices_final <- unlist(all_maxprices_list, recursive = FALSE, use.names = FALSE)
venues_final <- unlist(all_venues_list, recursive = FALSE, use.names = FALSE)
longitude_final <- unlist(all_lon_list, recursive = FALSE, use.names = FALSE)
latitude_final <- unlist(all_lat_list, recursive = FALSE, use.names = FALSE)
parking_final <- unlist(all_parking_list, recursive = FALSE, use.names = FALSE)

# replace all NULLs with NAs so lenght of all lists is the same when combining into dataframe
for(i in 1:length(minprices_final)) {
  if(is.null(minprices_final[[i]])) {
    minprices_final[[i]] <- NA
  }
  if(is.null(events_final[[i]])) {
    events_final[[i]] <- NA
  }
  if(is.null(dates_final[[i]])) {
    dates_final[[i]] <- NA
  }
  if(is.null(times_final[[i]])) {
    times_final[[i]] <- NA
  }
  if(is.null(genres_final[[i]])) {
    genres_final[[i]] <- NA
  }
  if(is.null(maxprices_final[[i]])) {
    maxprices_final[[i]] <- NA
  }
  if(is.null(venues_final[[i]])) {
    venues_final[[i]] <- NA
  }
  if(is.null(longitude_final[[i]])) {
    longitude_final[[i]] <- NA
  }
  if(is.null(latitude_final[[i]])) {
    latitude_final[[i]] <- NA
  }
  if(is.null(parking_final[[i]])) {
    parking_final[[i]] <- NA
  }
}


# Create a dataframe and remove all rows with NA Events -----------------

events_dataframe <- do.call(bind_rows, Map(data.frame,
                           'Event Name' = events_final, 
                           'Date' = dates_final,
                           'Time' = times_final,
                           'Genre' = genres_final,
                           'Minimum Price' = minprices_final,
                           'Maximum Price' = maxprices_final,
                           'Venue' = venues_final, 
                           'Longitude' = longitude_final,
                           'Latitude' = latitude_final,
                           'Parking Info' = parking_final)) %>%
                filter(!is.na(Event.Name)) 


# remove objects from environment
rm(list=ls(pattern="_list"),
   name, dates, times, genres, minprices, maxprices, lats, longs, parking, venues, apicontent)
rm(list=ls(pattern="_final"))


# Save dataframe as csv -------------------------------------------------


events_dataframe$Date <- as.Date(events_dataframe$Date) 

events_dataframe <- arrange(events_dataframe, Date) 

write.csv(events_dataframe, "data/raw-data/Sheffield Events 2019.csv", row.names = FALSE)  
  