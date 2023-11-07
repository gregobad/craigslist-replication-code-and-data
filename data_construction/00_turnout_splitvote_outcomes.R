### build dataset of turnout and split-ticket voting

library(tidyverse)
library(data.table)
library(haven)
library(glue)

## change to directory where archive was extracted
data_dir <- "~/craigslist-replication-code-and-data/data"

stfips <- fread(glue("{data_dir}/state_fips_codes.csv")) %>% 
	setnames(old="statefips", new="stfips")
ctyfips <- fread(glue("{data_dir}/county_fips_codes.csv")) %>% 
	setnames(old=c("statefips", "countyfips", "stateabbr","countyname"), new=c("stfips", "ctyfips", "state","county"))

clean_vote <- function(dt) {
	dt[,.(statename = toupper(State),
		   year = as.numeric(substr(raceDate, 1,4)),
		   office = recode(Office, Governor = "gov", Senate = "sen", President = "pres"),
		   county = Area,
		   rep_vote = as.numeric(gsub(",","",RepVotes)),
		   dem_vote = as.numeric(gsub(",","",DemVotes)),
		   third_vote = as.numeric(gsub(",","",ThirdVotes)),
		   other_vote = as.numeric(gsub(",","",OtherVotes)))] %>%
	.[office %in% c("sen", "gov","pres")] %>% 
	.[,map(.SD, ~ replace_na(.,0)), by = .(statename, year, office, county),.SDcols = c("rep_vote", "dem_vote", "third_vote", "other_vote")] %>%
	.[stfips, on="statename", nomatch=0]
}

votes_pres <- fread(glue("{data_dir}/political/electoral/cq_voteshares_pres.csv"), fill=T, sep=",") %>%
	clean_vote

votes_sen <- fread(glue("{data_dir}/political/electoral/cq_voteshares_sen.csv"), fill=T, sep=",") %>%
	clean_vote

votes_gov <- fread(glue("{data_dir}/political/electoral/cq_voteshares_gov.csv"), fill=T, sep=",") %>%
	clean_vote

votes <- rbind(votes_pres, votes_gov, votes_sen)

# fix a few county names
votes[,county:=str_trim(county)]
votes[,county:=sub(" COUNTY", "", county)]

votes$county[votes$county=="PRINCE GEORGES"] <- "PRINCE GEORGE'S"
votes$county[votes$county=="LA MOURE"] <- "LAMOURE"
votes$county[votes$county=="LA PORTE"] <- "LAPORTE"
votes$county[votes$county=="DE BACA"] <- "DEBACA"
votes$county[votes$county=="DU PAGE"] <- "DUPAGE"
votes$county[votes$county=="DE WITT" & votes$state=="TX"] <- "DEWITT"
votes$county[votes$county=="DE SOTO" & votes$state %in% c("FL", "MS")] <- "DESOTO"
votes$county[votes$county=="QUEEN ANNES"] <- "QUEEN ANNE'S"
votes$county[votes$county=="ST. MARYS"] <- "ST. MARY'S"
votes$county[votes$county=="ST. LOUIS CITY"] <- "ST LOUIS CITY"
votes$county[votes$county=="KINGSBURG" & votes$state=="SD"] <- "KINGSBURY"
votes$county[grepl("WASHABAUGH", votes$county)] <- "JACKSON"
votes$county[votes$county=="WASHINGTON" & votes$state == "SD"] <- "JACKSON"

# el paso county, TX in 2002 sen race votes are wrong - swapped with Ellis county see:
# http://www.epcountyvotes.com/election-information/historical-election-results/#Election
# http://tx-elliscounty3.civicplus.com/DocumentCenter/View/7857/2002-11-05-General-Election-Final-Cum-Totals?bidId=
votes$rep_vote[votes$year==2002 & votes$office=="sen" & votes$county == "EL PASO" & votes$state == "TX"] <- 28642
votes$dem_vote[votes$year==2002 & votes$office=="sen" & votes$county == "EL PASO" & votes$state == "TX"] <- 69490
votes$other_vote[votes$year==2002 & votes$office=="sen" & votes$county == "EL PASO" & votes$state == "TX"] <- 1615
votes$rep_vote[votes$year==2002 & votes$office=="sen" & votes$county == "ELLIS" & votes$state == "TX"] <- 19285
votes$dem_vote[votes$year==2002 & votes$office=="sen" & votes$county == "ELLIS" & votes$state == "TX"] <- 8774
votes$other_vote[votes$year==2002 & votes$office=="sen" & votes$county == "ELLIS" & votes$state == "TX"] <- 314

