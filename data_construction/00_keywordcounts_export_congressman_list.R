### Construct list of names to search for congressional reps + candidates


### SETUP ###
library(data.table)
library(tidyverse)
library(humaniformat)
library(glue)
library(lubridate)
library(jsonlite)


base <- "~/craigslist-replication-code-and-data/data/political/congressman_data"

parse_terms <- function(termstring){
    termstring <- sub(", 'fax': None", "", termstring) %>%
        gsub("'", '"', .) %>%
        parse_json

    terms <- data.table(
        office = map_chr(termstring, "type", .default = "rep"),
        start_date = ymd(map_chr(termstring, "start", .default = "1900-01-01")),
        end_date = ymd(map_chr(termstring, "end", .default = "1900-01-01")),
        state = map_chr(termstring, "state", .default = ""),
        party = map_chr(termstring, "party", .default = "None"),
        district = map_chr(termstring, ~ as.character(pluck(.,"district", .default = 0))))
    
    terms[office == "sen", district := "SE"]

    copy(terms)
    
}

parse_search_names <- function(raw_names) {
    name_df <- raw_names %>%
        format_reverse %>%
        parse_names

    paste(if_else(grepl("\\([A-Za-z ]+\\)", name_df$middle_name) | grepl("^[A-Z]\\.?$", name_df$first_name),
          gsub("[()]", "", name_df$middle_name),
          name_df$first_name), name_df$last_name, sep = " ")

}

### Load sitting congressman lists
l1 <- fread(glue("{base}/github/legislator_historical1.csv")) %>%
    .[, .(bioguide, first, last, middle, gender, terms, nickname, official_full, other_names)]
l2 <- fread(glue("{base}/github/legislators-current1.csv")) %>%
    .[, .(bioguide, first, last, middle, gender, terms, nickname, official_full, other_names)]

leg <- rbind(l1,l2)


### expand to 1 entry per term
leg <- leg[, parse_terms(terms),
           by = .(first, last, middle, gender, nickname, official_full, bioguide)]

leg <- leg[year(end_date) >= 2000 & year(start_date) <= 2012]

namecols <- c("first", "last", "middle", "nickname", "official_full")
leg <- leg[, (namecols) := map(.SD, iconv, from = "ISO-8859-1", to = "UTF-8", sub = ""), .SDcols = namecols]


### clean the names
leg[, searchname :=
        case_when(nickname != "" ~ paste(nickname, last),
                  TRUE ~ paste(first, last))]


leg[grepl("^[A-Z][a-z]?\\. [A-Za-z]+$", searchname), searchname := paste(first, middle, last)]
leg[grepl("^[A-Z][a-z]?\\. [A-Z][a-z]+", searchname), searchname := sub("^[A-Z][a-z]?\\. ", "", searchname)]

leg[grepl("Ruppersberger", searchname), searchname := "Dutch Ruppersberger"]
leg[searchname == "Kay Hutchison", searchname := "Kay Bailey Hutchison"]
leg[searchname == "Shelley Capito", searchname := "Shelley Moore Capito"]
leg[searchname == "Eddie Johnson", searchname := "Eddie Bernice Johnson"]
leg[searchname == "Eleanor Norton", searchname := "Eleanor Holmes Norton"]
leg[searchname == "H. L. Callahan", searchname := "H.L. Callahan"]
leg[searchname == "C. W. Bill Young", searchname := "Bill Young"]

leg_alt <- copy(leg[nickname != ""])
leg_alt[, searchname := paste(first, last)]
leg_alt[grepl("^[A-Z]\\. [A-Z][a-z]+$", searchname), searchname := paste(middle, last)]

leg <- rbind(leg, leg_alt)

leg[, searchname := iconv(searchname, to='ASCII//TRANSLIT')]

### drop territorial reps
leg <- leg[!state %in% c("PR", "GU", "MP", "AS", "VI")]

## standardize districts
leg[district == "0", district := "1"]
leg[office == "rep", district := paste0(state, str_pad(district, pad = "0", width = 2))]


leg[office == "rep"] %>% fwrite(glue("{base}/congressman_House_to2012.csv"))
leg[office == "sen"] %>% fwrite(glue("{base}/congressman_Senate_to2012.csv"))


### add in challengers from DIME
dime_names <- fread(glue("{base}/dime_cong_elections_current.csv")) %>%
    .[seat %in% c("federal:house", "federal:senate") &
      candidate_inactive == 0 &
      Incum_Chall != "I" &
      cycle >= 2000 &
      cycle <= 2012,
     .(cycle,
       office = if_else(seat == "federal:house", "rep", "sen"),
       district = if_else(seat == "federal:house", district, "SE"),
       state,
       party = case_when(party == "D" ~ "Democrat", party == "R" ~ "Republican", party == "I" ~ "Independent"),
       recipient_candid,
       recipient_fecid,
       bonica_rid,
       state,
       searchname = str_to_title(parse_search_names(Name)))
     ]

# clean up names, don't search for too-generic things like "J Smith"
dime_names[grepl("^[A-Z]\\.? ", searchname), searchname := sub("^[A-Z]\\.? ", "", searchname)]
dime_names[, searchname := gsub('"', '', searchname)]
dime_names <- dime_names[grepl("[A-Z][a-z]+ \\w+", searchname)]
dime_names[grep("\\w+ [A-Z]\\.? \\w+", searchname), searchname := sub("(\\w+) ([A-Z]\\.?) (\\w+)", "\\1 \\3", searchname)]

dime_names[, start_date := ymd(paste0(cycle - 1, "/01/01"))]
dime_names[, end_date := ymd(paste0(cycle, "/12/31"))]

fwrite(dime_names,
    file = glue("{base}/congressional_candidate_names.csv"))


## combine both sets of names together
combined <- rbind(
    leg[, .(id = bioguide, office, district, state, party, start_date, end_date, incumbent = 1, searchname)],
    dime_names[, .(id = bonica_rid, office, district, state, party, start_date, end_date, incumbent = 0, searchname)]
)

fwrite(combined,
    file = glue("{base}/congressional_candidate_and_incumbent_names.csv"))

## sitting reps who run for Senate will be double-counted in the "anycongress" measure; keep track
combined[, searchname := tolower(searchname)]
problemguys <- combined %>%
    .[, first_in_house := min(start_date[office == "rep" & incumbent == 1]), by = .(searchname, state)] %>%
    .[, last_in_house := max(end_date[office == "rep" & incumbent == 1]), by = .(searchname, state)] %>%
    .[!is.na(first_in_house), .(problem = any(incumbent == 0 & office == "sen" & end_date >= first_in_house & start_date <= last_in_house)),
    by = .(searchname, state)] %>%
    .[problem == TRUE]

combined[problemguys, on = .(searchname, state)] %>%
    .[office == "sen" & incumbent == 0 & end_date > first_in_house & start_date < last_in_house] -> todrop

fwrite(todrop,
    file = glue("{base}/house_members_running_for_senate.csv"))
