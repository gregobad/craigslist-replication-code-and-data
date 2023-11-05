### regress newspapers.com measure of classifieds extent on E&P classified manager indicator
### and "first stage" diff in diff of page count on CL entry

library(tidyverse)
library(lubridate)
library(data.table)
library(haven)
library(fixest)
library(magrittr)
library(glue)

# setup for tables
setFixest_dict(c(post_CL_="Post-CL", 
                 classif_2000="Classif. Mgr.",
                 fips="County",
                 year="Year",
                 state="State",
                 statdist="District",
                 dma_2000="DMA",
                 cl_pages_corrected = "Average Classified Pages per Issue",
                 cl_pages_share = "Avg. Share of\nClassified Pages per Issue",
                 cl_pages_excluding = "Average Classified Pages per Issue",
                 classif_pg_ct = "Average Classified Pages per Issue",
                 classif_pg_frac = "Avg. Share of\nClassified Pages per Issue",
                 classif_pg_frac_sun = "Avg. Share of\nClassified Pages per Issue (Sun.)",
                 classif_rate = "Classified Rate",
                 classif_rate_winsor = "Classified Rate",
                 ClRatesdaily_winsorized = "Classified Rate",
                 log_cl_rate = "Log Classified Rate",
                 ep_std_name = "Newspaper",
                 unit = "Unit",
                 np_name = "Newspaper",
                 wkday = "Day-of-week"
                )
    )


fitstat_register(type = "mean_dv", alias = "Mean dependent variable",
                 fun = function(x) mean(x$fitted.values + x$residuals) )

setFixest_etable(digits = 3,
                fitstat = ~ n + r2 + mean_dv)

tablestyle <- style.tex(main = "aer",
                 fixef.suffix = " FEs",
                 fixef.where = "var",
                 fixef.title = "",
                 stats.title = "\\midrule",
                 tablefoot = F,
                 yesNo = c("Yes", "No"))



### BEGIN SCRIPT ###

## change to directory where archive was extracted
data_dir <- "~/craigslist-replication-code-and-data/data"
out_dir <- "~/craigslist-replication-code-and-data/output"
read_dtadt <- compose(as.data.table, read_dta)

## read craigslist panel
cl <- read_dtadt(glue("{data_dir}/master_data_newspaper_level.dta")) %>%
  setnames(old="NPNAME1", new="np_name") %>%
  .[largepaper == 0]

# fix some classif_mgr assignments
classif2000_fix <- fread(glue("{data_dir}/E&P/check_newspapers_id_classif2000.csv")) %>%
  .[, classif_2000_corrected := as.numeric(classif_2000_corrected)] %>%
  setnames(old = "ep_std_name", new = "np_name")

cl <- classif2000_fix[cl, on = .(np_name)] %>%
  .[year == 2000 & !is.na(classif_2000_corrected), classif := classif_2000_corrected]

# year 2000 values
np_2000 <- cl[year == 2000,
             .(np_name,
               classif_2000 = classif,
               circ_2000 = circ,
               headcount_2000 = headcount,
               jobscount_2000 = jobscount,
               freq_2000 = freq,
               ad_rate_2000 = ad_rate,
               log_pop_2000 = log_pop,
               num_ISPs_2000 = num_ISPs,
               circ_pop_2000 = circ_2000 / exp(log_pop_2000),
               income_2000,
               pct_college_2000,
               pct_rental_2000,
               population_2000,
               age_2000,
               unemployment_2000,
               pop_density_2000,
               share_urban_2000,
               share_white_2000,
               share_black_2000,
               share_hisp_2000,
               pres_turnout_2000,
               pres_repshare_2000,
               num_pages_2000
               )]

## load counts of classified pages
load(glue("{data_dir}/Newspapers.com/npcom_classified_pages_with_totals_corrected.RData"))

# first: aggregate to paper level, restricting to pre-2000 period
npcom_pages_bypaper_pre <- npcom_pages[year <= 2000,
      .(cl_pages_corrected = mean(cl_pages_corrected, na.rm = T),
       classif_pg_frac = sum(cl_pages_corrected, na.rm = T) / sum(total_pages, na.rm = T),
       total_pages = mean(total_pages, na.rm = T),
       issues = .N),
      by = .(np_name, wkday)] %>%
  .[np_2000, on = .(np_name), nomatch = 0]

npcom_pages_bypaper_pre[, cl_pages_share := cl_pages_corrected / num_pages_2000]


pages_pre <- feols(cl_pages_share ~ classif_2000 + circ_pop_2000 + total_pages +
                                                          log_pop_2000 + num_ISPs_2000 + income_2000 + pct_college_2000 + pct_rental_2000 + age_2000 + unemployment_2000 + pop_density_2000 + share_urban_2000 + share_white_2000 + share_black_2000 + share_hisp_2000 + pres_turnout_2000 + pres_repshare_2000
                                                          | wkday,
                          data = npcom_pages_bypaper_pre,
                          weights = ~ issues)


##
## Same, but on classified price
##

prices <- fread(glue("{data_dir}/Classified_Prices/classif_prices_pre2000.csv")) %>%
  setnames(old = "NPNAME1", new = "np_name")

