
#internal checks to make sure the data is in the correct format and there are no missing/incorrect names


#make sure all the site codes are correct
sort(unique(water_chemistry_joined$site_code))

#make sure all the site codes are correct
 names_check <- water_chemistry_joined %>%
   select( Date, site_code, Site)%>%
   mutate(site_combo = paste0(water_chemistry_joined$site_code," ",  water_chemistry_joined$Site))%>%
  # sort alphabetically
  arrange(site_combo)
 sort(unique(names_check$site_combo))
 #find sites where a site code had multiple options for "Site"
 names_check %>%
   group_by(site_code)%>%
   summarise(n_distinct(Site))%>%
   filter(`n_distinct(Site)` > 1)
 
 #%>%
   # remove rows with incorrect combos
#   view(names_check %>% filter(Site == "Poudre below Rustic" ))


#make a histogram of the sampling times
water_chemistry_joined%>%
  ggplot(aes(x = final_time_mst))+
  geom_histogram(bins = 24)+
  labs(title = "Histogram of Field Measurements Times",
       x = "Time (mst)",
       y = "Count")
# check for times before 7 am or after 8 pm
time_check <- water_chemistry_joined%>%
  filter(final_time_mst < hms("7:00:00")|final_time_mst > hms("18:00:00"))%>%
  select(site_code, FCW_number, Date, final_time_mst)
#print out results from time check
cat(nrow(time_check), "samples have times before 7 am or after 6 pm:\n" )
head(time_check, n = nrow(time_check))


#check any dates which were incorrect
water_chemistry_joined%>%
  filter(is.na(Date))%>%
  select(site_code, FCW_number,ROSS_number, Date, final_time_mst)

#check for any datetimes that did not get joined correctly
dt_check <- water_chemistry_joined%>%
  filter(is.na(DT_mst))%>%
  select(site_code, FCW_number,ROSS_number,  Date, final_time_mst, `ROSS Time (MST)`, Time_mst, time_mst)

#print out results from dt_check if there are any recent values (ROSS number)
head(dt_check%>%filter(!is.na(ROSS_number)))

#make sure no field data was lost in aggregation

cond_test <- water_chemistry_joined%>%filter(is.na(final_Field_Cond_µS_cm) & !is.na(cond_ms_cm) & !is.na(`ROSS Field_Cond_µS/cm`) & !is.na(`Field_Cond_µS/cm`))
# repeat for DO
do_test <- water_chemistry_joined%>%filter(is.na(final_Field_DO_mgL) & !is.na(do_mgl) & !is.na(`ROSS Field_DO_mgL`) & !is.na(Field_DO_mgL))
#repeat for temp
temp_test <- water_chemistry_joined%>%filter(is.na(final_Field_Temp_C) & !is.na(temp_c) & !is.na(`ROSS Field_Temp_C`) & !is.na(Field_Temp_C))
#repeat for time
time_test <- water_chemistry_joined%>%filter(is.na(final_time_mst) & !is.na(time_mst) & !is.na(Time_mst) & !is.na(`ROSS Time (MST)`))

cat(paste0("Cond joining errors:" ,nrow(cond_test), 
             "\nDO joining errors:", nrow(do_test), 
             "\nTemp joining errors:", nrow(temp_test), 
              "\nTime joining errors:", nrow(time_test)))


rm(cond_test, do_test, temp_test, time_test, time_check, names_check, water_chemistry_import)

#plot handeld sc and sc
ggplotly(water_chemistry_joined%>%filter(!is.na(final_Field_Cond_µS_cm) & !is.na(SC))%>%
  
  #filter(year(Date) == 2024)%>%
  ggplot(aes(x = SC, y = final_Field_Cond_µS_cm, color = site_code))+
  geom_point()+
    #add 1:1 line
  geom_abline(intercept = 0, slope = 1, linetype = "dashed")+
  labs(title = "Comparison of Field and Handheld Conductivity",
       x = "Lab SC",
       y = "Field SC")+
    scale_y_log10()+
    scale_x_log10()+
    facet_wrap(~year(Date))
)
  #facet_wrap(~site_)code)+

#find rows with repeat FCW numbers in old_field_meas
old_field_meas%>%
  group_by(FCW_number)%>%
  summarise(n = n())%>%
  filter(n > 1)


