#Graduation project#

#prepare the R packages
install.packages('haven','forestplot','tidyverse','lubridate')
##Set work directory##
setwd("C:/Users/SCU-mark/Desktop/graduation project/data")
##Read data file##
library(haven)

###download dta file from the website of CHARLS###
demographic_background <- read_dta("Demographic_Background.dta")
family_transfer <- read_dta("Family_Transfer.dta")
health_status <- read_dta("Health_Status_and_Functioning.dta")
cognition <- read_dta("Cognition.dta")
insider <- read_dta("Insider.dta")
family_info <- read_dta("Family_Information.dta")
work <- read_dta("Work_Retirement.dta")
##Clean data##

##load the library##
library('tidyverse')
library('lubridate')

#find the birth time(year) from demographic background
birth_time1 <- demographic_background %>% mutate(birthtime=ba004_w3_1) %>% filter(ba005_w4==1)
birth_time2 <- demographic_background %>% mutate(birthtime=ba002_1) %>% filter(ba005_w4==2)
birth_time <- rbind(birth_time1,birth_time2) %>% mutate(age=2018-birthtime) 
#calculate the age and filter the elderly(>60years)
elderly <- birth_time%>% filter(age>=60)

#Build the TFI

#merge the data set from the downloaded dta files
health <- merge(health_status,cognition,by=c('ID','householdID','communityID')) %>% 
  merge(family_transfer,by=c('ID','householdID','communityID')) %>% 
  merge(insider,by=c('ID','householdID','communityID')) %>% 
  merge(elderly,by=c('ID','householdID','communityID')) %>% 
  merge(family_info,by=c('ID','householdID','communityID')) %>% 
  merge(work,by=c('ID','householdID','communityID'))

#Physical dimension of TFI
physical <- subset(health,
                   select = c(ID,da002,da007_1_:da007_14_,db003,db006,da039,da033
                              ,da034,db008,dc012))  %>% drop_na(da002)
#Reassignment the 1st item of TFI physical
physical$tfi1 <- ifelse(physical$da002<=3,0,1)
#Reassignment the 2nd item of TFI physical
physical$tfi2 <- ifelse(physical$da007_1_==1|physical$da007_2_==1|
                 physical$da007_3_==1|physical$da007_4_==1|physical$da007_5_==1
               |physical$da007_6_==1|physical$da007_7_==1|physical$da007_8_==1
               |physical$da007_9_==1|physical$da007_10_==1|physical$da007_11_==1
               |physical$da007_12_==1|physical$da007_13_==1|physical$da007_14_==1,1,0)%>% 
  replace_na(0)
#Reassignment the 3rd item of TFI physical
physical$tfi3 <- ifelse(physical$db003 %in% c(3,4),1,0) %>% replace_na(0)
#Reassignment the 4th item of TFI physical
physical$tfi4 <- ifelse(physical$db006 %in% c(1,2),0,1) 
#Reassignment the 5th item of TFI physical
physical$tfi5 <- ifelse(physical$da039 %in% c(1,2,3,4),0,1)
#Reassignment the 6th item of TFI physical
physical$tfi6 <- ifelse(physical$da033 %in% c(1,2,3,4) &
                          physical$da034 %in% c(1,2,3,4),0,1)
#Reassignment the 7th item of TFI physical
physical$tfi7 <- ifelse(physical$db008 %in% c(1,2),0,1)
#Reassignment the 8th item of TFI physical
physical$tfi8 <- ifelse(physical$dc012 %in% c(1,2),0,1)
#the physical part of TFI
TFI_physical <- subset(physical,select = c(ID,tfi1:tfi8))
rm(physical)

#Mental dimension of TFI
mental <- subset(health,select = c(ID,dc004,dc011,dc014,dd039_w4:dd041_w4))
#Reassignment the first item of TFI mental part
mental$tfi9[mental$dc004 %in% c(1,2,3)] <- 0
mental$tfi9[mental$dc004 ==4] <- 0.5
mental$tfi9[mental$dc004 ==5] <- 1
#Reassignment the 2nd item of TFI mental part
mental$tfi10[mental$dc011 %in% c(1,2)] <- 0
mental$tfi10[mental$dc011 ==3] <- 0.5
mental$tfi10[mental$dc011 ==4] <- 1
#Reassignment the 3rd item of TFI mental part
mental$tfi11[mental$dc014 %in% c(1,2)] <- 0
mental$tfi11[mental$dc014 ==3] <- 0.5
mental$tfi11[mental$dc014 ==4] <- 1
#Reassignment the 4th item of TFI mental part
mental$tfi12 <- ifelse(mental$dd039_w4 %in% c(1,2)
                       |mental$dd040_w4 %in% c(1,2) 
                       |mental$dd041_w4 %in% c(1,2),0,1)
