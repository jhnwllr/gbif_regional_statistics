

# gbifregionalstats::isea3h_res6

if(FALSE) { # create isea3h files

library(dplyr)
library(gbifregionalstats)

isea3h_res6 = create_isea3h_data(6)
# isea3h_res6
save(isea3h_res6,file="C:/Users/ftw712/Desktop/isea3h_res6.rda")
# saveRDS("C:/Users/ftw712/Desktop/isea3h_res6.rda")
}

if(FALSE) { # fix counts problem with kingdomkey 
library(dplyr)

D = data.table::fread("C:/Users/ftw712/Desktop/gbif_regional_statistics/data/polygon_counts_isea3h_res6.tsv") 

D = D %>%
glimpse()
# mutate(id = as.integer(polygon_id)) %>%
# group_by(id,kingdomkey,phylumkey,classkey) %>%
# summarise(occ_count=sum(occ_count),num_species=sum(num_species),num_datasets=sum(num_datasets),num_publishers=sum(num_publishers)) %>%
# merge(isea3h,id="id",all.y=TRUE) %>%
# mutate(long = lon) %>%
# mutate(lat = lat) %>%
# mutate(group = id) %>%
# glimpse() %>%
# arrange(ordering)
}

if(FALSE) { # plot wire frame of isea3h
library(dplyr)
library(ggplot2)

load("C:/Users/ftw712/Desktop/gbif_regional_statistics/data/isea3h.rda")

centroids = isea3h %>%
filter(res == 5) %>%
filter(centroid == 1) %>%
select(id,lonCenter = lon,latCenter = lat) %>%
glimpse()

isea3h = isea3h %>% 
filter(res == 5) %>%
filter(centroid == 0) %>% 
glimpse() %>%
mutate(long = lon) %>%
mutate(cell = id) %>%
mutate(group = id) %>%
merge(centroids,id="id",only.x=TRUE) %>%
glimpse() %>%
mutate(ordering = 1:nrow(.))

# isea3h = isea3h %>%
# filter(res == 4) %>% # actually resolution 5 since this data is indexed at 0
# filter(centroid == 0) %>%  
# mutate(group = id) %>%
# glimpse()

p = gbifrasters::plotWireFrame(isea3h,textSize=1)

ggsave("C:/Users/ftw712/Desktop/wire_frame.pdf",plot=p,device="pdf",scale=1,width=9,height=5)

}

if(FALSE) { # basic polygon plotting 

library(roperators)
library(dplyr)
library(dggridR) # used to make hexagon grid
library(sf)
library(purrr)

# load("C:/Users/ftw712/Desktop/gbif_regional_statistics/data/isea3h.rda")

# isea3h = isea3h %>%
# filter(res == 4) %>% # actually resolution 5 since this data is indexed at 0
# filter(centroid == 0) %>%  
# glimpse()

# polygon_list = isea3h %>%
# group_split(id) %>%
# map(~ .x %>%
# select(lon,lat) %>%
# as.matrix() %>% 
# list() %>%
# st_polygon() %>% 
# st_wrap_dateline(options = c("WRAPDATELINE=YES"))  
# ) 

# polygon_list




library(dplyr)

# grid = readRDS("C:/Users/ftw712/Desktop/grid_300_1.rda")
# grid %>% glimpse()

load("C:/Users/ftw712/Desktop/gbif_regional_statistics/data/isea3h.rda")

centroids = isea3h %>%
filter(res == 5) %>%
filter(centroid == 1) %>%
select(id,lonCenter = lon,latCenter = lat) %>%
glimpse()

isea3h = isea3h %>% 
filter(res == 5) %>%
filter(centroid == 0) %>% 
glimpse() %>%
merge(centroids,id="id",only.x=TRUE) %>%
glimpse() %>%
mutate(ordering = 1:nrow(.))
 
# mutate(id = paste0("polygon_",id)) %>%

D = data.table::fread("C:/Users/ftw712/Desktop/gbif_regional_statistics/data/polygon_counts_isea3h_res6.tsv") 

# arrange(-occ_count) %>% 
D = D %>%
filter(orderkey == 797) %>%
mutate(id = as.integer(polygon_id)) %>% 
group_by(id) %>% 
summarise(occ_count=sum(occ_count),num_species=sum(num_species),num_datasets=sum(num_datasets),num_publishers=sum(num_publishers)) %>% 
glimpse() %>%
merge(isea3h,id="id",all.y=TRUE) %>% 
mutate(long = lon) %>%
mutate(lat = lat) %>%
mutate(group = id) %>%
glimpse() %>%
filter(lonCenter < 160 & lonCenter > -165) %>%
arrange(ordering) 

# D$num_datasets

# mutate(lat = lat) %>%
library(gbifrasters)
library(ggplot2)

p = plotPolyMap(grid = D ,
		   variable = "num_publishers",
		   breaks=NULL,
		   labels=NULL,
		   legend_title="num_publishers",
		   pretty_breaks=7,
		   zoom_x=c(-180,180),
		   zoom_y=c(-55,80),
		   legend.position = c(.50,-0.05),
		   polygon_text_size=1.7,
		   polygon_alpha=0.7,
		   labelType="fancy",
		   keywidth=0.01,
		   keyheight=0.2,
		   legend_text_size=12,
		   numBreaks=7,
		   breaksType="linear")

# p = p + geom_point(data=D,aes(lonCenter,latCenter))
		   
ggsave("C:/Users/ftw712/Desktop/plot.pdf",plot=p,device="pdf",scale=1,width=9,height=5)

}

if(FALSE) { # Regional hexagon Plots  
library(ggplot2)
library(dplyr)
library(purrr)
library(roperators)
library(gbifregionalstats)

vars = tibble::tribble(
~gbif_region,~region_value,~orientation, ~xlim_ortho, ~ylim_ortho,~breaks,~variable_,~legend_title_,
"europe","Europe",c(50.72,20,4.5),c(-25,70), c(75,25),c(0,5000,10000,55000),"num_species","species count",
"europe","Europe",c(50.72,20,4.5),c(-25,70), c(75,25),c(0,200,300,5000),"num_datasets","dataset count",
"europe","Europe",c(50.72,20,4.5),c(-25,70), c(75,25),c(0,100,300,500),"num_publishers","publisher count",
"afrca", "Africa",c(0.7901464,22.8335061,4.26),c(-25,70),c(-40,40),c(0,5000,10000,55000),"num_species","species count",
"afrca", "Africa",c(0.7901464,22.8335061,4.26),c(-25,70),c(-40,40),c(0,200,300,5000),"num_datasets","dataset count",
"afrca", "Africa",c(0.7901464,22.8335061,4.26),c(-25,70),c(-40,40),c(0,100,300,500),"num_publishers","publisher count",
"latin america","Americas",c(-17.60,-60.62,4),c(-100.85,-24.21),c(-61.36,27.51),c(0,5000,10000,55000),"num_species","species count",
"latin america","Americas",c(-17.60,-60.62,4),c(-100.85,-24.21),c(-61.36,27.51),c(0,200,300,5000),"num_datasets","dataset count",
"latin america","Americas",c(-17.60,-60.62,4),c(-100.85,-24.21),c(-61.36,27.51),c(0,100,300,500),"num_publishers","publisher count",
"asia", "Asia", c(26.6078252,98.0344816,3.66), c(-32.14,178.39), c(-13.43,79.00), c(0,5000,10000,55000),"num_species","species count",
"asia", "Asia", c(26.6078252,98.0344816,3.66), c(-32.14,178.39), c(-13.43,79.00), c(0,200,300,5000),"num_datasets","dataset count",
"asia", "Asia", c(26.6078252,98.0344816,3.66), c(-32.14,178.39), c(-13.43,79.00), c(0,100,300,500),"num_publishers","publisher count",
"north america", "Americas", c(47.2058929,-97.297683,3.88), c(-171.91,-9.48), c(9.88,84.27), c(0,100,300,500),"num_publishers","publisher count",
"north america", "Americas", c(47.2058929,-97.297683,3.88), c(-171.91,-9.48), c(9.88,84.27), c(0,200,300,5000),"num_datasets","dataset count",
"north america", "Americas", c(47.2058929,-97.297683,3.88), c(-171.91,-9.48), c(9.88,84.27), c(0,5000,10000,55000),"num_species","species count",
"oceania", "Oceania", c(-13.4796711,152.8237114,4.04), c(100.87,-175.45), c(-51.8,5.19), c(0,100,300,500),"num_publishers","publisher count",
"oceania", "Oceania", c(-13.4796711,152.8237114,4.04), c(100.87,-175.45), c(-51.8,5.19), c(0,200,300,5000),"num_datasets","dataset count",
"oceania", "Oceania", c(-13.4796711,152.8237114,4.04), c(100.87,-175.45), c(-51.8,5.19), c(0,5000,10000,55000),"num_species","species count"
) %>% 
purrr::transpose()

# filter(gbif_region=="oceania") %>%

# POLYGON((-171.91 84.27,-9.48 84.27,-9.48 9.88,-171.91 9.88,-171.91 84.27))
# POLYGON((100.87 5.19,-175.45 5.19,-175.45 -51.8,100.87 -51.88,100.87 5.19))

D = data.table::fread("C:/Users/ftw712/Desktop/gbif_regional_statistics/data/polygon_counts_isea3h_res6.tsv") %>% 
glimpse()

# filter(variable_ == "num_species") %>%
vars

plots = vars %>%
map(~
stats_plotter(D,
isea3h = gbifregionalstats::isea3h_res6,
variable_ = .x$variable_,
legend_title_=.x$legend_title_,
breaks_ = .x$breaks,
filter_column_string = NULL,
filter_column_value = NULL,
orientation = .x$orientation,
xlim_ortho = .x$xlim_ortho,
ylim_ortho = .x$ylim_ortho,
region_value = .x$region_value
)) %>%
map2(vars,~ {
ggsave(paste0("C:/Users/ftw712/Desktop/gbif_regional_statistics/plots/hexagon plots/",.y$gbif_region,"_",.y$variable_,".pdf"),plot=.x,scale=1,width=9,height=5)
ggsave(paste0("C:/Users/ftw712/Desktop/gbif_regional_statistics/plots/hexagon plots/",.y$gbif_region,"_",.y$variable_,".svg"),plot=.x,scale=1,width=9,height=5)
ggsave(paste0("C:/Users/ftw712/Desktop/gbif_regional_statistics/plots/hexagon plots/",.y$gbif_region,"_",.y$variable_,".jpg"),plot=.x,scale=1,width=9,height=5,dpi=600)
})


}

if(FALSE) { # global plots 
library(ggplot2)
library(dplyr)
library(purrr)
library(roperators)
library(gbifregionalstats)

vars = tibble::tribble(
~breaks,~variable_,~legend_title_,
c(0,5000,10000,55000),"num_species","species count",
c(0,200,300,5000),"num_datasets","dataset count",
c(0,100,300,500),"num_publishers","publisher count"
) %>% purrr::transpose()

vars

D = data.table::fread("C:/Users/ftw712/Desktop/gbif_regional_statistics/data/polygon_counts_isea3h_res6.tsv") %>% 
glimpse()

vars %>%
map(~ 
stats_plotter_global(D,
isea3h = gbifregionalstats::isea3h_res6,
variable_ = .x$variable_,
legend_title_=.x$legend_title_,
breaks_ = .x$breaks,
filter_column_string = NULL,
filter_column_value = NULL
)) %>%
map2(vars,~ 
{
ggsave(paste0("C:/Users/ftw712/Desktop/gbif_regional_statistics/plots/hexagon plots/global_",.y$variable_,".pdf"),plot=.x,scale=1,width=9,height=5)
ggsave(paste0("C:/Users/ftw712/Desktop/gbif_regional_statistics/plots/hexagon plots/global_",.y$variable_,".svg"),plot=.x,scale=1,width=9,height=5)
ggsave(paste0("C:/Users/ftw712/Desktop/gbif_regional_statistics/plots/hexagon plots/global_",.y$variable_,".jpg"),plot=.x,scale=1,width=9,height=5,dpi=600)
})

}

