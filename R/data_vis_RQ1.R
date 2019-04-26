#### Data Vis Script Details: ####
#     .--.             .--.      
#     '.    `   --  `    .'
#       /'   _        _  `\
#     /  ~ \\        // ~  \
#     |/    {}/    \{}    \|
#     |/_   /'       `\  _\|
#     \   | .  .==.  . |  /
#      '._ \.' \__/ './ _.'
#           '._-''-_.'``  
#              '---'                     (adapted from from jgs @ asciiart)
#This script has been created by Cameron Cosgrove (s1427163@sms.ed.ac.uk)
#to graph forest loss data from red panda habitats. 

#### Packages ####

library(tidyr)
library(dplyr)
library(ggplot2)
library(readr)
library(gridExtra)
library(sjPlot)


#### Input data and make a data frame ####
Year <- c(2001:2018)
nepal_gain <- 9.24
nepal_treecover <- 13934.22
nepal_loss <- c(2.559335104,	2.667599036,	5.926754595,	4.490490745,	5.821683786,	5.739870572,	6.875078657,	3.364418914,	12.525476,	3.56764509,	2.237395965,	9.387846205,	1.115411371,	1.489671842,	3.752692236,	5.630841002,	10.70599577,	4.517010614)
india_gain <-52.87
india_treecover <-29411.6
india_loss <- c(16.85720014,	13.29837125	,13.00672213,	22.33217587	,18.40466614,	20.22432114,	29.54191728,	26.67453272,	17.00848408,	20.92708779,	15.52936119,	16.92811712,	18.66403816,	26.1458632,	27.22413093,	34.28782186,	52.08685438,	33.72982733)
bhutan_gain <- 4.74
bhutan_treecover <- 11066.73
bhutan_loss<- c(0.8353046843,	0.9577895593,	1.404081816,	3.984356069,	3.71078244,	3.359286256,	1.977622369,	2.34894297,	4.303208189,	20.48741514,	2.978873587,	1.53122877,	1.09462829,	2.606706952,	2.059110023,	7.222615429,	8.469527001,	3.127026544)
burma_gain <- 89.115
burma_treecover <- 19017.723
burma_loss <- c(5.035765532,	7.550812792,	5.442634487,	16.01660513,	8.098995089,	12.99401878,	14.69998513,	11.68060962,	24.1071898,	16.44055283,	18.4873353,	26.90063435,	29.81116613,	21.68378103,	21.93754604,	26.6295307,	23.26260542,	12.26570447)
china_fulgens_gain <- 34.33
china_fulgens_treecover <- 37187.9
china_fulgens_loss <- c(20.08413432,	22.46674665,	20.27366286,	30.73080507,	25.86094583,	56.55531042,	44.24541258,	30.4369143,	45.57692703,	28.64421245,	16.15988545,	30.41366952,	18.17085901,	15.05683519,	9.062010514,	45.75951509,	44.42173668,	16.26905059)
china_styani_gain <- 38.5479
china_styani_treecover <-  24262.622
china_styani_loss <- c(5.898417729,	9.725619035,	3.440161424,	4.203390676,	16.08396715,	12.88292094,	14.65404204,	131.4677872,	39.54747806,	17.61399922,	26.69955445,	17.5789718,	7.139608087,	7.695306731,	4.497781104,	8.253705752,	8.973815036,	5.511382039)
loss_data <- data.frame(Year, nepal_loss, bhutan_loss, india_loss, burma_loss, china_fulgens_loss, china_styani_loss)
loss_data

