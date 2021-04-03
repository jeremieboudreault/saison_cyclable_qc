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


source(file.path("R", "functions", "internals.R"))


# Imports ----------------------------------------------------------------------


# List all available files in data/weather/airport.
files <- list.files(file.path("data", "weather", "airport"))

# Read all files and combine them.
data_all <- do.call(
    what = rbind,
    arg  = lapply(
        X   = file.path("data", "weather", "airport", files),
        FUN = data.table::fread
    )
)

# Names of the columns.
oldnames <- names(data_all)
oldnames

# Rename columnsé
names(data_all) <- names(names_wdata)

# Result.
cbind(oldnames, names(data_all))


# Fix <MAX_GUST_SPEED> ---------------------------------------------------------


# Some values are stored as "<x", which we will convert to "x" for now.
data_all[, MAX_GUST_SPEED := as.numeric(gsub("<", "", MAX_GUST_SPEED))]


# Aggregate information for further analysis -----------------------------------


# Take the mean value available over the available information.
data <- data_all[, lapply(.SD, mean, na.rm = TRUE),
                 .SDcols = names(names_wdata)[names_wdata == "VALUE"],
                 by      = c("DATETIME", "YEAR", "MONTH", "DAY")]


# Calculate a new <SNOW_TOT_APPROX> field --------------------------------------


# Calculate <PROP_FREEZE> as a portion of the day when it was below 0ºC.
data[, PROP_FREEZE := abs(TEMP_MIN/(TEMP_MAX - TEMP_MIN))]
data[TEMP_MIN <= 0 & TEMP_MAX <= 0, PROP_FREEZE := 1L]
data[TEMP_MIN >= 0 & TEMP_MAX >= 0, PROP_FREEZE := 0L]

# Calculate <SNOW_TOT_APPROX> as <PREC_TOT> x <PROP_FREEZE>.
data[, SNOW_TOT_APPROX := round(PREC_TOT * PROP_FREEZE, 1L)]

# Check first 20 values that it is allright.
data[1:20, .(PREC_TOT, SNOW_TOT, RAIN_TOT, SNOW_TOT_APPROX, TEMP_MAX, TEMP_MIN)]

# Calculate R2.
R2 <- data[, cor(
    x      = SNOW_TOT,
    y      = SNOW_TOT_APPROX,
    use    = "complete.obs",
    method = "pearson")^2
]

# Check adequation between <SNOW_TOT> and <SNOW_TOT_APPROX>.
ggplot(
    data    = data,
    mapping = aes(
        x = SNOW_TOT,
        y = SNOW_TOT_APPROX
    )
) +
geom_point(
) +
geom_abline(
    intercept = 0L,
    slope     = 1L,
    lwd       = 1.5,
    col       = "blue"
) +
labs(
    title    = "Adequation between measured snow quantity and approximation",
    subtitle = paste0("R2 = ", round(R2, 3L)),
    xlab     = "Measured snow quantity (cm)",
    ylab     = "Estimated snow quantity (cm)"
)

# Fill missing values with the approximation.
data[is.na(SNOW_TOT),  SNOW_TOT := SNOW_TOT_APPROX]
data[is.nan(SNOW_TOT), SNOW_TOT := SNOW_TOT_APPROX]


# Calculate winter year --------------------------------------------------------


# Calculate field <WYEAR> from july to july of next year.
data[, WYEAR := floor(YEAR + 0.5 + MONTH / 12)]

# Remove last winter year as it is incomplete.
data <- data[WYEAR != max(data$WYEAR), ]


# Export results for future use ------------------------------------------------


qs::qsave(
    x    = data,
    file = file.path("out", "quebec_airport_data.qs")
)