if(FALSE) { # hexagon plot_poly_map_gaps

library(ggplot2)
library(dplyr)
library(purrr)
library(roperators)
library(gbifregionalstats)

# c(0,200,300,5000),"num_datasets","dataset count",
# c(0,100,300,500),"num_publishers","publisher count"
vars = tibble::tribble(
~breaks,~variable_,~legend_title_,
c(0,5000,10000,55000),"num_species","species count"
) %>% purrr::transpose()

vars

D = data.table::fread("C:/Users/ftw712/Desktop/gbif_regional_statistics/data/polygon_counts_isea3h_res6.tsv") %>% 
glimpse()

vars %>%
map(~ 
gbifregionalstats::stats_plotter_global(D,
isea3h = gbifregionalstats::isea3h_res6,
variable_ = .x$variable_,
legend_title_=.x$legend_title_,
breaks_ = .x$breaks,
filter_column_string = NULL,
filter_column_value = NULL
)) %>%
map2(vars,~ 
{
ggsave(paste0("C:/Users/ftw712/Desktop/gbif_regional_statistics/plots/hexagon plots/global_",.y$variable_,".pdf"),plot=.x,scale=1,width=9,height=5)
ggsave(paste0("C:/Users/ftw712/Desktop/gbif_regional_statistics/plots/hexagon plots/global_",.y$variable_,".svg"),plot=.x,scale=1,width=9,height=5)
ggsave(paste0("C:/Users/ftw712/Desktop/gbif_regional_statistics/plots/hexagon plots/global_",.y$variable_,".jpg"),plot=.x,scale=1,width=9,height=5,dpi=900)
})
}

if(FALSE) { # get regions list to put into hdfs 

library(dplyr)

gbifapi::get_gbif_countries() %>%
merge(gbifapi::get_participation_data() %>% select(iso2,participationStatus),id="iso2") %>%
readr::write_tsv("C:/Users/ftw712/Desktop/gbif_regions.tsv")

# scp /cygdrive/c/Users/ftw712/Desktop/gbif_regions.tsv jwaller@c4gateway-vh.gbif.org:/home/jwaller/
# hdfs dfs -put gbif_regions.tsv gbif_regions.tsv
# hdfs dfs -ls 
}

if(FALSE) {

library(dplyr)
library(purrr)

# data_about = tibble::tribble(
# ~gbifregion,~occ_count,~num_datasets,~num_publishers,~num_species,
# "Asia",49357887,6392,577,370902,
# "Oceania",102098216,3174,512,225512,
# "North America",536909648,3195,574,329073,
# "Europe",535081925,11105,930,365206,
# "Antarctica",2069344,1218,245,17124,
# "Africa",43098291,3720,628,246119,
# "Latin America",90913729,7536,742,448877,) %>% 
# filter(!gbifregion == "Antarctica") %>%
# mutate(type = "about") 

# Without plazi 
# data_published = tibble::tribble(
# ~gbifregion,~occ_count,~num_datasets,~num_publishers,~num_species,
# "Asia",38191155,726,73,175952,
# "Oceania",86739832,512,106,166729,
# "North America",559478470,882,234,1032429,
# "Europe",579180992,15076,602,1053157,
# "Antarctica",53584,1,1,102,
# "Africa",32310791,613,123,110999,
# "Latin America",70684361,2715,295,278438) %>% 
# filter(!gbifregion == "Antarctica") %>%
# mutate(type = "published")  

# d = rbind(data_about,data_published) %>%
# glimpse()

d = readr::read_tsv("http://download.gbif.org/custom_download/jwaller/gbif_regions_counts.tsv") %>% 
filter(!gbif_region == "Antarctica")
glimpse() %>% 

parameters_occ = 
tibble::tibble(
	variable = "occ_count",
	plot_title="Number of Occurrences",
	plot_subtitle = "Number of occurrences about/published by GBIF regions",
	variable_pretty = "",
	y_lab = "number of occurrences",
	unit_scale = 1e-6,
	unit_MK = "M",
	fill="#509E2F") 

parameters_species = 
tibble::tibble(
	variable = "num_species",
	plot_title="Number of Species",
	plot_subtitle = "Number of species about/published by GBIF regions",
	variable_pretty = "",
	y_lab = "number of species",
	unit_scale = 1e-3,
	unit_MK = "K",
	fill="#FDAF02")	

parameters = rbind(parameters_species,parameters_occ) %>% 
purrr::transpose()

parameters %>% 
map(~	
gbifregionalstats::plot_comparison_barchart(
d,
variable = .x$variable,
plot_title=.x$plot_title,
plot_subtitle = .x$plot_subtitle,
variable_pretty = "",
y_lab = .x$y_lab,
unit_scale = .x$unit_scale,
unit_MK = .x$unit_MK,
fill= .x$fill,
footnote="published records - do not necessarily occur within the region\nabout records - must occur within the region")
) %>% 
map2(parameters,~ {
ggsave(paste0("C:/Users/ftw712/Desktop/gbif_regional_statistics/plots/comparison barchart/gbif_regions_",.y$variable,".pdf"), plot = .x,width=6,height=5)
ggsave(paste0("C:/Users/ftw712/Desktop/gbif_regional_statistics/plots/comparison barchart/gbif_regions_",.y$variable,".svg"), plot = .x,width=6,height=5)
ggsave(paste0("C:/Users/ftw712/Desktop/gbif_regional_statistics/plots/comparison barchart/gbif_regions_",.y$variable,".jpg"), plot = .x,width=6,height=5,dpi=600)
})

}	

if(FALSE) { # barchart data about regions 
library(dplyr)
library(purrr)

data_about = tibble::tribble(
~gbifregion,~occ_count,~num_datasets,~num_publishers,~num_species,
"Asia",49357887,6392,577,370902,
"Oceania",102098216,3174,512,225512,
"North America",536909648,3195,574,329073,
"Europe",535081925,11105,930,365206,
"Antarctica",2069344,1218,245,17124,
"Africa",43098291,3720,628,246119,
"Latin America",90913729,7536,742,448877,
) %>% 
filter(!gbifregion == "Antarctica") %>%
glimpse()

# Without plazi 
data_published = tibble::tribble(
~gbifregion,~occ_count_published,~num_datasets_published,~num_publishers_published,~num_species_published,
"Asia",38191155,726,73,175952,
"Oceania",86739832,512,106,166729,
"North America",559478470,882,234,1032429,
"Europe",579180992,15076,602,1053157,
"Antarctica",53584,1,1,102,
"Africa",32310791,613,123,110999,
"Latin America",70684361,2715,295,278438) %>% 
glimpse()

# "num_datasets",seq(0,12000,2000),c("0","2K","4K","6K","8K","10K","12K"),c(0, 12000),"Number of datasets within regions","number of datasets","#40BFFF",
parameters_about = tibble::tribble(
~variable,~variable_pretty,~plot_title, ~y_lab,~fill,~unit_MK,~unit_scale,
"occ_count","occurrences","Number of Occurrences","number of occurrences","#509E2F","M",1e-6,
"num_publishers","publishers","Number of Publishers","number of publishers","#535362","",1,
"num_species","species","Number of Species","number of species","#FDAF02","K",1e-3,
) %>% 
mutate(plot_subtitle = paste0("Number of ", variable_pretty," about GBIF region")) %>%
glimpse() 

parameters_published = tibble::tribble(
~variable,~variable_pretty,~plot_title, ~y_lab,~fill,~unit_MK,~unit_scale,
"occ_count_published","occurrences","Number of Published Occurrences","number of occurrences","#509E2F","M",1e-6,
"num_publishers_published","publishers","Number of Publishers","number of publishers","#535362","",1,
"num_species_published","species","Number of Published Species","number of species","#FDAF02","K",1e-3,
) %>% 
mutate(plot_subtitle = paste0("Number of published ", variable_pretty," from GBIF region")) %>%
glimpse() 

d = merge(data_about,data_published,id="gbifregion")

parameters = rbind(parameters_published,parameters_about) %>%
purrr::transpose() 

parameters %>%
map(~
gbifregionalstats::plot_bar_chart(
d,
variable = .x$variable,
variable_pretty = .x$variable_pretty,
plot_title = .x$plot_title,
plot_subtitle = .x$plot_subtitle,
y_lab = .x$y_lab,
fill = .x$fill,
unit_MK = .x$unit_MK,
unit_scale = .x$unit_scale
)) %>%
map2(parameters, ~ 
{
ggsave(paste0("C:/Users/ftw712/Desktop/gbif_regional_statistics/plots/barplots/barplot_data_about_",.y$variable,".pdf"), plot = .x,width=6,height=5)
ggsave(paste0("C:/Users/ftw712/Desktop/gbif_regional_statistics/plots/barplots/barplot_data_about_",.y$variable,".svg"), plot = .x,width=6,height=5)
ggsave(paste0("C:/Users/ftw712/Desktop/gbif_regional_statistics/plots/barplots/barplot_data_about_",.y$variable,".jpg"), plot = .x,width=6,height=5,dpi=600)
})

}

if(FALSE) { # Data published by regions without plazi 
library(dplyr)
library(purrr)


# Without plazi 
data_published = tibble::tribble(
~gbifregion,~occ_count,~num_datasets,~num_publishers,~num_species,
"Asia",38191155,726,73,175952,
"Oceania",86739832,512,106,166729,
"North America",559478470,882,234,1032429,
"Europe",579180992,15076,602,1053157,
"Antarctica",53584,1,1,102,
"Africa",32310791,613,123,110999,
"Latin America",70684361,2715,295,278438) %>% 
glimpse()

# data_published = tibble::tribble(
# ~gbifregion,~occ_count,~num_datasets,~num_publishers,~num_species,
# "Asia",38186488,724,73,175951,
# "Oceania",86739466,512,106,166815,
# "North America",559459447,880,233,1032421,
# "Europe",579406851,23325,603,1080875,
# "Antarctica",53584,1,1,102,
# "Africa",32310791,613,123,110999,
# "Latin America",70684306,2714,295,278436) %>%
# mutate(gbifregion = forcats::fct_reorder(gbifregion,occ_count)) %>%
# glimpse()

parameters = tibble::tribble(
~variable,~breaks,~label,~limits,~plot_title, ~y_lab,~fill,~footnote,
"occ_count",seq(0,600e6,100e6),c("0","100M","200M","300M","400M","500M","600M"),c(0, 600e6),"Number of occurrences published by regions","number of occurrences published by region","#509E2F","",
"num_datasets",seq(0,16e3,2e3),c("0","2K","4K","6K","8K","10K","12K","14K","16K"),c(0, 16e3),"Number of datasets published by regions","number of datasets published by region","#40BFFF","*Excluding Plazi",
"num_publishers",seq(0,1000,200),c("0","200","400","600","800","1000"),c(0, 1000),"Number of publishers from regions","number of publishers from region","#231F20","",
"num_species",seq(0,120e4,20e4),c("0","20K","40K","60K","80K","100K","120K"),c(0, 120e4),"Number of species published by regions","number of species published by region","#FDAF02",""
) %>% 
glimpse() %>%
purrr::transpose()

# parameters

parameters %>%
map(~
gbifregionalstats::plot_bar_chart(
d=data_published,
variable = .x$variable,
breaks = .x$breaks,
label = .x$label,
limits = .x$limits,
plot_title = .x$plot_title,
y_lab = .x$y_lab,
fill = .x$fill,
footnote = .x$footnote)
) %>%
map2(parameters, ~ 
{
ggsave(paste0("C:/Users/ftw712/Desktop/gbif_regional_statistics/plots/barplots/barplot_data_published_",.y$variable,".pdf"), plot = .x,width=6,height=5)
ggsave(paste0("C:/Users/ftw712/Desktop/gbif_regional_statistics/plots/barplots/barplot_data_published_",.y$variable,".svg"), plot = .x,width=6,height=5)
ggsave(paste0("C:/Users/ftw712/Desktop/gbif_regional_statistics/plots/barplots/barplot_data_published_",.y$variable,".jpg"), plot = .x,width=6,height=5,dpi=600)
})

}

