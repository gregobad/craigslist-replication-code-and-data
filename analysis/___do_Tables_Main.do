global base         = "C:\Users\mdjou\OneDrive\Desktop\craigslist-replication-code-and-data"
global base_results = "C:\Users\mdjou\OneDrive\Desktop\craigslist-replication-code-and-data\Results"

clear all
set more off



*** baseline county characteristics

global basevars    share_white_2000 /*
				*/ share_black_2000 /*
				*/ share_hisp_2000 /*
				*/ age_2000 /*
				*/ income_2000 /*
				*/ unemployment_2000 /*
				*/ pct_college_2000 /*
				*/ pct_rental_2000 /*
				*/ share_urban_2000 /*
				*/ pres_turnout_2000 




		
**** Correlates of CL entry year   
   


***Classified manager / jobs / circ by county in the year 2000 / in the year 1995


use "$base\data\master_data_newspaper_level", clear

keep if year == 1995


collapse (sum) classif_1995   = classif_1995 /*
			*/  jobscount_1995 = jobscount /*
			*/  circ_1995 = circ /*
			*/ (mean) log_pop_1995 = log_pop /*
			*/        num_ISPs_1995 = num_ISPs /*
			*/, by(fips)


tempfile vars_1995
   save `vars_1995', replace


   
   

**** years until CL entry + county characteristics in 2000

use "$base\data\master_data_newspaper_level", clear


gen years_untilCL = CL_entry_year_ - 1995  if CL_entry_year_!=.


keep if year == 2000			
	

collapse (sum)  classif_2000 /*
			 */ jobscount_2000 = jobscount /*
			 */ circ_2000 = circ /*
			 */ (mean) log_pop_2000 = log_pop /*
				   */  num_ISPs_2000 = num_ISPs /*
				   */  CL_entry_year_ years_untilCL /*
				   */  share_urban_2000 /*
				   */  pct_college_2000 /*
				   */  pct_rental_2000 /*
				   */  income_2000 /*
				   */  unemployment_2000 /*
				   */  age_2000 /*
				   */  share_white_2000 share_black_2000 share_hisp_2000 /*
				   */  pres_turnout_2000 /*
			   */ (first) CL_area /*
*/, by(fips state)


		
				

local countyvars  $basevars  /*
						*/  circ_2000 /*
						*/  jobscount_2000 /*
						*/  classif_2000 
						

keep fips state CL_area years_untilCL log_pop num_ISPs `countyvars'
					
			

