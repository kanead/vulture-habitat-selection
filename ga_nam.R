# ga_nam

# select ga_nam data
ga_nam_data <- filter(mydata, study == "ga_nam")
ga_nam_data

# set the time column
ga_nam_data$New_time<-parse_date_time(x=ga_nam_data$time,c("%m/%d/%Y %H:%M:%S", "%d-%m-%Y %H:%M", "%d-%m-%Y %H:%M:%S", "%d/%m/%Y %H:%M:%S","m/d/Y H:M"))
ga_nam_data

# keep only the new time data
ga_nam_data <- select(ga_nam_data, New_time,long,lat,id,species,study)
ga_nam_data <- rename(ga_nam_data, time = New_time)
ga_nam_data

# check the minimum time and the maximum time
min_time <- ga_nam_data %>% group_by(id) %>% slice(which.min(time))
data.frame(min_time)


max_time <- ga_nam_data %>% group_by(id) %>% slice(which.max(time))
data.frame(max_time)

# max time for one track is 2025-09-18! The id is 5863
ga_nam_data <- filter(ga_nam_data, time < "2019-01-01")
max_time <- ga_nam_data %>% group_by(id) %>% slice(which.max(time))
data.frame(max_time)


# amt package
x5863 <-  filter(ga_nam_data,id=="5863")
x5863 <- mk_track(x5863, .x = long, .y = lat, .t =time,id=id,crs = sp::CRS("+init=epsg:4326"))
summarize_sampling_rate(x5863)