if(FALSE) { # Regional growth spagetti chart 

library(dplyr)

d = data.table::fread("C:/Users/ftw712/Desktop/gbif_regional_statistics/data/gbif_regions_over_time.tsv") %>%
janitor::clean_names() %>%
glimpse() %>% 
mutate(date=stringr::str_replace_all(snapshot,"occurrence_","")) %>%
mutate(date=lubridate::ymd(date)) %>%
filter(with_birds == "no") %>%
mutate(gbif_region = stringr::str_replace_all(gbif_region,"_"," ")) %>%
mutate(gbif_region = stringr::str_to_title(gbif_region)) %>%
mutate(gbif_region = forcats::fct_reorder(gbif_region,-num_of_occ)) %>%
filter(!gbif_region == "Antarctica") %>%
glimpse() 

sec_axis = d %>% 
group_by(gbif_region) %>%
top_n(1) 

breaks_sec = sec_axis %>% pull(num_of_occ)
labels_sec = sec_axis %>% pull(gbif_region)

breaks = seq(0,600e6,50e6)
# label = c("0","50M","100M","150M","200M","250M","300M","350M")
label = paste0(seq(0,600,50),"M")

# ,c(0, 600e6)

library(ggplot2)
p = ggplot(d, aes(date, num_of_occ,group=gbif_region,color=gbif_region)) + 
theme_bw() + 
geom_line() +
geom_point() +
scale_y_continuous(
breaks = breaks, label = label,
sec.axis = sec_axis(~ ., breaks = breaks_sec, labels = labels_sec)) +
scale_x_date(expand = c(0, 0)) +
theme(axis.text.y.right = element_text(face="bold", size=7)) + 
theme(legend.position = c(0.21, 0.78)) +
theme(legend.title=element_blank()) + 
theme(axis.text.x=element_text(face="bold")) +
theme(axis.text.y=element_text(face="bold",size=12)) +
theme(axis.title.y = element_text(margin = margin(t = 15, r = 10, b = 0, l = 0), size = 12, face="bold",color="#535362")) +
theme(legend.text=element_text(size=14,face="plain",color="#535362")) + 
xlab("") +
ylab("Number of Occurrences") + 
scale_colour_manual(values = c("#509E2F", "#231F20", "#FDAF02","#175CA1", "#7D466A", "#40BFFF"
)) + 
theme(plot.title = element_text(colour = "#535362",face="bold")) + 
labs(title = "Growth of GBIF Regions Occurrences",subtitle = "", caption = "")
    
# guides(fill=guide_legend(title="New Legend Title"))
# axis.line.y.right = element_line(color = "red"), 
# axis.ticks.y.right = element_line(color = "red"))

ggsave(paste0("C:/Users/ftw712/Desktop/gbif_regional_statistics/plots/plot.pdf"), plot = p,width=6,height=5)
ggsave(paste0("C:/Users/ftw712/Desktop/gbif_regional_statistics/plots/plot.svg"), plot = p,width=6,height=5)
ggsave(paste0("C:/Users/ftw712/Desktop/gbif_regional_statistics/plots/plot.jpg"), plot = p,width=6,height=5,dpi=600)

}

if(FALSE) { # species through time on gbif

library(dplyr)

d = data.table::fread("C:/Users/ftw712/Desktop/gbif_regional_statistics/data/gbif_regions_num_species_over_time.tsv") %>%
janitor::clean_names() %>%
glimpse() %>% 
mutate(date=stringr::str_replace_all(snapshot,"occurrence_","")) %>%
mutate(date=lubridate::ymd(date)) %>%
mutate(gbif_region = stringr::str_replace_all(gbif_region,"_"," ")) %>%
mutate(gbif_region = stringr::str_to_title(gbif_region)) %>%
mutate(gbif_region = forcats::fct_reorder(gbif_region,-num_species)) %>%
filter(!gbif_region == "Antarctica") %>%
glimpse() 

sec_axis = d %>% 
group_by(gbif_region) %>%
top_n(1) 

breaks_sec = sec_axis %>% pull(num_species)
labels_sec = sec_axis %>% pull(gbif_region)

breaks = seq(0,500e3,100e3)
breaks_sec
breaks
label = c("0","100K","200K","300K","400K","500K")
# label = paste0(seq(0,100,50),"M")

library(ggplot2)
p = ggplot(d, aes(date, num_species,group=gbif_region,color=gbif_region)) + 
theme_bw() + 
geom_line()  +
geom_point() +
scale_y_continuous(
breaks = breaks, label = label,
sec.axis = sec_axis(~ ., breaks = breaks_sec, labels = labels_sec)) +
scale_x_date(expand = c(0, 0)) +
theme(axis.text.y.right = element_text(face="bold", size=7)) + 
theme(legend.position = c(0.19, 0.78)) +
theme(legend.title=element_blank()) + 
theme(axis.text.x=element_text(face="bold")) +
theme(axis.text.y=element_text(face="bold",size=12)) +
theme(axis.title.y = element_text(margin = margin(t = 15, r = 10, b = 0, l = 0), size = 12, face="bold",color="#535362")) +
theme(legend.text=element_text(size=12,face="plain",color="#535362")) + 
xlab("") +
ylab("Number of Species on GBIF") + 
scale_colour_manual(values = c("#509E2F", "#231F20", "#FDAF02","#175CA1", "#7D466A", "#40BFFF"
)) + 
theme(plot.title = element_text(colour = "#535362",face="bold")) + 
labs(title = "Number of species on GBIF",subtitle = "", caption = "")
    
ggsave(paste0("C:/Users/ftw712/Desktop/gbif_regional_statistics/plots/plot.pdf"), plot = p,width=6,height=5)
ggsave(paste0("C:/Users/ftw712/Desktop/gbif_regional_statistics/plots/plot.svg"), plot = p,width=6,height=5)
ggsave(paste0("C:/Users/ftw712/Desktop/gbif_regional_statistics/plots/plot.jpg"), plot = p,width=6,height=5,dpi=600)

}

if(FALSE) { # proccess num occ over time to remove with and without birds 

library(dplyr)

gbif_regions_num_occ_over_time_no_birds = data.table::fread("C:/Users/ftw712/Desktop/gbif_regional_statistics/data/gbif_regions_num_occ_over_time.tsv") %>% 
filter(with_birds == "yes") %>%
select("gbifRegion","num_of_occ","snapshot") %>% 
glimpse() %>%
readr::write_tsv("C:/Users/ftw712/Desktop/gbif_regions_num_occ_over_time_with_no_birds.tsv")

gbif_regions_num_occ_over_time_with_birds = data.table::fread("C:/Users/ftw712/Desktop/gbif_regional_statistics/data/gbif_regions_num_occ_over_time.tsv") %>% 
filter(with_birds == "no") %>%
select("gbifRegion","num_of_occ","snapshot") %>% 
glimpse() %>%
readr::write_tsv("C:/Users/ftw712/Desktop/gbif_regions_num_occ_over_time_with_birds.tsv")

}


if(FALSE) { # Ususal suspects look up 
library(dplyr)
library(purrr)

keys = tibble::tribble(
~common_name,~rank,~sci_name,
"Mammals","Class","Animalia",
"Birds","Class","Aves",
"Bony fish","Superclass","Osteichthyes",
"Amphibians","Class","Amphibia",
"Insects","Class","Insecta",
"Reptiles","Class","Reptilia",
"Molluscs","Phylum","Mollusca",
"Arachnids","Class","Arachnida",
"Flowering plants","Phylum","Magnoliophyta",
"Gymnosperms","Superclass","Gymnospermae",
"Ferns","Phylum","Pteridophyta",
"Mosses","Phylum","Bryophyta",
"Sac fungi","Phylum","Ascomycota",
"Basidiomycota","Phylum","Basidiomycota"
) %>% 
pull("sci_name") %>% # use fewer names if you want to just test 
taxize::get_gbifid_(method="backbone") %>% # match names to the GBIF backbone to get taxonkeys
imap(~ .x %>% mutate(original_sciname = .y)) %>% # add original name back into data.frame
bind_rows() %>%
glimpse() %>%
filter(rank == "kingdom") %>%
select(rank,usagekey)

keys
}

if(FALSE) { # process table 
common_names = tibble::tribble(
~common_name,~rank,~sci_name,
"Mammals","Class","Mammalia", 
"Birds","Class","Aves",
"Bony fish","Superclass","Osteichthyes",
"Amphibians","Class","Amphibia",
"Insects","Class","Insecta",
"Reptiles","Class","Reptilia",
"Molluscs","Phylum","Mollusca",
"Arachnids","Class","Arachnida",
"Flowering plants","Phylum","Magnoliophyta",
"Gymnosperms","Superclass","Gymnospermae",
"Ferns","Phylum","Pteridophyta",
"Mosses","Phylum","Bryophyta",
"Sac fungi","Phylum","Ascomycota",
"Basidiomycota","Phylum","Basidiomycota",
"Animals", "Kingdom","Animalia",
"Plants", "Kingdom","Plantae",
"Fungi", "Kingdom","Fungi"
) %>%
select(common_name,sci_name) %>%
glimpse()


d1 = common_names %>%
pull("sci_name") %>% # use fewer names if you want to just test 
taxize::get_gbifid_(method="backbone") %>% # match names to the GBIF backbone to get taxonkeys
imap(~ .x %>% mutate(sci_name = .y)) %>% # add original name back into data.frame
bind_rows() %>%
filter(matchtype == "EXACT") %>%
filter(status == "ACCEPTED") %>%
select(usagekey,scientificname,rank) %>%
mutate(sci_name = scientificname) %>%
glimpse() 

merge(common_names,d1,id="sci_name") %>%
glimpse() %>% 
datapasta::dpasta()
# arrange(rank) %>%
# select(usagekey,rank,sci_name) %>% 
# glimpse() 
# %>% 
# filter(rank == "class")

# pull(usagekey)


}

