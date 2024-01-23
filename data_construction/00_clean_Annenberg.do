set more off


** Directories
global base0 "C:\Users\\`c(username)'\OneDrive\Desktop\craigslist-replication-code-and-data"
global base  "C:\Users\\`c(username)'\OneDrive\Desktop\craigslist-replication-code-and-data\annenberg"






** 2000

use "$base/2000/naes_2000_nat_cs_19991214_20000403_data.dta", clear

append using "$base/2000/naes_2000_nat_cs_20000404_20000717_data.dta"
append using "$base/2000/naes_2000_nat_cs_20000718_20000904_data.dta"
append using "$base/2000/naes_2000_nat_cs_20000905_20001002_data.dta"
append using "$base/2000/naes_2000_nat_cs_20001003_20001106_data.dta"
append using "$base/2000/naes_2000_nat_cs_20001108_20010119_data.dta"

drop cu01 cw32 cw33*

merge 1:1 ckey using "$base/2000/NAES00_mapping_zip.dta"

gen year=2000

*senator name
      gen recall_senator=1 if cu22_1==97 | cu22_1==998 | cu22_2==97 | cu22_2==998
  replace recall_senator=0 if recall_senator!=1 & cu22_1!=. | recall_senator!=1 & cu22_2!=. 
label var recall "=1 if don't know or incorrect name of at least one Senator"

*intended vote
    gen intended_general=1 if cr30==2
replace intended_general=0 if intended_general!=1 & cr30!=.

    gen intended_house=1 if cu14==4
replace intended_house=0 if intended_house!=1 & cu14

    gen intended_senate=1 if cu27==4
replace intended_senate=0 if intended_senate!=1 & cu27!=.

label var intended_general	"=1 if does not intend to vote - GENERAL ELECTION"
label var intended_house	"=1 if does not intend to vote - US HOUSE"
label var intended_senate	"=1 if does not intend to vote - US SENATE"

* Internet Access

recode ce20 998/999 = . 2=0
la define yn 0 "no" 1 "yes"
la values ce20 yn
la var ce20 "=1 if has access to Internet at home or workplace"

* Voted in general election
recode cr34 998/999 = . 2=0
la values cr34 yn
la var cr34 "=1 if voted in general election"

*Party majority Congress --> Evenly divided (cs84)

*Interviewer rating
rename cy06 knowledge_rating
label var knowledge "Interviewer's rating on political knowledge (A, excellent; B, good; C, average; D,poor; F, very poor)"

*Variables for coverage analysis:
global vars00 "cr04	cr15 cr34 cr46 cr47	cr48 cr49 cr50 cr51	cv01 cv02 cv03 cv04	cba05 cba06	ce01 ce02 ce05 ce06	ce09 ce13 ce14 ce17	ce18 ce23 ck03	ck05	ck09	ck13	ck14	ck15	ck16	ck17	ck18	ck19	ck20	ck21	ck22	ck23	ck24	ck25	ck26	ck27"
**univar $vars00
**des $vars00

*Pre-selection:
 keep year ckey cu01 cw32 cr04 cr15 cv01 cv02 cv03 cv04 cba05 cba06 ce01	ce02 ce06 ce13 ce14	ce18 ce20 ck05 ck09  cr34  cw01	cw02	cw03	cw06	cw07	cw08	cw09	cw12	cw13	cw14	cw18	cw24	cw26 cw28	recall intended* knowledge
order year ckey cu01 cw32 cr04 cr15 cv01 cv02 cv03 cv04 cba05 cba06 ce01	ce02 ce06 ce13 ce14	ce18 ce20 ck05 ck09  cr34 cw01	cw02	cw03	cw06	cw07	cw08	cw09	cw12	cw13	cw14	cw18	cw24 cw26	cw28 recall intended* knowledge	

rename cu01	district_id 
rename cw32 zipcode

rename  cr04 registered
rename  cr15 voted_primary
rename  cv01 party_id
rename  cv02 party_strength
rename  cv03 party_lean
rename  cv04 conservative_liberal
rename  ce01 watched_network
rename  ce02 watched_cable
rename  ce06 watched_local_tv
rename  ce13 read_newspaper
rename  ce14 read_most
rename  ce18 listened_radio
rename  ck05 discuss_politics_fam
rename  ck09 discuss_politics_work
rename	ce20 internet_access
rename	cr34 voted_general_election

*demogrpahic controls: cw*

save "$base/annenberg2000_select", replace // 58,373 respondents.


** 2004

use "$base/2004/DataNRCS.dta", clear

merge 1:1 ckey using "$base/2004/NAES04_mapping_zip.dta"

