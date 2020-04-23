plot_country_dotplot = function(
  d,
  variable = "num_species",
  plot_title = "Europe - Number of Species",
  y_lab = "number of species",
  country_text_size = 10,
  gbif_region = "Europe",
  filter_count = 1e4,
  plot_subtitle = "Unique species with occurrences in country",
  scale_MK = 1e-3,
  unit_MK = "K",
  gain_color =  "#FDAF02",
  comparison_snapshot = "2015-01-19",
  comparison_snapshot_label = "2015"
) {

  d$date %>% unique()

  d = gbifapi::get_gbif_countries() %>%
    select(iso2,title) %>%
    merge(d,id=iso2) %>%
    mutate(date = as.character(date)) %>%
    filter(date == !! comparison_snapshot | date == "2020-01-01") %>%
    group_by(title) %>%
    mutate(order_variable = max(!! rlang::sym(variable))) %>%
    ungroup() %>%
    mutate(title = stringr::str_replace_all(title,", Republic of the","")) %>%
    mutate(title = stringr::str_replace_all(title,", United Republic of","")) %>%
    mutate(title = stringr::str_replace_all(title,"Congo, Democratic Republic of the","DR Congo")) %>%
    mutate(title = stringr::str_replace_all(title,", Islamic Republic of","")) %>%
    mutate(title = stringr::str_replace_all(title,", Bolivarian Republic of","")) %>%
    mutate(title = stringr::str_replace_all(title,", Plurinational State of","")) %>%
    mutate(title = stringr::str_replace_all(title,"Korea, Republic of","South Korea")) %>%
    mutate(title_ = forcats::fct_reorder(title,order_variable)) %>%
    filter(gbif_region == !! gbif_region) %>%
    glimpse() %>%
    select(title_,
           date,
           num_species,
           num_of_occ,
           num_datasets,
           num_species_published,
           num_of_occ_published,
           num_datasets_published)


  countries_to_keep = d %>%
    filter(!! rlang::sym(variable) > !! filter_count) %>%
    pull(title_)

  d = d %>% filter(title_ %in% !! countries_to_keep)

  filler = tibble(
    title_ = unique(d$title_),
    date = "2015-01-19",
    num_of_occ = 0,
    num_species = 0
  )

  d = rbind(d,filler) %>%
    group_by(title_,date) %>%
    summarise(num_of_occ = max(num_of_occ),num_species=max(num_species)) %>%
    glimpse()

  library(ggplot2)
  # geom_bar(stat = "identity", position = position_dodge(preserve = "single")) +
  # expand = c(0.01, 0)
  p = ggplot(d,aes_string("title_",variable,color="date",group="date")) +
    geom_point(size=4) +
    coord_flip() +
    xlab("") +
    ylab(y_lab) +
    theme_bw() +
    theme(legend.position = c(0.9, 0.1)) +
    theme(legend.title=element_blank()) +
    scale_color_manual(labels = c(comparison_snapshot_label, "2020"), values = c("#535362",gain_color)) +
    scale_y_continuous(breaks = scales::pretty_breaks(n = 5),labels = scales::unit_format(unit = unit_MK, scale = scale_MK,accuracy = 1,sep="")) +
    theme(axis.text.x=element_text(face="plain",size=12,color="#535362")) +
    theme(axis.text.y=element_text(face="plain",size=country_text_size,color="#535362")) +
    theme(axis.title.x = element_text(margin = margin(t = 15, r = 0, b = 0, l = 0), size = 12, face="plain",color="#535362")) +
    theme(plot.title = element_text(color="#535362", size=14, face="bold")) +
    labs(title = plot_title,subtitle = plot_subtitle)

  return(p)
}
