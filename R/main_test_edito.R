rm(list = ls()) 

#turn off scientific notation
options(scipen=999)

#remove need for user prompts
options(needs.promptUser = FALSE)

#enter the range of years covered by the reference period (this is used to define the reference envelope)
ref_years <- c(2010, 2016)

#enter the range of years covered by the comparison period (this is used to determine the comparison data)
comp_years <- c(2017, 2025)

#lifeform abundance dataset filename
file_lf <- "PH1_edito_test.csv"

#set threshold for minimum number of months out of the year required for an assessment area to be included
mon_thr <- 8
print('ok')

 ################################

list.of.packages <- c("tidyverse", "data.table", "janitor", "pracma", "broom", "EnvStats", "patchwork", "rnaturalearth", "zoo")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)
lapply(list.of.packages, require, character.only = TRUE)
rm(list.of.packages, new.packages)

#load the supporting functions
source("Supporting_scripts/PI_functions_v1.R")
source("Supporting_scripts/Supporting_functions_v2.R")

##################################


#specify the directory for where the raw data is stored
dir_data <- "../data/"

#enter the main directory to use to store image outputs
dir_out <- "../output/"

#create plot output directory
dir.create(file.path(dir_out), showWarnings = FALSE)


####################################




df = read.csv("../data/PH1_edito_test.csv")

dates <- read.table(text = as.character(df$period), sep="-", 
                    stringsAsFactors=FALSE)
print(dates)
colnames(dates) <- c("year", "month")

df <- cbind(dates, df) %>%
  dplyr::select(-period) %>%
  filter(year >= min(c(ref_years, comp_years)),
         year <= max(c(ref_years, comp_years)))

rm(dates)

###############################


## --------------------------------------------------------------------------------------------
assess_list <- create_assess_id(x=df)

df <- assess_list[[1]]
df_assess_id <- assess_list[[2]]


## --------------------------------------------------------------------------------------------
polygon_maps <- plot_polys(x=df_assess_id, buff=2)


## --------------------------------------------------------------------------------------------
df <- log_transform(x=df, method=1)


## --------------------------------------------------------------------------------------------
#function for remove years from time series with less than n months of interpolated data and determine proportion of years removed
df <- clean_years(x=df, thr=mon_thr)

#function for filling month gaps in the time series using temporal interpolation with a max gap of 3 months as default
df <- fill_gaps(x=df, max_gap = 3)



## --------------------------------------------------------------------------------------------
#function for extracting a dataframe for a particular time period
df_ref <- dataSelect(x=df, lf=df_lf, lims=ref_years)
df_comp <- dataSelect(x=df, lf=df_lf, lims=comp_years)


## --------------------------------------------------------------------------------------------
#df_ref <- qc_ref(x=df_ref, ind_years = 3, ind_months = 30, rep_months = 2)


## --------------------------------------------------------------------------------------------
#function to prepare the reference envelopes for the multiple lifeform pairs comparisons
envAll <- find_envAll(x=df_ref, lf=df_lf)

#function to calculate the lifeform pairs indicator from the reference envelopes and comparison data
piResults <- PIcalcAll(x=envAll, y=df_comp, z=df_ref, lf=df_lf)

#Calculate PI annually
piResultsAnnual <- suppressWarnings(PIcalcAnnual(x=envAll, y=df_comp, z=df_ref, lf=df_lf))


## --------------------------------------------------------------------------------------------
#function for plotting the PI envelope
env_plots <- plot_env(x=envAll, y=df_ref, z=df_comp, lf=df_lf, pi=piResults)


## --------------------------------------------------------------------------------------------
#function for modelling change in lifeforms over time with Kendall test
df_fits_tot <- kendallAll(x=df, seasonal=FALSE)


## --------------------------------------------------------------------------------------------
#function to prepare the data to be plotted as time-series
df_plot <- create_ts(x=df, y=df_fits_tot)

#function for plotting time-series
ts_plots <- plot_ts(x=df_plot)


## ----include=FALSE---------------------------------------------------------------------------
do.call(file.remove, list(list.files(dir_out, full.names = TRUE)))


## ----include=FALSE---------------------------------------------------------------------------
#function to select, combine and save the combined plots (saved to output subdirectory)
combine_pi_plots(x=env_plots, y=ts_plots, maps=polygon_maps, limits=range(df_plot$year), path=dir_out)


## --------------------------------------------------------------------------------------------
if(nrow(df_assess_id) > 1){
  list_of_datasets <- list("Kendall_results" = df_fits_tot, "PI_results" = piResults, "PI_annual_results" = piResultsAnnual, "Assessment_ids" = df_assess_id)
} else {
  list_of_datasets <- list("Kendall_results" = df_fits_tot, "PI_results" = piResults, "PI_annual_results" = piResultsAnnual)
}

openxlsx::write.xlsx(list_of_datasets, file = paste0(dir_out, "PH1_results", ".xlsx"), overwrite = TRUE)



















