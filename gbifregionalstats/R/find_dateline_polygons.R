

find_dateline_polygons = function(res = 6) {

  # load("C:/Users/ftw712/Desktop/isea3h.rda")
  isea3h = gbifregionalstats::isea3h

  isea3h = isea3h %>%
    filter(res == UQ(res) - 1) %>% # actually resolution 5 since this data is indexed at 0
    filter(centroid == 0)

  polygon_list = isea3h %>%
    group_split(id) %>%
    map(~ .x %>%
          select(lon,lat) %>%
          as.matrix() %>%
          list() %>%
          st_polygon() %>%
          st_wrap_dateline(options = c("WRAPDATELINE=YES"))
    )

  # polygon_list
  dateline_polygons = st_set_geometry(data.frame(unique(isea3h$id)),st_cast(st_sfc(polygon_list), "MULTIPOLYGON")) %>%
    st_cast("POLYGON") %>%
    as.data.frame() %>%
    group_by(unique.isea3h.id.) %>%
    summarise(count=n()) %>%
    filter(count > 1) %>%
    pull(unique.isea3h.id.)

  dateline_polygons
}
