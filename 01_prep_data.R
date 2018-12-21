#########################################################################
# Vulture comparative analysis
# tutorials here https://www.jessesadler.com/post/gis-with-r-intro/
# and here https://www.r-spatial.org/
# https://movebankworkshopraleighnc.netlify.com/testvignettemovebank2018
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
# remember to arrange Morgan's data!
# Section 1: Load the data ----
data_path <- "data/raw_data"   # path to the data
# data_path <- "C:\\Users\\Adam Kane\\Documents\\Manuscripts\\project-structure-master\\data\\raw_data"
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

# drop missing rows
mydata<- mydata %>% drop_na

# recode one of the species factor levels cv_wb hybird to cv
mydata <- mydata %>%
  mutate(species = recode(species, 
                          cv_wb = "cv"))

# Section 2: Summary of the data  ----
# by species
mydata %>%
  group_by(species) %>%
  summarise(length = length(mydata), n = n())

ggplot(mydata) +
  geom_bar(mapping = aes(x = species, fill=species)) +
  theme(text = element_text(size=20)) + ggtitle("N-relocations by species")

# by study
mydata %>%
  group_by(study) %>%
  summarise(length = length(mydata), n = n())

# by bird
length(unique(mydata$id))

# Section 4: Make the data temporal  ----
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
mydata_exc_kerri<-filter(mydata, gmt != "GMT_plus2")
mydata_exc_kerri

mydata_exc_kerri$New_time<-force_tz (parse_date_time(x=mydata_exc_kerri$time,c("%m/%d/%Y %H:%M:%S", "%d-%m-%Y %H:%M", "%d-%m-%Y %H:%M:%S", "%d/%m/%Y %H:%M:%S","m/d/Y H:M")),"UTC")
which(is.na(mydata_exc_kerri$New_time))
mydata_exc_kerri <- select(mydata_exc_kerri, New_time, long,lat,id,species,study,gmt)
mydata_exc_kerri <- rename(mydata_exc_kerri, time = New_time)
mydata_exc_kerri

# stick it all back together again
all_data<-bind_rows(newdata, mydata_exc_kerri)


# Morgan's data is in reverse order of time
# sort by the bird ID and reverse the order so that it matches with the other data
all_data <- all_data %>% group_by(id)  %>% 
  arrange(time, .by_group = TRUE)
all_data


# calculate the time difference between points 
all_data <- all_data %>%
  mutate(time_diff = as.numeric(time-lag(time), units = 'mins'))
all_data

# calculate summary statistics for these time differences
time_diff_summary <- all_data %>% group_by(id) %>% 
  summarise_at("time_diff", 
               funs(median,mean = mean, sd = sd, min = min), 
               na.rm = TRUE)

hist(time_diff_summary$median)
summary(time_diff_summary$median)

# subset to only include daily records 
daily_data <- all_data %>% filter((hour(time) >= 6 & minutes(time) >= 0) | (hour(time) <= 18 & minutes(time) <= 0))
daily_data

# Section 4: Make the data spatial  ----
# change the lat long columns to numeric class
mydata <- mydata %>% 
  convert(num(long:lat))
str(mydata)

# Spatial data with sf
# Create sf object with geo_data data frame and CRS
points_sf <- st_as_sf(mydata, coords = c("long", "lat"), crs = 4326)
class(points_sf)
str(points_sf)

# Get coastal and country world maps as Spatial objects
coast_sp <- ne_coastline(scale = "medium")
countries_sp <- ne_countries(scale = "medium")

# Convert them to sf format 
coast_sf <- ne_coastline(scale = "medium", returnclass = "sf")
countries_sf <- ne_countries(scale = "medium", returnclass = "sf")

# mapping the data for a sample species 
cv_wb<-points_sf %>% filter(species=="lf")

ggplot() + 
  geom_sf(data = coast_sf) + 
  geom_sf(data = cv_wb,
          aes(color = species),
          alpha = 0.7,
          show.legend = "point") +
  coord_sf(xlim = c(-14, 58), ylim = c(-36, 34))

# remove the studies with fewer than 100 points 
common <- points_sf %>% group_by(id) %>% filter(n() >= 100)

# sample x points from the remaining studies 
Samp <- common %>% group_by(id) %>% sample_n(size=100)
Samp

# plot those samples 
ggplot() + 
  geom_sf(data = coast_sf) + 
  geom_sf(data = Samp,
          aes(color = species),
          alpha = 0.7,
          show.legend = "point") +
  coord_sf(xlim = c(-14, 58), ylim = c(-36, 34))  +  
  theme(text = element_text(size=20)) +
  labs(title = "Sample of vulture tracks") 








max_time <- all_data %>%  slice(which.max(time))
data.frame(max_time)
tail(max_time)


morgan_raw<-filter(mydata, id=="X055")
head(morgan_raw)

morgan<-filter(all_data, id=="X055")
tail(morgan)

example<-slice(morgan,9716) 
day(example$time)


x105042<-filter(mydata,id=="105042")
head(x105042)
tail(x105042,10)

y105042<-filter(all_data,id=="105042")
head(y105042)
tail(y105042,10)



x105042


x105042$New_time<-force_tz (parse_date_time(x=x105042$time,c("%m/%d/%Y %H:%M:%S", "%d-%m-%Y %H:%M", "%d-%m-%Y %H:%M:%S", "%d/%m/%Y %H:%M:%S","m/d/Y H:M")),"UTC")
tail(x105042)
