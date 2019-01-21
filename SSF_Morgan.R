#' ---
#' title: "Fisher SSF"
#' author: "John Fieberg"
#' date: ""
#' ---
#' 
#' 
#' ### Preamble
#' 
#' Load libraries
#+warning=FALSE, message=FALSE
library(ezknitr)
library(knitr)
library(lubridate)
library(raster)
library(move)
library(amt) 
library(tidyverse)
options(width=150)
opts_chunk$set(fig.width=12,fig.height=4.5)


#' Read in annotated available data for RSF modeling
ssfdat1<-read.csv("data/processed_data/step selection morgan-8783795833129171580.csv")
ssfdat2<-read.csv("data/processed_data/AllStepsMorgan.csv")

# add the land cover data from one to the other
head(ssfdat1)
head(ssfdat2)
ssfdat2$LandClass <- ssfdat1$GlobCover.2009.Land.Cover.Classification
head(ssfdat2)

# rename
ssfdat <- ssfdat2
#' Convert time variables
ssfdat$t1_<-as.POSIXct(ssfdat$t1_, format="%Y-%m-%d %H:%M:%OS", tz="UTC")
ssfdat$t2_<-as.POSIXct(ssfdat$t2_, format="%Y-%m-%d %H:%M:%OS", tz="UTC")
 
   
#' Simplify some variable names and make case a numeric variable
names(ssfdat)[c(13)]<-c("id")
head(ssfdat)
ssfdat$case_<-as.numeric(ssfdat$case)

#' Create landcover classes (as suggested by Scott Lapoint :)
ssfdat$LandClass<-as.character(ssfdat$LandClass)
ssfdat<-ssfdat %>% mutate(landC = fct_collapse(LandClass,
                                               agri = c("11", "14","20", "30"),
                                               forest =c("30","40","50","60", "70","80", "90","100"),
                                               shrub= c("110", "130", "150"),
                                               grass = c("120", "140"),
                                              # wet= c("160"),
                                               other = c("170", "180", "190", "200", "210", "220")))

#' Center and scale variables
ssfdat<-ssfdat %>% mutate(elev=as.numeric(scale(Elevation)), 
                          popD=as.numeric(scale(PopDens)))

#' ## Explore the data:

#' Look Distribution of variables for used and available
#+fig.width=8, fig.height=8
binomial_smooth <- function(...) {
  geom_smooth(method = "glm", method.args = list(family = "binomial"), ...)
}
ggplot(ssfdat,aes(x=Elevation, y=case_))+
  stat_smooth(method="glm", method.args = list(family = "binomial"))+
  binomial_smooth(formula = y ~ splines::ns(x, 5), colour="red")+
  facet_wrap(~id, scales="free")


ggplot(ssfdat,aes(x=PopDens, y=case_))+
  stat_smooth(method="glm", method.args = list(family = "binomial"))+
  binomial_smooth(formula = y ~ splines::ns(x, 5), colour="red")+
  facet_wrap(~id, scales="free")

ggplot(ssfdat, aes(x=landC, y=..prop..,group=case_, colour=case_))+
  geom_bar(position="dodge", aes(fill=case_))+facet_wrap(~id, scales="free")


#' Now, fit an RSF model to data from each animal.  Since not all animals experience
#' all habitat types, lets just explore forest versus non-forest
ssfdat$forest<-ifelse(ssfdat$landC=="forest", 1, 0)

#' Fit an SSF to a single animal
summary(fit_issf(case_ ~ landC+sl_+log(sl_)+strata(step_id_), 
                 data = subset(ssfdat, id=="X023")))

#' Note, animal X057 was always in forest, so we can't include this individual.
ssfdat <- filter(ssfdat,id != "X057")
ssfdat


#' Fit an SSF model to data from each animal
fitted_ssf <- function(data){
   mod <- fit_issf(case_ ~ landC+sl_+log(sl_)+strata(step_id_), data=data)
  return(mod)
}
ssffits <-ssfdat %>%  nest(-id) %>% 
  dplyr::mutate(mod = purrr::map(data, fitted_ssf)) 

#' Look at first model
ssffits$mod[[1]]

#' Now, use tidy to extract information about the model fits
ssffits <- ssffits %>%
  dplyr::mutate(tidy = purrr::map(mod, ~broom::tidy(.x$model)),
                n = purrr::map(data, nrow) %>% simplify())

ssffits$tidy

#' Now, create data frame w/ the coefficients, etc
ssf_coefs <- ssffits %>%
  tidyr::unnest(tidy) %>%
  dplyr::select(-(std.error:conf.high)) 
  
ssf_coefs %>% tidyr::spread(term, estimate)

#' Plot coefficients
#+ fig.width=12, fig.height= 8
ssf_coefs %>% 
  ggplot(., aes(x=1, y=estimate)) + 
  geom_dotplot(binaxis="y", stackdir="center")+geom_hline(yintercept=0)+
  facet_wrap(~term, scales="free")


#' ## Document Footer	
#' 	
#' Document spun with:  ezspin("FisherSSF.R",  fig_dir = "figures", keep_md=FALSE)  	
#' 	
#' Session Information:	
#' 	
sessionInfo()	  
