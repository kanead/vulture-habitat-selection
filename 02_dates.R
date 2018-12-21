#########################################################################
# Vulture comparative analysis
# tutorials here https://www.jessesadler.com/post/gis-with-r-intro/
# and here https://www.r-spatial.org/
# 06 November 2018
# 02_dates.R
#########################################################################
# format the dates 
mydata$time <- as.POSIXct(mydata$time,format="%d/%m/%Y %H:%M")
class(mydata$time)  
head(mydata)

# arrange by id and time 
mydata <- mydata %>% group_by(id)  %>% 
  arrange(time, .by_group = TRUE)


# calculate the time difference
mydata <- mydata %>% group_by(id) %>% arrange(time) %>%
  mutate(time_diff_2 = as.numeric(time-lag(time), units = 'mins'))
head(mydata)

tdiff<- mydata %>% group_by(id) %>% 
  summarise_at("time_diff_2", 
               funs(median,mean = mean, sd = sd, min = min), 
               na.rm = TRUE)
tdiff
hist(tdiff$median)



region <- c("UTC","Africa/Johannesburg")
(localtime <- lapply(seq(mydata$time),function(x) as.POSIXlt(mydata$time[x],tz=region[x])))
