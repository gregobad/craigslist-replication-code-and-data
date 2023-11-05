### Generate maps of Craigslist expansion

library(data.table)
library(tidyverse)
library(ggmap)
library(ggthemes)
library(lubridate)
library(glue)

theme_set(theme_few())

# change to location where archive was extracted
data_dir <- "~/craigslist-replication-code-and-data/data"
out_dir <- "~/craigslist-replication-code-and-data/output"

mapdata <- fread(glue("{data_dir}/craigslist_expansion/expansion_full_for_maps.csv"))

mapdata

us <- c(left = -126, bottom = 25, right = -66, top = 49)

mapdata[, entry_date := as.character(entry_year_month)]
mapdata[, entry_date := ym(paste0(substr(entry_date, 1,4), substr(entry_date, 7,8)))]


make_map <- function(
    data_subset,
    date_label,
    pointsize = 2
    ) {
    get_stamenmap(us, zoom = 5,
              maptype = "toner-background",
              color = "bw") %>%
        ggmap() +
        geom_point(aes(x = longitude, y = latitude),
                size = pointsize,
                colour = "gray40",
                data = data_subset) + 
        theme(axis.line = element_blank(),
            axis.text.x = element_blank(),
            axis.text.y = element_blank(),
            axis.ticks = element_blank(),
            axis.title.x = element_blank(),
            axis.title.y = element_blank(),
            legend.position = "none")
    
    ggsave(glue("{out_dir}/expansionmap_{date_label}.png"), 
        height = 5, width = 9.5
    )
}

make_map(mapdata[entry_date <= ymd("2000-10-01")], date_label = "2000", pointsize = 3)
make_map(mapdata[entry_date <= ymd("2005-09-01")], date_label = "2005", pointsize = 3)
make_map(mapdata, date_label = "2009", pointsize = 2)