if(FALSE) { # regional taxanomic split ups
library(dplyr)
library(roperators)
library(purrr)

path = "C:/Users/ftw712/Desktop/gbif_regional_statistics/data/"

Files = c(
"gbif_regions_over_time_class.tsv",
"gbif_regions_over_time_kingdom.tsv",              
"gbif_regions_over_time_phylum.tsv"
)

common_names = data.frame(stringsAsFactors=FALSE,
sci_name = c("Amphibia", "Animalia", "Arachnida", "Ascomycota",
"Aves", "Basidiomycota", "Bryophyta", "Fungi", "Insecta",
"Mammalia", "Mollusca", "Plantae", "Reptilia"),
common_name = c("Amphibians", "Animals", "Arachnids", "Sac fungi",
"Birds", "Basidiomycota", "Mosses", "Fungi", "Insects",
"Mammals", "Molluscs", "Plants", "Reptiles"),
taxon_id = c(131L, 1L, 367L, 95L, 212L, 34L, 35L, 5L, 216L, 359L, 52L,
6L, 358L),
scientificname = c("Amphibia", "Animalia", "Arachnida", "Ascomycota",
"Aves", "Basidiomycota", "Bryophyta", "Fungi", "Insecta",
"Mammalia", "Mollusca", "Plantae", "Reptilia"),
rank = c("class", "kingdom", "class", "phylum", "class", "phylum",
"phylum", "kingdom", "class", "class", "phylum",
"kingdom", "class")
) %>%
glimpse()

d = Files %>% 
map(~ data.table::fread(path %+% .x) %>%
mutate(table_name = .x) %>% 
mutate(rank=stringr::str_replace_all(table_name,"gbif_regions_over_time_","")) %>%
mutate(rank=stringr::str_replace_all(rank,".tsv","")) 
) %>%
bind_rows() %>%
janitor::clean_names() %>%
mutate(gbif_region = stringr::str_replace_all(gbif_region,"_"," ")) %>%
mutate(gbif_region = stringr::str_to_title(gbif_region)) %>%
mutate(snapshot=stringr::str_replace_all(snapshot,"occurrence_","")) %>%
mutate(date=lubridate::ymd(snapshot)) %>%
filter(!gbif_region == "Antarctica") %>%
merge(common_names,id="taxon_id") %>%
glimpse()

parameters_1 = tibble(
taxa = d %>% pull(common_name) %>% unique(),
variable = "num_species",
ylab = "number of species",
) %>% 
mutate(title = paste0(taxa," - Number of Species on GBIF")) %>% 
glimpse()  

parameters_2 = tibble(
taxa = d %>% pull(common_name) %>% unique(),
variable = "num_of_occ",
ylab = "number of occurrences",
) %>% 
mutate(title = paste0(taxa," - Number of Occurrences on GBIF")) %>% 
glimpse()

parameters = rbind(parameters_1,parameters_2) %>%
purrr::transpose()


parameters

parameters %>%
map(~
gbifregionalstats::plot_time_series_taxa(
d,
variable=.x$variable,
ylab=.x$ylab,
title=.x$title,
taxa = .x$taxa
)) %>% 
map2(parameters,~ {
ggsave(paste0("C:/Users/ftw712/Desktop/gbif_regional_statistics/plots/time series/","timeseries_taxa_",.y$variable,"_",.y$taxa,".pdf"),plot=.x,width=6,height=5)
ggsave(paste0("C:/Users/ftw712/Desktop/gbif_regional_statistics/plots/time series/","timeseries_taxa_",.y$variable,"_",.y$taxa,".svg"),plot=.x,width=6,height=5)
ggsave(paste0("C:/Users/ftw712/Desktop/gbif_regional_statistics/plots/time series/","timeseries_taxa_",.y$variable,"_",.y$taxa,".jpg"),plot=.x,width=6,height=5,dpi=600)
})



}

if(FALSE) { # create generalized time series function 

library(dplyr)
library(roperators)
library(purrr)

d = readr::read_tsv("http://download.gbif.org/custom_download/jwaller/gbif_regions_time_series.tsv") %>%
mutate(gbif_region = stringr::str_replace_all(gbif_region,"_"," ")) %>%
mutate(gbif_region = stringr::str_to_title(gbif_region)) %>%
filter(!gbif_region == "Antarctica") %>%
mutate(date=stringr::str_replace_all(snapshot,"occurrence_","")) %>%
mutate(date=lubridate::ymd(date)) %>%
glimpse()

d_about = d %>% 
mutate(id = paste(snapshot,gbif_region,sep="_")) %>%
filter(type == "about") %>%
select(id,gbif_region,date,num_occ,num_species)

d_published = d %>% 
filter(type == "published") %>%
rename_at(c("num_occ","num_species"),function(x) paste0(x,"_published")) %>%
mutate(id = paste(snapshot,gbif_region,sep="_")) %>%
select(id,contains("_published")) %>%
glimpse() 

d = merge(d_about,d_published,id="id") %>%
glimpse()

parameters = tibble::tribble(
~variable,~subtitle,~title,~unit_MK,~unit_scale,
"num_species_published","Number of occurrences published on GBIF","Number of Species Published on GBIF","K",1e-3,
"num_species","Number of species about region on GBIF","Number of Species on GBIF","K",1e-3,
"num_occ","Number of occurrences about region on GBIF","Number of occurrences","M",1e-6,
"num_occ_published","Number of occurrences published by region on GBIF","Number of published occurrences on GBIF","M",1e-6
) %>% 
purrr::transpose()

parameters

parameters %>%
map(~
gbifregionalstats::plot_time_series(
d,
variable=.x$variable,
ylab="",
title=.x$title,
subtitle=.x$subtitle,
unit_MK = .x$unit_MK,
unit_scale = .x$unit_scale
)) %>% 
map2(parameters,~ {
ggsave(paste0("C:/Users/ftw712/Desktop/gbif_regional_statistics/plots/time series/","timeseries_",.y$variable,".pdf"),plot=.x,width=6,height=5)
ggsave(paste0("C:/Users/ftw712/Desktop/gbif_regional_statistics/plots/time series/","timeseries_",.y$variable,".svg"),plot=.x,width=6,height=5)
ggsave(paste0("C:/Users/ftw712/Desktop/gbif_regional_statistics/plots/time series/","timeseries_",.y$variable,".jpg"),plot=.x,width=6,height=5,dpi=600)
})

}

if(FALSE) { # timer series function version 1 
path = "C:/Users/ftw712/Desktop/gbif_regional_statistics/data/"

Files = c(
"gbif_regions_num_occ_over_time_with_birds.tsv",
"gbif_regions_num_occ_over_time_with_no_birds.tsv",
"gbif_regions_num_published_species_over_time.tsv",
"gbif_regions_num_species_over_time.tsv",
"gbif_regions_num_occ_published_over_time.tsv")

d = Files %>% 
map(~ data.table::fread(path %+% .x) %>%
mutate(gbifRegion=stringr::str_replace_all(gbifRegion,"_"," ")) %>%
mutate(id = paste(snapshot,gbifRegion,sep="_")) %>%
select(-snapshot,-gbifRegion)
) %>% 
reduce(left_join, by = "id") %>%
mutate(id=stringr::str_replace_all(id,"occurrence_","")) %>%
tidyr::separate(id, c("snapshot", "gbifRegion"),sep="_") %>%
mutate(date=lubridate::ymd(snapshot)) %>%
janitor::clean_names() %>%
mutate(gbif_region = stringr::str_replace_all(gbif_region,"_"," ")) %>%
mutate(gbif_region = stringr::str_to_title(gbif_region)) %>%
filter(!gbif_region == "Antarctica") %>%
na.omit() %>%
glimpse() 

parameters = tibble::tribble(
~variable,~subtitle,~title,~unit_MK,~unit_scale,
"num_published_species","Number of occurrences published on GBIF","Number of Species Published on GBIF","M",1e-6,
"num_species","Number of species about region on GBIF","Number of Species on GBIF","K",1e-3,
"num_of_occ","Number of occurrences about region on GBIF","Number of occurrences","M",1e-6,
"num_of_occ_no_birds","","Number of non-bird occurrences on GBIF","M",1e-6,
"num_published_of_occ","","Number of published occurrences on GBIF","K",1e-3
) %>% 
purrr::transpose()

parameters

parameters %>%
map(~
gbifregionalstats::plot_time_series(
d,
variable=.x$variable,
ylab="",
title=.x$title,
subtitle=.x$subtitle,
unit_MK = .x$unit_MK,
unit_scale = .x$unit_scale
)) %>% 
map2(parameters,~ {
ggsave(paste0("C:/Users/ftw712/Desktop/gbif_regional_statistics/plots/time series/","timeseries_",.y$variable,".pdf"),plot=.x,width=6,height=5)
ggsave(paste0("C:/Users/ftw712/Desktop/gbif_regional_statistics/plots/time series/","timeseries_",.y$variable,".svg"),plot=.x,width=6,height=5)
ggsave(paste0("C:/Users/ftw712/Desktop/gbif_regional_statistics/plots/time series/","timeseries_",.y$variable,".jpg"),plot=.x,width=6,height=5,dpi=600)
})

}

if(FALSE) { # regional country breakdowns about and published dotplots

# library(purrr)
# library(dplyr)

d_published = data.table::fread("C:/Users/ftw712/Desktop/gbif_regional_statistics/data/country_breakdown_data_published.tsv") %>%
filter(publisher_country != "null") %>%  
mutate(merge_id = paste(snapshot,publisher_country,sep="_")) %>%
select(merge_id,publisher_country,num_species_published,num_of_occ_published,num_datasets_published)  

d_about = data.table::fread("C:/Users/ftw712/Desktop/gbif_regional_statistics/data/country_breakdown_data_about.tsv") %>% 
mutate(merge_id = paste(snapshot,country,sep="_")) 

d = merge(d_about,d_published,id="merge_id",all.x=TRUE) %>%
select(-merge_id) %>%
glimpse() %>%
janitor::clean_names() %>%
mutate(snapshot=stringr::str_replace_all(snapshot,"occurrence_","")) %>%
mutate(date=lubridate::ymd(snapshot)) %>%
mutate(gbif_region = stringr::str_replace_all(gbif_region,"_"," ")) %>%
mutate(gbif_region = stringr::str_to_title(gbif_region)) %>%
mutate(iso2 = country) %>%
filter(!gbif_region == "Antarctica") %>%
glimpse()


parameters_occ_published = tibble(
variable = "num_of_occ_published",
gbif_region = d %>% pull(gbif_region) %>% unique()
) %>% 
mutate(plot_title = paste0(gbif_region, " - Number of Occurrences Published")) %>% 
mutate(plot_subtitle = "Number of occurrences published by country on GBIF") %>% 
mutate(y_lab = "number of occurrences") %>%
mutate(filter_count = 5e5) %>%
mutate(country_text_size = 11) %>%
mutate(unit_scale = 1e-6) %>%
mutate(unit_MK = "M") %>%
mutate(gain_color =  "#40BFFF") %>% 
mutate(comparison_snapshot = "2015-01-19") %>%
mutate(comparison_snapshot_label = "2015")

parameters_species_published = tibble(
variable = "num_species_published",
gbif_region = d %>% pull(gbif_region) %>% unique()
) %>% 
mutate(plot_title = paste0(gbif_region, " - Number of Species Published")) %>% 
mutate(plot_subtitle = "Number of species published by country on GBIF") %>% 
mutate(y_lab = "number of species") %>%
mutate(filter_count = 1e3) %>%
mutate(country_text_size = 11) %>%
mutate(unit_scale = 1e-3) %>%
mutate(unit_MK = "K") %>%
mutate(gain_color =  "#D66F27") %>% 
mutate(comparison_snapshot = "2015-01-19") %>%
mutate(comparison_snapshot_label = "2015")

parameters_num_species = tibble(
variable = "num_species",
gbif_region = d %>% pull(gbif_region) %>% unique()
) %>% 
mutate(plot_title = paste0(gbif_region, " - Number of Species")) %>% 
mutate(plot_subtitle = "Number of species about country on GBIF") %>% 
mutate(y_lab = "number of species") %>%
mutate(filter_count = 1e4) %>%
mutate(country_text_size = 11) %>%
mutate(unit_scale = 1e-3) %>%
mutate(unit_MK = "K") %>%
mutate(gain_color =  "#FDAF02") %>% 
mutate(comparison_snapshot = "2015-01-19") %>%
mutate(comparison_snapshot_label = "2015") %>% 
glimpse() 

parameters_num_of_occ = tibble(
variable = "num_of_occ",
gbif_region = d %>% pull(gbif_region) %>% unique()
) %>% 
mutate(plot_title = paste0(gbif_region, " - Number of Occurrences")) %>% 
mutate(plot_subtitle = "Number of occurrences about country on GBIF") %>% 
mutate(y_lab = "number of occurrences") %>%
mutate(filter_count = 1e6) %>%
mutate(country_text_size = 11) %>%
mutate(unit_scale = 1e-6) %>%
mutate(unit_MK = "M") %>%
mutate(gain_color =  "#509E2F") %>% 
mutate(comparison_snapshot = "2015-01-19") %>%
mutate(comparison_snapshot_label = "2015") %>% 
glimpse()

parameters = rbind(
parameters_num_of_occ,
parameters_num_species,
parameters_occ_published,
parameters_species_published
) %>% 
purrr::transpose()

library(ggplot2)

parameters %>%
map( ~
gbifregionalstats::plot_country_dotplot(
d,
variable = .x$variable,
plot_title = .x$plot_title,
y_lab = .x$y_lab,
country_text_size = .x$country_text_size,
gbif_region = .x$gbif_region,
filter_count = .x$filter_count,
plot_subtitle = .x$plot_subtitle,
unit_MK = .x$unit_MK,
unit_scale = .x$unit_scale,
gain_color =  .x$gain_color,
comparison_snapshot = .x$comparison_snapshot,
comparison_snapshot_label = .x$comparison_snapshot_label,
plot_lower = FALSE
)) %>%
map2(parameters,~{
ggsave(paste0("C:/Users/ftw712/Desktop/gbif_regional_statistics/plots/country dotplots/country_dotplot_",.y$variable,"_",.y$gbif_region,".pdf"),plot=.x,width=6,height=5)
ggsave(paste0("C:/Users/ftw712/Desktop/gbif_regional_statistics/plots/country dotplots/country_dotplot_",.y$variable,"_",.y$gbif_region,".svg"),plot=.x,width=6,height=5)
ggsave(paste0("C:/Users/ftw712/Desktop/gbif_regional_statistics/plots/country dotplots/country_dotplot_",.y$variable,"_",.y$gbif_region,".jpg"),plot=.x,width=6,height=5,dpi=600)
})

}

