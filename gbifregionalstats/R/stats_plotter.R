stats_plotter = function(D,
                         isea3h = gbifregionalstats::isea3h_res6,
                         variable_ = "num_species",
                         legend_title_="number of species",
                         breaks_ = c(0,5000,60000),
                         filter_column_string = NULL,
                         filter_column_value = NULL,
                         orientation = c(50.72,20,4.5),
                         xlim_ortho = c(-25,70),
                         ylim_ortho = c(75,25),
                         region_value = "Europe"
) {


  D = D %>%
    mutate(id = as.integer(polygon_id)) %>%
    merge(isea3h,id=polygon_id,all.y=TRUE) %>%
    select(-region) %>%
    merge(gbifapi::get_gbif_countries() %>%
    select(iso2,region = gbifRegion),all.x=TRUE) %>%
    mutate(long = lon) %>%
    mutate(lat = lat) %>%
    mutate(group = id) %>%
    glimpse() %>%
    filter(
          region == UQ(region_value) |
          !UQ(variable_) == max(UQ(variable_)) |
          id == 496 |
          iso2 == "RU"
          ) %>%
    filter(!date_line_polygon) %>%
    arrange(ordering)

  D %>% glimpse()


  # library(gbifrasters)
  library(ggplot2)

  p = plot_poly_map_gaps(grid = D,
                  variable = variable_,
                  breaks=breaks_,
                  labels=NULL,
                  legend_title=legend_title_,
                  pretty_breaks=7,
                  zoom_x=c(-180,180),
                  zoom_y=c(-55,80),
                  legend.position = c(.50,-0.05),
                  polygon_text_size=2,
                  polygon_alpha=0.6,
                  labelType="fancy",
                  keywidth=0.01,
                  keyheight=0.2,
                  legend_text_size=12,
                  numBreaks=7,
                  breaksType="fancy",
                  country_line_color = "#c3c4c4")

  # p = p + coord_map("ortho",orientation=orientation,xlim=xlim_ortho, ylim=ylim_ortho)
  p = p + coord_map("azequalarea",xlim=xlim_ortho, ylim=ylim_ortho)

  return(p)
}


