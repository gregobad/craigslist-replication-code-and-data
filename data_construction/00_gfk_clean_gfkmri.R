#### Read in GFK-MRI data ###
### NOTE: data is proprietary, not included in archive

library(tidyverse)
library(data.table)
library(readxl)
library(haven)
library(stringi)
library(glue)

read_dtadt <- compose(as.data.table, read_dta)
data_dir <- "~/craigslist-replication-code-and-data/data"
setwd("{data_dir}/GfK-MRI/")


#### RESPID TO ZIP ####
setwd("Zipcodes")

zipfiles <- list.files()

read_zips <- function(f) {
	fread(f) %>% .[,.(RespID, wgtpop, zipcode)]
}

zipfiles %>% map(read_zips) %>% rbindlist -> id2zip

id2zip[,mristudywave := as.numeric(substr(as.character(RespID), 1,2))]
id2zip[,RespID:=as.character(RespID)]

#### Get interview / wave date ####
setwd("..")
fread("mri_wave_to_year.csv") %>% 
	setnames(old=c("year", "month"), new=c("wave_year", "wave_month")) -> 
	wave2year

id2zip <- wave2year[id2zip, on = .(mristudywave)]

setwd("Interview Dates")
datefiles <- list.files(pattern="xlsx")
read_dates <- function(f) {
	read_excel(f) %>% 
		as.data.table %>% 
		setnames(old=c("Interview month", "Interview day", "Interview Year"), new = c("int_month", "int_day", "int_year")) %>%
		.[,RespID:=as.character(RespID)]
}
datefiles %>% map(read_dates) %>% rbindlist -> id2date

id2zip <- id2date[id2zip, on = .(RespID)]

# fill dates for years prior to 2010 w/ no interview dates:
# March YYYY -> 8/YYYY
# Sep YYYY -> 1/YYYY+1
# (median interview in March 2009 wave occurs 8/2009, median interview in Sep 2009 wave occurs Jan 2010)
id2zip[is.na(int_year), int_year := ifelse(wave_month=="March", wave_year, wave_year+1)]
id2zip[is.na(int_month), int_month := ifelse(wave_month=="March", 8, 1)]

# add county and DMA info
zip2cty <- fread("{data_dir}/_zipcode/DMA-zip.csv")
setnames(zip2cty, c("fips", "county", "state", "dma", "dmaname", "zipcode"))

id2zip <- zip2cty[id2zip, on = .(zipcode)]

# a couple missing zips in that file, fill those in from census crosswalk file
ctyfips <- fread("{data_dir}/_zipcode/county_fips_codes.csv") %>% 
	.[,.(fips = as.integer(paste0(statefips, str_pad(countyfips, pad="0", width=3))),
		 county = str_to_title(countyname),
		 state = stateabbr)]
zip2cty <- fread("{data_dir}/_zipcode/zcta_county_rel_10.txt") %>%
	.[,.(zipcode = ZCTA5, fips = as.integer(paste0(STATE, str_pad(COUNTY, pad="0", width=3))), ZPOPPCT)] %>%
	.[,.(fips=fips[which.max(ZPOPPCT)]), by = .(zipcode)]

id2zip_yes <- id2zip[!is.na(fips)]
id2zip_no <- id2zip[is.na(fips)]
id2zip_no$state <- NULL
id2zip_no$county <- NULL
id2zip_no$fips <- NULL

id2zip_no <- zip2cty[id2zip_no, on = .(zipcode)]
id2zip_no[zipcode==6430, fips := 9001]
id2zip_no[zipcode==6432, fips := 9001]
id2zip_no[zipcode==6490, fips := 9001]
id2zip_no[zipcode==75033, fips := 48085]


id2zip_no <- ctyfips[id2zip_no, on = .(fips)]

id2zip <- rbind(id2zip_no, id2zip_yes) %>% 
	.[order(int_year, int_month, fips, zipcode)]

fwrite(id2zip, "../mri_respid_zip_date.csv")

