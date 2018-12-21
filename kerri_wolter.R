# kerri data

library(amt)



# extract the data from Kerri that is GMT plus 2 
mydata_kerri <- filter(mydata, study == "kerri", gmt == "GMT_plus2")
glimpse(mydata_kerri)

# Provide options for foramts because there are multiples ones in the column
# and change the date column so that it is read in as a South African time zone
mydata_kerri$New_time<-force_tz (parse_date_time(x=mydata_kerri$time,c("%m/%d/%Y %H:%M:%S", "%d-%m-%Y %H:%M", "%d-%m-%Y %H:%M:%S", "%d/%m/%Y %H:%M:%S")),"Africa/Johannesburg")
head(mydata_kerri)

# convert the south african dates to UTC
GMT_dates<- mydata_kerri %>% transmute(datetime = New_time, tz = "Africa/Johannesburg",  datetime = with_tz(datetime, 'UTC'))
head(GMT_dates)
# stick the new date column back onto the old dataframe 
newdata<-bind_cols(mydata_kerri, GMT_dates)
# pick the columns we want 
newdata<-select(newdata,datetime,long,lat,id,species,study,gmt)
newdata <- rename(newdata, time = datetime)
head(newdata)

# Extract all data except Kerri which is in UTC
mydata_exc_kerri<-filter(mydata, study == "kerri",gmt != "GMT_plus2")
mydata_exc_kerri

mydata_exc_kerri$New_time<-force_tz (parse_date_time(x=mydata_exc_kerri$time,c("%m/%d/%Y %H:%M:%S", "%d-%m-%Y %H:%M", "%d-%m-%Y %H:%M:%S", "%d/%m/%Y %H:%M:%S","m/d/Y H:M")),"UTC")
which(is.na(mydata_exc_kerri$New_time))
mydata_exc_kerri <- select(mydata_exc_kerri, New_time, long,lat,id,species,study,gmt)
mydata_exc_kerri <- rename(mydata_exc_kerri, time = New_time)
mydata_exc_kerri

# stick it all back together again
kerri_data<-bind_rows(newdata, mydata_exc_kerri)

# check the minimum time and the maximum time
min_time <- kerri_data %>% group_by(id) %>% slice(which.min(time))
data.frame(min_time)


max_time <- kerri_data %>% group_by(id) %>% slice(which.max(time))
data.frame(max_time)

# amt package
AM86 <-  filter(kerri_data,id=="AM86")
AM86 <- mk_track(AM86, .x = long, .y = lat, .t =time,crs = sp::CRS("+init=epsg:4326"))
summarize_sampling_rate(AM86)