if(FALSE) { # stacked bar charts taxonomic breakdowns by country

library(dplyr)
library(purrr)

# d = data.table::fread("C:/Users/ftw712/Desktop/gbif_regional_statistics/data/country_breakdown_taxon.tsv",na.strings="null") %>% 
d = readr::read_tsv("http://download.gbif.org/custom_download/jwaller/country_breakdown_taxon.tsv") %>%
mutate(iso2=countrycode) %>%
merge(gbifapi::get_gbif_countries() %>% select(iso2,title,gbifRegion),id="iso2") %>%
janitor::clean_names() %>%
mutate(gbif_region = stringr::str_replace_all(gbif_region,"_"," ")) %>%
mutate(gbif_region = stringr::str_to_title(gbif_region)) %>%
filter(!gbif_region == "Antarctica") %>%
glimpse()

parameters_about = tibble::tibble(
gbif_region = unique(d$gbif_region)
) %>% 
mutate(top_groups = list(c("Birds","Plants","Insects","Fungi","Mammals"))) %>%
mutate(variable = "num_of_occ") %>%
mutate(variable_total = "occ_total") %>% 
mutate(plot_title = paste0(gbif_region," - Number of Occurrences")) %>%
mutate(plot_subtitle = "Number of occurrences about country for popular groups") %>% 
mutate(total_filter = 500e3) %>%
mutate(
color_values = list(c(
Birds = "#ff9326", 
Plants = "#509E2F", 
Mammals = "#175CA1", 
Insects = "#40BFFF",
Fungi = "#FDAF02", 
Other = "#ff0040"))) %>%
glimpse() 

parameters_published = tibble::tibble(
gbif_region = unique(d$gbif_region)
) %>% 
mutate(top_groups = list(c("Birds","Plants","Insects","Fungi","Mammals"))) %>%
mutate(variable = "num_of_occ_published") %>%
mutate(variable_total = "occ_published_total") %>% 
mutate(plot_title = paste0(gbif_region," - Number of Published Occurrences")) %>%
mutate(plot_subtitle = "Number of published occurrences by country for popular groups") %>% 
mutate(total_filter = 200e3) %>%
mutate(
color_values = list(c(
Birds = "#ff9326", 
Plants = "#509E2F", 
Mammals = "#175CA1", 
Insects = "#40BFFF",
Fungi = "#FDAF02", 
Other = "#ff0040"))) %>%
glimpse()

parameters = rbind(parameters_about,parameters_published) %>%
purrr::transpose()

parameters %>%
map(~
gbifregionalstats::plot_taxon_breakdown(
d,
variable = .x$variable,
variable_total = .x$variable_total,
gbif_region = .x$gbif_region,
top_groups = .x$top_groups,
plot_title = .x$plot_title,
plot_subtitle = .x$plot_subtitle,
country_text_size = 11,
color_values = .x$color_values,
total_filter = .x$total_filter
)) %>% 
map2(parameters,~{
ggsave(paste0("C:/Users/ftw712/Desktop/gbif_regional_statistics/plots/country stacked barplots/country_stacked_",.y$variable,"_",.y$gbif_region,".pdf"),plot=.x,width=6,height=5)
ggsave(paste0("C:/Users/ftw712/Desktop/gbif_regional_statistics/plots/country stacked barplots/country_stacked_",.y$variable,"_",.y$gbif_region,".svg"),plot=.x,width=6,height=5)
ggsave(paste0("C:/Users/ftw712/Desktop/gbif_regional_statistics/plots/country stacked barplots/country_stacked_",.y$variable,"_",.y$gbif_region,".jpg"),plot=.x,width=6,height=5,dpi=600)
})

}

if(FALSE) { # stacked barchart other views  

library(dplyr)
library(purrr)

d = data.table::fread("C:/Users/ftw712/Desktop/gbif_regional_statistics/data/country_breakdown_taxon.tsv",na.strings="null") %>% 
mutate(iso2=countrycode) %>%
merge(gbifapi::get_gbif_countries() %>% select(iso2,title,gbifRegion),id="iso2") %>%
janitor::clean_names() %>%
mutate(gbif_region = stringr::str_replace_all(gbif_region,"_"," ")) %>%
mutate(gbif_region = stringr::str_to_title(gbif_region)) %>%
filter(!gbif_region == "Antarctica") %>%
glimpse()

parameters_about = tibble::tibble(
gbif_region = unique(d$gbif_region)
) %>% 
mutate(top_groups = list(c("Birds","Plants","Insects","Fungi","Mammals"))) %>%
mutate(variable = "num_of_occ") %>%
mutate(variable_total = "occ_total") %>% 
mutate(plot_title = paste0(gbif_region," - Number of Occurrences")) %>%
mutate(plot_subtitle = "Number of occurrences about country for popular groups") %>% 
mutate(total_filter = 500e3) %>%
mutate(
color_values = list(c(
Birds = "#ff9326", 
Plants = "#509E2F", 
Mammals = "#175CA1", 
Insects = "#40BFFF",
Fungi = "#FDAF02", 
Other = "#ff0040"))) %>%
glimpse() 

parameters_published = tibble::tibble(
gbif_region = unique(d$gbif_region)
) %>% 
mutate(top_groups = list(c("Birds","Plants","Insects","Fungi","Mammals"))) %>%
mutate(variable = "num_of_occ_published") %>%
mutate(variable_total = "occ_published_total") %>% 
mutate(plot_title = paste0(gbif_region," - Number of Published Occurrences")) %>%
mutate(plot_subtitle = "Number of published occurrences by country for popular groups") %>% 
mutate(total_filter = 200e3) %>%
mutate(
color_values = list(c(
Birds = "#ff9326", 
Plants = "#509E2F", 
Mammals = "#175CA1", 
Insects = "#40BFFF",
Fungi = "#FDAF02", 
Other = "#ff0040"))) %>%
glimpse()

parameters = rbind(parameters_about,parameters_published) %>%
purrr::transpose()

parameters %>%
map(~
gbifregionalstats::plot_taxon_breakdown(
d,
variable = .x$variable,
variable_total = .x$variable_total,
gbif_region = .x$gbif_region,
top_groups = .x$top_groups,
plot_title = .x$plot_title,
plot_subtitle = .x$plot_subtitle,
country_text_size = 11,
color_values = .x$color_values,
total_filter = .x$total_filter
)) %>% 
map2(parameters,~{
ggsave(paste0("C:/Users/ftw712/Desktop/gbif_regional_statistics/plots/country stacked barplots/country_stacked_",.y$variable,"_",.y$gbif_region,".pdf"),plot=.x,width=6,height=5)
ggsave(paste0("C:/Users/ftw712/Desktop/gbif_regional_statistics/plots/country stacked barplots/country_stacked_",.y$variable,"_",.y$gbif_region,".svg"),plot=.x,width=6,height=5)
ggsave(paste0("C:/Users/ftw712/Desktop/gbif_regional_statistics/plots/country stacked barplots/country_stacked_",.y$variable,"_",.y$gbif_region,".jpg"),plot=.x,width=6,height=5,dpi=600)
})


}


if(FALSE) { # taxonkey
library(dplyr)
library(wbstats)

d_gbif = readr::read_tsv("http://download.gbif.org/custom_download/jwaller/country_breakdown_taxon.tsv") %>% 
mutate(iso2 = countrycode) %>%
glimpse() 

d_country = 
gbifapi::get_gbif_countries() %>% 
pull(iso2) %>%
wb(country = ., 
indicator = c("SP.POP.TOTL","NY.GDP.MKTP.CD","NY.GDP.PCAP.CD","AG.LND.TOTL.K2"),
startdate = 2018, enddate = 2019) %>% 
select(iso2 = iso2c,indicator,value) %>% 
tidyr::pivot_wider(names_from = indicator, values_from = value) %>% 
merge(gbifapi::get_gbif_countries(),id="iso2") %>% 
janitor::clean_names() %>%
mutate(gbif_region = stringr::str_replace_all(gbif_region,"_"," ")) %>%
mutate(gbif_region = stringr::str_to_title(gbif_region)) %>%
filter(!gbif_region == "Antarctica") %>% 
glimpse()

d = merge(d_country, d_gbif, id="iso2") %>% 
select(
iso2,
title,
gbif_region,
countrycode,
publishingcountry,
taxonkey,
num_species_published,
num_of_occ_published,
occ_published_total,
species_published_total,
occ_total,
species_total,
population_total,
gdp_current_us,
gdp_per_capita_current_us,
land_area_sq_km
) %>% 
glimpse() %>%
saveRDS("C:/Users/ftw712/Desktop/d.rda")
}

