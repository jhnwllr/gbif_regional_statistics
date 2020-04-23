# plot faceted barplot
plot_comparison_barchart = function(d,
                          variable,
                          plot_title,
                          plot_subtitle = "",
                          variable_pretty = "",
                          y_lab,
                          unit_scale = 1e-6,
                          unit_MK = "M",
                          fill="#509E2F",
                          footnote="") {

  d = d %>%
    mutate(gbif_region = forcats::fct_reorder(gbif_region,.[[variable]])) %>%
    mutate(type = forcats::fct_relevel(type,c("about","published"))) %>%
    glimpse()

  breaks = scales::pretty_breaks(n = 7)(c(0,d[[variable]]))
  labels = gbifapi::plot_label_maker(breaks,unit_MK,unit_scale)

  library(ggplot2)

  p = ggplot(d,  aes_string("gbif_region",y=variable, group = "type",fill="type")) +
    scale_y_continuous(breaks = breaks, label = labels) +
    geom_bar(stat = "identity", position = "dodge") +
    coord_flip() +
    theme_bw() +
    xlab("") +
    ylab(y_lab) +
    theme(axis.text.x=element_text(face="bold", color = "#535362")) +
    theme(axis.text.y=element_text(face="bold", color = "#535362")) +
    theme(plot.margin = unit(c(0.5,0.5,0.5,0.5), "cm")) +
    theme(axis.title.x = element_text(margin = margin(t = 15, r = 0, b = 5, l = 0), size = 12, face="bold", color = "#535362")) +
    theme(plot.title = element_text(family = "sans",face="bold", size = 14,color = "#535362", margin=margin(0,0,5,0))) +
    ggtitle(plot_title) +
    labs(title = plot_title,
         subtitle = plot_subtitle,
         caption = footnote) +
    theme(plot.caption = element_text(hjust = 1, size=8,lineheight = 0.8)) +
    theme(legend.position = c(0.85, 0.15)) +
    theme(legend.title=element_blank()) +
  scale_fill_manual(values = c(
  "about"=fill,
  "published" ="#535362"
  ))

  +
    # facet_wrap(~ type)
  # theme(plot.caption = element_text(footnote))

  return(p)
}
