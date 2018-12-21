# ck_tanz

# select ck_tanz data
ck_tanz_data <- filter(mydata, study == "ck_tanz")
ck_tanz_data

# set the time column
ck_tanz_data$New_time<-parse_date_time(x=ck_tanz_data$time,c("%m/%d/%Y %H:%M:%S", "%d-%m-%Y %H:%M", "%d-%m-%Y %H:%M:%S", "%d/%m/%Y %H:%M:%S","m/d/Y H:M"))
ck_tanz_data

# keep only the new time data
ck_tanz_data <- select(ck_tanz_data, New_time,long,lat,id,species,study)
ck_tanz_data <- rename(ck_tanz_data, time = New_time)
ck_tanz_data

# check the minimum time and the maximum time
min_time <- ck_tanz_data %>% group_by(id) %>% slice(which.min(time))
data.frame(min_time)


max_time <- ck_tanz_data %>% group_by(id) %>% slice(which.max(time))
data.frame(max_time)


# amt package
x151400 <-  filter(ck_tanz_data,id=="151400")
x151400 <- mk_track(x151400, .x = long, .y = lat, .t =time,id=id,crs = sp::CRS("+init=epsg:4326"))
summarize_sampling_rate(x151400)