#### READ ACTUAL SURVEY DATA ####

parse_mediamark <- function(dt, cols_dict) {
	dtwgt <- dt[,.(RespID, wgtpop)]

	dt <- melt(dt, id.vars="RespID", variable.name="item", value.name="value")



	dt1 <- dt %>%
		.[,item:=str_extract(item, regex("(?<=\\[)[0-9xXyYzZ-]+(?=\\])"))] %>%
		.[value!=0, .(RespID, item)] %>%
		.[cols_dict, on = .(item), nomatch=0] %>%
		.[colname != "exclude"] %>%
		.[order(RespID, colname, item, value)] %>%
		unique(by=c("RespID", "colname")) %>%
		dcast(RespID ~ colname, value.var = "value")

	dt2 <- dt1[,map(.SD, ~ as.numeric(!is.na(.))), .SDcols = setdiff(colnames(dt1), c("RespID", "agebin", "educ1", "educ2", "employment", "hhi", "ideo", "inet_use", "lang", "ownrent", "race"))]

	educcols <- grep("educ", colnames(dt1), value=T)

	selectcols <- intersect(c("RespID", "agebin", educcols, "employment", "hhi", "ideo", "inet_use", "lang", "ownrent", "race"), colnames(dt1))

	cbind(dt1[,selectcols, with=F], dt2)
}

### READ IN RAW DATA AND STANDARDIZE
### DO COMMENTED PART ONLY ONCE, requires manual intervention
setwd("{data_dir}/GfK-MRI/")
gfk01 <- fread("doublebaseGfKMRI2001.csv")

# index01 <- data.table(item = colnames(dt) %>% str_extract(regex("(?<=\\[)[0-9xXyYzZ-]+(?=\\])")) %>% stri_enc_toascii, 
# 					  colname  = stri_enc_toascii(colnames(dt)))

# fwrite(index01, "mri_col_index.csv")


gfk03 <- fread("doublebaseGfKMRI2003.csv")
# index03 <- data.table(item = colnames(gfk03) %>% str_extract(regex("(?<=\\[)[0-9xXyYzZ-]+(?=\\])")) %>% stri_enc_toascii, 
# 					  colname  = stri_enc_toascii(colnames(gfk03)))

# index03[!index01, on = .(item)]  # 59 new columns
# fwrite(index03[!index01, on = .(item)], "mri_col_index_adds.csv")




gfk05 <- fread("doublebaseGfKMRI2005.csv")
# index <- fread("mri_col_index.csv")
# index05 <- data.table(item = colnames(gfk05) %>% str_extract(regex("(?<=\\[)[0-9xXyYzZ-]+(?=\\])")) %>% stri_enc_toascii, 
# 					  colname  = stri_enc_toascii(colnames(gfk05)))

# index05[!index, on = .(item)] # 64 new columns
# fwrite(index05[!index, on = .(item)], "mri_col_index_adds.csv")



gfk07 <- fread("doublebaseGfKMRI2007.csv")
# index <- fread("mri_col_index.csv")
# index07 <- data.table(item = colnames(gfk07) %>% str_extract(regex("(?<=\\[)[0-9xXyYzZ-]+(?=\\])")) %>% stri_enc_toascii, 
# 					  colname  = stri_enc_toascii(colnames(gfk07)))

gfk07_demos <- fread("doublebaseGfKMRI2007_demos.csv")
gfk07_demos$wgtpop <- NULL

gfk07 <- gfk07[gfk07_demos, on=.(RespID), nomatch=0]


# index07[!index, on = .(item)] # 67 new columns
# fwrite(index07[!index, on = .(item)], "mri_col_index_adds.csv")



gfk09 <- fread("doublebaseGfKMRI2009.csv")
# index <- fread("mri_col_index.csv")
# index09 <- data.table(item = colnames(gfk09) %>% str_extract(regex("(?<=\\[)[0-9xXyYzZ-]+(?=\\])")) %>% stri_enc_toascii, 
# 					  colname  = stri_enc_toascii(colnames(gfk09)))

