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


# Internal functions -----------------------------------------------------------


# Approximatly equal function.
`%~=%` <- function(x, y, tol = 0.05) {
    return(abs(x - y) < tol)
}