## Data plots after running the remainder of the script
library(plotly)
water_chemistry_tidy %>%
  # Filter for the specific sites and year
  filter(Year == 2026) %>%
  # Pivot to longer format
  pivot_longer(cols = c(Turbidity:Field_Temp_C), names_to = "param", values_to = "Value")%>%
  ggplot(., aes(x = Date, y = Value, color = site_code)) +
  geom_point() +
  facet_wrap(~param, scales = "free_y") +
  theme_bw(base_size = 15) +
  labs(x = "Date", y = "Value")


  
  TC_samples_max_min <- water_chemistry_tidy %>%
    filter(!is.na(TOC) & site_code != "JWC") %>%
    group_by(site_code) %>%
    summarise(
      max_TC = max(TOC, na.rm = TRUE),
      min_TC = min(TOC, na.rm = TRUE)) %>%
    pivot_longer(
      cols = c(max_TC, min_TC),
      names_to = "TC_type",
      values_to = "TOC") %>%
    left_join(water_chemistry_tidy, by = c("site_code", "TOC")) %>%
    filter(!is.na(Date))
  
  
  # TC_samples_q1 <- water_chemistry_tidy %>%
  #   filter(!is.na(TC) & site_code != "JWC") %>%
  #   group_by(site_code) %>%
  #   #if the site has more than 5 values
  #   filter(n() > 5) %>%
  #   # Calculate Q1 and find the closest value
  #   mutate(Q1 = quantile(TC, 0.25, na.rm = TRUE),
  #          abs_diff = abs(TC - Q1)) %>%
  #   slice_min(abs_diff, n = 1) %>%
  #   ungroup() %>%
  #   select(site_code, Date, TC, Q1)
  
  TC_samples_med <- water_chemistry_tidy %>%
    filter(!is.na(TOC) & site_code != "JWC") %>%
    group_by(site_code) %>%
    #if the site has more than 5 values
    filter(n() > 5) %>%
    # Calculate Q1 and find the closest value
    mutate(median = median(TOC, na.rm = TRUE),
           abs_diff = abs(TOC - median), 
           TC_type = "median") %>%
    slice_min(abs_diff, n = 1) %>%
    ungroup()
  
  
  TC_samples <- bind_rows(TC_samples_max_min, TC_samples_med) 
  
  
ggplotly(    water_chemistry_tidy%>%
      filter(Year %in% c("2024", "2025", "2026"))%>%
        filter(!is.na(TOC)) %>%
    ggplot(aes(x = Date, y = TOC, color = site_code)) +
    geom_point() +
    #geom_point(data = TC_samples, aes(y = TC), color = "black", size = 2) +
    theme_bw(base_size = 15) +
    labs(x = "Date", y = "TOC"))



  #plot all the samples vs the TC samples
water_chemistry_tidy %>%
    filter(site_code != "JWC" & Year %in% c("2024", "2025") & !is.na(TOC)) %>%
    ggplot(aes(x = Date, y = TOC)) +
    geom_point(color = "grey") +
    geom_point(data = TC_samples, aes(y = TOC), color = "black", size = 2) +
    theme_bw(base_size = 15) +
    labs(x = "Date", y = "TC (mg/L)")
 

 
 # Combine histogram and scatter plot
 ggplot(water_chemistry_tidy %>% filter(!is.na(TOC) & site_code != "JWC")) +
   # Histogram layer
   geom_dotplot(aes(x = "All", y = TOC), fill = "steelblue", binaxis = "y", stackdir = "center", dotsize = 0.5, color = "black", alpha = 0.7, width = 0.3) +   # Scatter plot layer
   geom_dotplot(data = TC_samples, aes(x = "Selected", y = TOC), binaxis = "y", stackdir = "center", dotsize = 0.5, fill = "darkorange") +
   labs(
     title = "Dotplot of all TC Values (blue) with Selected Samples (orange)",
     x = "Sample group",
     y = "TC (mg/L)"
   ) +
   theme_minimal()
 
 ggplot(water_chemistry_tidy %>% filter(!is.na(TOC) & site_code != "JWC")) +
   # Histogram layer
   geom_boxplot(aes(x = "All", y = TOC), fill = "steelblue") +   # Scatter plot layer
   geom_boxplot(data = TC_samples, aes(x = "Selected", y = TOC), fill = "orange") +
   labs(
     title = "Boxplot of all TC Values (blue) with Selected Samples (orange)",
     x = "Sample group",
     y = "TC value"
   ) +
   theme_minimal()
 
 # Print the combined plot
 print(combined_plot)
 
 #make a histogram of the water chem 
  


