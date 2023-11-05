#### Use MRI data to predict propensity of reading classifieds given demographics ###
#### NOTE: first part relies on proprietary data from GfK-MRI, not included in archive

library(tidyverse)
library(data.table)
library(readxl)
library(haven)
library(stringi)
library(glmnet)
library(glue)

# change to location where archive was extracted
data_dir <- "~/craigslist-replication-code-and-data/data"
out_dir <- "~/craigslist-replication-code-and-data/output"

read_dtadt <- compose(as.data.table, read_dta)


## read data (proprietary, not included in archive)
sections99 <- fread(glue("{data_dir}/GfK-MRI/gfk1999_sections.csv"))
sections01 <- fread(glue("{data_dir}/GfK-MRI/gfk2001_sections.csv"))

rename_colgroup <- function(start, end, varlabel, cnames) {
    if(end > start) {
        cnames[(start+1):end] <- sub("\\[[0-9a-z&?!-]+\\]:", varlabel, cnames[(start+1):end])
    }

    gsub("\\W+", "_", sub("\\[[0-9a-z&?!-]+\\]: ", "", cnames[start:end]))
}


rename_cols <- function(cnames) {
    var_group_start <- grep("\\[[0-9a-z&?!-]+\\]: (.*): (.*)", cnames)
    var_group_label <- cnames[var_group_start]
    var_group_label <- sub("\\[[0-9a-z&?!-]+\\]: (.*): .*", "\\1", var_group_label)

    c(cnames[1:(var_group_start[1]-1)],
    pmap(list(start = var_group_start,
              end = c(var_group_start[2:length(var_group_start)]-1, length(cnames)),
              varlabel = var_group_label), rename_colgroup, cnames) %>% 
    reduce(c) %>% 
    tolower
    )
}

# Standardize col. names
colnames(sections99) <- rename_cols(colnames(sections99))
colnames(sections01) <- rename_cols(colnames(sections01))


## get overall readership of each section in 1999-2001
pre_reading <- rbind(sections99[,.SD, .SDcols = grep("daily_newspaper", colnames(sections99), value=T)],
                     sections01[,.SD, .SDcols = grep("daily_newspaper", colnames(sections01), value=T)])


sum(!is.na(pre_reading[,daily_newspaper_sections_read_or_looked_at_tv_radio_listings]))
# [1] 100519

with(pre_reading, table(newspapers_read_any_daily_newspaper, daily_newspaper_sections_read_or_looked_at_general_news))

pre_reading <- melt(pre_reading, variable.name="Section", value.name="Read") %>% 
    .[,Section:=sub("daily_newspaper_sections_read_or_looked_at_", "", Section)] %>% 
    .[Section!="newspapers_read_any_daily_newspaper",Section:=str_to_title(gsub("_", " ", Section))] %>% 
    .[Section!="newspapers_read_any_daily_newspaper",.(share= mean(Read)), by = .(Section)] %>% 
    .[order(share)]

pre_reading[Section=="Movie Listings Reviews", Section:="Movie Listings & Reviews"]
pre_reading[Section=="Home Furnishings Gardening", Section:="Home & Garden"]
pre_reading[Section=="Science Technology", Section:="Science & Technology"]
pre_reading[Section=="Business Finance", Section:="Business"]
pre_reading[Section=="Tv Radio Listings", Section:="TV & Radio Listings"]
pre_reading[Section=="Food Cooking", Section:="Food"]

pre_reading[,Section:=factor(Section, levels=Section)]

pre_reading[, highlight := if_else(Section %in% c("General News", "Classified"), "yes", "no")]

ggplot(aes(x = Section, y = share, fill = highlight), data = pre_reading) +
    theme_bw() +
    scale_fill_manual(values = c("yes" = "darkred", "no" = "steelblue")) +
    geom_bar(stat = "identity") +
    coord_flip() +
    theme(axis.title.y=element_blank(),
          axis.text.y=element_text(face="bold")) +
    guides(fill = FALSE) +
    labs(y="Share Respondents Reading Section")

