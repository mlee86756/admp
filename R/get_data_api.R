# This script is getting data using api

# Upload libraries
library(httr)
library(jsonlite)
library(xml2)
library(dplyr)


# get data from ticketmaster: I used my own api Key, this needs replacing with your own key from: https://developer.ticketmaster.com/products-and-docs/apis/getting-started/
events <- GET("https://app.ticketmaster.com/discovery/v2/events.json?classificationName=music&city=Sheffield&apikey=NqcnLGc44dacGS0uZClA8U3L5Gj3OnEs") %>%
  content()

# this function gets data from different places of the api content and puts it in a dataframe
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

# create table with data 
events_tb <- lapply(1:length(events$`_embedded`$events), collect_events) %>% 
  bind_rows() 

# format date from character to date
events_tb$date <- as.Date(events_tb$date)

# sort in date ascending order 
events_tb <- events_tb %>% 
  arrange(date)


