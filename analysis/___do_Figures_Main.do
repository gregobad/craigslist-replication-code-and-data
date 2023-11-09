global base         = "C:\Users\mdjou\OneDrive\Desktop\craigslist-replication-code-and-data"
global base_results = "C:\Users\mdjou\OneDrive\Desktop\craigslist-replication-code-and-data\Results"


clear all
set more off






	   

*******************************************************************************    
***** Graph for CL's expansion + ISPs


   use $base/data/master_data_county_level, clear
   
   collapse (mean) num_ISPs post_CL_ , by(year)

   tsset year
   
   label var post_CL_        "Share counties with CL (core)"
   label var num_ISPs        "Num. Internet service providers by zipcode"
   
 
   
   twoway  (tsline post_CL_ ,yaxis(1)) (tsline num_ISPs ,yaxis(2) )
   

   
   
*******************************************************************************    
***** Time-series of CL visits vs. visits to other classified websites
   
use $base/data/Comscore/visitcounts	, clear
	
		
collapse (sum) craigslistorg_count /*
			*/ monstercom_count /*
			*/ ebaycom_count /*
			*/ realtorcom_count  all_count, by(year)
			

foreach var in craigslistorg_count /*
			*/ monstercom_count /*
			*/ ebaycom_count /*
			*/ realtorcom_count /*
			*/  {
				
				replace `var' =  (`var' / all_count)*1000
						
			}			
	
	tsset year
	tsfill
	
	tsline 	craigslistorg_count /*
			*/ monstercom_count /*
			*/ ebaycom_count /*
			*/ realtorcom_count 
		



		
		
		
		
		
		
		


*** TABLE B1: SHARE PAGES DEVOTED TO CLASSIFIED ADS AND CLASSIFIED RATE IN PRE-CL PERIOD, BY PRESENCE OF CLASSIFIED MANAGER IN 2000.
		
				
	***** Pre-2000 classified PAGES 		
	

	use $base/data/Newspapers.com/npcom_classified_pages_with_totals_corrected, clear
	
	
	rename np_name NPNAME1
	
	keep if year<=2000
	
	
	replace NPNAME1 = "tinleyparkdailysouthtownIL" /*
				*/ if NPNAME1=="tinleyparksouthtownstarIL"
	
	replace NPNAME1 = "sanbernardinosunCA" /*
				*/ if NPNAME1=="sanbernardinocountysunCA"
	
	replace NPNAME1 = "pottsvillerepublicanandeveningheraldPA" /*
				*/ if NPNAME1=="pottsvillerepublicanPA"
	
	replace NPNAME1 = "oklahomacityoklahomanOK" /*
				*/ if NPNAME1=="oklahomacitydailyoklahomanOK"
	
	replace NPNAME1 = "mcalesternewscapitalOK" /*
				*/ if NPNAME1=="mcalesternewscapitalanddemocratOK"
	
	
	gen n = 1
	
	collapse (mean) cl_pages_corrected total_pages (sum) issues = n  , by(NPNAME1 wkday)
	

	
	joinby NPNAME1 using $base/data/master_data_newspaper_level
	
	
	drop if largepaper > 0
	

	
	gen clpages = (cl_pages_corrected/ num_pages_2000)

			
			keep if year == 2000
			
			
			est clear
			eststo: reg clpages i.classif_2000 $basevars log_pop num_ISPs circ_2000 jobscount_2000 i.wkday total_pages [pw= issues], robust
			qui distinct  NPNAME1_ if e(sample)
			estadd scalar NPNAME1_ r(ndistinct) 		
			qui sum clpages if e(sample)
			estadd scalar  m r(mean)

			
				margins, over(classif_2000)
				margins, at(classif_2000 = (0 1))
				
			
			label var classif_2000 "Classified Mgr."

			
		
			
			marginsplot,  recast(bar) plotopts(barw(.8)) graphregion(fcolor(white)) title("Classified pages (share of total)") xtitle("Classified Mgr.", size(medlarge)) ytitle("Linear Prediction", size(medlarge)) 
						
			graph export "$base_results/Figures/Figure_3a.pdf", replace	
			
	
	
