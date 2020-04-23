create_isea3h_data = function(res) {

  isea3h = gbifregionalstats::isea3h

  date_line_polygons = gbifregionalstats::find_dateline_polygons(res)

  centroids = isea3h %>%
    filter(res == UQ(res)-1) %>%
    filter(centroid == 1) %>%
    select(id,lonCenter = lon,latCenter = lat) %>%
    mutate(iso2 = gbifapi::reverse_geocode(latCenter,lonCenter)) %>%
    mutate(region = gbifapi::get_continent_name(iso2)) %>%
    glimpse()

  # print(centroids$region %>% unique())

  isea3h = isea3h %>%
    filter(res == UQ(res)-1) %>%
    filter(centroid == 0) %>%
    merge(centroids,id="id",only.x=TRUE) %>%
    mutate(ordering = 1:nrow(.)) %>%
    mutate(res = UQ(res)) %>%
    mutate(date_line_polygon = id %in% date_line_polygons) %>%
    glimpse()

  return(isea3h)
}
