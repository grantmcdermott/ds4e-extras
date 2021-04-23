# Libraries ---------------------------------------------------------------

library(tidyverse)
library(sf)
library(tidycensus)
library(tigris)
library(leaflet)
library(mapview)
library(here)

# Oregon leaflet map ------------------------------------------------------

oregon = 
	get_acs(
		geography = "county", variables = "B01003_001",
		state = "OR", geometry = TRUE
		) 

col_pal = colorQuantile(palette = "viridis", domain = oregon$estimate, n = 10)

or =
	oregon %>%
	mutate(county = gsub(",.*", "", NAME)) %>% ## Get rid of everything after the first comma
	st_transform(crs = 4326) %>%
	leaflet(width = "100%") %>%
	addProviderTiles(provider = "CartoDB.Positron") %>%
	addPolygons(
		popup = ~paste0(county, "<br>", "Population: ", prettyNum(estimate, big.mark=",")),
		stroke = FALSE,
		smoothFactor = 0,
		fillOpacity = 0.7,
		color = ~col_pal(estimate)
		) %>%
	addLegend(
		"bottomright", 
		pal = col_pal, 
		values = ~estimate,
		title = "Population percentiles",
		opacity = 1
		) 
or %>%
	mapshot(url = here("spatial/oregon_leaflet.html"))
or %>%
	mapshot(file = here("spatial/oregon_leaflet.png"))
