

set more off

clear all 


global base   = "C:\Users\mdjou\OneDrive\Desktop\craigslist-replication-code-and-data"



	

****Start with reading in controls

***2000 median age
clear
import delimited "$base\data\controls\age_2000_census", delim(";")
		drop if inlist(_n, 1, 2)	
		rename v3 county_state 
		rename v4 age_2000
		rename v2 geo_id
		replace age_2000 = subinstr(age_2000, ",", ".",.)
		destring geo_id age_2000, replace
		keep county_state age_2000 geo_id
		label var age_2000 "Age"
save "$base\data\master_data_county_level", replace


***2000 population
clear
import delimited "$base\data\controls\population_2000_census"
		drop if inlist(_n, 1, 2)	
		rename v3 county_state 
		rename v4 population_2000
		rename v2 geo_id
		destring geo_id population, replace
		keep county_state population_2000 geo_id
		label var population_2000 "Population"
merge 1:1 county_state using "$base\data\master_data_county_level"
keep if _merge ==3
drop _merge
save "$base\data\master_data_county_level", replace


***2000 pct rental
clear
import delimited "$base\data\controls\pct_rental_2000_census"
		drop if inlist(_n, 1, 2)
		rename v5 county_state
		destring v4 v8 v6, replace
		rename v4 geo_id
		gen pct_rental_2000 = (v8/v6)*100
		keep county_state pct_rental_2000 geo_id
		label var pct_rental_2000 "Pct. rental"

merge 1:1 county_state using "$base\data\master_data_county_level"
keep if _merge ==3
drop _merge
save "$base\data\master_data_county_level", replace


***2000 education
clear
import delimited "$base\data\controls\educ_2000_census"
		drop if inlist(_n, 1, 2)
		rename v5 county_state
		destring v19-v23 v36-v40 v6 v4, replace
		gen pct_college_2000 = ((v19+v20+v21+v22+v23 + v36+v37+v38+v39+v40)/v6)*100
		rename v4 geo_id
		keep county_state pct_college geo_id
		label var pct_college_2000 "Pct. college degree"
		
merge 1:1 county_state using "$base\data\master_data_county_level"
keep if _merge ==3		
drop _merge
save "$base\data\master_data_county_level", replace


*** 2000 income per capita
clear
import delimited "$base\data\controls\per_capita_income_2000_census"
		drop if inlist(_n, 1, 2)
		rename v5 county_state
		destring v4 v6, replace
		rename v6 income_2000
		rename v4 geo_id
		keep county_state income_2000 geo_id
		
		replace income_2000 = log(income_2000)
		
		label var income_2000 "Log income per capita"
		
merge 1:1 county_state using "$base\data\master_data_county_level"	
keep if _merge ==3	
drop _merge
save "$base\data\master_data_county_level", replace


*** 2000 percent urban
clear
import delimited "$base\data\controls\urban_rural_2000_census"
		drop if inlist(_n, 1, 2)
		rename v3 county_state
		destring v4 v5, replace
		gen share_urban_2000 = (v5 / v4)*100
		keep county_state share_urban
		label var share_urban_2000 "Share urban"
		
merge 1:1 county_state using "$base\data\master_data_county_level"	
keep if _merge ==3	
drop _merge
save "$base\data\master_data_county_level", replace



*** 2000 population density
clear
import delimited "$base\data\controls\density_2000_census"
		drop if length(v5)>=7
		rename v3 county_state
		destring v13, replace
		rename v13 pop_density_2000
		rename v12 land_area
		destring land_area, replace
		keep county_state pop_density_2000 land_area
		
		replace pop_density = log(pop_density)
		
		label var pop_density_2000 "Log pop. density"
		label var land_area "Area in square miles (land area)"
		
merge 1:1 county_state using "$base\data\master_data_county_level"	
keep if _merge ==3	
drop _merge
save "$base\data\master_data_county_level", replace



***drop Puerto Rico
drop if strpos(county_state, "Puerto Rico")!=0

drop if geo_id==.

save "$base\data\master_data_county_level", replace



