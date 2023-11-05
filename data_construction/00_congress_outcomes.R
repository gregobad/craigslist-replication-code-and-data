### build dataset of congressional district-level outcomes ###

library(tidyverse)
library(lubridate)
library(data.table)
library(haven)
library(glue)
library(magrittr)
library(ipumsr)

## change to directory where archive was extracted
data_dir <- "~/craigslist-replication-code-and-data/data"

read_dtadt <- compose(as.data.table, read_dta)


### campaign finance and election data
# note: 2001/2002 roll call outcomes correspond to districts in 2000 elections, 2003/2004 outcomes correspond to 2002 elections...
# votes and contribs are concurrent

dwdime <- fread(glue("{data_dir}/political/congressman_data/rf_predicted_scores.csv"))
dwdime[, party := case_when(party == 100 ~ "D", party == 200 ~ "R", TRUE ~ "I")]
setnames(dwdime, old = "rid", new = "bonica_rid")
dwdime <- dwdime[!(state %in% c("00", "AS", "GU", "MP", "VI", "PR")),
                 .(dwdime = mean(dwdime), num_unq_donors = mean(num_unq_donors)),
                 by = .(bonica_rid, state, party)]  # deal with repeats w/ different names, same id


dime <- fread(glue("{data_dir}/political/congressman_data/dime_cong_elections_current.csv"))
dime <- dwdime[dime, on = .(bonica_rid, state, party)]

# fix a couple of elections (mostly seems to occur when candidates with the same last name appear in the primary)
# or when sitting house members run for senate
dime[bonica_rid %in% c("cand1144", "cand43865") & cycle == 2012 & district == "NY13", district := "NY11"]
dime[bonica_rid == "cand43784" & cycle == 2002 & district == "NY05", district := "NY02"]

baddime <- 
  rbind(
  dime[bonica_rid == "cand52225" & cycle == 1998 & district == "OK03", ],
  dime[bonica_rid == "cand52727" & cycle == 1998 & district == "TX04", ],
  dime[bonica_rid == "cand48741" & cycle == 2004 & district == "TX16", ],
  dime[bonica_rid == "cand36185" & cycle == 2006 & district == "HI02", ],
  dime[bonica_rid == "cand36208" & cycle == 2006 & district == "HI02", ],
  dime[bonica_rid == "cand52724" & cycle == 2006 & district == "TX03", ],
  dime[bonica_rid == "cand876" & cycle == 2012 & district == "CA39", ],
  dime[bonica_rid == "cand791" & cycle == 2012 & district == "NJ10", ],
  dime[bonica_rid == "cand1057" & cycle == 2012 & district == "NM01", ],
  dime[bonica_rid == "cand1544" & cycle == 2012 & district == "WI02", ],
  dime[bonica_rid == "cand1526" & cycle == 2012 & district == "NV01", ],
  dime[bonica_rid == "cand52675" & cycle == 2006 & district == "TN09", ],
  dime[bonica_rid == "cand820" & cycle == 2012 & district == "AZ06", ],
  dime[bonica_rid == "cand53373" & cycle == 2008 & district == "AZ03", ],
  dime[bonica_rid == "cand978" & cycle == 2012 & district == "HI02", ],
  dime[bonica_rid == "cand982" & cycle == 2012 & district == "IN02", ],
  dime[bonica_rid == "cand843" & cycle == 2012 & district == "MO02", ],
  dime[bonica_rid == "cand1150" & cycle == 2012 & district == "ND01", ]
)

dime <- dime[!baddime, on = .(bonica_rid, cycle, district)]

dime_house_all <- dime[seat == "federal:house" &
                       (candidate_inactive == 0 | is.na(candidate_inactive)),
                       .(state,
                         district = substr(district, 3, 4),
                         year = cycle,
                         dwdime,
                         recipient_cfscore,
                         num_distinct_donors_all_donors,
                         total_receipts,
                         total_indiv_contrib,
                         total_pac_contribs,
                         unitemized)]




# use base year of 2000 to define the centrist / extremist thresholds
thresh <- quantile(dime_house_all[year == 2000, recipient_cfscore], probs = c(0.25, 0.5, 0.75), na.rm = T)
thresh_dwdime <- quantile(dime_house_all[year == 2000, dwdime], probs = c(0.25, 0.5, 0.75), na.rm = T)

