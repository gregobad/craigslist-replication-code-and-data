global base         = "C:\Users\mdjou\OneDrive\Desktop\craigslist-replication-code-and-data"
global base_results = "C:\Users\mdjou\OneDrive\Desktop\craigslist-replication-code-and-data\Results"

clear all
set more off




	

********************************************************************************
**** FIGURE A1: SPLIT-TICKET VOTING – EVENT STUDY


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

	recode post_CL_classif (0/0.5=0)(0.5/1=1)
	
		
	
**** Duplicate data to pool House and Senate elections
	
expand 2, gen(exp)
	
 
    gen split_vote = house_dev if exp==0
replace split_vote = sen_dev   if exp==1



	gen turnout_congress = turnout_house if exp==0
replace turnout_congress = turnout_sen   if exp==1

	

label var split_vote   "\shortstack{Split ticket \\ (House/Senate-President)}"
label var turnout_congress  "\shortstack{Turnout \\ House/Senate elections}"

	
	gen exp_year = string(year) + string(exp)
	
	encode exp_year, gen(exp_year_)
	
	
	

did_multiplegt split_vote /*
			*/ fips  /*
			*/ year /*
			*/ post_CL_classif /*
			*/, trends_nonparam(exp_year_) weight(voting_pop_)   robust_dynamic breps(100) /*
			*/ controls(log_pop num_ISPs ) /*
			*/ placebo(2) dynamic(1) /*
			*/ cluster(CL_area_) save_results("$base_results/Appendix_Figures/Figure_A1.dta")

			
			
			
preserve
			use "$base_results/Appendix_Figures/Figure_A1.dta", clear
			
			eclplot treatment_effect treatment_effect_lower_95CI treatment_effect_upper_95CI time_to_treatment,  /*
		*/  yline(0, lcolor(gs12) lpattern(dash))  /*
		*/  eplottype(scatter) ciopts(color(navy*0.5) lwidth(medthick))   /*
		*/  yline(0, lcolor(grey*0.4) lpattern(dash) lwidth(medthick))  /*
		*/  xline(-0.5, lcolor(red*0.4) lwidth(medthick) ) /*
		*/  legend(off)  graphregion(fcolor(white)) /*
		*/  xtitle("Election cycles Pre/Post CL") ytitle(" ") /*
		*/  xsize(1.2) ysize(1) 
			graph export "$base_results/Appendix_Figures/Figure_A1.pdf",  replace	

		cap erase "$base_results/Appendix_Figures/Figure_A1.dta"	
			
restore		
		

	



******************************************************************************
**** FIGURE A2: ENTRY AND PERFORMANCE OF EXTREMIST CANDIDATES – EVENT STUDIES

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
	
	encode state_dist, gen(state_dist_)
	
	est clear
	
	
	
	recode post_CL_classif (0/0.5=0)(0.5/1=1)
	
	
	

	
*** EXTREMIST IN PRIMARY ELECTION	
	

did_multiplegt extremist_in_eitherpri /*
			*/ fips  /*
			*/ year /*
			*/ post_CL_classif /*
			*/, trends_nonparam(district_code) weight(w_cty_dist) average_effect  robust_dynamic breps(100) /*
			*/ controls(log_pop num_ISPs) /*
			*/ placebo(3) dynamic(2) /*
			*/ cluster(state_dist_) save_results("$base_results/Appendix_Figures/Figure_A2_a.dta")

			
			
			
preserve
			use "$base_results/Appendix_Figures/Figure_A2_a.dta", clear
			
			eclplot treatment_effect treatment_effect_lower_95CI treatment_effect_upper_95CI time_to_treatment,  /*
		*/  yline(0, lcolor(gs12) lpattern(dash))  /*
		*/  eplottype(scatter) ciopts(color(navy*0.5) lwidth(medthick))   /*
		*/  yline(0, lcolor(grey*0.4) lpattern(dash) lwidth(medthick))  /*
		*/  xline(-0.5, lcolor(red*0.4) lwidth(medthick) ) /*
		*/  legend(off)  graphregion(fcolor(white)) /*
		*/  xtitle("Election cycles Pre/Post CL") ytitle(" ") /*
		*/  xsize(1.2) ysize(1) /* 
		*/  xlabel(-4(1)2)
			graph export "$base_results/Appendix_Figures/Figure_A2_a.pdf",  replace	

		cap erase "$base_results/Appendix_Figures/Figure_A2_a.dta"	
			
restore		
		

	
	
	
*** EXTREMIST IN GENERAL ELECTION

	
did_multiplegt extremist_in_general /*
			*/ fips  /*
			*/ year /*
			*/ post_CL_classif /*
			*/, trends_nonparam(district_code) weight(w_cty_dist) average_effect  robust_dynamic breps(100) /*
			*/ controls(log_pop num_ISPs) /*
			*/ placebo(3) dynamic(2) /*
			*/ cluster(state_dist_) save_results("$base_results/Appendix_Figures/Figure_A2_b.dta")

			
			
			
