# s1_fetch_weather_data.R


# Project : saison_cyclable_qc
# Author  : Jeremie Boudreault
# Email   : JeremieBoudreault11@gmail.com
# Depends : R (v3.6.3)
# License : ---



# Libraries --------------------------------------------------------------------


library(data.table)
library(ggplot2)


# Functions and globals --------------------------------------------------------


source(file.path("R", "internals.R"))


# Imports ----------------------------------------------------------------------


# Import the list of the weather stations in Canada.
stns <- data.table::fread(
    file.path("data", "weather", "stations_weather_can_fr.csv")
)

# Update names.
names(stns) <- names_stns


# Extract Airport Station ID ---------------------------------------------------


# Coordinates of Quebec Airport.
airport_lat  <- 46.79
airport_long <- -71.39

# Extract stations close enough to YQB.
stns_airport <- stns[LATITUDE  %~=% airport_lat &
                     LONGITUDE %~=% airport_long,
                     .(NAME,
                       STATION_ID,
                       YEAR_START_D,
                       YEAR_END_D)]

# Take a look at what we've got.
stns_airport


# Weather Can API --------------------------------------------------------------


api <- paste0(
    "https://climate.weather.gc.ca/climate_data/bulk_data_e.html?",
    "format=csv&stationID=stn_id&Year=year&Month=1&Day=14",
    "&timeframe=2&submit=Download+Data"
)


# Function to download data from the API ---------------------------------------


fetch_data <- function(stn) {

    # Extract relevant information.
    stn_id     <- stn$STATION_ID
    year_start <- stn$YEAR_START_D
    year_end   <- stn$YEAR_END_D

    # Update API for the current query.
    url <- gsub("stn_id", stn_id, api)

    # Apply to all year.
    lapply(

        # Years.
        X   = seq.int(max(year_start, 1950L), year_end),

        # Function.
        FUN = function(w) {

            # Generate a specific query.
            url_i <- gsub("year", w, url)

            # Read table
            tbl <- data.table::fread(url_i)

            # Save file
            data.table::fwrite(
                x    = tbl,
                file = file.path(
                    "data", "weather", "airport",
                    sprintf("daily_stn_id_%s_year_%s.csv", stn_id, w)
                )
            )

        }
    )

    # Return NULL invisibly.
    return(invisible(NULL))

}

# Fetch data for the 3 stations ------------------------------------------------


fetch_data(stns_airport[1L, ])
fetch_data(stns_airport[2L, ])
fetch_data(stns_airport[3L, ])