gfk09_demos <- fread("doublebaseGfKMRI2009_demos.csv")
gfk09_demos$wgtpop <- NULL

gfk09 <- gfk09[gfk09_demos, on=.(RespID), nomatch=0]

# index09[!index, on = .(item)] # 41 new columns
# fwrite(index09[!index, on = .(item)], "mri_col_index_adds.csv")


gfk11 <- fread("doublebaseGfKMRI2011.csv")
# index <- fread("mri_col_index.csv")
# index11 <- data.table(item = colnames(gfk11) %>% str_extract(regex("(?<=\\[)[0-9xXyYzZ-]+(?=\\])")) %>% stri_enc_toascii, 
# 					  colname  = stri_enc_toascii(colnames(gfk11)))

gfk11_demos <- fread("doublebaseGfKMRI2011_demos.csv")
gfk11_demos$wgtpop <- NULL

gfk11 <- gfk11[gfk11_demos, on=.(RespID), nomatch=0]

# index11[!index, on = .(item)] # 82 new columns
# fwrite(index11[!index, on = .(item)], "mri_col_index_adds.csv")


gfk13 <- fread("doublebaseGfKMRI2013.csv")
# index <- fread("mri_col_index.csv")
# index13 <- data.table(item = colnames(gfk13) %>% str_extract(regex("(?<=\\[)[0-9xXyYzZ-]+(?=\\])")) %>% stri_enc_toascii, 
# 					  colname  = stri_enc_toascii(colnames(gfk13)))

# index13[!index, on = .(item)] # 585 new columns
# fwrite(index13[!index, on = .(item)], "mri_col_index_adds.csv")


index <- fread("mri_col_index.csv")

list(gfk01, gfk03, gfk05, gfk07, gfk09, gfk11, gfk13) %>%
	map(parse_mediamark, cols_dict = index) %>% 
	rbindlist(fill=T) ->
	gfk


gfk[,RespID:=as.character(RespID)]
gfk <- gfk[id2zip, on = .(RespID), nomatch=0]
gfk[,educ := ifelse(is.na(educ1), educ2, educ1)]
gfk[is.na(ideo), ideo := "Refused"]

saveRDS(gfk, file = "gfk.rds")


## add read any daily newspaper for years where it was not included in main pull ##
addl_01 <- fread("doublebaseGfKMRI2001_additional.csv")
addl_03 <- fread("doublebaseGfKMRI2003_additional.csv")
addl_05 <- fread("doublebaseGfKMRI2005_additional.csv")
addl_07 <- fread("doublebaseGfKMRI2007_additional.csv")
addl_09 <- fread("doublebaseGfKMRI2009_additional.csv")
addl_11 <- fread("doublebaseGfKMRI2011_additional.csv")

addl_01 <- addl_01[,.(RespID = as.character(RespID), read_np_any01=`[01681]: Newspapers: Read any daily newspaper`)]
addl_03 <- addl_03[,.(RespID = as.character(RespID), read_np_any03=`[01681]: Newspapers: Read any daily newspaper`)]
addl_05 <- addl_05[,.(RespID = as.character(RespID), read_np_any05=`[01681]: Newspapers: Read any daily newspaper`)]
addl_07 <- addl_07[,.(RespID = as.character(RespID), read_np_any07=`[01681]: Newspapers: Read any daily newspaper`)]
addl_09 <- addl_09[,.(RespID = as.character(RespID), read_np_any09=`[01681]: Newspapers: Read any daily newspaper`)]
addl_11 <- addl_11[,.(RespID = as.character(RespID), read_np_any11=`[01681]: Newspapers: Read any daily newspaper`)]


