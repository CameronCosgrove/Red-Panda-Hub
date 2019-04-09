library(tidyr)
library(dplyr)
library(ggplot2)
library(readr)
library(gridExtra)

#### Create data frame for Megahayla region ####
Year <- c(2001:2018)
l_loss <- c(1.427090017,	1.035702972,	0.5674293525,	3.738315922,	1.94664912,	2.929340464,
          3.724295709,	4.544881004,	1.882976783,	3.430158376,	3.33732629,	1.956030896,
          3.271632595,	5.621536099,	5.94028808,	6.395344242,	6.164168121,	3.97737037)
m_loss <- c(4.873361586, 3.421097485, 1.652784656, 5.269099402, 3.302171072,
           5.384272028, 5.354152532,	9.352939322, 3.638897778,	7.953403538,
           4.837613426,	6.21809593,	11.0628342, 15.84096517,	18.48179334,
           18.32826639,	19.37272264,	16.50837556)
c_loss <- c(0.6161667506, 0.4917,	0.234,	0.707,	0.707,
            1.022,	0.903,	1.16,	0.482,	0.639,
            0.562,	0.463,	1.007,	1.310630,	2.0387,
            2.402,	1.592,	1.11)


loss_data_test <- data.frame(Year, l_loss, m_loss, c_loss)
loss_data_test

#### Add percentage values for relative comparison ####
percent_loss <- loss_data_test %>%
  mutate(percent_loss_low = (l_loss/813.26)*100 ) %>%
  mutate(percent_loss_medium = (m_loss/1351)*100 ) %>%
  mutate(percent_loss_core = (c_loss/147)*100) %>%
  mutate(percent_cumulative_low = cumsum(percent_loss_low)) %>%
  mutate(percent_cumulative_medium = cumsum(percent_loss_medium)) %>%
  mutate(percent_cumulative_core = cumsum(percent_loss_core)) %>%
  mutate(total_cumulative_low = cumsum(l_loss)) %>%
  mutate(total_cumulative_medium = cumsum(m_loss)) %>%
  mutate(total_cumulative_core = cumsum(c_loss))



View(percent_loss) #looks good

####Reshape the data for visulisation. Tidy it all up. ####
data_long <- gather(percent_loss, Treatment, measurement, l_loss:total_cumulative_core, factor_key=TRUE)
View(data_long) #looks good 
str(data_long)
####filter for the %data and the absolute value data####
percent_data <- data_long %>%
  filter(Treatment == "percent_loss_low" | Treatment == "percent_loss_medium" | Treatment == "percent_loss_core") %>%
  group_by(Treatment, measurement)



absolute_data <- data_long %>%
  filter(Treatment == "l_loss" | Treatment == "m_loss" | Treatment == "c_loss")

red_panda_palett <- c("#b67a3e", "#cb9b74", "#f2e0d2", "#a45544", "	#5a1c1a") 

####Graphs ####

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
           ymax=c(1.7), 
           alpha=0.2, 
           fill="#a45544") +
  labs(title = "Percentage Forest Lost Per Year",
       x = "Year", 
       y = "% forest loss") +
  scale_colour_manual(values =c("#66CDAA", "#00B2EE", "#EE0000"),
                      name="Habitat\nSuitability",
                      breaks=c("percent_loss_low", "percent_loss_medium", "percent_loss_core"),
                      labels=c("Low", "Medium", "High") ))


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
    labs(title = "Area of Forest Lost Each Year",
         x = "Year", 
         y = expression(km^{2}~forest~loss)) +
    scale_colour_manual(values =c("#66CDAA", "#00B2EE", "#EE0000"),
                        name="Habitat\nSuitability",
                        breaks=c("l_loss", "m_loss", "c_loss"),
                        labels=c("Low", "Medium", "High")))

#### Cumulative graphs ####
#Percentage

cum_percent_data <- data_long %>%
  filter(Treatment == "percent_cumulative_low" | Treatment == "percent_cumulative_medium" | Treatment == "percent_cumulative_core")

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
            ymax=c(14), 
            alpha=0.2, 
            fill="#a45544") +
   labs(title = "Cumulative Percentage Forest Loss",
        x = "Year", 
        y = "% forest loss") +
   scale_colour_manual(values =c("#66CDAA", "#00B2EE", "#EE0000"),
                       name="Habitat\nSuitability",
                       breaks=c("percent_cumulative_low", "percent_cumulative_medium", "percent_cumulative_core"),
                       labels=c("Low", "Medium", "High") ))

# total loss 
cum_total_data <- data_long %>%
  filter(Treatment == "total_cumulative_low" | Treatment == "total_cumulative_medium" | Treatment == "total_cumulative_core")

(cum_total_chart <- ggplot(cum_total_data, 
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
             ymax=c(160), 
             alpha=0.2, 
             fill="#a45544") +
    labs(title = "Cumulative Area of Forest Loss",
         x = "Year", 
         y = expression(km^{2}~forest~loss)) +
    scale_colour_manual(values =c("#66CDAA", "#00B2EE", "#EE0000"),
                        name="Habitat\nSuitability",
                        breaks=c("total_cumulative_low", "total_cumulative_medium", "total_cumulative_core"),
                        labels=c("Low", "Medium", "High") ))



#### Arrange Graphs ####
cumulative_arrange <- grid.arrange(cum_total_chart, cum_percent_chart,absolute_chart, percent_chart,  nrow = 2) 
c("#EE2C2C", "#FFFFFF", "#FFFFFF")

