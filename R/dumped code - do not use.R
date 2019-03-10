# events <- GET("https://app.ticketmaster.com/discovery/v2/events.json?classificationName=music&dmaID=604&apikey=NqcnLGc44dacGS0uZClA8U3L5Gj3OnEs") %>%
#   content()

# events$`_embedded`$events[[20]]$name
# events$`_embedded`$events[[20]]$dates$start$localDate
# events$`_embedded`$events[[20]]$dates$start$localTime
# events$`_embedded`$events[[20]]$classifications[[1]]$genre$name
# events$`_embedded`$events[[20]]$priceRanges[[1]]$min
# events$`_embedded`$events[[20]]$priceRanges[[1]]$max

# get data from songkick
# artist <- GET("https://api.songkick.com/api/3.0/search/artists.json?apikey={your_api_key}&query={Sia}") %>%
#   content()