***merge in the dates of CL expansion by county

rename geo_id fips

	merge 1:1 fips using "$base\data\craigslist_expansion\CL_entry"
	drop _merge
	
	rename fips geo_id
	
	drop if geo_id==.
	
	save "$base\data\master_data_county_level", replace
		
	
	
	***2000 unemployment
	clear 
	import excel using "$base\data\controls\unemployment_2000_bls.xlsx"

		drop if _n<7
		gen geo_id = B + C
		destring geo_id, replace
		rename J unemployment_2000 
	    destring geo_id unemployment_2000, replace
		keep geo_id unemployment_2000
		duplicates drop geo_id, force
		label var unemployment_2000 "Unemployment rate"	
		merge 1:1 geo_id using "$base\data\master_data_county_level"
		keep if _merge==3
		drop _merge
		
		
		order geo_id county_state income_2000 pct_college_2000 pct_rental_2000 population_2000 age_2000 unemployment_2000
		
		rename geo_id fips

		rename entry_ym entry_ym_ 
		
			local variants = " _  _broad"
			
		foreach v of local variants {
		
			 rename entry_ym`v'    CL_entry_ym`v'
		     gen CL_entry_year`v'  = year(dofm(CL_entry_ym`v'))
		  
									}				
					
								
		save "$base\data\master_data_county_level", replace
	
	

