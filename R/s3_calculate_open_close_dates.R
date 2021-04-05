# s3_calculate_open_close_dates.R


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


data <- qs::qread(
    file.path("out", "quebec_airport_data.qs")
)



# Opening dates for the cycling network ----------------------------------------


season_opening <- as.integer(format(as.Date("2019-05-01"), "%j"))
season_closing <- as.integer(format(as.Date("2019-10-31"), "%j")) - 365


# Plot snow on ground ----------------------------------------------------------


ggplot(
) +
geom_rect(
    mapping = aes(
        xmin = -61,
        xmax = 121,
        ymin = -Inf,
        ymax = Inf,
    ),
    fill  = rgb(0, 0, 1),
    alpha = 0.05
) +
geom_line(
    data    = data,
    mapping = aes(
        x = DAYOFYEAR,
        y = SNOW_GRND,
        group = as.factor(WYEAR)
    ),
    color = rgb(0, 0, 0, 0.2)
) +
scale_x_continuous(
    limits = c(-122, 182),
    breaks = c(-122, -61, 0, 60, 121, 182),
    labels = c("Sep", "Nov", "Jan.", "Mars", "Mai",  "Juil")
) +
geom_vline(
    xintercept = c(-61, 121),
    lwd        = 1,
    color      = "darkblue"
) +
labs(
    title   = "Neige au sol à l'aéroport de Québec",
    subtitle = "1956-2020"
)


# Main function to get optimal opening and closing dates -----------------------


calculate_oc_dates <- function(
    wyear,                   # A winter year of data
    snow_qty_close = 1L,     # Quantity of snow on ground to close the network
    n_days_close   = 1L,     # Consecutive number of day above threshold to close
    snow_qty_open  = 0L,     # Quantity of snow on ground to open the network
    n_days_open    = 3L,     # Consecutive number of days below thresold to open
    delay_open     = 0L,    # Delay before opening (cleaning, etc.)
    print_plot     = TRUE    # Plotting the results
) {

    # Extract data.
    data_close <- data[WYEAR == wyear, ]
    data_open <- data[WYEAR == wyear & DAYOFYEAR >= 0L, ]

    # Calculate runs of <SNOW_GRND> > snow_qty.
    runs_close <- rle(data_close$SNOW_GRND >= snow_qty_close)
    runs_open <- rle(data_open$SNOW_GRND <= snow_qty_open)

    # Add the date at which
    runs_close$date <- c(0, cumsum(runs_close$lengths)[1:length(runs_close$lengths)])
    runs_open$date <- c(0, cumsum(runs_open$lengths)[1:length(runs_open$lengths)])

    # Extract the moment i for closing.
    i_close <- runs_close$date[which(
        runs_close$values == TRUE &
        runs_close$lengths >= n_days_close
    )][1L]

    # Extract the moment i for opening.
    i_open <- runs_open$date[which(
        runs_open$values == TRUE &
        runs_open$lengths >= n_days_open
    )][1L]

    # Extract the closing date.
    date_close <- data_close[i_close, DAYOFYEAR]
    date_open <- data_open[i_open, DAYOFYEAR + delay_open + 1L]

    # Plot is asked
    if (print_plot) {
        p <- ggplot(
            data    = data_close,
            mapping = aes(
                x = DAYOFYEAR,
                y = SNOW_GRND
            )
        ) +
        geom_line(
        ) +
        geom_vline(
            xintercept = date_close,
            lwd        = 1.1,
            col        = "darkred",
        ) +
        geom_vline(
            xintercept = date_open,
            lwd        = 1.1,
            col        ="darkgreen"
        ) +
        labs(
            title = wyear
        ) +
        scale_x_continuous(
            limits = c(-122, 183),
            breaks = c(-122, -61, 0, 61, 122, 183),
            labels = c("Sep.", "Nov.", "Jan.", "Mar.", "Ma.", "Jul.")
        )
        print(p)
    }

    # Return return as a list.
    return(data.table::data.table(
        WYEAR      = wyear,
        DAY_CLOSE  = date_close,
        DAY_OPEN   = date_open
    ))

}


# Pessimist scenario -----------------------------------------------------------


# Note : In this scenario, the cycling network :
#        > Close before we have 3 consecutive days with >= 1cm accumulation
#        > Open when we have 15 days with <= 0cm accumulation + 10 days delay.
res_pes <- dtlapply(
    X              = sort(unique(data$WYEAR)),
    FUN            = calculate_oc_dates,
    snow_qty_close = 1L,
    n_days_close   = 3L,
    snow_qty_open  = 0L,
    n_days_open    = 15L,
    delay_open     = 10L,
    print_plot     = FALSE
)

# Opening and closing dates.
open_1999_pes <- floor(res_pes[WYEAR >= 1980 & WYEAR <= 1999, mean(DAY_OPEN)])
open_2020_pes <- floor(res_pes[WYEAR >= 2000 & WYEAR <= 2020, mean(DAY_OPEN)])
close_1999_pes <- floor(res_pes[WYEAR >= 1980 & WYEAR <= 1999, mean(DAY_CLOSE)])
close_2020_pes <- floor(res_pes[WYEAR >= 2000 & WYEAR <= 2020, mean(DAY_CLOSE)])

# Pessimist results 1980-1999.
message(sprintf(
    "Scénario pessimiste : saison cyclable du %s au %s (%s jours). [1980-1999]",
    j_to_date(open_1999_pes),
    j_to_date(close_1999_pes + 365),
    366 - (open_1999_pes - close_1999_pes)
))

# Pessimist results 2000-2020.
message(sprintf(
    "Scénario pessimiste : saison cyclable du %s au %s (%s jours). [2000-2020]",
    j_to_date(open_2020_pes),
    j_to_date(close_2020_pes + 365),
    366 - (open_2020_pes - close_2020_pes)
))


# Optimistic scenario ----------------------------------------------------------


# Note : In this scenario, the cycling network :
#        > Close before we have 5 consecutive days with >= 3cm accumulation
#        > Open when we have 5 days with <= 2cm accumulation + 10 days delay.
res_opt <- dtlapply(
    X              = sort(unique(data$WYEAR)),
    FUN            = calculate_oc_dates,
    snow_qty_close = 3L,
    n_days_close   = 5L,
    snow_qty_open  = 2L,
    n_days_open    = 5L,
    delay_open     = 10L,
    print_plot     = FALSE
)

# Opening date.
open_1999_opt  <- floor(res_opt[WYEAR >= 1980 & WYEAR <= 1999, mean(DAY_OPEN)])
open_2020_opt  <- floor(res_opt[WYEAR >= 2000 & WYEAR <= 2020, mean(DAY_OPEN)])
close_1999_opt <- floor(res_opt[WYEAR >= 1980 & WYEAR <= 1999, mean(DAY_CLOSE)])
close_2020_opt <- floor(res_opt[WYEAR >= 2000 & WYEAR <= 2020, mean(DAY_CLOSE)])


# Optimistic results 1980-1999.
message(sprintf(
    "Scénario optimiste : saison cyclable du %s au %s (%s jours). [1980-1999]",
    j_to_date(open_1999_opt),
    j_to_date(close_1999_opt + 365),
    366 - (open_1999_opt - close_1999_opt)
))

# Pessimist results 2000-2020.
message(sprintf(
    "Scénario optimistie : saison cyclable du %s au %s (%s jours). [2000-2020]",
    j_to_date(open_2020_opt),
    j_to_date(close_2020_opt + 365),
    366 - (open_2020_opt - close_2020_opt)
))
