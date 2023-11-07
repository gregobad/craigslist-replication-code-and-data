# Replication files for "The Impact of Online Competition on Local Newspapers: Evidence from the Introduction of Craigslist"

This repository contains replication code and data for Djourelova, Durante, and Martin (2023), "The Impact of Online Competition on Local Newspapers."

## How to use this archive

1. R and Stata scripts in `data_construction` construct the analysis datasets from the raw data. Some parts of these scripts depend on proprietary data not included in the archive (see below for description). These scripts must be run in the order specified in the file name: all scripts beginning with "00_" must be run before scripts beginning with "01_", and so on. Scripts with the same number prefix may be run in any order. This step can be skipped, as the resulting processed datasets are included in the `data` folder.

2. R, Stata scripts in `analysis` run the analyses and produce tables and figures in the paper from the processed data. Processed datasets are included in the archive in the `data` folder. These scripts may be run in any order. See below for indices describing which file produces each table or figure in the manuscript and appendices. Some of the tables / figures also depend on proprietary data. These are noted in the indices.



# Manuscript Figures / Tables to Source Code Index

Table / Figure | Code to Produce | Requires Proprietary Data?
------ | ------ | ------
Figure 1   | `make_maps.R` | 
Figure 2   | `?.do` | 
Figure 3   | `?.do` |
Figure 4   | `?.do` | Yes
Figure 5   | `?.do` |
Table 1    | `?.do` |
Table 2    | `?.do` |
Table 3    | `?.do` |
Table 4    | `?.do` |
Table 5    | `?.do` | 
Table 6    | `?.do` | Yes
Table 7    | `?.do` | 


# Appendix Figures / Tables to Source Code Index

Table / Figure | Code to Produce | Requires Proprietary Data?
------ | ------ | ------
Figure A.1   | `?.do` |
Figure A.2   | `?.do` |
Figure B.1 | N/A | 
Figure B.2 | N/A |  
Figure B.3 | N/A | 
Figure B.4 | `?.do` | Yes
Figure B.5 | `?.do` | Yes
Figure B.6 | `?.do` | 
Figure B.7 | `?.do` | 
Table A.1  | `?.do` | 
Table A.2  | `?.do`  | 
Table A.3  | `?.do`  | 
Table A.4  | `?.do` | 
Table A.5  | `?.do` | 
Table A.6  | `?.do` | 
Table A.7  | `?.do` | 
Table A.8  | `?.do` | 
Table A.9  | `?.do` | 
Table A.10  | `?.do` | 
Table A.11 | `?.do` | 
Table A.12  | `?.do` | 
Table A.13  | `?.do` | Yes
Table A.14 | `?.do` | Yes
Table A.15  | `?.do` | 
Table A.16  | `?.do` | 
Table A.17  | `?.do` | 
Table A.18  | `?.do` | 
Table A.19  | `?.do` | 
Table A.20  | `?.do` |
Table B.1  | `?.do` | 
Table B.2  | `?.do` |
Table B.3  | `?.do` |

# Description of Data Files

The `data` directory contains the main analysis data sets, `master_data_county_level.dta` and `master_data_newspaper_level.dta` used to run the regressions. It also contains raw data in the following directories: 


Directory | Description
------ | ------ 
`annenberg` | Predicted values of interest in news and classified sections given reader demographics, estimated in the National Annenberg Election Survey data (raw data not included)
`census` | Data from the US census used to crosswalk census tracts to counties, and for intercensal population estimates at county level
`Classified_Prices` | Data from SRDS on classified rates at the newspaper-year level
`_counties_to_CDs` | Crosswalks from county to congressional district
`craigslist_expansion` | Data on opening dates of local Craigslist sites
`E&P` | Digitized data from the Editor and Publisher yearbooks
`GfK-MRI` | Fitted models and predicted values of interest in news and classified sections given reader demographics, estimated in the GfK-MRI data (raw data not included)
`Newspapers.com` | Data on the number of classified pages per issue at the newspaper-year level, extracted from the Newspapers.com archive
`Newspapers_content` | Keyword counts and topic models extracted from the NewsBank database of newspaper content
`political` | Electoral data at county and county x congressional district level, along with information on members of congress used to generate keyword searches


# Sources for Proprietary Data Sets

There are four proprietary or access-restricted data sets used in the paper. These are:

1. NewsBank full-text archive. These data are required to run the scripts in `data_construction/newsbank_server`, which generate counts of mentions of politician names and other keywords in newspaper text. We licensed the NewsBank data through the Stanford University Libraries. Contact `jmcdowell@newsbank.com` for licensing inquiries. 

1. GfK-MRI Survey of the American Consumer. These data are used in the analysis of self-reported newspaper reading (reported in Table 6(a)). Contact `Adriane.Heimann@mrisimmons.com` for licensing inquiries.

1. National Annenberg Election Survey (NAES) restricted data. These data are used in the analysis of self-reported newspaper reading (reported in Table 6(b)). [Visit the NAES home page to request access.](https://www.annenbergpublicpolicycenter.org/political-communication/naes/)

1. Comscore web traffic panel. These data are used in the analysis of visits to the Craigslist.org domain (Figure 4). Contact `zzz@comscore.com` for licensing inquiries.