np_2000 <- np_2000[prices, on = .(np_name)]
np_2000[, log_cl_rate := log(classif_rate)]

clrate_pre <- feols(log_cl_rate ~ classif_2000 + circ_pop_2000 + num_pages_2000 +
                                                          log_pop_2000 + num_ISPs_2000 + income_2000 + pct_college_2000 + pct_rental_2000 + age_2000 + unemployment_2000 + pop_density_2000 + share_urban_2000 + share_white_2000 + share_black_2000 + share_hisp_2000 + pres_turnout_2000 + pres_repshare_2000
                                                          | unit,
                          data = np_2000)


##
## data for diff in diff on classified pages
##

## diff in diff on yearly average pages
npcom_pg_avg <- npcom_pages[,.(total_npcom_pages = mean(total_pages, na.rm = T),
                               classif_pg_ct = mean(cl_pages_corrected, na.rm = T),
                               issues = .N),
                            by=.(year, np_name, wkday)]


ep_npcom <- cl[npcom_pg_avg, on=.(year, np_name), nomatch = 0]
ep_npcom[, classif_pg_frac := classif_pg_ct / num_pages]

## benchmark for decline
ep_npcom[, .(pg_frac_mean = mean(classif_pg_frac, na.rm=T), pg_frac_med = median(classif_pg_frac,na.rm=T)), by = .(year)]


## setup for regression specifications
ep_npcom[,url_1:=if_else(ever_CL_==1, url, county_state)]

##
## data for diff in diff on classified prices
##

prices <- fread(glue("{data_dir}/Classified_Prices/classif_prices_panel.csv")) %>%
  setnames(old = "NPNAME1", new = "np_name")

prices[, log_cl_rate := log(ClRatesdaily)]

ep_price <- cl[prices, on=.(year, np_name), nomatch=0]


ep_price[,url_1:=if_else(ever_CL_==1, url, county_state)]



##
## combined "first stage" tables
##
classif_dd_fullcontrols <- feols(classif_pg_frac ~
  post_CL_ + sw0(post_CL_:classif_2000) +
  log_pop + num_ISPs + total_npcom_pages +
  i(year, share_urban_2000, 2000) +
  i(year,pct_college_2000,2004) +
  i(year,pct_rental_2000,2004) +
  i(year,age_2000,2004) +
  i(year,share_white_2000,2004) +
  i(year,share_black_2000,2004) +
  i(year,share_hisp_2000,2004) +
  i(year,income_2000,2004) +
  i(year,unemployment_2000,2004) +
  i(year,pres_turnout_2000,2004) +
  i(year,pres_repshare_2000,2004) |
  wkday^np_name + year,
  data = ep_npcom, cluster = ~url_1)

clrate_dd_fullcontrols <- feols(log_cl_rate ~
  post_CL_ + sw0(post_CL_:classif_2000) +
  log_pop + num_ISPs +
  i(year, share_urban_2000, 2000) +
  i(year,pct_college_2000,2004) +
  i(year,pct_rental_2000,2004) +
  i(year,age_2000,2004) +
  i(year,share_white_2000,2004) +
  i(year,share_black_2000,2004) +
  i(year,share_hisp_2000,2004) +
  i(year,income_2000,2004) +
  i(year,unemployment_2000,2004) +
  i(year,pres_turnout_2000,2004) +
  i(year,pres_repshare_2000,2004) |
  unit^np_name + year,
  data = ep_price,
  cluster = ~url_1)


## Table 2
etable(classif_dd_fullcontrols, clrate_dd_fullcontrols,
    digits = 3,
    digits.stats = 2,
    style.tex=tablestyle,
    cluster = ~url_1,
    extralines = list("^_# Newspapers" =
      map_chr(list(ep_price[np_name %in% unique(npcom_pages_bypaper_pre$np_name)],
                   ep_price[np_name %in% unique(npcom_pages_bypaper_pre$np_name)],
                   ep_price,
                   ep_price), ~ length(unique(.$np_name)))),
    group=list("Log population, \\#ISPs"=c("log_pop", "num_ISPs"),
               "2000 Demographics $\\times$ Year FE"=c(" Year "),
               "Total Pages in Newspapers.com" = "total_npcom_pages"),
    file = glue("{out_dir}/classif_rates_and_prices.tex"),
    replace=T
  )

## Table B1
etable(pages_pre, clrate_pre,
    digits = 3,
    digits.stats = 2,
    style.tex=tablestyle,
    cluster = ~np_name,
    extralines = list("^_# Newspapers" =
      map_chr(list(ep_price[np_name %in% unique(npcom_pages_bypaper_pre$np_name)],
                   ep_price), ~ length(unique(.$np_name)))),
    group=list("Log population, \\#ISPs"=c("log_pop", "num_ISPs"),
      "Newspaper Characteristics" = c("circ_pop","total_pages","num_pages"),
      "Additional County Characteristics" = c("income", "pct_", "age_", "unemployment", "pop_density", "share", "pres")
               ),
    file = glue("{out_dir}/classif_rates_and_prices_preCL.tex"),
    replace=T
  )
