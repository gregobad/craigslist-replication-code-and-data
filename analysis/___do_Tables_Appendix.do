global base         = "C:\Users\mdjou\OneDrive\Desktop\craigslist-replication-code-and-data"
global base_results = "C:\Users\mdjou\OneDrive\Desktop\craigslist-replication-code-and-data\Results"

clear all
set more off





use $base/data/master_data_newspaper_level, clear

   
   
drop if largepaper >0

		
		
		
	
**** baseline county-characteristics interacted with time FEs
	
global basevars share_white_2000 /*
			*/ share_black_2000 /*
			*/ share_hisp_2000 /*
			*/ age_2000 /*
			*/ income_2000 /*
			*/ unemployment_2000 /*
			*/ pct_college_2000 /*
			*/ pct_rental_2000 /*
			*/ share_urban_2000 /*
			*/ pres_turnout_2000 
	

*******************************************
	


tempfile master
   save `master', replace

   
   

*** TABLE A2: ALTERNATIVE CONTROLS
   

*** No controls
				
eststo: reghdfe  jobscount  /*
		*/ post_CL_   /*
		*/ , absorb(year NPNAME1_ ) /*
		*/ cluster(CL_area)
				qui sum jobscount if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 		

eststo: reghdfe  jobscount /*
		*/ post_CL_  post_CL_classif /*
		*/ , absorb(year NPNAME1_ ) /*
		*/ cluster(CL_area)
				qui sum jobscount if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 		
									
eststo: reghdfe  circ  /*
		*/ post_CL_   /*
		*/ , absorb(year NPNAME1_ ) /*
		*/ cluster(CL_area)
				qui sum circ if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 		
						

eststo: reghdfe  circ  /*
		*/ post_CL_  post_CL_classif /*
		*/ , absorb(year NPNAME1_ ) /*
		*/ cluster(CL_area)
				qui sum circ if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 		
					
				
eststo: reghdfe  topic2  /*
		*/ post_CL_   /*
		*/ , absorb(year NPNAME1_ ) /*
		*/ cluster(CL_area)
				qui sum topic2 if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 			
	
eststo: reghdfe  topic2  /*
		*/ post_CL_  post_CL_classif /*
		*/ , absorb(year NPNAME1_ ) /*
		*/ cluster(CL_area)
				qui sum topic2 if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 		
	
			
eststo: reghdfe  ihs_congress_name_mentions  /*
		*/ post_CL_   /*
		*/ ihs_total_articles /*
		*/ , absorb(year NPNAME1_ ) /*
		*/ cluster(CL_area)
				qui sum ihs_congress_name_mentions if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 			
	
	
eststo: reghdfe  ihs_congress_name_mentions  /*
		*/ post_CL_  post_CL_classif /*
		*/ ihs_total_articles /*
		*/ , absorb(year NPNAME1_ ) /*
		*/ cluster(CL_area)
				qui sum ihs_congress_name_mentions if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 		
		

			
estfe *, labels(year "Year FE"  NPNAME1_ "Newspaper FE")
	return list
				
esttab  using $base_results/Appendix_Tables/Table_A2_a.tex, nomtitle r2 label replace se star(* 0.1 ** 0.05 *** 0.01) booktabs  nonotes b(3) se(3) ///		
		mgroups("\shortstack{Number \\ of jobs}"  "\shortstack{Circulation \\ per capita}"  "\shortstack{Politics coverage \\ topic weight }" "\shortstack{Congress coverage \\ names count (ihs)}", pattern(1 0 1 0 1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
		drop( _cons ihs_total_articles) ///
		order(post_CL_ post_CL_classif) ///
		indicate("Baseline controls $\times$ Year FEs = " "Log population, num. ISPs = " "Newspaper FEs, Year FEs = 0.NPNAME1_ 0.year",  labels("Yes"  "No")) ///
		stats(N NPNAME1_ r2 m, label( "Observations" "Number of newspapers" "R$^2$" "Mean dependent variable"  ) fmt(%13.0fc %13.0fc %9.2f %9.2f))
est clear




*** No baseline controls
				
eststo: reghdfe  jobscount  /*
		*/ post_CL_   /*
		*/ log_pop num_ISPs  /*
		*/ , absorb(year NPNAME1_ ) /*
		*/ cluster(CL_area)
				qui sum jobscount if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 		

eststo: reghdfe  jobscount /*
		*/ post_CL_  post_CL_classif /*
		*/ log_pop num_ISPs  /*
		*/ , absorb(year NPNAME1_ ) /*
		*/ cluster(CL_area)
				qui sum jobscount if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 		
									
eststo: reghdfe  circ  /*
		*/ post_CL_   /*
		*/ log_pop num_ISPs  /*
		*/ , absorb(year NPNAME1_ ) /*
		*/ cluster(CL_area)
				qui sum circ if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 		
						

eststo: reghdfe  circ  /*
		*/ post_CL_  post_CL_classif /*
		*/ log_pop num_ISPs  /*
		*/ , absorb(year NPNAME1_ ) /*
		*/ cluster(CL_area)
				qui sum circ if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 		
					
				
eststo: reghdfe  topic2  /*
		*/ post_CL_   /*
		*/ log_pop num_ISPs  /*
		*/ , absorb(year NPNAME1_ ) /*
		*/ cluster(CL_area)
				qui sum topic2 if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 			
	
eststo: reghdfe  topic2  /*
		*/ post_CL_  post_CL_classif /*
		*/ log_pop num_ISPs  /*
		*/ , absorb(year NPNAME1_ ) /*
		*/ cluster(CL_area)
				qui sum topic2 if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 		
	
			
eststo: reghdfe  ihs_congress_name_mentions  /*
		*/ post_CL_   /*
		*/ log_pop num_ISPs  /*
		*/ ihs_total_articles /*
		*/ , absorb(year NPNAME1_ ) /*
		*/ cluster(CL_area)
				qui sum ihs_congress_name_mentions if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 			
	
	
eststo: reghdfe  ihs_congress_name_mentions  /*
		*/ post_CL_  post_CL_classif /*
		*/ log_pop num_ISPs  /*
		*/ ihs_total_articles /*
		*/ , absorb(year NPNAME1_ ) /*
		*/ cluster(CL_area)
				qui sum ihs_congress_name_mentions if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 		
		

			
estfe *, labels(year "Year FE"  NPNAME1_ "Newspaper FE")
	return list
				
esttab  using $base_results/Appendix_Tables/Table_A2_b.tex, nomtitle r2 label replace se star(* 0.1 ** 0.05 *** 0.01) booktabs  nonotes b(3) se(3) ///		
		mgroups("\shortstack{Number \\ of jobs}"  "\shortstack{Circulation \\ per capita}"  "\shortstack{Politics coverage \\ topic weight }" "\shortstack{Congress coverage \\ names count (ihs)}", pattern(1 0 1 0 1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
		drop( _cons ihs_total_articles ) ///
		order(post_CL_ post_CL_classif) ///
		indicate( "Baseline controls $\times$ Year FEs = " "Log population, num. ISPs = log_pop num_ISPs" "Newspaper FEs, Year FEs = 0.NPNAME1_ 0.year",  labels("Yes"  "No")) ///
		stats(N NPNAME1_ r2 m, label( "Observations" "Number of newspapers" "R$^2$" "Mean dependent variable"  ) fmt(%13.0fc %13.0fc %9.2f %9.2f))
est clear



/*
/*

**** Additional control for survey measure of Internet access

   
  
use "$base\data\annenberg\annenberg2000-2004-2008_select", clear   

		keep fips year internet_access

		tempfile inet_access
		   save `inet_access', replace


use "$base\data\GfK-MRI\gfk_full", clear   
   	
		rename gfk_inet_access internet_access
		rename int_year year

		append using `inet_access'

		gen n = 1 

		drop if fips==. | internet_access==.

collapse (mean) internet_access (sum) n, by(fips year)


merge 1:m fips year using `master'
	drop if _merge == 1
	drop _merge
		
	
