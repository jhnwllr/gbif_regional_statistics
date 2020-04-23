plot_country_dotplot = function(
  d,
  variable = "num_species",
  plot_title = "Europe - Number of Species",
  y_lab = "number of species",
  country_text_size = 10,
  gbif_region = "Europe",
  filter_count = 1e4,
  plot_subtitle = "Unique species with occurrences in country",
  unit_MK = "M",
  unit_scale = 1e-3,
  gain_color =  "#FDAF02",
  comparison_snapshot = "2015-01-19",
  comparison_snapshot_label = "2015",
  plot_lower = FALSE
) {

  if(gbif_region == "Global") {

    d = gbifapi::get_gbif_countries() %>%
      select(iso2,title) %>%
      merge(d,id=iso2) %>%
      mutate(title = gbifapi::clean_country_titles(title)) %>%
      mutate(date = as.character(date)) %>%
      filter(date == !! comparison_snapshot | date == "2020-01-01") %>%
      select(title,
             date,
             species_count,
             occ_count,
             species_count_published,
             occ_count_published
      )
  } else {

  d = gbifapi::get_gbif_countries() %>%
      select(iso2,title) %>%
      merge(d,id=iso2) %>%
      mutate(title = gbifapi::clean_country_titles(title)) %>%
      mutate(date = as.character(date)) %>%
      filter(gbif_region == !! gbif_region) %>%
      filter(date == !! comparison_snapshot | date == "2020-01-01") %>%
      select(title,
              date,
              species_count,
              occ_count,
              species_count_published,
              occ_count_published

                       )
  }

  countries_to_keep = d %>%
    filter(!! rlang::sym(variable) > !! filter_count) %>%
    pull(title)


  countries_to_keep = d %>%
    filter(!! rlang::sym(variable) > !! filter_count) %>%
    pull(title)

  d = d %>% filter(title %in% !! countries_to_keep)

  filler = tibble(
    title = unique(d$title),
    date = "2015-01-19",
    occ_count = 0,
    species_count = 0,
    species_count_published = 0,
    occ_count_published = 0
  )

  d = rbind(d,filler) %>%
    group_by(title,date) %>%
    summarise(occ_count = max(occ_count),
              species_count=max(species_count),
              occ_count_published=max(occ_count_published,na.rm=TRUE),
              species_count_published=max(species_count_published,na.rm=TRUE)) %>%
    na.omit()

  d = d %>%
    group_by(title) %>%
    mutate(order_variable = max(!! rlang::sym(variable))) %>%
    ungroup() %>%
    mutate(title_ = forcats::fct_reorder(title,order_variable))

  print(glimpse(d))

  breaks = scales::pretty_breaks(n = 7)(c(0,d[[variable]]))
  labels = gbifapi::plot_label_maker(breaks,unit_MK,unit_scale)

  library(ggplot2)
  p = ggplot(d,aes_string("title_",variable,color="date",group="date")) +
    geom_point(size=3) +
    coord_flip() +
    xlab("") +
    ylab(y_lab) +
    theme_bw() +
    theme(legend.position = c(0.9, 0.1)) +
    theme(legend.title=element_blank()) +
    scale_color_manual(labels = c(comparison_snapshot_label, "2020"), values = c("#535362",gain_color)) +
    scale_y_continuous(breaks = breaks,labels=labels) +
    theme(axis.text.x=element_text(face="plain",size=12,color="#535362")) +
    theme(axis.text.y=element_text(face="plain",size=country_text_size,color="#535362")) +
    theme(axis.title.x = element_text(margin = margin(t = 15, r = 0, b = 0, l = 0), size = 12, face="plain",color="#535362")) +
    theme(plot.title = element_text(color="#535362", size=11, face="bold")) +
    labs(title = plot_title,subtitle = plot_subtitle)

  return(p)
}