#the mental part of TFI
TFI_mental <- subset(mental,select = c(ID,tfi9:tfi12)) %>% drop_na()
rm(mental)

#Social dimension of TFI
social <- subset(health,select = c(ID,be002,a005_w3_1_:a005_w3_10_,dc017,
                                   ce002_1_1_:ce002_1_8_,ce009_1_1_:ce009_1_15_))
#Reassignment the first item of TFI social part
social$tfi13 <- ifelse(!is.na(social$be002) & social$be002==2 & is.na(social$a005_w3_1_) 
                       & is.na(social$a005_w3_2_)& is.na(social$a005_w3_3_)
                       & is.na(social$a005_w3_4_) & is.na(social$a005_w3_5_)
                       & is.na(social$a005_w3_6_) & is.na(social$a005_w3_7_)
                       & is.na(social$a005_w3_8_) & is.na(social$a005_w3_9_)
                       & is.na(social$a005_w3_10_),1,0)
#Reassignment the 2nd item of TFI social part
social$tfi14[social$dc017 %in% c(1,2)] <- 0
social$tfi14[social$dc017 ==3] <- 0.5
social$tfi14[social$dc017 ==4] <- 1
#Reassignment the 3rd item of TFI social part
social$tfi15 <- ifelse(is.na(social$ce002_1_1_) &social$ce002_1_1_==0 
                       & is.na(social$ce002_1_2_) &social$ce002_1_2_==0
                       & is.na(social$ce002_1_3_) &social$ce002_1_3_==0
                       & is.na(social$ce002_1_4_) &social$ce002_1_4_==0
                       & is.na(social$ce002_1_5_) &social$ce002_1_5_==0
                       & is.na(social$ce002_1_6_) &social$ce002_1_6_==0
                       & is.na(social$ce002_1_7_) &social$ce002_1_7_==0
                       & is.na(social$ce002_1_8_) &social$ce002_1_8_==0
                       & is.na(social$ce009_1_1_) &social$ce009_1_1_==0
                       & is.na(social$ce009_1_2_) &social$ce009_1_2_==0
                       & is.na(social$ce009_1_3_) &social$ce009_1_3_==0
                       & is.na(social$ce009_1_4_) &social$ce009_1_4_==0
                       & is.na(social$ce009_1_5_) &social$ce009_1_5_==0
                       & is.na(social$ce009_1_6_) &social$ce009_1_6_==0
                       & is.na(social$ce009_1_7_) &social$ce009_1_7_==0
                       & is.na(social$ce009_1_8_) &social$ce009_1_8_==0
                       & is.na(social$ce009_1_9_) &social$ce009_1_9_==0
                       & is.na(social$ce009_1_10_) &social$ce009_1_10_==0
                       & is.na(social$ce009_1_11_) &social$ce009_1_11_==0
                       & is.na(social$ce009_1_12_) &social$ce009_1_12_==0
                       & is.na(social$ce009_1_13_) &social$ce009_1_13_==0
                       & is.na(social$ce009_1_14_) &social$ce009_1_14_==0
                       & is.na(social$ce009_1_15_) &social$ce009_1_15_==0,1,0)
#the social part of TFI
TFI_social <- subset(social,select = c(ID,tfi13:tfi15)) %>% drop_na()
rm(social)

#Combine the 3 parts
tilburg1 <- merge(TFI_physical,TFI_mental,by='ID') %>% merge(TFI_social,by='ID')
#calculate the total score
Tilburg <- tilburg1 %>% mutate(total=tfi1+tfi2+tfi3+tfi4+tfi5+tfi6+tfi7
                                +tfi8+tfi9+tfi10+tfi11+tfi12+tfi13+tfi14+tfi15)

