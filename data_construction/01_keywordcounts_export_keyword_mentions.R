library(tidyverse)
library(lubridate)
library(data.table)
library(haven)
library(glue)

# change to location where archive was extracted
data_dir <- "~/craigslist-replication-code-and-data/data"
out_dir <- "~/craigslist-replication-code-and-data/output"

read_dtadt <- compose(as.data.table, read_dta)

n_unq <- function(inds) {
  if (length(inds) == 0) {
    length(character(0))
  } else {
    inds %>%
      str_split(fixed("|")) %>%
      unlist %>%
      unique %>%
      length
  }
}

aggregate_yearly <- function(data, subgroups = character(0), fill_df = NULL, col_name = "other") {
  
  if (length(subgroups) == 0) {
    data$type <- col_name
    subgroups <- "type"
  }

  cast_fmla <- as.formula(glue("ep_std_name + year ~ {paste(subgroups, collapse = ' + ')}"))

  agg <- data[, .(article_count = sum(article_count),
           distinct_articles = n_unq(article_inds)),
           by = c(c("ep_std_name", "year", "date"), subgroups)] %>%
      .[, .(article_count = sum(article_count),
            distinct_articles = sum(distinct_articles)),
        by = c(c("ep_std_name", "year"), subgroups)] %>%
      dcast(cast_fmla, value.var = c("article_count", "distinct_articles"), fill = 0)

  if (is.null(fill_df)) {
    agg
  } else {
    agg <- agg[fill_df, on = .(ep_std_name, year)]
    agg[is.na(agg)] <- 0
    agg
  }
}




## years that exist in Newsbank
ep_years <- fread(glue("{data_dir}/Newspapers_content/newsbank_ep_paper_years.csv")) %>%
  .[year <= 2012]

in_nb <- ep_years %>%
  .[, .(year, ep_std_name)] %>%
  unique %>%
  .[year <= 2012]


## ACCOUNTABILITY WORDS AND LOCAL TITLES ##
corruptwords_mentions <- fread(glue("{data_dir}/Newspapers_content/Newsbank_article_counts/newsbank_corruption_localtitle_mentions.csv")) %>%
  .[, year := year(ymd(date))] %>%
  .[ep_years, on = .(PBI, year), nomatch = 0] %>%
  .[,.(article_count = max(article_count),
       article_inds = article_inds[which.max(article_count)]),
       by = .(ep_std_name, state, year, date, pattern)]   # deal with repeats


corruptwords_mentions[grep("judge|manager|alderman|attorney|commissioner|council|governor|mayor|state", pattern), type := "local_title"]
corruptwords_mentions[is.na(type), type := "accountability_word"]

# aggregate unique articles yearly, recast wide
corruptwords_mentions_yearly <- corruptwords_mentions %>%
  aggregate_yearly(subgroups = "type", fill_df = in_nb)

rm(corruptwords_mentions)

### SITTING CONGRESSMAN / SENATOR MENTIONS

congress_coverage <- fread(glue("{data_dir}/Newspapers_content/Newsbank_article_counts/newsbank_congress_and_candidate_mentions.csv")) %>%
  .[, year := year(ymd(date))] %>%
  .[ep_years, on = .(PBI, year, state), nomatch = 0]
  
# extract sections
congress_sections <- congress_coverage[,
    .(section = article_sects %>% str_split(fixed("|")) %>% unlist),
    by = .(ep_std_name, state, year)] %>%
  .[, .(appearances = .N), by = .(ep_std_name, state, year, section)] %>%
  .[order(ep_std_name, state, year, -appearances)]

# congress_coverage <- congress_coverage[,.(article_count = max(article_count),
#        article_inds = article_inds[which.max(article_count)]),
#        by = .(ep_std_name, state, year, date, first, last, party, district, chamber)]   # deal with repeats

