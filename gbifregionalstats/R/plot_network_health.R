plot_network_health = function(
  d,
  legend_position = c(0.78,1.08),
  title_hjust=-0.55,
  subtitle_hjust=-1.165,
  type = "COUNTRY"
) {

  color_values = c(
    `Healthy` = "#509E2F",
    `Some Failed Ingestion` = "#ff9326",
    `Always Failed Ingestion` = "#ff0040",
    `No Datasets` = "gray")

  d = d %>%
    filter(type == !!type)%>%
    group_by(node_title) %>%
    mutate(total_installations = sum(value)) %>%
    ungroup() %>%
    group_by(gbif_region) %>%
    mutate(total_installations_region = max(value)) %>%
    ungroup() %>%
    mutate(node_title = forcats::fct_reorder(node_title,total_installations)) %>%
    mutate(gbif_region = forcats::fct_reorder(gbif_region,-total_installations_region)) %>%
    mutate(name = forcats::fct_relevel(name,
    c("Installation With No Datasets","Healthy","Some Failed Ingestion","Always Failed Ingestion"))) %>%
    glimpse()

library(ggplot2)

p = ggplot(d,aes(value,node_title,fill=name)) +
    geom_col(position = position_stack(reverse = TRUE)) +
    theme_bw() +
    theme(legend.position = legend_position) +
    facet_grid(gbif_region ~ .,scales="free",space = "free") +
    theme(
      strip.background = element_blank(),
      strip.text.x = element_blank(),
      strip.text = element_blank()
    ) +
    xlab("number of installations") +
    ylab("") +
    theme(legend.title=element_blank()) +
    guides(fill = guide_legend(ncol = 1)) +
    labs(title = "Network Health",
         subtitle = "Dataset ingestion health of GBIF nodes",
         caption="Health assessed from a random sample of 10 datasets per installation") +
    scale_fill_manual(values = color_values) +
    theme(plot.title = element_text(
      margin = margin(t = 0, r = 0, b = 0, l = 0),
      size = 18, face="bold",color="#535362",hjust=title_hjust)
    ) +
    theme(plot.subtitle = element_text(
      margin = margin(t = 0, r = 0, b = 45, l = 0),
      size = 12, face="plain",color="#535362",hjust=subtitle_hjust)) +
    theme(plot.margin = unit(c(t=1,r=0.2,b=0.2,l=0.2), "cm")) +
    theme(legend.background = element_rect(fill = NA, size = 3))

return(p)
}
