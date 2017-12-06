rm(list = ls())
path<-"/media/maku/DATA/Nueva_carpeta_7/Datasets/"
period<-"months"
setwd(path)

library(dplyr)
library(lubridate)
library(sqldf)
library(chron)
library(xlsx)
library(zoo)
library(xts)
library(ggplot2)
library(reshape)
library(reshape2)
library(survival)

data_pro_version_bunny<-read.csv("Pro version Bunny Inc.csv", header = TRUE)
data_2<-data_pro_version_bunny;
data_2<-data_2[,-3];
data_2f<-data_2
colnames(data_2f)<-c("user_id","date_confirmed");
data_2f$revenue<-0;

data_2f$date_confirmed_w<-floor_date(as.Date((data_2f$date_confirmed),format="%Y-%m-%d %H:%M:%S",origin = "1970-01-01"), period)
data_3 <- sqldf("select date_confirmed_w, user_id, sum(revenue) as revenue from data_2f group by date_confirmed_w, user_id order by date_confirmed_w")
data_4<-sqldf("select cohort_w, date_confirmed_w, data_3.user_id, revenue FROM data_3, (select user_id, min(date_confirmed_w) AS cohort_w from data_3 group by user_id) AS B where data_3.user_id=B.user_id")
data_5 <- sqldf("select cohort_w as cohort_month, date_confirmed_w as activity_month, count(user_id) as users, sum(revenue) as revenue from data_4 group by cohort_month, activity_month order by cohort_month, activity_month")

a<-seq(min(data_5$cohort_month), max(data_5$cohort_month), by = "months")
R<-rep(a, each=length(a))
go<-cbind(R,a,0,0)
colnames(go)<-c("cohort_month","activity_month","users","revenue")
go<-as.data.frame(go)
go$cohort_month<-as.Date(as.numeric(go$cohort_month),origin = "1970-01-01")
go$activity_month<-as.Date(as.numeric(go$activity_month),origin = "1970-01-01")
data_5<-rbind(data_5,go)

data_5<-sqldf("select cohort_month, activity_month, sum(users) as users, sum(revenue) as revenue from data_5 group by cohort_month, activity_month order by cohort_month, activity_month")

data_5$diffdays<-data_5$activity_month-data_5$cohort_month
data_5<-data_5[data_5[, "diffdays"]>=0,];
data_5<-data_5[,1:4];