preserve
			use "$base_results/Appendix_Figures/Figure_A2_b.dta", clear
			
			eclplot treatment_effect treatment_effect_lower_95CI treatment_effect_upper_95CI time_to_treatment,  /*
		*/  yline(0, lcolor(gs12) lpattern(dash))  /*
		*/  eplottype(scatter) ciopts(color(navy*0.5) lwidth(medthick))   /*
		*/  yline(0, lcolor(grey*0.4) lpattern(dash) lwidth(medthick))  /*
		*/  xline(-0.5, lcolor(red*0.4) lwidth(medthick) ) /*
		*/  legend(off)  graphregion(fcolor(white)) /*
		*/  xtitle("Election cycles Pre/Post CL") ytitle(" ") /*
		*/  xsize(1.2) ysize(1) /* 
		*/  xlabel(-4(1)2)
			graph export "$base_results/Appendix_Figures/Figure_A2_b.pdf",  replace	

		cap erase "$base_results/Appendix_Figures/Figure_A2_b.dta"	
			
restore		
		
	

	
	
**** EXTREMIST WINS GENERAL ELECTION


did_multiplegt extremist_wins /*
			*/ fips  /*
			*/ year /*
			*/ post_CL_classif /*
			*/, trends_nonparam(district_code) weight(w_cty_dist) average_effect  robust_dynamic breps(100) /*
			*/ controls(log_pop num_ISPs) /*
			*/ placebo(3) dynamic(2) /*
			*/ cluster(state_dist_) save_results("$base_results/Appendix_Figures/Figure_A2_c.dta")

			
			
			
preserve
			use "$base_results/Appendix_Figures/Figure_A2_c.dta", clear
			
			eclplot treatment_effect treatment_effect_lower_95CI treatment_effect_upper_95CI time_to_treatment,  /*
		*/  yline(0, lcolor(gs12) lpattern(dash))  /*
		*/  eplottype(scatter) ciopts(color(navy*0.5) lwidth(medthick))   /*
		*/  yline(0, lcolor(grey*0.4) lpattern(dash) lwidth(medthick))  /*
		*/  xline(-0.5, lcolor(red*0.4) lwidth(medthick) ) /*
		*/  legend(off)  graphregion(fcolor(white)) /*
		*/  xtitle("Election cycles Pre/Post CL") ytitle(" ") /*
		*/  xsize(1.2) ysize(1) /* 
		*/  xlabel(-4(1)2)
			graph export "$base_results/Appendix_Figures/Figure_A2_c.pdf",  replace	

		cap erase "$base_results/Appendix_Figures/Figure_A2_c.dta"	
			
restore		
		
	
	
		
	 


	/*
	/*
	
**** FIGURE B4: NUMBER OF ISPS AND SELF-REPORTED INTERNET ACCESS



*** GfK-MRI


use "$base\data\GfK-MRI\gfk_full", clear   
   

   rename int_year year
   
   merge m:1 fips year using "$base/data/master_data_county_level", keepusing(num_ISPs)
   
   keep if _merge ==3
   
   
   label var num_ISPs "Num. ISPs"
   label var gfk_inet_access "Internet access"
   
   binscatterhist gfk_inet_access num_ISPs, coefficient(0.0001) sample xtitle("Num. Internet Service Providers", size(medlarge)) ytitle("Self reported Internet access", size(medlarge))
   
   
   graph export "$base_results/Appendix_Figures/Figure_B4_a.pdf",  replace
	 est clear			
		




*** NAES

use "$base\data\annenberg\annenberg2000-2004-2008_select", clear   

   
   merge m:1 fips year using "$base/data/master_data_county_level", keepusing(num_ISPs)
   
   keep if _merge ==3
   
   
   label var num_ISPs "Num. ISPs"
   label var internet_access "Internet access"
   
    binscatterhist internet_access num_ISPs, coefficient(0.0001) sample xtitle("Num. Internet Service Providers", size(medlarge)) ytitle("Self reported Internet access", size(medlarge))
   
    
   graph export "$base_results/Appendix_Figures/Figure_B4_b.pdf",  replace
	 est clear	
		
		
		*/
		*/
		
   


**** FIGURE B5: NEWSPAPER READERSHIP BY SECTION


   import delimited using $base/data/GfK-MRI/gfk_newspapersections_2001.csv, clear


   rename  v4 Business_Finance
   rename  v5 Classified
   rename  v6 Comics
   rename  v7 Editorial_Page 
   rename  v8 Fashion
   rename  v9 Food_Cooking
   rename  v10 General_News
   rename  v11 Home_Furnishing_Gardening
   rename  v12 Movie_Listings_Reviews
   rename  v13 Science_Technology
   rename  v14 Sports
   rename  v15 Travel
   rename  v16 TV_Radio_Listings
  
  drop respid wgtpop alldata
  
  collapse (mean) *

xpose, varname clear

replace _varname = "Business / Finance" if _varname == "Business_Finance"
replace _varname = "Editorial Page" if _varname == "Editorial_Page"
replace _varname = "Food / Cooking" if _varname == "Food_Cooking"
replace _varname = "General News"   if _varname == "General_News"
replace _varname = "Home / Furnishing / Gardening" if _varname == "Home_Furnishing_Gardening"
replace _varname = "Movie Listings / Reviews" if _varname == "Movie_Listings_Reviews"
replace _varname = "Science / Technology" if _varname == "Science_Technology"
replace _varname = "TV / Radio Listings" if _varname == "TV_Radio_Listings"

label var v1 "Share respondents reading section"


separate v1, by(inlist(_varname, "General News", "Classified" ))

graph hbar v10 v11, over(_varname, sort(v1) descending)  graphregion(fcolor(white)) nofill legend(off) title("Share respondents reading section", size(medlarge))

*** export graph

graph export "$base_results/Appendix_Figures/Figure_B5.pdf", replace	

