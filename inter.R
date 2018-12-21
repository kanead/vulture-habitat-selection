# inter

# select ga_nam data
inter_data <- filter(mydata, study == "inter")
inter_data

# set the time column
inter_data$New_time<-parse_date_time(x=inter_data$time,c("%m/%d/%Y %H:%M:%S", "%d-%m-%Y %H:%M", "%d-%m-%Y %H:%M:%S", "%d/%m/%Y %H:%M:%S","m/d/Y H:M"))
inter_data

# keep only the new time data
inter_data <- select(inter_data, New_time,long,lat,id,species,study)
inter_data <- rename(inter_data, time = New_time)
inter_data

# check the minimum time and the maximum time
min_time <- inter_data %>% group_by(id) %>% slice(which.min(time))
data.frame(min_time)


max_time <- inter_data %>% group_by(id) %>% slice(which.max(time))
data.frame(max_time)

inter_data <- filter(inter_data, time < "2019-01-01")
max_time <- inter_data %>% group_by(id) %>% slice(which.max(time))
data.frame(max_time)


# amt package
x5863 <-  filter(inter_data,id=="5863")
x5863 <- mk_track(x5863, .x = long, .y = lat, .t =time,id=id,crs = sp::CRS("+init=epsg:4326"))
summarize_sampling_rate(x5863)
