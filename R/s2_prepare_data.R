# s2_prepare_data.R


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


# List all available files in data/weather/airport.
files <- list.files(file.path("data", "weather", "airport"))

# Read all files and combine them.
data <- do.call(
    what = rbind,
    arg  = lapply(
        X   = file.path("data", "weather", "airport", files),
        FUN = data.table::fread
    )
)

# Names of the columns.
oldnames <- names(data)
oldnames

# Rename columnsé
names(data) <- names(names_wdata)

# Result.
cbind(oldnames, names(data))


# Fix <MAX_GUST_SPEED> ---------------------------------------------------------


# Some values are stored as "<x", which we will convert to "x" for now.
data[, MAX_GUST_SPEED := as.numeric(gsub("<", "", MAX_GUST_SPEED))]


# Aggregate information for further analysis -----------------------------------


# Take the mean value available over the available information.
data_agg <- data[, lapply(.SD, mean, na.rm = TRUE),
                 .SDcols = names(names_wdata)[names_wdata == "VALUE"],
                 by      = c("DATETIME", "YEAR", "MONTH", "DAY")]


