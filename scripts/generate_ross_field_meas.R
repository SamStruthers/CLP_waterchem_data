## Water Sampling Data Processing Script
## Goal:
## Load raw water sampling and field measurement data (from mWater using ross.wq.tools functions), clean and 
## process the records (including standardizing site codes, rounding datetimes, 
## extracting time, and separating/reconciling BLANK and DUPLICATE samples), 
## and save the complete, data publication-ready field measurement log to a dated CSV file.


library(tidyverse)
library(ross.wq.tools)
library(here)
#pull in site meta data
site_meta <- read_csv(here("data","metadata","location_metadata.csv"),show_col_types = FALSE)%>%
  select(site = site_code, Site_Name)
# sort for sites in upper network (ie. acronyms rather than street names)
upper_sites <- read_csv(here("data","metadata","location_metadata.csv"),show_col_types = FALSE)%>%
  filter(watershed != "CLP  Mainstem-Fort Collins")%>%
  #this is to help match with user input
  mutate(site_code = tolower(site_code))

# create df of all water samples and save DT, handheld probe and chla volume data
sampling_notes <- load_mWater()%>%
  filter(grepl("Sampling",visit_type))%>%
  mutate(site = ifelse(site %in% upper_sites$site_code, toupper(site), site),
         DT_round = round_date(with_tz(start_DT, tz = "MST"), "15 minutes"), 
         start_time_mst = format(DT_round, format = "%H:%M:%S"))%>%
  select(site,crew, DT_round, date, time = start_time_mst, sample_collected, chla_volume_ml, vol_filtered_blank_dup, do_mgl, cond_ms_cm, temp_c, visit_comments, q_cfs)

# Distinguish BLANK and DUPLICATE values
blanks_dups <- sampling_notes %>%
  #find all values that have blank or dup
  filter(grepl("DUPLICATE|BLANK", sample_collected)) %>%
  # change sample collected to match BLANK/DUP
  mutate(sample_collected = ifelse(grepl("DUPLICATE", sample_collected), "DUPLICATE", "BLANK"),
         # Volume filtered blank dup becomes chla volume
         chla_volume_ml = vol_filtered_blank_dup,
         #drop vol_filtered_blank/dup
         vol_filtered_blank_dup = NULL)

# Add blank and duplicate values back to main
sampling_notes <- sampling_notes%>%
  #get rid of blank/dup in sample collcected
  mutate(sample_collected = gsub("DUPLICATE|BLANK| |,", "", sample_collected),
         #drop vol_filtered_blank/dup
         vol_filtered_blank_dup = NULL)%>%
  #bring in blank and dup rows
  rbind(blanks_dups)%>%
  #arrange by datetime and site (Blanks and dups go second)
  arrange(DT_round, site)%>%
  # join with RMRS friendly metadata
  left_join(site_meta, by = "site")

#Save to CSV to join with Data Pub

sampling_notes_output <- sampling_notes%>%
  # select only the needed columns, saved in the correct order and fix column names
  select(site_code = site, Date = date, DT_round, SampleType = sample_collected, time_mst = time,chla_volume_ml,  do_mgl, cond_ms_cm, temp_c, visit_comments)

max_date = max(sampling_notes_output$Date, na.rm = T)%>% as.character()

# write to csv
write_csv(x = sampling_notes_output, file = here("data","raw", paste0("ROSS_field_meas_upto_",max_date,".csv" )))