congress_coverage <- congress_coverage[,.(article_count = max(article_count),
       article_inds = article_inds[which.max(article_count)]),
       by = .(ep_std_name, state, year, date, id, office, district, incumbent)]   # deal with repeats

## add primary dates
primary_dates <- fread(glue("{data_dir}/political/primary_election_dates.csv"))
odds <- copy(primary_dates) %>% .[,year := year - 1]
primary_dates <- rbind(primary_dates, odds) %>%
  .[order(year, state)]

congress_coverage <- congress_coverage[primary_dates, on = .(state, year), nomatch = 0]
congress_coverage[, primary := if_else(date <= primary_date, "primary", "general")]

## splits: 
## 1. house / senate
## 2. incumbent / challenger
## 3. primary / general
## 4. everything

# split by house / senate
hs_coverage <- congress_coverage %>%
  aggregate_yearly(subgroups = "office", fill_df = in_nb)

# split by incumbent / challenger
congress_coverage[, incumbent_ := if_else(incumbent == 1, "incumbent", "challenger")]
ic_coverage <- congress_coverage %>%
  aggregate_yearly(subgroups = "incumbent_", fill_df = in_nb)

# note: remaining two splits pool across challengers and incumbents.
# to avoid double counting, exclude Senate candidates who are also sitting members of the House
house_sen_cands <- fread(glue("{data_dir}/political/congressman_data/house_members_running_for_senate.csv"))
congress_coverage <- congress_coverage %>%
  .[!house_sen_cands, on = .(id, office, incumbent, date >= start_date, date <= end_date)]

# split by primary / general
pg_coverage <- congress_coverage %>%
  aggregate_yearly(subgroups = "primary", fill_df = in_nb)

# combined
congress_coverage_yearly <- congress_coverage %>%
  aggregate_yearly(col_name = "anycongress", fill_df = in_nb)

# join together
congress_coverage_yearly <- congress_coverage_yearly %>%
  .[ic_coverage, on = .(ep_std_name, year)] %>%
  .[pg_coverage, on = .(ep_std_name, year)] %>%
  .[hs_coverage, on = .(ep_std_name, year)]

# in-district mentions for congressmen
np_districts <- read_dtadt(glue("{data_dir}/master_data_newspaper_level.dta")) %>%
  setnames(old = "NPNAME1", new = "ep_std_name") %>%
  .[, .(ep_std_name, year, np_state = state, np_cd = if_else(year <= 2002, HQ_CD_106th_, HQ_CD_109th_))] %>%
  .[, np_cd := paste0(np_state, str_pad(str_extract(np_cd, "\\d+"), pad = "0", width = 2))]

# repeat for 2011 / 2012
np_districts_11 <- np_districts[year == 2010] %>%
  .[, year := 2011]
np_districts_12 <- np_districts[year == 2010] %>%
  .[, year := 2012]

np_districts <- rbind(np_districts, np_districts_11, np_districts_12)
np_districts[np_state == "" | is.na(np_state), np_state := str_extract(ep_std_name, "[A-Z]{2}$")]
np_districts[np_cd == "00" | np_cd == "98", np_cd := paste0(np_state, "01")]
np_districts[grep("[A-Z]{2}00", np_cd), np_cd := sub("00", "01", np_cd)]

house_coverage <- np_districts[congress_coverage[office == "rep"], on = .(ep_std_name, year), nomatch = 0]
house_coverage[, in_district := if_else(np_cd == district, "rep_in_district", "rep_out_district")]


house_coverage_yearly <- house_coverage %>%
  aggregate_yearly(subgroups = "in_district", fill_df = in_nb)

congress_coverage_yearly <- congress_coverage_yearly[house_coverage_yearly, on = .(ep_std_name, year)]

