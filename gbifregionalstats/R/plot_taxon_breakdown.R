
plot_taxon_breakdown = function(
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
  unit_scale = 1e-6
) {

  ########################################

  common_names = gbifapi::get_fuzzy_animals_dataframe()

  if(gbif_region == "Global") {
    number_breaks = 5
    d_clean = d %>%
      merge(common_names,id="taxonkey") %>%
      glimpse()
    country_text_size = 10
    total_filter = 5e6
  } else {
    number_breaks = 7
    d_clean = d %>%
      filter(gbif_region == !! gbif_region) %>%
      merge(common_names,id="taxonkey") %>%
      glimpse()
  }

  d_top_groups = d_clean %>%
    filter(common_name %in% top_groups) %>%
    mutate(common_name = forcats::fct_relevel(common_name,!!top_groups)) %>%
    select(title,common_name,!! rlang::sym(variable),!! rlang::sym(variable_total)) %>%
    glimpse()

  d_other_fill = d_top_groups %>%
    group_by(title,!!rlang::sym(variable_total)) %>%
    summarise(top_groups_total = sum(!!rlang::sym(variable))) %>%
    ungroup() %>%
    mutate(!!rlang::sym(variable) := !!rlang::sym(variable_total) - top_groups_total) %>%
    mutate(common_name = "Other") %>%
    select(title,common_name,!!rlang::sym(variable),!!rlang::sym(variable_total)) %>%
    glimpse()

  d = rbind(d_top_groups,d_other_fill) %>%
    group_by(title) %>%
    mutate(total = sum(!!rlang::sym(variable))) %>%
    ungroup() %>%
    filter(total > !! total_filter) %>%
    mutate(title=gbifapi::clean_country_titles(title)) %>%
    mutate(title = forcats::fct_reorder(title,total)) %>%
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
    labs(title = plot_title,subtitle = plot_subtitle) +
    scale_fill_manual(values = color_values) +
    xlab("number of occurrences") +
    theme_bw() +
    theme(legend.position = c(0.72, 0.15)) +
    theme(legend.title=element_blank()) +
    guides(fill = guide_legend(nrow = 3)) +
    theme(axis.title.y=element_blank()) +
    theme(legend.text=element_text(size=13,color="#535362",face="plain")) +
    theme(axis.text.x=element_text(face="plain",size=12,color="#535362")) +
    theme(axis.title.x = element_text(
      margin = margin(t = 15, r = 0, b = 0, l = 0),
      size = 12, face="plain",color="#535362")) +
    theme(plot.title = element_text(color="#535362", size=12, face="bold")) +
    theme(axis.text.y=element_text(face="plain",size=country_text_size,color="#535362")) +
    theme(plot.margin = unit(c(0.2,0.4,0.2,0.2), "cm"))

  # p = p + facet_grid(.~gbif_region)

  return(p)
}


