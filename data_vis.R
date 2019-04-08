library(tidyr)
library(dplyr)
library(ggplot2)
library(readr)
library(gridExtra)

# Create data frame for Megahayla region
Year <- c(2001:2018)
l_loss <- c(1.427090017,	1.035702972,	0.5674293525,	3.738315922,	1.94664912,	2.929340464,
          3.724295709,	4.544881004,	1.882976783,	3.430158376,	3.33732629,	1.956030896,
          3.271632595,	5.621536099,	5.94028808,	6.395344242,	6.164168121,	3.97737037)
m_loss <- c(4.873361586, 3.421097485, 1.652784656, 5.269099402, 3.302171072,
           5.384272028, 5.354152532,	9.352939322, 3.638897778,	7.953403538,
           4.837613426,	6.21809593,	11.0628342, 15.84096517,	18.48179334,
           18.32826639,	19.37272264,	16.50837556)
c_loss <- c(0.6161667506, 0.45189958,	0.1886321409,	0.5344447486,	0.5491237747,
            0.7730590484,	0.7046096825,	0.9551966405,	0.1866935015,	0.5142730343,
            0.4560844977,	0.4093576161,	0.5494159674,	1.091311285,	1.538551272,
            2.119459785,	1.386940711,	0.945083388)

loss_data_test <- data.frame(Year, l_loss, m_loss, c_loss)
loss_data_test

#Add percentage values for relative comparison 
percent_loss <- loss_data_test %>%
  mutate(percent_loss_low = (l_loss/1120)*100 ) %>%
  mutate(percent_loss_medium = (m_loss/1705)*100 ) %>%
  mutate(percent_loss_core = (c_loss/149)*100)

View(percent_loss) #looks good

#Reshape the data for visulisation. Tidy it all up. 
data_long <- gather(percent_loss, Treatment, measurement, l_loss:percent_loss_core, factor_key=TRUE)
View(data_long) #looks good 

#filter for the %data and the absolute value data
percent_data <- data_long %>%
  filter(Treatment == "percent_loss_low" | Treatment == "percent_loss_medium" | Treatment == "percent_loss_core")


absolute_data <- data_long %>%
  filter(Treatment == "l_loss" | Treatment == "m_loss" | Treatment == "c_loss")

#Graphs Graphs 
percent_chart <- ggplot(percent_data, aes(x=Year, y= measurement, group= Treatment)) +
  geom_line(stat="identity", aes(col=Treatment), show.legend = FALSE) +
  theme_bw() 
(absolute_chart <- ggplot(absolute_data,
                          aes(x=Year,
                              y= measurement,
                              group= Treatment)) +
    geom_line(stat="identity",
              aes(col=Treatment),
              show.legend = FALSE)+
    theme_bw() + 
    coord_cartesian(xlim = c(2000,2018), ylim = c(0,20), expand = F,
                    default = FALSE)+
    #add a bo showing where the hansen method is improved in detecting small forestry loss
    annotate("rect",
             xmin=c(2012), 
             xmax=c(2018), 
             ymin=c(0), 
             ymax=c(20), 
             alpha=0.2, 
             fill="blue") +
    labs(title = "Area of forest lossed from red panda habitat \nfrom 2000-2018 in Meghalaya India",
         x = "Year", 
         y = expression(km^{2}~forest~loss)))

#Arrange in a grid
test_arrange <- grid.arrange(absolute_chart, percent_chart, ncol = 1) 
