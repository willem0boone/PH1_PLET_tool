library(yaml)
library(dplyr)
library(rlang)
library(arrow)
library(tidyr)
library(lubridate)

source("search_data_lake/_search_STAC.R")
source("search_data_lake/_open_parquet.R")
source("search_data_lake/_filter_parquet.R")

# ------------------------------------------------------------------------------
# get the occurrence parquet file
# ------------------------------------------------------------------------------

occ = search_STAC()
print(occ)
# my_parquet = occ[[1]]

#' older version of the occ parquet file:
#' 
#' https://s3.waw3-1.cloudferro.com/emodnet/biology/eurobis_occurrence_data/
#' eurobis_occurrences_geoparquet_2024-10-01.parquet
#' 
#' or 
#' 
#' https://s3.waw3-1.cloudferro.com/emodnet/emodnet_biology/12639/
#' eurobis_parquet_2025-03-14.parquet

# at the moment this script was written, this was the parquet url;
my_parquet <- paste0("https://s3.waw3-1.cloudferro.com/emodnet/emodnet_biology", 
                     "/12639/eurobis_parquet_2025-03-14.parquet")

# ------------------------------------------------------------------------------
# filter and get the occurrence data
# ------------------------------------------------------------------------------

dataset = open_my_parquet(my_parquet)
print(dataset$schema)
column_names <- dataset$schema$names
print(column_names)

filter_params <- list(
  #longitude = c(0, 1),
  #latitude = c(50, 51),
  datasetid = 4687,
  parameter = "WaterAbund (#/ml)",
  eventtype = "sample"
)

# Apply filtering
my_selection <- filter_parquet(dataset, filter_params)


# select columns
my_subset = subset(my_selection, select=c(parameter,
                                          parameter_value,
                                          datasetid,
                                          observationdate,
                                          scientificname_accepted,
                                          longitude,
                                          latitude,
                                          eventtype,
                                          eventid
                                          )
                   )

# ------------------------------------------------------------------------------
# format column names according to PLET requirements
# ------------------------------------------------------------------------------

names(my_subset)[names(my_subset) == "parameter_value"] <- "abundance"
my_subset$abundance <- as.numeric(my_subset$abundance)

my_subset$Time <- as.Date(my_subset$observationdate,format="%Y-%m-%d %H:%M:%S")
my_subset$date = floor_date(my_subset$Time, "month")
my_subset$period = format(my_subset$date, format="%Y-%m")

# ------------------------------------------------------------------------------
# classify in life form groups
# ------------------------------------------------------------------------------

# Load the classification mapping
lifeform_map <- read_yaml(paste0("lifeform_lookup_tables/",
                                 "lifeform_lookup_zooplankton.yaml")
                          )

# Initialize lifeform column
my_subset$lifeform <- NA

# Loop through and classify
for (group in names(lifeform_map)) {
  my_subset$lifeform[my_subset$scientificname_accepted 
                     %in% lifeform_map[[group]]
                     ] <- group
}

my_subset %>% drop_na(lifeform)

# ------------------------------------------------------------------------------
# Aggregate abundances per life form
# ------------------------------------------------------------------------------
print(my_subset)


my_subset <- my_subset[my_subset$lifeform %in% c("meroplankton",
                                                  "holoplankton"),
                        ]

#' Aggregate holoplankton & meroplankton for each event and assign this as 
#' 1 sample
#' 
my_subset = aggregate(abundance ~ period + lifeform + eventid, my_subset, sum)
my_subset$num_samples = 1

#' aggregate per period and divide by the numer of samples
my_subset = aggregate(cbind(abundance, num_samples) ~ period + lifeform,
                      my_subset,
                      sum)

my_subset$abundance = my_subset$abundance/my_subset$num_samples

print(my_subset)



#
# Step 1: Ensure all lifeform-date combinations exist
my_subset <- my_subset %>%
  complete(period, lifeform = c("holoplankton", "meroplankton"), fill = list(abundance = 0))

# Step 2: Fix num_samples by grouping by period and taking the max for each period
my_subset <- my_subset %>%
  group_by(period) %>%
  mutate(num_samples = max(num_samples, na.rm = TRUE)) %>%
  ungroup()

# Done
print(my_subset)

# ------------------------------------------------------------------------------
# save
# ------------------------------------------------------------------------------
dest = file.path("../data/PH1_edito_test.csv")
write.csv(my_subset, dest, row.names=F)








