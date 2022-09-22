
#Reading in the Bee data
colony <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2022/2022-01-11/colony.csv')

### Aim: create a map of number of bee colonies across US for each month, 

## Group by state and get an average number of colonies

## Example of map of states
# avg_ColonyNum_per_state <- colony %>%
#   group_by(state) %>%
#   summarize(avg_ColonyNum = mean(colony_n, na.rm = TRUE)) %>%
#   print()
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