dime_house_all[, ideo_group := case_when(recipient_cfscore <= thresh[1] ~ "extrem_left",
                                         recipient_cfscore >= thresh[3] ~ "extrem_right",
                                         recipient_cfscore > thresh[1] & recipient_cfscore < thresh[3] ~ "moderate",
                                         TRUE ~ "nocfscore")]

dime_house_contribs <- dime_house_all[,
                            .(total_receipts = sum(total_receipts, na.rm = T),
                              num_distinct_donors = as.numeric(max(num_distinct_donors_all_donors, na.rm = T)),
                              total_indiv_contrib = sum(total_indiv_contrib, na.rm = T),
                              total_pac_contrib   = sum(total_pac_contribs, na.rm = T),
                              total_unitemized_contrib = sum(unitemized, na.rm = T)),
                            by = .(year, state, district, ideo_group)] %>%
                        melt(id.vars = c("year", "state", "district", "ideo_group")) %>%
                        dcast(year + state + district ~ variable + ideo_group)


dime_house_contribs <- dime_house_contribs[, map(.SD, replace_na, replace = 0),
                                            by = .(year, state, district)]

dime_house_general <- dime[seat == "federal:house" &
                           (candidate_inactive == 0 | is.na(candidate_inactive)) &
                           (pwinner == "W" | !is.na(gwinner) | !is.na(gpct)),
  .(Name, bonica_rid, state, district = substr(district, 3, 4), year = cycle, party, recipient_cfscore, dwdime, pwinner, ppct, gwinner, gpct, Incum_Chall)]

## determine who is in the general
# if gpct defined for anyone in the race, keep candidates getting at least 10% in the general; else use pwinner
dime_house_general <- dime_house_general[order(year, state, district, desc(gpct), desc(gwinner), desc(pwinner))]
dime_house_general[,has_gpct := any(!is.na(gpct)), by = .(year, state, district)]
dime_house_general <- dime_house_general[(has_gpct & gpct >= 0.1) | (!has_gpct & pwinner == "W")]

dime_house_general <- dime_house_general %>%
  .[, ideo_group := case_when(recipient_cfscore <= thresh[1] ~ "extrem_left",
                              recipient_cfscore >= thresh[3] ~ "extrem_right",
                              recipient_cfscore > thresh[1] & recipient_cfscore < thresh[3] ~ "moderate",
                              TRUE ~ "nocfscore")] %>%
  .[, ideo_group_dwdime := case_when(dwdime <= thresh_dwdime[1] ~ "extrem_left",
                              dwdime >= thresh_dwdime[3] ~ "extrem_right",
                              dwdime > thresh_dwdime[1] & dwdime < thresh_dwdime[3] ~ "moderate",
                              TRUE ~ "nocfscore")] %>%
  .[, .(incumb_party = party[which(Incum_Chall == "I")][1],
       winner_party = party[which(gwinner == "W")][1],
       winner_cfscore = abs(recipient_cfscore[which(gwinner == "W")][1] - thresh[2]),
       winner_dwdime = abs(dwdime[which(gwinner == "W")][1] - thresh_dwdime[2]),
       winner_group = ideo_group[which(gwinner == "W")][1],
       winner_group_dwdime = ideo_group_dwdime[which(gwinner == "W")][1],
       dem_group = ideo_group[which(party == "D")][1],
       rep_group = ideo_group[which(party == "R")][1],
       ind_group = ideo_group[which(party == "I")][1],
       dem_group_dwdime = ideo_group_dwdime[which(party == "D")][1],
       rep_group_dwdime = ideo_group_dwdime[which(party == "R")][1],
       ind_group_dwdime = ideo_group_dwdime[which(party == "I")][1],
       diverge_cfscore = diff(range(recipient_cfscore, na.rm = T)),
       diverge_dwdime = diff(range(dwdime, na.rm = T)),
       extremist_in_general = as.numeric(any(ideo_group %in% c("extrem_left", "extrem_right"))),
       extremist_in_general_dwdime = as.numeric(any(ideo_group_dwdime %in% c("extrem_left", "extrem_right"))),
       n_cands = .N,
       cfscored_cands = sum(!is.na(recipient_cfscore)),
       dwdimed_cands = sum(!is.na(dwdime))
       ),
       by = .(year, state, district)]