#### Add percentage values for relative comparison ####
percent_loss <- loss_data %>%
  mutate(percent_loss_nepal = (nepal_loss/nepal_treecover)*100 ) %>%
  mutate(percent_loss_india = (india_loss/india_treecover)*100 ) %>%
  mutate(percent_loss_bhutan = (bhutan_loss/bhutan_treecover)*100) %>%
  mutate(percent_loss_burma = (burma_loss/burma_treecover)*100) %>%
  mutate(percent_loss_china_fulgens = (china_fulgens_loss/china_fulgens_treecover)*100)%>%
  mutate(percent_loss_china_styani = (china_styani_loss/china_styani_treecover)*100)%>%
  mutate(percent_cumulative_nepal = cumsum(percent_loss_nepal)) %>%
  mutate(percent_cumulative_india = cumsum(percent_loss_india)) %>%
  mutate(percent_cumulative_bhutan = cumsum(percent_loss_bhutan)) %>%
  mutate(percent_cumulative_burma = cumsum(percent_loss_burma)) %>%
  mutate(percent_cumulative_china_fulgens = cumsum(percent_loss_china_fulgens)) %>%
  mutate(percent_cumulative_china_styani = cumsum(percent_loss_china_styani)) %>%
  mutate(percent_gain = ((nepal_gain + bhutan_gain +burma_gain + china_fulgens_gain +china_styani_gain +india_gain)/(nepal_treecover + india_treecover + bhutan_treecover + burma_treecover + china_fulgens_treecover + china_styani_treecover))*100)%>%
  mutate(entire_range = ((nepal_loss +india_loss +bhutan_loss+burma_loss+china_fulgens_loss+china_styani_loss)/(nepal_treecover + india_treecover + bhutan_treecover + burma_treecover + china_fulgens_treecover + china_styani_treecover))*100) %>%
  mutate(percent_cumulative_total = cumsum(entire_range))

write.table(percent_loss, file="total_area_data.csv",sep=",",row.names=T)


#### Reshape the data for visulisation. Tidy it all up. ####
data_long <- gather(percent_loss, Treatment, measurement, nepal_loss:percent_cumulative_total, factor_key=TRUE)
View(data_long) #looks good 
str(data_long)
#### filter for the %data and the absolute value data####
percent_data <- data_long %>%
  filter(Treatment == "percent_loss_india" | Treatment == "percent_loss_nepal" | Treatment == "percent_loss_bhutan" | Treatment == "percent_loss_burma"| Treatment == "percent_loss_china_fulgens" | Treatment == "percent_loss_china_styani" | Treatment == "entire_range") %>%
  group_by(Treatment, measurement)
percent_entire_data <- data_long %>%
  filter(Treatment == "entire_range")
#### Graphs ####

colour_theme <- c("#D43B3534", "#8D37FC52", "#18D9C667", "#D9E0196F", "#45FF5145", "#FF970557", '#BB00FF')


#Percentage
ggplot(percent_data, 
                         aes(x=Year,
                         y= (measurement),
                         group= Treatment)) +
  geom_line(stat="identity",
            aes(col=Treatment),
            show.legend = T,
            size = .5) +
  coord_cartesian(xlim = c(2001,2018), expand = F,
                  default = FALSE)+
  geom_smooth(data = percent_entire_data, method = lm, colour = "#7D7D7D", size = .5, fill = "#F0F0F0", alpha = 0.6) +
  scale_x_continuous(breaks = as.numeric(Year), labels = c("01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11","12","13", "14", "15","16","17","18")) +
  #add a box showing where the hansen method is improved in detecting small forestry loss
 
  labs(title = " ",
       x = "\n Year",
       y = "% Forest Loss \n ") +
  scale_colour_manual(values =c("#D43B3534", "#8D37FC52", "#18D9C667", "#D9E0196F", "#45FF5145", "#8C69086E", '#141414'),
                      name="Country",
                      breaks=c("entire_range","percent_loss_nepal", "percent_loss_india", "percent_loss_bhutan", "percent_loss_burma", "percent_loss_china_fulgens", "percent_loss_china_styani"),
                      labels=c('Entire Range', "Nepal", "India", "Bhutan","Burma","China (A.Fulgens)", "China (A.Styani)")) +
  geom_line(data = percent_entire_data, aes(color=name), color='#141414', size=1.4 ) + 
  theme(
    panel.grid.major.x = element_blank(), # Vertical major grid lines
    panel.grid.major.y = element_blank(), # Horizontal major grid lines
    panel.grid.minor.x = element_blank(), # Vertical minor grid lines
    panel.grid.minor.y = element_blank(),
    axis.line = element_line(colour = "black"),
    plot.background = element_rect(fill = "#FFFFFF"),
    panel.background = element_rect(fill = "#FFFFFF"),
    strip.background = element_rect(fill = "#FFFFFF"),
    legend.key = element_rect(fill = "#FFFFFF")) 
  
  
