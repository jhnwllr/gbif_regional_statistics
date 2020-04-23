plot_time_series = function(d,
                            variable="num_species",
                            title="",
                            subtitle = "",
                            ylab="",
                            unit_MK = "M",
                            unit_scale = 1e-6
                            ) {

  d %>% glimpse()

  d = d %>%
    mutate(gbif_region = forcats::fct_reorder(gbif_region,.[[variable]],.desc = TRUE))

  sec_axis = d %>%
    filter(date >= "2020-01-01") %>%
    group_by(gbif_region) %>%
    summarize(breaks = max(!! rlang::sym(variable)))

  breaks_sec = sec_axis %>% pull(breaks)
  labels_sec = sec_axis %>% pull(gbif_region)

  number_breaks = 6

  breaks = scales::pretty_breaks(n = number_breaks)(c(0,d[[variable]]))
  labels = gbifapi::plot_label_maker(breaks,unit_MK,unit_scale)

  # scale_y_continuous(
  #   breaks = breaks, label = labels,
  #   sec.axis = sec_axis(~ ., breaks = breaks_sec, labels = labels_sec)) +


  library(ggplot2)
p = ggplot(d, aes_string("date",y=variable,color="gbif_region")) +
    theme_bw() +
    geom_line()  +
    geom_point(size=1) +
    scale_y_continuous(breaks = breaks, label = labels) +
    scale_x_date(expand = c(0, 0)) +
    theme(axis.text.y.right = element_text(face="bold", size=7)) +
    theme(legend.position = "right") +
    theme(legend.title=element_blank()) +
    theme(axis.text.x=element_text(face="plain")) +
    theme(axis.text.y=element_text(face="plain",size=12)) +
    theme(axis.title.y = element_text(margin = margin(t = 0, r = 10, b = 0, l = 0), size = 12, face="bold",color="#535362")) +
    theme(axis.title.x = element_blank()) +
    theme(legend.text=element_text(size=10,face="plain",color="#535362")) +
    xlab("") +
    ylab(ylab) +
  scale_colour_manual(values = c(
    "Europe &\nCentral Asia"="#509E2F",
    "North America" ="#FDAF02",
    "Oceania" = "#D66F27",
    "Asia" = "#ffcccc",
    "Latin America &\nThe Caribbean" = "#40BFFF",
    "Africa" = "#ff4c4d"
  )) +
    theme(plot.title = element_text(colour = "#535362",face="bold")) +
    labs(title = title,subtitle = subtitle, caption = "")


return(p)
}