if(FALSE) { # process occ by GDP/ Population size 

library(wbstats)
library(dplyr)

d_gbif = readr::read_tsv("http://download.gbif.org/custom_download/jwaller/country_counts_time_series.tsv") %>%
filter(snapshot == "occurrence_20200101") %>% 
mutate(row = row_number()) %>%
tidyr::pivot_wider(names_from = c(type), values_from = c(occ_count,species_count)) %>%
mutate(iso2 = country)

d_country = 
gbifapi::get_gbif_countries() %>% 
pull(iso2) %>%
wb(country = ., 
indicator = c("SP.POP.TOTL","NY.GDP.MKTP.CD","NY.GDP.PCAP.CD","AG.LND.TOTL.K2"),
startdate = 2018, enddate = 2019) %>% 
select(iso2 = iso2c,indicator,value) %>% 
tidyr::pivot_wider(names_from = indicator, values_from = value) %>% 
merge(gbifapi::get_gbif_countries(),id="iso2") %>% 
janitor::clean_names() %>%
mutate(gbif_region = stringr::str_replace_all(gbif_region,"_"," ")) %>%
mutate(gbif_region = stringr::str_to_title(gbif_region)) %>%
filter(!gbif_region == "Antarctica") 

d = merge(d_country, d_gbif, id="iso2") %>% 
select(
iso2,
title,
gbif_region,
occ_count_about,
occ_count_published,
species_count_about,
species_count_published,
population_total,
gdp_current_us,
gdp_per_capita_current_us,
land_area_sq_km
) %>%
glimpse() %>%
saveRDS("C:/Users/ftw712/Desktop/d.rda")
}

if(FALSE) { # GDP plots
library(dplyr)
library(purrr)

d = readRDS("C:/Users/ftw712/Desktop/d.rda") %>% 
filter(taxonkey == 212) %>% 
glimpse() %>%
mutate(num_occ_published_birds = num_of_occ_published) %>%
mutate(num_occ_published_nobirds = occ_published_total - num_occ_published_birds) %>%
glimpse() %>% 
filter(num_occ_published_nobirds > 50e3) %>% # only with 50K occurrences
filter(occ_published_total > 50e3) %>% # only with 50K occurrences
filter(land_area_sq_km > 10e3) %>%
filter(gdp_per_capita_current_us > 500) %>% 
glimpse() %>%
select(iso2,title,gbif_region,occ_published_total,num_occ_published_nobirds,land_area_sq_km,gdp_current_us,gdp_per_capita_current_us,population_total) %>%
na.omit() 

parameters_1 = tibble(
variable = "occ_published_total",
gdp_variable = "gdp_per_capita_current_us",
title = "Number of Occurrences Published",
subtitle = "published occurrences after controlling for country GDP",
full_model = c(TRUE,FALSE)
) 

parameters_2 = tibble(
variable = "num_occ_published_nobirds",
gdp_variable = "gdp_per_capita_current_us",
title = "Number of Non-Bird Occurrences Published",
subtitle = "published occurrences after controlling for country GDP",
full_model = c(TRUE,FALSE)
)

parameters = rbind(parameters_1,parameters_2) %>%
purrr::transpose() 

parameters

# path_to_plots = "C:/Users/ftw712/Desktop/gbif_regional_statistics/plots/"

parameters %>%  
map(~
gbifregionalstats::gdp_plot(
variable = .x$variable,
gdp_variable = .x$gdp_variable,
title = .x$title,
subtitle = .x$subtitle,
full_model = .x$full_model
)) %>%
map2(parameters,~{
ggsave(paste0(path_to_plots,"gdp plots/",.y$gdp_variable,"_",.y$variable,"_full_model_",.y$full_model,".pdf"),plot=.x,width=9,height=6)
ggsave(paste0(path_to_plots,"gdp plots/",.y$gdp_variable,"_",.y$variable,"_full_model_",.y$full_model,".svg"),plot=.x,width=9,height=6)
ggsave(paste0(path_to_plots,"gdp plots/",.y$gdp_variable,"_",.y$variable,"_full_model_",.y$full_model,".jpg"),plot=.x,dpi=600,width=9,height=6)
})


# p = gbifregionalstats::gdp_plot(
# variable = "occ_published_total",
# gdp_variable = "gdp_per_capita_current_us",
# title = "Number of Occurrences Published",
# subtitle = "published occurrences after controlling for country GDP",
# full_model = FALSE
# )

# ggsave(paste0("C:/Users/ftw712/Desktop/gbif_regional_statistics/plots/plot2.pdf"),plot=p,width=9,height=6)
# ggsave(paste0("C:/Users/ftw712/Desktop/gbif_regional_statistics/plots/plot2.jpg"),plot=p,width=8,height=5,dpi=600)

}

if(FALSE) { # fixing country breakdowns 

library(dplyr)
library(purrr)

d = readr::read_tsv("http://download.gbif.org/custom_download/jwaller/country_breakdown_taxon.tsv") %>%
mutate(iso2=countrycode) %>%
merge(gbifapi::get_gbif_countries() %>% select(iso2,title,gbifRegion),id="iso2") %>%
janitor::clean_names() %>%
mutate(gbif_region = stringr::str_replace_all(gbif_region,"_"," ")) %>%
mutate(gbif_region = stringr::str_to_title(gbif_region)) %>%
filter(!gbif_region == "Antarctica") %>%
glimpse()

parameters_global = tibble::tibble(
gbif_region = "Global",
global = TRUE
) %>% 
mutate(top_groups = list(c("Birds","Plants","Insects","Fungi","Mammals"))) %>%
mutate(variable = "num_of_occ") %>%
mutate(variable_total = "occ_total") %>% 
mutate(plot_title = paste0(gbif_region," - Number of Occurrences")) %>%
mutate(plot_subtitle = "Number of occurrences about country for popular groups") %>% 
mutate(total_filter = 5e6) %>%
mutate(
color_values = list(c(
Birds = "#ff9326", 
Plants = "#509E2F", 
Mammals = "#175CA1", 
Insects = "#40BFFF",
Fungi = "#FDAF02", 
Other = "#ff0040"))) %>%
glimpse() 



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

  return(p)
}

path_to_plots = "C:/Users/ftw712/Desktop/gbif_regional_statistics/plots/"

parameters = parameters_global %>%
purrr::transpose()

parameters %>%
map(~
plot_taxon_breakdown(
d,
variable = .x$variable,
variable_total = .x$variable_total,
gbif_region = .x$gbif_region,
top_groups = .x$top_groups,
plot_title = .x$plot_title,
plot_subtitle = .x$plot_subtitle,
country_text_size = 11,
color_values = .x$color_values,
total_filter = .x$total_filter
)) %>% 
map2(parameters,~{
ggsave(paste0(path_to_plots,"/plot.pdf"),plot=.x,width=6,height=5)
# ggsave(paste0(path_to_plots,"country stacked barplots/country_stacked_",.y$variable,"_",.y$gbif_region,".pdf"),plot=.x,width=6,height=5)
# ggsave(paste0(path_to_plots,"country stacked barplots/country_stacked_",.y$variable,"_",.y$gbif_region,".svg"),plot=.x,width=6,height=5)
# ggsave(paste0(path_to_plots,"country stacked barplots/country_stacked_",.y$variable,"_",.y$gbif_region,".jpg"),plot=.x,width=6,height=5,dpi=600)
})


}


if(FALSE) { # rename regions
# Africa
# Asia
# Europe & Central Asia
# Latin America &\nThe Caribbean
# North America
# Oceania
}

if(FALSE) { # installations exploration
library(dplyr)
library(purrr)

path = "C:/Users/ftw712/Desktop/"

d = readxl::read_excel(
paste0(path,"gbif_regional_statistics/data/information_installations_per_region_nodes_2020-03-05.xlsx"),
sheet = "ENDOSING NODE") %>% 
janitor::clean_names() %>%
mutate(number_of_installations_with_some_failed_ingestion = as.numeric(number_of_installations_with_some_failed_ingestion)) %>% 
merge(gbifapi::get_nodes_data(),id="node_title") %>%
mutate(number_of_installations_with_some_failed_ingestion) %>%
tidyr::pivot_longer(contains("number_of_")) %>%
filter(!name == "number_of_installations") %>%
filter(!value == 0) %>%
mutate(name = stringr::str_replace_all(name,"number_of_installations_with_","")) %>%
mutate(name = stringr::str_replace_all(name,"no_failed_ingestion","Healthy")) %>%
mutate(name = stringr::str_replace_all(name,"only_failed_ingestion","Always Failed Ingestion")) %>%
mutate(name = stringr::str_replace_all(name,"some_failed_ingestion","Some Failed Ingestion")) %>%
mutate(name = stringr::str_replace_all(name,"no_datasets","No Datasets")) %>%
group_by(node_title) %>%
mutate(total_installations = sum(value)) %>%
ungroup() %>%
group_by(gbif_region) %>% 
mutate(total_installations_region = max(value)) %>%
ungroup() 

path_to_plots = "C:/Users/ftw712/Desktop/gbif_regional_statistics/plots/"

p = gbifregionalstats::plot_network_health(
d,
legend_position = c(0.78,1.08),
title_hjust=-0.55,
subtitle_hjust=-1.165,
type = "COUNTRY")

ggsave(paste0(path_to_plots,"network health/pdf/network_health_country.pdf"),plot=p,width=7,height=10)
ggsave(paste0(path_to_plots,"network health/svg/network_health_country.svg"),plot=p,width=7,height=10)
ggsave(paste0(path_to_plots,"network health/jpg/network_health_country.jpg"),plot=p,width=7,height=10,dpi=600)

p = gbifregionalstats::plot_network_health(
d,
legend_position = c(0.75,1.08),
title_hjust=-0.98,
subtitle_hjust=-3.465,
type = "OTHER"
)

ggsave(paste0(path_to_plots,"network health/pdf/network_health_other.pdf"),plot=p,width=7,height=10)
ggsave(paste0(path_to_plots,"network health/svg/network_health_other.svg"),plot=p,width=7,height=10)
ggsave(paste0(path_to_plots,"network health/jpg/network_health_other.jpg"),plot=p,width=7,height=10,dpi=600)

}

if(FALSE) { # facet grid stacked bar charts 

library(purrr)
library(dplyr)

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
      strip.text = element_blank()
    )

  return(p)
  
}


d = readr::read_tsv("http://download.gbif.org/custom_download/jwaller/country_breakdown_taxon.tsv") %>%
mutate(iso2=countrycode) %>%
merge(gbifapi::get_gbif_countries() %>% select(iso2,title,gbifRegion),id="iso2") %>%
janitor::clean_names() %>%
mutate(gbif_region = stringr::str_replace_all(gbif_region,"_"," ")) %>%
mutate(gbif_region = stringr::str_to_title(gbif_region)) %>%
filter(!gbif_region == "Antarctica")

d$taxonkey %>% unique()

# parameters 
parameters_about = tibble::tibble(
gbif_region = c("Global")
) %>% 
mutate(top_groups = list(c("Birds","Plants","Insects","Fungi","Mammals"))) %>%
mutate(variable = "num_of_occ") %>%
mutate(variable_total = "occ_total") %>% 
mutate(plot_title = paste0(gbif_region," - Number of Occurrences")) %>%
mutate(plot_subtitle = "Number of occurrences about country/area") %>% 
mutate(total_filter = 1e6) %>%
mutate(
color_values = list(c(
Birds = "#ff9326", 
Plants = "#509E2F", 
Mammals = "#175CA1", 
Insects = "#40BFFF",
Fungi = "#FDAF02", 
Other = "#ff0040"))) %>%
mutate(no_birds = FALSE) %>% 
glimpse() 

parameters_published = tibble::tibble(
gbif_region = c("Global")
) %>% 
mutate(top_groups = list(c("Birds","Plants","Insects","Fungi","Mammals"))) %>%
mutate(variable = "num_of_occ_published") %>%
mutate(variable_total = "occ_published_total") %>% 
mutate(plot_title = paste0(gbif_region," - Number of Published Occurrences")) %>%
mutate(plot_subtitle = "Number of published occurrences by country/area") %>% 
mutate(total_filter = 1e6) %>%
mutate(
color_values = list(c(
Birds = "#ff9326", 
Plants = "#509E2F", 
Mammals = "#175CA1", 
Insects = "#40BFFF",
Fungi = "#FDAF02", 
Other = "#ff0040"))) %>%
mutate(no_birds = FALSE) %>% 
glimpse() 


