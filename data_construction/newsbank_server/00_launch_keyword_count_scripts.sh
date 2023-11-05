#!/bin/bash

# create index of xml files to loop over
Rscript /home/gmartin/craigslist/generate_xml_folder_index.R

# count mentions of national politicians
rm /work/mentionfiles/*
julia -t 8 /home/gmartin/craigslist/count_nationalmentions_newsbank.jl

# count mentions of candidates for congress
rm /work/mentionfiles/*
julia -t 8 /home/gmartin/craigslist/count_mentions_newsbank_congress_and_candidates.jl

# count articles with mention of primary or nomination, and US House / Senate / Congress
rm /work/mentionfiles/*
julia -t 8 /home/gmartin/craigslist/count_primaries_newsbank.jl

# count references to AP / Reuters
rm /work/mentionfiles/*
julia -t 8 /home/gmartin/craigslist/count_ap_references_newsbank.jl

# count usage of Hamilton words plus local official titles
rm /work/mentionfiles/*
julia -t 8 /home/gmartin/craigslist/count_corruption_words_newsbank.jl

# count total articles (should be redundant with AP but just in case)
rm /work/mentionfiles/*
julia -t 8 /home/gmartin/craigslist/count_total_articles_newsbank.jl