*senator name
      gen recall_senator=1 if cua02!=1 & cua02!=.
  replace recall_senator=0 if recall_senator!=1 & cua02!=.
label var recall "=1 if don't know or incorrect name of at least one Senator"

*intended vote
      gen intended_general=1 if crc01==2
  replace intended_general=0 if intended_general!=1 & crc01!=.
label var intended_general	"=1 if does not intend to vote - GENERAL ELECTION"

*Party majority Congress
      gen congress_control=1 if cmc07!=2 & cmc07!=.
  replace congress_control=0 if congress_control!=1 & cmc07!=.
label var congress "=1 if does not know party with Congress majority (House)"

*Interviewer rating
rename cya06 knowledge_rating
label var knowledge "Interviewer's rating on political knowledge (A, excellent; B, good; C, average; D,poor; F, very poor)"

*job approval
    gen congress_approval_rep=1 if cae01==998 | cae01==999  
replace congress_approval_rep=0 if congress_approval_rep!=1 & cae01!=.

    gen congress_approval_dem=1 if cae02==998 | cae02==999
replace congress_approval_dem=0 if congress_approval_dem!=1 & cae02!=.

label var congress_approval_rep "=1 if does not provide job approval rating - Congress REPUBLICANS"
label var congress_approval_dem "=1 if does not provide job approval rating - Congress DEMOCRATS"

*veto
      gen override_veto=1 if cmc05!=1 & cmc05!=.
  replace override_veto=0 if override_veto!=1 & cmc05!=.
label var override "=1 if does not know congress majority required to override presidential veto"

* Voted in general election
recode crc28 998/999 = . 2=0
la values crc28 yn
la var crc28 "=1 if voted in general election"

* Internet Access

recode cea21 998/999 = . 2=0
la define yn 0 "no" 1 "yes"
la values cea21 yn
la var cea21 "=1 if has access to Internet at home or workplace"

* Discussed politics online

recode ckb05 998/999 = . 
la var ckb05 "How many days discussed politics online the past week?"
g discussed_online = 0 if ckb05 == 0
replace discussed_online = 1 if ckb05 >=1
la var discussed_online "=1 if discussed politics online in the past week"

* Selection:
preserve
 des ckey cUA01 cWF11 cWF12 cdate cae15 cae06 cae07 cae09 cae11 cae12 cae13 cae14 cwe01 cca07 crc28 cwa02 cwa01 cwa03 cwc03 cwa04 cwb01 cwc05 cwc06 cwd02 cwe01 cwf07 cwf01 cwg01-cwg05 
keep ckey cUA01 cWF11 cWF12 cdate cae15 cae06 cae07 cae09 cae11 cae12 cae13 cae14 cwe01 cca07 crc28 cwa02 cwa01 cwa03 cwc03 cwa04 cwb01 cwc05 cwc06 cwd02 cwe01 cwf07 cwf01 cwg01-cwg05 recall intended congress_c knowledge congress_approval* override
save "$base/annenberg2004_select", replace
restore

gen year=2004

*Variables for coverage analysis:
global vars04 "cra01	crb11	crc28		cre15	cre16	cre08	cre07	cre05	cre01	cre06	cma01	cma02	cma03	cma06	ccb01	ccb02	ccb03	ccb04	ccb05	cea01	cea03	cea05	cea06	cea07	cea10	cea11	cea13	cea14	cea15	cea22	cea23	cka05	ckb01	ckb03	ckc02	ckc03	ckc04	ckc05	ckc07"
**univar $vars04
**des $vars04 

*Pre-selection:
keep year ckey discussed_online cUA01 cWF11 cra01	crb11 crc28	cma01	cma02	cma03	cma06	ccb01	ccb02	ccb03	ccb04	ccb05	cea01	cea03	cea06	cea10	cea11	cea14	cea15 cea21	ckb01	ckb03 ckb05 cwa01 cwa02 cwc03 cwa03 cwc05 cwf07 cwb01 cwb04 cwb05 cwd02 cwc07 cwf13 cwa04 cwf01 recall intended congress_c knowledge congress_approval* override

order year ckey discussed_online cUA01 cWF11 cra01	crb11 crc28	cma01	cma02	cma03	cma06	ccb01	ccb02	ccb03	ccb04	ccb05	cea01	cea03	cea06	cea10	cea11	cea14	cea15 cea21	ckb01	ckb03  ckb05 cwa01 cwa02 cwc03 cwa03 cwc05 cwf07 cwb01 cwb04 cwb05 cwd02 cwc07 cwf13 cwa04 cwf01 recall intended congress_c knowledge congress_approval* override

rename cUA01 district_id
rename cWF11 zipcode