dime_house_general[is.infinite(diverge_cfscore), diverge_cfscore := as.numeric(NA)]
dime_house_general[is.infinite(diverge_dwdime), diverge_dwdime := as.numeric(NA)]

dime_house_primary <- dime[seat == "federal:house" &
                           (candidate_inactive == 0 | is.na(candidate_inactive)) &
                           (!is.na(pwinner) | !is.na(ppct)),
  .(Name, bonica_rid, state, district = substr(district, 3, 4), year = cycle, party, recipient_cfscore, dwdime, pwinner, ppct, gwinner, gpct, Incum_Chall)]
  

dime_house_primary <- dime_house_primary[order(year, state, district, desc(ppct), desc(pwinner))]
dime_house_primary[,has_ppct := any(!is.na(ppct)), by = .(year, state, district)]
dime_house_primary <- dime_house_primary[(has_ppct & ppct >= 0.05) | (!has_ppct & !is.na(pwinner))]
   
dime_house_primary <- dime_house_primary %>%
  .[, ideo_group := case_when(recipient_cfscore <= thresh[1] ~ "extrem_left",
                              recipient_cfscore >= thresh[3] ~ "extrem_right",
                              recipient_cfscore > thresh[1] & recipient_cfscore < thresh[3] ~ "moderate",
                              TRUE ~ "nocfscore")] %>%
  .[, ideo_group_dwdime := case_when(dwdime <= thresh_dwdime[1] ~ "extrem_left",
                              dwdime >= thresh_dwdime[3] ~ "extrem_right",
                              dwdime > thresh_dwdime[1] & dwdime < thresh_dwdime[3] ~ "moderate",
                              TRUE ~ "nocfscore")] %>%
  .[, .(dempri_winner_cfscore = abs(recipient_cfscore[which(pwinner == "W" & party == "D")][1] - thresh[2]),
       dempri_winner_dwdime = abs(dwdime[which(pwinner == "W" & party == "D")][1] - thresh_dwdime[2]),
       dempri_winner_group = ideo_group[which(pwinner == "W" & party == "D")][1],
       dempri_winner_group_dwdime = ideo_group_dwdime[which(pwinner == "W" & party == "D")][1],
       reppri_winner_cfscore = abs(recipient_cfscore[which(pwinner == "W" & party == "R")][1] - thresh[2]),
       reppri_winner_dwdime = abs(dwdime[which(pwinner == "W" & party == "R")][1] - thresh_dwdime[2]),
       reppri_winner_group = ideo_group[which(pwinner == "W" & party == "R")][1],
       reppri_winner_group_dwdime = ideo_group_dwdime[which(pwinner == "W" & party == "R")][1],
       dempri_diverge_cfscore = diff(range(recipient_cfscore[which(party == "D")], na.rm = T)),
       dempri_diverge_dwdime = diff(range(dwdime[which(party == "D")], na.rm = T)),
       reppri_diverge_cfscore = diff(range(recipient_cfscore[which(party == "R")], na.rm = T)),
       reppri_diverge_dwdime = diff(range(dwdime[which(party == "R")], na.rm = T)),
       extremist_in_dempri = as.numeric(any(ideo_group[which(party == "D")] %in% c("extrem_left", "extrem_right"))),
       extremist_in_dempri_dwdime = as.numeric(any(ideo_group_dwdime[which(party == "D")] %in% c("extrem_left", "extrem_right"))),
       extremist_in_reppri = as.numeric(any(ideo_group[which(party == "R")] %in% c("extrem_left", "extrem_right"))),
       extremist_in_reppri_dwdime = as.numeric(any(ideo_group_dwdime[which(party == "R")] %in% c("extrem_left", "extrem_right"))),
       n_cands_dempri = sum(party == "D"),
       n_cands_reppri = sum(party == "R"),
       cfscored_cands_dempri = sum(!is.na(recipient_cfscore[which(party == "D")])),
       cfscored_cands_reppri = sum(!is.na(recipient_cfscore[which(party == "R")])),
       dwdimed_cands_dempri = sum(!is.na(dwdime[which(party == "D")])),
       dwdimed_cands_reppri = sum(!is.na(dwdime[which(party == "R")]))
       ),
       by = .(year, state, district)]

