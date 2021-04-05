# internals.R


# Project : saison_cyclable_qc
# Author  : Jeremie Boudreault
# Email   : JeremieBoudreault11@gmail.com
# Depends : R (v3.6.3)
# License : ---



# Globals variables ------------------------------------------------------------


# Names for the columns of the station file.
names_stns <- c(
    "NAME",
    "PROVINCE",
    "CLIMATE_ID",
    "STATION_ID",
    "OMM_ID",
    "TC_ID",
    "LATITUDE",
    "LONGITUDE",
    "LATITUDE_PROJ",
    "LONGITUDE_PROJ",
    "ALTITUDE",
    "YEAR_START",
    "YEAR_END",
    "YEAR_START_H",
    "YEAR_END_H",
    "YEAR_START_D",
    "YEAR_END_D",
    "YEAR_START_M",
    "YEAR_END_M"
)

# Names for the weather data files.
names_wdata <- list(

    # Geo -------------------------
    LONGITUDE           = "GEO",
    LATITUDE            = "GEO",

    # IDs -------------------------
    NAME                = "ID",
    CLIMATEID           = "ID",

    # Dates -----------------------
    DATETIME            = "DATE",
    YEAR                = "DATE",
    MONTH               = "DATE",
    DAY                 = "DATE",

    # Values and flags ------------
    DATAQUALITY         = "FLAG",
    TEMP_MAX            = "VALUE",
    TEMP_MAX_FLAG       = "FLAG",
    TEMP_MIN            = "VALUE",
    TEMP_MIN_FLAG       = "FLAG",
    TEMP_MEAN           = "VALUE",
    TEMP_MEAN_FLAG      = "FLAG",
    HEAT_DAYS_DEG       = "VALUE",
    HEAT_DAYS_DEG_FLAG  = "FLAG",
    COOL_DAYS_DEG       = "VALUE",
    COOL_DAYS_DEG_FLAG  = "FLAG",
    RAIN_TOT            = "VALUE",
    RAIN_TOT_FLAG       = "FLAG",
    SNOW_TOT            = "VALUE",
    SNOW_TOT_FLAG       = "FLAG",
    PREC_TOT            = "VALUE",
    PREC_TOT_FLAG       = "FLAG",
    SNOW_GRND           = "VALUE",
    SNOW_GRND_FLAG      = "FLAG",
    MAX_GUST_DIR        = "VALUE",
    MAX_GUST_DIR_FLAG   = "FLAG",
    MAX_GUST_SPEED      = "VALUE",
    MAX_GUST_SPEED_FLAG = "FLAG"
)


# Internal functions -----------------------------------------------------------


# Approximatly equal function.
`%~=%` <- function(x, y, tol = 0.05) {
    return(abs(x - y) < tol)
}

# Apply a function and return a data.table.
dtlapply <- function(X, FUN, ...) {
    do.call(rbind, lapply(X, FUN, ...))
}

# Day of year to DD/MM format.
j_to_date <- function(j, leap = FALSE) {
    ndays <- c(31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31)
    if (leap) ndays[2L] <- ndays[2L] + 1L
    cndays <- c(0, cumsum(ndays))
    month <- which((j - cndays) <= 0)[1L] - 1L
    day <- j - cndays[month]
    if (nchar(month) == 1L) month <- paste0("0", month)
    if (nchar(day) == 1L) day <- paste0("0", day)
    return(paste0(day, "-", month))
}

