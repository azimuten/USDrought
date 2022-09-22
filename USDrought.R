library(tidyverse)
library(maps)
library(mapproj)

#Reading in the Bee data
colony <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2022/2022-01-11/colony.csv')

### Aim: create a map of number of bee colonies across US for each month, 

# get code from R Graph Gallery: https://r-graph-gallery.com/330-bubble-map-with-ggplot2.html


## Group by state and get an average number of colonies

#Get latitude and longitude data for the US states
states <- map_data("state")

#Get the average number of colonies per state (across time)
avg_ColonyNum_per_state <- colony %>%
  group_by(state) %>%
  summarize(avg_ColonyNum = mean(colony_n, na.rm = TRUE))


# #Change the state names to lower case
# avg_ColonyNum_per_state$region <- str_to_lower(avg_ColonyNum_per_state$state)

#Got US state centriods from here: https://developers.google.com/public-data/docs/canonical/states_csv
UScentriod <- read.csv("UScentroid.csv")
## REMOVE THE SECOND DOT IN THE COORDINATES

# #Join the colony and map data
avg_ColonyNum_per_state <- left_join(avg_ColonyNum_per_state, UScentroid, 
                                      by = c("state" = "name"))
  

ggplot() +
  geom_polygon(data = states, aes(x=long, 
                                  y = lat, 
                                  group = group), 
               fill="grey", 
               alpha=0.3) +
  geom_point( data=avg_ColonyNum_per_state, aes(x=longitude, 
                                                y=latitude, 
                                                color = avg_ColonyNum, 
                                                size = avg_ColonyNum)) +
  scale_colour_viridis_c() +
  theme_void() + coord_map() 
  





## Example of map of states

   print()
# avg_ColonyNum_per_state %>%
#   left_join(airports, by = c("dest" = "faa")) %>%
#   ggplot(aes(lon, lat, size = avg_ColonyNum, color = avg_ColonyNum)) +
#   borders("state") +
#   geom_point() +
#   coord_quickmap() +
#   theme_bw(13) +
#   scale_color_viridis_c(direction = -1)











#Reading in the Drought data
drought_fips <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2022/2022-06-14/drought-fips.csv')
drought <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2022/2022-06-14/drought.csv')