dime_house_primary[is.infinite(dempri_diverge_cfscore), dempri_diverge_cfscore := as.numeric(NA)]
dime_house_primary[is.infinite(reppri_diverge_cfscore), reppri_diverge_cfscore := as.numeric(NA)]
dime_house_primary[is.infinite(dempri_diverge_dwdime), dempri_diverge_dwdime := as.numeric(NA)]
dime_house_primary[is.infinite(reppri_diverge_dwdime), reppri_diverge_dwdime := as.numeric(NA)]


dime_house <- dime_house_contribs[dime_house_primary, on = .(state, district, year)] %>%
  .[dime_house_general, on = .(state, district, year)] %>%
  .[year >= 1996 & year <= 2010]

# read house votes by district x county, expand dataset to county-district cells
ys <- seq(1996, 2010, 2)
names(ys) <- ys
votes_dist_cty <- ys %>%
    map(~ setnames(fread(paste0(data_dir, "/political/electoral/house_", ., "_county_dist.csv")), old = "FIPS", new = "fips",skip_absent = T)) %>%
    rbindlist(fill = T, idcol = "year") %>%
    .[state != ""] %>%
    .[state == "TXTX", state := "TX"] %>%
    .[, .(year = parse_number(year),
        fips,
        state,
        district = str_pad(CD, width = 2, pad = "0"),
        vs_dem = parse_number(Democratic, na = c("", "NA", "-")),
        vs_rep = parse_number(Republican, na = c("", "NA", "-")),
        vs_ind = parse_number(Independent, na = c("", "NA", "-")) + parse_number(Other, na = c("", "NA", "-")),
        votes_cast = `Total Vote`)] %>%
    .[order(year, state, fips, district)] %>%
    .[votes_cast > 0]

# KC reports separately creating duplicate entry for 29095 (Jackson county)
# combine them

nrow(votes_dist_cty)
# [1] 29539
votes_dist_cty <- votes_dist_cty[, .(vs_dem = weighted.mean(vs_dem, w = votes_cast),
                                    vs_rep = weighted.mean(vs_rep, w = votes_cast),
                                    vs_ind = weighted.mean(vs_ind, w = votes_cast),
                                    votes_cast = sum(votes_cast)),
                                  by = .(year, fips, state, district)]

nrow(votes_dist_cty)
# [1] 29531   (merged 8 rows corresponding to Jackson MO)

votes_dist_cty[, vote_frac := votes_cast / sum(votes_cast), by = .(year, state, fips)]

## add AK back - not in the dist x county or county files
## just repeat statewide shares for every fips
ak <- fread(glue("{data_dir}/political/electoral/AK_house_vote.csv")) %>%
  .[, district := str_pad(district, pad = "0", width = 2)] %>%
  .[year <= 2010, .(fips = c(2013,2016,2020,2050,2060,2068,2070,2090,2100,2110,2122,2130,2150,2164,2170,2180,2185,2188,2201,2220,2232,2240,2261,2270,2280,2282,2290),
       votes_cast = NA, vs_dem, vs_rep, vs_ind), by = .(year, state, district)] %>%
  .[, vote_frac := NA]

votes_dist_cty <- rbind(votes_dist_cty, ak)
setnames(votes_dist_cty, old = "year", new = "election_year")

## weight each county-district cell by voting age population

# read tract-level voting-age population

tracts90 <- read_nhgis(glue("{data_dir}/census/tract/nhgis0016_ds120_1990_tract.csv")) %>%
  setDT %>%
  .[,.(fips = as.numeric(paste0(STATEA, COUNTYA)), tract = TRACTA, pop18 = ET3013 + ET3014 + ET3015 + ET3016 + ET3017 + ET3018 + ET3019 + ET3020 + ET3021 + ET3022 + ET3023 + ET3024 + ET3025 + ET3026 + ET3027 + ET3028 + ET3029 + ET3030 + ET3031)]
 
tracts00 <- read_nhgis(glue("{data_dir}/census/tract/nhgis0009_ds146_2000_tract.csv")) %>% 
  setDT %>% 
  .[,.(fips = as.numeric(paste0(STATEA, COUNTYA)), tract = TRACTA, pop18 = FMH001)]