***** Pre-2000 classified PRICES	
	
	
	use $base/data/Classified_Prices/ClassRates_1994_2006, clear
	

	keep if year <=2000
	
	cap drop unit
	
	rename unit_original unit
	
	collapse (mean) cl_daily, by(NPNAME1 unit)
	
	
	duplicates drop NPNAME1 unit , force
	
	
	joinby NPNAME1 using $base/data/master_data_newspaper_level
	
	
	drop if largepaper > 0 
	
		keep if year ==2000
		
		encode unit, gen(_unit)
		
		
		gen log_classif_rate = log(cl_daily)

		
		eststo: reg log_classif_rate i.classif_2000 i._unit $basevars log_pop num_ISPs circ_2000 jobscount_2000, robust
		qui distinct  NPNAME1_ if e(sample)
		estadd scalar NPNAME1_ r(ndistinct) 		
		qui sum log_classif_rate if e(sample)
		estadd scalar  m r(mean)

				margins, over(classif_2000)
				margins, at(classif_2000 = (0 1))
				
			
			label var classif_2000 "Classified Mgr."

			
			
			marginsplot,  recast(bar) plotopts(barw(.8)) graphregion(fcolor(white)) title("Log classified rates") xtitle("Classified Mgr.", size(medlarge)) ytitle("Linear Prediction", size(medlarge)) 
			
			
			graph export "$base_results/Figures/Figure_3b.pdf", replace	
	
	
estfe *, labels(year "Year FE"  NPNAME1_ "Newspaper FE" wkday "Day-of-week FE")
	return list
				
