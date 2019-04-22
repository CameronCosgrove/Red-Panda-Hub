##### This Script wrangles my GEE sample data #####

library(tidyverse)
library(ggExtra)
library(lme4)
library(ggeffects)

raw_sample_data <- read_csv('R/5000_sampledata_30mScale_processed.csv')

filtered <- raw_sample_data %>%
  filter(over_20_pc_canopy_cover == 1) %>%
  filter(habitat_class == "core" | habitat_class == "moderate" | habitat_class == "low") %>%
  filter(country == "china" | 
           country == "india" |
           country == "bhutan" |
           country == "burma" |
           country == "china_spp" |
           country == "nepal") %>%
  mutate(area = percent_loss*1000)
filtered$habitat_class <- as.factor(filtered$habitat_class)
filtered$country <- as.factor(filtered$country)
filtered$longitude_round <- as.factor(filtered$longitude_round)
#### average loss per country +se ####

filtered <- filtered %>% 
  group_by(country) %>%
  mutate(averagecountry = sum(percent_loss)/length(percent_loss)) %>%
  mutate(secountry = sd(percent_loss)/sqrt(length(percent_loss))) %>%
  group_by(habitat_class) %>%
  mutate(averageclass = sum(percent_loss)/length(percent_loss)) %>%
  mutate(seclass = sd(percent_loss)/sqrt(length(percent_loss))) %>%
  ungroup()
write.table(filtered, file="sample_data.csv",sep=",",row.names=F)
avg_total_sample_loss <- sum(filtered$percent_loss)/2932
avg_total_sample_se <- sd(filtered$percent_loss)/sqrt(2932)
total_average_loss <- data.frame(avg_total_sample_loss,avg_total_sample_se)
#### exploratry models ####
elvation.m <- glm(percent_loss ~ elevation, family = poisson, data = filtered)
summary(elvation.m)

test.gp <- as.data.frame(ggpredict(elvation.m))
ggpredict(elvation.m)

#### test data vis 

#Habitat class average %loss with se 
ggplot(filtered, aes(x= habitat_class, y = averageclass)) + 
  geom_point(stat="identity")  +
  geom_errorbar(aes(ymin= averageclass-seclass, ymax= averageclass+seclass),
                width=.2,                    # Width of the error bars
                position=position_dodge(.9))
#Total average loss
ggplot(total_average_loss, aes(x= 1, y= avg_total_sample_loss)) + 
  geom_bar(position=position_dodge(), stat="identity") +
  geom_errorbar(aes(ymin= avg_total_sample_loss-avg_total_sample_se, ymax= avg_total_sample_loss+avg_total_sample_se),
                width=.2,                    # Width of the error bars
                position=position_dodge(.9))

#Country average %loss with se 
ggplot(filtered, aes(x= country, y = averagecountry)) + 
  geom_point(stat="identity") +
  geom_errorbar(aes(ymin= averagecountry-secountry, ymax= averagecountry+secountry),
                width=.2,                    # Width of the error bars
                position=position_dodge(.9))

#elevation woth simple model
ggplot(test.gp, aes(x= elevation.x, y = elevation.predicted)) +
  geom_point(data = filtered, aes(x = elevation, y = percent_loss, color = 'red')) +
  geom_line() +
  geom_ribbon(aes(ymin = elevation.conf.low, ymax = elevation.conf.high), alpha = .1) +
  xlab( "elevation ") + 
  ylab("percent forest loss") +
  scale_y_log10()

##ggplot(filtered, aes(x= elevation, y = percent_loss)) +geom_point( aes(color = country)) +
  geom_line(data = cbind(filtered, pred = predict(elvation.m)), aes(y = pred))




ggplot(data, aes(x=x, y=y) ) +
  geom_bin2d() +
  theme_bw()

# Number of bins in each direction?
ggplot(data, aes(x=x, y=y) ) +
  geom_bin2d(bins = 70) +
  theme_bw()

ggplot(data, aes(x=x, y=y) ) +
  geom_bin2d() +
  theme_bw()

ggplot(filtered, aes(x= country, y = area)) + geom_density_ridges() +
  coord_cartesian(ylim = c(0,10000), expand = F,
                  default = FALSE)
