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
loss_data <- data.frame(Year, nepal_loss, bhutan_loss, india_loss, burma_loss)
loss_data

#### Add percentage values for relative comparison ####
percent_loss <- loss_data %>%
  mutate(percent_loss_nepal = (nepal_loss/nepal_treecover)*100 ) %>%
  mutate(percent_loss_india = (india_loss/india_treecover)*100 ) %>%
  mutate(percent_loss_bhutan = (bhutan_loss/bhutan_treecover)*100) %>%
  mutate(percent_loss_burma = (burma_loss/burma_treecover)*100) %>%
  mutate(percent_cumulative_nepal = cumsum(percent_loss_nepal)) %>%
  mutate(percent_cumulative_india = cumsum(percent_loss_india)) %>%
  mutate(percent_cumulative_bhutan = cumsum(percent_loss_bhutan)) %>%
  mutate(percent_cumulative_burma = cumsum(percent_loss_burma)) %>%
  mutate(entire_range = ((nepal_loss +india_loss +bhutan_loss+burma_loss)/(nepal_treecover + india_treecover + bhutan_treecover + burma_treecover))*100) %>%
  mutate(percent_cumulative_total = cumsum(entire_range))

write.table(percent_loss, file="total_area_data.csv",sep=",",row.names=T)
View(percent_loss) #looks good

#### Reshape the data for visulisation. Tidy it all up. ####
data_long <- gather(percent_loss, Treatment, measurement, nepal_loss:percent_cumulative_total, factor_key=TRUE)
View(data_long) #looks good 
str(data_long)
#### filter for the %data and the absolute value data####
percent_data <- data_long %>%
  filter(Treatment == "percent_loss_india" | Treatment == "percent_loss_nepal" | Treatment == "percent_loss_bhutan" | Treatment == "percent_loss_burma"| Treatment == "entire_range" ) %>%
  group_by(Treatment, measurement)




#### Graphs ####

#Percentage
(percent_chart <- ggplot(percent_data, 
                         aes(x=Year,
                         y= (measurement),
                         group= Treatment)) +
  geom_line(stat="identity",
            aes(col=Treatment),
            show.legend = T,
            size = 1) +
  theme_bw() + 
  coord_cartesian(xlim = c(2001,2018), expand = F,
                  default = FALSE)+
  #add a box showing where the hansen method is improved in detecting small forestry loss
  annotate("rect",
           xmin=c(2012), 
           xmax=c(2018), 
           ymin=c(0), 
           ymax=c(0.3), 
           alpha=0.2, 
           fill="#a45544") +
  labs(title = "Percentage Forest Lost Per Year",
       x = "Year",
       y = "percent_loss") +
  scale_colour_manual(values =c("#66CDAA", "#00B2EE", "#EE0000", "#000000", "#FF00FF"),
                      name="country",
                      breaks=c("percent_loss_nepal", "percent_loss_india", "percent_loss_bhutan", "percent_loss_burma", "entire_range"),
                      labels=c("Nepal", "India", "Bhutan","Burma", 'entire range') )) 


#Total area
(absolute_chart <- ggplot(absolute_data,
                          aes(x=Year,
                              y= measurement,
                              group= Treatment)) +
    geom_line(stat="identity",
              aes(col=Treatment),
              show.legend = T,
              size = 1) +
    theme_bw() + 
    coord_cartesian(xlim = c(2001,2018), ylim = c(0,20), expand = F,
                    default = FALSE)+
    #add a box showing where the hansen method is improved in detecting small forestry loss
    annotate("rect",
             xmin=c(2012), 
             xmax=c(2018), 
             ymin=c(0), 
             ymax=c(20), 
             alpha=0.2, 
             fill="#a45544") +
    labs(title = "Area of Forest Lost Each Year") +
    scale_colour_manual(values =c("#66CDAA", "#00B2EE", "#EE0000"),
                        name="Habitat\nSuitability",
                        breaks=c("l_loss", "m_loss", "c_loss"),
                        labels=c("Low", "Medium", "High")))

#### Cumulative graphs ####
#Percentage

cum_percent_data <- data_long %>%
  filter(Treatment == "percent_cumulative_nepal" | Treatment == "percent_cumulative_india" | Treatment == "percent_cumulative_bhutan"| Treatment == "percent_cumulative_burma"| Treatment == "percent_cumulative_total")

(cum_percent_chart <- ggplot(cum_percent_data, 
                         aes(x=Year,
                             y= measurement,
                             group= Treatment)) +
   geom_line(stat="identity",
             aes(col=Treatment),
             show.legend = T,
             size = 1) +
   theme_bw() + 
   coord_cartesian(xlim = c(2001,2018), expand = F,
                   default = FALSE)+
   #add a box showing where the hansen method is improved in detecting small forestry loss
   annotate("rect",
            xmin=c(2012), 
            xmax=c(2018), 
            ymin=c(0), 
            ymax=c(2), 
            alpha=0.2, 
            fill="#a45544") +
   labs(title = "Cumulative Percentage Forest Loss",
        x = "Year", 
        y = "% forest loss") +
   scale_colour_manual(values =c("#66CDAA", "#00B2EE", "#EE0000", "#000000", "#FF00FF"),
                       name="Country",
                       breaks=c("percent_cumulative_nepal", "percent_cumulative_india", "percent_cumulative_bhutan", "percent_cumulative_burma", "percent_cumulative_total"),
                       labels=c("Nepal", "India", "Bhutan","Burma", 'entire range') )) 

# total loss 
cum_total_data <- data_long %>%
  filter(Treatment == "total_cumulative_low" | Treatment == "total_cumulative_medium" | Treatment == "total_cumulative_core")

(cum_total_chart <- ggplot(cum_total_data, 
                             aes(x=Year,
                                 y= measurement,
                                 group= Treatment)) +
    geom_line(stat="identity",
              aes(col=Treatment),
              show.legend = F,
              size = 1) +
    theme_bw() + 
    coord_cartesian(xlim = c(2001,2018), expand = F,
                    default = FALSE)+
    #add a box showing where the hansen method is improved in detecting small forestry loss
    annotate("rect",
             xmin=c(2012), 
             xmax=c(2018), 
             ymin=c(0), 
             ymax=c(160), 
             alpha=0.2, 
             fill="#a45544") +
    labs(title = "Cumulative Area of Forest Loss",
         y = expression(km^{2}~forest~loss)) +
    scale_colour_manual(values =c("#66CDAA", "#00B2EE", "#EE0000"),
                        name="Habitat\nSuitability",
                        breaks=c("total_cumulative_low", "total_cumulative_medium", "total_cumulative_core"),
                        labels=c("Low", "Medium", "High") ))



#### Arrange Graphs ####
cumulative_arrange <- grid.arrange(cum_total_chart, absolute_chart, cum_percent_chart, percent_chart,  nrow = 2) 
c("#EE2C2C", "#FFFFFF", "#FFFFFF")

#### Gain to loss ratio for 2000-2013 ####
# Enter in specific values as printed in the GEE Forest Loss Script
low_ratio = 4.57/cum_total_data$measurement[13]
moderate_ratio = 21.79/cum_total_data$measurement[31]
core_ratio = 2.58/cum_total_data$measurement[49]

View(data.frame(low_ratio, moderate_ratio, core_ratio))


