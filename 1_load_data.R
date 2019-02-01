#########################################################################
# Vulture comparative analysis
# tutorials here https://www.jessesadler.com/post/gis-with-r-intro/
# and here https://www.r-spatial.org/
# 06 November 2018
# 01_prep_data.R
#########################################################################
rm(list=ls())

# Load the required packages
library(knitr)
library(lubridate)
library(maptools)
library(raster)
library(move)
library(amt) 
library(ggmap)
library(tibble)
library(leaflet)
library(dplyr)
library(readr)
library(tidyverse)

# Section 1: Load the data ----
data_path <- "data"   # path to the data
#data_path <- "C:\\Users\\Adam Kane\\Documents\\Manuscripts\\project-structure-master\\data\\raw_data"
#data_path <- "C:\\Users\\Adam\\Documents\\Science\\Manuscripts\\vulture-habitat-selection\\data"

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
levels(as.factor(mydata$study))
