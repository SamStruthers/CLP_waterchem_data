library(tidyverse)
library(sf)
library(nhdplusTools)
library(mapview)

`%nin%` = Negate(`%in%`)
# Poudre HUC
huc8 <- get_huc(id="10190007", type = "huc08")

# Pull all NHDPlusV2 flowines within Poudre Watershed
flowlines <- get_nhdplus(AOI = huc8, realization = "flowline", t_srs = 4326)

# Pull in site coordinates
xy <- read_csv('data/metadata/location_metadata.csv') %>%
  filter(Campaign %nin% c("Mainstem - Lower", "Lower Tributary"))%>%
  st_as_sf(coords=c('Long','Lat'), crs=4326) 

# Find NHD comid for each coordinate. NOTE: resolution not great for some sites (see Comanche/Hourglass
# complex)... Some samples are along the same flowline, and are therefore represented with the same
# information. 
for(i in 1:nrow(xy)){
  xy$comid[i] <- discover_nhdplus_id(xy[i,])
}

# Isolate location you want as furthest downstream in the trace
lowest <- filter(xy, site_code=="PBD")

# Identify all flowlines upstream of that furthest downstream location
ws_list <- get_UT(flowlines, lowest$comid)

# redownload flowlines, only those upstream of PBD...
flowlines <- get_nhdplus(comid=ws_list) %>%
  get_tocomid(., add=TRUE) %>%
  mutate(ID=comid, toID=tocomid, length=lengthkm)

# calculate distance upstream each flowline is from PBD, then connect with sample locations
paths <- get_pathlength(flowlines) %>%
  rename(comid=ID) %>%
  right_join(xy, by='comid') %>%
  select(site_code,comid,distance_upstream_km=pathlength)

write.csv(paths, "data/metadata/distance_from_pbd.csv")

# res_comid <-filter(xy, Type == "Reservoir")
# write.csv(res_comid, "data/res_comid.csv")


mapview(flowlines) + mapview(xy)