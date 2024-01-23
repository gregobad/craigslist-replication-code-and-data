set more off
clear all 


global base = "C:\Users\\`c(username)'\OneDrive\Desktop\craigslist-replication-code-and-data"

cd $base\data\ISPs\raw

*** read in the data for each year


save "$base\data\ISPs\isps", replace empty

local files : dir "$base\data\ISPs\raw" files "hzip*"  
	   foreach file in `files'{
	import excel using `file', clear
	
drop if _n<=2

rename A state
rename B zipcode
rename C num_ISPs
rename D year
rename E month

keep state zipcode num_ISPs year month

append using "$base\data\ISPs\isps"
        save "$base\data\ISPs\isps", replace
}

drop if num_ISPs==""
drop if year==""


***number of providers between 1 and 3 denoted with a * -- code as 2

replace num_ISPs="2" if num_ISPs=="*"

destring zipcode num_ISPs year, replace
 collapse (mean) num_ISPs, by(zipcode year)

rename zipcode zip


*** reshape wide by year

drop if year == .

reshape wide num_ISPs, i(zip) j(year)

save "$base\data\ISPs\isps", replace



**** merge in zip-code level population (as of 2000)

import delimited using "$base\data\_zipcode\zcta_county_rel_10.txt", clear delim(",")

  keep zcta5 geoid poppt 
rename zcta5 zip
rename geoid fips

merge m:1 zip using "$base\data\ISPs\isps"

drop if _merge==2
   drop _merge


   *** if not listed in FCC files, assume 0 ISPs
   
forval year= 1999 / 2008{
	
	replace num_ISPs`year' = 0 if num_ISPs`year' == .
    
	}

	
	
   **** collapse by county, using zip-code-level population as weights
   

collapse (mean) num_ISPs* [pw=poppt], by(fips)   
		
		
	reshape long num_ISPs , i(fips) j(year)
	
	
	save "$base\data\ISPs\isps", replace

	

	*** interpolation of pre-Internet years
	
	
	expand 5 if year==1999, gen(expand)

	keep if year==1999

	replace num_ISPs = . if expand==1
	
	sort fips expand year
	by fips: replace year = year[_n-1]-1 if _n>1

	replace num_ISPs = 0 if year<=1998
	
	****interpolate 1997 and 1998
	bys fips: ipolate num_ISPs year, gen(num_ISPs_ipo)
	
	drop if year==1999
	append using "$base\data\ISPs\isps"

	drop expand
	replace num_ISPs_ipo = num_ISPs if num_ISPs_ipo==.

	sort fips year
	
	keep fips year num_ISPs_ipo

save "$base\data\ISPs\isps", replace