gfk <- addl_01[gfk, on = .(RespID)]
gfk[,read_np_any := if_else(is.na(read_np_any), as.numeric(read_np_any01), read_np_any)]
gfk <- addl_03[gfk, on = .(RespID)]
gfk[,read_np_any := if_else(is.na(read_np_any), as.numeric(read_np_any03), read_np_any)]
gfk <- addl_05[gfk, on = .(RespID)]
gfk[,read_np_any := if_else(is.na(read_np_any), as.numeric(read_np_any05), read_np_any)]
gfk <- addl_07[gfk, on = .(RespID)]
gfk[,read_np_any := if_else(is.na(read_np_any), as.numeric(read_np_any07), read_np_any)]
gfk <- addl_09[gfk, on = .(RespID)]
gfk[,read_np_any := if_else(is.na(read_np_any), as.numeric(read_np_any09), read_np_any)]
gfk <- addl_11[gfk, on = .(RespID)]
gfk[,read_np_any := if_else(is.na(read_np_any), as.numeric(read_np_any11), read_np_any)]

gfk$read_np_any01 <- NULL
gfk$read_np_any03 <- NULL
gfk$read_np_any05 <- NULL
gfk$read_np_any07 <- NULL
gfk$read_np_any09 <- NULL
gfk$read_np_any11 <- NULL

## redo radio - inconsistently included in main pull ##
radio_01 <- fread("doublebaseGfKMRI2001_radio.csv")
radio_03 <- fread("doublebaseGfKMRI2003_radio.csv")
radio_05 <- fread("doublebaseGfKMRI2005_radio.csv")
radio_07 <- fread("doublebaseGfKMRI2007_radio.csv")
radio_09 <- fread("doublebaseGfKMRI2009_radio.csv")
radio_11 <- fread("doublebaseGfKMRI2011_radio.csv")
radio_13 <- fread("doublebaseGfKMRI2013_radio.csv")

radio_01 <- radio_01[,.(RespID = as.character(RespID), radio_news01=`[09404]: News/Talk`)]
radio_03 <- radio_03[,.(RespID = as.character(RespID), radio_news03=`[08015]: News/Talk`)]
radio_05 <- radio_05[,.(RespID = as.character(RespID), radio_news05=`[08015]: News/Talk`)]
radio_07 <- radio_07[,.(RespID = as.character(RespID), radio_news07=`[08015]: News/Talk`)]
radio_09 <- radio_09[,.(RespID = as.character(RespID), radio_news09=`[08015]: News/Talk`)]
radio_11 <- radio_11[,.(RespID = as.character(RespID), radio_news11=`[08015]: News/Talk`)]
radio_13 <- radio_13[,.(RespID = as.character(RespID), radio_news13=`[08015]: News/Talk`)]


gfk$radio_news <- NULL

gfk <- radio_01[gfk, on = .(RespID)]
gfk[,radio_news:=as.numeric(radio_news01)]
gfk <- radio_03[gfk, on = .(RespID)]
gfk[,radio_news := if_else(is.na(radio_news), as.numeric(radio_news03), radio_news)]
gfk <- radio_05[gfk, on = .(RespID)]
gfk[,radio_news := if_else(is.na(radio_news), as.numeric(radio_news05), radio_news)]
gfk <- radio_07[gfk, on = .(RespID)]
gfk[,radio_news := if_else(is.na(radio_news), as.numeric(radio_news07), radio_news)]
gfk <- radio_09[gfk, on = .(RespID)]
gfk[,radio_news := if_else(is.na(radio_news), as.numeric(radio_news09), radio_news)]
gfk <- radio_11[gfk, on = .(RespID)]
gfk[,radio_news := if_else(is.na(radio_news), as.numeric(radio_news11), radio_news)]
gfk <- radio_13[gfk, on = .(RespID)]
gfk[,radio_news := if_else(is.na(radio_news), as.numeric(radio_news13), radio_news)]

gfk$radio_news01 <- NULL
gfk$radio_news03 <- NULL
gfk$radio_news05 <- NULL
gfk$radio_news07 <- NULL
gfk$radio_news09 <- NULL
gfk$radio_news11 <- NULL
gfk$radio_news13 <- NULL

