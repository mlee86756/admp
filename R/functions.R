## This defines functions

library(dplyr)


# Function to run some other function that creates a list of lists, and return it as a data frame
data_frame_via_lapply <- function(data, udf) {
  results <- lapply(data, udf)
  return(as.data.frame(do.call(rbind, results)))
}