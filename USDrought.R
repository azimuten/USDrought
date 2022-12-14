library(tidyverse)
library(maps)
library(mapproj)

#Reading in the Bee data
colony <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2022/2022-01-11/colony.csv')

#Reaading in drought data
drought_fips <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2022/2022-06-14/drought-fips.csv')


#Get latitude and longitude data for the US states
states <- map_data("state")

#Get the number of colonies and number of colonies lost per state per year
avg_ColonyNum_per_state <- colony %>%
  group_by(state, year) %>%
  summarize(total_col_lost = sum(colony_lost, na.rm = TRUE),
            total_col_n = sum(colony_n, na.rm = TRUE))

#Calculate percentage of lost colony
avg_ColonyNum_per_state$pct_lost <- (avg_ColonyNum_per_state$total_col_lost / 
                                       avg_ColonyNum_per_state$total_col_n) * 100

#Got US state centriods from here: https://developers.google.com/public-data/docs/canonical/states_csv
install.packages("datapasta")
library(datapasta)
Uscentroid <- data.frame(
  stringsAsFactors = FALSE,
                                state = c("AK","AL","AR","AZ","CA",
                                          "CO","CT","DC","DE","FL","GA",
                                          "HI","IA","ID","IL","IN","KS","KY",
                                          "LA","MA","MD","ME","MI","MN",
                                          "MO","MS","MT","NC","ND","NE",
                                          "NH","NJ","NM","NV","NY","OH","OK",
                                          "OR","PA","PR","RI","SC","SD",
                                          "TN","TX","UT","VA","VT","WA",
                                          "WI","WV","WY"),
                             latitude = c(63.588753,32.318231,35.20105,
                                          34.048928,36.778261,39.550051,
                                          41.603221,38.905985,38.910832,27.664827,
                                          32.157435,19.898682,41.878003,
                                          44.068202,40.633125,40.551217,
                                          39.011902,37.839333,31.244823,42.407211,
                                          39.045755,45.253783,44.314844,
                                          46.729553,37.964253,32.354668,46.879682,
                                          35.759573,47.551493,41.492537,
                                          43.193852,40.058324,34.97273,38.80261,
                                          43.299428,40.417287,35.007752,
                                          43.804133,41.203322,18.220833,41.580095,
                                          33.836081,43.969515,35.517491,
                                          31.968599,39.32098,37.431573,44.558803,
                                          47.751074,43.78444,38.597626,
                                          43.075968),
                            longitude = c(-154.493062,-86.902298,
                                          -91.831833,-111.093731,-119.417932,
                                          -105.782067,-73.087749,-77.033418,
                                          -75.52767,-81.515754,-82.907123,
                                          -155.665857,-93.097702,-114.742041,-89.398528,
                                          -85.602364,-98.484246,-84.270018,
                                          -92.145024,-71.382437,-76.641271,
                                          -69.445469,-85.602364,-94.6859,
                                          -91.831833,-89.398528,-110.362566,
                                          -79.0193,-101.002012,-99.901813,-71.572395,
                                          -74.405661,-105.032363,-116.419389,
                                          -74.217933,-82.907123,-97.092877,
                                          -120.554201,-77.194525,-66.590149,
                                          -71.477429,-81.163725,-99.901813,
                                          -86.580447,-99.901813,-111.093731,
                                          -78.656894,-72.577841,-120.740139,
                                          -88.787868,-80.454903,-107.290284),
                                 name = c("Alaska","Alabama","Arkansas",
                                          "Arizona","California","Colorado",
                                          "Connecticut","District of Columbia",
                                          "Delaware","Florida","Georgia",
                                          "Hawaii","Iowa","Idaho","Illinois",
                                          "Indiana","Kansas","Kentucky",
                                          "Louisiana","Massachusetts","Maryland",
                                          "Maine","Michigan","Minnesota",
                                          "Missouri","Mississippi","Montana",
                                          "North Carolina","North Dakota","Nebraska",
                                          "New Hampshire","New Jersey",
                                          "New Mexico","Nevada","New York","Ohio",
                                          "Oklahoma","Oregon","Pennsylvania",
                                          "Puerto Rico","Rhode Island",
                                          "South Carolina","South Dakota",
                                          "Tennessee","Texas","Utah","Virginia",
                                          "Vermont","Washington","Wisconsin",
                                          "West Virginia","Wyoming")
                   )



# #Join the colony and map data
avg_ColonyNum_per_state <- left_join(avg_ColonyNum_per_state, UScentroid, 
                                      by = c("state" = "name"))
  
#Remove Hawaii
avg_ColonyNum_per_state <- avg_ColonyNum_per_state %>% filter(state != "Hawaii")

###Get drought score for 2015-2021

#remove everything but year
drought_fips$date <- str_sub(drought_fips$date, end = -7)

#remove years before 2015 and after 2021
drought_fips <- drought_fips %>% filter(date > 2014 & date < 2022)

#Calculate mean drought score
drought_fips1 <- drought_fips %>%
  group_by(date, State) %>%
  summarize(mDSCI = mean(DSCI, na.rm = TRUE))

#Get state name from UScentroid data
drought_fips1 <- left_join(drought_fips1, UScentroid, by = c("State" = "state"))
drought_fips1$latitude = NULL
drought_fips1$longitude = NULL
colnames(drought_fips1) [1] = "year"
drought_fips1$name <- str_to_lower(drought_fips1$name)

#Remove Hawaii and alaska
drought_fips1 <- drought_fips1 %>% filter(name != "hawaii")
drought_fips1 <- drought_fips1 %>% filter(name != "alaska")

states1 <- left_join(states, drought_fips1, by = c("region" = "name"))

states1$year <- as.numeric(states1$year)

install.packages("devtools")
library(devtools)
devtools::install_github("thomasp85/transformr")
install.packages("gganimate")
library(gganimate)
install.packages("RColorBrewer")
library("RColorBrewer")

plot <- ggplot() +
  geom_polygon(data = states1, aes(x=long, 
                                  y = lat, 
                                  group = group,
                                  fill = mDSCI,
                                  ), alpha=0.6) +
  scale_fill_viridis_c(option = "inferno", trans = "reverse") +
  guides(guide_legend(title = "Mean Drought Score")) +

  
geom_point(data=avg_ColonyNum_per_state, aes(x=longitude, 
                                                 y=latitude, 
                                                 color = pct_lost,
                                                 size = pct_lost
  ) +

  borders("state") +
  scale_colour_viridis_c(trans = "reverse") +
  theme_void() + coord_map() +
  theme(plot.title = element_text(hjust = 0.5)) +
  labs(title = "Drought & Bee Colonies Year {frame_time}", 
       color = "% Bee Colony Lost",
       fill =  "Mean Drought Score",
       size = "% Bee Colony Lost"
       )) +
  transition_time(as.integer(year))
  
animate(plot, height = 576, width = 800, fps = 4)