esttab  using $base_results/Appendix_Tables/Table_B1.tex, nomtitle r2 label replace se star(* 0.1 ** 0.05 *** 0.01) booktabs  nonotes b(3) se(3) ///		
		mgroups( "\shortstack{Share classified pages}" "\shortstack{Log classified rate}", pattern(1 1) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
		indicate("Day-of-week FEs = 1.wkday" "Unit FEs = 1._unit" "Baseline controls = $basevars"  "Log population, num. ISPs = log_pop num_ISPs" "Newspaper circulation and jobscount = circ_2000 jobscount_2000" "Total newspapers.com pages = total_pages",  labels("Yes"  "No")) ///
		stats(N NPNAME1_ r2 m, label( "Observations" "Number of newspapers" "R$^2$" "Mean dependent variable"  ) fmt(%13.0fc %13.0fc %9.2f %9.2f))
est clear

	
	
		
		


	
use $base/data/Comscore/visitcounts	, clear
	
	

merge 1:m fips year using "$base\data/master_data_county_level"

*** Note: Here we are using all counties, not only ones newspaper HQ

drop _merge



	
	****** dependent variable: CL visits, controlling for total visits

	gen cl        = asinh(craigslistorg_count)
	gen total     = asinh(all_count)
	
		
	label var cl          "CL visits (ihs)"
	label var total       "Total Comscore visits (ihs)"
	


	
*** FIGURE 4: Visits to Craigslist.org -- Event Study


did_multiplegt cl /*
			*/ fips  /*
			*/ year /*
			*/ post_CL_ /*
			*/, average_effect robust_dynamic breps(50) /*
			*/ controls(total log_pop num_ISPs) /*
			*/ placebo(4) dynamic(4) /*
			*/ cluster(CL_area_) save_results("$base_results/Figures/Figure_4.dta")

	
preserve
			use "$base_results/Figures/Figure_4.dta", clear
			
			eclplot treatment_effect treatment_effect_lower_95CI treatment_effect_upper_95CI time_to_treatment,  /*
		*/  yline(0, lcolor(gs12) lpattern(dash))  /*
		*/  eplottype(scatter) ciopts(color(navy*0.5) lwidth(medthick))   /*
		*/  yline(0, lcolor(grey*0.4) lpattern(dash) lwidth(medthick))  /*
		*/  legend(off)  graphregion(fcolor(white)) /*
		*/  xtitle("Years Pre/Post CL") ytitle(" ") /*
		*/  xline(-0.5, lcolor(red*0.4) lwidth(medthick) ) /*
		*/  xsize(1.2) ysize(1) /* 
		*/  xlabel(-5(1)4) 
			graph export "$base_results/Figures/Figure_4.pdf",  replace	

		cap erase "$base_results/Figures/Figure_4.dta"	
			
restore		
		
	
	
	
************************************************************

use $base/data/master_data_newspaper_level, clear


   
drop if largepaper >0

		
	
**** baseline county characteristics
	
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
	

************************************************************
	

**** FIGURE 5: MAIN NEWSPAPER OUTCOMES – EVENT STUDIES	
	
	
	
*** Jobs count	

did_multiplegt jobscount /*
			*/ NPNAME1_  /*
			*/ year /*
			*/ post_CL_ /*
			*/, average_effect  robust_dynamic breps(100) /*
			*/ controls(log_pop num_ISPs ) /*
			*/ placebo(4) dynamic(4) /*
			*/ cluster(CL_area_) save_results("$base_results/Figures/Figure_5a_1.dta")

	
preserve
			use "$base_results/Figures/Figure_5a_1.dta", clear
			
			eclplot treatment_effect treatment_effect_lower_95CI treatment_effect_upper_95CI time_to_treatment,  /*
		*/  yline(0, lcolor(gs12) lpattern(dash))  /*
		*/  eplottype(scatter) ciopts(color(navy*0.5) lwidth(medthick))   /*
		*/  yline(0, lcolor(grey*0.4) lpattern(dash) lwidth(medthick))  /*
		*/  xline(-0.5, lcolor(red*0.4) lwidth(medthick) ) /*
		*/  legend(off)  graphregion(fcolor(white)) /*
		*/  xtitle("Years Pre/Post CL") ytitle(" ") /*
		*/  xsize(1.2) ysize(1) /* 
		*/  xlabel(-5(1)4) ylabel(-5(1)3)
			graph export "$base_results/Figures/Figure_5a_1.pdf",  replace	

		cap erase "$base_results/Figures/Figure_5a_1.dta"	
			
restore		
		
		
		

did_multiplegt jobscount /*
			*/ NPNAME1_  /*
			*/ year /*
			*/ post_CL_classif /*
			*/, average_effect  robust_dynamic breps(100) /*
			*/ controls(log_pop num_ISPs ) /*
			*/ placebo(4) dynamic(4) /*
			*/ cluster(CL_area_) save_results("$base_results/Figures/Figure_5a_2.dta")

	
preserve
			use "$base_results/Figures/Figure_5a_2.dta", clear
			
			eclplot treatment_effect treatment_effect_lower_95CI treatment_effect_upper_95CI time_to_treatment,  /*
		*/  yline(0, lcolor(gs12) lpattern(dash))  /*
		*/  eplottype(scatter) ciopts(color(navy*0.5) lwidth(medthick))   /*
		*/  yline(0, lcolor(grey*0.4) lpattern(dash) lwidth(medthick))  /*
		*/  xline(-0.5, lcolor(red*0.4) lwidth(medthick) ) /*
		*/  legend(off)  graphregion(fcolor(white)) /*
		*/  xtitle("Years Pre/Post CL") ytitle(" ") /*
		*/  xsize(1.2) ysize(1) /* 
		*/  xlabel(-5(1)4) ylabel(-5(1)3)
			graph export "$base_results/Figures/Figure_5a_2.pdf",  replace	

		cap erase "$base_results/Figures/Figure_5a_2.dta"	
			
restore		
	
	
	
	

*** Circulation per capita	
	

did_multiplegt circ /*
			*/ NPNAME1_  /*
			*/ year /*
			*/ post_CL_ /*
			*/, average_effect  robust_dynamic breps(100) /*
			*/ controls(log_pop num_ISPs ) /*
			*/ placebo(4) dynamic(4) /*
			*/ cluster(CL_area_) save_results("$base_results/Figures/Figure_5b_1.dta")

	
preserve
			use "$base_results/Figures/Figure_5b_1.dta", clear
			
			eclplot treatment_effect treatment_effect_lower_95CI treatment_effect_upper_95CI time_to_treatment,  /*
		*/  yline(0, lcolor(gs12) lpattern(dash))  /*
		*/  eplottype(scatter) ciopts(color(navy*0.5) lwidth(medthick))   /*
		*/  yline(0, lcolor(grey*0.4) lpattern(dash) lwidth(medthick))  /*
		*/  xline(-0.5, lcolor(red*0.4) lwidth(medthick) ) /*
		*/  legend(off)  graphregion(fcolor(white)) /*
		*/  xtitle("Years Pre/Post CL") ytitle(" ") /*
		*/  xsize(1.2) ysize(1) /* 
		*/  xlabel(-5(1)4)  ylabel(-0.02(0.005)0.01)
			graph export "$base_results/Figures/Figure_5b_1.pdf",  replace	

		cap erase "$base_results/Figures/Figure_5b_1.dta"	
			
restore		
		
		

did_multiplegt circ /*
			*/ NPNAME1_  /*
			*/ year /*
			*/ post_CL_classif /*
			*/, average_effect  robust_dynamic breps(100) /*
			*/ controls(log_pop num_ISPs ) /*
			*/ placebo(4) dynamic(4) /*
			*/ cluster(CL_area_) save_results("$base_results/Figures/Figure_5b_2.dta")

	
preserve
			use "$base_results/Figures/Figure_5b_2.dta", clear
			
			eclplot treatment_effect treatment_effect_lower_95CI treatment_effect_upper_95CI time_to_treatment,  /*
		*/  yline(0, lcolor(gs12) lpattern(dash))  /*
		*/  eplottype(scatter) ciopts(color(navy*0.5) lwidth(medthick))   /*
		*/  yline(0, lcolor(grey*0.4) lpattern(dash) lwidth(medthick))  /*
		*/  xline(-0.5, lcolor(red*0.4) lwidth(medthick) ) /*
		*/  legend(off)  graphregion(fcolor(white)) /*
		*/  xtitle("Years Pre/Post CL") ytitle(" ") /*
		*/  xsize(1.2) ysize(1) /* 
		*/  xlabel(-5(1)4) ylabel(-0.02(0.005)0.01)
			graph export "$base_results/Figures/Figure_5b_2.pdf",  replace	

		cap erase "$base_results/Figures/Figure_5b_2.dta"	
			
restore		
	
	
	
	
*** Politics coverage, topic weight		
		
		
did_multiplegt ihs_congress_name_mentions /*
			*/ NPNAME1_  /*
			*/ year /*
			*/ post_CL_ /*
			*/, average_effect  robust_dynamic breps(100) /*
			*/ controls(ihs_total_articles log_pop num_ISPs ) /*
			*/ placebo(4) dynamic(4) /*
			*/ cluster(CL_area_) save_results("$base_results/Figures/Figure_5c_1.dta")

	
preserve
			use "$base_results/Figures/Figure_5c_1.dta", clear
			
			eclplot treatment_effect treatment_effect_lower_95CI treatment_effect_upper_95CI time_to_treatment,  /*
		*/  yline(0, lcolor(gs12) lpattern(dash))  /*
		*/  eplottype(scatter) ciopts(color(navy*0.5) lwidth(medthick))   /*
		*/  yline(0, lcolor(grey*0.4) lpattern(dash) lwidth(medthick))  /*
		*/  xline(-0.5, lcolor(red*0.4) lwidth(medthick) ) /*
		*/  legend(off)  graphregion(fcolor(white)) /*
		*/  xtitle("Years Pre/Post CL") ytitle(" ") /*
		*/  xsize(1.2) ysize(1) /* 
		*/  xlabel(-5(1)4) xlabel(-0.3(0.1)0.2) 
			graph export "$base_results/Figures/Figure_5c_1.pdf",  replace	

		cap erase "$base_results/Figures/Figure_5c_1.dta"	
			
restore		
			
		
	

did_multiplegt ihs_congress_name_mentions /*
			*/ NPNAME1_  /*
			*/ year /*
			*/ post_CL_classif /*
			*/, average_effect  robust_dynamic breps(100) /*
			*/ controls(ihs_total_articles log_pop num_ISPs ) /*
			*/ placebo(4) dynamic(4) /*
			*/ cluster(CL_area_) save_results("$base_results/Figures/Figure_5c_2.dta")

	
preserve
			use "$base_results/Figures/Figure_5c_2.dta", clear
			
			eclplot treatment_effect treatment_effect_lower_95CI treatment_effect_upper_95CI time_to_treatment,  /*
		*/  yline(0, lcolor(gs12) lpattern(dash))  /*
		*/  eplottype(scatter) ciopts(color(navy*0.5) lwidth(medthick))   /*
		*/  yline(0, lcolor(grey*0.4) lpattern(dash) lwidth(medthick))  /*
		*/  xline(-0.5, lcolor(red*0.4) lwidth(medthick) ) /*
		*/  legend(off)  graphregion(fcolor(white)) /*
		*/  xtitle("Years Pre/Post CL") ytitle(" ") /*
		*/  xsize(1.2) ysize(1) /* 
		*/  xlabel(-5(1)4) xlabel(-0.3(0.1)0.2) 
			graph export "$base_results/Figures/Figure_5c_2.pdf",  replace	

		cap erase "$base_results/Figures/Figure_5c_2.dta"	
			
restore		





*** Congress coverage, names count (ihs)			
		
did_multiplegt ihs_congress_name_mentions /*
			*/ NPNAME1_  /*
			*/ year /*
			*/ post_CL_ /*
			*/, average_effect  robust_dynamic breps(100) /*
			*/ controls(ihs_total_articles log_pop num_ISPs ) /*
			*/ placebo(4) dynamic(4) /*
			*/ cluster(CL_area_) save_results("$base_results/Figures/Figure_5d_1.dta")

	
preserve
			use "$base_results/Figures/Figure_5d_1.dta", clear
			
			eclplot treatment_effect treatment_effect_lower_95CI treatment_effect_upper_95CI time_to_treatment,  /*
		*/  yline(0, lcolor(gs12) lpattern(dash))  /*
		*/  eplottype(scatter) ciopts(color(navy*0.5) lwidth(medthick))   /*
		*/  yline(0, lcolor(grey*0.4) lpattern(dash) lwidth(medthick))  /*
		*/  xline(-0.5, lcolor(red*0.4) lwidth(medthick) ) /*
		*/  legend(off)  graphregion(fcolor(white)) /*
		*/  xtitle("Years Pre/Post CL") ytitle(" ") /*
		*/  xsize(1.2) ysize(1) /* 
		*/  xlabel(-5(1)4) 
			graph export "$base_results/Figures/Figure_5d_1.pdf",  replace	

		cap erase "$base_results/Figures/Figure_5d_1.dta"	
			
restore		
			
		

did_multiplegt ihs_congress_name_mentions /*
			*/ NPNAME1_  /*
			*/ year /*
			*/ post_CL_classif /*
			*/, average_effect  robust_dynamic breps(100) /*
			*/ controls(ihs_total_articles log_pop num_ISPs ) /*
			*/ placebo(4) dynamic(4) /*
			*/ cluster(CL_area_) save_results("$base_results/Figures/Figure_5d_2.dta")

	
preserve
			use "$base_results/Figures/Figure_5d_2.dta", clear
			
			eclplot treatment_effect treatment_effect_lower_95CI treatment_effect_upper_95CI time_to_treatment,  /*
		*/  yline(0, lcolor(gs12) lpattern(dash))  /*
		*/  eplottype(scatter) ciopts(color(navy*0.5) lwidth(medthick))   /*
		*/  yline(0, lcolor(grey*0.4) lpattern(dash) lwidth(medthick))  /*
		*/  xline(-0.5, lcolor(red*0.4) lwidth(medthick) ) /*
		*/  legend(off)  graphregion(fcolor(white)) /*
		*/  xtitle("Years Pre/Post CL") ytitle(" ") /*
		*/  xsize(1.2) ysize(1) /* 
		*/  xlabel(-5(1)4)  
			graph export "$base_results/Figures/Figure_5d_2.pdf",  replace	

		cap erase "$base_results/Figures/Figure_5d_2.dta"	
			
restore		
	

	
	
	