#Check the normality of the TFI score
hist(as.numeric(Tilburg$total))
#Calculate the median and quartiles of TFI score
Tilburg %>% summarise(avg=median(total),q25=quantile(total,probs=0.25)
          ,q75=quantile(total,probs=0.75))

#set a new variable rate to represent the status of fraility
Tilburg$fra <- ifelse(Tilburg$total>=5,1,0)
#Set the determinants of fraility
determinants <- subset(health,select = c(ID,ba000_w2_3,bd001_w2_4,age,be001,zbc004
                                          ,bc002_w3_1,bc001_w3_2,bc002_w3,bc001_w3_1
                                         ,bg001_w4,da059,da067,dc028,da056_s1:da056_s12
                                         ,da049,da050,da061_w4,xzf1,da025_w4
                                         ,da023,da023_w4,da025,xf11,xf5))
#Reassign the determinants
#sex
determinants$sex <- ifelse(determinants$ba000_w2_3==1,0,1)
#nation
determinants$nation <- ifelse(determinants$bg001_w4==1,0,1)
#education level
determinants$education[determinants$bd001_w2_4==1] <- 1
determinants$education[determinants$bd001_w2_4 %in% c(2,3,4)] <- 2
determinants$education[determinants$bd001_w2_4 %in% c(5:11)] <- 3
#marital status
determinants$marsta <- ifelse(determinants$be001 %in%c(4:6),0,1)
#last record of hukou
determinants$lhukou <- ifelse(determinants$bc001_w3_1 ==1,determinants$zbc004
                              ,determinants$bc001_w3_2)
#current type of hukou
determinants$chukou <- ifelse(determinants$bc002_w3%in%c(2,4),determinants$lhukou
                              ,determinants$bc002_w3_1)
#reassign the hukou type
determinants$hukou <- ifelse(determinants$chukou==1,1,0)
#ever smoked
determinants$smoke[determinants$da059==2|determinants$da061_w4==3] <- 0
determinants$smoke[determinants$da059==1|determinants$da061_w4 %in% c(1,2)] <- 1
#social activities
determinants$sociact <- ifelse(determinants$da056_s12==12,0,1)
#working status
determinants$work <- ifelse(determinants$xzf1==3,1,0)
#ever fallen
determinants$fall[determinants$da023==2 | determinants$da023_w4==2] <- 0
determinants$fall[determinants$da023==1 | determinants$da023_w4==1] <- 1
#fractured hip
determinants$hip[determinants$da025==2 | determinants$da025_w4==2] <- 0
determinants$hip[determinants$da025==1 | determinants$da025_w4==1] <- 1
#group by age
determinants$age_group[determinants$age<70] <- 1
determinants$age_group[determinants$age<80 & determinants$age>=70] <- 2
determinants$age_group[determinants$age>=80] <- 3
#group by sleep hours
determinants$slphrs[determinants$da049<6] <- 1
determinants$slphrs[determinants$da049>=6 & determinants$da049<=8] <- 2
determinants$slphrs[determinants$da049>=8] <- 3
#group by napping time
determinants$naptime <- ifelse(determinants$da050<30,0,1)

#generate the influencing factor of frailty
det <- subset(determinants,select = c(ID,age,age_group,sex,nation,education,hukou,marsta,
                                      smoke,da067,sociact,slphrs,naptime,work,fall,hip))
#clear the environment panel
rm(demographic_background,birth_time,interview_time,health_status,birth_time1
     ,insider,family_transfer,family_info,cognition,tilburg1,determinants,elderly
   ,health,TFI_mental,TFI_physical,TFI_social,work,birth_time2)
#Prep the final list
final <- merge(Tilburg,det,by='ID') 

#Descriptive analysis

#check the normality of the variable 'age'
hist(as.numeric(final$age))
#calculate the median age and quartile of age
final %>% summarise(avg=median(age),q25=quantile(age,probs=0.25)
                    ,q75=quantile(age,probs=0.75))

#calculate the average TFI score and prevalence of frailty
Tilburg %>% summarise(frailrate=sum(fra)/length(fra))

#describe the characteristics of sex for study objects
group_by(final,sex) %>%  summarise(num_of_sex=n()
                                   ,proportion=num_of_sex/length(Tilburg$fra))
#describe the characteristics of nation for study objects
group_by(final,nation) %>%  summarise(num_of_nation=n()
                                      ,proportion=num_of_nation/length(Tilburg$fra))