# deduplicate county names for independent cities
ctyfips$county[ctyfips$ctyfips==510 & ctyfips$stfips==29] <- "ST LOUIS CITY"
ctyfips$county[ctyfips$ctyfips==510 & ctyfips$stfips==24] <- "BALTIMORE CITY"
ctyfips$county[ctyfips$ctyfips==515 & ctyfips$stfips==51] <- "BEDFORD CITY"
ctyfips$county[ctyfips$ctyfips==600 & ctyfips$stfips==51] <- "FAIRFAX CITY"
ctyfips$county[ctyfips$ctyfips==620 & ctyfips$stfips==51] <- "FRANKLIN CITY"
ctyfips$county[ctyfips$ctyfips==760 & ctyfips$stfips==51] <- "RICHMOND CITY"
ctyfips$county[ctyfips$ctyfips==770 & ctyfips$stfips==51] <- "ROANOKE CITY"

votes <- votes[ctyfips, on =c("state", "stfips", "county"), nomatch = 0]
votes[,total_vote := (rep_vote + dem_vote + third_vote + other_vote)]

votes_house <- read_dta(glue("{data_dir}/political/electoral/house.dta")) %>% as.data.table %>%
	.[,.(stfips=as.numeric(substr(str_pad(fips, width=5,pad="0"), 1,2)), ctyfips = as.numeric(substr(str_pad(fips, width=5,pad="0"), 3,5)), total_vote, rep_vote, dem_vote, year, office="house")]


## voting age population estimates
ctypop_2010s <- fread(glue("{data_dir}/census/county/intercensal_pop_estimates_county_2010s.csv")) %>%
	.[year > 2010] %>%
	.[agegrp==4,tot_pop:=tot_pop * 0.4] %>% 	# allocate 40% of the 15-19 age group
	.[agegrp>=4] %>% 
	.[,`:=` (ctyfips = as.numeric(substr(str_pad(county, width=5,pad="0"), 3,5)),
			 stfips = state)] %>%
	.[,.(voting_pop=sum(tot_pop)),by=.(stfips, ctyfips, year)]

ctypop_2000s <- fread(glue("{data_dir}/census/county/intercensal_pop_estimates_county_2000s.csv")) %>%
	setnames(old=c("STATE", "COUNTY"), new=c("stfips", "ctyfips")) %>%
	.[SEX==0 & AGEGRP>=4] %>% 
	gather(key = year, value = voting_pop, starts_with("POPESTIMATE")) %>%
	as.data.table %>%
	.[,year := as.numeric(sub("\\D+","",year))] %>%
	.[AGEGRP==4,voting_pop:=voting_pop * 0.4] %>% 	# allocate 40% of the 15-19 age group
	.[,.(voting_pop=sum(voting_pop)),by=.(stfips, ctyfips, year)]

y90s <- 1992:1999
ctypop_1990s <- y90s %>% 
	map(~ fread(paste0(data_dir, "/census/county/intercensal_pop_estimates_county_", ., ".csv"))) %>% 
	rbindlist %>%
	.[agegroup==4,pop:=pop * 0.4] %>% 	# allocate 40% of the 15-19 age group
	.[agegroup>=4,.(voting_pop=sum(pop)), by=.(year, state, county)] %>%
	.[,`:=` (ctyfips = as.numeric(substr(str_pad(county, width=5,pad="0"), 3,5)),
			 stfips = state)] %>%
	.[,.(year, stfips, ctyfips, voting_pop)]

ctypop <- rbind(ctypop_1990s, ctypop_2000s, ctypop_2010s)


votes <- votes[,.(year, stfips, ctyfips, office, rep_vote, dem_vote, total_vote)] %>%
	rbind(votes_house)

votes <- votes[ctypop, on=.(stfips, ctyfips, year), nomatch=0]
votes[,turnout := total_vote / voting_pop]
votes[,fips:=as.numeric(paste(str_pad(stfips, width=2, pad="0"), str_pad(ctyfips, width=3, pad="0"), sep=""))]


votes %>% saveRDS(file=glue("{data_dir}/political/electoral/county_vote_all.rds"))

votes <- votes %>%
	.[year >= 1996 & year <= 2012 & turnout > 0.1 & turnout < 0.9,.(year, fips, office, voting_pop, turnout, r_share = rep_vote / total_vote)]  ## assume any turnout values > 0.9 or < 0.1 are errors, drop

votes_wide <- votes %>% 
  .[,map(.SD, mean), by = .(year, fips, office), .SDcols = c("turnout", "r_share", "voting_pop")] %>%  # there's a double senate election in Wyoming in 2008; use average
  dcast(year + fips + voting_pop ~ office, value.var = c("turnout", "r_share"))


# split vote measures
votes_wide[,`:=` (house_dev = abs(r_share_pres - r_share_house),
                  sen_dev = abs(r_share_pres - r_share_sen))]

votes_wide[, avg_dev := if_else(!is.na(sen_dev), (house_dev + sen_dev) / 2, house_dev)]

# export
votes_wide <- votes_wide[order(fips, year)]
write_dta(votes_wide, path=glue("{data_dir}/political/turnout_data_notmerged.dta"))