## Figure B.5
ggsave(file = glue("{out_dir}/gfk_sections_read.png"), height = 6, width = 10)



## limit to cols appearing in 2003-2011 data so that we can project forward

forprediction03 <- fread(glue("{data_dir}/GfK-MRI/gfk2003_forprediction.csv"))
forprediction05 <- fread(glue("{data_dir}/GfK-MRI/gfk2005_forprediction.csv"))
forprediction07 <- fread(glue("{data_dir}/GfK-MRI/gfk2007_forprediction.csv"))
forprediction09 <- fread(glue("{data_dir}/GfK-MRI/gfk2009_forprediction.csv"))
forprediction11 <- fread(glue("{data_dir}/GfK-MRI/gfk2011_forprediction.csv"))

colnames(forprediction03) <- rename_cols(colnames(forprediction03))
colnames(forprediction05) <- rename_cols(colnames(forprediction05))
colnames(forprediction07) <- rename_cols(colnames(forprediction07))
colnames(forprediction09) <- rename_cols(colnames(forprediction09))
colnames(forprediction11) <- rename_cols(colnames(forprediction11))

# harmonize names of variables that changed over time
fixnames <- function(df, year) {
    # misc changes
    colnames(df) <- sub("hoh_highest_degree_received_", "hoh_highest_degree_received_new_census_question_", colnames(df))
    colnames(df) <- sub("hoh_job_title_other_foreman_supervisor_administrator_superintendent_", "hoh_job_title_other", colnames(df))
    colnames(df) <- sub("hoh_job_title_controller_chief_financial_officer_cfo_measured_as_comptroller_chief_financial_officer_in_waves_49_50_", "hoh_job_title_comptroller", colnames(df))

    colnames(df) <- sub("respondent_job_title_other","respondent_job_title_other_foreman_supervisor_administrator_superintendent_", colnames(df))
    colnames(df) <- sub("respondent_job_title_controller_chief_financial_officer_cfo_measured_as_comptroller_chief_financial_officer_in_waves_49_50_", "respondent_job_title_comptroller", colnames(df))
    
    colnames(df) <- sub("respondent_job_title_top_management_new_", "top_management_prof_l_managerial_with_iei_35_000_and_with_a_job_title_code_1_8_above", colnames(df))
    colnames(df) <- sub("respondent_job_function_area_of_responsibility_mis_is_it_networking_technology_measured_as_mis_edp_in_waves_49_50_","respondent_job_function_area_of_responsibility_mis_edp", colnames(df))
    colnames(df) <- sub("respondent_job_function_area_of_responsibility_manufacturing_production_operations_measured_as_manufacturing_in_waves_49_50_","respondent_job_function_area_of_responsibility_manufacturing", colnames(df))
    colnames(df) <- sub("respondent_job_function_area_of_responsibility_marketing_advertising_measured_as_marketing_in_waves_49_50_","respondent_job_function_area_of_responsibility_marketing", colnames(df))
    colnames(df) <- sub("race_black_african_american", "race_black", colnames(df))

    # occupations relabeled beginning in 2005
    if(year == 2005) {
        df[,respondent_occupation_executive_managerial_administrative := pmax(respondent_occupation_new_management_occupations,respondent_occupation_new_business_and_financial_operations_occupations)]      
        df[,respondent_occupation_professional_specialties := pmax(respondent_occupation_new_computer_and_mathematical_occupations, respondent_occupation_new_architecture_and_engineering_occupations, respondent_occupation_new_life_physical_and_social_science_occupations,respondent_occupation_new_legal_occupations,respondent_occupation_new_healthcare_practitioner_and_technical)]
        df[,respondent_occupation_technicians_related_support := pmax(respondent_occupation_new_healthcare_support_occupations)]
        df[,respondent_occupation_sales := respondent_occupation_new_sales_and_related_occupations]                      
        df[,respondent_occupation_administrative_support_including_clerical := pmax(respondent_occupation_new_office_and_administrative_support_occupations)]
        df[,respondent_occupation_private_household := pmax(respondent_occupation_new_personal_care_and_service_occupations)]          
        df[,respondent_occupation_protective_service := respondent_occupation_new_protective_service_occupations]         
        df[,respondent_occupation_service_except_protective_private_household := pmax(respondent_occupation_new_food_preparation_serving_related_occupations)]                          
        df[,respondent_occupation_farm_operators_and_managers := pmax(respondent_occupation_new_farming_fishing_and_forestry_occupations)]
        df[,respondent_occupation_forestry_logging_fishers_hunters_trappers := pmax(respondent_occupation_new_farming_fishing_and_forestry_occupations)]
        df[,respondent_occupation_mechanics_and_repairers := respondent_occupation_new_installation_maintenance_and_repair_occupations]    
        df[,respondent_occupation_construction_trades := pmax(respondent_occupation_new_construction_and_extraction_occupations)]        
        df[,respondent_occupation_extractive_and_precision_production := pmax(respondent_occupation_new_production_occupations)]      
        df[,respondent_occupation_machine_operators_assemblers_inspectors := 0]  
        df[,respondent_occupation_transportation_and_material_moving := respondent_occupation_new_transportation_and_material_moving_occupations]       
        df[,respondent_occupation_handlers_equipment_cleaners_helpers_laborers := pmax(respondent_occupation_new_building_and_grounds_cleaning_and_maintenance)]                         
        df[,respondent_occupation_military := respondent_occupation_new_military_specific_occupations]                   
        df[,respondent_occupation_other := pmax(respondent_occupation_new_community_and_social_services_occupations, respondent_occupation_new_education_training_and_library_occupations, respondent_occupation_new_arts_design_entertainment_sports_and_media)]
    
        df[,hoh_occupation_executive_managerial_administrative := pmax(hoh_occupation_new_management_occupations,hoh_occupation_new_business_and_financial_operations_occupations)]      
        df[,hoh_occupation_professional_specialties := pmax(hoh_occupation_new_computer_and_mathematical_occupations, hoh_occupation_new_architecture_and_engineering_occupations, hoh_occupation_new_life_physical_and_social_science_occupations,hoh_occupation_new_legal_occupations,hoh_occupation_new_healthcare_practitioner_and_technical)]
        df[,hoh_occupation_technicians_related_support := pmax(hoh_occupation_new_healthcare_support_occupations)]
        df[,hoh_occupation_sales := hoh_occupation_new_sales_and_related_occupations]                      
        df[,hoh_occupation_administrative_support_including_clerical := pmax(hoh_occupation_new_office_and_administrative_support_occupations)]
        df[,hoh_occupation_private_household := pmax(hoh_occupation_new_personal_care_and_service_occupations)]          
        df[,hoh_occupation_protective_service := hoh_occupation_new_protective_service_occupations]         
        df[,hoh_occupation_service_except_protective_private_household := pmax(hoh_occupation_new_food_preparation_serving_related_occupations)]                          
        df[,hoh_occupation_farm_operators_and_managers := pmax(hoh_occupation_new_farming_fishing_and_forestry_occupations)]
        df[,hoh_occupation_forestry_logging_fishers_hunters_trappers := pmax(hoh_occupation_new_farming_fishing_and_forestry_occupations)]
        df[,hoh_occupation_mechanics_and_repairers := hoh_occupation_new_installation_maintenance_and_repair_occupations]    
        df[,hoh_occupation_construction_trades := pmax(hoh_occupation_new_construction_and_extraction_occupations)]        
        df[,hoh_occupation_extractive_and_precision_production := pmax(hoh_occupation_new_production_occupations)]      
        df[,hoh_occupation_machine_operators_assemblers_inspectors := 0]  
        df[,hoh_occupation_transportation_and_material_moving := hoh_occupation_new_transportation_and_material_moving_occupations]       
        df[,hoh_occupation_handlers_equipment_cleaners_helpers_laborers := pmax(hoh_occupation_new_building_and_grounds_cleaning_and_maintenance)]                         
        df[,hoh_occupation_military := hoh_occupation_new_military_specific_occupation]                   
        df[,hoh_occupation_other := pmax(hoh_occupation_new_community_and_social_services_occupations, hoh_occupation_new_education_training_and_library_occupations, hoh_occupation_new_arts_design_entertainment_sports_and_media)]
    
    }

    if(year >= 2007) {
        df[,respondent_occupation_executive_managerial_administrative := pmax(respondent_occupation_management_occupations,respondent_occupation_business_and_financial_operations_occupations)]      
        df[,respondent_occupation_professional_specialties := pmax(respondent_occupation_computer_and_mathematical_occupations, respondent_occupation_architecture_and_engineering_occupations, respondent_occupation_life_physical_and_social_science_occupations,respondent_occupation_legal_occupations,respondent_occupation_healthcare_practitioner_and_technical)]
        df[,respondent_occupation_technicians_related_support := pmax(respondent_occupation_healthcare_support_occupations)]
        df[,respondent_occupation_sales := respondent_occupation_sales_and_related_occupations]                      
        df[,respondent_occupation_administrative_support_including_clerical := pmax(respondent_occupation_office_and_administrative_support_occupations)]
        df[,respondent_occupation_private_household := pmax(respondent_occupation_personal_care_and_service_occupations)]          
        df[,respondent_occupation_protective_service := respondent_occupation_protective_service_occupations]         
        df[,respondent_occupation_service_except_protective_private_household := pmax(respondent_occupation_food_preparation_serving_related_occupations)]                          
        df[,respondent_occupation_farm_operators_and_managers := pmax(respondent_occupation_farming_fishing_and_forestry_occupations)]
        df[,respondent_occupation_forestry_logging_fishers_hunters_trappers := pmax(respondent_occupation_farming_fishing_and_forestry_occupations)]
        df[,respondent_occupation_mechanics_and_repairers := respondent_occupation_installation_maintenance_and_repair_occupations]    
        df[,respondent_occupation_construction_trades := pmax(respondent_occupation_construction_and_extraction_occupations)]        
        df[,respondent_occupation_extractive_and_precision_production := pmax(respondent_occupation_production_occupations)]      
        df[,respondent_occupation_machine_operators_assemblers_inspectors := 0]  
        df[,respondent_occupation_transportation_and_material_moving := respondent_occupation_transportation_and_material_moving_occupations]       
        df[,respondent_occupation_handlers_equipment_cleaners_helpers_laborers := pmax(respondent_occupation_building_and_grounds_cleaning_and_maintenance)]                         
        df[,respondent_occupation_military := respondent_occupation_military_specific_occupations]                   
        df[,respondent_occupation_other := pmax(respondent_occupation_community_and_social_services_occupations, respondent_occupation_education_training_and_library_occupations, respondent_occupation_arts_design_entertainment_sports_and_media)]
    
        df[,hoh_occupation_executive_managerial_administrative := pmax(hoh_occupation_management_occupations,hoh_occupation_business_and_financial_operations_occupations)]      
        df[,hoh_occupation_professional_specialties := pmax(hoh_occupation_computer_and_mathematical_occupations, hoh_occupation_architecture_and_engineering_occupations, hoh_occupation_life_physical_and_social_science_occupations,hoh_occupation_legal_occupations,hoh_occupation_healthcare_practitioner_and_technical)]
        df[,hoh_occupation_technicians_related_support := pmax(hoh_occupation_healthcare_support_occupations)]
        df[,hoh_occupation_sales := hoh_occupation_sales_and_related_occupations]                      
        df[,hoh_occupation_administrative_support_including_clerical := pmax(hoh_occupation_office_and_administrative_support_occupations)]
        df[,hoh_occupation_private_household := pmax(hoh_occupation_personal_care_and_service_occupations)]          
        df[,hoh_occupation_protective_service := hoh_occupation_protective_service_occupations]         
        df[,hoh_occupation_service_except_protective_private_household := pmax(hoh_occupation_food_preparation_serving_related_occupations)]                          
        df[,hoh_occupation_farm_operators_and_managers := pmax(hoh_occupation_farming_fishing_and_forestry_occupations)]
        df[,hoh_occupation_forestry_logging_fishers_hunters_trappers := pmax(hoh_occupation_farming_fishing_and_forestry_occupations)]
        df[,hoh_occupation_mechanics_and_repairers := hoh_occupation_installation_maintenance_and_repair_occupations]    
        df[,hoh_occupation_construction_trades := pmax(hoh_occupation_construction_and_extraction_occupations)]        
        df[,hoh_occupation_extractive_and_precision_production := pmax(hoh_occupation_production_occupations)]      
        df[,hoh_occupation_machine_operators_assemblers_inspectors := 0]  
        df[,hoh_occupation_transportation_and_material_moving := hoh_occupation_transportation_and_material_moving_occupations]       
        df[,hoh_occupation_handlers_equipment_cleaners_helpers_laborers := pmax(hoh_occupation_building_and_grounds_cleaning_and_maintenance)]                         
        df[,hoh_occupation_military := hoh_occupation_military_specific_occupation]                   
        df[,hoh_occupation_other := pmax(hoh_occupation_community_and_social_services_occupations, hoh_occupation_education_training_and_library_occupations, hoh_occupation_arts_design_entertainment_sports_and_media)]
    }

    # marital status and home values changed in 2007
    if(year >=2007) {
        colnames(df) <- sub("marital_status_never_married", "marital_status_single", colnames(df))
        colnames(df) <- sub("hoh_marital_status_now_married", "marital_status_married", colnames(df))
        colnames(df) <- sub("census_region_midwest", "census_region_north_central", colnames(df))
        colnames(df) <- sub("type_of_dwelling_unit_10_family_", "type_of_dwelling_unit_10_family", colnames(df))
        
        df[,value_of_owned_home_0_19999_dollars:=0]
        df[,value_of_owned_home_20000_29999_dollars:=0]
        df[,value_of_owned_home_30000_39999_dollars:=0]
        df[,value_of_owned_home_40000_49999_dollars:=value_of_owned_home_0_49999_dollars]
        df[,value_of_owned_home_50000_59999_dollars:=0]
        df[,value_of_owned_home_60000_74999_dollars:=value_of_owned_home_50000_74999_dollars]
        df[,value_of_owned_home_200000_dollars:=pmax(value_of_owned_home_200000_249999_dollars,value_of_owned_home_250000_299999_dollars,value_of_owned_home_300000_399999_dollars,value_of_owned_home_400000_499999_dollars,value_of_owned_home_500000_749999_dollars,value_of_owned_home_750000_dollars)]
    } else if (year >=2003 & year <= 2005) {
        df[,value_of_owned_home_200000_dollars:=value_of_owned_home_200000_499999_dollars+value_of_owned_home_500000_dollars]
    }

    if(year ==2011) {
        df[,college_or_university_student_full_time_student:=college_or_university_student_respondent_is_currently_attending_college_or_university]
        df[,college_or_university_student_part_time_student:=0]
        df[,college_or_university_student_working_toward_associate_s_degree:=0]
        df[,college_or_university_student_working_toward_bachelor_s_degree:=0]
        df[,college_or_university_student_working_toward_post_graduate_degree:=0]
        df[,college_or_university_student_working_toward_no_degree:=0]
        df[,household_income_150000_dollars:=household_income_150000_199999_dollars+household_income_200000_249999_dollars + household_income_250000_dollars]
        df[,income_iei_100000_dollars:=income_iei_100000_149999_dollars+income_iei_150000_199999_dollars+income_iei_200000_249999_dollars+income_iei_250000_dollars]
    }

    if (year < 2011) {
        df[,household_income_150000_dollars:=household_income_150000_199999_dollars+household_income_200000_dollars]
        df[,income_iei_100000_dollars:=income_iei_100000_149999_dollars+income_iei_150000_199999_dollars+income_iei_200000_dollars]
    }
    
    



    df

}