tracts10 <- read_nhgis(glue("{data_dir}/census/tract/nhgis0015_ds172_2010_tract.csv")) %>% 
  setDT %>% 
  .[,.(fips = as.numeric(paste0(STATEA, COUNTYA)), tract = TRACTA, 
       pop18 = H76007 + H76007 + H76008 + H76009 + H76010 + H76011 + H76012 + H76013 + H76014 + H76015 + H76016 + H76017 + H76018 + H76019 + H76020 + H76021 + H76022 + H76023 + H76024 + H76025 + H76031 + H76032 + H76033 + H76034 + H76035 + H76036 + H76037 + H76038 + H76039 + H76040 + H76041 + H76042 + H76043 + H76044 + H76045 + H76046 + H76047 + H76048 + H76049)]


# read tract to CD assignments
st_fips <- fread(glue("{data_dir}/state_fips_codes.csv"))[,.(state, statefips)]
tract2cd103 <- fread(glue("{data_dir}/_counties_to_CDs/tract_to_cd103.csv")) %>% 
  .[,.(fips=county, tract=str_pad(tract*100,width=6, pad="0"), statefips=stfips, district = str_pad(cd103, pad="0", width=2), afact)] %>% 
  .[st_fips, on = .(statefips)] %>% 
  .[,.(fips, tract, state, district, afact)]
tract2cd103[district=="00", district:="01"]

tract2cd106 <- fread(glue("{data_dir}/_counties_to_CDs/tract_to_cd106.csv")) %>% 
  .[,.(fips=county, tract=str_pad(tract*100,width=6, pad="0"), state = stab, district = str_pad(cd106, pad="0", width=2), afact)]
tract2cd106[district=="00", district:="01"]

tract2cd108 <- fread(glue("{data_dir}/_counties_to_CDs/tract_to_cd108.csv")) %>% 
  .[,.(fips=county, tract=str_pad(tract*100,width=6, pad="0"), state = stab, district = str_pad(cd108, pad="0", width=2), afact)]
tract2cd108[district=="00", district:="01"]

tract2cd109 <- fread(glue("{data_dir}/_counties_to_CDs/tract_to_cd109.csv")) %>% 
  .[,.(fips=county, tract=str_pad(tract*100,width=6, pad="0"), state = stab, district = str_pad(cd109, pad="0", width=2), afact)]
tract2cd109[district=="00", district:="01"]

tract2cd111 <- fread(glue("{data_dir}/_counties_to_CDs/tract_to_cd111.csv")) %>% 
  .[,.(fips=county, tract=str_pad(tract*100,width=6, pad="0"), state = stab, district = str_pad(cd111, pad="0", width=2), afact)]
tract2cd111[district=="00", district:="01"]

# join tracts with census pop 18+ data
tract2cd103 <- tracts90[tract2cd103, on = .(fips, tract), nomatch=0]
tract2cd106 <- tracts00[tract2cd106, on = .(fips, tract), nomatch=0]
tract2cd108 <- tracts00[tract2cd108, on = .(fips, tract), nomatch=0]
tract2cd109 <- tracts00[tract2cd109, on = .(fips, tract), nomatch=0]
tract2cd111 <- tracts10[tract2cd111, on = .(fips, tract), nomatch=0]

# expand for in between years
tract2cd1996 <- copy(tract2cd106)[,election_year:=1996]
tract2cd1998 <- copy(tract2cd106)[,election_year:=1998]
tract2cd2000 <- copy(tract2cd106)[,election_year:=2000]
tract2cd2002 <- tract2cd108[,election_year:=2002]
tract2cd2004 <- copy(tract2cd109)[,election_year:=2004]
tract2cd2006 <- copy(tract2cd109)[,election_year:=2006]
tract2cd2008 <- copy(tract2cd111)[,election_year:=2008]
tract2cd2010 <- copy(tract2cd111)[,election_year:=2010]


# combine
tract2cd <- rbind(tract2cd1996,tract2cd1998,tract2cd2000,tract2cd2002,tract2cd2004,tract2cd2006,tract2cd2008,tract2cd2010)

cty2cd <- tract2cd[,.(pop18 = sum(pop18*afact)), by = .(election_year,fips, state, district)]

# check match 
# good except NC / VA in 1996, GA/TX in 2006
votes_dist_cty[!cty2cd, on =.(election_year, fips, state, district)] %$% table(state, election_year)

# join votes with census pops
votes_dist_cty <- cty2cd[votes_dist_cty, on = .(election_year, fips, state, district)]

