

global base = "C:\Users\mdjou\OneDrive\Desktop\craigslist-replication-code-and-data"

clear all


save $base/data/Comscore/visitcounts, empty replace


foreach n in "2002" "2004" "2006" "2007" "2008" "2009" "2010" {
	
	import delimited using $base/data/Comscore/raw/visitcounts_`n'.csv, clear	
	
	gen year = `n'
	
	destring year, replace
	
	rename zip_code zip
	
	append using $base/data/Comscore/visitcounts
	
			save $base/data/Comscore/visitcounts, replace
	
}


keep zip year craigslist monster ebay realtor /*
		*/ nytimes wsj usatoday top100 /*
		*/ all_count


*** collapse by county


****from ZIP codes, get longitude and latitude
						
						import delimited using $base/data/_zipcode\zipcode.csv, clear 
						
						merge 1:m zip using $base/data/Comscore/visitcounts
							
						 drop if _merge==1
							drop _merge
						
						drop if zip == .
						
						****now matching latitude and longitude to counties and taking the average

						rename   longitude _X
						rename   latitude  _Y

						geoinpoly _Y _X using "$base\data\_co99_d00_shp/coor.dta"
						merge m:1 _ID   using "$base\data\_co99_d00_shp/data.dta"

						drop if _merge==2
						   drop _merge

						gen fips = STATE + COUNTY
						destring fips, replace	

						
						
						rename NAME county 

					
						drop if fips == .
								


								
collapse (sum) *_count, by(fips year)


	save $base/data/Comscore/visitcounts, replace
