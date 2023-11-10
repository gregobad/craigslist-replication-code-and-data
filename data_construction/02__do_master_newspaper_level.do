
global base   = "C:\Users\mdjou\OneDrive\Desktop\craigslist-replication-code-and-data"

clear all
set more off


***********************************

** Start with E&P dataset 

use "$base\data\E&P\EP_panel_1995_2010", clear



		
	** Merge in master dataset

	merge m:1 fips year using "$base\data\master_data_county_level"
	
	drop if _merge==2
	   drop _merge
	   
			
			
			
			**** Generate interaction of post-CL with classified manager
			
				  gen post_CL_classif = post_CL_ * classif_2000
			label var post_CL_classif "Post-CL $\times$ Classified Mgr."
		
			
			**** Years post-CL
			
				  gen years_CL_classif = years_CL_ * classif_2000
			
			label var years_CL_ "Years post-CL"
			label var years_CL_classif "Years post-CL $\times$ Classified Mgr."
			
			
	save $base\data\master_data_newspaper_level, replace

		
	**** Merge in politician's name counts	
					
						
			import delimited using $base\data\Newspapers_content\Newsbank_article_counts\all_nb_counts_yearly.csv, clear
			rename ep_std_name NPNAME1


			
			**** Content variables

						
			gen congress_name_mentions   = article_count_anycongress_in_sta
			
			gen congress_mentions        =	article_count_congress	
		
			gen president_mentions       =  article_count_pres
			
			gen congressleaders_mentions = article_count_partyleaders
			
			gen local_mentions           = article_count_local_title
			
			gen congress_prim_mentions   = article_count_cong_primary
			
			
			gen cong_incumbent_mentions  = article_count_incumbent_in_stat
			gen cong_challenger_mentions = article_count_challenger_in_stat
			gen cong_primary_mentions    = article_count_primary_in_state
			gen cong_general_mentions    = article_count_general_in_state
			gen cong_sen_mentions        = article_count_sen_in_state
			gen cong_house_mentions      = article_count_rep_in_state
			
			
			gen accountability_mentions =  article_count_accountability_wor
			
			
			foreach var in congress_name_mentions /*
						*/ congress_mentions /*
						*/ congress_prim_mentions /*
						*/ president_mentions /*
						*/ congressleaders_mentions /*
						*/ local_mentions /*
						*/ cong_incumbent_mentions /*
						*/ cong_challenger_mentions /*
						*/ cong_primary_mentions /*
						*/ cong_general_mentions /*
						*/ cong_sen_mentions /*
						*/ cong_house_mentions /*
						*/ accountability_mentions {
						
						gen ihs_`var' = asinh(`var')
							
						}
			
			gen ihs_total_articles = asinh(total_articles_mentionsections)
				
			keep NPNAME1 year *_mentions total_articles ihs_total_articles 		

			merge 1:1 NPNAME1 year using $base\data\master_data_newspaper_level

				drop if _merge == 1
				   drop _merge

	save $base\data\master_data_newspaper_level, replace
	

	
	
	**** Topics
	
	import excel using $base\data\Newspapers_content\Topic_Model\avg_topic_prob_unanchored_by_newspaper_year.xlsx, clear first


			drop if inlist(_n, 1,2)

					
					forval n = 0/4 {

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


			save $base/data/master_data_newspaper_level, replace
			
			
			
			**** Label variables	
				
			label var ihs_congress_mentions "\shortstack{Coverage of Congress Reps\\ (IHS)}"	
		
			label var topic0 "Sports"
			label var topic1 "Obituaries"
			label var topic2 "Politics"
			label var topic3 "Crime"
			label var topic4 "Entertainment"
				
	
			save $base/data/master_data_newspaper_level, replace
			
		