#describe the level of education for study objects
group_by(final,education) %>%  summarise(num_of_nation=n()
                                         ,proportion=num_of_nation/length(Tilburg$fra))
#describe the characteristics of hukou for study objects
group_by(final,hukou) %>% summarise(num_hukou=n()
                                    ,proportion=num_hukou/length(Tilburg$fra)) %>%
  drop_na()
#describe the marital status of study objects
group_by(final,marsta) %>% summarise(num_mar=n()
                                     ,proportion=num_mar/length(Tilburg$fra))
#describe the characteristics of smoke for study objects
group_by(final,smoke) %>% summarise(num_smoke=n()
                                    ,proportion=num_smoke/length(Tilburg$fra))
#describe the characteristics of drinking alcohol for study objects
group_by(final,da067) %>% summarise(num_drink=n()
                                    ,proportion=num_drink/length(Tilburg$fra))
#describe the social activities for study objects
group_by(final,sociact) %>% summarise(num_sociact=n()
                                      ,proportion=num_sociact/length(Tilburg$fra))
#describe the age group for study objects
group_by(final,age_group) %>% summarise(num_group=n()
                                        ,proportion=num_group/length(Tilburg$fra))
#describe the hrs of sleep
group_by(final,slphrs) %>% summarise(num_group=n()
                                     ,proportion=num_group/length(Tilburg$fra))
#describe the napping time
group_by(final,naptime) %>% summarise(num_group=n()
                                      ,proportion=num_group/length(Tilburg$fra))
#describe the working status
group_by(final,work) %>% summarise(num_group=n()
                                      ,proportion=num_group/length(Tilburg$fra))
#describe if fallen
group_by(final,fall) %>% summarise(num_group=n()
                                   ,proportion=num_group/length(Tilburg$fra))
#describe if hip been fractured
group_by(final,hip) %>% summarise(num_group=n()
                                   ,proportion=num_group/length(Tilburg$fra))



# One-way analysis of variance ie. chi-square test

#chi-square for different age groups
final %>% count(fra==0 & age_group==1)
final %>% count(fra==0 & age_group==2)
final %>% count(fra==0 & age_group==3)
final %>% count(fra==1 & age_group==1)
final %>% count(fra==1 & age_group==2)
final %>% count(fra==1 & age_group==3)
age_group <- matrix(c(456,278,60,148,126,46),nrow = 3,ncol = 2)
chisq.test(age_group)

#chi-square for different sex_groups
final %>% count(fra==0 & sex==0)
final %>% count(fra==0 & sex==1)
final %>% count(fra==1 & sex==0)
final %>% count(fra==1 & sex==1)
sex_group <- matrix(c(441,353,121,199),nrow = 2,ncol = 2)
chisq.test(sex_group)

#chi-square for different nation groups
final %>% count(fra==0 & nation==0)
final %>% count(fra==0 & nation==1)
final %>% count(fra==1 & nation==0)
final %>% count(fra==1 & nation==1)
nation_group <- matrix(c(746,48,294,26),nrow = 2,ncol = 2)
chisq.test(nation_group)

#chi-square for different education groups
final %>% count(fra==0 & education==1)
final %>% count(fra==0 & education==2)
final %>% count(fra==0 & education==3)
final %>% count(fra==1 & education==1)
final %>% count(fra==1 & education==2)
final %>% count(fra==1 & education==3)
education_group <- matrix(c(145,357,292,123,147,50),nrow = 3,ncol = 2)
chisq.test(education_group)

#chi-square for different marital status groups
final %>% count(fra==0 & marsta==0)
final %>% count(fra==0 & marsta==1)
final %>% count(fra==1 & marsta==0)
final %>% count(fra==1 & marsta==1)
mari_group <- matrix(c(174,620,145,175),nrow = 2,ncol = 2)
chisq.test(mari_group)

#chi-square for different types of hukou
final %>% count(fra==0 & hukou==0)
final %>% count(fra==0 & hukou==1)
final %>% count(fra==1 & hukou==0)
final %>% count(fra==1 & hukou==1)
hukou_group <- matrix(c(274,519,61,258),nrow = 2,ncol = 2)
chisq.test(hukou_group)

