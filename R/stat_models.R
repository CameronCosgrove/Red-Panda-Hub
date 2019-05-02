#### MODELING ######

#### Packages ####
library(tidyverse)
library(ggExtra)
library(lme4)
library(ggeffects)
library(stargazer)
library(nlme)
library(multcompView)
library(pgirmess)
library(effects)

#### Filter data ####
modeling_data <- read_csv('R/final_data_2.csv')



tidy_data <- modeling_data %>%
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


tidy_data[is.na(tidy_data)] <- "none"
tidy_data$habitat_class <- as.factor(tidy_data$habitat_class)
tidy_data$country <- as.factor(tidy_data$country)
tidy_data$longtitude<- as.factor(tidy_data$longtitude)
tidy_data$iucn<- as.factor(tidy_data$iucn)
str(tidy_data)

View(tidy_data)


#### Elevation ####

cor <- cor.test(tidy_data$percent_loss, tidy_data$elevation, 
          method = "spearman",
          continuity = FALSE,
          conf.level = 0.95)
test.cor <- as.data.frame(ggpredict(cor))
# Make 0/1 binary dataset with forest loss no forest loss logistic regression
str(tidy_data)
log_tidy_data <- tidy_data %>%
 mutate(log_loss = log10(percent_loss + 0.000001)) %>%
 mutate((category = 0))

log_tidy_data$percent_loss[log_tidy_data$percent_loss>=0.00001] <- "1"
log_tidy_data$elevation <- as.numeric(log_tidy_data$elevation)

log_tidy_data$percent_loss <- as.numeric(log_tidy_data$percent_loss)


str(log_tidy_data)
log_reg <- lm(percent_loss ~ elevation, data = log_tidy_data, family = binomial)
plot(effect("elevation", log_reg))

stargazer(log_reg, type = "text",
          digits = 3,
          star.cutoffs = c(0.1, 0.01, 0.001),
          digit.separator = "")

plot(log_reg)
r.squaredGLMM(log_reg)


ggplot(log_tidy_data, aes(x=elevation, y=percent_loss)) + geom_point() + 
  stat_smooth(method="glm", method.args=list(family="binomial"), se=FALSE)

library(MuMIn)

elevation.m<- lmer(percent_loss ~ elevation + (1|longtitude), data = tidy_data)
plot(elevation.m)
summary(elevation.m)
stargazer(elevation.m, type = "text",
          digits = 3,
          star.cutoffs = c(0.1, 0.01, 0.001),
          digit.separator = "")

r.squaredGLMM(elevation.m)

#### IUCN ####
#make a balanced sample
iucn_filter <- tidy_data %>%
  select(iucn, percent_loss)%>%
  filter(iucn == "IUCN IV" | iucn == "IUCN II" | iucn == "IUCN VI")

write.table(iucn_filter, file="protected.csv",sep=",",row.names=F)

iucn_filter_small <- iucn_fiter[samplwe(1:nrow(iucn_fiter), 170,
                                        replace=FALSE),]

write.table(iucn_filter_small, file="170_none.csv",sep=",",row.names=F)
# Import new data set
iucn_data <-  read_csv("data_for_IUCN_areas.csv")
View(iucn_data)
iucn_data$iucn <- as.factor(iucn_data$iucn)

for_iucn_graph <- iucn_data%>%
group_by(iucn) %>%
  mutate(averagerating = sum(percent_loss)/length(percent_loss)) %>%
  mutate(serating = sd(percent_loss)/sqrt(length(percent_loss))) %>%
  mutate(n = length(iucn))

levels(for_iucn_graph$iucn)[levels(for_iucn_graph$iucn)=="none"] <- "Unprotected"

iucn_graph <- for_iucn_graph  %>%
  select(iucn, averagerating, serating, percent_loss) %>%
  filter(iucn == "IUCN II" | 
           iucn == "IUCN IV" |
           iucn == "IUCN VI"|
           iucn == "Unprotected" )


ggplot(iucn_graph , aes(x= iucn, y = averagerating)) + 
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



kruskal.test(percent_loss ~ iucn, data = iucn_data)
kruskalmc(percent_loss ~ iucn, data = iucn_data)


iucn.aov <- aov(iucn.m)
summary(iucn.aov)
TukeyHSD(x=iucn.aov, conf.level=0.95)

#### COuntry ####
kruskalmc(percent_loss ~ country, data = tidy_data)
kruskal.test(percent_loss ~ country, data = tidy_data)
posthoc.kruskal.conover.test(percent_loss ~ country, data = tidy_data, p.adjust="none")
lenght<-tidy_data %>%
  group_by(country)%>%
  mutate(n_country = length(country))


unique(tidy_data$n_country)   


#### Habitat Class ####
kruskalmc(percent_loss ~ habitat_class, data = tidy_data)
kruskal.test(percent_loss ~ habitat_class, data = tidy_data)