forprediction03 <- fixnames(forprediction03, 2003)
forprediction05 <- fixnames(forprediction05, 2005)
forprediction07 <- fixnames(forprediction07, 2007)
forprediction09 <- fixnames(forprediction09, 2009)
forprediction11 <- fixnames(forprediction11, 2011)


### use all columns appearing in all years of GfK after harmonization
keepcols <- list(sections99, sections01, forprediction03, forprediction05,forprediction07,forprediction09,forprediction11) %>% 
    map(colnames) %>% 
    reduce(intersect)

keepcols <- c("daily_newspaper_sections_read_or_looked_at_classified", "daily_newspaper_sections_read_or_looked_at_general_news","daily_newspaper_sections_read_or_looked_at_sports", keepcols)

alldata <- rbind(sections99[,..keepcols], sections01[,..keepcols])

X <- Matrix(as.matrix(alldata[,8:length(keepcols)]), sparse=T)


### predictions: use elastic net with small ridge penalty
classified_reader <- alldata[,daily_newspaper_sections_read_or_looked_at_classified]  
classif_predictor <- cv.glmnet(
    x = X, 
    y = classified_reader, 
    nfolds=5,
    family="gaussian",
    alpha=0.99)

beta_classif <- coef(classif_predictor) %>% as.matrix() 