# parameters no birds 
parameters_about_nobirds = tibble::tibble(
gbif_region = c("Global")
) %>% 
mutate(top_groups = list(c("Birds","Plants","Insects","Fungi","Mammals","Molluscs"))) %>%
mutate(variable = "num_of_occ") %>%
mutate(variable_total = "occ_total") %>% 
mutate(plot_title = paste0(gbif_region," - Number of Occurrences (No Birds)")) %>%
mutate(plot_subtitle = "Number of occurrences about country/area") %>% 
mutate(total_filter = 1e6) %>%
mutate(
color_values = list(c(
Molluscs = "#ffcccc",
Birds = "#ff9326", 
Plants = "#509E2F", 
Mammals = "#175CA1", 
Insects = "#40BFFF",
Fungi = "#FDAF02", 
Other = "#ff0040"))) %>%
mutate(no_birds = TRUE) 

parameters_published_nobirds = tibble::tibble(
gbif_region = c("Global")
) %>% 
mutate(top_groups = list(c("Birds","Plants","Insects","Fungi","Mammals","Molluscs"))) %>%
mutate(variable = "num_of_occ_published") %>%
mutate(variable_total = "occ_published_total") %>% 
mutate(plot_title = paste0(gbif_region," - Number of Published Occurrences")) %>%
mutate(plot_subtitle = "Number of published occurrences by country/area") %>% 
mutate(total_filter = 1e6) %>%
mutate(
color_values = list(c(
Molluscs = "#ffcccc",
Birds = "#ff9326", 
Plants = "#509E2F", 
Mammals = "#175CA1", 
Insects = "#40BFFF",
Fungi = "#FDAF02", 
Other = "#ff0040"))) %>%
mutate(no_birds = TRUE) 

parameters = 
rbind(
parameters_about,
parameters_published,
parameters_about_nobirds,
parameters_published_nobirds
) %>%
purrr::transpose()

parameters

path_to_plots = "C:/Users/ftw712/Desktop/gbif_regional_statistics/plots/"

library(ggplot2)

parameters %>%
map(~
stacked_bar_facet(
d,
variable = .x$variable,
variable_total = .x$variable_total,
gbif_region = .x$gbif_region,
top_groups = .x$top_groups,
plot_title = .x$plot_title,
plot_subtitle = .x$plot_subtitle,
country_text_size = 10,
color_values = .x$color_values,
total_filter = .x$total_filter,
no_birds = .x$no_birds
)) %>% 
map2(parameters,~{
ggsave(paste0(path_to_plots,"country stacked barplots facet/pdf/facet_stacked_",.y$variable,"_",.y$gbif_region,"_nobirds_",.y$no_birds,".pdf"),plot=.x,width=6,height=10)
ggsave(paste0(path_to_plots,"country stacked barplots facet/svg/facet_stacked_",.y$variable,"_",.y$gbif_region,"_nobirds_",.y$no_birds,".svg"),plot=.x,width=6,height=10)
ggsave(paste0(path_to_plots,"country stacked barplots facet/jpg/facet_stacked_",.y$variable,"_",.y$gbif_region,"_nobirds_",.y$no_birds,".jpg"),plot=.x,width=6,height=10,dpi=600)
})

}

if(FALSE) { ## make map of regions 

library(tmap)
library(dplyr)
data("World") 


d = World %>% 
mutate(iso3 = iso_a3) %>%
merge(gbifapi::get_gbif_countries(),id="iso3") %>% 
janitor::clean_names() %>%
mutate(`GBIF Region` = gbifapi::replace_gbif_region(gbif_region)) %>%
mutate(`GBIF Region` = forcats::fct_relevel(`GBIF Region`,
c(
"Europe and Central Asia",
"North America",
"Asia",
"Latin America and The Caribbean",
"Africa",
"Oceania",
"Antarctica"
))) %>%
glimpse() 

region_colors = c(
"Europe and Central Asia" = "#509E2F",
"North America" = "#FDAF02",
"Oceania" = "#D66F27",
"Asia" = "#ffcccc",
"Latin America and The Caribbean" = "#40BFFF",
"Africa" = "#ff4c4d",
"Antarctica" = "gray"
)

tm = tm_shape(d) +
tm_polygons("GBIF Region",
palette = region_colors) +
tm_layout("",
          legend.title.size = 1.5,
          legend.text.size = 1,
          legend.position = c("left","bottom"),
          legend.bg.color = NA,
          legend.bg.alpha = 1)

path_to_plots = "C:/Users/ftw712/Desktop/gbif_regional_statistics/plots/"
		  
tmap_save(tm,filename=paste0(path_to_plots,"gbif region map/pdf/gbif_region_map.pdf"))
tmap_save(tm,filename=paste0(path_to_plots,"gbif region map/jpg/gbif_region_map.jpg"))
tmap_save(tm,filename=paste0(path_to_plots,"gbif region map/svg/gbif_region_map.svg"))

}


if(FALSE) { # data use 
library(dplyr)
library(tidyr)

# citation statistics from Daniel

d = tibble::tribble(
~region, ~`total citations`, ~num_occurrences,~`citations per 10M occurrences`,~num_publishers,
"AFRICA",284,32368381,88,221,
"ASIA",353,38511527,92,118,
"EUROPE",663,594946055,11,809,
"LATIN_AMERICA",475,70968100,67,390,
"NORTH_AMERICA",645,562429807,11,304,
"OCEANIA",407,86935324,47,124,
"no_region",391,16503417,237,41) %>% 
select(region,`total citations`,`citations per 10M occurrences`,num_publishers) %>%
mutate(region = gbifapi::replace_gbif_region(region,shorten=TRUE)) %>%
tidyr::pivot_longer(cols = c(`total citations`,`citations per 10M occurrences`)) %>%
filter(!region == "no region") %>%
mutate(region = forcats::fct_relevel(region,
c(
"Africa",
"Asia",                          
"Oceania",
"Latin America &\nThe Caribbean",
"North America",                  
"Europe &\nCentral Asia"         
))) %>%
mutate(name = forcats::fct_relevel(name,
c(
"total citations",
"citations per 10M occurrences"
))) %>%
glimpse() 

path_to_plots = "C:/Users/ftw712/Desktop/gbif_regional_statistics/plots/"

library(ggplot2)
p = ggplot(d,aes(value,region,fill=region)) +
    geom_col(position = position_stack(reverse = TRUE)) + 
	facet_grid(. ~ name,scales="free") +
    theme_bw() +
    theme(strip.background = element_blank()) + 
    theme(strip.text.x = element_text(size = 12,
	face="bold",
	hjust=-0.005,
	margin = margin(t = 15, r = 0, b = 15, l = 0))) + 
	theme(axis.title.x = element_text(size = 12,
	face="plain",
	margin = margin(t = 10, r = 0, b = 15, l = 0))) +
	ylab("") + 
	xlab("peer-reviewed citations") + 
	labs(title = "Data Use",
         subtitle = "Citations from peer-reviewed journals of GBIF mediated data",
         caption="Unique, peer-reviewed journal articles citing use of data published by publisher in region") +
	scale_fill_manual(values = c(
    "Europe &\nCentral Asia"="#509E2F",
    "North America" ="#FDAF02",
    "Oceania" = "#D66F27",
    "Asia" = "#ffcccc",
    "Latin America &\nThe Caribbean" = "#40BFFF",
    "Africa" = "#ff4c4d"
	)) +
	theme(
	  plot.title = element_text(
      margin = margin(t = 0, r = 0, b = 4, l = 0),
      size = 18, 
	  face="bold",
	  color="#535362")) +	
	theme(legend.position = "none")
	
ggsave(paste0(path_to_plots,"data use/pdf/data_use.pdf"),plot=p,width=16*0.5,height=9*0.5)
ggsave(paste0(path_to_plots,"data use/svg/data_use.svg"),plot=p,width=16*0.5,height=9*0.5)
ggsave(paste0(path_to_plots,"data use/jpg/data_use.jpg"),plot=p,width=16*0.5,height=9*0.5,dpi=600)

}

