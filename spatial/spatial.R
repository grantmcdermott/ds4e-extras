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


# Lane county leaflet map -------------------------------------------------

lane = 
	get_acs(
		geography = "tract", variables = "B25077_001", 
		state = "OR", county = "Lane County", geometry = TRUE
	)

lane_pal = colorNumeric(palette = "plasma", domain = lane$estimate)

l =
	lane %>%
	mutate(tract = gsub(",.*", "", NAME)) %>% ## Get rid of everything after the first comma
	st_transform(crs = 4326) %>%
	leaflet(width = "100%") %>%
	addProviderTiles(provider = "CartoDB.Positron") %>%
	addPolygons(
		# popup = ~tract,
		popup = ~paste0(tract, "<br>", "Median value: $", prettyNum(estimate, big.mark=",")),
		stroke = FALSE,
		smoothFactor = 0,
		fillOpacity = 0.5,
		color = ~lane_pal(estimate)
	) %>%
	addLegend(
		"bottomright", 
		pal = lane_pal, 
		values = ~estimate,
		title = "Median home values<br>Lane County, OR",
		labFormat = labelFormat(prefix = "$"),
		opacity = 1
	)
l %>%
	mapshot(url = here("spatial/lane_leaflet.html"))
l %>%
	mapshot(file = here("spatial/lane_leaflet.png"))

# * mapview version -------------------------------------------------------

# https://github.com/r-spatial/mapview/issues/321
mapviewOptions(fgb = FALSE)
l_mv =
	mapview::mapview(lane, zcol = "estimate", 
									 layer.name = 'Median home values<br>Lane County, OR')
l_mv %>%
	mapshot(url = here("spatial/lane_mapview.html"))
l_mv %>%
	mapshot(file = here("spatial/lane_mapview.png"))