## redo internet news - also inconsistently included in main pull ##
gfk <- gfk[,.SD,.SDcols = grep("inet_", colnames(gfk), value=T, invert=T)]
inet_01 <- fread("doublebaseGFKMRI2001_inet.csv")
inet_03 <- fread("doublebaseGFKMRI2003_inet.csv")
inet_05 <- fread("doublebaseGFKMRI2005_inet.csv")
inet_07 <- fread("doublebaseGFKMRI2007_inet.csv")
inet_09 <- fread("doublebaseGFKMRI2009_inet.csv")
inet_11 <- fread("doublebaseGFKMRI2011_inet.csv")
inet_13 <- fread("doublebaseGFKMRI2013_inet.csv")

inet_01 <- inet_01 %>% 
	melt(id.vars="RespID") %>% 
	.[grepl("^\\[\\d", variable)] %>%
	.[,.(inet_news01 = max(value)), by=.(RespID=as.character(RespID))]
inet_03 <- inet_03 %>% 
	melt(id.vars="RespID") %>% 
	.[grepl("^\\[\\d", variable)] %>%
	.[,.(inet_news03 = max(value)), by=.(RespID=as.character(RespID))]
inet_05 <- inet_05 %>% 
	melt(id.vars="RespID") %>% 
	.[grepl("^\\[\\d", variable)] %>%
	.[,.(inet_news05 = max(value)), by=.(RespID=as.character(RespID))]
inet_07 <- inet_07 %>% 
	melt(id.vars="RespID") %>% 
	.[grepl("^\\[\\d", variable)] %>%
	.[,.(inet_news07 = max(value)), by=.(RespID=as.character(RespID))]
inet_09 <- inet_09 %>% 
	melt(id.vars="RespID") %>% 
	.[grepl("^\\[\\d", variable)] %>%
	.[,.(inet_news09 = max(value)), by=.(RespID=as.character(RespID))]
inet_11 <- inet_11 %>% 
	melt(id.vars="RespID") %>% 
	.[grepl("^\\[\\d", variable)] %>%
	.[,.(inet_news11 = max(value)), by=.(RespID=as.character(RespID))]
inet_13 <- inet_13 %>% 
	melt(id.vars="RespID") %>% 
	.[grepl("^\\[\\d", variable)] %>%
	.[,.(inet_news13 = max(value)), by=.(RespID=as.character(RespID))]

gfk <- inet_01[gfk, on = .(RespID)]
gfk[,inet_news:=as.numeric(inet_news01)]
gfk <- inet_03[gfk, on = .(RespID)]
gfk[,inet_news := if_else(is.na(inet_news), as.numeric(inet_news03), inet_news)]
gfk <- inet_05[gfk, on = .(RespID)]
gfk[,inet_news := if_else(is.na(inet_news), as.numeric(inet_news05), inet_news)]
gfk <- inet_07[gfk, on = .(RespID)]
gfk[,inet_news := if_else(is.na(inet_news), as.numeric(inet_news07), inet_news)]
gfk <- inet_09[gfk, on = .(RespID)]
gfk[,inet_news := if_else(is.na(inet_news), as.numeric(inet_news09), inet_news)]
gfk <- inet_11[gfk, on = .(RespID)]
gfk[,inet_news := if_else(is.na(inet_news), as.numeric(inet_news11), inet_news)]
gfk <- inet_13[gfk, on = .(RespID)]
gfk[,inet_news := if_else(is.na(inet_news), as.numeric(inet_news13), inet_news)]

gfk$inet_news01 <- NULL
gfk$inet_news03 <- NULL
gfk$inet_news05 <- NULL
gfk$inet_news07 <- NULL
gfk$inet_news09 <- NULL
gfk$inet_news11 <- NULL
gfk$inet_news13 <- NULL

