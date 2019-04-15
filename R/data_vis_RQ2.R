Year <- c(2001:2018)
IUCN_VI <- c(0.027088907165527348, 0.06828863139097921, 0.023547218990310967,
             0.3116195273021027, 0.32225754122697425, 0.12619683892558975, 0.08274666723321653,
             0.11364846318814145, 0.20754228915943818, 2.0192376229738698, 0.19686371086952353,
             0.02625190844726562, 0.035651385142367494, 0.07444520295362284, 0.23509224004337073,
             0.6743853536044246, 0.3278547139284619, 0.0354885362302294)
IUCN_II <- c(0.086,0.057, 0.506, 1.020, 1.048, 0.649, 0.26, 0.225, 1.126, 6.764,
             0.6067, 0.24, 0.216, 0.46, 1.0172, 2.4898,2.3395, 0.5704)

IUCN_test <- data.frame(Year, IUCN_VI, IUCN_II)

IUCN_AREA_VI <- 974
IUCN_AREA_II <- 2638

#### Manipulate data ####
percent_loss_IUCN <- IUCN_test %>%
  mutate(percent_loss_II = (IUCN_II/IUCN_AREA_II)*100 ) %>%
  mutate(percent_loss_VI = (IUCN_VI/IUCN_AREA_VI)*100 ) %>%
  mutate(percent_cumulative_II = cumsum(percent_loss_II)) %>%
  mutate(percent_cumulative_VI = cumsum(percent_loss_VI)) %>%
  mutate(total_cumulative_II = cumsum(IUCN_II)) %>%
  mutate(total_cumulative_VI = cumsum(IUCN_VI))

data_long_IUCN <- gather(percent_loss_IUCN, Treatment, measurement, IUCN_VI:total_cumulative_VI, factor_key=TRUE)
View(data_long_IUCN) #looks good 

#### Filter for graphing ####
percent_data_IUCN <- data_long_IUCN %>%
  filter(Treatment == "percent_loss_II" | Treatment == "percent_loss_VI")
cum_percent_data_IUCN <- data_long_IUCN %>%
  filter(Treatment == "percent_cumulative_II" | Treatment == "percent_cumulative_VI")



absolute_data_IUCN <- data_long_IUCN %>%
  filter(Treatment == "IUCN_II" | Treatment == "IUCN_VI" )
cum_absolute_data_IUCN <- data_long_IUCN %>%
  filter(Treatment == "total_cumulative_II" | Treatment == "total_cumulative_VI")
#### Graphs ####


(cum_total_chart_IUCN <- ggplot(cum_absolute_data_IUCN, 
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
             ymax=c(22), 
             alpha=0.2, 
             fill="#a45544") +
    labs(title = "Cumulative Area of Forest Loss",
         y = expression(km^{2}~forest~loss)) +
    scale_colour_manual(values =c("#66CDAA", "#00B2EE"),
                        name="IUCN Category",
                        breaks=c("total_cumulative_II", "total_cumulative_VI"),
                        labels=c("IUCN II", "IUCN VI") ))

(cum_percent_chart_IUCN <- ggplot(cum_percent_data_IUCN, 
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
             ymax=c(12), 
             alpha=0.2, 
             fill="#a45544") +
    labs(title = "Cumulative % of Forest Loss",
         y = "% forest loss") +
    scale_colour_manual(values =c("#66CDAA", "#00B2EE"),
                        name="IUCN Category",
                        breaks=c("percent_cumulative_II", "percent_cumulative_VI"),
                        labels=c("IUCN II", "IUCN VI") ))
(cumulative_arrange_test <- grid.arrange(cum_percent_chart, cum_percent_chart_IUCN,  nrow = 1))

  