duplicates drop 		

		
		merge 1:1 fips using `vars_1995'
		drop _merge
		
		
		gen change_log_pop   = (log_pop_2000   - log_pop_1995)
		gen change_num_ISPs  = (num_ISPs_2000  - num_ISPs_1995)
		gen change_jobscount = (jobscount_2000 - jobscount_1995)
		gen change_circ      = (circ_2000      - circ_1995)
		gen change_classif   = (classif_2000   - classif_1995)
		
		
	
		*** Multivariate regression table
		
		label var share_white_2000  "Share White"  
		label var share_black_2000  "Share Black"	
		label var share_hisp_2000   "Share Hispanic"	
		label var num_ISPs_2000     "Number ISPs" 	     
		label var log_pop_2000      "Log population"      
		label var income_2000	    "Income per capita" 	 
		label var pct_rental_2000   "Rental share"		
		label var share_urban_2000  "Share urban" 	
		label var pct_college_2000  "College degree"     
		label var unemployment_2000 "Unemployment rate"     
		label var pres_turnout_2000 "Turnout" 			
		label var age_2000          "Median age"
		label var num_ISPs_2000     "Internet service providers"
		
		
		label var circ_2000         "Newspaper circulation per capita"   
		label var jobscount_2000    "Newspaper jobs"		
		label var classif_2000      "Newspaper classified manager"
			
			
		label var change_circ      "$\Delta$ Newspaper circulation per capita"	
		label var change_jobscount "$\Delta$ Newspaper jobs"
		label var change_classif   "$\Delta$ Newspaper classified manager"
		label var change_log_pop   "$\Delta$ Log population"	
		label var change_num_ISPs  "$\Delta$ Internet service providers"	

		
		

		
		
		**** TABLE 1: Correlates of year of CL entry
		
		
		*** In levels
				
		est clear	
		
		eststo: reg years_untilCL  jobscount_2000 /*
			   */  log_pop_2000  num_ISPs_2000  /*
			   */ , cluster(CL_area)
		
		eststo: reg years_untilCL jobscount_2000 /*
			   */  log_pop_2000 num_ISPs_2000 /*
			   */  $basevars, cluster(CL_area)
			   
			   
		eststo: reg years_untilCL circ_2000 /*
			   */  log_pop_2000 num_ISPs_2000 /*
			   */ , cluster(CL_area)

			   
		eststo: reg years_untilCL circ_2000 /*
			   */  log_pop_2000 num_ISPs_2000 /*
			   */  $basevars, cluster(CL_area)
		
		
		eststo: reg years_untilCL classif_2000 /*
			   */  log_pop_2000 num_ISPs_2000 /*
			   */ , cluster(CL_area)

		eststo: reg years_untilCL classif_2000 /*
			   */  log_pop_2000 num_ISPs_2000 /*
			   */  $basevars, cluster(CL_area)
		

		
		esttab  using $base_results/Appendix_Tables/Table_A1.tex, r2 label replace se star(* 0.1 ** 0.05 *** 0.01) booktabs  nonotes b(3) se(3) ///		
				drop( _cons /*c1*/) ///
				nomtitle mgroups("\textit{Dependent variable:} Year of CL entry" , pattern(1 0 0 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) /// ///
				order(jobscount_2000 circ_2000 classif_2000 log_pop_2000 num_ISPs_2000) ///
				stats(N r2, label( "Observations" "R$^2$") fmt( 0 %9.2f ))

			   
		esttab  using $base_results/Tables/Table_1a.tex, r2 label replace se star(* 0.1 ** 0.05 *** 0.01) booktabs  nonotes b(3) se(3) ///		
				drop( _cons /*c1*/) ///
				nomtitle mgroups("\textit{Dependent variable:} Year of CL entry" , pattern(1 0 0 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) /// ///
				order(jobscount_2000 circ_2000 classif_2000 log_pop_2000 num_ISPs_2000) ///
				indicate("Other county characteristics = $basevars" ,  labels("Yes"  "No")) ///
				stats(N r2, label( "Observations" "R$^2$") fmt( 0 %9.2f ))
		est clear
		
		
		
		
		
		**** In changes
		
		
eststo: reg years_untilCL  change_jobscount /*
			   */  change_log_pop  change_num_ISPs , robust		
		
		eststo: reg years_untilCL  change_jobscount /*
			   */  change_log_pop  change_num_ISPs /*
			   */  $basevars, cluster(CL_area)
	
	
		eststo: reg years_untilCL  change_circ /*
			   */  change_log_pop  change_num_ISPs , cluster(CL_area)		
		
		eststo: reg years_untilCL  change_circ /*
			   */  change_log_pop  change_num_ISPs /*
			   */  $basevars, cluster(CL_area)
		
  
		eststo: reg years_untilCL  change_classif /*
			   */   change_log_pop  change_num_ISPs , cluster(CL_area)
			   
			   
		eststo: reg years_untilCL  change_classif /*
			   */   change_log_pop  change_num_ISPs /*
			   */  $basevars, cluster(CL_area)
		
							

		esttab  using $base_results/Tables/Table_1b.tex, r2 label replace se star(* 0.1 ** 0.05 *** 0.01) booktabs  nonotes b(3) se(3) ///		
				drop( _cons /*c1*/) ///
				nomtitle mgroups("\textit{Dependent variable:} Year of CL entry" , pattern(1 0 0 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) /// 
				indicate("Other county characteristics = $basevars" ,  labels("Yes"  "No")) /// 
				order( change_jobscount  change_circ change_classif change_log_pop change_num_ISPs) ///
				stats(N r2, label( "Observations" "R$^2$") fmt( 0 %9.2f ))

		
		
			
			
			
			
			

***** TABLE 2: EFFECT OF CL ENTRY ON CLASSIFIED AD QUANTITIES AND PRICES
	

	use $base/data/Newspapers.com/npcom_classified_pages_with_totals_corrected, clear
	
	
	rename np_name NPNAME1
	
 	
	collapse (mean) cl_pages_corrected total_pages [pw=total_pages], by(NPNAME1 wkday year)
	

	
	merge m:1 NPNAME1 year using $base/data/master_data_newspaper_level
	
	
	drop if largepaper > 0
	

	
	gen clpages = (cl_pages_corrected/ num_pages)
	
	
			
		eststo: reghdfe clpages  post_CL_      /*
				*/ log_pop num_ISPs /*
				*/  total_pages, absorb(year NPNAME1_ i.NPNAME1_#i.wkday i.year#c.($basevars) ) /*
				*/ cluster(CL_area)
						qui sum clpages  if e(sample)
						estadd scalar  m r(mean)
						qui distinct  NPNAME1 if e(sample)
						estadd scalar NPNAME1 r(ndistinct) 
							
			
			
		eststo: reghdfe clpages  post_CL_  post_CL_classif    /*
				*/ log_pop num_ISPs /*
				*/ total_pages  , absorb(year NPNAME1_ i.NPNAME1_#i.wkday  i.year#c.($basevars) ) /*
				*/ cluster(CL_area)
						qui sum clpages  if e(sample)
						estadd scalar  m r(mean)
						qui distinct  NPNAME1 if e(sample)
						estadd scalar NPNAME1 r(ndistinct) 
							

	
use $base/data/Classified_Prices/ClassRates_1994_2006, clear
		
		
		drop unit unit_final
		
		rename unit_original unit
		
	
	merge m:1 NPNAME1 year using $base/data/master_data_newspaper_level
	
	
	drop if largepaper > 0
	

	
	gen log_classif_rate = log(cl_daily)

	
	encode unit, gen(unit_)
	
			
		eststo: reghdfe log_classif_rate  post_CL_      /*
				*/ log_pop num_ISPs /*
				*/  , absorb(year NPNAME1_ i.NPNAME1_#i.unit_ i.year#c.($basevars) ) /*
				*/ cluster(CL_area)
						qui sum log_classif_rate  if e(sample)
						estadd scalar  m r(mean)
						qui distinct  NPNAME1 if e(sample)
						estadd scalar NPNAME1 r(ndistinct) 
							
			
			
		eststo: reghdfe log_classif_rate  post_CL_  post_CL_classif    /*
				*/ log_pop num_ISPs /*
				*/   , absorb(year NPNAME1_ i.NPNAME1_#i.unit_  i.year#c.($basevars) ) /*
				*/ cluster(CL_area)
						qui sum log_classif_rate  if e(sample)
						estadd scalar  m r(mean)
						qui distinct  NPNAME1 if e(sample)
						estadd scalar NPNAME1 r(ndistinct) 
							
				

estfe *, labels(year "Year FE"  NPNAME1_ "Newspaper FE")
	return list
	
	
	

estfe *, labels(year "Year FE"  NPNAME1_ "Newspaper FE")
	return list
				
esttab  using $base_results/Tables/Table_2.tex,  nomtitle r2 label replace se star(* 0.1 ** 0.05 *** 0.01) booktabs  nonotes b(3) se(3) ///		
		indicate("Baseline controls $\times$ Year FEs = 0.year#c.*"  "Log population, num. ISPs = log_pop num_ISPs" "Newspaper FEs, Year FEs = 0.NPNAME1_ 0.year" "Newspaper $\times$ Day-of-Week FEs = 0.NPNAME1_#0.wkday" "Newspaper $\times$ Unit FEs = 0.NPNAME1_#0.unit_",  labels("Yes"  "No")) ///
		mgroups("\shortstack{Share classified pages}" "\shortstack{Log classified rates}", pattern(1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
		drop(_cons total_pages) ///
		order(post_CL_) ///
		stats(N NPNAME1 r2 m, label( "Observations" "Number of newspapers" "R$^2$" "Mean dependent variable"  ) fmt(%13.0fc %13.0fc %9.2f %9.2f))
est clear
		
	
	
			
			
			

*******************************************************************************
		
use $base/data/master_data_newspaper_level, clear
   
drop if largepaper >0
	

	

*******************************************************************************

			
***** TABLE 3: Main newspaper outcomes		
	
eststo: reghdfe  jobscount  /*
		*/ post_CL_   /*
		*/ log_pop num_ISPs  /*
		*/ , absorb(year NPNAME1_ i.year#c.($basevars)) /*
		*/ cluster(CL_area)
				qui sum jobscount if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 		

eststo: reghdfe  jobscount /*
		*/ post_CL_  post_CL_classif /*
		*/ log_pop num_ISPs  /*
		*/ , absorb(year NPNAME1_ i.year#c.($basevars)) /*
		*/ cluster(CL_area)
				qui sum jobscount if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 		
									
eststo: reghdfe  circ  /*
		*/ post_CL_   /*
		*/ log_pop num_ISPs  /*
		*/ , absorb(year NPNAME1_ i.year#c.($basevars)) /*
		*/ cluster(CL_area)
				qui sum circ if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 		
						

eststo: reghdfe  circ  /*
		*/ post_CL_  post_CL_classif /*
		*/ log_pop num_ISPs  /*
		*/ , absorb(year NPNAME1_ i.year#c.($basevars)) /*
		*/ cluster(CL_area)
				qui sum circ if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 		
					
				
eststo: reghdfe  topic2  /*
		*/ post_CL_   /*
		*/ log_pop num_ISPs  /*
		*/ , absorb(year NPNAME1_ i.year#c.($basevars)) /*
		*/ cluster(CL_area)
				qui sum topic2 if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 			
	
eststo: reghdfe  topic2  /*
		*/ post_CL_  post_CL_classif /*
		*/ log_pop num_ISPs  /*
		*/ , absorb(year NPNAME1_ i.year#c.($basevars)) /*
		*/ cluster(CL_area)
				qui sum topic2 if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 		
	
		
eststo: reghdfe  ihs_congress_name_mentions /*
		*/ post_CL_   /*
		*/ log_pop num_ISPs  /*
		*/ ihs_total_articles /*
		*/ , absorb(year NPNAME1_ i.year#c.($basevars)) /*
		*/ cluster(CL_area)
				qui sum ihs_congress_name_mentions if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 			

	
eststo: reghdfe  ihs_congress_name_mentions  /*
		*/ post_CL_  post_CL_classif /*
		*/ log_pop num_ISPs  /*
		*/ ihs_total_articles /*
		*/ , absorb(year NPNAME1_ i.year#c.($basevars)) /*
		*/ cluster(CL_area)
				qui sum ihs_congress_name_mentions if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 		
		
			
estfe *, labels(year "Year FE"  NPNAME1_ "Newspaper FE")
	return list
				
esttab  using $base_results/Tables/Table_3.tex, nomtitle r2 label replace se star(* 0.1 ** 0.05 *** 0.01) booktabs  nonotes b(3) se(3) ///		
		mgroups("\shortstack{Number \\ of jobs}"  "\shortstack{Circulation \\ per capita}"  "\shortstack{Politics coverage \\ topic weight }" "\shortstack{Congress coverage \\ names count (ihs)}", pattern(1 0 1 0 1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
		drop( _cons ihs_total_articles) ///
		order(post_CL_ post_CL_classif) ///
		indicate("Baseline controls $\times$ Year FEs = 0.year#c.*"  "Log population, num. ISPs = log_pop num_ISPs" "Newspaper FEs, Year FEs = 0.NPNAME1_ 0.year" ,  labels("Yes"  "No")) ///
		stats(N NPNAME1_ r2 m, label( "Observations" "Number of newspapers" "R$^2$" "Mean dependent variable"  ) fmt(%13.0fc %13.0fc %9.2f %9.2f))
est clear









*******************************************************************************


**** TABLE 4: Newspapers' jobs by type	
				
				
**** Job categories				
			
est clear			
			
eststo: reghdfe jobscount_mgmt    post_CL_  post_CL_classif    /*
		*/ log_pop num_ISPs   /*
		*/ , absorb(year NPNAME1_ i.year#c.($basevars)) /*
		*/ cluster(CL_area)
				qui sum jobscount_mgmt if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 				
							

eststo: reghdfe jobscount_ad    post_CL_  post_CL_classif    /*
		*/ log_pop num_ISPs   /*
		*/ , absorb(year NPNAME1_ i.year#c.($basevars)) /*
		*/ cluster(CL_area)
				qui sum jobscount_ad if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 	
				
			
eststo: reghdfe jobscount_edit    post_CL_  post_CL_classif    /*
		*/ log_pop num_ISPs   /*
		*/ , absorb(year NPNAME1_ i.year#c.($basevars)) /*
		*/ cluster(CL_area)
				qui sum jobscount_edit if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 				
						

eststo: reghdfe jobscount_other    post_CL_  post_CL_classif    /*
		*/ log_pop num_ISPs   /*
		*/ , absorb(year NPNAME1_ i.year#c.($basevars)) /*
		*/ cluster(CL_area)
				qui sum jobscount_other if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 				
	
estfe *, labels(year "Year FE"  NPNAME1_ "Newspaper FE")
	return list
				
esttab  using $base_results/Tables/Table_4a.tex, r2 label replace se star(* 0.1 ** 0.05 *** 0.01) booktabs  nonotes b(3) se(3) ///		
		drop( _cons) ///
		indicate("Baseline controls $\times$ Year FEs = 0.year#c.*"  "Log population, num. ISPs = log_pop num_ISPs" "Newspaper FEs, Year FEs = 0.NPNAME1_ 0.year" ,  labels("Yes"  "No")) ///
		stats(N NPNAME1_ r2 m, label( "Observations" "Number of newspapers" "R$^2$" "Mean dependent variable"  ) fmt(%13.0fc %13.0fc %9.2f %9.2f))
est clear
				
	
	
	
	
**** Editor job titles	
	
est clear	
						
eststo: reghdfe politics_editors    post_CL_  post_CL_classif    /*
		*/ log_pop num_ISPs   /*
		*/ , absorb(year NPNAME1_ i.year#c.($basevars)) /*
		*/ cluster(CL_area)
				qui sum politics_editors if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 				
				
				
eststo: reghdfe sports_editors    post_CL_  post_CL_classif    /*
		*/ log_pop num_ISPs   /*
		*/ , absorb(year NPNAME1_ i.year#c.($basevars)) /*
		*/ cluster(CL_area)
				qui sum sports_editors if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 					
				
				
eststo: reghdfe ent_editors    post_CL_  post_CL_classif    /*
		*/ log_pop num_ISPs  /*
		*/ , absorb(year NPNAME1_ i.year#c.($basevars)) /*
		*/ cluster(CL_area)
				qui sum ent_editors if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 					
		
				
estfe *, labels(year "Year FE"  NPNAME1_ "Newspaper FE")
	return list
				
esttab  using $base_results/Tables/Table_4b.tex, r2 label replace se star(* 0.1 ** 0.05 *** 0.01) booktabs  nonotes b(3) se(3) ///		
		drop( _cons) ///
		indicate("Baseline controls $\times$ Year FEs = 0.year#c.*"  "Log population, num. ISPs = log_pop num_ISPs" "Newspaper FEs, Year FEs = 0.NPNAME1_ 0.year" ,  labels("Yes"  "No")) ///
		stats(N NPNAME1_ r2 m, label( "Observations" "Number of newspapers" "R$^2$" "Mean dependent variable"  ) fmt(%13.0fc %13.0fc %9.2f %9.2f))
est clear
			




*******************************************************************************

**** TABLE 5: Newspapers' coverage


*** Topic probability weight

est clear

foreach var in topic2 topic0 topic4 topic1 topic3 {

eststo: reghdfe  `var'  /*
		*/ post_CL_ post_CL_classif  /*
		*/ log_pop num_ISPs  /*
		*/ , absorb(year NPNAME1_ i.year#c.($basevars)) /*
		*/ cluster(CL_area)
				qui sum `var' if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 		

}
			
estfe *, labels(year "Year FE"  NPNAME1_ "Newspaper FE")
	return list
				
esttab  using $base_results/Tables/Table_5a.tex, r2 label replace se star(* 0.1 ** 0.05 *** 0.01) booktabs  nonotes b(3) se(3) ///		
		drop( _cons ) ///
		order(post_CL_ post_CL_classif) ///
		indicate("Baseline controls $\times$ Year FEs = 0.year#c.*"  "Log population, num. ISPs = log_pop num_ISPs" "Newspaper FEs, Year FEs = 0.NPNAME1_ 0.year" ,  labels("Yes"  "No")) ///
		stats(N NPNAME1_ r2 m, label( "Observations" "Number of newspapers" "R$^2$" "Mean dependent variable"  ) fmt(%13.0fc %13.0fc %9.2f %9.2f))
est clear




*** Coverage of congressional representatives and candidates: By time in the election-cycle
	
use $base/data/master_data_newspaper_level, clear


drop if largepaper > 0
		
		
		label var ihs_cong_general_mentions "\shortstack{General election}"
		label var ihs_cong_primary_mentions "\shortstack{Other times}"
		
		foreach var in ihs_cong_general_mentions ihs_cong_primary_mentions  {
			

eststo: reghdfe  `var'  /*
		*/ post_CL_  post_CL_classif /*
		*/ log_pop num_ISPs  /*
		*/ ihs_total_articles, absorb(year NPNAME1_ i.year#c.($basevars)) /*
		*/ cluster(CL_area)
				qui sum `var' if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 				

			}

				
estfe *, labels(year "Year FE"  NPNAME1_ "Newspaper FE")
	return list
				
esttab  using $base_results/Tables/Table_5b.tex, r2 label replace se star(* 0.1 ** 0.05 *** 0.01) booktabs  nonotes b(3) se(3) ///		
		order(post_CL_ post_CL_classif) ///
		indicate("Baseline controls $\times$ Year FEs = 0.year#c.*"  "Log population, num. ISPs = log_pop num_ISPs" "Newspaper FEs, Year FEs = 0.NPNAME1_ 0.year" ,  labels("Yes"  "No")) ///
		drop( _cons ihs_total_articles) ///
		mgroups("Split by timing" , pattern(1 0 ) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
		stats(N NPNAME1_ r2 m, label( "Observations" "Number of newspapers" "R$^2$" "Mean dependent variable"  ) fmt(%13.0fc %13.0fc %9.2f %9.2f))
est clear


/*
*** Equality of coefs

rename ihs_cong_general_mentions x

rename ihs_cong_primary_mentions y


*same results as seemingly unrelated regression
qui sureg (x post_CL_  post_CL_classif /*
		*/ log_pop num_ISPs  /*
		*/ ihs_total_articles i.year i.NPNAME1_ i.year#c.($basevars)) /*
		*/ (y post_CL_  post_CL_classif /*
		*/ log_pop num_ISPs  /*
		*/ ihs_total_articles i.year i.NPNAME1_ i.year#c.($basevars))

		
suregr, cluster(CL_area) minus(1) noheader		
		
		
*To use lincom it is the exact same code as with mvreg
lincom _b[x:post_CL_classif] - _b[y:post_CL_classif]


*/




/*

**** TABLE 6: Self-reported newspaper readership 
	

**** Merging in GfK-MRI survey

use "$base/data/master_data_newspaper_level", clear

	keep NPNAME1 fips classif_2000 circ_2000 largepaper

	duplicates drop
	
collapse (mean) classif_2000 largepaper [pw=circ_2000], by(fips)

drop if largepaper !=0


merge 1:m fips using "$base/data/master_data_county_level"

drop _merge



rename year int_year

merge 1:m fips int_year using "$base/data/GfK-MRI/gfk"

rename int_year year

keep if _merge==3
   drop _merge
   
   destring RespID, replace
     rename RespID respid

tempfile master
   save `master', replace 

   
import delimited using "$base/data/GfK-MRI/news_section_propensities", clear   
 
   
merge 1:1 respid using `master'   
   
   drop _merge

  
gen post_CL_classif    = post_CL_ * classif_2000

label var post_CL_		  	 "Post-CL"
label var post_CL_classif 	 "Post-CL $\times$ Classified Mgr."

		
				
	
	*** respondent controls
	
	
	    gen college = "0" if educ1=="NA"
	replace college = "1" if educ1!="NA"	
	replace college = "2" if inlist(educ1, "Post-graduate degree", "Bachelor's degree", "Associate degree")
	
		
	 replace agebin = subinstr(agebin, "Years", "",.)
	 replace agebin = subinstr(agebin, "+", "",.)
	   split agebin, p("-")
	destring agebin1, replace
	

	qui tab race, gen(__race)
	qui tab college, gen(__college)
	
	gen agebin_2 = agebin1^2
	
	
	
	global resp_controls __race* agebin1 agebin_2 __college*
	
	

	**** newspaper readership excluding top newspapers
	
	    gen read_np = read_np_any
	replace read_np = 0 if read_natl_paper ==1 & read_np!=.
	

	
	************************************
	
	**Heterogeneity by classif / news propensity
	
	egen median_clas = median(pred_classif_propensity)
	egen median_news = median(pred_news_propensity)
	
	rename pred_classif_propensity pred_clas_propensity
			
	
	gen read_np_HnewsLclas = read_np if (pred_news_propensity >= median_news & pred_news_propensity!=.) /*
										   */ & (pred_clas_propensity <  median_clas )
	
	gen read_np_LnewsHclas = read_np if (pred_clas_propensity >= median_clas & pred_clas_propensity!=.) /*
										   */ & (pred_news_propensity <  median_news )
		
	gen read_np_LnewsLclas = read_np if (pred_news_propensity < median_news ) /*
							       */ & (pred_clas_propensity <  median_clas )
	
	gen read_np_HnewsHclas = read_np if (pred_clas_propensity >= median_clas & pred_clas_propensity!=.) /*
								   */ & (pred_news_propensity >= median_news & pred_news_propensity!=.)
	

	label var read_np "\shortstack{Read newspaper \\ dummy: \\ Full sample}"
	
	
	label var read_np_HnewsLclas "\shortstack{News propensity $\geq$ median, \\ Classif. propensity < median}"
	label var read_np_LnewsHclas "\shortstack{News propensity < median, \\ Classif. propensity $\geq$ median}"

	label var read_np_HnewsHclas "\shortstack{News propensity $\geq$ median, \\ Classif. propensity $\geq$ median}"
	label var read_np_LnewsLclas "\shortstack{News propensity < median \\ Classif. propensity < median}"
	
	
	foreach depvar in read_np read_np_HnewsLclas read_np_LnewsHclas {
	
	
eststo: reghdfe `depvar'  post_CL_ post_CL_classif    /*
		*/ log_pop num_ISPs $resp_controls /*
		*/ , absorb(year  fips i.year#c.($basevars)) /*
		*/ cluster(CL_area)
				qui sum `depvar' if e(sample)
				estadd scalar  m r(mean)
				qui distinct  fips if e(sample)
				estadd scalar fips r(ndistinct) 
	}
				
				
estfe *, labels(year "Year FE"  fips "County FE")
	return list
				
esttab  using $base_results/Tables/Table_6a.tex, r2 label replace se star(* 0.1 ** 0.05 *** 0.01) booktabs  nonotes b(3) se(3) ///		
		drop( _cons) ///
		indicate("Respondent controls = $resp_controls" "Baseline controls $\times$ Year FEs = 0.year#c.*"  "Log population, num. ISPs  = log_pop num_ISPs" "County FEs, Year FEs = 0.fips 0.year",  labels("Yes"  "No")) ///
		stats(N fips r2 m, label( "Observations" "Number of counties" "R$^2$" "Mean dependent variable"  ) fmt( %13.0fc  %13.0fc %9.2f %9.2f))
est clear


		gen     dummy = 0 if read_np_HnewsLclas!=.
		replace dummy = 1 if read_np_LnewsHclas!=.
		
		
		eststo: reghdfe read_np  i.dummy#i.post_CL_ i.dummy#c.post_CL_classif    /*
		*/ i.dummy#c.log_pop i.dummy#c.num_ISPs i.dummy#(c.$resp_controls) /*
		*/ , absorb(i.dummy#i.year  i.dummy#i.fips i.dummy#(i.year#c.($basevars))) /*
		*/ cluster(CL_area)
		
		test post_CL_classif#0.dummy = post_CL_classif#1.dummy

		drop dummy
		
		
		


***************************************************************************

*** Merging in NAES survey

use "$base\data\master_data_newspaper_level", clear

	keep if year == 2000 

	keep NPNAME1 fips classif_2000 circ_2000 
	
	replace classif_2000 = 0 if classif_2000==. 

	
collapse (mean) classif_2000 largepaper [pw=circ_2000], by(fips)

	drop if largepaper!=0
	
merge 1:m fips using "$base\data\master_data_county_level"

keep if _merge ==3
   drop _merge


tempfile master
   save `master', replace
   

use "$base\data\annenberg\annenberg2000-2004-2008_select", clear


merge 1:1 ckey using "$base\data\annenberg\annenberg2000-2004-2008_preds"

keep if _merge==3
   drop _merge
   
   
 
merge m:1 fips year using `master'


	keep if year!=2008 /*only campaign-specific media consumption Qs in 2008*/ 
	
	
rename read_newspaper_national read_national

egen watched_TV = rowmax(watched_local watched_network watched_cable)
		
		
    gen read_newspaper_dummy = 0 if read_newspaper!=.
replace read_newspaper_dummy = 1 if read_newspaper > 0 & read_newspaper!=.
		

	egen median_clas = median(pred_cl) 
	egen median_news = median(pred_news) 
	
				
			
	gen read_np_HnewsLclas = read_newspaper_dummy if (pred_news >= median_news & pred_news!=.) /*
										   */ & (pred_cl <  median_clas )
	
	gen read_np_LnewsHclas = read_newspaper_dummy if (pred_cl >= median_clas & pred_cl!=.) /*
										   */ & (pred_news <  median_news )
	
	gen read_np_LnewsLclas = read_newspaper_dummy if (pred_news < median_news ) /*
							       */ & (pred_cl <  median_clas )
	
	gen read_np_HnewsHclas = read_newspaper_dummy if (pred_cl >= median_clas & pred_cl!=.) /*
								   */ & (pred_news >= median_news & pred_news!=.)

	
	label var read_np_HnewsLclas "\shortstack{News propensity $\geq$ median, \\ Classif. propensity < median}"
	label var read_np_LnewsHclas "\shortstack{News propensity < median, \\ Classif. propensity $\geq$ median}"

	label var read_np_HnewsHclas "\shortstack{News propensity $\geq$ median, \\ Classif. propensity $\geq$ median}"
	label var read_np_LnewsLclas "\shortstack{News propensity < median \\ Classif. propensity < median}"


	

**** respondent controls

gen resp_age2 = resp_age * resp_age				
		
global resp_controls resp_sex /*
				  */ resp_age  /*
				  */ resp_age2 /*
				  */ resp_college /*
				  */ resp_race*
		
*******************************************


	 
**** post-CL interacted with baseline county characteristics
	  
gen post_CL_classif    = post_CL_ * classif_2000


label var post_CL_		  	 "Post-CL"
label var post_CL_classif 	 "Post-CL $\times$ Classified Mgr."



est clear


foreach var in read_newspaper_dummy read_np_HnewsLclas read_np_LnewsHclas {
		
eststo: reghdfe `var' post_CL_  post_CL_classif    /*
		*/ log_pop num_ISPs   /*
		*/ $resp_controls, absorb(year  fips  i.year#c.($basevars) ) /*
		*/ cluster(CL_area)
				qui sum `var' if e(sample)
				estadd scalar  m r(mean)
				qui distinct  fips if e(sample)
				estadd scalar fips r(ndistinct) 
	
			}
				
estfe *, labels(year "Year FE"  NPNAME1_ "Newspaper FE")
	return list
				
esttab  using $base_results/Tables/Table_6b.tex, r2 label replace se star(* 0.1 ** 0.05 *** 0.01) booktabs  nonotes b(3) se(3) ///		
		drop( _cons) ///
		indicate("Respondent controls = $resp_controls" "Baseline controls $\times$ Year FEs = 0.year#c.*"  "Log population, num. ISPs  = log_pop num_ISPs" "County FEs, Year FEs = 0.fips 0.year",  labels("Yes"  "No")) ///
		stats(N fips r2 m, label( "Observations" "Number of counties" "R$^2$" "Mean dependent variable"  ) fmt( %13.0fc  %13.0fc %9.2f %9.2f))
est clear




		*** Testing equality of coefs
				
		gen     dummy = 0 if read_np_HnewsLclas!=.
		replace dummy = 1 if read_np_LnewsHclas!=.
		
		
				eststo: reghdfe read_newspaper_dummy  i.dummy#i.post_CL_ i.dummy#c.post_CL_classif    /*
		*/ i.dummy#c.log_pop i.dummy#c.num_ISPs i.dummy#(c.$resp_controls) /*
		*/ , absorb(i.dummy#i.year  i.dummy#i.fips i.dummy#(i.year#c.($basevars))) /*
		*/ cluster(CL_area)
		
		test post_CL_classif#0.dummy = post_CL_classif#1.dummy

		drop dummy
		
		
*/		
	





**** Merging in electoral turnout 


use "$base\data\master_data_newspaper_level", clear

	
	keep if year==2000
	
	keep NPNAME1 fips classif_2000 circ_2000
	
	replace classif_2000= 0 if classif_2000==. 
	
	
collapse (mean) classif_2000 [pw=circ], by(fips)
	
gen newspHQ_2000 = 1


merge 1:m fips using "$base\data\master_data_county_level"
drop _merge
	

keep if newspHQ_2000 ==1	
	

merge 1:1 fips year using $base\data\political\turnout_data_notmerged,  keepusing(house_dev sen_dev turnout_house turnout_sen)

drop _merge

		
  
gen post_CL_classif    = post_CL_  * classif_2000


label var post_CL_		  	 "Post-CL"
label var post_CL_classif 	 "Post-CL $\times$ Classified Mgr."




**** Pooling House and Senate elections
	
expand 2, gen(exp)
	
 
    gen split_vote = house_dev if exp==0
replace split_vote = sen_dev   if exp==1



	gen turnout_congress = turnout_house if exp==0
replace turnout_congress = turnout_sen   if exp==1


	

label var split_vote   "\shortstack{Split ticket \\ (House/Senate-President)}"
label var turnout_congress  "\shortstack{Turnout \\ House/Senate elections}"


*** TABLE 7: Political effects


*** Turnout in Congressional elections and split-ticket voting

eststo: reghdfe turnout_congress     post_CL_      /*
		*/ log_pop num_ISPs /*
		*/ [pw=voting_pop_], absorb(i.year##i.exp fips i.year#c.($basevars)) /*
		*/ cluster(CL_area)
				qui sum turnout_congress if e(sample)
				estadd scalar  m r(mean)
				qui distinct  fips if e(sample)
				estadd scalar fips r(ndistinct) 						

	
eststo: reghdfe turnout_congress     post_CL_  post_CL_classif    /*
		*/ log_pop num_ISPs /*
		*/ [pw=voting_pop_], absorb(i.year##i.exp fips i.year#c.($basevars)) /*
		*/ cluster(CL_area)
				qui sum turnout_congress if e(sample)
				estadd scalar  m r(mean)
				qui distinct  fips if e(sample)
				estadd scalar fips r(ndistinct) 											
		
		

eststo: reghdfe split_vote     post_CL_      /*
		*/ log_pop num_ISPs /*
		*/ [pw=voting_pop_], absorb(i.year##i.exp fips i.year#c.($basevars)) /*
		*/ cluster(CL_area)
				qui sum split_vote if e(sample)
				estadd scalar  m r(mean)
				qui distinct  fips if e(sample)
				estadd scalar fips r(ndistinct) 						

	
eststo: reghdfe split_vote     post_CL_  post_CL_classif    /*
		*/ log_pop num_ISPs /*
		*/ [pw=voting_pop_], absorb(i.year##i.exp  fips i.year#c.($basevars)) /*
		*/ cluster(CL_area)
				qui sum split_vote if e(sample)
				estadd scalar  m r(mean)
				qui distinct  fips if e(sample)
				estadd scalar fips r(ndistinct) 						

				
estfe *, labels(year "Year FE"  fips "County FE")
	return list
							
						
esttab  using $base_results/Tables/Table_7a.tex, nomtitle r2 label replace se star(* 0.1 ** 0.05 *** 0.01) booktabs  nonotes b(3) se(3) ///		
		drop( _cons) ///
		mgroups("\shortstack{Turnout \\ House/Senate}"  "\shortstack{Split-ticket \\ vote}", pattern(1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
		indicate("Baseline controls $\times$ Year FEs = 0.year#c.*" "Log population, num. ISPs = log_pop num_ISPs"  "County FEs, Year-Office FEs = 0.fips 0.year*" , labels("Yes"  "No")) ///
		stats(N fips r2 m, label( "Observations" "Number of counties" "R$^2$" "Mean dependent variable"  ) fmt( %13.0fc %13.0fc %9.2f %9.2f))
est clear						
					

					
					
		
	

					
					
					
** Merge in electoral results by candidate extremity


use "$base\data\master_data_newspaper_level", clear

	keep if year==2000
	
	keep NPNAME1 fips classif_2000 circ_2000

	replace classif_2000 = 0 if classif_2000==.

		
collapse (mean) classif_2000 = classif [pw=circ_2000], by(fips)

	
gen newspHQ_2000 = 1


merge 1:m fips using "$base\data\master_data_county_level"

drop _merge

tempfile np


keep if newspHQ_2000 == 1



save `np', replace

import delimited "$base\data\political\house_elections_cf_dist_cty.csv", clear

tempfile politics
save `politics', replace 



use `np' , clear

merge 1:m fips year using `politics', keepusing(extremist_in_general extremist_in_dempri extremist_in_reppri winner_group w_cty_dist district redist_regime winner_cfscore)
	
	
	keep if _merge == 3
	   drop _merge

	  


			  gen post_CL_classif = post_CL_ * classif_2000
		label var post_CL_classif "Post-CL $\times$ Classified Mgr."
		
	
				
			gen extremist_wins = 0 if winner_group!="nocfscore" & extremist_in_general!=.
		replace extremist_wins = 1 if winner_group=="extrem_left" | winner_group=="extrem_right"
		
	
		    gen extremist_in_eitherpri = 0 if extremist_in_dempri==0 & extremist_in_reppri ==0
		replace extremist_in_eitherpri = 1 if extremist_in_dempri==1 | extremist_in_reppri ==1
	

	   gen district_code_ = state + string(district) + string(redist_regime)
	encode district_code_, gen(district_code)

	
	gen state_dist = state + string(district)
	
	
	
		
	
	est clear
	
	foreach depvar in extremist_in_eitherpri extremist_in_general  extremist_wins  {
	

eststo: reghdfe `depvar'  /*
		*/ post_CL_    /*
		*/ log_pop num_ISPs  /*
		*/ [pw=w_cty_dist], absorb(year fips i.year#c.($basevars) district_code_) /*
		*/ cluster(state_dist)
				qui sum `depvar' if e(sample)
				estadd scalar  m r(mean)
				qui distinct  fips if e(sample)
				estadd scalar fips r(ndistinct) 
				qui distinct state_dist if e(sample)
				estadd scalar districts r(ndistinct) 
				
eststo: reghdfe `depvar'  /*
		*/ post_CL_  post_CL_classif  /*
		*/ log_pop num_ISPs  /*
		*/ [pw=w_cty_dist], absorb(year fips i.year#c.($basevars) district_code_) /*
		*/ cluster(state_dist)
				qui sum `depvar' if e(sample)
				estadd scalar  m r(mean)	
				qui distinct  fips if e(sample)
				estadd scalar fips r(ndistinct) 
				qui distinct state_dist if e(sample)
				estadd scalar districts r(ndistinct) 
}

				
estfe *, labels(year "Year FE"  fips "County FE")
	return list
							
						
esttab  using $base_results/Tables/Table_7b.tex, nomtitle r2 label replace se star(* 0.1 ** 0.05 *** 0.01) booktabs  nonotes b(3) se(3) ///		
		drop( _cons) ///
		mgroups("\shortstack{Extremist \\ in primary}"  "\shortstack{Extremist \\ in general}" "\shortstack{Extremist wins \\ general}", pattern(1 0 1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
		indicate("Baseline controls $\times$ Year FEs = 0.year#c.*" "Log population, num. ISPs = log_pop num_ISPs"  "County FEs, Year FEs = 0.fips 0.year" "District FEs = 0.district_code_", labels("Yes"  "No")) ///
		stats(N fips districts r2 m, label( "Observations" "Number of counties" "Number of districts" "R$^2$" "Mean dependent variable"  ) fmt( %13.0fc %13.0fc %13.0fc %9.2f %9.2f))
est clear						
					
					