#chi-square for smoke group
final %>% count(fra==0 & smoke==0)
final %>% count(fra==0 & smoke==1)
final %>% count(fra==1 & smoke==0)
final %>% count(fra==1 & smoke==1)
smoke_group <- matrix(c(402,392,177,143),nrow = 2,ncol = 2)
chisq.test(smoke_group)

#chi-square for alcohol group
final %>% count(fra==0 & da067==1)
final %>% count(fra==0 & da067==2)
final %>% count(fra==0 & da067==3)
final %>% count(fra==1 & da067==1)
final %>% count(fra==1 & da067==2)
final %>% count(fra==1 & da067==3)
education_group <- matrix(c(205,69,520,44,24,252),nrow = 3,ncol = 2)
chisq.test(education_group)

#chi-square for socail ativity group
final %>% count(fra==0 & sociact==0)
final %>% count(fra==0 & sociact==1)
final %>% count(fra==1 & sociact==0)
final %>% count(fra==1 & sociact==1)
social_group <- matrix(c(354,440,175,145),nrow = 2,ncol = 2)
chisq.test(social_group)

#chi-square for sleep-time group
final %>% count(fra==0 & slphrs==1)
final %>% count(fra==0 & slphrs==2)
final %>% count(fra==0 & slphrs==3)
final %>% count(fra==1 & slphrs==1)
final %>% count(fra==1 & slphrs==2)
final %>% count(fra==1 & slphrs==3)
sleep_group <- matrix(c(278,311,205,170,90,60),nrow = 3,ncol = 2)
chisq.test(sleep_group)

#chi-square for nap-time group
final %>% count(fra==0 & naptime==0)
final %>% count(fra==0 & naptime==1)
final %>% count(fra==1 & naptime==0)
final %>% count(fra==1 & naptime==1)
nap_group <- matrix(c(361,433,166,154),nrow = 2,ncol = 2)
chisq.test(nap_group)

#chi-square for working group
final %>% count(fra==0 & work==0)
final %>% count(fra==0 & work==1)
final %>% count(fra==1 & work==0)
final %>% count(fra==1 & work==1)
work_group <- matrix(c(284,476,149,154),nrow = 2,ncol = 2)
chisq.test(work_group)

#chi-square for fallen group
final %>% count(fra==0 & fall==0)
final %>% count(fra==0 & fall==1)
final %>% count(fra==1 & fall==0)
final %>% count(fra==1 & fall==1)
fall_group <- matrix(c(636,158,207,113),nrow = 2,ncol = 2)
chisq.test(fall_group)

#chi-square for hip fractured group
final %>% count(fra==0 & hip==0)
final %>% count(fra==0 & hip==1)
final %>% count(fra==1 & hip==0)
final %>% count(fra==1 & hip==1)
hip_group <- matrix(c(311,9,783,11),nrow = 2,ncol = 2)
chisq.test(hip_group)


#Logistic regression
#change the selected variable type as factor
fit <- glm(fra~as.factor(sex)+as.factor(age_group)+as.factor(education)
           +as.factor(marsta)+as.factor(hukou)+as.factor(da067)+as.factor(sociact)
           +as.factor(slphrs)+as.factor(work)+as.factor(fall)
           ,family=binomial(link = "logit"),data=final)
summary(fit)

#compute the variance inflation factor
library('car')
vif(fit)

#Compute OR value and Confidence interval(95%)
dat <-data.frame(cbind(OR=exp(coef(fit)),exp(confint(fit))))

#Draw the random forest map
library('forestplot')
forestmap <- forestplot(matrix(c('Intercept','???','70~???','80~???','???????????????'
                                 ,'???????????????','??????','??????','?????????1???/???'
                                 ,'??????','???????????????','????????????6~8h','???????????????8h'
                                 ,'???????????????','??????'),nrow =15 ,ncol=1),mean=dat$OR,
                        lower=dat$X2.5..,upper=dat$X97.5..,zero=1,boxsize=0.2,
                        lineheight = unit(7,'mm'),colgap=unit(2,'mm'),lwd.zero=1.5,
                        lwd.ci=2,lty.ci = "solid",title = "Forestplot",
                        txt_gp = fpTxtGp(ticks = gpar(cex = 0.85),
                                         xlab  = gpar(cex = 0.8),cex = 0.9),
                        line.margin = 0.08,xlab="OR",lwd.xaxis =1,graph.pos=2)
forestmap