if(FALSE) { # change in number of species since 2015 dotplots
# library(dplyr)
# library(purrr)

# d = readr::read_tsv("http://download.gbif.org/custom_download/jwaller/country_counts_time_series.tsv") %>%
# mutate(iso2 = country) %>%
# merge(gbifapi::get_gbif_countries(),id="iso2") %>%
# janitor::clean_names() %>%
# mutate(snapshot=stringr::str_replace_all(snapshot,"occurrence_","")) %>%
# mutate(date=lubridate::ymd(snapshot)) %>%
# mutate(gbif_region = stringr::str_replace_all(gbif_region,"_"," ")) %>%
# mutate(gbif_region = stringr::str_to_title(gbif_region)) %>%
# mutate(gbif_region = gbifapi::replace_gbif_region(gbif_region,shorten=FALSE)) %>%
# filter(!gbif_region == "Antarctica") %>% 
# glimpse()





################################################ Global Parameters 

# parameters_num_of_occ_global = tibble(
# variable = "occ_count",
# gbif_region = "Global"
# ) %>% 
# mutate(plot_title = paste0(gbif_region, "")) %>% 
# mutate(plot_subtitle = "Number of occurrences about country on GBIF") %>% 
# mutate(y_lab = "number of occurrences") %>%
# mutate(filter_count = 5e6) %>%
# mutate(country_text_size = 11) %>%
# mutate(unit_scale = 1e-6) %>%
# mutate(unit_MK = "M") %>%
# mutate(gain_color =  "#509E2F") %>% 
# mutate(comparison_snapshot = "2015-01-19") %>%
# mutate(comparison_snapshot_label = "2015") 

# parameters_num_species_global = tibble(
# variable = "species_count",
# gbif_region = "Global"
# ) %>% 
# mutate(plot_title = paste0(gbif_region, "")) %>% 
# mutate(plot_subtitle = "Number of species about country on GBIF") %>% 
# mutate(y_lab = "number of species") %>%
# mutate(filter_count = 2e4) %>%
# mutate(country_text_size = 11) %>%
# mutate(unit_scale = 1e-3) %>%
# mutate(unit_MK = "K") %>%
# mutate(gain_color =  "#FDAF02") %>% 
# mutate(comparison_snapshot = "2015-01-19") %>%
# mutate(comparison_snapshot_label = "2015") 

# parameters_occ_published_global = tibble(
# variable = "occ_count_published",
# gbif_region = "Global"
# ) %>% 
# mutate(plot_title = paste0(gbif_region, "")) %>% 
# mutate(plot_subtitle = "Number of occurrences published by country on GBIF") %>% 
# mutate(y_lab = "number of occurrences") %>%
# mutate(filter_count = 5e5) %>%
# mutate(country_text_size = 11) %>%
# mutate(unit_scale = 1e-6) %>%
# mutate(unit_MK = "M") %>%
# mutate(gain_color =  "#40BFFF") %>% 
# mutate(comparison_snapshot = "2015-01-19") %>%
# mutate(comparison_snapshot_label = "2015")

# parameters_species_published_global = tibble(
# variable = "species_count_published",
# gbif_region = "Global"
# ) %>% 
# mutate(plot_title = paste0(gbif_region, "")) %>% 
# mutate(plot_subtitle = "Number of species published by country on GBIF") %>% 
# mutate(y_lab = "number of species") %>%
# mutate(filter_count = 1e4) %>%
# mutate(country_text_size = 11) %>%
# mutate(unit_scale = 1e-3) %>%
# mutate(unit_MK = "K") %>%
# mutate(gain_color =  "#D66F27") %>% 
# mutate(comparison_snapshot = "2015-01-19") %>%
# mutate(comparison_snapshot_label = "2015")



# plot_country_dotplot_change = function(
  # d,
  # variable = "num_species",
  # plot_title = "Europe - Number of Species",
  # y_lab = "number of species",
  # country_text_size = 10,
  # gbif_region = "Europe",
  # filter_count = 1e4,
  # plot_subtitle = "Unique species with occurrences in country",
  # unit_MK = "M",
  # unit_scale = 1e-3,
  # gain_color =  "#FDAF02",
  # comparison_snapshot = "2015-01-19",
  # comparison_snapshot_label = "2015",
  # plot_lower = FALSE
# ) {
  # if(gbif_region == "Global") {

    # d = gbifapi::get_gbif_countries() %>%
      # select(iso2,title) %>%
      # merge(d,id=iso2) %>%
      # mutate(title = gbifapi::clean_country_titles(title)) %>%
      # mutate(date = as.character(date)) %>%
      # filter(date == !! comparison_snapshot | date == "2020-01-01") %>%
      # select(title,
             # date,
             # species_count,
             # occ_count
      # )
  # } else {

    # d = gbifapi::get_gbif_countries() %>%
      # select(iso2,title) %>%
      # merge(d,id=iso2) %>%
      # mutate(title = gbifapi::clean_country_titles(title)) %>%
      # mutate(date = as.character(date)) %>%
      # filter(gbif_region == !! gbif_region) %>%
      # filter(date == !! comparison_snapshot | date == "2020-01-01") %>%
      # select(title,
             # date,
             # species_count,
             # occ_count
      # )
  # }

  # countries_to_keep = d %>%
    # filter(!! rlang::sym(variable) > !! filter_count) %>%
    # pull(title)

  # change part 	
  # d = d %>% 
  # filter(title %in% !! countries_to_keep) %>%
  # tidyr::pivot_wider(names_from = date, values_from = !! rlang::sym(variable)) %>%
  # tidyr::replace_na(list(`2020-01-01` = 0, `2015-01-19` = 0))  %>%
  # mutate(change = `2020-01-01` - `2015-01-19`) %>%
  # group_by(title) %>%
  # summarise(change = max(change)) %>%
  # na.omit() %>%
  # mutate(log10_change = log10(change)) %>%
  # mutate(title = forcats::fct_reorder(title,log10_change)) %>%
  # glimpse()

  # breaks = scales::pretty_breaks(n = 7)(c(0,d$log10_change))
  # print(breaks)
  # 0 1 2 3 4 5 6
  # # breaks = c(0, 1, 2, 3, 4, 5, 6)
  # # labels = c("0","10","100","1K","10K","100K","1M")
  # labels = gbifapi::plot_label_maker(breaks,unit_MK,unit_scale)

  # library(ggplot2)
  # p = ggplot(d,aes(title,log10_change)) +
    # geom_point(size=2) +
    # coord_flip() +
    # xlab("") +
    # ylab(y_lab) +
    # theme_bw() +
    # scale_y_continuous(breaks = breaks,labels=labels,limits=c(3.5,6)) +
    # theme(axis.text.x=element_text(face="plain",size=12,color="#535362")) +
    # theme(axis.text.y=element_text(face="plain",size=6,color="#535362")) +
    # labs(title = plot_title,subtitle = plot_subtitle)
    # theme(legend.position = c(0.9, 0.1)) +
    # theme(legend.title=element_blank()) +
    # scale_color_manual(labels = c(comparison_snapshot_label, "2020"), values = c("#535362",gain_color)) +
    # theme(axis.title.x = element_text(margin = margin(t = 15, r = 0, b = 0, l = 0), size = 12, face="plain",color="#535362")) +
    # theme(plot.title = element_text(color="#535362", size=11, face="bold")) +

  # # return(p)
# # }
    # parameters_num_of_occ_global,

# parameters = 
# parameters_num_species_global %>%
# purrr::transpose()

# path_to_plots = "C:/Users/ftw712/Desktop/gbif_regional_statistics/plots/"

# library(ggplot2)

# parameters %>%
# map( ~
# plot_country_dotplot_change(
# d,
# variable = .x$variable,
# plot_title = .x$plot_title,
# y_lab = .x$y_lab,
# country_text_size = .x$country_text_size,
# gbif_region = .x$gbif_region,
# filter_count = .x$filter_count,
# plot_subtitle = .x$plot_subtitle,
# unit_MK = .x$unit_MK,
# unit_scale = .x$unit_scale,
# gain_color =  .x$gain_color,
# comparison_snapshot = .x$comparison_snapshot,
# comparison_snapshot_label = .x$comparison_snapshot_label,
# plot_lower = FALSE
# )) %>%
# map2(parameters,~{
# ggsave(paste0(path_to_plots,"country dotplots/pdf/change_dotplot_",.y$variable,"_",.y$gbif_region,".pdf"),plot=.x,width=6,height=5)
# ggsave(paste0(path_to_plots,"country dotplots/svg/change_dotplot_",.y$variable,"_",.y$gbif_region,".svg"),plot=.x,width=6,height=5)
# ggsave(paste0(path_to_plots,"country dotplots/jpg/change_dotplot_",.y$variable,"_",.y$gbif_region,".jpg"),plot=.x,width=6,height=5,dpi=600)
# })

}


if(FALSE) { # hexagon species count blue green plot_poly_map_gaps

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

getLabels = function(breaks) {

  Start = 2:length(breaks) %>% map_dbl(~breaks[.x-1])
  Finish = 1:(length(breaks)-1) %>% map_dbl(~breaks[.x+1])

  return(paste0(Start,"-",Finish))
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

  # countries = map_data("world")
countries = gbifapi::ggplot2_small_map_data(dTolerance=1.2)
  
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


hexagon_plot_global = function(D,
                         isea3h = gbifregionalstats::isea3h_res6,
                         variable_ = "num_species",
                         legend_title_="number of species",
                         breaks_ = c(0,5000,60000),
                         filter_column_string = NULL,
                         filter_column_value = NULL
                        ) {


  D = D %>%
    mutate(id = as.integer(polygon_id)) %>%
    merge(isea3h,id="id",all.y=TRUE) %>%
    mutate(long = lon) %>%
    mutate(lat = lat) %>%
    mutate(group = id) %>%
    filter(!date_line_polygon) %>%
    filter(!is.na(iso2)) %>%
    arrange(ordering)

  D %>% glimpse()

  # library(gbifrasters)
  library(ggplot2)

  p = plot_poly_map_gaps(grid = D,
                  variable = variable_,
                  breaks=breaks_,
                  labels=NULL,
                  legend_title=legend_title_,
                  pretty_breaks=7,
                  zoom_x=c(-165,165),
                  zoom_y=c(-55,80),
                  legend.position = c(.50,-0.05),
                  polygon_text_size=2,
                  polygon_alpha=0.6,
                  labelType="",
                  keywidth=0.01,
                  keyheight=0.2,
                  legend_text_size=12,
                  numBreaks=7,
                  breaksType="fancy",
                  country_line_color = "#c3c4c4")

  return(p)
}



library(ggplot2)
library(dplyr)
library(purrr)
library(roperators)

vars = tibble::tribble(
~breaks,~variable_,~legend_title_,
c(0,5000,10000,55000),"num_species","species count"
) %>% purrr::transpose()

vars

D = data.table::fread("C:/Users/ftw712/Desktop/gbif_regional_statistics/data/polygon_counts_isea3h_res6.tsv") %>% 
glimpse()

vars %>%
map(~ 
hexagon_plot_global(D,
isea3h = gbifregionalstats::isea3h_res6,
variable_ = .x$variable_,
legend_title_=.x$legend_title_,
breaks_ = .x$breaks,
filter_column_string = NULL,
filter_column_value = NULL
)) %>%
map2(vars,~ 
{
ggsave(paste0("C:/Users/ftw712/Desktop/gbif_regional_statistics/plots/hexagon plots/pdf/global_",.y$variable_,".pdf"),plot=.x,scale=1,width=9,height=5)
ggsave(paste0("C:/Users/ftw712/Desktop/gbif_regional_statistics/plots/hexagon plots/svg/global_",.y$variable_,".svg"),plot=.x,scale=1,width=9,height=5)
ggsave(paste0("C:/Users/ftw712/Desktop/gbif_regional_statistics/plots/hexagon plots/jpg/global_",.y$variable_,".jpg"),plot=.x,scale=1,width=9,height=5,dpi=900)
})

}

# if(FALSE) { # plot regions separately 

library(ggplot2)
library(dplyr)
library(purrr)
library(roperators)
library(gbifregionalstats)

vars = tibble::tribble(
~gbif_region,~region_value,~orientation, ~xlim_ortho, ~ylim_ortho,~breaks,~variable_,~legend_title_,
"europe","Europe",c(50.72,20,4.5),c(-25,70), c(75,25),c(0,5000,10000,55000),"num_species","species count",
"afrca", "Africa",c(0.7901464,22.8335061,4.26),c(-25,70),c(-40,40),c(0,5000,10000,55000),"num_species","species count",
"latin america","Americas",c(-17.60,-60.62,4),c(-100.85,-24.21),c(-61.36,27.51),c(0,5000,10000,55000),"num_species","species count",
"asia", "Asia", c(26.6078252,98.0344816,3.66), c(-32.14,178.39), c(-13.43,79.00), c(0,5000,10000,55000),"num_species","species count",
"north america", "Americas", c(47.2058929,-97.297683,3.88), c(-171.91,-9.48), c(9.88,84.27), c(0,5000,10000,55000),"num_species","species count",
"oceania", "Oceania", c(-13.4796711,152.8237114,4.04), c(100.87,-175.45), c(-51.8,5.19), c(0,5000,10000,55000),"num_species","species count"
) %>% 
purrr::transpose()

# filter(gbif_region=="oceania") %>%

# POLYGON((-171.91 84.27,-9.48 84.27,-9.48 9.88,-171.91 9.88,-171.91 84.27))
# POLYGON((100.87 5.19,-175.45 5.19,-175.45 -51.8,100.87 -51.88,100.87 5.19))

D = data.table::fread("C:/Users/ftw712/Desktop/gbif_regional_statistics/data/polygon_counts_isea3h_res6.tsv") %>% 
glimpse()

# filter(variable_ == "num_species") %>%
# vars

plots = vars %>%
map(~
stats_plotter(D,
isea3h = gbifregionalstats::isea3h_res6,
variable_ = .x$variable_,
legend_title_=.x$legend_title_,
breaks_ = .x$breaks,
filter_column_string = NULL,
filter_column_value = NULL,
orientation = .x$orientation,
xlim_ortho = .x$xlim_ortho,
ylim_ortho = .x$ylim_ortho,
region_value = toupper(.x$gbif_region)
)) %>%
map2(vars,~ {
ggsave(paste0("C:/Users/ftw712/Desktop/gbif_regional_statistics/plots/hexagon plots/pdf/",.y$gbif_region,"_",.y$variable_,".pdf"),plot=.x,scale=1,width=9,height=5)
# ggsave(paste0("C:/Users/ftw712/Desktop/gbif_regional_statistics/plots/hexagon plots/",.y$gbif_region,"_",.y$variable_,".svg"),plot=.x,scale=1,width=9,height=5)
# ggsave(paste0("C:/Users/ftw712/Desktop/gbif_regional_statistics/plots/hexagon plots/",.y$gbif_region,"_",.y$variable_,".jpg"),plot=.x,scale=1,width=9,height=5,dpi=600)
})

if(FALSE) {
}