rename  cra01 registered
rename  crb11 voted_primary
rename  cma01 party_id
rename  cma02 party_strength
rename  cma03 party_lean
rename  cma06 conservative_liberal

    gen us_eco_better=1 if ccb02<=2 
replace us_eco_better=0 if ccb02!=. & us!=1

    gen pers_eco_better=1 if ccb05<=2 
replace pers_eco_better=0 if ccb05!=. & pers!=1

rename  cea01 watched_network
rename  cea03 watched_cable
rename  cea06 watched_local_tv
rename  cea10 read_newspaper
rename  cea11 read_most
rename	cea21 internet_access
rename	crc28 voted_general_election

gen listened_radio=cea15
replace listened_radio=. if cea15==998 | cea15==999

rename  ckb01 discuss_politics_fam
rename  ckb03 discuss_politics_work
rename	ckb05 discuss_politics_online

label var us_eco_better		"=1 if Economic conditions in US were better last year"
label var pers_eco_better 	"=1 if Personal economic conditions were better last year"
label var listened_radio	"Listened Talk Radio last week (days)"

*demographic controls
rename  cwa01 cw01
rename  cwa02 cw02
rename  cwc03 cw03
rename  cwa03 cw06
rename  cwc05 cw07
rename  cwf07 cw08
rename  cwb01 cw09
rename  cwb04 cw12
rename  cwd02 cw14
rename  cwc07 cw18
rename  cwf13 cw24
rename  cwa04 cw28
rename  cwf01 cw26

save "$base/annenberg2004_select", replace // 81,422 respondents.


*Note for the whole US: ZIP to counties crosswalk
*Source: http://mcdc.missouri.edu/applications/geocorr2014.html
*import delimited "$original/zip to counties/zip_to_counties.csv", clear
/*
                         |        Observations
                         |      total   distinct
-------------------------+----------------------
 zipcensustabulationarea |      44139      32846
              countycode |      44139       3143
*/

** 2008

use "$base/2008/naes08_phone_nat_rcs_data_full.dta", clear

merge 1:1 rkey using "$base/2008/NAES08_mapping_zip.dta"

gen year=2008

*senator name
*No info

*intended vote
      gen intended_general=1 if rca01_c==2
  replace intended_general=0 if intended_general!=1 & rca01_c!=.
label var intended_general	"=1 if does not intend to vote - GENERAL ELECTION"

*Party majority Congress
      gen congress_control=1 if mc03_c!=1 & mc03_c!=.
  replace congress_control=0 if congress_control!=1 & mc03_c!=.
label var congress "=1 if does not know party with Congress majority (House)"

*job approval
      gen congress_approval=1 if ae03_c==998 | ae03_c==999  
  replace congress_approval=0 if congress_approval!=1 & ae03_c!=.
label var congress_approval "=1 if does not provide job approval rating - Congress"

*veto
      gen override_veto=1 if mc02_c!=1 & mc02_c!=.
  replace override_veto=0 if override_veto!=1 & mc02_c!=.
label var override "=1 if does not know congress majority required to override presidential veto"

* Internet Access

recode wg01_c 998/999 = . 2=0
la define yn 0 "no" 1 "yes"
la values wg01_c yn
la var wg01_c "=1 if has access to Internet at home or workplace"

* Voted in general election
recode rcb02_c 998/999 = . 2=1
la values rcb02_c yn
la var rcb02_c "=1 if voted in general election"

* discussed online
g discussed_online = 0 if kg18_c ==0 | kg19_c == 0 | kg20_c==0
replace discussed_online = 1 if kg18_c ==1 | kg19_c == 1 | kg20_c==1
la var discussed_online "=1 if discussed politics online in the past week"


*Variables for coverage analysis:
global vars08 "ra01_c	rbb02_c	rcb03_c	rcb04_c	ma01_c	ma02_c	ma03_c	ma04_c	cba01_c			cba02_c			eb02_c	eb03_c				ed01_c	ed02_c		ec01_c	ec02_c	ee02_c	ee03_c	kb03_c	kb04_c	kb05_c	kb06_c	kb07_c	kf01_c	kf03_c	kf04_c	ke01_c	ke02_c		kd01_c	kd02_c	kd04_c	kd05_c	kf07_c	kf10_c"
**univar $vars08
**des $vars08

 keep year rkey district discussed_online wfc06 ra01_c rbb02_c	ma01_c	ma02_c	ma03_c	ma04_c	cba01_c	cba02_c	eb03_c	ed02_c	ec01_c	ec02_c  ed01_c ed02_c  rcb02_c     wa01_c	wa02_c	wc03_c	wa03_c	wc05_c	wfa03_c	wb01_c	wb04_c	wd01_c	wfb01_c wfc02_c wa04_c	wa05_c	wfa01_c wg01_c intended congress_control congress_approval override_veto

