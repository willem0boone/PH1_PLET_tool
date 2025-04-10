library(dplyr)
library(rlang)
library(arrow)
library(yaml)
library(lubridate)
library(tidyr)


source("search_data_lake/_search_STAC.R")
source("search_data_lake/_open_parquet.R")
source("search_data_lake/_filter_parquet.R")


occ = search_STAC()
print(occ)

# alternatives for occ parquet
# https://s3.waw3-1.cloudferro.com/emodnet/biology/eurobis_occurrence_data/eurobis_occurrences_geoparquet_2024-10-01.parquet
# https://s3.waw3-1.cloudferro.com/emodnet/emodnet_biology/12639/eurobis_parquet_2025-03-14.parquet


# my_parquet = occ[[1]]
my_parquet = "https://s3.waw3-1.cloudferro.com/emodnet/emodnet_biology/12639/eurobis_parquet_2025-03-14.parquet"
#my_parquet = occ[[1]]
print(my_parquet)


dataset = open_my_parquet(my_parquet)
print(dataset$schema)
column_names <- dataset$schema$names
print(column_names)



filter_params <- list(
  #datasetid = 8437,
  #longitude = c(0, 1),
  #latitude = c(50, 51),
  datasetid = 4687
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


my_subset = my_subset[my_subset$parameter == "WaterAbund (#/ml)",]
my_subset = my_subset[my_subset$eventtype == "sample",]

names(my_subset)[names(my_subset) == "parameter_value"] <- "abundance"
my_subset$abundance <- as.numeric(my_subset$abundance)


my_subset$Time <- as.Date(my_subset$observationdate,format="%Y-%m-%d %H:%M:%S")
my_subset$date = floor_date(my_subset$Time, "month")
my_subset$period = format(my_subset$date, format="%Y-%m")



# Load the classification mapping
lifeform_map <- read_yaml("lifeform_lookup_tables/lifeform_lookup_zooplankton.yaml")

# Initialize lifeform column
my_subset$lifeform <- NA




# Loop through and classify
for (group in names(lifeform_map)) {
  my_subset$lifeform[my_subset$scientificname_accepted %in% lifeform_map[[group]]] <- group
}


my_subset %>% drop_na(lifeform)

my_subset = aggregate(abundance ~ observationdate + latitude + longitude + eventid + period + lifeform,
                      my_subset,
                      sum)



all_lifeforms <- unique(my_subset$lifeform)

my_subset <- my_subset %>%
  complete(period, lifeform = all_lifeforms, fill = list(abundance = 0))

my_subset$num_samples = 1


my_agg = aggregate(cbind(abundance, num_samples) ~ period + lifeform,
                   my_subset,
                   sum)











