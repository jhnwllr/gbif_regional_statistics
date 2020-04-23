

plot_bar_chart = function(d,
                          variable,
                          plot_title,
                          plot_subtitle = "",
                          variable_pretty = "",
                          y_lab,
                          unit_scale = 1e-6,
                          unit_MK = "M",
                          fill="#509E2F",
                          footnote="") {

  d = d %>% mutate(gbifregion = forcats::fct_reorder(gbifregion,.[[variable]])) %>%
    glimpse()


  breaks = scales::pretty_breaks(n = 7)(c(0,d[[variable]]))
  labels = scales::unit_format(unit = unit_MK, scale = unit_scale,accuracy = 1,sep="")(breaks) %>%
    stringr::str_replace_all(stringr::regex("^0M$"),"0")


  library(ggplot2)

  p = ggplot(d,  aes_string("gbifregion",y=variable)) +
    scale_y_continuous(breaks = breaks, label = labels) +
    geom_bar(stat = "identity", position = "dodge",fill=fill) +
    coord_flip() +
    theme_bw() +
    xlab("") +
    ylab(y_lab) +
    theme(axis.text.x=element_text(face="bold", color = "#535362")) +
    theme(axis.text.y=element_text(face="bold", color = "#535362")) +
    theme(plot.margin = unit(c(0.5,0.5,0.5,0.5), "cm")) +
    theme(axis.title.x = element_text(margin = margin(t = 15, r = 0, b = 0, l = 0), size = 12, face="bold", color = "#535362")) +
    theme(plot.title = element_text(family = "sans",face="bold", size = 14,color = "#535362", margin=margin(0,0,5,0))) +
    ggtitle(plot_title) +
    labs(title = plot_title,
         subtitle = plot_subtitle,
         caption = footnote)
    # theme(plot.caption = element_text(footnote))

  return(p)
}
