# Morgan Pfeiffer's SA Vulture Tracking Dataset 

# select Morgan's data
morgan_data <- filter(mydata, study == "pfeiffer")
morgan_data

# drop missing rows
morgan_data<- morgan_data %>% drop_na

#' Check for duplicated observations (ones with same lat, long, timestamp,
#'  and individual identifier).
ind2<-morgan_data %>% select(long, lat, id) %>%
  duplicated 
sum(ind2) 
# remove them 
morgan_data$dups <- ind2
morgan_data <- filter(morgan_data,dups=="FALSE")
morgan_data

# set the time column
# some are in day/month/year format e.g. X016_Complete; X020_Final; X021_Final; X022_Complete; X032_Final; X033_Complete;  
# some are in month/day/year format e.g. X023; X027; X042; X050; X051; X052; X053; X055; X056; X057; X071
levels(factor(morgan_data$id))
temp1<-filter(morgan_data,
               id == "X016_Complete" |
               id=="X021_Final" | 
               id == "X020_Final" |
               id == "X021_Final" |
               id == "X022_Complete" |
               id == "X032_Final" |
               id == "X033_Complete" ); tail(temp1) ;head(temp1)
temp1
temp1$New_time<-parse_date_time(x=temp1$time,c("%d/%m/%Y %H:%M"))
tail(temp1)

temp2<-filter(morgan_data, 
                id == "X023" |
                id == "X027" |
                id == "X042" |
                id == "X050" |
                id == "X051" |
                id == "X052" |
                id == "X053" |
                id == "X055" |
                id == "X056" |
                id == "X057" |
                id == "X071" ); tail(temp2) ;head(temp2)
temp2
temp2$New_time<-parse_date_time(x=temp2$time,c("%m/%d/%Y %H:%M"))
tail(temp2)

# stick them back together again
morgan_data <- full_join(temp1,temp2)
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


#' filter extreme data based on a speed threshold 
#' based on vmax which is km/hr
#' time needs to be labelled DateTime for these functions to work
library(SDLfilter)
names(morgan_data)[names(morgan_data) == 'time'] <- 'DateTime'
SDLfilterData<-ddfilter.speed(data.frame(morgan_data), vmax = 60, method = 1)
length(SDLfilterData$DateTime)

#' rename everything as before
morgan_data <- SDLfilterData
names(morgan_data)[names(morgan_data) == 'DateTime'] <- 'time'

# try the amt package 
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

# select individuals that have temporal resolution of ~ 15 mins 
trk<- filter(trk,id=="X027"|
         id=="X042"|
         id=="X023"|
         id=="X050"|
         id=="X051"|
         id=="X053"|
         id=="X052"|
         id=="X071"|
         id=="X056"|
         id=="X057"|
         id=="X055")

# need to run timestats again for the subsetted dataframe so that the IDs match up below
(timestats<-trk %>% nest(-id) %>% mutate(sr = map(data, summarize_sampling_rate)) %>%
    dplyr::select(id, sr) %>% unnest)


#'  Loop over the individuals and do the following:
#' 
#' - Regularize trajectories using an appropriate time window (see e.g., below) 
#' - calculate new dt values
#' - Create bursts using individual-specific time intervals
#' - Generate random steps within each burst
#' 
#' The random steps are generated using the following approach:
#' 
#' 1. Fit a gamma distribution to step lenghts
#' 2. Fit a von mises distribution to turn angles
#' 3. Use these distribution to draw new turns and step lengths, form new simulated steps
#' and generate random x,y values.
#' 

#+warning=FALSE
ssfdat<-NULL
temptrk<-with(trk, track(x=x_, y=y_, t=t_, id=id))
uid<-unique(trk$id) # individual identifiers
luid<-length(uid) # number of unique individuals
for(i in 1:luid){
  # Subset individuals & regularize track
  temp<-temptrk%>% filter(id==uid[i]) %>% 
    track_resample(rate=minutes(round(timestats$median[i])), 
                   tolerance=minutes(max(10,round(timestats$median[i]/5))))
  
  # Get rid of any bursts without at least 2 points
  temp<-filter_min_n_burst(temp, 2)
  
  # burst steps
  stepstemp<-steps_by_burst(temp)
  
  # create random steps using fitted gamma and von mises distributions and append
  rnd_stps <- stepstemp %>%  random_steps(n = 15)
  
  # append id
  rnd_stps<-rnd_stps%>%mutate(id=uid[i])
  
  # append new data to data from other individuals
  ssfdat<-rbind(rnd_stps, ssfdat)
}
ssfdat<-as_tibble(ssfdat)
ssfdat


#' ## Write out data for further annotating
#' 
#' Need to rename variables so everything is in the format Movebank requires for annotation of generic time-location 
#' records (see https://www.movebank.org/node/6608#envdata_generic_request). This means, we need the following variables:
#' 
#' - location-lat (perhaps with addition of Easting/Northing in UTMs)
#' - location-long (perhaps with addition of Easting/Northing in UTMs)
#' - timestamp (in Movebank format)
#' 
#' Need to project to lat/long, while also keeping lat/long. Then rename
#' variables and write out the data sets. With the SSFs, we have the extra complication of
#' having a time and location at both the start and end of the step.  
#' 
#' For the time being, we will assume we want to annotate variables at the end of the step
#' but use the starting point of the step as the timestamp.
#' 
#' You could also calculate the midpoint of the timestep like this:
#' data$timestamp.midpoint <- begintime + (endtime-begintime)/2
#'
#' we want the x2_ and y2_ columns for Movebank 
head(ssfdat)
ncol(ssfdat)
ssfdat2 <- SpatialPointsDataFrame(ssfdat[,c("x2_","y2_")], ssfdat, 
                                  proj4string=CRS("+proj=longlat +datum=WGS84"))  
ssf.df <- data.frame(spTransform(ssfdat2, CRS("+proj=longlat +datum=WGS84"))) 

names(ssf.df)[names(ssf.df) == 'id'] <- 'individual.local.identifier'
names(ssf.df)[names(ssf.df) == 'x2_.1'] <- 'location-long'
names(ssf.df)[names(ssf.df) == 'y2_.1'] <- 'location-lat'
head(ssf.df)

ssf.df$timestamp<-ssf.df$t1_
ssf.df %>% select('location-lat', x1_, x2_, y1_, y2_, 'location-long') %>% head


#' These points then need to be annotated prior to fitting ssfs. Let's 
#' Can subset to certain essential columns so as take up less space, making it easier to annotate (and also possible to upload to github)
ssf.df.out<-ssf.df %>% select("timestamp", "location-long", "location-lat","individual.local.identifier","case_")
head(ssf.df.out)
write.csv(ssf.df.out, file="movebank/MorganSSFannotate.csv", row.names = FALSE)

