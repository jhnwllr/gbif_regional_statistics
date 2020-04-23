# GBIF regional statistics 

Plots and statistics generated for GBIF regions. 

![](https://raw.githubusercontent.com/jhnwllr/gbif_regional_statistics/master/plots/gbif%20region%20map/svg/gbif_region_map.svg)

### How to make plots

Install R packages. 
You might need to install some other dependecies from CRAN too. 

```
devtools::install_github("jhnwllr/gbifapi")
devtools::install_github("jhnwllr/gbifregionalstats", subdir="gbif_regional_statistics")
```

1. Open `/gbif_regional_statistics/gbifregionalstats/plot_gallery_notebook.rmd` in Rstudio
2. Run code chunk corresponding to plot that you want. 

### Running spark code to update data 

1. Find chunks in `/gbif_regional_statistics/gbifregionalstats/plot_gallery_notebook.rmd` with scala code. 
2. These need to run inside a `spark2-shell` instance on c4 or c5. 
3. csv files will be saved to `/mnt/auto/misc/download.gbif.org/custom_download/jwaller/`

The csv small csv files will be put in the public downloads folder, so they are accessible by the R scripts. 

### Plot Examples 

![](https://raw.githubusercontent.com/jhnwllr/gbif_regional_statistics/master/plots/comparison%20barchart/svg/gbif_regions_occ_count.svg)
![](https://raw.githubusercontent.com/jhnwllr/gbif_regional_statistics/master/plots/country%20dotplots/svg/country_dotplot_species_count_Asia.svg)

 