/**********************/
*** reshape into a panel: years 1995 - 2011
clear
use "$base\data\master_data_county_level"

	
	expand 17, gen(year)
	
	bys fips: replace year = 1995 + _n - 1
	
	
	local variants = " _  _broad"
			
		foreach v of local variants {
	
	    gen post_CL`v' = 0
	replace post_CL`v' = 1 if year >= CL_entry_year`v'
	
				}
			
	
	
	save "$base\data\master_data_county_level", replace
	
	
	
	*** merge in number of ISPs by county 
	
	merge 1:1 fips year using "$base\data\ISPs\isps", keepusing(num_ISPs_ipo)

	drop if _merge==2
	   drop _merge
	   
	rename num_ISPs_ipo num_ISPs
		
	*** extrapolate for remaining years			
		
	bys fips: ipolate num_ISPs year, epolate gen(num_ISPs_) 
		
	  drop num_ISPs
	rename num_ISPs_ num_ISPs

	save "$base\data\master_data_county_level", replace


	
	*** merge in time-varying population
	

	merge 1:1 fips year using "$base\data\controls\total_pop"

	drop if _merge==2
	   drop _merge
	   
	   
	   gen log_pop = log(pop_)
	   
	
	***********************************************************
		
	
	merge 1:1 fips year using "$base\data\controls\voting_age_pop"

	drop if _merge==2
	   drop _merge
	   
	
	merge 1:1 fips year using "$base\data\controls\white_pop"

	drop if _merge==2
	   drop _merge
	   
	   
	   gen share_white = (white_pop / pop_) * 100
	   
	   drop white_pop
	   
	
	merge 1:1 fips year using "$base\data\controls\black_pop"

	drop if _merge==2
	   drop _merge
	   
	   
	   gen share_black = (black_pop / pop_) * 100
	   
	   drop black_pop
	   
	   
	merge 1:1 fips year using "$base\data\controls\hisp_pop"

	drop if _merge==2
	   drop _merge
	   
	   
	   gen share_hisp = (hisp_pop / pop_) * 100   
	   
	   drop hisp_pop
	   
	  
	  foreach var in white black hisp {
			   gen share_`var'_2000_ = share_`var' if year==2000  
	bys fips: egen share_`var'_2000  = mean(share_`var'_2000_)
		      drop share_`var'_2000_
				}
	   
	save "$base\data\master_data_county_level", replace
	
	
	
	*** merge in turnout
	
	import delimited using "$base\data\political\electoral\county_vote_all.csv", clear
	
	keep if inlist(office, "pres")
	
	gen stfips_  = string(stfips)
	gen ctyfips_ = string(ctyfips)
	
	replace stfips_  = "0"  + stfips_  if length(stfips_) ==1
	replace ctyfips_ = "0"  + ctyfips_ if length(ctyfips_)==2
	replace ctyfips_ = "00" + ctyfips_ if length(ctyfips_)==1
	
	gen fips = stfips_ + ctyfips_
	
	destring fips, replace
					
	keep if year == 2000				
					
	keep fips turnout	
	
	destring turnout, replace force
	
	rename turnout pres_turnout_2000
	
	merge 1:m fips using "$base\data\master_data_county_level"
			
			drop if _merge == 1
			drop _merge
			
		

			label var log_pop     "Log population"
			label var share_white "Share white"
			label var share_black "Share black"
			label var share_hisp  "Share hispanic"
			

			
			label var num_ISPs "Number ISPs"
			
			
	order year fips  url* /*
		*/  CL_entry_year* CL_entry_ym* post_CL* /*
		*/  *_2000
		
		
	
	keep if year>=1995 & year <=2010

		
	save "$base\data\master_data_county_level", replace	


	

*************************************************************	

	 *** 2000 level of population and ISPs
	 
	 tempfile master
	    save `master', replace
		 
		 keep if year==2000

		 keep fips log_pop num_ISPs
		 
		 duplicates drop
		 
		 rename log_pop   log_pop_2000
		 rename num_ISPs num_ISPs_2000
		
	merge 1:m fips using `master'
	drop _merge
		

	 sort fips year
	 
	 order year fips  url*  CL_entry_year* CL_entry_ym* /*
		*/  post_CL*  *_2000
		
		
			*** drop counties with missing controls
			drop if pres_turnout_2000 == .
				
				
				
		
	*** merge in DMA-IDs
	
	merge m:1 fips using "$base\data\_counties_to_DMAs\fips_to_DMA_2000", keepusing(dma_2000)
	
	replace dma_2000 = "missing" if dma_2000 == "" 
	
	/*DMAs for Viginiria missing*/
	
	drop if _merge==2
	   drop _merge
			
	save "$base\data\master_data_county_level", replace	

	
	
	   
	*** merge in state IDs
	
	import delimited using "$base\data\county_fips_codes.csv", clear

	    gen fips = string(statefips) + string(countyfips) if length(string(statefips))==2 & length(string(countyfips))==3
	replace fips = string(statefips) + "0"  + string(countyfips) if length(string(statefips))==2 & length(string(countyfips))==2
	replace fips = string(statefips) + "00" + string(countyfips) if length(string(statefips))==2 & length(string(countyfips))==1	
	replace fips = "0" + string(statefips)  + string(countyfips) if length(string(statefips))==1 & length(string(countyfips))==3	
	replace fips = "0" + string(statefips)  + "0" + string(countyfips) if length(string(statefips))==1 & length(string(countyfips))==2
	replace fips = "0" + string(statefips)  + "00" + string(countyfips) if length(string(statefips))==1 & length(string(countyfips))==1
	
	
	destring fips, replace 
	keep fips stateabbr
	rename stateabbr state
	
	merge 1:m fips using "$base\data\master_data_county_level"
	
	replace state = "FL" if fips == 12086
	
	
	drop if _merge==1 
	   drop _merge
	
				
				
		
			**** label treatment variables and generate CL-area (for clustering)

				label var post_CL_		  	 "Post-CL"
				

				**** Standard errors: Cluster at the level of CL-assignment -- 
				**** URL(in the case of newspaper ever affected by CL entry), or single county if not 

					gen CL_area = string(fips)
				replace CL_area = url if url != ""
				 encode CL_area, gen(CL_area_)

			encode state, gen(state_)
			encode dma_2000, gen(DMA_code_)

				
				
	
	
	    gen years_CL_ = (year - CL_entry_year_) + 1 if CL_entry_year_!=.
	replace years_CL_ = 0 if post_CL_ == 0

	
	
	label var years_CL_ "Years post-CL"
	

	
	order state fips year url* CL_entry_* post_CL* years_CL*
				
				
	save "$base\data\master_data_county_level", replace	
