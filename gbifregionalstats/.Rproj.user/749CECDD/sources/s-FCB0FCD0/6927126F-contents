gdp_plot = function(
  variable = "num_occ_published_nobirds",
  gdp_variable = "gdp_per_capita_current_us",
  title = "Number of Non-Bird Occurrences Published",
  subtitle = "published occurrences after controlling for country GDP",
  full_model = FALSE
) {

  d = d %>% mutate(variable = !!rlang::sym(variable))
  # fit = lm(num_occ_published_nobirds ~  gdp_current_us, data=d)

  if(full_model == TRUE) {
    fit = lm(variable ~ land_area_sq_km + gdp_per_capita_current_us + population_total,data=d)
    caption = "full model - includes land area and population total"
  }
  if(full_model == FALSE) {
    fit = lm(variable ~ gdp_per_capita_current_us,data=d)
    fit %>% summary()
    caption = ""
  }



  d = d %>%
    mutate(predicted_occ = predict(fit,.)) %>%
    mutate(observed_minus_predicted = !!rlang::sym(variable) - predicted_occ) %>%
    mutate(title = forcats::fct_reorder(title,observed_minus_predicted)) %>%
    glimpse()

  library(ggplot2)
  library(patchwork)

  breaks = scales::pretty_breaks(n = 7)(c(0,d[["observed_minus_predicted"]]))
  labels = gbifapi::plot_label_maker(breaks,unit_MK="M",unit_scale=1e-6)

  gdp_breaks = scales::pretty_breaks(n = 5)(c(0,d[[gdp_variable]]))
  gdp_labels = scales::dollar_format(largest_with_cents = 1,suffix = "")(gdp_breaks) %>%
    stringr::str_replace_all("\\$0","0")

  p1 = ggplot(d,aes_string(gdp_variable,variable,label="iso2")) +
    theme_bw() +
    scale_y_continuous(breaks = breaks,labels=labels) +
    scale_x_continuous(breaks = gdp_breaks,labels=gdp_labels) +
    geom_smooth(method='lm', formula= y~x,se=FALSE,color="gray",fullrange=TRUE,linetype="dashed") +
    geom_point(aes(color=gbif_region),size=5) +
    theme(legend.position = "none") +
    theme(legend.title =element_blank()) +
    theme(axis.title.x = element_text(margin = margin(t = 10, r = 10, b = 0, l = 0), size = 12, face="bold",color="#535362")) +
    theme(axis.title.y = element_text(margin = margin(t = 0, r = 10, b = 10, l = 0), size = 12, face="bold",color="#535362")) +
    xlab("GDP per capita (USD)") +
    ylab("occurrences published") +
    geom_text(size=2) +
    scale_colour_manual(values = c(
      "Europe"="#509E2F",
      "North America" ="#FDAF02",
      "Oceania" = "#D66F27",
      "Asia" = "#ffcccc",
      "Latin America" = "#40BFFF",
      "Africa" = "#ff4c4d"
    ))

  p2 = ggplot(d,aes(observed_minus_predicted,title,colour=gbif_region,label=iso2)) +
    geom_vline(xintercept = 3, linetype="dashed", color = "gray", size=0.6) +
    geom_point(size=1.5) +
    scale_x_continuous(breaks = breaks,labels=labels) +
    theme_bw() +
    xlab("occurrence surplus/shortfall\n= (observed - predicted)") +
    theme(legend.position = c(0.47,1.08)) +
    theme(legend.title =element_blank()) +
    theme(axis.text.y=element_text(face="plain",size=6,color="#535362")) +
    theme(axis.title.x = element_text(margin = margin(t = 10, r = 10, b = 0, l = 0), size = 12, face="bold",color="#535362")) +
    theme(axis.title.y=element_blank()) +
    guides(colour = guide_legend(nrow = 2 ,override.aes = list(size=3))) +
    scale_colour_manual(values = c(
      "Europe"="#509E2F",
      "North America" ="#FDAF02",
      "Oceania" = "#D66F27",
      "Asia" = "#ffcccc",
      "Latin America" = "#40BFFF",
      "Africa" = "#ff4c4d"
    )) +
    theme(legend.background = element_rect(fill=NA))

  p = p1 + p2 +
    plot_annotation(
      title,subtitle,caption,
      theme = theme(
        plot.title = element_text(face="bold",size = 14,colour = "#535362"),
        plot.margin = unit(c(t=1,r=1,b=1,l=1), "cm")
      ))

  return(p)
}
