library(data.table)
library(tidyverse)
library(haven)

data_dir <- "~/craigslist-replication-code-and-data/data"
read_dtadt <- compose(as.data.table, read_dta)


# all papers in NB, by newsbank ID (PBI)
source_index <- fread("{data_dir}/Newspapers_content/newsbank_folder_index.csv") %>%
  .[, .(PBI, paper)]

# drop duplicate paper names for the same PBI
dups <- source_index[,. (n = length(unique(paper))), by = .(PBI)][n > 1]
dups_to_drop <- source_index[dups, on = .(PBI)] %>%
  .[!grepl("\\([A-Z]{2}\\)", paper)]  # prefer the version ending in (ST)

source_index <- source_index[!dups_to_drop, on = .(PBI, paper)]

# translate to E&P paper names
nb_to_ep <- read_dtadt("{data_dir}/Newspapers_content/matching_NLPQ_to_EP/NL_namelist_matched_to_EP.dta") %>%
  .[, .(paper = NL_originalname, ep_std_name = NPNAME1)]

nb_to_ep_extra <- fread("{data_dir}/Newspapers_content/matching_NLPQ_to_EP/nb_unmatched_names_manual_adds.csv") %>%
  .[ep_std_name != ""]

nb_to_ep <- rbind(nb_to_ep, nb_to_ep_extra) %>%
  unique %>%
  .[order(ep_std_name)]

fwrite(nb_to_ep, file = "{data_dir}/Newspapers_content/matching_NLPQ_to_EP/nb_to_ep_all.csv")

source_index <- source_index[nb_to_ep, on = .(paper), nomatch = 0]

# index of which PBIs are tracked in Newsbank by year
pbi_years <- fread("{data_dir}/Newspapers_content/newsbank_paper_years.csv") %>% 
  unique

# convert PBI to E&P standardized name
ep_years <- pbi_years[source_index, on = .(PBI)] %>%
  .[order(ep_std_name, year)]

ep_years[, state := sub("\\w+([A-Z]{2})$", "\\1", ep_std_name)]

fwrite(ep_years, "{data_dir}/Newspapers_content/newsbank_ep_paper_years.csv")
