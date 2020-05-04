# autoBreaks

getLabels = function(breaks) {

  Start = 2:length(breaks) %>% map_dbl(~breaks[.x-1])
  Finish = 1:(length(breaks)-1) %>% map_dbl(~breaks[.x+1])

  return(paste0(Start,"-",Finish))
}

es50Breaks = function(grid,numBreaks) {

  sd4 = sd(grid$var,na.rm=TRUE)*4 # smart breaks skip lower bunch
  es50_breaks = grid %>% filter(var > sd4) %>% pull(var)
  breaks = seq(sd4,max(es50_breaks,na.rm=TRUE)+1,length.out=numBreaks) %>% round(0)
  breaks = c(0,breaks)

  return(breaks)
}

linearBreaks = function(grid,numBreaks) {
  seq(0,max(grid$var,na.rm=TRUE),length.out=numBreaks)
}

logBreaks = function(numBreaks) {
  10^(1:numBreaks)
}


plotPolyMap = function(grid,
                       variable,
                       breaks=c(1,27,38,42,44,46,48,50),
                       labels=NULL,
                       legend_title="es50",
                       pretty_breaks=7,
                       zoom_x=c(-150,170),
                       zoom_y=c(-55,80),
                       legend.position = c(.50,-0.05),
                       polygon_text_size=1,
                       polygon_alpha=1,
                       labelType="identity",
                       keywidth=0.01,
                       keyheight=0.2,
                       legend_text_size=12,
                       numBreaks=6,
                       breaksType="linear",
                       country_line_color = NA
) { # a data.frame of taxonkey,count,cell


  grid$var = grid[,variable] # rename variable

  if(is.null(breaks)) {
    if(breaksType == "es50") breaks = es50Breaks(grid,numBreaks)
    if(breaksType == "linear") breaks = linearBreaks(grid,numBreaks)
    if(breaksType == "log") breaks = logBreaks(numBreaks)
  }
  if(is.null(labels)) labels = getLabels(breaks)

  grid = grid %>% filter(!is.na(var)) %>% # remove missing
    mutate(fancyLabel = case_when(
      var >= 1e6 ~ round(var/1e6) %+% "M",
      var >= 1e3 ~ round(var/1e3) %+% "K",
      TRUE ~ as.character(var)
    ))

  countries = map_data("world")

  p = ggplot() +
    coord_cartesian(zoom_x,zoom_y) +
    geom_polygon(data=countries,aes(x=long, y=lat, group=group), fill="#D8DACF", color=country_line_color,alpha=0.8) +
    geom_path(data=grid,aes(x=long,y=lat,group=group), alpha=1, color="#7d8085") +
    geom_polygon(data=grid,aes(x=long,y=lat,group=group,fill=cut(var,breaks,labels)),alpha=polygon_alpha) +
    scale_fill_brewer(palette="Spectral",direction=1) +
    guides(fill=guide_legend(title=legend_title,label.position="bottom",keywidth=keywidth,keyheight=keyheight,nrow=1)) +
    theme_bw() +
    theme(panel.background = element_rect(fill = '#F0F3F8')) +
    scale_y_continuous(name="",breaks = seq(-90,90,by = 20),labels=rep("",length(seq(-90,90,by = 20)))) +
    scale_x_continuous(name="",breaks = seq(-175,175,by = 20),labels=rep("",length(seq(-175,175,by = 20)))) +
    theme(legend.position=legend.position,legend.direction="horizontal") +
    theme(axis.ticks.x=element_blank()) +
    theme(axis.ticks.y=element_blank()) +
    theme(legend.text=element_text(size=legend_text_size), legend.title=element_text(size=legend_text_size))

  if(labelType == "identity") {
    p = p + geom_text(data=grid,aes(lonCenter,latCenter,label=round(var,0)),size=polygon_text_size)
  }
  if(labelType == "fancy") {
    p = p + geom_text(data=grid,aes(lonCenter,latCenter,label=fancyLabel),size=polygon_text_size)
  }

  return(p)
}


