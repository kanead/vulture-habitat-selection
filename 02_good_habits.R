#########################################################################
# 3-day R workshop 
# Day 3 pm - Project structure
# Part B
# 4th November 2018
# 02_good_habits.R
#########################################################################
# format the dates 
mydata$time <- as.POSIXct(mydata$time,format="%d/%m/%Y %H:%M")
class(mydata$time)  
head(mydata)

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