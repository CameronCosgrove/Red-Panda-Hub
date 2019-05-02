##### This Script wrangles my GEE sample data #####

library(tidyverse)
library(ggExtra)
library(lme4)
library(ggeffects)
library(stargazer)
library(nlme)
library(multcompView)
library(pgirmess)

raw_sample_data <- read_csv('R/final_data_2.csv')



filtered <- raw_sample_data %>%
  filter(over_20_pc_canopy_cover == 1) %>%
  filter(habitat_class == "Core" | habitat_class == "Moderate" | habitat_class == "Low") %>%
  filter(country == "China_fulgens" | 
           country == "India" |
           country == "Bhutan"|
           country == "Burma" |
           country == "china_styani" |
           country == "Nepal") %>%
  mutate(percent_loss = loss_mean*100) %>%
  mutate(area = percent_loss*1000)


filtered[is.na(filtered)] <- "none"
filtered$habitat_class <- as.factor(filtered$habitat_class)
filtered$country <- as.factor(filtered$country)
filtered$longtitude<- as.factor(filtered$longtitude)
filtered$iucn<- as.factor(filtered$iucn)
str(filtered)

filtered$habitat_class <- as.factor(filtered$habitat_class)
filtered$country <- as.factor(filtered$country)
filtered$longtitude<- as.factor(filtered$longtitude)
filtered$iucn<- as.factor(filtered$iucn)

View(filtered)
#### average loss per country +se ####

filtered <- filtered %>%  
  group_by(country) %>%
  mutate(averagecountry = sum(percent_loss)/length(percent_loss)) %>%
  mutate(secountry = sd(percent_loss)/sqrt(length(percent_loss)))%>%
  group_by(habitat_class) %>%
  mutate(averageclass = sum(percent_loss)/length(percent_loss)) %>%
  mutate(seclass = sd(percent_loss)/sqrt(length(percent_loss))) %>%
  group_by(iucn) %>%
  mutate(averagerating = sum(percent_loss)/length(percent_loss)) %>%
  mutate(serating = sd(percent_loss)/sqrt(length(percent_loss))) %>%
  mutate(n = length(iucn))


unique(filtered$n)   

write.table(filtered, file="sample_data.csv",sep=",",row.names=F)
avg_total_sample_loss <- sum(filtered$percent_loss)/3073
avg_total_sample_se <- sd(filtered$percent_loss)/sqrt(3073)
total_average_loss <- data.frame(avg_total_sample_loss,avg_total_sample_se)



#### Models ####

# Elevation 
elevation.m <- lmer(percent_loss ~ elevation + (1|longtitude), data = filtered)

wilcox.test(filtered$percent_loss, filtered$elevation, paired = F)
library(mblm)

model.k = mblm(percent_loss ~ elevation, data = filtered)

summary(model.k)


summary(np.elevation.m)
plot(np.elevation.m)


anova.lme(elevation.m)

qqnorm(resid(elevation.m))
gvlma::gvlma(elevation.m)

test.gp <- as.data.frame(ggpredict(elevation.m))
mod <- lm(dist ~ speed, data=cars)



# Country
country.m <- lmer(percent_loss ~ Country + (1|Habitat_class), data = filtered)
sum.m <- summary(country.m)
plot_model(country.m, show.values = T)
stargazer(country.m, type = "text",
          digits = 3,
          star.cutoffs = c(0.1, 0.01, 0.001),
          digit.separator = "")

#IUCN
iucn.m <- glm(percent_loss ~ iucn, data = filtered)



iucn.aov <- aov(iucn.m)
summary(iucn.aov)
TukeyHSD(x=iucn.aov, conf.level=0.95)

#### test data vis ####




#Habitat class average %loss with se

ggplot(filtered, aes(x= Habitat_class, y = averageclass)) + 
  geom_point(stat="identity")  +
  geom_errorbar(aes(ymin= averageclass-seclass, ymax= averageclass+seclass),
                width=.2,                    # Width of the error bars
                position=position_dodge(.9)) +
  theme_bw()

ggplot(filtered , aes(x= habitat_class, y = averageclass)) + 
  geom_point(stat="identity")  +
  geom_errorbar(aes(ymin= averageclass-seclass, ymax= averageclass+seclass),
                width=.3,                    # Width of the error bars
                position=position_dodge(.9),
                size = .5) +
  labs(title = " ",
       x = "\n Habitat Class",
       y = "% Forest Loss \n ")+
  theme(
    panel.grid.major.x = element_blank(), # Vertical major grid lines
    panel.grid.major.y = element_blank(), # Horizontal major grid lines
    panel.grid.minor.x = element_blank(), # Vertical minor grid lines
    panel.grid.minor.y = element_blank(),
    panel.border= element_blank(),
    axis.line = element_line(colour = "black"),
    plot.background = element_rect(fill = "#FFFFFF"),
    panel.background = element_rect(fill = "#FFFFFF"),
    strip.background = element_rect(fill = "#FFFFFF"),
    legend.key = element_rect(fill = "#FFFFFF")) 