# set indicators for redistricting regimes
votes_dist_cty[election_year < 2002, redist_regime:=1992]   ## all states except NC, VA
votes_dist_cty[election_year >= 2002, redist_regime:=2002]  ## all states except GA, TX
votes_dist_cty[election_year >= 2006 & state == "GA", redist_regime:=2005]    ## GA redrew districts in 2005
votes_dist_cty[election_year >= 2004 & state == "TX", redist_regime:=2003]    ## TX redrew districts in 2003
votes_dist_cty[election_year > 1998 & election_year <= 2002 & state == "VA", redist_regime:=1998]     ## VA court-ordered redistricting of dist. 3 in 1998
votes_dist_cty[election_year == 2000 & state == "NC", redist_regime := 1998]     ## NC court-ordered redistricting in 1998
votes_dist_cty[election_year == 2002 & state == "NC", redist_regime := 2000]     ## second change after NC court-ordered redistricting in 1998


# fill pop using average turnout rate for occasional dist / county cells not in the census data (197 total obs)
votes_dist_cty[, .(mean(pop18 / votes_cast, na.rm = T)), by = .(election_year)]
#    election_year       V1
# 1:          1996 2.662147
# 2:          1998 3.075139
# 3:          2000 2.125312
# 4:          2002 2.891341
# 5:          2004 1.870896
# 6:          2006 2.663302
# 7:          2008 1.961916
# 8:          2010 2.719317

votes_dist_cty[is.na(pop18)] %$% table(state, election_year)
votes_dist_cty[is.na(pop18) & election_year == 1996, pop18 := 2.66 * votes_cast]
votes_dist_cty[is.na(pop18) & election_year == 1998, pop18 := 3.08 * votes_cast]
votes_dist_cty[is.na(pop18) & election_year == 2000, pop18 := 2.13 * votes_cast]
votes_dist_cty[is.na(pop18) & election_year == 2002, pop18 := 2.89 * votes_cast]
votes_dist_cty[is.na(pop18) & election_year == 2004, pop18 := 1.87 * votes_cast]
votes_dist_cty[is.na(pop18) & election_year == 2006, pop18 := 2.66 * votes_cast]
votes_dist_cty[is.na(pop18) & election_year == 2008, pop18 := 1.96 * votes_cast]
votes_dist_cty[is.na(pop18) & election_year == 2010, pop18 := 2.72 * votes_cast]
votes_dist_cty <- votes_dist_cty[!is.na(pop18)]   # drops 6 remaining obs

# weights: fraction of district residing in county
votes_dist_cty[, w_cty_dist := pop18 / sum(pop18), by = .(election_year, state, district)]

# join with DIME data
# for DIME, election year => year
setnames(votes_dist_cty, old = "election_year", new = "year")
vote_cf_dist_cty <- dime_house[votes_dist_cty, on = .(year, state, district)]

vote_cf_dist_cty[, vs_extrem_left := (dem_group == "extrem_left") * vs_dem + (rep_group == "extrem_left") * vs_rep]
vote_cf_dist_cty[, vs_extrem_right := (dem_group == "extrem_right") * vs_dem + (rep_group == "extrem_right") * vs_rep]
vote_cf_dist_cty[, vs_moderate := (rep_group == "moderate") * vs_rep + (dem_group == "moderate") * vs_dem]

vote_cf_dist_cty[, vs_extrem_left_dwdime := (dem_group_dwdime == "extrem_left") * vs_dem + (rep_group_dwdime == "extrem_left") * vs_rep]
vote_cf_dist_cty[, vs_extrem_right_dwdime := (dem_group_dwdime == "extrem_right") * vs_dem + (rep_group_dwdime == "extrem_right") * vs_rep]
vote_cf_dist_cty[, vs_moderate_dwdime := (rep_group_dwdime == "moderate") * vs_rep + (dem_group_dwdime == "moderate") * vs_dem]

vote_cf_dist_cty[, vs_incumb := (incumb_party == "D") * vs_dem + (incumb_party == "R") * vs_rep]
vote_cf_dist_cty[, turnover := if_else(is.na(incumb_party), 1, as.numeric(winner_party != incumb_party))]

# save
fwrite(vote_cf_dist_cty, glue("{data_dir}/political/house_elections_cf_dist_cty.csv"))