### NATIONAL POLITICIAN COVERAGE
natl_coverage <- fread(glue("{data_dir}/Newspapers_content/Newsbank_article_counts/newsbank_nationalpol_mentions.csv")) %>%
  .[, year := year(ymd(date))] %>%
  .[ep_years, on = .(PBI, year), nomatch = 0] %>%
  .[,.(article_count = max(article_count),
       article_inds = article_inds[which.max(article_count)]),
       by = .(ep_std_name, state, year, date, pattern)] %>%   # deal with repeats
  .[, type := if_else(grepl("Bush|Obama|Clinton", pattern), "pres", "partyleaders")] %>%
  aggregate_yearly(subgroups = "type", fill_df = in_nb)


### AP / WIRE SERVICE REFERENCES ###
raw_refs <- fread(glue("{data_dir}/Newspapers_content/Newsbank_article_counts/newsbank_ap_references.csv")) %>%
  .[, year := year(ymd(date))] %>%
  .[ep_years, on = .(PBI, year), nomatch = 0] %>%
  merge(., congress_sections, by = c("ep_std_name", "year", "state", "section"), all.x = TRUE)

refs <- raw_refs[, .(total_articles_searched = sum(articles_searched),
                     article_count_congress = sum(articles_congress),
                     total_articles_mentionsections = sum(articles_searched[!is.na(appearances)]),
                     total_ap_refs_mentionsections = sum(articles_wire_service[!is.na(appearances)]),
                     pct_mentionsections = sum(articles_searched[!is.na(appearances)]) / sum(articles_searched),
                     pct_ap = sum(articles_wire_service) / sum(articles_searched),
                     pct_ap_mentionsections = sum(articles_wire_service[!is.na(appearances)] * appearances[!is.na(appearances)]) / sum(articles_searched[!is.na(appearances)] * appearances[!is.na(appearances)])),
                by = .(ep_std_name, year)]

rm(raw_refs)

### TOTAL ARTICLES BY YEAR / PAPER
totalcounts <- fread(glue("{data_dir}/Newspapers_content/Newsbank_article_counts/newsbank_total_articles.csv")) %>%
  .[, year := year(date)] %>%
  .[ep_years, on = .(PBI, year), nomatch = 0] %>%
  .[, .(total_articles = sum(n)), by = .(ep_std_name, year)]


### coverage of congressional primaries
primary_coverage <- fread(glue("{data_dir}/Newspapers_content/Newsbank_article_counts/newsbank_primary_mentions.csv")) %>%
  .[, year := year(date)] %>%
  .[ep_years, on = .(PBI, year), nomatch = 0] %>%
  .[primary_dates, on = .(year, state), nomatch = 0] %>%
  .[,.(article_count = max(article_count)),
       by = .(ep_std_name, state, year, date, primary_date)] %>%  # deal with repeats
  .[date < primary_date, .(article_count_cong_primary = sum(article_count)), by = .(ep_std_name, year)]

primary_coverage <- primary_coverage[in_nb, on = .(year, ep_std_name)]
primary_coverage[is.na(article_count_cong_primary), article_count_cong_primary := 0]


### join everything
setnames(congress_coverage_yearly,
  old =  c("article_count_rep",
           "article_count_sen",
           "article_count_incumbent",
           "article_count_challenger",
           "article_count_primary",
           "article_count_general",
           "article_count_anycongress",
           "distinct_articles_rep",
           "distinct_articles_sen",
           "distinct_articles_incumbent",
           "distinct_articles_challenger",
           "distinct_articles_primary",
           "distinct_articles_general",
           "distinct_articles_anycongress"),
  new = function(x) paste0(x, "_in_state"))



all_nb_counts <- corruptwords_mentions_yearly[congress_coverage_yearly, on = .(year, ep_std_name)] %>%
    .[natl_coverage, on = .(year, ep_std_name)] %>%
    .[refs, on = .(year, ep_std_name)] %>%
    .[totalcounts, on = .(year, ep_std_name)] %>%
    .[primary_coverage, on = .(year, ep_std_name)]

fwrite(all_nb_counts, file = glue("{data_dir}/Newspapers_content/Newsbank_article_counts/all_nb_counts_yearly.csv"))