#IUCN average %loss with se 

iucn_data <- filtered %>%
  select(iucn, averagerating, serating) %>%
  filter(iucn == "IUCN II" | 
           iucn == "IUCN IV" |
           iucn == "IUCN VI"|
           iucn == "none" )
levels(iucn_data$iucn)[levels(iucn_data$iucn)=="none"] <- "Unprotected"

#revalue(c("IUCN_Ia"="1IUCN_Ia", "IUCN II"="2IUCN II", "IUCN IV" = "3IUCN IV", "IUCN VI" = "4IUCN VI", "none" = "5none"))
  
 # arrange(averagerating) %>%
 # mutate(iucn2  = reorder(iucn, levels=c("IUCN_Ia", "IUCN II", "IUCN IV","IUCN VI", "none")))


ggplot(iucn_data , aes(x= iucn, y = averagerating)) + 
  geom_point(stat="identity")  +
  geom_errorbar(aes(ymin= averagerating-serating, ymax= averagerating+serating),
                width=.3,                    # Width of the error bars
                position=position_dodge(.9),
                size = .5) +
  labs(title = " ",
       x = "\n Protection Category",
       y = "% Forest Loss \n ")+
  theme(
    panel.grid.major.x = element_blank(), # Vertical major grid lines
    panel.grid.major.y = element_blank(), # Horizontal major grid lines
    panel.grid.minor.x = element_blank(), # Vertical minor grid lines
    panel.grid.minor.y = element_blank(),
    panel.border= element_blank(),
    axis.line = element_line(colour = "black"),
    plot.background = element_rect(fill = "#FFFFFF"),
    panel.background = element_rect(fill = "#FFFFFF"),
    strip.background = element_rect(fill = "#FFFFFF"),
    legend.key = element_rect(fill = "#FFFFFF")) 

  
  
  
  
ggplot(total_average_loss, aes(x= 1, y= avg_total_sample_loss)) + 
  geom_bar(position=position_dodge(), stat="identity") +
  geom_errorbar(aes(ymin= avg_total_sample_loss-avg_total_sample_se, ymax= avg_total_sample_loss+avg_total_sample_se),
                width=.2,                    # Width of the error bars
                position=position_dodge(.9)) +
  theme_bw()

#Country average %loss with se 
levels(filtered$country)[levels(filtered$country)=="China"] <- "China \n A.fulgens"
levels(filtered$country)[levels(filtered$country)=="china_styani"] <- "China \n A.styani"
ggplot(filtered, aes(x= country, y = averagecountry)) + 
  geom_point(stat="identity")  +
  geom_errorbar(aes(ymin= averagecountry-secountry, ymax= averagecountry+secountry),
                width=.3,                    # Width of the error bars
                position=position_dodge(.9),
                size = .5) +
  labs(title = " ",
       x = "\n Country",
       y = "% Forest Loss \n ")+
  theme(
    panel.grid.major.x = element_blank(), # Vertical major grid lines
    panel.grid.major.y = element_blank(), # Horizontal major grid lines
    panel.grid.minor.x = element_blank(), # Vertical minor grid lines
    panel.grid.minor.y = element_blank(),
    panel.border= element_blank(),
    axis.line = element_line(colour = "black"),
    plot.background = element_rect(fill = "#FFFFFF"),
    panel.background = element_rect(fill = "#FFFFFF"),
    strip.background = element_rect(fill = "#FFFFFF"),
    legend.key = element_rect(fill = "#FFFFFF")) 



#elevation woth simple model
library(ggpubr)

ggplot(test.gp, aes(x= elevation.x, y = elevation.predicted)) +
  geom_point(data = filtered, aes(x = elevation, y = percent_loss, color = 'red'), space=0.04, font.axis=2, size = 0.01) +
  labs(title = " ",
       x = "\n Elevation",
       y = "% Forest Loss \n") +
  theme(
    panel.grid.major.x = element_blank(), # Vertical major grid lines
    panel.grid.major.y = element_blank(), # Horizontal major grid lines
    panel.grid.minor.x = element_blank(), # Vertical minor grid lines
    panel.grid.minor.y = element_blank(),
    panel.border= element_blank(),
    axis.line = element_line(colour = "black"),
    plot.background = element_rect(fill = "#FFFFFF"),
    panel.background = element_rect(fill = "#FFFFFF"),
    strip.background = element_rect(fill = "#FFFFFF"),
    legend.key = element_rect(fill = "#FFFFFF")) +
    scale_y_log10()+
    coord_cartesian(ylim = c(0,100))

ggExtra::ggMarginal(p, type = "density", color="grey")

ggplot(filtered, aes(x=Country, fill=Habitat_class)) +
    geom_bar(stat="identity", position="dodge") 
  
ggplot(filtered, aes(x=Country)) + geom_bar(fill = Habitat_class)