plot_poly_map_gaps = function(grid,
                       variable,
                       breaks=c(1,27,38,42,44,46,48,50),
                       labels=NULL,
                       legend_title="es50",
                       pretty_breaks=7,
                       zoom_x=c(-150,170),
                       zoom_y=c(-55,80),
                       legend.position = c(.50,-0.05),
                       polygon_text_size=1,
                       polygon_alpha=1,
                       labelType="identity",
                       keywidth=0.01,
                       keyheight=0.2,
                       legend_text_size=12,
                       numBreaks=6,
                       breaksType="linear",
                       country_line_color = NA
) { # a data.frame of taxonkey,count,cell


  grid$var = grid[,variable] # rename variable

  if(is.null(breaks)) {
    if(breaksType == "es50") breaks = es50Breaks(grid,numBreaks)
    if(breaksType == "linear") breaks = linearBreaks(grid,numBreaks)
    if(breaksType == "log") breaks = logBreaks(numBreaks)
  }
  if(is.null(labels)) labels = getLabels(breaks)

  grid = grid %>% filter(!is.na(var)) %>% # remove missing
    mutate(fancyLabel = case_when(
      var >= 1e6 ~ round(var/1e6) %+% "M",
      var >= 1e3 ~ round(var/1e3) %+% "K",
      TRUE ~ as.character(var)
    ))

  countries = map_data("world")

  p = ggplot() +
    coord_cartesian(zoom_x,zoom_y) +
    geom_polygon(data=countries,aes(x=long, y=lat, group=group), fill="#D8DACF", color=country_line_color,alpha=0.8) +
    geom_path(data=grid,aes(x=long,y=lat,group=group), alpha=1, color="#7d8085") +
    geom_polygon(data=grid,aes(x=long,y=lat,group=group,fill=cut(var,breaks,c("<5K","5K-10K",">10K") )),alpha=polygon_alpha) +
    scale_fill_manual(values = c("#E8E8E8", "#175CA1", "#509E2F")) +
    guides(fill=guide_legend(title=legend_title,label.position="bottom",keywidth=keywidth,keyheight=keyheight,nrow=1)) +
    theme_bw() +
    theme(panel.background = element_rect(fill = '#F0F3F8')) +
    scale_y_continuous(name="",breaks = seq(-90,90,by = 20),labels=rep("",length(seq(-90,90,by = 20)))) +
    scale_x_continuous(name="",breaks = seq(-175,175,by = 20),labels=rep("",length(seq(-175,175,by = 20)))) +
    theme(legend.position=legend.position,legend.direction="horizontal") +
    theme(axis.ticks.x=element_blank()) +
    theme(axis.ticks.y=element_blank()) +
    theme(legend.text=element_text(size=legend_text_size), legend.title=element_text(size=legend_text_size))

  if(labelType == "identity") {
    p = p + geom_text(data=grid,aes(lonCenter,latCenter,label=round(var,0)),size=polygon_text_size)
  }
  if(labelType == "fancy") {
    p = p + geom_text(data=grid,aes(lonCenter,latCenter,label=fancyLabel),size=polygon_text_size)
  }

  return(p)
}

plot_poly_map_gaps = function(grid,
                              variable,
                              breaks=c(1,27,38,42,44,46,48,50),
                              labels=NULL,
                              legend_title="es50",
                              pretty_breaks=7,
                              zoom_x=c(-150,170),
                              zoom_y=c(-55,80),
                              legend.position = c(.50,-0.05),
                              polygon_text_size=1,
                              polygon_alpha=1,
                              labelType="identity",
                              keywidth=0.01,
                              keyheight=0.2,
                              legend_text_size=12,
                              numBreaks=6,
                              breaksType="linear",
                              country_line_color = NA,
                              ggplot2_small_map = FALSE
) { # a data.frame of taxonkey,count,cell


  grid$var = grid[,variable] # rename variable

  if(is.null(breaks)) {
    if(breaksType == "es50") breaks = es50Breaks(grid,numBreaks)
    if(breaksType == "linear") breaks = linearBreaks(grid,numBreaks)
    if(breaksType == "log") breaks = logBreaks(numBreaks)
  }
  if(is.null(labels)) labels = getLabels(breaks)

  grid = grid %>%
    filter(!is.na(var)) %>% # remove missing
    mutate(
      fancyLabel = case_when(
        var >= 1e6 ~ round(var/1e6) %+% "M",
        var >= 1e3 ~ round(var/1e3) %+% "K",
        TRUE ~ as.character(var)
      ))

  manual_colors = c("#E8E8E8", "#175CA1", "#509E2F")
  manual_labels = c("<5K","5K-10K",">10K")

  if(ggplot2_small_map) { countries = gbifapi::ggplot2_small_map_data(dTolerance=1.2)}
  else {countries = map_data("world") }

  p = ggplot() +
    coord_cartesian(zoom_x,zoom_y) +
    geom_polygon(data=countries,aes(x=long, y=lat, group=group), fill="#D8DACF", color=country_line_color,alpha=0.8) +
    geom_path(data=grid,aes(x=long,y=lat,group=group), alpha=1, color="#7d8085") +
    geom_polygon(data=grid,aes(x=long,y=lat,group=group,fill=cut(var,breaks, manual_labels )),alpha=polygon_alpha) +
    scale_fill_manual(values = manual_colors) +
    guides(fill=guide_legend(title=legend_title,label.position="bottom",keywidth=keywidth,keyheight=keyheight,nrow=1)) +
    theme_bw() +
    theme(panel.background = element_rect(fill = '#F0F3F8')) +
    scale_y_continuous(name="",breaks = seq(-90,90,by = 20),labels=rep("",length(seq(-90,90,by = 20)))) +
    scale_x_continuous(name="",breaks = seq(-175,175,by = 20),labels=rep("",length(seq(-175,175,by = 20)))) +
    theme(legend.position=legend.position,legend.direction="horizontal") +
    theme(axis.ticks.x=element_blank()) +
    theme(axis.ticks.y=element_blank()) +
    theme(legend.text=element_text(size=legend_text_size), legend.title=element_text(size=legend_text_size))

  if(labelType == "identity") {
    p = p + geom_text(data=grid,aes(lonCenter,latCenter,label=round(var,0)),size=polygon_text_size)
  }
  if(labelType == "fancy") {
    p = p + geom_text(data=grid,aes(lonCenter,latCenter,label=fancyLabel),size=polygon_text_size)
  }

  return(p)
}