beta_classif <- data.table(predictor = rownames(beta_classif), coef = beta_classif[,1]) %>% 
    .[abs(coef) > 1e-5 ]


beta_classif[order(coef)] %>% tail(11)
beta_classif[order(coef)] %>% head(10)



saveRDS(classif_predictor, file=glue("{data_dir}/GfK-MRI/elasticnet_classified_interest.rds"))


news_reader <- alldata[,daily_newspaper_sections_read_or_looked_at_general_news]
news_predictor <- cv.glmnet(
    x = X, 
    y = news_reader, 
    nfolds=10,
    family="gaussian",
    alpha=0.99)


beta_news <- coef(news_predictor) %>% as.matrix() 

beta_news <- data.table(predictor = rownames(beta_news), coef = beta_news[,1]) %>% 
    .[abs(coef) > 1e-5 ]


beta_news[order(coef)] %>% tail(11)
beta_news[order(coef)] %>% head(10)

saveRDS(news_predictor, file=glue("{data_dir}/GfK-MRI/elasticnet_news_interest.rds"))

sports_reader <- alldata[,daily_newspaper_sections_read_or_looked_at_sports]
sports_predictor <- cv.glmnet(
    x = X, 
    y = sports_reader, 
    nfolds=10,
    family="gaussian",
    alpha=0.99)


