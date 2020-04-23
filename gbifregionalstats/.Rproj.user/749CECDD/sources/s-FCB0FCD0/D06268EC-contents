plot_time_series_taxa = function(d,
                                 variable="num_species",
                                 title="",
                                 ylab="",
                                 taxa = ""
) {

  d = d %>%
    filter(common_name == taxa) %>%
    mutate(gbif_region = forcats::fct_reorder(gbif_region,.[[variable]],.desc = TRUE))

  # sec_axis = d %>%
  # group_by(gbif_region) %>%
  # arrange(-!! rlang::sym(variable)) %>%
  # top_n(1)

  sec_axis = d %>%
    filter(date >= "2020-01-01") %>%
    group_by(gbif_region) %>%
    summarize(breaks = max(!! rlang::sym(variable)))

  breaks_sec = sec_axis %>% pull(breaks)
  labels_sec = sec_axis %>% pull(gbif_region)

  # aes(date, num_species,color=gbif_region)) +

  # breaks = scales::pretty_breaks(n = 7)(c(0,d[[variable]]))
  # labels = scales::unit_format(unit = unit_MK, scale = unit_scale,accuracy = 1,sep="")(breaks) %>%
  #   stringr::str_replace_all(stringr::regex("^0M$"),"0") %>%
  #   stringr::str_replace_all(stringr::regex("^0K$"),"0") %>%
  #   stringr::str_replace_all(stringr::regex("^1 000K$"),"1M") %>%
  #   stringr::str_replace_all(stringr::regex("^2 000K$"),"2M") %>%
  #   stringr::str_replace_all(stringr::regex("^3 000K$"),"3M") %>%
  #   stringr::str_replace_all(stringr::regex("^4 000K$"),"4M") %>%
  #   stringr::str_replace_all(stringr::regex("^5 000K$"),"1M") %>%
  #   stringr::str_replace_all(stringr::regex("^1 000M$"),"1B") %>%
  #   stringr::str_replace_all(stringr::regex("^2 000M$"),"2B")


  library(ggplot2)
  p = ggplot(d, aes_string("date",y=variable,color="gbif_region")) +
    theme_bw() +
    geom_line()  +
    geom_point() +
    scale_y_continuous(labels = scales::unit_format(unit = "K", scale = 1e-3,accuracy = 1,sep=""),
                       sec.axis = sec_axis(~ ., breaks = breaks_sec, labels = labels_sec)) +
    scale_x_date(expand = c(0, 0)) +
    theme(axis.text.y.right = element_text(face="bold", size=7)) +
    theme(legend.position = "bottom") +
    theme(legend.title=element_blank()) +
    theme(axis.text.x=element_text(face="bold")) +
    theme(axis.text.y=element_text(face="bold",size=12)) +
    theme(axis.title.y = element_text(margin = margin(t = 0, r = 10, b = 0, l = 0), size = 12, face="bold",color="#535362")) +
    theme(axis.title.x = element_blank()) +
    theme(legend.text=element_text(size=10,face="plain",color="#535362")) +
    xlab("") +
    ylab(ylab) +
    scale_colour_manual(values = c(
      "Europe"="#509E2F",
      "North America" ="#231F20",
      "Oceania" = "#FDAF02",
      "Asia" = "#175CA1",
      "Latin America" = "#7D466A",
      "Africa" = "#40BFFF"
    )) +
    theme(plot.title = element_text(colour = "#535362",face="bold")) +
    labs(title = title,subtitle = "", caption = "")


  return(p)
}