eststo: reghdfe  jobscount  /*
		*/ post_CL_   /*
		*/ log_pop num_ISPs internet_access /*
		*/ , absorb(year NPNAME1_ i.year#c.($basevars)) /*
		*/ cluster(CL_area)
				qui sum jobscount if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 		

eststo: reghdfe  jobscount /*
		*/ post_CL_  post_CL_classif /*
		*/ log_pop num_ISPs internet_access /*
		*/ , absorb(year NPNAME1_ i.year#c.($basevars)) /*
		*/ cluster(CL_area)
				qui sum jobscount if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 		
									
eststo: reghdfe  circ  /*
		*/ post_CL_   /*
		*/ log_pop num_ISPs internet_access /*
		*/ , absorb(year NPNAME1_ i.year#c.($basevars)) /*
		*/ cluster(CL_area)
				qui sum circ if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 		
						

eststo: reghdfe  circ  /*
		*/ post_CL_  post_CL_classif /*
		*/ log_pop num_ISPs internet_access /*
		*/ , absorb(year NPNAME1_ i.year#c.($basevars)) /*
		*/ cluster(CL_area)
				qui sum circ if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 		
					
				
eststo: reghdfe  topic2  /*
		*/ post_CL_   /*
		*/ log_pop num_ISPs internet_access /*
		*/ , absorb(year NPNAME1_ i.year#c.($basevars)) /*
		*/ cluster(CL_area)
				qui sum topic2 if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 			
	
eststo: reghdfe  topic2  /*
		*/ post_CL_  post_CL_classif /*
		*/ log_pop num_ISPs internet_access /*
		*/ , absorb(year NPNAME1_ i.year#c.($basevars)) /*
		*/ cluster(CL_area)
				qui sum topic2 if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 		
	
			
eststo: reghdfe  ihs_congress_mentions  /*
		*/ post_CL_   /*
		*/ log_pop num_ISPs internet_access /*
		*/ ihs_total_articles /*
		*/ , absorb(year NPNAME1_ i.year#c.($basevars)) /*
		*/ cluster(CL_area)
				qui sum ihs_congress_mentions if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 			
	
	
eststo: reghdfe  ihs_congress_name_mentions  /*
		*/ post_CL_  post_CL_classif /*
		*/ log_pop num_ISPs internet_access /*
		*/ ihs_total_articles /*
		*/ , absorb(year NPNAME1_ i.year#c.($basevars)) /*
		*/ cluster(CL_area)
				qui sum ihs_congress_name_mentions if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 		
			
			
estfe *, labels(year "Year FE"  NPNAME1_ "Newspaper FE")
	return list
				
esttab  using $base_results/Appendix_Tables/Table_A2_c.tex, nomtitle r2 label replace se star(* 0.1 ** 0.05 *** 0.01) booktabs  nonotes b(3) se(3) ///		
		mgroups("\shortstack{Number \\ of jobs}"  "\shortstack{Circulation \\ per capita}"  "\shortstack{Politics coverage \\ topic weight }" "\shortstack{Congress coverage \\ names count (ihs)}", pattern(1 0 1 0 1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
		drop( _cons ihs_total_articles ) ///
		indicate("\shortstack{Share with self-reported \\ Internet access} = internet_access" "Baseline controls $\times$ Year FEs = 0.year#c.*"  "Log population, num. ISPs = log_pop num_ISPs" "Newspaper FEs, Year FEs = 0.NPNAME1_ 0.year",  labels("Yes"  "No")) ///
		order(post_CL_ post_CL_classif) ///
		stats(N NPNAME1_ r2 m, label( "Observations" "Number of newspapers" "R$^2$" "Mean dependent variable"  ) fmt(%13.0fc %13.0fc %9.2f %9.2f))
est clear			
			
*/
*/			


   
   


**** TABLE A3: LOCATION X YEAR FIXED EFFECTS

**** State X Year FEs
				
eststo: reghdfe  jobscount  /*
		*/ post_CL_   /*
		*/ log_pop num_ISPs  /*
		*/ , absorb(year NPNAME1_ i.year#c.($basevars)  i.year##i.state_) /*
		*/ cluster(CL_area)
				qui sum jobscount if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 		

eststo: reghdfe  jobscount /*
		*/ post_CL_  post_CL_classif /*
		*/ log_pop num_ISPs  /*
		*/ , absorb(year NPNAME1_ i.year#c.($basevars)  i.year##i.state_) /*
		*/ cluster(CL_area)
				qui sum jobscount if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 		
									
eststo: reghdfe  circ  /*
		*/ post_CL_   /*
		*/ log_pop num_ISPs  /*
		*/ , absorb(year NPNAME1_ i.year#c.($basevars)  i.year##i.state_) /*
		*/ cluster(CL_area)
				qui sum circ if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 		
						

eststo: reghdfe  circ  /*
		*/ post_CL_  post_CL_classif /*
		*/ log_pop num_ISPs  /*
		*/ , absorb(year NPNAME1_ i.year#c.($basevars)  i.year##i.state_) /*
		*/ cluster(CL_area)
				qui sum circ if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 		
					
				
eststo: reghdfe  topic2  /*
		*/ post_CL_   /*
		*/ log_pop num_ISPs  /*
		*/ , absorb(year NPNAME1_ i.year#c.($basevars)  i.year##i.state_) /*
		*/ cluster(CL_area)
				qui sum topic2 if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 			
	
eststo: reghdfe  topic2  /*
		*/ post_CL_  post_CL_classif /*
		*/ log_pop num_ISPs  /*
		*/ , absorb(year NPNAME1_ i.year#c.($basevars)  i.year##i.state_) /*
		*/ cluster(CL_area)
				qui sum topic2 if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 		
	
			
eststo: reghdfe  ihs_congress_name_mentions  /*
		*/ post_CL_   /*
		*/ log_pop num_ISPs  /*
		*/ ihs_total_articles /*
		*/ , absorb(year NPNAME1_ i.year#c.($basevars)  i.year##i.state_) /*
		*/ cluster(CL_area)
				qui sum ihs_congress_name_mentions if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 			
	
	
eststo: reghdfe  ihs_congress_name_mentions  /*
		*/ post_CL_  post_CL_classif /*
		*/ log_pop num_ISPs  /*
		*/ ihs_total_articles /*
		*/ , absorb(year NPNAME1_ i.year#c.($basevars) i.year##i.state_) /*
		*/ cluster(CL_area)
				qui sum ihs_congress_name_mentions if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 		
		

			
estfe *, labels(year "Year FE"  NPNAME1_ "Newspaper FE")
	return list
				
esttab  using $base_results/Appendix_Tables/Table_A3_a.tex, nomtitle r2 label replace se star(* 0.1 ** 0.05 *** 0.01) booktabs  nonotes b(3) se(3) ///		
		mgroups("\shortstack{Number \\ of jobs}"  "\shortstack{Circulation \\ per capita}"  "\shortstack{Politics coverage \\ topic weight }" "\shortstack{Congress coverage \\ names count (ihs)}", pattern(1 0 1 0 1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
		drop( _cons ihs_total_articles) ///
		indicate("State $\times$ Year FEs =0.year#0.state_" "Baseline controls $\times$ Year FEs = 0.year#c.*"  "Log population, num. ISPs = log_pop num_ISPs" "Newspaper FEs, Year FEs = 0.NPNAME1_ 0.year",  labels("Yes"  "No")) ///
		order(post_CL_ post_CL_classif) ///
		stats(N NPNAME1_ r2 m, label( "Observations" "Number of newspapers" "R$^2$" "Mean dependent variable"  ) fmt(%13.0fc %13.0fc %9.2f %9.2f))
est clear





**** DMA X Year FEs
				
eststo: reghdfe  jobscount  /*
		*/ post_CL_   /*
		*/ log_pop num_ISPs  /*
		*/ , absorb(year NPNAME1_ i.year#c.($basevars)  i.year##i.DMA_code_) /*
		*/ cluster(CL_area)
				qui sum jobscount if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 		

eststo: reghdfe  jobscount /*
		*/ post_CL_  post_CL_classif /*
		*/ log_pop num_ISPs  /*
		*/ , absorb(year NPNAME1_ i.year#c.($basevars)  i.year##i.DMA_code_) /*
		*/ cluster(CL_area)
				qui sum jobscount if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 		
									
eststo: reghdfe  circ  /*
		*/ post_CL_   /*
		*/ log_pop num_ISPs  /*
		*/ , absorb(year NPNAME1_ i.year#c.($basevars)  i.year##i.DMA_code_) /*
		*/ cluster(CL_area)
				qui sum circ if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 		
						

eststo: reghdfe  circ  /*
		*/ post_CL_  post_CL_classif /*
		*/ log_pop num_ISPs  /*
		*/ , absorb(year NPNAME1_ i.year#c.($basevars)  i.year##i.DMA_code_) /*
		*/ cluster(CL_area)
				qui sum circ if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 		
					
				
eststo: reghdfe  topic2  /*
		*/ post_CL_   /*
		*/ log_pop num_ISPs  /*
		*/ , absorb(year NPNAME1_ i.year#c.($basevars)  i.year##i.DMA_code_) /*
		*/ cluster(CL_area)
				qui sum topic2 if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 			
	
eststo: reghdfe  topic2  /*
		*/ post_CL_  post_CL_classif /*
		*/ log_pop num_ISPs  /*
		*/ , absorb(year NPNAME1_ i.year#c.($basevars)  i.year##i.DMA_code_) /*
		*/ cluster(CL_area)
				qui sum topic2 if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 		
	
			
eststo: reghdfe  ihs_congress_name_mentions  /*
		*/ post_CL_   /*
		*/ log_pop num_ISPs  /*
		*/ ihs_total_articles /*
		*/ , absorb(year NPNAME1_ i.year#c.($basevars)  i.year##i.DMA_code_) /*
		*/ cluster(CL_area)
				qui sum ihs_congress_name_mentions if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 			
	
	
eststo: reghdfe  ihs_congress_name_mentions  /*
		*/ post_CL_  post_CL_classif /*
		*/ log_pop num_ISPs  /*
		*/ ihs_total_articles /*
		*/ , absorb(year NPNAME1_ i.year#c.($basevars) i.year##i.DMA_code_) /*
		*/ cluster(CL_area)
				qui sum ihs_congress_name_mentions if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 		
		

			
estfe *, labels(year "Year FE"  NPNAME1_ "Newspaper FE")
	return list
				
esttab  using $base_results/Appendix_Tables/Table_A3_b.tex, nomtitle r2 label replace se star(* 0.1 ** 0.05 *** 0.01) booktabs  nonotes b(3) se(3) ///		
		mgroups("\shortstack{Number \\ of jobs}"  "\shortstack{Circulation \\ per capita}"  "\shortstack{Politics coverage \\ topic weight }" "\shortstack{Congress coverage \\ names count (ihs)}", pattern(1 0 1 0 1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
		drop( _cons ihs_total_articles ) ///
		indicate("DMA $\times$ Year FEs =0.year#0.DMA_code_" "Baseline controls $\times$ Year FEs = 0.year#c.*"  "Log population, num. ISPs = log_pop num_ISPs" "Newspaper FEs, Year FEs = 0.NPNAME1_ 0.year",  labels("Yes"  "No")) ///
		order(post_CL_ post_CL_classif) ///
		stats(N NPNAME1_ r2 m, label( "Observations" "Number of newspapers" "R$^2$" "Mean dependent variable"  ) fmt(%13.0fc %13.0fc %9.2f %9.2f))
est clear




**** County X Year FEs
				
eststo: reghdfe  jobscount /*
		*/  post_CL_classif /*
		*/ , absorb(year NPNAME1_  i.year##i.fips) /*
		*/ cluster(CL_area)
				qui sum jobscount if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 													

eststo: reghdfe  circ  /*
		*/  post_CL_classif /*
		*/ , absorb(year NPNAME1_  i.year##i.fips) /*
		*/ cluster(CL_area)
				qui sum circ if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 		
								
	
eststo: reghdfe  topic2  /*
		*/  post_CL_classif /*
		*/ , absorb(year NPNAME1_  i.year##i.fips) /*
		*/ cluster(CL_area)
				qui sum topic2 if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 		
	

eststo: reghdfe  ihs_congress_name_mentions  /*
		*/  post_CL_classif /*
		*/ ihs_total_articles /*
		*/ , absorb(year NPNAME1_  i.year##i.fips) /*
		*/ cluster(CL_area)
				qui sum ihs_congress_name_mentions if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 		
		

			
estfe *, labels(year "Year FE"  NPNAME1_ "Newspaper FE")
	return list
				
esttab  using $base_results/Appendix_Tables/Table_A3_c.tex, nomtitle r2 label replace se star(* 0.1 ** 0.05 *** 0.01) booktabs  nonotes b(3) se(3) ///		
		mgroups("\shortstack{Number \\ of jobs}"  "\shortstack{Circulation \\ per capita}"  "\shortstack{Politics coverage \\ topic weight }" "\shortstack{Congress coverage \\ names count (ihs)}", pattern(1 1 1 1) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
		drop( _cons ihs_total_articles) ///
		order( post_CL_classif) ///
		indicate( "County $\times$ Year FEs = 0.year#0.fips" "Newspaper FEs, Year FEs = 0.NPNAME1_ 0.year",  labels("Yes"  "No")) ///
		stats(N NPNAME1_ r2 m, label( "Observations" "Number of newspapers" "R$^2$" "Mean dependent variable"  ) fmt(%13.0fc %13.0fc %9.2f %9.2f))
est clear







*** TABLE A4: DYNAMIC EFFECTS OF CL ENTRY


**** Years since CL entry
				
eststo: reghdfe  jobscount  /*
		*/ years_CL_   /*
		*/ log_pop num_ISPs  /*
		*/ , absorb(year NPNAME1_ i.year#c.($basevars)) /*
		*/ cluster(CL_area)
				qui sum jobscount if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 		

eststo: reghdfe  jobscount /*
		*/ years_CL_  years_CL_classif /*
		*/ log_pop num_ISPs  /*
		*/ , absorb(year NPNAME1_ i.year#c.($basevars)) /*
		*/ cluster(CL_area)
				qui sum jobscount if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 		
									
eststo: reghdfe  circ  /*
		*/ years_CL_   /*
		*/ log_pop num_ISPs  /*
		*/ , absorb(year NPNAME1_ i.year#c.($basevars)) /*
		*/ cluster(CL_area)
				qui sum circ if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 		
						

eststo: reghdfe  circ  /*
		*/ years_CL_  years_CL_classif /*
		*/ log_pop num_ISPs  /*
		*/ , absorb(year NPNAME1_ i.year#c.($basevars)) /*
		*/ cluster(CL_area)
				qui sum circ if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 		
					
				
eststo: reghdfe  topic2  /*
		*/ years_CL_   /*
		*/ log_pop num_ISPs  /*
		*/ , absorb(year NPNAME1_ i.year#c.($basevars)) /*
		*/ cluster(CL_area)
				qui sum topic2 if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 			
	
eststo: reghdfe  topic2  /*
		*/ years_CL_  years_CL_classif /*
		*/ log_pop num_ISPs  /*
		*/ , absorb(year NPNAME1_ i.year#c.($basevars)) /*
		*/ cluster(CL_area)
				qui sum topic2 if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 		
	
			
eststo: reghdfe  ihs_congress_name_mentions  /*
		*/ years_CL_   /*
		*/ log_pop num_ISPs  /*
		*/ ihs_total_articles /*
		*/ , absorb(year NPNAME1_ i.year#c.($basevars)) /*
		*/ cluster(CL_area)
				qui sum ihs_congress_name_mentions if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 			
	
	
eststo: reghdfe  ihs_congress_name_mentions  /*
		*/ years_CL_  years_CL_classif /*
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
				
esttab  using $base_results/Appendix_Tables/Table_A4_a.tex, nomtitle r2 label replace se star(* 0.1 ** 0.05 *** 0.01) booktabs  nonotes b(3) se(3) ///		
		mgroups("\shortstack{Number \\ of jobs}"  "\shortstack{Circulation \\ per capita}"  "\shortstack{Politics coverage \\ topic weight }" "\shortstack{Congress coverage \\ names count (ihs)}", pattern(1 0 1 0 1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
		drop( _cons ihs_total_articles ) ///
		order(years_CL_ years_CL_classif) ///
		indicate("Baseline controls $\times$ Year FEs = 0.year#c.*"  "Log population, num. ISPs = log_pop num_ISPs" "Newspaper FEs, Year FEs = 0.NPNAME1_ 0.year",  labels("Yes"  "No")) ///
		stats(N NPNAME1_ r2 m, label( "Observations" "Number of newspapers" "R$^2$" "Mean dependent variable"  ) fmt(%13.0fc %13.0fc %9.2f %9.2f))
est clear






*** Short vs long-term effects

gen post_CL_shortterm =  0 if post_CL_!=. 
gen post_CL_longterm   = 0 if post_CL_!=.

replace post_CL_shortterm = 1 if (year  - CL_entry_year_ )>=0 & (year - CL_entry_year_ )<=2 & CL_entry_year_!=.
replace post_CL_longterm  = 1 if (year  - CL_entry_year_ )>2 & CL_entry_year_!=.


gen post_CL_shortterm_classif = post_CL_shortterm * classif_2000
gen post_CL_longterm_classif = post_CL_longterm   * classif_2000


label var post_CL_shortterm "Post-CL short-term}"
label var post_CL_longterm  "Post-CL long-term}"

label var post_CL_shortterm_classif "\shortstack{Post-CL short-term $\times$ Classified Mgr.}"
label var post_CL_longterm_classif  "\shortstack{Post-CL long-term $\times$ Classified Mgr.}"


est clear
				
eststo: reghdfe  jobscount  /*
		*/ post_CL_shortterm post_CL_longterm   /*
		*/ log_pop num_ISPs  /*
		*/ , absorb(year NPNAME1_ i.year#c.($basevars)) /*
		*/ cluster(CL_area)
				qui sum jobscount if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 		

eststo: reghdfe  jobscount /*
		*/ post_CL_shortterm post_CL_shortterm_classif /*
		*/ post_CL_longterm  post_CL_longterm_classif /*
		*/ log_pop num_ISPs  /*
		*/ , absorb(year NPNAME1_ i.year#c.($basevars)) /*
		*/ cluster(CL_area)
				qui sum jobscount if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 		
									
eststo: reghdfe  circ  /*
		*/ post_CL_shortterm  /*
		*/ post_CL_longterm   /*
		*/ log_pop num_ISPs  /*
		*/ , absorb(year NPNAME1_ i.year#c.($basevars)) /*
		*/ cluster(CL_area)
				qui sum circ if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 		
						

eststo: reghdfe  circ  /*
		*/ post_CL_shortterm post_CL_shortterm_classif /*
		*/ post_CL_longterm  post_CL_longterm_classif /*
		*/ log_pop num_ISPs  /*
		*/ , absorb(year NPNAME1_ i.year#c.($basevars)) /*
		*/ cluster(CL_area)
				qui sum circ if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 		
					
				
eststo: reghdfe  topic2  /*
		*/ post_CL_shortterm  /*
		*/ post_CL_longterm   /*
		*/ log_pop num_ISPs  /*
		*/ , absorb(year NPNAME1_ i.year#c.($basevars)) /*
		*/ cluster(CL_area)
				qui sum topic2 if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 			
	
eststo: reghdfe  topic2  /*
		*/ post_CL_shortterm post_CL_shortterm_classif /*
		*/ post_CL_longterm  post_CL_longterm_classif /*
		*/ log_pop num_ISPs  /*
		*/ , absorb(year NPNAME1_ i.year#c.($basevars)) /*
		*/ cluster(CL_area)
				qui sum topic2 if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 		
	
			
eststo: reghdfe  ihs_congress_name_mentions  /*
		*/ post_CL_shortterm  /*
		*/ post_CL_longterm   /*
		*/ log_pop num_ISPs  /*
		*/ ihs_total_articles /*
		*/ , absorb(year NPNAME1_ i.year#c.($basevars)) /*
		*/ cluster(CL_area)
				qui sum ihs_congress_name_mentions if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 			
	
	
eststo: reghdfe  ihs_congress_name_mentions  /*
		*/ post_CL_shortterm post_CL_shortterm_classif /*
		*/ post_CL_longterm  post_CL_longterm_classif /*
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
				
esttab  using $base_results/Appendix_Tables/Table_A4_b.tex, nomtitle r2 label replace se star(* 0.1 ** 0.05 *** 0.01) booktabs  nonotes b(3) se(3) ///		
		mgroups("\shortstack{Number \\ of jobs}"  "\shortstack{Circulation \\ per capita}"  "\shortstack{Politics coverage \\ topic weight }" "\shortstack{Congress coverage \\ names count (ihs)}", pattern(1 0 1 0 1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
		drop( _cons ihs_total_articles) ///
		indicate("Baseline controls $\times$ Year FEs = 0.year#c.*"  "Log population, num. ISPs = log_pop num_ISPs" "Newspaper FEs, Year FEs = 0.NPNAME1_ 0.year",  labels("Yes"  "No")) ///
		stats(N NPNAME1_ r2 m, label( "Observations" "Number of newspapers" "R$^2$" "Mean dependent variable"  ) fmt(%13.0fc %13.0fc %9.2f %9.2f))
est clear






*** TABLE A5: SAMPLE RESTRICTIONS BY NEWSPAPER SIZE



				
***	Excluding top 100 largest newspapers	


tempfile master

save `master', replace


		keep if year ==2000 

		keep NPNAME1 circ_2000 jobscount_2000

		gsort -circ_2000

		gen top_100 = 1 if _n<=100
	
		xtile circ_qtile = circ_2000, nq(4)

		merge 1:m NPNAME1 using `master'

		drop _merge



		
			
eststo: reghdfe  jobscount  /*
		*/ post_CL_   /*
		*/ log_pop num_ISPs  /*
		*/ if top_100!=1 & circ_2000!=., absorb(year NPNAME1_ i.year#c.($basevars)) /*
		*/ cluster(CL_area)
				qui sum jobscount if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 		

eststo: reghdfe  jobscount /*
		*/ post_CL_  post_CL_classif /*
		*/ log_pop num_ISPs  /*
		*/ if top_100!=1 & circ_2000!=., absorb(year NPNAME1_ i.year#c.($basevars)) /*
		*/ cluster(CL_area)
				qui sum jobscount if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 		
									
eststo: reghdfe  circ  /*
		*/ post_CL_   /*
		*/ log_pop num_ISPs  /*
		*/ if top_100!=1 & circ_2000!=., absorb(year NPNAME1_ i.year#c.($basevars)) /*
		*/ cluster(CL_area)
				qui sum circ if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 		
						

eststo: reghdfe  circ  /*
		*/ post_CL_  post_CL_classif /*
		*/ log_pop num_ISPs  /*
		*/ if top_100!=1 & circ_2000!=., absorb(year NPNAME1_ i.year#c.($basevars)) /*
		*/ cluster(CL_area)
				qui sum circ if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 		
					
				
eststo: reghdfe  topic2  /*
		*/ post_CL_   /*
		*/ log_pop num_ISPs  /*
		*/ if top_100!=1 & circ_2000!=., absorb(year NPNAME1_ i.year#c.($basevars)) /*
		*/ cluster(CL_area)
				qui sum topic2 if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 			
	
eststo: reghdfe  topic2  /*
		*/ post_CL_  post_CL_classif /*
		*/ log_pop num_ISPs  /*
		*/ if top_100!=1 & circ_2000!=., absorb(year NPNAME1_ i.year#c.($basevars)) /*
		*/ cluster(CL_area)
				qui sum topic2 if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 		
	
			
eststo: reghdfe  ihs_congress_name_mentions  /*
		*/ post_CL_   /*
		*/ log_pop num_ISPs  /*
		*/ ihs_total_articles /*
		*/ if top_100!=1 & circ_2000!=., absorb(year NPNAME1_ i.year#c.($basevars)) /*
		*/ cluster(CL_area)
				qui sum ihs_congress_name_mentions if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 			
	
	
eststo: reghdfe  ihs_congress_name_mentions  /*
		*/ post_CL_  post_CL_classif /*
		*/ log_pop num_ISPs  /*
		*/ ihs_total_articles /*
		*/ if top_100!=1 & circ_2000!=., absorb(year NPNAME1_ i.year#c.($basevars)) /*
		*/ cluster(CL_area)
				qui sum ihs_congress_name_mentions if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 		
		
			
			
estfe *, labels(year "Year FE"  NPNAME1_ "Newspaper FE")
	return list
				
esttab  using $base_results/Appendix_Tables/Table_A5_a.tex, nomtitle r2 label replace se star(* 0.1 ** 0.05 *** 0.01) booktabs  nonotes b(3) se(3) ///		
		mgroups("\shortstack{Number \\ of jobs}"  "\shortstack{Circulation \\ per capita}"  "\shortstack{Politics coverage \\ topic weight }" "\shortstack{Congress coverage \\ names count (ihs)}", pattern(1 0 1 0 1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
		drop( _cons ihs_total_articles ) ///
		indicate("Baseline controls $\times$ Year FEs = 0.year#c.*"  "Log population, num. ISPs = log_pop num_ISPs" "Newspaper FEs, Year FEs = 0.NPNAME1_ 0.year",  labels("Yes"  "No")) ///
		order(post_CL_ post_CL_classif) ///
		stats(N NPNAME1_ r2 m, label( "Observations" "Number of newspapers" "R$^2$" "Mean dependent variable"  ) fmt(%13.0fc %13.0fc %9.2f %9.2f))
est clear




*** Excluding top 25% and bottom 25% of newspapers			
		
est clear

eststo: reghdfe  jobscount  /*
		*/ post_CL_   /*
		*/ log_pop num_ISPs  /*
		*/ if inlist(circ_qtile,2,3) & circ_2000!=., absorb(year NPNAME1_ i.year#c.($basevars)) /*
		*/ cluster(CL_area)
				qui sum jobscount if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 		

eststo: reghdfe  jobscount /*
		*/ post_CL_  post_CL_classif /*
		*/ log_pop num_ISPs  /*
		*/ if inlist(circ_qtile,2,3) & circ_2000!=., absorb(year NPNAME1_ i.year#c.($basevars)) /*
		*/ cluster(CL_area)
				qui sum jobscount if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 		
									
eststo: reghdfe  circ  /*
		*/ post_CL_   /*
		*/ log_pop num_ISPs  /*
		*/ if inlist(circ_qtile,2,3) & circ_2000!=., absorb(year NPNAME1_ i.year#c.($basevars)) /*
		*/ cluster(CL_area)
				qui sum circ if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 		
						

eststo: reghdfe  circ  /*
		*/ post_CL_  post_CL_classif /*
		*/ log_pop num_ISPs  /*
		*/ if inlist(circ_qtile,2,3) & circ_2000!=., absorb(year NPNAME1_ i.year#c.($basevars)) /*
		*/ cluster(CL_area)
				qui sum circ if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 		
					
				
eststo: reghdfe  topic2  /*
		*/ post_CL_   /*
		*/ log_pop num_ISPs  /*
		*/ if inlist(circ_qtile,2,3) & circ_2000!=., absorb(year NPNAME1_ i.year#c.($basevars)) /*
		*/ cluster(CL_area)
				qui sum topic2 if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 			
	
eststo: reghdfe  topic2  /*
		*/ post_CL_  post_CL_classif /*
		*/ log_pop num_ISPs  /*
		*/ if inlist(circ_qtile,2,3) & circ_2000!=., absorb(year NPNAME1_ i.year#c.($basevars)) /*
		*/ cluster(CL_area)
				qui sum topic2 if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 		
	
			
eststo: reghdfe  ihs_congress_name_mentions  /*
		*/ post_CL_   /*
		*/ log_pop num_ISPs  /*
		*/ ihs_total_articles /*
		*/ if inlist(circ_qtile,2,3) & circ_2000!=., absorb(year NPNAME1_ i.year#c.($basevars)) /*
		*/ cluster(CL_area)
				qui sum ihs_congress_name_mentions if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 			
	
	
eststo: reghdfe  ihs_congress_name_mentions  /*
		*/ post_CL_  post_CL_classif /*
		*/ log_pop num_ISPs  /*
		*/ ihs_total_articles /*
		*/ if inlist(circ_qtile,2,3) & circ_2000!=., absorb(year NPNAME1_ i.year#c.($basevars)) /*
		*/ cluster(CL_area)
				qui sum ihs_congress_name_mentions if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 		
		
	
estfe *, labels(year "Year FE"  NPNAME1_ "Newspaper FE")
	return list
				
esttab  using $base_results/Appendix_Tables/Table_A5_b.tex, nomtitle r2 label replace se star(* 0.1 ** 0.05 *** 0.01) booktabs  nonotes b(3) se(3) ///		
		mgroups("\shortstack{Number \\ of jobs}"  "\shortstack{Circulation \\ per capita}"  "\shortstack{Politics coverage \\ topic weight }" "\shortstack{Congress coverage \\ names count (ihs)}", pattern(1 0 1 0 1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
		drop( _cons ihs_total_articles ) ///
		indicate("Baseline controls $\times$ Year FEs = 0.year#c.*"  "Log population, num. ISPs = log_pop num_ISPs" "Newspaper FEs, Year FEs = 0.NPNAME1_ 0.year ",  labels("Yes"  "No")) ///
		order(post_CL_ post_CL_classif) ///
		stats(N NPNAME1_ r2 m, label( "Observations" "Number of newspapers" "R$^2$" "Mean dependent variable"  ) fmt(%13.0fc %13.0fc %9.2f %9.2f))
est clear







*** TABLE A6: CONTROLLING FOR HETEROGENEITY BY NEWSPAPER SIZE



*** Controlling for heterogeneity by newspaper size


*** de-meaned size measures

egen mean_circ_2000 = mean(circ_2000)
egen mean_jobs_2000 = mean(jobscount_2000)

gen post_CL_circ      = post_CL_ * (circ_2000 - mean_circ_2000)
gen post_CL_jobscount = post_CL_ * (jobscount_2000 - mean_jobs_2000)



est clear 

eststo: reghdfe  jobscount /*
		*/ post_CL_  post_CL_classif post_CL_circ /*
		*/ log_pop num_ISPs  /*
		*/ , absorb(year NPNAME1_ i.year#c.($basevars)) /*
		*/ cluster(CL_area)
				qui sum jobscount if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 		
	

eststo: reghdfe  circ  /*
		*/ post_CL_  post_CL_classif post_CL_jobscount /*
		*/ log_pop num_ISPs  /*
		*/ , absorb(year NPNAME1_ i.year#c.($basevars)) /*
		*/ cluster(CL_area)
				qui sum circ if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 			
	
				
eststo: reghdfe  topic2  /*
		*/ post_CL_  post_CL_classif post_CL_circ  /*
		*/ log_pop num_ISPs  /*
		*/ , absorb(year NPNAME1_ i.year#c.($basevars)) /*
		*/ cluster(CL_area)
				qui sum topic2 if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 		
						
				
	
eststo: reghdfe  topic2  /*
		*/ post_CL_  post_CL_classif post_CL_jobscount  /*
		*/ log_pop num_ISPs  /*
		*/ , absorb(year NPNAME1_ i.year#c.($basevars)) /*
		*/ cluster(CL_area)
				qui sum topic2 if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 		
										
				
				
eststo: reghdfe  ihs_congress_name_mentions  /*
		*/ post_CL_  post_CL_classif post_CL_circ  /*
		*/ log_pop num_ISPs  /*
		*/ ihs_total_articles /*
		*/ , absorb(year NPNAME1_ i.year#c.($basevars)) /*
		*/ cluster(CL_area)
				qui sum ihs_congress_name_mentions if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 		
		
		

eststo: reghdfe  ihs_congress_name_mentions  /*
		*/ post_CL_  post_CL_classif post_CL_jobscount  /*
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
				
esttab  using $base_results/Appendix_Tables/Table_A6.tex, nomtitles r2 label replace se star(* 0.1 ** 0.05 *** 0.01) booktabs  nonotes b(3) se(3) ///		
		mgroups("\shortstack{Number \\ of jobs}"  "\shortstack{Circulation \\ per capita}"  "\shortstack{Politics coverage \\ topic weight }" "\shortstack{Congress coverage \\ names count (ihs)}", pattern(1 1 1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
		order(post_CL_ post_CL_classif post_CL_circ post_CL_jobscount) ///
		drop( _cons ihs_total_articles ) ///
		indicate("Post-CL $\times$ Baseline circulation = post_CL_circ" "Post-CL $\times$ Baseline job-count = post_CL_jobscount"  "Baseline controls $\times$ Year FEs = 0.year#c.*"  "Log population, num. ISPs = log_pop num_ISPs" "Newspaper FEs, year FEs = 0.year 0.NPNAME1_ ",  labels("Yes"  "No")) ///
		stats(N NPNAME1_ r2 m, label( "Observations" "Number of newspapers" "R$^2$" "Mean dependent variable"  ) fmt(%13.0fc %13.0fc %9.2f %9.2f))
est clear







*** TABLE A7: CLASSIFIED RELIANCE BASED ON THE SHARE OF CLASSIFIED PAGES


	use $base/data/Newspapers.com/npcom_classified_pages_with_totals_corrected, clear
	

	rename np_name NPNAME1
	
	keep if year<=2000
	
	
	
	collapse (mean) cl_pages_corrected , by(NPNAME1)
	


	merge 1:m NPNAME1 using $base/data/master_data_newspaper_level
	

	
	drop if largepaper > 0
	

	drop if _merge==1
	   drop _merge
	
	
	tempfile master
	save `master', replace
		
		keep if year==2000
		
		keep NPNAME1 num_pages
		
		rename num_pages num_pages_2000
		
	merge 1:m NPNAME1 using `master'
	drop _merge
	
	
	gen clpages =  (cl_pages_corrected/ num_pages_2000)
		
	
	recode clpages (0/0.3=0)(0.3/2=1)  /*below / above median (~0.3)*/

	
	gen post_CL_clpages = post_CL_ * clpages
	
	
	label var post_CL_clpages "Post-CL $\times$ [Share classif. pages$\geq$ median]"
	
	
	
	
eststo: reghdfe  jobscount /*
		*/ post_CL_  post_CL_clpages /*
		*/ log_pop num_ISPs  /*
		*/ , absorb(year NPNAME1_ i.year#c.($basevars)) /*
		*/ cluster(CL_area)
				qui sum jobscount if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 		
				

eststo: reghdfe  circ  /*
		*/ post_CL_  post_CL_clpages /*
		*/ log_pop num_ISPs  /*
		*/ , absorb(year NPNAME1_ i.year#c.($basevars)) /*
		*/ cluster(CL_area)
				qui sum circ if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 		
					
				
eststo: reghdfe  topic2  /*
		*/ post_CL_  post_CL_clpages /*
		*/ log_pop num_ISPs  /*
		*/ , absorb(year NPNAME1_ i.year#c.($basevars)) /*
		*/ cluster(CL_area)
				qui sum topic2 if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 		
	
			
eststo: reghdfe  ihs_congress_name_mentions  /*
		*/ post_CL_  post_CL_clpages /*
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
				
esttab  using $base_results/Appendix_Tables/Table_A7.tex, nomtitle r2 label replace se star(* 0.1 ** 0.05 *** 0.01) booktabs  nonotes b(3) se(3) ///		
		mgroups("\shortstack{Number \\ of jobs}"  "\shortstack{Circulation \\ per capita}"  "\shortstack{Politics coverage \\ topic weight }" "\shortstack{Congress coverage \\ names count (ihs)}", pattern(1 1 1 1) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
		drop( _cons ihs_total_articles ) ///
		indicate("Baseline controls $\times$ Year FEs = 0.year#c.*"  "Log population, num. ISPs = log_pop num_ISPs" "Newspaper FEs, Year FEs = 0.NPNAME1_ 0.year"  ,  labels("Yes"  "No")) ///
		order(post_CL_ post_CL_clpages) ///
		stats(N NPNAME1_ r2 m, label( "Observations" "Number of newspapers" "R$^2$" "Mean dependent variable"  ) fmt(%13.0fc %13.0fc %9.2f %9.2f))
est clear










*** TABLE A8: ALTERNATIVE SAMPLES AND TREATMENT DEFINITIONS



*** Balanced panel

		
		 cap drop n
		 
		 gen n=1 
		 
		 bys NPNAME1: egen m = total(n)
				 

			
eststo: reghdfe  jobscount  /*
		*/ post_CL_   /*
		*/ log_pop num_ISPs  /*
		*/ if m==16, /*
		*/ absorb(year NPNAME1_ i.year#c.($basevars)) /*
		*/ cluster(CL_area)
				qui sum jobscount if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 		

eststo: reghdfe  jobscount /*
		*/ post_CL_  post_CL_classif /*
		*/ log_pop num_ISPs  /*
		*/ if m==16 /*
		*/ , absorb(year NPNAME1_ i.year#c.($basevars)) /*
		*/ cluster(CL_area)
				qui sum jobscount if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 		
									
eststo: reghdfe  circ  /*
		*/ post_CL_   /*
		*/ log_pop num_ISPs  /*
		*/ if m==16 /*
		*/ , absorb(year NPNAME1_ i.year#c.($basevars)) /*
		*/ cluster(CL_area)
				qui sum circ if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 		
						

eststo: reghdfe  circ  /*
		*/ post_CL_  post_CL_classif /*
		*/ log_pop num_ISPs  /*
		*/ if m==16 /*
		*/ , absorb(year NPNAME1_ i.year#c.($basevars)) /*
		*/ cluster(CL_area)
				qui sum circ if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 		
					
				
eststo: reghdfe  topic2  /*
		*/ post_CL_   /*
		*/ log_pop num_ISPs  /*
		*/ if m==16 /*
		*/ , absorb(year NPNAME1_ i.year#c.($basevars)) /*
		*/ cluster(CL_area)
				qui sum topic2 if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 			
	
eststo: reghdfe  topic2  /*
		*/ post_CL_  post_CL_classif /*
		*/ log_pop num_ISPs  /*
		*/ if m==16 /*
		*/ , absorb(year NPNAME1_ i.year#c.($basevars)) /*
		*/ cluster(CL_area)
				qui sum topic2 if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 		
	
			
eststo: reghdfe  ihs_congress_name_mentions  /*
		*/ post_CL_   /*
		*/ log_pop num_ISPs  /*
		*/ ihs_total_articles /*
		*/ if m==16 /*
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
		*/ if m==16 /*
		*/ , absorb(year NPNAME1_ i.year#c.($basevars)) /*
		*/ cluster(CL_area)
				qui sum ihs_congress_name_mentions if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 		
							
			
			
estfe *, labels(year "Year FE"  NPNAME1_ "Newspaper FE")
	return list
				
esttab  using $base_results/Appendix_Tables/Table_A8_a.tex, nomtitle r2 label replace se star(* 0.1 ** 0.05 *** 0.01) booktabs  nonotes b(3) se(3) ///		
		mgroups("\shortstack{Number \\ of jobs}"  "\shortstack{Circulation \\ per capita}"  "\shortstack{Politics coverage \\ topic weight }" "\shortstack{Congress coverage \\ names count (ihs)}", pattern(1 0 1 0 1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
		drop( _cons ihs_total_articles ) ///
		indicate("Baseline controls $\times$ Year FEs = 0.year#c.*"  "Log population, num. ISPs = log_pop num_ISPs" "Newspaper FEs, Year FEs = 0.NPNAME1_ 0.year",  labels("Yes"  "No")) ///
		order(post_CL_ post_CL_classif) ///
		stats(N NPNAME1_ r2 m, label( "Observations" "Number of newspapers" "R$^2$" "Mean dependent variable"  ) fmt(%13.0fc %13.0fc %9.2f %9.2f))
est clear
 
	


**** Excluding newspapers that do not experience CL entry

    gen never_CL = 0 if CL_entry_year_!=.
replace never_CL = 1 if CL_entry_year_==.



			
eststo: reghdfe  jobscount  /*
		*/ post_CL_   /*
		*/ log_pop num_ISPs  /*
		*/ if never_CL!=1 /*
		*/ , absorb(year NPNAME1_ i.year#c.($basevars)) /*
		*/ cluster(CL_area)
				qui sum jobscount if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 		

eststo: reghdfe  jobscount /*
		*/ post_CL_  post_CL_classif /*
		*/ log_pop num_ISPs  /*
		*/ if never_CL!=1 /*
		*/ , absorb(year NPNAME1_ i.year#c.($basevars)) /*
		*/ cluster(CL_area)
				qui sum jobscount if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 		
									
eststo: reghdfe  circ  /*
		*/ post_CL_   /*
		*/ log_pop num_ISPs  /*
		*/ if never_CL!=1 /*
		*/ , absorb(year NPNAME1_ i.year#c.($basevars)) /*
		*/ cluster(CL_area)
				qui sum circ if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 		
						

eststo: reghdfe  circ  /*
		*/ post_CL_  post_CL_classif /*
		*/ log_pop num_ISPs  /*
		*/ if never_CL!=1 /*
		*/ , absorb(year NPNAME1_ i.year#c.($basevars)) /*
		*/ cluster(CL_area)
				qui sum circ if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 		
					
				
eststo: reghdfe  topic2  /*
		*/ post_CL_   /*
		*/ log_pop num_ISPs  /*
		*/ if never_CL!=1 /*
		*/ , absorb(year NPNAME1_ i.year#c.($basevars)) /*
		*/ cluster(CL_area)
				qui sum topic2 if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 			
	
eststo: reghdfe  topic2  /*
		*/ post_CL_  post_CL_classif /*
		*/ log_pop num_ISPs  /*
		*/ if never_CL!=1 /*
		*/ , absorb(year NPNAME1_ i.year#c.($basevars)) /*
		*/ cluster(CL_area)
				qui sum topic2 if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 		
	
			
eststo: reghdfe  ihs_congress_name_mentions  /*
		*/ post_CL_   /*
		*/ log_pop num_ISPs  /*
		*/ ihs_total_articles /*
		*/ if never_CL!=1 /*
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
		*/ if never_CL!=1 /*
		*/ , absorb(year NPNAME1_ i.year#c.($basevars)) /*
		*/ cluster(CL_area)
				qui sum ihs_congress_name_mentions if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 		
		
							
			
estfe *, labels(year "Year FE"  NPNAME1_ "Newspaper FE")
	return list
				
esttab  using $base_results/Appendix_Tables/Table_A8_b.tex, nomtitle r2 label replace se star(* 0.1 ** 0.05 *** 0.01) booktabs  nonotes b(3) se(3) ///		
		mgroups("\shortstack{Number \\ of jobs}"  "\shortstack{Circulation \\ per capita}"  "\shortstack{Politics coverage \\ topic weight }" "\shortstack{Congress coverage \\ names count (ihs)}", pattern(1 0 1 0 1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
		drop( _cons ihs_total_articles ) ///
		indicate("Baseline controls $\times$ Year FEs = 0.year#c.*"  "Log population, num. ISPs = log_pop num_ISPs" "Newspaper FEs, Year FEs =0.NPNAME1_ 0.year ",  labels("Yes"  "No")) ///
		order(post_CL_ post_CL_classif) ///
		stats(N NPNAME1_ r2 m, label( "Observations" "Number of newspapers" "R$^2$" "Mean dependent variable"  ) fmt(%13.0fc %13.0fc %9.2f %9.2f))
est clear




**** Broad definition of CL and newspaper markets


label var post_CL_broad "Post-CL (broad)"

gen post_CL_broad_classif  = post_CL_broad * classif_2000 

label var post_CL_broad_classif "Post-CL(broad) $\times$ Classified Mgr."



eststo: reghdfe  jobscount /*
		*/ post_CL_broad  /*
		*/ log_pop num_ISPs  /*
		*/ , absorb(year NPNAME1_ i.year#c.($basevars)) /*
		*/ cluster(CL_area)
				qui sum jobscount if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 		
				

eststo: reghdfe  jobscount /*
		*/ post_CL_broad  post_CL_broad_classif  /*
		*/ log_pop num_ISPs  /*
		*/ , absorb(year NPNAME1_ i.year#c.($basevars)) /*
		*/ cluster(CL_area)
				qui sum jobscount if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 		
				
				
eststo: reghdfe  circ  /*
		*/ post_CL_broad  /*
		*/ log_pop num_ISPs  /*
		*/ , absorb(year NPNAME1_ i.year#c.($basevars)) /*
		*/ cluster(CL_area)
				qui sum circ if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 		
		
		

eststo: reghdfe  circ  /*
		*/ post_CL_broad post_CL_broad_classif /*
		*/ log_pop num_ISPs  /*
		*/ , absorb(year NPNAME1_ i.year#c.($basevars)) /*
		*/ cluster(CL_area)
				qui sum circ if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 				
		
		
eststo: reghdfe  topic2  /*
		*/ post_CL_broad /*
		*/ log_pop num_ISPs  /*
		*/ , absorb(year NPNAME1_ i.year#c.($basevars)) /*
		*/ cluster(CL_area)
				qui sum topic2 if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 						
					
					

eststo: reghdfe  topic2  /*
		*/ post_CL_broad post_CL_broad_classif /*
		*/ log_pop num_ISPs  /*
		*/ , absorb(year NPNAME1_ i.year#c.($basevars)) /*
		*/ cluster(CL_area)
				qui sum topic2 if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 						
					
eststo: reghdfe  ihs_congress_name_mentions  /*
		*/ post_CL_broad /*
		*/ log_pop num_ISPs  /*
		*/ ihs_total_articles /*
		*/ , absorb(year NPNAME1_ i.year#c.($basevars)) /*
		*/ cluster(CL_area)
				qui sum ihs_congress_name_mentions if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 	
			
	
eststo: reghdfe  ihs_congress_name_mentions  /*
		*/ post_CL_broad post_CL_broad_classif /*
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
				
esttab  using $base_results/Appendix_Tables/Table_A8_c.tex, nomtitles r2 label replace se star(* 0.1 ** 0.05 *** 0.01) booktabs  nonotes b(3) se(3) ///	
		mgroups("\shortstack{Number \\ of jobs}"  "\shortstack{Circulation \\ per capita}"  "\shortstack{Politics coverage \\ topic weight }" "\shortstack{Congress coverage \\ names count (ihs)}", pattern(1 0 1 0 1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///	
		drop( _cons ihs_total_articles ) ///
		indicate( "Baseline controls $\times$ Year FEs = 0.year#c.*"  "Log population, num. ISPs = log_pop num_ISPs" "Newspaper FEs, year FEs = 0.year 0.NPNAME1_ ",  labels("Yes"  "No")) ///
		stats(N NPNAME1_ r2 m, label( "Observations" "Number of newspapers" "R$^2$" "Mean dependent variable"  ) fmt( 0 0 %9.2f %9.2f))
est clear









*** TABLE A9: ALTERNATIVE CLUSTERING OF STANDARD ERRORS

**** Standard errors clustered by state


eststo: reghdfe  jobscount  /*
		*/ post_CL_   /*
		*/ log_pop  num_ISPs /*
		*/ , absorb(year NPNAME1_ i.year#c.($basevars)) /*
		*/ cluster(state)
				qui sum jobscount if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 		

eststo: reghdfe  jobscount /*
		*/ post_CL_  post_CL_classif /*
		*/ log_pop  num_ISPs   /*
		*/ , absorb(year NPNAME1_ i.year#c.($basevars)) /*
		*/ cluster(state)
				qui sum jobscount if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 		
									
eststo: reghdfe  circ  /*
		*/ post_CL_   /*
		*/ log_pop  num_ISPs  /*
		*/ , absorb(year NPNAME1_ i.year#c.($basevars)) /*
		*/ cluster(state)
				qui sum circ if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 		
						

eststo: reghdfe  circ  /*
		*/ post_CL_  post_CL_classif /*
		*/ log_pop  num_ISPs   /*
		*/ , absorb(year NPNAME1_ i.year#c.($basevars)) /*
		*/ cluster(state)
				qui sum circ if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 		
					
				
eststo: reghdfe  topic2  /*
		*/ post_CL_   /*
		*/ log_pop  num_ISPs    /*
		*/ , absorb(year NPNAME1_ i.year#c.($basevars)) /*
		*/ cluster(state)
				qui sum topic2 if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 			
	
eststo: reghdfe  topic2  /*
		*/ post_CL_  post_CL_classif /*
		*/ log_pop  num_ISPs  /*
		*/ , absorb(year NPNAME1_ i.year#c.($basevars)) /*
		*/ cluster(state)
				qui sum topic2 if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 		
	
			
eststo: reghdfe  ihs_congress_name_mentions  /*
		*/ post_CL_   /*
		*/ log_pop  num_ISPs  /*
		*/ ihs_total_articles /*
		*/ , absorb(year NPNAME1_ i.year#c.($basevars)) /*
		*/ cluster(state)
				qui sum ihs_congress_name_mentions if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 			
	
	
eststo: reghdfe  ihs_congress_name_mentions  /*
		*/ post_CL_  post_CL_classif /*
		*/ log_pop num_ISPs    /*
		*/ ihs_total_articles /*
		*/ , absorb(year NPNAME1_ i.year#c.($basevars)) /*
		*/ cluster(state)
				qui sum ihs_congress_name_mentions if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 		
			
			
estfe *, labels(year "Year FE"  NPNAME1_ "Newspaper FE")
	return list
				
esttab  using $base_results/Appendix_Tables/Table_A9_a.tex, nomtitle r2 label replace se star(* 0.1 ** 0.05 *** 0.01) booktabs  nonotes b(3) se(3) ///		
		mgroups("\shortstack{Number \\ of jobs}"  "\shortstack{Circulation \\ per capita}"  "\shortstack{Politics coverage \\ topic weight }" "\shortstack{Congress coverage \\ names count (ihs)}", pattern(1 0 1 0 1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
		drop( _cons ihs_total_articles) ///
		indicate("Baseline controls $\times$ Year FEs = 0.year#c.*"  "Log population, num. ISPs = log_pop num_ISPs" "Newspaper FEs, Year FEs = 0.NPNAME1_ 0.year ",  labels("Yes"  "No")) ///
		order(post_CL_ post_CL_classif) ///
		stats(N NPNAME1_ r2 m, label( "Observations" "Number of newspapers" "R$^2$" "Mean dependent variable"  ) fmt(%13.0fc %13.0fc %9.2f %9.2f))
est clear		


		
	
	
**** Standard errors clustred by group

est clear

eststo: reghdfe  jobscount  /*
		*/ post_CL_   /*
		*/ log_pop  num_ISPs /*
		*/ , absorb(year NPNAME1_ i.year#c.($basevars)) /*
		*/ cluster(group)
				qui sum jobscount if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 		

eststo: reghdfe  jobscount /*
		*/ post_CL_  post_CL_classif /*
		*/ log_pop  num_ISPs   /*
		*/ , absorb(year NPNAME1_ i.year#c.($basevars)) /*
		*/ cluster(group)
				qui sum jobscount if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 		
									
eststo: reghdfe  circ  /*
		*/ post_CL_   /*
		*/ log_pop  num_ISPs  /*
		*/ , absorb(year NPNAME1_ i.year#c.($basevars)) /*
		*/ cluster(group)
				qui sum circ if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 		
						

eststo: reghdfe  circ  /*
		*/ post_CL_  post_CL_classif /*
		*/ log_pop  num_ISPs   /*
		*/ , absorb(year NPNAME1_ i.year#c.($basevars)) /*
		*/ cluster(group)
				qui sum circ if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 		
					
				
eststo: reghdfe  topic2  /*
		*/ post_CL_   /*
		*/ log_pop  num_ISPs    /*
		*/ , absorb(year NPNAME1_ i.year#c.($basevars)) /*
		*/ cluster(group)
				qui sum topic2 if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 			
	
eststo: reghdfe  topic2  /*
		*/ post_CL_  post_CL_classif /*
		*/ log_pop  num_ISPs  /*
		*/ , absorb(year NPNAME1_ i.year#c.($basevars)) /*
		*/ cluster(group)
				qui sum topic2 if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 		
	
			
eststo: reghdfe  ihs_congress_name_mentions  /*
		*/ post_CL_   /*
		*/ log_pop  num_ISPs  /*
		*/ ihs_total_articles /*
		*/ , absorb(year NPNAME1_ i.year#c.($basevars)) /*
		*/ cluster(group)
				qui sum ihs_congress_name_mentions if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 			
	
	
eststo: reghdfe  ihs_congress_name_mentions  /*
		*/ post_CL_  post_CL_classif /*
		*/ log_pop  num_ISPs   /*
		*/ ihs_total_articles /*
		*/ , absorb(year NPNAME1_ i.year#c.($basevars)) /*
		*/ cluster(group)
				qui sum ihs_congress_name_mentions if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 		
			
			
estfe *, labels(year "Year FE"  NPNAME1_ "Newspaper FE")
	return list
				
esttab  using $base_results/Appendix_Tables/Table_A9_b.tex, nomtitle r2 label replace se star(* 0.1 ** 0.05 *** 0.01) booktabs  nonotes b(3) se(3) ///		
		mgroups("\shortstack{Number \\ of jobs}"  "\shortstack{Circulation \\ per capita}"  "\shortstack{Politics coverage \\ topic weight }" "\shortstack{Congress coverage \\ names count (ihs)}", pattern(1 0 1 0 1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
		drop( _cons ihs_total_articles ) ///
		indicate("Baseline controls $\times$ Year FEs = 0.year#c.*"  "Log population, num. ISPs = log_pop num_ISPs" "Newspaper FEs, Year FEs = 0.NPNAME1_ 0.year",  labels("Yes"  "No")) ///
		order(post_CL_ post_CL_classif) ///
		stats(N NPNAME1_ r2 m, label( "Observations" "Number of newspapers" "R$^2$" "Mean dependent variable"  ) fmt(%13.0fc %13.0fc %9.2f %9.2f))
est clear		






**** TABLE A10: SPILLOVER EFFECTS

tempfile master
   save `master', replace

	   
	   **** circulation-weighted share of other newspapers with classif. manager

	keep if year == 2000

	bysort DMA_code : egen totval = total(classif_2000 * circ_2000)
		by DMA_code : egen cval = total(circ_2000)

		gen classif_DMA_2000 = (totval - classif_2000*circ_2000) / (cval - circ_2000)

		cap drop totval cval

		keep NPNAME1 classif_DMA_2000


	merge 1:m NPNAME1 using `master'

		drop _merge 
	
	

	*** circulation-weigthed share of other papers in the same DMA affected by CL 


	bysort DMA_code year: egen totval = total(post_CL_ * circ)
		by DMA_code year: egen cval   = total(circ)

		gen post_CL_DMA = (totval - post_CL_*circ) / (cval - circ)

		cap drop totval cval



egen post_CL_DMA_      = std(post_CL_DMA)
egen classif_DMA_2000_ = std(classif_DMA_2000)


cap drop post_CL_DMA classif_DMA_2000

rename post_CL_DMA_ post_CL_DMA
rename classif_DMA_2000_ classif_DMA_2000


gen post_CL_DMA_classif = post_CL_DMA * classif_DMA_2000



replace post_CL_DMA = .         if DMA_code == .
replace post_CL_DMA_classif = . if DMA_code == .
replace classif_DMA = . 		if DMA_code == .




label var post_CL_DMA 		  "Post-CL DMA"
label var post_CL_DMA_classif "Post-CL DMA $\times$ Classified Mgr. DMA"
label var classif_DMA         "Classif Mgr. DMA"


est clear		
				
eststo: reghdfe  jobscount  /*
		*/ post_CL_  /*
		*/ post_CL_DMA  /*
		*/ log_pop num_ISPs  /*
		*/  , absorb(year NPNAME1_ i.year#c.($basevars)) /*
		*/ cluster(CL_area)
				qui sum jobscount if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 		
								
		
		
eststo: reghdfe  jobscount  /*
		*/ post_CL_       post_CL_classif /*
		*/ post_CL_DMA  post_CL_DMA_classif  /*
		*/  log_pop num_ISPs  /*
		*/ , absorb( year NPNAME1_ i.year#c.($basevars)) /*
		*/ cluster(CL_area)
				qui sum jobscount if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 		
				

eststo: reghdfe  circ  /*
		*/ post_CL_   /*
		*/ post_CL_DMA   /*
		*/ log_pop num_ISPs  /*
		*/ , absorb( year NPNAME1_ i.year#c.($basevars)) /*
		*/ cluster(CL_area)
				qui sum circ if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 		

	
eststo: reghdfe  circ  /*
		*/ post_CL_       post_CL_classif /*
		*/ post_CL_DMA  post_CL_DMA_classif  /*
		*/ log_pop num_ISPs  /*
		*/ , absorb( year NPNAME1_ i.year#c.($basevars)) /*
		*/ cluster(CL_area)
				qui sum circ if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 		
				
				
		
eststo: reghdfe  topic2  /*
		*/ post_CL_ /*
		*/ post_CL_DMA   /*
		*/ log_pop num_ISPs  /*
		*/ , absorb( year NPNAME1_ i.year#c.($basevars)) /*
		*/ cluster(CL_area)
				qui sum topic2 if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 			

				
eststo: reghdfe  topic2  /*
		*/ post_CL_       post_CL_classif /*
		*/ post_CL_DMA  post_CL_DMA_classif   /*
		*/ log_pop num_ISPs  /*
		*/ , absorb( year NPNAME1_ i.year#c.($basevars)) /*
		*/ cluster(CL_area)
				qui sum topic2 if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 			
		
	
	
eststo: reghdfe  ihs_congress_name_mentions  /*
		*/ post_CL_ /*
		*/ post_CL_DMA   /*
		*/ log_pop num_ISPs  /*
		*/ ihs_total_articles /*
		*/ , absorb( year NPNAME1_ i.year#c.($basevars)) /*
		*/ cluster(CL_area)
				qui sum ihs_congress_name_mentions if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 			

				
eststo: reghdfe  ihs_congress_name_mentions  /*
		*/ post_CL_       post_CL_classif /*
		*/ post_CL_DMA  post_CL_DMA_classif   /*
		*/ log_pop num_ISPs  /*
		*/ ihs_total_articles /*
		*/ , absorb( year NPNAME1_ i.year#c.($basevars)) /*
		*/ cluster(CL_area)
				qui sum ihs_congress_name_mentions if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 		
		
	
					
	
estfe *, labels(year "Year FE"  NPNAME1_ "Newspaper FE")
	return list
	
				
esttab  using $base_results/Appendix_Tables/Table_A10.tex, nomtitle r2 label replace se star(* 0.1 ** 0.05 *** 0.01) booktabs  nonotes b(3) se(3) ///		
		mgroups("\shortstack{Number \\ of jobs}"  "\shortstack{Circulation \\ per capita}"  "\shortstack{Politics coverage \\ topic weight }" "\shortstack{Congress coverage \\ names count (ihs)}", pattern(1 0 1 0 1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
		drop( _cons ihs_total_articles 0.NPNAME1_ 0.year) ///
		order(post_CL_ post_CL_DMA post_CL_classif post_CL_DMA_classif) ///
		indicate(  "Baseline controls $\times$ Year FEs = 0.year#c.*" "Log population, num. ISPs = log_pop num_ISPs"  ,  labels("Yes"  "No")) ///
		stats(N NPNAME1_ r2 m, label( "Observations" "Number of newspapers" "R$^2$" "Mean dependent variable"  ) fmt(%13.0fc %13.0fc %9.2f %9.2f))
est clear
				
			


			


*** TABLE A11: NUMBER OF NEWSPAPERS AND CHANGES IN OWNERSHIP

*** Number of newspapers and changes in ownership


use "$base/data/master_data_newspaper_level", clear

	
   collapse (count) num_papers = NPNAME1_ , by(fips year)
 
 
   tsset fips year
   
   tsfill, full
   
  
    replace num_papers = 0 if num_papers==.
 
  merge 1:1 fips year using "$base/data/master_data_county_level"
   keep if _merge == 3
      drop _merge

   

   
   tempfile num_papers
      save `num_papers', replace
   
   
*** Collapsing classified manager at county level

use "$base/data/master_data_newspaper_level", clear

	keep if year==2000
	
	keep NPNAME1 fips classif_2000 circ_2000

	replace classif_2000 = 0 if classif_2000==.
	
collapse (mean) classif_2000 [pw=circ_2000], by(fips)

	
gen newspHQ_2000 = 1


merge 1:m fips using `num_papers'

drop _merge



keep if newspHQ_2000 == 1 

	
gen post_CL_classif    = post_CL_  * classif_2000


label var post_CL_		  	 "Post-CL"
label var post_CL_classif    "Post-CL $\times$ Classified Mgr."

label var num_papers "Number of newspapers HQ-ed in county"


		est clear
		
	
eststo: reghdfe  num_papers  /*
		*/ post_CL_  /*
		*/ log_pop num_ISPs  /*
		*/ , absorb(year fips i.year#c.($basevars)) /*
		*/ cluster(CL_area)
				qui sum num_papers if e(sample)
				estadd scalar  m r(mean)
				qui distinct  fips if e(sample)
				estadd scalar fips r(ndistinct) 		
	
	
eststo: reghdfe  num_papers  /*
		*/ post_CL_  post_CL_classif /*
		*/ log_pop num_ISPs  /*
		*/ , absorb(year fips i.year#c.($basevars)) /*
		*/ cluster(CL_area)
				qui sum num_papers if e(sample)
				estadd scalar  m r(mean)
				qui distinct  fips if e(sample)
				estadd scalar fips r(ndistinct) 		
	

use "$base/data/master_data_newspaper_level", clear
					
	sort NPNAME1 year				
					
	by NPNAME1:     gen group_change = 0 if year>1996
	by NPNAME1: replace group_change = 1 if group[_n]!=group[_n-1]
					
						
	
	
eststo: reghdfe  group_change  /*
		*/ post_CL_  /*
		*/ log_pop num_ISPs  /*
		*/ , absorb(year NPNAME1_ i.year#c.($basevars)) /*
		*/ cluster(CL_area)
				qui sum group_change if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 		
	
	
eststo: reghdfe  group_change  /*
		*/ post_CL_  post_CL_classif /*
		*/ log_pop num_ISPs  /*
		*/ , absorb(year NPNAME1_ i.year#c.($basevars)) /*
		*/ cluster(CL_area)
				qui sum group_change if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 
				
				

estfe *, labels(year "Year FE"  NPNAME1_ "Newspaper FE")
	return list
				
esttab  using $base_results/Appendix_Tables/Table_A11.tex, nomtitle r2 label replace se star(* 0.1 ** 0.05 *** 0.01) booktabs  nonotes b(3) se(3) ///		
		mgroups("\shortstack{Num. newspapers \\ HQ-ed in county}"  "\shortstack{Change in ownership}", pattern(1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
		drop( _cons ) ///
		order(post_CL_ post_CL_classif) ///
		indicate("Baseline controls $\times$ Year FEs = 0.year#c.*"  "Log population, num. ISPs = log_pop num_ISPs" "County FEs = 0.fips" "Newspaper FEs = 0.NPNAME1_" "Year FEs = 0.year" ,  labels("Yes"  "No")) ///
		stats(N fips NPNAME1_ r2 m, label( "Observations" "Number of counties" "Number of newspapers" "R$^2$" "Mean dependent variable"  ) fmt(%13.0fc %13.0fc %13.0fc %9.2f %9.2f))
est clear






*** TABLE A12: NUMBER OF PAGES PER ISSUE AND SUBSCRIPTION PRICES
		

use "$base/data/master_data_newspaper_level", clear
	
	
	drop if largepaper > 0
	
	
	
	gen log_price_y = log(price_y)
	
	label var log_price_y "Log subscription price"
	
	est clear

	
eststo: reghdfe  num_pages  /*
		*/ post_CL_   /*
		*/ log_pop num_ISPs  /*
		*/ , absorb(year NPNAME1_ i.year#c.($basevars)) /*
		*/ cluster(CL_area)
				qui sum num_pages if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 
				

eststo: reghdfe  num_pages  /*
		*/ post_CL_  post_CL_classif /*
		*/ log_pop num_ISPs  /*
		*/ , absorb(year NPNAME1_ i.year#c.($basevars)) /*
		*/ cluster(CL_area)
				qui sum num_pages if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 				

				

eststo: reghdfe  log_price_y  /*
		*/ post_CL_  /*
		*/ log_pop num_ISPs  /*
		*/ , absorb(year NPNAME1_ i.year#c.($basevars)) /*
		*/ cluster(CL_area)
				qui sum log_price_y if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 		
	

eststo: reghdfe  log_price_y  /*
		*/ post_CL_ post_CL_classif /*
		*/ log_pop num_ISPs  /*
		*/ , absorb(year NPNAME1_ i.year#c.($basevars)) /*
		*/ cluster(CL_area)
				qui sum log_price_y if e(sample)
				estadd scalar  m r(mean)
				qui distinct  NPNAME1_ if e(sample)
				estadd scalar NPNAME1_ r(ndistinct) 		
					
				
estfe *, labels(year "Year FE"  NPNAME1_ "Newspaper FE")
	return list
				
esttab  using $base_results/Appendix_Tables/Table_A12.tex, nomtitle r2 label replace se star(* 0.1 ** 0.05 *** 0.01) booktabs  nonotes b(3) se(3) ///		
		mgroups("\shortstack{Total pages}" "\shortstack{Subscription price}", pattern(1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
		order(post_CL_ post_CL_classif) ///
		indicate("Baseline controls $\times$ Year FEs = 0.year#c.*"  "Log population, num. ISPs = log_pop num_ISPs" "Newspaper FEs, Year FEs = 0.NPNAME1_ 0.year" ,  labels("Yes"  "No")) ///
		drop( _cons ) ///
		stats(N NPNAME1_ r2 m, label( "Observations" "Number of newspapers" "R$^2$" "Mean dependent variable"  ) fmt(%13.0fc %13.0fc %9.2f %9.2f))
est clear

		
		
		
		
		/*
		/*

		
*** TABLE A13: SELF-REPORTED CONSUMPTION OF OTHER MEDIA



***** GfK-MRI survey


use "$base/data/master_data_newspaper_level", clear

	keep NPNAME1 fips classif_2000 circ_2000 largepaper_HQ

	duplicates drop
	
collapse (mean) classif_2000 [pw=circ_2000], by(fips largepaper_HQ)

	
gen newspHQ_2000 = 1

drop if largepaper_HQ >0


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


		keep if newspHQ_2000 == 1
		
				
	
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
	
	
	**** Consumption of other media
	
	
	label var tv_news_natl 	  "Watched TV"
	label var read_natl_paper "Read newspaper, national"
	label var inet_news  	  "Read online"
	label var radio_news 	  "Listened radio"
	
	
	est clear
	

foreach depvar in read_natl_paper tv_news_natl radio_news inet_news {

	
eststo: reghdfe `depvar' post_CL_  post_CL_classif    /*
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
				
esttab  using $base_results/Appendix_Tables/Table_A13_a.tex, r2 label replace se star(* 0.1 ** 0.05 *** 0.01) booktabs  nonotes b(3) se(3) ///		
		drop( _cons) ///
		indicate("Respondent controls = $resp_controls" "Baseline controls $\times$ Year FEs = 0.year#c.*"  "Log population, num. ISPs  = log_pop num_ISPs" "County FEs, Year FEs = 0.fips 0.year",  labels("Yes"  "No")) ///
		stats(N fips r2 m, label( "Observations" "Number of counties" "R$^2$" "Mean dependent variable"  ) fmt(%13.0fc %13.0fc %9.2f %9.2f))
est clear
	



*** NAES survey



use "$base/data/master_data_newspaper_level", clear

	keep if year == 2000 

	keep NPNAME1 fips classif_2000 circ_2000 
	
	replace classif_2000 = 0 if classif_2000==. 

	
collapse (mean) classif_2000 [pw=circ_2000], by(fips)

	gen newspHQ_2000=1

	
merge 1:m fips using "$base/data/master_data_county_level"

keep if _merge ==3
   drop _merge
   
    


tempfile master
   save `master', replace
   

use "$base\data\annenberg\annenberg2000-2004-2008_select", clear

gen n=_n


merge 1:1 n using "$base\data\annenberg\annenberg2000-2004-2008_preds"

keep if _merge==3
   drop _merge
   
   
 
merge m:1 fips year using `master'



gen post_CL_classif    = post_CL_ * classif_2000


label var post_CL_		  	 "Post-CL"
label var post_CL_classif 	 "Post-CL $\times$ Classified Mgr."



	keep if year!=2008 /*only campaign-specific media consumption questions in 2008*/ 
	
	
rename read_newspaper_national read_national

egen watched_TV = rowmax(watched_local watched_network watched_cable)
		
		
    gen read_newspaper_dummy = 0 if read_newspaper!=.
replace read_newspaper_dummy = 1 if read_newspaper > 0 & read_newspaper!=.
		
    gen read_national_dummy = 0 if read_national!=.
replace read_national_dummy = 1 if read_national > 0 & read_national!=.
	

	gen watched_TV_dummy = 0 if watched_TV!=.
replace watched_TV_dummy = 1 if watched_TV > 0 & watched_TV!=.
				
	gen listened_radio_dummy = 0 if listened_radio!=.
replace listened_radio_dummy = 1 if listened_radio > 0 & listened_radio!=.
		
	label var read_newspaper_dummy "\shortstack{Read newspaper\\dummy:\\ Full sample}"
label var read_national_dummy  "\shortstack{Read newspaper, national\\dummy}"
label var watched_TV_dummy     "\shortstack{Watched TV\\dummy}"
label var listened_radio_dummy "\shortstack{Listened radio\\dummy}"		




gen resp_age2 = resp_age * resp_age				
		
global resp_controls resp_sex /*
				  */ resp_age  /*
				  */ resp_age2 /*
				  */ resp_college /*
				  */ resp_race*
		



		est clear

	foreach var in read_national_dummy  /*
				*/ watched_TV_dummy  /*
				*/ listened_radio_dummy  {
	
eststo: reghdfe `var' post_CL_  post_CL_classif    /*
		*/ log_pop num_ISPs  /*
		*/ $resp_controls, absorb(year  fips  i.year#c.($basevars)) /*
		*/ cluster(CL_area)
				qui sum `var' if e(sample)
				estadd scalar  m r(mean)
				qui distinct  fips if e(sample)
				estadd scalar fips r(ndistinct) 
				
				}
				
estfe *, labels(year "Year FE"  NPNAME1_ "Newspaper FE")
	return list
				
esttab  using $base_results/Appendix_Tables/Table_A13_b.tex, r2 label replace se star(* 0.1 ** 0.05 *** 0.01) booktabs  nonotes b(3) se(3) ///		
		drop( _cons ) ///
		indicate("Respondent controls = $resp_controls" "Baseline controls $\times$ Year FEs = 0.year#c.*"  "Log population, num. ISPs  = log_pop num_ISPs" "County FEs, Year FEs = 0.fips 0.year",  labels("Yes"  "No")) ///
		stats(N fips r2 m, label( "Observations" "Number of counties" "R$^2$" "Mean dependent variable"  ) fmt(%13.0fc %13.0fc %9.2f %9.2f))
est clear
	
	

*/
*/


	

***	TABLE A14: ONLINE NEWS CONSUMPTION


	 
	
****  Popularity of other websites	
	
use $base/data/Comscore/visitcounts	, clear
	
	
	
	egen top3_count = rowtotal(wsj nyt usat)

	cap rename geo fips

	tempfile comscore
       save `comscore', replace


use "$base/data/master_data_newspaper_level", clear
		
	keep if year==2000
	
	replace classif_2000=0 if classif_2000==.
	
	collapse (mean) classif_2000 [pw=circ_2000], by(fips)

		
	gen newspHQ_2000 = 1


	merge 1:m fips using "$base/data/master_data_county_level"

	drop _merge



	merge 1:1 fips year using `comscore'


	keep if _merge==3
	   drop _merge


	
	****** dependent variable: CL visits, controlling for total visits

	gen cl        = asinh(craigslistorg_count)
	gen total     = asinh(all_count)
	
		
	label var cl          "CL visits (ihs)"
	label var total       "Total Comscore visits (ihs)"
	

	
	foreach var in nytimescom_count /*
				*/ wsjcom_count /*
				*/ usatodaycom_count /*
				*/ top3_count /*
				*/ top100_count {
					
	gen ihs_`var' = asinh(`var')				
					
				}
	
	
	gen post_CL_classif  = post_CL_  * classif_2000
				
		label var post_CL_		  	 "Post-CL"
		label var post_CL_classif 	 "Post-CL $\times$ Classified Mgr."

		
	
	keep if newspHQ_2000 == 1
	

	label var ihs_nytimescom_count "\shortstack{Visits to \\ \url{nytimes.com} \\ (ihs)}"
	label var ihs_wsjcom_count "\shortstack{Visits to \\ \url{wsj.com} \\ (ihs)}"
	label var ihs_usatodaycom_count "\shortstack{Visits to \\ \url{usatoday.com} \\ (ihs)}"
	label var ihs_top3_count "\shortstack{Visits to top 3 \\ newspaper websites \\ (ihs)}"
	label var ihs_top100_count "\shortstack{Visits to top 100 \\ news websites \\ (ihs) }"
	

		
		est clear
	
			foreach var in ihs_nytimescom_count /*
						*/ ihs_wsjcom_count /*
						*/ ihs_usatodaycom_count /*
						*/ ihs_top3_count /*
						*/ ihs_top100_count {
		

eststo: reghdfe `var'  post_CL_  post_CL_classif    /*
		*/ log_pop num_ISPs /*
		*/ all_count , absorb(year fips i.year#c.($basevars)) /*
		*/ cluster(CL_area)
				qui sum `var'  if e(sample)
				estadd scalar  m r(mean)
				qui distinct  fips if e(sample)
				estadd scalar fips r(ndistinct) 
				
			}	
			
			
estfe *, labels(year "Year FE"  fips "County FE")
	return list
				
esttab  using $base_results/Appendix_Tables/Table_A14.tex,  r2 label replace se star(* 0.1 ** 0.05 *** 0.01) booktabs  nonotes b(3) se(3) ///		
		drop( _cons ) ///
		order(post_CL_) ///
		indicate("Baseline controls $\times$ Year FEs = 0.year#c.*"  "Log population, \#ISPs  = log_pop num_ISPs" "County FEs, Year FEs = 0.fips 0.year" "Total Comscore visits (ihs) = all_count",  labels("Yes"  "No")) ///
		stats(N fips r2 m, label( "Observations" "Number of counties" "R$^2$" "Mean dependent variable"  ) fmt(%13.0fc %13.0fc %9.2f %9.2f))
est clear
		



	
	
	

*** TABLE A15: TOPIC MODEL WEIGHTS: SEPARATING POLITICAL TOPICS



		**** Merge in anchored topics
	
			import excel using $base\data\Newspapers_content\Topic_Model\avg_topic_prob_by_newspaper_year.xlsx, clear first


			drop if inlist(_n, 1,2)

					forval n = 0/9 {

					cap rename label`n' topic`n'

					}

			destring topic*, replace

			rename source NL_originalname

			   
			merge m:1 NL_originalname using "$base\data\Newspapers_content\matching_NLPQ_to_EP\NL_namelist_matched_to_EP", keepusing(NPNAME1)

				keep if _merge==3
				   drop _merge
			   
				duplicates drop NPNAME1 year, force
			   
			merge 1:1 NPNAME1 year using $base/data/master_data_newspaper_level

			drop if _merge == 1
			   drop _merge


			drop if largepaper > 0   
					
			
			
			**** Label variables				
		
			label var topic0 "\shortstack{presid,\\ feder, govern,\\ compani, tax}"
			label var topic1 "\shortstack{council,\\ mayor, board,\\ plan, student}"
			label var topic2 "\shortstack{repres,\\ senat, congress,\\ republican, elect}"
			label var topic3 "\shortstack{intern,\\ war, foreign,\\ iraq, militari}"
			label var topic4 "\shortstack{man,\\ kill, injuri,\\ injur, accid}"
			label var topic5 "\shortstack{music,\\ art, food,\\ festival, featur}"
			label var topic6 "\shortstack{car,\\ vehicl, driver,\\ road, truck}"
			label var topic7 "\shortstack{di,\\ born, funer,\\ son, daughter}"
			label var topic8 "\shortstack{game,\\ team, coach,\\ win, season}"
			label var topic9 "\shortstack{polic,\\ charg, court,\\ arrest, judg}"

			
			forval n=0/3 {
			
				
			eststo: reghdfe  topic`n'  /*
					*/ post_CL_  post_CL_classif /*
					*/ log_pop  num_ISPs /*
					*/ , absorb(year NPNAME1_ i.year#c.($basevars)) /*
					*/ cluster(CL_area)
							qui sum topic`n' if e(sample)
							estadd scalar  m r(mean)
							qui distinct  NPNAME1_ if e(sample)
							estadd scalar NPNAME1_ r(ndistinct) 		
					}
			
			
			estfe *, labels(year "Year FE"  NPNAME1_ "Newspaper FE")
	return list
				
esttab  using $base_results/Appendix_Tables/Table_A15_a.tex,  r2 label replace se star(* 0.1 ** 0.05 *** 0.01) booktabs  nonotes b(3) se(3) ///		
		order(post_CL_ post_CL_classif) ///
		drop( _cons ) ///
		indicate("Baseline controls $\times$ Year FEs = 0.year#c.*"  "Log population, num. ISPs = log_pop num_ISPs" "Newspaper FEs, Year FEs = 0.NPNAME1_ 0.year" ,  labels("Yes"  "No")) ///
		stats(N NPNAME1_ r2 m, label( "Observations" "Number of newspapers" "R$^2$" "Mean dependent variable"  ) fmt(%13.0fc %13.0fc %9.2f %9.2f))
est clear		
	
			
					forval n=4/9 {
			
				
			eststo: reghdfe  topic`n'  /*
					*/ post_CL_  post_CL_classif /*
					*/ log_pop  num_ISPs /*
					*/ , absorb(year NPNAME1_ i.year#c.($basevars)) /*
					*/ cluster(CL_area)
							qui sum topic`n' if e(sample)
							estadd scalar  m r(mean)
							qui distinct  NPNAME1_ if e(sample)
							estadd scalar NPNAME1_ r(ndistinct) 		
						}
			
			
			estfe *, labels(year "Year FE"  NPNAME1_ "Newspaper FE")
	return list
				
esttab  using $base_results/Appendix_Tables/Table_A15_b.tex,  r2 label replace se star(* 0.1 ** 0.05 *** 0.01) booktabs  nonotes b(3) se(3) ///		
		order(post_CL_ post_CL_classif) ///
		drop( _cons ) ///
		indicate("Baseline controls $\times$ Year FEs = 0.year#c.*"  "Log population, num. ISPs = log_pop num_ISPs" "Newspaper FEs, Year FEs = 0.NPNAME1_ 0.year" ,  labels("Yes"  "No")) ///
		stats(N NPNAME1_ r2 m, label( "Observations" "Number of newspapers" "R$^2$" "Mean dependent variable"  ) fmt(%13.0fc %13.0fc %9.2f %9.2f))
est clear		
	
			
			


*** TABLE A16: MENTIONS OF IN-STATE CONGRESSIONAL INCUMBENTS AND CANDIDATES: HETEROGENEITY

		
	
use $base/data/master_data_newspaper_level, clear


drop if largepaper > 0
		
		
		label var ihs_cong_general_mentions "\shortstack{General election}"
		label var ihs_cong_primary_mentions "\shortstack{Other times}"
	
		label var ihs_cong_incumbent_mentions "\shortstack{Incumbents}"
		label var ihs_cong_challenger_mentions "\shortstack{Challengers}"
		
		label var ihs_cong_sen_mentions "\shortstack{Senate}"
		label var ihs_cong_house_mentions "\shortstack{House}"
		
		
	
	
		foreach var in /*
					*/ ihs_cong_incumbent_mentions ihs_cong_challenger_mentions /*
					*/ ihs_cong_sen_mentions ihs_cong_house_mentions {
			

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
				
esttab  using $base_results/Appendix_Tables/Table_A16.tex, r2 label replace se star(* 0.1 ** 0.05 *** 0.01) booktabs  nonotes b(3) se(3) ///		
		order(post_CL_ post_CL_classif) ///
		indicate("Baseline controls $\times$ Year FEs = 0.year#c.*"  "Log population, num. ISPs = log_pop num_ISPs" "Newspaper FEs, Year FEs = 0.NPNAME1_ 0.year" ,  labels("Yes"  "No")) ///
		drop( _cons ihs_total_articles) ///
		mgroups("Split by incumbency"  "Split by office", pattern(1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
		stats(N NPNAME1_ r2 m, label( "Observations" "Number of newspapers" "R$^2$" "Mean dependent variable"  ) fmt(%13.0fc %13.0fc %9.2f %9.2f))
est clear


		
		
*** TABLE A17: MENTIONS OF OTHER POLITICIANS		


	
use $base/data/master_data_newspaper_level, clear


drop if largepaper > 0
		
		
		label var ihs_congressleaders_mentions "\shortstack{Congress. leaders \\ articles count (ihs)}"
		label var ihs_president_mentions "\shortstack{President \\ articles count (ihs)}"
		label var ihs_local_mentions "\shortstack{State and local \\ articles count (ihs)}"
		
		
		
		foreach var in ihs_congressleaders_mentions ihs_president_mentions ihs_local_mentions {
			

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
				
esttab  using $base_results/Appendix_Tables/Table_A17.tex, r2 label replace se star(* 0.1 ** 0.05 *** 0.01) booktabs  nonotes b(3) se(3) ///		
		order(post_CL_ post_CL_classif) ///
		indicate("Baseline controls $\times$ Year FEs = 0.year#c.*"  "Log population, num. ISPs = log_pop num_ISPs" "Newspaper FEs, Year FEs = 0.NPNAME1_ 0.year" ,  labels("Yes"  "No")) ///
		drop( _cons ihs_total_articles) ///
		stats(N NPNAME1_ r2 m, label( "Observations" "Number of newspapers" "R$^2$" "Mean dependent variable"  ) fmt(%13.0fc %13.0fc %9.2f %9.2f))
est clear





*** TABLE A18: GENERIC MENTIONS OF CONGRESSIONAL INSTITUTIONS
		
		
		
use $base/data/master_data_newspaper_level, clear


drop if largepaper > 0
		
		
		label var ihs_congress_mentions "\shortstack{Congress keywords \\ articles count (ihs)}"
		label var ihs_congress_prim_mentions "\shortstack{Congress. primary keywords \\ articles count (ihs)}"
			
		foreach var in ihs_congress_mentions ihs_congress_prim_mentions{
			

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
				
esttab  using $base_results/Appendix_Tables/Table_A18.tex, r2 label replace se star(* 0.1 ** 0.05 *** 0.01) booktabs  nonotes b(3) se(3) ///		
		order(post_CL_ post_CL_classif) ///
		indicate("Baseline controls $\times$ Year FEs = 0.year#c.*"  "Log population, num. ISPs = log_pop num_ISPs" "Newspaper FEs, Year FEs = 0.NPNAME1_ 0.year" ,  labels("Yes"  "No")) ///
		drop( _cons ihs_total_articles) ///
		stats(N NPNAME1_ r2 m, label( "Observations" "Number of newspapers" "R$^2$" "Mean dependent variable"  ) fmt(%13.0fc %13.0fc %9.2f %9.2f))
est clear



		
		
		
*** TABLE A19: MENTIONS OF HAMILTON (2016) ACCOUNTABILITY KEYWORDS		


use $base/data/master_data_newspaper_level, clear


drop if largepaper > 0
		
		
		label var ihs_accountability_mentions "\shortstack{Accountability words}"
		

		foreach var in ihs_accountability_mentions  {			

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
				
esttab  using $base_results/Appendix_Tables/Table_A19.tex, r2 label replace se star(* 0.1 ** 0.05 *** 0.01) booktabs  nonotes b(3) se(3) ///		
		order(post_CL_ post_CL_classif) ///
		indicate("Baseline controls $\times$ Year FEs = 0.year#c.*"  "Log population, num. ISPs = log_pop num_ISPs" "Newspaper FEs, Year FEs = 0.NPNAME1_ 0.year" ,  labels("Yes"  "No")) ///
		drop( _cons ihs_total_articles) ///
		mgroups("Split by timing" , pattern(1 0 ) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
		stats(N NPNAME1_ r2 m, label( "Observations" "Number of newspapers" "R$^2$" "Mean dependent variable"  ) fmt(%13.0fc %13.0fc %9.2f %9.2f))
est clear







**** Merging in electoral turnout 


use "$base/data/master_data_newspaper_level", clear

	
	keep if year==2000
	
	keep NPNAME1 fips classif_2000 circ_2000
	
	replace classif_2000= 0 if classif_2000==. 
	
	
collapse (mean) classif_2000 [pw=circ], by(fips)
	
gen newspHQ_2000 = 1


merge 1:m fips using "$base/data/master_data_county_level"
drop _merge
	

keep if newspHQ_2000 ==1	
	

merge 1:1 fips year using $base\data\political\turnout_data_notmerged, keepusing(house_dev sen_dev turnout_house turnout_sen)

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


*** TABLE A20: POLITICAL EFFECTS: ROBUSTNESS TO THE INCLUSION OF STATE-SPECIFIC TRENDS


*** Turnout in Congressional elections and split-ticket voting


eststo: reghdfe turnout_congress     post_CL_      /*
		*/ log_pop num_ISPs /*
		*/ [pw=voting_pop_], absorb(i.year##i.exp fips i.year#c.($basevars) c.year#i.state_) /*
		*/ cluster(CL_area)
				qui sum turnout_congress if e(sample)
				estadd scalar  m r(mean)
				qui distinct  fips if e(sample)
				estadd scalar fips r(ndistinct) 						

	
eststo: reghdfe turnout_congress     post_CL_  post_CL_classif    /*
		*/ log_pop num_ISPs /*
		*/ [pw=voting_pop_], absorb(i.year##i.exp fips i.year#c.($basevars) c.year#i.state_) /*
		*/ cluster(CL_area)
				qui sum turnout_congress if e(sample)
				estadd scalar  m r(mean)
				qui distinct  fips if e(sample)
				estadd scalar fips r(ndistinct) 											
		
		

eststo: reghdfe split_vote     post_CL_      /*
		*/ log_pop num_ISPs /*
		*/ [pw=voting_pop_], absorb(i.year##i.exp fips i.year#c.($basevars) c.year#i.state_) /*
		*/ cluster(CL_area)
				qui sum split_vote if e(sample)
				estadd scalar  m r(mean)
				qui distinct  fips if e(sample)
				estadd scalar fips r(ndistinct) 						

	
eststo: reghdfe split_vote     post_CL_  post_CL_classif    /*
		*/ log_pop num_ISPs /*
		*/ [pw=voting_pop_], absorb(i.year##i.exp  fips i.year#c.($basevars) c.year#i.state_) /*
		*/ cluster(CL_area)
				qui sum split_vote if e(sample)
				estadd scalar  m r(mean)
				qui distinct  fips if e(sample)
				estadd scalar fips r(ndistinct) 						

				
estfe *, labels(year "Year FE"  fips "County FE")
	return list
							
							
esttab  using $base_results/Appendix_Tables/Table_A20_a.tex, nomtitle r2 label replace se star(* 0.1 ** 0.05 *** 0.01) booktabs  nonotes b(3) se(3) ///		
		drop( _cons) ///
		mgroups("\shortstack{Turnout \\ House/Senate}"  "\shortstack{Split-ticket \\ vote}", pattern(1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
		indicate("State $\times$ Linear time trend = 0.state_#c.year" "Baseline controls $\times$ Year FEs = 0.year#c.*" "Log population, num. ISPs = log_pop num_ISPs"  "County FEs, Year-Office FEs = 0.fips 0.year*" , labels("Yes"  "No")) ///
		stats(N fips r2 m, label( "Observations" "Number of counties" "R$^2$" "Mean dependent variable"  ) fmt( %13.0fc %13.0fc %9.2f %9.2f))
est clear						
											
									
					
		
	

					
					
					
** Merge in electoral results by candidate extremity


use "$base/data/master_data_newspaper_level", clear

	keep if year==2000
	
	keep NPNAME1 fips classif_2000 circ_2000

	replace classif_2000 = 0 if classif_2000==.

		
collapse (mean) classif_2000 = classif [pw=circ_2000], by(fips)

	
gen newspHQ_2000 = 1


merge 1:m fips using "$base/data/master_data_county_level"

drop _merge

tempfile np


keep if newspHQ_2000 == 1



save `np', replace

import delimited "$base\data\political\house_elections_cf_dist_cty.csv", clear

tempfile politics
save `politics', replace 



use `np' , clear

merge 1:m fips year using `politics', keepusing(extremist_in_general extremist_in_dempri extremist_in_reppri winner_group w_cty_dist district redist_regime winner_cfscore winner_dwdime winner_group_dwdime vs_extrem_right vs_extrem_left diverge_cfscore)
	
	
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
		*/ [pw=w_cty_dist], absorb(year fips i.year#c.($basevars) district_code_ c.year##i.state_) /*
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
		*/ [pw=w_cty_dist], absorb(year fips i.year#c.($basevars) district_code_ c.year##i.state_) /*
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
							
						
esttab  using $base_results/Appendix_Tables/Table_A20_b.tex, nomtitle r2 label replace se star(* 0.1 ** 0.05 *** 0.01) booktabs  nonotes b(3) se(3) ///		
		drop( _cons) ///
		mgroups("\shortstack{Extremist \\ in primary}"  "\shortstack{Extremist \\ in general}" "\shortstack{Extremist wins \\ general}", pattern(1 0 1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
		indicate("State $\times$ Linear time trend = 0.state_#c.year" "Baseline controls $\times$ Year FEs = 0.year#c.*" "Log population, num. ISPs = log_pop num_ISPs"  "County FEs, Year FEs = 0.fips 0.year" "District FEs = 0.district_code_", labels("Yes"  "No")) ///
		stats(N fips districts r2 m, label( "Observations" "Number of counties" "Number of districts" "R$^2$" "Mean dependent variable"  ) fmt( %13.0fc %13.0fc %13.0fc %9.2f %9.2f))
est clear						
			