#theme(panel.grid.major  = element_blank(), panel.grid.minor = element_blank())

# + geom_smooth(mapping = NULL, data = percent_entire_data, method = "lm")



#### Cumulative graphs ####
#Percentage

cum_percent_data <- data_long %>%
  filter(Treatment == "percent_cumulative_nepal" | Treatment == "percent_cumulative_india" | Treatment == "percent_cumulative_bhutan"| Treatment == "percent_cumulative_burma"| Treatment == "percent_cumulative_china_fulgens"| Treatment == "percent_cumulative_china_styani"| Treatment == "percent_cumulative_total")

cum_percent_total <- data_long %>%
  filter(Treatment == "percent_cumulative_total")

ggplot(cum_percent_data, 
                         aes(x=Year,
                             y= measurement,
                             group= Treatment)) +
   geom_line(stat="identity",
             aes(col=Treatment),
             show.legend = T,
             size = .5)  +
    coord_cartesian(xlim = c(2001,2018), expand = F,
                    default = FALSE)+
    scale_x_continuous(breaks = as.numeric(Year), labels = c("01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11","12","13", "14", "15","16","17","18")) +
    #add a box showing where the hansen method is improved in detecting small forestry loss
   
  
    labs(title = " ",
         x = "\n Year",
         y = "% Cumulative Forest Loss \n ") +
    scale_colour_manual(values =c("#D43B3534", "#8D37FC52", "#18D9C667", "#D9E0196F", "#45FF5145", "#8C69086E", '#141414'),
                        name="Country",
                        breaks=c("percent_cumulative_total","percent_cumulative_nepal", "percent_cumulative_india", "percent_cumulative_bhutan", "percent_cumulative_burma", "percent_cumulative_china_fulgens", "percent_cumulative_china_styani"),
                        labels=c('Entire Range', "Nepal", "India", "Bhutan","Burma","China (A.Fulgens)", "China (A.Styani)")) +
    geom_line(data = cum_percent_total, aes(color=name), color='#141414', size=1.4 ) +
   annotate("pointrange", x = 2013, y = 0.1696631, ymin = 0.1696631, ymax = 0.1696631, colour = "green", size = .5, shape = 3)+
    theme(
      panel.grid.major.x = element_blank(), # Vertical major grid lines
      panel.grid.major.y = element_blank(), # Horizontal major grid lines
      panel.grid.minor.x = element_blank(), # Vertical minor grid lines
      panel.grid.minor.y = element_blank(),
      axis.line = element_line(colour = "black"),
      plot.background = element_rect(fill = "#FFFFFF"),
      panel.background = element_rect(fill = "#FFFFFF"),
      strip.background = element_rect(fill = "#FFFFFF"),
      legend.key = element_rect(fill = "#FFFFFF")) 
  




#### Arrange Graphs ####
cumulative_arrange <- grid.arrange(x, y,  nrow = 1) 


#### Gain to loss ratio for 2000-2013 ####
# Enter in specific values as printed in the GEE Forest Loss Script
low_ratio = 4.57/cum_total_data$measurement[13]
moderate_ratio = 21.79/cum_total_data$measurement[31]
core_ratio = 2.58/cum_total_data$measurement[49]

View(data.frame(low_ratio, moderate_ratio, core_ratio))

###### Models ####

#filter data
lm_data <- data_long %>%
  filter(Treatment == "entire_range") %>%
  mutate(log_loss = log10(measurement))
str(lm_data)
#Check distrubution. Does a transformation look nessesary? If so add to pipe above
ggplot(lm_data, aes(x = Year, y = log_loss)) + geom_line()

#run models 
is_loss_increasing_lm <- lm(measurement ~ Year, data = lm_data)
log_is_loss_increasing_lm <- lm(log_loss ~ Year, data = lm_data)

cor.test(lm_data$log_loss, lm_data$Year)

summary(is_loss_increasing_lm)
summary(log_is_loss_increasing_lm)

#assumptions met?
lm.resid <- resid(log_is_loss_increasing_lm)
shapiro.test(lm.resid) #null of normal dist not rejected

plot(log_is_loss_increasing_lm)
(fe.effects <- plot_model(log_is_loss_increasing_lm, show.values = F))