# regularize names
clean_names <- function(.data, unique = FALSE) {
  n <- if (is.data.frame(.data)) colnames(.data) else .data
  n <- gsub("%+", "_pct_", n)
  n <- gsub("\\$+", "_dollars_", n)
  n <- gsub("\\++", "_plus_", n)
  n <- gsub("-+", "_minus_", n)
  n <- gsub("\\*+", "_star_", n)
  n <- gsub("#+", "_cnt_", n)
  n <- gsub("&+", "_and_", n)
  n <- gsub("@+", "_at_", n)
  n <- gsub("[^a-zA-Z0-9_]+", "_", n)
  n <- gsub("([A-Z][a-z])", "_\\1", n)
  n <- tolower(trimws(n))
  
  n <- gsub("(^_+|_+$)", "", n)
  
  n <- gsub("_+", "_", n)
  
  if (unique) n <- make.unique(n, sep = "_")
  
  if (is.data.frame(.data)) {
    colnames(.data) <- n
    .data
  } else {
    n
  }
}

gfk <- clean_names(gfk)
colnames(gfk)[1] <- "RespID"


## combine national TV
gfk[, tv_news_natl := as.numeric(tv_abc_this_week == 1 | tv_abc_wld_nw_tonite_minus_sat == 1 | 
	tv_abc_wld_nw_tonit_minus_sun == 1 | tv_abc_world_nws_tonite == 1 | tv_abc_wrld_nws_ths_mor == 1 | tv_cbs_evening_news == 1 | 
	tv_cbs_evening_news_minus_sat == 1 | tv_cbs_evening_news_minus_sun == 1 | tv_cbs_face_the_nation == 1 | tv_cbs_morning_news == 1 | 
	tv_cbs_sat_early_show == 1 | tv_cbs_sunday_morning == 1 | tv_cnn == 1 | tv_fox_news_sunday == 1 | tv_fox_news == 1 | 
	tv_headline_cnn_news == 1 | tv_msnbc == 1 | tv_nbc_meet_the_press == 1 | tv_nbc_nightly_news == 1 | tv_nbc_nightly_nws_minus_sat == 1 | 
	tv_nbc_nightly_nws_minus_sun == 1 | tv_nbc_saturday_today == 1 | tv_nbc_sunday_today == 1 | tv_newshour_jim_lehr == 1 | 
	tv_nightly_business_rep == 1 | tv_wall_street_jorn_rep == 1 | tv_abc_wld_nws_p_jenni == 1 | tv_abc_wld_nws_this_mor == 1 | 
	tv_abc_wld_nws_ton_minus_sat == 1 | tv_abc_wld_nws_ton_minus_sun == 1 | tv_cbs_evening_nws_minus_rath == 1 | 
	tv_cbs_evening_nws_minus_sun == 1 | tv_cbs_marketwatch == 1 | tv_cbs_morn_nws_j_chen == 1 | tv_nbc_nightly_nws_minus_brok == 1 | 
	tv_nbc_sat_today == 1 | tv_nbc_sun_today == 1 | tv_newshr_w_jim_lehrer == 1 | tv_wall_street_journ_report == 1 | 
	tv_abc_wld_nw_tnite_minus_sat == 1 | tv_abc_wld_nw_tnite_minus_sun == 1 | tv_abc_wrld_nws_tnight == 1 | tv_bbc_world_news == 1 | 
	tv_cbs_even_news_minus_sat == 1 | tv_cbs_even_news_minus_sun == 1 | tv_cbs_sat_early_shw == 1 | tv_cbs_sun_morning == 1 | 
	tv_newshour_w_j_lehrer == 1 | tv_nightly_bus_report == 1 | tv_wall_st_journal_rept == 1 | tv_abc_wrld_nws_tngt_sat == 1 | 
	tv_abc_wrld_nws_tngt_sun == 1 | tv_abc_wrld_nws_ths_mrn == 1 | tv_abc_wrld_nws_tnght == 1 | tv_bbc_world_news_m_minus_f == 1 | 
	tv_cbs_eve_news_sat == 1 | tv_cbs_eve_news_sun == 1 | tv_cbs_morning_nws == 1 | tv_cbs_sat_erly_show == 1 | 
	tv_chris_matthews_show == 1 | tv_good_mrng_amer_wk_ed == 1 | tv_nbc_nghtly_nws_sat == 1 | tv_nbc_nghtly_nws_sun == 1 | 
	tv_newshour_the == 1 | tv_wall_st_journal_rprt == 1 | tv_abc_news_nightline == 1 | tv_abc_this_wk_w_geo == 1 | 
	tv_abc_world_news_now == 1 | tv_abc_wrld_nws_ton_minus_sa == 1 | tv_abc_wrld_nws_ton_minus_su == 1 | tv_abc_wrld_nws_toni == 1 | 
	tv_cbs_eveni_news == 1 | tv_cbs_evening_news_minus_sa == 1 | tv_cbs_evening_news_minus_su == 1 | tv_cbs_face_nation == 1 | 
	tv_fox_news_sun  == 1 | tv_good_morn_amer_wkd == 1 | tv_nbc_meet_press == 1 | tv_nbc_nightly_news_minus_sa == 1 | 
	tv_nbc_nightly_news_minus_su == 1  | tv_pbs_news_hour == 1 | 
	tv_wall_st_journal_rpr == 1 | tv_abc_america_this_mo == 1 | tv_abc_nws_nightline == 1 | tv_abc_this_wk_w_georg == 1 | 
	tv_abc_wrld_nws_now == 1 | tv_abc_wrld_nws_ton_di == 1 | tv_all_night_minus_dateline == 1 | tv_bbc_wrld_nws == 1 | 
	tv_cbs_evening_nws_sco == 1 | tv_cbs_evening_nws_minus_sat == 1 | tv_cbs_morn_nws == 1 | tv_cbs_sun_morn == 1 | 
	tv_cbs_this_morn_sat == 1 | tv_fox_nws_sun == 1 | tv_good_morn_america_w == 1 | tv_nbc_nightly_nws_bri == 1 | tv_pbs_nws_hr == 1 | 
	tv_wall_street_jrl_minus_tv == 1)]
