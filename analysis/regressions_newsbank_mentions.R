### regressions with coverage of members of congress as outcome ###

library(tidyverse)
library(lubridate)
library(data.table)
library(haven)
library(fixest)

## change to directory where archive was extracted
data_dir <- "~/craigslist-replication-code-and-data/data"
out_dir <- "~/craigslist-replication-code-and-data/output"

read_dtadt <- compose(as.data.table, read_dta)


# setup for tables
setFixest_dict(c(post_CL_ = "Post-CL",
                 classif_2000 = "Classif. Mgr.",
                 fips = "County",
                 year = "Year",
                 state = "State",
                 statdist = "District",
                 ep_std_name = "Newspaper",
                 dma_2000 = "DMA",
                 url_1 = "CL Market",
                article_count_congress_ihs = "Congress",
                article_count_cong_primary_ihs = "Congress. Primaries",
                article_count_anycongress_in_state_ihs = "Articles Mentioning In-State Cong. Cands. (ihs)",
                article_count_general_in_state_ihs = "Gen. Election Period",
                article_count_primary_in_state_ihs = "Pri. Election Period",
                article_count_sen_in_state_ihs = "Senate",
                article_count_rep_in_state_ihs = "House",
                article_count_pres_ihs = "President",
                article_count_incumbent_in_state_ihs = "Incumbents",
                article_count_challenger_in_state_ihs = "Challengers",
                article_count_partyleaders_ihs = "Party Leaders",
                article_count_accountability_word_ihs = "Accountability Words",
                article_count_local_title_ihs = "State and Local"
                )
    )


fitstat_register(type = "mean_dv", alias = "Mean dependent variable",
                 fun = function(x) mean(x$fitted.values + x$residuals))

setFixest_etable(digits = 3,
                 digits.stats = 2,
                fitstat = ~ n + r2 + mean_dv)

tablestyle <- style.tex(main = "aer",
                 fixef.suffix = " FEs",
                 fixef.where = "var",
                 fixef.title = "",
                 stats.title = "\\midrule",
                 tablefoot = F,
                 yesNo = c("Yes", "No"))


# read newspaper level data
np <- read_dtadt(glue("{data_dir}/master_data_newspaper_level.dta")) %>%
  setnames(old = "NPNAME1", new = "ep_std_name") %>%
  .[largepaper == 0]

# fix a couple of entries of classif manager in 2000
classif2000_fix <- fread(glue("{data_dir}/E&P/check_newspapers_id_classif2000.csv")) %>%
  .[, classif_2000_corrected := parse_number(classif_2000_corrected, na = c("", "NA", "."))]

np <- classif2000_fix[np, on = .(ep_std_name)] %>%
  .[!is.na(classif_2000_corrected), classif_2000 := classif_2000_corrected]





## join with coverage data
coverage <- fread(glue("{data_dir}/Newspapers_content/Newsbank_article_counts/all_nb_counts_yearly.csv"))

np[, c("natlpol_mentions", "total_articles", "congress_mentions", "ihs_congress_mentions", "ihs_natlpol_mentions", "ihs_total_articles") := NULL]

np_coverage <- np[coverage, on = .(ep_std_name, year)]

#clustering setup
np_coverage[ever_CL_==1,url_1:=url]
np_coverage[ever_CL_==0,url_1:=fips]


ihscols <- c(grep("distinct_articles", colnames(np_coverage), value = TRUE),
  grep("article_count", colnames(np_coverage), value = TRUE),
  "total_articles",
  "total_articles_searched",
  "total_articles_mentionsections",
  "total_ap_refs_mentionsections")

np_coverage[, paste0(ihscols, "_ihs") := map(.SD, asinh), .SDcols = ihscols]



# Table A17: pres / congress / local
localtable <- feols(.[c("article_count_pres_ihs",
          "article_count_partyleaders_ihs",
          "article_count_local_title_ihs")] ~
          post_CL_ + sw0(post_CL_:classif_2000) +
          log_pop + num_ISPs +
          i(year, share_urban_2000, 2004) +
          i(year, pct_college_2000, 2004) +
          i(year, pct_rental_2000, 2004) +
          i(year, age_2000, 2004) +
          i(year, share_white_2000, 2004) +
          i(year, share_black_2000, 2004) +
          i(year, share_hisp_2000, 2004) +
          i(year, income_2000, 2004) +
          i(year, unemployment_2000, 2004) +
          i(year, pres_turnout_2000, 2004) +
          i(year, pres_repshare_2000, 2004) +
          total_articles_mentionsections_ihs |
          ep_std_name + year,
          data = np_coverage[year <= 2010],
          cluster = ~ CL_area)

etable(localtable,
        group=list("Log population, \\#ISPs"=c("log_pop", "num_ISPs"),
               "Tot. articles in relevant sections"="total_articles_mentionsections",
               "2000 Demographics $\\times$ Year FE"=c(" Year ")),
            file = glue("{out_dir}/ihs_local_mentions.tex"),
            style.tex = tablestyle,
            replace = T)

# Table A18: generic Congress coverage

congtable2 <- feols(.[c("article_count_congress_ihs",
          "article_count_cong_primary_ihs")] ~
          post_CL_ + sw0(post_CL_:classif_2000) +
          log_pop + num_ISPs +
          i(year, share_urban_2000, 2004) +
          i(year, pct_college_2000, 2004) +
          i(year, pct_rental_2000, 2004) +
          i(year, age_2000, 2004) +
          i(year, share_white_2000, 2004) +
          i(year, share_black_2000, 2004) +
          i(year, share_hisp_2000, 2004) +
          i(year, income_2000, 2004) +
          i(year, unemployment_2000, 2004) +
          i(year, pres_turnout_2000, 2004) +
          i(year, pres_repshare_2000, 2004) +
          total_articles_mentionsections_ihs |
          ep_std_name + year,
          data = np_coverage[year <= 2010],
          cluster = ~ CL_area)

etable(congtable2,
        group=list("Log population, \\#ISPs"=c("log_pop", "num_ISPs"),
               "Tot. articles in relevant sections"="total_articles_mentionsections",
               "2000 Demographics $\\times$ Year FE"=c(" Year ")),
            style.tex = tablestyle,
            file = glue("{out_dir}/ihs_generic_mentions.tex"),
            replace = T)

# Table A19: accountability words
accttable <- feols(.[c("article_count_accountability_word_ihs")] ~
          post_CL_ + sw0(post_CL_:classif_2000) +
          log_pop + num_ISPs +
          i(year, share_urban_2000, 2004) +
          i(year, pct_college_2000, 2004) +
          i(year, pct_rental_2000, 2004) +
          i(year, age_2000, 2004) +
          i(year, share_white_2000, 2004) +
          i(year, share_black_2000, 2004) +
          i(year, share_hisp_2000, 2004) +
          i(year, income_2000, 2004) +
          i(year, unemployment_2000, 2004) +
          i(year, pres_turnout_2000, 2004) +
          i(year, pres_repshare_2000, 2004) +
          total_articles_mentionsections_ihs |
          ep_std_name + year,
          data = np_coverage[year <= 2010],
          cluster = ~ CL_area)

etable(accttable,
        group=list("Log population, \\#ISPs"=c("log_pop", "num_ISPs"),
               "Tot. articles in relevant sections"="total_articles_mentionsections",
               "2000 Demographics $\\times$ Year FE"=c(" Year ")),
            file = glue("{out_dir}/ihs_accountability_word_mentions.tex"),
            style.tex = tablestyle,
            replace = T)
