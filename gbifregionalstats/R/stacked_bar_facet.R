stacked_bar_facet = function(
  d,
  variable = "num_of_occ_published",
  variable_total = "occ_published_total",
  gbif_region = "Asia",
  top_groups = c("Birds","Plants","Insects","Fungi","Mammals"),
  plot_title = "Asia - Number of Published Occurrences",
  plot_subtitle = "Number of occurrences published by country for popular groups",
  country_text_size = 11,
  color_values = c(
    Birds = "#ff9326",
    Plants = "#509E2F",
    Mammals = "#175CA1",
    Insects = "#40BFFF",
    Fungi = "#FDAF02",
    Other = "#ff0040"),
  total_filter = 100e6,
  unit_MK = "M",
  unit_scale = 1e-6,
  no_birds = FALSE
) {

  common_names = gbifapi::get_fuzzy_animals_dataframe()

  if(no_birds) {
    bird_data = d %>%
      filter(taxonkey == 212) %>%
      select(iso2,
             bird_total = !!rlang::sym(variable))

    d = d %>%
      merge(bird_data,id="iso2") %>%
      mutate(!!rlang::sym(variable_total) := !!rlang::sym(variable_total) - bird_total) %>%
      filter(!taxonkey == 212) %>%
      glimpse()
  }

  number_breaks = 5

  d_clean = d %>%
    merge(common_names,id="taxonkey")

  d_top_groups = d_clean %>%
    filter(common_name %in% top_groups) %>%
    mutate(common_name = forcats::fct_relevel(common_name,!!top_groups)) %>%
    select(title,gbif_region,common_name,!! rlang::sym(variable),!! rlang::sym(variable_total)) %>%
    glimpse()

  d_other_fill = d_top_groups %>%
    group_by(title,gbif_region,!!rlang::sym(variable_total)) %>%
    summarise(top_groups_total = sum(!!rlang::sym(variable))) %>%
    ungroup() %>%
    mutate(!!rlang::sym(variable) := !!rlang::sym(variable_total) - top_groups_total) %>%
    mutate(common_name = "Other") %>%
    mutate(common_name = "Other") %>%
    select(title,gbif_region,common_name,!!rlang::sym(variable),!!rlang::sym(variable_total)) %>%
    glimpse()

  d = rbind(d_top_groups,d_other_fill) %>%
    group_by(title) %>%
    mutate(total = sum(!!rlang::sym(variable))) %>%
    ungroup() %>%
    filter(total > !! total_filter) %>%
    mutate(title=gbifapi::clean_country_titles(title)) %>%
    mutate(title = forcats::fct_reorder(title,total)) %>%
    group_by(gbif_region) %>%
    mutate(max_region = max(!! rlang::sym(variable_total))) %>%
    ungroup() %>%
    mutate(gbif_region = forcats::fct_reorder(gbif_region,-max_region)) %>%
    na.omit() %>%
    glimpse()

  breaks = scales::pretty_breaks(n = number_breaks)(c(0,d[[variable_total]]))
  labels = gbifapi::plot_label_maker(breaks,unit_MK,unit_scale)

  library(ggplot2)

  p = ggplot(d, aes(!!rlang::sym(variable),title,fill=common_name)) +
    geom_col(position = position_stack(reverse = TRUE)) +
    scale_x_continuous(
      expand = c(0.01,0.01),
      breaks = breaks,
      labels = labels
    ) +
    labs(title = plot_title,
         subtitle = plot_subtitle,
         caption =
           "all with >1M occurrences\ndata from 2020") +
    theme(plot.caption = element_text(hjust = 1, size=8,lineheight = 0.8)) +
    scale_fill_manual(values = color_values) +
    xlab("number of occurrences") +
    theme_bw() +
    theme(legend.position = "top") +
    theme(legend.justification = c(0, 0)) +
    theme(legend.title=element_blank()) +
    guides(fill = guide_legend(nrow = 2)) +
    theme(axis.title.y=element_blank()) +
    theme(legend.text=element_text(size=13,color="#535362",face="plain")) +
    theme(axis.text.x=element_text(face="plain",size=12,color="#535362")) +
    theme(axis.title.x = element_text(
      margin = margin(t = 15, r = 0, b = 0, l = 0),
      size = 12, face="plain",color="#535362")) +
    theme(plot.title = element_text(color="#535362", size=12, face="bold")) +
    theme(plot.subtitle = element_text(margin = margin(t = 0, r = 0, b = 10, l = 0))) +
    theme(axis.text.y=element_text(face="plain",size=country_text_size,color="#535362")) +
    theme(plot.margin = unit(c(0.2,0.4,0.2,0.2), "cm")) +
     facet_grid(gbif_region ~ .,scales="free",space = "free") +
      theme(
      strip.background = element_blank(),
      strip.text.x = element_blank(),
      strip.text = element_blank())

  return(p)

}