gfk[is.na(tv_news_natl),tv_news_natl:=0]

## combine national papers 
gfk[, read_natl_paper := as.numeric(read_nyt == 1 | read_usa_today == 1 | read_wapo == 1 | read_wsj == 1 | read_nyt_daily == 1 | read_nyt_sunday == 1)]
gfk[is.na(read_natl_paper),read_natl_paper:=0]



#### ADD INTERNET ACCESS ####


inet01 <- fread("gfk2001_inet_access.csv")
inet03 <- fread("gfk2003_inet_access.csv")
inet05 <- fread("gfk2005_inet_access.csv")
inet07 <- fread("gfk2007_inet_access.csv")
inet09 <- fread("gfk2009_inet_access.csv")
inet11 <- fread("gfk2011_inet_access.csv")

inet01 <- inet01[,.(RespID, gfk_inet_access = `[14241]: Internet - Have access: Internet access: At home`)]
inet03 <- inet03[,.(RespID, gfk_inet_access = `[14241]: Internet - Have access: Internet access: At home`)]
inet05 <- inet05[,.(RespID, gfk_inet_access = `[14241]: Internet - Have access: Internet access: At home`)]
inet07 <- inet07[,.(RespID, gfk_inet_access = `[14241]: Internet - Have access: Internet access: At home`)]
inet09 <- inet09[,.(RespID, gfk_inet_access = `[14241]: Internet - Have Access: Internet access: At home`)]
# inet11 <- inet11[,.(RespID, gfk_inet_access = `[14241]: Internet - Have Access At Home, Using A Computer: Yes [added \"\"using a computer\"\" in Wave 62]`)]




inet <- rbind(inet01, inet03, inet05, inet07, inet09, inet11)
inet[,RespID:=as.character(RespID)]


gfk <- inet[gfk, on = .(RespID)]

write_dta(gfk, "gfk.dta")