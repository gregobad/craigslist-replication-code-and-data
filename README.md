# Replication files for "The Impact of Online Competition on Local Newspapers: Evidence from the Introduction of Craigslist"

This repository contains replication code and data for Djourelova, Durante, and Martin (2023), "The Impact of Online Competition on Local Newspapers."

## How to use this archive

1. R and Stata scripts in `data_construction` construct the analysis datasets from the raw data. Some parts of these scripts depend on proprietary data not included in the archive (see below for description). These scripts must be run in the order specified in the file name: all scripts beginning with "00_" must be run before scripts beginning with "01_", and so on. Scripts with the same number prefix may be run in any order. This step can be skipped, as the resulting processed datasets are included in the `data` folder.

2. R, Stata scripts in `analysis` run the analyses and produce tables and figures in the paper from the processed data. Processed datasets are included in the archive in the `data` folder. These scripts may be run in any order. See below for indices describing which file produces each table or figure in the manuscript and appendices. Some of the tables / figures also depend on proprietary data. These are noted in the indices.



# Manuscript Figures / Tables to Source Code Index

Table / Figure | Code to Produce | Requires Proprietary Data?
------ | ------ | ------
Figure 1   | `make_maps.R` | 
Figure 2   | `___do_Figures_Main.do` | 
Figure 3   | `___do_Figures_Main.do` |
Figure 4   | `___do_Figures_Main.do` | Yes
Figure 5   | `___do_Figures_Main.do` |
Table 1    | `___do_Tables_Main.do` |
Table 2    | `___do_Tables_Main.do` |
Table 3    | `___do_Tables_Main.do` |
Table 4    | `___do_Tables_Main.do` |
Table 5    | `___do_Tables_Main.do` | 
Table 6    | `___do_Tables_Main.do` | Yes
Table 7    | `___do_Tables_Main.do` | 


# Appendix Figures / Tables to Source Code Index

Table / Figure | Code to Produce | Requires Proprietary Data?
------ | ------ | ------
Figure A.1   | `___do_Tables_Appendix.do` |
Figure A.2   | `___do_Tables_Appendix.do` |
Figure B.1 | N/A | 
Figure B.2 | N/A |  
Figure B.3 | N/A | 
Figure B.4 | `___do_Figures_Appendix.do` | Yes
Figure B.5 | `___do_Figures_Appendix.do` | Yes
Figure B.6 | `N/A` | 
Figure B.7 | `N/A` | 
Table A.1  | `___do_Tables.do` | 
Table A.2  | `___do_Tables_Appendix.do`  | Yes (panel c)
Table A.3  | `___do_Tables_Appendix.do`  | 
Table A.4  | `___do_Tables_Appendix.do` | 
Table A.5  | `___do_Tables_Appendix.do` | 
Table A.6  | `___do_Tables_Appendix.do` | 
Table A.7  | `___do_Tables_Appendix.do` | 
Table A.8  | `___do_Tables_Appendix.do` | 
Table A.9  | `___do_Tables_Appendix.do` | 
Table A.10  | `___do_Tables_Appendix.do` | 
Table A.11 | `___do_Tables_Appendix.do` | 
Table A.12  | `___do_Tables_Appendix.do` | 
Table A.13  | `___do_Tables_Appendix.do` | Yes
Table A.14 | `___do_Tables_Appendix.do` | Yes
Table A.15  | `___do_Tables_Appendix.do` | 
Table A.16  | `___do_Tables_Appendix.do` | 
Table A.17  | `___do_Tables_Appendix.do` | 
Table A.18  | `___do_Tables_Appendix.do` | 
Table A.19  | `___do_Tables_Appendix.do` | 
Table A.20  | `___do_Tables_Appendix.do` |
Table B.1  | `___do_Figures_Main.do` | 
Table B.2  | `___do_Tables_Appendix.do` |
Table B.3  | `/data_construction/01_Topic Model.ipynb` | Yes

# Description of Data Files

The `data` directory contains the main analysis data sets, `master_data_county_level.dta` and `master_data_newspaper_level.dta` used to run the regressions. It also contains raw data in the following directories: 


Directory | Description
------ | ------ 
`_co99_d00_shp` | County shape files
`_counties_to_CDs` | Crosswalks from county to congressional district
`_counties_to_DMAs` | Crosswalks from county to media market (DMA)
`_zipcode` | Zipcode to county crosswalks
`annenberg` | Predicted values of interest in news and classified sections given reader demographics, estimated in the National Annenberg Election Survey data (raw data not included)
`census` | Data from the US census used to crosswalk census tracts to counties, and for intercensal population estimates at county level
`Classified_Prices` | Digitized data from SRDS on classified rates at the newspaper-year level
`Comscore` | Aggregated website visits recorded by Comscore (raw data not included)
`craigslist_expansion` | Data on opening dates of local Craigslist sites
`controls' | Data on county-level socio-economic characteristics from the US census and BLS 
`E&P` | Digitized data from the Editor and Publisher yearbooks
`GfK-MRI` | Fitted models and predicted values of interest in news and classified sections given reader demographics, estimated in the GfK-MRI data (raw data not included)
`ISPs` | Data from the FCC on the number of Internet service providers by zip-code
`Newspapers.com` | Data on the number of classified pages per issue at the newspaper-year level, extracted from the Newspapers.com archive
`Newspapers_content` | Keyword counts and topic models extracted from the NewsBank database of newspaper content
`political` | Electoral data at county and county x congressional district level, along with information on members of congress used to generate keyword searches



# List of Data Construction Scripts


Script | Requires Proprietary Data?
------ | ------ 
`00_classifieds_clean_newspapers_com_data.R` | Yes
`00_clean_Annenberg.do`	| Yes
`00_clean_Comscore.do`	| Yes
`00_clean_ISPs.do`		| 
`00_congress_outcomes.R` 	|
`00_gfk_clean_gfkmri.R` | Yes
`00_keywordcounts_export_congressman_list.R`  | Yes
`00_keywordcounts_export_nb_search_folders.R` | Yes
`00_turnout_splitvote_outcomes.R` | 
`01_gfk_predict_classified_interest.R` | Yes
`01_keywordcounts_export_keyword_mentions.R` | Yes
`01_Topic Model.ipynb` | Yes
`02__do_master_county_level.do` |
`02__do_master_newspaper_level.do` |


# Sources for Proprietary Data Sets

There are four proprietary or access-restricted data sets used in the paper. These are:

1. NewsBank full-text archive. These data are required to run the scripts in `data_construction/newsbank_server`, which generate counts of mentions of politician names and other keywords in newspaper text. We licensed the NewsBank data through the Stanford University Libraries. Contact `jmcdowell@newsbank.com` for licensing inquiries. 

1. GfK-MRI Survey of the American Consumer. These data are used in the analysis of self-reported newspaper reading (reported in Table 6(a)). Contact `Adriane.Heimann@mrisimmons.com` for licensing inquiries.

1. National Annenberg Election Survey (NAES) restricted data. These data are used in the analysis of self-reported newspaper reading (reported in Table 6(b)). [Visit the NAES home page to request access.](https://www.annenbergpublicpolicycenter.org/political-communication/naes/)

1. Comscore WRDS web traffic panel. These data are used in the analysis of visits to the Craigslist.org domain (Figure 4). Visit https://wrds-www.wharton.upenn.edu/pages/about/data-vendors/comscore/ for licensing inquiries.
