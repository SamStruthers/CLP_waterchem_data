#This script will output upper_sites_map.html and lower_sites_map.html so folks can view where sites are located

#load packages 
source("scripts/00_setup.R")

# Read in location data from "data/metadata//location_metadata.csv" into object 
sites <- read_csv("data/metadata//location_metadata.csv", show_col_types = FALSE)%>%
 #make into sf object for mapping
  sf::st_as_sf(coords = c("Long","Lat"), crs = 4326)


#Make map of each type of site that ROSS samples
upper_map <-
  mapview::mapview(
    filter(sites, site_code %in% c("JOEI", "JOER","CBRI","CHD","CBRR", "BRNR", "BMD")),
    col.regions = "green3",
    legend = TRUE, 
    layer.name = "Joe Wright Creek Reservoirs")+
  mapview::mapview(
    filter(sites, Campaign == "Longdraw"),
    col.regions = "blue",
    legend = TRUE, 
    layer.name = "Long Draw Road Reservoirs")+ 
  mapview::mapview(
    filter(sites, Campaign == "South Fork"),
    col.regions = "cyan",
    legend = TRUE, 
    layer.name = "South Fork Reservoirs")+ 
  mapview::mapview(
    filter(sites, site_code %in% c("JWC", "PJW", "PFAL", "SLEP", "PBR", "PSF","PNF","PMAN", "PBD")),
    col.regions = "orange",
    legend = TRUE, 
    layer.name = "Upper Mainstem CLP")+ 
  mapview::mapview(
    filter(sites, site_code %in% c("SAWM", "PENN", "LBEA")),
    col.regions = "grey4",
    legend = TRUE, 
    layer.name = "CLP Tributaries") 
  
upper_map



#Make map of each type of site that ROSS samples and owns the data for
lower_map <- mapview(filter(sites, site_code == "PBD"),
    col.regions = "#448CF3", 
    layer.name = "Poudre at Canyon Mouth")+
  mapview(filter(sites, site_code == "lincoln"),
    col.regions = "#F1948A", 
    layer.name = "Poudre at Lincoln Ave")+
  mapview(filter(sites, site_code == "timberline"),
    col.regions = "#FB6A4A", 
    layer.name = "Poudre at Timberline")+
  mapview( filter(sites, site_code == "prospect"),
    col.regions = "#CB4335", 
    layer.name = "Poudre at Prospect St")+
  mapview(filter(sites, site_code == "boxelder"),
    col.regions = "#922B21", 
    layer.name = "Poudre at Boxelder (formerly ELC)")+
  mapview(filter(sites, site_code == "archery"),
    col.regions = "#641E16", 
    layer.name = "Poudre at Archery Range")+
  mapview(filter(sites, site_code == "springcreek"),
    col.regions = "green1",
    layer.name = "Spring Creek Outflow")+
  mapview(filter(sites, site_code == "boxcreek"),
    col.regions =  "green4",
    layer.name = "Boxelder Creek above Boxelder Sanitaton")

lower_map


