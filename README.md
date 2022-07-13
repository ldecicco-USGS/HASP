# HASP: Hydrologic AnalySis Package <img src="man/figures/R_logo.png" alt="HASP" class="logo" style="width:90px;height:auto;" align="right" />

[![R build
status](https://code.usgs.gov/water/stats/hasp/badges/master/pipeline.svg)](https://code.usgs.gov/water/stats/hasp/pipelines)
[![status](https://img.shields.io/badge/USGS-Research-blue.svg)](https://owi.usgs.gov/R/packages.html#research)
[![status](https://img.shields.io/badge/USGS-Documentation-blue.svg)](https://rconnect.usgs.gov/HASP/)
[![status](https://img.shields.io/badge/USGS-Source-orange.svg)](https://code.usgs.gov/water/stats/hasp)

*H*ydrologic *A*naly*S*is *P*ackage

The [Hydrologic Analysis Package
(HASP)](https://code.usgs.gov/water/stats/hasp) can retrieve groundwater
level and groundwater quality data, aggregate these data, plot them, and
generate basic statistics. One of the benefits of HASP is its ability to
aggregate two time-series of data into one record and generate
statistics and graphics on that record. By merging two data sets
together, users can view and manipulate a much longer record of data.
Users can download the aggregated record and see basic statistics that
have been calculated with these data. HASP also allows users to plot
groundwater level trends in major aquifers as well. The explore_aquifers
function allows users to pull data from wells classified in Principal
Aquifers and synthesize water-level data to better understand trends.

Inspiration: <https://fl.water.usgs.gov/mapper/>

See <https://usgs-r.github.io/HASP/> for more information!

## Sample workflow

### Single site workflows:

``` r
library(HASP)
library(dataRetrieval)
site <- "263819081585801"

#Field GWL data:
gwl_data <- dataRetrieval::readNWISgwl(site)

# Daily data:
parameterCd <- "62610"
statCd <- "00001"
dv <- dataRetrieval::readNWISdv(site,
                                parameterCd,
                                statCd = statCd)

# Water Quality data:
parameterCd <- c("00095","90095","00940","99220")
qw_data <- dataRetrieval::readWQPqw(paste0("USGS-", site),
                                    parameterCd)
```

``` r
y_axis_label <- dataRetrieval::readNWISpCode("62610")$parameter_nm

monthly_frequency_plot(dv,
                       parameter_cd = "62610",
                       plot_title = "L2701_example_data",
                       y_axis_label = y_axis_label)
```

![](man/figures/README-graphs-1.png)<!-- -->

``` r
gwl_plot_all(gw_level_dv = dv, 
             gwl_data = gwl_data, 
             parameter_cd = "62610",
             plot_title = "L2701_example_data", 
             add_trend = TRUE, flip_y = FALSE)
```

![](man/figures/README-graphs-2.png)<!-- -->

``` r
Sc_Cl_plot(qw_data, "L2701_example_data")
```

![](man/figures/README-graphs-3.png)<!-- -->

``` r
trend_plot(qw_data, plot_title = "L2701_example_data")
```

![](man/figures/README-graphs-4.png)<!-- -->

### Composite workflows:

``` r
#included sample data:

aquifer_data <- aquifer_data
num_years <- 30

plot_composite_data(aquifer_data, num_years)
```

![](man/figures/README-example-1.png)<!-- -->

``` r
plot_normalized_data(aquifer_data, num_years)
```

![](man/figures/README-example-2.png)<!-- -->

## Shiny App

<p align="center">
<img src="https://code.usgs.gov/water/stats/HASP/raw/master/man/figures/app.gif" alt="app_demo">
</p>

## Installation of R and RStudio

To use the HASP package, you will need to have R and RStudio installed
on your computer. This installation will only need to be done once for
each computer. This link has instructions for installing R and RStudio:

[R and RStudio Installation
Instructions](https://owi.usgs.gov/R/training-curriculum/installr/)

Useful links:

-   [Download R Windows](https://cran.r-project.org/bin/windows/base/)
-   [Download R Mac](https://cran.r-project.org/bin/macosx/)
-   [Download
    RStudio](https://www.rstudio.com/products/rstudio/download/)

## Installation of HASP

You can install the `HASP` package using the `remotes` package.

To install the remotes package, copy the following line into R or the
“Console” window in RStudio:

``` r
install.packages("remotes")
```

To install the `HASP` package:

``` r
remotes::install_gitlab("water/stats/hasp",
                        host = "code.usgs.gov",
                        build_opts = c("--no-resave-data",
                                       "--no-manual"),
                        build_vignettes = TRUE, 
                        dependencies = TRUE)
```

During this installation, you may be prompted to update or install some
packages. Press 3 to skip the updates, but don’t forget to update all of
your packages later.

## Running the apps

`HASP` includes two interactive applications as a way to explore the
functionality of this package. One has functions for exploring data from
a single site, and the other has functions for exploring data from an
aquifer.

To run the single site application, use the following code:

``` r
HASP::explore_site()
```

To run the aquifer application use the following code:

``` r
HASP::explore_aquifers()
```

## Disclaimer

This software is preliminary or provisional and is subject to revision.
It is being provided to meet the need for timely best science. The
software has not received final approval by the U.S. Geological Survey
(USGS). No warranty, expressed or implied, is made by the USGS or the
U.S. Government as to the functionality of the software and related
material nor shall the fact of release constitute any such warranty. The
software is provided on the condition that neither the USGS nor the U.S.
Government shall be held liable for any damages resulting from the
authorized or unauthorized use of the software.
