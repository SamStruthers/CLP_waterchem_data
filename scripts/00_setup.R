#this file contains all the packages,metadata, groupings and color palettes that are used in downstream scripts

### ----- Load packages ----- ###
package_load <- function(package_names){
  for(i in 1:length(package_names)){
    if(!package_names[i] %in% installed.packages()){
      install.packages(package_names[i])
    }
    library(package_names[i],character.only = TRUE)
  }
}

#vector of packages
pack_req <- c( 
  # data wrangling packages
  "tidyverse","lubridate","padr","janitor","padr", "broom","arrow","readxl",
  #spatial packages
  "sf", "mapview",
  # plotting
  "ggpubr","ggthemes","scales","corrplot","gghighlight", "geomtextpath", "ggbeeswarm","plotly", "ggpmisc","flextable", "RColorBrewer")
package_load(pack_req)


remove(pack_req, package_load)
#Simple function to negate %in%
`%nin%` = Negate(`%in%`)