#
# plot_taxon_breakdown_1 = function(
#   d,
#   variable = "num_of_occ_published",
#   variable_total = "occ_published_total",
#   gbif_region = "Asia",
#   top_groups = c("Birds","Plants","Insects","Fungi","Mammals"),
#   plot_title = "Asia - Number of Published Occurrences",
#   plot_subtitle = "Number of occurrences published by country for popular groups",
#   country_text_size = 11,
#   color_values = c(
#     Birds = "#ff9326",
#     Plants = "#509E2F",
#     Mammals = "#175CA1",
#     Insects = "#40BFFF",
#     Fungi = "#FDAF02",
#     Other = "#ff0040"),
#   total_filter = 500e3,
#   unit_MK = "M",
#   unit_scale = 1e-6
# ) {
#
#   ########################################
#
#   common_names = gbifapi::get_fuzzy_animals_dataframe()
#
#   d_clean = d %>% filter(gbif_region == !! gbif_region) %>%
#     merge(common_names,id="taxonkey") %>%
#     glimpse()
#
#   # mutate(common_name = forcats::fct_reorder(common_name,-.[[variable]])) %>%
#   d_top_groups = d_clean %>%
#     filter(common_name %in% top_groups) %>%
#     mutate(common_name = forcats::fct_relevel(common_name,!!top_groups)) %>%
#     select(title,common_name,!! rlang::sym(variable),!! rlang::sym(variable_total)) %>%
#     glimpse()
#
#   d_other_fill = d_top_groups %>%
#     group_by(title,!!rlang::sym(variable_total)) %>%
#     summarise(top_groups_total = sum(!!rlang::sym(variable))) %>%
#     ungroup() %>%
#     mutate(!!rlang::sym(variable) := !!rlang::sym(variable_total) - top_groups_total) %>%
#     mutate(common_name = "Other") %>%
#     select(title,common_name,!!rlang::sym(variable),!!rlang::sym(variable_total)) %>%
#     glimpse()
#
#   d = rbind(d_top_groups,d_other_fill) %>%
#     group_by(title) %>%
#     mutate(total = sum(!!rlang::sym(variable))) %>%
#     ungroup() %>%
#     filter(total > !! total_filter) %>%
#     mutate(title=gbifapi::clean_country_titles(title)) %>%
#     mutate(title = forcats::fct_reorder(title,total)) %>%
#     glimpse()
#
#   breaks = scales::pretty_breaks(n = 7)(c(0,d[[variable_total]]))
#   labels = scales::unit_format(unit = unit_MK, scale = unit_scale,accuracy = 1,sep="")(breaks) %>%
#     stringr::str_replace_all(stringr::regex("^0M$"),"0") %>%
#     stringr::str_replace_all(stringr::regex("^0K$"),"0") %>%
#     stringr::str_replace_all(stringr::regex("^1 000K$"),"1M") %>%
#     stringr::str_replace_all(stringr::regex("^2 000K$"),"2M") %>%
#     stringr::str_replace_all(stringr::regex("^3 000K$"),"3M") %>%
#     stringr::str_replace_all(stringr::regex("^4 000K$"),"4M") %>%
#     stringr::str_replace_all(stringr::regex("^5 000K$"),"5M") %>%
#     stringr::str_replace_all(stringr::regex("^1 000M$"),"1B") %>%
#     stringr::str_replace_all(stringr::regex("^2 000M$"),"2B")
#
#
#   # breaks = scales::pretty_breaks(n = 7)(d[[variable_total]])
#   # labels = scales::unit_format(unit = "M", scale = 1e-6,accuracy = 1,sep="")(breaks)
#
#   library(ggplot2)
#
#   p = ggplot(d, aes(!!rlang::sym(variable),title,fill=common_name)) +
#     geom_col(position = position_stack(reverse = TRUE)) +
#     scale_x_continuous(
#       expand = c(0.01,0.01),
#       breaks = breaks,
#       labels = labels
#     ) +
#     labs(title = plot_title,subtitle = plot_subtitle) +
#     scale_fill_manual(values = color_values) +
#     xlab("number of occurrences") +
#     theme_bw() +
#     theme(legend.position = c(0.72, 0.15)) +
#     theme(legend.title=element_blank()) +
#     guides(fill = guide_legend(nrow = 3)) +
#     theme(axis.title.y=element_blank()) +
#     theme(legend.text=element_text(size=13,color="#535362",face="plain")) +
#     theme(axis.text.x=element_text(face="plain",size=12,color="#535362")) +
#     theme(axis.title.x = element_text(
#       margin = margin(t = 15, r = 0, b = 0, l = 0),
#       size = 12, face="plain",color="#535362")) +
#     theme(plot.title = element_text(color="#535362", size=12, face="bold")) +
#     theme(axis.text.y=element_text(face="plain",size=country_text_size,color="#535362")) +
#     theme(plot.margin = unit(c(0.2,0.4,0.2,0.2), "cm"))
#
#   return(p)
# }
#
#
#
#
