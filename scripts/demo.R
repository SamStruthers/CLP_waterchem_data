# Demo download and plotting in R
#Install and library needed packages `tidyverse` and `arrow`
install.packages(c("tidyverse", "arrow"))
library(tidyverse)
library(arrow)

#URL for zenodo data set
#FILL IN below
# Most look like this format:
# "https://zenodo.org/records/", DOI, "/files/rossyndicate/" project-name, data_version, ".zip?download=1"

zenodo_url <- "ZENODO_URL"

# Download the entire folder from Zenodo DOI as a zipped folder in your working directory
download.file(url = zenodo_url,destfile = 'ross_clp_chem.zip') 
# unzip this file
unzip('ross_clp_chem.zip') 
 # Grab the name of the download file from current R project   
ROSS_download_file <- list.files() %>%
  keep(~ grepl("rossyndicate", .))

 # Grab the most recent cleaned and collated chemistry dataset
most_recent_chem_file <- list.files(path = paste0(ROSS_download_file,'/data/cleaned/'), pattern = ".csv", full.names = TRUE)
most_recent_chem <- read_csv_arrow(most_recent_chem_file)

#Example plot of NO3 over time at four sites
no3_example_plot <- most_recent_chem %>% 
  filter(site_code %in% c("PBD", "PBR", "SFM", "JOEI") & between(Year, 2016, 2023))%>%
  ggplot(aes(x = Date, y = NO3, color = site_code)) + 
  geom_point(size = 2)+
    labs(x = "Date", y = "NO3 (mg/L)")+
    theme_bw(base_size = 15)+
    facet_wrap(~Year, scales = "free_x")

no3_example_plot

Mainstem_2023_comp <- most_recent_chem %>%
  # Filter for the specific sites and year
    filter(site_code %in% c("PJW", "PBR", "PBD") & Year == 2023) %>%
  # Group by Date and filter to keep only dates with data from both sites
  group_by(Date) %>%
  filter(n_distinct(site_code) == 3) %>%
  ungroup() %>%
  # Pivot to longer format
  pivot_longer(cols = c(Turbidity:Field_Temp_C), names_to = "param", values_to = "Value")%>%
  ggplot(., aes(x = Date, y = Value, color = site_code)) +
  geom_point() +
  facet_wrap(~param, scales = "free_y") +
  theme_bw(base_size = 15) +
  labs(x = "Date", y = "Value")

Mainstem_2023_comp
