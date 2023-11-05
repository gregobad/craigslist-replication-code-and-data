### finalize SRDS prices data ###

library(tidyverse)
library(lubridate)
library(data.table)
library(readxl)
library(glue)

## change to directory where archive was extracted
data_dir <- "~/craigslist-replication-code-and-data/data"


## price file in wide format
prices <- read_dta(glue("{data_dir}/Classified_Prices/CLrates_final.dta")) %>%
  setDT
  
pricecols <- c("NPNAME1", grep("cl_daily", colnames(prices), value = T))
unitcols <- c("NPNAME1", grep("unit", colnames(prices), value = T))

price_vals <- prices[, ..pricecols] %>%
  melt(id.vars = "NPNAME1", value.name = "ClRatesdaily", variable.name = "year", variable.factor = FALSE) %>%
  .[, year := parse_number(year)]

price_units <- prices[, ..unitcols] %>%
  melt(id.vars = "NPNAME1", value.name = "unit", variable.name = "year", variable.factor = FALSE) %>%
  .[, year := parse_number(year)]

## add in some corrected values from Lorena
prices_lorena <- read_dta(glue("{data_dir}/Classified_Prices/CLrates_npcom.dta")) %>%
  setDT %>%
  setnames(old = c("cl_daily", "unit"), new = c("ClRatesdaily_corrected", "unit_corrected"))

prices <- price_vals[price_units, on = .(NPNAME1, year)]

prices <- prices_lorena[prices, on = .(NPNAME1, year)]

prices[!is.na(unit_corrected), unit := unit_corrected]
prices[!is.na(ClRatesdaily_corrected), ClRatesdaily := ClRatesdaily_corrected]

prices[, unit_corrected := NULL]
prices[, ClRatesdaily_corrected := NULL]

## add in some more corrected values from Lorena
prices_lorena <- read_dta(glue("{data_dir}/Classified_Prices/CLrates_temp700.dta")) %>%
  setDT %>%
  setnames(old = c("cl_daily", "unit"), new = c("ClRatesdaily_corrected", "unit_corrected"))

prices_lorena <- prices_lorena[!duplicated(prices_lorena)]

prices <- prices_lorena[prices, on = .(NPNAME1, year)]

prices[!is.na(unit_corrected), unit := unit_corrected]
prices[!is.na(ClRatesdaily_corrected), ClRatesdaily := ClRatesdaily_corrected]

prices[, price_corrected := !is.na(ClRatesdaily_corrected)]

## combine some unit categories
prices[grep("words", unit), unit := "word"]
prices[grep("count line", unit), unit := "line"]
prices[grep("agate line", unit), unit := "line"]
prices[grep("col[.]? inch", unit), unit := "col inch"]

# per-word prices have 2 distinct regimes
prices[unit == "word" & ClRatesdaily > 10, ClRatesdaily := as.numeric(NA)]

prices[, ClRatesdaily_winsorized := pmin(ClRatesdaily, quantile(ClRatesdaily, probs = 0.9, na.rm = TRUE)), by = .(unit, year)]

fwrite(prices, file = glue("{data_dir}/Classified_Prices/classif_prices_panel.csv"))

# average pre-period prices
price_bypaper_pre <- prices[year <= 2000,
    .(classif_rate = mean(ClRatesdaily, na.rm = T),
      classif_rate_winsor = mean(ClRatesdaily_winsorized, na.rm = T)),
    by = .(NPNAME1, unit)]

fwrite(price_bypaper_pre, file = glue("{data_dir}/Classified_Prices/classif_prices_pre2000.csv"))


## benchmark change over the 1995-2006 period
pricetrends <- prices[, .(avg_price = mean(ClRatesdaily_winsorized, na.rm=T)), by = .(year, unit)]

pricetrends %>% ggplot(aes(x = year, y = avg_price)) +
  geom_line(aes(group = unit, colour = unit))