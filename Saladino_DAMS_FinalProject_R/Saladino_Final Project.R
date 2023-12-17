library(janitor)
library(tidyverse)
library(tidycensus)

# limit rows for API calls in case data sets are too large
limit <- c("3000000")

# Data sets are huge, so I need to expand the processing capabilities
Sys.setenv("VROOM_CONNECTION_SIZE" = 30000000)

# Crash Data, only want 2015 to match tree census
# start with an API call to pull from New York City's open data site
Crash_URL <- "https://data.cityofnewyork.us/resource/h9gi-nx95.csv"
crash_api <- paste0(Crash_URL,"?$query=SELECT * LIMIT ",limit)
crash_api_enc <- URLencode(crash_api)

# Load in encoded url, clean up, select out non-essential columns, isolate to confirmed locations in Brooklyn    
BK_crash_data_2015 <- read_csv(crash_api_enc) %>% 
  clean_names() %>% 
  filter(year(crash_date) == 2015, latitude != "N/A", borough == "BROOKLYN") %>% 
  select(crash_date,latitude,longitude,collision_id)

# Save this processed .csv file to upload into QGIS
write.csv(BK_crash_data_2015, "BK_crash_data_2015.csv", row.names = FALSE)

# Tree Data, most recent data is 2015
# start with an API call to pull from New York City's open data site
Tree_URL <- "https://data.cityofnewyork.us/resource/uvpi-gqnh.csv"
tree_api <- paste0(Tree_URL,"?$query=SELECT * LIMIT ",limit)
tree_api_enc <- URLencode(tree_api)


# Load in encoded url, clean up, select out non-essential columns, isolate to confirmed locations in Brooklyn
BK_tree_data_2015 <- read_csv(tree_api_enc) %>% 
  clean_names() %>% 
  filter(latitude != "N/A", borocode == 3) %>% 
  select(tree_id,latitude,longitude,census_tract)

# Save this processed .csv file to upload into QGIS
write.csv(BK_tree_data_2015, "BK_tree_data_2015.csv", row.names = FALSE)

# ~~~END OF STAGE ONE OF R ANALYSIS~~~

# ~~~STAGE TWO: load in .csv files from QGIS analysis to clean up before creating visualizations

# Filter for census tracts with a tree density greater than 12 trees/acre (top 8)
buff_tracts_count_dens <- read_csv("buff_tracts_count_dens.csv") %>% 
  filter(tree_dens>12) %>% 
  arrange(desc(tree_dens))

# Save this data frame as a .csv file to visualize in a third party (datamapper)
write.csv(buff_tracts_count_dens, "Phase2_graph_data", row.names = FALSE)

# upload phase 3 data, may not need
high_crash_interx_stat <- read_csv("high_crash_interx_stat.csv")