order year rkey district discussed_online wfc06 ra01_c rbb02_c	ma01_c	ma02_c	ma03_c	ma04_c	cba01_c	cba02_c	eb03_c	ed02_c	ec01_c	ec02_c    rcb02_c    wa01_c	wa02_c	wc03_c	wa03_c	wc05_c	wfa03_c	wb01_c	wb04_c	wd01_c	wfb01_c	wfc02_c wa04_c	wa05_c	wfa01_c wg01_c intended congress_control congress_approval override_veto


rename rkey ckey
rename district district_id
rename wfc06 zipcode

rename  ra01_c registered
rename  rbb02_c voted_primary
rename  ma01_c party_id
rename  ma02_c party_strength
rename  ma03_c party_lean
rename  ma04_c conservative_liberal

gen us_eco_better=1 if cba01_c>=4 & cba01_c<998 
replace us_eco_better=0 if cba01_c!=. & us!=1

gen pers_eco_better=1 if cba02_c>=4 & cba02_c<998
replace pers_eco_better=0 if cba02_c!=. & pers!=1

replace ec01_c=. if ec01_c==998 | ec01_c==999
rename ec01_c listened_radio



rename	wg01_c internet_access
rename rcb02_c voted_general_election


label var us_eco_better		"=1 if Economic conditions in US were better last year"
label var pers_eco_better 	"=1 if Personal economic conditions were better last year"

*demographic controls
rename  wa01_c cw01
rename  wa02_c cw02
rename  wc03_c cw03
rename  wa03_c cw06
rename  wc05_c cw07
rename  wfa03_c cw08
rename  wb01_c cw09
rename  wb04_c cw12
rename  wd01_c cw14
rename  wfb01_c cw18
rename  wfc02_c  cw24
rename  wa04_c cw28
rename  wa05_c cw28b
rename  wfa01_c cw26


*** media Qs only regarding campaign info


save "$base/annenberg2008_select", replace // 57,967 respondents.




use "$base/annenberg2000_select", clear
append using "$base/annenberg2004_select"
append using "$base/annenberg2008_select"

drop cba* ccb* cea* eb* ec*

save "$base/annenberg2000-2004-2008_select", replace


**

rename zipcode zip

local vars watched_network watched_cable watched_local_tv read_newspaper listened_radio /*
	*/ discuss_politics_fam discuss_politics_work 

recode `vars' (998=.)(999=.)



**** respondent characteristics

recode cw* (998=.)(999=.)

    gen resp_college = 0 if cw06!=.
replace resp_college = 1 if cw06>=6 & cw06!=.

recode cw01 (1=1)(2=0)


rename cw01 resp_sex
rename cw02 resp_age

recode cw03 (4=4)(5=4)(6=4)(7=4) /*"other category"*/

qui tab cw03, gen(resp_race)



**** code readership of national newspapers as 0
**** new york times, usa today, wall street journal



    gen read_newspaper_type = 0 if read_newspaper == 0
replace read_newspaper_type = 1 if inlist(read_most, 17, 29, 30) 


replace read_newspaper_type = 2 if read_newspaper!=. & read_newspaper_type!=0 & read_newspaper_type!=1
replace read_newspaper_type = . if read_most == . & read_newspaper!=0



    gen read_newspaper_national = 0 if read_newspaper!=.
replace read_newspaper_national = read_newspaper if read_newspaper_type==1


    replace read_newspaper = 0 if read_newspaper_type==1



save "$base/annenberg2000-2004-2008_select", replace


cap erase "$base/annenberg2000_select.dta"
cap erase "$base/annenberg2004_select.dta"
cap erase "$base/annenberg2008_select.dta"



**** inferring county from zip-code of the respondent


	import delimited "$base0/data/_zipcode/zipcode.csv", clear 
					
					keep zip city latitude longitude
					
					merge 1:m zip using "$base/annenberg2000-2004-2008_select"
						
					*** drop a zip-codes with no newspaper match
					
					drop if _merge==1
					   drop _merge
					
					drop if zip == .

					
					****now matching latitude and longitude to counties 
					
					rename   longitude _X
					rename   latitude  _Y

					geoinpoly _Y _X using "$base0/data/_co99_d00_shp/coor.dta"
					merge m:1 _ID   using "$base0/data/_co99_d00_shp/data.dta"
								
					drop if _merge==2  /*drop any counties that do not match a newspaper zip code*/
					   drop _merge

		
					gen fips = STATE + COUNTY
						destring fips, replace


					rename NAME county 
						
	save "$base/annenberg2000-2004-2008_select", replace
	
	
