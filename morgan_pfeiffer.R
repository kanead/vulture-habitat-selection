#########################################################################
# Vulture comparative analysis
# tutorials here https://www.jessesadler.com/post/gis-with-r-intro/
# and here https://www.r-spatial.org/
# 06 November 2018
# 01_prep_data.R
#########################################################################
rm(list=ls())

# Load the required packages
library(tidyverse)
library(sp)
library(hablar)
library(rnaturalearth)
library(sf)
library(lubridate)
library(amt)
library(knitr)
library(maptools)
library(raster)
library(move)
library(ggmap)
library(tibble)
library(leaflet)
library(dplyr)

# remember to arrange Morgan's data!
# Section 1: Load the data ----
# data_path <- "data/raw_data"   # path to the data
data_path <- "C:\\Users\\Adam Kane\\Documents\\Manuscripts\\project-structure-master\\data\\raw_data"
files <- dir(data_path, pattern = "*.csv") # get file names

mydata <- files %>%
  # read in all the files, appending the path before the filename
  map(~ read_csv(file.path(data_path, .))) %>% 
  reduce(rbind)

# filter the data to remove outliers
mydata <- filter(mydata, lat < 20 & lat > -40 & long > 10)
head(mydata)
tail(mydata)
str(mydata)

# select Morgan's data
morgan_data <- filter(mydata, study == "pfeiffer")
morgan_data

# drop missing rows
morgan_data<- morgan_data %>% drop_na

# extract one id for testing
levels(factor(morgan_data$id))
temp<-filter(morgan_data,id=="X071"); tail(temp)


# some are in day/month/year format e.g. X016_Complete; X020_Final; X021_Final; X022_Complete; X032_Final; X033_Complete;  
# some are in month/day/year format e.g. X023; X027; X042; X050; X051; X052; X053; X055; X056; X057; X071

# set the time column
morgan_data$New_time<-parse_date_time(x=morgan_data$time,c("%d/%m/%Y %H:%M"))

# Morgan's data is in reverse order of time
# sort by the bird ID and reverse the order
morgan_data <- morgan_data %>% group_by(id)  %>% 
  arrange(New_time, .by_group = TRUE)
morgan_data


# check the minimum time and the maximum time
min_time <- morgan_data %>% group_by(id) %>% slice(which.min(New_time))
data.frame(min_time)


max_time <- morgan_data %>% group_by(id) %>% slice(which.max(New_time))
data.frame(max_time)


# keep only the new time data
morgan_data <- select(morgan_data, New_time,long,lat,id,species,study)
morgan_data <- rename(morgan_data, time = New_time)


# try to amt package 
trk <- mk_track(morgan_data, .x=long, .y=lat, .t=time, id = id, 
                crs = CRS("+init=epsg:4326"))

# Now it is easy to calculate day/night with either movement track
trk <- trk %>% time_of_day()


#' Save the class here (and apply it later after adding columns to the 
#' object)
trk.class<-class(trk)

# nest by id
nesttrk<-trk%>%nest(-id)
nesttrk

#' We can add a columns to each nested column of data using purrr::map
trk<-trk %>% nest(-id) %>% 
  mutate(dir_abs = map(data, direction_abs,full_circle=TRUE, zero="N"), 
         dir_rel = map(data, direction_rel), 
         sl = map(data, step_lengths),
         nsd_=map(data, nsd))%>%unnest()

#' Now, calculate month, year, hour, week of each observation and append these to the dataset
#' Unlike the movement charactersitics, these calculations can be done all at once, 
#' since they do not utilize successive observations (like step lengths and turn angles do).
trk<-trk%>% 
  mutate(
    week=week(t_),
    month = month(t_, label=TRUE), 
    year=year(t_),
    hour = hour(t_)
  )


#' Now, we need to again tell R that this is a track (rather 
#' than just a data frame)
class(trk)
class(trk)<-trk.class

#' Lets take a look at what we created
trk <- trk %>% group_by(id)
trk
#' ## Some plots of movement characteristics

#' ### Absolute angles (for each movement) relative to North 
#' We could use a rose diagram (below) to depict the distribution of angles. 
#+fig.height=12, fig.width=12
ggplot(trk, aes(x = dir_abs, y=..density..)) + geom_histogram(breaks = seq(0,360, by=20))+
  coord_polar(start = 0) + theme_minimal() + 
  scale_fill_brewer() + ylab("Density") + ggtitle("Angles Direct") + 
  scale_x_continuous("", limits = c(0, 360), breaks = seq(0, 360, by=20), 
                     labels = seq(0, 360, by=20))+
  facet_wrap(~id)

#' ### Turning angles 
#' 
#' Note: a 0 indicates the animal continued to move in a straight line, a 180 
#' indicates the animal turned around (but note, resting + measurement error often can
#' make it look like the animal turned around).
#+fig.height=12, fig.width=12
ggplot(trk, aes(x = dir_rel, y=..density..)) + geom_histogram(breaks = seq(-180,180, by=20))+
  coord_polar(start = 0) + theme_minimal() + 
  scale_fill_brewer() + ylab("Density") + ggtitle("Angles Direct") + 
  scale_x_continuous("", limits = c(-180, 180), breaks = seq(-180, 180, by=20), 
                     labels = seq(-180, 180, by=20))+
  facet_wrap(~id)

#' ### Turning angles as histograms
#+fig.height=12, fig.width=12
ggplot(trk, aes(x = dir_rel)) +  geom_histogram(breaks = seq(-180,180, by=20))+
  theme_minimal() + 
  scale_fill_brewer() + ylab("Count") + ggtitle("Angles Relative") + 
  scale_x_continuous("", limits = c(-180, 180), breaks = seq(-180, 180, by=20),
                     labels = seq(-180, 180, by=20))+facet_wrap(~id, scales="free")

#' ### Net-squared displacement over time for each individual
#+fig.height=12, fig.width=12
ggplot(trk, aes(x = t_, y=nsd_)) + geom_point()+
  facet_wrap(~id, scales="free")


#' ## Explore movement characteristics by (day/night, hour, month)
#' 
#' ### step length distribution by day/night
#' 
#+fig.height=12, fig.width=12, warning=FALSE, message=FALSE
ggplot(trk, aes(x = tod_, y = log(sl))) + 
  geom_boxplot()+geom_smooth()+facet_wrap(~id)

#' ## SSF prep
#' 
#' SSFs assume that data have been collected at regular time intervals.
#' We can use the track_resample function to regularize the trajectory so that
#' all points are located within some tolerence of each other in time. To figure
#' out a meaningful tolerance range, we should calculate time differences between
#' locations & look at as a function of individual.
(timestats<-trk %>% nest(-id) %>% mutate(sr = map(data, summarize_sampling_rate)) %>%
    dplyr::select(id, sr) %>% unnest)

#' Time intervals range from every 2 to 15 minutes on average, depending
#' on the individual.  Lets add on the time difference to each obs.
trk<-trk %>% group_by(id) %>% mutate(dt_ = t_ - lag(t_, default = NA))
trk