beta_sports <- coef(sports_predictor) %>% as.matrix() 

beta_sports <- data.table(predictor = rownames(beta_sports), coef = beta_sports[,1]) %>% 
    .[abs(coef) > 1e-5 ]


beta_sports[order(coef)] %>% tail(11)
beta_sports[order(coef)] %>% head(10)

saveRDS(sports_predictor, file=glue("{data_dir}/GfK-MRI/elasticnet_sports_interest.rds"))


### Project onto 01-11 data, export predictions
classif_predictor <- readRDS(glue("{data_dir}/GfK-MRI/elasticnet_classified_interest.rds")
news_predictor <- readRDS(glue("{data_dir}/GfK-MRI/elasticnet_news_interest.rds")

keepcols <- keepcols[8:length(keepcols)]

predict_from_df <- function(df, classif_model, news_model, sports_model) {
    X <- Matrix(as.matrix(df[,..keepcols]), sparse=T)
    classif <- predict(classif_model, newx = X) %>% as.numeric
    news <- predict(news_model, newx = X) %>% as.numeric
    sports <- predict(sports_model, newx = X) %>% as.numeric
    data.table(RespID=df[,RespID], 
               pred_classif_propensity = classif,
               pred_news_propensity = news,
               pred_sports_propensity = sports)
}

propensities <- list(sections01, forprediction03, forprediction05, forprediction07, forprediction09, forprediction11) %>% 
    map(predict_from_df, classif_model=classif_predictor, news_model=news_predictor, sports_model = sports_predictor) %>% 
    rbindlist

fwrite(propensities, file = glue("{data_dir}/GfK-MRI/news_section_propensities.csv"))

with(propensities, cor(pred_classif_propensity, pred_news_propensity))
with(propensities, cor(pred_sports_propensity, pred_news_propensity))
with(propensities, cor(pred_sports_propensity, pred_classif_propensity))

library(ggthemes)
theme_set(theme_few())
ggplot(aes(x=pred_classif_propensity, y=pred_news_propensity), data = propensities) + 
    geom_point(alpha=0.05) +
    geom_smooth(method="lm") +
    labs(x="Classified Reading Propensity", y="General News Reading Propensity")

ggsave(glue("{out_dir}/section_propensity_scores.png"))

## subsample sizes: high / low and low / high
propensities[pred_classif_propensity >= median(pred_classif_propensity) & pred_news_propensity < median(pred_news_propensity)]  # 103K
propensities[pred_classif_propensity < median(pred_classif_propensity) & pred_news_propensity >= median(pred_news_propensity)]  # 103K

## do in NAES
classif_predictor <- readRDS(file=glue("{data_dir}/GfK-MRI/elasticnet_classified_interest.rds"))
news_predictor <- readRDS(file=glue("{data_dir}/GfK-MRI/elasticnet_news_interest.rds"))

beta_cl <- coef(classif_predictor)
beta_news <- coef(news_predictor)

## rownames needed for prediction model
union(rownames(beta_cl)[which(beta_cl != 0)], rownames(beta_news)[which(beta_news != 0)])

## align NAES with model
## NOTE: NAES restricted data not included in archive
naes <- read_dta(file=glue("{data_dir}/annenberg/annenberg2000-2004-2008_select.dta")) %>%
    setDT

naes[, respondent_age := cut(resp_age, breaks = c(0,18,19,20,25,30,35,40,45,50,55,60,65,70,75))]
naes[, respondent_age_18_years := as.numeric(resp_age == 18)]
naes[, respondent_age_19_years := as.numeric(resp_age == 19)]
naes[, respondent_age_20_years := as.numeric(resp_age == 20)]
naes[, respondent_age_25_29_years := as.numeric(resp_age >= 25 & resp_age <= 29)]
naes[, respondent_age_30_34_years := as.numeric(resp_age >= 30 & resp_age <= 34)]
naes[, respondent_age_35_39_years := as.numeric(resp_age >= 35 & resp_age <= 39)]
naes[, respondent_age_40_44_years := as.numeric(resp_age >= 40 & resp_age <= 44)]
naes[, respondent_age_45_49_years := as.numeric(resp_age >= 45 & resp_age <= 49)]
naes[, respondent_age_55_59_years := as.numeric(resp_age >= 55 & resp_age <= 59)]
naes[, respondent_age_60_64_years := as.numeric(resp_age >= 60 & resp_age <= 64)]
naes[, respondent_age_65_69_years := as.numeric(resp_age >= 65 & resp_age <= 69)]
naes[, respondent_age_70_74_years := as.numeric(resp_age >= 70 & resp_age <= 74)]
naes[, respondent_age_75_years := as.numeric(resp_age >= 75)] 
naes[, race_white := resp_race1]
naes[, race_black := resp_race2]
naes[, hoh_highest_degree_received_new_census_question_12th_grade_or_less := as.numeric(cw06 == 1 | cw06 == 2)]
naes[, hoh_highest_degree_received_new_census_question_bachelor_s_degree := as.numeric(cw06 == 7)]
naes[, hoh_highest_degree_received_new_census_question_graduated_high_school_or_equivalent := as.numeric(cw06 == 3)]
naes[, hoh_highest_degree_received_new_census_question_post_graduate_degree := as.numeric(cw06 == 8)]
naes[, hoh_highest_degree_received_new_census_question_some_college_no_degree_or_associate_degree_ := as.numeric(cw06 == 5 | cw06 == 6)]
naes[, respondent_marital_status_engaged := as.numeric(cw08 == 2)]
naes[, respondent_marital_status_separated_legally_ := as.numeric(cw08 == 5)]
naes[, respondent_marital_status_single := as.numeric(cw08 == 6)]
naes[, respondent_marital_status_widowed_ := as.numeric(cw08 == 3)]
naes[, hoh_marital_status_divorced := as.numeric(cw08 == 4)]
naes[, hoh_sex_male := as.numeric(resp_sex == 0)]
naes[, hoh_sex_female := as.numeric(resp_sex == 1)]
naes[, respondent_employment_status_full_time := as.numeric(cw09 == 1)]
naes[, respondent_employment_status_other := as.numeric(cw09 == 8)]
naes[, respondent_employment_status_retired := as.numeric(cw09 == 4)]
naes[, respondent_employment_status_temporarily_unemployed := as.numeric(cw09 == 3)]
naes[, hoh_employment_status_full_time := as.numeric(cw09 == 1)]
naes[, hoh_employment_status_retired := as.numeric(cw08 == 4)]
naes[, hoh_employment_status_student := as.numeric(cw08 == 7)]
naes[, household_income_0_4999_dollars:= as.numeric(cw28 == 1)]
naes[, household_income_10000_14999_dollars:= as.numeric(cw28 == 2)]
naes[, household_income_100000_149999_dollars:= as.numeric(cw28 == 8)]
naes[, household_income_15000_19999_dollars := as.numeric(cw28 == 3)]
naes[, household_income_150000_dollars := as.numeric(cw28 == 9)]
naes[, household_income_20000_24999_dollars  := as.numeric(cw28 == 3)]
naes[, household_income_25000_29999_dollars  := as.numeric(cw28 == 4)]
naes[, household_income_30000_34999_dollars  := as.numeric(cw28 == 4)]
naes[, household_income_45000_49999_dollars  := as.numeric(cw28 == 5)]
naes[, household_income_5000_9999_dollars    := as.numeric(cw28 == 2)]
naes[, household_income_50000_59999_dollars  := as.numeric(cw28 == 6)]
naes[, household_income_60000_74999_dollars  := as.numeric(cw28 == 6)]
naes[, household_income_75000_99999_dollars  := as.numeric(cw28 == 7)]

cl_names <- intersect(colnames(naes), rownames(beta_cl)) %>% sort
news_names <- intersect(colnames(naes), rownames(beta_news)) %>% sort

beta_cl_naes <- beta_cl[match(cl_names, rownames(beta_cl))]
beta_news_naes <- beta_news[match(news_names, rownames(beta_news))]


X_cl <- as.matrix(naes[, cl_names, with = F])
X_news <- as.matrix(naes[, news_names, with = F])



naes[, pred_cl := X_cl %*% beta_cl_naes]
naes[, pred_news := X_news %*% beta_news_naes]

naes[, .(pred_cl, pred_news)] %>% write_dta(glue("{data_dir}/annenberg/annenberg2000-2004-2008_preds.dta"))
summary(naes[, .(pred_cl, pred_news)])
with(naes, cor(pred_cl, pred_news, use = "pairwise.complete.obs"))
