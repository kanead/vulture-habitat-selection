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

# set the time column
morgan_data$New_time<-parse_date_time(x=morgan_data$time,c("%m/%d/%Y %H:%M:%S", "%d-%m-%Y %H:%M", "%d-%m-%Y %H:%M:%S", "%d/%m/%Y %H:%M:%S","m/d/Y H:M"))
morgan_data

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
morgan_data

# try to amt package 
X016_Complete <-  filter(morgan_data,id=="X016_Complete")
X016_Complete <- mk_track(X016_Complete, .x = long, .y = lat, .t =time, crs = sp::CRS("+init=epsg:4326"))
summarize_sampling_rate(X016_Complete)

stps <- track_resample(X016_Complete, rate = hours(2), tolerance = minutes(30)) %>%
  filter_min_n_burst(min_n = 3) %>% steps_by_burst() %>%
  time_of_day(include.crepuscule = FALSE)

str(stps)

land_use <- raster("data/raw_data/ESACCI-LC-L4-LC10-Map-20m-P1Y-2016-v1.0.tif")
str(land_use)

grass <- land_use == 3
names(grass) <- "grass"

# Create a box as a Spatial object and crop your raster by the box.
e <- as(extent(-16, -7.25, 4, 12.75), 'SpatialPolygons')
crs(e) <- "+proj=longlat +datum=WGS84 +no_defs"
r <- crop(worldpopcount, e)

